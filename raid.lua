------------------------------------------------------------------------

local db = {
	locked = false,

	width = 50,
	height = 40,
	spacing = 4,

	tooltip = "nocombat", -- Options: "always", "never", "nocombat"
	
	layout = "class", -- Options: "class", "group"
	pets = true,
}

db.indicator = {
	["frame-alpha"] = {
		status = {
			"offline",
			"vehicle",
			"range",
			"healing-prevented",
		},
	},
	["frame-border"] = {
		size = 3,
		texture = "Interface\\AddOns\\oUF_Phanx\\media\\borderTexture",
		status = {
			"debuffType-Curse",
			"debuffType-Disease",
			"debuffType-Magic",
			"debuffType-Poison",
			"threat",
			"target",
			"mana-low",
		},
	},
	["bar"] = {
		texture = "Interface\\AddOns\\SharedMedia\\statusbar\\Neal",
	},
	["bar-color"] = {
		status = {
			"offline",
			"debuff-Ghost",
			"dead",
			"charmed",
			"healing-prevented",
			"class",
		},
	},
	["bar-overlay"] = {
		texture = "Interface\\AddOns\\SharedMedia\\statusbar\\Neal",
		status = {
			"healing-incoming",
		},
	},
	["text-center"] = {
		font = "Fonts\\FRIZQT__.ttf",
		size = 16,
		outline = "OUTLINE",
		shadow = false,
		status = {
			"offline",
			"resurrection",
			"feign-death",
			"ghost",
			"dead",
			"health-deficit",
			"name",
		},
	},
	["icon-center"] = {
		size = 20,
		border = 2,
		showDuration = false,
		showStacks = false,
		status = {
			"debuff-Frost Blast",
			"buff-" .. GetSpellInfo(1459),	-- Arcane Intellect
			"buff-" .. GetSpellInfo(20217),	-- Blessing of Kings
			"buff-" .. GetSpellInfo(1126),	-- Mark of the Wild
			"buff-" .. GetSpellInfo(1243),	-- Power Word: Fortitude
		},
	},
	["square-top-left"] = {
		size = 10,
		status = {
			"buff-" .. GetSpellInfo(139),		-- Renew
			"buff-" .. GetSpellInfo(33763),	-- Lifebloom
			"buff-" .. GetSpellInfo(8936),	-- Regrowth
			"buff-" .. GetSpellInfo(774),		-- Rejuvenation
			"buff-" .. GetSpellInfo(48438),	-- Wild Growth
			"buff-" .. GetSpellInfo(55428),	-- Lifeblood
			"buff-" .. GetSpellInfo(59547),	-- Gift of the Naaru
		},
	},
	["square-top-right"] = {
		size = 10,
		status = {
			"buff-" .. GetSpellInfo(17),		-- Power Word: Shield
			"buff-" .. GetSpellInfo(41635),	-- Prayer of Mending
			"buff-" .. GetSpellInfo(47753),	-- Divine Aegis
			"buff-" .. GetSpellInfo(48504),	-- Living Seed
		},
	},
	["square-bottom-left"] = {
		size = 10,
		status = {
			"buff-" .. ,	-- Riptide
			"buff-" .. GetSpellInfo(51945),	-- Earthliving
		},
	},
	["square-bottom-right"] = {
		size = 10,
		status = {
			"healing-reduced",
			"buff-" .. GetSpellInfo(974),		-- Earth Shield
		},
	},
}

db.status = {
	["buff"] = {
		--
		-- Static buffs
		--
		[GetSpellInfo(1459)] = { -- Arcane Intellect
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = true,
			includes = {
				[GetSpellInfo(23028)] = true, -- Arcane Brilliance
				[GetSpellInfo(61316)] = true, -- Dalaran Brilliance
			},
			class = {
				MAGE = true,
			},
		},
		[GetSpellInfo(20217)] = { -- Blessing of Kings
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = true,
			includes = {
				[GetSpellInfo(25898)] = true, -- Greater Blessing of Kings
				[GetSpellInfo(19740)] = true, -- Blessing of Might
				[GetSpellInfo(25782)] = true, -- Greater Blessing of Might
				[GetSpellInfo(20911)] = true, -- Blessing of Sanctuary
				[GetSpellInfo(25899)] = true, -- Greater Blessing of Sanctuary
				[GetSpellInfo(19742)] = true, -- Blessing of Wisdom
				[GetSpellInfo(25894)] = true, -- Greater Blessing of Wisdom
			},
			class = {
				PALADIN = true,
			},
		},
		[GetSpellInfo(1126)] = { -- Mark of the Wild
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = true,
			includes = {
				[GetSpellInfo(21849)] = true, -- Gift of the Wild
			},
			class = {
				DRUID = true,
			},
		},
		[GetSpellInfo(1243)] = { -- Power Word: Fortitude
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = true,
			includes = {
				[GetSpellInfo(21562)] = true, -- Prayer of Fortitude
			},
			class = {
				PRIEST = true,
			},
		},
		--
		-- Periodic heals
		--
		[GetSpellInfo(51945)] = { -- Earthliving
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(59547)] = { -- Gift of the Naaru
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(55428)] = { -- Lifeblood
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(33763)] = { -- Lifebloom
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(8936)] = { -- Regrowth
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(774)] = { -- Rejuvenation
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(139)] = { -- Renew
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(61295)] = { -- Riptide
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(48438)] = { -- Wild Growth
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		--
		-- Reactive heals
		--
		[GetSpellInfo(974)] = { -- Earth Shield
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(48504)] = { -- Living Seed
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(41635)] = { -- Prayer of Mending
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		--
		-- Absorption shields
		--
		[GetSpellInfo(47753)] = { -- Divine Aegis
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(17)] = { -- Power Word: Shield
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		--
		-- Miscellaneous
		--
		[GetSpellInfo(53563)] = { -- Beacon of Light
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(1022)] = { -- Hand of Protection
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
		[GetSpellInfo(6940)] = { -- Hand of Sacrifice
			alpha = 1,
			color = { 1, 1, 1 },
			mine = false,
			missing = false,
		},
	},
	["debuff"] = {
		[GetSpellInfo()] = { -- Feign Death
			alpha = 1,
			color = { 1, 0, 0 },
		},
		[GetSpellInfo()] = { -- Forbearance
			alpha = 1,
			color = { 1, 0, 0 },
			class = {
				PALADIN = true,
			},
		},
		[GetSpellInfo()] = { -- Ghost
			alpha = 1,
			color = { 1, 0, 0 },
		},
		[GetSpellInfo()] = { -- Weakened Soul
			alpha = 1,
			color = { 1, 0, 0 },
			class = {
				PRIEST = true,
			},
		},
	},
	["debuffType-Curse"] = {
		alpha = 1,
		color = { 1, 1, 1 },
		showDispelIcon = true,
		class = {
			DRUID = true,
			MAGE = true,
			SHAMAN = true,
		},
	},
	["debuffType-Disease"] = {
		alpha = 1,
		color = { 1, 1, 1 },
		showDispelIcon = true,
		class = {
			PALADIN = true,
			PRIEST = true,
			SHAMAN = true,
		},
	},
	["debuffType-Magic"] = {
		alpha = 1,
		color = { 1, 1, 1 },
		showDispelIcon = true,
		class = {
			PALADIN = true,
			PRIEST = true,
		},
	},
	["debuffType-Poison"] = {
		alpha = 1,
		color = { 1, 1, 1 },
		showDispelIcon = true,
		class = {
			DRUID = true,
			PALADIN = true,
			SHAMAN = true,
		},
	},
	["charmed"] = {
		alpha = 1,
		color = { 1, 0, 0 },
		showGenericIcon = true,
	},
	["dead"] = {
		alpha = 1,
		color = { 1, 1, 1 },
	},
	["health-deficit"] = {
		alpha = 1,
		color = { 1, 1, 1 },
		threshold = 0.8,
	},
	["healing-incoming"] = {
		alpha = 1,
		color = { 1, 1, 1 },
	},
	["healing-prevented"] = {
		alpha = 1,
		color = { 1, 1, 1 },
	},
	["healing-reduced"] = {
		alpha = 1,
		color = { 1, 1, 1 },
	},
	["mana-low"] = {
		alpha = 1,
		color = { 1, 1, 1 },
		threshold = 0.3,
		class = {
			DRUID = true,
			PRIEST = true,
			SHAMAN = true,
		},
	},
	["offline"] = {
		alpha = 1,
		color = { 1, 1, 1 },
	},
	["range"] = {
		alpha = 1,
		color = { 1, 1, 1 },
		interval = 0.2,
	},
	["target"] = {
		alpha = 1,
		color = { 1, 1, 1 },
	},
	["threat"] = {
		alpha = 1,
		color = { 1, 1, 1 },
		showLevels = false,
	},
	["vehicle"] = {
		alpha = 1,
		color = { 1, 1, 1 },
	},
}

-- Reorder these as you prefer, using 1, 2, 3, and 4. Debuffs your class
-- can dispel are automatically prioritized over others, so don't worry
-- about that.
local DispelPriority = {
	Curse = 2,
	Disease = 4,
	Magic = 1,
	Poison = 3,
}

-- If for some reason you want to change this, leave the insets alone.
local backdrop = {
	bgFile = "Interface\\Addons\\Grid\\white16x16", tile = true, tileSize = 16,
	edgeFile = "Interface\\Addons\\Grid\\white16x16", edgeSize = 3,
	insets = { left = 0, right = 0, top = 0, bottom = 0 },
},

------------------------------------------------------------------------

assert(oUF, "oUF_Phanx is just a layout. You need the base oUF addon too!")

local function debug(str, ...)
	if select(1, ...) then str = str:format(...) end
	print("|cffff3333oUF_Phanx:|r " .. str)
end

local colors = oUF.colors

--[[--------------------------------------------------------------------
	AbbreviateValue
	arguments:
		value (number)
	returns:
		value (string) - nicely formatted value for display
----------------------------------------------------------------------]]

local function AbbreviateValue(value)
	if value >= 10000000 then
		return string.format("%.1fm", value / 1000000)
	elseif value >= 1000000 then
		return string.format("%.2fm", value / 1000000)
	elseif value >= 100000 then
		return string.format("%.0fk", value / 1000)
	elseif value >= 10000 then
		return string.format("%.1fk", value / 1000)
	else
		return value
	end
end

------------------------------------------------------------------------

local function UpdateBorder()
end

local function UpdateCorners()
end

------------------------------------------------------------------------

local function UpdateHealth(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	--debug("UpdateHealth: %s, %s", event, unit)

	local r, g, b
	if not UnitIsConnected(unit) then
		bar:SetValue(max)
		bar.value:SetText(strings.offline)
		r, g, b = unpack(colors.offline)
	elseif UnitIsDeadOrGhost(unit) then
		bar:SetValue(max)
		if UnitIsGhost(unit) then
			bar.value:SetText(strings.ghost)
			r, g, b = unpack(colors.ghost)
		else
			bar.value:SetText(strings.dead)
			r, g, b = unpack(colors.dead)
		end
	else
		bar:SetValue(max - min)
		bar.value:SetFormattedText("-%s", AbbreviateValue(UnitHealthMax(unit) - UnitHealth(unit)))

		local _, class = UnitClass(unit)
		r, g, b = unpack(colors.class[class])
	end

	bar.value:SetTextColor(r, g, b)

	bar:SetStatusBarColor(r * .2, g * .2, b * .2)
	bar.bg:SetVertexColor(r, g, b)
end

------------------------------------------------------------------------

local function UpdatePower(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	--debug("UpdatePower: %s, %s", event, unit)

	if UnitPowerType(unit) > 0 then return end

	if UnitMana(unit) / UnitManaMax(unit) <= status["low-mana"].threshold then
		if not statusActiveForUnit[unit]["low-mana"] then
			UpdateIndicatorsForStatus("low-mana", unit)
		end
	end
end

------------------------------------------------------------------------

local function UpdateAuraIcon(self, button, icons, index, isDebuff)
end

------------------------------------------------------------------------

local function UpdateThreat(self, event, unit)
end

------------------------------------------------------------------------

local function menu(self)
end

local function Spawn(self, unit)
end

------------------------------------------------------------------------

oUF:RegisterStyle("PhanxRaid", Spawn)

local pets = oUF:Spawn("header", "oUF_RaidPet", "SecurePetHeaderTemplate")
pets:SetPoint("TOPRIGHT", UIParent, "RIGHT", -20, -5 * settings.height)
pets:SetManyAttributes(
	"showRaid", true,
	"groupBy", "CLASS",
	"groupFilter", "1,2,3,4,5",
	"groupingOrder", "HUNTER,WARLOCK,DEATHKNIGHT,MAGE,SHAMAN,DRUID,PRIEST,WARRIOR,ROGUE,PALADIN",
	"maxColumns", 5,
	"unitsPerColumn", 5,
	"xOffset", -10,
	"yOffset", -10,
)
pets:Show()

local raid = oUF:Spawn("header", "oUF_Raid")
raid:SetPoint("TOPRIGHT", pets, "TOPLEFT", -10, 0)
raid:SetManyAttributes(
	"showRaid", true,
	"groupBy", "CLASS",
	"groupFilter", "1,2,3,4,5",
	"groupingOrder", "WARRIOR,DEATHKNIGHT,ROGUE,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER",
	"maxColumns", 5,
	"unitsPerColumn", 5,
	"xOffset", -10,
	"yOffset", -10,
)
raid:Show()

------------------------------------------------------------------------