--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright 2008-2018 Phanx <addons@phanx.net>. All rights reserved.
	https://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	https://www.curseforge.com/wow/addons/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
----------------------------------------------------------------------]]

local _, ns = ...
local _, class = UnitClass("player")

local Totems

local ColorGradient = oUF.ColorGradient
local SMOOTH_COLORS = oUF.colors.smooth
local SecondsToTimeAbbrev = SecondsToTimeAbbrev
local unpack = unpack

local function TotemBar_OnUpdate(bar, elapsed)
	local timeLeft = bar.duration - elapsed
	if timeLeft > 0 then
		bar.timeLeft = timeLeft
		bar:SetValue(timeLeft)
		bar.value:SetFormattedText(SecondsToTimeAbbrev(timeLeft))
		bar.value:SetTextColor(ColorGradient(bar.timeLeft, bar.duration, unpack(SMOOTH_COLORS)))
	else
		bar:SetValue(0)
	end
end

local function Totems_PostUpdate(element, id, _, name, start, duration, icon)
	local totem = element[id]
	local bar = totem.Bar
		
	bar.duration = duration
	bar.timeLeft = duration
	if duration > 0 then
		bar:SetMinMaxValues(0, duration)
		bar:SetScript("OnUpdate", TotemBar_OnUpdate)
	else
		bar:SetScript("OnUpdate", nil)
		bar:SetValue(0)
	end

	local color
	if element.colorClass then
		color = oUF.colors.class[class]
	elseif element.colorPower then
		color = oUF.colors.power[UnitPowerType("player")]
	else
		color = ns.config.powerColor
	end
	if color then
		local r, g, b = color[1], color[2], color[3]
		local mu = bar.bg.multiplier
		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * mu, g * mu, b * mu)
	end
end

ns.CreateTotems = function(frame)
	if Totems then
		return Totems
	end
	
	local config = ns.config
	local uconfig = ns.uconfig.player

	Totems = {
		side = "LEFT",
	}
	for i = 1, 4 do
		local totem = CreateFrame("Frame", nil, frame)
		totem:SetWidth(config.height * (1 - config.powerHeight) - 1)

		totem:EnableMouse(true)
		totem:SetScript("OnEnter", Totem_OnEnter)
		totem:SetScript("OnLeave", Totem_OnLeave)

		ns.CreateBorder(totem)

		local bar = ns.CreateStatusBar(totem, 16, "CENTER", nil, true)
		bar:SetPoint("BOTTOMLEFT", 1, 1)
		bar:SetPoint("BOTTOMRIGHT", -1, -1)
		bar:SetHeight(config.height * config.powerHeight)
		totem.Bar = bar

		bar.value:SetPoint("BOTTOM", bar, "TOP")
		tinsert(frame.mouseovers, bar.value)

		local icon = totem:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT", 1, -1)
		icon:SetPoint("TOPRIGHT", -1, 1)
		icon:SetPoint("BOTTOM", bar, "TOP", 0, 1)
		icon:SetTexCoord(0.09, 0.91, 0.08, 0.91)
		totem.Icon = icon

		local anchor = i > 1 and Totems[i-1] or frame
		if side == "LEFT" then
			totem:SetPoint("BOTTOMRIGHT", anchor, "LEFT", -6, 0)
		else
			totem:SetPoint("LEFT", anchor, "RIGHT", 6, 0)
		end

		Totems[i] = totem
	end

	return Totems
end
