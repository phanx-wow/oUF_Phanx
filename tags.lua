--[[--------------------------------------------------------------------
	oUF_Phanx
	An oUF layout.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Phanx. See README file for license terms.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
----------------------------------------------------------------------]]

oUF.TagEvents["unitcolor"] = "UNIT_HEALTH UNIT_CLASSIFICATION UNIT_REACTION"
oUF.Tags["unitcolor"] = function(unit)
	local color
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		color = oUF.colors.disconnected
	elseif UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = oUF.colors.class[class]
	elseif UnitIsUnit(unit, "pet") and GetPetHappiness() then
		color = oUF.colors.happiness[GetPetHappiness()]
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = oUF.colors.tapped
	elseif UnitIsEnemy(unit, "player") then
		color = oUF.colors.reaction[1]
	else
		color = oUF.colors.reaction[UnitReaction(unit, "player") or 5] or oUF.colors.disconnected
	end
	return ("|cff%02x%02x%02x"):format(color[1] * 255, color[2] * 255, color[3] * 255)
end

oUF.TagEvents["powercolor"] = "UNIT_DISPLAYPOWER"
oUF.Tags["powercolor"] = function(unit)
	local _, type = UnitPowerType(unit)
	local color = ns.colors.power[type] or ns.colors.power.FUEL
	return ("|cff%02x%02x%02x"):format(color[1] * 255, color[2] * 255, color[3] * 255)
end

oUF.TagEvents["combaticon"] = "PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED"
oUF.Tags["combaticon"] = function(unit)
	if unit == "player" and UnitAffectingCombat("player") then
		return [[|TInterface\CharacterFrame\UI-StateIcon:16:16:0:0:256:256:128:256:0:125|t ]]
	end
end

oUF.TagEvents["leadericon"] = "PARTY_LEADER_CHANGED PARTY_MEMBERS_CHANGED"
oUF.Tags["leadericon"] = function(unit)
	if UnitIsPartyLeader(unit) then
		return [[|TInterface\GroupFrame\UI-Group-LeaderIcon:0|t]]
	elseif UnitInRaid(unit) and UnitIsRaidOfficer(unit) then
		return [[|TInterface\GroupFrame\UI-Group-AssistantIcon:0|t]]
	end
end

oUF.TagEvents["mastericon"] = "PARTY_LOOT_METHOD_CHANGED PARTY_MEMBERS_CHANGED"
oUF.Tags["mastericon"] = function(unit)
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
		return [[|TInterface\GroupFrame\UI-Group-MasterLooter:0|t]]
	end
end

oUF.TagEvents["restingicon"] = "PLAYER_UPDATE_RESTING"
oUF.Tags["restingicon"] = function(unit)
	if unit == "player" and IsResting() then
		return [[|TInterface\CharacterFrame\UI-StateIcon:16:16:0:0:256:256:0:128:0:108|t]]
	end
end
