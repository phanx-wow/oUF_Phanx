--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
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
	-- druids have Faerie Fire, they don't need to see the generic one too
	auras[113746] = 1 -- Weakened Armor (druid, hunter raptor, hunter tallstrider, rogue, warrior)
end

------------------------------------------------------------------------
--	Weakened Blows

if playerClass == "DEATHKNIGHT" or playerClass == "MONK" or playerClass == "PALADIN" or playerClass == "SHAMAN" or playerClass == "WARLOCK" or playerClass == "WARRIOR" then
	-- druids have Thrash, they don't need to see the generic one too
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
--	Spell-locked -- NOT UPDATED FOR WOW5

if PVP_MODE then
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
end

------------------------------------------------------------------------
--	Druid

if playerClass == "DRUID" then
	auras[88212]  = 4 -- Barkskin
	auras[106952] = 4 -- Berserk
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
	auras[62606]  = 4 -- Savage Defense
	auras[52610]  = 4 -- Savage Roar
	auras[93400]  = 4 -- Shooting Stars
	auras[114108] = 2 -- Soul of the Forest (resto)
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
	auras[744]    = 2 -- Rejuvenation
	auras[77761]  = 3 -- Stampeding Roar (bear)
	auras[77764]  = 3 -- Stampeding Roar (cat)
	auras[106898] = 3 -- Stampeding Roar
	auras[48438]  = 2 -- Wild Growth
end

------------------------------------------------------------------------
--	Hunter

if playerClass == "HUNTER" then
end

------------------------------------------------------------------------
--	Mage

if playerClass == "MAGE" then
end

------------------------------------------------------------------------
--	Monk

if playerClass == "MONK" then
	auras[126050] = 4 -- Adaptation
	auras[122278] = 4 -- Dampen Harm
	auras[122465] = 4 -- Dematerialize
	auras[122783] = 4 -- Diffuse Magic
	auras[128939] = 4 -- Elusive Brew (stack)
	auras[115308] = 4 -- Elusive Brew (consume)
	auras[115288] = 4 -- Energizing Brew
	auras[115203] = 4 -- Fortifying Brew
	auras[115295] = 4 -- Guard
	auras[124458] = 4 -- Healing Sphere (count)
	auras[115867] = 4 -- Mana Tea (stack)
	auras[119085] = 4 -- Momentum
	auras[124968] = 4 -- Retreat
	auras[127722] = 4 -- Serpent's Zeal
	auras[125359] = 4 -- Tiger Power
	auras[120273] = 4 -- Tiger Strikes
	auras[116841] = 4 -- Tiger's Lust
	auras[125195] = 4 -- Tigereye Brew (stack)
	auras[116740] = 4 -- Tigereye Brew (consume)
	auras[122470] = 4 -- Touch of Karma
	auras[118674] = 4 -- Vital Mists

	auras[128531] = 2 -- Blackout Kick
	auras[123393] = 1 -- Breath of Fire (disorient)
	auras[123725] = 2 -- Breath of Fire (dot)
	auras[119392] = 1 -- Charging Ox Wave
	auras[122242] = 1 -- Clash (stun) -- NEEDS CHECK
	auras[126451] = 1 -- Clash (stun) -- NEEDS CHECK
	auras[128846] = 1 -- Clash (stun) -- NEEDS CHECK
	auras[125647] = 2 -- Crackling Jade Lightning (+damage)
	auras[116095] = 1 -- Disable
	auras[116330] = 1 -- Dizzying Haze -- NEEDS CHECK
	auras[123727] = 1 -- Dizzying Haze -- NEEDS CHECK
	auras[123586] = 4 -- Flying Serpent Kick
	auras[117368] = 1 -- Grapple Weapon
	auras[118585] = 1 -- Leer of the Ox
	auras[119381] = 1 -- Leg Sweep
	auras[115078] = 1 -- Paralysis
	auras[118635] = 1 -- Provoke -- NEEDS CHECK
	auras[116189] = 1 -- Provoke -- NEEDS CHECK
	auras[130320] = 2 -- Rising Sun Kick
	auras[116847] = 2 -- Rushing Jade Wind
	auras[116709] = 1 -- Spear Hand Strike
	auras[123407] = 1 -- Spinning Fire Blossom

	auras[124682] = 2 -- Enveloping Mist
	auras[116849] = 3 -- Life Cocoon
	auras[119611] = 2 -- Renewing Mist
	auras[115175] = 2 -- Soothing Mist
	auras[124081] = 2 -- Zen Sphere
end

------------------------------------------------------------------------
--	Paladin

if playerClass == "PALADIN" then
end

------------------------------------------------------------------------
--	Priest

if playerClass == "PRIEST" then
end

------------------------------------------------------------------------
--	Rogue

if playerClass == "ROGUE" then
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
end

------------------------------------------------------------------------
--	Warrior

if playerClass == "WARRIOR" then
end

------------------------------------------------------------------------
-- Racials

if playerRace == "Draenei" then
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
	pet = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3)
		return caster and unitIsPlayer[caster] and auras[spellID] == 2
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
			return isBossDebuff or caster and UnitIsUnit(caster, "vehicle")
		end
	end,
	party = function(self, unit, iconFrame, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3)
		local v = auras[spellID]
		return v and v < 4
	end,
}

ns.AuraList = auras