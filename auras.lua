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
	[2825]  = 4, -- Bloodlust
	[32182] = 4, -- Heroism
	[49016] = 4, -- Hysteria
	[29166] = 4, -- Innervate
	[10060] = 4, -- Power Infusion
}

------------------------------------------------------------------------

if playerClass == "DEATHKNIGHT" then addAuras({
	[48707] = 4, -- Anti-Magic Shell
	[49222] = 4, -- Bone Shield
	[49028] = 4, -- Dancing Rune Weapon
	[49796] = 4, -- Deathchill
	[59052] = 4, -- Freezing Fog <== Rime
	[48792] = 4, -- Icebound Fortitude
	[51124] = 4, -- Killing Machine
	[49039] = 4, -- Lichborne
	[51271] = 4, -- Unbreakable Armor
	[55233] = 4, -- Vampiric Blood

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
	[22812] = 4, -- Barkskin
	[50334] = 4, -- Berserk
	[16870] = 4, -- Clearcasting <== Omen of Clarity
	[48518] = 4, -- Eclipse (Lunar)
	[48517] = 4, -- Eclipse (Solar)
	[22842] = 4, -- Frenzied Regeneration
	[17116] = 4, -- Nature's Swiftness
	[52610] = 4, -- Savage Roar
	[61336] = 4, -- Survival Instincts
	[50213] = 4, -- Tiger's Fury

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
	[19574] = 4, -- Bestial Wrath
	[53434] = 4, -- Call of the Wild
	[19263] = 4, -- Deterrence
	[5384]  = 4, -- Feign Death
	[56453] = 4, -- Lock and Load
	[34477] = 4, -- Misdirection
	[3045]  = 4, -- Rapid Fire
	[35099] = 4, -- Rapid Killing

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
	[12042] = 4, -- Arcane Power
--	[12536] = 4, -- Clearcasting <== Arcane Concentration
	[28682] = 4, -- Combustion
	[44544] = 4, -- Fingers of Frost
	[57761] = 4, -- Fireball! <== Brain Freeze
	[48108] = 4, -- Hot Streak
	[12472] = 4, -- Icy Veins
	[44401] = 4, -- Missile Barrage
	[12043] = 4, -- Presence of Mind

	[43017] = 1, -- Amplify Magic
	[43015] = 1, -- Dampen Magic
	[54646] = 1, -- Focus Magic

	[42945] = 1, -- Blast Wave
	[42931] = 1, -- Cone of Cold
	[44572] = 1, -- Deep Freeze
	[42950] = 1, -- Dragon's Breath
--	[42833] = 2, -- Fireball
	[42917] = 1, -- Frost Nova
	[47610] = 2, -- Frostfire Bolt
	[22959] = 1, -- Improved Scorch
	[55360] = 2, -- Living Bomb
	[31589] = 1, -- Slow
}) end

------------------------------------------------------------------------

if playerClass == "PALADIN" then addAuras({
	[31884] = 4, -- Avenging Wrath
	[20216] = 4, -- Divine Favor
	[54428] = 4, -- Divine Plea
	[31842] = 4, -- Divine Protection
	[64205] = 4, -- Divine Sacrifice
	[642]   = 4, -- Divine Shield
	[31834] = 4, -- Light's Grace
	[59578] = 4, -- The Art of War

	[31821] = 2, -- Aura Mastery
	[53563] = 2, -- Beacon of Light
	[19752] = 1, -- Divine Intervention
	[1044]  = 1, -- Hand of Freedom
	[1022]  = 1, -- Hand of Protection
	[6940]  = 1, -- Hand of Sacrifice
	[1038]  = 1, -- Hand of Salvation
	[58597] = 2, -- Sacred Shield

	[31935] = 1, -- Avenger's Shield
	[31803] = 2, -- Censure
	[25771] = 1, -- Forbearance
	[853]   = 1, -- Hammer of Justice
	[20184] = 1, -- Judgement of Justice
	[20267] = 1, -- Judgement of Light
	[20186] = 1, -- Judgement of Wisdom
}) end

------------------------------------------------------------------------

if playerClass == "PRIEST" then addAuras({
	[586]   = 4, -- Fade
	[14751] = 4, -- Inner Focus
	[15271] = 4, -- Spirit Tap
	[33151] = 4, -- Surge of Light

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
	[13750] = 4, -- Adrenaline Rush
	[13877] = 4, -- Blade Flurry
	[67210] = 4, -- Clearcasting <== Rogue T9 2P Bonus
	[6774]  = 4, -- Slice and Dice
}) end

------------------------------------------------------------------------

if playerClass == "SHAMAN" then addAuras({
	[16246] = 4, -- Clearcasting <== Elemental Focus
	[16166] = 4, -- Elemental Mastery
--	[53817] = 4, -- Maelstrom Weapon -- not shown since we're using a combopoints-like text display for it
	[16188] = 4, -- Nature's Swiftness
	[53390] = 4, -- Tidal Waves

	[49284] = 1, -- Earth Shield
	[61301] = 1, -- Riptide
--	[131]   = 1, -- Water Breathing
--	[5697]  = 1, -- Water Breathing <== Undending Breath
--	[546]   = 1, -- Water Walking

--	[49231] = 1, -- Earth Shock
	[3600]  = 1, -- Earthbind
	[49233] = 2, -- Flame Shock
--	[49236] = 1, -- Frost Shock
	[77655] = 2, -- Searing Flames
	[37976] = 1, -- Stoneclaw Stun
	[17364] = 2, -- Stormstrike
}) end

------------------------------------------------------------------------

if playerClass == "WARLOCK" then addAuras({
	[34936] = 4, -- Backlash
	[47241] = 4, -- Demon Form
	[47283] = 4, -- Empowered Imp
	[71165] = 4, -- Molten Core
	[17941] = 4, -- Shadow Trance

	[27239] = 1, -- Soulstone Resurrection
--	[5697]  = 1, -- Unending Breath
--	[131]   = 1, -- Unending Breath <== Water Breathing

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
	[46924] = 4, -- Bladestorm
	[12292] = 4, -- Death Wish
	[55694] = 4, -- Enraged Regeneration
	[12975] = 4, -- Last Stand
	[1719]  = 4, -- Recklessness
	[20230] = 4, -- Retaliation
	[2565]  = 4, -- Shield Block
	[871]   = 4, -- Shield Wall
	[46916] = 4, -- Slam! <== Bloodsurge
	[52437] = 4, -- Sudden Death
	[12328] = 4, -- Sweeping Strikes
	[50227] = 4, -- Sword and Board
	[34428] = 4, -- Victory Rush

	[1715]  = 1, -- Hamstring
	[47465] = 2, -- Rend
	[7386]  = 2, -- Sunder Armor
}) end

------------------------------------------------------------------------
-- Racials

if playerRace == "Dwarf" then
	ns.AuraList[20594] = 4 -- Stoneform
elseif playerRace == "NightElf" then
	ns.AuraList[58984] = 4 -- Shadowmeld
elseif playerRace == "Orc" then
	ns.AuraList[20572] = 4 -- Blood Fury
elseif playerRace == "Scourge" then
	ns.AuraList[7744]  = 4 -- Will of the Forsaken
elseif playerRace == "Troll" then
	ns.AuraList[26297] = 4 -- Berserking
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
}) end

-- Healing Reduced (Player)
if playerClass == "HUNTER" or playerClass == "WARRIOR" then addAuras({
	[49050] = 1, -- Aimed Shot
	[47486] = 1, -- Mortal Strike
}) end

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
	[76780] = 1, -- Bind Elemental
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
})

------------------------------------------------------------------------
-- Level 80 Trinkets
--[[
addAuras({
})
--]]
------------------------------------------------------------------------
-- Healing Reduced (NPC)
--[[
if playerClass == "DRUID" or playerClass == "PALADIN" or playerClass =="PRIEST" or playerClass == "SHAMAN" then addAuras({
	[19434] = 3, -- Aimed Shot
	[40599] = 3, -- Arcing Smash
	[23169] = 3, -- Brood Affliction: Green
	[43410] = 3, -- Chop
	[34073] = 3, -- Curse of the Bleeding Hollow
	[13583] = 3, -- Curse of the Deadwood
	[45347] = 3, -- Dark Touched
	[63038] = 3, -- Dark Volley
	[36023] = 3, -- Deathblow
	[34625] = 3, -- Demolish
	[34366] = 3, -- Ebon Poison
	[48291] = 3, -- Fetid Rot
	[32378] = 3, -- Filet
	[56112] = 3, -- Furious Attacks
	[19716] = 3, -- Gehennas' Curse
	[52645] = 3, -- Hex of Weakness
	[70671] = 3, -- Leeching Rot -- 70710 Heroic
	[36917] = 3, -- Magma-Thrower's Curse
	[48301] = 3, -- Mind Trauma
	[22859] = 3, -- Mortal Cleave
	[12294] = 3, -- Mortal Strike (Warriors)
	[24573] = 3, -- Mortal Strike (Broodlord Lashlayer)
	[43441] = 3, -- Mortal Strike (Hex Lord Malacrass)
	[44268] = 3, -- Mortal Strike (Warlord Salaris)
	[25646] = 3, -- Mortal Wound -- Also 31464, 36814, 54378
	[69674] = 3, -- Mutated Infection
	[28776] = 3, -- Necrotic Poison
	[60626] = 3, -- Necrotic Strike
	[30423] = 3, -- Nether Portal - Dominance
	[68391] = 3, -- Permafrost
	[59525] = 3, -- Ray of Pain
	[45885] = 3, -- Shadow Spike
	[54525] = 3, -- Shroud of Darkness
	[35189] = 3, -- Solar Strike
	[32315] = 3, -- Soul Strike
	[70588] = 3, -- Suppression
	[32858] = 3, -- Touch of the Forgotten
	[7068]  = 3, -- Veil of Shadow (Nefarian)
	[28440] = 3, -- Veil of Shadow (Dread Creeper)
	[69633] = 3, -- Veil of Shadow (Spectral Warden)
	[13218] = 3, -- Wound Poison (Rogues)
	[43461] = 3, -- Wound Poison (Hex Lord Malacrass)
	[13222] = 3, -- Wound Poison II
	[13223] = 3, -- Wound Poison III
	[13224] = 3, -- Wound Poison IV
	[27189] = 3, -- Wound Poison V
	[57974] = 3, -- Wound Poison VI
	[57975] = 3, -- Wound Poison VII
	[52771] = 3, -- Wounding Strike
	[44534] = 3, -- Wretched Strike

	[41292] = 3, -- Aura of Suffering
	[45996] = 3, -- Darkness
	[59513] = 3, -- Embrace of the Vampyr
	[30843] = 3, -- Enfeeble
	[55593] = 3, -- Necrotic Aura
}) end
--]]
------------------------------------------------------------------------
-- Raid Encounters
--[[
addAuras({
	-- Ulduar
	[62717] = 3, -- Ignis the Furnace Master ==> Slag Pot
	[63024] = 3, -- XT-002 Deconstructor ==> Gravity Bomb
	[63018] = 3, -- XT-002 Deconstructor ==> Searing Light
	[61888] = 3, -- Steelbreaker => Overwhelming Power
	[63355] = 3, -- Kologarn ==> Crunch Armor
	[64290] = 3, -- Kologarn ==> Stone Grip
	[64396] = 3, -- Auriaya ==> Guardian Swarm
	[64666] = 3, -- Auriaya ==> Savage Pounce
	[62532] = 3, -- Freya ==> Conservator's Grip
--	[62310] = 3, -- Freya ==> Impale
	[62283] = 3, -- Freya ==> Iron Roots
	[61969] = 3, -- Hodir ==> Flash Freeze
	[62130] = 3, -- Thorim ==> Unbalancing Strike
	[62997] = 3, -- Mimiron ==> Plasma Blast
	[63276] = 3, -- General Vezax ==> Mark of the Faceless
	[63802] = 3, -- Yogg-Saron ==> Brain Link
	[63830] = 3, -- Yogg-Saron ==> Malady of the Mind
	[63134] = 3, -- Yogg-Saron ==> Sara's Blessing
	[64125] = 3, -- Yogg-Saron ==> Squeeze
	[64412] = 3, -- Algalon the Observer ==> Phase Punch

	-- Trial of the Crusader
	[66331] = 3, -- Gormok the Impaler ==> Impale
	[66406] = 3, -- Gormok the Impaler ==> Snobolled!
	[66823] = 3, -- Acidmaw ==> Paralytic Toxin
	[66869] = 3, -- Dreadscale ==> Burning Bile
	[66689] = 3, -- Icehowl ==> Arctic Breath
	[66237] = 3, -- Lord Jaraxxus ==> Incinerate Flesh
	[68124] = 3, -- Lord Jaraxxus ==> Legion Flame
	[66012] = 3, -- Anub'arak ==> Freezing Slash
	[67700] = 3, -- Anub'arak ==> Penetrating Cold

	-- Icecrown Citadel
	[69065] = 3, -- Lord Marrowgar ==> Impaled
	[72385] = 3, -- Deathbringer Saurfang ==> Boiling Blood
	[72293] = 3, -- Deathbringer Saurfang ==> Mark of the Fallen Champion
	[72410] = 3, -- Deathbringer Saurfang ==> Rune of Blood
	[69279] = 3, -- Festergut ==> Gas Spore
	[72219] = 3, -- Festergut ==> Gastric Bloat
	[72103] = 3, -- Festergut ==> Inoculated
	[69674] = 3, -- Rotface ==> Mutated Infection
	[70672] = 3, -- Professor Putricide ==> Gaseous Bloat
	[72672] = 3, -- Professor Putricide ==> Mutated Plague
	[70447] = 3, -- Professor Putricide ==> Volatile Ooze Adhesive
	[71510] = 3, -- Blood-Queen Lana'thel ==> Blood Mirror
	[70867] = 3, -- Blood-Queen Lana'thel ==> Essence of the Blood Queen
	[70877] = 3, -- Blood-Queen Lana'thel ==> Frenzied Bloodthirst
	[71340] = 3, -- Blood-Queen Lana'thel ==> Pact of the Darkfallen
	[71265] = 3, -- Blood-Queen Lana'thel ==> Swarming Shadows
	[70923] = 3, -- Blood-Queen Lana'thel ==> Uncontrollable Frenzy
	[70873] = 3, -- Valithria Dreamwalker ==> Emerald Vigor
	[70106] = 3, -- Sindragosa ==> Chilled to the Bone
	[70126] = 3, -- Sindragosa ==> Frost Beacon
	[70157] = 3, -- Sindragosa ==> Ice Tomb
	[69766] = 3, -- Sindragosa ==> Instability
	[70127] = 3, -- Sindragosa ==> Mystic Buffet
	[68980] = 3, -- The Lich King ==> Harvest Soul
	[74322] = 3, -- The Lich King ==> Harvested Soul
	[70337] = 3, -- The Lich King ==> Necrotic Plague
	[74074] = 3, -- The Lich King ==> Plague Siphon
	[69409] = 3, -- The Lich King ==> Soul Reaper

	-- Ruby Sanctum
	[74562] = 3, -- Halion ==> Fiery Consumption
	[74792] = 3, -- Halion ==> Soul Consumption
}) end
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
