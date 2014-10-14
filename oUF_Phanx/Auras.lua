--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Filter settings stored as bitfields.
	0x MODE SOURCE DEST ROLE 0 CLASSx3
	See below for related constants. Class takes up 3 bits, and has
	an empty bit in front of it in case Blizzard adds more classes.
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")

local bit_band, bit_bor = bit.band, bit.bor

------------------------------------------------------------------------

-- Permanent filters, only checked on login, role change, options change:
local FILTER_ALL               = 0x10000000
local FILTER_DISABLE           = 0x20000000
local FILTER_PVP               = 0x30000000
local FILTER_PVE               = 0x40000000

local FILTER_ROLE_TANK         = 0x00010000
local FILTER_ROLE_HEALER       = 0x00020000
local FILTER_ROLE_DAMAGER      = 0x00040000
local FILTER_ROLE_MASK         = 0x000F0000

local FILTER_CLASS_MASK        = 0x00000FFF
local FILTER_CLASS_WARRIOR     = 0x00000001
local FILTER_CLASS_PALADIN     = 0x00000002
local FILTER_CLASS_HUNTER      = 0x00000004
local FILTER_CLASS_ROGUE       = 0x00000008
local FILTER_CLASS_PRIEST      = 0x00000010
local FILTER_CLASS_DEATHKNIGHT = 0x00000020
local FILTER_CLASS_SHAMAN      = 0x00000040
local FILTER_CLASS_MAGE        = 0x00000080
local FILTER_CLASS_WARLOCK     = 0x00000100
local FILTER_CLASS_MONK        = 0x00000200
local FILTER_CLASS_DRUID       = 0x00000400

-- Temporary filters, checked in realtime:
local FILTER_BY_PLAYER         = 0x01000000
local FILTER_BY_MASK           = 0x0F000000

local FILTER_ON_PLAYER         = 0x00100000
local FILTER_ON_OTHER          = 0x00200000
local FILTER_ON_FRIEND         = 0x00400000
local FILTER_ON_ENEMY          = 0x00800000
local FILTER_ON_MASK           = 0x00F00000

ns.auraFilterValues = {
	ALL               = FILTER_ALL,
	DISABLE           = FILTER_DISABLE,
	PVP               = FILTER_PVP,
	PVE               = FILTER_PVE,

	BY_PLAYER         = FILTER_BY_PLAYER,
	BY_MASK           = FILTER_BY_MASK,

	ON_PLAYER         = FILTER_ON_PLAYER,
	ON_OTHER          = FILTER_ON_OTHER,
	ON_FRIEND         = FILTER_ON_FRIEND,
	ON_ENEMY          = FILTER_ON_ENEMY,
	ON_MASK           = FILTER_ON_MASK,

	ROLE_TANK         = FILTER_ROLE_TANK,
	ROLE_HEALER       = FILTER_ROLE_HEALER,
	ROLE_DAMAGER      = FILTER_ROLE_DAMAGER,
	ROLE_MASK         = FILTER_ROLE_MASK,

	CLASS_MASK        = FILTER_CLASS_MASK,
	CLASS_WARRIOR     = FILTER_CLASS_WARRIOR,
	CLASS_PALADIN     = FILTER_CLASS_PALADIN,
	CLASS_HUNTER      = FILTER_CLASS_HUNTER,
	CLASS_ROGUE       = FILTER_CLASS_ROGUE,
	CLASS_PRIEST      = FILTER_CLASS_PRIEST,
	CLASS_DEATHKNIGHT = FILTER_CLASS_DEATHKNIGHT,
	CLASS_SHAMAN      = FILTER_CLASS_SHAMAN,
	CLASS_MAGE        = FILTER_CLASS_MAGE,
	CLASS_WARLOCK     = FILTER_CLASS_WARLOCK,
	CLASS_MONK        = FILTER_CLASS_MONK,
	CLASS_DRUID       = FILTER_CLASS_DRUID,
}

local classFilter = {
	WARRIOR     = FILTER_CLASS_WARRIOR,
	PALADIN     = FILTER_CLASS_PALADIN,
	HUNTER      = FILTER_CLASS_HUNTER,
	ROGUE       = FILTER_CLASS_ROGUE,
	PRIEST      = FILTER_CLASS_PRIEST,
	DEATHKNIGHT = FILTER_CLASS_DEATHKNIGHT,
	SHAMAN      = FILTER_CLASS_SHAMAN,
	MAGE        = FILTER_CLASS_MAGE,
	WARLOCK     = FILTER_CLASS_WARLOCK,
	MONK        = FILTER_CLASS_MONK,
	DRUID       = FILTER_CLASS_DRUID,
}

local roleFilter = {
	TANK    = FILTER_ROLE_TANK,
	HEALER  = FILTER_ROLE_HEALER,
	DAMAGER = FILTER_ROLE_DAMAGER,
}

------------------------------------------------------------------------

local defaultAuras = {
	[1022]   = FILTER_ON_PLAYER, -- Hand of Protection
	[29166]  = FILTER_ON_PLAYER, -- Innervate
	[102342] = FILTER_ON_PLAYER, -- Ironbark
	[33206]  = FILTER_ON_PLAYER, -- Pain Suppression
	[10060]  = FILTER_ON_PLAYER, -- Power Infusion
	[49016]  = FILTER_ON_PLAYER, -- Unholy Frenzy

	-- Bloodlust
	[90355]  = FILTER_ON_PLAYER, -- Ancient Hysteria (core hound)
	[2825]   = FILTER_ON_PLAYER, -- Bloodlust (shaman)
	[32182]  = FILTER_ON_PLAYER, -- Heroism (shaman)
	[80353]  = FILTER_ON_PLAYER, -- Time Warp (mage)

	-- Herbalism
	[81708]  = FILTER_BY_PLAYER, -- Lifeblood (Rank 1)
	[55428]  = FILTER_BY_PLAYER, -- Lifeblood (Rank 2)
	[55480]  = FILTER_BY_PLAYER, -- Lifeblood (Rank 3)
	[55500]  = FILTER_BY_PLAYER, -- Lifeblood (Rank 4)
	[55501]  = FILTER_BY_PLAYER, -- Lifeblood (Rank 5)
	[55502]  = FILTER_BY_PLAYER, -- Lifeblood (Rank 6)
	[55503]  = FILTER_BY_PLAYER, -- Lifeblood (Rank 7)
	[74497]  = FILTER_BY_PLAYER, -- Lifeblood (Rank 8)
	[121279] = FILTER_BY_PLAYER, -- Lifeblood (Rank 9)

	-- Crowd Control
	[710]    = FILTER_ALL, -- Banish
	[76780]  = FILTER_ALL, -- Bind Elemental
	[33786]  = FILTER_ALL, -- Cyclone
	[339]    = FILTER_ALL, -- Entangling Roots
	[5782]   = FILTER_ALL, -- Fear -- NEEDS CHECK
	[118699] = FILTER_ALL, -- Fear
	[3355]   = FILTER_ALL, -- Freezing Trap, -- NEEDS CHECK
	[43448]  = FILTER_ALL, -- Freezing Trap, -- NEEDS CHECK
	[51514]  = FILTER_ALL, -- Hex
	[2637]   = FILTER_ALL, -- Hibernate
	[118]    = FILTER_ALL, -- Polymorph
	[61305]  = FILTER_ALL, -- Polymorph [Black Cat]
	[28272]  = FILTER_ALL, -- Polymorph [Pig]
	[61721]  = FILTER_ALL, -- Polymorph [Rabbit]
	[61780]  = FILTER_ALL, -- Polymorph [Turkey]
	[28271]  = FILTER_ALL, -- Polymorph [Turtle]
	[20066]  = FILTER_ALL, -- Repentance
	[6770]   = FILTER_ALL, -- Sap
	[6358]   = FILTER_ALL, -- Seduction
	[9484]   = FILTER_ALL, -- Shackle Undead
	[10326]  = FILTER_ALL, -- Turn Evil
	[114404] = FILTER_ALL, -- Void Tendrils
	[19386]  = FILTER_ALL, -- Wyvern Sting
}

ns.defaultAuras = defaultAuras

------------------------------------------------------------------------
-- Death Knight

do
	local SELF   = bit_bor(FILTER_CLASS_DEATHKNIGHT, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_DEATHKNIGHT, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_DEATHKNIGHT, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_DEATHKNIGHT, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[48707]  = SELF -- Anti-Magic Shell
	defaultAuras[49222]  = SELF -- Bone Shield
	defaultAuras[53386]  = SELF -- Cinderglacier
	defaultAuras[119975] = SELF -- Conversion
	defaultAuras[101568] = SELF -- Dark Succor <-- glyph
	defaultAuras[96268]  = SELF -- Death's Advance
	defaultAuras[59052]  = SELF -- Freezing Fog <-- Rime
	defaultAuras[48792]  = SELF -- Icebound Fortitude
	defaultAuras[51124]  = SELF -- Killing Machine
	defaultAuras[49039]  = SELF -- Lichborne
	defaultAuras[51271]  = SELF -- Pillar of Frost
	defaultAuras[46584]  = SELF -- Raise Dead
	defaultAuras[108200] = SELF -- Remorseless Winter
	defaultAuras[51460]  = SELF -- Runic Corruption
	defaultAuras[50421]  = SELF -- Scent of Blood
	defaultAuras[116888] = SELF -- Shroud of Purgatory
	defaultAuras[8134]   = SELF -- Soul Reaper
	defaultAuras[81340]  = SELF -- Sudden Doom
	defaultAuras[115989] = SELF -- Unholy Blight
--	defaultAuras[53365]  = SELF -- Unholy Strength <-- Rune of the Fallen Crusader
	defaultAuras[55233]  = SELF -- Vampiric Blood
	defaultAuras[81162]  = SELF -- Will of the Necropolis (damage reduction)
	defaultAuras[96171]  = SELF -- Will of the Necropolis (free Rune Tap)

	-- Pet Buffs
	defaultAuras[63560]  = MINE -- Dark Transformation

	-- Buffs
	defaultAuras[49016]  = BUFF -- Unholy Frenzy

	-- Debuffs
	defaultAuras[108194] = DEBUFF  -- Asphyxiate
	defaultAuras[55078]  = MINE -- Blood Plague
	defaultAuras[45524]  = DEBUFF  -- Chains of Ice
	--defaultAuras[50435]  = DEBUFF  -- Chilblains
	defaultAuras[111673] = MINE -- Control Undead -- needs check
	defaultAuras[77606]  = MINE -- Dark Simulacrum
	defaultAuras[55095]  = MINE -- Frost Fever
	defaultAuras[51714]  = MINE -- Frost Vulernability <-- Rune of Razorice
	defaultAuras[73975]  = DEBUFF  -- Necrotic Strike
	defaultAuras[115000] = MINE -- Remorseless Winter (slow)
	defaultAuras[115001] = MINE -- Remorseless Winter (stun)
	defaultAuras[114866] = MINE -- Soul Reaper (blood)
	defaultAuras[130735] = MINE -- Soul Reaper (frost)
	defaultAuras[130736] = MINE -- Soul Reaper (unholy)
	defaultAuras[47476]  = DEBUFF  -- Strangulate
end

------------------------------------------------------------------------
-- Druid

do
	local SELF   = bit_bor(FILTER_CLASS_DRUID, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_DRUID, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_DRUID, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_DRUID, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[22812]  = SELF -- Barkskin
	defaultAuras[106951] = SELF -- Berserk (cat)
	defaultAuras[50334]  = SELF -- Berserk (bear)
	defaultAuras[112071] = SELF -- Celestial Alignment
	defaultAuras[16870]  = SELF -- Clearcasting <-- Omen of Clarity
	defaultAuras[1850]   = SELF -- Dash
	defaultAuras[108381] = SELF -- Dream of Cenarius (+damage)
	defaultAuras[108382] = SELF -- Dream of Cenarius (+healing)
	defaultAuras[5229]   = SELF -- Enrage
	defaultAuras[124769] = SELF -- Frenzied Regeneration <-- glyph
	defaultAuras[102560] = SELF -- Incarnation: Chosen of Elune
	defaultAuras[102543] = SELF -- Incarnation: King of the Jungle
	defaultAuras[102558] = SELF -- Incarnation: Son of Ursoc
	defaultAuras[33891]  = SELF -- Incarnation: Tree of Life -- NEEDS CHECK
	defaultAuras[81192]  = SELF -- Lunar Shower
	defaultAuras[106922] = SELF -- Might of Ursoc
	defaultAuras[16689]  = SELF -- Nature's Grasp
	defaultAuras[132158] = SELF -- Nature's Swiftness
	defaultAuras[124974] = SELF -- Nature's Vigil
	defaultAuras[48391]  = SELF -- Owlkin Frenzy
	defaultAuras[69369]  = SELF -- Predator's Swiftness
	defaultAuras[132402] = SELF -- Savage Defense
	defaultAuras[52610]  = SELF -- Savage Roar -- VERIFIED 13/02/20 on tauren feral
	defaultAuras[127538] = SELF -- Savage Roar -- NEEDS CHECK
	defaultAuras[93400]  = SELF -- Shooting Stars
	defaultAuras[114108] = SELF -- Soul of the Forest (resto)
	defaultAuras[48505]  = SELF -- Starfall
	defaultAuras[61336]  = SELF -- Survival Instincts
	defaultAuras[5217]   = SELF -- Tiger's Fury
	defaultAuras[102416] = SELF -- Wild Charge (aquatic)
	-- WOD
	defaultAuras[164547] = SELF -- Lunar Empowerment
	defaultAuras[171743] = SELF -- Lunar Peak
	defaultAuras[164545] = SELF -- Solar Empowerment
	defaultAuras[171744] = SELF -- Solar Peak

	-- Buffs
	defaultAuras[102351] = MINE -- Cenarion Ward (buff)
	defaultAuras[102352] = MINE -- Cenarion Ward (heal)
	defaultAuras[29166]  = BUFF -- Innervate
	defaultAuras[102342] = BUFF -- Ironbark
	defaultAuras[33763]  = MINE -- Lifebloom
	defaultAuras[94447]  = MINE -- Lifebloom (tree)
	defaultAuras[8936]   = MINE -- Regrowth
	defaultAuras[774]    = MINE -- Rejuvenation
	defaultAuras[77761]  = BUFF -- Stampeding Roar (bear)
	defaultAuras[77764]  = BUFF -- Stampeding Roar (cat)
	defaultAuras[106898] = BUFF -- Stampeding Roar (caster)
	defaultAuras[48438]  = MINE -- Wild Growth

	-- Debuffs
	defaultAuras[102795] = DEBUFF  -- Bear Hug
	defaultAuras[33786]  = DEBUFF  -- Cyclone
	defaultAuras[99]     = DEBUFF  -- Disorienting Roar
	defaultAuras[339]    = DEBUFF  -- Entangling Roots
	defaultAuras[114238] = DEBUFF  -- Fae Silence <-- glpyh
	defaultAuras[81281]  = DEBUFF  -- Fungal Growth <-- Wild Mushroom: Detonate
	defaultAuras[2637]   = DEBUFF  -- Hibernate
	defaultAuras[33745]  = MINE -- Lacerate
	defaultAuras[22570]  = DEBUFF  -- Maim
	defaultAuras[5211]   = DEBUFF  -- Mighty Bash
	defaultAuras[8921]   = MINE -- Moonfire
	defaultAuras[9005]   = MINE -- Pounce -- NEEDS CHECK
	defaultAuras[102546] = MINE -- Pounce -- NEEDS CHECK
	defaultAuras[9007]   = MINE -- Pounce Bleed
	defaultAuras[1822]   = MINE -- Rake
	defaultAuras[1079]   = MINE -- Rip
	defaultAuras[106839] = DEBUFF  -- Skull Bash -- NOT CURRENTLY USED
	defaultAuras[78675]  = DEBUFF  -- Solar Beam (silence)
	defaultAuras[97547]  = DEBUFF  -- Solar Beam (interrupt)
	defaultAuras[93402]  = MINE -- Sunfire
	defaultAuras[77758]  = MINE -- Thrash (bear)
	defaultAuras[106830] = MINE -- Thrash (cat)
	defaultAuras[61391]  = DEBUFF  -- Typhoon
	defaultAuras[102793] = DEBUFF  -- Ursol's Vortex
	defaultAuras[45334]  = DEBUFF  -- Immobilize <-- Wild Charge (bear)
	defaultAuras[50259]  = DEBUFF  -- Dazed <-- Wild Charge (cat)

	defaultAuras[770]    = bit_bor(FILTER_CLASS_DRUID, FILTER_PVP) -- Faerie Fire
	defaultAuras[102355] = bit_bor(FILTER_CLASS_DRUID, FILTER_PVP) -- Faerie Swarm
end

------------------------------------------------------------------------
-- Hunter

do
	local SELF   = bit_bor(FILTER_CLASS_HUNTER, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_HUNTER, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_HUNTER, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_HUNTER, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[83559]  = SELF -- Black Ice
	--defaultAuras[82921]  = SELF -- Bombardment
	--defaultAuras[53257]  = SELF -- Cobra Strikes
	defaultAuras[51755]  = SELF -- Camouflage
	defaultAuras[19263]  = SELF -- Deterrence
	defaultAuras[15571]  = SELF -- Dazed <-- Aspect of the Cheetah
	defaultAuras[6197]   = SELF -- Eagle Eye
	defaultAuras[5384]   = SELF -- Feign Death
	defaultAuras[82726]  = SELF -- Fervor
	defaultAuras[82926]  = SELF -- Fire! <-- Master Marksman
	defaultAuras[82692]  = SELF -- Focus Fire
	defaultAuras[56453]  = SELF -- Lock and Load
	defaultAuras[54216]  = SELF -- Master's Call
	defaultAuras[34477]  = SELF -- Misdirection
	defaultAuras[118922] = SELF -- Posthaste
	defaultAuras[3045]   = SELF -- Rapid Fire
	--defaultAuras[82925]  = SELF -- Ready, Set, Aim... <-- Master Marksman
	defaultAuras[53220]  = SELF -- Steady Focus
	defaultAuras[34471]  = SELF -- The Beast Within
	defaultAuras[34720]  = SELF -- Thrill of the Hunt

	-- Pet Buffs
	defaultAuras[19615]  = MINE -- Frenzy
	defaultAuras[19574]  = MINE -- Bestial Wrath
	defaultAuras[136]    = MINE -- Mend Pet

	-- Buffs
	defaultAuras[34477]  = BUFF -- Misdirection (30 sec threat)
	defaultAuras[35079]  = BUFF -- Misdirection (4 sec transfer)

	-- Debuffs
	defaultAuras[131894] = MINE -- defaultAuras Murder of Crows
	defaultAuras[117526] = MINE -- Binding Shot (stun)
	defaultAuras[117405] = MINE -- Binding Shot (tether)
	defaultAuras[3674]   = MINE -- Black Arrow
	defaultAuras[35101]  = MINE -- Concussive Barrage
	defaultAuras[5116]   = MINE -- Concussive Shot
	defaultAuras[20736]  = MINE -- Distracting Shot
	defaultAuras[64803]  = MINE -- Entrapment
	defaultAuras[53301]  = MINE -- Explosive Shot
	defaultAuras[13812]  = MINE -- Explosive Trap
	defaultAuras[43446]  = MINE -- Explosive Trap Effect -- NEEDS CHECK
	defaultAuras[128961] = MINE -- Explosive Trap Effect -- NEEDS CHECK
	defaultAuras[3355]   = MINE -- Freezing Trap
	defaultAuras[61394]  = MINE -- Frozen Wake <-- Glyph of Freezing Trap
	defaultAuras[120761] = MINE -- Glaive Toss -- NEEDS CHECK
	defaultAuras[121414] = MINE -- Glaive Toss -- NEEDS CHECK
	defaultAuras[1130]   = DEBUFF  -- Hunter's Mark
	defaultAuras[135299] = DEBUFF  -- Ice Trap
	defaultAuras[34394]  = MINE -- Intimidation
	defaultAuras[115928] = MINE -- Narrow Escape -- NEEDS CHECK
	defaultAuras[128405] = MINE -- Narrow Escape -- NEEDS CHECK
	--defaultAuras[63468]  = MINE -- Piercing Shots
	defaultAuras[1513]   = MINE -- Scare Beast
	defaultAuras[19503]  = MINE -- Scatter Shot
	defaultAuras[118253] = MINE -- Serpent Sting
	defaultAuras[34490]  = MINE -- Silencing Shot
	defaultAuras[82654]  = MINE -- Widow Venom
	defaultAuras[19386]  = MINE -- Wyvern Sting
end

------------------------------------------------------------------------
-- Mage

do
	local SELF   = bit_bor(FILTER_CLASS_MAGE, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_MAGE, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_MAGE, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_MAGE, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[110909] = SELF -- Alter Time
	defaultAuras[36032]  = SELF -- Arcane Charge
	defaultAuras[12042]  = SELF -- Arcane Power
	defaultAuras[108843] = SELF -- Blazing Speed
	defaultAuras[57761]  = SELF -- Brain Freeze
	defaultAuras[87023]  = SELF -- Cauterize
	defaultAuras[44544]  = SELF -- Fingers of Frost
	defaultAuras[110960] = SELF -- Greater Invisibility
	defaultAuras[48107]  = SELF -- Heating Up
	defaultAuras[11426]  = SELF -- Ice Barrier
	defaultAuras[45438]  = SELF -- Ice Block
	defaultAuras[108839] = SELF -- Ice Floes
	defaultAuras[12472]  = SELF -- Icy Veins
	defaultAuras[116267] = SELF -- Inacnter's Absorption
	defaultAuras[1463]   = SELF -- Inacnter's Ward
	defaultAuras[66]     = SELF -- Invisibility
	defaultAuras[12043]  = SELF -- Presence of Mind
	defaultAuras[116014] = SELF -- Rune of Power
	defaultAuras[48108]  = SELF -- Pyroblast!
	defaultAuras[115610] = SELF -- Temporal Shield (shield)
	defaultAuras[115611] = SELF -- Temporal Shield (heal)

	-- Debuffs
	defaultAuras[34356]  = MINE -- Blizzard (slow) -- NEEDS CHECK
	defaultAuras[83853]  = MINE -- Combustion
	defaultAuras[120]    = MINE -- Cone of Cold
	defaultAuras[44572]  = MINE -- Deep Freeze
	defaultAuras[31661]  = MINE -- Dragon's Breath
	defaultAuras[112948] = MINE -- Frost Bomb
	defaultAuras[113092] = MINE -- Frost Bomb (slow)
	defaultAuras[122]    = DEBUFF  -- Frost Nova
	defaultAuras[116]    = MINE -- Frostbolt
	defaultAuras[44614]  = MINE -- Frostfire Bolt
	defaultAuras[102051] = MINE -- Frostjaw
	defaultAuras[84721]  = MINE -- Frozen Orb
	--defaultAuras[12654]  = MINE -- Ignite
	defaultAuras[44457]  = MINE -- Living Bomb
	defaultAuras[114923] = MINE -- Nether Tempest
	--defaultAuras[11366]  = MINE -- Pyroblast
	defaultAuras[132210] = MINE -- Pyromaniac
	defaultAuras[82691]  = MINE -- Ring of Frost
	defaultAuras[55021]  = DEBUFF  -- Silenced - Improved Counterspell
	defaultAuras[31589]  = DEBUFF  -- Slow
end

------------------------------------------------------------------------
-- Monk

do
	local SELF   = bit_bor(FILTER_CLASS_MONK, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_MONK, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_MONK, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_MONK, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[122278] = SELF -- Dampen Harm
	defaultAuras[121125] = SELF -- Death Note
	defaultAuras[122783] = SELF -- Diffuse Magic
	defaultAuras[128939] = SELF -- Elusive Brew (stack)
	defaultAuras[115308] = SELF -- Elusive Brew (consume)
	defaultAuras[115288] = SELF -- Energizing Brew
	defaultAuras[115203] = SELF -- Fortifying Brew
	defaultAuras[115295] = SELF -- Guard
	defaultAuras[123402] = SELF -- Guard (glyphed)
	defaultAuras[124458] = SELF -- Healing Sphere (count)
	defaultAuras[115867] = SELF -- Mana Tea (stack)
	defaultAuras[119085] = SELF -- Momentum
	defaultAuras[124968] = SELF -- Retreat
	defaultAuras[127722] = SELF -- Serpent's Zeal
	defaultAuras[125359] = SELF -- Tiger Power
	defaultAuras[116841] = SELF -- Tiger's Lust
	defaultAuras[125195] = SELF -- Tigereye Brew (stack)
	defaultAuras[116740] = SELF -- Tigereye Brew (consume)
	defaultAuras[122470] = SELF -- Touch of Karma
	defaultAuras[118674] = SELF -- Vital Mists

	-- Buffs
	defaultAuras[132120] = MINE -- Enveloping Mist
	defaultAuras[116849] = BUFF -- Life Cocoon
	defaultAuras[119607] = MINE -- Renewing Mist (jump)
	defaultAuras[119611] = MINE -- Renewing Mist (hot)
	defaultAuras[124081] = MINE -- Zen Sphere

	-- Debuffs
	defaultAuras[123393] = MINE -- Breath of Fire (disorient)
	defaultAuras[123725] = MINE -- Breath of Fire (dot)
	defaultAuras[119392] = MINE -- Charging Ox Wave
	defaultAuras[122242] = MINE -- Clash (stun) -- NEEDS CHECK
	defaultAuras[126451] = MINE -- Clash (stun) -- NEEDS CHECK
	defaultAuras[128846] = MINE -- Clash (stun) -- NEEDS CHECK
	defaultAuras[116095] = MINE -- Disable
	defaultAuras[116330] = MINE -- Dizzying Haze -- NEEDS CHECK
	defaultAuras[123727] = MINE -- Dizzying Haze -- NEEDS CHECK
	defaultAuras[117368] = MINE -- Grapple Weapon
	defaultAuras[118585] = MINE -- Leer of the Ox
	defaultAuras[119381] = MINE -- Leg Sweep
	defaultAuras[115078] = MINE -- Paralysis
	defaultAuras[118635] = MINE -- Provoke -- NEEDS CHECK
	defaultAuras[116189] = MINE -- Provoke -- NEEDS CHECK
	defaultAuras[130320] = MINE -- Rising Sun Kick
	defaultAuras[116847] = MINE -- Rushing Jade Wind
	defaultAuras[116709] = MINE -- Spear Hand Strike
	defaultAuras[123407] = MINE -- Spinning Fire Blossom
end

------------------------------------------------------------------------
-- Paladin

do
	local SELF   = bit_bor(FILTER_CLASS_PALADIN, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_PALADIN, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_PALADIN, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_PALADIN, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[121467] = SELF -- Alabaster Shield
	defaultAuras[31850]  = SELF -- Ardent Defender
	defaultAuras[31884]  = SELF -- Avenging Wrath
	defaultAuras[114637] = SELF -- Bastion of Glory
	defaultAuras[88819]  = SELF -- Daybreak
	defaultAuras[31842]  = SELF -- Divine Favor
	defaultAuras[54428]  = SELF -- Divine Plea
	defaultAuras[498]    = SELF -- Divine Protection
	defaultAuras[90174]  = SELF -- Divine Purpose
	defaultAuras[642]    = SELF -- Divine Shield
	defaultAuras[54957]  = SELF -- Glyph of Flash of Light
	defaultAuras[85416]  = SELF -- Grand Crusader
	defaultAuras[86659]  = SELF -- Guardian of Ancient Kings (protection)
	defaultAuras[86669]  = SELF -- Guardian of Ancient Kings (holy)
	defaultAuras[86698]  = SELF -- Guardian of Ancient Kings (retribution)
	defaultAuras[105809] = SELF -- Holy Avenger
	defaultAuras[54149]  = SELF -- Infusion of Light
	defaultAuras[84963]  = SELF -- Inquisition
	defaultAuras[114250] = SELF -- Selfless Healer
	--defaultAuras[132403] = SELF -- Shield of the Righteous
	defaultAuras[85499]  = SELF -- Speed of Light
	defaultAuras[94686]  = SELF -- Supplication

	-- Buffs
	defaultAuras[53563]  = BUFF -- Beacon of Light
	defaultAuras[31821]  = BUFF -- Devotion Aura
	defaultAuras[114163] = BUFF -- Eternal Flame
	defaultAuras[1044]   = BUFF -- Hand of Freedom
	defaultAuras[1022]   = BUFF -- Hand of Protection
	defaultAuras[114039] = BUFF -- Hand of Purity
	defaultAuras[6940]   = BUFF -- Hand of Sacrifice
	defaultAuras[1038]   = BUFF -- Hand of Salvation
	defaultAuras[86273]  = BUFF -- Illuminated Healing
	defaultAuras[20925]  = BUFF -- Sacred Shield
	defaultAuras[20170]  = BUFF -- Seal of Justice
	defaultAuras[114917] = BUFF -- Stay of Execution

	-- Buff Debuffs
	defaultAuras[25771]  = BUFF -- Forbearace

	-- Debuffs
	defaultAuras[31935]  = MINE -- Avenger's Shield
	--defaultAuras[110300] = MINE -- Burden of Guilt
	defaultAuras[105421] = MINE -- Blinding Light
	defaultAuras[31803]  = MINE -- Censure
	defaultAuras[63529]  = MINE -- Dazed - Avenger's Shield
	defaultAuras[2812]   = MINE -- Denounce
	defaultAuras[114916] = MINE -- Execution Sentence
	defaultAuras[105593] = MINE -- Fist of Justice
	defaultAuras[853]    = MINE -- Hammer of Justice
	defaultAuras[119072] = MINE -- Holy Wrath
	defaultAuras[20066]  = MINE -- Repentance
	defaultAuras[10326]  = MINE -- Turn Evil
end

------------------------------------------------------------------------
-- Priest

do
	local SELF   = bit_bor(FILTER_CLASS_PRIEST, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_PRIEST, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_PRIEST, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_PRIEST, FILTER_BY_PLAYER)

	-- Self Buffs
	--defaultAuras[114214] = SELF -- Angelic Bulwark
	defaultAuras[81700]  = SELF -- Archangel
	--defaultAuras[59889]  = SELF -- Borrowed Time
	defaultAuras[47585]  = SELF -- Dispersion
	defaultAuras[123266] = SELF -- Divine Insight (discipline)
	defaultAuras[123267] = SELF -- Divine Insight (holy)
	defaultAuras[124430] = SELF -- Divine Insight (shadow)
	defaultAuras[81661]  = SELF -- Evangelism
	defaultAuras[586]    = SELF -- Fade
	defaultAuras[2096]   = SELF -- Mind Vision
	defaultAuras[114239] = SELF -- Phantasm
	defaultAuras[10060]  = SELF -- Power Infusion
	defaultAuras[63735]  = SELF -- Serendipity
	defaultAuras[112833] = SELF -- Spectral Guise
	defaultAuras[109964] = SELF -- Spirit Shell (self)
	defaultAuras[87160]  = SELF -- Surge of Darkness
	defaultAuras[114255] = SELF -- Surge of Light
	defaultAuras[123254] = SELF -- Twist of Fate
	defaultAuras[15286]  = SELF -- Vampiric Embrace

	-- Buffs
	defaultAuras[47753]  = BUFF -- Divine Aegis
	defaultAuras[77613]  = MINE -- Grace
	defaultAuras[47788]  = BUFF -- Guardian Spirit
	defaultAuras[88684]  = BUFF -- Holy Word: Serenity
	defaultAuras[33206]  = BUFF -- Pain Suppression
	defaultAuras[81782]  = BUFF -- Power Word: Barrier
	defaultAuras[17]     = BUFF -- Power Word: Shield
	defaultAuras[41635]  = BUFF -- Prayer of Mending
	defaultAuras[139]    = BUFF -- Renew
	defaultAuras[114908] = BUFF -- Spirit Shell (shield)

	-- Buff Debuffs
	defaultAuras[6788]   = BUFF -- Weakened Soul

	-- Debuffs
	defaultAuras[2944]   = MINE -- Devouring Plague
	defaultAuras[14914]  = MINE -- Holy Fire
	defaultAuras[88625]  = MINE -- Holy Word: Chastise
	defaultAuras[89485]  = MINE -- Inner Focus
	defaultAuras[64044]  = MINE -- Psychic Horror (horror, FILTER_ON_ENEMY)
	--defaultAuras[64058]  = MINE -- Psychic Horror (disarm, FILTER_ON_ENEMY)
	defaultAuras[8122]   = MINE -- Psychic Scream
	defaultAuras[113792] = MINE -- Psychic Terror
	defaultAuras[9484]   = MINE -- Shackle Undead
	defaultAuras[589]    = MINE -- Shadow Word: Pain
	defaultAuras[15487]  = MINE -- Silence
	defaultAuras[34914]  = MINE -- Vampiric Touch
end

------------------------------------------------------------------------
-- Rogue

do
	local SELF   = bit_bor(FILTER_CLASS_ROGUE, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_ROGUE, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_ROGUE, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_ROGUE, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[13750]  = SELF -- Adrenaline Rush
	defaultAuras[115189] = SELF -- Anticipation
	defaultAuras[18377]  = SELF -- Blade Flurry
	defaultAuras[121153] = SELF -- Blindside
	defaultAuras[108212] = SELF -- Burst of Speed
	defaultAuras[31224]  = SELF -- Cloak of Shadows
	defaultAuras[74002]  = SELF -- Combat Insight
	defaultAuras[74001]  = SELF -- Combat Readiness
	defaultAuras[84747]  = SELF -- Deep Insight
	defaultAuras[56814]  = SELF -- Detection
	defaultAuras[32645]  = SELF -- Envenom
	defaultAuras[5277]   = SELF -- Evasion
	defaultAuras[1966]   = SELF -- Feint
	defaultAuras[51690]  = SELF -- Killing Spree
	defaultAuras[84746]  = SELF -- Moderate Insight
	defaultAuras[73651]  = SELF -- Recuperate
	defaultAuras[121472] = SELF -- Shadow Blades
	defaultAuras[51713]  = SELF -- Shadow Dance
	defaultAuras[114842] = SELF -- Shadow Walk
	defaultAuras[36554]  = SELF -- Shadowstep
	defaultAuras[84745]  = SELF -- Shallow Insight
	defaultAuras[114018] = SELF -- Shroud of Concealment
	defaultAuras[5171]   = SELF -- Slice and Dice
	defaultAuras[76577]  = SELF -- Smoke Bomb
	defaultAuras[2983]   = SELF -- Sprint
	defaultAuras[57934]  = SELF -- Tricks of the Trade
	defaultAuras[1856]   = SELF -- Vanish

	-- Debuffs
	defaultAuras[2094]   = DEBUFF -- Blind
	defaultAuras[1833]   = DEBUFF -- Cheap Shot
	--defaultAuras[122233] = MINE -- Crimson Tempest
	--defaultAuras[3409]   = MINE -- Crippling Poison
	--defaultAuras[2818]   = MINE -- Deadly Poison
	defaultAuras[26679]  = MINE -- Deadly Throw
	defaultAuras[51722]  = DEBUFF -- Dismantle -- TODO: generic Disarm group
	defaultAuras[91021]  = MINE -- Find Weakness
	defaultAuras[703]    = MINE -- Garrote
	defaultAuras[1330]   = MINE -- Garrote - Silence
	defaultAuras[1773]   = MINE -- Gouge
	defaultAuras[89774]  = MINE -- Hemorrhage
	defaultAuras[408]    = MINE -- Kidney Shot
	defaultAuras[112961] = MINE -- Leeching Poison
	defaultAuras[5760]   = MINE -- Mind-numbing Poison
	defaultAuras[112947] = MINE -- Nerve Strike
	defaultAuras[113952] = MINE -- Paralytic Poison
	defaultAuras[84617]  = MINE -- Revealing Strike
	defaultAuras[1943]   = MINE -- Rupture
	defaultAuras[6770]   = DEBUFF -- Sap -- TODO: move to CC group
	defaultAuras[57933]  = MINE -- Tricks of the Trade
	defaultAuras[79140]  = MINE -- Vendetta
	defaultAuras[8680]   = MINE -- Wound Poison
end

------------------------------------------------------------------------
-- Shaman

do
	local SELF   = bit_bor(FILTER_CLASS_SHAMAN, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_SHAMAN, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_SHAMAN, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_SHAMAN, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[108281] = SELF -- Ancestral Guidance
	defaultAuras[16188]  = SELF -- Ancestral Swiftness
	defaultAuras[114050] = SELF -- Ascendance (elemental)
	defaultAuras[114051] = SELF -- Ascendance (enhancement)
	defaultAuras[114052] = SELF -- Ascendance (restoration)
	defaultAuras[108271] = SELF -- Astral Shift
	defaultAuras[16166]  = SELF -- Elemental Mastery
	defaultAuras[77762]  = SELF -- Lava Surge
	defaultAuras[31616]  = SELF -- Nature's Guardian
	defaultAuras[77661]  = SELF -- Searing Flames
	defaultAuras[30823]  = SELF -- Shamanistic Rage
	defaultAuras[58876]  = SELF -- Spirit Walk
	defaultAuras[79206]  = SELF -- Spiritwalker's Grace
	defaultAuras[53390]  = SELF -- Tidal Waves

	-- Buffs
	--defaultAuras[2825]   = BUFF -- Bloodlust (shaman) -- show all
	defaultAuras[32182]  = BUFF -- Heroism (shaman)
	defaultAuras[974]    = MINE -- Earth Shield
	defaultAuras[8178]   = BUFF -- Grounding Totem Effect
	defaultAuras[89523]  = BUFF -- Grounding Totem (reflect)
	defaultAuras[119523] = BUFF -- Healing Stream Totem (resistance)
	defaultAuras[16191]  = BUFF -- Mana Tide
	defaultAuras[61295]  = MINE -- Riptide
	defaultAuras[98007]  = BUFF -- Spirit Link Totem
	defaultAuras[114893] = BUFF -- Stone Bulwark
	--defaultAuras[120676] = BUFF -- Stormlash Totem -- see totem timer
	defaultAuras[73685]  = SELF -- Unleash Life
	defaultAuras[118473] = MINE -- Unleashed Fury (Earthliving)
	defaultAuras[114896] = BUFF -- Windwalk Totem

	-- Debuffs
	defaultAuras[61882]  = MINE -- Earthquake
	defaultAuras[8050]   = MINE -- Flame Shock
	defaultAuras[115356] = MINE -- Stormblast
	defaultAuras[17364]  = MINE -- Stormstrike
	--defaultAuras[73684]  = MINE -- Unleash Earth
	defaultAuras[73682]  = MINE -- Unleash Frost
	defaultAuras[118470] = MINE -- Unleashed Fury (Flametongue)

	-- Debuffs - Crowd Control
	defaultAuras[76780]  = DEBUFF  -- Bind Elemental
	defaultAuras[51514]  = DEBUFF  -- Hex

	-- Debuffs - Root/Slow
	defaultAuras[3600]   = DEBUFF  -- Earthbind <-- Earthbind Totem
	defaultAuras[64695]  = DEBUFF  -- Earthgrab <-- Earthgrab Totem
	defaultAuras[8056]   = DEBUFF  -- Frost Shock
	defaultAuras[8034]   = MINE    -- Frostbrand Attack <-- Frostbrand Weapon
	defaultAuras[63685]  = DEBUFF  -- Freeze <-- Frozen Power
	defaultAuras[118905] = DEBUFF  -- Static Charge <-- Capacitor Totem
	--defaultAuras[51490]  = DEBUFF  -- Thunderstorm
end

------------------------------------------------------------------------
-- Warlock

do
	local SELF   = bit_bor(FILTER_CLASS_WARLOCK, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_WARLOCK, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_WARLOCK, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_WARLOCK, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[116198] = MINE -- Aura of Enfeeblement
	defaultAuras[116202] = MINE -- Aura of the Elements
	defaultAuras[117828] = SELF -- Backdraft
	defaultAuras[111400] = SELF -- Burning Rush
	defaultAuras[114168] = SELF -- Dark Apotheosis
	defaultAuras[110913] = SELF -- Dark Bargain (absorb)
	defaultAuras[110914] = SELF -- Dark Bargain (dot)
	defaultAuras[108359] = SELF -- Dark Regeneration
	defaultAuras[113858] = SELF -- Dark Soul: Instability
	defaultAuras[113861] = SELF -- Dark Soul: Knowledge
	defaultAuras[113860] = SELF -- Dark Soul: Misery
	defaultAuras[88448]  = SELF -- Demonic Rebirth
	defaultAuras[126]    = SELF -- Eye of Kilrogg
	defaultAuras[108683] = SELF -- Fire and Brimstone
	defaultAuras[119839] = SELF -- Fury Ward
	defaultAuras[119049] = SELF -- Kil'jaeden's Cunning
	defaultAuras[126090] = SELF -- Molten Core -- NEEDS CHECK
	defaultAuras[122355] = SELF -- Molten Core -- NEEDS CHECK
	defaultAuras[104232] = SELF -- Rain of Fire
	defaultAuras[108416] = SELF -- Sacrificial Pact
	defaultAuras[86211]  = SELF -- Soul Swap
	defaultAuras[104773] = SELF -- Unending Resolve

	-- Buffs
	defaultAuras[20707]  = BUFF -- Soulstone -- TODO: hide on self?

	-- Debuffs
	defaultAuras[980]    = MINE -- Agony
	defaultAuras[108505] = MINE -- Archimonde's Vengeance
	defaultAuras[124915] = MINE -- Chaos Wave
	defaultAuras[17962]  = MINE -- Conflagrate (slow)
	defaultAuras[172]    = MINE -- Corruption -- NEEDS CHECK
	defaultAuras[131740] = MINE -- Corruption -- NEEDS CHECK
	defaultAuras[146739] = MINE -- Corruption -- NEEDS CHECK
	defaultAuras[109466] = MINE -- Curse of Enfeeblement
	defaultAuras[18223]  = MINE -- Curse of Exhaustion
	defaultAuras[1490]   = MINE -- Curse of the Elements
	defaultAuras[603]    = MINE -- Doom
	defaultAuras[48181]  = MINE -- Haunt
	defaultAuras[80240]  = MINE -- Havoc
	defaultAuras[348]    = MINE -- Immolate
	defaultAuras[108686] = MINE -- Immolate <-- Fire and Brimstone
	defaultAuras[60947]  = MINE -- Nightmare
	defaultAuras[30108]  = MINE -- Seed of Corruption
	defaultAuras[47960]  = MINE -- Shadowflame
	defaultAuras[30283]  = MINE -- Shadowfury
	defaultAuras[27243]  = MINE -- Unstable Affliction

	-- Debuffs - Crowd Control
	defaultAuras[170]    = DEBUFF -- Banish -- TODO: move to CC group ?
	defaultAuras[111397] = MINE   -- Blood Fear
	defaultAuras[137143] = MINE   -- Blood Horror
	defaultAuras[1098]   = MINE   -- Enslave Demon
	defaultAuras[5782]   = DEBUFF -- Fear
	defaultAuras[5484]   = DEBUFF -- Howl of Terror
	defaultAuras[6789]   = MINE   -- Mortal Coil
end

------------------------------------------------------------------------
-- Warrior

do
	local SELF   = bit_bor(FILTER_CLASS_WARRIOR, FILTER_ON_PLAYER)
	local BUFF   = bit_bor(FILTER_CLASS_WARRIOR, FILTER_ON_FRIEND)
	local DEBUFF = bit_bor(FILTER_CLASS_WARRIOR, FILTER_ON_ENEMY)
	local MINE   = bit_bor(FILTER_CLASS_WARRIOR, FILTER_BY_PLAYER)

	-- Self Buffs
	defaultAuras[107574] = SELF -- Avatar
	defaultAuras[18499]  = SELF -- Berserker Rage
	defaultAuras[46924]  = SELF -- Bladestorm
	defaultAuras[12292]  = SELF -- Bloodbath
	defaultAuras[46916]  = SELF -- Bloodsurge
	defaultAuras[85730]  = SELF -- Deadly Calm
	defaultAuras[125565] = SELF -- Demoralizing Shout
	defaultAuras[118038] = SELF -- Die by the Sword
	defaultAuras[12880]  = SELF -- Enrage
	defaultAuras[55964]  = SELF -- Enraged Regeneration
	defaultAuras[115945] = SELF -- Glyph of Hamstring
	defaultAuras[12975]  = SELF -- Last Stand
	defaultAuras[114028] = SELF -- Mass Spell Reflection
	defaultAuras[85739]  = SELF -- Meat Cleaver
	defaultAuras[114192] = SELF -- Mocking Banner
	defaultAuras[97463]  = SELF -- Rallying Cry
	defaultAuras[1719]   = SELF -- Recklessness
	defaultAuras[112048] = SELF -- Shield Barrier
	defaultAuras[2565]   = SELF -- Shield Block
	defaultAuras[871]    = SELF -- Shield Wall
	defaultAuras[114206] = SELF -- Skull Banner
	defaultAuras[23920]  = SELF -- Spell Banner
	defaultAuras[52437]  = SELF -- Sudden Death
	defaultAuras[12328]  = SELF -- Sweeping Strikes
	defaultAuras[50227]  = SELF -- Sword and Board
	defaultAuras[125831] = SELF -- Taste for Blood
	defaultAuras[122510] = SELF -- Ultimatum

	-- Buffs
	defaultAuras[46947]  = BUFF -- Safeguard (damage reduction)
	defaultAuras[114029] = BUFF -- Safeguard (intercept)
	defaultAuras[114030] = BUFF -- Vigilance

	-- Debuffs
	defaultAuras[86346]  = MINE -- Colossus Smash
	defaultAuras[114205] = MINE -- Demoralizing Banner
	defaultAuras[1160]   = MINE -- Demoralizing Shout
	defaultAuras[676]    = MINE -- Disarm
	defaultAuras[118895] = MINE -- Dragon Roar
	defaultAuras[1715]   = MINE -- Hamstring
	defaultAuras[5246]   = MINE -- Intimidating Shout -- NEEDS CHECK
	defaultAuras[20511]  = MINE -- Intimidating Shout -- NEEDS CHECK
	defaultAuras[12323]  = MINE -- Piercing Howl
	defaultAuras[64382]  = MINE -- Shattering Throw
	defaultAuras[46968]  = MINE -- Shockwave
	defaultAuras[18498]  = MINE -- Silenced - Gag Order
	defaultAuras[107566] = MINE -- Staggering Shout
	defaultAuras[107570] = MINE -- Storm Bolt
	defaultAuras[355]    = MINE -- Taunt
	defaultAuras[105771] = MINE -- Warbringer
end

------------------------------------------------------------------------
-- Racials

-- Blood Elf
defaultAuras[50613]  = FILTER_BY_PLAYER -- Arcane Torrent (death knight)
defaultAuras[80483]  = FILTER_BY_PLAYER -- Arcane Torrent (hunter)
defaultAuras[28730]  = FILTER_BY_PLAYER -- Arcane Torrent (mage, paladin, priest, warlock)
defaultAuras[129597] = FILTER_BY_PLAYER -- Arcane Torrent (monk)
defaultAuras[25046]  = FILTER_BY_PLAYER -- Arcane Torrent (rogue)
defaultAuras[69179]  = FILTER_BY_PLAYER -- Arcane Torrent (warrior)
-- Draenei
defaultAuras[59545]  = FILTER_BY_PLAYER -- Gift of the Naaru (death knight)
defaultAuras[59543]  = FILTER_BY_PLAYER -- Gift of the Naaru (hunter)
defaultAuras[59548]  = FILTER_BY_PLAYER -- Gift of the Naaru (mage)
defaultAuras[121093] = FILTER_BY_PLAYER -- Gift of the Naaru (monk)
defaultAuras[59542]  = FILTER_BY_PLAYER -- Gift of the Naaru (paladin)
defaultAuras[59544]  = FILTER_BY_PLAYER -- Gift of the Naaru (priest)
defaultAuras[59547]  = FILTER_BY_PLAYER -- Gift of the Naaru (shaman)
defaultAuras[28880]  = FILTER_BY_PLAYER -- Gift of the Naaru (warrior)
-- Dwarf
defaultAuras[20594]  = FILTER_ON_PLAYER -- Stoneform
-- NightElf
defaultAuras[58984]  = FILTER_ON_PLAYER -- Shadowmeld
-- Orc
defaultAuras[20572]  = FILTER_ON_PLAYER -- Blood Fury (attack power)
defaultAuras[33702]  = FILTER_ON_PLAYER -- Blood Fury (spell power)
defaultAuras[33697]  = FILTER_ON_PLAYER -- Blood Fury (attack power and spell damage)
-- Pandaren
defaultAuras[107079] = FILTER_ON_PLAYER -- Quaking Palm
-- Scourge
defaultAuras[7744]   = FILTER_ON_PLAYER -- Will of the Forsaken
-- Tauren
defaultAuras[20549]  = FILTER_ALL -- War Stomp
-- Troll
defaultAuras[26297]  = FILTER_ON_PLAYER -- Berserking
-- Worgen
defaultAuras[68992]  = FILTER_ON_PLAYER -- Darkflight

------------------------------------------------------------------------
-- Magic Vulnerability

do
	local FILTER = bit_bor(FILTER_CLASS_ROGUE, FILTER_CLASS_WARLOCK)

	defaultAuras[1490]  = FILTER -- Curse of the Elements (warlock)
	defaultAuras[34889] = FILTER -- Fire Breath (hunter dragonhawk)
	defaultAuras[24844] = FILTER -- Lightning Breath (hunter wind serpent)
	defaultAuras[93068] = FILTER -- Master Poisoner (rogue)
end

------------------------------------------------------------------------
-- Mortal Wounds

do
	local FILTER = bit_bor(FILTER_CLASS_HUNTER, FILTER_CLASS_MONK, FILTER_CLASS_ROGUE, FILTER_CLASS_WARRIOR)

	defaultAuras[54680]  = FILTER -- Monstrous Bite (hunter devilsaur)
	defaultAuras[115804] = FILTER -- Mortal Wounds (monk, warrior)
	defaultAuras[82654]  = FILTER -- Widow Venom (hunter)
	defaultAuras[8680]   = FILTER -- Wound Poison (rogue)
end

------------------------------------------------------------------------
-- Physical Vulnerability

do
	local FILTER = bit_bor(FILTER_CLASS_DEATHKNIGHT, FILTER_CLASS_PALADIN, FILTER_CLASS_WARRIOR)

	defaultAuras[55749] = FILTER -- Acid Rain (hunter worm)
	defaultAuras[35290] = FILTER -- Gore (hunter boar)
	defaultAuras[81326] = FILTER -- Physical Vulnerability (death knight, paladin, warrior)
	defaultAuras[50518] = FILTER -- Ravage (hunter ravager)
	defaultAuras[57386] = FILTER -- Stampede (hunter rhino)
end

------------------------------------------------------------------------
-- Slow Casting

do
	local FILTER = bit_bor(FILTER_CLASS_DEATHKNIGHT, FILTER_CLASS_MAGE, FILTER_CLASS_WARLOCK)

	defaultAuras[109466] = FILTER -- Curse of Enfeeblement (warlock)
	defaultAuras[5760]   = FILTER -- Mind-numbing Poison (rogue)
	defaultAuras[73975]  = FILTER -- Necrotic Strike (death knight)
	defaultAuras[31589]  = FILTER -- Slow (mage)
	defaultAuras[50274]  = FILTER -- Spore Cloud (hunter sporebat)
	defaultAuras[90315]  = FILTER -- Tailspin (hunter fox)
	defaultAuras[126406] = FILTER -- Trample (hunter goat)
	defaultAuras[58604]  = FILTER -- Lava Breath (hunter core hound)
end

------------------------------------------------------------------------
-- Taunts (tanks only)

do
	local FILTER = FILTER_ROLE_TANK

	defaultAuras[56222]  = FILTER -- Dark Command
	defaultAuras[57604]  = FILTER -- Death Grip -- NEEDS CHECK 57603
	defaultAuras[20736]  = FILTER -- Distracting Shot
	defaultAuras[6795]   = FILTER -- Growl
	defaultAuras[118585] = FILTER -- Leer of the Ox
	defaultAuras[62124]  = FILTER -- Reckoning
	defaultAuras[355]    = FILTER -- Taunt
end

------------------------------------------------------------------------
-- Weakened Armor

do
	-- druids need to keep Faerie Fire/Swarm up anyway, no need to see both, this has the shorter duration
	local FILTER = bit_bor(FILTER_ROLE_TANK, FILTER_CLASS_DRUID, FILTER_CLASS_ROGUE, FILTER_CLASS_WARRIOR)

	defaultAuras[113746] = FILTER -- Weakened Armor (druid, hunter raptor, hunter tallstrider, rogue, warrior)
end

------------------------------------------------------------------------
-- Weakened Blows (tanks only)

do
	-- druids need to keep Thrash up anyway, no need to see both
	local FILTER = bit_bor(FILTER_ROLE_TANK, FILTER_CLASS_DEATHKNIGHT, FILTER_CLASS_MONK, FILTER_CLASS_PALADIN, FILTER_CLASS_WARRIOR)

	defaultAuras[109466] = FILTER -- Curse of Enfeeblement (warlock)
	defaultAuras[60256]  = FILTER -- Demoralizing Roar (hunter bear)
	defaultAuras[24423]  = FILTER -- Demoralizing Screech (hunter carrion bird)
	defaultAuras[115798] = FILTER -- Weakened Blows (death knight, druid, monk, paladin, shaman, warrior)
end

------------------------------------------------------------------------
-- PvP

-- Disarmed
defaultAuras[50541]  = FILTER_PVP -- Clench (hunter scorpid)
defaultAuras[676]    = FILTER_PVP -- Disarm (warrior)
defaultAuras[51722]  = FILTER_PVP -- Dismantle (rogue)
defaultAuras[117368] = FILTER_PVP -- Grapple Weapon (monk)
defaultAuras[91644]  = FILTER_PVP -- Snatch (hunter bird of prey)

-- Silenced
defaultAuras[25046]  = FILTER_PVP -- Arcane Torrent (blood elf - rogue)
defaultAuras[28730]  = FILTER_PVP -- Arcane Torrent (blood elf - mage, paladin, priest, warlock)
defaultAuras[50613]  = FILTER_PVP -- Arcane Torrent (blood elf - death knight)
defaultAuras[69179]  = FILTER_PVP -- Arcane Torrent (blood elf - warrior)
defaultAuras[80483]  = FILTER_PVP -- Arcane Torrent (blood elf - hunter)
defaultAuras[129597] = FILTER_PVP -- Arcane Torrent (blood elf - monk)
defaultAuras[31935]  = FILTER_PVP -- Avenger's Shield (paladin)
defaultAuras[102051] = FILTER_PVP -- Frostjaw (mage)
defaultAuras[1330]   = FILTER_PVP -- Garrote - Silence (rogue)
defaultAuras[50479]  = FILTER_PVP -- Nether Shock (hunter nether ray)
defaultAuras[15487]  = FILTER_PVP -- Silence (priest)
defaultAuras[18498]  = FILTER_PVP -- Silenced - Gag Order (warrior)
defaultAuras[34490]  = FILTER_PVP -- Silencing Shot (hunter)
defaultAuras[78675]  = FILTER_PVP -- Solar Beam (druid)
defaultAuras[97547]  = FILTER_PVP -- Solar Beam (druid)
defaultAuras[113286] = FILTER_PVP -- Solar Beam (symbiosis)
defaultAuras[113287] = FILTER_PVP -- Solar Beam (symbiosis)
defaultAuras[113288] = FILTER_PVP -- Solar Beam (symbiosis)
defaultAuras[116709] = FILTER_PVP -- Spear Hand Strike (monk)
defaultAuras[24259]  = FILTER_PVP -- Spell Lock (warlock felhunter)
defaultAuras[47476]  = FILTER_PVP -- Strangulate (death knight)

------------------------------------------------------------------------
-- Random quest related auras

defaultAuras[127372] = FILTER_BY_PLAYER -- Unstable Serum (Klaxxi Enhancement: Raining Blood)

------------------------------------------------------------------------
-- Boss debuffs that Blizzard forgot to flag

defaultAuras[106648] = FILTER_ALL -- Brew Explosion (Ook Ook in Stormsnout Brewery)
defaultAuras[106784] = FILTER_ALL -- Brew Explosion (Ook Ook in Stormsnout Brewery)
defaultAuras[123059] = FILTER_ALL -- Destabilize (Amber-Shaper Un'sok)

------------------------------------------------------------------------
-- Enchant procs that Blizzard failed to flag with their caster

defaultAuras[116631] = FILTER_DISABLE -- Colossus
defaultAuras[118334] = FILTER_DISABLE -- Dancing Steel (agi)
defaultAuras[118335] = FILTER_DISABLE -- Dancing Steel (str)
defaultAuras[104993] = FILTER_DISABLE -- Jade Spirit
defaultAuras[116660] = FILTER_DISABLE -- River's Song
defaultAuras[104509] = FILTER_DISABLE -- Windsong (crit)
defaultAuras[104423] = FILTER_DISABLE -- Windsong (haste)
defaultAuras[104510] = FILTER_DISABLE -- Windsong (mastery)

------------------------------------------------------------------------
-- NPC buffs that are completely useless

defaultAuras[63501] = FILTER_DISABLE -- Argent Crusade Champion's Pennant
defaultAuras[60023] = FILTER_DISABLE -- Scourge Banner Aura (Boneguard Commander in Icecrown)
defaultAuras[63406] = FILTER_DISABLE -- Darnassus Champion's Pennant
defaultAuras[63405] = FILTER_DISABLE -- Darnassus Valiant's Pennant
defaultAuras[63423] = FILTER_DISABLE -- Exodar Champion's Pennant
defaultAuras[63422] = FILTER_DISABLE -- Exodar Valiant's Pennant
defaultAuras[63396] = FILTER_DISABLE -- Gnomeregan Champion's Pennant
defaultAuras[63395] = FILTER_DISABLE -- Gnomeregan Valiant's Pennant
defaultAuras[63427] = FILTER_DISABLE -- Ironforge Champion's Pennant
defaultAuras[63426] = FILTER_DISABLE -- Ironforge Valiant's Pennant
defaultAuras[63433] = FILTER_DISABLE -- Orgrimmar Champion's Pennant
defaultAuras[63432] = FILTER_DISABLE -- Orgrimmar Valiant's Pennant
defaultAuras[63399] = FILTER_DISABLE -- Sen'jin Champion's Pennant
defaultAuras[63398] = FILTER_DISABLE -- Sen'jin Valiant's Pennant
defaultAuras[63403] = FILTER_DISABLE -- Silvermoon Champion's Pennant
defaultAuras[63402] = FILTER_DISABLE -- Silvermoon Valiant's Pennant
defaultAuras[62594] = FILTER_DISABLE -- Stormwind Champion's Pennant
defaultAuras[62596] = FILTER_DISABLE -- Stormwind Valiant's Pennant
defaultAuras[63436] = FILTER_DISABLE -- Thunder Bluff Champion's Pennant
defaultAuras[63435] = FILTER_DISABLE -- Thunder Bluff Valiant's Pennant
defaultAuras[63430] = FILTER_DISABLE -- Undercity Champion's Pennant
defaultAuras[63429] = FILTER_DISABLE -- Undercity Valiant's Pennant

------------------------------------------------------------------------

local auraList = {}
ns.AuraList = auraList

ns.UpdateAuraList = function()
	--print("UpdateAuraList")
	wipe(auraList)
	local PVP = ns.config.PVP
	local role = ns.GetPlayerRole()
	local filterForRole = roleFilter[role]
	local filterForClass = classFilter[playerClass]
	for id, v in pairs(oUFPhanxAuraConfig) do
		local skip
		if bit_band(v, FILTER_ALL) == 0 then
			if (bit_band(v, FILTER_PVP) > 0 and not PVP)
			or (bit_band(v, FILTER_PVE) > 0 and PVP)
			or (bit_band(v, FILTER_ROLE_MASK) > 0 and bit_band(v, filterForRole) == 0)
			or (bit_band(v, FILTER_CLASS_MASK) > 0 and bit_band(v,filterForClass ) == 0) then
				skip = true
			end
		end
		if not skip then
			auraList[id] = v
		end
	end

	-- Update all the things
	for _, obj in pairs(oUF.objects) do
		if obj.Auras then
			obj.Auras:ForceUpdate()
		end
		if obj.Buffs then
			obj.Buffs:ForceUpdate()
		end
		if obj.Debuffs then
			obj.Debuffs:ForceUpdate()
		end
	end
end

------------------------------------------------------------------------

local IsInInstance, UnitCanAttack, UnitIsFriend, UnitIsUnit, UnitPlayerControlled
    = IsInInstance, UnitCanAttack, UnitIsFriend, UnitIsUnit, UnitPlayerControlled

local unitIsPlayer = { player = true, pet = true, vehicle = true }

local filters = {
	[2] = function(self, unit, caster) return unitIsPlayer[caster] end,
	[3] = function(self, unit, caster) return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) end,
	[4] = function(self, unit, caster) return unit == "player" and not self.__owner.isGroupFrame end,
}

local function checkFilter(v, self, unit, caster)
	if bit_band(v, FILTER_BY_PLAYER) > 0 then
		return unitIsPlayer[caster]
	elseif bit_band(v, FILTER_ON_FRIEND) > 0 then
		return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit)
	elseif bit_band(v, FILTER_ON_PLAYER) > 0 then
		return unit == "player" and not self.__owner.isGroupFrame
	else
		return bit_band(v, FILTER_DISABLE) == 0
	end
end

local function debug(...)
	ChatFrame3:AddMessage(strjoin(" ", tostringall(...)))
end

ns.CustomAuraFilters = {
	player = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		--debug("CustomAuraFilter", "[unit]", unit, "[caster]", caster, "[name]", name, "[id]", spellID, "[filter]", v, "[vehicle]", caster == "vehicle")
		if v then
			return checkFilter(v, self, unit, caster)
		end
		return caster and UnitIsUnit(caster, "vehicle")
	end,
	pet = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		--debug("CustomAuraFilter", "[unit]", unit, "[caster]", caster, "[name]", name, "[id]", spellID, "[filter]", v, "[vehicle]", caster == "vehicle")
		return caster and unitIsPlayer[caster] and v and bit_band(v, FILTER_BY_PLAYER) > 0
	end,
	target = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		if isBossAura then
			local show = not v or bit_band(v, FILTER_DISABLE) == 0
			if show then
				debug("CustomAuraFilter", spellID, name, "BOSS")
			end
			return show
		elseif v then
			local show = checkFilter(v, self, unit, caster)
			if show then
				debug("CustomAuraFilter", spellID, name, "FILTER", v, caster)
			end
			return show
		elseif not caster and not IsInInstance() then
			-- EXPERIMENTAL: ignore debuffs from players outside the group, eg. on world bosses.
			return
		elseif UnitCanAttack("player", unit) and not UnitPlayerControlled(unit) then
			-- Hostile NPC. Show auras cast by the unit, or auras cast by the player's vehicle.
			-- print("hostile NPC")
			local show = not caster or caster == unit or UnitIsUnit(caster, "vehicle")
			if show then
				debug("CustomAuraFilter", spellID, name, (not caster) and "UNKNOWN" or (caster == unit) and "SELFCAST" or "VEHICLE")
			end
			return show
		else
			-- Friendly target or hostile player. Show auras cast by the player's vehicle.
			-- print("hostile player / friendly unit")
			local show = not caster or UnitIsUnit(caster, "vehicle")
			if show then
				debug("CustomAuraFilter", spellID, name, (not caster) and "UNKNOWN" or "VEHICLE")
			end
			return show
		end
	end,
	party = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		return v and bit_band(v, FILTER_ON_PLAYER) == 0
	end,
}