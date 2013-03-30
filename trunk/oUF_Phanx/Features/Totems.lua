--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
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
local unpack = unpack

local function Totems_OnShow(element)
	local frame = element.__owner
	local totem
	for i = 1, #element do
		if element[i]:IsShown() then
			totem = element[i]
		end
	end
	frame:SetBorderParent(totem)
	frame:SetBorderSize()
end

local function Totems_OnHide(element)
	local frame = element.__owner
	frame:SetBorderParent(frame.overlay)
	frame:SetBorderSize()
end

local function Frame_SetBorderSize(frame, size, offset)
	if Totems:IsShown() then
		local _, offset = frame:GetBorderSize()
		frame.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", Totems, -offset, offset)
		frame.BorderTextures.TOPRIGHT:SetPoint("TOPRIGHT", Totems, offset, offset)
	end
end

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
		bar:SetMinMaxValues(0, duration)

		local color = bar.color or TOTEM_COLORS[id]
		local r, g, b, mu = color[1], color[2], color[3], bar.bg.multiplier or 1
		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * mu, g * mu, b * mu)
	end

	if not bar.scripted then
		bar:HookScript("OnEnter", Totem_OnEnter)
		bar:HookScript("OnLeave", Totem_OnLeave)
		bar.scripted = true
	end

	element:Hide()
	for i = 1, #element do
		if element[i]:IsShown() then
			return element:Show()
		end
	end
end

ns.CreateTotems = function(frame)
	if Totems then
		return Totems
	end

	Totems = CreateFrame("Frame", nil, frame)

	Totems:SetBackdrop(ns.config.backdrop)
	Totems:SetBackdropColor(0, 0, 0, 1)
	Totems:SetBackdropBorderColor(unpack(ns.config.borderColor))

	Totems:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -1)
	Totems:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -1)
	Totems:SetHeight(frame:GetHeight() * ns.config.powerHeight + 2)

	local totemGap = 1
	local totemWidth = (frame:GetWidth() - (totemGap * (MAX_TOTEMS + 1))) / MAX_TOTEMS

	for i = 1, MAX_TOTEMS do
		local bar = ns.CreateStatusBar(Totems, 16, "CENTER")
		bar:SetWidth(totemWidth)
		bar:SetHitRectInsets(0, 0, -10, 0)

		bar:EnableMouse(true)
		bar:Hide()
		bar:SetScript("OnUpdate", Totem_OnUpdate)

		if i > 1 then
			bar:SetPoint("TOPLEFT", Totems[i-1], "TOPRIGHT", 1, 0)
			bar:SetPoint("BOTTOMLEFT", Totems[i-1], "BOTTOMRIGHT", 1, 0)
		else
			bar:SetPoint("TOPLEFT", Totems, 1, -1)
			bar:SetPoint("BOTTOMLEFT", Totems, 1, 1)
		end

		local mu, co = ns.config.powerBG, oUF.colors.totems[i]
		bar.bg.multiplier = mu
		bar.bg:SetParent(Totems)
		bar.bg:SetDrawLayer("ARTWORK")
		bar.bg:SetVertexColor(co[1] * mu, co[2] * mu, co[3] * mu)
		bar.bg:Show()

		bar.iconFrame = CreateFrame("Frame", nil, bar)
		bar.iconFrame:SetPoint("CENTER")
		bar.iconFrame:SetSize(totemWidth * 0.5, totemWidth * 0.5)
		bar.iconFrame:Hide()

		ns.CreateBorder(bar.iconFrame)

		bar.Icon = bar.iconFrame:CreateTexture(nil, "BACKGROUND")
		bar.Icon:SetAllPoints(true)
		bar.Icon:SetTexCoord(0.09, 0.91, 0.08, 0.91)

		bar.value:SetPoint("CENTER", 1, 1)
		bar.value:Hide()

		tinsert(frame.mouseovers, bar.value)

		bar.__owner = frame
		Totems[i] = bar
	end

	Totems:SetScript("OnShow", Totems_OnShow)
	Totems:SetScript("OnHide", Totems_OnHide)
	hooksecurefunc(frame, "SetBorderSize", Frame_SetBorderSize)

	Totems.PostUpdate = Totems_PostUpdate
	return Totems
end