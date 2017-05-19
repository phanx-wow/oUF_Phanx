--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	https://mods.curse.com/addons/wow/ouf-phanx
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
local FILTER_ALL          = 0x1000000
local FILTER_DISABLE      = 0x2000000

local FILTER_UNIT_FOCUS   = 0x0100000 -- Additionally show on focus frame
local FILTER_UNIT_TOT     = 0x0200000 -- Additionally show on tot frame

local FILTER_ROLE_MASK    = 0x00F0000
local FILTER_ROLE_TANK    = 0x0010000
local FILTER_ROLE_HEALER  = 0x0020000
local FILTER_ROLE_DAMAGER = 0x0040000

-- Dynamic filters, checked in realtime:
local FILTER_BY_MASK      = 0x000FF00
local FILTER_BY_PLAYER    = 0x0000100

local FILTER_ON_MASK      = 0x00000FF
local FILTER_ON_PLAYER    = 0x0000001
local FILTER_ON_OTHER     = 0x0000002
local FILTER_ON_FRIEND    = 0x0000004
local FILTER_ON_ENEMY     = 0x0000008

ns.auraFilterValues = {
	FILTER_ALL            = FILTER_ALL,
	FILTER_DISABLE        = FILTER_DISABLE,

	FILTER_UNIT_FOCUS     = FILTER_UNIT_FOCUS,
	FILTER_UNIT_TOT       = FILTER_UNIT_TOT,

	FILTER_ROLE_MASK      = FILTER_ROLE_MASK,
	FILTER_ROLE_TANK      = FILTER_ROLE_TANK,
	FILTER_ROLE_HEALER    = FILTER_ROLE_HEALER,
	FILTER_ROLE_DAMAGER   = FILTER_ROLE_DAMAGER,

	FILTER_BY_MASK        = FILTER_BY_MASK,
	FILTER_BY_PLAYER      = FILTER_BY_PLAYER,

	FILTER_ON_MASK        = FILTER_ON_MASK,
	FILTER_ON_PLAYER      = FILTER_ON_PLAYER,
	FILTER_ON_OTHER       = FILTER_ON_OTHER,
	FILTER_ON_FRIEND      = FILTER_ON_FRIEND,
	FILTER_ON_ENEMY       = FILTER_ON_ENEMY,
}

local roleFilter = {
	TANK    = FILTER_ROLE_TANK,
	HEALER  = FILTER_ROLE_HEALER,
	DAMAGER = FILTER_ROLE_DAMAGER,
}

------------------------------------------------------------------------

local a = {
	-- Bloodlust
	[ 90355] = FILTER_ON_PLAYER, -- Ancient Hysteria
	[  2825] = FILTER_ON_PLAYER, -- Bloodlust
	[ 32182] = FILTER_ON_PLAYER, -- Heroism
	[160452] = FILTER_ON_PLAYER, -- Netherwinds
	[ 80353] = FILTER_ON_PLAYER, -- Time Warp
	-- Other Buffs
	[ 29166] = FILTER_ON_PLAYER, -- Innervate
	[102342] = FILTER_ON_PLAYER, -- Ironbark
	[ 33206] = FILTER_ON_PLAYER, -- Pain Suppression
	[ 10060] = FILTER_ON_PLAYER, -- Power Infusion
	[ 64901] = FILTER_ON_PLAYER, -- Symbol of Hope
	-- Crowd Control
	[   710] = FILTER_ON_ENEMY, -- Banish
	[  2094] = FILTER_ON_ENEMY, -- Blind
	[   339] = FILTER_ON_ENEMY, -- Entangling Roots
	[  5782] = FILTER_ON_ENEMY, -- Fear
	[  3355] = FILTER_ON_ENEMY, -- Freezing Trap -- NEEDS CHECK, 212365
	[ 51514] = FILTER_ON_ENEMY, -- Hex
	[210873] = FILTER_ON_ENEMY, -- Hex (Compy)
	[211015] = FILTER_ON_ENEMY, -- Hex (Cockroach)
	[211010] = FILTER_ON_ENEMY, -- Hex (Snake)
	[211004] = FILTER_ON_ENEMY, -- Hex (Spider)
	[196942] = FILTER_ON_ENEMY, -- Hex (Voodoo Totem)
	[  5484] = FILTER_ON_ENEMY, -- Howl of Terror
	[217832] = FILTER_ON_ENEMY, -- Imprison
	[199743] = FILTER_ON_ENEMY, -- Parley
	[   118] = FILTER_ON_ENEMY, -- Polymorph
	[ 61308] = FILTER_ON_ENEMY, -- Polymorph (Black Cat)
	[161354] = FILTER_ON_ENEMY, -- Polymorph (Monkey)
	[161372] = FILTER_ON_ENEMY, -- Polymorph (Peacock)
	[161355] = FILTER_ON_ENEMY, -- Polymorph (Penguin)
	[ 28272] = FILTER_ON_ENEMY, -- Polymorph (Pig)
	[161353] = FILTER_ON_ENEMY, -- Polymorph (Polar Bear Cub)
	[126819] = FILTER_ON_ENEMY, -- Polymorph (Porcupine)
	[ 61721] = FILTER_ON_ENEMY, -- Polymorph (Rabbit)
	[ 61780] = FILTER_ON_ENEMY, -- Polymorph (Turkey)
	[ 28271] = FILTER_ON_ENEMY, -- Polymorph (Turtle)
	[ 20066] = FILTER_ON_ENEMY, -- Repentance
	[  6770] = FILTER_ON_ENEMY, -- Sap
	[  6358] = FILTER_ON_ENEMY, -- Seduction
	[  9484] = FILTER_ON_ENEMY, -- Shackle Undead
	[162480] = FILTER_ON_ENEMY, -- Steel Trap
	[ 19386] = FILTER_ON_ENEMY, -- Wyvern Sting
	-- Consumables - Legion
	[188030] = FILTER_BY_PLAYER, -- Leytorrent Potion -- channeled
	[188027] = FILTER_BY_PLAYER, -- Potion of Deadly Grace
	[188028] = FILTER_BY_PLAYER, -- Potion of the Old War
	[188029] = FILTER_BY_PLAYER, -- Unbending Potion
	-- Random quest related auras
	[127372] = FILTER_ON_PLAYER, -- Unstable Serum (Klaxxi Enhancement: Raining Blood)
	-- Boss debuffs that Blizzard failed to flag
	[106648] = FILTER_ALL, -- Brew Explosion (Ook Ook in Stormsnout Brewery)
	[106784] = FILTER_ALL, -- Brew Explosion (Ook Ook in Stormsnout Brewery)
	[123059] = FILTER_ALL, -- Destabilize (Amber-Shaper Un'sok)
	-- NPC buffs that are completely useless
	[ 63501] = FILTER_DISABLE, -- Argent Crusade Champion's Pennant
	[ 60023] = FILTER_DISABLE, -- Scourge Banner Aura (Boneguard Commander in Icecrown)
	[ 63406] = FILTER_DISABLE, -- Darnassus Champion's Pennant
	[ 63405] = FILTER_DISABLE, -- Darnassus Valiant's Pennant
	[ 63423] = FILTER_DISABLE, -- Exodar Champion's Pennant
	[ 63422] = FILTER_DISABLE, -- Exodar Valiant's Pennant
	[ 63396] = FILTER_DISABLE, -- Gnomeregan Champion's Pennant
	[ 63395] = FILTER_DISABLE, -- Gnomeregan Valiant's Pennant
	[ 63427] = FILTER_DISABLE, -- Ironforge Champion's Pennant
	[ 63426] = FILTER_DISABLE, -- Ironforge Valiant's Pennant
	[ 63433] = FILTER_DISABLE, -- Orgrimmar Champion's Pennant
	[ 63432] = FILTER_DISABLE, -- Orgrimmar Valiant's Pennant
	[ 63399] = FILTER_DISABLE, -- Sen'jin Champion's Pennant
	[ 63398] = FILTER_DISABLE, -- Sen'jin Valiant's Pennant
	[ 63403] = FILTER_DISABLE, -- Silvermoon Champion's Pennant
	[ 63402] = FILTER_DISABLE, -- Silvermoon Valiant's Pennant
	[ 62594] = FILTER_DISABLE, -- Stormwind Champion's Pennant
	[ 62596] = FILTER_DISABLE, -- Stormwind Valiant's Pennant
	[ 63436] = FILTER_DISABLE, -- Thunder Bluff Champion's Pennant
	[ 63435] = FILTER_DISABLE, -- Thunder Bluff Valiant's Pennant
	[ 63430] = FILTER_DISABLE, -- Undercity Champion's Pennant
	[ 63429] = FILTER_DISABLE, -- Undercity Valiant's Pennant
}

ns.defaultAuras = a

------------------------------------------------------------------------
-- Death Knight

if playerClass == "DEATHKNIGHT" then
	-- Abilities
	a[ 48707] = FILTER_BY_PLAYER -- Anti-Magic Shell
	a[221562] = FILTER_BY_PLAYER -- Asphyxiate -- NEEDS CHECK, 108194
	a[206977] = FILTER_BY_PLAYER -- Blood Mirror
	a[ 55078] = FILTER_BY_PLAYER -- Blood Plague
	a[195181] = FILTER_BY_PLAYER -- Bone Shield
	a[ 45524] = FILTER_BY_PLAYER -- Chains of Ice
	a[111673] = FILTER_BY_PLAYER -- Control Undead
	a[207319] = FILTER_BY_PLAYER -- Corpse Shield
	a[101568] = FILTER_BY_PLAYER -- Dark Succor
	a[194310] = FILTER_BY_PLAYER -- Festering Wound
	a[190780] = FILTER_BY_PLAYER -- Frost Breath
	a[ 55095] = FILTER_BY_PLAYER -- Frost Fever
	a[206930] = FILTER_BY_PLAYER -- Heart Strike
	a[ 48792] = FILTER_BY_PLAYER -- Icebound Fortitude
	a[194879] = FILTER_BY_PLAYER -- Icy Talons
	a[ 51124] = FILTER_BY_PLAYER -- Killing Machine
	a[206940] = FILTER_BY_PLAYER -- Mark of Blood
	a[216974] = FILTER_BY_PLAYER -- Necrosis
	a[207256] = FILTER_BY_PLAYER -- Obliteration
	a[219788] = FILTER_BY_PLAYER -- Ossuary
	a[  3714] = FILTER_BY_PLAYER -- Path of Frost -- TODO: show only OOC
	a[ 51271] = FILTER_BY_PLAYER -- Pillar of Frost
	a[196770] = FILTER_BY_PLAYER -- Remorseless Winter (self)
	a[211793] = FILTER_BY_PLAYER -- Remorseless Winter (slow)
	a[ 59052] = FILTER_BY_PLAYER -- Rime
	a[130736] = FILTER_BY_PLAYER -- Soul Reaper
	a[ 55233] = FILTER_BY_PLAYER -- Vampiric Blood
	a[191587] = FILTER_BY_PLAYER -- Virulent Plague
	a[211794] = FILTER_BY_PLAYER -- Winter is Coming
	a[212552] = FILTER_BY_PLAYER -- Wraith Walk
	-- Talents
	a[116888] = FILTER_BY_PLAYER -- Shroud of Purgatory (from Purgatory)
	-- Artifact Traits
	a[191748] = FILTER_BY_PLAYER -- Scouge of Worlds
end

------------------------------------------------------------------------
-- Demon Hunter

if playerClass == "DEMONHUNTER" then
	-- Abilities
	a[207709] = FILTER_BY_PLAYER -- Blade Turning
	a[207690] = FILTER_BY_PLAYER -- Bloodlet
	a[212800] = FILTER_BY_PLAYER -- Blur
	a[203819] = FILTER_BY_PLAYER -- Demon Spikes
	a[227330] = FILTER_BY_PLAYER -- Gluttony
	a[218256] = FILTER_BY_PLAYER -- Empower Wards
	a[162264] = FILTER_BY_PLAYER -- Metamorphosis
	a[207810] = FILTER_BY_PLAYER -- Nether Bond
	a[196555] = FILTER_BY_PLAYER -- Netherwalk
	-- Talents
	-- Artifact Traits
end

------------------------------------------------------------------------
-- Druid

if playerClass == "DRUID" then
	a[ 29166] = FILTER_ON_FRIEND -- Innervate
	a[102342] = FILTER_ON_FRIEND -- Ironbark
	a[106898] = FILTER_ON_FRIEND -- Stampeding Roar
	-- Abilities
	a[  1850] = FILTER_BY_PLAYER -- Dash
	a[ 22812] = FILTER_BY_PLAYER -- Barkskin
	a[106951] = FILTER_BY_PLAYER -- Berserk
	a[202739] = FILTER_BY_PLAYER -- Blessing of An'she (Blessing of the Ancients)
	a[202737] = FILTER_BY_PLAYER -- Blessing of Elune (Blessing of the Ancients)
	a[145152] = FILTER_BY_PLAYER -- Bloodtalons
	a[155835] = FILTER_BY_PLAYER -- Bristling Fur
	a[135700] = FILTER_BY_PLAYER -- Clearcasting (Omen of Clarity) (Feral)
	a[ 16870] = FILTER_BY_PLAYER -- Clearcasting (Omen of Clarity) (Restoration)
	a[202060] = FILTER_BY_PLAYER -- Elune's Guidance
	a[ 22842] = FILTER_BY_PLAYER -- Frenzied Regeneration
	a[202770] = FILTER_BY_PLAYER -- Fury of Elune
	a[213709] = FILTER_BY_PLAYER -- Galactic Guardian
	a[213680] = FILTER_BY_PLAYER -- Guardian of Elune
	a[    99] = FILTER_BY_PLAYER -- Incapacitating Roar
	a[102560] = FILTER_BY_PLAYER -- Incarnation: Chosen of Elune
	a[102558] = FILTER_BY_PLAYER -- Incarnation: Guardian of Ursoc
	a[102543] = FILTER_BY_PLAYER -- Incarnation: King of the Jungle
	a[192081] = FILTER_BY_PLAYER -- Ironfur
	a[164547] = FILTER_BY_PLAYER -- Lunar Empowerment
	a[203123] = FILTER_BY_PLAYER -- Maim
	a[192083] = FILTER_BY_PLAYER -- Mark of Ursol
	a[ 33763] = FILTER_BY_PLAYER -- Lifebloom
	a[164812] = FILTER_BY_PLAYER -- Moonfire -- NEEDS CHECK, 8921
	a[155625] = FILTER_BY_PLAYER -- Moonfire (Cat Form)
	a[ 69369] = FILTER_BY_PLAYER -- Predatory Swiftness
	a[158792] = FILTER_BY_PLAYER -- Pulverize
	a[155722] = FILTER_BY_PLAYER -- Rake
	a[  8936] = FILTER_BY_PLAYER -- Regrowth
	a[   774] = FILTER_BY_PLAYER -- Rejuvenation
	a[  1079] = FILTER_BY_PLAYER -- Rip
	a[ 52610] = FILTER_BY_PLAYER -- Savage Roar
	a[ 78675] = FILTER_BY_PLAYER -- Solar Beam
	a[164545] = FILTER_BY_PLAYER -- Solar Empowerment
	a[191034] = FILTER_BY_PLAYER -- Starfire
	a[202347] = FILTER_BY_PLAYER -- Stellar Flare
	a[164815] = FILTER_BY_PLAYER -- Sunfire -- NEEDS CHECK, 93402
	a[ 61336] = FILTER_BY_PLAYER -- Survival Instincts
	a[192090] = FILTER_BY_PLAYER -- Thrash (Bear) -- NEEDS CHECK
	a[106830] = FILTER_BY_PLAYER -- Thrash (Cat)
	a[  5217] = FILTER_BY_PLAYER -- Tiger's Fury
	a[102793] = FILTER_BY_PLAYER -- Ursol's Vortex
	a[202425] = FILTER_BY_PLAYER -- Warrior of Elune
	a[ 48438] = FILTER_BY_PLAYER -- Wild Growth
	-- Talents
	-- Artifact Traits
	a[210723] = FILTER_BY_PLAYER -- Ashmane's Frenzy
	a[200851] = FILTER_BY_PLAYER -- Rage of the Sleeper
	a[210664] = FILTER_BY_PLAYER -- Scent of Blood
end

------------------------------------------------------------------------
-- Hunter

if playerClass == "HUNTER" then
	-- Abilities
	a[131894] = FILTER_BY_PLAYER -- A Murder of Crows (Beast Mastery, Marksmanship)
	a[206505] = FILTER_BY_PLAYER -- A Murder of Crows (Survival)
	a[186257] = FILTER_BY_PLAYER -- Aspect of the Cheetah
	a[186289] = FILTER_BY_PLAYER -- Aspect of the Eagle
	a[186265] = FILTER_BY_PLAYER -- Aspect of the Turtle
	a[193530] = FILTER_BY_PLAYER -- Aspect of the Wild
	a[ 19574] = FILTER_BY_PLAYER -- Bestial Wrath
	a[117526] = FILTER_BY_PLAYER -- Binding Shot (stun)
	a[117405] = FILTER_BY_PLAYER -- Binding Shot (tether)
	a[194279] = FILTER_BY_PLAYER -- Caltrops
	a[199483] = FILTER_BY_PLAYER -- Camouflage
	a[  5116] = FILTER_BY_PLAYER -- Concussive Shot
	a[ 13812] = FILTER_BY_PLAYER -- Explosive Trap -- NEEDS CHECK
	a[  5384] = FILTER_BY_PLAYER -- Feign Death
	a[  3355] = FILTER_BY_PLAYER -- Freezing Trap -- NEEDS CHECK
	a[194594] = FILTER_BY_PLAYER -- Lock and Load
	a[ 34477] = FILTER_BY_PLAYER -- Misdirection
	a[201081] = FILTER_BY_PLAYER -- Mok'Nathal Tactics
	a[190931] = FILTER_BY_PLAYER -- Mongoose Fury
	a[118922] = FILTER_BY_PLAYER -- Posthaste
	a[200108] = FILTER_BY_PLAYER -- Ranger's Net
	a[118253] = FILTER_BY_PLAYER -- Serpent Sting
	a[135299] = FILTER_BY_PLAYER -- Tar Trap
	a[193526] = FILTER_BY_PLAYER -- Trueshot
	a[187131] = FILTER_BY_PLAYER -- Vulnerable
	a[195645] = FILTER_BY_PLAYER -- Wing Clip
	-- Talents
	-- Artifact Traits
end

------------------------------------------------------------------------
-- Mage

if playerClass == "MAGE" then
	-- Abilities
	a[ 12042] = FILTER_BY_PLAYER -- Arcane Power
	a[157981] = FILTER_BY_PLAYER -- Blast Wave
	a[108843] = FILTER_BY_PLAYER -- Blazing Speed
	a[205766] = FILTER_BY_PLAYER -- Bone Chilling
	a[190319] = FILTER_BY_PLAYER -- Combustion
	a[   120] = FILTER_BY_PLAYER -- Cone of Cold
	a[31661] = FILTER_BY_PLAYER -- Dragon's Breath
	a[210134] = FILTER_BY_PLAYER -- Erosion
	a[126084] = FILTER_BY_PLAYER -- Fingers of Frost -- NEEDS CHECK 44544
	a[  2120] = FILTER_BY_PLAYER -- Flamestrike
	a[112948] = FILTER_BY_PLAYER -- Frost Bomb
	a[   122] = FILTER_BY_PLAYER -- Frost Nova
	a[228600] = FILTER_BY_PLAYER -- Glacial Spike
	a[110960] = FILTER_BY_PLAYER -- Greater Invisibility
	a[195283] = FILTER_BY_PLAYER -- Hot Streak
	a[ 11426] = FILTER_BY_PLAYER -- Ice Barrier
	a[ 45438] = FILTER_BY_PLAYER -- Ice Block
	a[108839] = FILTER_BY_PLAYER -- Ice Floes
	a[ 12472] = FILTER_BY_PLAYER -- Icy Veins
	a[ 12654] = FILTER_BY_PLAYER -- Ignite
	a[    66] = FILTER_BY_PLAYER -- Invisibility
	a[ 44457] = FILTER_BY_PLAYER -- Living Bomb
	a[114923] = FILTER_BY_PLAYER -- Nether Tempest
	a[205025] = FILTER_BY_PLAYER -- Presence of Mind
	a[198924] = FILTER_BY_PLAYER -- Quickening
	a[ 82691] = FILTER_BY_PLAYER -- Ring of Frost
	a[ 31589] = FILTER_BY_PLAYER -- Slow
	a[   130] = FILTER_BY_PLAYER -- Slow Fall
	-- Talents
	-- Artifact Traits
end

------------------------------------------------------------------------
-- Monk

if playerClass == "MONK" then
	-- Abilities
	a[228563] = FILTER_BY_PLAYER -- Blackout Combo
	a[115181] = FILTER_BY_PLAYER -- Breath of Fire
	a[119085] = FILTER_BY_PLAYER -- Chi Torpedo
	a[122278] = FILTER_BY_PLAYER -- Dampen Harm
	a[122783] = FILTER_BY_PLAYER -- Diffuse Magic
	a[116095] = FILTER_BY_PLAYER -- Disable
	a[196723] = FILTER_BY_PLAYER -- Dizzying Kicks
	a[124682] = FILTER_BY_PLAYER -- Enveloping Mist
	a[191840] = FILTER_BY_PLAYER -- Essence Font
	a[196739] = FILTER_BY_PLAYER -- Elusive Dance
	a[196608] = FILTER_BY_PLAYER -- Eye of the Tiger
	a[120954] = FILTER_BY_PLAYER -- Fortifying Brew
	a[124273] = FILTER_BY_PLAYER -- Heavy Stagger
	a[196741] = FILTER_BY_PLAYER -- Hit Combo
	a[215479] = FILTER_BY_PLAYER -- Ironskin Brew
	a[121253] = FILTER_BY_PLAYER -- Keg Smash
	a[119381] = FILTER_BY_PLAYER -- Leg Sweep
	a[116849] = FILTER_BY_PLAYER -- Life Cocoon
	a[197919] = FILTER_BY_PLAYER -- Lifecycles (Enveloping Mist)
	a[197916] = FILTER_BY_PLAYER -- Lifecycles (Vivify)
	a[124275] = FILTER_BY_PLAYER -- Light Stagger
	a[197908] = FILTER_BY_PLAYER -- Mana Tea
	a[124274] = FILTER_BY_PLAYER -- Moderate Stagger
	a[115078] = FILTER_BY_PLAYER -- Paralysis
	a[129914] = FILTER_BY_PLAYER -- Power Strikes
	a[196725] = FILTER_BY_PLAYER -- Refreshing Jade Wind
	a[119611] = FILTER_BY_PLAYER -- Renewing Mist -- NEEDS CHECK 144080
	a[116844] = FILTER_BY_PLAYER -- Ring of Peace
	a[116847] = FILTER_BY_PLAYER -- Rushing Jade Wind
	a[152173] = FILTER_BY_PLAYER -- Serenity
	a[198909] = FILTER_BY_PLAYER -- Song of Chi-Ji
	a[196733] = FILTER_BY_PLAYER -- Special Delivery -- NEEDS CHECK
	a[202090] = FILTER_BY_PLAYER -- Teachings of the Monastery
	a[116680] = FILTER_BY_PLAYER -- Thunder Focus Tea
	a[116841] = FILTER_BY_PLAYER -- Tiger's Lust
	a[115080] = FILTER_BY_PLAYER -- Touch of Death
	a[122470] = FILTER_BY_PLAYER -- Touch of Karma
	a[115176] = FILTER_BY_PLAYER -- Zen Meditation
	-- Talents
	a[116768] = FILTER_BY_PLAYER -- Blackout Kick! (from Combo Breaker)
	-- Artifact Traits
	a[205320] = FILTER_BY_PLAYER -- Strike of the Windlord
end

------------------------------------------------------------------------
-- Paladin

if playerClass == "PALADIN" then
	a[257771] = FILTER_ON_FRIEND -- Forbearance
	a[ 53563] = FILTER_ON_FRIEND -- Beacon of Light
	a[  1044] = FILTER_ON_FRIEND -- Blessing of Freedom
	a[  1022] = FILTER_ON_FRIEND -- Blessing of Protection
	a[  6940] = FILTER_ON_FRIEND -- Blessing of Sacrifice
	a[204013] = FILTER_ON_FRIEND -- Blessing of Salvation
	a[204018] = FILTER_ON_FRIEND -- Blessing of Spellwarding
	a[203538] = FILTER_ON_FRIEND -- Greater Blessing of Kings
	a[203528] = FILTER_ON_FRIEND -- Greater Blessing of Might
	a[203539] = FILTER_ON_FRIEND -- Greater Blessing of Wisdom
	-- Abilities
	a[204150] = FILTER_BY_PLAYER -- Aegis of Light
	a[ 31850] = FILTER_BY_PLAYER -- Ardent Defender
	a[ 31842] = FILTER_BY_PLAYER -- Avenging Wrath (Holy)
	a[ 31884] = FILTER_BY_PLAYER -- Avenging Wrath (Protection, Retribution)
	a[105421] = FILTER_BY_PLAYER -- Blinding Light
	a[224668] = FILTER_BY_PLAYER -- Crusade
	a[216411] = FILTER_BY_PLAYER -- Divine Purpose (Holy - Holy Shock)
	a[216413] = FILTER_BY_PLAYER -- Divine Purpose (Holy - Light of Dawn)
	a[223819] = FILTER_BY_PLAYER -- Divine Purpose (Retribution)
	a[   642] = FILTER_BY_PLAYER -- Divine Shield
	a[220509] = FILTER_BY_PLAYER -- Divine Steed
	a[221883] = FILTER_BY_PLAYER -- Divine Steed
	a[221886] = FILTER_BY_PLAYER -- Divine Steed (Blood Elf)
	a[221887] = FILTER_BY_PLAYER -- Divine Steed (Draenei)
	a[221885] = FILTER_BY_PLAYER -- Divine Steed (Tauren)
	a[205191] = FILTER_BY_PLAYER -- Eye for an Eye
	a[223316] = FILTER_BY_PLAYER -- Fervent Light
	a[ 86659] = FILTER_BY_PLAYER -- Guardian of Ancient Kings
	a[   853] = FILTER_BY_PLAYER -- Hammer of Justice
	a[183218] = FILTER_BY_PLAYER -- Hand of Hindrance
	a[105809] = FILTER_BY_PLAYER -- Holy Avenger
	a[ 54149] = FILTER_BY_PLAYER -- Infusion of Light
	a[183436] = FILTER_BY_PLAYER -- Retribution
	a[214202] = FILTER_BY_PLAYER -- Rule of Law
	a[202273] = FILTER_BY_PLAYER -- Seal of Light
	a[152262] = FILTER_BY_PLAYER -- Seraphim
	a[132403] = FILTER_BY_PLAYER -- Shield of the Righteous
	a[184662] = FILTER_BY_PLAYER -- Shield of Vengeance
	a[209785] = FILTER_BY_PLAYER -- The Fires of Justice
	-- Talents
	-- Artifact Traits
end

------------------------------------------------------------------------
-- Priest

if playerClass == "PRIEST" then
	-- Abilities
	a[194384] = FILTER_BY_PLAYER -- Atonement
	a[ 47585] = FILTER_BY_PLAYER -- Disperson
	a[   586] = FILTER_BY_PLAYER -- Fade
	a[ 47788] = FILTER_BY_PLAYER -- Guardian Spirit
	a[ 14914] = FILTER_BY_PLAYER -- Holy Fire
	a[200196] = FILTER_BY_PLAYER -- Holy Word: Chastise
	a[  1706] = FILTER_BY_PLAYER -- Levitate
	a[   605] = FILTER_BY_PLAYER -- Mind Control
	a[ 33206] = FILTER_BY_PLAYER -- Pain Suppression
	a[ 81782] = FILTER_BY_PLAYER -- Power Word: Barrier
	a[    17] = FILTER_BY_PLAYER -- Power Word: Shield
	a[ 41635] = FILTER_BY_PLAYER -- Prayer of Mending
	a[  8122] = FILTER_BY_PLAYER -- Psychic Scream
	a[ 47536] = FILTER_BY_PLAYER -- Rapture
	a[   139] = FILTER_BY_PLAYER -- Renew
	a[187464] = FILTER_BY_PLAYER -- Shadow Mend
	a[   589] = FILTER_BY_PLAYER -- Shadow Word: Pain
	a[ 15487] = FILTER_BY_PLAYER -- Silence
	a[ 15286] = FILTER_BY_PLAYER -- Vampiric Embrace
	a[ 34914] = FILTER_BY_PLAYER -- Vampiric Touch
	a[227386] = FILTER_BY_PLAYER -- Voidform -- NEEDS CHECK
	-- Talents
	a[200183] = FILTER_BY_PLAYER -- Apotheosis
	a[214121] = FILTER_BY_PLAYER -- Body and Mind
	a[152118] = FILTER_BY_PLAYER -- Clarity of Will
	a[ 19236] = FILTER_BY_PLAYER -- Desperate Prayer
	a[197030] = FILTER_BY_PLAYER -- Divinity
	a[205369] = FILTER_BY_PLAYER -- Mind Bomb
	a[226943] = FILTER_BY_PLAYER -- Mind Bomb (stun)
	a[204213] = FILTER_BY_PLAYER -- Purge the Wicked
	a[214621] = FILTER_BY_PLAYER -- Schism
	a[219521] = FILTER_BY_PLAYER -- Shadow Covenant
	a[124430] = FILTER_BY_PLAYER -- Shadowy Insight
	a[204263] = FILTER_BY_PLAYER -- Shining Force
	a[114255] = FILTER_BY_PLAYER -- Surge of Light -- NEEDS CHECK, 128654
	a[123254] = FILTER_BY_PLAYER -- Twist of Fate
	-- Artifact Traits
	a[196644] = FILTER_BY_PLAYER -- Blessing of T'uure
	a[197763] = FILTER_BY_PLAYER -- Borrowed Time
	a[208065] = FILTER_BY_PLAYER -- Light of T'uure
end

------------------------------------------------------------------------
-- Rogue

if playerClass == "ROGUE" then
	-- Abilities
	a[ 13750] = FILTER_BY_PLAYER -- Adrenaline Rush
	a[ 13877] = FILTER_BY_PLAYER -- Blade Flurry
	a[199740] = FILTER_BY_PLAYER -- Bribe
	a[  1833] = FILTER_BY_PLAYER -- Cheap Shot
	a[ 31224] = FILTER_BY_PLAYER -- Cloak of Shadows
	a[  3409] = FILTER_BY_PLAYER -- Crippling Poison (debuff)
	a[  2818] = FILTER_BY_PLAYER -- Deadly Poison (debuff)
	a[  5277] = FILTER_BY_PLAYER -- Evasion
	a[  1966] = FILTER_BY_PLAYER -- Feint
	a[   703] = FILTER_BY_PLAYER -- Garrote
	a[  1776] = FILTER_BY_PLAYER -- Gouge
	a[   408] = FILTER_BY_PLAYER -- Kidney Shot
	a[195452] = FILTER_BY_PLAYER -- Nightblade
	a[185763] = FILTER_BY_PLAYER -- Pistol Shot
	a[199754] = FILTER_BY_PLAYER -- Riposte
	a[193356] = FILTER_BY_PLAYER -- Roll the Bones - Broadsides
	a[199600] = FILTER_BY_PLAYER -- Roll the Bones - Buried Treasure
	a[193358] = FILTER_BY_PLAYER -- Roll the Bones - Grand Melee
	a[199603] = FILTER_BY_PLAYER -- Roll the Bones - Jolly Roger
	a[193357] = FILTER_BY_PLAYER -- Roll the Bones - Shark Infested Waters
	a[193359] = FILTER_BY_PLAYER -- Roll the Bones - True Bearing
	a[  1943] = FILTER_BY_PLAYER -- Rupture
	a[121471] = FILTER_BY_PLAYER -- Shadow Blades
	a[185422] = FILTER_BY_PLAYER -- Shadow Dance
	a[ 36554] = FILTER_BY_PLAYER -- Shadowstep
	a[  2983] = FILTER_BY_PLAYER -- Sprint
	a[212283] = FILTER_BY_PLAYER -- Symbols of Death
	a[ 57934] = FILTER_BY_PLAYER -- Tricks of the Trade
	a[  1856] = FILTER_BY_PLAYER -- Vanish
	a[ 79140] = FILTER_BY_PLAYER -- Vendetta
--	a[  8680] = FILTER_BY_PLAYER -- Wound Poison -- who cares?
	-- Talents
	a[200803] = FILTER_BY_PLAYER -- Agonizing Poison
	a[196937] = FILTER_BY_PLAYER -- Ghostly Strike
	a[ 16511] = FILTER_BY_PLAYER -- Hemorrhage
	a[135345] = FILTER_BY_PLAYER -- Internal Bleeding
	a[ 51690] = FILTER_BY_PLAYER -- Killing Spree
	a[137619] = FILTER_BY_PLAYER -- Marked for Death
	a[  5171] = FILTER_BY_PLAYER -- Slice and Dice
	-- Artifact Traits
	a[220901] = FILTER_BY_PLAYER -- Goremaw's Bite (regen)
	a[209786] = FILTER_BY_PLAYER -- Goremaw's Bite (slow)
	a[192759] = FILTER_BY_PLAYER -- Kingsbane (dot)
	a[192853] = FILTER_BY_PLAYER -- Kingsbane (+damage)
end

------------------------------------------------------------------------
-- Shaman

if playerClass == "SHAMAN" then
	a[108281] = FILTER_BY_PLAYER -- Ancestral Guidance
	a[108271] = FILTER_BY_PLAYER -- Astral Shift
	a[187878] = FILTER_BY_PLAYER -- Crash Lightning
	a[188089] = FILTER_BY_PLAYER -- Earthen Spike -- 10s duration on a 20s cooldown
--	a[118522] = FILTER_BY_PLAYER -- Elemental Blast: Critical Strike -- 10s duration on a 12s cooldown
--	a[173183] = FILTER_BY_PLAYER -- Elemental Blast: Haste -- 10s duration on a 12s cooldown
--	a[173184] = FILTER_BY_PLAYER -- Elemental Blast: Mastery -- 10s duration on a 12s cooldown
	a[ 16246] = FILTER_BY_PLAYER -- Elemental Focus
	a[188389] = FILTER_BY_PLAYER -- Flame Shock
	a[194084] = FILTER_BY_PLAYER -- Flametongue
	a[196840] = FILTER_BY_PLAYER -- Frost Shock
	a[196834] = FILTER_BY_PLAYER -- Frostbrand
	a[ 73920] = FILTER_BY_PLAYER -- Healing Rain
	a[215785] = FILTER_BY_PLAYER -- Hot Hand
	a[210714] = FILTER_BY_PLAYER -- Icefury
	a[202004] = FILTER_BY_PLAYER -- Landslide
	a[ 77756] = FILTER_BY_PLAYER -- Lava Surge
	a[197209] = FILTER_BY_PLAYER -- Lightning Rod -- NEEDS CHECK
	a[ 61295] = FILTER_BY_PLAYER -- Riptide
	a[ 98007] = FILTER_ON_FRIEND -- Spirit Link Totem
	a[ 58875] = FILTER_BY_PLAYER -- Spirit Walk
	a[ 79206] = FILTER_BY_PLAYER -- Spiritwalker's Grace
--	a[201846] = FILTER_BY_PLAYER -- Stormbringer -- see spell alert overlay, action button proc glow
	a[ 51490] = FILTER_BY_PLAYER -- Thunderstorm
	a[ 53390] = FILTER_BY_PLAYER -- Tidal Waves
--	a[   546] = FILTER_ON_FRIEND -- Water Walking -- TODO: show only OOC
--	a[201898] = FILTER_BY_PLAYER -- Windsong -- 20s duration on a 45s cooldown
	-- Talents
	a[114050] = FILTER_BY_PLAYER -- Ascendance (Elemental)
	a[114051] = FILTER_BY_PLAYER -- Ascendance (Enhancement)
	a[114052] = FILTER_BY_PLAYER -- Ascendance (Restoration)
	a[218825] = FILTER_BY_PLAYER -- Boulderfist
	a[ 64695] = FILTER_ON_ENEMY  -- Earthgrab (Totem) -- NEEDS CHECK
	a[135621] = FILTER_ON_ENEMY  -- Static Charge (Lightning Surge Totem) -- NEEDS CHECK
	a[192082] = FILTER_ON_FRIEND -- Wind Rush (Totem)
	-- Artifact Traits
	a[198300] = FILTER_BY_PLAYER -- Gathering Storms -- +2% damage to next Stormstrike per Crash Lightning target
	a[191877] = FILTER_BY_PLAYER -- Power of the Maelstrom -- buffs next 3 LBs, 20s duration
	a[205495] = FILTER_BY_PLAYER -- Stormkeeper -- buffs next 3 LB/CBs, 15s duration
end

------------------------------------------------------------------------
-- Warlock

if playerClass == "WARLOCK" then
	a[   980] = FILTER_BY_PLAYER -- Agony
	a[117828] = FILTER_BY_PLAYER -- Backdraft
	a[111400] = FILTER_BY_PLAYER -- Burning Rush
	a[146739] = FILTER_BY_PLAYER -- Corruption
	a[108416] = FILTER_BY_PLAYER -- Dark Pact
	a[205146] = FILTER_BY_PLAYER -- Demonic Calling
	a[ 48018] = FILTER_BY_PLAYER -- Demonic Circle -- TODO show on the side as a separate thingy
	a[193396] = FILTER_BY_PLAYER -- Demonic Empowerment
	a[171982] = FILTER_BY_PLAYER -- Demonic Synergy -- too passive?
	a[   603] = FILTER_BY_PLAYER -- Doom
	a[  1098] = FILTER_BY_PLAYER -- Enslave Demon
	a[196414] = FILTER_BY_PLAYER -- Eradication
	a[ 48181] = FILTER_BY_PLAYER -- Haunt -- NEEDS CHECK, 171788, 183357
	a[ 80240] = FILTER_BY_PLAYER -- Havoc
	a[228312] = FILTER_BY_PLAYER -- Immolate -- NEEDS CHECK
	a[  6789] = FILTER_BY_PLAYER -- Mortal Coil
	a[205179] = FILTER_BY_PLAYER -- Phantom Singularity
	a[196674] = FILTER_BY_PLAYER -- Planeswalker
	a[  5740] = FILTER_BY_PLAYER -- Rain of Fire
	a[ 27243] = FILTER_BY_PLAYER -- Seed of Corruption
	a[205181] = FILTER_BY_PLAYER -- Shadowflame
	a[ 30283] = FILTER_BY_PLAYER -- Shadowfury
	a[205178] = FILTER_BY_PLAYER -- Soul Effigy
	a[196098] = FILTER_BY_PLAYER -- Soul Harvest
--	a[ 20707] = FILTER_BY_PLAYER -- Soulstone -- OOC
--	a[  5697] = FILTER_BY_PLAYER -- Unending Breath -- OOC
	a[104773] = FILTER_BY_PLAYER -- Unending Resolve
	a[ 30108] = FILTER_BY_PLAYER -- Unstable Affliction
	-- Talents
	-- Artifact Traits
	a[199281] = FILTER_BY_PLAYER -- Compounding Horror
	a[196546] = FILTER_BY_PLAYER -- Conflagration of Chaos
	a[211583] = FILTER_BY_PLAYER -- Stolen Power
	a[216695] = FILTER_BY_PLAYER -- Tormented Souls
end

------------------------------------------------------------------------
-- Warrior

if playerClass == "WARRIOR" then
	-- Abilities
	a[  1719] = FILTER_BY_PLAYER -- Battle Cry
	a[ 18499] = FILTER_BY_PLAYER -- Berserker Rage
	a[227847] = FILTER_BY_PLAYER -- Bladestorm
	a[105771] = FILTER_BY_PLAYER -- Charge
	a[ 97463] = FILTER_ON_FRIEND -- Commanding Shout
	a[115767] = FILTER_BY_PLAYER -- Deep Wounds
	a[  1160] = FILTER_BY_PLAYER -- Demoralizing Shout
	a[118038] = FILTER_BY_PLAYER -- Die by the Sword
	a[184362] = FILTER_BY_PLAYER -- Enrage
	a[184364] = FILTER_BY_PLAYER -- Enraged Regeneration
	a[204488] = FILTER_BY_PLAYER -- Focused Rage
	a[  1715] = FILTER_BY_PLAYER -- Hamstring
	a[190456] = FILTER_BY_PLAYER -- Ignore Pain
	a[  5246] = FILTER_BY_PLAYER -- Intimidating Shout
	a[ 12975] = FILTER_BY_PLAYER -- Last Stand
	a[ 85739] = FILTER_BY_PLAYER -- Meat Cleaver
	a[ 12323] = FILTER_BY_PLAYER -- Piercing Howl
	a[132404] = FILTER_BY_PLAYER -- Shield Block
	a[   871] = FILTER_BY_PLAYER -- Shield Wall
	a[ 23920] = FILTER_BY_PLAYER -- Spell Reflection
	a[206333] = FILTER_BY_PLAYER -- Taste for Blood
	a[  6343] = FILTER_BY_PLAYER -- Thunder Clap
	-- Talents
	a[107574] = FILTER_BY_PLAYER -- Avatar
	a[ 46924] = FILTER_BY_PLAYER -- Bladestorm
	a[ 12292] = FILTER_BY_PLAYER -- Bloodbath
	a[197690] = FILTER_BY_PLAYER -- Defensive Stance
	a[118000] = FILTER_BY_PLAYER -- Dragon Roar
	a[207982] = FILTER_BY_PLAYER -- Focused Rage
	a[215572] = FILTER_BY_PLAYER -- Frothing Berserker
	a[   772] = FILTER_BY_PLAYER -- Rend
	a[ 46968] = FILTER_BY_PLAYER -- Shockwave
	a[107570] = FILTER_BY_PLAYER -- Storm Bolt
	a[215537] = FILTER_BY_PLAYER -- Trauma
--	a[122510] = FILTER_BY_PLAYER -- Ultimatum -- action button glow + spell alert overlay
	a[202573] = FILTER_BY_PLAYER -- Vengeance: Focused Rage
	a[202547] = FILTER_BY_PLAYER -- Vengeance: Ignore Pain
	a[215562] = FILTER_BY_PLAYER -- War Machine
	a[215570] = FILTER_BY_PLAYER -- Wrecking Ball
	-- Artifact Traits
	a[203524] = FILTER_BY_PLAYER -- Neltharion's Fury
	a[205546] = FILTER_BY_PLAYER -- Odyn's Fury (dot) -- NEEDS CHECK, 205546
end

------------------------------------------------------------------------
-- Racials

local _, playerRace = UnitRace("player")
if playerRace == "BloodElf" then
	a[50613]  = FILTER_BY_PLAYER -- Arcane Torrent (DK)
	a[80483]  = FILTER_BY_PLAYER -- Arcane Torrent (HU)
	a[28730]  = FILTER_BY_PLAYER -- Arcane Torrent (MA, PA, PR, WL)
	a[129597] = FILTER_BY_PLAYER -- Arcane Torrent (MO)
	a[25046]  = FILTER_BY_PLAYER -- Arcane Torrent (RO)
	a[69179]  = FILTER_BY_PLAYER -- Arcane Torrent (WR)
elseif playerRace == "Draenei" then
	a[59545]  = FILTER_BY_PLAYER -- Gift of the Naaru (DK)
	a[59543]  = FILTER_BY_PLAYER -- Gift of the Naaru (HU)
	a[59548]  = FILTER_BY_PLAYER -- Gift of the Naaru (MA)
	a[121093] = FILTER_BY_PLAYER -- Gift of the Naaru (MO)
	a[59542]  = FILTER_BY_PLAYER -- Gift of the Naaru (PA)
	a[59544]  = FILTER_BY_PLAYER -- Gift of the Naaru (PR)
	a[59547]  = FILTER_BY_PLAYER -- Gift of the Naaru (SH)
	a[28880]  = FILTER_BY_PLAYER -- Gift of the Naaru (WR)
elseif playerRace == "Dwarf" then
	a[20594]  = FILTER_BY_PLAYER -- Stoneform
elseif playerRace == "NightElf" then
	a[58984]  = FILTER_BY_PLAYER -- Shadowmeld
elseif playerRace == "Orc" then
	a[20572]  = FILTER_BY_PLAYER -- Blood Fury (attack power)
	a[33702]  = FILTER_BY_PLAYER -- Blood Fury (spell power)
	a[33697]  = FILTER_BY_PLAYER -- Blood Fury (attack power and spell damage)
elseif playerRace == "Pandaren" then
	a[107079] = FILTER_BY_PLAYER -- Quaking Palm
elseif playerRace == "Scourge" then
	a[7744]   = FILTER_BY_PLAYER -- Will of the Forsaken
elseif playerRace == "Tauren" then
	a[20549]  = FILTER_ALL -- War Stomp
elseif playerRace == "Troll" then
	a[26297]  = FILTER_BY_PLAYER -- Berserking
elseif playerRace == "Worgen" then
	a[68992]  = FILTER_BY_PLAYER -- Darkflight
end

------------------------------------------------------------------------
-- Taunts (tanks only)

if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "MONK" or playerClass == "PALADIN" or playerClass == "WARRIOR" then
	a[56222]  = FILTER_ROLE_TANK -- Dark Command (DK)
	a[57604]  = FILTER_ROLE_TANK -- Death Grip (DK) -- NEEDS CHECK 49560 51399 57603
	a[6795]   = FILTER_ROLE_TANK -- Growl (DR)
	a[20736]  = FILTER_ROLE_TANK -- Distracting Shot (HU)
	a[118585] = FILTER_ROLE_TANK -- Leer of the Ox (MO)
	a[116189] = FILTER_ROLE_TANK -- Provoke (MO)
	a[118635] = FILTER_ROLE_TANK -- Provoke (MO Black Ox Statue) -- NEEDS CHECK
	a[62124]  = FILTER_ROLE_TANK -- Reckoning (PA)
	a[36213]  = FILTER_ROLE_TANK -- Angered Earth (SH Earth Elemental)
	a[17735]  = FILTER_ROLE_TANK -- Suffering (WL Voidwalker)
	a[114198] = FILTER_ROLE_TANK -- Mocking Banner (WR)
	a[355]    = FILTER_ROLE_TANK -- Taunt (WR)

	a[ 62124] = FILTER_ROLE_TANK -- Hand of Reckoning (Paladin)
	a[185245] = FILTER_ROLE_TANK -- Torment (Demon Hunter)
end

------------------------------------------------------------------------

local auraList = {}
ns.AuraList = auraList

local auraList_focus = {}
local auraList_targettarget = {}

local function AddAurasToList(auras)
	local role = ns.GetPlayerRole()
	local filterForRole = roleFilter[role]
	for id, v in pairs(auras) do
		local skip
		if bit_band(v, FILTER_ALL) == 0 then
			if (bit_band(v, FILTER_ROLE_MASK) > 0 and bit_band(v, filterForRole) == 0) then
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
	default = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll, timeMod)
		local v = auraList[spellID]
		return not v or bit_band(v, FILTER_DISABLE) == 0
	end,
	player = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll, timeMod)
		local v = auraList[spellID]
		if v then
			return checkFilter(v, self, unit, caster)
		else
			return isBossAura or caster == "vehicle"
		end
	end,
	pet = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll, timeMod)
		local v = auraList[spellID]
		if v then
			return caster and unitIsPlayer[caster] and bit_band(v, FILTER_BY_PLAYER) > 0
		else
			return isBossAura or caster == "vehicle"
		end
	end,
	target = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll, timeMod)
		local v = auraList[spellID]
		if v then
			local show = checkFilter(v, self, unit, caster)
			return show
		elseif isBossAura or caster == "vehicle" then
			return true
		elseif iconFrame.isDebuff and not caster then -- and not IsInInstance() then
			-- EXPERIMENTAL: ignore debuffs from players outside the group, eg. world bosses
			return
		elseif UnitCanAttack("player", unit) and not UnitPlayerControlled(unit) then
			-- Hostile NPC
			-- Show auras of unknown origin
			-- Show auras cast by the unit
			-- Show buffs with a duration < 1 hour
			return (not caster or caster == unit) or (not iconFrame.isDebuff and duration < 3600)
		else
			-- Friendly target or hostile player
			-- Show auras of unknown origin
			return not caster
		end
	end,
	party = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
		local v = auraList[spellID]
		if v then
			return (iconFrame.isPlayer and bit_band(v, FILTER_BY_PLAYER) > 0) or bit_band(v, FILTER_ON_FRIEND) > 0
		else
			return isBossAura
		end
	end,
}

filterFuncs.focus = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	if auraList_focus[id] then
		return filterFuncs.target(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	else
		return isBossAura
	end
end

filterFuncs.targettarget = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	if auraList_targettarget[id] then
		return filterFuncs.target(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	else
		return isBossAura
	end
end

ns.CustomAuraFilters = filterFuncs
