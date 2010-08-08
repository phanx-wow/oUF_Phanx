--[[--------------------------------------------------------------------
	oUF_Phanx
	An oUF layout.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Phanx. See README file for license terms.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
----------------------------------------------------------------------]]

local _, ns = ...

------------------------------------------------------------------------
--	General
------------------------------------------------------------------------

ns.config = {
	font = [[Interface\AddOns\oUF_Phanx\media\Expressway.ttf]],
	fontOutline = "OUTLINE",

	statusbar = [[Interface\AddOns\oUF_Phanx\media\Neal]],

	backdrop = { bgFile = [[Interface\BUTTONS\WHITE8X8]] },
	backdropColor = { 32/256, 32/256, 32/256, 1 },

	borderColor = { 0.2, 0.2, 0.2 },
	borderSize = 15,

	width = 225,
	height = 30,
	powerHeight = 1/5,

	dispellableDebuffsOnly = true,
	-- only highlight the frame for debuffs you can dispel

	threatLevels = true,
	-- show threat levels instead of binary aggro

	spellCostPercent = true,
	-- modify spell tooltips to show mana cost as a percent
}

------------------------------------------------------------------------
--	Units
------------------------------------------------------------------------

ns.uconfig = {
	player = {
		point = "TOPRIGHT UIParent CENTER -100 -200",
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
		point = "LEFT player RIGHT 200 0",
		power = true,
		castbar = true,
	},
	targettarget = {
		point = "LEFT target RIGHT 10 0",
		width = 0.5,
	},
	focus = {
		point = "TOPLEFT target BOTTOMLEFT 0 -30",
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
		visibility = "party",
	},
	partypet = {
		width = 0.25,
	},
}

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

oUF.colors.castbar = {
	friend = { 0.2, 0.6, 0.2 },
	enemy = { 0.6, 0.2, 0.2 },
	shield = { 0.6, 0.5, 0 },
}

oUF.colors.debuff = { }
for type, color in pairs(DebuffTypeColor) do
	if type ~= "none" then
		oUF.colors.debuff[type] = { color.r, color.g, color.b }
	end
end

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
	end
end
