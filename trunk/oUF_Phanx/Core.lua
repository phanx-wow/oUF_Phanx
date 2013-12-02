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
ns.statsubarList = {}

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

	-- Global settings:
	oUFPhanxConfig = PoUFDB or oUFPhanxConfig or {} -- upgrade old settings
	for k, v in pairs(ns.defaultDB) do
		if type(oUFPhanxConfig[k]) ~= type(v) then
			oUFPhanxConfig[k] = v
		end
	end
	ns.config = oUFPhanxConfig

	-- Aura settings stored per character:
	oUFPhanxAuraConfig = oUFPhanxAuraConfig or {}
	ns.UpdateAuraList()

	local SharedMedia = LibStub("LibSharedMedia-3.0", true)
	if SharedMedia then
		SharedMedia:Register("font", "PT Sans Bold", [[Interface\AddOns\oUF_Phanx\media\PTSans-Bold.ttf]])

		SharedMedia:Register("statusbar", "Flat", [[Interface\BUTTONS\WHITE8X8]])
		SharedMedia:Register("statusbar", "Neal", [[Interface\AddOns\oUF_Phanx\media\Neal]])

		for i, v in pairs(SharedMedia:List("font")) do
			tinsert(ns.fontList, v)
		end
		table.sort(ns.fontList)

		for i, v in pairs(SharedMedia:List("statusbar")) do
			tinsert(ns.statusbarList, v)
		end
		table.sort(ns.statusbarList)

		SharedMedia.RegisterCallback("oUF_Phanx", "LibSharedMedia_Registered", function(callback, mediaType, name)
			if mediaType == "font" then
				wipe(ns.fontList)
				for i, v in pairs(SharedMedia:List("font")) do
					tinsert(ns.fontList, v)
				end
				table.sort(ns.fontList)
			elseif mediaType == "statusbar" then
				wipe(ns.statusbarList)
				for i, v in pairs(SharedMedia:List("statusbar")) do
					tinsert(ns.statusbarList, v)
				end
				table.sort(ns.statusbarList)
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

	for i, f in ipairs(ns.loadFuncs) do f() end
	ns.loadFuncs = nil

	self:UnregisterEvent(event)
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	if not UnitAffectingCombat("player") then
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
	end
end

function Loader:PLAYER_REGEN_DISABLED(event)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
end

function Loader:PLAYER_REGEN_ENABLED(event)
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
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

	for _, v in ipairs(ns.fontstrings) do
		local _, size, flag = v:GetFont()
		v:SetFont(file, size or 18, flag)
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