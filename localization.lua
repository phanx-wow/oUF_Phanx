--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	by Phanx < addons@phanx.net >
	Currently maintainted by Akkorian < akkorian@hotmail.com >.
	Copyright © 2007–2010. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
----------------------------------------------------------------------]]

local locale = GetLocale()
if locale:match("^en") then return end

local _, ns = ...

local L = { }
ns.L = L

--[[--------------------------------------------------------------------
	deDE | Deutsch | German
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "deDE" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health and power bars."] = ""
	L["Font"] = ""
	L["Select a typeface for text on the frames."] = ""
	L["Font Outline"] = ""
	L["Select an outline weight for text on the frames."] = ""
	L["None"] = ""
	L["Thin"] = ""
	L["Thick"] = ""
	L["Border Color"] = ""
	L["Set the default color for frame borders."] = ""
	L["Border Size"] = ""
	L["Change the size of the frame borders."] = ""
	L["Filter debuff highlight"] = ""
	L["Show the debuff highlight only for debuffs you can dispel."] = ""
	L["Ignore own heals"] = ""
	L["Show only incoming heals cast by other players."] = ""
	L["Show threat levels"] = ""
	L["Show threat levels instead of binary aggro status."] = ""
return end

--[[--------------------------------------------------------------------
	esES | Español (EU) | Spanish (Europe)
	esMX | Español (AL) | Spanish (Latin America)
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "esES" or GetLocale() == "esMX" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health and power bars."] = ""
	L["Font"] = ""
	L["Select a typeface for text on the frames."] = ""
	L["Font Outline"] = ""
	L["Select an outline weight for text on the frames."] = ""
	L["None"] = ""
	L["Thin"] = ""
	L["Thick"] = ""
	L["Border Color"] = ""
	L["Set the default color for frame borders."] = ""
	L["Border Size"] = ""
	L["Change the size of the frame borders."] = ""
	L["Filter debuff highlight"] = ""
	L["Show the debuff highlight only for debuffs you can dispel."] = ""
	L["Ignore own heals"] = ""
	L["Show only incoming heals cast by other players."] = ""
	L["Show threat levels"] = ""
	L["Show threat levels instead of binary aggro status."] = ""
return end

--[[--------------------------------------------------------------------
	frFR | Français | French
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "frFR" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health and power bars."] = ""
	L["Font"] = ""
	L["Select a typeface for text on the frames."] = ""
	L["Font Outline"] = ""
	L["Select an outline weight for text on the frames."] = ""
	L["None"] = ""
	L["Thin"] = ""
	L["Thick"] = ""
	L["Border Color"] = ""
	L["Set the default color for frame borders."] = ""
	L["Border Size"] = ""
	L["Change the size of the frame borders."] = ""
	L["Filter debuff highlight"] = ""
	L["Show the debuff highlight only for debuffs you can dispel."] = ""
	L["Ignore own heals"] = ""
	L["Show only incoming heals cast by other players."] = ""
	L["Show threat levels"] = ""
	L["Show threat levels instead of binary aggro status."] = ""
return end

--[[--------------------------------------------------------------------
	ruRU | ??????? | Russian
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "ruRU" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health and power bars."] = ""
	L["Font"] = ""
	L["Select a typeface for text on the frames."] = ""
	L["Font Outline"] = ""
	L["Select an outline weight for text on the frames."] = ""
	L["None"] = ""
	L["Thin"] = ""
	L["Thick"] = ""
	L["Border Color"] = ""
	L["Set the default color for frame borders."] = ""
	L["Border Size"] = ""
	L["Change the size of the frame borders."] = ""
	L["Filter debuff highlight"] = ""
	L["Show the debuff highlight only for debuffs you can dispel."] = ""
	L["Ignore own heals"] = ""
	L["Show only incoming heals cast by other players."] = ""
	L["Show threat levels"] = ""
	L["Show threat levels instead of binary aggro status."] = ""
return end

--[[--------------------------------------------------------------------
	koKR | ??? | Korean
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "koKR" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health and power bars."] = ""
	L["Font"] = ""
	L["Select a typeface for text on the frames."] = ""
	L["Font Outline"] = ""
	L["Select an outline weight for text on the frames."] = ""
	L["None"] = ""
	L["Thin"] = ""
	L["Thick"] = ""
	L["Border Color"] = ""
	L["Set the default color for frame borders."] = ""
	L["Border Size"] = ""
	L["Change the size of the frame borders."] = ""
	L["Filter debuff highlight"] = ""
	L["Show the debuff highlight only for debuffs you can dispel."] = ""
	L["Ignore own heals"] = ""
	L["Show only incoming heals cast by other players."] = ""
	L["Show threat levels"] = ""
	L["Show threat levels instead of binary aggro status."] = ""
return end

--[[--------------------------------------------------------------------
	zhCN | ???? | Simplified Chinese
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "zhCN" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health and power bars."] = ""
	L["Font"] = ""
	L["Select a typeface for text on the frames."] = ""
	L["Font Outline"] = ""
	L["Select an outline weight for text on the frames."] = ""
	L["None"] = ""
	L["Thin"] = ""
	L["Thick"] = ""
	L["Border Color"] = ""
	L["Set the default color for frame borders."] = ""
	L["Border Size"] = ""
	L["Change the size of the frame borders."] = ""
	L["Filter debuff highlight"] = ""
	L["Show the debuff highlight only for debuffs you can dispel."] = ""
	L["Ignore own heals"] = ""
	L["Show only incoming heals cast by other players."] = ""
	L["Show threat levels"] = ""
	L["Show threat levels instead of binary aggro status."] = ""
return end

--[[--------------------------------------------------------------------
	zhTW | ???? | Traditional Chinese
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "zhTW" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health and power bars."] = ""
	L["Font"] = ""
	L["Select a typeface for text on the frames."] = ""
	L["Font Outline"] = ""
	L["Select an outline weight for text on the frames."] = ""
	L["None"] = ""
	L["Thin"] = ""
	L["Thick"] = ""
	L["Border Color"] = ""
	L["Set the default color for frame borders."] = ""
	L["Border Size"] = ""
	L["Change the size of the frame borders."] = ""
	L["Filter debuff highlight"] = ""
	L["Show the debuff highlight only for debuffs you can dispel."] = ""
	L["Ignore own heals"] = ""
	L["Show only incoming heals cast by other players."] = ""
	L["Show threat levels"] = ""
	L["Show threat levels instead of binary aggro status."] = ""
return end