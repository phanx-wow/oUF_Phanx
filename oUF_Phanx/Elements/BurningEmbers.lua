
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF is missing!")

local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local WARLOCK_BURNING_EMBERS = WARLOCK_BURNING_EMBERS
local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local MAX_POWER_PER_EMBER = MAX_POWER_PER_EMBER

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event, unit)
	local element = self.BurningEmbers

	if GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION or not IsPlayerSpell(WARLOCK_BURNING_EMBERS)
	or SecureCmdOptionParse("[overridebar][possessbar][vehicleui][@vehicle,exists]hide") == "hide" then
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		self:UnregisterEvent("UNIT_POWER", Path)

		if element.Hide then
			element:Hide()
		end
		for i = 1, #element do
			element[i]:Hide()
		end

		element.disabled = true
	end

	element.disabled = nil

	if element.Show then
		element:Show()
	end

	self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
	self:RegisterEvent("UNIT_POWER", Path)

	element:ForceUpdate()
end

function Update(self, event, unit, powerType)
	if (unit and unit ~= self.unit) or (powerType and powerType ~= "BURNING_EMBERS") then return end
	local element = self.BurningEmbers
	if element.disabled then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local embers = UnitPower(unit, SPELL_POWER_BURNING_EMBERS, true)
	local embersMax = UnitPowerMax(unit, SPELL_POWER_BURNING_EMBERS, true)

	local whole = floor(embers / MAX_POWER_PER_EMBER)
	local wholeMax = floor(embersMax / MAX_POWER_PER_EMBER)
	local parts = embers % MAX_POWER_PER_EMBER

	if element.SetValue then
		element:SetMinMaxValues(0, embersMax)
		element:SetValue(embers)
	else
		local rest = embers
		for i = 1, #element do
			local ember = element[i]
			ember.activated = false
			if i > wholeMax then
				--print(i, "Hide")
				ember:Hide()
			else
				--print(i, "Show")
				if rest >= MAX_POWER_PER_EMBER then
					--print(i, "Full")
					if ember.SetValue then
						ember:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
						ember:SetValue(MAX_POWER_PER_EMBER)
					else
						ember:SetAlpha(1)
					end
					ember.activated = true
					ember:Show()
					rest = rest - MAX_POWER_PER_EMBER
				elseif rest > 0 then
					--print(i, "Partial", rest, parts)
					if ember.SetValue then
						ember:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
						ember:SetValue(rest)
					else
						ember:SetAlpha(1 - (0.75 * (rest / MAX_POWER_PER_EMBER)))
					end
					ember:Show()
					rest = 0
				else
					--print(i, "Empty")
					if ember.SetValue then
						ember:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
						ember:SetValue(0)
					else
						ember:SetAlpha(0.25)
					end
					ember:Show()
				end
			end
		end
	end

	if element.PostUpdate then
		element:PostUpdate(embers, embersMax, SPELL_POWER_BURNING_EMBERS)
	end
end

function Path(self, ...)
	return (self.BurningEmbers.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self, unit)
	local element = self.BurningEmbers
	if element and unit == "player" then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		for i = 1, #element do
			if element.SetValue then
				element:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
			end
		end

		self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
		self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
		self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

		UpdateVisibility(self, nil, "player")

		return true
	end
end

function Disable(self)
	local element = self.BurningEmbers
	if element then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)

		self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility)
		self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
		self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

		if element.Hide then
			element:Hide()
		else
			for i = 1, #element do
				element[i]:Hide()
			end
		end
	end
end

oUF:AddElement("BurningEmbers", Path, Enable, Disable)
