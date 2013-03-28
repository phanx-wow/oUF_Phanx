--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local _, ns = ...

-- Better unholy color:
oUF.colors.runes[2][1] = 0.3
oUF.colors.runes[2][2] = 0.9
oUF.colors.runes[2][3] = 0

-- Better frost color:
oUF.colors.runes[3][1] = 0
oUF.colors.runes[3][2] = 0.8
oUF.colors.runes[3][3] = 1

-- Better death color:
oUF.colors.runes[4][1] = 0.8
oUF.colors.runes[4][2] = 0.5
oUF.colors.runes[4][3] = 1

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
		bar:SetAlpha(1)
	else
		bar:SetAlpha(0.5)
	end
end

ns.CreateRunes = function(frame)
	if Runes then
		return Runes
	end

	Runes = CreateFrame("Frame", nil, frame)

	for i = 1, 6 do
		local bar = ns.CreateStatusBar(Runes, 16, "CENTER")

		bar:EnableMouse(true)
		bar:SetScript("OnEnter", Rune_OnEnter)
		bar:SetScript("OnLeave", Rune_OnLeave)

		bar.value:Hide()
		bar.value:SetPoint("CENTER", 0, 1)

		Runes[i] = bar
	end

	Runes.PostUpdateRune = PostUpdateRune
	return Runes
end