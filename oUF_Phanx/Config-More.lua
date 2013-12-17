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

LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(L.MoreSettings, "oUF Phanx", function(self)
	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(self, self.name, L.MoreSettings_Desc)

	--------------------------------------------------------------------

	local FrameWidth = CreateSlider(self, L.FrameWidth, L.FrameWidth_Desc, 100, 400, 20)
	FrameWidth:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	FrameWidth:SetPoint("TOPRIGHT", notes, "BOTTOM", -12, -12)
	function FrameWidth:OnValueChanged(value)
		ns.config.width = value
	end

	local FrameHeight = CreateSlider(self, L.FrameHeight, L.FrameHeight_Desc, 10, 60, 5)
	FrameHeight:SetPoint("TOPLEFT", FrameWidth, "BOTTOMLEFT", 0, -24)
	FrameHeight:SetPoint("TOPRIGHT", FrameWidth, "BOTTOMRIGHT", 0, -24)
	function FrameHeight:OnValueChanged(value)
		ns.config.height = value
	end

	local PowerHeight = CreateSlider(self, L.PowerHeight, L.PowerHeight_Desc, 0.1, 0.5, 0.05, true)
	PowerHeight:SetPoint("TOPLEFT", FrameHeight, "BOTTOMLEFT", 0, -24)
	PowerHeight:SetPoint("TOPRIGHT", FrameHeight, "BOTTOMRIGHT", 0, -24)
	function PowerHeight:OnValueChanged(value)
		ns.config.powerHeight = value
	end

	--------------------------------------------------------------------

	local CombatText = CreateCheckbox(self, L.CombatText, L.CombatText_Desc)
	CombatText:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
	function CombatText:OnValueChanged(value)
		ns.config.combatText = value
	end

	local RuneBars, DruidMana, EclipseBar, EclipseBarIcons, TotemBars

	if playerClass == "DEATHKNIGHT" then

		RuneBars = CreateCheckbox(self, L.RuneBars, L.RuneBars_Desc)
		RuneBars:SetPoint("TOPLEFT", CombatText, "BOTTOMLEFT", 0, -12)
		function RuneBars:OnValueChanged(value)
			ns.config.runeBars = value
		end

	elseif playerClass == "DRUID" then

		DruidMana = CreateCheckbox(self, L.DruidMana, L.DruidMana_Desc)
		DruidMana:SetPoint("TOPLEFT", CombatText, "BOTTOMLEFT", 0, -12)
		function DruidMana:OnValueChanged(value)
			ns.config.druidMana = value
		end

		EclipseBar = CreateCheckbox(self, L.EclipseBar, L.EclipseBar_Desc)
		EclipseBar:SetPoint("TOPLEFT", DruidMana, "BOTTOMLEFT", 0, -12)
		function EclipseBar:OnValueChanged(value)
			ns.config.eclipseBar = value
			EclipseBarIcons:SetEnabled(value)
		end

		EclipseBarIcons = CreateCheckbox(self, L.EclipseBarIcons, L.EclipseBarIcons_Desc)
		EclipseBarIcons:SetPoint("TOPLEFT", EclipseBar, "BOTTOMLEFT", 0, -12)
		function EclipseBarIcons:OnValueChanged(value)
			ns.config.eclipseBarIcons = value
		end

	elseif playerClass == "SHAMAN" then

		TotemBars = CreateCheckbox(self, L.TotemBars, L.TotemBars_Desc)
		TotemBars:SetPoint("TOPLEFT", CombatText, "BOTTOMLEFT", 0, -12)
		function TotemBars:OnValueChanged(value)
			ns.config.totemBars = value
		end

	end

	--------------------------------------------------------------------

	local Reload = CreateFrame("Button", "oUFPhanxOptionsReloadButton", self, "UIPanelButtonTemplate")
	Reload:SetPoint("BOTTOMRIGHT", -16, 16)
	Reload:SetSize(96, 22)
	Reload:SetText(L.ReloadUI)
	Reload:SetAlpha(0.75)
	Reload:SetScript("OnEnter", function(this) this:SetAlpha(1) end)
	Reload:SetScript("OnLeave", function(this) this:SetAlpha(0.75) end)
	Reload:SetScript("OnClick", ReloadUI)

	--------------------------------------------------------------------

	function self:refresh()
		Reload:SetWidth(max(96, Reload:GetFontString():GetStringWidth() + 16))

		FrameWidth:SetValue(ns.config.width)
		FrameHeight:SetValue(ns.config.height)
		PowerHeight:SetValue(ns.config.powerHeight)

		CombatText:SetValue(ns.config.combatText)

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