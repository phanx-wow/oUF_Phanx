--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Values:
	1 = by anyone on anyone
	2 = by player on anyone
	3 = by anyone on friendly
	4 = by anyone on player
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")
local _, playerRace = UnitRace("player")

local updateFuncs = {} -- functions to call to add/remove auras

local BaseAuras = {
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
	[5782]   = 1, -- Fear -- NEEDS CHECK
	[118699] = 1, -- Fear
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
	[114404] = 1, -- Void Tendrils
	[19386]  = 1, -- Wyvern Sting
}

------------------------------------------------------------------------
--	Death Knight

if playerClass == "DEATHKNIGHT" then
	-- Self Buffs
	BaseAuras[48707]  = 4 -- Anti-Magic Shell
	BaseAuras[49222]  = 4 -- Bone Shield
	BaseAuras[53386]  = 4 -- Cinderglacier
	BaseAuras[119975] = 4 -- Conversion
	BaseAuras[101568] = 4 -- Dark Succor <= glyph
	BaseAuras[96268]  = 4 -- Death's Advance
	BaseAuras[59052]  = 4 -- Freezing Fog <= Rime
	BaseAuras[48792]  = 4 -- Icebound Fortitude
	BaseAuras[51124]  = 4 -- Killing Machine
	BaseAuras[49039]  = 4 -- Lichborne
	BaseAuras[51271]  = 4 -- Pillar of Frost
	BaseAuras[46584]  = 4 -- Raise Dead
	BaseAuras[108200] = 4 -- Remorseless Winter
	BaseAuras[51460]  = 4 -- Runic Corruption
	BaseAuras[50421]  = 4 -- Scent of Blood
	BaseAuras[116888] = 4 -- Shroud of Purgatory
	BaseAuras[8134]   = 4 -- Soul Reaper
	BaseAuras[81340]  = 4 -- Sudden Doom
	BaseAuras[115989] = 4 -- Unholy Blight
--	BaseAuras[53365]  = 4 -- Unholy Strength <= Rune of the Fallen Crusader
	BaseAuras[55233]  = 4 -- Vampiric Blood
	BaseAuras[81162]  = 4 -- Will of the Necropolis (damage reduction)
	BaseAuras[96171]  = 4 -- Will of the Necropolis (free Rune Tap)

	-- Pet Buffs
	BaseAuras[63560]  = 2 -- Dark Transformation

	-- Buffs
	BaseAuras[49016]  = 3 -- Unholy Frenzy

	-- Debuffs
	BaseAuras[108194] = 1 -- Asphyxiate
	BaseAuras[55078]  = 2 -- Blood Plague
	BaseAuras[45524]  = 1 -- Chains of Ice
--	BaseAuras[50435]  = 1 -- Chilblains
	BaseAuras[111673] = 2 -- Control Undead -- needs check
	BaseAuras[77606]  = 2 -- Dark Simulacrum
	BaseAuras[55095]  = 2 -- Frost Fever
	BaseAuras[51714]  = 2 -- Frost Vulernability <= Rune of Razorice
	BaseAuras[73975]  = 1 -- Necrotic Strike
	BaseAuras[115000] = 2 -- Remorseless Winter (slow)
	BaseAuras[115001] = 2 -- Remorseless Winter (stun)
	BaseAuras[114866] = 2 -- Soul Reaper (blood)
	BaseAuras[130735] = 2 -- Soul Reaper (frost)
	BaseAuras[130736] = 2 -- Soul Reaper (unholy)
	BaseAuras[47476]  = 1 -- Strangulate

end

------------------------------------------------------------------------
--	Druid

if playerClass == "DRUID" then
	-- Self Buffs
	BaseAuras[22812]  = 4 -- Barkskin
	BaseAuras[106951] = 4 -- Berserk (cat)
	BaseAuras[50334]  = 4 -- Berserk (bear)
	BaseAuras[112071] = 4 -- Celestial Alignment
	BaseAuras[16870]  = 4 -- Clearcasting <= Omen of Clarity
	BaseAuras[1850]   = 4 -- Dash
	BaseAuras[108381] = 4 -- Dream of Cenarius (+damage)
	BaseAuras[108382] = 4 -- Dream of Cenarius (+healing)
	BaseAuras[48518]  = 4 -- Eclipse (Lunar)
	BaseAuras[48517]  = 4 -- Eclipse (Solar)
	BaseAuras[5229]   = 4 -- Enrage
	BaseAuras[124769] = 4 -- Frenzied Regeneration <= glyph
	BaseAuras[102560] = 4 -- Incarnation: Chosen of Elune
	BaseAuras[102543] = 4 -- Incarnation: King of the Jungle
	BaseAuras[102558] = 4 -- Incarnation: Son of Ursoc
	BaseAuras[33891]  = 4 -- Incarnation: Tree of Life -- NEEDS CHECK
	BaseAuras[81192]  = 4 -- Lunar Shower
	BaseAuras[106922] = 4 -- Might of Ursoc
	BaseAuras[16689]  = 4 -- Nature's Grasp
	BaseAuras[132158] = 4 -- Nature's Swiftness
	BaseAuras[124974] = 4 -- Nature's Vigil
	BaseAuras[48391]  = 4 -- Owlkin Frenzy
	BaseAuras[69369]  = 4 -- Predator's Swiftness
	BaseAuras[132402] = 4 -- Savage Defense
	BaseAuras[52610]  = 4 -- Savage Roar -- VERIFIED 13/02/20 on tauren feral
	BaseAuras[127538] = 4 -- Savage Roar -- NEEDS CHECK
	BaseAuras[93400]  = 4 -- Shooting Stars
	BaseAuras[114108] = 2 -- Soul of the Forest (resto)
	BaseAuras[48505]  = 4 -- Starfall
	BaseAuras[61336]  = 4 -- Survival Instincts
	BaseAuras[5217]   = 4 -- Tiger's Fury
	BaseAuras[102416] = 4 -- Wild Charge (aquatic)

	-- Buffs
	BaseAuras[102351] = 2 -- Cenarion Ward (buff)
	BaseAuras[102352] = 2 -- Cenarion Ward (heal)
	BaseAuras[29166]  = 3 -- Innervate
	BaseAuras[102342] = 3 -- Ironbark
	BaseAuras[33763]  = 2 -- Lifebloom
	BaseAuras[94447]  = 2 -- Lifebloom (tree)
	BaseAuras[8936]   = 2 -- Regrowth
	BaseAuras[774]    = 2 -- Rejuvenation
	BaseAuras[77761]  = 3 -- Stampeding Roar (bear)
	BaseAuras[77764]  = 3 -- Stampeding Roar (cat)
	BaseAuras[106898] = 3 -- Stampeding Roar (caster)
	BaseAuras[48438]  = 2 -- Wild Growth

	-- Debuffs
	BaseAuras[102795] = 1 -- Bear Hug
	BaseAuras[33786]  = 1 -- Cyclone
	BaseAuras[99]     = 1 -- Disorienting Roar
	BaseAuras[339]    = 1 -- Entangling Roots
	BaseAuras[114238] = 1 -- Fae Silence <= glpyh
	BaseAuras[81281]  = 1 -- Fungal Growth <= Wild Mushroom: Detonate
	BaseAuras[2637]   = 1 -- Hibernate
	BaseAuras[33745]  = 2 -- Lacerate
	BaseAuras[22570]  = 1 -- Maim
	BaseAuras[5211]   = 1 -- Mighty Bash
	BaseAuras[8921]   = 2 -- Moonfire
	BaseAuras[9005]   = 2 -- Pounce -- NEEDS CHECK
	BaseAuras[102546] = 2 -- Pounce -- NEEDS CHECK
	BaseAuras[9007]   = 2 -- Pounce Bleed
	BaseAuras[1822]   = 2 -- Rake
	BaseAuras[1079]   = 2 -- Rip
	BaseAuras[106839] = 1 -- Skull Bash -- NOT CURRENTLY USED
	BaseAuras[78675]  = 1 -- Solar Beam (silence)
	BaseAuras[97547]  = 1 -- Solar Beam (interrupt)
	BaseAuras[93402]  = 2 -- Sunfire
	BaseAuras[77758]  = 2 -- Thrash (bear)
	BaseAuras[106830] = 2 -- Thrash (cat)
	BaseAuras[61391]  = 3 -- Typhoon
	BaseAuras[102793] = 1 -- Ursol's Vortex
	BaseAuras[45334]  = 1 -- Immobilize <= Wild Charge (bear)
	BaseAuras[50259]  = 1 -- Dazed <= Wild Charge (cat)
--[[
	if PVP_MODE then
		BaseAuras[770]    = 1 -- Faerie Fire
		BaseAuras[102355] = 1 -- Faerie Swarm
	end
]]
end

------------------------------------------------------------------------
--	Hunter

if playerClass == "HUNTER" then
	-- Self Buffs
	BaseAuras[83559]  = 4 -- Black Ice
--	BaseAuras[82921]  = 4 -- Bombardment
--	BaseAuras[53257]  = 4 -- Cobra Strikes
	BaseAuras[51755]  = 4 -- Camouflage
	BaseAuras[19263]  = 4 -- Deterrence
	BaseAuras[15571]  = 4 -- Dazed <== Aspect of the Cheetah
	BaseAuras[6197]   = 4 -- Eagle Eye
	BaseAuras[5384]   = 4 -- Feign Death
	BaseAuras[82726]  = 4 -- Fervor
	BaseAuras[82926]  = 4 -- Fire! <= Master Marksman
	BaseAuras[82692]  = 4 -- Focus Fire
	BaseAuras[56453]  = 4 -- Lock and Load
	BaseAuras[54216]  = 4 -- Master's Call
	BaseAuras[34477]  = 4 -- Misdirection
	BaseAuras[118922] = 4 -- Posthaste
	BaseAuras[3045]   = 4 -- Rapid Fire
--	BaseAuras[82925]  = 4 -- Ready, Set, Aim... <= Master Marksman
	BaseAuras[53220]  = 4 -- Steady Focus
	BaseAuras[34471]  = 4 -- The Beast Within
	BaseAuras[34720]  = 4 -- Thrill of the Hunt

	-- Pet Buffs
	BaseAuras[19615]  = 2 -- Frenzy
	BaseAuras[19574]  = 2 -- Bestial Wrath
	BaseAuras[136]    = 2 -- Mend Pet

	-- Buffs
	BaseAuras[34477]  = 1 -- Misdirection (30 sec threat)
	BaseAuras[35079]  = 1 -- Misdirection (4 sec transfer)

	-- Debuffs
	BaseAuras[131894] = 2 -- BaseAuras Murder of Crows
	BaseAuras[117526] = 2 -- Binding Shot (stun)
	BaseAuras[117405] = 2 -- Binding Shot (tether)
	BaseAuras[3674]   = 2 -- Black Arrow
	BaseAuras[35101]  = 2 -- Concussive Barrage
	BaseAuras[5116]   = 2 -- Concussive Shot
	BaseAuras[20736]  = 2 -- Distracting Shot
	BaseAuras[64803]  = 2 -- Entrapment
	BaseAuras[53301]  = 2 -- Explosive Shot
	BaseAuras[13812]  = 2 -- Explosive Trap
	BaseAuras[43446]  = 2 -- Explosive Trap Effect -- NEEDS CHECK
	BaseAuras[128961] = 2 -- Explosive Trap Effect -- NEEDS CHECK
	BaseAuras[3355]   = 2 -- Freezing Trap
	BaseAuras[61394]  = 2 -- Frozen Wake <= Glyph of Freezing Trap
	BaseAuras[120761] = 2 -- Glaive Toss -- NEEDS CHECK
	BaseAuras[121414] = 2 -- Glaive Toss -- NEEDS CHECK
	BaseAuras[1130]   = 1 -- Hunter's Mark
	BaseAuras[135299] = 1 -- Ice Trap
	BaseAuras[34394]  = 2 -- Intimidation
	BaseAuras[115928] = 2 -- Narrow Escape -- NEEDS CHECK
	BaseAuras[128405] = 2 -- Narrow Escape -- NEEDS CHECK
--	BaseAuras[63468]  = 2 -- Piercing Shots
	BaseAuras[1513]   = 2 -- Scare Beast
	BaseAuras[19503]  = 2 -- Scatter Shot
	BaseAuras[118253] = 2 -- Serpent Sting
	BaseAuras[34490]  = 2 -- Silencing Shot
	BaseAuras[82654]  = 2 -- Widow Venom
	BaseAuras[19386]  = 2 -- Wyvern Sting
end

------------------------------------------------------------------------
--	Mage

if playerClass == "MAGE" then
	-- Self Buffs
	BaseAuras[110909] = 4 -- Alter Time
	BaseAuras[36032]  = 4 -- Arcane Charge
	BaseAuras[12042]  = 4 -- Arcane Power
	BaseAuras[108843] = 4 -- Blazing Speed
	BaseAuras[57761]  = 4 -- Brain Freeze
	BaseAuras[87023]  = 4 -- Cauterize
	BaseAuras[44544]  = 4 -- Fingers of Frost
	BaseAuras[110960] = 4 -- Greater Invisibility
	BaseAuras[48107]  = 4 -- Heating Up
	BaseAuras[11426]  = 4 -- Ice Barrier
	BaseAuras[45438]  = 4 -- Ice Block
	BaseAuras[108839] = 4 -- Ice Floes
	BaseAuras[12472]  = 4 -- Icy Veins
	BaseAuras[116267] = 4 -- Inacnter's Absorption
	BaseAuras[1463]   = 4 -- Inacnter's Ward
	BaseAuras[66]     = 4 -- Invisibility
	BaseAuras[12043]  = 4 -- Presence of Mind
	BaseAuras[116014] = 4 -- Rune of Power
	BaseAuras[48108]  = 4 -- Pyroblast!
	BaseAuras[115610] = 4 -- Temporal Shield (shield)
	BaseAuras[115611] = 4 -- Temporal Shield (heal)

	-- Debuffs
	BaseAuras[34356]  = 2 -- Blizzard (slow) -- NEEDS CHECK
	BaseAuras[83853]  = 2 -- Combustion
	BaseAuras[120]    = 2 -- Cone of Cold
	BaseAuras[44572]  = 2 -- Deep Freeze
	BaseAuras[31661]  = 2 -- Dragon's Breath
	BaseAuras[112948] = 2 -- Frost Bomb
	BaseAuras[113092] = 2 -- Frost Bomb (slow)
	BaseAuras[122]    = 2 -- Frost Nova
	BaseAuras[116]    = 2 -- Frostbolt
	BaseAuras[44614]  = 2 -- Frostfire Bolt
	BaseAuras[102051] = 2 -- Frostjaw
	BaseAuras[84721]  = 2 -- Frozen Orb
--	BaseAuras[12654]  = 2 -- Ignite
	BaseAuras[44457]  = 2 -- Living Bomb
	BaseAuras[114923] = 2 -- Nether Tempest
	BaseAuras[118]    = 2 -- Polymorph
	BaseAuras[61305]  = 2 -- Polymorph (Black Cat)
	BaseAuras[28272]  = 2 -- Polymorph (Pig)
	BaseAuras[61721]  = 2 -- Polymorph (Rabbit)
	BaseAuras[61780]  = 2 -- Polymorph (Turkey)
	BaseAuras[28217]  = 2 -- Polymorph (Turtle)
--	BaseAuras[11366]  = 2 -- Pyroblast
	BaseAuras[132210] = 2 -- Pyromaniac
	BaseAuras[82691]  = 2 -- Ring of Frost
	BaseAuras[55021]  = 2 -- Silenced - Improved Counterspell
	BaseAuras[31589]  = 2 -- Slow
end

------------------------------------------------------------------------
--	Monk

if playerClass == "MONK" then
	-- Self Buffs
	BaseAuras[122278] = 4 -- Dampen Harm
	BaseAuras[121125] = 4 -- Death Note
	BaseAuras[122783] = 4 -- Diffuse Magic
	BaseAuras[128939] = 4 -- Elusive Brew (stack)
	BaseAuras[115308] = 4 -- Elusive Brew (consume)
	BaseAuras[115288] = 4 -- Energizing Brew
	BaseAuras[115203] = 4 -- Fortifying Brew
	BaseAuras[115295] = 4 -- Guard
	BaseAuras[123402] = 4 -- Guard (glyphed)
	BaseAuras[124458] = 4 -- Healing Sphere (count)
	BaseAuras[115867] = 4 -- Mana Tea (stack)
	BaseAuras[119085] = 4 -- Momentum
	BaseAuras[124968] = 4 -- Retreat
	BaseAuras[127722] = 4 -- Serpent's Zeal
	BaseAuras[125359] = 4 -- Tiger Power
	BaseAuras[116841] = 4 -- Tiger's Lust
	BaseAuras[125195] = 4 -- Tigereye Brew (stack)
	BaseAuras[116740] = 4 -- Tigereye Brew (consume)
	BaseAuras[122470] = 4 -- Touch of Karma
	BaseAuras[118674] = 4 -- Vital Mists

	-- Buffs
	BaseAuras[132120] = 2 -- Enveloping Mist
	BaseAuras[116849] = 3 -- Life Cocoon
	BaseAuras[119607] = 2 -- Renewing Mist (jump)
	BaseAuras[119611] = 2 -- Renewing Mist (hot)
	BaseAuras[124081] = 2 -- Zen Sphere

	-- Debuffs
	BaseAuras[123393] = 2 -- Breath of Fire (disorient)
	BaseAuras[123725] = 2 -- Breath of Fire (dot)
	BaseAuras[119392] = 2 -- Charging Ox Wave
	BaseAuras[122242] = 2 -- Clash (stun) -- NEEDS CHECK
	BaseAuras[126451] = 2 -- Clash (stun) -- NEEDS CHECK
	BaseAuras[128846] = 2 -- Clash (stun) -- NEEDS CHECK
	BaseAuras[116095] = 2 -- Disable
	BaseAuras[116330] = 2 -- Dizzying Haze -- NEEDS CHECK
	BaseAuras[123727] = 2 -- Dizzying Haze -- NEEDS CHECK
	BaseAuras[117368] = 2 -- Grapple Weapon
	BaseAuras[118585] = 2 -- Leer of the Ox
	BaseAuras[119381] = 2 -- Leg Sweep
	BaseAuras[115078] = 2 -- Paralysis
	BaseAuras[118635] = 2 -- Provoke -- NEEDS CHECK
	BaseAuras[116189] = 2 -- Provoke -- NEEDS CHECK
	BaseAuras[130320] = 2 -- Rising Sun Kick
	BaseAuras[116847] = 2 -- Rushing Jade Wind
	BaseAuras[116709] = 2 -- Spear Hand Strike
	BaseAuras[123407] = 2 -- Spinning Fire Blossom
end

------------------------------------------------------------------------
--	Paladin

if playerClass == "PALADIN" then
	-- Self Buffs
	BaseAuras[121467] = 4 -- Alabaster Shield
	BaseAuras[31850]  = 4 -- Ardent Defender
	BaseAuras[31884]  = 4 -- Avenging Wrath
	BaseAuras[114637] = 4 -- Bastion of Glory
	BaseAuras[88819]  = 4 -- Daybreak
	BaseAuras[31842]  = 4 -- Divine Favor
	BaseAuras[54428]  = 4 -- Divine Plea
	BaseAuras[498]    = 4 -- Divine Protection
	BaseAuras[90174]  = 4 -- Divine Purpose
	BaseAuras[642]    = 4 -- Divine Shield
	BaseAuras[54957]  = 4 -- Glyph of Flash of Light
	BaseAuras[85416]  = 4 -- Grand Crusader
	BaseAuras[86659]  = 4 -- Guardian of Ancient Kings (protection)
	BaseAuras[86669]  = 4 -- Guardian of Ancient Kings (holy)
	BaseAuras[86698]  = 4 -- Guardian of Ancient Kings (retribution)
	BaseAuras[105809] = 4 -- Holy Avenger
	BaseAuras[54149]  = 4 -- Infusion of Light
	BaseAuras[84963]  = 4 -- Inquisition
	BaseAuras[114250] = 4 -- Selfless Healer
--	BaseAuras[132403] = 4 -- Shield of the Righteous
	BaseAuras[85499]  = 4 -- Speed of Light
	BaseAuras[94686]  = 4 -- Supplication

	-- Buffs
	BaseAuras[53563]  = 3 -- Beacon of Light
	BaseAuras[31821]  = 3 -- Devotion Aura
	BaseAuras[114163] = 3 -- Eternal Flame
	BaseAuras[1044]   = 3 -- Hand of Freedom
	BaseAuras[1022]   = 3 -- Hand of Protection
	BaseAuras[114039] = 3 -- Hand of Purity
	BaseAuras[6940]   = 3 -- Hand of Sacrifice
	BaseAuras[1038]   = 3 -- Hand of Salvation
	BaseAuras[86273]  = 3 -- Illuminated Healing
	BaseAuras[20925]  = 3 -- Sacred Shield
	BaseAuras[20170]  = 3 -- Seal of Justice
	BaseAuras[114917] = 3 -- Stay of Execution

	-- Buff Debuffs
	BaseAuras[25771]  = 3 -- Forbearace

	-- Debuffs
	BaseAuras[31935]  = 2 -- Avenger's Shield
--	BaseAuras[110300] = 2 -- Burden of Guilt
	BaseAuras[105421] = 2 -- Blinding Light
	BaseAuras[31803]  = 2 -- Censure
	BaseAuras[63529]  = 2 -- Dazed - Avenger's Shield
	BaseAuras[2812]   = 2 -- Denounce
	BaseAuras[114916] = 2 -- Execution Sentence
	BaseAuras[105593] = 2 -- Fist of Justice
	BaseAuras[853]    = 2 -- Hammer of Justice
	BaseAuras[119072] = 2 -- Holy Wrath
	BaseAuras[20066]  = 2 -- Repentance
	BaseAuras[10326]  = 2 -- Turn Evil
end

------------------------------------------------------------------------
--	Priest

if playerClass == "PRIEST" then
	-- Self Buffs
--	BaseAuras[114214] = 4 -- Angelic Bulwark
	BaseAuras[81700]  = 4 -- Archangel
--	BaseAuras[59889]  = 4 -- Borrowed Time
	BaseAuras[47585]  = 4 -- Dispersion
	BaseAuras[123266] = 4 -- Divine Insight (discipline)
	BaseAuras[123267] = 4 -- Divine Insight (holy)
	BaseAuras[124430] = 4 -- Divine Insight (shadow)
	BaseAuras[81661]  = 4 -- Evangelism
	BaseAuras[586]    = 4 -- Fade
	BaseAuras[2096]   = 4 -- Mind Vision
	BaseAuras[114239] = 4 -- Phantasm
	BaseAuras[10060]  = 4 -- Power Infusion
	BaseAuras[63735]  = 4 -- Serendipity
	BaseAuras[112833] = 4 -- Spectral Guise
	BaseAuras[109964] = 4 -- Spirit Shell (self)
	BaseAuras[87160]  = 4 -- Surge of Darkness
	BaseAuras[114255] = 4 -- Surge of Light
	BaseAuras[123254] = 4 -- Twist of Fate
	BaseAuras[15286]  = 4 -- Vampiric Embrace

	-- Buffs
	BaseAuras[47753]  = 3 -- Divine Aegis
	BaseAuras[77613]  = 2 -- Grace
	BaseAuras[47788]  = 3 -- Guardian Spirit
	BaseAuras[88684]  = 3 -- Holy Word: Serenity
	BaseAuras[33206]  = 3 -- Pain Suppression
	BaseAuras[81782]  = 3 -- Power Word: Barrier
	BaseAuras[17]     = 3 -- Power Word: Shield
	BaseAuras[41635]  = 3 -- Prayer of Mending
	BaseAuras[139]    = 3 -- Renew
	BaseAuras[114908] = 3 -- Spirit Shell (shield)

	-- Buff Debuffs
	BaseAuras[6788]   = 1 -- Weakened Soul

	-- Debuffs
	BaseAuras[2944]   = 2 -- Devouring Plague
	BaseAuras[14914]  = 2 -- Holy Fire
	BaseAuras[88625]  = 2 -- Holy Word: Chastise
	BaseAuras[89485]  = 2 -- Inner Focus
	BaseAuras[64044]  = 2 -- Psychic Horror (horror)
--	BaseAuras[64058]  = 2 -- Psychic Horror (disarm)
	BaseAuras[8122]   = 2 -- Psychic Scream
	BaseAuras[113792] = 2 -- Psychic Terror
	BaseAuras[9484]   = 2 -- Shackle Undead
	BaseAuras[589]    = 2 -- Shadow Word: Pain
	BaseAuras[15487]  = 2 -- Silence
	BaseAuras[34914]  = 2 -- Vampiric Touch
end

------------------------------------------------------------------------
--	Rogue

if playerClass == "ROGUE" then
	-- Self Buffs
	BaseAuras[13750]  = 4 -- Adrenaline Rush
	BaseAuras[115189] = 4 -- Anticipation
	BaseAuras[18377]  = 4 -- Blade Flurry
	BaseAuras[121153] = 4 -- Blindside
	BaseAuras[108212] = 4 -- Burst of Speed
	BaseAuras[31224]  = 4 -- Cloak of Shadows
	BaseAuras[74002]  = 4 -- Combat Insight
	BaseAuras[74001]  = 4 -- Combat Readiness
	BaseAuras[84747]  = 4 -- Deep Insight
	BaseAuras[56814]  = 4 -- Detection
	BaseAuras[32645]  = 4 -- Envenom
	BaseAuras[5277]   = 4 -- Evasion
	BaseAuras[1966]   = 4 -- Feint
	BaseAuras[51690]  = 4 -- Killing Spree
	BaseAuras[84746]  = 4 -- Moderate Insight
	BaseAuras[73651]  = 4 -- Recuperate
	BaseAuras[121472] = 4 -- Shadow Blades
	BaseAuras[51713]  = 4 -- Shadow Dance
	BaseAuras[114842] = 4 -- Shadow Walk
	BaseAuras[36554]  = 4 -- Shadowstep
	BaseAuras[84745]  = 4 -- Shallow Insight
	BaseAuras[114018] = 4 -- Shroud of Concealment
	BaseAuras[5171]   = 4 -- Slice and Dice
	BaseAuras[76577]  = 4 -- Smoke Bomb
	BaseAuras[2983]   = 4 -- Sprint
	BaseAuras[57934]  = 4 -- Tricks of the Trade
	BaseAuras[1856]   = 4 -- Vanish

	-- Debuffs
	BaseAuras[2094]   = 2 -- Blind
	BaseAuras[1833]   = 2 -- Cheap Shot
--	BaseAuras[122233] = 2 -- Crimson Tempest
--	BaseAuras[3409]   = 2 -- Crippling Poison
--	BaseAuras[2818]   = 2 -- Deadly Poison
	BaseAuras[26679]  = 2 -- Deadly Throw
	BaseAuras[51722]  = 2 -- Dismantle
	BaseAuras[91021]  = 2 -- Find Weakness
	BaseAuras[703]    = 2 -- Garrote
	BaseAuras[1330]   = 2 -- Garrote - Silence
	BaseAuras[1773]   = 2 -- Gouge
	BaseAuras[89774]  = 2 -- Hemorrhage
	BaseAuras[408]    = 2 -- Kidney Shot
	BaseAuras[112961] = 2 -- Leeching Poison
	BaseAuras[5760]   = 2 -- Mind-numbing Poison
	BaseAuras[112947] = 2 -- Nerve Strike
	BaseAuras[113952] = 2 -- Paralytic Poison
	BaseAuras[84617]  = 2 -- Revealing Strike
	BaseAuras[1943]   = 2 -- Rupture
	BaseAuras[6770]   = 2 -- Sap
	BaseAuras[57933]  = 2 -- Tricks of the Trade
	BaseAuras[79140]  = 2 -- Vendetta
	BaseAuras[8680]   = 2 -- Wound Poison
end

------------------------------------------------------------------------
--	Shaman

if playerClass == "SHAMAN" then
	-- Self Buffs
	BaseAuras[108281] = 4 -- Ancestral Guidance
	BaseAuras[16188]  = 4 -- Ancestral Swiftness
	BaseAuras[114050] = 4 -- Ascendance (elemental)
	BaseAuras[114051] = 4 -- Ascendance (enhancement)
	BaseAuras[114052] = 4 -- Ascendance (restoration)
	BaseAuras[108271] = 4 -- Astral Shift
	BaseAuras[16166]  = 4 -- Elemental Mastery
	BaseAuras[77762]  = 4 -- Lava Surge
	BaseAuras[31616]  = 4 -- Nature's Guardian
	BaseAuras[77661]  = 4 -- Searing Flames
	BaseAuras[30823]  = 4 -- Shamanistic Rage
	BaseAuras[58876]  = 4 -- Spirit Walk
	BaseAuras[79206]  = 4 -- Spiritwalker's Grace
	BaseAuras[53390]  = 4 -- Tidal Waves

	-- Buffs
	--BaseAuras[2825]   = 3 -- Bloodlust (shaman) -- show all
	BaseAuras[32182]  = 3 -- Heroism (shaman)
	BaseAuras[974]    = 2 -- Earth Shield
	BaseAuras[8178]   = 1 -- Grounding Totem Effect
	BaseAuras[89523]  = 1 -- Grounding Totem (reflect)
	BaseAuras[119523] = 3 -- Healing Stream Totem (resistance)
	BaseAuras[16191]  = 3 -- Mana Tide
	BaseAuras[61295]  = 2 -- Riptide
	BaseAuras[98007]  = 3 -- Spirit Link Totem
	BaseAuras[114893] = 3 -- Stone Bulwark
	--BaseAuras[120676] = 1 -- Stormlash Totem -- see totem timer
	BaseAuras[73685]  = 4 -- Unleash Life
	BaseAuras[118473] = 2 -- Unleashed Fury (earthliving)
	BaseAuras[114896] = 3 -- Windwalk Totem

	-- Debuffs
	BaseAuras[61882]  = 2 -- Earthquake
	BaseAuras[8050]   = 2 -- Flame Shock
	BaseAuras[115356] = 2 -- Stormblast
	BaseAuras[17364]  = 2 -- Stormstrike
	--BaseAuras[73684]  = 2 -- Unleash Earth
	BaseAuras[73682]  = 2 -- Unleash Frost
	BaseAuras[118470] = 2 -- Unleashed Fury (flametongue)

	-- Debuffs - Crowd Control
	BaseAuras[76780]  = 1 -- Bind Elemental
	BaseAuras[51514]  = 1 -- Hex

	-- Debuffs - Root/Slow
	BaseAuras[3600]   = 1 -- Earthbind <= Earthbind Totem
	BaseAuras[64695]  = 1 -- Earthgrab <= Earthgrab Totem
	BaseAuras[8056]   = 1 -- Frost Shock
	BaseAuras[8034]   = 2 -- Frostbrand Attack <= Frostbrand Weapon
	BaseAuras[63685]  = 1 -- Freeze <= Frozen Power
	BaseAuras[118905] = 1 -- Static Charge <= Capacitor Totem
	--BaseAuras[51490]  = 1 -- Thunderstorm
end

------------------------------------------------------------------------
--	Warlock

if playerClass == "WARLOCK" then
	-- Self Buffs
	BaseAuras[116198] = 2 -- Aura of Enfeeblement
	BaseAuras[116202] = 2 -- Aura of the Elements
	BaseAuras[117828] = 4 -- Backdraft
	BaseAuras[111400] = 4 -- Burning Rush
	BaseAuras[114168] = 4 -- Dark Apotheosis
	BaseAuras[110913] = 4 -- Dark Bargain (absorb)
	BaseAuras[110914] = 4 -- Dark Bargain (dot)
	BaseAuras[108359] = 4 -- Dark Regeneration
	BaseAuras[113858] = 4 -- Dark Soul: Instability
	BaseAuras[113861] = 4 -- Dark Soul: Knowledge
	BaseAuras[113860] = 4 -- Dark Soul: Misery
	BaseAuras[88448]  = 4 -- Demonic Rebirth
	BaseAuras[126]    = 4 -- Eye of Kilrogg
	BaseAuras[108683] = 4 -- Fire and Brimstone
	BaseAuras[119839] = 4 -- Fury Ward
	BaseAuras[119049] = 4 -- Kil'jaeden's Cunning
	BaseAuras[126090] = 4 -- Molten Core -- NEEDS CHECK
	BaseAuras[122355] = 4 -- Molten Core -- NEEDS CHECK
	BaseAuras[104232] = 4 -- Rain of Fire
	BaseAuras[108416] = 4 -- Sacrificial Pact
	BaseAuras[86211]  = 4 -- Soul Swap
	BaseAuras[104773] = 4 -- Unending Resolve

	-- Buffs
	BaseAuras[20707]  = 1 -- Soulstone

	-- Debuffs
	BaseAuras[980]    = 2 -- Agony
	BaseAuras[108505] = 2 -- Archimonde's Vengeance
	BaseAuras[124915] = 2 -- Chaos Wave
	BaseAuras[17962]  = 2 -- Conflagrate (slow)
	BaseAuras[172]    = 2 -- Corruption -- NEEDS CHECK
	BaseAuras[131740] = 2 -- Corruption -- NEEDS CHECK
	BaseAuras[146739] = 2 -- Corruption -- NEEDS CHECK
	BaseAuras[109466] = 2 -- Curse of Enfeeblement
	BaseAuras[18223]  = 2 -- Curse of Exhaustion
	BaseAuras[1490]   = 2 -- Curse of the Elements
	BaseAuras[603]    = 2 -- Doom
	BaseAuras[48181]  = 2 -- Haunt
	BaseAuras[80240]  = 2 -- Havoc
	BaseAuras[348]    = 2 -- Immolate
	BaseAuras[108686] = 2 -- Immolate <= Fire and Brimstone
	BaseAuras[60947]  = 2 -- Nightmare
	BaseAuras[30108]  = 2 -- Seed of Corruption
	BaseAuras[47960]  = 2 -- Shadowflame
	BaseAuras[30283]  = 2 -- Shadowfury
	BaseAuras[27243]  = 2 -- Unstable Affliction

	-- Debuffs - Crowd Control
	BaseAuras[170]    = 2 -- Banish
	BaseAuras[111397] = 2 -- Blood Fear
	BaseAuras[137143] = 2 -- Blood Horror
	BaseAuras[1098]   = 2 -- Enslave Demon
	BaseAuras[5782]   = 2 -- Fear
	BaseAuras[5484]   = 2 -- Howl of Terror
	BaseAuras[6789]   = 2 -- Mortal Coil
end

------------------------------------------------------------------------
--	Warrior

if playerClass == "WARRIOR" then
	-- Self Buffs
	BaseAuras[107574] = 4 -- Avatar
	BaseAuras[18499]  = 4 -- Berserker Rage
	BaseAuras[46924]  = 4 -- Bladestorm
	BaseAuras[12292]  = 4 -- Bloodbath
	BaseAuras[46916]  = 4 -- Bloodsurge
	BaseAuras[85730]  = 4 -- Deadly Calm
	BaseAuras[125565] = 4 -- Demoralizing Shout
	BaseAuras[118038] = 4 -- Die by the Sword
	BaseAuras[12880]  = 4 -- Enrage
	BaseAuras[55964]  = 4 -- Enraged Regeneration
	BaseAuras[115945] = 4 -- Glyph of Hamstring
	BaseAuras[12975]  = 4 -- Last Stand
	BaseAuras[114028] = 4 -- Mass Spell Reflection
	BaseAuras[85739]  = 4 -- Meat Cleaver
	BaseAuras[114192] = 4 -- Mocking Banner
	BaseAuras[97463]  = 4 -- Rallying Cry
	BaseAuras[1719]   = 4 -- Recklessness
	BaseAuras[112048] = 4 -- Shield Barrier
	BaseAuras[2565]   = 4 -- Shield Block
	BaseAuras[871]    = 4 -- Shield Wall
	BaseAuras[114206] = 4 -- Skull Banner
	BaseAuras[23920]  = 4 -- Spell Banner
	BaseAuras[52437]  = 4 -- Sudden Death
	BaseAuras[12328]  = 4 -- Sweeping Strikes
	BaseAuras[50227]  = 4 -- Sword and Board
	BaseAuras[125831] = 4 -- Taste for Blood
	BaseAuras[122510] = 4 -- Ultimatum

	-- Buffs
	BaseAuras[46947]  = 3 -- Safeguard (damage reduction)
	BaseAuras[114029] = 3 -- Safeguard (intercept)
	BaseAuras[114030] = 3 -- Vigilance

	-- Debuffs
	BaseAuras[86346]  = 2 -- Colossus Smash
	BaseAuras[114205] = 2 -- Demoralizing Banner
	BaseAuras[1160]   = 2 -- Demoralizing Shout
	BaseAuras[676]    = 2 -- Disarm
	BaseAuras[118895] = 2 -- Dragon Roar
	BaseAuras[1715]   = 2 -- Hamstring
	BaseAuras[5246]   = 2 -- Intimidating Shout -- NEEDS CHECK
	BaseAuras[20511]  = 2 -- Intimidating Shout -- NEEDS CHECK
	BaseAuras[12323]  = 2 -- Piercing Howl
	BaseAuras[64382]  = 2 -- Shattering Throw
	BaseAuras[46968]  = 2 -- Shockwave
	BaseAuras[18498]  = 2 -- Silenced - Gag Order
	BaseAuras[107566] = 2 -- Staggering Shout
	BaseAuras[107570] = 2 -- Storm Bolt
	BaseAuras[355]    = 2 -- Taunt
	BaseAuras[105771] = 2 -- Warbringer
end

------------------------------------------------------------------------
-- Racials

if playerRace == "BloodElf" then
	BaseAuras[50613]  = 2 -- Arcane Torrent (death knight)
	BaseAuras[80483]  = 2 -- Arcane Torrent (hunter)
	BaseAuras[28730]  = 2 -- Arcane Torrent (mage, paladin, priest, warlock)
	BaseAuras[129597] = 2 -- Arcane Torrent (monk)
	BaseAuras[25046]  = 2 -- Arcane Torrent (rogue)
	BaseAuras[69179]  = 2 -- Arcane Torrent (warrior)
elseif playerRace == "Draenei" then
	BaseAuras[59545]  = 4 -- Gift of the Naaru (death knight)
	BaseAuras[59543]  = 4 -- Gift of the Naaru (hunter)
	BaseAuras[59548]  = 4 -- Gift of the Naaru (mage)
	BaseAuras[121093] = 4 -- Gift of the Naaru (monk)
	BaseAuras[59542]  = 4 -- Gift of the Naaru (paladin)
	BaseAuras[59544]  = 4 -- Gift of the Naaru (priest)
	BaseAuras[59547]  = 4 -- Gift of the Naaru (shaman)
	BaseAuras[28880]  = 4 -- Gift of the Naaru (warrior)
elseif playerRace == "Dwarf" then
	BaseAuras[20594]  = 4 -- Stoneform
elseif playerRace == "NightElf" then
	BaseAuras[58984]  = 4 -- Shadowmeld
elseif playerRace == "Orc" then
	BaseAuras[20572]  = 4 -- Blood Fury (attack power)
	BaseAuras[33702]  = 4 -- Blood Fury (spell power)
	BaseAuras[33697]  = 4 -- Blood Fury (attack power and spell damage)
elseif playerRace == "Pandaren" then
	BaseAuras[107079] = 4 -- Quaking Palm
elseif playerRace == "Scourge" then
	BaseAuras[7744]   = 4 -- Will of the Forsaken
elseif playerRace == "Tauren" then
	BaseAuras[20549]  = 1 -- War Stomp
elseif playerRace == "Troll" then
	BaseAuras[26297]  = 4 -- Berserking
elseif playerRace == "Worgen" then
	BaseAuras[68992]  = 4 -- Darkflight
end

------------------------------------------------------------------------
--	Magic Vulnerability

if playerClass == "ROGUE" or playerClass == "WARLOCK" then
	BaseAuras[1490]  = 1 -- Curse of the Elements (warlock)
	BaseAuras[34889] = 1 -- Fire Breath (hunter dragonhawk)
	BaseAuras[24844] = 1 -- Lightning Breath (hunter wind serpent)
	BaseAuras[93068] = 1 -- Master Poisoner (rogue)
end

------------------------------------------------------------------------
--	Mortal Wounds

if playerClass == "HUNTER" or playerClass == "MONK" or playerClass == "ROGUE" or playerClass == "WARRIOR" then
	BaseAuras[54680]  = 1 -- Monstrous Bite (hunter devilsaur)
	BaseAuras[115804] = 1 -- Mortal Wounds (monk, warrior)
	BaseAuras[82654]  = 1 -- Widow Venom (hunter)
	BaseAuras[8680]   = 1 -- Wound Poison (rogue)
end

------------------------------------------------------------------------
--	Physical Vulnerability

if playerClass == "DEATHKNIGHT" or playerClass == "PALADIN" or playerClass == "WARRIOR" then
	BaseAuras[55749] = 1 -- Acid Rain (hunter worm)
	BaseAuras[35290] = 1 -- Gore (hunter boar)
	BaseAuras[81326] = 1 -- Physical Vulnerability (death knight, paladin, warrior)
	BaseAuras[50518] = 1 -- Ravage (hunter ravager)
	BaseAuras[57386] = 1 -- Stampede (hunter rhino)
end

------------------------------------------------------------------------
--	Slow Casting

if playerClass == "DEATHKNIGHT" or playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then
	BaseAuras[109466] = 1 -- Curse of Enfeeblement (warlock)
	BaseAuras[5760]   = 1 -- Mind-numbing Poison (rogue)
	BaseAuras[73975]  = 1 -- Necrotic Strike (death knight)
	BaseAuras[31589]  = 1 -- Slow (mage)
	BaseAuras[50274]  = 1 -- Spore Cloud (hunter sporebat)
	BaseAuras[90315]  = 1 -- Tailspin (hunter fox)
	BaseAuras[126406] = 1 -- Trample (hunter goat)
	BaseAuras[58604]  = 1 -- Lava Breath (hunter core hound)
end

------------------------------------------------------------------------
--	Weakened Armor

if playerClass == "DRUID" or playerClass == "ROGUE" or playerClass == "WARRIOR" then
	-- druids need to keep Faerie Fire/Swarm up anyway, no need to see both, this has the shorter duration
	BaseAuras[113746] = 1 -- Weakened Armor (druid, hunter raptor, hunter tallstrider, rogue, warrior)
end

------------------------------------------------------------------------
--	Weakened Blows (tanks only)

if playerClass == "DEATHKNIGHT" or playerClass == "MONK" or playerClass == "PALADIN" or playerClass == "WARRIOR" then
	-- druids need to keep Thrash up anyway, no need to see both
	tinsert(updateFuncs, function(auraList)
		if ns.GetPlayerRole() == "TANK" then
			--print("Adding Weakened Blows")
			auraList[109466] = 1 -- Curse of Enfeeblement (warlock)
			auraList[60256]  = 1 -- Demoralizing Roar (hunter bear)
			auraList[24423]  = 1 -- Demoralizing Screech (hunter carrion bird)
			auraList[115798] = 1 -- Weakened Blows (death knight, druid, monk, paladin, shaman, warrior)
		end
	end)
end

------------------------------------------------------------------------
--	PvP

tinsert(updateFuncs, function(auraList)
	if ns.config.PVP then
		--print("Adding PVP auras")
		-- Disarmed
		auraList[50541]  = 1 -- Clench (hunter scorpid)
		auraList[676]    = 1 -- Disarm (warrior)
		auraList[51722]  = 1 -- Dismantle (rogue)
		auraList[117368] = 1 -- Grapple Weapon (monk)
		auraList[91644]  = 1 -- Snatch (hunter bird of prey)
		--	Silenced
		auraList[25046]  = 1 -- Arcane Torrent (blood elf - rogue)
		auraList[28730]  = 1 -- Arcane Torrent (blood elf - mage, paladin, priest, warlock)
		auraList[50613]  = 1 -- Arcane Torrent (blood elf - death knight)
		auraList[69179]  = 1 -- Arcane Torrent (blood elf - warrior)
		auraList[80483]  = 1 -- Arcane Torrent (blood elf - hunter)
		auraList[129597] = 1 -- Arcane Torrent (blood elf - monk)
		auraList[31935]  = 1 -- Avenger's Shield (paladin)
		auraList[102051] = 1 -- Frostjaw (mage)
		auraList[1330]   = 1 -- Garrote - Silence (rogue)
		auraList[50479]  = 1 -- Nether Shock (hunter nether ray)
		auraList[15487]  = 1 -- Silence (priest)
		auraList[18498]  = 1 -- Silenced - Gag Order (warrior)
		auraList[34490]  = 1 -- Silencing Shot (hunter)
		auraList[78675]  = 1 -- Solar Beam (druid)
		auraList[97547]  = 1 -- Solar Beam (druid)
		auraList[113286] = 1 -- Solar Beam (symbiosis)
		auraList[113287] = 1 -- Solar Beam (symbiosis)
		auraList[113288] = 1 -- Solar Beam (symbiosis)
		auraList[116709] = 1 -- Spear Hand Strike (monk)
		auraList[24259]  = 1 -- Spell Lock (warlock felhunter)
		auraList[47476]  = 1 -- Strangulate (death knight)
	end
end)

------------------------------------------------------------------------
--	Taunted

if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "MONK" or playerClass == "PALADIN" or playerClass == "WARRIOR" then
	local Taunts = {
		[56222]  = 1, -- Dark Command
		[57604]  = 1, -- Death Grip -- NEEDS CHECK 57603
		[20736]  = 1, -- Distracting Shot
		[6795]   = 1, -- Growl
		[118585] = 1, -- Leer of the Ox
		[62124]  = 1, -- Reckoning
		[355]    = 1, -- Taunt
	}
	tinsert(updateFuncs, function(auraList)
		if ns.config.PVP then
			--print("Removing taunts for PVP")
			for aura in pairs(Taunts) do
				BaseAuras[aura] = nil
			end
		else
			--print("Adding taunts for PVE")
			for aura, filter in pairs(Taunts) do
				auraList[aura] = filter
			end
		end
	end)
end

------------------------------------------------------------------------
--	Random quest related auras

BaseAuras[127372] = 2 -- Unstable Serum (Klaxxi Enhancement: Raining Blood)

------------------------------------------------------------------------
--	Boss debuffs that Blizzard forgot to flag

BaseAuras[106648] = 1 -- Brew Explosion (Ook Ook in Stormsnout Brewery)
BaseAuras[106784] = 1 -- Brew Explosion (Ook Ook in Stormsnout Brewery)
BaseAuras[123059] = 1 -- Destabilize (Amber-Shaper Un'sok)

------------------------------------------------------------------------
--	Enchant procs that Blizzard failed to flag with their caster

BaseAuras[116631] = 0 -- Colossus
BaseAuras[118334] = 0 -- Dancing Steel (agi)
BaseAuras[118335] = 0 -- Dancing Steel (str)
BaseAuras[104993] = 0 -- Jade Spirit
BaseAuras[116660] = 0 -- River's Song
BaseAuras[104509] = 0 -- Windsong (crit)
BaseAuras[104423] = 0 -- Windsong (haste)
BaseAuras[104510] = 0 -- Windsong (mastery)

------------------------------------------------------------------------
--	NPC buffs that are completely useless

BaseAuras[63501] = 0 -- Argent Crusade Champion's Pennant
BaseAuras[60023] = 0 -- Scourge Banner Aura (Boneguard Commander in Icecrown)
BaseAuras[63406] = 0 -- Darnassus Champion's Pennant
BaseAuras[63405] = 0 -- Darnassus Valiant's Pennant
BaseAuras[63423] = 0 -- Exodar Champion's Pennant
BaseAuras[63422] = 0 -- Exodar Valiant's Pennant
BaseAuras[63396] = 0 -- Gnomeregan Champion's Pennant
BaseAuras[63395] = 0 -- Gnomeregan Valiant's Pennant
BaseAuras[63427] = 0 -- Ironforge Champion's Pennant
BaseAuras[63426] = 0 -- Ironforge Valiant's Pennant
BaseAuras[63433] = 0 -- Orgrimmar Champion's Pennant
BaseAuras[63432] = 0 -- Orgrimmar Valiant's Pennant
BaseAuras[63399] = 0 -- Sen'jin Champion's Pennant
BaseAuras[63398] = 0 -- Sen'jin Valiant's Pennant
BaseAuras[63403] = 0 -- Silvermoon Champion's Pennant
BaseAuras[63402] = 0 -- Silvermoon Valiant's Pennant
BaseAuras[62594] = 0 -- Stormwind Champion's Pennant
BaseAuras[62596] = 0 -- Stormwind Valiant's Pennant
BaseAuras[63436] = 0 -- Thunder Bluff Champion's Pennant
BaseAuras[63435] = 0 -- Thunder Bluff Valiant's Pennant
BaseAuras[63430] = 0 -- Undercity Champion's Pennant
BaseAuras[63429] = 0 -- Undercity Valiant's Pennant

------------------------------------------------------------------------

local auraList = {}
ns.AuraList = auraList

ns.UpdateAuraList = function()
	--print("UpdateAuraList")
	wipe(auraList)
	-- Add base auras
	for aura, filter in pairs(BaseAuras) do
		auraList[aura] = filter
	end
	-- Add auras that depend on spec or PVP mode
	for i = 1, #updateFuncs do
		updateFuncs[i](auraList)
	end
	-- Add custom auras
	for aura, filter in pairs(oUFPhanxAuraConfig) do
		auraList[aura] = filter
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

ns.export.UpdateAuraList = ns.UpdateAuraList

------------------------------------------------------------------------

local IsInInstance, UnitCanAttack, UnitIsFriend, UnitIsUnit, UnitPlayerControlled
	= IsInInstance, UnitCanAttack, UnitIsFriend, UnitIsUnit, UnitPlayerControlled

local unitIsPlayer = { player = true, pet = true, vehicle = true }

local filters = {
	[2] = function(self, unit, caster) return unitIsPlayer[caster] end,
	[3] = function(self, unit, caster) return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) end,
	[4] = function(self, unit, caster) return unit == "player" and not self.__owner.isGroupFrame end,
}

ns.CustomAuraFilters = {
	player = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3)
		-- print("CustomAuraFilter", self.__owner:GetName(), "[unit]", unit, "[caster]", caster, "[name]", name, "[id]", spellID, "[filter]", v, caster == "vehicle")
		local v = auraList[spellID]
		if v and filters[v] then
			return filters[v](self, unit, caster)
		elseif v then
			return v > 0
		else
			return caster and UnitIsUnit(caster, "vehicle")
		end
	end,
	pet = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3)
		return caster and unitIsPlayer[caster] and auraList[spellID] == 2
	end,
	target = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		-- print("CustomAuraFilter", unit, spellID, name, caster, v)
		if v and filters[v] then
			return filters[v](self, unit, caster)
		elseif v then
			return v > 0
		elseif not caster and not IsInInstance() then
			-- test
			return
		elseif UnitCanAttack("player", unit) and not UnitPlayerControlled(unit) then
			-- Hostile NPC. Show boss debuffs, auraList cast by the unit, or auras cast by the player's vehicle.
			-- print("hostile NPC")
			return isBossDebuff or not caster or caster == unit or UnitIsUnit(caster, "vehicle")
		else
			-- Friendly target or hostile player. Show boss debuffs, or auras cast by the player's vehicle.
			-- print("hostile player / friendly unit")
			return isBossDebuff or not caster or UnitIsUnit(caster, "vehicle")
		end
	end,
	party = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3)
		local v = auraList[spellID]
		return v and v < 4
	end,
}