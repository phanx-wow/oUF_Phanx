--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local _, ns = ...
local BurningEmbers

local color = { 1, 0.5, 0 }
oUF.colors.power.BURNING_EMBERS = color

local function PostUpdate(element, embers, embersMax, powerType)
	local total = 0
	for i = 1, #element do
		local bar = element[i]

		local r, g, b = color[1], color[2], color[3]
		if bar.activated then
			bar:SetStatusBarColor(r, g, b)
		else
			bar:SetStatusBarColor(r * 0.65, g * 0.65, b * 0.65)
		end

		local m = bar.bg.multiplier or 0.2
		bar.bg:SetVertexColor(r * m, g * m, b * m)
	end
end

ns.SetupBurningEmbers = function(frame)
	if BurningEmbers then
		BurningEmbers:SetParent(frame)
		return BurningEmbers
	end

	BurningEmbers = CreateFrame("Frame", nil, frame)
	for i = 1, 4 do
		local bar = ns.CreateStatusBar(BurningEmbers, nil, nil, true)
		bar.__owner = frame
		BurningEmbers[i] = bar
	end

	BurningEmbers.PostUpdate = PostUpdate
	return BurningEmbers
end
