--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Element to display burning embers on oUF frames.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "BurningEmbers element requires oUF")

local MAX_POWER_PER_EMBER = MAX_POWER_PER_EMBER
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local WARLOCK_BURNING_EMBERS = WARLOCK_BURNING_EMBERS

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event)
	local element = self.BurningEmbers

	if UnitHasVehicleUI("player") or GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION or not IsPlayerSpell(WARLOCK_BURNING_EMBERS) then
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

	Update(self, "UpdateVisibility", "player")
end

function Update(self, event, unit, powerType)
	if powerType and powerType ~= "BURNING_EMBERS" then return end
	local element = self.BurningEmbers
	if element.__disabled then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local embers = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
	local embersMax = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)

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
				--print(i, "Unused")
				ember:Hide()
			elseif rest >= MAX_POWER_PER_EMBER then
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

function Enable(self)
	local element = self.BurningEmbers
	if not element or self.unit ~= "player" then return end

	element.__name = "BurningEmbers"
	element.__owner = self
	element.ForceUpdate = ForceUpdate

	for i = 1, #element do
		local ember = element[i]
		if ember.GetStatusBarTexture and not ember:GetStatusBarTexture() then
			ember:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end
	end

	self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
	self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	UpdateVisibility(self, "Enable")
	return true
end

function Disable(self)
	local element = self.BurningEmbers
	if not element then return end

	self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
	self:UnregisterEvent("UNIT_POWER", Path)

	self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility)
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

	for i = 1, #element do
		element[i]:Hide()
	end
	if element.Hide then
		element:Hide()
	end
end

oUF:AddElement("BurningEmbers", Path, Enable, Disable)
