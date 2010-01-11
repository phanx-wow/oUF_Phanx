--[[--------------------------------------------------------------------
	oUF_Phanx
	A layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	Copyright ©2009–2010 Alyssa "Phanx" Kinley. All rights reserved.
	See README for license terms and additional information.
----------------------------------------------------------------------]]

local L = { }
local _, namespace = ...
namespace.L = L

L.CreatureType = {
	["elite"]     = "|cffcc9900E|r",
	["rare"]      = "|cff999999R|r",
	["rareelite"] = "|cff999999R|r|cffcc9900E|r",
	["worldboss"] = "|cffcc0000B|r",
}

L.Classification = { }
do
	local useBlank = function(t, k)
		t[k] = ""
		return ""
	end

	local useEnglish = function(t, k)
		t[k] = k
		return k
	end

	local ignore
	local locale = GetLocale()
	if locale:match("^en") then
		L.CreatureType["Beast"]       = "Be"
		L.CreatureType["Demon"]       = "De"
		L.CreatureType["Dragonkin"]   = "Dr"
		L.CreatureType["Elemental"]   = "El"
		L.CreatureType["Giant"]       = "Gi"
		L.CreatureType["Humanoid"]    = "Hu"
		L.CreatureType["Mechanical"]  = "Me"
		L.CreatureType["Undead"]      = "Un"
	elseif locale == "deDE" then
		L.CreatureType["Wildtier"]    = "Wi"
		L.CreatureType["Dämon"]       = "Dä"
		L.CreatureType["Drachkin"]    = "Dr"
		L.CreatureType["Elementar"]   = "El"
		L.CreatureType["Riese"]       = "Ri"
		L.CreatureType["Humanoid"]    = "Hu"
		L.CreatureType["Mechanisch"]  = "Me"
		L.CreatureType["Untoter"]     = "Un"
	elseif locale == "esES" then
		L.CreatureType["Bestia"]      = "Be"
		L.CreatureType["Demonio"]     = "De"
		L.CreatureType["Dragón"]      = "Dr"
		L.CreatureType["Elemental"]   = "El"
		L.CreatureType["Gigante"]     = "Gi"
		L.CreatureType["Humanoide"]   = "Hu"
		L.CreatureType["Mecánico"]    = "Me"
		L.CreatureType["No-muerto"]   = "No"
	elseif locale == "esMX" then
		L.CreatureType["Bestia"]      = "Be"
		L.CreatureType["Demonio"]     = "De"
		L.CreatureType["Dragon"]      = "Dr"
		L.CreatureType["Elemental"]   = "El"
		L.CreatureType["Gigante"]     = "Gi"
		L.CreatureType["Humanoide"]   = "Hu"
		L.CreatureType["Mecánico"]    = "Me"
		L.CreatureType["No-muerto"]   = "No"
	elseif locale == "frFR" then
		L.CreatureType["Bête"]        = "Bê"
		L.CreatureType["Démon"]       = "Dé"
		L.CreatureType["Draconien"]   = "Dr"
		L.CreatureType["Elémentaire"] = "El"
		L.CreatureType["Géant"]       = "Gé"
		L.CreatureType["Humanoïde"]   = "Hu"
		L.CreatureType["Machine"]     = "Ma"
		L.CreatureType["Mort-vivant"] = "Mo"
	elseif locale == "ruRU" then
		L.CreatureType["Животное"]    = "Жи"
		L.CreatureType["Демон"]       = "Де"
		L.CreatureType["Дракон"]      = "Др"
		L.CreatureType["Элементаль"]  = "Эл"
		L.CreatureType["Великан"]     = "Ве"
		L.CreatureType["Гуманоид"]    = "Гу"
		L.CreatureType["Механизм"]    = "Ме"
		L.CreatureType["Нежить"]      = "Не"
	elseif locale == "koKR" then
		L.Classification["elite"]     = "|cffcc9900+|r"
		L.Classification["rare"]      = "|cff999999희|r"
		L.Classification["rareelite"] = "|cff999999희|r|cffcc9900+|r"
		L.Classification["worldboss"] = "|cffcc0000보|r"
		ignore = {
			["작은 동물"] = true, -- Critter
			["가스 구름"] = true, -- Gas Cloud
			["비전투 소환수"] = true, -- Non-combat Pet
			["지정하지 않음"] = true, -- Not specified
			["토템"] = true, -- Totem
		}
	elseif locale == "zhCN" then
		L.Classification["elite"]     = "|cffcc9900+|r"
		L.Classification["rare"]      = "|cff999999稀|r"
		L.Classification["rareelite"] = "|cff999999稀|r|cffcc9900+|r"
		L.Classification["worldboss"] = "|cffcc0000首|r"
		ignore = {
			["小动物"] = true,
			["气体云雾"] = true,
			["非战斗宠物"] = true,
			["未指定"] = true,
			["图腾"] = true,
		}
	elseif locale == "zhTW" then
		L.Classification["elite"]     = "|cffcc9900+|r"
		L.Classification["rare"]      = "|cff999999稀|r"
		L.Classification["rareelite"] = "|cff999999稀|r|cffcc9900+|r"
		L.Classification["worldboss"] = "|cffcc0000首|r"
		ignore = {
			["小動物"] = true,
			["氣體雲"] = true,
			["非戰鬥寵物"] = true,
			["不明"] = true,
			["圖騰"] = true,
		}
	end
	if ignore then
		setmetatable(L.CreatureType, { __index = function(t, k)
			if ignore[k] then
				t[k] = ""
				return ""
			else
				t[k] = k
				return k
			end
		end })
	else
		setmetatable(L.CreatureType, { __index = useBlank })
	end
	setmetatable(L.Classification, { __index = useBlank })
end
