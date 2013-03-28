--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Element to track stacking self-buffs like combo points.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.
------------------------------------------------------------------------
	Usage:

	self.PowerStack = {
		buff = GetSpellInfo(53817) -- Gets localized spell name for Maelstrom Weapon
	}
	for i = 1, 5 do
		self.PowerStack[i] = CreateTexture(nil, "OVERLAY")
		self.PowerStack[i]:SetSize(20, 20)
		if i == 1 then
			self.PowerStack[i]:SetPoint("LEFT", self, "BOTTOMLEFT", 5, 0)
		else
			self.PowerStack[i]:SetPoint("LEFT", self.PowerStack[i-1], "RIGHT", 0, 0)
		end
	end
------------------------------------------------------------------------
	Notes:

	Only works for the player unit. Only supports one buff per frame.

	Spell IDs are *not* currently supported, as the WoW API does not
	support looking up buffs directly by ID.

	Override function is supported. PreUpdate/PostUpdate are not.

	The individual objects do not have to be textures. They can be
	frames, fontstrings, or even basic tables, as long as they have
	Show, Hide, SetAlpha, and IsObjectType methods.

	The buff to track can be changed dynamically (for example, when
	the player's spec changes) by the layout.
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "PowerStack element requires oUF")

local UnitBuff = UnitBuff

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event)
	local element = self.PowerStack

	if UnitInVehicle("player") or UnitHasVehicleUI("player") then
		self:UnregisterEvent("UNIT_AURA", Path)
		for i = 1, #element do
			element[i]:Hide()
		end
		element.__disabled = true
		return
	end

	element.__disabled = false
	self:RegisterEvent("UNIT_AURA", Path)
	Update(self, "UpdateVisibility", self.unit)
end

function Update(self, event, unit)
	if unit ~= self.unit then return end
	local element = self.PowerStack
	if element.__disabled then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local _, _, _, count = UnitBuff("player", element.buff)
	count = count or 0

	if count == element.__count then
		return
	end
	element.__count = count

	for i = 1, #element do
		local obj = element[i]
		if count == 0 or i > element.num then
			obj:Hide()
		else
			obj:Show()
			obj:SetAlpha(i <= count and 1 or 0.25)
		end
	end

	if element.PostUpdate then
		element:PostUpdate(count)
	end
end

function Path(self, ...)
	return (self.PowerStack.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local element = self.PowerStack
	if not element then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	if not element.num then
		element.num = #element
	end

	for i = 1, #element do
		local obj = element[i]
		if obj:IsObjectType("Texture") and not obj:GetTexture() then
			obj:SetTexture([[Interface\ComboFrame\ComboPoint]])
			obj:SetTexCoord(0, 0.375, 0, 1)
		end
	end

	self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)
	UpdateVisibility(self, "Enable")

	return true
end

function Disable(self)
	local element = self.PowerStack
	if not element then return end

	self:UnregisterEvent("UNIT_AURA", Path)
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	for i = 1, #element do
		element[i]:Hide()
	end
end

oUF:AddElement("PowerStack", Path, Enable, Disable)
