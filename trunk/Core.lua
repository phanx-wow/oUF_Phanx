--[[--------------------------------------------------------------------
	oUF_Phanx
	A layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curse.com/downloads/wow-addons/details/ouf-phanx.aspx
	Copyright © 2009–2010 Phanx. See README for license terms.
----------------------------------------------------------------------]]

local OUF_PHANX, oUF_Phanx = ...
oUF_Phanx.frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)

local SharedMedia

local myClass = select(2, UnitClass("player"))
local myTalents = { 0, 0, 0 }

------------------------------------------------------------------------

local settings = {
	font = "Fonts\\FRIZQT__.TTF",
	statusbar = "Interface\\AddOns\\SharedMedia\\statusbar\\Flat",

	borderStyle = "FLAT", -- FLAT or TEXTURE
	borderColor = { 0.6, 0.6, 0.6 } -- Only applies to TEXTURE style border
	borderSize = 3, -- Only applies to FLAT style border

	width = 230,
	height = 30,

	focusPlacement = "RIGHT", -- LEFT or RIGHT

	threatLevels = false,
}

------------------------------------------------------------------------

local defaultFonts = {
	["Expressway"] = [[Interface\AddOns\oUF_Phanx\media\Expressway.ttf]],
	["Arial Narrow"] = [[Fonts\ARIALN.TTF]],
	["Friz Quadrata TT"] = [[Fonts\FRIZQT__.TTF]],
	["Morpheus"] = [[Fonts\MORPHEUS.ttf]],
	["Skurri"] = [[Fonts\skurri.ttf]],
}

local defaultStatusbars = {
	["Gradient"] = [[Interface\AddOns\oUF_Phanx\media\gradient]],
	["Blizzard"] = [[Interface\TargetingFrame\UI-StatusBar]],
}

------------------------------------------------------------------------

local colors = oUF.colors

colors.dead = { 0.6, 0.6, 0.6 }
colors.ghost = { 0.6, 0.6, 0.6 }
colors.offline = { 0.6, 0.6, 0.6 }

colors.civilian = { 0.2, 0.4, 1 }
colors.friendly = { 0.2, 1, 0.2 }
colors.hostile = { 1, 0.1, 0.1 }
colors.neutral = { 1, 1, 0.2 }

colors.power.AMMOSLOT = { 0.8, 0.6, 0 }
colors.power.ENERGY = { 1, 1, 0.2 }
colors.power.FOCUS = { 1, 0.5, 0.25 }
colors.power.FUEL = { 0, 0.5, 0.5 }
colors.power.MANA = { 0, 0.8, 1 }
colors.power.RAGE = { 1, 0.2, 0.2 }
colors.power.RUNIC_POWER = { 0.4, 0.4, 1 }

colors.unknown = { 1, 0.2, 1 }

colors.threat = {
	{ 1, 1, 0.47 }, -- not tanking, high threat
	{ 1, 0.6, 0 },  -- tanking, insecure threat
	{ 1, 0, 0 },    -- tanking, secure threat
}

colors.debuff = { }
for type, color in pairs(DebuffTypeColor) do
	if type ~= "none" then
		colors.debuff[type] = { color.r, color.g, color.b }
	end
end

------------------------------------------------------------------------

if not oUF_Phanx.L then oUF_Phanx.L = { } end

local L = setmetatable(oUF_Phanx.L, { __index = function(t, k)
	local v = tostring(k)
	t[k] = v
	return v
end })

------------------------------------------------------------------------

local function DoNothing()
end

------------------------------------------------------------------------

local function debug(str, ...)
	if ... then
		if str:match("%%") then
			str = str:format(...)
		else
			str = string.join(", ", str, ...)
		end
	end
	print(("|cffffcc00[DEBUG] oUF_Phanx:|r %s"):format(str))
end

------------------------------------------------------------------------

local function si(n, plus)
	if type(n) ~= "number" then return n end

	local sign
	if n < 0 then
		sign = "-"
		n = -n
	elseif plus then
		sign = "+"
	else
		sign = ""
	end

	if n >= 10000000 then
		return ("%s%.1fm"):format(sign, n / 1000000)
	elseif n >= 1000000 then
		return ("%s%.2fm"):format(sign, n / 1000000)
	elseif n >= 100000 then
		return ("%s%.0fk"):format(sign, n / 1000)
	elseif n >= 10000 then
		return ("%s%.1fk"):format(sign, n / 1000)
	else
		return ("%s%d"):format(sign, n)
	end
end

------------------------------------------------------------------------

local IsHealing

if myClass == "DRUID" then
	IsHealing = function()
		return (myTalents[3] > myTalents[1]) and (myTalents[3] > myTalents[2])
	end
elseif myClass == "PALADIN" then
	IsHealing = function()
		return (myTalents[1] > myTalents[2]) and (myTalents[1] > myTalents[3])
	end
elseif myClass == "PRIEST" then
	IsHealing = function()
		return (myTalents[1] > myTalents[3]) or (myTalents[2] > myTalents[3])
	end
elseif myClass == "SHAMAN" then
	IsHealing = function()
		return (myTalents[3] > myTalents[1]) and (myTalents[3] > myTalents[2])
	end
else
	IsHealing = DoNothing
end

oUF_Phanx.IsHealing = IsHealing

------------------------------------------------------------------------

local IsTanking

if myClass == "DEATHKNIGHT" then
	local FROST_PRESENCE = GetSpellInfo(48263)
	IsTanking = function()
		local form = GetShapeshiftForm() or 0
		if form > 0 then
			local _, name = GetShapeshiftFormInfo(form)
			return name == FROST_PRESENCE
		end
	end
elseif myClass == "DRUID" then
	local BEAR_FORM = GetSpellInfo(5487)
	local DIRE_BEAR_FORM = GetSpellInfo(9634)
	function IsTanking()
		if (myTalents[2] > myTalents[1]) and (myTalents[2] > myTalents[3]) then
			local form = GetShapeshiftForm() or 0
			if form > 0 then
				local _, name = GetShapeshiftFormInfo(form)
				return name == DIRE_BEAR_FORM or name == BEAR_FORM
			end
		end
	end
elseif myClass == "PALADIN" then
	local RIGHTEOUS_FURY = GetSpellInfo(25780)
	IsTanking = function()
		if (myTalents[2] > myTalents[1]) and (myTalents[2] > myTalents[3]) then
			return UnitAura("player", RIGHTEOUS_FURY, "HELPFUL")
		end
	end
elseif myClass == "WARRIOR" then
	local DEFENSIVE_STANCE = GetSpellInfo(71)
	function IsTanking()
		if (myTalents[3] > myTalents[1]) and (myTalents[3] > myTalents[2]) then
			local form = GetShapeshiftForm() or 0
			if form > 0 then
				local _, name = GetShapeshiftFormInfo(form)
				return name == DEFENSIVE_STANCE
			end
		end
	end
else
	IsTanking = DoNothing
end

oUF_Phanx.IsTanking = IsTanking

------------------------------------------------------------------------

local function setFonts(frame, font, outline)
	if type(frame) ~= "table" then return end
	for k, v in pairs(frame) do
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
	return SharedMedia and SharedMedia:Fetch("font", fontName) or defaultFonts[fontName] or [[Fonts\FRIZQT__.TTF]]
end

function oUF_Phanx:SetFont(font, outline)
	if not font then font = self.settings.font end
	if not outline then outline = self.settings.outline end

	font = self:GetFont(font)

	for _, frame in ipairs(oUF.objects) do
		setFonts(frame, font, outline)
	end
end

------------------------------------------------------------------------

local defaultStatusbars = oUF_Phanx.defaultStatusbars

local function setStatusBarTextures(frame, statusbar)
	if type(frame) ~= "table" then return end
--	print("setStatusBarTextures", frame.GetName and (frame:GetName() or "nil name") or ("no GetName"))
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
	return SharedMedia and SharedMedia:Fetch("statusbar", statusbarName) or defaultStatusbars[statusbarName] or [[Interface\TargetingFrame\UI-StatusBar]]
end

function oUF_Phanx:SetStatusBarTexture(statusbar)
	if not statusbar then statusbar = self.settings.statusbar end

	statusbar = self:GetStatusBarTexture(statusbar)

	for _, frame in ipairs(oUF.objects) do
		setStatusBarTextures(frame, statusbar)
	end
end

------------------------------------------------------------------------

oUF_Phanx.fonts = { }
oUF_Phanx.statusbars = { }

oUF_Phanx.defaultFonts = defaultFonts
oUF_Phanx.defaultStatusbars = defaultStatusbars

oUF_Phanx.settings = settings

oUF_Phanx.DoNothing = DoNothing
oUF_Phanx.debug = debug
oUF_Phanx.si = si

------------------------------------------------------------------------

function oUF_Phanx:PLAYER_TALENT_UPDATE()
	myTalents[1] = GetNumTalents(1) or 0
	myTalents[2] = GetNumTalents(2) or 0
	myTalents[3] = GetNumTalents(3) or 0
end

function oUF_Phanx:ADDON_LOADED(addon)
	if addon ~= OUF_PHANX then return end

	if not oUF_Phanx_Settings then
		oUF_Phanx_Settings = { }
	end
	for k, v in pairs(settings) do
		if type(v) ~= type(oUF_Phanx_Settings[k]) then
			oUF_Phanx_Settings[k] = v
		end
	end
	settings = oUF_Phanx_Settings

	local fonts = oUF_Phanx.fonts
	local statusbars = oUF_Phanx.statusbars

	SharedMedia = LibStub("LibSharedMedia-3.0", true)

	if SharedMedia then
		for name, file in pairs(defaultFonts) do
			if file:match("^Interface\\AddOns") then
				SharedMedia:Register("font", name, file)
			end
		end

		for i, v in pairs(SharedMedia:List("font")) do
			table.insert(fonts, v)
		end

		table.sort(fonts)

		for name, file in pairs(defaultStatusbars) do
			if file:match("^Interface\\AddOns") then
				SharedMedia:Register("statusbar", name, file)
			end
		end

		for i, v in pairs(SharedMedia:List("statusbar")) do
			table.insert(statusbars, v)
		end

		table.sort(statusbars)

		oUF_Phanx.SharedMedia_Registered = function(self, _, mediaType, mediaName)
			if mediaType == "font" then
				table.insert(fonts, mediaName)
				table.sort(fonts)
				self:SetFont()
			elseif mediaType == "statusbar" then
				table.insert(statusbars, mediaName)
				table.sort(statusbars)
				self:SetStatusBarTexture()
			end
		end

		SharedMedia.RegisterCallback(oUF_Phanx, "LibSharedMedia_Registered", "SharedMedia_Registered")

		oUF_Phanx.SharedMedia_SetGlobal = function(self, _, mediaType)
			if mediaType == "font" then
				self:SetFont()
			elseif mediaType == "statusbar" then
				self:SetStatusBarTexture()
			end
		end

		SharedMedia.RegisterCallback(oUF_Phanx, "LibSharedMedia_SetGlobal",  "SharedMedia_SetGlobal")
	else
		for k, v in pairs(defaultFonts) do
			table.insert(fonts, k)
		end

		table.sort(fonts)

		for k, v in pairs(defaultStatusbars) do
			table.insert(statusbars, k)
		end

		table.sort(statusbars)
	end

	self:UnregisterEvent("ADDON_LOADED")

	if myClass == "DEATHKNIGHT" or myClass == "DRUID" or myClass == "PRIEST" or myClass == "SHAMAN" or myClass == "PALADIN" or myClass == "WARRIOR" then
		self:RegisterEvent("PLAYER_TALENT_UPDATE")
	end
end

oUF_Phanx.frame:SetScript("OnEvent", function(self, event, ...) return self[event] and self[event](self, ...) end)
oUF_Phanx.frame:RegisterEvent("ADDON_LOADED")

------------------------------------------------------------------------

oUF_Phanx.frame:Hide()
oUF_Phanx.frame.name = OUF_PHANX
oUF_Phanx.frame:SetScript("OnShow", function(self)
	-------------------------
	-- Widget constructors --
	-------------------------

	self.CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	self.CreateColorPicker = LibStub("PhanxConfig-ColorPicker").CreateColorPicker
	self.CreateDropdown = LibStub("PhanxConfig-Dropdown").CreateDropdown
	self.CreateScrollingDropdown = LibStub("PhanxConfig-ScrollingDropdown").CreateScrollingDropdown
	self.CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	-----------------------------
	-- Heading and description --
	-----------------------------

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

	-------------------------------
	-- Select: Statusbar Texture --
	-------------------------------

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
					self.bg:SetVertexColor(0.35, 0.35, 0.35)
				end
				return self.bg
			end

			local function SetButtonBackgroundTextures(self)
				local numButtons = 0
				local buttons = statusbar.list.buttons
				for i = 1, #buttons do
					local button = buttons[i]
					if i > 1 then
						button:SetPoint("TOPLEFT", buttons[i - 1], "BOTTOMLEFT", 0, -1)
					end
					if button.value and button:IsShown() then
						local bg = getButtonBackground(button)
						bg:SetTexture(oUF_Phanx:GetStatusBarTexture(button.value))
						local ff, fs = button.label:GetFont()
						button.label:SetFont(ff, fs, "OUTLINE")
						numButtons = numButtons + 1
					end
				end

				statusbar.list:SetHeight(statusbar.list:GetHeight() + (numButtons * 1))
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

	-----------------------
	-- Select: Font Face --
	-----------------------

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

	--------------------------
	-- Select: Font Outline --
	--------------------------

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

		local info = UIDropDownMenu_CreateInfo()
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

	--------------------------
	-- Select: Border Style -- [NYI]
	--------------------------

	local borderStyle = self:CreateDropdown(L["Border Style"])
	borderStyle.container.desc = L["Select a border style for the frames."] .. "\n\n" .. L["Requires a UI reload to apply."]
	borderStyle.container:SetPoint("TOPLEFT", statusbar.container, "BOTTOMLEFT", 0, -8)
	borderStyle.container:SetPoint("TOPRIGHT", statusbar.container, "BOTTOMRIGHT", 0, -8)
	do
		local borderStyles = { ["NONE"] = L["None"], ["GLOW"] = L["Glow"], ["TEXTURE"] = L["Texture"] }

		local function OnClick(self)
		--	settings.borderStyle = self.value
		--	for _, frame in pairs(oUF.units) do
		--		if frame.UpdateBorder then
		--			frame:UpdateBorder()
		--		end
		--	end
			borderStyle.valueText:SetText(self.text)
			UIDropDownMenu_SetSelectedValue(borderStyle, self.value)
		end

		local info = UIDropDownMenu_CreateInfo()
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

	------------------------
	-- Range: Border Size -- [NYI]
	------------------------

	local borderSize = self:CreateSlider(L["Border Size"], 6, 16, 1)
	borderSize.desc = L["Set the default thickness for frame borders. Only applies to Texture style borders."]
	borderSize.container:SetPoint("TOPLEFT", borderStyle.container, "BOTTOMLEFT", -1, -12)
	borderSize.container:SetPoint("TOPRIGHT", borderStyle.container, "BOTTOMRIGHT", 1, -12)
	borderSize:SetValue(settings.borderSize)
	borderSize.valueText:SetText(settings.borderSize)
	borderSize.OnValueChanged = function(self, value)
		value = math.floor(value)
	--	settings.borderSize = value
	--	for _, frame in pairs(oUF.units) do
	--		if frame.UpdateBorder then
	--			frame:UpdateBorder()
	--		end
	--	end
		return value
	end

	-------------------------
	-- Color: Border Color -- [NYI]
	-------------------------

	local borderColor = self:CreateColorPicker(L["Border Color"])
	borderColor.desc = L["Set the default color for frame borders. Only applies to Texture style borders."]
	borderColor:SetPoint("TOPLEFT", borderSize.container, "BOTTOMLEFT", 5, -8)
	borderColor:SetColor(unpack(settings.borderColor))
	borderColor.GetColor = function() return unpack(settings.borderColor) end
	borderColor.OnColorChanged = function(self, r, g, b)
	--	settings.borderColor[1] = r
	--	settings.borderColor[2] = g
	--	settings.borderColor[3] = b
	--	for _, frame in pairs(oUF.units) do
	--		if frame.UpdateBorder then
	--			frame:UpdateBorder()
	--		end
	--	end
	end

	-----------------------------
	-- Select: Focus Placement -- [NYI]
	-----------------------------

	local focusPlacement = self:CreateDropdown(L["Focus Placement"])
	focusPlacement.container.desc = L["Choose where to show the focus frame."] .. "\n\n" .. L["Requires a UI reload to apply."]
	focusPlacement.container:SetPoint("TOPLEFT", outline.container, "BOTTOMLEFT", 0, -8)
	focusPlacement.container:SetPoint("TOPRIGHT", outline.container, "BOTTOMRIGHT", 0, -8)
	do
		local focusPlacements = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] }

		local function OnClick(self)
		--	settings.focusPlacement = self.value
			focusPlacement.valueText:SetText(self.text)
			UIDropDownMenu_SetSelectedValue(focusPlacement, self.value)
		end

		local info = UIDropDownMenu_CreateInfo()
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

	---------------------------
	-- Toggle: Threat Levels --
	---------------------------

	local threatLevels = self:CreateCheckbox(L["Show threat levels"])
	threatLevels.desc = L["Show threat levels instead of binary aggro status."]
	threatLevels:SetPoint("TOPLEFT", focusPlacement.container, "BOTTOMLEFT", 0, -8)
	threatLevels:SetChecked(settings.threatLevels)
	threatLevels.OnClick = function(self, checked)
		settings.threatLevels = checked
	end

	-------------
	-- The End --
	-------------

	self:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(oUF_Phanx.frame)
oUF_Phanx.frame.aboutPanel = LibStub("LibAboutPanel").new(OUF_PHANX, OUF_PHANX)

SLASH_OUFPHANX1 = "/op"
SlashCmdList.OUFPHANX = function()
	InterfaceOptionsFrame_OpenToCategory(oUF_Phanx.frame.aboutPanel) -- so it gets expanded
	InterfaceOptionsFrame_OpenToCategory(oUF_Phanx.frame)
end
