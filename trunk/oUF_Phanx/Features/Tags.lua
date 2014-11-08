--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx

	Please DO NOT upload this addon to other websites, or post modified
	versions of it. However, you are welcome to include a copy of it
	WITHOUT CHANGES in compilations posted on Curse and/or WoWInterface.
	You are also welcome to use any/all of its code in your own addon, as
	long as you do not use my name or the name of this addon ANYWHERE in
	your addon, including its name, outside of an optional attribution.
----------------------------------------------------------------------]]

local _, ns = ...

local GetLootMethod, IsResting, UnitAffectingCombat, UnitBuff, UnitClass, UnitInRaid, UnitIsConnected, UnitIsDeadOrGhost, UnitIsEnemy, UnitIsGroupAssistant, UnitIsGroupLeader, UnitIsPlayer, UnitIsTapped, UnitIsTappedByPlayer, UnitIsUnit, UnitPowerType, UnitReaction = GetLootMethod, IsResting, UnitAffectingCombat, UnitBuff, UnitClass, UnitInRaid, UnitIsConnected, UnitIsDeadOrGhost, UnitIsEnemy, UnitIsGroupAssistant, UnitIsGroupLeader, UnitIsPlayer, UnitIsTapped, UnitIsTappedByPlayer, UnitIsUnit, UnitPowerType, UnitReaction

------------------------------------------------------------------------
--	Colors

oUF.Tags.Events["unitcolor"] = "UNIT_HEALTH UNIT_CLASSIFICATION_CHANGED UNIT_CONNECTION UNIT_FACTION UNIT_REACTION"
oUF.Tags.Methods["unitcolor"] = function(unit)
	local color
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		color = oUF.colors.disconnected
	elseif UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = oUF.colors.class[class]
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) then
		color = oUF.colors.tapped
	elseif UnitIsEnemy(unit, "player") then
		color = oUF.colors.reaction[1]
	else
		color = oUF.colors.reaction[UnitReaction(unit, "player") or 5]
	end
	return color and ("|cff%02x%02x%02x"):format(color[1] * 255, color[2] * 255, color[3] * 255) or "|cffffffff"
end

oUF.Tags.Events["powercolor"] = "UNIT_DISPLAYPOWER"
oUF.Tags.Methods["powercolor"] = function(unit)
	local _, type = UnitPowerType(unit)
	local color = ns.colors.power[type] or ns.colors.power.FUEL
	return format("|cff%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)
end

------------------------------------------------------------------------
--	Icons

oUF.Tags.Events["combaticon"] = "PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED"
oUF.Tags.SharedEvents["PLAYER_REGEN_DISABLED"] = true
oUF.Tags.SharedEvents["PLAYER_REGEN_ENABLED"] = true
oUF.Tags.Methods["combaticon"] = function(unit)
	if unit == "player" and UnitAffectingCombat("player") then
		return [[|TInterface\CharacterFrame\UI-StateIcon:0:0:0:0:64:64:37:58:5:26|t]]
	end
end

oUF.Tags.Events["leadericon"] = "GROUP_ROSTER_UPDATE"
oUF.Tags.SharedEvents["GROUP_ROSTER_UPDATE"] = true
oUF.Tags.Methods["leadericon"] = function(unit)
	if UnitIsGroupLeader(unit) then
		return [[|TInterface\GroupFrame\UI-Group-LeaderIcon:0|t]]
	elseif UnitInRaid(unit) and UnitIsGroupAssistant(unit) then
		return [[|TInterface\GroupFrame\UI-Group-AssistantIcon:0|t]]
	end
end

oUF.Tags.Events["mastericon"] = "PARTY_LOOT_METHOD_CHANGED GROUP_ROSTER_UPDATE"
oUF.Tags.SharedEvents["PARTY_LOOT_METHOD_CHANGED"] = true
oUF.Tags.SharedEvents["GROUP_ROSTER_UPDATE"] = true
oUF.Tags.Methods["mastericon"] = function(unit)
	local method, pid, rid = GetLootMethod()
	if method ~= "master" then return end
	local munit
	if pid then
		if pid == 0 then
			munit = "player"
		else
			munit = "party" .. pid
		end
	elseif rid then
		munit = "raid" .. rid
	end
	if munit and UnitIsUnit(munit, unit) then
		return [[|TInterface\GroupFrame\UI-Group-MasterLooter:0:0:0:2|t]]
	end
end

oUF.Tags.Events["restingicon"] = "PLAYER_UPDATE_RESTING"
oUF.Tags.SharedEvents["PLAYER_UPDATE_RESTING"] = true
oUF.Tags.Methods["restingicon"] = function(unit)
	if unit == "player" and IsResting() then
		return [[|TInterface\CharacterFrame\UI-StateIcon:0:0:0:-6:64:64:28:6:6:28|t]]
	end
end

oUF.Tags.Methods["battlepeticon"] = function(unit)
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		local petType = UnitBattlePetType(unit)
		return [[|TInterface\TargetingFrame\PetBadge-]] .. PET_TYPE_SUFFIX[petType]
	end
end

------------------------------------------------------------------------
--	Threat

do
	local colors = {
		[0] = "|cffffffff",
		[1] = "|cffffff33",
		[2] = "|cffff9933",
		[3] = "|cffff3333",
	}
	oUF.Tags.Events["threatpct"] = "UNIT_THREAT_LIST_UPDATE"
	oUF.Tags.Methods["threatpct"] = function(unit)
		local isTanking, status, percentage, rawPercentage = UnitDetailedThreatSituation("player", unit)
		local pct = rawPercentage
		if isTanking then
			pct = UnitThreatPercentageOfLead("player", unit)
		end
		if pct and pct > 0 and pct < 300 then
			return format("%s%d%%", colors[status] or colors[0], pct + 0.5)
		end
	end
end

------------------------------------------------------------------------
--	Buffs

do
	local EVANGELISM = GetSpellInfo(81661) -- 81660 for rank 1
	local DARK_EVANGELISM = GetSpellInfo(87118) -- 87117 for rank 1
	oUF.Tags.Events["evangelism"] = "UNIT_AURA"
	oUF.Tags.Methods["evangelism"] = function(unit)
		if unit == "player" then
			local name, _, icon, count = UnitBuff("player", EVANGELISM)
			if name then return count end

			name, _, icon, count = UnitBuff("player", DARK_EVANGELISM)
			return name and count
		end
	end
end

do
	local MAELSTROM_WEAPON = GetSpellInfo(53817)
	oUF.Tags.Events["maelstrom"] = "UNIT_AURA"
	oUF.Tags.Methods["maelstrom"] = function(unit)
		if unit == "player" then
			local name, _, icon, count = UnitBuff("player", MAELSTROM_WEAPON)
			return name and count
		end
	end
end

do
	local EARTH_SHIELD = GetSpellInfo(974)
	local LIGHTNING_SHIELD = GetSpellInfo(324)
	local WATER_SHIELD = GetSpellInfo(52127)

	local EARTH_TEXT = setmetatable({}, { __index = function(t,i)
		return format("|cffa7c466%d|r", i)
	end })
	local LIGHTNING_TEXT = setmetatable({}, { __index = function(t,i)
		return format("|cff7f97f7%d|r", i)
	end })
	local WATER_TEXT = setmetatable({}, { __index = function(t,i)
		return format("|cff7cbdff%d|r", i)
	end })

	oUF.Tags.Events["elementalshield"] = "UNIT_AURA"
	oUF.Tags.Methods["elementalshield"] = function(unit)
		local name, _, icon, count = UnitBuff(unit, EARTH_SHIELD, nil, "PLAYER")
		if name then
			return EARTH_TEXT[count]
		end
		if unit == "player" then
			name, _, icon, count = UnitBuff(unit, LIGHTNING_SHIELD)
			if name then
				return LIGHTNING_TEXT[count]
			end
			name, _, icon, count = UnitBuff(unit, WATER_SHIELD)
			if name then
				return WATER_TEXT[count]
			end
		end
	end
end