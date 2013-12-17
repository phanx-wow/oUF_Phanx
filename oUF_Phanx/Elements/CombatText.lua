--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Element to display combat feedback text on oUF frames.

	Concept inspired by oUF_CombatFeedback, by Ammo.
	All code "liberated" from the Blizzard UI with minor modifications.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	Basic usage:
	self.CombatText = self:CreateFontString(nil, "OVERLAY")
	self.CombatText:SetPoint("CENTER")

	Advanced usage:
	self.CombatText.maxAlpha = 1 -- default is 0.8
	self.CombatText.ignore = { -- no defaults
		BLOCK = true,
		MISS = true,
	}
----------------------------------------------------------------------]]

if select(4, GetAddOnInfo("oUF_CombatFeedback")) then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "CombatText element requires oUF")

local si = AbbreviateLargeNumbers
local L = CombatFeedbackText

local colors = {
	DEFAULT     = { 1, 1, 1 },
	WOUND       = { 1, 0, 0 },
	HEAL        = { 0, 1, 0 },
	ENERGIZE    = { 0.41, 0.8, 0.94 },
	ABSORB      = { 0.6, 0.6, 0.6 },
	BLOCK       = { 0.6, 0.6, 0.6 },
	IMMUNE      = { 0.6, 0.6, 0.6 },
	MISS        = { 0.6, 0.6, 0.6 },
	RESIST      = { 0.6, 0.6, 0.6 },
}
oUF.colors.combatfeedback = colors -- So layouts can modify them.

local active = {}

local updater = CreateFrame("Frame")
updater:Hide()

local next, pairs, GetTime = next, pairs, GetTime
updater:SetScript("OnUpdate", function(self)
	if not next(active) then
		self:Hide()
	end

	local fadeInTime = COMBATFEEDBACK_FADEINTIME
	local holdTime = COMBATFEEDBACK_HOLDTIME
	local fadeOutTime = COMBATFEEDBACK_FADEOUTTIME

	for element, startTime in pairs(active) do
		local elapsedTime = GetTime() - startTime
		local maxAlpha = element.maxAlpha
		if elapsedTime < fadeInTime then
			element:SetAlpha(elapsedTime / fadeInTime * maxAlpha)
		elseif elapsedTime < (fadeInTime + holdTime) then
			element:SetAlpha(1 * maxAlpha)
		elseif elapsedTime < (fadeInTime + holdTime + fadeOutTime) then
			element:SetAlpha(maxAlpha - ((elapsedTime - holdTime - fadeInTime) / fadeOutTime * maxAlpha))
		else
			element:Hide()
			active[element] = nil
		end
	end
end)

local seentypes = {
	["DODGE"] = true,
	["HEAL"] = true,
	["WOUND"] = true,
	["WOUND CRITICAL"] = true,
}

local Update = function(self, event, unit, combatEvent, flags, amount, school)
	if not combatEvent or unit ~= self.unit then return end

	local logentry = flags and (combatEvent .. " " .. flags) or flags
	if not seentypes[logentry] then
		seentypes[logentry] = true
		print(logentry)
	end

	local element = self.CombatText
	if combatEvent == "WOUND" and amount < 1 then
		combatEvent = flags
	end

	if element.ignore[combatEvent] then return end

	local color = colors[combatEvent] or colors.DEFAULT
	local size = element.baseSize
	local text

	if combatEvent == "WOUND" and amount > 0 then
		if flags == "CRITICAL" or flags == "CRUSHING" then
			size = size * 1.5
		elseif flags == "GLANCING" then
			size = size * 0.75
		end
		text = si(amount)
	elseif combatEvent == "HEAL" then
		if flags == "CRITICAL" then
			size = size * 1.5
		end
		text = si(amount)
	elseif combatEvent == "ENERGIZE" then
		if flags == "CRITICAL" then
			size = size * 1.5
		end
		text = si(amount)
	elseif combatEvent == "IMMUNE" then
		size = size * 0.5
		text = L[combatEvent]
	else
		size = size * 0.75
		text = L[combatEvent]
	end

	if text then
		local font, _, flags = element:GetFont()
		element:SetFont(font, size, flags)
		element:SetText(text)
		element:SetTextColor(color[1], color[2], color[3])
		element:SetAlpha(0)
		element:Show()
		active[element] = GetTime()
		updater:Show()
	end
end

local Enable = function(self)
	local element = self.CombatText
	if not element then return end

	-- Can't upvalue in main chunk due to load order.
	-- Remove this if using outside of oUF Phanx.
	if ns.si then
		si = ns.si
	end

	element.__owner = self
	element.ForceUpdate = Update

	if not element:GetFont() then
		element:SetFontObject("GameFontHighlightMedium")
	end

	if not element.baseSize then
		local _, size = element:GetFont()
		element.baseSize = size
	end

	element.ignore = element.ignore or {}
	element.maxAlpha = element.maxAlpha or 0.8

	self:RegisterEvent("UNIT_COMBAT", Update)
	return true
end

local Disable = function(self)
	local element = self.CombatText
	if not element then return end

	self:UnregisterEvent("UNIT_COMBAT", Update)
	element:Hide()
	active[element] = nil
end

oUF:AddElement("CombatText", Update, Enable, Disable)