--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
----------------------------------------------------------------------]]

if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local _, ns = ...
local BurningEmbers

local color = { 1, 0.6, 0.2 }
oUF.colors.power.BURNING_EMBERS = color

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

	BurningEmbers = ns.CreateMultiBar(frame, 4)
	BurningEmbers.PostUpdate = BurningEmbers_PostUpdate
	
	for i = 1, #BurningEmbers do
		BurningEmbers[i]:SetReverseFill(true)
	end

	return BurningEmbers
end
