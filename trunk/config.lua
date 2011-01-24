--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
	Copyright © 2007–2011. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curse.com/downloads/wow-addons/details/ouf-phanx.aspx
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
		attributes = { "showPlayer", true, "showParty", true, "showRaid", false, "xOffset", 0, "yOffset", -25 },
		visible = "party",
	},
	partypet = {
		point = "TOPLEFT party TOPRIGHT 10 0",
		width = 0.25,
		attributes = { "showPlayer", true, "showParty", true, "showRaid", false, "xOffset", 0, "yOffset", -25, "useOwnerUnit", true, "unitsuffix", "pet" },
		visible = "party",
	},
}

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

oUF.colors.uninterruptible = { 1, 0.7, 0 }

oUF.colors.threat = {}
for i = 1, 3 do
	local r, g, b = GetThreatStatusColor( i )
	oUF.colors.threat[ i ] = { r, g, b }
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

ns.SetAllFonts = function( file, flag )
	if not file then file = ns.config.font end
	if not flag then flag = ns.config.fontOutline end

	for _, v in ipairs( ns.fontstrings ) do
		local _, size = v:GetFont()
		v:SetFont( file, size, flag )
	end
end

ns.SetAllStatusBarTextures = function( file )
	if not file then file = ns.config.statusbar end

	for _, v in ipairs( ns.statusbars ) do
		v:SetStatusBarTexture( file )
		if v.bg then
			v.bg:SetTexture( file )
		end
	end
end

------------------------------------------------------------------------
--	Load stuff
------------------------------------------------------------------------

ns.loadFuncs = {}

ns.loader = CreateFrame( "Frame" )
ns.loader:RegisterEvent( "ADDON_LOADED" )
ns.loader:SetScript( "OnEvent", function( self, event, addon )
	if addon ~= "oUF_Phanx" then return end

	local defaults = {
		width = 225,
		height = 30,
		powerHeight = 1/5,				-- how much of the frame's height should be occupied by the power bar

		backdrop = { bgFile = [[Interface\BUTTONS\WHITE8X8]] },
		backdropColor = { 32/256, 32/256, 32/256, 1 },

		statusbar = [[Interface\AddOns\oUF_Phanx\media\Neal]],

		font = [[Interface\AddOns\oUF_Phanx\media\DroidSerif-Regular.ttf]],
		fontOutline = "OUTLINE",

		dispelFilter = true,			-- only highlight the frame for debuffs you can dispel
		ignoreOwnHeals = false,			-- only show incoming heals from other players
		threatLevels = true,			-- show threat levels instead of binary aggro

		barColor = { 0.2, 0.2, 0.2 },
		barColorMode = "CUSTOM",

		bgColorIntensity = 1.5,

		borderColor = { 0.2, 0.2, 0.2 },
		borderSize = 15,
	}

	PoUFDB = PoUFDB or {}
	for k, v in pairs( defaults ) do
		if type( PoUFDB[ k ] ) ~= type( v ) then
			PoUFDB[ k ] = v
		end
	end
	ns.config = PoUFDB

	for i, f in ipairs( ns.loadFuncs ) do f() end
	ns.loadFuncs = nil

	self:UnregisterAllEvents()
	self:SetScript( "OnEvent", nil )
end )

------------------------------------------------------------------------
--	Options panel
------------------------------------------------------------------------

ns.fontList, ns.statusbarList = {}, {}

ns.L = setmetatable( ns.L or {}, { __index = function( t, k )
	if k == nil then return "" end
	local v = tostring( k )
	t[ k ] = v
	return v
end } )

for k, v in pairs( ns.L ) do -- clean up missing translations
	if v == "" then
		ns.L[ k ] = k
	end
end

------------------------------------------------------------------------

ns.optionsPanel = CreateFrame( "Frame", nil, InterfaceOptionsFramePanelContainer )
ns.optionsPanel.name = "oUF Phanx"
ns.optionsPanel:Hide()

ns.optionsPanel:SetScript( "OnShow", function( self )

	SharedMedia = LibStub( "LibSharedMedia-3.0", true )
	if SharedMedia then
		SharedMedia:Register( "font", "Andika", [[Interface\AddOns\oUF_Phanx\media\AndikaBasic-Custom.ttf]] )
		SharedMedia:Register( "font", "Droid Serif", [[Interface\AddOns\oUF_Phanx\media\DroidSerif-Regular.ttf]] )
		SharedMedia:Register( "font", "Expressway", [[Interface\AddOns\oUF_Phanx\media\Expressway.ttf]] )
		SharedMedia:Register( "statusbar", "Neal", [[Interface\AddOns\oUF_Phanx\media\Neal]] )

		for i, v in pairs( SharedMedia:List( "font" ) ) do
			tinsert( ns.fontList, v )
		end
		table.sort( ns.fontList )

		for i, v in pairs( SharedMedia:List( "statusbar" ) ) do
			tinsert( ns.statusbarList, v )
		end
		table.sort( ns.statusbarList )

		SharedMedia.RegisterCallback( "oUF_Phanx", "LibSharedMedia_Registered", function( type )
			if type == "font" then
				wipe( ns.fontList )
				for i, v in pairs( SharedMedia:List( "font" ) ) do
					tinsert( ns.fontList, v )
				end
				table.sort( ns.fontList )
			elseif type == "statusbar" then
				wipe( ns.statusbarList )
				for i, v in pairs( SharedMedia:List( "statusbar" ) ) do
					tinsert( ns.statusbarList, v )
				end
				table.sort( ns.statusbarList )
			end
		end )

		SharedMedia.RegisterCallback( "oUF_Phanx", "LibSharedMedia_SetGlobal", function( _, type )
			if type == "font" then
				ns.SetAllFonts()
			elseif type == "statusbar" then
				ns.SetAllStatusBarTextures()
			end
		end )
	end

	--------------------------------------------------------------------

	local db = ns.config
	local L = ns.L

	self.CreateCheckbox = LibStub( "PhanxConfig-Checkbox" ).CreateCheckbox
	self.CreateColorPicker = LibStub( "PhanxConfig-ColorPicker" ).CreateColorPicker
	self.CreateDropdown = LibStub( "PhanxConfig-Dropdown" ).CreateDropdown
	self.CreateScrollingDropdown = LibStub( "PhanxConfig-ScrollingDropdown" ).CreateScrollingDropdown
	self.CreateSlider = LibStub( "PhanxConfig-Slider" ).CreateSlider

	--------------------------------------------------------------------

	local title = self:CreateFontString( nil, "ARTWORK", "GameFontNormalLarge" )
	title:SetPoint( "TOPLEFT", 16, -16 )
	title:SetPoint( "TOPRIGHT", -16, -16 )
	title:SetJustifyH( "LEFT" )
	title:SetText( self.name )

	local notes = self:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
	notes:SetPoint( "TOPLEFT", title, "BOTTOMLEFT", 0, -8 )
	notes:SetPoint( "TOPRIGHT", title, "BOTTOMRIGHT", 0, -8 )
	notes:SetHeight( 32 )
	notes:SetJustifyH( "LEFT" )
	notes:SetJustifyV( "TOP" )
	notes:SetNonSpaceWrap( true )
	notes:SetText( L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] )

	--------------------------------------------------------------------

	local statusbar = self:CreateScrollingDropdown( L["Texture"], ns.statusbarList )
	statusbar.desc = L["Select a texture for health, power, and other bars."]
	statusbar:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	statusbar:SetPoint( "TOPRIGHT", notes, "BOTTOM", -8, -12 )
	statusbar.valueText.bg = statusbar:CreateTexture( nil, "ARTWORK" )
	statusbar.valueText.bg:SetPoint( "RIGHT", statusbar.valueText, 4, -1 )
	statusbar.valueText.bg:SetPoint( "LEFT", statusbar.valueText, -4, -1 )
	statusbar.valueText.bg:SetHeight( 16 )
	statusbar.valueText.bg:SetVertexColor( 0.4, 0.4, 0.4 )

	statusbar.OnValueChanged = function( self, value )
		local file = SharedMedia:Fetch( "statusbar", value )
		if db.statusbar == file then return end
		db.statusbar = file
		self.valueText.bg:SetTexture( file )
		ns.SetAllStatusBarTextures()
	end

	do
		local button_OnClick = statusbar.button:GetScript( "OnClick" )
		statusbar.button:SetScript( "OnClick", function( self )
			button_OnClick( self )
			statusbar.dropdown.list:Hide()

			local function getButtonBackground( self )
				if not self.bg then
					self.bg = self:CreateTexture( nil, "BACKGROUND" )
					self.bg:SetPoint( "TOPLEFT", -3, 0 )
					self.bg:SetPoint( "BOTTOMRIGHT", 3, 0 )
					self.bg:SetVertexColor( 0.35, 0.35, 0.35 )
				end
				return self.bg
			end

			local function SetButtonBackgroundTextures( self )
				local numButtons = 0
				local buttons = statusbar.dropdown.list.buttons
				for i = 1, #buttons do
					local button = buttons[ i ]
					if i > 1 then
						button:SetPoint( "TOPLEFT", buttons[ i - 1 ], "BOTTOMLEFT", 0, -1 )
					end
					if button.value and button:IsShown() then
						local bg = getButtonBackground( button )
						bg:SetTexture( SharedMedia:Fetch( "statusbar", button.value ) )
						local ff, fs = button.label:GetFont()
						button.label:SetFont( ff, fs, "OUTLINE" )
						numButtons = numButtons + 1
					end
				end

				statusbar.dropdown.list:SetHeight( statusbar.dropdown.list:GetHeight() + ( numButtons * 1 ) )
			end

			local OnShow = statusbar.dropdown.list:GetScript( "OnShow" )
			statusbar.dropdown.list:SetScript( "OnShow", function( self )
				OnShow( self )
				SetButtonBackgroundTextures( self )
			end )

			local OnVerticalScroll = statusbar.dropdown.list.scrollFrame:GetScript( "OnVerticalScroll" )
			statusbar.dropdown.list.scrollFrame:SetScript( "OnVerticalScroll", function( self, delta )
				OnVerticalScroll( self, delta )
				SetButtonBackgroundTextures( self )
			end )

			button_OnClick( self )
			self:SetScript( "OnClick", button_OnClick )
		end )
	end

	--------------------------------------------------------------------

	local font = self:CreateScrollingDropdown( L["Font"], ns.fontList )
	font.desc = L["Select a typeface for text on the frames."]
	font:SetPoint( "TOPLEFT", statusbar, "BOTTOMLEFT", 0, -12 )
	font:SetPoint( "TOPRIGHT", statusbar, "BOTTOMRIGHT", 0, -12 )

	font.OnValueChanged = function( self, value )
		local file = SharedMedia:Fetch( "font", value )
		if db.font == file then return end
		db.font = file
		local _, height, flags = self.valueText:GetFont()
		self.valueText:SetFont( file, height, flags )
		ns.SetAllFonts()
	end

	do
		local button_OnClick = font.button:GetScript( "OnClick" )
		font.button:SetScript( "OnClick", function( self )
			button_OnClick( self )
			font.dropdown.list:Hide()

			local function SetButtonFonts( self )
				local buttons = font.dropdown.list.buttons
				for i = 1, #buttons do
					local button = buttons[ i ]
					if button.value and button:IsShown() then
						button.label:SetFont( SharedMedia:Fetch( "font", button.value ), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT )
					end
				end
			end

			local OnShow = font.dropdown.list:GetScript( "OnShow" )
			font.dropdown.list:SetScript( "OnShow", function( self )
				OnShow( self )
				SetButtonFonts( self )
			end )

			local OnVerticalScroll = font.dropdown.list.scrollFrame:GetScript( "OnVerticalScroll" )
			font.dropdown.list.scrollFrame:SetScript( "OnVerticalScroll", function( self, delta )
				OnVerticalScroll( self, delta )
				SetButtonFonts( self )
			end )

			local SetText = font.dropdown.list.text.SetText
			font.dropdown.list.text.SetText = function( self, text )
				self:SetFont( SharedMedia:Fetch( "font", text ), UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT + 1 )
				SetText( self, text )
			end

			button_OnClick( self )
			self:SetScript( "OnClick", button_OnClick )
		end )
	end

	--------------------------------------------------------------------

	local outline
	local outlines = {
		["NONE"] = L["None"],
		["OUTLINE"] = L["Thin"],
		["THICKOUTLINE"] = L["Thick"],
	}
	do
		local function OnClick( self )
			db.fontOutline = self.value
			ns.SetAllFonts()
			outline:SetValue( self.value, self.text )
		end

		local info = {}

		outline = self:CreateDropdown( L["Font Outline"], function()
			local selected = db.fontOutline

			info.text = L["None"]
			info.value = "NONE"
			info.func = OnClick
			info.checked = "NONE" == selected
			UIDropDownMenu_AddButton( info )

			info.text = L["Thin"]
			info.value = "OUTLINE"
			info.func = OnClick
			info.checked = "THIN" == selected
			UIDropDownMenu_AddButton( info )

			info.text = L["Thick"]
			info.value = "THICKOUTLINE"
			info.func = OnClick
			info.checked = "THICK" == selected
			UIDropDownMenu_AddButton( info )
		end )
	end
	outline.desc = L["Select an outline weight for text on the frames."]
	outline:SetPoint( "TOPLEFT", font, "BOTTOMLEFT", 0, -12 )
	outline:SetPoint( "TOPRIGHT", font, "BOTTOMRIGHT", 0, -12 )

	--------------------------------------------------------------------

	local borderSize = self:CreateSlider( L["Border Size"], 8, 24, 1 )
	borderSize.desc = L["Change the size of the frame borders."]
	borderSize:SetPoint( "TOPLEFT", outline, "BOTTOMLEFT", -2, -12 )
	borderSize:SetPoint( "TOPRIGHT", outline, "BOTTOMRIGHT", 4, -12 )

	borderSize.OnValueChanged = function( self, value )
		value = math.floor( value + 0.5 )
		db.borderSize = value
		for _, frame in ipairs( ns.borderedObjects ) do
			frame:SetBorderSize( value )
		end
		return value
	end

	--------------------------------------------------------------------

	local borderColor = self:CreateColorPicker( L["Border color"] )
	borderColor.desc = L["Change the default frame border color."]
	borderColor:SetPoint( "TOPLEFT", borderSize, "BOTTOMLEFT", 6, -8 )

	borderColor.GetColor = function()
		return unpack( db.borderColor )
	end

	borderColor.OnColorChanged = function( self, r, g, b )
		db.borderColor[1] = r
		db.borderColor[2] = g
		db.borderColor[3] = b
		for _, frame in ipairs( ns.borderedObjects ) do
			frame:SetBorderColor( r, g, b )
		end
		for _, frame in ipairs( ns.objects ) do
			if frame.UpdateBorder then
				frame:UpdateBorder()
			end
		end
	end

	--------------------------------------------------------------------

	local dispelFilter = self:CreateCheckbox( L["Filter debuff highlight"] )
	dispelFilter.desc = L["Show the debuff highlight only for debuffs you can dispel."]
	dispelFilter:SetPoint( "TOPLEFT", notes, "BOTTOM", 12, -24 )
	dispelFilter.OnClick = function( self, checked )
		db.dispelFilter = checked
		for _, frame in ipairs( ns.objects ) do
			if frame.DispelHighlight then
				frame.DispelHighlightFilter = checked
				if frame:IsShown() then
					frame:GetScript( "OnEvent" )( frame, "UNIT_AURA", frame.unit )
				end
			end
		end
	end

	--------------------------------------------------------------------

	local healFilter = self:CreateCheckbox( L["Ignore own heals"] )
	healFilter.desc = L["Show only incoming heals cast by other players."]
	healFilter:SetPoint( "TOPLEFT", dispelFilter, "BOTTOMLEFT", 0, -8 )

	healFilter.OnClick = function( self, checked )
		db.ignoreOwnHeals = checked
		for _, frame in ipairs( oUF.objects ) do
			if frame.HealPrediction and frame:IsShown() then
				frame.HealPrediction:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	local threatLevels = self:CreateCheckbox( L["Show threat levels"] )
	threatLevels.desc = L["Show threat levels instead of binary aggro status."]
	threatLevels:SetPoint( "TOPLEFT", healFilter, "BOTTOMLEFT", 0, -8 )

	threatLevels.OnClick = function( self, checked )
		db.threatLevels = checked
		for _, frame in ipairs( oUF.objects ) do
			if frame.ThreatHighlight and frame:IsShown() then
				frame.ThreatHighlight:ForceUpdate()
			end
		end
	end

	--------------------------------------------------------------------

	self.refresh = function()
		for k, v in pairs( SharedMedia:HashTable( "statusbar" ) ) do
			if v == db.statusbar or v:match( "([^\\]+)$" ) == db.statusbar:match( "([^\\]+)$" ) then
				statusbar:SetValue( k )
			end
		end
		for k, v in pairs( SharedMedia:HashTable( "font" ) ) do
			if v == db.font or v:lower():match( "([^\\]+)%.ttf$" ) == db.font:lower():match( "([^\\]+)%.ttf$" ) then
				font:SetValue( k )
			end
		end
		outline:SetValue( db.fontOutline, outlines[ db.fontOutline ] )
		borderSize:SetValue( db.borderSize )
		borderColor:SetColor( unpack( db.borderColor ) )
		dispelFilter:SetChecked( db.dispelFilter )
		healFilter:SetChecked( db.ignoreOwnHeals )
		threatLevels:SetChecked( db.threatLevels )
	end

	self.refresh()
	self:SetScript( "OnShow", nil )
end )

InterfaceOptions_AddCategory( ns.optionsPanel )

------------------------------------------------------------------------

ns.colorsPanel = CreateFrame( "Frame", nil, InterfaceOptionsFramePanelContainer )
ns.colorsPanel.parent = ns.optionsPanel.name
ns.colorsPanel.name = ns.L["Bar Colors"]
ns.colorsPanel:Hide()

ns.colorsPanel:SetScript( "OnShow", function( self )
	local db = ns.config
	local L = ns.L

	self.CreateCheckbox = LibStub( "PhanxConfig-Checkbox" ).CreateCheckbox
	self.CreateColorPicker = LibStub( "PhanxConfig-ColorPicker" ).CreateColorPicker
	self.CreateDropdown = LibStub( "PhanxConfig-Dropdown" ).CreateDropdown
	self.CreateSlider = LibStub( "PhanxConfig-Slider" ).CreateSlider

	--------------------------------------------------------------------

	local title = self:CreateFontString( nil, "ARTWORK", "GameFontNormalLarge" )
	title:SetPoint( "TOPLEFT", 16, -16 )
	title:SetPoint( "TOPRIGHT", -16, -16 )
	title:SetJustifyH( "LEFT" )
	title:SetText( self.name )

	local notes = self:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
	notes:SetPoint( "TOPLEFT", title, "BOTTOMLEFT", 0, -8 )
	notes:SetPoint( "TOPRIGHT", title, "BOTTOMRIGHT", 0, -8 )
	notes:SetHeight( 20 )
	notes:SetJustifyH( "LEFT" )
	notes:SetJustifyV( "TOP" )
	notes:SetNonSpaceWrap( true )
	notes:SetText( L["Use this panel to configure the colors used for different parts of the unit frames created by this layout."] )

	--------------------------------------------------------------------

	local barColor

	local barColorModes = {
		["CLASS"]  = L["By Class"],
		["HEALTH"] = L["By Health"],
		["CUSTOM"] = L["Custom"],
	}

	local barColorMode = self:CreateDropdown( L["Health color mode"] )
	barColorMode.desc = L["Change how health bars are colored."]
	barColorMode:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	barColorMode:SetPoint( "TOPRIGHT", notes, "BOTTOM", -8, -12 )

	do
		local function OnClick( self )
			local v = self.value
			db.barColorMode = v
			barColorMode:SetValue( v, self.text )
			for _, frame in ipairs( ns.objects ) do
				local hp = frame.Health
				if type( hp ) == "table" then
					hp.colorClass = v == "CLASS"
					hp.colorReaction = v == "CLASS"
					hp.colorSmooth = v == "HEALTH"
					if v == "CUSTOM" then
						local mu = hp.bg.multiplier
						local r, g, b = unpack( db.barColor )
						hp:SetStatusBarColor( r, g, b )
						hp.bg:SetVertexColor( r * mu, g * mu, b * mu )
					else
						frame:GetScript( "OnEvent" )( frame, "UNIT_HEALTH", frame.unit )
					end
				end
			end
			if v == "CUSTOM" then
				barColor:Show()
			else
				barColor:Hide()
			end
		end

		local info = {}
		UIDropDownMenu_Initialize( barColorMode.dropdown, function()
			local selected = db.barColorMode

			info.text = L["By Class"]
			info.value = "CLASS"
			info.func = OnClick
			info.checked = "CLASS" == selected
			UIDropDownMenu_AddButton( info )

			info.text = L["By Health"]
			info.value = "HEALTH"
			info.func = OnClick
			info.checked = "HEALTH" == selected
			UIDropDownMenu_AddButton( info )

			info.text = L["Custom"]
			info.value = "CUSTOM"
			info.func = OnClick
			info.checked = "CUSTOM" == selected
			UIDropDownMenu_AddButton( info )
		end )
	end

	--------------------------------------------------------------------

	barColor = self:CreateColorPicker( L["Health bar color"] )
	barColor.desc = L["Change the health bar color."]
	barColor:SetPoint( "BOTTOMLEFT", barColorMode, "BOTTOMRIGHT", 16, 6 )

	barColor.GetColor = function()
		return unpack( db.barColor )
	end

	barColor.OnColorChanged = function( self, r, g, b )
		db.barColor[1] = r
		db.barColor[2] = g
		db.barColor[3] = b
		for _, frame in ipairs( ns.objects ) do
			local hp = frame.Health
			if type( hp ) == "table" then
				local mu = hp.bg.multiplier
				hp:SetStatusBarColor( r, g, b )
				hp.bg:SetVertexColor( r * mu, g * mu, b * mu )
			end
		end
	end

	--------------------------------------------------------------------

	local powerColor

	local powerColorModes = {
		["CLASS"]  = L["By Class"],
		["POWER"]  = L["By Power Type"],
		["CUSTOM"] = L["Custom"],
	}

	local powerColorMode = self:CreateDropdown( L["Power color mode"] )
	powerColorMode.desc = L["Change how power bars are colored."]
	powerColorMode:SetPoint( "TOPLEFT", barColorMode, "BOTTOMLEFT", 0, -12 )
	powerColorMode:SetPoint( "TOPRIGHT", barColorMode, "BOTTOMRIGHT", 0, -12 )

	do
		local function OnClick( self )
			local v = self.value
			db.powerColorMode = v
			powerColorMode:SetValue( v, self.text )
			for _, frame in ipairs( ns.objects ) do
				local pp = object.Power
				if type( pp ) == "table" then
					pp.colorClass = v == "CLASS"
					pp.colorReaction = v == "CLASS"
					pp.colorPower = v == "POWER"
					if v == "CUSTOM" then
						local mu = pp.bg.multiplier
						local r, g, b = unpack( db.powerColor )
						pp:SetStatusBarColor( r, g, b )
						pp.bg:SetVertexColor( r * mu, g * mu, b * mu )
					else
						frame:GetScript( "OnEvent" )( frame, "UNIT_POWER", frame.unit )
					end
				end
			end
			if v == "CUSTOM" then
				powerColor:Show()
			else
				powerColor:Hide()
			end
		end

		local info = {}
		UIDropDownMenu_Initialize( powerColorMode.dropdown, function()
			local selected = db.powerColorMode

			info.text = L["By Class"]
			info.value = "CLASS"
			info.func = OnClick
			info.checked = "CLASS" == selected
			UIDropDownMenu_AddButton( info )

			info.text = L["By Power Type"]
			info.value = "POWER"
			info.func = OnClick
			info.checked = "HEALTH" == selected
			UIDropDownMenu_AddButton( info )

			info.text = L["Custom"]
			info.value = "CUSTOM"
			info.func = OnClick
			info.checked = "CUSTOM" == selected
			UIDropDownMenu_AddButton( info )
		end )
	end

	powerColorMode:Hide() -- NYI

	--------------------------------------------------------------------

	powerColor = self:CreateColorPicker( L["Health bar color"] )
	powerColor.desc = L["Change the health bar color."]
	powerColor:SetPoint( "BOTTOMLEFT", powerColorMode, "BOTTOMRIGHT", 16, 4 )

	powerColor.OnColorChanged = function( self, r, g, b )
		db.powerColor[1] = r
		db.powerColor[2] = g
		db.powerColor[3] = b
		for _, frame in ipairs( ns.objects ) do
			local pp = frame.Power
			if type( pp ) == "table" then
				local mu = pp.bg.multiplier
				pp:SetStatuspowerColor( r, g, b )
				pp.bg:SetVertexColor( r * mu, g * mu, b * mu )
			end
		end
	end

	powerColor:Hide() -- NYI

	--------------------------------------------------------------------

	local bgColorIntensity = self:CreateSlider( L["Background intensity"], 0, 2, 0.1, true )
	bgColorIntensity.desc = L["Change the brightness of the health bar background color, relative to the foreground color."]
	bgColorIntensity:SetPoint( "TOPLEFT", powerColorMode, "BOTTOMLEFT", 0, -16 )
	bgColorIntensity:SetPoint( "TOPRIGHT", powerColorMode, "BOTTOMRIGHT", 0, -16 )

	bgColorIntensity.OnValueChanged = function( self, value )
		value = math.floor( value * 100 + 0.5 ) / 100
		db.bgColorIntensity = value
		local custom = db.barColorMode == "CUSTOM"
		for _, frame in ipairs( ns.objects ) do
			local hp = frame.Health
			if type( hp ) == "table" then
				hp.bg.multiplier = value
				if custom then
					barColor:OnColorChanged( unpack( db.barColor ) )
				else
					frame:GetScript( "OnEvent" )( frame, "UNIT_HEALTH", frame.unit )
				end
			end
		end
		return value
	end

	--------------------------------------------------------------------

	self.refresh = function()
		barColorMode:SetValue( db.barColorMode, barColorModes[ db.barColorMode ] )
		if db.barColorMode == "CUSTOM" then
			barColor:Show()
		else
			barColor:Hide()
		end
		barColor:SetColor( unpack( db.barColor ) )
		bgColorIntensity:SetValue( db.bgColorIntensity )
	end

	self.refresh()
	self:SetScript( "OnShow", nil )
end )

InterfaceOptions_AddCategory( ns.colorsPanel )

------------------------------------------------------------------------

local AboutPanel = LibStub( "LibAboutPanel", true )
if AboutPanel then
	ns.aboutPanel = AboutPanel.new( ns.optionsPanel.name, "oUF_Phanx" )
end

------------------------------------------------------------------------

SLASH_OUFPHANX1 = "/pouf"

SlashCmdList.OUFPHANX = function()
	InterfaceOptionsFrame_OpenToCategory( ns.colorsPanel )
	InterfaceOptionsFrame_OpenToCategory( ns.optionsPanel )
end