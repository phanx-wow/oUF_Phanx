--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...

local TotemBars

local TOTEM_COLORS = {
	[1] = { 0.6, 1,   0.2 }, -- Earth
	[2] = { 1,   0.6, 0.2 }, -- Fire
	[3] = { 0.2, 0.8, 1   }, -- Water
	[4] = { 0.8, 0.4, 1   }, -- Air
}
oUF.colors.totems = TOTEM_COLORS

local ColorGradient = oUF.ColorGradient
local SMOOTH_COLORS = oUF.colors.smooth
local unpack = unpack

local function TotemBar_OnMouseUp(bar, button)
	if button == "RightButton" and bar.mouseover then
		DestroyTotem(bar:GetID())
	end
end

local function TotemBar_OnEnter(bar)
	bar.mouseover = true

	bar.value:Show()
	bar.Icon:Show()

	local b = bar.BorderTextures
	local _, _, _, d = b.BOTTOMRIGHT:GetPoint("BOTTOMRIGHT")
	b.BOTTOMLEFT:SetPoint("BOTTOMLEFT", bar.Icon, -d, -d)
	b.BOTTOMRIGHT:SetPoint("BOTTOMRIGHT", bar.Icon, d, -d)
end

local function TotemBar_OnLeave(bar)
	bar.mouseover = nil

	bar.value:Hide()
	bar.Icon:Hide()

	local b = bar.BorderTextures
	local _, _, _, d = b.BOTTOMRIGHT:GetPoint("BOTTOMRIGHT")
	b.BOTTOMLEFT:SetPoint("BOTTOMLEFT", bar, -d, -d)
	b.BOTTOMRIGHT:SetPoint("BOTTOMRIGHT", bar, d, -d)
end

local function TotemBar_OnUpdate(bar, elapsed)
	local duration = bar.duration - elapsed
	if duration > 0 then
		bar.duration = duration
		bar:SetValue(duration)

		if bar.mouseover then
			bar.value:SetFormattedText(SecondsToTimeAbbrev(duration))
			bar.value:SetTextColor(ColorGradient(bar.duration, bar.max, unpack(SMOOTH_COLORS)))
		end
	else
		bar:SetValue(0)
	end
end

local function TotemBars_PostUpdate(element, id, _, name, start, duration, icon)
	local bar = element[id]

	bar.duration = duration
	bar.max = duration

	if duration > 0 then
		bar:SetMinMaxValues(0, duration)

		local color = bar.color or TOTEM_COLORS[id]
		local r, g, b, mu = color[1], color[2], color[3], bar.bg.multiplier or 1
		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * mu, g * mu, b * mu)

		bar:SetScript("OnUpdate", TotemBar_OnUpdate)
	else
		bar:SetScript("OnUpdate", nil)
	end

	if not bar.scripted then
		bar:HookScript("OnEnter", TotemBar_OnEnter)
		bar:HookScript("OnLeave", TotemBar_OnLeave)
		bar.scripted = true
	end
end

ns.CreateTotemBars = function(frame)
	if TotemBars then
		return TotemBars
	end

	TotemBars = {
		PostUpdate = TotemBars_PostUpdate
	}

	for i = 1, MAX_TOTEMS do
		local bar = ns.CreateStatusBar(frame, 16, "CENTER", true)
		ns.CreateBorder(bar)

		bar.value:Hide()
		bar.value:SetPoint("CENTER", bar, "TOP")

		bar.Icon = bar:CreateTexture(nil, "ARTWORK")
		bar.Icon:SetPoint("TOPLEFT")
		bar.Icon:SetPoint("TOPRIGHT")
		bar.Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		bar.Icon:Hide()

		bar:EnableMouse(true)
		bar:SetScript("OnMouseDown", TotemBar_OnClick)

		bar.__owner = frame

		TotemBars[i] = bar
	end

	return TotemBars
end