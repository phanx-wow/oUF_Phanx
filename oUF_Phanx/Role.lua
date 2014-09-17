--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")

local CURRENT_ROLE = "DAMAGER"

function ns.GetPlayerRole()
	return CURRENT_ROLE
end

if playerClass == "HUNTER" or playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then
	return -- These classes can only be DAMAGER, no need to listen for spec changes.
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:SetScript("OnEvent", function(_, event, ...)
	local spec = GetSpecialization()
	local role = spec and spec > 0 and select(6, GetSpecializationInfo(spec)) or "DAMAGER"
	if role == CURRENT_ROLE then return end

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
end)
