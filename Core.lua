--[[--------------------------------------------------------------------
	oUF_Phanx
	A layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curse.com/downloads/wow-addons/details/ouf-phanx.aspx
	Copyright © 2009–2010 Phanx. See README for license terms.
----------------------------------------------------------------------]]

local settings = {

	font = "Andika Basic Compact",
	outline = "OUTLINE",
	shadow = false,

	statusbar = "Gradient",

	borderStyle = "NONE", -- NONE or TEXTURE
	borderSize = 3, -- only applies to NONE border
	borderColor = { 0.6, 0.6, 0.6 }, -- only applies to TEXTURE border

	width = 230,
	height = 28,

	focusPlacement = "RIGHT", -- LEFT or RIGHT

	threatLevels = false,

	filterAuras = true,
	remapAuraIcons = true,

}

------------------------------------------------------------------------

local OUF_PHANX, oUF_Phanx = ...
oUF_Phanx.frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)

local SharedMedia

local myClass = select(2, UnitClass("player"))
local myTalents = { 0, 0, 0 }

------------------------------------------------------------------------

local defaultFonts = {
	["Andika Basic Compact"] = [[Interface\AddOns\oUF_Phanx\media\AndikaBasicCompact.ttf]],
	["Expressway"] = [[Interface\AddOns\oUF_Phanx\media\Expressway.ttf]],
	["Arial Narrow"] = [[Fonts\ARIALN.TTF]],
	["Friz Quadrata TT"] = [[Fonts\FRIZQT__.TTF]],
	["Morpheus"] = [[Fonts\MORPHEUS.ttf]],
	["Skurri"] = [[Fonts\skurri.ttf]],
}

local defaultStatusbars = {
	["Gradient"] = [[Interface\AddOns\oUF_Phanx\media\gradient]],
	["Blizzard"] = [[Interface\TargetingFrame\UI-StatusBar]],
	["Flat"] = [[Interface\BUTTONS\WHITE8X8]],
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

oUF_Phanx.DoNothing = DoNothing

------------------------------------------------------------------------

local function debug(str, ...)
	if str:match("%%") then
		print("|cffffcc00[DEBUG] oUF_Phanx:|r", str:format(...))
	elseif ... then
		print("|cffffcc00[DEBUG] oUF_Phanx:|r", str, ...)
	else
		print("|cffffcc00[DEBUG] oUF_Phanx:|r", str)
	end
end

oUF_Phanx.debug = debug

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

oUF_Phanx.si = si

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
		return (myTalents[2] > myTalents[1]) and (myTalents[2] > myTalents[3]) and UnitAura("player", RIGHTEOUS_FURY, "HELPFUL")
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
	if not font then font = settings.font end
	if not outline then outline = settings.outline end

	font = self:GetFont(font)

	for _, frame in ipairs(oUF.objects) do
		setFonts(frame, font, outline)
	end
end

------------------------------------------------------------------------

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
	if not statusbar then statusbar = settings.statusbar end

	statusbar = self:GetStatusBarTexture(statusbar)

	for _, frame in ipairs(oUF.objects) do
		setStatusBarTextures(frame, statusbar)
	end
end

------------------------------------------------------------------------

function oUF_Phanx:CreateFontString(parent, size)
	if not parent then return end

	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(self:GetFont(settings.font), size or 18, settings.outline)
	fs:SetShadowOffset(0, 0)

	if settings.shadow then
		fs:SetShadowOffset(1, -1)
	end

	return fs
end

------------------------------------------------------------------------

oUF_Phanx.fonts = { }
oUF_Phanx.statusbars = { }

oUF_Phanx.defaultFonts = defaultFonts
oUF_Phanx.defaultStatusbars = defaultStatusbars

oUF_Phanx.settings = settings

------------------------------------------------------------------------

function oUF_Phanx:PLAYER_TALENT_UPDATE()
	myTalents[1] = GetNumTalents(1) or 0
	myTalents[2] = GetNumTalents(2) or 0
	myTalents[3] = GetNumTalents(3) or 0
end

function oUF_Phanx:ADDON_LOADED(addon)
	if addon ~= OUF_PHANX then return end
	debug("ADDON_LOADED", addon)
--[[
	if not oUF_Phanx_Settings then
		oUF_Phanx_Settings = { }
	end
	for k, v in pairs(settings) do
		if type(v) ~= type(oUF_Phanx_Settings[k]) then
			oUF_Phanx_Settings[k] = v
		end
	end
	settings = oUF_Phanx_Settings
	self.settings = settings
]]
	local fonts = self.fonts
	local statusbars = self.statusbars

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

	self.frame:UnregisterEvent("ADDON_LOADED")

	if myClass == "DEATHKNIGHT" or myClass == "DRUID" or myClass == "PRIEST" or myClass == "SHAMAN" or myClass == "PALADIN" or myClass == "WARRIOR" then
		self.frame:RegisterEvent("PLAYER_TALENT_UPDATE")
	end
end

oUF_Phanx.frame:SetScript("OnEvent", function(self, event, ...) return oUF_Phanx[event] and oUF_Phanx[event](oUF_Phanx, ...) end)
oUF_Phanx.frame:RegisterEvent("ADDON_LOADED")

------------------------------------------------------------------------

oUF_Phanx.frame:Hide()
oUF_Phanx.frame.name = "oUF: Phanx"
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
	statusbar.desc = L["Change the texture for bars on the frames."]
	statusbar:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -8)
	statusbar:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -8)
	statusbar:SetValue(settings.statusbar)
	do
		statusbar.valueText.bg = statusbar:CreateTexture(nil, "ARTWORK")
		local bg = statusbar.valueText.bg
		bg:SetPoint("RIGHT", statusbar.valueText, 4, -1)
		bg:SetPoint("LEFT", statusbar.valueText, -4, -1)
		bg:SetHeight(16)
		bg:SetTexture(oUF_Phanx:GetStatusBarTexture(settings.statusbar))
		bg:SetVertexColor(0.4, 0.4, 0.4)

		statusbar.OnValueChanged = function(self, value)
			settings.statusbar = value
			oUF_Phanx:SetStatusBarTexture(value)
			self.valueText.bg:SetTexture(oUF_Phanx:GetStatusBarTexture(value))
		end

		local button_OnClick = statusbar.button:GetScript("OnClick")
		statusbar.button:SetScript("OnClick", function(self)
			button_OnClick(self)
			statusbar.dropdown.list:Hide()

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
				local buttons = statusbar.dropdown.list.buttons
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

	-----------------------
	-- Select: Font Face --
	-----------------------

	local font = self:CreateScrollingDropdown(L["Font Face"], oUF_Phanx.fontList)
	font.desc = L["Choose the font face for text on the frames."]
	font:SetPoint("TOPLEFT", notes, "BOTTOM", 8, -8)
	font:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -8)
	font:SetValue(settings.font)
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
			font.dropdown.list:Hide()

			local function SetButtonFonts(self)
				local buttons = font.dropdown.list.buttons
				for i = 1, #buttons do
					local button = buttons[i]
					if button.value and button:IsShown() then
						button.label:SetFont(oUF_Phanx:GetFont(button.value), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT)
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
			font.dropdown.list.text.SetText = function(self, text)
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

	local outlines = { ["NONE"] = L["None"], ["OUTLINE"] = L["Thin"], ["THICKOUTLINE"] = L["Thick"] }

	local outline
	do
		local function OnClick(self)
			settings.outline = self.value
			oUF_Phanx:SetFont()
			outline.valueText:SetText(self.text)
			UIDropDownMenu_SetSelectedValue(outline, self.value)
		end

		local info = UIDropDownMenu_CreateInfo()

		outline = self:CreateDropdown(L["Font Outline"], function()
			local selected = settings.outline

			info.text = L["None"]
			info.value = "NONE"
			info.func = OnClick
			info.checked = "NONE" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Thin"]
			info.value = "OUTLINE"
			info.func = OnClick
			info.checked = "OUTLINE" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Thick"]
			info.value = "THICKOUTLINE"
			info.func = OnClick
			info.checked = "THICKOUTLINE" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end
	outline.desc = L["Choose the outline weight for text on the frames."]
	outline:SetPoint("TOPLEFT", font, "BOTTOMLEFT", 0, -8)
	outline:SetPoint("TOPRIGHT", font, "BOTTOMRIGHT", 0, -8)
	outline:SetValue(settings.outline, outlines[settings.outline])

	--------------------------
	-- Select: Border Style -- [NYI]
	--------------------------

	local borderStyles = { ["NONE"] = L["None"], ["GLOW"] = L["Glow"], ["TEXTURE"] = L["Texture"] }

	local borderStyle
	do
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
		borderStyle = self:CreateDropdown(L["Border Style"], function()
			local selected = settings.borderStyle

			info.text = L["None"]
			info.value = "NONE"
			info.func = OnClick
			info.checked = "NONE" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Glow"]
			info.value = "GLOW"
			info.func = OnClick
			info.checked = "GLOW" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Textured"]
			info.value = "TEXTURE"
			info.func = OnClick
			info.checked = "TEXTURE" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end
	borderStyle.desc = L["Select a border style for the frames."] .. "\n\n" .. L["Requires a UI reload to apply."]
	borderStyle:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, -8)
	borderStyle:SetPoint("TOPRIGHT", statusbar, "BOTTOMRIGHT", 0, -8)
	borderStyle:SetValue(settings.borderStyle, borderStyles[settings.borderStyle])

	------------------------
	-- Range: Border Size -- [NYI]
	------------------------

	local borderSize = self:CreateSlider(L["Border Size"], 6, 16, 1)
	borderSize.desc = L["Set the default thickness for frame borders. Only applies to Texture style borders."]
	borderSize:SetPoint("TOPLEFT", borderStyle, "BOTTOMLEFT", -1, -12)
	borderSize:SetPoint("TOPRIGHT", borderStyle, "BOTTOMRIGHT", 1, -12)
	borderSize:SetValue(settings.borderSize)

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
	borderColor:SetPoint("TOPLEFT", borderSize, "BOTTOMLEFT", 5, -8)
	borderColor:SetColor(unpack(settings.borderColor))

	borderColor.GetColor = function()
		return unpack(settings.borderColor)
	end

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

	local focusPlacements = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] }

	local focusPlacement
	do
		local function OnClick(self)
		--	settings.focusPlacement = self.value
			focusPlacement.valueText:SetText(self.text)
			UIDropDownMenu_SetSelectedValue(focusPlacement, self.value)
		end

		local info = UIDropDownMenu_CreateInfo()

		focusPlacement = self:CreateDropdown(L["Focus Placement"], function()
			local selected = settings.focusPlacement

			info.text = L["Left"]
			info.value = "LEFT"
			info.func = OnClick
			info.checked = "LEFT" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Right"]
			info.value = "RIGHT"
			info.func = OnClick
			info.checked = "RIGHT" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end
	focusPlacement.desc = L["Choose where to show the focus frame."] .. "\n\n" .. L["Requires a UI reload to apply."]
	focusPlacement:SetPoint("TOPLEFT", outline, "BOTTOMLEFT", 0, -8)
	focusPlacement:SetPoint("TOPRIGHT", outline, "BOTTOMRIGHT", 0, -8)
	focusPlacement:SetValue(settings.focusPlacement, focusPlacements[settings.focusPlacement])

	---------------------------
	-- Toggle: Threat Levels --
	---------------------------

	local threatLevels = self:CreateCheckbox(L["Show threat levels"])
	threatLevels.desc = L["Show threat levels instead of binary aggro status."]
	threatLevels:SetPoint("TOPLEFT", focusPlacement, "BOTTOMLEFT", 0, -8)
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
oUF_Phanx.frame.aboutPanel = LibStub("LibAboutPanel").new(oUF_Phanx.frame.name, OUF_PHANX)

SLASH_OUFPHANX1 = "/oph"
SlashCmdList.OUFPHANX = function()
	InterfaceOptionsFrame_OpenToCategory(oUF_Phanx.frame.aboutPanel) -- so it gets expanded
	InterfaceOptionsFrame_OpenToCategory(oUF_Phanx.frame)
end

_G.oUF_Phanx = oUF_Phanx
