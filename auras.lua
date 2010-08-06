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
	3 = by anyone on player
----------------------------------------------------------------------]]

local _, ns = ...
local playerClass = select(2, UnitClass("player"))
local playerRace = select(2, UnitRace("player"))
local addAuras = function(t) for k, v in pairs(t) do ns.AuraList[k] = v end end

------------------------------------------------------------------------

ns.AuraList = {
	[2825]  = 3, -- Bloodlust
	[32182] = 3, -- Heroism
	[49016] = 3, -- Hysteria
	[29166] = 3, -- Innervate
	[10060] = 3, -- Power Infusion
}

------------------------------------------------------------------------

if playerClass == "DEATHNKNIGHT" then addAuras({
	[48707] = 3, -- Anti-Magic Shell
	[49222] = 3, -- Bone Shield
	[49028] = 3, -- Dancing Rune Weapon
	[49796] = 3, -- Deathchill
	[59052] = 3, -- Freezing Fog <== Rime
	[48792] = 3, -- Icebound Fortitude
	[51124] = 3, -- Killing Machine
	[49039] = 3, -- Lichborne
	[51271] = 3, -- Unbreakable Armor
	[55233] = 3, -- Vampiric Blood

	[59879] = 2, -- Blood Plague
	[45524] = 1, -- Chains of Ice
	[49938] = 2, -- Death and Decay
	[59921] = 2, -- Frost Fever
	[51735] = 2, -- Ebon Plague
	[49203] = 1, -- Hungering Cold
	[49005] = 2, -- Mark of Blood
}) end

------------------------------------------------------------------------

if playerClass == "DRUID" then addAuras({
	[22812] = 3, -- Barkskin
	[50334] = 3, -- Berserk
	[16870] = 3, -- Clearcasting <== Omen of Clarity
	[48518] = 3, -- Eclipse (Lunar)
	[48517] = 3, -- Eclipse (Solar)
	[22842] = 3, -- Frenzied Regeneration
	[16886] = 3, -- Nature's Grace
	[17116] = 3, -- Nature's Swiftness
	[52610] = 3, -- Savage Roar
	[61336] = 3, -- Survival Instincts
	[50213] = 3, -- Tiger's Fury

	[48451] = 2, -- Lifebloom
	[48443] = 1, -- Regrowth
	[48441] = 1, -- Rejuvenation
	[53251] = 1, -- Wild Growth

	[770]   = 1, -- Faerie Fire
	[16857] = 1, -- Faerie Fire (Feral)
	[48468] = 2, -- Insect Swarm
	[48568] = 2, -- Lacerate
	[22570] = 1, -- Maim
	[48463] = 2, -- Moonfire
	[59881] = 1, -- Pounce Stun
	[48574] = 2, -- Rake
	[49800] = 2, -- Rip
	[26995] = 1, -- Soothe Animal
}) end

------------------------------------------------------------------------

if playerClass == "HUNTER" then addAuras({
	[19574] = 3, -- Bestial Wrath
	[53434] = 3, -- Call of the Wild
	[19263] = 3, -- Deterrence
	[5384]  = 3, -- Feign Death
	[56453] = 3, -- Lock and Load
	[34477] = 3, -- Misdirection
	[3045]  = 3, -- Rapid Fire
	[35099] = 3, -- Rapid Killing

	[6991]  = 2, -- Feed Pet
	[19577] = 2, -- Intimidation
	[34026] = 2, -- Kill Command
	[48990] = 2, -- Mend Pet

	[63672] = 2, -- Black Arrow
	[5116]  = 1, -- Concussive Shot
	[48999] = 1, -- Counterattack
	[60053] = 2, -- Explosive Shot
	[49065] = 2, -- Explosive Trap Effect
	[53338] = 1, -- Hunter's Mark
	[57140] = 2, -- Immolation Trap Effect
	[14327] = 1, -- Scare Beast
	[19503] = 1, -- Scatter Shot
	[3043]  = 1, -- Scorpid Sting
	[49001] = 2, -- Serpent Sting
	[34490] = 1, -- Silencing Shot
	[3034]  = 2, -- Viper Sting
	[2974]  = 1, -- Wing Clip
	[49012] = 1, -- Wyvern Sting
}) end

------------------------------------------------------------------------

if playerClass == "MAGE" then addAuras({
	[12042] = 3, -- Arcane Power
	[12536] = 3, -- Clearcasting <== Arcane Concentration
	[28682] = 3, -- Combustion
	[44544] = 3, -- Fingers of Frost
	[57761] = 3, -- Fireball! <== Brain Freeze
	[48108] = 3, -- Hot Streak
	[12472] = 3, -- Icy Veins
	[44401] = 3, -- Missile Barrage
	[12043] = 3, -- Presence of Mind

	[43017] = 1, -- Amplify Magic
	[43015] = 1, -- Dampen Magic
	[54646] = 1, -- Focus Magic

	[42945] = 1, -- Blast Wave
	[42931] = 1, -- Cone of Cold
	[44572] = 1, -- Deep Freeze
	[42950] = 1, -- Dragon's Breath
	[42833] = 2, -- Fireball
	[42917] = 1, -- Frost Nova
	[47610] = 2, -- Frostfire Bolt
	[22959] = 1, -- Improved Scorch
	[55360] = 2, -- Living Bomb
	[31589] = 1, -- Slow
}) end

------------------------------------------------------------------------

if playerClass == "PALADIN" then addAuras({
	[31884] = 3, -- Avenging Wrath
	[20216] = 3, -- Divine Favor
	[54428] = 3, -- Divine Plea
	[31842] = 3, -- Divine Protection
	[64205] = 3, -- Divine Sacrifice
	[642]   = 3, -- Divine Shield
	[31834] = 3, -- Light's Grace
	[59578] = 3, -- The Art of War

	[31821] = 2, -- Aura Mastery
	[53563] = 2, -- Beacon of Light
	[19752] = 1, -- Divine Intervention
	[1044]  = 1, -- Hand of Freedom
	[1022]  = 1, -- Hand of Protection
	[6940]  = 1, -- Hand of Sacrifice
	[1038]  = 1, -- Hand of Salvation
	[58597] = 2, -- Sacred Shield

	[31935] = 1, -- Avenger's Shield
	[25771] = 1, -- Forbearance
	[853]   = 1, -- Hammer of Justice
	[20184] = 1, -- Judgement of Justice
	[20267] = 1, -- Judgement of Light
	[20186] = 1, -- Judgement of Wisdom
	[53736] = 2, -- Seal of Corruption
	[31801] = 2, -- Seal of Vengeance
	[63529] = 1, -- Silenced - Shield of the Templar
}) end

------------------------------------------------------------------------

if playerClass == "PRIEST" then addAuras({
	[586]   = 3, -- Fade
	[14751] = 3, -- Inner Focus
	[15271] = 3, -- Spirit Tap
	[33151] = 3, -- Surge of Light

	[6346]  = 1, -- Fear Ward
	[47517] = 2, -- Grace
	[47788] = 1, -- Guardian Spirit
	[33206] = 1, -- Pain Suppression
	[48066] = 1, -- Power Word: Shield
	[48068] = 2, -- Renew

	[47753] = 2, -- Divine Aegis
	[48300] = 2, -- Devouring Plague
	[453]   = 1, -- Mind Soothe
	[33198] = 1, -- Misery
	[64044] = 1, -- Psychic Horror
	[10890] = 1, -- Psychic Scream
	[15258] = 2, -- Shadow Weaving
	[48125] = 2, -- Shadow Word: Pain
	[48160] = 1, -- Vampiric Touch
	[6788]  = 1, -- Weakened Soul
}) end

------------------------------------------------------------------------

if playerClass == "ROGUE" then addAuras({
	[13750] = 3, -- Adrenaline Rush
	[13877] = 3, -- Blade Flurry
	[67210] = 3, -- Clearcasting <== Rogue T9 2P Bonus
	[6774]  = 3, -- Slice and Dice
}) end

------------------------------------------------------------------------

if playerClass == "SHAMAN" then addAuras({
	[16246] = 3, -- Clearcasting <== Elemental Focus
	[16166] = 3, -- Elemental Mastery
--	[53817] = 3, -- Maelstrom Weapon -- not shown since we're using a combopoints-like text display for it
	[16188] = 3, -- Nature's Swiftness
	[53390] = 3, -- Tidal Waves

	[49284] = 1, -- Earth Shield
	[61301] = 1, -- Riptide
	[131]   = 1, -- Water Breathing
	[5697]  = 1, -- Water Breathing <== Undending Breath
	[546]   = 1, -- Water Walking

--	[49231] = 1, -- Earth Shock
	[3600]  = 1, -- Earthbind
	[49233] = 2, -- Flame Shock
--	[49236] = 1, -- Frost Shock
	[37976] = 1, -- Stoneclaw Stun
	[17364] = 2, -- Stormstrike
}) end

------------------------------------------------------------------------

if playerClass == "WARLOCK" then addAuras({
	[34936] = 3, -- Backlash
	[47241] = 3, -- Demon Form
	[47283] = 3, -- Empowered Imp
	[71165] = 3, -- Molten Core
	[17941] = 3, -- Shadow Trance

	[27239] = 1, -- Soulstone Resurrection
	[5697]  = 1, -- Unending Breath
	[131]   = 1, -- Unending Breath <== Water Breathing

	[17962] = 2, -- Conflagrate
	[47813] = 2, -- Corruption
	[47864] = 2, -- Curse of Agony
	[18223] = 1, -- Curse of Exhaustion
	[47865] = 1, -- Curse of the Elements
	[11719] = 1, -- Curse of Tongues
	[50511] = 1, -- Curse of Weakness
	[6215]  = 2, -- Fear
	[59164] = 2, -- Haunt
	[17928] = 2, -- Howl of Terror
	[47811] = 2, -- Immolate
	[47836] = 2, -- Seed of Corruption
	[61290] = 2, -- Shadowflame
	[47843] = 2, -- Unstable Affliction
}) end

------------------------------------------------------------------------

if playerClass == "WARRIOR" then addAuras({
	[46924] = 3, -- Bladestorm
	[12292] = 3, -- Death Wish
	[55694] = 3, -- Enraged Regeneration
	[12975] = 3, -- Last Stand
	[1719]  = 3, -- Recklessness
	[20230] = 3, -- Retaliation
	[2565]  = 3, -- Shield Block
	[871]   = 3, -- Shield Wall
	[46916] = 3, -- Slam! <== Bloodsurge
	[52437] = 3, -- Sudden Death
	[12328] = 3, -- Sweeping Strikes
	[50227] = 3, -- Sword and Board
	[34428] = 3, -- Victory Rush

	[1715]  = 1, -- Hamstring
	[47465] = 2, -- Rend
	[7386]  = 2, -- Sunder Armor
}) end

------------------------------------------------------------------------
-- Racials

if playerRace == "Dwarf" then
	ns.AuraList[20594] = 3 -- Stoneform
elseif playerRace == "NightElf" then
	ns.AuraList[58984] = 3 -- Shadowmeld
elseif playerRace == "Orc" then
	ns.AuraList[20572] = 3 -- Blood Fury
elseif playerRace == "Scourge" then
	ns.AuraList[7744]  = 3 -- Will of the Forsaken
elseif playerRace == "Troll" then
	ns.AuraList[26297] = 3 -- Berserking
end

------------------------------------------------------------------------
-- Equivalent Debuffs

-- Attack Power Reduced
if playerClass == "DRUID" or playerClass == "WARRIOR" then addAuras({
	[702]   = 1, -- Curse of Weakness
	[99]    = 1, -- Demoralizing Roar
	[1160]  = 1, -- Demoralizing Shout
	[26016] = 1, -- Vindication
}) end

-- Attack Speed Reduced
if playerClass == "WARRIOR" then addAuras({
	[58181] = 1, -- Infected Wounds
	[68055] = 1, -- Judgements of the Just
	[47502] = 1, -- Thunder Clap
}) end

-- Bleed Damage Increased
if playerClass == "DRUID" or playerclass == "WARRIOR" then addAuras({
	[33878] = 1, -- Mangle (Bear)
	[33876] = 1, -- Mangle (Cat)
	[46857] = 1, -- Trauma
})

-- Healing Reduced
if playerClass == "HUNTER" or playerClass == "WARRIOR" then addAuras({
	[49050] = 1, -- Aimed Shot
	[47486] = 1, -- Mortal Strike
})

-- Taunted
if playerClass == "DEATHKNIGHT" or playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "WARRIOR" then addAuras({
	[5209]  = 1, -- Challenging Roar
	[1161]  = 1, -- Challenging Shout
	[56222] = 1, -- Dark Command
	[57603] = 1, -- Death Grip
	[57603] = 1, -- Growl
	[62124] = 1, -- Hand of Reckoning
	[694]   = 1, -- Mocking Blow
	[31790] = 1, -- Righteous Defense
	[355]   = 1, -- Taunt
}) end

------------------------------------------------------------------------
-- Crowd Control

addAuras({
	[18647] = 1, -- Banish
	[33786] = 1, -- Cyclone
	[53308] = 1, -- Entangling Roots
	[6215]  = 1, -- Fear
	[14309] = 1, -- Freezing Trap
	[51514] = 1, -- Hex
	[18658] = 1, -- Hibernate
	[12825] = 1, -- Polymorph
	[61305] = 1, -- Polymorph (Black Cat)
	[28272] = 1, -- Polymorph (Pig)
	[61721] = 1, -- Polymorph (Rabbit)
	[61780] = 1, -- Polymorph (Turkey)
	[28271] = 1, -- Polymorph (Turtle)
	[20066] = 1, -- Repentance
	[51724] = 1, -- Sap
	[6358]  = 1, -- Seduction
	[10955] = 1, -- Shackle Undead
	[10326] = 1, -- Turn Evil
}) end

------------------------------------------------------------------------
-- Level 80 Trinkets

addAuras({
})

------------------------------------------------------------------------
-- Raid Encounters

addAuras({
	-- Naxxramas

	-- Eye of Eternity

	-- Obsidian Sanctum

	-- Ulduar

	-- Trial of the Crusader
	[66331] = 1, -- Gormok the Impaler ==> Impale
	[66406] = 1, -- Gormok the Impaler ==> Snobolled!
	[66823] = 1, -- Acidmaw ==> Paralytic Toxin
	[66869] = 1, -- Dreadscale ==> Burning Bile
	[66689] = 1, -- Icehowl ==> Arctic Breath
	[66237] = 1, -- Lord Jaraxxus ==> Incinerate Flesh
	[68124] = 1, -- Lord Jaraxxus ==> Legion Flame
	[66012] = 1, -- Anub'arak ==> Freezing Slash
	[67700] = 1, -- Anub'arak ==> Penetrating Cold

	-- Icecrown Citadel
	[69065] = 1, -- Lord Marrowgar ==> Impaled
	[72385] = 1, -- Deathbringer Saurfang ==> Boiling Blood
	[72293] = 1, -- Deathbringer Saurfang ==> Mark of the Fallen Champion
	[72410] = 1, -- Deathbringer Saurfang ==> Rune of Blood
	[69279] = 1, -- Festergut ==> Gas Spore
	[72219] = 1, -- Festergut ==> Gastric Bloat
	[72103] = 1, -- Festergut ==> Inoculated
	[69674] = 1, -- Rotface ==> Mutated Infection
	[70672] = 1, -- Professor Putricide ==> Gaseous Bloat
	[72672] = 1, -- Professor Putricide ==> Mutated Plague
	[70447] = 1, -- Professor Putricide ==> Volatile Ooze Adhesive
	[71510] = 1, -- Blood-Queen Lana'thel ==> Blood Mirror
	[70867] = 1, -- Blood-Queen Lana'thel ==> Essence of the Blood Queen
	[70877] = 1, -- Blood-Queen Lana'thel ==> Frenzied Bloodthirst
	[71340] = 1, -- Blood-Queen Lana'thel ==> Pact of the Darkfallen
	[71265] = 1, -- Blood-Queen Lana'thel ==> Swarming Shadows
	[70923] = 1, -- Blood-Queen Lana'thel ==> Uncontrollable Frenzy
	[70873] = 1, -- Valithria Dreamwalker ==> Emerald Vigor
	[70106] = 1, -- Sindragosa ==> Chilled to the Bone
	[70126] = 1, -- Sindragosa ==> Frost Beacon
	[70157] = 1, -- Sindragosa ==> Ice Tomb
	[69766] = 1, -- Sindragosa ==> Instability
	[70127] = 1, -- Sindragosa ==> Mystic Buffet
	[68980] = 1, -- The Lich King ==> Harvest Soul
	[74322] = 1, -- The Lich King ==> Harvested Soul
	[70337] = 1, -- The Lich King ==> Necrotic Plague
	[74074] = 1, -- The Lich King ==> Plague Siphon
	[69409] = 1, -- The Lich King ==> Soul Reaper

	-- Ruby Sanctum
	[74562] = 1, -- Halion ==> Fiery Consumption
	[74792] = 1, -- Halion ==> Soul Consumption
}) end

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

local t = { }
for k, v in pairs(ns.AuraList) do t[GetSpellInfo(k)] = v end
ns.AuraList = t

local auras = ns.AuraList
local playerunits = { player = true, pet = true, vehicle = true }

ns.CustomAuraFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)
	-- print("CustomAuraFilter", unit, name, caster, auras[name])
	local aurav = auras[name]
	if aurav == 3 then
		return unit == "player"
	elseif aurav == 2 then
		return playerunits[caster]
	elseif aurav == 1 then
		return true
	elseif not unit or caster == unit then
		return not UnitPlayerControlled(unit)
	end
end
