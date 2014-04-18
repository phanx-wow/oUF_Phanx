--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
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

local METAMORPHOSIS_FORM = 22
local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY

oUF.colors.power.DEMONIC_FURY = { 132/255, 41/255, 235/255 }
oUF.colors.power.METAMORPHOSIS = { 132/255, 235/255, 41/255 }

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event, unit)
	local element = self.DemonicFury

	if UnitHasVehicleUI("player") or GetSpecialization() ~= SPEC_WARLOCK_DEMONOLOGY then
		self:UnregisterEvent("SHAPESHIFT_FORM_CHANGED", Path)
		self:UnregisterEvent("UNIT_POWER", Path)
		element:Hide()
		return
	end

	element:Show()
	self:RegisterEvent("SHAPESHIFT_FORM_CHANGED", Path, true)
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
	local inMetamorphosis = GetShapeshiftFormID() == METAMORPHOSIS_FORM
	local color = oUF.colors.power[inMetamorphosis and "METAMORPHOSIS" or "DEMONIC_FURY"]
	local r, g, b = color[1], color[2], color[3]

	element:SetMinMaxValues(0, furyMax)
	element:SetValue(fury)
	element:SetStatusBarColor(r, g, b)

	local bg = element.bg
	if bg then
		local mu = bg.multiplier or 1
		bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	if element.PostUpdate then
		element:PostUpdate(fury, furyMax, "DEMONIC_FURY", inMetamorphosis)
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

	self:UnregisterEvent("SHAPESHIFT_FORM_CHANGED", Path)
	self:UnregisterEvent("UNIT_POWER", Path)

	self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility)
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	element:Hide()
end

oUF:AddElement("DemonicFury", Path, Enable, Disable)
