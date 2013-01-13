--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local PVP_MODE = false
	-- Enabling this will show PvP buffs and debuffs, and hide some
	-- buffs and debuffs that are only really useful in PvE.

--[[--------------------------------------------------------------------
	Values:
	1 = by anyone on anyone
	2 = by player on anyone
	3 = by anyone on friendly
	4 = by anyone on player
----------------------------------------------------------------------]]

local _, ns = ...
local playerClass = select(2, UnitClass("player"))
local playerRace = select(2, UnitRace("player"))

local auras = {
	[1022]   = 4, -- Hand of Protection
	[29166]  = 4, -- Innervate
	[102342] = 4, -- Ironbark
	[33206]  = 4, -- Pain Suppression
	[10060]  = 4, -- Power Infusion
	[49016]  = 4, -- Unholy Frenzy
	-- Bloodlust
	[90355]  = 4, -- Ancient Hysteria (core hound)
	[2825]   = 4, -- Bloodlust (shaman)
	[32182]  = 4, -- Heroism (shaman)
	[80353]  = 4, -- Time Warp (mage)
	-- Herbalism
	[81708]  = 2, -- Lifeblood (Rank 1)
	[55428]  = 2, -- Lifeblood (Rank 2)
	[55480]  = 2, -- Lifeblood (Rank 3)
	[55500]  = 2, -- Lifeblood (Rank 4)
	[55501]  = 2, -- Lifeblood (Rank 5)
	[55502]  = 2, -- Lifeblood (Rank 6)
	[55503]  = 2, -- Lifeblood (Rank 7)
	[74497]  = 2, -- Lifeblood (Rank 8)
	[121279] = 2, -- Lifeblood (Rank 9)
	-- Crowd Control
	[710]    = 1, -- Banish
	[76780]  = 1, -- Bind Elemental
	[33786]  = 1, -- Cyclone
	[339]    = 1, -- Entangling Roots
	[5782]   = 1, -- Fear
	[3355]   = 1, -- Freezing Trap, -- NEEDS CHECK
	[43448]  = 1, -- Freezing Trap, -- NEEDS CHECK
	[51514]  = 1, -- Hex
	[2637]   = 1, -- Hibernate
	[118]    = 1, -- Polymorph
	[61305]  = 1, -- Polymorph [Black Cat]
	[28272]  = 1, -- Polymorph [Pig]
	[61721]  = 1, -- Polymorph [Rabbit]
	[61780]  = 1, -- Polymorph [Turkey]
	[28271]  = 1, -- Polymorph [Turtle]
	[20066]  = 1, -- Repentance
	[6770]   = 1, -- Sap
	[6358]   = 1, -- Seduction
	[9484]   = 1, -- Shackle Undead
	[10326]  = 1, -- Turn Evil
	[19386]  = 1, -- Wyvern Sting
}

------------------------------------------------------------------------
--	Magic Vulnerability

if playerClass == "ROGUE" or playerClass == "WARLOCK" then
	auras[1490]  = 1 -- Curse of the Elements (warlock)
	auras[34889] = 1 -- Fire Breath (hunter dragonhawk)
	auras[24844] = 1 -- Lightning Breath (hunter wind serpent)
	auras[93068] = 1 -- Master Poisoner (rogue)
end

------------------------------------------------------------------------
--	Mortal Wounds

if playerClass == "HUNTER" or playerClass == "MONK" or playerClass == "ROGUE" or playerClass == "WARRIOR" then
	auras[54680]  = 1 -- Monstrous Bite (hunter devilsaur)
	auras[115804] = 1 -- Mortal Wounds (monk, warrior)
	auras[82654]  = 1 -- Widow Venom (hunter)
	auras[8680]   = 1 -- Wound Poison (rogue)
end

------------------------------------------------------------------------
--	Physical Vulnerability

if playerClass == "DEATHKNIGHT" or playerClass == "PALADIN" or playerClass == "WARRIOR" then
	auras[55749] = 1 -- Acid Rain (hunter worm)
	auras[35290] = 1 -- Gore (hunter boar)
	auras[81326] = 1 -- Physical Vulnerability (death knight, paladin, warrior)
	auras[50518] = 1 -- Ravage (hunter ravager)
	auras[57386] = 1 -- Stampede (hunter rhino)
end

------------------------------------------------------------------------
--	Slow Casting

if playerClass == "DEATHKNIGHT" or playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then
	auras[109466] = 1 -- Curse of Enfeeblement (warlock)
	auras[5760]   = 1 -- Mind-numbing Poison (rogue)
	auras[73975]  = 1 -- Necrotic Strike (death knight)
	auras[31589]  = 1 -- Slow (mage)
	auras[50274]  = 1 -- Spore Cloud (hunter sporebat)
	auras[90315]  = 1 -- Tailspin (hunter fox)
	auras[126406] = 1 -- Trample (hunter goat)
	auras[58604]  = 1 -- Lava Breath (hunter core hound)
end

------------------------------------------------------------------------
--	Weakened Armor

if playerClass == "DRUID" or playerClass == "ROGUE" or playerClass == "WARRIOR" then
	auras[113746] = 1 -- Weakened Armor (druid, hunter raptor, hunter tallstrider, rogue, warrior)
end

------------------------------------------------------------------------
--	Weakened Blows

if playerClass == "DEATHKNIGHT" or playerClass == "MONK" or playerClass == "PALADIN" or playerClass == "WARRIOR" then
	-- druids need to keep Thrash up anyway, no need to see both
	auras[109466] = 1 -- Curse of Elements (warlock)
	auras[60256]  = 1 -- Demoralizing Roar (hunter bear)
	auras[24423]  = 1 -- Demoralizing Screech (hunter carrion bird)
	auras[115798] = 1 -- Weakened Blows (death knight, druid, monk, paladin, shaman, warrior)
end

------------------------------------------------------------------------
--	Disarmed

if PVP_MODE then
	auras[50541]  = 1 -- Clench (hunter scorpid)
	auras[676]    = 1 -- Disarm (warrior)
	auras[51722]  = 1 -- Dismantle (rogue)
	auras[117368] = 1 -- Grapple Weapon (monk)
	auras[91644]  = 1 -- Snatch (hunter bird of prey)
end

------------------------------------------------------------------------
--	Silenced

if PVP_MODE then
	auras[25046]  = 1 -- Arcane Torrent (blood elf - rogue)
	auras[28730]  = 1 -- Arcane Torrent (blood elf - mage, paladin, priest, warlock)
	auras[50613]  = 1 -- Arcane Torrent (blood elf - death knight)
	auras[69179]  = 1 -- Arcane Torrent (blood elf - warrior)
	auras[80483]  = 1 -- Arcane Torrent (blood elf - hunter)
	auras[129597] = 1 -- Arcane Torrent (blood elf - monk)
	auras[31935]  = 1 -- Avenger's Shield (paladin)
	auras[102051] = 1 -- Frostjaw (mage)
	auras[1330]   = 1 -- Garrote - Silence (rogue)
	auras[50479]  = 1 -- Nether Shock (hunter nether ray)
	auras[15487]  = 1 -- Silence (priest)
	auras[18498]  = 1 -- Silenced - Gag Order (warrior)
	auras[34490]  = 1 -- Silencing Shot (hunter)
	auras[78675]  = 1 -- Solar Beam (druid)
	auras[97547]  = 1 -- Solar Beam (druid)
	auras[113286] = 1 -- Solar Beam (symbiosis)
	auras[113287] = 1 -- Solar Beam (symbiosis)
	auras[113288] = 1 -- Solar Beam (symbiosis)
	auras[116709] = 1 -- Spear Hand Strike (monk)
	auras[24259]  = 1 -- Spell Lock (warlock felhunter)
	auras[47476]  = 1 -- Strangulate (death knight)
end

------------------------------------------------------------------------
--	Taunted

if not PVP_MODE and (playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "MONK" or playerClass == "PALADIN" or playerClass == "WARRIOR") then
	auras[56222]  = 1 -- Dark Command
	auras[57604]  = 1 -- Death Grip -- NEEDS CHECK 57603
	auras[20736]  = 1 -- Distracting Shot
	auras[6795]   = 1 -- Growl
	auras[118585] = 1 -- Leer of the Ox
	auras[62124]  = 1 -- Reckoning
	auras[355]    = 1 -- Taunt
end

------------------------------------------------------------------------
--	Death Knight

if playerClass == "DEATHKNIGHT" then
	auras[48707]  = 4 -- Anti-Magic Shell
	auras[49222]  = 4 -- Bone Shield
	auras[53386]  = 4 -- Cinderglacier
	auras[119975] = 4 -- Conversion
	auras[101568] = 4 -- Dark Succor <= glyph
	auras[96268]  = 4 -- Death's Advance
	auras[59052]  = 4 -- Freezing Fog <= Rime
	auras[48792]  = 4 -- Icebound Fortitude
	auras[51124]  = 4 -- Killing Machine
	auras[49039]  = 4 -- Lichborne
	auras[51271]  = 4 -- Pillar of Frost
	auras[46584]  = 4 -- Raise Dead
	auras[108200] = 4 -- Remorseless Winter
	auras[51460]  = 4 -- Runic Corruption
	auras[50421]  = 4 -- Scent of Blood
	auras[116888] = 4 -- Shroud of Purgatory
	auras[8134]   = 4 -- Soul Reaper
	auras[81340]  = 4 -- Sudden Doom
	auras[115989] = 4 -- Unholy Blight
--	auras[53365]  = 4 -- Unholy Strength <= Rune of the Fallen Crusader
	auras[55233]  = 4 -- Vampiric Blood
	auras[81162]  = 4 -- Will of the Necropolis (damage reduction)
	auras[96171]  = 4 -- Will of the Necropolis (free Rune Tap)

	auras[108194] = 1 -- Asphyxiate
	auras[55078]  = 2 -- Blood Plague
	auras[45524]  = 1 -- Chains of Ice
--	auras[50435]  = 1 -- Chilblains
	auras[111673] = 2 -- Control Undead -- needs check
	auras[77606]  = 2 -- Dark Simulacrum
	auras[55095]  = 2 -- Frost Fever
	auras[51714]  = 2 -- Frost Vulernability <= Rune of Razorice
	auras[73975]  = 1 -- Necrotic Strike
	auras[115000] = 2 -- Remorseless Winter (slow)
	auras[115001] = 2 -- Remorseless Winter (stun)
	auras[114866] = 2 -- Soul Reaper (blood)
	auras[130735] = 2 -- Soul Reaper (frost)
	auras[130736] = 2 -- Soul Reaper (unholy)
	auras[47476]  = 1 -- Strangulate

	auras[49016]  = 3 -- Unholy Frenzy

	auras[63560]  = 2 -- Dark Transformation
end

------------------------------------------------------------------------
--	Druid

if playerClass == "DRUID" then
	auras[22812]  = 4 -- Barkskin
	auras[106951] = 4 -- Berserk
	auras[112071] = 4 -- Celestial Alignment
	auras[16870]  = 4 -- Clearcasting <= Omen of Clarity
	auras[1850]   = 4 -- Dash
	auras[108381] = 4 -- Dream of Cenarius (+damage)
	auras[108382] = 4 -- Dream of Cenarius (+healing)
	auras[48518]  = 4 -- Eclipse (Lunar)
	auras[48517]  = 4 -- Eclipse (Solar)
	auras[5229]   = 4 -- Enrage
	auras[124769] = 4 -- Frenzied Regeneration <= glpyh
	auras[102560] = 4 -- Incarnation: Chosen of Elune
	auras[102543] = 4 -- Incarnation: King of the Jungle
	auras[102558] = 4 -- Incarnation: Son of Ursoc
	auras[33891]  = 4 -- Incarnation: Tree of Life -- NEEDS CHECK
	auras[81192]  = 4 -- Lunar Shower
	auras[106922] = 4 -- Might of Ursoc
	auras[16689]  = 4 -- Nature's Grasp
	auras[132158] = 4 -- Nature's Swiftness
	auras[124974] = 4 -- Nature's Vigil
	auras[48391]  = 4 -- Owlkin Frenzy
	auras[69369]  = 4 -- Predator's Swiftness
	auras[132402] = 4 -- Savage Defense
	auras[127538] = 4 -- Savage Roar
	auras[93400]  = 4 -- Shooting Stars
	auras[114108] = 2 -- Soul of the Forest (resto)
	auras[48505]  = 4 -- Starfall
	auras[61336]  = 4 -- Survival Instincts
	auras[5217]   = 4 -- Tiger's Fury
	auras[102416] = 4 -- Wild Charge (aquatic)

	auras[33786]  = 1 -- Cyclone
	auras[99]     = 1 -- Disorienting Roar
	auras[339]    = 1 -- Entangling Roots
	auras[114238] = 1 -- Fae Silence <= glpyh
	auras[770]    = 1 -- Faerie Fire
	auras[102355] = 1 -- Faerie Swarm
	auras[81281]  = 1 -- Fungal Growth <= Wild Mushroom: Detonate
	auras[2637]   = 1 -- Hibernate
	auras[33745]  = 2 -- Lacerate
	auras[22570]  = 1 -- Maim
	auras[5211]   = 1 -- Mighty Bash
	auras[8921]   = 2 -- Moonfire
	auras[9005]   = 2 -- Pounce
	auras[102546] = 2 -- Pounce
	auras[9007]   = 2 -- Pounce Bleed
	auras[1822]   = 2 -- Rake
	auras[1079]   = 2 -- Rip
	auras[106839] = 1 -- Skull Bash
	auras[78675]  = 1 -- Solar Beam (silence)
	auras[97547]  = 1 -- Solar Beam (interrupt)
	auras[93402]  = 2 -- Sunfire
	auras[77758]  = 2 -- Thrash (bear)
	auras[106830] = 2 -- Thrash (cat)
	auras[61391]  = 3 -- Typhoon
	auras[102793] = 1 -- Ursol's Vortex
	auras[16979]  = 1 -- Wild Charge (bear) -- NEEDS CHECK
	auras[45334]  = 1 -- Immobilize <= Wild Charge (bear) -- NEEDS CHECK
	auras[49376]  = 1 -- Wild Charge (cat) -- NEEDS CHECK
	auras[50259]  = 1 -- Immobilize <= Wild Charge (cat) -- NEEDS CHECK

	auras[102352] = 2 -- Cenarion Ward
	auras[29166]  = 3 -- Innervate
	auras[102342] = 3 -- Ironbark
	auras[33763]  = 2 -- Lifebloom
	auras[94447]  = 2 -- Lifebloom (tree)
	auras[8936]   = 2 -- Regrowth
	auras[774]    = 2 -- Rejuvenation
	auras[77761]  = 3 -- Stampeding Roar (bear)
	auras[77764]  = 3 -- Stampeding Roar (cat)
	auras[106898] = 3 -- Stampeding Roar
	auras[48438]  = 2 -- Wild Growth
end

------------------------------------------------------------------------
--	Hunter

if playerClass == "HUNTER" then
	auras[83559]  = 4 -- Black Ice
--	auras[82921]  = 4 -- Bombardment
--	auras[53257]  = 4 -- Cobra Strikes
	auras[51755]  = 4 -- Camouflage
	auras[19263]  = 4 -- Deterrence
	auras[15571]  = 4 -- Dazed <== Aspect of the Cheetah
	auras[6197]   = 4 -- Eagle Eye
	auras[5384]   = 4 -- Feign Death
	auras[82726]  = 4 -- Fervor
	auras[82926]  = 4 -- Fire! <= Master Marksman
	auras[82692]  = 4 -- Focus Fire
	auras[56453]  = 4 -- Lock and Load
	auras[62305]  = 4 -- Master's Call -- NEEDS CHECK
	auras[64216]  = 4 -- Master's Call -- NEEDS CHECK
	auras[34477]  = 4 -- Misdirection
	auras[118922] = 4 -- Posthaste
	auras[3045]   = 4 -- Rapid Fire
--	auras[82925]  = 4 -- Ready, Set, Aim... <= Master Marksman
	auras[53220]  = 4 -- Steady Focus
	auras[34471]  = 4 -- The Beast Within
	auras[34720]  = 4 -- Thrill of the Hunt

	auras[131894] = 2 -- A Murder of Crows
	auras[117526] = 2 -- Binding Shot (stun)
	auras[117405] = 2 -- Binding Shot (tether)
	auras[3674]   = 2 -- Black Arrow
	auras[35101]  = 2 -- Concussive Barrage
	auras[5116]   = 2 -- Concussive Shot
	auras[20736]  = 2 -- Distracting Shot
	auras[64803]  = 2 -- Entrapment
	auras[53301]  = 2 -- Explosive Shot
	auras[13812]  = 2 -- Explosive Trap -- NEEDS CHECK
	auras[43446]  = 2 -- Explosive Trap Effect -- NEEDS CHECK
	auras[128961] = 2 -- Explosive Trap Effect -- NEEDS CHECK
	auras[3355]   = 2 -- Freezing Trap -- NEEDS CHECK
	auras[43448]  = 2 -- Freezing Trap -- NEEDS CHECK
	auras[61394]  = 2 -- Frozen Wake <= Glyph of Freezing Trap
	auras[120761] = 2 -- Glaive Toss -- NEEDS CHECK
	auras[121414] = 2 -- Glaive Toss -- NEEDS CHECK
	auras[1130]   = 1 -- Hunter's Mark
	auras[67035]  = 2 -- Ice Trap -- NEEDS CHECK
	auras[110610] = 2 -- Ice Trap -- NEEDS CHECK
	auras[34394]  = 2 -- Intimidation
	auras[115928] = 2 -- Narrow Escape -- NEEDS CHECK
	auras[128405] = 2 -- Narrow Escape -- NEEDS CHECK
--	auras[63468]  = 2 -- Piercing Shots
	auras[1513]   = 2 -- Scare Beast
	auras[19503]  = 2 -- Scatter Shot
	auras[118253] = 2 -- Serpent Sting
	auras[34490]  = 2 -- Silencing Shot
	auras[82654]  = 2 -- Widow Venom
	auras[19386]  = 2 -- Wyvern Sting

	auras[19615]  = 3 -- Frenzy
--	auras[118455] = 3 -- Beast Cleave
	auras[19574]  = 3 -- Bestial Wrath
	auras[136]    = 3 -- Mend Pet
	auras[35079]  = 3 -- Misdirection -- NEEDS CHECK
	auras[110588] = 3 -- Misdirection -- NEEDS CHECK
	auras[110591] = 3 -- Misdirection -- NEEDS CHECK
end

------------------------------------------------------------------------
--	Mage

if playerClass == "MAGE" then
	auras[110909] = 4 -- Alter Time
	auras[36032]  = 4 -- Arcane Charge
	auras[12042]  = 4 -- Arcane Power
	auras[108843] = 4 -- Blazing Speed
	auras[57761]  = 4 -- Brain Freeze
	auras[87023]  = 4 -- Cauterize
	auras[44544]  = 4 -- Fingers of Frost
	auras[110960] = 4 -- Greater Invisibility
	auras[48107]  = 4 -- Heating Up
	auras[11426]  = 4 -- Ice Barrier
	auras[45438]  = 4 -- Ice Block
	auras[108839] = 4 -- Ice Floes
	auras[12472]  = 4 -- Icy Veins
	auras[1463]   = 4 -- Inacnter's Ward
	auras[66]     = 4 -- Invisibility
	auras[12043]  = 4 -- Presence of Mind
	auras[116014] = 4 -- Rune of Power
	auras[115610] = 4 -- Temporal Shield (shield)
	auras[115611] = 4 -- Temporal Shield (heal)

	auras[34356]  = 2 -- Blizzard (slow) -- NEEDS CHECK
	auras[83853]  = 2 -- Combustion
	auras[120]    = 2 -- Cone of Cold
	auras[44572]  = 2 -- Deep Freeze
	auras[31661]  = 2 -- Dragon's Breath
	auras[112948] = 2 -- Frost Bomb
	auras[113092] = 2 -- Frost Bomb (slow)
	auras[122]    = 2 -- Frost Nova
	auras[116]    = 2 -- Frostbolt
	auras[44614]  = 2 -- Frostfire Bolt
	auras[102051] = 2 -- Frostjaw
	auras[84721]  = 2 -- Frozen Orb
--	auras[12654]  = 2 -- Ignite
	auras[44457]  = 2 -- Living Bomb
	auras[114923] = 2 -- Nether Tempest
	auras[118]    = 2 -- Polymorph
	auras[61305]  = 2 -- Polymorph (Black Cat)
	auras[28272]  = 2 -- Polymorph (Pig)
	auras[61721]  = 2 -- Polymorph (Rabbit)
	auras[61780]  = 2 -- Polymorph (Turkey)
	auras[28217]  = 2 -- Polymorph (Turtle)
--	auras[11366]  = 2 -- Pyroblast
	auras[132210] = 2 -- Pyromaniac
	auras[82691]  = 2 -- Ring of Frost
	auras[55021]  = 2 -- Silenced - Improved Counterspell
	auras[31589]  = 2 -- Slow
end

------------------------------------------------------------------------
--	Monk

if playerClass == "MONK" then
	auras[126050] = 4 -- Adaptation
	auras[122278] = 4 -- Dampen Harm
	auras[121125] = 4 -- Death Note
	auras[122465] = 4 -- Dematerialize
	auras[122783] = 4 -- Diffuse Magic
	auras[128939] = 4 -- Elusive Brew (stack)
	auras[115308] = 4 -- Elusive Brew (consume)
	auras[115288] = 4 -- Energizing Brew
	auras[115203] = 4 -- Fortifying Brew
	auras[115295] = 4 -- Guard
	auras[123402] = 4 -- Guard (glyphed)
	auras[124458] = 4 -- Healing Sphere (count)
	auras[115867] = 4 -- Mana Tea (stack)
	auras[119085] = 4 -- Momentum
	auras[124968] = 4 -- Retreat
	auras[127722] = 4 -- Serpent's Zeal
	auras[125359] = 4 -- Tiger Power
	auras[116841] = 4 -- Tiger's Lust
	auras[125195] = 4 -- Tigereye Brew (stack)
	auras[116740] = 4 -- Tigereye Brew (consume)
	auras[122470] = 4 -- Touch of Karma
	auras[118674] = 4 -- Vital Mists

	auras[128531] = 2 -- Blackout Kick
	auras[123393] = 2 -- Breath of Fire (disorient)
	auras[123725] = 2 -- Breath of Fire (dot)
	auras[119392] = 2 -- Charging Ox Wave
	auras[122242] = 2 -- Clash (stun) -- NEEDS CHECK
	auras[126451] = 2 -- Clash (stun) -- NEEDS CHECK
	auras[128846] = 2 -- Clash (stun) -- NEEDS CHECK
	auras[125647] = 2 -- Crackling Jade Lightning (+damage)
	auras[116095] = 2 -- Disable
	auras[116330] = 2 -- Dizzying Haze -- NEEDS CHECK
	auras[123727] = 2 -- Dizzying Haze -- NEEDS CHECK
	auras[123586] = 4 -- Flying Serpent Kick
	auras[117368] = 2 -- Grapple Weapon
	auras[118585] = 2 -- Leer of the Ox
	auras[119381] = 2 -- Leg Sweep
	auras[115078] = 2 -- Paralysis
	auras[118635] = 2 -- Provoke -- NEEDS CHECK
	auras[116189] = 2 -- Provoke -- NEEDS CHECK
	auras[130320] = 2 -- Rising Sun Kick
	auras[116847] = 2 -- Rushing Jade Wind
	auras[116709] = 2 -- Spear Hand Strike
	auras[123407] = 2 -- Spinning Fire Blossom

	auras[132120] = 2 -- Enveloping Mist
	auras[116849] = 3 -- Life Cocoon
	auras[119607] = 2 -- Renewing Mist (jump)
	auras[119611] = 2 -- Renewing Mist (hot)
	auras[124081] = 2 -- Zen Sphere
end

------------------------------------------------------------------------
--	Paladin

if playerClass == "PALADIN" then
	auras[121467] = 4 -- Alabaster Shield
	auras[31850]  = 4 -- Ardent Defender
	auras[31884]  = 4 -- Avenging Wrath
	auras[114637] = 4 -- Bastion of Glory
	auras[88819]  = 4 -- Daybreak
	auras[31842]  = 4 -- Divine Favor
	auras[54428]  = 4 -- Divine Plea
	auras[498]    = 4 -- Divine Protection
	auras[90174]  = 4 -- Divine Purpose
	auras[642]    = 4 -- Divine Shield
	auras[54957]  = 4 -- Glyph of Flash of Light
	auras[85416]  = 4 -- Grand Crusader
	auras[86659]  = 4 -- Guardian of Ancient Kings (protection)
	auras[86669]  = 4 -- Guardian of Ancient Kings (holy)
	auras[86698]  = 4 -- Guardian of Ancient Kings (retribution)
	auras[105809] = 4 -- Holy Avenger
	auras[54149]  = 4 -- Infusion of Light
	auras[84963]  = 4 -- Inquisition
	auras[114250] = 4 -- Selfless Healer
--	auras[132403] = 4 -- Shield of the Righteous
	auras[85499]  = 4 -- Speed of Light
	auras[94686]  = 4 -- Supplication

	auras[31935]  = 2 -- Avenger's Shield
--	auras[110300] = 2 -- Burden of Guilt
	auras[105421] = 2 -- Blinding Light
	auras[31803]  = 2 -- Censure
	auras[63529]  = 2 -- Dazed - Avenger's Shield
	auras[2812]   = 2 -- Denounce
	auras[114916] = 2 -- Execution Sentence
	auras[105593] = 2 -- Fist of Justice
	auras[853]    = 2 -- Hammer of Justice
	auras[119072] = 2 -- Holy Wrath
	auras[20066]  = 2 -- Repentance
	auras[10326]  = 2 -- Turn Evil

	auras[31821]  = 3 -- Devotion Aura
	auras[114163] = 3 -- Eternal Flame
	auras[1044]   = 3 -- Hand of Freedom
	auras[1022]   = 3 -- Hand of Protection
	auras[114039] = 3 -- Hand of Purity
	auras[6940]   = 3 -- Hand of Sacrifice
	auras[1038]   = 3 -- Hand of Salvation
	auras[86273]  = 3 -- Illuminated Healing
	auras[20925]  = 3 -- Sacred Shield
	auras[20170]  = 3 -- Seal of Justice
	auras[114917] = 3 -- Stay of Execution
end

------------------------------------------------------------------------
--	Priest

if playerClass == "PRIEST" then
--	auras[114214] = 4 -- Angelic Bulwark
	auras[81700]  = 4 -- Archangel
--	auras[59889]  = 4 -- Borrowed Time
	auras[47585]  = 4 -- Dispersion
	auras[123266] = 4 -- Divine Insight (discipline)
	auras[123267] = 4 -- Divine Insight (holy)
	auras[124430] = 4 -- Divine Insight (shadow)
	auras[81661]  = 4 -- Evangelism
	auras[586]    = 4 -- Fade
	auras[2096]   = 4 -- Mind Vision
	auras[114239] = 4 -- Phantasm
	auras[10060]  = 4 -- Power Infusion
	auras[63735]  = 4 -- Serendipity
	auras[112833] = 4 -- Spectral Guise
	auras[109964] = 4 -- Spirit Shell
	auras[87160]  = 4 -- Surge of Darkness -- NEEDS CHECK
	auras[126083] = 4 -- Surge of Darkness -- NEEDS CHECK
	auras[128654] = 4 -- Surge of Light -- NEEDS CHECK
	auras[114255] = 4 -- Surge of Light -- NEEDS CHECK
	auras[123254] = 4 -- Twist of Fate
	auras[15286]  = 4 -- Vampiric Embrace
	auras[108920] = 4 -- Void Tendrils

	auras[2944]   = 2 -- Devouring Plague
--	auras[14914]  = 2 -- Holy Fire
	auras[88625]  = 2 -- Holy Word: Chastise
	auras[89485]  = 2 -- Inner Focus
	auras[64044]  = 2 -- Psychic Horror (horror)
--	auras[64058]  = 2 -- Psychic Horror (disarm)
	auras[8122]   = 2 -- Psychic Scream
	auras[113792] = 2 -- Psychic Terror
	auras[9484]   = 2 -- Shackle Undead
	auras[589]    = 2 -- Shadow Word: Pain
	auras[15487]  = 2 -- Silence
	auras[34914]  = 2 -- Vampiric Touch

	auras[77613]  = 3 -- Grace
	auras[47788]  = 3 -- Guardian Spirit
	auras[88684]  = 3 -- Holy Word: Serenity
	auras[33206]  = 3 -- Pain Suppression
	auras[62618]  = 3 -- Power Word: Barrier
	auras[17]     = 3 -- Power Word: Shield
	auras[139]    = 3 -- Renew
end

------------------------------------------------------------------------
--	Rogue

if playerClass == "ROGUE" then
	auras[13750]  = 4 -- Adrenaline Rush
	auras[115189] = 4 -- Anticipation
	auras[18377]  = 4 -- Blade Flurry
	auras[121153] = 4 -- Blindside
	auras[108212] = 4 -- Burst of Speed
	auras[31224]  = 4 -- Cloak of Shadows
	auras[74002]  = 4 -- Combat Insight
	auras[74001]  = 4 -- Combat Readiness
	auras[84747]  = 4 -- Deep Insight
	auras[56814]  = 4 -- Detection
	auras[32645]  = 4 -- Envenom
	auras[5277]   = 4 -- Evasion
	auras[1966]   = 4 -- Feint
	auras[51690]  = 4 -- Killing Spree
	auras[84746]  = 4 -- Moderate Insight
	auras[73651]  = 4 -- Recuperate
	auras[121472] = 4 -- Shadow Blades
	auras[51713]  = 4 -- Shadow Dance
	auras[114842] = 4 -- Shadow Walk
	auras[36554]  = 4 -- Shadowstep
	auras[84745]  = 4 -- Shallow Insight
	auras[114018] = 4 -- Shroud of Concealment
	auras[5171]   = 4 -- Slice and Dice
	auras[76577]  = 4 -- Smoke Bomb
	auras[2983]   = 4 -- Sprint
	auras[57934]  = 4 -- Tricks of the Trade
	auras[1856]   = 4 -- Vanish

	auras[2094]   = 2 -- Blind
	auras[1833]   = 2 -- Cheap Shot
--	auras[122233] = 2 -- Crimson Tempest
--	auras[3409]   = 2 -- Crippling Poison
--	auras[2818]   = 2 -- Deadly Poison
	auras[26679]  = 2 -- Deadly Throw
	auras[51722]  = 2 -- Dismantle
	auras[91021]  = 2 -- Find Weakness
	auras[703]    = 2 -- Garrote
	auras[1330]   = 2 -- Garrote - Silence
	auras[1773]   = 2 -- Gouge
	auras[89774]  = 2 -- Hemorrhage
	auras[408]    = 2 -- Kidney Shot
	auras[112961] = 2 -- Leeching Poison
	auras[5760]   = 2 -- Mind-numbing Poison
	auras[112947] = 2 -- Nerve Strike
	auras[113952] = 2 -- Paralytic Poison
	auras[84617]  = 2 -- Revealing Strike
	auras[1943]   = 2 -- Rupture
	auras[6770]   = 2 -- Sap
	auras[57933]  = 2 -- Tricks of the Trade
	auras[79140]  = 2 -- Vendetta
	auras[8680]   = 2 -- Wound Poison
end

------------------------------------------------------------------------
--	Shaman

if playerClass == "SHAMAN" then
	auras[108281] = 4 -- Ancestral Guidance
	auras[16188]  = 4 -- Ancestral Swiftness
	auras[114050] = 4 -- Ascendance (elemental)
	auras[114051] = 4 -- Ascendance (enhancement)
	auras[114052] = 4 -- Ascendance (restoration)
	auras[108271] = 4 -- Astral Shift
	auras[118522] = 4 -- Elemental Blast
	auras[16166]  = 4 -- Elemental Mastery
	auras[6196]   = 4 -- Far Sight
	auras[77762]  = 4 -- Lava Surge
	auras[31616]  = 4 -- Nature's Guardian
--	auras[77661]  = 4 -- Searing Flames
	auras[30823]  = 4 -- Shamanistic Rage
	auras[58876]  = 4 -- Spirit Walk
	auras[79206]  = 4 -- Spiritwalker's Grace
	auras[53390]  = 4 -- Tidal Waves
	auras[73683]  = 4 -- Unleash Flame
	auras[73681]  = 4 -- Unleash Wind
	auras[118474] = 4 -- Unleashed Fury (frostbrand)
	auras[118475] = 4 -- Unleashed Fury (rockbiter)
	auras[118472] = 4 -- Unleashed Fury (windfury)

	auras[76780]  = 1 -- Bind Elemental
	auras[3600]   = 1 -- Earthbind <= Earthbind Totem
	auras[64695]  = 1 -- Earthgrab <= Earthgrab Totem
	auras[61882]  = 2 -- Earthquake
	auras[8050]   = 2 -- Flame Shock
	auras[8056]   = 1 -- Frost Shock
	auras[8034]   = 2 -- Frostbrand Attack <= Frostbrand Weapon
	auras[63685]  = 1 -- Freeze <= Frozen Power
	auras[51514]  = 1 -- Hex
	auras[8178]   = 1 -- Grounding Totem Effect
	auras[89523]  = 1 -- Grounding Totem (reflect)
	auras[118905] = 1 -- Static Charge <= Capacitor Totem
	auras[115356] = 2 -- Stormblast
	auras[120676] = 1 -- Stormlash Totem
	auras[17364]  = 2 -- Stormstrike
	auras[51490]  = 1 -- Thunderstorm
	auras[73684]  = 2 -- Unleash Earth
	auras[73682]  = 2 -- Unleash Frost
	auras[118740] = 2 -- Unleashed Fury (flametongue)

	auras[2825]   = 3 -- Bloodlust (shaman)
	auras[32182]  = 3 -- Heroism (shaman)
	auras[974]    = 2 -- Earth Shield
	auras[119523] = 3 -- Healing Stream Totem (resistance)
	auras[16191]  = 3 -- Mana Tide
	auras[61295]  = 2 -- Riptide
	auras[98007]  = 3 -- Spirit Link Totem
	auras[114893] = 3 -- Stone Bulwark
	auras[73685]  = 4 -- Unleash Life
	auras[118473] = 2 -- Unleashed Fury (earthliving)
	auras[114896] = 3 -- Windwalk Totem
end

------------------------------------------------------------------------
--	Warlock

if playerClass == "WARLOCK" then
	auras[116198] = 2 -- Aura of Enfeeblement -- NEEDS CHECK
	auras[119652] = 2 -- Aura of Enfeeblement -- NEEDS CHECK
	auras[116202] = 2 -- Aura of the Elements
	auras[117828] = 4 -- Backdraft
	auras[111400] = 4 -- Burning Rush
	auras[114168] = 4 -- Dark Apotheosis
	auras[110913] = 4 -- Dark Bargain (absorb)
	auras[110914] = 4 -- Dark Bargain (dot)
	auras[108359] = 4 -- Dark Regeneration
	auras[113858] = 4 -- Dark Soul: Instability
	auras[113861] = 4 -- Dark Soul: Knowledge
	auras[113860] = 4 -- Dark Soul: Misery
	auras[88448]  = 4 -- Demonic Rebirth
	auras[126]    = 4 -- Eye of Kilrogg
	auras[108683] = 4 -- Fire and Brimstone
	auras[119839] = 4 -- Fury Ward
	auras[80240]  = 4 -- Havoc
	auras[119049] = 4 -- Kil'jaeden's Cunning
	auras[126090] = 4 -- Molten Core -- NEEDS CHECK
	auras[122355] = 4 -- Molten Core -- NEEDS CHECK
	auras[86211]  = 4 -- Soul Swap

	auras[980]    = 2 -- Agony
	auras[108505] = 2 -- Archimonde's Vengeance
	auras[170]    = 2 -- Banish
	auras[111397] = 2 -- Blood Fear
	auras[124915] = 2 -- Chaos Wave -- NEEDS CHECK
	auras[129347] = 2 -- Chaos Wave -- NEEDS CHECK
	auras[17962]  = 2 -- Conflagrate (slow)
	auras[172]    = 2 -- Corruption
	auras[109466] = 2 -- Curse of Enfeeblement
	auras[18223]  = 2 -- Curse of Exhaustion
	auras[1490]   = 2 -- Curse of the Elements
	auras[603]    = 2 -- Doom
	auras[5782]   = 2 -- Fear
	auras[48181]  = 2 -- Haunt
	auras[5484]   = 2 -- Howl of Terror
	auras[348]    = 2 -- Immolate
	auras[103103] = 2 -- Malefic Grasp
	auras[6789]   = 2 -- Mortal Coil
	auras[60947]  = 2 -- Nightmare
	auras[108416] = 2 -- Sacrificial Pact
	auras[30108]  = 2 -- Seed of Corruption
	auras[47960]  = 2 -- Shadowflame
	auras[30283]  = 2 -- Shadowfury
	auras[104773] = 2 -- Unending Resolve
	auras[27243]  = 2 -- Unstable Affliction
end

------------------------------------------------------------------------
--	Warrior

if playerClass == "WARRIOR" then
	auras[107574] = 4 -- Avatar
	auras[18499]  = 4 -- Berserker Rage
	auras[46924]  = 4 -- Bladestorm
	auras[12292]  = 4 -- Bloodbath
	auras[46916]  = 4 -- Bloodsurge
	auras[85730]  = 4 -- Deadly Calm
	auras[125565] = 4 -- Demoralizing Shout
	auras[118038] = 4 -- Die by the Sword
	auras[12880]  = 4 -- Enrage
	auras[55964]  = 4 -- Enraged Regeneration
	auras[115945] = 4 -- Glyph of Hamstring
	auras[12975]  = 4 -- Last Stand
	auras[114028] = 4 -- Mass Spell Reflection
	auras[85739]  = 4 -- Meat Cleaver
	auras[114192] = 4 -- Mocking Banner
	auras[97463]  = 4 -- Rallying Cry
	auras[1719]   = 4 -- Recklessness
	auras[112048] = 4 -- Shield Barrier
	auras[2565]   = 4 -- Shield Block
	auras[871]    = 4 -- Shield Wall
	auras[114206] = 4 -- Skull Banner
	auras[23920]  = 4 -- Spell Banner
	auras[52437]  = 4 -- Sudden Death
	auras[12328]  = 4 -- Sweeping Strikes
	auras[50227]  = 4 -- Sword and Board
	auras[125831] = 4 -- Taste for Blood
	auras[122510] = 4 -- Ultimatum

	auras[86346]  = 2 -- Colossus Smash
	auras[114205] = 2 -- Demoralizing Banner
	auras[1160]   = 2 -- Demoralizing Shout
	auras[676]    = 2 -- Disarm
	auras[118895] = 2 -- Dragon Roar
	auras[1715]   = 2 -- Hamstring
	auras[5246]   = 2 -- Intimidating Shout -- NEEDS CHECK
	auras[20511]  = 2 -- Intimidating Shout -- NEEDS CHECK
	auras[12323]  = 2 -- Piercing Howl
	auras[64382]  = 2 -- Shattering Throw
	auras[46968]  = 2 -- Shockwave
	auras[18498]  = 2 -- Silenced - Gag Order
	auras[107566] = 2 -- Staggering Shout
	auras[107570] = 2 -- Storm Bolt
	auras[355]    = 2 -- Taunt
	auras[105771] = 2 -- Warbringer

	auras[46947]  = 3 -- Safeguard (damage reduction)
	auras[114029] = 3 -- Safeguard (intercept)
	auras[114030] = 3 -- Vigilance
end

------------------------------------------------------------------------
-- Racials

if playerRace == "BloodElf" then
	auras[50613]  = 4 -- Arcane Torrent (death knight)
	auras[80483]  = 4 -- Arcane Torrent (hunter)
	auras[28730]  = 4 -- Arcane Torrent (mage, paladin, priest, warlock)
	auras[129597] = 4 -- Arcane Torrent (monk)
	auras[25046]  = 4 -- Arcane Torrent (rogue)
	auras[69179]  = 4 -- Arcane Torrent (warrior)
elseif playerRace == "Draenei" then
	auras[59545]  = 4 -- Gift of the Naaru (death knight)
	auras[59543]  = 4 -- Gift of the Naaru (hunter)
	auras[59548]  = 4 -- Gift of the Naaru (mage)
	auras[121093] = 4 -- Gift of the Naaru (monk)
	auras[59542]  = 4 -- Gift of the Naaru (paladin)
	auras[59544]  = 4 -- Gift of the Naaru (priest)
	auras[59547]  = 4 -- Gift of the Naaru (shaman)
	auras[28880]  = 4 -- Gift of the Naaru (warrior)
elseif playerRace == "Dwarf" then
	auras[20594]  = 4 -- Stoneform
elseif playerRace == "NightElf" then
	auras[58984]  = 4 -- Shadowmeld
elseif playerRace == "Orc" then
	auras[20572]  = 4 -- Blood Fury (attack power)
	auras[33702]  = 4 -- Blood Fury (spell power)
	auras[33697]  = 4 -- Blood Fury (attack power and spell damage)
elseif playerRace == "Pandaren" then
	auras[107079] = 4 -- Quaking Palm
elseif playerRace == "Scourge" then
	auras[7744]   = 4 -- Will of the Forsaken
elseif playerRace == "Tauren" then
	auras[20549]  = 1 -- War Stomp
elseif playerRace == "Troll" then
	auras[26297]  = 4 -- Berserking
elseif playerRace == "Worgen" then
	auras[68992]  = 4 -- Darkflight
end

------------------------------------------------------------------------
--	Boss debuffs that Blizzard forgot to flag

auras[106648] = 1 -- Brew Explosion (Ook Ook in Stormsnout Brewery)
auras[106784] = 1 -- Brew Explosion (Ook Ook in Stormsnout Brewery)
auras[123059] = 1 -- Destabilize (Amber-Shaper Un'sok)

------------------------------------------------------------------------
--	NPC buffs that are completely useless

auras[63501] = 0 -- Argent Crusade Champion's Pennant
auras[60023] = 0 -- Scourge Banner Aura (Boneguard Commander in Icecrown)
auras[63406] = 0 -- Darnassus Champion's Pennant
auras[63405] = 0 -- Darnassus Valiant's Pennant
auras[63423] = 0 -- Exodar Champion's Pennant
auras[63422] = 0 -- Exodar Valiant's Pennant
auras[63396] = 0 -- Gnomeregan Champion's Pennant
auras[63395] = 0 -- Gnomeregan Valiant's Pennant
auras[63427] = 0 -- Ironforge Champion's Pennant
auras[63426] = 0 -- Ironforge Valiant's Pennant
auras[63433] = 0 -- Orgrimmar Champion's Pennant
auras[63432] = 0 -- Orgrimmar Valiant's Pennant
auras[63399] = 0 -- Sen'jin Champion's Pennant
auras[63398] = 0 -- Sen'jin Valiant's Pennant
auras[63403] = 0 -- Silvermoon Champion's Pennant
auras[63402] = 0 -- Silvermoon Valiant's Pennant
auras[62594] = 0 -- Stormwind Champion's Pennant
auras[62596] = 0 -- Stormwind Valiant's Pennant
auras[63436] = 0 -- Thunder Bluff Champion's Pennant
auras[63435] = 0 -- Thunder Bluff Valiant's Pennant
auras[63430] = 0 -- Undercity Champion's Pennant
auras[63429] = 0 -- Undercity Valiant's Pennant

------------------------------------------------------------------------

local unitIsPlayer = { player = true, pet = true, vehicle = true }

local filters = {
	[2] = function(self, unit, caster) return unitIsPlayer[caster] end,
	[3] = function(self, unit, caster) return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) end,
	[4] = function(self, unit, caster) return unit == "player" and not self.__owner.isGroupFrame end,
}

ns.CustomAuraFilters = {
	player = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3)
		-- print("CustomAuraFilter", self.__owner:GetName(), "[unit]", unit, "[caster]", caster, "[name]", name, "[id]", spellID, "[filter]", v, caster == "vehicle")
		return auras[spellID] or caster and UnitIsUnit(caster, "vehicle")
	end,
	pet = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3)
		return caster and unitIsPlayer[caster] and auras[spellID] == 2
	end,
	target = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3)
		local v = auras[spellID]
		-- print("CustomAuraFilter", unit, spellID, name, caster, v)
		if v then
			if filters[v] then
				return filters[v](self, unit, caster)
			else
				return v > 0
			end
	--[[
		if v == 1 then
			-- Whitelist
			-- print("whitelist")
			return true
		elseif v == 0 then
			-- Blacklist
			-- print("blacklist")
			return false
		elseif v and filters[v] then
			-- Specific filter
			-- print("filter", v)
			return filters[v](self, unit, caster)
	]]
		elseif UnitCanAttack("player", unit) and not UnitPlayerControlled(unit) then
			-- Hostile NPC. Show boss debuffs, auras cast by the unit, or auras cast by the player's vehicle.
			-- print("hostile NPC")
			return isBossDebuff or not caster or caster == unit or UnitIsUnit(caster, "vehicle")
		else
			-- Friendly target or hostile player. Show boss debuffs, or auras cast by the player's vehicle.
			-- print("hostile player / friendly unit")
			return isBossDebuff or not caster or UnitIsUnit(caster, "vehicle")
		end
	end,
	party = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3)
		local v = auras[spellID]
		return v and v < 4
	end,
}

ns.AuraList = auras