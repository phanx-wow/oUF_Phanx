--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

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

	Runes = CreateFrame("Frame", nil, frame)
	Runes:SetFrameLevel(frame:GetFrameLevel() - 2) -- ???
	Runes:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -1)
	Runes:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -1)
	Runes:SetHeight(frame:GetHeight() * ns.config.powerHeight + 2)

	Runes:SetBackdrop(ns.config.backdrop)
	Runes:SetBackdropColor(0, 0, 0, 1)
	Runes:SetBackdropBorderColor(unpack(ns.config.borderColor))

	local MAX_RUNES = 6
	local RUNE_WIDTH = floor((frame:GetWidth() - (MAX_RUNES + 1)) / MAX_RUNES + 0.5)

	for i = 1, MAX_RUNES do
		local bar = ns.CreateStatusBar(Runes, 16, "CENTER")
		bar:SetWidth(RUNE_WIDTH)
		if i > 1 then
			bar:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
			bar:SetPoint("BOTTOMLEFT", Runes[i-1], "BOTTOMRIGHT", 1, 0)
			if i == MAX_RUNES then
				-- Fill up remaining space (probably 1px) left by rounding
				-- the bars down to avoid fuzzy edges.
				bar:SetPoint("TOPRIGHT", Runes, -1, -1)
				bar:SetPoint("BOTTOMRIGHT", Runes, -1, 1)
			end
		else
			bar:SetPoint("TOPLEFT", Runes, 1, -1)
			bar:SetPoint("BOTTOMLEFT", Runes, 1, 1)
		end

		bar:EnableMouse(false)
		bar:SetScript("OnEnter", Rune_OnEnter)
		bar:SetScript("OnLeave", Rune_OnLeave)

		bar.bg.multiplier = ns.config.powerBG

		bar.value:SetPoint("CENTER", bar, 0, 1)
		bar.value:Hide()

		Runes[i] = bar
	end

	Runes.__name = "Runes"
	Runes:Hide()
	Runes:SetScript("OnShow", ns.ExtraBar_OnShow)
	Runes:SetScript("OnHide", ns.ExtraBar_OnHide)

	tinsert(frame.mouseovers, function(self, isMouseOver)
		local func = isMouseOver and Rune_OnEnter or Rune_OnLeave
		for i = 1, #Runes do
			func(Runes[i])
		end
	end)

	Runes.PostUpdateRune = PostUpdateRune
	return Runes
end