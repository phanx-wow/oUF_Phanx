--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
----------------------------------------------------------------------]]
-- TODO: check interaction between default bar behavior vs MultiBar

if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local _, ns = ...

local Runes

local ColorGradient = oUF.ColorGradient
local SMOOTH_COLORS = oUF.colors.smooth
local unpack = unpack

local function Rune_OnUpdate(bar, elapsed)
	if bar.mouseover and not bar.ready then
		local duration, max = bar.duration, bar.max
		if duration < max then
			bar.value:SetFormattedText(SecondsToTimeAbbrev(max - duration))
			bar.value:SetTextColor(ColorGradient(duration, max, unpack(SMOOTH_COLORS)))
		end
	end
end

local function Rune_OnEnter(bar)
	bar.mouseover = true
	if bar.duration and not bar.ready then 
		bar.value:Show()
		if not bar.hookedOnUpdate then
			bar:HookScript("OnUpdate", Rune_OnUpdate)
			bar.hookedOnUpdate = true
		end
	end
end

local function Rune_OnLeave(bar)
	bar.mouseover = nil
	bar.value:Hide()
end

local function PostUpdateRune(element, bar, i, start, duration, ready)
	bar.ready = ready
	if ready then
		bar:GetStatusBarTexture():SetAlpha(1)
	else
		bar:GetStatusBarTexture():SetAlpha(0.5)
	end

	local color
	if element.colorPower then
		color = oUF.colors.power.RUNES
	elseif element.colorClass then
		color = oUF.colors.class.DEATHKNIGHT
	end
	if color then
		local mu = bar.bg.multiplier
		bar:SetStatusBarColor(color[1], color[2], color[3])
		bar.bg:SetVertexColor(color[1] * mu, color[2] * mu, color[3] * mu)
	end

	local shown = element:IsShown()
	for i = 1, #element do
		if element[i]:IsShown() then
			return shown or element:Show()
		end
	end
	return shown and element:Hide()
end

ns.CreateRunes = function(frame)
	if Runes then
		return Runes
	end

	Runes = ns.CreateMultiBar(frame, 6, 16, true)
	Runes.PostUpdate = PostUpdateRune

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
