
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF is missing!")

local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
local WARLOCK_SOULBURN = WARLOCK_SOULBURN

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event, unit)
	local element = self.SoulShards

	self:UnregisterEvent("SPELLS_CHANGED", UpdateVisibility)
	self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
	self:UnregisterEvent("UNIT_POWER", Path)

	if element.Hide then
		element:Hide()
	end
	for i = 1, #element do
		element[i]:Hide()
	end

	element.disabled = true

	if SecureCmdOptionParse("[overridebar][possessbar][vehicleui][@vehicle,exists]hide") == "hide" then
		return
	end
	if GetSpecialization() ~= SPEC_WARLOCK_AFFLICTION then
		return
	end
	if not IsPlayerSpell(WARLOCK_SOULBURN) then
		self:RegisterEvent("SPELLS_CHANGED", UpdateVisibility)
		return
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
	if unit ~= self.unit or (powerType and powerType ~= SPELL_POWER_SOUL_SHARDS) then return end
	if not powerType then powerType = SPELL_POWER_SOUL_SHARDS end
	local element = self.SoulShards
	if element.disabled then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local shards = UnitPower(unit, powerType)
	local shardsMax = UnitPowerMax(unit, powerType)

	if element.SetValue then
		element:SetMinMaxValues(0, shardsMax)
		element:SetValue(shards)
	else
		for i = 1, #element do
			local shard = element[i]
			if i > shardsMax then
				shard:Hide()
			elseif i > shards then
				if shard.SetValue then
					shard:SetMinMaxValues(0, 1)
					shard:SetValue(0)
				else
					shard:SetAlpha(0.25)
				end
				shard:Show()
			else
				if shard.SetValue then
					shard:SetMinMaxValues(0, 1)
					shard:SetValue(1)
				else
					shard:SetAlpha(1)
				end
				shard:Show()
			end
		end
	end

	if element.PostUpdate then
		element:PostUpdate(shards, shardsMax, powerType)
	end
end

function Path(self, ...)
	return (self.SoulShards.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self, unit)
	local element = self.SoulShards
	if element and unit == "player" then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateVisibility, true)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
		self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
		self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

		UpdateVisibility(self, nil, "player")

		return true
	end
end

function Disable(self)
	local element = self.SoulShards
	if element then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)

		self:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateVisibility)
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

oUF:AddElement("SoulShards", Path, Enable, Disable)
