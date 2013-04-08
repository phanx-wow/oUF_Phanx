--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Element to display demonic fury on oUF frames.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "DemonicFury element requires oUF")

local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY
local WARLOCK_METAMORPHOSIS = GetSpellInfo(WARLOCK_METAMORPHOSIS)

local color = { 247/255, 40/255, 255/255 }
oUF.colors.power.DEMONIC_FURY = color

local metacolor = { 132/255, 235/255, 41/255 }
oUF.colors.power.METAMORPHOSIS = color

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event, unit)
	local element = self.DemonicFury

	if UnitInVehicle("player") or UnitHasVehicleUI("player") or GetSpecialization() ~= SPEC_WARLOCK_DEMONOLOGY then
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		self:UnregisterEvent("UNIT_POWER", Path)

		element:Hide()
		return
	end

	element:Show()

	self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
	self:RegisterEvent("UNIT_POWER", Path)

	Update(self, "UpdateVisibility", "player")
end

function Update(self, event, unit, powerType)
	if powerType and powerType ~= "DEMONIC_FURY" then return end
	local element = self.DemonicFury
	if not element:IsShown() then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local fury = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
	local furyMax = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)

	element:SetMinMaxValues(0, furyMax)
	element:SetValue(fury)

	if UnitBuff("player", WARLOCK_METAMORPHOSIS) then
		element.activated = true
		element:SetStatusBarColor(metacolor[1], metacolor[2], metacolor[3])
	else
		element.activated = nil
		element:SetStatusBarColor(color[1], color[2], color[3])
	end

	if element.PostUpdate then
		element:PostUpdate(fury, furyMax, powerType)
	end
end

function Path(self, ...)
	return (self.DemonicFury.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self, unit)
	local element = self.DemonicFury
	if not element or self.unit ~= "player" then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	if element.GetStatusBarTexture and not element:GetStatusBarTexture() then
		element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	end

	self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
	self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	UpdateVisibility(self, "Enable", "player")
	return true
end

function Disable(self)
	local element = self.DemonicFury
	if not element then return end

	self:UnregisterEvent("UNIT_POWER", Path)
	self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)

	self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility)
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	element:Hide()
end

oUF:AddElement("DemonicFury", Path, Enable, Disable)
