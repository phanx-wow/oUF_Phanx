--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2015 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
------------------------------------------------------------------------
	Filter settings stored as bitfields.
	0x MODE EXTRAUNIT ROLEx2 SOURCEx2 DESTx2
	See below for related constants.
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")

local bit_band, bit_bor = bit.band, bit.bor

------------------------------------------------------------------------

-- Permanent filters, checked on login and respec:
local FILTER_ALL            = 0x1000000
local FILTER_DISABLE        = 0x2000000
local FILTER_PVP            = 0x4000000 -- only show in PVP
local FILTER_PVE            = 0x8000000 -- only show in PVE

local FILTER_UNIT_FOCUS     = 0x0100000 -- Additionally show on focus frame
local FILTER_UNIT_TOT       = 0x0200000 -- Additionally show on tot frame

local FILTER_ROLE_MASK      = 0x00F0000
local FILTER_ROLE_TANK      = 0x0010000
local FILTER_ROLE_HEALER    = 0x0020000
local FILTER_ROLE_DAMAGER   = 0x0040000

-- Dynamic filters, checked in realtime:
local FILTER_BY_MASK        = 0x000FF00
local FILTER_BY_PLAYER      = 0x0000100

local FILTER_ON_MASK        = 0x00000FF
local FILTER_ON_PLAYER      = 0x0000001
local FILTER_ON_OTHER       = 0x0000002
local FILTER_ON_FRIEND      = 0x0000004
local FILTER_ON_ENEMY       = 0x0000008

ns.auraFilterValues = {
	FILTER_ALL               = FILTER_ALL,
	FILTER_DISABLE           = FILTER_DISABLE,
	FILTER_PVP               = FILTER_PVP,
	FILTER_PVE               = FILTER_PVE,

	FILTER_UNIT_FOCUS        = FILTER_UNIT_FOCUS,
	FILTER_UNIT_TOT          = FILTER_UNIT_TOT,

	FILTER_ROLE_MASK         = FILTER_ROLE_MASK,
	FILTER_ROLE_TANK         = FILTER_ROLE_TANK,
	FILTER_ROLE_HEALER       = FILTER_ROLE_HEALER,
	FILTER_ROLE_DAMAGER      = FILTER_ROLE_DAMAGER,

	FILTER_BY_MASK           = FILTER_BY_MASK,
	FILTER_BY_PLAYER         = FILTER_BY_PLAYER,

	FILTER_ON_MASK           = FILTER_ON_MASK,
	FILTER_ON_PLAYER         = FILTER_ON_PLAYER,
	FILTER_ON_OTHER          = FILTER_ON_OTHER,
	FILTER_ON_FRIEND         = FILTER_ON_FRIEND,
	FILTER_ON_ENEMY          = FILTER_ON_ENEMY,
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
	[90355]  = FILTER_ON_PLAYER, -- Ancient Hysteria (HU: Core Hound)
	[2825]   = FILTER_ON_PLAYER, -- Bloodlust (SH)
	[146555] = FILTER_ON_PLAYER, -- Drums of Rage (25%)
	[32182]  = FILTER_ON_PLAYER, -- Heroism (SH)
	[160452] = FILTER_ON_PLAYER, -- Netherwinds (HU: Nether Ray)
	[80353]  = FILTER_ON_PLAYER, -- Time Warp (MA)
	-- Crowd Control
	[710]    = FILTER_ALL, -- Banish
	[33786]  = FILTER_ALL, -- Cyclone
	[339]    = FILTER_ALL, -- Entangling Roots
	[5782]   = FILTER_ALL, -- Fear -- NEEDS CHECK
	[118699] = FILTER_ALL, -- Fear
	[1499]   = FILTER_ALL, -- Freezing Trap, -- NEEDS CHECK
	[3355]   = FILTER_ALL, -- Freezing Trap, -- NEEDS CHECK
	[43448]  = FILTER_ALL, -- Freezing Trap, -- NEEDS CHECK
	[60192]  = FILTER_ALL, -- Freezing Trap, -- NEEDS CHECK
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
	-- Random quest related auras
	[127372] = FILTER_BY_PLAYER, -- Unstable Serum (Klaxxi Enhancement: Raining Blood)
	-- Boss debuffs that Blizzard failed to flag
	[106648] = FILTER_ALL, -- Brew Explosion (Ook Ook in Stormsnout Brewery)
	[106784] = FILTER_ALL, -- Brew Explosion (Ook Ook in Stormsnout Brewery)
	[123059] = FILTER_ALL, -- Destabilize (Amber-Shaper Un'sok)
	-- Enchant procs that Blizzard failed to flag with their caster
	[116631] = FILTER_DISABLE, -- Colossus
	[118334] = FILTER_DISABLE, -- Dancing Steel (agi)
	[118335] = FILTER_DISABLE, -- Dancing Steel (str)
	[104993] = FILTER_DISABLE, -- Jade Spirit
	[116660] = FILTER_DISABLE, -- River's Song
	[104509] = FILTER_DISABLE, -- Windsong (crit)
	[104423] = FILTER_DISABLE, -- Windsong (haste)
	[104510] = FILTER_DISABLE, -- Windsong (mastery)
	-- NPC buffs that are completely useless
	[63501] = FILTER_DISABLE, -- Argent Crusade Champion's Pennant
	[60023] = FILTER_DISABLE, -- Scourge Banner Aura (Boneguard Commander in Icecrown)
	[63406] = FILTER_DISABLE, -- Darnassus Champion's Pennant
	[63405] = FILTER_DISABLE, -- Darnassus Valiant's Pennant
	[63423] = FILTER_DISABLE, -- Exodar Champion's Pennant
	[63422] = FILTER_DISABLE, -- Exodar Valiant's Pennant
	[63396] = FILTER_DISABLE, -- Gnomeregan Champion's Pennant
	[63395] = FILTER_DISABLE, -- Gnomeregan Valiant's Pennant
	[63427] = FILTER_DISABLE, -- Ironforge Champion's Pennant
	[63426] = FILTER_DISABLE, -- Ironforge Valiant's Pennant
	[63433] = FILTER_DISABLE, -- Orgrimmar Champion's Pennant
	[63432] = FILTER_DISABLE, -- Orgrimmar Valiant's Pennant
	[63399] = FILTER_DISABLE, -- Sen'jin Champion's Pennant
	[63398] = FILTER_DISABLE, -- Sen'jin Valiant's Pennant
	[63403] = FILTER_DISABLE, -- Silvermoon Champion's Pennant
	[63402] = FILTER_DISABLE, -- Silvermoon Valiant's Pennant
	[62594] = FILTER_DISABLE, -- Stormwind Champion's Pennant
	[62596] = FILTER_DISABLE, -- Stormwind Valiant's Pennant
	[63436] = FILTER_DISABLE, -- Thunder Bluff Champion's Pennant
	[63435] = FILTER_DISABLE, -- Thunder Bluff Valiant's Pennant
	[63430] = FILTER_DISABLE, -- Undercity Champion's Pennant
	[63429] = FILTER_DISABLE, -- Undercity Valiant's Pennant
}

ns.defaultAuras = defaultAuras

------------------------------------------------------------------------
-- Death Knight

if playerClass == "DEATHKNIGHT" then
	-- Self Buffs
	defaultAuras[48707]  = FILTER_ON_PLAYER -- Anti-Magic Shell
	defaultAuras[49222]  = FILTER_ON_PLAYER -- Bone Shield
	defaultAuras[53386]  = FILTER_ON_PLAYER -- Cinderglacier
	defaultAuras[119975] = FILTER_ON_PLAYER -- Conversion
	defaultAuras[101568] = FILTER_ON_PLAYER -- Dark Succor <-- glyph
	defaultAuras[96268]  = FILTER_ON_PLAYER -- Death's Advance
	defaultAuras[59052]  = FILTER_ON_PLAYER -- Freezing Fog <-- Rime
	defaultAuras[48792]  = FILTER_ON_PLAYER -- Icebound Fortitude
	defaultAuras[51124]  = FILTER_ON_PLAYER -- Killing Machine
	defaultAuras[49039]  = FILTER_ON_PLAYER -- Lichborne
	defaultAuras[51271]  = FILTER_ON_PLAYER -- Pillar of Frost
	defaultAuras[46584]  = FILTER_ON_PLAYER -- Raise Dead
	defaultAuras[108200] = FILTER_ON_PLAYER -- Remorseless Winter
	defaultAuras[51460]  = FILTER_ON_PLAYER -- Runic Corruption
	defaultAuras[50421]  = FILTER_ON_PLAYER -- Scent of Blood
	defaultAuras[116888] = FILTER_ON_PLAYER -- Shroud of Purgatory
	defaultAuras[8134]   = FILTER_ON_PLAYER -- Soul Reaper
	defaultAuras[81340]  = FILTER_ON_PLAYER -- Sudden Doom
	defaultAuras[115989] = FILTER_ON_PLAYER -- Unholy Blight
--	defaultAuras[53365]  = FILTER_ON_PLAYER -- Unholy Strength <-- Rune of the Fallen Crusader
	defaultAuras[55233]  = FILTER_ON_PLAYER -- Vampiric Blood
	defaultAuras[81162]  = FILTER_ON_PLAYER -- Will of the Necropolis (damage reduction)
	defaultAuras[96171]  = FILTER_ON_PLAYER -- Will of the Necropolis (free Rune Tap)

	-- Pet Buffs
	defaultAuras[63560]  = FILTER_BY_PLAYER -- Dark Transformation

	-- Buffs
	defaultAuras[49016]  = FILTER_ON_FRIEND -- Unholy Frenzy

	-- Debuffs
	defaultAuras[108194] = FILTER_ON_ENEMY  -- Asphyxiate
	defaultAuras[55078]  = FILTER_BY_PLAYER -- Blood Plague
	defaultAuras[45524]  = FILTER_ON_ENEMY  -- Chains of Ice
--	defaultAuras[50435]  = FILTER_ON_ENEMY  -- Chilblains
	defaultAuras[111673] = FILTER_BY_PLAYER -- Control Undead -- needs check
	defaultAuras[77606]  = FILTER_BY_PLAYER -- Dark Simulacrum
	defaultAuras[55095]  = FILTER_BY_PLAYER -- Frost Fever
	defaultAuras[51714]  = FILTER_BY_PLAYER -- Frost Vulernability <-- Rune of Razorice
	defaultAuras[73975]  = FILTER_ON_ENEMY  -- Necrotic Strike
	defaultAuras[115000] = FILTER_BY_PLAYER -- Remorseless Winter (slow)
	defaultAuras[115001] = FILTER_BY_PLAYER -- Remorseless Winter (stun)
	defaultAuras[114866] = FILTER_BY_PLAYER -- Soul Reaper (blood)
	defaultAuras[130735] = FILTER_BY_PLAYER -- Soul Reaper (frost)
	defaultAuras[130736] = FILTER_BY_PLAYER -- Soul Reaper (unholy)
	defaultAuras[47476]  = FILTER_ON_ENEMY  -- Strangulate
end

------------------------------------------------------------------------
-- Druid

if playerClass == "DRUID" then
	-- Self Buffs
	defaultAuras[22812]  = FILTER_ON_PLAYER -- Barkskin
	defaultAuras[106951] = FILTER_ON_PLAYER -- Berserk (cat)
	defaultAuras[50334]  = FILTER_ON_PLAYER -- Berserk (bear)
	defaultAuras[112071] = FILTER_ON_PLAYER -- Celestial Alignment
	defaultAuras[16870]  = FILTER_ON_PLAYER -- Clearcasting <-- Omen of Clarity
	defaultAuras[1850]   = FILTER_ON_PLAYER -- Dash
	defaultAuras[108381] = FILTER_ON_PLAYER -- Dream of Cenarius (+damage)
	defaultAuras[108382] = FILTER_ON_PLAYER -- Dream of Cenarius (+healing)
	defaultAuras[5229]   = FILTER_ON_PLAYER -- Enrage
	defaultAuras[124769] = FILTER_ON_PLAYER -- Frenzied Regeneration <-- glyph
	defaultAuras[102560] = FILTER_ON_PLAYER -- Incarnation: Chosen of Elune
	defaultAuras[102543] = FILTER_ON_PLAYER -- Incarnation: King of the Jungle
	defaultAuras[102558] = FILTER_ON_PLAYER -- Incarnation: Son of Ursoc
	defaultAuras[33891]  = FILTER_ON_PLAYER -- Incarnation: Tree of Life -- NEEDS CHECK
	defaultAuras[81192]  = FILTER_ON_PLAYER -- Lunar Shower
	defaultAuras[106922] = FILTER_ON_PLAYER -- Might of Ursoc
	defaultAuras[16689]  = FILTER_ON_PLAYER -- Nature's Grasp
	defaultAuras[132158] = FILTER_ON_PLAYER -- Nature's Swiftness
	defaultAuras[124974] = FILTER_ON_PLAYER -- Nature's Vigil
	defaultAuras[48391]  = FILTER_ON_PLAYER -- Owlkin Frenzy
	defaultAuras[69369]  = FILTER_ON_PLAYER -- Predator's Swiftness
	defaultAuras[158792] = FILTER_ON_PLAYER -- Pulverize
	defaultAuras[132402] = FILTER_ON_PLAYER -- Savage Defense
	defaultAuras[52610]  = FILTER_ON_PLAYER -- Savage Roar -- VERIFIED 13/02/20 on tauren feral
	defaultAuras[127538] = FILTER_ON_PLAYER -- Savage Roar -- NEEDS CHECK
	defaultAuras[93400]  = FILTER_ON_PLAYER -- Shooting Stars
	defaultAuras[114108] = FILTER_ON_PLAYER -- Soul of the Forest (resto)
	defaultAuras[48505]  = FILTER_ON_PLAYER -- Starfall
	defaultAuras[61336]  = FILTER_ON_PLAYER -- Survival Instincts
	defaultAuras[5217]   = FILTER_ON_PLAYER -- Tiger's Fury
	defaultAuras[102416] = FILTER_ON_PLAYER -- Wild Charge (aquatic)
	-- WOD
	defaultAuras[164547] = FILTER_ON_PLAYER -- Lunar Empowerment
	defaultAuras[171743] = FILTER_ON_PLAYER -- Lunar Peak
	defaultAuras[164545] = FILTER_ON_PLAYER -- Solar Empowerment
	defaultAuras[171744] = FILTER_ON_PLAYER -- Solar Peak

	-- Buffs
	defaultAuras[102351] = FILTER_BY_PLAYER -- Cenarion Ward (buff)
	defaultAuras[102352] = FILTER_BY_PLAYER -- Cenarion Ward (heal)
	defaultAuras[29166]  = FILTER_ON_FRIEND -- Innervate
	defaultAuras[102342] = FILTER_ON_FRIEND -- Ironbark
	defaultAuras[33763]  = FILTER_BY_PLAYER -- Lifebloom
	defaultAuras[94447]  = FILTER_BY_PLAYER -- Lifebloom (tree)
	defaultAuras[8936]   = FILTER_BY_PLAYER -- Regrowth
	defaultAuras[774]    = FILTER_BY_PLAYER -- Rejuvenation
	defaultAuras[155777] = FILTER_BY_PLAYER -- Rejuvenation (Germination)
	defaultAuras[77761]  = FILTER_ON_FRIEND -- Stampeding Roar (bear)
	defaultAuras[77764]  = FILTER_ON_FRIEND -- Stampeding Roar (cat)
	defaultAuras[106898] = FILTER_ON_FRIEND -- Stampeding Roar (caster)
	defaultAuras[48438]  = FILTER_BY_PLAYER -- Wild Growth

	-- Debuffs
	defaultAuras[102795] = FILTER_ON_ENEMY  -- Bear Hug
	defaultAuras[33786]  = FILTER_ON_ENEMY  -- Cyclone
	defaultAuras[99]     = FILTER_ON_ENEMY  -- Disorienting Roar
	defaultAuras[339]    = FILTER_ON_ENEMY  -- Entangling Roots
	defaultAuras[114238] = FILTER_ON_ENEMY  -- Fae Silence <-- glpyh
	defaultAuras[81281]  = FILTER_ON_ENEMY  -- Fungal Growth <-- Wild Mushroom: Detonate
	defaultAuras[2637]   = FILTER_ON_ENEMY  -- Hibernate
	defaultAuras[33745]  = FILTER_BY_PLAYER -- Lacerate
	defaultAuras[22570]  = FILTER_ON_ENEMY  -- Maim
	defaultAuras[5211]   = FILTER_ON_ENEMY  -- Mighty Bash
	defaultAuras[8921]   = FILTER_BY_PLAYER -- Moonfire
	defaultAuras[9005]   = FILTER_BY_PLAYER -- Pounce -- NEEDS CHECK
	defaultAuras[102546] = FILTER_BY_PLAYER -- Pounce -- NEEDS CHECK
	defaultAuras[9007]   = FILTER_BY_PLAYER -- Pounce Bleed
--	defaultAuras[1822]   = FILTER_BY_PLAYER -- Rake -- REMOVED?
	defaultAuras[155722] = FILTER_BY_PLAYER -- Rake
	defaultAuras[1079]   = FILTER_BY_PLAYER -- Rip
	defaultAuras[106839] = FILTER_ON_ENEMY  -- Skull Bash -- NOT CURRENTLY USED
	defaultAuras[78675]  = FILTER_ON_ENEMY  -- Solar Beam (silence)
	defaultAuras[97547]  = FILTER_ON_ENEMY  -- Solar Beam (interrupt)
	defaultAuras[93402]  = FILTER_BY_PLAYER -- Sunfire
	defaultAuras[77758]  = FILTER_BY_PLAYER -- Thrash (bear)
	defaultAuras[106830] = FILTER_BY_PLAYER -- Thrash (cat)
	defaultAuras[61391]  = FILTER_ON_ENEMY  -- Typhoon
	defaultAuras[102793] = FILTER_ON_ENEMY  -- Ursol's Vortex
	defaultAuras[45334]  = FILTER_ON_ENEMY  -- Immobilize <-- Wild Charge (bear)
	defaultAuras[50259]  = FILTER_ON_ENEMY  -- Dazed <-- Wild Charge (cat)

	defaultAuras[770]    = FILTER_PVP -- Faerie Fire
	defaultAuras[102355] = FILTER_PVP -- Faerie Swarm
end

------------------------------------------------------------------------
-- Hunter

if playerClass == "HUNTER" then
	-- Self Buffs
	defaultAuras[83559]  = FILTER_ON_PLAYER -- Black Ice
--	defaultAuras[82921]  = FILTER_ON_PLAYER -- Bombardment
--	defaultAuras[53257]  = FILTER_ON_PLAYER -- Cobra Strikes
	defaultAuras[51755]  = FILTER_ON_PLAYER -- Camouflage
	defaultAuras[19263]  = FILTER_ON_PLAYER -- Deterrence
	defaultAuras[15571]  = FILTER_ON_PLAYER -- Dazed <-- Aspect of the Cheetah
	defaultAuras[6197]   = FILTER_ON_PLAYER -- Eagle Eye
	defaultAuras[5384]   = FILTER_ON_PLAYER -- Feign Death
	defaultAuras[82726]  = FILTER_ON_PLAYER -- Fervor
	defaultAuras[82926]  = FILTER_ON_PLAYER -- Fire! <-- Master Marksman
	defaultAuras[82692]  = FILTER_ON_PLAYER -- Focus Fire
	defaultAuras[56453]  = FILTER_ON_PLAYER -- Lock and Load
	defaultAuras[54216]  = FILTER_ON_PLAYER -- Master's Call
	defaultAuras[34477]  = FILTER_ON_PLAYER -- Misdirection
	defaultAuras[118922] = FILTER_ON_PLAYER -- Posthaste
	defaultAuras[3045]   = FILTER_ON_PLAYER -- Rapid Fire
--	defaultAuras[82925]  = FILTER_ON_PLAYER -- Ready, Set, Aim... <-- Master Marksman
	defaultAuras[53220]  = FILTER_ON_PLAYER -- Steady Focus
	defaultAuras[34471]  = FILTER_ON_PLAYER -- The Beast Within
	defaultAuras[34720]  = FILTER_ON_PLAYER -- Thrill of the Hunt
	-- Pet Buffs
	defaultAuras[19615]  = FILTER_BY_PLAYER -- Frenzy
	defaultAuras[19574]  = FILTER_BY_PLAYER -- Bestial Wrath
	defaultAuras[136]    = FILTER_BY_PLAYER -- Mend Pet
	-- Buffs
	defaultAuras[34477]  = FILTER_ON_FRIEND -- Misdirection (30 sec threat)
	defaultAuras[35079]  = FILTER_ON_FRIEND -- Misdirection (4 sec transfer)
	-- Debuffs
	defaultAuras[131894] = FILTER_BY_PLAYER -- defaultAuras Murder of Crows
	defaultAuras[117526] = FILTER_BY_PLAYER -- Binding Shot (stun)
	defaultAuras[117405] = FILTER_BY_PLAYER -- Binding Shot (tether)
	defaultAuras[3674]   = FILTER_BY_PLAYER -- Black Arrow
	defaultAuras[35101]  = FILTER_BY_PLAYER -- Concussive Barrage
	defaultAuras[5116]   = FILTER_BY_PLAYER -- Concussive Shot
	defaultAuras[20736]  = FILTER_BY_PLAYER -- Distracting Shot
	defaultAuras[64803]  = FILTER_BY_PLAYER -- Entrapment
	defaultAuras[53301]  = FILTER_BY_PLAYER -- Explosive Shot
	defaultAuras[13812]  = FILTER_BY_PLAYER -- Explosive Trap
	defaultAuras[43446]  = FILTER_BY_PLAYER -- Explosive Trap Effect -- NEEDS CHECK
	defaultAuras[128961] = FILTER_BY_PLAYER -- Explosive Trap Effect -- NEEDS CHECK
	defaultAuras[3355]   = FILTER_BY_PLAYER -- Freezing Trap
	defaultAuras[61394]  = FILTER_BY_PLAYER -- Frozen Wake <-- Glyph of Freezing Trap
	defaultAuras[120761] = FILTER_BY_PLAYER -- Glaive Toss -- NEEDS CHECK
	defaultAuras[121414] = FILTER_BY_PLAYER -- Glaive Toss -- NEEDS CHECK
	defaultAuras[1130]   = FILTER_ON_ENEMY  -- Hunter's Mark
	defaultAuras[135299] = FILTER_ON_ENEMY  -- Ice Trap
	defaultAuras[34394]  = FILTER_BY_PLAYER -- Intimidation
	defaultAuras[115928] = FILTER_BY_PLAYER -- Narrow Escape -- NEEDS CHECK
	defaultAuras[128405] = FILTER_BY_PLAYER -- Narrow Escape -- NEEDS CHECK
--	defaultAuras[63468]  = FILTER_BY_PLAYER -- Piercing Shots
	defaultAuras[1513]   = FILTER_BY_PLAYER -- Scare Beast
	defaultAuras[19503]  = FILTER_BY_PLAYER -- Scatter Shot
	defaultAuras[118253] = FILTER_BY_PLAYER -- Serpent Sting
	defaultAuras[34490]  = FILTER_BY_PLAYER -- Silencing Shot
	defaultAuras[82654]  = FILTER_BY_PLAYER -- Widow Venom
	defaultAuras[19386]  = FILTER_BY_PLAYER -- Wyvern Sting
end

------------------------------------------------------------------------
-- Mage

if playerClass == "MAGE" then
	-- Self Buffs
	defaultAuras[110909] = FILTER_ON_PLAYER -- Alter Time
	defaultAuras[36032]  = FILTER_ON_PLAYER -- Arcane Charge
	defaultAuras[12042]  = FILTER_ON_PLAYER -- Arcane Power
	defaultAuras[108843] = FILTER_ON_PLAYER -- Blazing Speed
	defaultAuras[57761]  = FILTER_ON_PLAYER -- Brain Freeze
	defaultAuras[87023]  = FILTER_ON_PLAYER -- Cauterize
	defaultAuras[44544]  = FILTER_ON_PLAYER -- Fingers of Frost
	defaultAuras[110960] = FILTER_ON_PLAYER -- Greater Invisibility
	defaultAuras[48107]  = FILTER_ON_PLAYER -- Heating Up
	defaultAuras[11426]  = FILTER_ON_PLAYER -- Ice Barrier
	defaultAuras[45438]  = FILTER_ON_PLAYER -- Ice Block
	defaultAuras[108839] = FILTER_ON_PLAYER -- Ice Floes
	defaultAuras[12472]  = FILTER_ON_PLAYER -- Icy Veins
	defaultAuras[116267] = FILTER_ON_PLAYER -- Inacnter's Absorption
	defaultAuras[1463]   = FILTER_ON_PLAYER -- Inacnter's Ward
	defaultAuras[66]     = FILTER_ON_PLAYER -- Invisibility
	defaultAuras[12043]  = FILTER_ON_PLAYER -- Presence of Mind
	defaultAuras[116014] = FILTER_ON_PLAYER -- Rune of Power
	defaultAuras[48108]  = FILTER_ON_PLAYER -- Pyroblast!
	defaultAuras[115610] = FILTER_ON_PLAYER -- Temporal Shield (shield)
	defaultAuras[115611] = FILTER_ON_PLAYER -- Temporal Shield (heal)
	-- Debuffs
	defaultAuras[34356]  = FILTER_BY_PLAYER -- Blizzard (slow) -- NEEDS CHECK
	defaultAuras[83853]  = FILTER_BY_PLAYER -- Combustion
	defaultAuras[120]    = FILTER_BY_PLAYER -- Cone of Cold
	defaultAuras[44572]  = FILTER_BY_PLAYER -- Deep Freeze
	defaultAuras[31661]  = FILTER_BY_PLAYER -- Dragon's Breath
	defaultAuras[112948] = FILTER_BY_PLAYER -- Frost Bomb
	defaultAuras[113092] = FILTER_BY_PLAYER -- Frost Bomb (slow)
	defaultAuras[122]    = FILTER_ON_ENEMY  -- Frost Nova
	defaultAuras[116]    = FILTER_BY_PLAYER -- Frostbolt
	defaultAuras[44614]  = FILTER_BY_PLAYER -- Frostfire Bolt
	defaultAuras[102051] = FILTER_BY_PLAYER -- Frostjaw
	defaultAuras[84721]  = FILTER_BY_PLAYER -- Frozen Orb
--	defaultAuras[12654]  = FILTER_BY_PLAYER -- Ignite
	defaultAuras[44457]  = FILTER_BY_PLAYER -- Living Bomb
	defaultAuras[114923] = FILTER_BY_PLAYER -- Nether Tempest
--	defaultAuras[11366]  = FILTER_BY_PLAYER -- Pyroblast
	defaultAuras[132210] = FILTER_BY_PLAYER -- Pyromaniac
	defaultAuras[82691]  = FILTER_BY_PLAYER -- Ring of Frost
	defaultAuras[55021]  = FILTER_ON_ENEMY  -- Silenced - Improved Counterspell
	defaultAuras[31589]  = FILTER_ON_ENEMY  -- Slow
end

------------------------------------------------------------------------
-- Monk

if playerClass == "MONK" then
	-- Self Buffs
	defaultAuras[122278] = FILTER_ON_PLAYER -- Dampen Harm
	defaultAuras[121125] = FILTER_ON_PLAYER -- Death Note
	defaultAuras[122783] = FILTER_ON_PLAYER -- Diffuse Magic
	defaultAuras[128939] = FILTER_ON_PLAYER -- Elusive Brew (stack)
	defaultAuras[115308] = FILTER_ON_PLAYER -- Elusive Brew (consume)
	defaultAuras[115288] = FILTER_ON_PLAYER -- Energizing Brew
	defaultAuras[115203] = FILTER_ON_PLAYER -- Fortifying Brew
	defaultAuras[115295] = FILTER_ON_PLAYER -- Guard
	defaultAuras[123402] = FILTER_ON_PLAYER -- Guard (glyphed)
	defaultAuras[124458] = FILTER_ON_PLAYER -- Healing Sphere (count)
	defaultAuras[115867] = FILTER_ON_PLAYER -- Mana Tea (stack)
	defaultAuras[119085] = FILTER_ON_PLAYER -- Momentum
	defaultAuras[124968] = FILTER_ON_PLAYER -- Retreat
	defaultAuras[127722] = FILTER_ON_PLAYER -- Serpent's Zeal
	defaultAuras[125359] = FILTER_ON_PLAYER -- Tiger Power
	defaultAuras[116841] = FILTER_ON_PLAYER -- Tiger's Lust
	defaultAuras[125195] = FILTER_ON_PLAYER -- Tigereye Brew (stack)
	defaultAuras[116740] = FILTER_ON_PLAYER -- Tigereye Brew (consume)
	defaultAuras[122470] = FILTER_ON_PLAYER -- Touch of Karma
	defaultAuras[118674] = FILTER_ON_PLAYER -- Vital Mists
	-- Buffs
	defaultAuras[132120] = FILTER_BY_PLAYER -- Enveloping Mist
	defaultAuras[116849] = FILTER_ON_FRIEND -- Life Cocoon
	defaultAuras[119607] = FILTER_BY_PLAYER -- Renewing Mist (jump)
	defaultAuras[119611] = FILTER_BY_PLAYER -- Renewing Mist (hot)
	defaultAuras[124081] = FILTER_BY_PLAYER -- Zen Sphere
	-- Debuffs
	defaultAuras[123393] = FILTER_BY_PLAYER -- Breath of Fire (disorient)
	defaultAuras[123725] = FILTER_BY_PLAYER -- Breath of Fire (dot)
	defaultAuras[119392] = FILTER_BY_PLAYER -- Charging Ox Wave
	defaultAuras[122242] = FILTER_BY_PLAYER -- Clash (stun) -- NEEDS CHECK
	defaultAuras[126451] = FILTER_BY_PLAYER -- Clash (stun) -- NEEDS CHECK
	defaultAuras[128846] = FILTER_BY_PLAYER -- Clash (stun) -- NEEDS CHECK
	defaultAuras[116095] = FILTER_BY_PLAYER -- Disable
	defaultAuras[116330] = FILTER_BY_PLAYER -- Dizzying Haze -- NEEDS CHECK
	defaultAuras[123727] = FILTER_BY_PLAYER -- Dizzying Haze -- NEEDS CHECK
	defaultAuras[117368] = FILTER_BY_PLAYER -- Grapple Weapon
	defaultAuras[118585] = FILTER_BY_PLAYER -- Leer of the Ox
	defaultAuras[119381] = FILTER_BY_PLAYER -- Leg Sweep
	defaultAuras[115078] = FILTER_BY_PLAYER -- Paralysis
	defaultAuras[118635] = FILTER_BY_PLAYER -- Provoke -- NEEDS CHECK
	defaultAuras[116189] = FILTER_BY_PLAYER -- Provoke -- NEEDS CHECK
	defaultAuras[130320] = FILTER_BY_PLAYER -- Rising Sun Kick
	defaultAuras[116847] = FILTER_BY_PLAYER -- Rushing Jade Wind
	defaultAuras[116709] = FILTER_BY_PLAYER -- Spear Hand Strike
	defaultAuras[123407] = FILTER_BY_PLAYER -- Spinning Fire Blossom
end

------------------------------------------------------------------------
-- Paladin

if playerClass == "PALADIN" then
	-- Self Buffs
	defaultAuras[121467] = FILTER_ON_PLAYER -- Alabaster Shield
	defaultAuras[31850]  = FILTER_ON_PLAYER -- Ardent Defender
	defaultAuras[31884]  = FILTER_ON_PLAYER -- Avenging Wrath
	defaultAuras[114637] = FILTER_ON_PLAYER -- Bastion of Glory
	defaultAuras[88819]  = FILTER_ON_PLAYER -- Daybreak
	defaultAuras[31842]  = FILTER_ON_PLAYER -- Divine Favor
	defaultAuras[54428]  = FILTER_ON_PLAYER -- Divine Plea
	defaultAuras[498]    = FILTER_ON_PLAYER -- Divine Protection
	defaultAuras[90174]  = FILTER_ON_PLAYER -- Divine Purpose
	defaultAuras[642]    = FILTER_ON_PLAYER -- Divine Shield
	defaultAuras[54957]  = FILTER_ON_PLAYER -- Glyph of Flash of Light
	defaultAuras[85416]  = FILTER_ON_PLAYER -- Grand Crusader
	defaultAuras[86659]  = FILTER_ON_PLAYER -- Guardian of Ancient Kings (protection)
	defaultAuras[86669]  = FILTER_ON_PLAYER -- Guardian of Ancient Kings (holy)
	defaultAuras[86698]  = FILTER_ON_PLAYER -- Guardian of Ancient Kings (retribution)
	defaultAuras[105809] = FILTER_ON_PLAYER -- Holy Avenger
	defaultAuras[54149]  = FILTER_ON_PLAYER -- Infusion of Light
	defaultAuras[84963]  = FILTER_ON_PLAYER -- Inquisition
	defaultAuras[114250] = FILTER_ON_PLAYER -- Selfless Healer
--	defaultAuras[132403] = FILTER_ON_PLAYER -- Shield of the Righteous
	defaultAuras[85499]  = FILTER_ON_PLAYER -- Speed of Light
	defaultAuras[94686]  = FILTER_ON_PLAYER -- Supplication
	-- Buffs
	defaultAuras[53563]  = FILTER_ON_FRIEND -- Beacon of Light
	defaultAuras[31821]  = FILTER_ON_FRIEND -- Devotion Aura
	defaultAuras[114163] = FILTER_ON_FRIEND -- Eternal Flame
	defaultAuras[1044]   = FILTER_ON_FRIEND -- Hand of Freedom
	defaultAuras[1022]   = FILTER_ON_FRIEND -- Hand of Protection
	defaultAuras[114039] = FILTER_ON_FRIEND -- Hand of Purity
	defaultAuras[6940]   = FILTER_ON_FRIEND -- Hand of Sacrifice
	defaultAuras[1038]   = FILTER_ON_FRIEND -- Hand of Salvation
	defaultAuras[86273]  = FILTER_ON_FRIEND -- Illuminated Healing
	defaultAuras[20925]  = FILTER_ON_FRIEND -- Sacred Shield
	defaultAuras[20170]  = FILTER_ON_FRIEND -- Seal of Justice
	defaultAuras[114917] = FILTER_ON_FRIEND -- Stay of Execution
	-- Buff Debuffs
	defaultAuras[25771]  = FILTER_ON_FRIEND -- Forbearace
	-- Debuffs
	defaultAuras[31935]  = FILTER_BY_PLAYER -- Avenger's Shield
--	defaultAuras[110300] = FILTER_BY_PLAYER -- Burden of Guilt
	defaultAuras[105421] = FILTER_BY_PLAYER -- Blinding Light
	defaultAuras[31803]  = FILTER_BY_PLAYER -- Censure
	defaultAuras[63529]  = FILTER_BY_PLAYER -- Dazed - Avenger's Shield
	defaultAuras[2812]   = FILTER_BY_PLAYER -- Denounce
	defaultAuras[114916] = FILTER_BY_PLAYER -- Execution Sentence
	defaultAuras[105593] = FILTER_BY_PLAYER -- Fist of Justice
	defaultAuras[853]    = FILTER_BY_PLAYER -- Hammer of Justice
	defaultAuras[119072] = FILTER_BY_PLAYER -- Holy Wrath
	defaultAuras[20066]  = FILTER_BY_PLAYER -- Repentance
	defaultAuras[10326]  = FILTER_BY_PLAYER -- Turn Evil
end

------------------------------------------------------------------------
-- Priest

if playerClass == "PRIEST" then
	-- Self Buffs
--	defaultAuras[114214] = FILTER_ON_PLAYER -- Angelic Bulwark
	defaultAuras[81700]  = FILTER_ON_PLAYER -- Archangel
--	defaultAuras[59889]  = FILTER_ON_PLAYER -- Borrowed Time
	defaultAuras[47585]  = FILTER_ON_PLAYER -- Dispersion
	defaultAuras[123266] = FILTER_ON_PLAYER -- Divine Insight (discipline)
	defaultAuras[123267] = FILTER_ON_PLAYER -- Divine Insight (holy)
	defaultAuras[124430] = FILTER_ON_PLAYER -- Divine Insight (shadow)
	defaultAuras[81661]  = FILTER_ON_PLAYER -- Evangelism
	defaultAuras[586]    = FILTER_ON_PLAYER -- Fade
	defaultAuras[2096]   = FILTER_ON_PLAYER -- Mind Vision
	defaultAuras[114239] = FILTER_ON_PLAYER -- Phantasm
	defaultAuras[10060]  = FILTER_ON_PLAYER -- Power Infusion
	defaultAuras[63735]  = FILTER_ON_PLAYER -- Serendipity
	defaultAuras[112833] = FILTER_ON_PLAYER -- Spectral Guise
	defaultAuras[109964] = FILTER_ON_PLAYER -- Spirit Shell (self)
	defaultAuras[87160]  = FILTER_ON_PLAYER -- Surge of Darkness
	defaultAuras[114255] = FILTER_ON_PLAYER -- Surge of Light
	defaultAuras[123254] = FILTER_ON_PLAYER -- Twist of Fate
	defaultAuras[15286]  = FILTER_ON_PLAYER -- Vampiric Embrace
	-- Buffs
	defaultAuras[47753]  = FILTER_ON_FRIEND -- Divine Aegis
	defaultAuras[77613]  = FILTER_BY_PLAYER -- Grace
	defaultAuras[47788]  = FILTER_ON_FRIEND -- Guardian Spirit
	defaultAuras[88684]  = FILTER_ON_FRIEND -- Holy Word: Serenity
	defaultAuras[33206]  = FILTER_ON_FRIEND -- Pain Suppression
	defaultAuras[81782]  = FILTER_ON_FRIEND -- Power Word: Barrier
	defaultAuras[17]     = FILTER_ON_FRIEND -- Power Word: Shield
	defaultAuras[41635]  = FILTER_ON_FRIEND -- Prayer of Mending
	defaultAuras[139]    = FILTER_ON_FRIEND -- Renew
	defaultAuras[114908] = FILTER_ON_FRIEND -- Spirit Shell (shield)
	-- Buff Debuffs
	defaultAuras[6788]   = FILTER_ON_FRIEND -- Weakened Soul
	-- Debuffs
	defaultAuras[2944]   = FILTER_BY_PLAYER -- Devouring Plague
	defaultAuras[14914]  = FILTER_BY_PLAYER -- Holy Fire
	defaultAuras[88625]  = FILTER_BY_PLAYER -- Holy Word: Chastise
	defaultAuras[89485]  = FILTER_BY_PLAYER -- Inner Focus
	defaultAuras[64044]  = FILTER_BY_PLAYER -- Psychic Horror (horror, FILTER_ON_ENEMY)
--	defaultAuras[64058]  = FILTER_BY_PLAYER -- Psychic Horror (disarm, FILTER_ON_ENEMY)
	defaultAuras[8122]   = FILTER_BY_PLAYER -- Psychic Scream
	defaultAuras[113792] = FILTER_BY_PLAYER -- Psychic Terror
	defaultAuras[9484]   = FILTER_BY_PLAYER -- Shackle Undead
	defaultAuras[589]    = FILTER_BY_PLAYER -- Shadow Word: Pain
	defaultAuras[15487]  = FILTER_BY_PLAYER -- Silence
	defaultAuras[34914]  = FILTER_BY_PLAYER -- Vampiric Touch
end

------------------------------------------------------------------------
-- (ro)

if playerClass == "ROGUE" then
	-- Self Buffs
	defaultAuras[13750]  = FILTER_ON_PLAYER -- Adrenaline Rush
	defaultAuras[115189] = FILTER_ON_PLAYER -- Anticipation
	defaultAuras[18377]  = FILTER_ON_PLAYER -- Blade Flurry
	defaultAuras[121153] = FILTER_ON_PLAYER -- Blindside
	defaultAuras[108212] = FILTER_ON_PLAYER -- Burst of Speed
	defaultAuras[31224]  = FILTER_ON_PLAYER -- Cloak of Shadows
	defaultAuras[74002]  = FILTER_ON_PLAYER -- Combat Insight
	defaultAuras[74001]  = FILTER_ON_PLAYER -- Combat Readiness
	defaultAuras[84747]  = FILTER_ON_PLAYER -- Deep Insight
	defaultAuras[56814]  = FILTER_ON_PLAYER -- Detection
	defaultAuras[32645]  = FILTER_ON_PLAYER -- Envenom
	defaultAuras[5277]   = FILTER_ON_PLAYER -- Evasion
	defaultAuras[1966]   = FILTER_ON_PLAYER -- Feint
	defaultAuras[51690]  = FILTER_ON_PLAYER -- Killing Spree
	defaultAuras[84746]  = FILTER_ON_PLAYER -- Moderate Insight
	defaultAuras[73651]  = FILTER_ON_PLAYER -- Recuperate
	defaultAuras[121472] = FILTER_ON_PLAYER -- Shadow Blades
	defaultAuras[51713]  = FILTER_ON_PLAYER -- Shadow Dance
	defaultAuras[114842] = FILTER_ON_PLAYER -- Shadow Walk
	defaultAuras[36554]  = FILTER_ON_PLAYER -- Shadowstep
	defaultAuras[84745]  = FILTER_ON_PLAYER -- Shallow Insight
	defaultAuras[114018] = FILTER_ON_PLAYER -- Shroud of Concealment
	defaultAuras[5171]   = FILTER_ON_PLAYER -- Slice and Dice
	defaultAuras[76577]  = FILTER_ON_PLAYER -- Smoke Bomb
	defaultAuras[2983]   = FILTER_ON_PLAYER -- Sprint
	defaultAuras[57934]  = FILTER_ON_PLAYER -- Tricks of the Trade
	defaultAuras[1856]   = FILTER_ON_PLAYER -- Vanish
	-- Debuffs
	defaultAuras[2094]   = FILTER_ON_ENEMY -- Blind
	defaultAuras[1833]   = FILTER_ON_ENEMY -- Cheap Shot
--	defaultAuras[122233] = FILTER_BY_PLAYER -- Crimson Tempest
--	defaultAuras[3409]   = FILTER_BY_PLAYER -- Crippling Poison
--	defaultAuras[2818]   = FILTER_BY_PLAYER -- Deadly Poison
	defaultAuras[26679]  = FILTER_BY_PLAYER -- Deadly Throw
	defaultAuras[51722]  = FILTER_ON_ENEMY -- Dismantle -- TODO: generic Disarm group
	defaultAuras[91021]  = FILTER_BY_PLAYER -- Find Weakness
	defaultAuras[703]    = FILTER_BY_PLAYER -- Garrote
	defaultAuras[1330]   = FILTER_BY_PLAYER -- Garrote - Silence
	defaultAuras[1773]   = FILTER_BY_PLAYER -- Gouge
	defaultAuras[16511]  = FILTER_BY_PLAYER -- Hemorrhage
	defaultAuras[408]    = FILTER_BY_PLAYER -- Kidney Shot
	defaultAuras[112961] = FILTER_BY_PLAYER -- Leeching Poison
	defaultAuras[5760]   = FILTER_BY_PLAYER -- Mind-numbing Poison
	defaultAuras[112947] = FILTER_BY_PLAYER -- Nerve Strike
	defaultAuras[113952] = FILTER_BY_PLAYER -- Paralytic Poison
	defaultAuras[84617]  = FILTER_BY_PLAYER -- Revealing Strike
	defaultAuras[1943]   = FILTER_BY_PLAYER -- Rupture
	defaultAuras[57933]  = FILTER_BY_PLAYER -- Tricks of the Trade
	defaultAuras[79140]  = FILTER_BY_PLAYER -- Vendetta
	defaultAuras[8680]   = FILTER_BY_PLAYER -- Wound Poison
end

------------------------------------------------------------------------
-- Shaman

if playerClass == "SHAMAN" then
	-- Self Buffs
	defaultAuras[108281] = FILTER_ON_PLAYER -- Ancestral Guidance
	defaultAuras[16188]  = FILTER_ON_PLAYER -- Ancestral Swiftness
	defaultAuras[114050] = FILTER_ON_PLAYER -- Ascendance (elemental)
	defaultAuras[114051] = FILTER_ON_PLAYER -- Ascendance (enhancement)
	defaultAuras[114052] = FILTER_ON_PLAYER -- Ascendance (restoration)
	defaultAuras[108271] = FILTER_ON_PLAYER -- Astral Shift
	defaultAuras[16166]  = FILTER_ON_PLAYER -- Elemental Mastery
	defaultAuras[77762]  = FILTER_ON_PLAYER -- Lava Surge
	defaultAuras[31616]  = FILTER_ON_PLAYER -- Nature's Guardian
	defaultAuras[77661]  = FILTER_ON_PLAYER -- Searing Flames
	defaultAuras[30823]  = FILTER_ON_PLAYER -- Shamanistic Rage
	defaultAuras[58876]  = FILTER_ON_PLAYER -- Spirit Walk
	defaultAuras[79206]  = FILTER_ON_PLAYER -- Spiritwalker's Grace
	defaultAuras[53390]  = FILTER_ON_PLAYER -- Tidal Waves
	-- Buffs
--	defaultAuras[2825]   = FILTER_ON_FRIEND -- Bloodlust (SH) -- show all
--	defaultAuras[32182]  = FILTER_ON_FRIEND -- Heroism (SH) -- show all
	defaultAuras[974]    = FILTER_BY_PLAYER -- Earth Shield
	defaultAuras[8178]   = FILTER_ON_FRIEND -- Grounding Totem Effect
	defaultAuras[89523]  = FILTER_ON_FRIEND -- Grounding Totem (reflect)
	defaultAuras[119523] = FILTER_ON_FRIEND -- Healing Stream Totem (resistance)
	defaultAuras[16191]  = FILTER_ON_FRIEND -- Mana Tide
	defaultAuras[61295]  = FILTER_BY_PLAYER -- Riptide
	defaultAuras[98007]  = FILTER_ON_FRIEND -- Spirit Link Totem
	defaultAuras[114893] = FILTER_ON_FRIEND -- Stone Bulwark
	defaultAuras[73685]  = FILTER_ON_PLAYER -- Unleash Life
	defaultAuras[118473] = FILTER_BY_PLAYER -- Unleashed Fury (Earthliving)
	defaultAuras[114896] = FILTER_ON_FRIEND -- Windwalk Totem
	-- Debuffs
	defaultAuras[61882]  = FILTER_BY_PLAYER -- Earthquake
	defaultAuras[8050]   = FILTER_BY_PLAYER -- Flame Shock
	defaultAuras[115356] = FILTER_BY_PLAYER -- Stormblast
	defaultAuras[17364]  = FILTER_BY_PLAYER -- Stormstrike
--	defaultAuras[73684]  = FILTER_BY_PLAYER -- Unleash Earth
	defaultAuras[73682]  = FILTER_BY_PLAYER -- Unleash Frost
	defaultAuras[118470] = FILTER_BY_PLAYER -- Unleashed Fury (Flametongue)
	-- Debuffs - Root/Slow
	defaultAuras[3600]   = FILTER_ON_ENEMY  -- Earthbind <-- Earthbind Totem
	defaultAuras[64695]  = FILTER_ON_ENEMY  -- Earthgrab <-- Earthgrab Totem
	defaultAuras[8056]   = FILTER_ON_ENEMY  -- Frost Shock
	defaultAuras[8034]   = FILTER_BY_PLAYER -- Frostbrand Attack <-- Frostbrand Weapon
	defaultAuras[63685]  = FILTER_ON_ENEMY  -- Freeze <-- Frozen Power
	defaultAuras[118905] = FILTER_ON_ENEMY  -- Static Charge <-- Capacitor Totem
--	defaultAuras[51490]  = FILTER_ON_ENEMY  -- Thunderstorm
end

------------------------------------------------------------------------
-- Warlock

if playerClass == "WARLOCK" then
	-- Self Buffs
	defaultAuras[116198] = FILTER_BY_PLAYER -- Aura of Enfeeblement
	defaultAuras[116202] = FILTER_BY_PLAYER -- Aura of the Elements
	defaultAuras[117828] = FILTER_ON_PLAYER -- Backdraft
	defaultAuras[111400] = FILTER_ON_PLAYER -- Burning Rush
	defaultAuras[114168] = FILTER_ON_PLAYER -- Dark Apotheosis
	defaultAuras[110913] = FILTER_ON_PLAYER -- Dark Bargain (absorb)
	defaultAuras[110914] = FILTER_ON_PLAYER -- Dark Bargain (dot)
	defaultAuras[108359] = FILTER_ON_PLAYER -- Dark Regeneration
	defaultAuras[113858] = FILTER_ON_PLAYER -- Dark Soul: Instability
	defaultAuras[113861] = FILTER_ON_PLAYER -- Dark Soul: Knowledge
	defaultAuras[113860] = FILTER_ON_PLAYER -- Dark Soul: Misery
	defaultAuras[88448]  = FILTER_ON_PLAYER -- Demonic Rebirth
	defaultAuras[126]    = FILTER_ON_PLAYER -- Eye of Kilrogg
	defaultAuras[108683] = FILTER_ON_PLAYER -- Fire and Brimstone
	defaultAuras[119839] = FILTER_ON_PLAYER -- Fury Ward
	defaultAuras[119049] = FILTER_ON_PLAYER -- Kil'jaeden's Cunning
	defaultAuras[126090] = FILTER_ON_PLAYER -- Molten Core -- NEEDS CHECK
	defaultAuras[122355] = FILTER_ON_PLAYER -- Molten Core -- NEEDS CHECK
	defaultAuras[104232] = FILTER_ON_PLAYER -- Rain of Fire
	defaultAuras[108416] = FILTER_ON_PLAYER -- Sacrificial Pact
	defaultAuras[86211]  = FILTER_ON_PLAYER -- Soul Swap
	defaultAuras[104773] = FILTER_ON_PLAYER -- Unending Resolve
	-- Buffs
	defaultAuras[20707]  = FILTER_ON_FRIEND -- Soulstone -- TODO: hide on self?
	-- Debuffs
	defaultAuras[980]    = FILTER_BY_PLAYER -- Agony
	defaultAuras[124915] = FILTER_BY_PLAYER -- Chaos Wave
	defaultAuras[17962]  = FILTER_BY_PLAYER -- Conflagrate (slow)
	defaultAuras[172]    = FILTER_BY_PLAYER -- Corruption -- NEEDS CHECK
	defaultAuras[131740] = FILTER_BY_PLAYER -- Corruption -- NEEDS CHECK
	defaultAuras[146739] = FILTER_BY_PLAYER -- Corruption -- NEEDS CHECK
	defaultAuras[109466] = FILTER_BY_PLAYER -- Curse of Enfeeblement
	defaultAuras[18223]  = FILTER_BY_PLAYER -- Curse of Exhaustion
	defaultAuras[1490]   = FILTER_BY_PLAYER -- Curse of the Elements
	defaultAuras[603]    = FILTER_BY_PLAYER -- Doom
	defaultAuras[48181]  = FILTER_BY_PLAYER -- Haunt
	defaultAuras[80240]  = FILTER_BY_PLAYER -- Havoc
	defaultAuras[157736] = FILTER_BY_PLAYER -- Immolate (changed in WOD)
	defaultAuras[108686] = FILTER_BY_PLAYER -- Immolate <-- Fire and Brimstone
	defaultAuras[60947]  = FILTER_BY_PLAYER -- Nightmare
	defaultAuras[30108]  = FILTER_BY_PLAYER -- Seed of Corruption
	defaultAuras[47960]  = FILTER_BY_PLAYER -- Shadowflame
	defaultAuras[30283]  = FILTER_BY_PLAYER -- Shadowfury
	defaultAuras[27243]  = FILTER_BY_PLAYER -- Unstable Affliction
	-- Debuffs - Crowd Control
	defaultAuras[111397] = FILTER_BY_PLAYER   -- Blood Fear
	defaultAuras[137143] = FILTER_BY_PLAYER   -- Blood Horror
	defaultAuras[1098]   = FILTER_BY_PLAYER   -- Enslave Demon
	defaultAuras[6789]   = FILTER_BY_PLAYER   -- Mortal Coil
end

------------------------------------------------------------------------
-- Warrior

if playerClass == "WARRIOR" then
	-- Self Buffs
	defaultAuras[107574] = FILTER_ON_PLAYER -- Avatar
	defaultAuras[18499]  = FILTER_ON_PLAYER -- Berserker Rage
	defaultAuras[46924]  = FILTER_ON_PLAYER -- Bladestorm
	defaultAuras[12292]  = FILTER_ON_PLAYER -- Bloodbath
	defaultAuras[46916]  = FILTER_ON_PLAYER -- Bloodsurge
	defaultAuras[85730]  = FILTER_ON_PLAYER -- Deadly Calm
	defaultAuras[125565] = FILTER_ON_PLAYER -- Demoralizing Shout
	defaultAuras[118038] = FILTER_ON_PLAYER -- Die by the Sword
	defaultAuras[12880]  = FILTER_ON_PLAYER -- Enrage
	defaultAuras[55964]  = FILTER_ON_PLAYER -- Enraged Regeneration
	defaultAuras[115945] = FILTER_ON_PLAYER -- Glyph of Hamstring
	defaultAuras[12975]  = FILTER_ON_PLAYER -- Last Stand
	defaultAuras[114028] = FILTER_ON_PLAYER -- Mass Spell Reflection
	defaultAuras[85739]  = FILTER_ON_PLAYER -- Meat Cleaver
	defaultAuras[114192] = FILTER_ON_PLAYER -- Mocking Banner
	defaultAuras[97463]  = FILTER_ON_PLAYER -- Rallying Cry
	defaultAuras[1719]   = FILTER_ON_PLAYER -- Recklessness
	defaultAuras[112048] = FILTER_ON_PLAYER -- Shield Barrier
	defaultAuras[2565]   = FILTER_ON_PLAYER -- Shield Block
	defaultAuras[871]    = FILTER_ON_PLAYER -- Shield Wall
	defaultAuras[114206] = FILTER_ON_PLAYER -- Skull Banner
	defaultAuras[23920]  = FILTER_ON_PLAYER -- Spell Banner
	defaultAuras[52437]  = FILTER_ON_PLAYER -- Sudden Death
	defaultAuras[12328]  = FILTER_ON_PLAYER -- Sweeping Strikes
	defaultAuras[50227]  = FILTER_ON_PLAYER -- Sword and Board
	defaultAuras[125831] = FILTER_ON_PLAYER -- Taste for Blood
	defaultAuras[122510] = FILTER_ON_PLAYER -- Ultimatum
	-- Buffs
	defaultAuras[46947]  = FILTER_ON_FRIEND -- Safeguard (damage reduction)
	defaultAuras[114029] = FILTER_ON_FRIEND -- Safeguard (intercept)
	defaultAuras[114030] = FILTER_ON_FRIEND -- Vigilance
	-- Debuffs
	defaultAuras[86346]  = FILTER_BY_PLAYER -- Colossus Smash -- DEPRECATED?
	defaultAuras[167105] = FILTER_BY_PLAYER -- Colossus Smash
	defaultAuras[114205] = FILTER_BY_PLAYER -- Demoralizing Banner
	defaultAuras[1160]   = FILTER_BY_PLAYER -- Demoralizing Shout
	defaultAuras[676]    = FILTER_BY_PLAYER -- Disarm
	defaultAuras[118895] = FILTER_BY_PLAYER -- Dragon Roar
	defaultAuras[1715]   = FILTER_BY_PLAYER -- Hamstring
	defaultAuras[5246]   = FILTER_BY_PLAYER -- Intimidating Shout -- NEEDS CHECK
	defaultAuras[20511]  = FILTER_BY_PLAYER -- Intimidating Shout -- NEEDS CHECK
	defaultAuras[12323]  = FILTER_BY_PLAYER -- Piercing Howl
	defaultAuras[772]    = FILTER_BY_PLAYER -- Rend
	defaultAuras[64382]  = FILTER_BY_PLAYER -- Shattering Throw
	defaultAuras[46968]  = FILTER_BY_PLAYER -- Shockwave
	defaultAuras[18498]  = FILTER_BY_PLAYER -- Silenced - Gag Order
	defaultAuras[107566] = FILTER_BY_PLAYER -- Staggering Shout
	defaultAuras[107570] = FILTER_BY_PLAYER -- Storm Bolt -- DEPRECATED?
	defaultAuras[132169] = FILTER_BY_PLAYER -- Storm Bolt
	defaultAuras[355]    = FILTER_BY_PLAYER -- Taunt
	defaultAuras[105771] = FILTER_BY_PLAYER -- Warbringer
end

------------------------------------------------------------------------
-- Racials

local _, playerRace = UnitRace("player")
if playerRace == "BloodElf" then
	defaultAuras[50613]  = FILTER_BY_PLAYER -- Arcane Torrent (DK)
	defaultAuras[80483]  = FILTER_BY_PLAYER -- Arcane Torrent (HU)
	defaultAuras[28730]  = FILTER_BY_PLAYER -- Arcane Torrent (MA, PA, PR, WL)
	defaultAuras[129597] = FILTER_BY_PLAYER -- Arcane Torrent (MO)
	defaultAuras[25046]  = FILTER_BY_PLAYER -- Arcane Torrent (RO)
	defaultAuras[69179]  = FILTER_BY_PLAYER -- Arcane Torrent (WR)
elseif playerRace == "Draenei" then
	defaultAuras[59545]  = FILTER_BY_PLAYER -- Gift of the Naaru (DK)
	defaultAuras[59543]  = FILTER_BY_PLAYER -- Gift of the Naaru (HU)
	defaultAuras[59548]  = FILTER_BY_PLAYER -- Gift of the Naaru (MA)
	defaultAuras[121093] = FILTER_BY_PLAYER -- Gift of the Naaru (MO)
	defaultAuras[59542]  = FILTER_BY_PLAYER -- Gift of the Naaru (PA)
	defaultAuras[59544]  = FILTER_BY_PLAYER -- Gift of the Naaru (PR)
	defaultAuras[59547]  = FILTER_BY_PLAYER -- Gift of the Naaru (SH)
	defaultAuras[28880]  = FILTER_BY_PLAYER -- Gift of the Naaru (WR)
elseif playerRace == "Dwarf" then
	defaultAuras[20594]  = FILTER_ON_PLAYER -- Stoneform
elseif playerRace == "NightElf" then
	defaultAuras[58984]  = FILTER_ON_PLAYER -- Shadowmeld
elseif playerRace == "Orc" then
	defaultAuras[20572]  = FILTER_ON_PLAYER -- Blood Fury (attack power)
	defaultAuras[33702]  = FILTER_ON_PLAYER -- Blood Fury (spell power)
	defaultAuras[33697]  = FILTER_ON_PLAYER -- Blood Fury (attack power and spell damage)
elseif playerRace == "Pandaren" then
	defaultAuras[107079] = FILTER_ON_PLAYER -- Quaking Palm
elseif playerRace == "Scourge" then
	defaultAuras[7744]   = FILTER_ON_PLAYER -- Will of the Forsaken
elseif playerRace == "Tauren" then
	defaultAuras[20549]  = FILTER_ALL -- War Stomp
elseif playerRace == "Troll" then
	defaultAuras[26297]  = FILTER_ON_PLAYER -- Berserking
elseif playerRace == "Worgen" then
	defaultAuras[68992]  = FILTER_ON_PLAYER -- Darkflight
end

------------------------------------------------------------------------
-- Taunts (tanks only)

if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "MONK" or playerClass == "PALADIN" or playerClass == "WARRIOR" then
	defaultAuras[56222]  = FILTER_ROLE_TANK -- Dark Command (DK)
	defaultAuras[57604]  = FILTER_ROLE_TANK -- Death Grip (DK) -- NEEDS CHECK 49560 51399 57603
	defaultAuras[6795]   = FILTER_ROLE_TANK -- Growl (DR)
	defaultAuras[20736]  = FILTER_ROLE_TANK -- Distracting Shot (HU)
	defaultAuras[118585] = FILTER_ROLE_TANK -- Leer of the Ox (MO)
	defaultAuras[116189] = FILTER_ROLE_TANK -- Provoke (MO)
	defaultAuras[118635] = FILTER_ROLE_TANK -- Provoke (MO Black Ox Statue) -- NEEDS CHECK
	defaultAuras[62124]  = FILTER_ROLE_TANK -- Reckoning (PA)
	defaultAuras[36213]  = FILTER_ROLE_TANK -- Angered Earth (SH Earth Elemental)
	defaultAuras[17735]  = FILTER_ROLE_TANK -- Suffering (WL Voidwalker)
	defaultAuras[114198] = FILTER_ROLE_TANK -- Mocking Banner (WR)
	defaultAuras[355]    = FILTER_ROLE_TANK -- Taunt (WR)
end

------------------------------------------------------------------------
-- PvP

local function AddAurasForPVP(t)
	-- Disorient
	t[2094]   = FILTER_PVP -- Blind (RO)
	t[105421] = FILTER_PVP -- Blinding Light (PA)
	t[33786]  = FILTER_PVP -- Cyclone (DR)
	t[118699] = FILTER_PVP -- Fear (WL)
	t[130616] = FILTER_PVP -- Fear (WL Glyph of Fear)
	t[5484]   = FILTER_PVP -- Howl of Terror (WL)
	t[5246]   = FILTER_PVP -- Intimidating Shout (WR)
	t[115268] = FILTER_PVP -- Mesmerize (WL shivarra)
	t[8122]   = FILTER_PVP -- Psychic Scream (PR)
	t[6358]   = FILTER_PVP -- Seduction (WL succubus)
	t[10326]  = FILTER_PVP -- Turn Evil (PA)
	-- Knockback
	t[119403] = FILTER_PVP -- Glyph of Explosive Trap (HU)
	t[115770] = FILTER_PVP -- Fellash (WL Shivarra)
	t[108199] = FILTER_PVP -- Gorefiend's Grasp (DK)
	t[51490]  = FILTER_PVP -- Thunderstorm (SH)
	t[132469] = FILTER_PVP -- Typhoon (DR)
	t[102793] = FILTER_PVP -- Ursol's Vortex (DR)
	t[6360]   = FILTER_PVP -- Whiplash (WL Succubus)
	-- Incapacitate
	t[710]    = FILTER_PVP -- Banish (WL)
	t[137143] = FILTER_PVP -- Blood Horror (WL) -- NEEDS CHECK
	t[111397] = FILTER_PVP -- Blood Horror (WL) -- NEEDS CHECK
	t[123393] = FILTER_PVP -- Breath of Fire (MO with glyph)
	t[605]    = FILTER_PVP -- Dominate Mind (PR)
	t[31661]  = FILTER_PVP -- Dragon's Breath (MA)
	t[1776]   = FILTER_PVP -- Gouge (RO)
	t[51514]  = FILTER_PVP -- Hex (SH)
	t[88625]  = FILTER_PVP -- Holy Word: Chastise (PR)
	t[99]     = FILTER_PVP -- Incapacitating Roar (DR)
	t[6789]   = FILTER_PVP -- Mortal Coil (WL)
	t[115078] = FILTER_PVP -- Paralysis (MO)
	t[64044]  = FILTER_PVP -- Psychic Horror (PR)
	t[107179] = FILTER_PVP -- Quaking Palm (Pandaren)
	t[20066]  = FILTER_PVP -- Repentence (PA)
	t[82691]  = FILTER_PVP -- Ring of Frost (MA)
	t[116844] = FILTER_PVP -- Ring of Peace (MO) -- NEEDS CHECK
	t[137460] = FILTER_PVP -- Ring of Peace (MO) -- NEEDS CHECK
	t[6770]   = FILTER_PVP -- Sap (RO)
	t[8484]   = FILTER_PVP -- Shackle Undead (PR)
	-- Root
	t[96294]  = FILTER_PVP -- Chains of Ice (DK Chilblains)
	t[53148]  = FILTER_PVP -- Charge (HU tenacity pet)
	t[116706] = FILTER_PVP -- Disable (MO)
	t[64695]  = FILTER_PVP -- Earthgrab Totem (SH)
	t[339]    = FILTER_PVP -- Entangling Roots (DR)
	t[113770] = FILTER_PVP -- Entangling Roots (DR treants)
	t[33395]  = FILTER_PVP -- Freeze (MA Water Elemental)
	t[63685]  = FILTER_PVP -- Freeze (SH talent Frozen Power)
	t[122]    = FILTER_PVP -- Frost Nova (MA)
	t[135373] = FILTER_PVP -- Entrapment (HU passive)
	t[87194]  = FILTER_PVP -- Glyph of Mind Blast (PR)
	t[111340] = FILTER_PVP -- Ice Ward (MA)
	t[102359] = FILTER_PVP -- Mass Entanglement (DR talent)
	t[136634] = FILTER_PVP -- Narrow Escape (HU passive talent)
	t[114404] = FILTER_PVP -- Void Tendrils (PR)
	-- Silence
	t[25046]  = FILTER_PVP -- Arcane Torrent (Blood Elf - Rogue)
	t[28730]  = FILTER_PVP -- Arcane Torrent (Blood Elf - Mage, Paladin, Priest, Warlock)
	t[50613]  = FILTER_PVP -- Arcane Torrent (Blood Elf - Death Knight)
	t[69179]  = FILTER_PVP -- Arcane Torrent (Blood Elf - Warrior)
	t[80483]  = FILTER_PVP -- Arcane Torrent (Blood Elf - Hunter)
	t[129597] = FILTER_PVP -- Arcane Torrent (Blood Elf - Monk)
	t[108194] = FILTER_PVP -- Asphyxiate (DK, functions as silence if target immune to stun)
	t[31935]  = FILTER_PVP -- Avenger's Shield (PA)
	t[102051] = FILTER_PVP -- Frostjaw (MA)
	t[1330]   = FILTER_PVP -- Garrote - Silence (RO)
	t[114237] = FILTER_PVP -- Glyph of Fae Silence (DR) -- NEEDS CHECK
	t[50479]  = FILTER_PVP -- Nether Shock (HU Nether Ray)
	t[15487]  = FILTER_PVP -- Silence (PR)
	t[18498]  = FILTER_PVP -- Silenced - Gag Order (WR)
	t[34490]  = FILTER_PVP -- Silencing Shot (HU)
	t[78675]  = FILTER_PVP -- Solar Beam (DR)
	t[97547]  = FILTER_PVP -- Solar Beam (DR)
	t[116709] = FILTER_PVP -- Spear Hand Strike (MO)
	t[24259]  = FILTER_PVP -- Spell Lock (WL Felhunter)
	t[47476]  = FILTER_PVP -- Strangulate (DK)
	-- Stun
	t[108194] = FILTER_PVP -- Asphyxiate (DK)
	t[89766]  = FILTER_PVP -- Axe Toss (WL Felguard)
	t[117526] = FILTER_PVP -- Binding Shot (HU)
	t[119392] = FILTER_PVP -- Charging Ox Wave (MO)
	t[1833]   = FILTER_PVP -- Cheap Shot (RO)
	t[44572]  = FILTER_PVP -- Deep Freeze (MA)
	t[105593] = FILTER_PVP -- Fist of Justice (PA)
	t[120086] = FILTER_PVP -- Fists of Fury (MO)
	t[91800]  = FILTER_PVP -- Gnaw (DK Ghoul)
	t[853]    = FILTER_PVP -- Hammer of Justice (PA)
	t[119072] = FILTER_PVP -- Holy Wrath (PA)
	t[24394]  = FILTER_PVP -- Intimidation (HU pet)
	t[408]    = FILTER_PVP -- Kidney Shot (RO)
	t[22570]  = FILTER_PVP -- Maim (DR)
	t[119381] = FILTER_PVP -- Leg Sweep (MO)
	t[5211]   = FILTER_PVP -- Mighty Bash (DR)
	t[91797]  = FILTER_PVP -- Monstrous Blow (DK Ghoul with Transformation)
	t[118345] = FILTER_PVP -- Pulverize (SH Primal Earth Elemental)
	t[163505] = FILTER_PVP -- Rake (DR with Prowl)
	t[115001] = FILTER_PVP -- Remorseless Winter (DK)
	t[30283]  = FILTER_PVP -- Shadowfury (WL)
	t[132168] = FILTER_PVP -- Shockwave (WR)
	t[118905] = FILTER_PVP -- Static Charge (SH Capacitor Totem)
	t[132169] = FILTER_PVP -- Storm Bolt (WR)
	t[22703]  = FILTER_PVP -- Summon Infernal (WL)
	t[20549]  = FILTER_PVP -- War Stomp (Tauren)
	-- Healing Reduction
	t[115804] = FILTER_PVP -- Mortal Wounds (WR, MO, HU Carrion Bird, Crocolisk, Riverbeast, Scorpid)
	t[54680]  = FILTER_PVP -- Monstrous Bite (HU Devilsaur)
	t[82654]  = FILTER_PVP -- Widow Venom (HU)
	t[8680]   = FILTER_PVP -- Wound Poison (RO)
end

-- TODO: Show PVE healing reductions for healers?

------------------------------------------------------------------------

local auraList = {}
ns.AuraList = auraList

local auraList_focus = {}
local auraList_targettarget = {}

local function AddAurasToList(auras)
	local PVP = ns.config.PVP
	local role = ns.GetPlayerRole()
	local filterForRole = roleFilter[role]
	for id, v in pairs(auras) do
		local skip
		if bit_band(v, FILTER_ALL) == 0 then
			if (bit_band(v, FILTER_PVP) > 0 and not PVP)
			or (bit_band(v, FILTER_PVE) > 0 and PVP)
			or (bit_band(v, FILTER_ROLE_MASK) > 0 and bit_band(v, filterForRole) == 0) then
				skip = true
			end
		end
		if not skip then
			auraList[id] = v
			if bit_band(v, FILTER_UNIT_FOCUS) > 0 then
				auraList_focus[id] = v
			end
			if bit_band(v, FILTER_UNIT_TOT) > 0 then
				auraList_targettarget[id] = v
			end
		end
	end
end

ns.UpdateAuraList = function()
	--print("UpdateAuraList")
	wipe(auraList)
	AddAurasToList(ns.defaultAuras)
	AddAurasToList(oUFPhanxAuraConfig.customFilters)
	if ns.config.PVP then
		AddAurasForPVP(auraList)
	end
	-- Remove default auras the player deleted
	for id in pairs(oUFPhanxAuraConfig.deleted) do
		auraList[id] = nil
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

local filterFuncs = {
	default = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		return not v or bit_band(v, FILTER_DISABLE) == 0
	end,
	player = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		--debug("CustomAuraFilter", "[unit]", unit, "[caster]", caster, "[name]", name, "[id]", spellID, "[filter]", v, "[vehicle]", caster == "vehicle")
		if v then
			return checkFilter(v, self, unit, caster)
		end
		return caster and UnitIsUnit(caster, "vehicle") and not UnitIsPlayer("vehicle")
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
			-- if show then debug("CustomAuraFilter", spellID, name, "BOSS") end
			return show
		elseif v then
			local show = checkFilter(v, self, unit, caster)
			-- if show then debug("CustomAuraFilter", spellID, name, "FILTER", v, caster) end
			return show
		elseif not caster and not IsInInstance() then
			-- EXPERIMENTAL: ignore debuffs from players outside the group, eg. on world bosses.
			return
		elseif UnitCanAttack("player", unit) and not UnitPlayerControlled(unit) then
			-- Hostile NPC. Show auras cast by the unit, or auras cast by the player's vehicle.
			-- print("hostile NPC")
			local show = not caster or caster == unit or (UnitIsUnit(caster, "vehicle") and not UnitIsPlayer("vehicle"))
			-- if show then debug("CustomAuraFilter", spellID, name, (not caster) and "UNKNOWN" or (caster == unit) and "SELFCAST" or "VEHICLE") end
			return show
		else
			-- Friendly target or hostile player. Show auras cast by the player's vehicle.
			-- print("hostile player / friendly unit")
			local show = not caster or (UnitIsUnit(caster, "vehicle") and not UnitIsPlayer("vehicle"))
			-- if show then debug("CustomAuraFilter", spellID, name, (not caster) and "UNKNOWN" or "VEHICLE") end
			return show
		end
	end,
	party = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		return v and bit_band(v, FILTER_ON_PLAYER) == 0
	end,
}

filterFuncs.focus = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
	if auraList_focus[id] then
		return filterFuncs.target(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
	end
end

filterFuncs.targettarget = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
	if auraList_targettarget[id] then
		return filterFuncs.target(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer, value1, value2, value3)
	end
end

ns.CustomAuraFilters = filterFuncs
