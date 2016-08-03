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
local FILTER_NONE         = 0x2000000

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
	FILTER_NONE           = FILTER_NONE,

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
	-- Crowd Control
	[   710] = FILTER_ALL, -- Banish
	[   339] = FILTER_ALL, -- Entangling Roots
	[  5782] = FILTER_ALL, -- Fear
	[  3355] = FILTER_ALL, -- Freezing Trap -- NEEDS CHECK, 212365
	[ 51514] = FILTER_ALL, -- Hex
	[210873] = FILTER_ALL, -- Hex (Compy)
	[211015] = FILTER_ALL, -- Hex (Cockroach)
	[211010] = FILTER_ALL, -- Hex (Snake)
	[211004] = FILTER_ALL, -- Hex (Spider)
	[  5484] = FILTER_ALL, -- Howl of Terror
	[   118] = FILTER_ALL, -- Polymorph
	[ 61308] = FILTER_ALL, -- Polymorph (Black Cat)
	[161354] = FILTER_ALL, -- Polymorph (Monkey)
	[161372] = FILTER_ALL, -- Polymorph (Peacock)
	[161355] = FILTER_ALL, -- Polymorph (Penguin)
	[ 28272] = FILTER_ALL, -- Polymorph (Pig)
	[161353] = FILTER_ALL, -- Polymorph (Polar Bear Cub)
	[126819] = FILTER_ALL, -- Polymorph (Porcupine)
	[ 61721] = FILTER_ALL, -- Polymorph (Rabbit)
	[ 61780] = FILTER_ALL, -- Polymorph (Turkey)
	[ 28271] = FILTER_ALL, -- Polymorph (Turtle)
	[ 20066] = FILTER_ALL, -- Repentance
	[  6770] = FILTER_ALL, -- Sap
	[  6358] = FILTER_ALL, -- Seduction
	[  9484] = FILTER_ALL, -- Shackle Undead
	[ 19386] = FILTER_ALL, -- Wyvern Sting
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
	[ 63501] = FILTER_NONE, -- Argent Crusade Champion's Pennant
	[ 60023] = FILTER_NONE, -- Scourge Banner Aura (Boneguard Commander in Icecrown)
	[ 63406] = FILTER_NONE, -- Darnassus Champion's Pennant
	[ 63405] = FILTER_NONE, -- Darnassus Valiant's Pennant
	[ 63423] = FILTER_NONE, -- Exodar Champion's Pennant
	[ 63422] = FILTER_NONE, -- Exodar Valiant's Pennant
	[ 63396] = FILTER_NONE, -- Gnomeregan Champion's Pennant
	[ 63395] = FILTER_NONE, -- Gnomeregan Valiant's Pennant
	[ 63427] = FILTER_NONE, -- Ironforge Champion's Pennant
	[ 63426] = FILTER_NONE, -- Ironforge Valiant's Pennant
	[ 63433] = FILTER_NONE, -- Orgrimmar Champion's Pennant
	[ 63432] = FILTER_NONE, -- Orgrimmar Valiant's Pennant
	[ 63399] = FILTER_NONE, -- Sen'jin Champion's Pennant
	[ 63398] = FILTER_NONE, -- Sen'jin Valiant's Pennant
	[ 63403] = FILTER_NONE, -- Silvermoon Champion's Pennant
	[ 63402] = FILTER_NONE, -- Silvermoon Valiant's Pennant
	[ 62594] = FILTER_NONE, -- Stormwind Champion's Pennant
	[ 62596] = FILTER_NONE, -- Stormwind Valiant's Pennant
	[ 63436] = FILTER_NONE, -- Thunder Bluff Champion's Pennant
	[ 63435] = FILTER_NONE, -- Thunder Bluff Valiant's Pennant
	[ 63430] = FILTER_NONE, -- Undercity Champion's Pennant
	[ 63429] = FILTER_NONE, -- Undercity Valiant's Pennant
}

ns.defaultAuras = a

------------------------------------------------------------------------
-- Death Knight

if playerClass == "DEATHKNIGHT" then
	a[ 48707] = FILTER_BY_PLAYER -- Anti-Magic Shell
	a[221562] = FILTER_BY_PLAYER -- Asphyxiate -- NEEDS CHECK, 108194
	a[206977] = FILTER_BY_PLAYER -- Blood Mirror
	a[ 55078] = FILTER_BY_PLAYER -- Blood Plague
	a[195181] = FILTER_BY_PLAYER -- Bone Shield
	a[194844] = FILTER_BY_PLAYER -- Bonestorm
	a[152279] = FILTER_BY_PLAYER -- Breath of Sindragosa
	a[ 45524] = FILTER_BY_PLAYER -- Chains of Ice
	a[111673] = FILTER_BY_PLAYER -- Control Undead
	a[207319] = FILTER_BY_PLAYER -- Corpse Shield
	a[101568] = FILTER_BY_PLAYER -- Dark Succor
	a[ 63560] = FILTER_BY_PLAYER -- Dark Transformation
	a[ 43265] = FILTER_BY_PLAYER -- Death and Decay
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
	a[  3714] = FILTER_BY_PLAYER -- Path of Frost
	a[ 51271] = FILTER_BY_PLAYER -- Pillar of Frost
	a[196770] = FILTER_BY_PLAYER -- Remorseless Winter
	a[ 59052] = FILTER_BY_PLAYER -- Rime
	a[194679] = FILTER_BY_PLAYER -- Rune Tap
	a[191748] = FILTER_BY_PLAYER -- Scouge of Worlds (artifact)
	a[116888] = FILTER_BY_PLAYER -- Shroud of Purgatory (talent: Purgatory)
	a[130736] = FILTER_BY_PLAYER -- Soul Reaper
	a[ 55233] = FILTER_BY_PLAYER -- Vampiric Blood
	a[191587] = FILTER_BY_PLAYER -- Virulent Plague
	a[211794] = FILTER_BY_PLAYER -- Winter is Coming
	a[212552] = FILTER_BY_PLAYER -- Wraith Walk
end

------------------------------------------------------------------------
-- Demon Hunter

if playerClass == "DEMONHUNTER" then
end

------------------------------------------------------------------------
-- Druid

if playerClass == "DRUID" then
	a[ 29166] = FILTER_ON_FRIEND -- Innervate
	a[102342] = FILTER_ON_FRIEND -- Ironbark
	a[106898] = FILTER_ON_FRIEND -- Stampeding Roar
	a[210723] = FILTER_BY_PLAYER -- Ashmane's Frenzy (artifact)
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
	a[ 22570] = FILTER_BY_PLAYER -- Maim
	a[192083] = FILTER_BY_PLAYER -- Mark of Ursol
	a[ 33763] = FILTER_BY_PLAYER -- Lifebloom
	a[164812] = FILTER_BY_PLAYER -- Moonfire -- NEEDS CHECK, 8921
	a[ 69369] = FILTER_BY_PLAYER -- Predatory Swiftness
	a[158792] = FILTER_BY_PLAYER -- Pulverize
	a[200851] = FILTER_BY_PLAYER -- Rage of the Sleeper (artifact)
	a[155722] = FILTER_BY_PLAYER -- Rake
	a[  8936] = FILTER_BY_PLAYER -- Regrowth
	a[   774] = FILTER_BY_PLAYER -- Rejuvenation
	a[  1079] = FILTER_BY_PLAYER -- Rip
	a[ 52610] = FILTER_BY_PLAYER -- Savage Roar
	a[210664] = FILTER_BY_PLAYER -- Scent of Blood (artifact)
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
end

------------------------------------------------------------------------
-- Hunter

if playerClass == "HUNTER" then
end

------------------------------------------------------------------------
-- Mage

if playerClass == "MAGE" then
end

------------------------------------------------------------------------
-- Monk

if playerClass == "MONK" then
	--a[] = FILTER_BY_PLAYER -- Breath of Fire
	--a[] = FILTER_BY_PLAYER -- Chi Torpedo
	--a[] = FILTER_BY_PLAYER -- Dampen Harm
	--a[] = FILTER_BY_PLAYER -- Diffuse Magic
	--a[] = FILTER_BY_PLAYER -- Disable
	--a[] = FILTER_BY_PLAYER -- Dizzying Kicks
	--a[] = FILTER_BY_PLAYER -- Enveloping Mist
	--a[] = FILTER_BY_PLAYER -- Essence Font
	--a[] = FILTER_BY_PLAYER -- Eye of the Tiger
	--a[] = FILTER_BY_PLAYER -- Flying Serpent Kick
	--a[] = FILTER_BY_PLAYER -- Fortifying Brew
	--a[] = FILTER_BY_PLAYER -- Hit Combo
	--a[] = FILTER_BY_PLAYER -- Ironskin Brew
	--a[] = FILTER_BY_PLAYER -- Keg Smash
	--a[] = FILTER_BY_PLAYER -- Leg Sweep
	--a[] = FILTER_BY_PLAYER -- Life Cocoon
	--a[] = FILTER_BY_PLAYER -- Paralysis
	--a[] = FILTER_BY_PLAYER -- Power Strikes
	--a[] = FILTER_BY_PLAYER -- Renewing Mist
	--a[] = FILTER_BY_PLAYER -- Ring of Peace
	--a[] = FILTER_BY_PLAYER -- Rushing Jade Wind
	--a[] = FILTER_BY_PLAYER -- Serenity
	--a[] = FILTER_BY_PLAYER -- Thunder Focus Tea
	--a[] = FILTER_BY_PLAYER -- Tiger Palm proc
	--a[] = FILTER_BY_PLAYER -- Tiger's Lust
	--a[] = FILTER_BY_PLAYER -- Touch of Karma
	--a[] = FILTER_BY_PLAYER -- Zen Meditation
end

------------------------------------------------------------------------
-- Paladin

if playerClass == "PALADIN" then
end

------------------------------------------------------------------------
-- Priest

if playerClass == "PRIEST" then
end

------------------------------------------------------------------------
-- Rogue

if playerClass == "ROGUE" then
end

------------------------------------------------------------------------
-- Shaman

if playerClass == "SHAMAN" then
	a[114050] = FILTER_BY_PLAYER -- Ascendance (Elemental)
	a[114051] = FILTER_BY_PLAYER -- Ascendance (Enhancement)
	a[114052] = FILTER_BY_PLAYER -- Ascendance (Restoration)
	a[108281] = FILTER_BY_PLAYER -- Ancestral Guidance
	a[108271] = FILTER_BY_PLAYER -- Astral Shift
	a[218825] = FILTER_BY_PLAYER -- Boulderfist
	a[187878] = FILTER_BY_PLAYER -- Crash Lightning
	a[118522] = FILTER_BY_PLAYER -- Elemental Blast: Critical Strike -- 10s duration on a 12s cooldown
	a[173183] = FILTER_BY_PLAYER -- Elemental Blast: Haste -- 10s duration on a 12s cooldown
	a[173184] = FILTER_BY_PLAYER -- Elemental Blast: Mastery -- 10s duration on a 12s cooldown
	a[ 16246] = FILTER_BY_PLAYER -- Elemental Focus
	a[188389] = FILTER_BY_PLAYER -- Flame Shock
	a[194084] = FILTER_BY_PLAYER -- Flametongue
	a[196840] = FILTER_BY_PLAYER -- Frost Shock
	a[196834] = FILTER_BY_PLAYER -- Frostbrand
	a[210714] = FILTER_BY_PLAYER -- Icefury
	a[ 77756] = FILTER_BY_PLAYER -- Lava Surge
	a[197209] = FILTER_BY_PLAYER -- Lightning Rod -- NEEDS CHECK
	a[ 58875] = FILTER_BY_PLAYER -- Spirit Walk
	a[201846] = FILTER_BY_PLAYER -- Stormbringer
	a[188089] = FILTER_BY_PLAYER -- Earthen Spike -- 10s duration on a 20s cooldown
	a[ 64695] = FILTER_ON_ENEMY  -- Earthgrab (Totem) -- NEEDS CHECK
	a[198300] = FILTER_BY_PLAYER -- Gathering Storms (artifact) -- +2% damage to next Stormstrike per Crash Lightning target
	a[ 73920] = FILTER_BY_PLAYER -- Healing Rain
	a[215785] = FILTER_BY_PLAYER -- Hot Hand
	a[202004] = FILTER_BY_PLAYER -- Landslide
	a[191877] = FILTER_BY_PLAYER -- Power of the Maelstrom (artifact) -- buffs next 3 LBs, 20s duration
	a[ 61295] = FILTER_BY_PLAYER -- Riptide
	a[ 98007] = FILTER_ON_FRIEND -- Spirit Link Totem -- NEEDS CHECK
	a[ 58875] = FILTER_BY_PLAYER -- Spirit Walk
	a[ 79206] = FILTER_BY_PLAYER -- Spiritwalker's Grace
	a[135621] = FILTER_ON_ENEMY  -- Static Charge (Lightning Surge Totem) -- NEEDS CHECK
	a[205495] = FILTER_BY_PLAYER -- Stormkeeper (artifact) -- buffs next 3 LB/CBs, 15s duration
	a[ 51490] = FILTER_BY_PLAYER -- Thunderstorm 
	a[ 53390] = FILTER_BY_PLAYER -- Tidal Waves
--	a[] = FILTER_ON_ENEMY -- Voodoo Totem -- NEEDS CHECK
--	a[   546] = FILTER_ON_FRIEND -- Water Walking -- TODO: show only OOC
	a[192082] = FILTER_ON_FRIEND -- Wind Rush (Totem)
	a[201898] = FILTER_BY_PLAYER -- Windsong -- 20s duration on a 45s cooldown
end

------------------------------------------------------------------------
-- Warlock

if playerClass == "WARLOCK" then
	a[   980] = FILTER_BY_PLAYER -- Agony
	a[117828] = FILTER_BY_PLAYER -- Backdraft
	a[111400] = FILTER_BY_PLAYER -- Burning Rush
	a[199281] = FILTER_BY_PLAYER -- Compounding Horror (artifact)
	a[196546] = FILTER_BY_PLAYER -- Conflagration of Chaos (artifact)
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
	a[211583] = FILTER_BY_PLAYER -- Stolen Power (artifact)
	a[216695] = FILTER_BY_PLAYER -- Tormented Souls (artifact)
--	a[  5697] = FILTER_BY_PLAYER -- Unending Breath -- OOC
	a[104773] = FILTER_BY_PLAYER -- Unending Resolve
	a[ 30108] = FILTER_BY_PLAYER -- Unstable Affliction
end

------------------------------------------------------------------------
-- Warrior

if playerClass == "WARRIOR" then
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
		return bit_band(v, FILTER_NONE) == 0
	end
end

local function debug(...)
	ChatFrame3:AddMessage(strjoin(" ", tostringall(...)))
end

local filterFuncs = {
	default = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
		local v = auraList[spellID]
		return not v or bit_band(v, FILTER_NONE) == 0
	end,
	player = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
		local v = auraList[spellID]
		if v then
			return checkFilter(v, self, unit, caster)
		else
			return isBossAura or caster == "vehicle"
		end
	end,
	pet = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
		local v = auraList[spellID]
		if v then
			return caster and unitIsPlayer[caster] and bit_band(v, FILTER_BY_PLAYER) > 0
		else
			return isBossAura or caster == "vehicle"
		end
	end,
	target = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
		local v = auraList[spellID]
		if v then
			local show = checkFilter(v, self, unit, caster)
			return show
		elseif isBossAura then
			return true
		elseif caster == "vehicle" then
			return true
		elseif not caster and not IsInInstance() then
			-- EXPERIMENTAL: ignore debuffs from players outside the group, eg. world bosses
			return
		elseif UnitCanAttack("player", unit) and not UnitPlayerControlled(unit) then
			-- Hostile NPC.
			-- Show auras cast by the unit, and auras of unknown origin.
			return not caster or caster == unit
		else
			-- Friendly target or hostile player
			-- Show auras of unknown origin
			return not caster
		end
	end,
	party = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
		local v = auraList[spellID]
		return v and bit_band(v, FILTER_ON_PLAYER) == 0
	end,
}

filterFuncs.focus = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	if auraList_focus[id] then
		return filterFuncs.target(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	end
end

filterFuncs.targettarget = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	if auraList_targettarget[id] then
		return filterFuncs.target(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	end
end

ns.CustomAuraFilters = filterFuncs
--[[
local tempfilter = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, isBossAura, casterIsPlayer, nameplateShowAll)
	if isBossAura then
		return true
	elseif iconFrame.isDebuff then
		return TargetFrame_ShouldShowDebuffs(unit, caster, nameplateShowAll, casterIsPlayer)
	elseif UnitCanAttack("player", unit) then
		return canStealOrPurge
	else
		return duration > 0 and expirationTime - GetTime() <= 30
	end
end

ns.CustomAuraFilters = setmetatable({}, { __index = function() return tempfilter end })
]]
