--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local playerClass = select(2, UnitClass("player"))

local CURRENT_ROLE = "DAMAGER"
local getRole, updateEvents

function ns.GetPlayerRole()
	return CURRENT_ROLE
end

if playerClass == "DEATHKNIGHT" then
	updateEvents = "UPDATE_SHAPESHIFT_FORM"
	function getRole()
		if GetSpecialization() == 1 then -- Blood 1, Frost 2, Unholy 3
			return "TANK"
		end
	end

elseif playerClass == "DRUID" then
	updateEvents = "UPDATE_SHAPESHIFT_FORM"
	function getRole()
		local form = GetShapeshiftFormID() -- Aquatic 4, Bear 5, Cat 1, Flight 29, Moonkin 31, Swift Flight 27, Travel 3, Tree 2
		if form == 5 then
			return "TANK"
		elseif GetSpecialization() == 4 then -- Balance 1, Feral 2, Guardian 3, Restoration 4
			return "HEALER"
		end
	end

elseif playerClass == "MONK" then
	updateEvents = "UPDATE_SHAPESHIFT_FORM"
	function getRole()
		local form = GetShapeshiftFormID() -- Tiger 24, Ox 23, Serpent 20
		if form == 23 then
			return "TANK"
		elseif form == 20 then
			return "HEALER"
		end
	end

elseif playerClass == "PALADIN" then
	local RIGHTEOUS_FURY = GetSpellInfo(25780)
	updateEvents = "PLAYER_REGEN_DISABLED"
	function getRole()
		if UnitAura("player", RIGHTEOUS_FURY, "HELPFUL") then
			return "TANK"
		elseif GetSpecialization() == 1 then -- Holy 1, Protection 2, Retribution 3
			return "HEALER"
		end
	end

elseif playerClass == "PRIEST" then
	function getRole()
		if GetSpecialization() ~= 3 then -- Discipline 1, Holy 2, Shadow 3
			return "HEALER"
		end
	end

elseif playerClass == "SHAMAN" then
	function getRole()
		if GetSpecialization() == 3 then -- Elemental 1, Enhancement 2, Restoration 3
			return "HEALER"
		end
	end

elseif playerClass == "WARRIOR" then
	updateEvents = "UPDATE_SHAPESHIFT_FORM"
	function getRole()
		if GetSpecialization() == 3 and GetShapeshiftFormID() == 18 then -- Battle 17, Berserker 19, Defensive 18
			return "TANK"
		end
	end

end

if getRole then
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	if updateEvents then
		for event in gmatch(updateEvents, "%S+") do
			eventFrame:RegisterEvent(event)
		end
	end
	eventFrame:SetScript("OnEvent", function(_, event, ...)
		local role = getRole() or "DAMAGER"
		if role ~= CURRENT_ROLE then
			--print(event, CURRENT_ROLE, "->", role)
			CURRENT_ROLE = role
			ns.UpdateAuraList()
			for _, frame in pairs(ns.objects) do
				if frame.updateOnRoleChange then
					for _, func in pairs(frame.updateOnRoleChange) do
						func(frame, role)
					end
				end
			end
		end
	end)
end
