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
-- true   : cast by anyone, use actual icon
-- string : cast by anyone, use specified icon
-- false  : cast by unit, use actual icon
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