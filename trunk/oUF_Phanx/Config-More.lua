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

L.MoreSettings = "More Settings"
L.MoreSettings_Info = "These settings will not take effect until the next time you reload your UI."
L.FrameWidth = "Base Width"
L.FrameWidth_Info = "Set the base frame width. Some frames are proportionally wider or narrower."
L.FrameHeight = "Base Height"
L.FrameHeight_Info = "Set the base frame height."
L.PowerHeight = "Power Bar Height"
L.PowerHeight_Info = "Set the height of the power bar, as a percent of the total frame height."

local function CreateSlider(parent)
	local slider = CreateFrame("Slider", "$parentSlider", parent, "OptionsSliderTemplate")
	slider:SetWidth(250)

	slider.Text = _G[slider:GetName().."Text"]

	slider.Low = _G[slider:GetName().."Low"]
	slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, 0)

	slider.High = _G[slider:GetName().."High"]
	slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, 0)

	slider.Value = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	slider.Value:SetPoint("TOP", slider, "BOTTOM", 0, 0)

	return slider
end

LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(L.MoreSettings, "oUF Phanx", function(self)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(self, self.name, L.MoreSettings_Info)

	local FrameWidth = CreateSlider(self)
	FrameWidth:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 6, 30)
	FrameWidth:SetPoint("TORPIGHT", notes, "BOTTOM", -10, 30)
	FrameWidth.Text:SetText(L.FrameWidth)
	FrameWidth.tooltipText = L.FrameWidth_Info
	FrameWidth.Low:SetText(100)
	FrameWidth.High:SetText(400)
	FrameWidth:SetMinMaxValues(100, 400)
	FrameWidth:SetValueStep(20)
	FrameWidth:SetScript("OnValueChanged", function(this, value)
		value = floor(value + 0.5)
		ns.config.width = value
		this.Value:SetText(value)
	end)

	local FrameHeight = CreateSlider(self)
	FrameHeight:SetPoint("TOPLEFT", FrameWidth, "BOTTOMLEFT", 0, 30)
	FrameHeight:SetPoint("TOPRIGHT", FrameWidth, "BOTTOMRIGHT", 0, 30)
	FrameHeight.Text:SetText(L.FrameHeight)
	FrameHeight.tooltipText = L.FrameHeight_Info
	FrameHeight.Low:SetText(100)
	FrameHeight.High:SetText(400)
	FrameHeight:SetMinMaxValues(100, 400)
	FrameHeight:SetValueStep(20)
	FrameHeight:SetScript("OnValueChanged", function(this, value)
		value = floor(value + 0.5)
		ns.config.height = value
		this.Value:SetText(value)
	end)

	local PowerHeight = CreateSlider(self)
	PowerHeight:SetPoint("TOPLEFT", FrameHeight, "BOTTOMLEFT", 0, 30)
	PowerHeight:SetPoint("TOPRIGHT", FrameHeight, "BOTTOMRIGHT", 0, 30)
	PowerHeight.Text:SetText(L.PowerHeight)
	PowerHeight.tooltipText = L.PowerHeight_Info
	PowerHeight.Low:SetText("10%")
	PowerHeight.High:SetText("50%")
	PowerHeight:SetMinMaxValues(10, 50)
	PowerHeight:SetValueStep(5)
	PowerHeight:SetScript("OnValueChanged", function(this, value)
		value = floor(value + 0.5)
		ns.config.powerHeight = value / 100
		this.Value:SetFormattedText("%d%%", value)
	end)

	--------------------------------------------------------------------

	local RuneBars, DruidMana, EclipseBar, EclipseBarIcons, TotemBars

	if playerClass == "DEATHKNIGHT" then
		RuneBars = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
		RuneBars:SetPoint("TOPLEFT", notes, "BOTTOM", 6, -8)
		RuneBars.Text:SetText(L.RuneBars)
		RuneBars.tooltipText = L.RuneBars_Info
		RuneBars:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.runeBars = checked
		end)

	elseif playerClass == "DRUID" then
		DruidMana = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
		DruidMana:SetPoint("TOPLEFT", notes, "BOTTOM", 6, -8)
		DruidMana.Text:SetText(L.DruidManaBar)
		DruidMana.tooltipText = L.DruidManaBar_Info
		DruidMana:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.druidMana = checked
		end)

		EclipseBar = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
		EclipseBar:SetPoint("TOPLEFT", DruidMana, "BOTTOMLEFT", 0, -8)
		EclipseBar.Text:SetText(L.EclipseBar)
		EclipseBar.tooltipText = L.EclipseBar_Info
		EclipseBar:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.eclipseBar = checked
			EclipseBarIcons:SetEnabled(checked)
		end)

		EclipseBarIcons = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
		EclipseBarIcons:SetPoint("TOPLEFT", EclipseBar, "BOTTOMLEFT", 0, -8)
		EclipseBarIcons.Text:SetText(L.EclipseBarIcons)
		EclipseBarIcons.tooltipText = L.EclipseBarIcons_Info
		EclipseBarIcons:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.eclipseBarIcons = checked
		end)

	elseif playerclass == "SHAMAN" then
		TotemBars = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
		TotemBars:SetPoint("TOPLEFT", notes, "BOTTOM", 6, -8)
		TotemBars.Text:SetText(L.TotemBars)
		TotemBars.tooltipText = L.TotemBars_Info
		TotemBars:SetScript("OnClick", function(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
			ns.config.totemBars = checked
		end)

	end

	--------------------------------------------------------------------

	function self:refresh()
		FrameWidth:SetValue(ns.config.width)
		FrameHeight:SetValue(ns.config.height)
		PowerHeight:SetValue(ns.config.powerHeight)

		if RuneBars then
			RuneBars:SetChecked(db.runeBars)
		end

		if DruidMana then
			DruidMana:SetChecked(db.druidMana)
			EclipseBar:SetChecked(db.eclipseBar)
			EclipseBarIcons:SetChecked(db.eclipseBarIcons)
			EclipseBarIcons:SetEnabled(db.eclipseBar)
		end

		if TotemBars then
			TotemBars:SetChecked(db.totemBars)
		end
	end
end)