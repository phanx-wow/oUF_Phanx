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

if select(2, UnitClass("player")) ~= "SHAMAN" then return end

local _, ns = ...

local Totems

local TOTEM_COLORS = {
	[1] = { 0.6, 1,   0.2 }, -- Earth
	[2] = { 1,   0.6, 0.2 }, -- Fire
	[3] = { 0.2, 0.8, 1   }, -- Water
	[4] = { 0.8, 0.4, 1   }, -- Air
}
oUF.colors.totems = TOTEM_COLORS

local ColorGradient = oUF.ColorGradient
local SMOOTH_COLORS = oUF.colors.smooth
local SecondsToTimeAbbrev = SecondsToTimeAbbrev
local unpack = unpack

local function Totem_OnEnter(bar)
	bar.isMouseOver = true

	bar.iconFrame:Show()
	bar.value:Show()
	bar.value:SetParent(bar.iconFrame)
end

local function Totem_OnLeave(bar)
	bar.isMouseOver = nil

	bar.iconFrame:Hide()
	bar.value:Hide()
	bar.value:SetParent(bar)
end

local function Totem_OnUpdate(bar, elapsed)
	local duration = bar.duration - elapsed
	if duration > 0 then
		bar.duration = duration
		bar:SetValue(duration)
		if bar.isMouseOver or bar.__owner.isMouseOver then
			bar.value:SetFormattedText(SecondsToTimeAbbrev(duration))
			bar.value:SetTextColor(ColorGradient(bar.duration, bar.max, unpack(SMOOTH_COLORS)))
		end
	else
		bar:SetValue(0)
	end
end

local function Totems_PostUpdate(element, id, _, name, start, duration, icon)
	local bar = element[id]

	bar.duration = duration
	bar.max = duration

	if duration > 0 then
		bar:EnableMouse(true)
		bar:SetMinMaxValues(0, duration)
		bar:SetScript("OnUpdate", Totem_OnUpdate)
		bar.icon:SetTexture(icon)
		element:Show()
	else
		Totem_OnLeave(bar)
		bar:EnableMouse(false)
		bar:SetScript("OnUpdate", nil)
		bar:SetValue(0)
		bar.icon:SetTexture(nil)
		for i = 1, #element do
			if element[i].duration > 0 then
				return element:Show()
			end
		end
		element:Hide()
	end
end

ns.CreateTotems = function(frame)
	if Totems then
		return Totems
	end

	Totems = ns.CreateMultiBar(frame, 4, 16, true)
	Totems.PostUpdate = Totems_PostUpdate

	local iconSize = Totems[1]:GetWidth() * 0.5

	for i = 1, #Totems do
		local bar = Totems[i]
		
		bar.duration = 0
		bar:SetMinMaxValues(0, 1)

		bar:SetHitRectInsets(0, 0, -10, 0)
		bar:SetReverseFill(true) -- TODO: experimental

		bar:EnableMouse(true)
		bar:SetScript("OnEnter", Totem_OnEnter)
		bar:SetScript("OnLeave", Totem_OnLeave)

		bar.value:SetPoint("CENTER", bar, 1, 1)
		bar.value:Hide()

		bar.iconFrame = CreateFrame("Frame", nil, bar)
		bar.iconFrame:SetPoint("CENTER")
		bar.iconFrame:SetSize(iconSize, iconSize)
		bar.iconFrame:Hide()

		bar.icon = bar.iconFrame:CreateTexture(nil, "BACKGROUND")
		bar.icon:SetAllPoints(true)
		bar.icon:SetTexCoord(0.09, 0.91, 0.08, 0.91)

		ns.CreateBorder(bar.iconFrame)

		local color = bar.color or TOTEM_COLORS[i]
		local r, g, b, mu = color[1], color[2], color[3], bar.bg.multiplier or 1
		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * mu, g * mu, b * mu)

		tinsert(frame.mouseovers, bar.value)
	end

	return Totems
end