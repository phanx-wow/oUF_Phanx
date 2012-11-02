--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...

local ECLIPSE_MARKER_COORDS = ECLIPSE_MARKER_COORDS
local SPELL_POWER_ECLIPSE = SPELL_POWER_ECLIPSE
local GetEclipseDirection = GetEclipseDirection

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

local eclipseBar
function ns.CreateEclipseBar(self, texture, useEclipseBarIcons)
	if eclipseBar then
		eclipseBar:SetParent(self)
		if eclipseBar.glow then
			EclipseBarFrame:SetParent(self)
		end
		return eclipseBar
	end

	eclipseBar = CreateFrame("Frame", nil, self)

	local bg = eclipseBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(true)
	bg:SetTexture(texture)
	bg:SetVertexColor(0, 0, 0, 1)
	eclipseBar.bg = bg

	local lunarBG = eclipseBar:CreateTexture(nil, "BACKGROUND", nil, 1)
	lunarBG:SetPoint("TOPLEFT")
	lunarBG:SetPoint("BOTTOMRIGHT", eclipseBar, "BOTTOM")
	lunarBG:SetTexture(texture)
	lunarBG:SetVertexColor(0, 0.6, 1)
	eclipseBar.lunarBG = lunarBG

	local solarBG = eclipseBar:CreateTexture(nil, "BACKGROUND", nil, 1)
	solarBG:SetPoint("TOPRIGHT")
	solarBG:SetPoint("BOTTOMLEFT", eclipseBar, "BOTTOM")
	solarBG:SetTexture(texture)
	solarBG:SetVertexColor(1, 0.8, 0)
	eclipseBar.solarBG = solarBG

	local eclipseArrow = eclipseBar:CreateTexture(nil, "OVERLAY")
	eclipseArrow:SetSize(24, 24)
	eclipseArrow:SetTexture([[Interface\PlayerFrame\UI-DruidEclipse]])
	eclipseArrow:SetBlendMode("ADD")
	eclipseBar.directionArrow = eclipseArrow

	if useEclipseBarIcons then
		local moon = EclipseBarFrame.moon
		moon:ClearAllPoints()
		moon:SetParent(eclipseBar)
		moon:SetPoint("CENTER", eclipseBar, "LEFT", -8, 0)
		moon:SetDrawLayer("OVERLAY", 1)
		eclipseBar.moon = moon

		local darkMoon = EclipseBarFrame.darkMoon
		darkMoon:ClearAllPoints()
		darkMoon:SetParent(eclipseBar)
		darkMoon:SetPoint("CENTER", moon)
		darkMoon:SetDrawLayer("OVERLAY", 1)
		eclipseBar.darkMoon = darkMoon

		local sun = EclipseBarFrame.sun
		sun:ClearAllPoints()
		sun:SetParent(eclipseBar)
		sun:SetPoint("CENTER", eclipseBar, "RIGHT", 8, 0)
		sun:SetDrawLayer("OVERLAY")
		eclipseBar.sun = sun

		local darkSun = EclipseBarFrame.darkSun
		darkSun:ClearAllPoints()
		darkSun:SetParent(eclipseBar)
		darkSun:SetPoint("CENTER", sun)
		darkSun:SetDrawLayer("OVERLAY", 1)
		eclipseBar.darkSun = darkSun

		local glow = EclipseBarFrame.glow
		glow:SetParent(eclipseBar)
		glow:SetDrawLayer("OVERLAY", 2)
		eclipseBar.glow = glow

		eclipseBar.moonActivate = EclipseBarFrame.moonActivate
		eclipseBar.moonDeactivate = EclipseBarFrame.moonDeactivate
		eclipseBar.sunActivate = EclipseBarFrame.sunActivate
		eclipseBar.sunDeactivate = EclipseBarFrame.sunDeactivate

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

	eclipseBar.PostDirectionChange = EclipseBar_PostUnitAura
	eclipseBar.PostUnitAura = EclipseBar_PostUnitAura
	eclipseBar.PostUpdatePower = EclipseBar_PostUpdatePower

	return eclipseBar
end