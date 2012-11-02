--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local playerClass = select(2, UnitClass("player"))
if playerClass == "HUNTER"
or playerClass == "MAGE"
or playerClass == "ROGUE"
or playerClass == "WARLOCK" then
	return
end

local _, ns = ...

ns.eventFrame = CreateFrame("Frame")
ns.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")

if playerClass == "DEATHKNIGHT" then

	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", function()
		ns.isTanking = GetSpecialization() == 1 and GetShapeshiftForm() == 1
	end)

elseif playerClass == "DRUID" then

	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", function()
		local spec = GetSpecialization()
		ns.isHealing = spec == 4
		ns.isTanking = spec == 3
	end)

elseif playerClass == "MONK" then

	ns.eventFrame:SetScript("OnEvent", function()
		local spec = GetSpecialization()
		ns.isHealing = spec == 2
		ns.isTanking = spec == 1
	end)

elseif playerClass == "PALADIN" then

	local RighteousFury = GetSpellInfo(25780)
	ns.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	ns.eventFrame:SetScript("OnEvent", function()
		ns.isHealing = GetSpecialization() == 1
		ns.isTanking = UnitAura("player", RighteousFury, "HELPFUL")
	end)

elseif playerClass == "PRIEST" then

	ns.eventFrame:SetScript("OnEvent", function()
		ns.isHealing = GetSpecialization() ~= 3
	end)

elseif playerClass == "SHAMAN" then

	ns.eventFrame:SetScript("OnEvent", function(_, event)
		ns.isHealing = GetSpecialization() == 3
	end)

elseif playerClass == "WARRIOR" then

	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", function()
		ns.isTanking = GetSpecialization() == 3 and GetShapeshiftForm() == 2
	end)

end