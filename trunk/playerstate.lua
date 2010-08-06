--[[--------------------------------------------------------------------
	oUF_Phanx
	An oUF layout.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Phanx. See README file for license terms.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
----------------------------------------------------------------------]]

local _, ns = ...

local playerClass = select(2, UnitClass("player"))
if playerClass == "HUNTER" or playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then return end

ns.eventFrame = CreateFrame("Frame")

local TANKFORM

local function tankCheck()
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
	ns.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	ns.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	ns.eventFrame:SetScript("OnEvent", function()
		local t1, t2, t3 = GetNumTalents(1) or 0, GetNumTalents(2) or 0, GetNumTalents(3) or 0
		ns.isHealing = (t3 > t1) and (t3 > t2)
		tankCheck()
	end)
	return
end

if playerClass == "PALADIN" then
	TANKFORM = GetSpellInfo(25780)
	ns.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	ns.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	ns.eventFrame:SetScript("OnEvent", function()
		local t1, t2, t3 = GetNumTalents(1) or 0, GetNumTalents(2) or 0, GetNumTalents(3) or 0
		ns.isHealing = (t1 > t2) and (t1 > t3)
		ns.isTanking = UnitAura("player", TANKFORM, "HELPFUL")
	end)
	return
end

if playerClass == "PRIEST" then
	ns.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	ns.eventFrame:SetScript("OnEvent", function()
		local t1, t2, t3 = GetNumTalents(1) or 0, GetNumTalents(2) or 0, GetNumTalents(3) or 0
		ns.isHealing = (t1 > t3) or (t2 > t3)
	end)
	return
end

if playerClass == "SHAMAN" then
	ns.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	ns.eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	ns.eventFrame:SetScript("OnEvent", function()
		local t1, t2, t3 = GetNumTalents(1) or 0, GetNumTalents(2) or 0, GetNumTalents(3) or 0
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
