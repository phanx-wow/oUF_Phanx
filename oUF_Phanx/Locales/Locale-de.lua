--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	German localization
	Last updated 2013-02-04 by Grafotz
	***
----------------------------------------------------------------------]]

if GetLocale() ~= "deDE" then return end
local _, private = ...
local L = private.L

L.BorderColor = "Rahmen Farbe"
L.BorderColor_Desc = "Standart Rahmen Farbe ändern."
L.BorderSize = "Rahmen Breite"
L.ColorClass = "nach Klasse"
--L.ColorCustom = "Use custom color"
L.ColorHealth = "nach Gesundheit"
L.ColorPower = "nach Energieart"
L.Colors = "Farbe"
--L.Colors_Desc = "Use this panel to configure the colors used for different parts of the unit frames created by this layout."
--L.DruidManaBar = "Show druid mana bar"
--L.DruidManaBar_Desc = "Show an extra power bar for your mana when you're in Bear or Cat Form."
--L.EclipseBar = "Show eclipse bar"
--L.EclipseBar_Desc = "Show an eclipse bar above the player frame."
--L.EclipseBarIcons = "Show eclipse bar icons"
--L.EclipseBarIcons_Desc = "Show animated moon and sun icons on either end of the eclipse bar."
--L.FilterDebuffHighlight = "Filter debuff highlight"
L.FilterDebuffHighlight_Desc = "Nur Schwächungszauber anzeigen die auch entfernt werden können."
L.Font = "Schriftart"
--L.HealthBG = "Health bar background"
--L.HealthBG_Desc = "Change the relative brightness of the health bar background color."
--L.HealthColor = "Health bar color"
--L.HealthColor_Desc = "Change how health bars are colored."
--L.HealthColorCustom = "Custom health bar color"
L.IgnoreOwnHeals = "Ignoriere eigene Heals"
L.IgnoreOwnHeals_Desc = "Zeige nur eingehende Heilungen anderer Spieler."
L.None = "Nichts"
L.OptionRequiresReload = "Wird erst nach neuladen des UI übernommen."
L.Options_Desc = "oUF_Phanx ist ein Layout für Haste's oUF Framework. Nutze diese Oberfläche um Grundeinstellungen zu konfigurieren."
--L.Outline = "Text outline"
--L.PowerBG = "Power bar background"
--L.PowerBG_Desc = "Change the relative brightness of the power bar background color."
--L.PowerColor = "Power bar color"
--L.PowerColor_Desc = "Change how power bars are colored."
--L.PowerColorCustom = "Custom power bar color"
L.RuneBars = "Zeige Runenleiste"
--L.RuneBars_Desc = "Show cooldown timer bars for your runes above the player frame."
L.Texture = "Textur"
L.Thick = "Dick"
L.Thin = "Dünn"
--L.ThreatLevels = "Show threat levels"
--L.ThreatLevels_Desc = "Show more granular threat levels, instead of simple aggro status."
L.TotemBars = "Zeige Totemleiste"
--L.TotemBars_Desc = "Show timer bars for your totems above the player frame."