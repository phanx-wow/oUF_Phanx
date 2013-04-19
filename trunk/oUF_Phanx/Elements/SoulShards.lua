--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Element to display soul shards on oUF frames.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.
------------------------------------------------------------------------
	Usage #1:

	self.SoulShards = {} -- may also be a frame
	for i = 1, 5 do
		self.SoulShards[i] = self:CreateTexture(nil, "OVERLAY")
	end
------------------------------------------------------------------------
	Usage #2:

	self.SoulShards = CreateFrame("StatusBar", nil, self)
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "SoulShards element requires oUF")

local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
local WARLOCK_SOULBURN = WARLOCK_SOULBURN

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event, unit)
	local element = self.SoulShards

	if UnitHasVehicleUI("player") or GetSpecialization() ~= SPEC_WARLOCK_AFFLICTION or not IsPlayerSpell(WARLOCK_SOULBURN) then
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		self:UnregisterEvent("UNIT_POWER", Path)

		element.__disabled = true

		for i = 1, #element do
			element[i]:Hide()
		end
		if element.Hide then
			element:Hide()
		end

		return
	end

	element.__disabled = nil

	if element.Show then
		element:Show()
	end

	self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
	self:RegisterEvent("UNIT_POWER", Path)

	Update(self, "UpdateVisibility", unit)
end

function Update(self, event, unit, powerType)
	if unit ~= self.unit or (powerType and powerType ~= "SOUL_SHARDS") then return end
	local element = self.SoulShards
	if element.__disabled then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local shards = UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
	local shardsMax = UnitPowerMax(unit, SPELL_POWER_SOUL_SHARDS)

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
		element:PostUpdate(shards, shardsMax, SPELL_POWER_SOUL_SHARDS)
	end
end

function Path(self, ...)
	return (self.SoulShards.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local element = self.SoulShards
	if not element or self.unit ~= "player" then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateVisibility, true)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
	self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	UpdateVisibility(self, "Enable")
	return true
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
