--[[--------------------------------------------------------------------
	oUF_Phanx
	A layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	Copyright © 2009–2010 Phanx. See README for license terms.
------------------------------------------------------------------------
	This file provides custom aura filtering and icon remapping.

	Currently, there is complete support only for druids, shamans, and
	paladins, but I'd gladly accept aura lists for other classes. :)
----------------------------------------------------------------------]]

local OUF_PHANX, oUF_Phanx = ...
local myClass = select(2, UnitClass("player"))
local auraList

--
-- true  : cast by anyone, use actual icon
-- string : cast by anyone, use specified icon
-- false : cast by unit, use actual icon
--

------------------------------------------------------------------------

if myClass == "DRUID" then auraList = {
	[GetSpellInfo(53692)] = false, -- Lifebloom
	[GetSpellInfo(8936)]  = false, -- Regrowth
	[GetSpellInfo(774)]   = false, -- Rejuvenation
	[GetSpellInfo(48438)] = false, -- Wild Growth

	[GetSpellInfo(99)]    = true,  -- Demoralizing Roar
	[GetSpellInfo(770)]   = true,  -- Faerie Fire
	[GetSpellInfo(16857)] = true,  -- Faerie Fire (Feral)
	[GetSpellInfo(6795)]  = true,  -- Growl
	[GetSpellInfo(5570)]  = false, -- Insect Swarm
	[GetSpellInfo(33745)] = false, -- Lacerate
	[GetSpellInfo(22570)] = true,  -- Maim
	[GetSpellInfo(8921)]  = false, -- Moonfire
	[GetSpellInfo(33878)] = true,  -- Mangle (Bear)
	[GetSpellInfo(33876)] = true,  -- Mangle (Cat)
	[GetSpellInfo(59881)] = true,  -- Pounce Stun
	[GetSpellInfo(59881)] = false, -- Rake
	[GetSpellInfo(1079)]  = false, -- Rip
	[GetSpellInfo(52610)] = false, -- Savage Roar

	[GetSpellInfo(702)]   = true, -- Curse of Weakness
	[GetSpellInfo(56222)] = "Ability_Physical_Taunt", -- Dark Command
	[GetSpellInfo(57603)] = "Ability_Physical_Taunt", -- Death Grip
	[GetSpellInfo(62124)] = "Ability_Physical_Taunt", -- Hand of Reckoning
	[GetSpellInfo(31790)] = "Ability_Physical_Taunt", -- Righteous Defense
	[GetSpellInfo(355)]   = "Ability_Physical_Taunt", -- Taunt
	[GetSpellInfo(1160)]  = "Ability_Druid_DemoralizingRoar", -- Demoralizing Shout
	[GetSpellInfo(26016)] = "Ability_Druid_DemoralizingRoar", -- Vindication
	[GetSpellInfo(46857)] = "Ability_Druid_Mangle2", -- Trauma
} end

------------------------------------------------------------------------

if myClass == "PALADIN" then auraList = {
	[GetSpellInfo(53563)] = true,  -- Beacon of Light
	[GetSpellInfo(20217)] = true,  -- Blessing of Kings
	[GetSpellInfo(19740)] = true,  -- Blessing of Might
	[GetSpellInfo(20911)] = true,  -- Blessing of Sanctuary
	[GetSpellInfo(19742)] = true,  -- Blessing of Wisdom
	[GetSpellInfo(19752)] = true,  -- Divine Intervention
	[GetSpellInfo(498)]   = true,  -- Divine Protection
	[GetSpellInfo(64205)] = true,  -- Divine Sacrifice
	[GetSpellInfo(642)]   = true,  -- Divine Shield
	[GetSpellInfo(25898)] = true,  -- Greater Blessing of Kings
	[GetSpellInfo(25782)] = true,  -- Greater Blessing of Might
	[GetSpellInfo(25899)] = true,  -- Greater Blessing of Sanctuary
	[GetSpellInfo(25894)] = true,  -- Greater Blessing of Wisdom
	[GetSpellInfo(1044)]  = true,  -- Hand of Freedom
	[GetSpellInfo(1022)]  = true,  -- Hand of Protection
	[GetSpellInfo(6940)]  = true,  -- Hand of Sacrifice
	[GetSpellInfo(1038)]  = true,  -- Hand of Salvation
	[GetSpellInfo(53651)] = true,  -- Light's Beacon
	[GetSpellInfo(53601)] = true,  -- Sacred Shield
--	[GetSpellInfo(58597)] = true,  -- Sacred Shield (proc)

	[GetSpellInfo(31935)] = true,  -- Avenger's Shield
	[GetSpellInfo(53742)] = false, -- Blood Corruption
	[GetSpellInfo(853)]   = true,  -- Hammer of Justice
	[GetSpellInfo(62124)] = true,  -- Hand of Reckoning
	[GetSpellInfo(2812)]  = true,  -- Holy Wrath
	[GetSpellInfo(20184)] = true,  -- Judgement of Justice
	[GetSpellInfo(20267)] = true,  -- Judgement of Light
	[GetSpellInfo(20186)] = true,  -- Judgement of Wisdom
	[GetSpellInfo(20066)] = true,  -- Repentance
	[GetSpellInfo(31790)] = true,  -- Righteous Defense
	[GetSpellInfo(10326)] = true,  -- Turn Evil
	[GetSpellInfo(26016)] = true,  -- Vindication

	[GetSpellInfo(56222)] = "Spell_Holy_UnyieldingFaith", -- Dark Command
	[GetSpellInfo(57603)] = "Spell_Holy_UnyieldingFaith", -- Death Grip
	[GetSpellInfo(6795)]  = "Spell_Holy_UnyieldingFaith", -- Growl
	[GetSpellInfo(355)]   = "Spell_Holy_UnyieldingFaith", -- Taunt
	[GetSpellInfo(99)]    = "Spell_Holy_Vindication", -- Demoralizing Roar
	[GetSpellInfo(1160)]  = "Spell_Holy_Vindication", -- Demoralizing Shout
} end

------------------------------------------------------------------------

if myClass == "SHAMAN" then auraList = {
--	[GetSpellInfo(70809)] = false, -- Chained Heal (Resto T10 4-piece bonus)
	[GetSpellInfo(974)]   = true,  -- Earth Shield
--	[GetSpellInfo(51945)] = false, -- Earthliving
	[GetSpellInfo(61295)] = false, -- Riptide
	[GetSpellInfo(131)]   = true,  -- Water Breathing
	[GetSpellInfo(546)]   = true,  -- Water Walking

	[GetSpellInfo(8042)]  = true,  -- Earth Shock
	[GetSpellInfo(8050)]  = false, -- Flame Shock
	[GetSpellInfo(8056)]  = true,  -- Frost Shock
	[GetSpellInfo(8034)]  = true,  -- Frostbrand Attack
	[GetSpellInfo(51514)] = true,  -- Hex
	[GetSpellInfo(17364)] = false, -- Stormstrike

	[GetSpellInfo(5697)]  = true,  -- Unending Breath
} end

------------------------------------------------------------------------

if not auraList then return end

------------------------------------------------------------------------

-- Naxxramas

-- Eye of Eternity

-- Obsidian Sanctum

-- Ulduar

-- Trial of the Crusader
auraList[GetSpellInfo(66331)] = true -- Gormok the Impaler -> Impale
auraList[GetSpellInfo(66406)] = true -- Gormok the Impaler -> Snobolled!
auraList[GetSpellInfo(66823)] = true -- Acidmaw -> Paralytic Toxin
auraList[GetSpellInfo(66869)] = true -- Dreadscale -> Burning Bile
auraList[GetSpellInfo(66689)] = true -- Icehowl -> Arctic Breath
auraList[GetSpellInfo(66237)] = true -- Lord Jaraxxus -> Incinerate Flesh
auraList[GetSpellInfo(68124)] = true -- Lord Jaraxxus -> Legion Flame
auraList[GetSpellInfo(67108)] = true -- Lord Jaraxxus -> Nether Power
auraList[GetSpellInfo(65858)] = true -- Fjola Lightbane -> Shield of Lights
auraList[GetSpellInfo(65874)] = true -- Eydis Darkbane -> Shield of Darkness
auraList[GetSpellInfo(66012)] = true -- Anub'arak -> Freezing Slash
auraList[GetSpellInfo(67700)] = true -- Anub'arak -> Penetrating Cold

-- Icecrown Citadel
auraList[GetSpellInfo(69065)] = true -- Lord Marrowgar -> Impaled
auraList[GetSpellInfo(72385)] = true -- Deathbringer Saurfang -> Boiling Blood
auraList[GetSpellInfo(72293)] = true -- Deathbringer Saurfang -> Mark of the Fallen Champion
auraList[GetSpellInfo(72410)] = true -- Deathbringer Saurfang -> Rune of Blood
auraList[GetSpellInfo(69279)] = true -- Festergut -> Gas Spore
auraList[GetSpellInfo(72219)] = true -- Festergut -> Gastric Bloat
auraList[GetSpellInfo(72103)] = true -- Festergut -> Inoculated
auraList[GetSpellInfo(69674)] = true -- Rotface -> Mutated Infection
auraList[GetSpellInfo(70672)] = true -- Professor Putricide -> Gaseous Bloat
auraList[GetSpellInfo(72672)] = true -- Professor Putricide -> Mutated Plague
auraList[GetSpellInfo(70447)] = true -- Professor Putricide -> Volatile Ooze Adhesive
auraList[GetSpellInfo(71510)] = true -- Blood-Queen Lana'thel -> Blood Mirror
auraList[GetSpellInfo(70867)] = true -- Blood-Queen Lana'thel -> Essence of the Blood Queen
auraList[GetSpellInfo(70877)] = true -- Blood-Queen Lana'thel -> Frenzied Bloodthirst
auraList[GetSpellInfo(71340)] = true -- Blood-Queen Lana'thel -> Pact of the Darkfallen
auraList[GetSpellInfo(71265)] = true -- Blood-Queen Lana'thel -> Swarming Shadows
auraList[GetSpellInfo(70923)] = true -- Blood-Queen Lana'thel -> Uncontrollable Frenzy
auraList[GetSpellInfo(70873)] = true -- Valithria Dreamwalker -> Emerald Vigor
auraList[GetSpellInfo(70106)] = true -- Sindragosa -> Chilled to the Bone
auraList[GetSpellInfo(70126)] = true -- Sindragosa -> Frost Beacon
auraList[GetSpellInfo(70157)] = true -- Sindragosa -> Ice Tomb
auraList[GetSpellInfo(69766)] = true -- Sindragosa -> Instability
auraList[GetSpellInfo(70127)] = true -- Sindragosa -> Mystic Buffet
auraList[GetSpellInfo(68980)] = true -- The Lich King -> Harvest Soul
auraList[GetSpellInfo(74322)] = true -- The Lich King -> Harvested Soul
auraList[GetSpellInfo(70337)] = true -- The Lich King -> Necrotic Plague
auraList[GetSpellInfo(74074)] = true -- The Lich King -> Plague Siphon
auraList[GetSpellInfo(69409)] = true -- The Lich King -> Soul Reaper

-- Ruby Sanctum
auraList[GetSpellInfo(74828)] = true -- Halion -> Corporeality
auraList[GetSpellInfo(74562)] = true -- Halion -> Fiery Consumption
auraList[GetSpellInfo(74792)] = true -- Halion -> Soul Consumption

------------------------------------------------------------------------

local auraIconMap = { }

for spell, icon in pairs(auraList) do
	if type(icon) == "string" then
		auraIconMap[spell] = icon
	end
end

oUF_Phanx.auraIconMap = auraIconMap

------------------------------------------------------------------------

local playerUnits = {
	player = true,
	pet = true,
	vehicle = true,
}

oUF_Phanx.CustomAuraFilter = auraList and function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)
	local status = auraList[name]

	if type(status) == "string" or status == true then
		return true
	elseif status == false then
		return playerUnits[caster]
	end
end

------------------------------------------------------------------------