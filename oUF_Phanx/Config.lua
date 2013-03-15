--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, private = ...
local SharedMedia

------------------------------------------------------------------------
--	Units
------------------------------------------------------------------------

private.uconfig = {
	player = {
		point = "BOTTOMRIGHT UIParent CENTER -200 -200",
		width = 4/3,
		power = true,
		castbar = true,
	},
	pet = {
		point = "RIGHT player LEFT -12 0",
		width = 0.5,
		power = true,
		castbar = true,
	},
	target = {
		point = "BOTTOMLEFT UIParent CENTER 200 -200",
		width = 4/3,
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

function private.SetAllFonts(file, flag)
	if not file then file = private.config.font end
	if not flag then flag = private.config.fontOutline end

	for _, v in ipairs(private.fontstrings) do
		local _, size = v:GetFont()
		v:SetFont(file, size, flag)
	end

	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		local _, size = bar.text:GetFont()
		bar.text:SetFont(file, size, flag)
	end
end

function private.SetAllStatusBarTextures(file)
	if not file then file = private.config.statusbar end

	for _, v in ipairs(private.statusbars) do
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

private.loadFuncs = {}

private.loader = CreateFrame("Frame")
private.loader:RegisterEvent("ADDON_LOADED")
private.loader:SetScript("OnEvent", function(self, event, addon)
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

		druidMana = false,				-- [druid] show a mana bar in cat/bear forms
		eclipseBar = true,				-- [druid] show an eclipse bar
		eclipseBarIcons = false,		-- [druid] show animated icons on the eclipse bar
		runeBars = true,				-- [deathknight] show rune cooldown bars
		totemBars = true,				-- [shaman] show totem duration bars

		healthColor = { 0.2, 0.2, 0.2 },
		healthColorMode = "CUSTOM",
		healthBG = 2,

		powerColor = { 0.8, 0.8, 0.8 },
		powerColorMode = "CLASS",
		powerBG = 0.25,

		borderColor = { 0.5, 0.5, 0.5 },
		borderSize = 16,

		--DBVERSION = 0,
	}

	PoUFDB = PoUFDB or {}
	for k, v in pairs(defaults) do
		if type(PoUFDB[k]) ~= type(v) then
			PoUFDB[k] = v
		end
	end
	private.config = PoUFDB
--[[
	if PoUFDB.DBVERSION < 1 then
		PoUFDB.borderSize = PoUFDB.borderSize / 2
		PoUFDB.DBVERSION = 1
	end
]]
	if PoUFDB.bgColorIntensity then
		PoUFDB.healthBG = PoUFDB.bgColorIntensity
		PoUFDB.powerBG = 1 / PoUFDB.bgColorIntensity
		PoUFDB.bgColorIntensity = nil
	end

	SharedMedia = LibStub("LibSharedMedia-3.0", true)
	if SharedMedia then
		SharedMedia:Register("font", "PT Sans Bold", [[Interface\AddOns\oUF_Phanx\media\PTSans-Bold.ttf]])

		SharedMedia:Register("statusbar", "Flat", [[Interface\BUTTONS\WHITE8X8]])
		SharedMedia:Register("statusbar", "Neal", [[Interface\AddOns\oUF_Phanx\media\Neal]])

		for i, v in pairs(SharedMedia:List("font")) do
			tinsert(private.fontList, v)
		end
		table.sort(private.fontList)

		for i, v in pairs(SharedMedia:List("statusbar")) do
			tinsert(private.statusbarList, v)
		end
		table.sort(private.statusbarList)

		SharedMedia.RegisterCallback("oUF_Phanx", "LibSharedMedia_Registered", function(type)
			if type == "font" then
				wipe(private.fontList)
				for i, v in pairs(SharedMedia:List("font")) do
					tinsert(private.fontList, v)
				end
				table.sort(private.fontList)
			elseif type == "statusbar" then
				wipe(private.statusbarList)
				for i, v in pairs(SharedMedia:List("statusbar")) do
					tinsert(private.statusbarList, v)
				end
				table.sort(private.statusbarList)
			end
		end)

		SharedMedia.RegisterCallback("oUF_Phanx", "LibSharedMedia_SetGlobal", function(_, type)
			if type == "font" then
				private.SetAllFonts()
			elseif type == "statusbar" then
				private.SetAllStatusBarTextures()
			end
		end)
	end

	for i, f in ipairs(private.loadFuncs) do f() end
	private.loadFuncs = nil

	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
end)

------------------------------------------------------------------------
--	Options panel
------------------------------------------------------------------------

local L = private.L
local CreateOptionsPanel = LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel

private.fontList, private.statusbarList = {}, {}

------------------------------------------------------------------------

private.optionsPanel = CreateOptionsPanel("oUF Phanx", nil, function(self)
	local db = private.config

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateColorPicker = LibStub("PhanxConfig-ColorPicker").CreateColorPicker
	local CreateDropdown = LibStub("PhanxConfig-Dropdown").CreateDropdown
	local CreateScrollingDropdown = LibStub("PhanxConfig-ScrollingDropdown").CreateScrollingDropdown
	local CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	--------------------------------------------------------------------

	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(self, self.name, L.Options_Desc)

	--------------------------------------------------------------------

	local statusbar = CreateScrollingDropdown(self, L.Texture, nil, private.statusbarList)
	statusbar:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	statusbar:SetPoint("TOPRIGHT", notes, "BOTTOM", -12, -12)

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
		private.SetAllStatusBarTextures()
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

	local font = CreateScrollingDropdown(self, L.Font, nil, private.fontList)
	font:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, -12)
	font:SetPoint("TOPRIGHT", statusbar, "BOTTOMRIGHT", 0, -12)

	function font:OnValueChanged(value)
		local file = SharedMedia:Fetch("font", value)
		if db.font == file then return end
		db.font = file
		local _, height, flags = self.valueText:GetFont()
		self.valueText:SetFont(file, height, flags)
		private.SetAllFonts()
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
		NONE = L.None,
		OUTLINE = L.Thin,
		THICKOUTLINE = L.Thick,
	}
	do
		local function OnClick(self)
			db.fontOutline = self.value
			private.SetAllFonts()
			outline:SetValue(self.value, self.text)
		end

		outline = CreateDropdown(self, L.Outline, nil, function()
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
	end
	outline:SetPoint("TOPLEFT", font, "BOTTOMLEFT", 0, -12)
	outline:SetPoint("TOPRIGHT", font, "BOTTOMRIGHT", 0, -12)

	--------------------------------------------------------------------

	local borderSize = CreateSlider(self, L.BorderSize, nil, 12, 24, 2)
	borderSize:SetPoint("TOPLEFT", outline, "BOTTOMLEFT", 0, -12)
	borderSize:SetPoint("TOPRIGHT", outline, "BOTTOMRIGHT", 0, -12)
	function borderSize:OnValueChanged(value)
		value = floor(value + 0.5)
		db.borderSize = value
		for _, frame in ipairs(private.borderedObjects) do
			frame:SetBorderSize(value)
		end
		return value
	end

	--------------------------------------------------------------------

	local borderColor = CreateColorPicker(self, L.BorderColor, L.BorderColor_Desc)
	borderColor:SetPoint("LEFT", borderSize, "RIGHT", 24, -2)

	function borderColor:GetColor()
		return unpack(db.borderColor)
	end

	function borderColor:OnColorChanged(r, g, b)
		db.borderColor[1] = r
		db.borderColor[2] = g
		db.borderColor[3] = b
		for _, frame in ipairs(private.borderedObjects) do
			frame:SetBorderColor(r, g, b)
		end
		for _, frame in ipairs(private.objects) do
			if frame.UpdateBorder then
				frame:UpdateBorder()
			end
		end
	end

	--------------------------------------------------------------------

	local dispelFilter = CreateCheckbox(self, L.FilterDebuffHighlight, L.FilterDebuffHighlight_Desc)
	dispelFilter:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
	function dispelFilter:OnClick(checked)
		db.dispelFilter = checked
		for _, frame in ipairs(private.objects) do
			if frame.DispelHighlight then
				frame.DispelHighlight.filter = checked
				frame.DispelHighlight:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	local healFilter = CreateCheckbox(self, L.IgnoreOwnHeals, L.IgnoreOwnHeals_Desc)
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

	local threatLevels = CreateCheckbox(self, L.ThreatLevels, L.ThreatLevels_Desc)
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

	local _, CLASS = UnitClass("player")

	local druidMana, eclipseBar, eclipseBarIcons
	if CLASS == "DRUID" then
		druidMana = CreateCheckbox(self, L.DruidManaBar, L.DruidManaBar_Desc .. "\n\n" .. L.OptionRequiresReload)
		druidMana:SetPoint("TOPLEFT", threatLevels, "BOTTOMLEFT", 0, -6)
		function druidMana:OnClick(checked)
			db.druidMana = checked
		end

		eclipseBar = CreateCheckbox(self, L.EclipseBar, L.EclipseBar_Desc .. "\n\n" .. L.OptionRequiresReload)
		eclipseBar:SetPoint("TOPLEFT", druidMana, "BOTTOMLEFT", 0, -6)
		function eclipseBar:OnClick(checked)
			db.eclipseBar = checked
			if checked then
				eclipseBarIcons:Enable()
			else
				eclipseBarIcons:Disable()
			end
		end

		eclipseBarIcons = CreateCheckbox(self, L.EclipseBarIcons, L.EclipseBarIcons_Desc .. "\n\n" .. L.OptionRequiresReload)
		eclipseBarIcons:SetPoint("TOPLEFT", eclipseBar, "BOTTOMLEFT", 0, -6)
		function eclipseBarIcons:OnClick(checked)
			db.eclipseBarIcons = checked
		end

		borderColor:ClearAllPoints()
		borderColor:SetPoint("TOPLEFT", eclipseBarIcons, "BOTTOMLEFT", 0, -5)
	end

	local totemBars
	if CLASS == "SHAMAN" then
		totemBars = CreateCheckbox(self, L.TotemBars, L.TotemBars_Desc .. "\n\n" .. L.OptionRequiresReload)
		totemBars:SetPoint("TOPLEFT", threatLevels, "BOTTOMLEFT", 0, -6)
		function totemBars:OnClick(checked)
			db.totemBars = checked
		end
	end

	local runeBars
	if CLASS == "DEATHKNIGHT" then
		runeBars = CreateCheckbox(self, L.RuneBars, L.RuneBars_Desc  .. "\n\n" .. L.OptionRequiresReload)
		runeBars:SetPoint("TOPLEFT", threatLevels, "BOTTOMLEFT", 0, -6)
		function runeBars:OnClick(checked)
			db.runeBars = checked
		end
	end

	local healthColor

	local healthColorModes = {
		CLASS  = L.ColorClass,
		HEALTH = L.ColorHealth,
		CUSTOM = L.ColorCustom,
	}

	local healthColorMode = CreateDropdown(self, L.HealthColor, L.HealthColor_Desc)
	healthColorMode:SetPoint("TOPLEFT", borderSize, "BOTTOMLEFT", 0, -12)
	healthColorMode:SetPoint("TOPRIGHT", borderSize, "BOTTOMRIGHT", 0, -12)

	do
		local info = {}
		info.func = function(self)
			local value = self.value
			db.healthColorMode = value
			healthColorMode:SetValue(value, healthColorModes[value])
			for _, frame in ipairs(private.objects) do
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

	healthColor = CreateColorPicker(self, L.HealthColorCustom)
	healthColor:SetPoint("LEFT", healthColorMode, "RIGHT", 24, eclipseBarIcons and -10 or -6)
	function healthColor:GetColor()
		return unpack(db.healthColor)
	end
	function healthColor:OnColorChanged(r, g, b)
		db.healthColor[1] = r
		db.healthColor[2] = g
		db.healthColor[3] = b
		for _, frame in ipairs(private.objects) do
			local hp = frame.Health
			if type(hp) == "table" then
				local mu = hp.bg.multiplier
				hp:SetStatusBarColor(r, g, b)
				hp.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	--------------------------------------------------------------------

	local healthBG = CreateSlider(self, L.HealthBG, L.HealthBG_Desc, 0, 3, 0.05, true)
	healthBG:SetPoint("TOPLEFT", healthColorMode, "BOTTOMLEFT", 0, -12)
	healthBG:SetPoint("TOPRIGHT", healthColorMode, "BOTTOMRIGHT", 0, -12)

	function healthBG:OnValueChanged(value)
		value = math.floor(value * 100 + 0.5) / 100
		db.healthBG = value
		local custom = db.healthColorMode == "CUSTOM"
		for _, frame in ipairs(private.objects) do
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
		CLASS  = L.ColorClass,
		POWER  = L.ColorPower,
		CUSTOM = L.ColorCustom,
	}

	local powerColorMode = CreateDropdown(self, L.PowerColor, L.PowerColor_Desc)
	powerColorMode:SetPoint("TOPLEFT", healthBG, "BOTTOMLEFT", 0, -12)
	powerColorMode:SetPoint("TOPRIGHT", healthBG, "BOTTOMRIGHT", 0, -12)

	do
		local function OnClick(self)
			local value = self.value
			db.powerColorMode = value
			powerColorMode:SetValue(value, powerColorModes[value])
			for _, frame in ipairs(private.objects) do
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

	powerColor = CreateColorPicker(self, L.PowerColorCustom)
	powerColor:SetPoint("LEFT", powerColorMode, "RIGHT", 24, eclipseBarIcons and -10 or -6)

	function powerColor:GetColor()
		return unpack(db.powerColor)
	end

	function powerColor:OnColorChanged(r, g, b)
		db.powerColor[1] = r
		db.powerColor[2] = g
		db.powerColor[3] = b
		for _, frame in ipairs(private.objects) do
			local power = frame.Power
			if type(power) == "table" then
				local mu = power.bg.multiplier
				power:SetStatusBarColor(r, g, b)
				power.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	--------------------------------------------------------------------

	local powerBG = CreateSlider(self, L.PowerBG, L.PowerBG_Desc, 0, 3, 0.05, true)
	powerBG:SetPoint("TOPLEFT", powerColorMode, "BOTTOMLEFT", 0, -12)
	powerBG:SetPoint("TOPRIGHT", powerColorMode, "BOTTOMRIGHT", 0, -12)

	function powerBG:OnValueChanged(value)
		value = floor(value * 100 + 0.5) / 100
		db.powerBG = value
		local custom = db.powerColorMode == "CUSTOM"
		for _, frame in ipairs(private.objects) do
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
	private.aboutPanel = AboutPanel.new(private.optionsPanel.name, "oUF_Phanx")
end

------------------------------------------------------------------------

SLASH_OUFPHANX1 = "/pouf"

local testMode
function SlashCmdList.OUFPHANX()
	InterfaceOptionsFrame_OpenToCategory(private.optionsPanel)
end