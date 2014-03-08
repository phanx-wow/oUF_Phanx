--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local L = ns.L

-- import other ns and remove global
setmetatable(ns, { __index = oUFPhanx })
oUFPhanx = nil

-- map values to labels
local outlineWeights = {
	NONE = L.None,
	OUTLINE = L.Thin,
	THICKOUTLINE = L.Thick,
}
local healthColorModes = {
	CLASS  = L.ColorClass,
	HEALTH = L.ColorHealth,
	CUSTOM = L.ColorCustom,
}
local powerColorModes = {
	CLASS  = L.ColorClass,
	POWER  = L.ColorPower,
	CUSTOM = L.ColorCustom,
}

------------------------------------------------------------------------
--	Options panel
------------------------------------------------------------------------

LibStub("PhanxConfig-OptionsPanel"):New(oUFPhanxOptions, nil, function(panel)
	local db = oUFPhanxConfig
	local Media = LibStub("LibSharedMedia-3.0")

	--------------------------------------------------------------------

	local title, notes = panel:CreateHeader(panel.name, L.Options_Desc)

	--------------------------------------------------------------------

	local statusbar = panel:CreateScrollingDropdown(L.Texture, nil, Media:List("statusbar"))
	statusbar:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	statusbar:SetPoint("TOPRIGHT", notes, "BOTTOM", -12, -12)

	local valueBG = statusbar.dropdown:CreateTexture(nil, "OVERLAY")
	valueBG:SetPoint("LEFT", statusbar.valueText, -2, 1)
	valueBG:SetPoint("RIGHT", statusbar.valueText, 5, 1)
	valueBG:SetHeight(15)
	valueBG:SetVertexColor(0.35, 0.35, 0.35)
	statusbar.valueBG = valueBG

	function statusbar:OnValueChanged(value)
		local file = Media:Fetch("statusbar", value)
		valueBG:SetTexture(file)

		if value == db.statusbar then return end

		db.statusbar = value
		ns.SetAllStatusBarTextures()
	end

	do
		local button_OnClick = statusbar.button:GetScript("OnClick")
		statusbar.button:SetScript("OnClick", function(self)
			button_OnClick(self)
			statusbar.dropdown.list:Hide()

			local function GetButtonBackground(self)
				if not self.bg then
					local bg = self:CreateTexture(nil, "BACKGROUND")
					bg:SetPoint("TOPLEFT", -3, 0)
					bg:SetPoint("BOTTOMRIGHT", 3, 0)
					bg:SetVertexColor(0.35, 0.35, 0.35)
					self.bg = bg
				end
				return self.bg
			end

			local function SetButtonBackgroundTextures(self)
				local numButtons = 0
				local buttons = statusbar.dropdown.list.buttons
				for i = 1, #buttons do
					local button = buttons[i]
					if i > 1 then
						button:SetPoint("TOPLEFT", buttons[i - 1], "BOTTOMLEFT", 0, -1)
					end
					if button.value and button:IsShown() then
						local bg = button.bg or GetButtonBackground(button)
						bg:SetTexture(Media:Fetch("statusbar", button.value))
						local file, size = button.label:GetFont()
						button.label:SetFont(file, size, "OUTLINE")
						numButtons = numButtons + 1
					end
				end
				statusbar.dropdown.list:SetHeight(statusbar.dropdown.list:GetHeight() + (numButtons * 1))
			end

			local OnShow = statusbar.dropdown.list:GetScript("OnShow")
			statusbar.dropdown.list:SetScript("OnShow", function(self)
				OnShow(self)
				SetButtonBackgroundTextures(self)
			end)

			local OnVerticalScroll = statusbar.dropdown.list.scrollFrame:GetScript("OnVerticalScroll")
			statusbar.dropdown.list.scrollFrame:SetScript("OnVerticalScroll", function(self, delta)
				OnVerticalScroll(self, delta)
				SetButtonBackgroundTextures(self)
			end)

			button_OnClick(self)
			self:SetScript("OnClick", button_OnClick)
		end)
	end

	--------------------------------------------------------------------

	local font = panel:CreateScrollingDropdown(L.Font, nil, Media:List("font"))
	font:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, -12)
	font:SetPoint("TOPRIGHT", statusbar, "BOTTOMRIGHT", 0, -12)

	function font:OnValueChanged(value)
		local file = Media:Fetch("font", value)
		local _, height, flags = self.valueText:GetFont()
		self.valueText:SetFont(file, height, flags)

		if value == db.font then return end

		db.font = value
		ns.SetAllFonts()
	end

	do
		local button_OnClick = font.button:GetScript("OnClick")
		font.button:SetScript("OnClick", function(self)
			button_OnClick(self)
			font.dropdown.list:Hide()

			local function SetButtonFonts(self)
				local buttons = font.dropdown.list.buttons
				for i = 1, #buttons do
					local button = buttons[i]
					if button.value and button:IsShown() then
						button.label:SetFont(Media:Fetch("font", button.value), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT)
					end
				end
			end

			local OnShow = font.dropdown.list:GetScript("OnShow")
			font.dropdown.list:SetScript("OnShow", function(self)
				OnShow(self)
				SetButtonFonts(self)
			end)

			local OnVerticalScroll = font.dropdown.list.scrollFrame:GetScript("OnVerticalScroll")
			font.dropdown.list.scrollFrame:SetScript("OnVerticalScroll", function(self, delta)
				OnVerticalScroll(self, delta)
				SetButtonFonts(self)
			end)

			local SetText = font.dropdown.list.text.SetText
			function font.dropdown.list.text:SetText(text)
				self:SetFont(Media:Fetch("font", text), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT + 1)
				SetText(self, text)
			end

			button_OnClick(self)
			self:SetScript("OnClick", button_OnClick)
		end)
	end

	--------------------------------------------------------------------

	local outline
	do
		local function OnClick(self)
			local value = self.value
			outline:SetValue(value, outlineWeights[value])
			db.fontOutline = value
			ns.SetAllFonts()
		end

		outline = panel:CreateDropdown(L.Outline, nil, function()
			local selected = db.fontOutline

			local info = {}
			info.func = OnClick

			info.text = L.None
			info.value = "NONE"
			info.checked = "NONE" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L.Thin
			info.value = "OUTLINE"
			info.checked = "OUTLINE" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L.Thick
			info.value = "THICKOUTLINE"
			info.checked = "THICKOUTLINE" == selected
			UIDropDownMenu_AddButton(info)
		end)

		outline:SetPoint("TOPLEFT", font, "BOTTOMLEFT", 0, -12)
		outline:SetPoint("TOPRIGHT", font, "BOTTOMRIGHT", 0, -12)
	end

	--------------------------------------------------------------------

	local borderSize = panel:CreateSlider(L.BorderSize, nil, 12, 24, 2)
	borderSize:SetPoint("TOPLEFT", outline, "BOTTOMLEFT", 0, -12)
	borderSize:SetPoint("TOPRIGHT", outline, "BOTTOMRIGHT", 0, -12)
	function borderSize:OnValueChanged(value)
		value = floor(value + 0.5)
		db.borderSize = value
		for i = 1, #ns.borderedObjects do
			ns.borderedObjects[i]:SetBorderSize(value)
		end
		return value
	end

	--------------------------------------------------------------------

	local borderColor = panel:CreateColorPicker(L.BorderColor, L.BorderColor_Desc)
	borderColor:SetPoint("LEFT", borderSize, "RIGHT", 24, -4)

	function borderColor:GetColor()
		return unpack(db.borderColor)
	end

	function borderColor:OnColorChanged(r, g, b)
		db.borderColor[1] = r
		db.borderColor[2] = g
		db.borderColor[3] = b
		for i = 1, #ns.borderedObjects do
			ns.borderedObjects[i]:SetBorderColor(r, g, b)
		end
		for i = 1, #ns.objects do
			local frame = ns.objects[i]
			if frame.UpdateBorder then
				frame:UpdateBorder()
			end
		end
	end

	--------------------------------------------------------------------

	local dispelFilter = panel:CreateCheckbox(L.FilterDebuffHighlight, L.FilterDebuffHighlight_Desc)
	dispelFilter:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
	function dispelFilter:OnValueChanged(value)
		db.dispelFilter = value
		for i = 1, #ns.objects do
			local frame = ns.objects[i]
			if frame.DispelHighlight then
				frame.DispelHighlight.filter = value
				frame.DispelHighlight:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	local healFilter = panel:CreateCheckbox(L.IgnoreOwnHeals, L.IgnoreOwnHeals_Desc)
	healFilter:SetPoint("TOPLEFT", dispelFilter, "BOTTOMLEFT", 0, -12)
	function healFilter:OnValueChanged(value)
		db.ignoreOwnHeals = value
		for i = 1, #ns.objects do
			local frame = ns.objects[i]
			if frame.HealPrediction and frame:IsShown() then
				frame.HealPrediction:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	local threatLevels = panel:CreateCheckbox(L.ThreatLevels, L.ThreatLevels_Desc)
	threatLevels:SetPoint("TOPLEFT", healFilter, "BOTTOMLEFT", 0, -12)
	function threatLevels:OnValueChanged(value)
		db.ignoreOwnHeals = value
		for i = 1, #ns.objects do
			local frame = ns.objects[i]
			if frame.ThreatHighlight and frame:IsShown() then
				frame.ThreatHighlight:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	local healthColor

	local healthColorMode = panel:CreateDropdown(L.HealthColor, L.HealthColor_Desc)
	healthColorMode:SetPoint("TOPLEFT", borderSize, "BOTTOMLEFT", 0, -12)
	healthColorMode:SetPoint("TOPRIGHT", borderSize, "BOTTOMRIGHT", 0, -12)

	do
		local info = {}
		info.func = function(self)
			local value = self.value
			healthColorMode:SetValue(value, healthColorModes[value])
			db.healthColorMode = value
			for i = 1, #ns.objects do
				local frame = ns.objects[i]
				local health = frame.Health
				if type(health) == "table" then
					health.colorClass = value == "CLASS"
					health.colorReaction = value == "CLASS"
					health.colorSmooth = value == "HEALTH"
					if value == "CUSTOM" then
						local mu = health.bg.multiplier
						local r, g, b = unpack(db.healthColor)
						health:SetStatusBarColor(r, g, b)
						health.bg:SetVertexColor(r * mu, g * mu, b * mu)
					elseif frame:IsShown() then
						health:ForceUpdate()
					end
				end
			end
			if value == "CUSTOM" then
				healthColor:Show()
			else
				healthColor:Hide()
			end
		end
		UIDropDownMenu_Initialize(healthColorMode.dropdown, function()
			local selected = db.healthColorMode

			info.text = L.ColorClass
			info.value = "CLASS"
			info.checked = "CLASS" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L.ColorHealth
			info.value = "HEALTH"
			info.checked = "HEALTH" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L.ColorCustom
			info.value = "CUSTOM"
			info.checked = "CUSTOM" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end

	--------------------------------------------------------------------

	healthColor = panel:CreateColorPicker(L.HealthColorCustom)
	healthColor:SetPoint("LEFT", healthColorMode, "RIGHT", 24, -8)
	function healthColor:GetColor()
		return unpack(db.healthColor)
	end
	function healthColor:OnColorChanged(r, g, b)
		db.healthColor[1] = r
		db.healthColor[2] = g
		db.healthColor[3] = b
		for i = 1, #ns.objects do
			local hp = ns.objects[i].Health
			if type(hp) == "table" then
				local mu = hp.bg.multiplier
				hp:SetStatusBarColor(r, g, b)
				hp.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	--------------------------------------------------------------------

	local healthBG = panel:CreateSlider(L.HealthBG, L.HealthBG_Desc, 0, 3, 0.05, true)
	healthBG:SetPoint("TOPLEFT", healthColorMode, "BOTTOMLEFT", 0, -12)
	healthBG:SetPoint("TOPRIGHT", healthColorMode, "BOTTOMRIGHT", 0, -12)

	function healthBG:OnValueChanged(value)
		value = math.floor(value * 100 + 0.5) / 100
		db.healthBG = value
		local custom = db.healthColorMode == "CUSTOM"
		for i = 1, #ns.objects do
			local frame = ns.objects[i]
			local health = frame.Health
			if health then
				health.bg.multiplier = value
				if custom then
					local r, g, b = unpack(db.healthColor)
					health:SetStatusBarColor(r, g, b)
					health.bg:SetVertexColor(r * value, g * value, b * value)
				elseif frame:IsShown() then
					health:ForceUpdate(frame.unit)
				end
			end
		end
		return value
	end

	--------------------------------------------------------------------

	local powerColor

	local powerColorMode = panel:CreateDropdown(L.PowerColor, L.PowerColor_Desc)
	powerColorMode:SetPoint("TOPLEFT", healthBG, "BOTTOMLEFT", 0, -12)
	powerColorMode:SetPoint("TOPRIGHT", healthBG, "BOTTOMRIGHT", 0, -12)

	do
		local function OnClick(self)
			local value = self.value
			db.powerColorMode = value
			powerColorMode:SetValue(value, powerColorModes[value])
			for i = 1, #ns.objects do
				local frame = ns.objects[i]
				local power = frame.Power
				if type(power) == "table" then
					power.colorClass = value == "CLASS"
					power.colorReaction = value == "CLASS"
					power.colorPower = value == "POWER"
					if value == "CUSTOM" then
						local mu = power.bg.multiplier
						local r, g, b = unpack(db.powerColor)
						power:SetStatusBarColor(r, g, b)
						power.bg:SetVertexColor(r * mu, g * mu, b * mu)
					elseif frame:IsShown() then
						power:ForceUpdate()
					end
				end
			end
			if value == "CUSTOM" then
				powerColor:Show()
			else
				powerColor:Hide()
			end
		end

		local info = {}
		UIDropDownMenu_Initialize(powerColorMode.dropdown, function()
			local selected = db.powerColorMode

			info.text = L.ColorClass
			info.value = "CLASS"
			info.func = OnClick
			info.checked = "CLASS" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L.ColorPower
			info.value = "POWER"
			info.func = OnClick
			info.checked = "HEALTH" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L.ColorCustom
			info.value = "CUSTOM"
			info.func = OnClick
			info.checked = "CUSTOM" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end

	--------------------------------------------------------------------

	powerColor = panel:CreateColorPicker(L.PowerColorCustom)
	powerColor:SetPoint("LEFT", powerColorMode, "RIGHT", 24, -4)

	function powerColor:GetColor()
		return unpack(db.powerColor)
	end

	function powerColor:OnColorChanged(r, g, b)
		db.powerColor[1] = r
		db.powerColor[2] = g
		db.powerColor[3] = b
		for i = 1, #ns.objects do
			local frame = ns.objects[i]
			local power = frame.Power
			if type(power) == "table" then
				local mu = power.bg.multiplier
				power:SetStatusBarColor(r, g, b)
				power.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	--------------------------------------------------------------------

	local powerBG = panel:CreateSlider(L.PowerBG, L.PowerBG_Desc, 0, 3, 0.05, true)
	powerBG:SetPoint("TOPLEFT", powerColorMode, "BOTTOMLEFT", 0, -12)
	powerBG:SetPoint("TOPRIGHT", powerColorMode, "BOTTOMRIGHT", 0, -12)

	function powerBG:OnValueChanged(value)
		value = floor(value * 100 + 0.5) / 100
		db.powerBG = value
		local custom = db.powerColorMode == "CUSTOM"
		for i = 1, #ns.objects do
			local frame = ns.objects[i]
			local Power = frame.Power
			if Power then
				Power.bg.multiplier = value
				if custom then
					local r, g, b = unpack(db.powerColor)
					Power:SetStatusBarColor(r, g, b)
					Power.bg:SetVertexColor(r * value, g * value, b * value)
				elseif frame:IsShown() then
					Power:ForceUpdate()
				end
			end

			local DruidMana = frame.DruidMana
			if DruidMana then
				local r, g, b = unpack(oUF.colors.power.MANA)
				DruidMana.bg.multiplier = value
				DruidMana:ForceUpdate()
			end

			local Runes = frame.Runes
			if Runes then
				for i = 1, #Runes do
					local r, g, b = Runes[i]:GetStatusBarColor()
					Runes[i].bg:SetVertexColor(r * value, g * value, b * value)
					Runes[i].bg.multiplier = value
				end
			end

			local Totems = frame.Totems
			if Totems then
				for i = 1, #Totems do
					local r, g, b = unpack(oUF.colors.totems[SHAMAN_TOTEM_PRIORITIES[i]])
					Totems[i].bg:SetVertexColor(r * value, g * value, b * value)
					Totems[i].bg.multiplier = value
				end
			end
		end
		return value
	end

	--------------------------------------------------------------------

	function panel.refresh()
		for k, v in pairs(Media:HashTable("statusbar")) do
			if v == db.statusbar or v:match("([^\\]+)$") == db.statusbar:match("([^\\]+)$") then
				statusbar:SetValue(k)
				statusbar.valueBG:SetTexture(v)
			end
		end
		for k, v in pairs(Media:HashTable("font")) do
			if v == db.font or v:lower():match("([^\\]+)%.ttf$") == db.font:lower():match("([^\\]+)%.ttf$") then
				font:SetValue(k)
				local _, height, flags = font.valueText:GetFont()
				font.valueText:SetFont(v, height, flags)
			end
		end
		outline:SetValue(db.fontOutline, outlineWeights[db.fontOutline])

		borderSize:SetValue(db.borderSize)

		dispelFilter:SetChecked(db.dispelFilter)
		healFilter:SetChecked(db.ignoreOwnHeals)
		threatLevels:SetChecked(db.threatLevels)

		healthColorMode:SetValue(db.healthColorMode, healthColorModes[db.healthColorMode])
		healthColor:SetValue(unpack(db.healthColor))
		if db.healthColorMode == "CUSTOM" then
			healthColor:Show()
		else
			healthColor:Hide()
		end
		healthBG:SetValue(db.healthBG)

		powerColorMode:SetValue(db.powerColorMode, powerColorModes[db.powerColorMode])
		powerColor:SetValue(unpack(db.powerColor))
		if db.powerColorMode == "CUSTOM" then
			powerColor:Show()
		else
			powerColor:Hide()
		end
		powerBG:SetValue(db.powerBG)

		borderColor:SetValue(unpack(db.borderColor))

		for i = 1, #oUF.objects do
			oUF.objects[i]:UpdateAllElements("OptionsRefresh")
		end
	end
end)