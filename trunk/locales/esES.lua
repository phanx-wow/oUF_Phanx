--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2011 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	esES | Español (Europa) | Spanish (Europe)
	esMX | Español (América Latina) | Spanish (Latin America)
	Last updated: 2011-02-22 by Akkorian <akkorian@hotmail.com>
----------------------------------------------------------------------]]

if not GetLocale():match( "^es" ) then return end

local _, ns = ...
local L = {}
ns.L = L

L["B"] = "J"
L["E"] = "É"
L["R"] = "R"

L[" Be"] = " Be"
L[" De"] = " De"
L[" Dr"] = " Dr"
L[" El"] = " El"
L[" Gi"] = " Gi"
L[" Hu"] = " Hu"
L[" Me"] = " Me"
L[" Un"] = " No"

L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = "oUF_Phanx es un diseño para el sistema oUF, por Haste. Estas opciones te permiten modificar la configuración de oUF_Phanx."

L["Texture"] = "Textura"
L["Select a texture for health, power, and other bars."] = "Establecer la textura para las barras de salud, poder, etc."

L["Font"] = "Fuente"
L["Select a typeface for text on the frames."] = "Establecer la fuente."
L["Font Outline"] = "Perfil de fuente"
L["Select an outline weight for text on the frames."] = "Establecer el perfil de la fuente."
L["None"] = "Ninguno"
L["Thin"] = "Fino"
L["Thick"] = "Grueso"

L["Border Size"] = "Tamaño de borde"
L["Change the size of the frame borders."] = "Ajustar el tamaño para los bordes de los marcos."
L["Border color"] = "Color de borde"
L["Change the default frame border color."] = "Ajustar el color por defecto para los bordes de los marcos."

L["Filter debuff highlight"] = "Sólo perjuicios disipables"
L["Show the debuff highlight only for debuffs you can dispel."] = "Resaltar los marcos sólo para perjuicios que puedes eliminar."
L["Ignore own heals"] = "Ignorar propias sanaciones"
L["Show only incoming heals cast by other players."] = "Mostrar sólo las sanaciones en curso de lanzamiento por otros."
L["Show threat levels"] = "Niveles de amenaza"
L["Show threat levels instead of binary aggro status."] = "Mostrar los niveles de amenaza en lugar del sólo agro."

L["Show druid mana bar"] = "Barra de maná en formas"
L["Show a mana bar while you are in Cat Form or Bear Form."] = "Mostrar una barra de maná debajo el marco de tu personaje cuando estás en forma felina o de oso."
L["Show eclipse bar"] = "Barra de eclipse"
L["Show an eclipse bar above the player frame."] = "Mostrar una barra de eclipse sobre el marco de tu personaje."
L["Show eclipse bar icons"] = "Iconos de eclipse"
L["Show animated moon and sun icons on either end of the eclipse bar."] = "Mostrar iconos animados en cada extremo de la barra de eclipse."
L["This option will not take effect until the next time you log in or reload your UI."] = "Esta opción no tendrá efecto hasta la próxima vez que te conecte o vuelva a cargar la interfaz de usuario."

L["Bar Colors"] = "Colores"
L["Use this panel to configure the colors used for different parts of the unit frames created by this layout."] = "Estas opciones te permiten modificar los colores utilizados para las diferentes partes de los marcos."

L["Health color mode"] = "Modo de color de salud"
L["Change how health bars are colored."] = "Establecer como están coloreadas las barras de salud."
L["Health bar color"] = "Color de barras de salud"
L["Change the health bar color."] = "Ajustar el color personalizado de las barras de salud."
L["Health background intensity"] = "Brillo de fondo de salud"
L["Change the brightness of the health bar background color, relative to the foreground color."] = "Ajustar el brillo de los fondos de las barras de salud, en relación con el color de primer plano."

L["Power color mode"] = "Modo de color de poder"
L["Change how power bars are colored."] = "Establecer como están coloreadas las barras de poder."
L["Power bar color"] = "Color de barras de poder"
L["Change the power bar color."] = "Ajustar el color personalizado de las barras de poder."
L["Power background intensity"] = "Brillo de fondo de poder"
L["Change the brightness of the power bar background color, relative to the foreground color."] = "Ajustar el brillo de los fondos de las barras de salud, en relación con el color de primer plano."

L["By Class"] = "Por clase"
L["By Health"] = "Por salud"
L["By Power Type"] = "Por tipo de poder"
L["Custom"] = "Personalizado"