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
	L["Select a texture for health, power, and other bars."] = ""
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
	Last updated: 2010-12-26 by Akkorian
----------------------------------------------------------------------]]

if locale == "esES" or GetLocale() == "esMX" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = "oUF_Phanx es un diseño para el sistema oUF, por Haste. Estas opciones te permiten modificar la configuración de oUF_Phanx."
	L["Texture"] = "Textura"
	L["Select a texture for health, power, and other bars."] = "Ajusta la textura para las barras de salud, poder, etc."
	L["Font"] = "Fuente"
	L["Select a typeface for text on the frames."] = "Cambia la fuente."
	L["Font Outline"] = "Perfil de fuente"
	L["Select an outline weight for text on the frames."] = "Ajusta el perfil de la fuente."
	L["None"] = "Ninguno"
	L["Thin"] = "Fino"
	L["Thick"] = "Grueso"
	L["Border Color"] = "Color de borde"
	L["Set the default color for frame borders."] = "Ajusta el color por defecto, para los bordes de los marcos."
	L["Border Size"] = "Tamaño de borde"
	L["Change the size of the frame borders."] = "Ajusta el tamaño para los bordes de los marcos."
	L["Filter debuff highlight"] = "Resaltar sólo perjuicios disipables"
	L["Show the debuff highlight only for debuffs you can dispel."] = "Resaltar los marcos sólo para perjuicios que puedes eliminar."
	L["Ignore own heals"] = "Ignorar las propias sanaciones"
	L["Show only incoming heals cast by other players."] = "Mostrar sólo las sanaciones lanzadas por otros."
	L["Show threat levels"] = "Mostrar los niveles de amenaza"
	L["Show threat levels instead of binary aggro status."] = "Mostrar los niveles de amenaza en lugar del sólo agro."
return end

--[[--------------------------------------------------------------------
	frFR | Français | French
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "frFR" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health, power, and other bars."] = ""
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
	ruRU | Русский | Russian
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "ruRU" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health, power, and other bars."] = ""
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
	koKR | 한국어 | Korean
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "koKR" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health, power, and other bars."] = ""
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
	zhCN | 简体中文 | Simplified Chinese
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "zhCN" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health, power, and other bars."] = ""
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
	zhTW | 正體中文 | Traditional Chinese
	Last updated: YYYY-MM-DD by UNKNOWN < CONTACT INFO >
----------------------------------------------------------------------]]

if locale == "zhTW" then
	L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = ""
	L["Texture"] = ""
	L["Select a texture for health, power, and other bars."] = ""
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