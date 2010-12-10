--[[--------------------------------------------------------------------
oUF_Phanx
Fully-featured PVE-oriented layout for oUF.

http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
http://wow.curseforge.com/addons/ouf-phanx/

Copyright © 2007–2010 Phanx < addons@phanx.net >

I, the copyright holder of this work, hereby release it into the public
domain. This applies worldwide. In case this is not legally possible:
I grant anyone the right to use this work for any purpose, without any
conditions, unless such conditions are required by law.
----------------------------------------------------------------------]]

local _, ns = ...

local playerClass = select(2, UnitClass("player"))
if playerClass == "HUNTER" or playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then return end

ns.eventFrame = CreateFrame("Frame")
ns.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local TANKFORM

local function tankCheck(_, event)
	local form = GetShapeshiftForm() or 0
	if form > 0 then
		local _, name = GetShapeshiftFormInfo(form)
		if name == TANKFORM then
			ns.isTanking = true
			return
		end
	end
end

if playerClass == "DEATHKNIGHT" then
	TANKFORM = GetSpellInfo(48263)
	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", tankCheck)
	return
end

if playerClass == "DRUID" then
	TANKFORM = GetSpellInfo(9634)
	ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", function()
		local t1, t2, t3 = select(3, GetTalentTabInfo(1)) or 0, select(3, GetTalentTabInfo(2)) or 0, select(3, GetTalentTabInfo(3)) or 0
		ns.isHealing = (t3 > t1) and (t3 > t2)
		tankCheck()
	end)
	return
end

if playerClass == "PALADIN" then
	TANKFORM = GetSpellInfo(25780)
	ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	ns.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	ns.eventFrame:SetScript("OnEvent", function()
		local t1, t2, t3 = select(3, GetTalentTabInfo(1)) or 0, select(3, GetTalentTabInfo(2)) or 0, select(3, GetTalentTabInfo(3)) or 0
		ns.isHealing = (t1 > t2) and (t1 > t3)
		ns.isTanking = UnitAura("player", TANKFORM, "HELPFUL")
	end)
	return
end

if playerClass == "PRIEST" then
	ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	ns.eventFrame:SetScript("OnEvent", function()
		local t1, t2, t3 = select(3, GetTalentTabInfo(1)) or 0, select(3, GetTalentTabInfo(2)) or 0, select(3, GetTalentTabInfo(3)) or 0
		ns.isHealing = (t1 > t3) or (t2 > t3)
	end)
	return
end

if playerClass == "SHAMAN" then
	ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	ns.eventFrame:SetScript("OnEvent", function(_, event)
		local t1, t2, t3 = select(3, GetTalentTabInfo(1)) or 0, select(3, GetTalentTabInfo(2)) or 0, select(3, GetTalentTabInfo(3)) or 0
		ns.isHealing = (t3 > t1) and (t3 > t2)
	end)
	return
end

if playerClass == "WARRIOR" then
	TANKFORM = GetSpellInfo(71)
	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", tankCheck)
	return
end
