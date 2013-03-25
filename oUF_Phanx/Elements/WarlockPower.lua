--[[--------------------------------------------------------------------
	oUF_WarlockPower
	by Phanx <addons@phanx.net>
	Adds support for the new (in WoW 5.0) warlock resources.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.
----------------------------------------------------------------------]]

local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local WARLOCK_SOULBURN = WARLOCK_SOULBURN
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS

local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
local WARLOCK_METAMORPHOSIS = WARLOCK_METAMORPHOSIS
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY

local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local WARLOCK_BURNING_EMBERS = WARLOCK_BURNING_EMBERS
local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local MAX_POWER_PER_EMBER = MAX_POWER_PER_EMBER

local powerTypes = {
	SOUL_SHARDS = true,
	DEMONIC_FURY = true,
	BURNING_EMBERS = true,
	[SPEC_WARLOCK_AFFLICTION] = "SOUL_SHARDS",
	[SPEC_WARLOCK_DEMONOLOGY] = "DEMONIC_FURY",
	[SPEC_WARLOCK_DESTRUCTION] = "BURNING_EMBERS",
}

local spellForSpec = {
	[SPEC_WARLOCK_AFFLICTION] = WARLOCK_SOULBURN,
	[SPEC_WARLOCK_DESTRUCTION] = WARLOCK_BURNING_EMBERS,
}

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event, unit)
	local element = self.WarlockPower

	self:UnregisterEvent("SPELLS_CHANGED", UpdateVisibility)
	self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
	self:UnregisterEvent("UNIT_POWER", Path)

	element.powerType = nil

	if element.Hide then
		element:Hide()
	else
		for i = 1, #element do
			element[i]:Hide()
		end
	end

	if UnitHasVehicleUI("player") then
		return
	end

	local spec = GetSpecialization()
	if not spec or spellForSpec[spec] and not IsPlayerSpell(spellForSpec[spec]) then
		return self:RegisterEvent("SPELLS_CHANGED", UpdateVisibility, true)
	end

	element.spec = spec
	element.powerType = powerTypes[spec]

	if element.areOrbs then -- oooorrrrbssss!
		if spec == SPEC_WARLOCK_DEMONOLOGY then
			element:SetOrientation("HORIZONTAL")
			element:SetReverseFill(true)
		elseif spec == SPEC_WARLOCK_DESTRUCTION then
			element:SetOrientation("VERTICAL")
			element:SetReverseFill(false)
		end
	end

	if element.Show then
		element:Show()
	end

	self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
	self:RegisterEvent("UNIT_POWER", Path)
	Update(self, "UpdateVisibility", "player")
end

function Update(self, event, unit, powerType)
	local element = self.WarlockPower
	if self.unit ~= unit or not element.powerType or (powerType and powerType ~= element.powerType) then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	--print("WarlockPower Update", powerType)
	if not powerType then
		powerType = element.powerType
	end

	local power, maxPower

	-- Affliction
	if powerType == "SOUL_SHARDS" then
		power = UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
		maxPower = UnitPowerMax(unit, SPELL_POWER_SOUL_SHARDS)
		--print(powerType, power, "/", maxPower)

		if element.SetValue then
			element:SetMinMaxValues(0, maxPower)
			element:SetValue(power)
		else
			for i = 1, #element do
				local shard = element[i]
				if i <= power then
					if shard.SetValue then
						shard:SetMinMaxValues(0, 1)
						shard:SetValue(1)
					else
						shard:SetAlpha(1)
					end
					shard:Show()
				elseif i <= maxPower then
					if shard.SetValue then
						shard:SetMinMaxValues(0, 1)
						shard:SetValue(0)
					else
						shard:SetAlpha(0.25)
					end
					shard:Show()
				else
					shard:Hide()
				end
			end
		end

	-- Demonology
	elseif powerType == "DEMONIC_FURY" then
		power = UnitPower(unit, SPELL_POWER_DEMONIC_FURY)
		maxPower = UnitPowerMax(unit, SPELL_POWER_DEMONIC_FURY)
		--print(powerType, power, "/", maxPower)

		local activated
		for i = 1, 40 do
			local name, _, _, _, _, _, _, _, _, _, spell = UnitBuff(unit, i)
			if not spell then
				break
			end
			if spell == WARLOCK_METAMORPHOSIS then
				activated = true
				break
			end
		end

		if element.SetValue then
			element:SetMinMaxValues(power, maxPower)
			element:SetValue(power)
		else
			local valuePerPart = maxPower / #element
			for i = 1, #element do
				local part = element[i]
				if power > valuePerPart then
					--print(i, "Full")
					if part.SetValue then
						part:SetMinMaxValues(0, valuePerPart)
						part:SetValue(valuePerPart)
					else
						part:SetAlpha(1)
					end
					part:Show()
					power = power - valuePerPart
				elseif power > 0 then
					--print(i, "Partial", power)
					if part.SetValue then
						--print("part.SetValue")
						part:SetMinMaxValues(0, valuePerPart)
						part:SetValue(power)
					else
						--print("part.SetAlpha")
						local percent = power / valuePerPart
						part:SetAlpha(1 - (0.75 * (percent)))
					end
					part:Show()
					power = 0
				else
					--print(i, "Empty")
					if part.SetValue then
						part:SetMinMaxValues(0, valuePerPart)
						part:SetValue(0)
					else
						part:SetAlpha(0.25)
					end
					part:Show()
				end
			end
		end

	-- Destruction
	elseif powerType == "BURNING_EMBERS" then
		power = UnitPower(unit, SPELL_POWER_BURNING_EMBERS, true)
		maxPower = UnitPowerMax(unit, SPELL_POWER_BURNING_EMBERS, true)

		local numWhole = floor(power / MAX_POWER_PER_EMBER)
		local maxWhole = floor(maxPower / MAX_POWER_PER_EMBER)

		local part = power % MAX_POWER_PER_EMBER

		if element.SetValue then
			--print("element.SetValue")
			element:SetMinMaxValues(0, maxPower)
			element:SetValue(power)
		else
			--print("#elements")
			for i = 1, #element do
				local ember = element[i]
				if i > maxWhole then
					--print(i, "Hide")
					ember:Hide()
				else
					--print(i, "Show")
					if power > MAX_POWER_PER_EMBER then
						--print(i, "Full")
						if ember.SetValue then
							ember:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
							ember:SetValue(MAX_POWER_PER_EMBER)
						else
							ember:SetAlpha(1)
						end
						if ember.bg then
							ember.bg:SetVertexColor(1, 0.6, 0)
						end
						ember:Show()
						power = power - MAX_POWER_PER_EMBER
					elseif power > 0 then
						--print(i, "Partial", power, part)
						if ember.SetValue then
							ember:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
							ember:SetValue(power)
						else
							local percent = power / MAX_POWER_PER_EMBER
							ember:SetAlpha(1 - (0.75 * (percent)))
						end
						ember:Show()
						power = 0
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
	end

	if element.PostUpdate then
		return element:PostUpdate(power, maxPower, powerType)
	end
end

function Path(self, ...)
	return (self.WarlockPower.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self, unit)
	local element = self.WarlockPower
	if element and unit == "player" then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
		self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
		self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

		UpdateVisibility(self, nil, "player")

		return true
	end
end

function Disable(self)
	local element = self.WarlockPower
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

oUF:AddElement("WarlockPower", Path, Enable, Disable)