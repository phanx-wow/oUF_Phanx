--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

if select(2, UnitClass("player")) ~= "DRUID" then return end

oUF.colors.power.ECLIPSE_LUNAR = { 0, 0.6, 1 }
oUF.colors.power.ECLIPSE_SOLAR = { 0.8, 0.5, 0 }

local _, ns = ...
local EclipseBar

local ECLIPSE_MARKER_COORDS = ECLIPSE_MARKER_COORDS
local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE

local LUNAR_COLOR = oUF.colors.power.ECLIPSE_LUNAR
local SOLAR_COLOR = oUF.colors.power.ECLIPSE_SOLAR

local BRIGHT = 1.2
local NORMAL = 0.8
local DIMMED = 0.5

local function PostUpdateVisibility(self, unit) --print("EclipseBar PostUpdateVisibility", self:IsShown())
	self.shown = self:IsShown()
end

local function PostUpdatePower(self, unit, power, maxPower)
	if not power or not self.shown then return end
	local x = (power / maxPower) * (self:GetWidth() / 2)
	self.lunarBG:SetPoint("RIGHT", self, "CENTER", x, 0)
end

local function PostUnitAura(self, unit)
	if not self.shown then return end
	local hasLunarEclipse, hasSolarEclipse = self.hasLunarEclipse, self.hasSolarEclipse
	--print("PostUnitAura", hasLunarEclipse, hasSolarEclipse)

	if hasLunarEclipse then
		self.lunarBG:SetVertexColor(LUNAR_COLOR[1] * DIMMED, LUNAR_COLOR[2] * DIMMED, LUNAR_COLOR[3] * DIMMED)
		self.solarBG:SetVertexColor(LUNAR_COLOR[1] * BRIGHT, LUNAR_COLOR[2] * BRIGHT, LUNAR_COLOR[3] * BRIGHT)
	elseif hasSolarEclipse then
		self.lunarBG:SetVertexColor(SOLAR_COLOR[1] * BRIGHT, SOLAR_COLOR[2] * BRIGHT, SOLAR_COLOR[3] * BRIGHT)
		self.solarBG:SetVertexColor(SOLAR_COLOR[1] * DIMMED, SOLAR_COLOR[2] * DIMMED, SOLAR_COLOR[3] * DIMMED)
	else
		self.lunarBG:SetVertexColor(LUNAR_COLOR[1] * NORMAL, LUNAR_COLOR[2] * NORMAL, LUNAR_COLOR[3] * NORMAL)
		self.solarBG:SetVertexColor(SOLAR_COLOR[1] * NORMAL, SOLAR_COLOR[2] * NORMAL, SOLAR_COLOR[3] * NORMAL)
	end

	local glow = self.glow
	if not glow then return end

	local moonActivate, moonDeactivate = self.moonActivate, self.moonDeactivate
	local sunActivate, sunDeactivate = self.sunActivate, self.sunDeactivate

	if hasLunarEclipse then
		local t = ECLIPSE_ICONS.moon.big
		glow:ClearAllPoints()
		glow:SetPoint("CENTER", self.moon, "CENTER", 0, 0)
		glow:SetWidth(t.x)
		glow:SetHeight(t.y)
		glow:SetTexCoord(t.left, t.right, t.top, t.bottom)

		self.darkSun:Show()
		if moonDeactivate:IsPlaying() then
			moonDeactivate:Stop()
		end
		if not moonActivate:IsPlaying() and EclipseBarFrame.hasLunarEclipse ~= hasLunarEclipse then
			moonActivate:Play()
		end
	else
		self.darkSun:Hide()
		if moonActivate:IsPlaying() then
			moonActivate:Stop()
		end
		if not moonDeactivate:IsPlaying() and EclipseBarFrame.hasLunarEclipse ~= hasLunarEclipse then
			moonDeactivate:Play()
		end
	end

	if hasSolarEclipse then
		local t = ECLIPSE_ICONS.sun.big
		glow:ClearAllPoints()
		glow:SetPoint("CENTER", self.sun, "CENTER", 0, 0)
		glow:SetWidth(t.x)
		glow:SetHeight(t.y)
		glow:SetTexCoord(t.left, t.right, t.top, t.bottom)

		self.darkMoon:Show()
		if sunDeactivate:IsPlaying() then
			sunDeactivate:Stop()
		end
		if not sunActivate:IsPlaying() and EclipseBarFrame.hasSolarEclipse ~= hasSolarEclipse then
			sunActivate:Play()
		end
	else
		self.darkMoon:Hide()
		if sunActivate:IsPlaying() then
			sunActivate:Stop()
		end
		if not sunDeactivate:IsPlaying() and EclipseBarFrame.hasSolarEclipse ~= hasSolarEclipse then
			sunDeactivate:Play()
		end
	end

	EclipseBarFrame.hasLunarEclipse = hasLunarEclipse
	EclipseBarFrame.hasSolarEclipse = hasSolarEclipse
end

local function PostDirectionChange(self, unit)
	if not self.shown then return end
	local direction = self.directionIsLunar or "none" -- GetEclipseDirection()
	--print("PostDirectionChanged", direction)

	local coords = ECLIPSE_MARKER_COORDS[direction]
	self.directionArrow:SetTexCoord(coords[1], coords[2], coords[3], coords[4])

	if direction == "moon" then
		self.directionArrow:SetPoint("CENTER", self.lunarBG, "RIGHT", 1, 1)
	elseif direction == "sun" then
		self.directionArrow:SetPoint("CENTER", self.lunarBG, "RIGHT", -1, 1)
	else
		self.directionArrow:SetPoint("CENTER", self.lunarBG, "RIGHT", 0, 1)
	end
end

function ns.CreateEclipseBar(self)
	if EclipseBar then
		return EclipseBar
	end

	EclipseBar = CreateFrame("Frame", nil, self)
	EclipseBar:Hide()

	EclipseBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	EclipseBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 0)
	EclipseBar:SetHeight(self:GetHeight() * ns.config.powerHeight + 1)

	local texture = self.Health:GetStatusBarTexture():GetTexture()

	local bg = EclipseBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(true)
	bg:SetTexture(texture)
	bg:SetVertexColor(0, 0, 0, 1)
	tinsert(ns.statusbars, bg)
	EclipseBar.bg = bg

	local lunarBG = EclipseBar:CreateTexture(nil, "BACKGROUND", nil, 1)
	lunarBG:SetPoint("TOPLEFT", EclipseBar, 1, -1)
	lunarBG:SetPoint("BOTTOMLEFT", EclipseBar, 1, 0)
	lunarBG:SetPoint("RIGHT", EclipseBar, "CENTER")
	lunarBG:SetTexture(texture)
	tinsert(ns.statusbars, lunarBG)
	EclipseBar.lunarBG = lunarBG

	local solarBG = EclipseBar:CreateTexture(nil, "BACKGROUND", nil, 1)
	solarBG:SetPoint("TOPRIGHT", EclipseBar, 1, 1)
	solarBG:SetPoint("BOTTOMRIGHT", EclipseBar, 1, 0)
	solarBG:SetPoint("LEFT", lunarBG, "RIGHT")
	solarBG:SetTexture(texture)
	tinsert(ns.statusbars, solarBG)
	EclipseBar.solarBG = solarBG

	local eclipseArrow = EclipseBar:CreateTexture(nil, "OVERLAY")
	eclipseArrow:SetPoint("CENTER", lunarBG, "RIGHT", 0, 1)
	eclipseArrow:SetSize(24, 24)
	eclipseArrow:SetTexture([[Interface\PlayerFrame\UI-DruidEclipse]])
	eclipseArrow:SetBlendMode("ADD")
	EclipseBar.directionArrow = eclipseArrow

	local eclipseText = ns.CreateFontString(EclipseBar, 16, "CENTER")
	eclipseText:SetPoint("CENTER", EclipseBar, "CENTER", 0, 1)
	eclipseText:Hide()
	self:Tag(eclipseText, "[pereclipse]%")
	tinsert(self.mouseovers, eclipseText)
	EclipseBar.value = eclipseText

	if ns.config.eclipseBarIcons then
		local moon = EclipseBarFrame.moon
		moon:ClearAllPoints()
		moon:SetParent(EclipseBar)
		moon:SetPoint("CENTER", EclipseBar, "LEFT", -8, 0)
		moon:SetDrawLayer("OVERLAY", 1)
		EclipseBar.moon = moon

		local darkMoon = EclipseBarFrame.darkMoon
		darkMoon:ClearAllPoints()
		darkMoon:SetParent(EclipseBar)
		darkMoon:SetPoint("CENTER", moon)
		darkMoon:SetDrawLayer("OVERLAY", 1)
		EclipseBar.darkMoon = darkMoon

		local sun = EclipseBarFrame.sun
		sun:ClearAllPoints()
		sun:SetParent(EclipseBar)
		sun:SetPoint("CENTER", EclipseBar, "RIGHT", 8, 0)
		sun:SetDrawLayer("OVERLAY")
		EclipseBar.sun = sun

		local darkSun = EclipseBarFrame.darkSun
		darkSun:ClearAllPoints()
		darkSun:SetParent(EclipseBar)
		darkSun:SetPoint("CENTER", sun)
		darkSun:SetDrawLayer("OVERLAY", 1)
		EclipseBar.darkSun = darkSun

		local glow = EclipseBarFrame.glow
		glow:SetParent(EclipseBar)
		glow:SetDrawLayer("OVERLAY", 2)
		EclipseBar.glow = glow

		EclipseBar.moonActivate = EclipseBarFrame.moonActivate
		EclipseBar.moonDeactivate = EclipseBarFrame.moonDeactivate
		EclipseBar.sunActivate = EclipseBarFrame.sunActivate
		EclipseBar.sunDeactivate = EclipseBarFrame.sunDeactivate

		EclipseBarFrame:EnableMouse(false)
		EclipseBarFrame:SetParent(self)
		EclipseBarFrame:SetScript("OnShow", nil)
		EclipseBarFrame:SetScript("OnEvent", nil)
		EclipseBarFrame:SetScript("OnUpdate", nil)
		EclipseBarFrame:Show()

		EclipseBarFrameBar:SetTexture("")
		EclipseBarFrameMarker:SetTexture("")
		EclipseBarFrameMoonBar:SetTexture("")
		EclipseBarFrameSunBar:SetTexture("")

		EclipseBarFrame.hasLunarEclipse = false
		EclipseBarFrame.hasSolarEclipse = false
	end

	EclipseBar:SetScript("OnEnter", ns.UnitFrame_OnEnter)
	EclipseBar:SetScript("OnLeave", ns.UnitFrame_OnLeave)

	EclipseBar.__name = "EclipseBar"
	EclipseBar:Hide()
	EclipseBar:SetScript("OnShow", ns.ExtraBar_OnShow)
	EclipseBar:SetScript("OnHide", ns.ExtraBar_OnHide)

	EclipseBar.PostUpdateVisibility = PostUpdateVisibility
	EclipseBar.PostDirectionChange = PostDirectionChange
	EclipseBar.PostUnitAura = PostUnitAura
	EclipseBar.PostUpdatePower = PostUpdatePower

	return EclipseBar
end