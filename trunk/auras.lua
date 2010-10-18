--[[--------------------------------------------------------------------
	oUF_Phanx
	An oUF layout.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Phanx. See README file for license terms.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
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
local addAuras = function(t) for k, v in pairs(t) do ns.AuraList[k] = v end end

------------------------------------------------------------------------

ns.AuraList = {
	[90355] = 4, -- Ancient Hysteria
	[2825]  = 4, -- Bloodlust
	[32182] = 4, -- Heroism
	[80353] = 4, -- Time Warp
	[29166] = 4, -- Innervate
	[10060] = 4, -- Power Infusion
}

------------------------------------------------------------------------

if playerClass == "DEATHKNIGHT" then addAuras({
	[48707] = 4, -- Anti-Magic Shell
	[49222] = 4, -- Bone Shield
	[49028] = 4, -- Dancing Rune Weapon
	[59052] = 4, -- Freezing Fog <== Rime
	[48792] = 4, -- Icebound Fortitude
	[51124] = 4, -- Killing Machine
	[49039] = 4, -- Lichborne
	[51271] = 4, -- Unbreakable Armor
	[55233] = 4, -- Vampiric Blood

	[59879] = 2, -- Blood Plague
	[45524] = 1, -- Chains of Ice
	[43265] = 2, -- Death and Decay
	[59921] = 2, -- Frost Fever
	[65142] = 2, -- Ebon Plague
	[49203] = 1, -- Hungering Cold
}) end

------------------------------------------------------------------------

if playerClass == "DRUID" then addAuras({
	[22812] = 4, -- Barkskin
	[50334] = 4, -- Berserk
	[5229]  = 4, -- Enrage
	[16870] = 4, -- Clearcasting <== Omen of Clarity
	[48518] = 4, -- Eclipse (Lunar)
	[48517] = 4, -- Eclipse (Solar)
	[22842] = 4, -- Frenzied Regeneration
	[16886] = 4, -- Nature's Grace
	[16689] = 4, -- Nature's Grasp
	[17116] = 4, -- Nature's Swiftness
	[52610] = 4, -- Savage Roar
	[61336] = 4, -- Survival Instincts
	[5217] 	= 4, -- Tiger's Fury

	[33763] = 2, -- Lifebloom
	[94447] = 2, -- Lifebloom (Tree of Life)
	[8936] 	= 1, -- Regrowth
	[774] 	= 1, -- Rejuvenation
	[467]   = 1, -- Thorns
	[48438] = 1, -- Wild Growth

	[5211]  = 1, -- Bash
	[5570] 	= 2, -- Insect Swarm
	[33745] = 2, -- Lacerate
	[22570] = 1, -- Maim
	[8921] 	= 2, -- Moonfire
	[93402] = 2, -- Sunfire
	[9005]  = 1, -- Pounce
	[1822] 	= 2, -- Rake
	[1079] 	= 2, -- Rip
}) end

------------------------------------------------------------------------

if playerClass == "HUNTER" then addAuras({
	[19574] = 4, -- Bestial Wrath
	[82921] = 4, -- Bombardment
	[53434] = 4, -- Call of the Wild
	[51775] = 4, -- Camouflage
	[19263] = 4, -- Deterrence
	[5384]  = 4, -- Feign Death
	[56453] = 4, -- Lock and Load
	[34477] = 4, -- Misdirection
	[3045]  = 4, -- Rapid Fire
	[35099] = 4, -- Rapid Killing

	[6991]  = 2, -- Feed Pet
	[19577] = 2, -- Intimidation
	[34026] = 2, -- Kill Command
	[136] 	= 2, -- Mend Pet

	[3674]  = 2, -- Black Arrow
	[5116]  = 1, -- Concussive Shot
	[19306] = 1, -- Counterattack
	[53301] = 2, -- Explosive Shot
	[43446] = 2, -- Explosive Trap Effect
	[1130] 	= 1, -- Hunter's Mark
	[57140] = 2, -- Immolation Trap Effect
	[1513] 	= 1, -- Scare Beast
	[19503] = 1, -- Scatter Shot
	[1978] 	= 2, -- Serpent Sting
	[34490] = 1, -- Silencing Shot
	[2974]  = 1, -- Wing Clip
	[19386] = 1, -- Wyvern Sting
}) end

------------------------------------------------------------------------

if playerClass == "MAGE" then addAuras({
	[36032] = 4, -- Arcane Blast
	[12042] = 4, -- Arcane Power
--	[57531] = 4, -- Arcane Potency
	[31643] = 4, -- Blazing Speed
	[57761] = 4, -- Brain Freeze
--	[12536] = 4, -- Clearcasting <== Arcane Concentration
	[44544] = 4, -- Fingers of Frost
	[57761] = 4, -- Fireball! <== Brain Freeze
	[48108] = 4, -- Hot Streak
	[11426] = 4, -- Ice Barrier
	[45438] = 4, -- Ice Block
	[12472] = 4, -- Icy Veins
	[64343] = 4, -- Impact
	[543]   = 4, -- Mage Ward
	[12043] = 4, -- Presence of Mind

	[54646] = 1, -- Focus Magic

	[11113] = 1, -- Blast Wave
	[12486] = 2, -- Chilled <== Blizzard <== Ice Shards
	[83853] = 4, -- Combustion
	[120] 	= 1, -- Cone of Cold
	[22959] = 1, -- Critical Mass
	[44572] = 1, -- Deep Freeze
	[31661] = 1, -- Dragon's Breath
	[122] 	= 1, -- Frost Nova
	[44614] = 2, -- Frostfire Bolt
	[44457] = 2, -- Living Bomb
	[11366] = 2, -- Pyroblast
	[92315] = 2, -- Pyroblast!
	[82691] = 2, -- Ring of Frost
	[31589] = 1, -- Slow
}) end

------------------------------------------------------------------------

if playerClass == "PALADIN" then addAuras({
	[86701] = 4, -- Ancient Crusader
	[86657] = 4, -- Ancient Guardian
	[86674] = 4, -- Ancient Healer
	[31850] = 4, -- Ardent Defender
	[31884] = 4, -- Avenging Wrath
	[31842] = 4, -- Divine Favor
	[54428] = 4, -- Divine Plea
	[31842] = 4, -- Divine Protection
	[642]   = 4, -- Divine Shield
	[20925] = 4, -- Holy Shield
	[82327] = 4, -- Holy Radiance
	[84963] = 4, -- Inquisition
	[85433] = 4, -- Sacred Duty
	[59578] = 4, -- The Art of War
	[85696] = 4, -- Zealotry

	[31821] = 2, -- Aura Mastery
	[53563] = 2, -- Beacon of Light
	[70940] = 1, -- Divine Guardian
	[1044]  = 1, -- Hand of Freedom
	[1022]  = 1, -- Hand of Protection
	[6940]  = 1, -- Hand of Sacrifice
	[1038]  = 1, -- Hand of Salvation

	[31935] = 1, -- Avenger's Shield
	[31803] = 2, -- Censure
	[25771] = 1, -- Forbearance
	[853]   = 1, -- Hammer of Justice
	[2812]  = 2, -- Holy Wrath
	[85285] = 2, -- Rebuke -- NEEDS CHECK
	[20710] = 1, -- Seal of Justice
}) end

------------------------------------------------------------------------

if playerClass == "PRIEST" then addAuras({
	[14751] = 4, -- Chakra
	[87117] = 4, -- Dark Evangelism -- NEEDS CHECK
	[87118] = 4, -- Dark Evangelism -- NEEDS CHECK
	[47585] = 4, -- Dispersion
	[81660] = 4, -- Evangelism -- NEEDS CHECK
	[81661] = 4, -- Evangelism -- NEEDS CHECK
	[586]   = 4, -- Fade
	[14751] = 4, -- Inner Focus
	[73413] = 4, -- Inner Will
	[88688] = 4, -- Surge of Light

	[6346]  = 1, -- Fear Ward
	[77613] = 2, -- Grace
	[47788] = 1, -- Guardian Spirit
	[33206] = 1, -- Pain Suppression
	[81782] = 1, -- Power Word: Barrier
	[17]    = 1, -- Power Word: Shield
	[139]   = 2, -- Renew

	[47753] = 2, -- Divine Aegis
	[2944]  = 2, -- Devouring Plague
	[605]   = 1, -- Mind Control
	[81292] = 2, -- Mind Melt (Rank 1)
	[87160] = 2, -- Mind Melt (Rank 2)
	[453]   = 1, -- Mind Soothe
	[87178] = 2, -- Mind Spike
	[33198] = 1, -- Misery
	[87193] = 2, -- Paralysis (Rank 1)
	[87194] = 2, -- Paralysis (Rank 2)
	[64044] = 1, -- Psychic Horror
	[8122]  = 1, -- Psychic Scream
	[589]   = 2, -- Shadow Word: Pain
	[34914] = 1, -- Vampiric Touch
	[6788]  = 1, -- Weakened Soul
}) end

------------------------------------------------------------------------

if playerClass == "ROGUE" then addAuras({
	[13750] = 4, -- Adrenaline Rush
	[13877] = 4, -- Blade Flurry
	[67210] = 4, -- Clearcasting <== Rogue T9 2P Bonus
	[31224] = 4, -- Cloak of Shadows
	[14177] = 4, -- Cold Blood
	[73651] = 4, -- Recuperate
	[5171]  = 4, -- Slice and Dice
	[56934] = 4, -- Tricks of the Trade

	[2094]  = 1, -- Blind
	[1833]  = 1, -- Cheap Shot
	[51722] = 1, -- Dismantle
	[703]   = 2, -- Garrote
	[1776]  = 2, -- Gouge
	[408]   = 1, -- Kidney Shot
	[84617] = 2, -- Revealing Strike
	[79140] = 2, -- Vendetta
}) end

------------------------------------------------------------------------

if playerClass == "SHAMAN" then addAuras({
	[16246] = 4, -- Clearcasting <== Elemental Focus
	[16166] = 4, -- Elemental Mastery
--	[53817] = 4, -- Maelstrom Weapon -- not shown since we're using a combopoints-like text display for it
	[16188] = 4, -- Nature's Swiftness
	[53390] = 4, -- Tidal Waves

	[974]   = 1, -- Earth Shield
--	[51945] = 1, -- Earthliving
	[61295] = 1, -- Riptide
--	[131]   = 1, -- Water Breathing
--	[5697]  = 1, -- Water Breathing <== Undending Breath
--	[546]   = 1, -- Water Walking

--	[8042]  = 1, -- Earth Shock
	[3600]  = 1, -- Earthbind
	[8050]  = 2, -- Flame Shock
--	[8056]  = 1, -- Frost Shock
	[8034]  = 2, -- Frostbrand Attack
	[77661] = 2, -- Searing Flames
	[37976] = 1, -- Stoneclaw Stun
	[17364] = 2, -- Stormstrike
}) end

------------------------------------------------------------------------

if playerClass == "WARLOCK" then addAuras({
	[34936] = 4, -- Backlash
	[47241] = 4, -- Demon Form
	[88448] = 4, -- Demonic Rebirth
	[47283] = 4, -- Empowered Imp
	[65371] = 4, -- Eradication
	[71165] = 4, -- Molten Core
	[91711] = 4, -- Nether Ward
	[17941] = 4, -- Shadow Trance
	[6229]  = 4, -- Shadow Ward
	[74434] = 4, -- Soulburn

	[80398] = 2, -- Dark Intent
	[20707] = 1, -- Soulstone Resurrection
--	[5697]  = 1, -- Unending Breath
--	[131]   = 1, -- Unending Breath <== Water Breathing

	[980]   = 2, -- Bane of Agony
	[603]   = 2, -- Bane of Doom
	[80240] = 2, -- Bane of Havoc
	[17962] = 2, -- Conflagrate
	[172]   = 2, -- Corruption
	[1490]  = 1, -- Curse of the Elements
	[18223] = 1, -- Curse of Exhaustion
	[1714]  = 1, -- Curse of Tongues
	[702]   = 1, -- Curse of Weakness
	[5782]  = 2, -- Fear
	[48181] = 2, -- Haunt
	[5484]  = 2, -- Howl of Terror
	[348]   = 2, -- Immolate
	[27243] = 2, -- Seed of Corruption
	[47897] = 2, -- Shadowflame
	[30108] = 2, -- Unstable Affliction
}) end

------------------------------------------------------------------------

if playerClass == "WARRIOR" then addAuras({
	[46924] = 4, -- Bladestorm
	[85730] = 4, -- Deadly Calm
	[12292] = 4, -- Death Wish
	[55694] = 4, -- Enraged Regeneration
	[1134]  = 4, -- Inner Rage
	[12975] = 4, -- Last Stand
	[1719]  = 4, -- Recklessness
	[20230] = 4, -- Retaliation
	[2565]  = 4, -- Shield Block
	[871]   = 4, -- Shield Wall
	[46916] = 4, -- Slam! <== Bloodsurge
	[12328] = 4, -- Sweeping Strikes
	[50227] = 4, -- Sword and Board
	[34428] = 4, -- Victory Rush

	[50720] = 2, -- Vigilance

	[86346] = 2, -- Colossus Smash
	[12809] = 1, -- Concussion Blow
	[676]   = 2, -- Disarmed!
	[1715]  = 1, -- Hamstring
	[772]   = 2, -- Rend
	[7386]  = 2, -- Sunder Armor
	[85388] = 2, -- Throwdown
	[6343]  = 1, -- Thunder Clap
}) end

------------------------------------------------------------------------
-- Racials

if playerRace == "Dwarf" then
	ns.AuraList[20594] = 4 -- Stoneform
elseif playerRace == "NightElf" then
	ns.AuraList[58984] = 4 -- Shadowmeld
elseif playerRace == "Orc" then
	ns.AuraList[20572] = 4 -- Blood Fury (attack power)
	ns.AuraList[33702] = 4 -- Blood Fury (spell power)
	ns.AuraList[33697] = 4 -- Blood Fury (attack power and spell damage)
elseif playerRace == "Scourge" then
	ns.AuraList[7744]  = 4 -- Will of the Forsaken
elseif playerRace == "Tauren" then
	ns.AuraList[20549] = 1 -- War Stomp
elseif playerRace == "Troll" then
	ns.AuraList[26297] = 4 -- Berserking
end

------------------------------------------------------------------------
-- Equivalent Debuffs

-- Armor Reduced
if playerClass == "DRUID" or playerClass == "ROGUE" or playerClass == "WARRIOR" then addAuras({
	[8647] 	= 1, -- Expose Armor
	[91565] = 1, -- Faerie Fire
	[7386] 	= 1, -- Sunder Armor
})

-- Attack Speed Reduced
if playerClass == "DEATHKNIGHT" or playerClass == "WARRIOR" then addAuras({
	[8042]  = 1, -- Earth Shock
	[55095] = 1, -- Frost Fever -- 45477 Icy Touch
	[58180] = 1, -- Infected Wounds
	[68055] = 1, -- Judgements of the Just
	[6343]  = 1, -- Thunder Clap
}) end

-- Bleed Damage Increased
if playerClass == "DRUID" or playerClass == "ROGUE" or playerclass == "WARRIOR" then addAuras({
	[16511] = 1, -- Hemorrhage
	[33878] = 1, -- Mangle (Bear)
	[33876] = 1, -- Mangle (Cat)
	[46857] = 1, -- Trauma
}) end

-- Healing Reduced (Player)
if playerClass == "HUNTER" or playerClass == "WARRIOR" then addAuras({
	[56112] = 3, -- Furious Attacks
	[48301] = 3, -- Mind Trauma
	[30213] = 3, -- Legion Strike (Felguard)
	[47486] = 1, -- Mortal Strike
	[82654] = 3, -- Widow Venom
}) end

-- Cast Speed Reduced
if playerClass == "DEATHKNIGHT" or playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then addAuras({
	[1714]  = 3, -- Curse of Tongues
	[5760]  = 3, -- Mind-Numbing Poison
	[73975] = 3, -- Necrotic Strike
	[31589] = 3, -- Slow

-- Physical Damage Dealt Reduced
if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "WARRIOR" then addAuras({
	[702]   = 1, -- Curse of Weakness
	[99]    = 1, -- Demoralizing Roar
	[1160]  = 1, -- Demoralizing Shout
	[81130] = 1, -- Scarlet Fever
	[26017] = 1, -- Vindication
}) end

-- Taunted
if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "WARRIOR" then addAuras({
	[5209]  = 1, -- Challenging Roar
	[1161]  = 1, -- Challenging Shout
	[56222] = 1, -- Dark Command
	[57603] = 1, -- Death Grip
	[6795]  = 1, -- Growl
	[62124] = 1, -- Hand of Reckoning
	[694]   = 1, -- Mocking Blow
	[31790] = 1, -- Righteous Defense
	[355]   = 1, -- Taunt
}) end

------------------------------------------------------------------------
-- Crowd Control

addAuras({
	[710]   = 1, -- Banish
	[76780] = 1, -- Bind Elemental
	[33786] = 1, -- Cyclone
	[339]   = 1, -- Entangling Roots
	[5782]  = 1, -- Fear
	[55041] = 1, -- Freezing Trap Effect
	[51514] = 1, -- Hex
	[2637]  = 1, -- Hibernate
	[118]   = 1, -- Polymorph
	[61305] = 1, -- Polymorph (Black Cat)
	[28272] = 1, -- Polymorph (Pig)
	[61721] = 1, -- Polymorph (Rabbit)
	[61780] = 1, -- Polymorph (Turkey)
	[28271] = 1, -- Polymorph (Turtle)
	[20066] = 1, -- Repentance
	[6670]  = 1, -- Sap
	[6358]  = 1, -- Seduction
	[9484]  = 1, -- Shackle Undead
	[10326] = 1, -- Turn Evil
})

------------------------------------------------------------------------
-- Level 80 Trinkets
--[[
addAuras({
})
--]]
------------------------------------------------------------------------
--[[
ns.AuraBlacklist = { -- not used currently
	[64805] = 1, -- Bested Darnassus
	[64809] = 1, -- Bested Gnomeregan
	[64810] = 1, -- Bested Ironforge
	[64811] = 1, -- Bested Orgrimmar
	[64812] = 1, -- Bested Sen'jin
	[64813] = 1, -- Bested Silvermoon City
	[84814] = 1, -- Bested Stormwind
	[64808] = 1, -- Bested the Exodar
	[64816] = 1, -- Bested the Undercity
	[64815] = 1, -- Bested Thunder Bluff
	[69127] = 1, -- Chill of the Throne
	[57723] = 1, -- Exhaustion
	[57724] = 1, -- Sated
}
--]]
------------------------------------------------------------------------

ns.AuraNameList = { }

local ids = ns.AuraList
local names = ns.AuraNameList

for k, v in pairs(ids) do
	local name = GetSpellInfo(k)
	if name then
		names[name] = v
	end
end

local playerunits = { player = true, pet = true, vehicle = true }

local filters = {
	[1] = function(self, unit, caster) return true end,
	[2] = function(self, unit, caster) return playerunits[caster] end,
	[3] = function(self, unit, caster) return UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) end,
	[4] = function(self, unit, caster) return unit == "player" and not self.__owner.isGroupFrame end,
}

ns.CustomAuraFilter = function(self, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)
	local v = ids[spellID] -- names[name]

	-- print("CustomAuraFilter", unit, caster, name, spellID, v)

	if v and filters[v] then
		return filters[v](self, unit, caster)
	else
		return (not caster or caster == unit) and UnitCanAttack(unit, "player") and not UnitPlayerControlled(unit)
	end
end
