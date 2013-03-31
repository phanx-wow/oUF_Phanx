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
Loader:SetScript("OnEvent", function(self, event, addon)
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

function ns.si(value, raw)
	local absvalue = abs(value)

	local str, val

	if absvalue >= 10000000 then
		str, val = "%.1fm", value / 1000000
	elseif absvalue >= 1000000 then
		str, val = "%.2fm", value / 1000000
	elseif absvalue >= 100000 then
		str, val = "%.0fk", value / 1000
	elseif absvalue >= 1000 then
		str, val = "%.1fk", value / 1000
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
		local _, size = v:GetFont()
		v:SetFont(file, size, flag)
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