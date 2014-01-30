--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
ns.loadFuncs = {}

ns.fontList = {}
ns.statusbarList = {}

ns.fontstrings = {}
ns.statusbars = {}

------------------------------------------------------------------------
--	Load stuff
------------------------------------------------------------------------

local Loader = CreateFrame("Frame")
Loader:RegisterEvent("ADDON_LOADED")
Loader:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

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

	-- Aura settings stored per character:
	oUFPhanxAuraConfig = initDB(oUFPhanxAuraConfig)
	ns.UpdateAuraList()

	-- SharedMedia
	local SharedMedia = LibStub("LibSharedMedia-3.0", true)
	if SharedMedia then
		SharedMedia:Register("font", "PT Sans Bold", [[Interface\AddOns\oUF_Phanx\media\PTSans-Bold.ttf]])

		SharedMedia:Register("statusbar", "Flat", [[Interface\BUTTONS\WHITE8X8]])
		SharedMedia:Register("statusbar", "Neal", [[Interface\AddOns\oUF_Phanx\media\Neal]])

		for i, name in pairs(SharedMedia:List("font")) do
			tinsert(ns.fontList, name)
		end
		sort(ns.fontList)

		for i, name in pairs(SharedMedia:List("statusbar")) do
			tinsert(ns.statusbarList, name)
		end
		sort(ns.statusbarList)

		SharedMedia.RegisterCallback("oUF_Phanx", "LibSharedMedia_Registered", function(callback, mediaType, name)
			if mediaType == "font" then
				wipe(ns.fontList)
				for i, v in pairs(SharedMedia:List("font")) do
					tinsert(ns.fontList, v)
				end
				sort(ns.fontList)
			elseif mediaType == "statusbar" then
				wipe(ns.statusbarList)
				for i, v in pairs(SharedMedia:List("statusbar")) do
					tinsert(ns.statusbarList, v)
				end
				sort(ns.statusbarList)
			end
		end)

		SharedMedia.RegisterCallback("oUF_Phanx", "LibSharedMedia_SetGlobal", function(callback, mediaType)
			if mediaType == "font" then
				ns.SetAllFonts()
			elseif mediaType == "statusbar" then
				ns.SetAllStatusBarTextures()
			end
		end)
	end

	-- Miscellaneous
	for i = 1, #ns.loadFuncs do
		ns.loadFuncs[i]()
	end
	ns.loadFuncs = nil

	-- Add about panel after all the other options panels
	local AboutPanel = LibStub("LibAboutPanel", true)
	if AboutPanel then
		ns.aboutPanel = AboutPanel.new(ns.optionsPanel.name, "oUF_Phanx")
	end

	-- Cleanup
	self:UnregisterEvent(event)
	self.ADDON_LOADED = nil
	self:RegisterEvent("PLAYER_LOGOUT")

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
	if state == 1 then
		a, b = "CustomFilter", "__CustomFilter"
	else
		a, b = "__CustomFilter", "CustomFilter"
	end
	for i = 1, #oUF.objects do
		local object = oUF.objects[i]
		local buffs = object.Auras or object.Buffs
		if buffs and buffs[a] then
			buffs[b] = buffs[a]
			buffs[a] = nil
			buffs:ForceUpdate()
		end
	end
end

------------------------------------------------------------------------

function ns.si(value, raw)
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

function ns.CreateFontString(parent, size, justify)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(ns.config.font, size or 16, ns.config.fontOutline)
	fs:SetJustifyH(justify or "LEFT")
	fs:SetShadowOffset(1, -1)

	tinsert(ns.fontstrings, fs)
	return fs
end

function ns.SetAllFonts(file, flag)
	if not file then file = ns.config.font end
	if not flag then flag = ns.config.fontOutline end

	for i = 1, #ns.fontstrings do
		local fontstring = ns.fontstrings[i]
		local _, size, flag = fontstring:GetFont()
		if not size or size == 0 then
			local element = fontstring:GetParent()

			local frame = element:GetParent()
			while frame and not frame:GetName() do
				frame = frame:GetParent()
			end

			local found
			for k, v in pairs(frame) do
				if v == element then
					for k2, v2 in pairs(element) do
						if v2 == fontstring then
							print("bad font height", tostring(size), "on", frame:GetName(), k, k2)
							found = true
						end
					end
				end
			end
			if not found then
				print("bad font height", tostring(size), "on mystery fontstring", fontstring:GetText() or "<no text>")
			end

			size = 18
		end
		fontstring:SetFont(file, size, flag)
	end

	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		local _, size = bar.text:GetFont()
		bar.text:SetFont(file, size, flag)
	end
end

------------------------------------------------------------------------

do
	local function SetReverseFill(self, reverse)
		self.__reverse = reverse
	end

	local function SetTexCoord(self, v)
		local mn, mx = self:GetMinMaxValues()
		if v > 0 and v > mn and v <= mx then
			local pct = (v - mn) / (mx - mn)
			if self.__reverse then
				self.tex:SetTexCoord(1 - pct, 1, 0, 1)
			else
				self.tex:SetTexCoord(0, pct, 0, 1)
			end
		end
	end

	function ns.CreateStatusBar(parent, size, justify)
		local sb = CreateFrame("StatusBar", nil, parent)
		sb:SetStatusBarTexture(ns.config.statusbar)

		sb.tex = sb:GetStatusBarTexture()
		sb.tex:SetDrawLayer("BORDER")
		sb.tex:SetHorizTile(false)
		sb.tex:SetVertTile(false)
		hooksecurefunc(sb, "SetReverseFill", SetReverseFill)
		hooksecurefunc(sb, "SetValue", SetTexCoord)

		sb.bg = sb:CreateTexture(nil, "BACKGROUND")
		sb.bg:SetTexture(ns.config.statusbar)
		sb.bg:SetAllPoints(true)

		if size then
			sb.value = ns.CreateFontString(sb, size, justify)
		end

		tinsert(ns.statusbars, sb)
		return sb
	end
end

function ns.SetAllStatusBarTextures(file)
	if not file then
		file = ns.config.statusbar
	end

	for i = 1, #ns.statusbars do
		local sb = ns.statusbars[i]
		if sb.SetStatusBarTexture then
			sb:SetStatusBarTexture(file)
		else
			sb:SetTexture(file)
		end
		if sb.bg then
			sb.bg:SetTexture(file)
		end
	end

	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		bar.bar:SetStatusBarTexture(file)
		bar.bg:SetTexture(file)
	end
end