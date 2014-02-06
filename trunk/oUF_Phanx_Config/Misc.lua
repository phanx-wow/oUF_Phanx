--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")
local L = ns.L

LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(L.MoreSettings, "oUF Phanx", function(panel)
	local title, notes = panel:CreateHeader(panel.name, L.MoreSettings_Desc)

	--------------------------------------------------------------------

	local FrameWidth = panel:CreateSlider(L.FrameWidth, L.FrameWidth_Desc, 100, 400, 20)
	FrameWidth:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	FrameWidth:SetPoint("TOPRIGHT", notes, "BOTTOM", -12, -12)
	function FrameWidth:OnValueChanged(value)
		ns.config.width = value
	end

	local FrameHeight = panel:CreateSlider(L.FrameHeight, L.FrameHeight_Desc, 10, 60, 5)
	FrameHeight:SetPoint("TOPLEFT", FrameWidth, "BOTTOMLEFT", 0, -24)
	FrameHeight:SetPoint("TOPRIGHT", FrameWidth, "BOTTOMRIGHT", 0, -24)
	function FrameHeight:OnValueChanged(value)
		ns.config.height = value
	end

	local PowerHeight = panel:CreateSlider(L.PowerHeight, L.PowerHeight_Desc, 0.1, 0.5, 0.05, true)
	PowerHeight:SetPoint("TOPLEFT", FrameHeight, "BOTTOMLEFT", 0, -24)
	PowerHeight:SetPoint("TOPRIGHT", FrameHeight, "BOTTOMRIGHT", 0, -24)
	function PowerHeight:OnValueChanged(value)
		ns.config.powerHeight = value
	end

	--------------------------------------------------------------------

	local ClassFeatures = {}

	if playerClass == "DEATHKNIGHT" then

		local RuneBars = panel:CreateCheckbox(L.RuneBars, L.RuneBars_Desc)
		RuneBars:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		function RuneBars:OnValueChanged(value)
			ns.config.runeBars = value
		end
		RuneBars.checkedKey = "runeBars"
		tinsert(ClassFeatures, RuneBars)

	elseif playerClass == "DRUID" then

		local DruidMana = panel:CreateCheckbox(L.DruidMana, L.DruidMana_Desc)
		DruidMana:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		function DruidMana:OnValueChanged(value)
			ns.config.druidMana = value
		end
		DruidMana.checkedKey = "druidMana"
		tinsert(ClassFeatures, DruidMana)

		local EclipseBar = panel:CreateCheckbox(L.EclipseBar, L.EclipseBar_Desc)
		EclipseBar:SetPoint("TOPLEFT", DruidMana, "BOTTOMLEFT", 0, -12)
		function EclipseBar:OnValueChanged(value)
			ns.config.eclipseBar = value
			EclipseBarIcons:SetEnabled(value)
		end
		EclipseBar.checkedKey = "eclipseBar"
		tinsert(ClassFeatures, EclipseBar)

		local EclipseBarIcons = panel:CreateCheckbox(L.EclipseBarIcons, L.EclipseBarIcons_Desc)
		EclipseBarIcons:SetPoint("TOPLEFT", EclipseBar, "BOTTOMLEFT", 0, -12)
		function EclipseBarIcons:OnValueChanged(value)
			ns.config.eclipseBarIcons = value
		end
		EclipseBarIcons.checkedKey = "eclipseBarIcons"
		EclipseBarIcons.enabledKey = "eclipseBar"
		tinsert(ClassFeatures, EclipseBarIcons)

	elseif playerClass == "MONK" then

		local StaggerBar = panel:CreateCheckbox(L.StaggerBar, L.StaggerBar_Desc)
		StaggerBar:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		function StaggerBar:OnValueChanged(value)
			ns.config.staggerBar = value
		end
		StaggerBar.checkedKey = "staggerBar"
		tinsert(ClassFeatures, StaggerBar)

	elseif playerClass == "SHAMAN" then

		local TotemBars = panel:CreateCheckbox(L.TotemBars, L.TotemBars_Desc)
		TotemBars:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		function TotemBars:OnValueChanged(value)
			ns.config.totemBars = value
		end
		TotemBars.checkedKey = "totemBars"
		tinsert(ClassFeatures, TotemBars)

	end

	--------------------------------------------------------------------

	local reload = CreateFrame("Button", "oUFPhanxOptionsMoreReloadButton", panel, "UIPanelButtonTemplate")
	reload:SetPoint("BOTTOMLEFT", 16, 16)
	reload:SetSize(150, 22)
	reload:SetText(L.ReloadUI)
	reload:SetMotionScriptsWhileDisabled(true)
	reload:SetScript("OnEnter", function(self) self:Enable() end)
	reload:SetScript("OnLeave", function(self) self:Disable() end)
	reload:SetScript("OnClick", ReloadUI)
	reload:Disable()

	--------------------------------------------------------------------

	function panel:refresh()
		FrameWidth:SetValue(ns.config.width)
		FrameHeight:SetValue(ns.config.height)
		PowerHeight:SetValue(ns.config.powerHeight)

		for i = 1, #ClassFeatures do
			local box = ClassFeatures[i]
			box:SetChecked(ns.config[box.checkedKey])
			box:SetEnabled(box.enabledKey and ns.config[box.enabledKey] or true)
		end

		for i = 1, #oUF.objects do
			oUF.objects[i]:UpdateAllElements("OptionsRefresh")
		end
	end
end)