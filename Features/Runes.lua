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
----------------------------------------------------------------------]]
-- TODO: check interaction between default bar behavior vs MultiBar

if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local _, ns = ...

local colors = oUF.colors.runes
colors[1][1], colors[1][2], colors[1][3] = 0.8, 0.2, 0.2 -- Blood
colors[3][1], colors[3][2], colors[3][3] = 0,   0.8, 1   -- Frost
colors[2][1], colors[2][2], colors[2][3] = 0.3, 0.9, 0   -- Unholy
colors[4][1], colors[4][2], colors[4][3] = 0.8, 0.5, 1   -- Death

local Runes

local ColorGradient = oUF.ColorGradient
local SMOOTH_COLORS = oUF.colors.smooth
local unpack = unpack

local function Rune_OnUpdate(bar, elapsed)
	if bar.mouseover then
		local duration, max = bar.duration, bar.max
		if duration < max then
			bar.value:SetFormattedText(SecondsToTimeAbbrev(max - duration))
			bar.value:SetTextColor(ColorGradient(duration, max, unpack(SMOOTH_COLORS)))
		end
	end
end

local function Rune_OnEnter(bar)
	bar.mouseover = true
	if not bar.ready then
		bar.value:Show()
		if bar.duration > 0 then
			bar:HookScript("OnUpdate", Rune_OnUpdate)
		end
	end
end

local function Rune_OnLeave(bar)
	bar.mouseover = nil
	bar.value:Hide()
end

local function PostUpdateRune(element, bar, id, start, duration, ready)
	bar.ready = ready
	if ready then
		bar:GetStatusBarTexture():SetAlpha(1)
	else
		bar:GetStatusBarTexture():SetAlpha(0.5)
	end

	for i = 1, #element do
		if element[i]:IsShown() then
			return element:Show()
		end
	end
	element:Hide()
end

ns.CreateRunes = function(frame)
	if Runes then
		return Runes
	end

	Runes = ns.CreateMultiBar(frame, 6, 16, true)
	Runes.PostUpdateRune = PostUpdateRune

	for i = 1, #Runes do
		local bar = Runes[i]
		bar:EnableMouse(false)
		bar:SetScript("OnEnter", Rune_OnEnter)
		bar:SetScript("OnLeave", Rune_OnLeave)

		bar.value:SetPoint("CENTER", bar, 0, 1)
		bar.value:Hide()
	end

	tinsert(frame.mouseovers, function(self, isMouseOver)
		local func = isMouseOver and Rune_OnEnter or Rune_OnLeave
		for i = 1, #Runes do
			func(Runes[i])
		end
	end)

	return Runes
end