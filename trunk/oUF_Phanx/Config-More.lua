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

	local RuneBars, DruidMana, EclipseBar, EclipseBarIcons, TotemBars

	if playerClass == "DEATHKNIGHT" then
		RuneBars = CreateFrame("CheckButton", "oUFPCRuneBars", self, "InterfaceOptionsCheckButtonTemplate")
		RuneBars:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		RuneBars.Text:SetText(L.RuneBars)
		RuneBars.tooltipText = L.RuneBars_Desc
		RuneBars:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.runeBars = checked
		end)

	elseif playerClass == "DRUID" then
		DruidMana = CreateFrame("CheckButton", "oUFPCDruidMana", self, "InterfaceOptionsCheckButtonTemplate")
		DruidMana:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		DruidMana.Text:SetText(L.DruidManaBar)
		DruidMana.tooltipText = L.DruidManaBar_Desc
		DruidMana:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.druidMana = checked
		end)

		EclipseBar = CreateFrame("CheckButton", "oUFPCEclipseBar", self, "InterfaceOptionsCheckButtonTemplate")
		EclipseBar:SetPoint("TOPLEFT", DruidMana, "BOTTOMLEFT", 0, -12)
		EclipseBar.Text:SetText(L.EclipseBar)
		EclipseBar.tooltipText = L.EclipseBar_Desc
		EclipseBar:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.eclipseBar = checked
			EclipseBarIcons:SetEnabled(checked)
		end)

		EclipseBarIcons = CreateFrame("CheckButton", "oUFPCEclipseBarIcons", self, "InterfaceOptionsCheckButtonTemplate")
		EclipseBarIcons:SetPoint("TOPLEFT", EclipseBar, "BOTTOMLEFT", 0, -12)
		EclipseBarIcons.Text:SetText(L.EclipseBarIcons)
		EclipseBarIcons.tooltipText = L.EclipseBarIcons_Desc
		EclipseBarIcons:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.eclipseBarIcons = checked
		end)

	elseif playerClass == "SHAMAN" then
		TotemBars = CreateFrame("CheckButton", "oUFPCTotemBars", self, "InterfaceOptionsCheckButtonTemplate")
		TotemBars:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
		TotemBars.Text:SetText(L.TotemBars)
		TotemBars.tooltipText = L.TotemBars_Desc
		TotemBars:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.totemBars = checked
		end)

	end

	--------------------------------------------------------------------

	local Reload = CreateFrame("Button", "oUFPCReloadButton", self, "UIPanelButtonTemplate")
	Reload:SetPoint("BOTTOMRIGHT", -16, 16)
	Reload:SetWidth(80)
	Reload:SetText(L.ReloadUI)
	Reload:SetAlpha(0.5)
	Reload:SetScript("OnEnter", function(this) this:SetAlpha(1) end)
	Reload:SetScript("OnLeave", function(this) this:SetAlpha(0.1) end)
	Reload:SetScript("OnClick", ReloadUI)

	--------------------------------------------------------------------

	function self:refresh()
		FrameWidth:SetValue(ns.config.width)
		FrameHeight:SetValue(ns.config.height)
		PowerHeight:SetValue(ns.config.powerHeight)

		if RuneBars then
			RuneBars:SetChecked(ns.config.runeBars)
		end

		if DruidMana then
			DruidMana:SetChecked(ns.config.druidMana)
			EclipseBar:SetChecked(ns.config.eclipseBar)
			EclipseBarIcons:SetChecked(ns.config.eclipseBarIcons)
			EclipseBarIcons:SetEnabled(ns.config.eclipseBar)
		end

		if TotemBars then
			TotemBars:SetChecked(ns.config.totemBars)
		end

		for i = 1, #oUF.objects do
			oUF.objects[i]:UpdateAllElements("OptionsRefresh")
		end
	end
end)