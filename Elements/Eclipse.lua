--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
------------------------------------------------------------------------
	Element to display demonic fury on oUF frames.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "Eclipse element requires oUF")

local colors = {
	sun  = { 132/255, 41/255, 235/255 },
	moon = { 132/255, 235/255, 41/255 },
}

local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE

local UpdateVisibility, UpdateDirection, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event, unit)
	local element = self.Eclipse
	local direction = GetEclipseDirection() or "none"
	local hidden = direction == "none" or UnitHasVehicleUI("player") or GetSpecialization() ~= 1
	if element.hidden == hidden then return end
	element.hidden = hidden

	if hidden then
		element:Hide()
	else
		local color = colors[direction]
		local r, g, b = color[1], color[2], color[3]
		local bg = element.bg
		if bg then
			local mu = bg.multiplier or 0.5
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
		element:SetStatusBarColor(r, g, b)
		element:Show()
	end

	if element.PostUpdateVisibility then
		element:PostUpdateVisibility(hidden, direction)
	end
end

function Update(self, event, unit, powerType)
	if powerType and powerType ~= "ECLIPSE" then return end
	
	local element = self.Eclipse
	if element.hidden then return end

	local powerMax = UnitPowerMax("player", SPELL_POWER_ECLIPSE)
	if powerMax == 0 then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local power = abs(UnitPower("player", SPELL_POWER_ECLIPSE))

	element:SetMinMaxValues(0, powerMax)
	element:SetValue(power)

	if element.PostUpdate then
		element:PostUpdate(power, powerMax)
	end
end

function Path(self, ...)
	return (self.Eclipse.Override or Update)(self, ...)
end

function ForceUpdate(element)
	UpdateVisibility(element, "ForceUpdate")
	UpdateDirection(element, "ForceUpdate")
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self, unit)
	local element = self.Eclipse
	if not element or self.unit ~= "player" then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	if element.GetStatusBarTexture and not element:GetStatusBarTexture() then
		element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	end

	self:RegisterEvent("ECLIPSE_DIRECTION_CHANGE", UpdateVisibility, true)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateVisibility, true)
	self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	UpdateVisibility(self, "Enable", "player")
	return true
end

function Disable(self)
	local element = self.Eclipse
	if not element then return end

	element:Hide()

	self:UnregisterEvent("ECLIPSE_DIRECTION_CHANGE", UpdateVisibility)
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility)
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateVisibility)
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)
end

oUF:AddElement("Eclipse", Path, Enable, Disable)
