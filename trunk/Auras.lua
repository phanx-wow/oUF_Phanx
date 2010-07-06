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

local blacklist = {
	["Bested Darnassus"] = true,
	["Bested Gnomeregan"] = true,
	["Bested Ironforge"] = true,
	["Bested Orgrimmar"] = true,
	["Bested Sen'jin"] = true,
	["Bested Silvermoon City"] = true,
	["Bested Stormwind"] = true,
	["Bested the Exodar"] = true,
	["Bested the Undercity"] = true,
	["Bested Thunder Bluff"] = true,

	["Chill of the Throne"] = true,

	["Exhaustion"] = true,
	["Sated"] = true,
}

------------------------------------------------------------------------

local OUF_PHANX, oUF_Phanx = ...
local myClass = select(2, UnitClass("player"))
local whitelist

------------------------------------------------------------------------

if myClass == "DRUID" then whitelist = {
	[GetSpellInfo(99)]    = true,  -- Demoralizing Roar
	[GetSpellInfo(770)]   = true,  -- Faerie Fire
	[GetSpellInfo(16857)] = true,  -- Faerie Fire (Feral)
	[GetSpellInfo(6795)]  = true,  -- Growl
	[GetSpellInfo(22570)] = true,  -- Maim
	[GetSpellInfo(33878)] = true,  -- Mangle (Bear)
	[GetSpellInfo(33876)] = true,  -- Mangle (Cat)
	[GetSpellInfo(59881)] = true,  -- Pounce Stun

	[GetSpellInfo(702)]   = true, -- Curse of Weakness
	[GetSpellInfo(56222)] = "Ability_Physical_Taunt", -- Dark Command
	[GetSpellInfo(57603)] = "Ability_Physical_Taunt", -- Death Grip
	[GetSpellInfo(62124)] = "Ability_Physical_Taunt", -- Hand of Reckoning
	[GetSpellInfo(31790)] = "Ability_Physical_Taunt", -- Righteous Defense
	[GetSpellInfo(355)]   = "Ability_Physical_Taunt", -- Taunt
	[GetSpellInfo(1160)]  = "Ability_Druid_DemoralizingRoar", -- Demoralizing Shout
	[GetSpellInfo(26016)] = "Ability_Druid_DemoralizingRoar", -- Vindication
	[GetSpellInfo(46857)] = "Ability_Druid_Mangle2", -- Trauma

--	[GetSpellInfo(53692)] = false, -- Lifebloom
--	[GetSpellInfo(8936)]  = false, -- Regrowth
--	[GetSpellInfo(774)]   = false, -- Rejuvenation
--	[GetSpellInfo(52610)] = false, -- Savage Roar
--	[GetSpellInfo(48438)] = false, -- Wild Growth

--	[GetSpellInfo(5570)]  = false, -- Insect Swarm
--	[GetSpellInfo(33745)] = false, -- Lacerate
--	[GetSpellInfo(8921)]  = false, -- Moonfire
--	[GetSpellInfo(59881)] = false, -- Rake
--	[GetSpellInfo(1079)]  = false, -- Rip
} end

------------------------------------------------------------------------

if myClass == "PALADIN" then whitelist = {
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

--	[GetSpellInfo(53742)] = false, -- Blood Corruption
} end

------------------------------------------------------------------------

if myClass == "SHAMAN" then whitelist = {
	[GetSpellInfo(974)]   = true,  -- Earth Shield
	[GetSpellInfo(131)]   = true,  -- Water Breathing
	[GetSpellInfo(546)]   = true,  -- Water Walking

	[GetSpellInfo(8042)]  = true,  -- Earth Shock
	[GetSpellInfo(8056)]  = true,  -- Frost Shock
	[GetSpellInfo(8034)]  = true,  -- Frostbrand Attack
	[GetSpellInfo(51514)] = true,  -- Hex

	[GetSpellInfo(5697)]  = true,  -- Unending Breath

--	[GetSpellInfo(70809)] = false, -- Chained Heal (Resto T10 4-piece bonus)
--	[GetSpellInfo(51945)] = false, -- Earthliving
--	[GetSpellInfo(61295)] = false, -- Riptide

--	[GetSpellInfo(8050)]  = false, -- Flame Shock
--	[GetSpellInfo(17364)] = false, -- Stormstrike
} end

------------------------------------------------------------------------

if whitelist then
	-- Naxxramas

	-- Eye of Eternity

	-- Obsidian Sanctum

	-- Ulduar

	-- Trial of the Crusader
	whitelist[GetSpellInfo(66331)] = true -- Gormok the Impaler -> Impale
	whitelist[GetSpellInfo(66406)] = true -- Gormok the Impaler -> Snobolled!
	whitelist[GetSpellInfo(66823)] = true -- Acidmaw -> Paralytic Toxin
	whitelist[GetSpellInfo(66869)] = true -- Dreadscale -> Burning Bile
	whitelist[GetSpellInfo(66689)] = true -- Icehowl -> Arctic Breath
	whitelist[GetSpellInfo(66237)] = true -- Lord Jaraxxus -> Incinerate Flesh
	whitelist[GetSpellInfo(68124)] = true -- Lord Jaraxxus -> Legion Flame
	whitelist[GetSpellInfo(66012)] = true -- Anub'arak -> Freezing Slash
	whitelist[GetSpellInfo(67700)] = true -- Anub'arak -> Penetrating Cold

	-- Icecrown Citadel
	whitelist[GetSpellInfo(69065)] = true -- Lord Marrowgar -> Impaled
	whitelist[GetSpellInfo(72385)] = true -- Deathbringer Saurfang -> Boiling Blood
	whitelist[GetSpellInfo(72293)] = true -- Deathbringer Saurfang -> Mark of the Fallen Champion
	whitelist[GetSpellInfo(72410)] = true -- Deathbringer Saurfang -> Rune of Blood
	whitelist[GetSpellInfo(69279)] = true -- Festergut -> Gas Spore
	whitelist[GetSpellInfo(72219)] = true -- Festergut -> Gastric Bloat
	whitelist[GetSpellInfo(72103)] = true -- Festergut -> Inoculated
	whitelist[GetSpellInfo(69674)] = true -- Rotface -> Mutated Infection
	whitelist[GetSpellInfo(70672)] = true -- Professor Putricide -> Gaseous Bloat
	whitelist[GetSpellInfo(72672)] = true -- Professor Putricide -> Mutated Plague
	whitelist[GetSpellInfo(70447)] = true -- Professor Putricide -> Volatile Ooze Adhesive
	whitelist[GetSpellInfo(71510)] = true -- Blood-Queen Lana'thel -> Blood Mirror
	whitelist[GetSpellInfo(70867)] = true -- Blood-Queen Lana'thel -> Essence of the Blood Queen
	whitelist[GetSpellInfo(70877)] = true -- Blood-Queen Lana'thel -> Frenzied Bloodthirst
	whitelist[GetSpellInfo(71340)] = true -- Blood-Queen Lana'thel -> Pact of the Darkfallen
	whitelist[GetSpellInfo(71265)] = true -- Blood-Queen Lana'thel -> Swarming Shadows
	whitelist[GetSpellInfo(70923)] = true -- Blood-Queen Lana'thel -> Uncontrollable Frenzy
	whitelist[GetSpellInfo(70873)] = true -- Valithria Dreamwalker -> Emerald Vigor
	whitelist[GetSpellInfo(70106)] = true -- Sindragosa -> Chilled to the Bone
	whitelist[GetSpellInfo(70126)] = true -- Sindragosa -> Frost Beacon
	whitelist[GetSpellInfo(70157)] = true -- Sindragosa -> Ice Tomb
	whitelist[GetSpellInfo(69766)] = true -- Sindragosa -> Instability
	whitelist[GetSpellInfo(70127)] = true -- Sindragosa -> Mystic Buffet
	whitelist[GetSpellInfo(68980)] = true -- The Lich King -> Harvest Soul
	whitelist[GetSpellInfo(74322)] = true -- The Lich King -> Harvested Soul
	whitelist[GetSpellInfo(70337)] = true -- The Lich King -> Necrotic Plague
	whitelist[GetSpellInfo(74074)] = true -- The Lich King -> Plague Siphon
	whitelist[GetSpellInfo(69409)] = true -- The Lich King -> Soul Reaper

	-- Ruby Sanctum
	whitelist[GetSpellInfo(74562)] = true -- Halion -> Fiery Consumption
	whitelist[GetSpellInfo(74792)] = true -- Halion -> Soul Consumption
end

------------------------------------------------------------------------

local playerUnits = {
	player = true,
	pet = true,
	vehicle = true,
}

if whitelist then
	oUF_Phanx.CustomAuraFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)
		return (not blacklist[name]) and (whitelist[name] or caster == unit or (playerUnits[caster] and duration > 0))
	end
else
	oUF_Phanx.CustomAuraFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)
		return not blacklist[name]
	end
end

------------------------------------------------------------------------

if whitelist then
	oUF_Phanx.auraIconMap = { }

	for spell, icon in pairs(whitelist) do
		if type(icon) == "string" then
			oUF_Phanx.auraIconMap[spell] = icon
		end
	end
end

------------------------------------------------------------------------