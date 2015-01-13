--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2015 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
------------------------------------------------------------------------
	Element to show Wild Mushrooms like combo points.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone module.

	Usage:

	frame.WildMushrooms = {}
	for i = 1, MAX_TOTEMS do
		frame.WildMushrooms[i] = frame:CreateTexture(nil, "OVERLAY")
	end

	Supports PreUpdate, PostUpdate, and Override.
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_WildMushrooms requires oUF")

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event)
	local element = self.WildMushrooms

	local spec = GetSpecialization()
	if spec == 2 or spec == 3 or UnitHasVehicleUI("player") then
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE", Path)
		element.__disabled = true
		for i = 1, #element do
			element[i]:Hide()
		end
		return
	end

	element.__disabled = nil
	self:RegisterEvent("PLAYER_TOTEM_UPDATE", Path, true)
	Update(self, "UpdateVisibility")
end

function Update(self, event)
	local element = self.WildMushrooms
	if element.__disabled then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	for i = 1, MAX_TOTEMS do
		local exists, name, start, duration, icon = GetTotemInfo(i)
		if duration > 0 then
			element[i]:Show()
		else
			element[i]:Hide()
		end
	end

	if element.PostUpdate then
		return element:PostUpdate()
	end
end

function Path(self, ...)
	return (self.WildMushrooms.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate")
end

function Enable(self)
	local element = self.WildMushrooms
	if not element then return end

	element.__name = "WildMushrooms"
	element.__owner = self
	element.ForceUpdate = ForceUpdate

	for i = 1, #element do
		local obj = element[i]
		if obj:IsObjectType("Texture") and not obj:GetTexture() then
			obj:SetTexture([[Interface\ComboFrame\ComboPoint]])
			obj:SetTexCoord(0, 0.375, 0, 1)
		end
		if i > MAX_TOTEMS then
			obj:Hide()
		end
	end

	self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
	self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	TotemFrame.Show = TotemFrame.Hide
	TotemFrame:Hide()

	TotemFrame:UnregisterEvent("PLAYER_TOTEM_UPDATE")
	TotemFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	TotemFrame:UnregisterEvent("UPDATE_SHAPESHIFT_FORM")
	TotemFrame:UnregisterEvent("PLAYER_TALENT_UPDATE")

	UpdateVisibility(self, "Enable")
	return true
end

function Disable(self)
	local element = self.WildMushrooms
	if not element then return end

	self:UnregisterEvent("PLAYER_TOTEM_UPDATE", Update)
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility)
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	for i = 1, #element do
		element[i]:Hide()
	end

	TotemFrame.Show = nil
	TotemFrame:Show()

	TotemFrame:RegisterEvent("PLAYER_TOTEM_UPDATE")
	TotemFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TotemFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	TotemFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
end

oUF:AddElement("WildMushrooms", Path, Enable, Disable)
