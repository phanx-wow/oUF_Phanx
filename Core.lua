--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	https://mods.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
----------------------------------------------------------------------]]

local _, ns = ...
local Media

ns.fontstrings = {}
ns.statusbars = {}

------------------------------------------------------------------------
--	Default configuration
------------------------------------------------------------------------

ns.configDefaultPC = {
	druidMana = true,       -- show secondary mana bar
}

ns.configDefault = {
	width = 225,
	height = 30,
	powerHeight = 0.2,      -- how much of the frame's height should be occupied by the power bar

	backdrop = { bgFile = [[Interface\BUTTONS\WHITE8X8]] },
	backdropColor = { 32/256, 32/256, 32/256, 1 },

	statusbar = "Neal",

	font = "PT Sans Bold",
	fontOutline = "OUTLINE",
	fontShadow = true,
	fontScale = 1,          -- no UI

	dispelFilter = true,    -- only highlight the frame for debuffs you can dispel
	ignoreOwnHeals = false, -- show only incoming heals from other players
	threatLevels = true,    -- show threat levels instead of binary aggro

	combatText = false,     -- show combat feedback text
	runeBars = true,        -- [deathknight] show rune cooldown bars
	staggerBar = true,      -- [monk] show stagger bar
	totemBars = true,       -- [shaman] show totem duration bars

	healthColor = { 0.2, 0.2, 0.2 },
	healthColorMode = "CUSTOM",
	healthBG = 2,

	powerColor = { 0.8, 0.8, 0.8 },
	powerColorMode = "CLASS",
	powerBG = 0.25,

	borderColor = { 0.5, 0.5, 0.5 },
	borderSize = 16,

	PVP = false,            -- enable PVP mode, currently only affects aura filtering
}

------------------------------------------------------------------------
--	Default unit configuration
------------------------------------------------------------------------

ns.uconfigDefault = {
	player = {
		point = "BOTTOMRIGHT UIParent CENTER -200 -200",
		width = 1.3,
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
		width = 1.3,
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
		point = "TOPLEFT boss5 BOTTOMLEFT 0 -75", -- CHECK POSITION
		width = 0.5,
		power = true,
		attributes = { "showPlayer", true, "showParty", true, "showRaid", false, "xOffset", 0, "yOffset", -25 },
		visible = "custom [nogroup][group:party,@party1,noexists][group:raid,@raid6,exists]hide;show",
	},
	partypet = {
		point = "TOPLEFT party TOPRIGHT 12 0",
		width = 0.25,
		attributes = { "showPlayer", true, "showParty", true, "showRaid", false, "xOffset", 0, "yOffset", -25, "useOwnerUnit", true, "unitsuffix", "pet" },
		visible = "custom [nogroup][group:party,@party1,noexists][group:raid,@raid6,exists]hide;show",
	},
	-------------
	--	Bosses --
	-------------
	boss1 = {
		point = "TOPRIGHT UIParent TOPRIGHT -15 -250",
		width = 0.8,
		height = 0.8,
		power = true,
	},
	boss2 = {
		point = "TOPRIGHT boss1 BOTTOMRIGHT 0 -25",
		width = 0.8,
		height = 0.8,
		power = true,
	},
	boss3 = {
		point = "TOPRIGHT boss2 BOTTOMRIGHT 0 -25",
		width = 0.8,
		height = 0.8,
		power = true,
	},
	boss4 = {
		point = "TOPRIGHT boss3 BOTTOMRIGHT 0 -25",
		width = 0.8,
		height = 0.8,
		power = true,
	},
	boss5 = {
		point = "TOPRIGHT boss4 BOTTOMRIGHT 0 -25",
		width = 0.8,
		height = 0.8,
		power = true,
	},
	-----------------------
	--	Arena Oppnonents --
	-----------------------
	arena1 = {
		point = "TOPLEFT boss1",
		width = 0.5,
		height = 0.8,
		power = true,
	},
	arena2 = {
		point = "TOPRIGHT arena1 BOTTOMRIGHT 0 -25",
		width = 0.5,
		height = 0.8,
		power = true,
	},
	arena3 = {
		point = "TOPRIGHT arena2 BOTTOMRIGHT 0 -25",
		width = 0.5,
		height = 0.8,
		power = true,
	},
	arena4 = {
		point = "TOPRIGHT arena3 BOTTOMRIGHT 0 -25",
		width = 0.5,
		height = 0.8,
		power = true,
	},
	arena5 = {
		point = "TOPRIGHT arena4 BOTTOMRIGHT 0 -25",
		width = 0.5,
		height = 0.8,
		power = true,
	},
	----------------------------
	--	Arena Opponents' Pets --
	----------------------------
	arenapet1 = {
		point = "LEFT arena1 RIGHT 10 0",
		width = 0.25,
		height = 0.8,
	},
	arenapet2 = {
		point = "LEFT arena2 RIGHT 10 0",
		width = 0.25,
		height = 0.8,
	},
	arenapet3 = {
		point = "LEFT arena3 RIGHT 10 0",
		width = 0.25,
		height = 0.8,
	},
	arenapet4 = {
		point = "LEFT arena4 RIGHT 10 0",
		width = 0.25,
		height = 0.8,
	},
	arenapet5 = {
		point = "LEFT arena5 RIGHT 10 0",
		width = 0.25,
		height = 0.8,
	},
}

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

oUF.colors.fallback = { 1, 1, 0.8 }
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
	rcolor[1][1], rcolor[1][2], rcolor[1][3] = 1, 0.2, 0.2 -- Hated
	rcolor[2][1], rcolor[2][2], rcolor[2][3] = 1, 0.2, 0.2 -- Hostile
	rcolor[3][1], rcolor[3][2], rcolor[3][3] = 1, 0.6, 0.2 -- Unfriendly
	rcolor[4][1], rcolor[4][2], rcolor[4][3] = 1,   1, 0.2 -- Neutral
	rcolor[5][1], rcolor[5][2], rcolor[5][3] = 0.2, 1, 0.2 -- Friendly
	rcolor[6][1], rcolor[6][2], rcolor[6][3] = 0.2, 1, 0.2 -- Honored
	rcolor[7][1], rcolor[7][2], rcolor[7][3] = 0.2, 1, 0.2 -- Revered
	rcolor[8][1], rcolor[8][2], rcolor[8][3] = 0.2, 1, 0.2 -- Exalted
end

------------------------------------------------------------------------
--	Load stuff
------------------------------------------------------------------------

local Loader = CreateFrame("Frame")
Loader:RegisterEvent("ADDON_LOADED")
Loader:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

local Options = CreateFrame("Frame", "oUFPhanxOptions")
Options:Hide()
Options.name = "oUF Phanx"
InterfaceOptions_AddCategory(Options)

function Loader:ADDON_LOADED(event, addon)
	if addon ~= "oUF_Phanx" then return end

	local function initDB(db, defaults)
		if type(db) ~= "table" then db = {} end
		if type(defaults) ~= "table" then return db end
		for k, v in pairs(defaults) do
			if type(v) == "table" then
				db[k] = initDB(db[k], v)
			elseif type(v) ~= type(db[k]) then
				db[k] = v
			end
		end
		return db
	end

	-- Global settings:
	oUFPhanxConfig = initDB(oUFPhanxConfig, ns.configDefault)
	ns.config = oUFPhanxConfig

	-- Global unit settings:
	oUFPhanxUnitConfig = initDB(oUFPhanxUnitConfig, ns.uconfigDefault)
	ns.uconfig = oUFPhanxUnitConfig

	-- Per-character settings:
	oUFPhanxConfigPC = initDB(oUFPhanxConfigPC, ns.configDefaultPC)
	ns.configPC = oUFPhanxConfigPC

	-- Aura settings stored per character:
	local AURA_CONFIG_VERSION = 3
	if oUFPhanxAuraConfig and oUFPhanxAuraConfig.VERSION and oUFPhanxAuraConfig.VERSION < AURA_CONFIG_VERSION then
		-- Just wipe old bitflags, upgrading v1, v2 is too much work.
		-- Will try to be more vigilant about incremental upgrades in the future.
		oUFPhanxAuraConfig = nil
	end
	oUFPhanxAuraConfig = initDB(oUFPhanxAuraConfig, {
		customFilters = {},
		deleted = {},
	})
	if oUFPhanxAuraConfig.VERSION == nil then
		-- Upgrade from pre-bitflag filter values
		local bitflags = {
			[0] = ns.auraFilterValues.FILTER_DISABLE,
			[1] = ns.auraFilterValues.FILTER_ALL,
			[2] = ns.auraFilterValues.FILTER_BY_PLAYER,
			[3] = ns.auraFilterValues.FILTER_ON_FRIEND,
			[4] = ns.auraFilterValues.FILTER_ON_PLAYER,
		}
		for id, flag in pairs(oUFPhanxAuraConfig) do
			if id ~= "customFilters" and id ~= "deleted" then
				oUFPhanxAuraConfig.customFilters[id] = bitflags[flag]
				oUFPhanxAuraConfig[id] = nil
			end
		end
	end
	-- Remove default values and auras that no longer exist in the game
	for id, flag in pairs(oUFPhanxAuraConfig.customFilters) do
		if flag == ns.defaultAuras[id] or not GetSpellInfo(id) then
			oUFPhanxAuraConfig.customFilters[id] = nil
		end
	end
	oUFPhanxAuraConfig.VERSION = AURA_CONFIG_VERSION
	ns.UpdateAuraList()

	-- SharedMedia
	Media = LibStub("LibSharedMedia-3.0", true)
	if Media then
		Media:Register("font", "PT Sans Bold", [[Interface\AddOns\oUF_Phanx\media\PTSans-Bold.ttf]])
		Media:Register("statusbar", "Flat", [[Interface\BUTTONS\WHITE8X8]])
		Media:Register("statusbar", "Neal", [[Interface\AddOns\oUF_Phanx\media\Neal]])

		Media.RegisterCallback("oUF_Phanx", "LibSharedMedia_Registered", function(callback, mediaType, key)
			--print(callback, mediaType, key)
			if mediaType == "font" and key == ns.config.font then
				ns.SetAllFonts()
			elseif mediaType == "statusbar" and key == ns.config.statusbar then
				ns.SetAllStatusBarTextures()
			end
		end)
		Media.RegisterCallback("oUF_Phanx", "LibSharedMedia_SetGlobal", function(callback, mediaType)
			--print(callback, mediaType)
			if mediaType == "font" then
				ns.SetAllFonts()
			elseif mediaType == "statusbar" then
				ns.SetAllStatusBarTextures()
			end
		end)
	end

	-- Cleanup
	self:UnregisterEvent(event)
	self.ADDON_LOADED = nil
	self:RegisterEvent("PLAYER_LOGOUT")

	-- Go
	oUF:Factory(ns.Factory)

	-- Sounds for target/focus changing and PVP flagging
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterUnitEvent("UNIT_FACTION", "player")

	-- Shift to temporarily show all buffs
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	if not UnitAffectingCombat("player") then
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
	end

	-- Load options on demand
--[===[@non-debug@
	Options:SetScript("OnShow", function(self)
		oUFPhanx = ns
		local loaded, reason = LoadAddOn("oUF_Phanx_Config")
		if not loaded then
			local text = self:CreateFontString(nil, nil, "GameFontHighlight")
			text:SetPoint("BOTTOMLEFT", 16, 16)
			text:SetPoint("TOPRIGHT", -16, -16)
			text:SetFormattedText(ADDON_LOAD_FAILED, "oUF_Phanx_Config", _G[reason])
			oUFPhanx = nil
		end
	end)
--@end-non-debug@]===]

	SLASH_OUFPHANX1 = "/pouf"
	SLASH_OUFPHANX2 = "/oufphanx"
	function SlashCmdList.OUFPHANX(cmd)
		cmd = strlower(cmd)
		if cmd == "buffs" or cmd == "debuffs" then
			local tmp = {}
			local func = cmd == "buffs" and UnitBuff or UnitDebuff
			for i = 1, 40 do
				local name, _, _, _, _, _, _, _, _, _, id = func("target", i)
				if not name then break end
				tinsert(tmp, format("%s [%d]", name, id))
			end
			if #tmp > 0 then
				sort(tmp)
				DEFAULT_CHAT_FRAME:AddMessage(format("|cff00ddbaoUF Phanx:|r Your current target has %d %s:", #tmp, cmd))
				for i = 1, #tmp do
					DEFAULT_CHAT_FRAME:AddMessage("   ", tmp[i])
				end
			else
				DEFAULT_CHAT_FRAME:AddMessage(format("|cff00ddbaoUF Phanx:|r Your current target does not have any %s.", cmd))
			end
		else
			InterfaceOptionsFrame_OpenToCategory("oUF Phanx")
			InterfaceOptionsFrame_OpenToCategory("oUF Phanx")
		end
	end
end

------------------------------------------------------------------------

function Loader:PLAYER_LOGOUT(event)
	local function cleanDB(db, defaults)
		if type(db) ~= "table" then return {} end
		if type(defaults) ~= "table" then return db end
		for k, v in pairs(db) do
			if type(v) == "table" then
				if not next(cleanDB(v, defaults[k])) then
					-- Remove empty subtables
					db[k] = nil
				end
			elseif v == defaults[k] then
				-- Remove default values
				db[k] = nil
			end
		end
		return db
	end

	oUFPhanxConfig = cleanDB(oUFPhanxConfig, ns.configDefault)
	oUFPhanxUnitConfig = cleanDB(oUFPhanxUnitConfig, ns.uconfigDefault)
end

------------------------------------------------------------------------

function Loader:PLAYER_FOCUS_CHANGED(event)
	if UnitExists("focus") then
		if UnitIsEnemy("focus", "player") then
			PlaySound("igCreatureAggroSelect")
		elseif UnitIsFriend("player", "focus") then
			PlaySound("igCharacterNPCSelect")
		else
			PlaySound("igCreatureNeutralSelect")
		end
	else
		PlaySound("INTERFACESOUND_LOSTTARGETUNIT")
	end
end

function Loader:PLAYER_TARGET_CHANGED(event)
	if UnitExists("target") then
		if UnitIsEnemy("target", "player") then
			PlaySound("igCreatureAggroSelect")
		elseif UnitIsFriend("player", "target") then
			PlaySound("igCharacterNPCSelect")
		else
			PlaySound("igCreatureNeutralSelect")
		end
	else
		PlaySound("INTERFACESOUND_LOSTTARGETUNIT")
	end
end

local announcedPVP
function Loader:UNIT_FACTION(event, unit)
	if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
		if not announcedPVP then
			announcedPVP = true
			PlaySound("igPVPUpdate")
		end
	else
		announcedPVP = nil
	end
end

------------------------------------------------------------------------

function Loader:PLAYER_REGEN_DISABLED(event)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	self:MODIFIER_STATE_CHANGED(event, "LSHIFT", 0)
end

function Loader:PLAYER_REGEN_ENABLED(event)
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:MODIFIER_STATE_CHANGED(event, "LSHIFT", IsShiftKeyDown() and 1 or 0)
end

function Loader:MODIFIER_STATE_CHANGED(event, key, state)
	if key ~= "LSHIFT" and key ~= "RSHIFT" then
		return
	end
	local a, b, c
	if state == 1 then
		a, b, c = "CustomFilter", "__CustomFilter", ns.CustomAuraFilters.default
	else
		a, b = "__CustomFilter", "CustomFilter"
	end
	for i = 1, #oUF.objects do
		local object = oUF.objects[i]
		local buffs = object.Auras or object.Buffs
		if buffs and buffs[a] then
			buffs[b] = buffs[a]
			buffs[a] = c
			buffs:ForceUpdate()
		end
		local debuffs = object.Debuffs
		if debuffs and debuffs[a] then
			debuffs[b] = debuffs[a]
			debuffs[a] = c
			debuffs:ForceUpdate()
		end
	end
end

------------------------------------------------------------------------

function ns.si(value, raw)
	if not value then return "" end
	local absvalue = abs(value)
	local str, val

	if absvalue >= 1e10 then
		str, val = "%.0fb", value / 1e9
	elseif absvalue >= 1e9 then
		str, val = "%.1fb", value / 1e9
	elseif absvalue >= 1e7 then
		str, val = "%.1fm", value / 1e6
	elseif absvalue >= 1e6 then
		str, val = "%.2fm", value / 1e6
	elseif absvalue >= 1e5 then
		str, val = "%.0fk", value / 1e3
	elseif absvalue >= 1e3 then
		str, val = "%.1fk", value / 1e3
	else
		str, val = "%d", value
	end

	if raw then
		return str, val
	else
		return format(str, val)
	end
end

------------------------------------------------------------------------

local FALLBACK_FONT_SIZE = 16 -- some Blizzard bug

function ns.GetFontFile()
	return Media:Fetch("font", ns.config.font) or STANDARD_TEXT_FONT
end

function ns.CreateFontString(parent, size, justify)
	local file = ns.GetFontFile()
	if not size or size < 6 then size = FALLBACK_FONT_SIZE end
	size = size * ns.config.fontScale

	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(file, size, ns.config.fontOutline)
	fs:SetJustifyH(justify or "LEFT")
	fs:SetShadowOffset(ns.config.fontShadow and 1 or 0, ns.config.fontShadow and -1 or 0)
	fs:SetWordWrap(false)
	fs.baseSize = size

	tinsert(ns.fontstrings, fs)
	return fs
end

function ns.SetAllFonts()
	local file = ns.GetFontFile()
	local outline = ns.config.fontOutline
	local shadow = ns.config.fontShadow and 1 or 0
	--print("SetAllFonts", strmatch(file, "[^/\\]+$"), outline)

	for i = 1, #ns.fontstrings do
		local fontstring = ns.fontstrings[i]
		local _, size = fontstring:GetFont()
		if not size or size < 6 then size = FALLBACK_FONT_SIZE end
		fontstring:SetFont(file, size, outline)
		fontstring:SetShadowOffset(shadow, -shadow)
	end

	if not MirrorTimer3.text then return end -- too soon!
	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		local _, size = bar.text:GetFont()
		bar.text:SetFont(file, size, outline)
	end
end

------------------------------------------------------------------------

do
	local function SetOrientation(self, orientation)
		self.__vertical = orientation == "VERTICAL"
	end

	local function SetReverseFill(self, reverse)
		self.__reverse = reverse
	end

	local function SetValue(self, v)
		local mn, mx = self:GetMinMaxValues()
		if v > 0 and v > mn and v <= mx then
			local pct = (v - mn) / (mx - mn)
			if self.__vertical then
				if self.__reverse then
					self.texture:SetTexCoord(0, 1, 1 - pct, 1)
				else
					self.texture:SetTexCoord(0, 1, 0, pct)
				end
			else
				if self.__reverse then
					self.texture:SetTexCoord(1 - pct, 1, 0, 1)
				else
					self.texture:SetTexCoord(0, pct, 0, 1)
				end
			end
		end
	end

	function ns.GetBarTexture()
		return Media:Fetch("statusbar", ns.config.statusbar) or "Interface\\TargetingFrame\\UI-StatusBar"
	end

	function ns.CreateStatusBar(parent, size, justify, noBG, noSmoothing)
		local file = ns.GetBarTexture()

		local sb = CreateFrame("StatusBar", "oUFPhanxStatusBar"..(1 + #ns.statusbars), parent) -- global name to avoid Blizzard /fstack error
		sb:SetStatusBarTexture(file)
		tinsert(ns.statusbars, sb)

		sb.texture = sb:GetStatusBarTexture()
		sb.texture:SetDrawLayer("BORDER")
		sb.texture:SetHorizTile(false)
		sb.texture:SetVertTile(false)

		if size then
			sb.value = ns.CreateFontString(sb, size, justify)
		end

		if not noBG then
			sb.bg = sb:CreateTexture(nil, "BACKGROUND")
			sb.bg:SetTexture(file)
			sb.bg:SetAllPoints(true)
			tinsert(ns.statusbars, sb.bg)
		end

		local SmoothBar = not noSmoothing and (parent.SmoothBar or parent.__owner and parent.__owner.SmoothBar)
		if SmoothBar then
			SmoothBar(nil, sb) -- nil should be frame but isn't used
			sb.__smooth = true
		end

		hooksecurefunc(sb, "SetOrientation", SetOrientation)
		hooksecurefunc(sb, "SetReverseFill", SetReverseFill)
		hooksecurefunc(sb, "SetValue", SetValue)

		return sb
	end
end

function ns.SetAllStatusBarTextures()
	local file = ns.GetBarTexture()
	--print("SetAllStatusBarTextures", strmatch(file, "[^/\\]+$"))

	for i = 1, #ns.statusbars do
		local sb = ns.statusbars[i]
		if sb.SetStatusBarTexture then
			local r, g, b, a = sb:GetStatusBarColor()
			sb:SetStatusBarTexture(file)
			sb:SetStatusBarColor(r, g, b, a)
		else
			local r, g, b, a = sb:GetVertexColor()
			sb:SetTexture(file)
			sb:SetVertexColor(r, g, b, a)
		end
	end

	if not MirrorTimer3.bar then return end -- too soon!
	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]

		local r, g, b, a = bar.bar:GetStatusBarColor()
		bar.bar:SetStatusBarTexture(file)
		bar.bar:SetStatusBarColor(r, g, b, a)

		local r, g, b, a = bar.bg:GetVertexColor()
		bar.bg:SetTexture(file)
		bar.bg:SetVertexColor(r, g, b, a)
	end
end
