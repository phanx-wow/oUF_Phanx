--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

if select(2, UnitClass("player")) ~= "DRUID" then return end

local _, ns = ...
local EclipseBar

local ECLIPSE_MARKER_COORDS = ECLIPSE_MARKER_COORDS
local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
local GetEclipseDirection = GetEclipseDirection

local function EclipseBar_OnShow(self)
	local frame = self.__owner
	frame:SetBorderParent(self)
	frame:SetBorderSize()
end

local function EclipseBar_OnHide(self)
	local frame = self.__owner
	frame:SetBorderParent(frame.overlay)
	frame:SetBorderSize()
end

local function Frame_SetBorderSize(self, size, offset)
	if EclipseBar:IsShown() then
		local _, offset = self:GetBorderSize()
		self.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", EclipseBar, -offset, offset)
		self.BorderTextures.TOPRIGHT:SetPoint("TOPRIGHT", EclipseBar, offset, offset)
	end
end

local function EclipseBar_PostUpdatePower(self, unit)
	local cur = UnitPower(unit, SPELL_POWER_ECLIPSE)
	local max = UnitPowerMax(unit, SPELL_POWER_ECLIPSE)

	local direction = GetEclipseDirection()
	self.directionArrow:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS[direction]))

	local x = (cur / max) * (self:GetWidth() / 2)
	if direction == "moon" then
		self.directionArrow:SetPoint("CENTER", self, x + 1, 1)
	elseif direction == "sun" then
		self.directionArrow:SetPoint("CENTER", self, x - 1, 1)
	else
		self.directionArrow:SetPoint("CENTER", self, x, 1)
	end
end

local function EclipseBar_PostUnitAura(self, unit)
	local hasLunarEclipse, hasSolarEclipse = self.hasLunarEclipse, self.hasSolarEclipse

	if hasLunarEclipse then
		self.solarBG:SetAlpha(0.5)
	else
		self.solarBG:SetAlpha(hasSolarEclipse and 1 or 0.8)
	end
	if hasSolarEclipase then
		self.lunarBG:SetAlpha(0.6)
	else
		self.lunarBG:SetAlpha(hasLunarEclipse and 1 or 0.8)
	end

	local glow = self.glow
	if glow then
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

	self:PostUpdatePower(unit)
end

function ns.CreateEclipseBar(self)
	if EclipseBar then
		return EclipseBar
	end

	EclipseBar = CreateFrame("Frame", nil, self)
	EclipseBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	EclipseBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 0)
	EclipseBar:SetHeight(self:GetHeight() * ns.config.powerHeight + 1)

	local texture = ns.config.statusbar

	local bg = EclipseBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(true)
	bg:SetTexture(texture)
	bg:SetVertexColor(0, 0, 0, 1)
	tinsert(ns.statusbars, bg)
	EclipseBar.bg = bg

	local lunarBG = EclipseBar:CreateTexture(nil, "BACKGROUND", nil, 1)
	lunarBG:SetPoint("TOPLEFT", EclipseBar, 1, -1)
	lunarBG:SetPoint("BOTTOMRIGHT", EclipseBar, "BOTTOM")
	lunarBG:SetTexture(texture)
	lunarBG:SetVertexColor(0, 0.6, 1)
	tinsert(ns.statusbars, lunarBG)
	EclipseBar.lunarBG = lunarBG

	local solarBG = EclipseBar:CreateTexture(nil, "BACKGROUND", nil, 1)
	solarBG:SetPoint("TOPRIGHT", EclipseBar, 1, 1)
	solarBG:SetPoint("BOTTOMLEFT", EclipseBar, "BOTTOM")
	solarBG:SetTexture(texture)
	solarBG:SetVertexColor(1, 0.8, 0)
	tinsert(ns.statusbars, solarBG)
	EclipseBar.solarBG = solarBG

	local eclipseArrow = EclipseBar:CreateTexture(nil, "OVERLAY")
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
	hooksecurefunc(self, "SetBorderSize", Frame_SetBorderSize)

	EclipseBar.PostDirectionChange = EclipseBar_PostUnitAura
	EclipseBar.PostUnitAura = EclipseBar_PostUnitAura
	EclipseBar.PostUpdatePower = EclipseBar_PostUpdatePower

	return EclipseBar
end