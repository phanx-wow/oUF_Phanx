--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")
local L = ns.L

LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(L.MoreSettings, "oUF Phanx", function(panel)
	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L.MoreSettings_Desc)

	--------------------------------------------------------------------

	local FrameWidth = CreateSlider(panel, L.FrameWidth, L.FrameWidth_Desc, 100, 400, 20)
	FrameWidth:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	FrameWidth:SetPoint("TOPRIGHT", notes, "BOTTOM", -12, -12)
	function FrameWidth:OnValueChanged(value)
		ns.config.width = value
	end

	local FrameHeight = CreateSlider(panel, L.FrameHeight, L.FrameHeight_Desc, 10, 60, 5)
	FrameHeight:SetPoint("TOPLEFT", FrameWidth, "BOTTOMLEFT", 0, -24)
	FrameHeight:SetPoint("TOPRIGHT", FrameWidth, "BOTTOMRIGHT", 0, -24)
	function FrameHeight:OnValueChanged(value)
		ns.config.height = value
	end

	local PowerHeight = CreateSlider(panel, L.PowerHeight, L.PowerHeight_Desc, 0.1, 0.5, 0.05, true)
	PowerHeight:SetPoint("TOPLEFT", FrameHeight, "BOTTOMLEFT", 0, -24)
	PowerHeight:SetPoint("TOPRIGHT", FrameHeight, "BOTTOMRIGHT", 0, -24)
	function PowerHeight:OnValueChanged(value)
		ns.config.powerHeight = value
	end

	--------------------------------------------------------------------

	local RuneBars, DruidMana, EclipseBar, EclipseBarIcons, TotemBars

	if playerClass == "DEATHKNIGHT" then

		RuneBars = CreateCheckbox(panel, L.RuneBars, L.RuneBars_Desc)
		RuneBars:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		function RuneBars:OnValueChanged(value)
			ns.config.runeBars = value
		end

	elseif playerClass == "DRUID" then

		DruidMana = CreateCheckbox(panel, L.DruidMana, L.DruidMana_Desc)
		DruidMana:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		function DruidMana:OnValueChanged(value)
			ns.config.druidMana = value
		end

		EclipseBar = CreateCheckbox(panel, L.EclipseBar, L.EclipseBar_Desc)
		EclipseBar:SetPoint("TOPLEFT", DruidMana, "BOTTOMLEFT", 0, -12)
		function EclipseBar:OnValueChanged(value)
			ns.config.eclipseBar = value
			EclipseBarIcons:SetEnabled(value)
		end

		EclipseBarIcons = CreateCheckbox(panel, L.EclipseBarIcons, L.EclipseBarIcons_Desc)
		EclipseBarIcons:SetPoint("TOPLEFT", EclipseBar, "BOTTOMLEFT", 0, -12)
		function EclipseBarIcons:OnValueChanged(value)
			ns.config.eclipseBarIcons = value
		end

	elseif playerClass == "SHAMAN" then

		TotemBars = CreateCheckbox(panel, L.TotemBars, L.TotemBars_Desc)
		TotemBars:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		function TotemBars:OnValueChanged(value)
			ns.config.totemBars = value
		end

	end

	--------------------------------------------------------------------

	local reload = CreateFrame("Button", "oUFPhanxOptionsMoreReloadButton", panel, "UIPanelButtonTemplate")
	reload:SetPoint("BOTTOMLEFT", 16, 16)
	reload:SetSize(150, 22)
	reload:SetText(L.ReloadUI)
	reload:Disable()
	reload:SetMotionScriptsWhileDisabled(true)
	reload:SetScript("OnEnter", function(self) self:Enable() end)
	reload:SetScript("OnLeave", function(self) self:Disable() end)
	reload:SetScript("OnClick", ReloadUI)

	--------------------------------------------------------------------

	function panel:refresh()
		FrameWidth:SetValue(ns.config.width)
		FrameHeight:SetValue(ns.config.height)
		PowerHeight:SetValue(ns.config.powerHeight)

		if RuneBars then
			RuneBars:SetChecked(ns.config.runeBars)

		elseif DruidMana then
			DruidMana:SetChecked(ns.config.druidMana)
			EclipseBar:SetChecked(ns.config.eclipseBar)
			EclipseBarIcons:SetChecked(ns.config.eclipseBarIcons)
			EclipseBarIcons:SetEnabled(ns.config.eclipseBar)

		elseif TotemBars then
			TotemBars:SetChecked(ns.config.totemBars)
		end

		for i = 1, #oUF.objects do
			oUF.objects[i]:UpdateAllElements("OptionsRefresh")
		end
	end
end)