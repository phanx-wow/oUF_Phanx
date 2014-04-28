--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local _, ns = ...
local BurningEmbers

local color = { 1, 0.6, 0.2 }
oUF.colors.power.BURNING_EMBERS = color

local function BurningEmbers_OnShow(element)
	local frame = element.__owner
	frame:SetBorderParent(element[#element])
	frame:SetBorderSize()
end

local function BurningEmbers_OnHide(element)
	local frame = element.__owner
	frame:SetBorderParent(frame.overlay)
	frame:SetBorderSize()
end

local function Frame_SetBorderSize(frame, size, offset)
	if BurningEmbers:IsShown() then
		local _, offset = frame:GetBorderSize()
		frame.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", BurningEmbers, -offset, offset)
		frame.BorderTextures.TOPRIGHT:SetPoint("TOPRIGHT", BurningEmbers, offset, offset)
	end
end

local function BurningEmbers_PostUpdate(element, embers, embersMax, powerType)
	local total = 0
	for i = 1, #element do
		local bar = element[i]

		local r, g, b = color[1], color[2], color[3]
		if bar.activated then
			bar:SetStatusBarColor(r, g, b)
		else
			bar:SetStatusBarColor(r * 0.5, g * 0.5, b * 0.5)
		end

		-- Ignore any .multiplier and just use something that looks good
		bar.bg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
	end
end

ns.CreateBurningEmbers = function(frame)
	if BurningEmbers then
		return BurningEmbers
	end

	BurningEmbers = CreateFrame("Frame", nil, frame)
	BurningEmbers:Hide()

	BurningEmbers:SetBackdrop(ns.config.backdrop)
	BurningEmbers:SetBackdropColor(0, 0, 0, 1)
	BurningEmbers:SetBackdropBorderColor(unpack(ns.config.borderColor))

	BurningEmbers:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -1)
	BurningEmbers:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -1)
	BurningEmbers:SetHeight(frame:GetHeight() * ns.config.powerHeight + 2)

	local numEmbers = 4
	local emberGap = 1
	local emberWidth = (frame:GetWidth() - (emberGap * (numEmbers + 1))) / numEmbers

	for i = 1, numEmbers do
		local bar = ns.CreateStatusBar(BurningEmbers)
		bar:SetWidth(emberWidth)
		bar:SetReverseFill(true)
		bar.bg.multiplier = ns.config.powerBG

		if i > 1 then
			bar:SetPoint("TOPRIGHT", BurningEmbers[i-1], "TOPLEFT", -1, 0)
			bar:SetPoint("BOTTOMRIGHT", BurningEmbers[i-1], "BOTTOMLEFT", -1, 0)
		else
			bar:SetPoint("TOPRIGHT", BurningEmbers, -1, -1)
			bar:SetPoint("BOTTOMRIGHT", BurningEmbers, -1, 1)
		end

		bar.__owner = frame
		BurningEmbers[i] = bar
	end

	BurningEmbers:SetScript("OnEnter", ns.UnitFrame_OnEnter)
	BurningEmbers:SetScript("OnLeave", ns.UnitFrame_OnLeave)
	BurningEmbers:SetScript("OnShow", BurningEmbers_OnShow)
	BurningEmbers:SetScript("OnHide", BurningEmbers_OnHide)
	hooksecurefunc(frame, "SetBorderSize", Frame_SetBorderSize)

	BurningEmbers.PostUpdate = BurningEmbers_PostUpdate
	return BurningEmbers
end
