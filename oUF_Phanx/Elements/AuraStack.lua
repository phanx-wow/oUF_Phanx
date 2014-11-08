--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx

	Please DO NOT upload this addon to other websites, or post modified
	versions of it. However, you are welcome to include a copy of it
	WITHOUT CHANGES in compilations posted on Curse and/or WoWInterface.
	You are also welcome to use any/all of its code in your own addon, as
	long as you do not use my name or the name of this addon ANYWHERE in
	your addon, including its name, outside of an optional attribution.
------------------------------------------------------------------------
	Element to track stacking self-(de)buffs like combo points.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.
------------------------------------------------------------------------
	Usage:

	self.AuraStack = {
		aura = GetSpellInfo(53817) -- Localized spell name for Maelstrom Weapon
		filter = "HELPFUL", -- Optional filter to pass to UnitAura, defaults to "HELPFUL"
	}
	for i = 1, 5 do
		self.AuraStack[i] = CreateTexture(nil, "OVERLAY")
		self.AuraStack[i]:SetSize(20, 20)
		if i == 1 then
			self.AuraStack[i]:SetPoint("LEFT", self, "BOTTOMLEFT", 5, 0)
		else
			self.AuraStack[i]:SetPoint("LEFT", self.AuraStack[i-1], "RIGHT", 0, 0)
		end
	end
------------------------------------------------------------------------
	Notes:

	Only supports one aura per frame.

	Supports Override or PreUpdate/PostUpdate.

	Does not support spell IDs, as the WoW API cannot look up a buff
	directly by its ID and looping is not desirable here.

	The buff to track can be changed dynamically (for example, when
	the player's spec changes) by the layout.

	The individual objects do not have to be textures. They can be
	frames, fontstrings, or even basic tables, as long as they have
	Show, Hide, SetAlpha, and IsObjectType methods.
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "AuraStack element requires oUF")

local UnitBuff = UnitBuff

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event)
	local element = self.AuraStack

	if UnitHasVehicleUI(self.unit) then
		self:UnregisterEvent("UNIT_AURA", Path)
		for i = 1, #element do
			element[i]:Hide()
		end
		if element.SetShown then
			element:SetShown(false) -- use SetShown instead of Hide so there's one less method to fake if the layout needs to
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
	local element = self.AuraStack
	if element.__disabled or not element.aura then return end

	local _, _, _, count = UnitAura(unit, element.aura, nil, element.filter or "HELPFUL")
	count = count or 0

	if count == element.__count then return end

	if element.PreUpdate then
		element:PreUpdate()
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

	if element.SetShown then
		element:SetShown(count > 0)
	end

	if element.PostUpdate then
		element:PostUpdate(count)
	end
end

function Path(self, ...)
	return (self.AuraStack.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local element = self.AuraStack
	if not element then return end

	element.__name = "AuraStack"
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
	local element = self.AuraStack
	if not element then return end

	self:UnregisterEvent("UNIT_AURA", Path)
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	for i = 1, #element do
		element[i]:Hide()
	end
end

oUF:AddElement("AuraStack", Path, Enable, Disable)
