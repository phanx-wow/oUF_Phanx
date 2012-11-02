--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...

local Runes

local ColorGradient = oUF.ColorGradient
local SMOOTH_COLORS = oUF.colors.smooth
local unpack = unpack

local function Rune_OnEnter(bar)
	bar.mouseover = true
	bar.value:Show()
end

local function Rune_OnLeave(bar)
	bar.mouseover = nil
	bar.value:Hide()
end

local function Rune_OnUpdate(bar, elapsed)
	if bar.mouseover then
		local duration, max = bar.duration, bar.max
		if duration < max then
			bar.value:SetFormattedText(SecondsToTimeAbbrev(max - duration))
			bar.value:SetTextColor(ColorGradient(duration, max, unpack(SMOOTH_COLORS)))
		end
	end
end

local function PostUpdateRune(element, bar, id, start, duration, ready)
	if duration > 0 then
		bar:HookScript("OnUpdate", Rune_OnUpdate)
	end

	if not bar.scripted then
		bar:HookScript("OnEnter", Rune_OnEnter)
		bar:HookScript("OnLeave", Rune_OnLeave)
		bar.scripted = true
	end
end

ns.CreateRunes = function(frame)
	if Runes then
		return Runes
	end

	Runes = {
		PostUpdateRune = PostUpdateRune
	}

	for i = 1, 6 do
		local bar = ns.CreateStatusBar(frame, 16, "CENTER", true)
		ns.CreateBorder(bar)

		bar.value:Hide()
		bar.value:SetPoint("CENTER")

		bar.__owner = frame

		Runes[i] = bar
	end

	return Runes
end