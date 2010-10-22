--[[--------------------------------------------------------------------
	oUF_Phanx
	An oUF layout.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Phanx. See README file for license terms.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
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
		point = "RIGHT player LEFT -10 0",
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
		point = "LEFT target RIGHT 10 0",
		width = 0.5,
	},
	focus = {
		point = "TOPLEFT target BOTTOMLEFT 0 -60",
		power = true,
	},
	focustarget = {
		point = "LEFT focus RIGHT 10 0",
		width = 0.5,
	},
	party = {
		point = "TOPLEFT targettarget BOTTOMRIGHT 110 250",
		width = 0.5,
		power = true,
		attributes = { "showParty", true, "showPlayer", true, "template", "oUF_PhanxPartyTemplate", "xOffset", 0, "yOffset", -25 },
		visible = "party",
	},
	partypet = {
		width = 0.5,
	},
}

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

oUF.colors.uninterruptible = { 1, 0.7, 0 }

oUF.colors.threat = { }
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

ns.SetAllFonts = function(file, flag)
	if not file then file = ns.config.font end
	if not flag then flag = ns.config.fontOutline end

	for _, v in ipairs(ns.fontstrings) do
		local _, size = v:GetFont()
		v:SetFont(file, size, flag)
	end
end

ns.SetAllStatusBarTextures = function(file)
	if not file then file = ns.config.statusbar end

	for _, v in ipairs(ns.statusbars) do
		v:SetStatusBarTexture(file)
		if v.bg then
			v.bg:SetTexture(file)
		end
	end
end

------------------------------------------------------------------------
--	Load stuff
------------------------------------------------------------------------

ns.loadFuncs = { }

ns.loader = CreateFrame("Frame")
ns.loader:RegisterEvent("ADDON_LOADED")
ns.loader:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "oUF_Phanx" then return end

	local defaults = {
		dispelFilter = true,			-- only highlight the frame for debuffs you can dispel

		ignoreOwnHeals = false,			-- only show incoming heals from other players

		threatLevels = true,			-- show threat levels instead of binary aggro

		modifySpellTooltips = false,	-- modify spell tooltips to show mana cost as a percent -- OFF by default

		statusbar = [[Interface\AddOns\oUF_Phanx\media\Neal]],

		font = [[Interface\AddOns\oUF_Phanx\media\Expressway.ttf]],
		fontOutline = "OUTLINE",

		borderColor = { 0.2, 0.2, 0.2 },
		borderSize = 15,

		width = 225,
		height = 30,
		powerHeight = 1/5,				-- how much of the frame's height should be occupied by the power bar

		backdrop = { bgFile = [[Interface\BUTTONS\WHITE8X8]] },
		backdropColor = { 32/256, 32/256, 32/256, 1 },
	}

	PoUFDB = PoUFDB or { }
	for k, v in pairs(defaults) do
		if type(PoUFDB[k]) ~= type(v) then
			PoUFDB[k] = v
		end
	end
	ns.config = PoUFDB

	for i, f in ipairs(ns.loadFuncs) do f() end
	ns.loadFuncs = nil

	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
end)

------------------------------------------------------------------------
--	Options panel
------------------------------------------------------------------------

LoadAddOn("PhanxConfigWidgets")
if not LibStub then return end
for i, lib in ipairs({ "PhanxConfig-Checkbox", "PhanxConfig-ColorPicker", "PhanxConfig-Dropdown", "PhanxConfig-ScrollingDropdown", "PhanxConfig-Slider", "LibSharedMedia-3.0" }) do
	if not LibStub(lib, true) then return end
end

ns.fontList, ns.statusbarList = { }, { }

ns.L = setmetatable(ns.L or { }, { __index = function(self, k)
	if not k then return "ERROR" end
	local v = tostring(k)
	self[k] = v
	return v
end })

ns.optionsPanel = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
ns.optionsPanel.name = "oUF Phanx"
ns.optionsPanel:Hide()

ns.optionsPanel:SetScript("OnShow", function(self)

	SharedMedia = LibStub("LibSharedMedia-3.0", true)
	if SharedMedia then
		SharedMedia:Register("font", "Expressway", [[Interface\AddOns\oUF_Phanx\media\Expressway.ttf]])
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

	--------------------------------------------------------------------

	local db = ns.config
	local L = ns.L

	self.CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	self.CreateColorPicker = LibStub("PhanxConfig-ColorPicker").CreateColorPicker
	self.CreateDropdown = LibStub("PhanxConfig-Dropdown").CreateDropdown
	self.CreateScrollingDropdown = LibStub("PhanxConfig-ScrollingDropdown").CreateScrollingDropdown
	self.CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	--------------------------------------------------------------------

	local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetPoint("TOPRIGHT", -16, -16)
	title:SetJustifyH("LEFT")
	title:SetText(self.name)

	local notes = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	notes:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	notes:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -8)
	notes:SetHeight(20)
	notes:SetJustifyH("LEFT")
	notes:SetJustifyV("TOP")
	notes:SetNonSpaceWrap(true)
	notes:SetText(L["Use this panel to configure some basic options for this layout."])

	--------------------------------------------------------------------

	local statusbar = self:CreateScrollingDropdown(L["Texture"], ns.statusbarList)
	statusbar.desc = L["Change the bar texture for the frames."]
	statusbar:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	statusbar:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -12)
	for k, v in pairs(SharedMedia:HashTable("statusbar")) do
		if v == db.statusbar or v:match("([^\\]+)$") == db.statusbar:match("([^\\]+)$") then
			statusbar:SetValue(k)
		end
	end
	do
		statusbar.valueText.bg = statusbar:CreateTexture(nil, "ARTWORK")
		statusbar.valueText.bg:SetPoint("RIGHT", statusbar.valueText, 4, -1)
		statusbar.valueText.bg:SetPoint("LEFT", statusbar.valueText, -4, -1)
		statusbar.valueText.bg:SetHeight(16)
		statusbar.valueText.bg:SetTexture(db.statusbar)
		statusbar.valueText.bg:SetVertexColor(0.4, 0.4, 0.4)

		function statusbar:OnValueChanged(value)
			db.statusbar = SharedMedia:Fetch("statusbar", value)
			ns.SetAllStatusBarTextures()
			statusbar.valueText.bg:SetTexture(db.statusbar)
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

	local font = self:CreateScrollingDropdown(L["Font"], ns.fontList)
	font.desc = L["Change the typeface for text on the frames."]
	font:SetPoint("TOPLEFT", statusbar, "BOTTOMLEFT", 0, -12)
	font:SetPoint("TOPRIGHT", statusbar, "BOTTOMRIGHT", 0, -12)
	for k, v in pairs(SharedMedia:HashTable("font")) do
		if v == db.font then
			font:SetValue(k)
		end
	end
	do
		local _, height, flags = font.valueText:GetFont()
		font.valueText:SetFont(db.font, height, flags)

		function font:OnValueChanged(value)
			local _, height, flags = self.valueText:GetFont()
			db.font = SharedMedia:Fetch("font", value)
			self.valueText:SetFont(db.font, height, flags)
			ns.SetAllFonts()
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
			font.dropdown.list.text.SetText = function(self, text)
				self:SetFont(SharedMedia:Fetch("font", text), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT + 1)
				SetText(self, text)
			end

			button_OnClick(self)
			self:SetScript("OnClick", button_OnClick)
		end)
	end

	--------------------------------------------------------------------

	local outlines = {
		["NONE"] = L["None"],
		["OUTLINE"] = L["Thin"],
		["THICKOUTLINE"] = L["Thick"],
	}

	local outline
	do
		local function OnClick(self)
			db.fontOutline = self.value
			ns.SetAllFonts()
			outline:SetValue(self.value, self.text)
		end

		local info = { } -- UIDropDownMenu_CreateInfo()

		outline = self:CreateDropdown(L["Font Outline"], function()
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
	outline.desc = L["Change the outline thickness for text on the frames."]
	outline:SetPoint("TOPLEFT", font, "BOTTOMLEFT", 0, -12)
	outline:SetPoint("TOPRIGHT", font, "BOTTOMRIGHT", 0, -12)
	outline:SetValue(db.fontOutline, outlines[db.fontOutline])

	--------------------------------------------------------------------

	local borderSize = self:CreateSlider(L["Border Size"], 8, 24, 1)
	borderSize.desc = L["Change the size of the frame borders."]
	borderSize:SetPoint("TOPLEFT", outline, "BOTTOMLEFT", 0, -12)
	borderSize:SetPoint("TOPRIGHT", outline, "BOTTOMRIGHT", 0, -12)
	borderSize:SetValue(db.borderSize)

	borderSize.OnValueChanged = function(self, value)
		value = math.floor(value + 0.5)
		db.borderSize = value
		for _, frame in ipairs(ns.borderedObjects) do
			frame:SetBorderSize(value)
		end
		return value
	end

	--------------------------------------------------------------------

	local borderColor = self:CreateColorPicker(L["Border Color"])
	borderColor.desc = L["Change the default color of the frame borders."]
	borderColor:SetPoint("TOPLEFT", borderSize, "BOTTOMLEFT", 5, -12)
	borderColor:SetColor(unpack(db.borderColor))

	borderColor.GetColor = function()
		return unpack(db.borderColor)
	end

	borderColor.OnColorChanged = function(self, r, g, b)
		db.borderColor[1] = r
		db.borderColor[2] = g
		db.borderColor[3] = b
		for _, frame in ipairs(ns.borderedObjects) do
			frame:SetBorderColor(r, g, b)
		end
		for _, frame in ipairs(oUF.objects) do
			if frame.Health then
				frame.Health:SetStatusBarColor(r, g, b)
				frame.Health.bg:SetVertexColor(r * 1.5, g * 1.5, b * 1.5)
			end
			if frame.UpdateBorder then
				frame:UpdateBorder()
			end
		end
	end

	--------------------------------------------------------------------

	local dispelFilter = self:CreateCheckbox(L["Filter dispel highlight"])
	dispelFilter.desc = L["Show the dispel highlight only for debuffs you can dispel yourself."]
	dispelFilter:SetPoint("TOPLEFT", notes, "BOTTOM", 12, -24)
	dispelFilter:SetChecked(db.dispelFilter)

	dispelFilter.OnClick = function(self, checked)
		db.dispelFilter = checked
		for _, frame in ipairs(oUF.objects) do
			if frame.DispelHighlight then
				frame.DispelHighlightFilter = checked
				if frame:IsShown() then
					frame.DispelHighlight:ForceUpdate()
				end
			end
		end
	end

	--------------------------------------------------------------------

	local healFilter = self:CreateCheckbox(L["Ignore own heals"])
	healFilter.desc = L["Show only incoming heals cast by other players."]
	healFilter:SetPoint("TOPLEFT", dispelFilter, "BOTTOMLEFT", 0, -8)
	healFilter:SetChecked(db.ignoreOwnHeals)

	healFilter.OnClick = function(self, checked)
		db.ignoreOwnHeals = checked
		for _, frame in ipairs(oUF.objects) do
			if frame.HealPrediction and frame:IsShown() then
				frame.HealPrediction:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	local threatLevels = self:CreateCheckbox(L["Show threat levels"])
	threatLevels.desc = L["Show threat levels instead of binary aggro status."]
	threatLevels:SetPoint("TOPLEFT", healFilter, "BOTTOMLEFT", 0, -8)
	threatLevels:SetChecked(db.threatLevels)

	threatLevels.OnClick = function(self, checked)
		db.threatLevels = checked
		for _, frame in ipairs(oUF.objects) do
			if frame.ThreatHighlight and frame:IsShown() then
				frame.ThreatHighlight:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	self.refresh = function()
		for k, v in pairs(SharedMedia:HashTable("font")) do
			if v == db.font or v:lower():match("([^\\]+)%.ttf$") == db.font:lower():match("([^\\]+)%.ttf$") then
				font:SetValue(k)
			end
		end

		outline:SetValue(db.fontOutline)

		for k, v in pairs(SharedMedia:HashTable("statusbar")) do
			if v == db.statusbar or v:lower():match("([^\\]+)$") == db.statusbar:lower():match("([^\\]+)$") then
				statusbar:SetValue(k)
			end
		end
	end

	self:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(ns.optionsPanel)

------------------------------------------------------------------------

local AboutPanel = LibStub("LibAboutPanel", true)
if AboutPanel then
	ns.aboutPanel = AboutPanel.new(ns.optionsPanel.name, "oUF_Phanx")
end

------------------------------------------------------------------------

SLASH_OUFPHANX1 = "/pouf"

SlashCmdList.OUFPHANX = function()
	if ns.aboutPanel then
		InterfaceOptionsFrame_OpenToCategory(ns.aboutPanel)
	end
	InterfaceOptionsFrame_OpenToCategory(ns.optionsPanel)
end
