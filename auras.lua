--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Written by Phanx <addons@phanx.net>
	Copyright © 2007–2011. Some rights reserved. See LICENSE.txt for details.
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
local playerClass = select(2, UnitClass("player"))
local playerRace = select(2, UnitRace("player"))

local auras = {
	-- Buffs
	[90355] = 4, -- Ancient Hysteria [hunter core hound]
	[2825]  = 4, -- Bloodlust
	[1022]  = 4, -- Hand of Protection
	[32182] = 4, -- Heroism
	[29166] = 4, -- Innervate
	[80353] = 4, -- Time Warp
	[33206] = 4, -- Pain Suppression
	[10060] = 4, -- Power Infusion
	[49016] = 4, -- Unholy Frenzy

	-- Herbalism
	[81708] = 2, -- Lifeblood [Rank 1]
	[55428] = 2, -- Lifeblood [Rank 2]
	[55480] = 2, -- Lifeblood [Rank 3]
	[55500] = 2, -- Lifeblood [Rank 4]
	[55501] = 2, -- Lifeblood [Rank 5]
	[55502] = 2, -- Lifeblood [Rank 6]
	[55503] = 2, -- Lifeblood [Rank 7]
	[74497] = 2, -- Lifeblood [Rank 8]

	-- Crowd Control
	[710]   = 1, -- Banish
	[76780] = 1, -- Bind Elemental
	[33786] = 1, -- Cyclone
	[339]   = 1, -- Entangling Roots
	[5782]  = 1, -- Fear
	[3355]  = 1, -- Freezing Trap, -- NEEDS CHECK 31932 43415 55041
	[51514] = 1, -- Hex
	[2637]  = 1, -- Hibernate
	[118]   = 1, -- Polymorph
	[61305] = 1, -- Polymorph [Black Cat]
	[28272] = 1, -- Polymorph [Pig]
	[61721] = 1, -- Polymorph [Rabbit]
	[61780] = 1, -- Polymorph [Turkey]
	[28271] = 1, -- Polymorph [Turtle]
	[20066] = 1, -- Repentance
	[6770]  = 1, -- Sap
	[6358]  = 1, -- Seduction
	[9484]  = 1, -- Shackle Undead
	[10326] = 1, -- Turn Evil
	[19386] = 1, -- Wyvern Sting
}

------------------------------------------------------------------------
--	Armor reduced

if playerClass == "DRUID" or playerClass == "WARRIOR" then
	auras[35387] = 1 -- Corrosive Spit [hunter serpent]
	auras[91565] = 1 -- Faerie Fire
	auras[8647]  = 1 -- Expose Armor
	auras[7386]  = 1 -- Sunder Armor
	auras[50498] = 1 -- Tear Armor [hunter raptor]
end

------------------------------------------------------------------------
--	Attack speed reduced

if playerClass == "WARRIOR" then
	auras[54404] = 1 -- Dust Cloud [hunter tallstrider]
	auras[8042]  = 1 -- Earth Shock
	auras[55095] = 1 -- Frost Fever
	auras[58179] = 1 -- Infected Wounds [Rank 1]
	auras[58180] = 1 -- Infected Wounds [Rank 2]
	auras[68055] = 1 -- Judgements of the Just
	auras[14251] = 1 -- Riposte
	auras[90315] = 1 -- Tailspin [hunter fox]
	auras[6343]  = 1 -- Thunder Clap
end

------------------------------------------------------------------------
--	Bleed damage taken increased

if playerClass == "DRUID" or playerClass == "ROGUE" then
	auras[35290] = 1 -- Gore [hunter boar] -- NEEDS CHECK
	auras[16511] = 1 -- Hemorrhage
	auras[33878] = 1 -- Mangle [Bear Form]
	auras[33876] = 1 -- Mangle [Cat Form]
	auras[57386] = 1 -- Stampede [hunter rhino]
	auras[50271] = 1 -- Tendon Rip [hunter hyena]
	auras[46857] = 1 -- Trauma <== Blood Frenzy
end

------------------------------------------------------------------------
--	Casting speed reduced

if playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then
	auras[1714]  = 1 -- Curse of Tongues
	auras[58604] = 1 -- Lava Breath [hunter core hound]
	auras[5760]  = 1 -- Mind-Numbing Poison
	auras[31589] = 1 -- Slow
	auras[50274] = 1 -- Spore Cloud [hunter sporebat]
end

------------------------------------------------------------------------
--	Healing effects reduced

if playerClass == "HUNTER" or playerClass == "ROGUE" or playerClass == "WARRIOR" then
	auras[56112] = 1 -- Furious Attacks
	auras[48301] = 1 -- Mind Trauma <== Improved Mind Blast
	auras[30213] = 1 -- Legion Strike [warlock felguard]
	auras[54680] = 1 -- Monstrous Bite [hunter devilsaur]
	auras[12294] = 1 -- Mortal Strike
	auras[82654] = 1 -- Widow Venom
	auras[13218] = 1 -- Wound Poison
end

------------------------------------------------------------------------
--	Physical damage dealt reduced

if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "WARRIOR" then
	auras[702]   = 1 -- Curse of Weakness
	auras[99]    = 1 -- Demoralizing Roar
	auras[50256] = 1 -- Demoralizing Roar [hunter bear]
	auras[1160]  = 1 -- Demoralizing Shout
	auras[81130] = 1 -- Scarlet Fever
	auras[26017] = 1 -- Vindication
end

------------------------------------------------------------------------
--	Disarmed

if playerClass == "" then
	auras[50541] = 1 -- Clench (hunter scorpid)
	auras[676]   = 1 -- Disarm (warrior)
	auras[51722] = 1 -- Dismantle (rogue)
	auras[64058] = 1 -- Psychic Horror (priest)
	auras[91644] = 1 -- Snatch (hunter bird of prey)
end

------------------------------------------------------------------------
--	Silenced

if playerClass == "" then
	auras[25046] = 1 -- Arcane Torrent (blood elf)
	auras[31935] = 1 -- Avenger's Shield (paladin)
	auras[1330]  = 1 -- Garrote - Silence (rogue)
	auras[50479] = 1 -- Nether Shock (hunter nether ray)
	auras[15487] = 1 -- Silence (priest)
	auras[18498] = 1 -- Silenced - Gag Order (warrior)
	auras[18469] = 1 -- Silenced - Improved Counterspell (mage)
	auras[18425] = 1 -- Silenced - Improved Kick (rogue)
	auras[34490] = 1 -- Silencing Shot (hunter)
	auras[81261] = 1 -- Solar Beam (druid)
	auras[24259] = 1 -- Spell Lock (warlock felhunter)
	auras[47476] = 1 -- Strangulate (death knight)
end

------------------------------------------------------------------------
--	Spell-locked

if playerClass == "" then
	auras[2139]  = 1 -- Counterspell (mage)
	auras[1766]  = 1 -- Kick (rogue)
	auras[47528] = 1 -- Mind Freeze (death knight)
	auras[6552]  = 1 -- Pummel (warrior)
	auras[26090] = 1 -- Pummel (hunter gorilla)
	auras[50318] = 1 -- Serenity Dust (hunter moth)
	auras[72]    = 1 -- Shield Bash (warrior)
	auras[80964] = 1 -- Skull Bash (Bear) (druid)
	auras[80965] = 1 -- Skull Bash (Cat) (druid)
	auras[57994] = 1 -- Wind Shear (shaman)
end

------------------------------------------------------------------------
--	Taunted

if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "WARRIOR" then
	auras[5209]  = 1 -- Challenging Roar
	auras[1161]  = 1 -- Challenging Shout
	auras[56222] = 1 -- Dark Command
	auras[57604] = 1 -- Death Grip -- NEEDS CHECK 57603
	auras[20736] = 1 -- Distracting Shot
	auras[6794]  = 1 -- Growl
	auras[62124] = 1 -- Hand of Reckoning
	auras[31790] = 1 -- Righteous Defense
	auras[355]   = 1 -- Taunt
	auras[58857] = 1 -- Twin Howl [shaman spirit wolves]
end

------------------------------------------------------------------------
--	Death Knight

if playerClass == "DEATHKNIGHT" then
	auras[55078] = 2 -- Blood Plague
	auras[45524] = 1 -- Chains of Ice
	auras[77606] = 2 -- Dark Simulacrum
	auras[43265] = 2 -- Death and Decay
	auras[65142] = 2 -- Ebon Plague
	auras[55095] = 2 -- Frost Fever
	auras[49203] = 1 -- Hungering Cold
	auras[81130] = 2 -- Scarlet Fever
	auras[50536] = 2 -- Unholy Blight -- NEEDS CHECK

	auras[48707] = 4 -- Anti-Magic Shell
	auras[81141] = 4 -- Blood Swarm <== Crimson Scourge
	auras[49222] = 4 -- Bone Shield
	auras[81256] = 4 -- Dancing Rune Weapon
	auras[59052] = 4 -- Freezing Fog <== Rime
	auras[48792] = 4 -- Icebound Fortitude
	auras[51124] = 4 -- Killing Machine
	auras[49039] = 4 -- Lichborne
	auras[51271] = 4 -- Pillar of Frost
	auras[50421] = 4 -- Scent of Blood
	auras[81340] = 4 -- Sudden Doom
	auras[55233] = 4 -- Vampiric Blood
	auras[81162] = 4 -- Will of the Necropolis -- NEEDS CHECK

	auras[49016] = 1 -- Unholy Frenzy
end

------------------------------------------------------------------------
--	Druid

if playerClass == "DRUID" then
	auras[5211]  = 2 -- Bash
	auras[33786] = 2 -- Cyclone
	auras[339]   = 2 -- Entangling Roots
	auras[45334] = 2 -- Feral Charge Effect [Bear Form]
	auras[61138] = 2 -- Feral Charge - Cat -- NEEDS CHECK
	auras[2637]  = 2 -- Hibernate
	auras[5570]  = 2 -- Insect Swarm
	auras[33745] = 2 -- Lacerate
	auras[22570] = 2 -- Maim
	auras[8921]  = 2 -- Moonfire
	auras[9005]  = 2 -- Pounce
	auras[9007]  = 2 -- Pounce Bleed
	auras[1822]  = 2 -- Rake
	auras[1079]  = 2 -- Rip
	auras[93402] = 2 -- Sunfire
	auras[77758] = 2 -- Thrash

	auras[22812] = 4 -- Barkskin
	auras[50334] = 4 -- Berserk
	auras[93622] = 4 -- Berserk [Mangle (Bear) cooldown reset proc]
	auras[16870] = 4 -- Clearcasting <== Omen of Clarity
	auras[1850]  = 4 -- Dash
	auras[5229]  = 4 -- Enrage
	auras[48518] = 4 -- Eclipse (Lunar)
	auras[48517] = 4 -- Eclipse (Solar)
	auras[22842] = 4 -- Frenzied Regeneration
	auras[81093] = 4 -- Fury of Stormrage
	auras[81192] = 4 -- Lunar Shower
	auras[16886] = 4 -- Nature's Grace
	auras[16689] = 4 -- Nature's Grasp
	auras[17116] = 4 -- Nature's Swiftness
	auras[80951] = 4 -- Pulverize
	auras[52610] = 4 -- Savage Roar
	auras[93400] = 4 -- Shooting Stars
	auras[81021] = 4 -- Stampede [Ravage effect]
	auras[81022] = 4 -- Stampede [Ravage effect]
	auras[61336] = 4 -- Survival Instincts
	auras[5217]  = 4 -- Tiger's Fury
	auras[33891] = 4 -- Tree of Life
	auras[61391] = 4 -- Typhoon

	auras[33763] = 2 -- Lifebloom
	auras[94447] = 2 -- Lifebloom [Tree of Life version]
	auras[8936]  = 2 -- Regrowth
	auras[774]   = 2 -- Rejuvenation
	auras[77764] = 1 -- Stampeding Roar
	auras[467]   = 1 -- Thorns
	auras[48438] = 2 -- Wild Growth
end

------------------------------------------------------------------------
--	Hunter

if playerClass == "HUNTER" then
	auras[50433] = 2 -- Ankle Crack [crocolisk]
	auras[3674]  = 2 -- Black Arrow
	auras[35101] = 2 -- Concussive Barrage
	auras[5116]  = 2 -- Concussive Shot
	auras[19306] = 2 -- Counterattack
	auras[20736] = 2 -- Distracting Shot
	auras[64803] = 2 -- Entrapment
	auras[53301] = 2 -- Explosive Shot
	auras[13812] = 2 -- Explosive Trap -- NEEDS CHECK 43446
	auras[3355]  = 2 -- Freezing Trap -- NEEDS CHECK 31932 43415 55041
	auras[1130]  = 1 -- Hunter's Mark
	auras[13810] = 2 -- Ice Trap
	auras[13797] = 2 -- Immolation Trap -- NEEDS CHECK 51740
	auras[24394] = 2 -- Intimidation
	auras[88691] = 1 -- Marked for Death
	auras[63468] = 2 -- Piercing Shots
	auras[1513]  = 2 -- Scare Beast
	auras[19503] = 2 -- Scatter Shot
	auras[1978]  = 2 -- Serpent Sting
	auras[82654] = 1 -- Widow Venom
	auras[2974]  = 2 -- Wing Clip
	auras[19386] = 2 -- Wyvern Sting

	auras[82921] = 4 -- Bombardment
	auras[51755] = 4 -- Camouflage
	auras[15571] = 4 -- Dazed <== Aspect of the Cheetah
	auras[19263] = 4 -- Deterrence
	auras[5384]  = 4 -- Feign Death
	auras[82926] = 4 -- Fire! <== Lock and Load
	auras[64418] = 4 -- Sniper Training [Rank 1]
	auras[64419] = 4 -- Sniper Training [Rank 2]
	auras[64420] = 4 -- Sniper Training [Rank 3]
	auras[56453] = 4 -- Lock and Load
	auras[34477] = 4 -- Misdirection
	auras[3045]  = 4 -- Rapid Fire
	auras[35099] = 4 -- Rapid Killing
--	auras[82925] = 4 -- Ready, Set, Aim...

	auras[19574] = 2 -- Bestial Wrath
	auras[1539]  = 2 -- Feed Pet
	auras[136]   = 2 -- Mend Pet
end

------------------------------------------------------------------------
--	Mage

if playerClass == "MAGE" then
	auras[11113] = 2 -- Blast Wave
	auras[12486] = 2 -- Chilled <== Blizzard <== Ice Shards -- NEEDS CHECK
	auras[7321]  = 2 -- Chilled <== Frost Aura
	auras[83853] = 2 -- Combustion
	auras[120]   = 2 -- Cone of Cold
	auras[44572] = 2 -- Deep Freeze
	auras[31661] = 2 -- Dragon's Breath
	auras[122]   = 2 -- Frost Nova
	auras[116]   = 2 -- Frostbolt
	auras[44614] = 2 -- Frostfire Bolt
	auras[12654] = 2 -- Ignite
	auras[12355] = 2 -- Impact
	auras[83301] = 2 -- Improved Cone of Cold [Rank 1]
	auras[83302] = 2 -- Improved Cone of Cold [Rank 2]
	auras[44457] = 2 -- Living Bomb
	auras[118]   = 2 -- Polymorph
	auras[61305] = 2 -- Polymorph [Black Cat]
	auras[28272] = 2 -- Polymorph [Pig]
	auras[61721] = 2 -- Polymorph [Rabbit]
	auras[61780] = 2 -- Polymorph [Turkey]
	auras[28271] = 2 -- Polymorph [Turtle]
	auras[82691] = 2 -- Ring of Frost
	auras[31589] = 2 -- Slow

	auras[36032] = 4 -- Arcane Blast
	auras[79683] = 4 -- Arcane Missiles!
	auras[12042] = 4 -- Arcane Power
	auras[31643] = 4 -- Blazing Speed
	auras[57761] = 4 -- Brain Freeze
	auras[44544] = 4 -- Fingers of Frost
	auras[48108] = 4 -- Hot Streak
	auras[11426] = 4 -- Ice Barrier
	auras[45438] = 4 -- Ice Block
	auras[12472] = 4 -- Icy Veins
	auras[64343] = 4 -- Impact
	auras[66]    = 4 -- Invisibility
	auras[543]   = 4 -- Mage Ward
	auras[1436]  = 4 -- Mana Shield
	auras[12043] = 4 -- Presence of Mind

	auras[54646] = 2 -- Focus Magic
	auras[130]   = 2 -- Slow Fall
end

------------------------------------------------------------------------
--	Paladin

if playerClass == "PALADIN" then
	auras[31935] = 2 -- Avenger's Shield
	auras[31803] = 2 -- Censure <== Seal of Truth
	auras[25771] = 1 -- Forbearance
	auras[853]   = 2 -- Hammer of Justice
	auras[2812]  = 2 -- Holy Wrath
	auras[20066] = 2 -- Repentance
	auras[10326] = 2 -- Turn Evil

	auras[86701] = 4 -- Ancient Crusader <== Guardian of Ancient Kings
	auras[86657] = 4 -- Ancient Guardian <== Guardian of Ancient Kings
	auras[86674] = 4 -- Ancient Healer <== Guardian of Ancient Kings
	auras[31850] = 4 -- Ardent Defender
	auras[31821] = 4 -- Aura Mastery
	auras[31884] = 4 -- Avenging Wrath
	auras[88819] = 4 -- Daybreak
	auras[85509] = 4 -- Denounce
	auras[31842] = 4 -- Divine Favor
	auras[54428] = 4 -- Divine Plea
	auras[498]   = 4 -- Divine Protection
	auras[642]   = 4 -- Divine Shield
	auras[82327] = 4 -- Holy Radiance
	auras[20925] = 4 -- Holy Shield
	auras[54149] = 4 -- Infusion of Light
	auras[84963] = 4 -- Inquisition
	auras[85433] = 4 -- Sacred Duty
	auras[85497] = 4 -- Speed of Light [haste effect]
	auras[59578] = 4 -- The Art of War
	auras[85696] = 4 -- Zealotry

	auras[53563] = 2 -- Beacon of Light
	auras[70940] = 1 -- Divine Guardian
	auras[1044]  = 1 -- Hand of Freedom
	auras[1022]  = 1 -- Hand of Protection
	auras[6940]  = 1 -- Hand of Sacrifice
	auras[1038]  = 1 -- Hand of Salvation
end

------------------------------------------------------------------------
--	Priest

if playerClass == "PRIEST" then
	auras[2944]  = 2 -- Devouring Plague
	auras[88625] = 2 -- Holy Word: Chastise
	auras[605]   = 2 -- Mind Control
	auras[453]   = 1 -- Mind Soothe
	auras[87178] = 2 -- Mind Spike
	auras[87193] = 2 -- Paralysis [Rank 1]
	auras[87194] = 2 -- Paralysis [Rank 2]
	auras[64044] = 2 -- Psychic Horror
	auras[8122]  = 2 -- Psychic Scream
	auras[9484]  = 2 -- Shackle Undead
	auras[589]   = 2 -- Shadow Word: Pain
	auras[34914] = 2 -- Vampiric Touch
	auras[6788]  = 1 -- Weakened Soul

	auras[81700] = 4 -- Archangel
	auras[14751] = 4 -- Chakra
	auras[81208] = 4 -- Chakra: Heal
	auras[81206] = 4 -- Chakra: Prayer of Healing
	auras[81207] = 4 -- Chakra: Renew
	auras[81209] = 4 -- Chakra: Smite
	auras[87153] = 4 -- Dark Archangel
	auras[87117] = 4 -- Dark Evangelism -- NEEDS CHECK
	auras[87118] = 4 -- Dark Evangelism -- NEEDS CHECK
	auras[47585] = 4 -- Dispersion
	auras[81660] = 4 -- Evangelism -- NEEDS CHECK
	auras[81661] = 4 -- Evangelism -- NEEDS CHECK
	auras[586]   = 4 -- Fade
	auras[89485] = 4 -- Inner Focus
	auras[81292] = 4 -- Mind Melt [Rank 1]
	auras[87160] = 4 -- Mind Melt [Rank 2]
	auras[63731] = 4 -- Serendipity [Rank 1]
	auras[63735] = 4 -- Serendipity [Rank 2]
	auras[88688] = 4 -- Surge of Light

	auras[6346]  = 1 -- Fear Ward
	auras[77613] = 2 -- Grace
	auras[47788] = 2 -- Guardian Spirit
	auras[88682] = 2 -- Holy Word: Aspire
	auras[33206] = 2 -- Pain Suppression
	auras[10060] = 2 -- Power Infusion
	auras[17]    = 1 -- Power Word: Shield
	auras[41635] = 2 -- Prayer of Mending
	auras[139]   = 2 -- Renew
end

------------------------------------------------------------------------
--	Rogue

if playerClass == "ROGUE" then
	auras[51585] = 2 -- Blade Twisting
	auras[2094]  = 2 -- Blind
	auras[1833]  = 2 -- Cheap Shot
	auras[3409]  = 2 -- Crippling Poison
	auras[2818]  = 2 -- Deadly Poison
	auras[26679] = 2 -- Deadly Throw
	auras[51722] = 2 -- Dismantle
	auras[8647]  = 1 -- Expose Armor
	auras[703]   = 2 -- Garrote
	auras[1776]  = 2 -- Gouge
	auras[89775] = 2 -- Hemorrhage [dot from glyph]
	auras[408]   = 2 -- Kidney Shot
	auras[84617] = 2 -- Revealing Strike
	auras[14251] = 1 -- Riposte
	auras[1943]  = 2 -- Rupture
	auras[79140] = 2 -- Vendetta
	auras[13218] = 2 -- Wound Poison

	auras[13750] = 4 -- Adrenaline Rush
	auras[13877] = 4 -- Blade Flurry
	auras[31224] = 4 -- Cloak of Shadows
	auras[14177] = 4 -- Cold Blood
	auras[84590] = 4 -- Deadly Momentum
	auras[32645] = 4 -- Envenom
	auras[5277]  = 4 -- Evasion
	auras[73651] = 4 -- Recuperate
	auras[5171]  = 4 -- Slice and Dice
	auras[2983]  = 4 -- Sprint
	auras[57934] = 4 -- Tricks of the Trade
end

------------------------------------------------------------------------
--	Shaman

if playerClass == "SHAMAN" then
	auras[76780] = 2 -- Bind Elemental
	auras[8042]  = 2 -- Earth Shock
	auras[3600]  = 1 -- Earthbind
	auras[56425] = 1 -- Earth's Grasp -- NEEDS CHECK
	auras[8050]  = 2 -- Flame Shock
	auras[8056]  = 2 -- Frost Shock
	auras[8034]  = 2 -- Frostbrand Attack -- NEEDS CHECK
	auras[89523] = 1 -- Grounding Totem [reflect]
	auras[8178]  = 1 -- Grounding Totem Effect
	auras[51514] = 2 -- Hex
	auras[77661] = 1 -- Searing Flames
	auras[39796] = 1 -- Stoneclaw Stun
	auras[17364] = 2 -- Stormstrike

	auras[16166] = 4 -- Elemental Mastery [instant cast]
	auras[77800] = 4 -- Focused Insight
	auras[65264] = 4 -- Lava Flows -- NEEDS CHECK
	auras[31616] = 4 -- Nature's Guardian
	auras[16188] = 4 -- Nature's Swiftness
	auras[30823] = 4 -- Shamanistic Rage
	auras[79206] = 4 -- Spiritwalker's Grace
	auras[53390] = 4 -- Tidal Waves

	auras[974]   = 2 -- Earth Shield
	auras[61295] = 2 -- Riptide
end

------------------------------------------------------------------------
--	Warlock

if playerClass == "WARLOCK" then
	auras[93986] = 2 -- Aura of Foreboding [stun effect] -- NEEDS CHECK 93975
	auras[93987] = 2 -- Aura of Foreboding [root effect] -- NEEDS CHECK 93974
	auras[980]   = 2 -- Bane of Agony
	auras[603]   = 2 -- Bane of Doom
	auras[80240] = 2 -- Bane of Havoc
	auras[710]   = 2 -- Banish
	auras[172]   = 2 -- Corruption
	auras[29539] = 1 -- Curse of Exhaustion
	auras[1490]  = 1 -- Curse of the Elements
	auras[1714]  = 1 -- Curse of Tongues
	auras[702]   = 1 -- Curse of Weakness
	auras[5782]  = 2 -- Fear
	auras[48181] = 2 -- Haunt
	auras[5484]  = 2 -- Howl of Terror
	auras[348]   = 2 -- Immolate
	auras[60947] = 2 -- Nightmare <== Improved Fear -- NEEDS CHECK 60946
	auras[27243] = 2 -- Seed of Corruption
	auras[47960] = 2 -- Shadowflame -- NEEDS CHECK 47897
	auras[30283] = 2 -- Shadowfury
	auras[63311] = 2 -- Shadowsnare <== Glyph of Shadowflame
	auras[30108] = 2 -- Unstable Affliction

	auras[54277] = 4 -- Backdraft
	auras[34936] = 4 -- Backlash
	auras[79462] = 4 -- Demon Soul: Felguard
	auras[79460] = 4 -- Demon Soul: Felhunter
	auras[79459] = 4 -- Demon Soul: Imp
	auras[79463] = 4 -- Demon Soul: Succubus
	auras[79464] = 4 -- Demon Soul: Voidwalker
	auras[88448] = 4 -- Demonic Rebirth
	auras[47283] = 4 -- Empowered Imp
	auras[64371] = 4 -- Eradication
	auras[50589] = 4 -- Immolation Aura
	auras[47241] = 4 -- Metamorphosis
	auras[71165] = 4 -- Molten Core
	auras[54373] = 4 -- Nether Protection (Arcane)
	auras[54371] = 4 -- Nether Protection (Fire)
	auras[54372] = 4 -- Nether Protection (Frost)
	auras[54370] = 4 -- Nether Protection (Holy)
	auras[54375] = 4 -- Nether Protection (Nature)
	auras[54374] = 4 -- Nether Protection (Shadow)
	auras[91711] = 4 -- Nether Ward
	auras[7812]  = 4 -- Sacrifice
	auras[17941] = 4 -- Shadow Trance <== Nightfall
	auras[6229]  = 4 -- Shadow Ward
	auras[86211] = 4 -- Soul Swap
	auras[74434] = 4 -- Soulburn

	auras[85767] = 2 -- Dark Intent
	auras[20707] = 1 -- Soulstone Resurrection
end

------------------------------------------------------------------------
--	Warrior

if playerClass == "WARRIOR" then
	auras[86346] = 2 -- Colossus Smash
	auras[12809] = 2 -- Concussion Blow
	auras[1160]  = 1 -- Demoralizing Shout
	auras[676]   = 1 -- Disarm
	auras[1715]  = 2 -- Hamstring
	auras[20511] = 2 -- Intimidating Shout
	auras[12294] = 2 -- Mortal Strike
	auras[12323] = 2 -- Piercing Howl
	auras[94009] = 2 -- Rend
	auras[64382] = 1 -- Shattering Throw
	auras[46968] = 2 -- Shockwave
	auras[58567] = 2 -- Sunder Armor
	auras[85388] = 2 -- Throwdown
	auras[6343]  = 2 -- Thunder Clap

	auras[12964] = 4 -- Battle Trance
	auras[18499] = 4 -- Berserker Rage
	auras[46924] = 4 -- Bladestorm
	auras[46916] = 4 -- Bloodsurge
	auras[23885] = 4 -- Bloodthirst -- NEEDS CHECK
	auras[85730] = 4 -- Deadly Calm
	auras[12292] = 4 -- Death Wish
	auras[55694] = 4 -- Enraged Regeneration
	auras[1134]  = 4 -- Inner Rage
	auras[65156] = 4 -- Juggernaut
	auras[12976] = 4 -- Last Stand
	auras[1719]  = 4 -- Recklessness
	auras[20230] = 4 -- Retaliation
	auras[2565]  = 4 -- Shield Block
	auras[871]   = 4 -- Shield Wall
	auras[23920] = 4 -- Spell Reflection
	auras[50227] = 4 -- Sword and Board
	auras[87069] = 4 -- Thunderstruck
	auras[32216] = 4 -- Victory Rush

	auras[3411]  = 2 -- Intervene
	auras[50720] = 2 -- Vigilance
end

------------------------------------------------------------------------
-- Racials

if playerRace == "Draenei" then
	auras[59545] = 4 -- Gift of the Naaru (death knight)
	auras[59543] = 4 -- Gift of the Naaru (hunter)
	auras[59548] = 4 -- Gift of the Naaru (mage)
	auras[59542] = 4 -- Gift of the Naaru (paladin)
	auras[59544] = 4 -- Gift of the Naaru (priest)
	auras[59547] = 4 -- Gift of the Naaru (shaman)
	auras[28880] = 4 -- Gift of the Naaru (warrior)
elseif playerRace == "Dwarf" then
	auras[20594] = 4 -- Stoneform
elseif playerRace == "NightElf" then
	auras[58984] = 4 -- Shadowmeld
elseif playerRace == "Orc" then
	auras[20572] = 4 -- Blood Fury (attack power)
	auras[33702] = 4 -- Blood Fury (spell power)
	auras[33697] = 4 -- Blood Fury (attack power and spell damage)
elseif playerRace == "Scourge" then
	auras[7744]  = 4 -- Will of the Forsaken
elseif playerRace == "Tauren" then
	auras[20549] = 1 -- War Stomp
elseif playerRace == "Troll" then
	auras[26297] = 4 -- Berserking
elseif playerRace == "Worgen" then
	auras[68992] = 4 -- Darkflight
end

------------------------------------------------------------------------

local unitIsPlayer = { player = true, pet = true, vehicle = true }

local filters = {
	[1] = function(self, unit, caster) return true end,
	[2] = function(self, unit, caster) return unitIsPlayer[caster] end,
	[3] = function(self, unit, caster) return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) end,
	[4] = function(self, unit, caster) return unit == "player" and not self.__owner.isGroupFrame end,
}

ns.CustomAuraFilters = {
	player = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3)
		return auras[spellID]
	end,
	target = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3)
		local v = auras[spellID]
		-- print("CustomAuraFilter", "[unit]", unit, "[caster]", caster, "[name]", name, "[id]", spellID, "[filter]", v)
		if v and filters[v] then
			-- Specific filter.
			return filters[v](self, unit, caster)
		elseif UnitCanAttack(unit, "player") and not UnitPlayerControlled(unit) then
			-- Hostile NPC. Show auras cast by the unit, or auras cast by the player's vehicle.
			-- print("Hostile NPC")
			return not caster or caster == unit or UnitIsUnit(caster, "vehicle")
		else
			-- Friendly target or hostile player. Show boss debuffs, or auras cast by the player's vehicle.
			-- print("Hostile player / friendly unit")
			return isBossDebuff or UnitIsUnit(caster, "vehicle")
		end
	end,
	party = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3)
		local v = auras[spellID]
		return v and v < 4
	end,
}

ns.AuraList = auras