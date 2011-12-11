--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Written by Phanx <addons@phanx.net>
	Copyright © 2007–2011. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curse.com/downloads/wow-addons/details/ouf-phanx.aspx
------------------------------------------------------------------------
	Values:
	1 = by anyone on anyone
	2 = by player on anyone
	3 = by anyone on friendly
	4 = by anyone on player
----------------------------------------------------------------------]]

local _, ns = ...
local playerClass = select( 2, UnitClass( "player" ) )
local playerRace = select( 2, UnitRace( "player" ) )

local auras = {}

local function addAuras( t )
	for k, v in pairs( t ) do
		if not auras[ k ] then
			auras[ k ] = v
		end
	end
end

------------------------------------------------------------------------
--	Buffed

addAuras({
	[90355] = 4, -- Ancient Hysteria [hunter core hound]
	[2825]  = 4, -- Bloodlust
	[1022]  = 4, -- Hand of Protection
	[32182] = 4, -- Heroism
	[29166] = 4, -- Innervate
	[80353] = 4, -- Time Warp
	[33206] = 4, -- Pain Suppression
	[10060] = 4, -- Power Infusion
	[49016] = 4, -- Unholy Frenzy

	[81708] = 4, -- Lifeblood [Rank 1]
	[55428] = 4, -- Lifeblood [Rank 2]
	[55480] = 4, -- Lifeblood [Rank 3]
	[55500] = 4, -- Lifeblood [Rank 4]
	[55501] = 4, -- Lifeblood [Rank 5]
	[55502] = 4, -- Lifeblood [Rank 6]
	[55503] = 4, -- Lifeblood [Rank 7]
	[74497] = 4, -- Lifeblood [Rank 8]
})

------------------------------------------------------------------------
--	Armor reduced

if playerClass == "DRUID" or playerClass == "WARRIOR" then addAuras({
	[35387] = 1, -- Corrosive Spit [hunter serpent]
	[91565] = 1, -- Faerie Fire
	[8647]  = 1, -- Expose Armor
	[7386]  = 1, -- Sunder Armor
	[50498] = 1, -- Tear Armor [hunter raptor]
}) end

------------------------------------------------------------------------
--	Attack speed reduced

if playerClass == "WARRIOR" then addAuras({
	[54404] = 1, -- Dust Cloud [hunter tallstrider]
	[8042]  = 1, -- Earth Shock
	[55095] = 1, -- Frost Fever
	[58179] = 1, -- Infected Wounds [Rank 1]
	[58180] = 1, -- Infected Wounds [Rank 2]
	[68055] = 1, -- Judgements of the Just
	[14251] = 1, -- Riposte
	[90315] = 1, -- Tailspin [hunter fox]
	[6343]  = 1, -- Thunder Clap
}) end

------------------------------------------------------------------------
--	Bleed damage taken increased

if playerClass == "DRUID" or playerClass == "ROGUE" then addAuras({
	[35290] = 1, -- Gore [hunter boar] -- NEEDS CHECK
	[16511] = 1, -- Hemorrhage
	[33878] = 1, -- Mangle [Bear Form]
	[33876] = 1, -- Mangle [Cat Form]
	[57386] = 1, -- Stampede [hunter rhino]
	[50271] = 1, -- Tendon Rip [hunter hyena]
	[46857] = 1, -- Trauma <== Blood Frenzy
}) end

------------------------------------------------------------------------
--	Casting speed reduced

if playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then addAuras({
	[1714]  = 1, -- Curse of Tongues
	[58604] = 1, -- Lava Breath [hunter core hound]
	[5760]  = 1, -- Mind-Numbing Poison
	[31589] = 1, -- Slow
	[50274] = 1, -- Spore Cloud [hunter sporebat]
}) end

------------------------------------------------------------------------
--	Healing effects reduced

if playerClass == "HUNTER" or playerClass == "ROGUE" or playerClass == "WARRIOR" then addAuras({
	[56112] = 1, -- Furious Attacks
	[48301] = 1, -- Mind Trauma <== Improved Mind Blast
	[30213] = 1, -- Legion Strike [warlock felguard]
	[54680] = 1, -- Monstrous Bite [hunter devilsaur]
	[12294] = 1, -- Mortal Strike
	[82654] = 1, -- Widow Venom
	[13218] = 1, -- Wound Poison
}) end

------------------------------------------------------------------------
--	Physical damage dealt reduced

if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "WARRIOR" then addAuras({
	[702]   = 1, -- Curse of Weakness
	[99]    = 1, -- Demoralizing Roar
	[50256] = 1, -- Demoralizing Roar [hunter bear]
	[1160]  = 1, -- Demoralizing Shout
	[81130] = 1, -- Scarlet Fever
	[26017] = 1, -- Vindication
}) end

------------------------------------------------------------------------
--	Disarmed

if playerClass == "" then addAuras({
	[50541] = 1, -- Clench (hunter scorpid)
	[676]   = 1, -- Disarm (warrior)
	[51722] = 1, -- Dismantle (rogue)
	[64058] = 1, -- Psychic Horror (priest)
	[91644] = 1, -- Snatch (hunter bird of prey)
}) end

------------------------------------------------------------------------
--	Silenced

if playerClass == "" then addAuras({
	[25046] = 1, -- Arcane Torrent (blood elf)
	[31935] = 1, -- Avenger's Shield (paladin)
	[1330]  = 1, -- Garrote - Silence (rogue)
	[50479] = 1, -- Nether Shock (hunter nether ray)
	[15487] = 1, -- Silence (priest)
	[18498] = 1, -- Silenced - Gag Order (warrior)
	[18469] = 1, -- Silenced - Improved Counterspell (mage)
	[18425] = 1, -- Silenced - Improved Kick (rogue)
	[34490] = 1, -- Silencing Shot (hunter)
	[81261] = 1, -- Solar Beam (druid)
	[24259] = 1, -- Spell Lock (warlock felhunter)
	[47476] = 1, -- Strangulate (death knight)
}) end

------------------------------------------------------------------------
--	Spell-locked

if playerClass == "" then addAuras({
	[2139]  = 1, -- Counterspell (mage)
	[1766]  = 1, -- Kick (rogue)
	[47528] = 1, -- Mind Freeze (death knight)
	[6552]  = 1, -- Pummel (warrior)
	[26090] = 1, -- Pummel (hunter gorilla)
	[50318] = 1, -- Serenity Dust (hunter moth)
	[72]    = 1, -- Shield Bash (warrior)
	[80964] = 1, -- Skull Bash (Bear) (druid)
	[80965] = 1, -- Skull Bash (Cat) (druid)
	[57994] = 1, -- Wind Shear (shaman)
}) end

------------------------------------------------------------------------
--	Taunted

if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "WARRIOR" then addAuras({
	[5209]  = 1, -- Challenging Roar
	[1161]  = 1, -- Challenging Shout
	[56222] = 1, -- Dark Command
	[57604] = 1, -- Death Grip -- NEEDS CHECK 57603
	[20736] = 1, -- Distracting Shot
	[6794]  = 1, -- Growl
	[62124] = 1, -- Hand of Reckoning
	[31790] = 1, -- Righteous Defense
	[355]   = 1, -- Taunt
	[58857] = 1, -- Twin Howl [shaman spirit wolves]
}) end

------------------------------------------------------------------------
--	Crowd controlled

addAuras({
	[710]   = 1, -- Banish
	[76780] = 1, -- Bind Elemental
	[33786] = 1, -- Cyclone
	[339]   = 1, -- Entangling Roots
	[5782]  = 1, -- Fear
	[3355]  = 1, -- Freezing Trap -- NEEDS CHECK 31932 43415 55041
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
})

------------------------------------------------------------------------
--	Death Knight

if playerClass == "DEATHKNIGHT" then addAuras({
	[55078] = 2, -- Blood Plague
	[45524] = 1, -- Chains of Ice
	[77606] = 2, -- Dark Simulacrum
	[43265] = 2, -- Death and Decay
	[65142] = 2, -- Ebon Plague
	[55095] = 2, -- Frost Fever
	[49203] = 1, -- Hungering Cold
	[81130] = 2, -- Scarlet Fever
	[50536] = 2, -- Unholy Blight -- NEEDS CHECK

	[48707] = 4, -- Anti-Magic Shell
	[81141] = 4, -- Blood Swarm <== Crimson Scourge
	[49222] = 4, -- Bone Shield
	[81256] = 4, -- Dancing Rune Weapon
	[59052] = 4, -- Freezing Fog <== Rime
	[48792] = 4, -- Icebound Fortitude
	[51124] = 4, -- Killing Machine
	[49039] = 4, -- Lichborne
	[51271] = 4, -- Pillar of Frost
	[50421] = 4, -- Scent of Blood
	[81340] = 4, -- Sudden Doom
	[55233] = 4, -- Vampiric Blood
	[81162] = 4, -- Will of the Necropolis -- NEEDS CHECK

	[49016] = 1, -- Unholy Frenzy
}) end

------------------------------------------------------------------------
--	Druid

if playerClass == "DRUID" then addAuras({
	[5211]  = 2, -- Bash
	[33786] = 2, -- Cyclone
	[339]   = 2, -- Entangling Roots
	[45334] = 2, -- Feral Charge Effect [Bear Form]
	[61138] = 2, -- Feral Charge - Cat -- NEEDS CHECK
	[2637]  = 2, -- Hibernate
	[5570]  = 2, -- Insect Swarm
	[33745] = 2, -- Lacerate
	[22570] = 2, -- Maim
	[8921]  = 2, -- Moonfire
	[9005]  = 2, -- Pounce
	[9007]  = 2, -- Pounce Bleed
	[1822]  = 2, -- Rake
	[1079]  = 2, -- Rip
	[93402] = 2, -- Sunfire
	[77758] = 2, -- Thrash

	[22812] = 4, -- Barkskin
	[50334] = 4, -- Berserk
	[93622] = 4, -- Berserk [Mangle (Bear) cooldown reset proc]
	[16870] = 4, -- Clearcasting <== Omen of Clarity
	[1850]  = 4, -- Dash
	[5229]  = 4, -- Enrage
	[48518] = 4, -- Eclipse (Lunar)
	[48517] = 4, -- Eclipse (Solar)
	[22842] = 4, -- Frenzied Regeneration
	[81093] = 4, -- Fury of Stormrage
	[81192] = 4, -- Lunar Shower
	[16886] = 4, -- Nature's Grace
	[16689] = 4, -- Nature's Grasp
	[17116] = 4, -- Nature's Swiftness
	[80951] = 4, -- Pulverize
	[52610] = 4, -- Savage Roar
	[93400] = 4, -- Shooting Stars
	[81021] = 4, -- Stampede [Ravage effect]
	[81022] = 4, -- Stampede [Ravage effect]
	[61336] = 4, -- Survival Instincts
	[5217]  = 4, -- Tiger's Fury
	[33891] = 4, -- Tree of Life
	[61391] = 4, -- Typhoon

	[33763] = 2, -- Lifebloom
	[94447] = 2, -- Lifebloom [Tree of Life version]
	[8936]  = 2, -- Regrowth
	[774]   = 2, -- Rejuvenation
	[77764] = 1, -- Stampeding Roar
	[467]   = 1, -- Thorns
	[48438] = 2, -- Wild Growth
}) end

------------------------------------------------------------------------
--	Hunter

if playerClass == "HUNTER" then addAuras({
	[50433] = 2, -- Ankle Crack [crocolisk]
	[3674]  = 2, -- Black Arrow
	[35101] = 2, -- Concussive Barrage
	[5116]  = 2, -- Concussive Shot
	[19306] = 2, -- Counterattack
	[20736] = 2, -- Distracting Shot
	[64803] = 2, -- Entrapment
	[53301] = 2, -- Explosive Shot
	[13812] = 2, -- Explosive Trap -- NEEDS CHECK 43446
	[3355]  = 2, -- Freezing Trap -- NEEDS CHECK 31932 43415 55041
	[1130]  = 1, -- Hunter's Mark
	[13810] = 2, -- Ice Trap
	[13797] = 2, -- Immolation Trap -- NEEDS CHECK 51740
	[24394] = 2, -- Intimidation
	[88691] = 1, -- Marked for Death
	[63468] = 2, -- Piercing Shots
	[1513]  = 2, -- Scare Beast
	[19503] = 2, -- Scatter Shot
	[1978]  = 2, -- Serpent Sting
	[82654] = 1, -- Widow Venom
	[2974]  = 2, -- Wing Clip
	[19386] = 2, -- Wyvern Sting

	[82921] = 4, -- Bombardment
	[51755] = 4, -- Camouflage
	[15571] = 4, -- Dazed <== Aspect of the Cheetah
	[19263] = 4, -- Deterrence
	[5384]  = 4, -- Feign Death
	[82926] = 4, -- Fire! <== Lock and Load
	[64418] = 4, -- Sniper Training [Rank 1]
	[64419] = 4, -- Sniper Training [Rank 2]
	[64420] = 4, -- Sniper Training [Rank 3]
	[56453] = 4, -- Lock and Load
	[34477] = 4, -- Misdirection
	[3045]  = 4, -- Rapid Fire
	[35099] = 4, -- Rapid Killing
--	[82925] = 4, -- Ready, Set, Aim...

	[19574] = 2, -- Bestial Wrath
	[1539]  = 2, -- Feed Pet
	[136]   = 2, -- Mend Pet
}) end

------------------------------------------------------------------------
--	Mage

if playerClass == "MAGE" then addAuras({
	[11113] = 2, -- Blast Wave
	[12486] = 2, -- Chilled <== Blizzard <== Ice Shards -- NEEDS CHECK
	[7321]  = 2, -- Chilled <== Frost Aura
	[83853] = 2, -- Combustion
	[120]   = 2, -- Cone of Cold
	[44572] = 2, -- Deep Freeze
	[31661] = 2, -- Dragon's Breath
	[122]   = 2, -- Frost Nova
	[116]   = 2, -- Frostbolt
	[44614] = 2, -- Frostfire Bolt
	[12654] = 2, -- Ignite
	[12355] = 2, -- Impact
	[83301] = 2, -- Improved Cone of Cold [Rank 1]
	[83302] = 2, -- Improved Cone of Cold [Rank 2]
	[44457] = 2, -- Living Bomb
	[118]   = 2, -- Polymorph
	[61305] = 2, -- Polymorph [Black Cat]
	[28272] = 2, -- Polymorph [Pig]
	[61721] = 2, -- Polymorph [Rabbit]
	[61780] = 2, -- Polymorph [Turkey]
	[28271] = 2, -- Polymorph [Turtle]
	[82691] = 2, -- Ring of Frost
	[31589] = 2, -- Slow

	[36032] = 4, -- Arcane Blast
	[79683] = 4, -- Arcane Missiles!
	[12042] = 4, -- Arcane Power
	[31643] = 4, -- Blazing Speed
	[57761] = 4, -- Brain Freeze
	[44544] = 4, -- Fingers of Frost
	[48108] = 4, -- Hot Streak
	[11426] = 4, -- Ice Barrier
	[45438] = 4, -- Ice Block
	[12472] = 4, -- Icy Veins
	[64343] = 4, -- Impact
	[66]    = 4, -- Invisibility
	[543]   = 4, -- Mage Ward
	[1436]  = 4, -- Mana Shield
	[12043] = 4, -- Presence of Mind

	[54646] = 2, -- Focus Magic
	[130]   = 2, -- Slow Fall
}) end

------------------------------------------------------------------------
--	Paladin

if playerClass == "PALADIN" then addAuras({
	[31935] = 2, -- Avenger's Shield
	[31803] = 2, -- Censure <== Seal of Truth
	[25771] = 1, -- Forbearance
	[853]   = 2, -- Hammer of Justice
	[2812]  = 2, -- Holy Wrath
	[20066] = 2, -- Repentance
	[10326] = 2, -- Turn Evil

	[86701] = 4, -- Ancient Crusader <== Guardian of Ancient Kings
	[86657] = 4, -- Ancient Guardian <== Guardian of Ancient Kings
	[86674] = 4, -- Ancient Healer <== Guardian of Ancient Kings
	[31850] = 4, -- Ardent Defender
	[31821] = 4, -- Aura Mastery
	[31884] = 4, -- Avenging Wrath
	[88819] = 4, -- Daybreak
	[85509] = 4, -- Denounce
	[31842] = 4, -- Divine Favor
	[54428] = 4, -- Divine Plea
	[498]   = 4, -- Divine Protection
	[642]   = 4, -- Divine Shield
	[82327] = 4, -- Holy Radiance
	[20925] = 4, -- Holy Shield
	[54149] = 4, -- Infusion of Light
	[84963] = 4, -- Inquisition
	[85433] = 4, -- Sacred Duty
	[85497] = 4, -- Speed of Light [haste effect]
	[59578] = 4, -- The Art of War
	[85696] = 4, -- Zealotry

	[53563] = 2, -- Beacon of Light
	[70940] = 1, -- Divine Guardian
	[1044]  = 1, -- Hand of Freedom
	[1022]  = 1, -- Hand of Protection
	[6940]  = 1, -- Hand of Sacrifice
	[1038]  = 1, -- Hand of Salvation
}) end

------------------------------------------------------------------------
--	Priest

if playerClass == "PRIEST" then addAuras({
	[2944]  = 2, -- Devouring Plague
	[88625] = 2, -- Holy Word: Chastise
	[605]   = 2, -- Mind Control
	[453]   = 1, -- Mind Soothe
	[87178] = 2, -- Mind Spike
	[87193] = 2, -- Paralysis [Rank 1]
	[87194] = 2, -- Paralysis [Rank 2]
	[64044] = 2, -- Psychic Horror
	[8122]  = 2, -- Psychic Scream
	[9484]  = 2, -- Shackle Undead
	[589]   = 2, -- Shadow Word: Pain
	[34914] = 2, -- Vampiric Touch
	[6788]  = 1, -- Weakened Soul

	[81700] = 4, -- Archangel
	[14751] = 4, -- Chakra
	[81208] = 4, -- Chakra: Heal
	[81206] = 4, -- Chakra: Prayer of Healing
	[81207] = 4, -- Chakra: Renew
	[81209] = 4, -- Chakra: Smite
	[87153] = 4, -- Dark Archangel
	[87117] = 4, -- Dark Evangelism -- NEEDS CHECK
	[87118] = 4, -- Dark Evangelism -- NEEDS CHECK
	[47585] = 4, -- Dispersion
	[81660] = 4, -- Evangelism -- NEEDS CHECK
	[81661] = 4, -- Evangelism -- NEEDS CHECK
	[586]   = 4, -- Fade
	[89485] = 4, -- Inner Focus
	[81292] = 4, -- Mind Melt [Rank 1]
	[87160] = 4, -- Mind Melt [Rank 2]
	[63731] = 4, -- Serendipity [Rank 1]
	[63735] = 4, -- Serendipity [Rank 2]
	[88688] = 4, -- Surge of Light

	[6346]  = 1, -- Fear Ward
	[77613] = 2, -- Grace
	[47788] = 2, -- Guardian Spirit
	[88682] = 2, -- Holy Word: Aspire
	[33206] = 2, -- Pain Suppression
	[10060] = 2, -- Power Infusion
	[17]    = 1, -- Power Word: Shield
	[41635] = 2, -- Prayer of Mending
	[139]   = 2, -- Renew
}) end

------------------------------------------------------------------------
--	Rogue

if playerClass == "ROGUE" then addAuras({
	[51585] = 2, -- Blade Twisting
	[2094]  = 2, -- Blind
	[1833]  = 2, -- Cheap Shot
	[3409]  = 2, -- Crippling Poison
	[2818]  = 2, -- Deadly Poison
	[26679] = 2, -- Deadly Throw
	[51722] = 2, -- Dismantle
	[8647]  = 1, -- Expose Armor
	[703]   = 2, -- Garrote
	[1776]  = 2, -- Gouge
	[89775] = 2, -- Hemorrhage [dot from glyph]
	[408]   = 2, -- Kidney Shot
	[84617] = 2, -- Revealing Strike
	[14251] = 1, -- Riposte
	[1943]  = 2, -- Rupture
	[79140] = 2, -- Vendetta
	[13218] = 2, -- Wound Poison

	[13750] = 4, -- Adrenaline Rush
	[13877] = 4, -- Blade Flurry
	[31224] = 4, -- Cloak of Shadows
	[14177] = 4, -- Cold Blood
	[84590] = 4, -- Deadly Momentum
	[32645] = 4, -- Envenom
	[5277]  = 4, -- Evasion
	[73651] = 4, -- Recuperate
	[5171]  = 4, -- Slice and Dice
	[2983]  = 4, -- Sprint
	[57934] = 4, -- Tricks of the Trade
}) end

------------------------------------------------------------------------
--	Shaman

if playerClass == "SHAMAN" then addAuras({
	[76780] = 2, -- Bind Elemental
	[8042]  = 2, -- Earth Shock
	[3600]  = 1, -- Earthbind
	[56425] = 1, -- Earth's Grasp -- NEEDS CHECK
	[8050]  = 2, -- Flame Shock
	[8056]  = 2, -- Frost Shock
	[8034]  = 2, -- Frostbrand Attack -- NEEDS CHECK
	[89523] = 1, -- Grounding Totem [reflect]
	[8178]  = 1, -- Grounding Totem Effect
	[51514] = 2, -- Hex
	[77661] = 1, -- Searing Flames
	[39796] = 1, -- Stoneclaw Stun
	[17364] = 2, -- Stormstrike

	[16166] = 4, -- Elemental Mastery [instant cast]
	[77800] = 4, -- Focused Insight
	[65264] = 4, -- Lava Flows -- NEEDS CHECK
	[31616] = 4, -- Nature's Guardian
	[16188] = 4, -- Nature's Swiftness
	[30823] = 4, -- Shamanistic Rage
	[79206] = 4, -- Spiritwalker's Grace
	[53390] = 4, -- Tidal Waves

	[974]   = 2, -- Earth Shield
	[61295] = 2, -- Riptide
}) end

------------------------------------------------------------------------
--	Warlock

if playerClass == "WARLOCK" then addAuras({
	[93986] = 2, -- Aura of Foreboding [stun effect] -- NEEDS CHECK 93975
	[93987] = 2, -- Aura of Foreboding [root effect] -- NEEDS CHECK 93974
	[980]   = 2, -- Bane of Agony
	[603]   = 2, -- Bane of Doom
	[80240] = 2, -- Bane of Havoc
	[710]   = 2, -- Banish
	[172]   = 2, -- Corruption
	[29539] = 1, -- Curse of Exhaustion
	[1490]  = 1, -- Curse of the Elements
	[1714]  = 1, -- Curse of Tongues
	[702]   = 1, -- Curse of Weakness
	[5782]  = 2, -- Fear
	[48181] = 2, -- Haunt
	[5484]  = 2, -- Howl of Terror
	[348]   = 2, -- Immolate
	[60947] = 2, -- Nightmare <== Improved Fear -- NEEDS CHECK 60946
	[27243] = 2, -- Seed of Corruption
	[47960] = 2, -- Shadowflame -- NEEDS CHECK 47897
	[30283] = 2, -- Shadowfury
	[63311] = 2, -- Shadowsnare <== Glyph of Shadowflame
	[30108] = 2, -- Unstable Affliction

	[54277] = 4, -- Backdraft
	[34936] = 4, -- Backlash
	[79462] = 4, -- Demon Soul: Felguard
	[79460] = 4, -- Demon Soul: Felhunter
	[79459] = 4, -- Demon Soul: Imp
	[79463] = 4, -- Demon Soul: Succubus
	[79464] = 4, -- Demon Soul: Voidwalker
	[88448] = 4, -- Demonic Rebirth
	[47283] = 4, -- Empowered Imp
	[64371] = 4, -- Eradication
	[50589] = 4, -- Immolation Aura
	[47241] = 4, -- Metamorphosis
	[71165] = 4, -- Molten Core
	[54373] = 4, -- Nether Protection (Arcane)
	[54371] = 4, -- Nether Protection (Fire)
	[54372] = 4, -- Nether Protection (Frost)
	[54370] = 4, -- Nether Protection (Holy)
	[54375] = 4, -- Nether Protection (Nature)
	[54374] = 4, -- Nether Protection (Shadow)
	[91711] = 4, -- Nether Ward
	[7812]  = 4, -- Sacrifice
	[17941] = 4, -- Shadow Trance <== Nightfall
	[6229]  = 4, -- Shadow Ward
	[86211] = 4, -- Soul Swap
	[74434] = 4, -- Soulburn

	[85767] = 2, -- Dark Intent
	[20707] = 1, -- Soulstone Resurrection
}) end

------------------------------------------------------------------------
--	Warrior

if playerClass == "WARRIOR" then addAuras({
	[86346] = 2, -- Colossus Smash
	[12809] = 2, -- Concussion Blow
	[1160]  = 1, -- Demoralizing Shout
	[676]   = 1, -- Disarm
	[1715]  = 2, -- Hamstring
	[20511] = 2, -- Intimidating Shout
	[12294] = 2, -- Mortal Strike
	[12323] = 2, -- Piercing Howl
	[94009] = 2, -- Rend
	[64382] = 1, -- Shattering Throw
	[46968] = 2, -- Shockwave
	[58567] = 2, -- Sunder Armor
	[85388] = 2, -- Throwdown
	[6343]  = 2, -- Thunder Clap

	[12964] = 4, -- Battle Trance
	[18499] = 4, -- Berserker Rage
	[46924] = 4, -- Bladestorm
	[46916] = 4, -- Bloodsurge
	[23885] = 4, -- Bloodthirst -- NEEDS CHECK
	[85730] = 4, -- Deadly Calm
	[12292] = 4, -- Death Wish
	[55694] = 4, -- Enraged Regeneration
	[1134]  = 4, -- Inner Rage
	[65156] = 4, -- Juggernaut
	[12976] = 4, -- Last Stand
	[1719]  = 4, -- Recklessness
	[20230] = 4, -- Retaliation
	[2565]  = 4, -- Shield Block
	[871]   = 4, -- Shield Wall
	[23920] = 4, -- Spell Reflection
	[50227] = 4, -- Sword and Board
	[87069] = 4, -- Thunderstruck
	[32216] = 4, -- Victory Rush

	[3411]  = 2, -- Intervene
	[50720] = 2, -- Vigilance
}) end

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
	[1] = function( self, unit, caster ) return true end,
	[2] = function( self, unit, caster ) return unitIsPlayer[ caster ] end,
	[3] = function( self, unit, caster ) return UnitIsFriend( unit, "player" ) and UnitPlayerControlled( unit ) end,
	[4] = function( self, unit, caster ) return unit == "player" and not self.__owner.isGroupFrame end,
}

ns.CustomAuraFilters = {
	player = function( self, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID )
		return auras[ spellID ]
	end,
	target = function( self, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID )
		local v = auras[ spellID ]
		-- print( "CustomAuraFilter", unit, caster, name, spellID, v )
		if v and filters[ v ] then
			return filters[ v ]( self, unit, caster )
		else
			return ( not caster or caster == unit ) and UnitCanAttack( unit, "player" ) and not UnitPlayerControlled( unit )
		end
	end,
	party = function( self, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID )
		local v = auras[ spellID ]
		return v and v < 4
	end,
}

ns.AuraList = auras