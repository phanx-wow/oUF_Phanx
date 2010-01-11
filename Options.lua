--[[--------------------------------------------------------------------
	oUF_Phanx
	A layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	Copyright ©2009–2010 Alyssa "Phanx" Kinley. All rights reserved.
	See README for license terms and additional information.
----------------------------------------------------------------------]]

local ADDON_NAME, namespace = ...
local oUF_Phanx = namespace.oUF_Phanx
local L = namespace.L

local SharedMedia = LibStub("LibSharedMedia-3.0", true)

------------------------------------------------------------------------

local function setFonts(object, font, outline)
	for k, v in pairs(object) do
		if type(v) == "table" then
			if v.SetFont then
				local _, size = v:GetFont()
				v:SetFont(font, size, outline)
			else
				setFonts(v, font, outline)
			end
		end
	end
end

function oUF_Phanx:GetFont(fontName)
	return SharedMedia and SharedMedia:Fetch("font", fontName) or oUF_Phanx.defaultFonts[fontName]
end

function oUF_Phanx:SetFont(font, outline)
	if not font then font = self.settings.font end
	if not outline then outline = self.settings.outline end

	font = self:GetFont(font)

	for unit, frame in pairs(oUF.units) do
		setFonts(frame, font, outline)
	end
end

------------------------------------------------------------------------

local defaultStatusbars = oUF_Phanx.defaultStatusbars

local function setStatusBarTextures(frame, statusbar)
	for k, v in pairs(frame) do
		if type(v) == "table" then
			if v.SetStatusBarTexture then
				v:SetStatusBarTexture(statusbar)
				if v.bg and v.bg.SetTexture then
					v.bg:SetTexture(statusbar)
				end
			else
				setStatusBarTextures(v, statusbar)
			end
		end
	end
end

function oUF_Phanx:GetStatusBarTexture(statusbarName)
	return SharedMedia and SharedMedia:Fetch("statusbar", statusbarName) or oUF_Phanx.defaultStatusbars[statusbarName]
end

function oUF_Phanx:SetStatusBarTexture(statusbar)
	if not statusbar then statusbar = self.settings.statusbar end

	statusbar = self:GetStatusBarTexture(statusbar)

	for unit, frame in pairs(oUF.units) do
		setStatusBarTextures(frame, statusbar)
	end
end

------------------------------------------------------------------------

local optionsFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
optionsFrame.name = GetAddOnMetadata(ADDON_NAME, "Title")
optionsFrame:Hide()
optionsFrame:SetScript("OnShow", function(self)
	local settings = oUF_Phanx.settings

	local SharedMedia = LibStub("LibSharedMedia-3.0", true)

	self.CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	self.CreateColorPicker = LibStub("PhanxConfig-ColorPicker").CreateColorPicker
	self.CreateDropdown = LibStub("PhanxConfig-Dropdown").CreateDropdown
	self.CreateScrollingDropdown = LibStub("PhanxConfig-ScrollingDropdown").CreateScrollingDropdown
	self.CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetPoint("TOPRIGHT", -16, -16)
	title:SetJustifyH("LEFT")
	title:SetText(self.name)

	local notes = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	notes:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	notes:SetPoint("TOPRIGHT", title, 0, -8)
	notes:SetHeight(32)
	notes:SetJustifyH("LEFT")
	notes:SetJustifyV("TOP")
	notes:SetNonSpaceWrap(true)
	notes:SetText(L["Use this panel to configure some basic options for the layout."])

	----------------------------------------------------------------
	--	statusbar
	--

	local statusbar = self:CreateScrollingDropdown(L["Bar Texture"], oUF_Phanx.statusbarList)
	statusbar.container.desc = L["Change the texture for bars on the frames."]
	statusbar.container:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -8)
	statusbar.container:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -8)
	statusbar.valueText:SetText(settings.statusbar)
	do
		statusbar.valueText.bg = statusbar:CreateTexture(nil, "ARTWORK")
		statusbar.valueText.bg:SetPoint("RIGHT", statusbar.valueText, 4, -1)
		statusbar.valueText.bg:SetPoint("LEFT", statusbar.valueText, -4, -1)
		statusbar.valueText.bg:SetHeight(16)
		statusbar.valueText.bg:SetTexture(oUF_Phanx:GetStatusBarTexture(settings.statusbar))
		statusbar.valueText.bg:SetVertexColor(0.4, 0.4, 0.4)

		function statusbar:OnValueChanged(value)
			settings.statusbar = value
			oUF_Phanx:SetStatusBarTexture(value)
			statusbar.valueText.bg:SetTexture(oUF_Phanx:GetStatusBarTexture(settings.statusbar))
		end

		local button_OnClick = statusbar.button:GetScript("OnClick")
		statusbar.button:SetScript("OnClick", function(self)
			button_OnClick(self)
			statusbar.list:Hide()

			local function getButtonBackground(self)
				if not self.bg then
					self.bg = self:CreateTexture(nil, "BACKGROUND")
					self.bg:SetPoint("TOPLEFT", -3, 0)
					self.bg:SetPoint("BOTTOMRIGHT", 3, 0)
					self.bg:SetVertexColor(0.4, 0.4, 0.4)
				end
				return self.bg
			end

			local function SetButtonBackgroundTextures(self)
				local buttons = statusbar.list.buttons
				for i = 1, #buttons do
					local button = buttons[i]
					if i > 1 then
						button:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0, -2)
					end
					if button.value and button:IsShown() then
						local bg = getButtonBackground(button)
						bg:SetTexture(oUF_Phanx:GetStatusBarTexture(button.value))
					end
				end

				local numButtons = (statusbar.list:GetHeight() - (UIDROPDOWNMENU_BORDER_HEIGHT * 2)) / UIDROPDOWNMENU_BUTTON_HEIGHT
				statusbar.list:SetHeight((numButtons * UIDROPDOWNMENU_BUTTON_HEIGHT) + (numButtons - 1) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2))
			end

			local OnShow = statusbar.list:GetScript("OnShow")
			statusbar.list:SetScript("OnShow", function(self)
				OnShow(self)
				SetButtonBackgroundTextures(self)
			end)

			local OnVerticalScroll = statusbar.list.scrollFrame:GetScript("OnVerticalScroll")
			statusbar.list.scrollFrame:SetScript("OnVerticalScroll", function(self, delta)
				OnVerticalScroll(self, delta)
				SetButtonBackgroundTextures(self)
			end)

			button_OnClick(self)
			self:SetScript("OnClick", button_OnClick)
		end)
	end

	----------------------------------------------------------------
	--	font
	--

	local font = self:CreateScrollingDropdown(L["Font Face"], oUF_Phanx.fontList)
	font.container.desc = L["Choose the font face for text on the frames."]
	font.container:SetPoint("TOPLEFT", notes, "BOTTOM", 8, -8)
	font.container:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -8)
	font.valueText:SetText(settings.font)
	do
		local _, height, flags = font.valueText:GetFont()
		font.valueText:SetFont(oUF_Phanx:GetFont(settings.font), height, flags)

		function font:OnValueChanged(value)
			local _, height, flags = self.valueText:GetFont()
			self.valueText:SetFont(oUF_Phanx:GetFont(value), height, flags)
			settings.font = value
			oUF_Phanx:SetFont()
		end

		local button_OnClick = font.button:GetScript("OnClick")
		font.button:SetScript("OnClick", function(self)
			button_OnClick(self)
			font.list:Hide()

			local function SetButtonFonts(self)
				local buttons = font.list.buttons
				for i = 1, #buttons do
					local button = buttons[i]
					if button.value and button:IsShown() then
						button.label:SetFont(oUF_Phanx:GetFont(button.value), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT)
					end
				end
			end

			local OnShow = font.list:GetScript("OnShow")
			font.list:SetScript("OnShow", function(self)
				OnShow(self)
				SetButtonFonts(self)
			end)

			local OnVerticalScroll = font.list.scrollFrame:GetScript("OnVerticalScroll")
			font.list.scrollFrame:SetScript("OnVerticalScroll", function(self, delta)
				OnVerticalScroll(self, delta)
				SetButtonFonts(self)
			end)

			local SetText = font.list.text.SetText
			font.list.text.SetText = function(self, text)
				self:SetFont(oUF_Phanx:GetFont(text), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT + 1)
				SetText(self, text)
			end

			button_OnClick(self)
			self:SetScript("OnClick", button_OnClick)
		end)
	end

	----------------------------------------------------------------
	--	outline
	--

	local outline = self:CreateDropdown(L["Font Outline"])
	outline.container.desc = L["Choose the outline weight for text on the frames."]
	outline.container:SetPoint("TOPLEFT", font.container, "BOTTOMLEFT", 0, -8)
	outline.container:SetPoint("TOPRIGHT", font.container, "BOTTOMRIGHT", 0, -8)
	do
		local outlines = { ["NONE"] = L["None"], ["OUTLINE"] = L["Thin"], ["THICKOUTLINE"] = L["Thick"] }

		local function OnClick(self)
			settings.outline = self.value
			oUF_Phanx:SetFont()
			outline.valueText:SetText(self.text)
			UIDropDownMenu_SetSelectedValue(outline, self.value)
		end

		local info = { } -- UIDropDownMenu_CreateInfo()
		UIDropDownMenu_Initialize(outline, function(self)
			local selected = outlines[UIDropDownMenu_GetSelectedValue(outline)] or self.valueText:GetText()

			info.text = L["None"]
			info.value = "NONE"
			info.func = OnClick
			info.checked = L["None"] == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Thin"]
			info.value = "OUTLINE"
			info.func = OnClick
			info.checked = L["Thin"] == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Thick"]
			info.value = "THICKOUTLINE"
			info.func = OnClick
			info.checked = L["Thick"] == selected
			UIDropDownMenu_AddButton(info)
		end)

		outline.valueText:SetText(outlines[settings.outline] or L["None"])
		UIDropDownMenu_SetSelectedValue(outline, settings.outline or L["None"])
	end

	----------------------------------------------------------------
	--	borderStyle
	--

	local borderStyle = self:CreateDropdown(L["Border Style"])
	borderStyle.container.desc = L["Select a border style for the frames."] .. L["Requires a UI reload to apply."]
	borderStyle.container:SetPoint("TOPLEFT", statusbar.container, "BOTTOMLEFT", 0, -8)
	borderStyle.container:SetPoint("TOPRIGHT", statusbar.container, "BOTTOMRIGHT", 0, -8)
	do
		local borderStyles = { ["NONE"] = L["None"], ["GLOW"] = L["Glow"], ["TEXTURE"] = L["Texture"] }

		local function OnClick(self)
			settings.borderStyle = self.value
			for _, frame in pairs(oUF.units) do
				if frame.UpdateBorder then
					frame:UpdateBorder()
				end
			end
			borderStyle.valueText:SetText(self.text)
			UIDropDownMenu_SetSelectedValue(borderStyle, self.value)
		end

		local info = { } -- UIDropDownMenu_CreateInfo()
		UIDropDownMenu_Initialize(borderStyle, function(self)
			local selected = borderStyles[UIDropDownMenu_GetSelectedValue(borderStyle)]

			info.text = L["None"]
			info.value = "NONE"
			info.func = OnClick
			info.checked = L["None"] == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Glow"]
			info.value = "GLOW"
			info.func = OnClick
			info.checked = L["Glow"] == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Textured"]
			info.value = "TEXTURE"
			info.func = OnClick
			info.checked = L["Texture"] == selected
			UIDropDownMenu_AddButton(info)
		end)

		borderStyle.valueText:SetText(borderStyles[settings.borderStyle])
		UIDropDownMenu_SetSelectedValue(borderStyle, settings.borderStyle)
	end

	----------------------------------------------------------------
	--	borderSize

	local borderSize = self:CreateSlider(L["Border Size"], 6, 16, 1)
	borderSize.desc = L["Set the default thickness for frame borders. Only applies to Texture style borders."]
	borderSize.container:SetPoint("TOPLEFT", borderStyle.container, "BOTTOMLEFT", -1, -12)
	borderSize.container:SetPoint("TOPRIGHT", borderStyle.container, "BOTTOMRIGHT", 1, -12)
	borderSize:SetValue(settings.borderSize)
	borderSize.valueText:SetText(settings.borderSize)
	borderSize.OnValueChanged = function(self, value)
		value = math.floor(value)
		settings.borderSize = value
		for _, frame in pairs(oUF.units) do
			if frame.UpdateBorder then
				frame:UpdateBorder()
			end
		end
		return value
	end

	----------------------------------------------------------------
	--	borderColor

	local borderColor = self:CreateColorPicker(L["Border Color"])
	borderColor.desc = L["Set the default color for frame borders. Only applies to Texture style borders."]
	borderColor:SetPoint("TOPLEFT", borderSize.container, "BOTTOMLEFT", 5, -8)
	borderColor:SetColor(unpack(settings.borderColor))
	borderColor.GetColor = function() return unpack(settings.borderColor) end
	borderColor.OnColorChanged = function(self, r, g, b)
		settings.borderColor[1] = r
		settings.borderColor[2] = g
		settings.borderColor[3] = b
		for _, frame in pairs(oUF.units) do
			if frame.UpdateBorder then
				frame:UpdateBorder()
			end
		end
	end

	----------------------------------------------------------------
	--	focusPlacement
	--

	local focusPlacement = self:CreateDropdown(L["Focus Placement"])
	focusPlacement.container.desc = L["Choose where to show the focus frame."] .. L["Requires a UI reload to apply."]
	focusPlacement.container:SetPoint("TOPLEFT", outline.container, "BOTTOMLEFT", 0, -8)
	focusPlacement.container:SetPoint("TOPRIGHT", outline.container, "BOTTOMRIGHT", 0, -8)
	do
		local focusPlacements = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] }

		local function OnClick(self)
			settings.focusPlacement = self.value
			focusPlacement.valueText:SetText(self.text)
			UIDropDownMenu_SetSelectedValue(focusPlacement, self.value)
		end

		local info = { } -- UIDropDownMenu_CreateInfo()
		UIDropDownMenu_Initialize(focusPlacement, function(self)
			local selected = focusPlacements[UIDropDownMenu_GetSelectedValue(focusPlacement)]

			info.text = L["Left"]
			info.value = "LEFT"
			info.func = OnClick
			info.checked = L["Left"] == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Right"]
			info.value = "RIGHT"
			info.func = OnClick
			info.checked = L["Right"] == selected
			UIDropDownMenu_AddButton(info)
		end)

		focusPlacement.valueText:SetText(focusPlacements[settings.focusPlacement])
		UIDropDownMenu_SetSelectedValue(focusPlacement, settings.focusPlacement)
	end

	----------------------------------------------------------------
	--	threatLevels
	--

	local threatLevels = self:CreateCheckbox(L["Show threat levels"])
	threatLevels.desc = L["Show threat levels instead of binary aggro status."]
	threatLevels:SetPoint("TOPLEFT", focusPlacement.container, "BOTTOMLEFT", 0, -8)
	threatLevels:SetChecked(settings.threatLevels)
	threatLevels.OnClick = function(self, checked)
		settings.threatLevels = checked
	end

	----------------------------------------------------------------

	self:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(optionsFrame)
oUF_Phanx.optionsFrame = optionsFrame

local AboutPanel = LibStub("LibAboutPanel", true)
if AboutPanel then
	AboutPanel.new(optionsFrame.name, ADDON_NAME)
end

SLASH_OUFPHANX1 = "/op"
SlashCmdList.OUFPHANX = function() InterfaceOptionsFrame_OpenToCategory(optionsFrame) end
