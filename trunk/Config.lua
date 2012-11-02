--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local SharedMedia

------------------------------------------------------------------------
--	Units
------------------------------------------------------------------------

ns.uconfig = {
	player = {
		point = "BOTTOMRIGHT UIParent CENTER -100 -230",
		power = true,
		castbar = true,
	},
	pet = {
		point = "RIGHT player LEFT -12 0",
		power = true,
		width = 0.5,
		castbar = true,
	},
	target = {
		point = "BOTTOMLEFT UIParent CENTER 100 -230",
		power = true,
		castbar = true,
	},
	targettarget = {
		point = "LEFT target RIGHT 12 0",
		width = 0.5,
	},
	focus = {
		point = "TOPLEFT target BOTTOMLEFT 0 -60",
		power = true,
	},
	focustarget = {
		point = "LEFT focus RIGHT 12 0",
		width = 0.5,
	},
	party = {
		point = "TOPLEFT boss4 BOTTOMLEFT 0 -73",
		width = 0.5,
		power = true,
		attributes = { "showPlayer", true, "showParty", true, "showRaid", false, "xOffset", 0, "yOffset", -25 },
		visible = "party",
	},
	partypet = {
		point = "TOPLEFT party TOPRIGHT 12 0",
		width = 0.25,
		attributes = { "showPlayer", true, "showParty", true, "showRaid", false, "xOffset", 0, "yOffset", -25, "useOwnerUnit", true, "unitsuffix", "pet" },
		visible = "party",
	},
	-------------
	--	Bosses --
	-------------
	boss1 = {
		point = "TOPRIGHT UIParent TOPRIGHT -29 -255",
		width = 0.8,
		power = true,
	},
	boss2 = {
		point = "TOPRIGHT boss1 BOTTOMRIGHT 0 -25",
		width = 0.8,
		power = true,
	},
	boss3 = {
		point = "TOPRIGHT boss2 BOTTOMRIGHT 0 -25",
		width = 0.8,
		power = true,
	},
	boss4 = {
		point = "TOPRIGHT boss3 BOTTOMRIGHT 0 -25",
		width = 0.8,
		power = true,
	},
	-----------------------
	--	Arena Oppnonents --
	-----------------------
	arena1 = {
		point = "TOPLEFT boss1 TOPLEFT 0 0",
		width = 0.5,
		power = true,
	},
	arena2 = {
		point = "TOPRIGHT arena1 BOTTOMRIGHT 0 -16",
		width = 0.5,
		power = true,
	},
	arena3 = {
		point = "TOPRIGHT arena2 BOTTOMRIGHT 0 -16",
		width = 0.5,
		power = true,
	},
	arena4 = {
		point = "TOPRIGHT arena3 BOTTOMRIGHT 0 -16",
		width = 0.5,
		power = true,
	},
	arena5 = {
		point = "TOPRIGHT arena4 BOTTOMRIGHT 0 -16",
		width = 0.5,
		power = true,
	},
	----------------------------
	--	Arena Opponents' Pets --
	----------------------------
	arenapet1 = {
		point = "LEFT arena1 RIGHT 10 0",
		width = 0.25,
	},
	arenapet2 = {
		point = "LEFT arena2 RIGHT 10 0",
		width = 0.25,
	},
	arenapet3 = {
		point = "LEFT arena3 RIGHT 10 0",
		width = 0.25,
	},
	arenapet4 = {
		point = "LEFT arena4 RIGHT 10 0",
		width = 0.25,
	},
	arenapet5 = {
		point = "LEFT arena5 RIGHT 10 0",
		width = 0.25,
	},
}

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

oUF.colors.uninterruptible = { 1, 0.7, 0 }

oUF.colors.threat = {}
for i = 1, 3 do
	local r, g, b = GetThreatStatusColor(i)
	oUF.colors.threat[i] = { r, g, b }
end

do
	local pcolor = oUF.colors.power
	pcolor.MANA[1], pcolor.MANA[2], pcolor.MANA[3] = 0, 0.8, 1
	pcolor.RUNIC_POWER[1], pcolor.RUNIC_POWER[2], pcolor.RUNIC_POWER[3] = 0.8, 0, 1

	local rcolor = oUF.colors.reaction
	rcolor[1][1], rcolor[1][2], rcolor[1][3] = 1,   0.2, 0.2 -- Hated
	rcolor[2][1], rcolor[2][2], rcolor[2][3] = 1,   0.2, 0.2 -- Hostile
	rcolor[3][1], rcolor[3][2], rcolor[3][3] = 1,   0.6, 0.2 -- Unfriendly
	rcolor[4][1], rcolor[4][2], rcolor[4][3] = 1,   1,   0.2 -- Neutral
	rcolor[5][1], rcolor[5][2], rcolor[5][3] = 0.2, 1,   0.2 -- Friendly
	rcolor[6][1], rcolor[6][2], rcolor[6][3] = 0.2, 1,   0.2 -- Honored
	rcolor[7][1], rcolor[7][2], rcolor[7][3] = 0.2, 1,   0.2 -- Revered
	rcolor[8][1], rcolor[8][2], rcolor[8][3] = 0.2, 1,   0.2 -- Exalted
end

------------------------------------------------------------------------
--	End configuration
------------------------------------------------------------------------

function ns.SetAllFonts(file, flag)
	if not file then file = ns.config.font end
	if not flag then flag = ns.config.fontOutline end

	for _, v in ipairs(ns.fontstrings) do
		local _, size = v:GetFont()
		v:SetFont(file, size, flag)
	end

	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		local _, size = bar.text:GetFont()
		bar.text:SetFont(file, size, flag)
	end
end

function ns.SetAllStatusBarTextures(file)
	if not file then file = ns.config.statusbar end

	for _, v in ipairs(ns.statusbars) do
		if v.SetStatusBarTexture then
			v:SetStatusBarTexture(file)
		else
			v:SetTexture(file)
		end
		if v.bg then
			v.bg:SetTexture(file)
		end
	end

	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		bar.bg:SetTexture(file)
		bar.bar:SetStatusBarTexture(file)
	end
end

------------------------------------------------------------------------
--	Load stuff
------------------------------------------------------------------------

ns.loadFuncs = {}

ns.loader = CreateFrame("Frame")
ns.loader:RegisterEvent("ADDON_LOADED")
ns.loader:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "oUF_Phanx" then return end

	local defaults = {
		width = 225,
		height = 30,
		powerHeight = 0.2,				-- how much of the frame's height should be occupied by the power bar

		backdrop = { bgFile = [[Interface\BUTTONS\WHITE8X8]] },
		backdropColor = { 32/256, 32/256, 32/256, 1 },

		statusbar = [[Interface\AddOns\oUF_Phanx\media\Neal]],

		font = [[Interface\AddOns\oUF_Phanx\media\PTSans-Bold.ttf]],
		fontOutline = "OUTLINE",

		dispelFilter = true,			-- only highlight the frame for debuffs you can dispel
		ignoreOwnHeals = false,			-- only show incoming heals from other players
		threatLevels = true,			-- show threat levels instead of binary aggro

		druidMana = false,				-- show a mana bar for druids while in feral forms

		eclipseBar = true,				-- show an eclipse bar for druids
		eclipseBarIcons = false,		-- show animated icons on the eclipse bar

		totemBars = true,				-- show totem bars for shamans

		runeBars = true,				-- show rune bars for death knights

		healthColor = { 0.2, 0.2, 0.2 },
		healthColorMode = "CUSTOM",
		healthBG = 2,

		powerColor = { 0.8, 0.8, 0.8 },
		powerColorMode = "CLASS",
		powerBG = 0.25,

		borderColor = { 0.3, 0.3, 0.3 },
		borderSize = 16,
	}

	PoUFDB = PoUFDB or {}
	for k, v in pairs(defaults) do
		if type(PoUFDB[k]) ~= type(v) then
			PoUFDB[k] = v
		end
	end
	ns.config = PoUFDB

	if PoUFDB.bgColorIntensity then
		PoUFDB.healthBG = PoUFDB.bgColorIntensity
		PoUFDB.powerBG = 1 / PoUFDB.bgColorIntensity
		PoUFDB.bgColorIntensity = nil
	end

	SharedMedia = LibStub("LibSharedMedia-3.0", true)
	if SharedMedia then
		SharedMedia:Register("font", "PT Sans Bold", [[Interface\AddOns\oUF_Phanx\media\PTSans-Bold.ttf]])
		SharedMedia:Register("font", "PT Serif", [[Interface\AddOns\oUF_Phanx\media\PTSerif.ttf]])

		SharedMedia:Register("statusbar", "Blizzard Flat", [[Interface\BUTTONS\WHITE8X8]])
		SharedMedia:Register("statusbar", "Neal", [[Interface\AddOns\oUF_Phanx\media\Neal]])

		for i, v in pairs(SharedMedia:List("font")) do
			tinsert(ns.fontList, v)
		end
		table.sort(ns.fontList)

		for i, v in pairs(SharedMedia:List("statusbar")) do
			tinsert(ns.statusbarList, v)
		end
		table.sort(ns.statusbarList)

		SharedMedia.RegisterCallback("oUF_Phanx", "LibSharedMedia_Registered", function(type)
			if type == "font" then
				wipe(ns.fontList)
				for i, v in pairs(SharedMedia:List("font")) do
					tinsert(ns.fontList, v)
				end
				table.sort(ns.fontList)
			elseif type == "statusbar" then
				wipe(ns.statusbarList)
				for i, v in pairs(SharedMedia:List("statusbar")) do
					tinsert(ns.statusbarList, v)
				end
				table.sort(ns.statusbarList)
			end
		end)

		SharedMedia.RegisterCallback("oUF_Phanx", "LibSharedMedia_SetGlobal", function(_, type)
			if type == "font" then
				ns.SetAllFonts()
			elseif type == "statusbar" then
				ns.SetAllStatusBarTextures()
			end
		end)
	end

	for i, f in ipairs(ns.loadFuncs) do f() end
	ns.loadFuncs = nil

	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
end)

------------------------------------------------------------------------
--	Options panel
------------------------------------------------------------------------

ns.fontList, ns.statusbarList = {}, {}

if ns.L then
	for k, v in pairs(ns.L) do -- clean up missing translations
		if v == "" then
			ns.L[k] = k
		end
	end
end

ns.L = setmetatable(ns.L or {}, { __index = function(t, k)
	if k == nil then return "" end
	local v = tostring(k)
	t[k] = v
	return v
end })

local CreateOptionsPanel = LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel

------------------------------------------------------------------------

ns.optionsPanel = CreateOptionsPanel("oUF Phanx", nil, function(self)

	local db = ns.config
	local L = ns.L

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateColorPicker = LibStub("PhanxConfig-ColorPicker").CreateColorPicker
	local CreateDropdown = LibStub("PhanxConfig-Dropdown").CreateDropdown
	local CreateScrollingDropdown = LibStub("PhanxConfig-ScrollingDropdown").CreateScrollingDropdown
	local CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	--------------------------------------------------------------------

	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(self, self.name,
		L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."])

	--------------------------------------------------------------------

	local statusbar = CreateScrollingDropdown(self, L["Texture"], ns.statusbarList,
		L["Select a texture for health, power, and other bars."])
	statusbar:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	statusbar:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -12)

	local valueBG = statusbar.dropdown:CreateTexture(nil, "OVERLAY")
	valueBG:SetPoint("LEFT", statusbar.valueText, -2, 1)
	valueBG:SetPoint("RIGHT", statusbar.valueText, 5, 1)
	valueBG:SetHeight(15)
	valueBG:SetVertexColor(0.35, 0.35, 0.35)
	statusbar.valueBG = valueBG

	function statusbar:OnValueChanged(value)
		local file = SharedMedia:Fetch("statusbar", value)
		if db.statusbar == file then return end
		valueBG:SetTexture(file)
		db.statusbar = file
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
						bg:SetTexture(SharedMedia:Fetch("statusbar", button.value))
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

	--------------------------------------------------------------------

	local font = CreateScrollingDropdown(self, L["Font"], ns.fontList,
		L["Select a typeface for text on the frames."])
	font:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, -12)
	font:SetPoint("TOPRIGHT", statusbar, "BOTTOMRIGHT", 0, -12)

	function font:OnValueChanged(value)
		local file = SharedMedia:Fetch("font", value)
		if db.font == file then return end
		db.font = file
		local _, height, flags = self.valueText:GetFont()
		self.valueText:SetFont(file, height, flags)
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
						button.label:SetFont(SharedMedia:Fetch("font", button.value), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT)
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
				self:SetFont(SharedMedia:Fetch("font", text), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT + 1)
				SetText(self, text)
			end

			button_OnClick(self)
			self:SetScript("OnClick", button_OnClick)
		end)
	end

	--------------------------------------------------------------------

	local outline
	local outlines = {
		["NONE"] = L["None"],
		["OUTLINE"] = L["Thin"],
		["THICKOUTLINE"] = L["Thick"],
	}
	do
		local function OnClick(self)
			db.fontOutline = self.value
			ns.SetAllFonts()
			outline:SetValue(self.value, self.text)
		end

		local info = {}

		outline = CreateDropdown(self, L["Font Outline"], function()
			local selected = db.fontOutline

			info.text = L["None"]
			info.value = "NONE"
			info.func = OnClick
			info.checked = "NONE" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Thin"]
			info.value = "OUTLINE"
			info.func = OnClick
			info.checked = "THIN" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Thick"]
			info.value = "THICKOUTLINE"
			info.func = OnClick
			info.checked = "THICK" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end
	outline.desc = L["Select an outline weight for text on the frames."]
	outline:SetPoint("TOPLEFT", font, "BOTTOMLEFT", 0, -12)
	outline:SetPoint("TOPRIGHT", font, "BOTTOMRIGHT", 0, -12)

	--------------------------------------------------------------------

	local borderSize = CreateSlider(self, L["Border Size"], 8, 24, 2)
	borderSize.desc = L["Change the size of the frame borders."]
	borderSize:SetPoint("TOPLEFT", outline, "BOTTOMLEFT", -2, -12)
	borderSize:SetPoint("TOPRIGHT", outline, "BOTTOMRIGHT", 4, -12)

	function borderSize:OnValueChanged(value)
		value = floor(value + 0.5)
		db.borderSize = value
		for _, frame in ipairs(ns.borderedObjects) do
			frame:SetBorderSize(value)
		end
		return value
	end

	local borderGlow = CreateCheckbox(self, L["Show Border Glow"])
	borderGlow.desc = L["Show a glow around the frame border to more visibly highlight important states."]
	borderGlow:SetPoint("TOPLEFT", borderSize, "BOTTOMLEFT", 2, -12)

	function borderGlow:OnClick(checked)
		db.borderGlow = checked
	end

	--------------------------------------------------------------------

	local dispelFilter = CreateCheckbox(self, L["Filter debuff highlight"])
	dispelFilter.desc = L["Show the debuff highlight only for debuffs you can dispel."]
	dispelFilter:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)

	function dispelFilter:OnClick(checked)
		db.dispelFilter = checked
		for _, frame in ipairs(ns.objects) do
			if frame.DispelHighlight then
				frame.DispelHighlightFilter = checked
				if frame:IsShown() then
					frame:GetScript("OnEvent")(frame, "UNIT_AURA", frame.unit)
				end
			end
		end
	end

	--------------------------------------------------------------------

	local healFilter = CreateCheckbox(self, L["Ignore own heals"])
	healFilter.desc = L["Show only incoming heals cast by other players."]
	healFilter:SetPoint("TOPLEFT", dispelFilter, "BOTTOMLEFT", 0, -6)

	function healFilter:OnClick(checked)
		db.ignoreOwnHeals = checked
		for _, frame in ipairs(oUF.objects) do
			if frame.HealPrediction and frame:IsShown() then
				frame.HealPrediction:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	local threatLevels = CreateCheckbox(self, L["Show threat levels"])
	threatLevels.desc = L["Show threat levels instead of binary aggro status."]
	threatLevels:SetPoint("TOPLEFT", healFilter, "BOTTOMLEFT", 0, -6)

	function threatLevels:OnClick(checked)
		db.threatLevels = checked
		for _, frame in ipairs(oUF.objects) do
			if frame.ThreatHighlight and frame:IsShown() then
				frame.ThreatHighlight:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	local druidMana, eclipseBar, eclipseBarIcons
	if select(2, UnitClass("player")) == "DRUID" then
		druidMana = CreateCheckbox(self, L["Show druid mana bar"], L["Show a mana bar while you are in Bear Form or Cat Form."] .. "\n\n" .. L["This option will not take effect until the next time you log in or reload your UI."])
		druidMana:SetPoint("TOPLEFT", threatLevels, "BOTTOMLEFT", 0, -18)

		function druidMana:OnClick(checked)
			db.druidMana = checked
		end

		eclipseBar = CreateCheckbox(self, L["Show eclipse bar"], L["Show an eclipse bar above the player frame."] .. "\n\n" .. L["This option will not take effect until the next time you log in or reload your UI."])
		eclipseBar:SetPoint("TOPLEFT", druidMana, "BOTTOMLEFT", 0, -18)

		function eclipseBar:OnClick(checked)
			db.eclipseBar = checked
			if checked then
				eclipseBarIcons:Enable()
			else
				eclipseBarIcons:Disable()
			end
		end

		eclipseBarIcons = CreateCheckbox(self, L["Show eclipse bar icons"],
			L["Show animated moon and sun icons on either end of the eclipse bar."] .. "\n\n" .. L["This option will not take effect until the next time you log in or reload your UI."])
		eclipseBarIcons:SetPoint("TOPLEFT", eclipseBar, "BOTTOMLEFT", 0, -6)

		function eclipseBarIcons:OnClick(checked)
			db.eclipseBarIcons = checked
		end
	end

	local totemBars
	if select(2, UnitClass("player")) == "SHAMAN" then
		totemBars = CreateCheckbox(self, L["Show totem bars"],
			L["Show timer bars for your totems."] .. "\n\n" .. L["This option will not take effect until the next time you log in or reload your UI."])
		totemBars:SetPoint("TOPLEFT", threatLevels, "BOTTOMLEFT", 0, -18)

		function totemBars:OnClick(checked)
			db.totemBars = checked
		end
	end

	local runeBars
	if select(2, UnitClass("player")) == "DEATHKNIGHT" then
		runeBars = CreateCheckbox(self, L["Show rune bars"],
			L["Show timer bars for your runes."] .. "\n\n" .. L["This option will not take effect until the next time you log in or reload your UI."])
		runeBars:SetPoint("TOPLEFT", threatLevels, "BOTTOMLEFT", 0, -18)

		function runeBars:OnClick(checked)
			db.runeBars = checked
		end
	end

	--------------------------------------------------------------------

	function self.refresh()
		for k, v in pairs(SharedMedia:HashTable("statusbar")) do
			if v == db.statusbar or v:match("([^\\]+)$") == db.statusbar:match("([^\\]+)$") then
				statusbar:SetValue(k)
				statusbar.valueBG:SetTexture(v)
			end
		end
		for k, v in pairs(SharedMedia:HashTable("font")) do
			if v == db.font or v:lower():match("([^\\]+)%.ttf$") == db.font:lower():match("([^\\]+)%.ttf$") then
				font:SetValue(k)
				local _, height, flags = font.valueText:GetFont()
				font.valueText:SetFont(v, height, flags)
			end
		end
		outline:SetValue(db.fontOutline, outlines[db.fontOutline])

		borderSize:SetValue(db.borderSize)
		borderGlow:SetChecked(db.borderGlow)

		dispelFilter:SetChecked(db.dispelFilter)
		healFilter:SetChecked(db.ignoreOwnHeals)
		threatLevels:SetChecked(db.threatLevels)

		if druidMana then
			druidMana:SetChecked(db.druidMana)
		end

		if eclipseBar then
			eclipseBar:SetChecked(db.eclipseBar)
			eclipseBarIcons:SetChecked(db.eclipseBarIcons)
			if db.eclipseBar then
				eclipseBarIcons:Enable()
			else
				eclipseBarIcons:Disable()
			end
		end

		if totemBars then
			totemBars:SetChecked(db.totemBars)
		end

		if runeBars then
			runeBars:SetChecked(db.runeBars)
		end
	end
end)

------------------------------------------------------------------------

ns.colorsPanel = CreateOptionsPanel(ns.L["Colors"], ns.optionsPanel.name, function(self)
	local db = ns.config
	local L = ns.L

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateColorPicker = LibStub("PhanxConfig-ColorPicker").CreateColorPicker
	local CreateDropdown = LibStub("PhanxConfig-Dropdown").CreateDropdown
	local CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	--------------------------------------------------------------------

	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(self, self.name,
		L["Use this panel to configure the colors used for different parts of the unit frames created by this layout."])

	--------------------------------------------------------------------

	local healthColor

	local healthColorModes = {
		["CLASS"]  = L["By Class"],
		["HEALTH"] = L["By Health"],
		["CUSTOM"] = L["Custom"],
	}

	local healthColorMode = CreateDropdown(self, L["Health color mode"])
	healthColorMode.desc = L["Change how health bars are colored."]
	healthColorMode:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	healthColorMode:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -12)

	do
		local function OnClick(self)
			local value = self.value
			db.healthColorMode = value
			healthColorMode:SetValue(value, healthColorModes[value])
			for _, frame in ipairs(ns.objects) do
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

		local info = {}
		UIDropDownMenu_Initialize(healthColorMode.dropdown, function()
			local selected = db.healthColorMode

			info.text = L["By Class"]
			info.value = "CLASS"
			info.func = OnClick
			info.checked = "CLASS" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["By Health"]
			info.value = "HEALTH"
			info.func = OnClick
			info.checked = "HEALTH" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Custom"]
			info.value = "CUSTOM"
			info.func = OnClick
			info.checked = "CUSTOM" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end

	--------------------------------------------------------------------

	healthColor = CreateColorPicker(self, L["Health bar color"])
	healthColor.desc = L["Change the health bar color."]
	healthColor:SetPoint("BOTTOMLEFT", healthColorMode, "BOTTOMRIGHT", 16, 4)

	function healthColor:GetColor()
		return unpack(db.healthColor)
	end

	function healthColor:OnColorChanged(r, g, b)
		db.healthColor[1] = r
		db.healthColor[2] = g
		db.healthColor[3] = b
		for _, frame in ipairs(ns.objects) do
			local hp = frame.Health
			if type(hp) == "table" then
				local mu = hp.bg.multiplier
				hp:SetStatusBarColor(r, g, b)
				hp.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	--------------------------------------------------------------------

	local healthBG = CreateSlider(self, L["Health background intensity"], 0, 3, 0.05, true)
	healthBG.desc = L["Change the brightness of the health bar background color, relative to the foreground color."]
	healthBG:SetPoint("TOPLEFT", healthColorMode, "BOTTOMLEFT", 0, -12)
	healthBG:SetPoint("TOPRIGHT", healthColorMode, "BOTTOMRIGHT", 0, -12)

	function healthBG:OnValueChanged(value)
		value = math.floor(value * 100 + 0.5) / 100
		db.healthBG = value
		local custom = db.healthColorMode == "CUSTOM"
		for _, frame in ipairs(ns.objects) do
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

	local powerColorModes = {
		["CLASS"]  = L["By Class"],
		["POWER"]  = L["By Power Type"],
		["CUSTOM"] = L["Custom"],
	}

	local powerColorMode = CreateDropdown(self, L["Power color mode"])
	powerColorMode.desc = L["Change how power bars are colored."]
	powerColorMode:SetPoint("TOPLEFT", healthBG, "BOTTOMLEFT", 0, -12)
	powerColorMode:SetPoint("TOPRIGHT", healthBG, "BOTTOMRIGHT", 0, -12)

	do
		local function OnClick(self)
			local value = self.value
			db.powerColorMode = value
			powerColorMode:SetValue(value, powerColorModes[value])
			for _, frame in ipairs(ns.objects) do
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

			info.text = L["By Class"]
			info.value = "CLASS"
			info.func = OnClick
			info.checked = "CLASS" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["By Power Type"]
			info.value = "POWER"
			info.func = OnClick
			info.checked = "HEALTH" == selected
			UIDropDownMenu_AddButton(info)

			info.text = L["Custom"]
			info.value = "CUSTOM"
			info.func = OnClick
			info.checked = "CUSTOM" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end

	--------------------------------------------------------------------

	powerColor = CreateColorPicker(self, L["Health bar color"])
	powerColor.desc = L["Change the health bar color."]
	powerColor:SetPoint("BOTTOMLEFT", powerColorMode, "BOTTOMRIGHT", 16, 4)

	function powerColor:GetColor()
		return unpack(db.powerColor)
	end

	function powerColor:OnColorChanged(r, g, b)
		db.powerColor[1] = r
		db.powerColor[2] = g
		db.powerColor[3] = b
		for _, frame in ipairs(ns.objects) do
			local power = frame.Power
			if type(power) == "table" then
				local mu = power.bg.multiplier
				power:SetStatusBarColor(r, g, b)
				power.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	--------------------------------------------------------------------

	local powerBG = CreateSlider(self, L["Power background intensity"], 0, 3, 0.05, true)
	powerBG.desc = L["Change the brightness of the power bar background color, relative to the foreground color."]
	powerBG:SetPoint("TOPLEFT", powerColorMode, "BOTTOMLEFT", 0, -12)
	powerBG:SetPoint("TOPRIGHT", powerColorMode, "BOTTOMRIGHT", 0, -12)

	function powerBG:OnValueChanged(value)
		value = floor(value * 100 + 0.5) / 100
		db.powerBG = value
		local custom = db.powerColorMode == "CUSTOM"
		for _, frame in ipairs(ns.objects) do
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
				DruidMana:PostUpdatePower(frame.unit)
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

	local borderColor = CreateColorPicker(self, L["Border color"])
	borderColor.desc = L["Change the default frame border color."]
	borderColor:SetPoint("TOPLEFT", powerBG, "BOTTOMLEFT", 4, -16)

	function borderColor:GetColor()
		return unpack(db.borderColor)
	end

	function borderColor:OnColorChanged(r, g, b)
		db.borderColor[1] = r
		db.borderColor[2] = g
		db.borderColor[3] = b
		for _, frame in ipairs(ns.borderedObjects) do
			frame:SetBorderColor(r, g, b)
		end
		for _, frame in ipairs(ns.objects) do
			if frame.UpdateBorder then
				frame:UpdateBorder()
			end
		end
	end

	--------------------------------------------------------------------

	function self.refresh()
		healthColorMode:SetValue(db.healthColorMode, healthColorModes[db.healthColorMode])
		healthColor:SetColor(unpack(db.healthColor))
		if db.healthColorMode == "CUSTOM" then
			healthColor:Show()
		else
			healthColor:Hide()
		end
		healthBG:SetValue(db.healthBG)

		powerColorMode:SetValue(db.powerColorMode, powerColorModes[db.powerColorMode])
		powerColor:SetColor(unpack(db.powerColor))
		if db.powerColorMode == "CUSTOM" then
			powerColor:Show()
		else
			powerColor:Hide()
		end
		powerBG:SetValue(db.powerBG)

		borderColor:SetColor(unpack(db.borderColor))
	end
end)

------------------------------------------------------------------------

local AboutPanel = LibStub("LibAboutPanel", true)
if AboutPanel then
	ns.aboutPanel = AboutPanel.new(ns.optionsPanel.name, "oUF_Phanx")
end

------------------------------------------------------------------------

SLASH_OUFPHANX1 = "/pouf"

local testMode
function SlashCmdList.OUFPHANX(cmd)
	if cmd == "test" then
		testMode = not testMode
		if testMode then
		else
		end
	else
		InterfaceOptionsFrame_OpenToCategory(ns.optionsPanel)
	end
end