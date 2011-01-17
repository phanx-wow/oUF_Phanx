--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	by Phanx < addons@phanx.net >
	Currently maintained by Akkorian < akkorian@hotmail.com >
	Copyright © 2007–2011. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
----------------------------------------------------------------------]]

local _, ns = ...

local playerClass = select(2, UnitClass("player"))
if playerClass == "HUNTER" or playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then return end

ns.eventFrame = CreateFrame("Frame")
ns.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")

if playerClass == "DEATHKNIGHT" then

	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", function()
		ns.isTanking = GetPrimaryTalentTree() == 1 and GetShapeshiftForm() == 1
	end)

elseif playerClass == "DRUID" then

	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", function()
		ns.isHealing = GetPrimaryTalentTree() == 3
		ns.isTanking = GetPrimaryTalentTree() == 2 and GetShapeshiftForm() == 1
	end)

elseif playerClass == "PALADIN" then

	local RighteousFury = GetSpellInfo(25780)
	ns.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	ns.eventFrame:SetScript("OnEvent", function()
		ns.isHealing = GetPrimaryTalentTree() == 1
		ns.isTanking = UnitAura("player", RighteousFury, "HELPFUL")
	end)

elseif playerClass == "PRIEST" then

	ns.eventFrame:SetScript("OnEvent", function()
		ns.isHealing = GetPrimaryTalentTree() ~= 3
	end)

elseif playerClass == "SHAMAN" then

	ns.eventFrame:SetScript("OnEvent", function(_, event)
		ns.isHealing = GetPrimaryTalentTree() == 3
	end)

elseif playerClass == "WARRIOR" then

	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", function()
		ns.isTanking = GetPrimaryTalentTree() == 3 and GetShapeshiftForm() == 2
	end)

end