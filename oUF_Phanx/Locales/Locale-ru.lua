--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Russian localization
	Contributors: Felixod
----------------------------------------------------------------------]]

if GetLocale() ~= "ruRU" then return end
local _, private = ...
local L = private.L

--L.AddAura = "Add Aura"
--L.AddAura_Info = "Enter a Spell ID and press Enter."
--L.AddAura_Invalid = "That is not a valid Spell ID!"
--L.AddAura_Note = "To find the Spell ID for a spell, look it up on Wowhead.com and copy the number out of the UR--L."
--L.AuraFilter0 = "Never show"
--L.AuraFilter1 = "Always show"
--L.AuraFilter2 = "Only show mine"
--L.AuraFilter3 = "Only show on friendly units"
--L.AuraFilter4 = "Only show on myself"
--L.Auras = "Auras"
--L.Auras_Info = "Add new buffs and debuffs to show, or change the filtering behavior of predefined auras."
L.BorderColor = "Цвет рамки"
L.BorderColor_Desc = "Изменить цвет рамки окна."
L.BorderSize = "Размер рамки"
L.ColorClass = "Цвет по классу"
L.ColorCustom = "Использовать другой цвет"
L.ColorHealth = "Цвет согласно уровня жизни"
L.ColorPower = "Цвет по типу мощности"
L.Colors = "Цвет"
L.Colors_Desc = "Используйте это окно для настройки цвета, используемого в различных элементах этого аддона."
--L.DeleteAura = "Delete Aura"
--L.DeleteAura = "Remove your custom filter for this aura."
L.DruidManaBar = "Отображать панель манны у друида"
--L.DruidManaBar_Desc = "Show an extra power bar for your mana when you're in Bear or Cat Form."
--L.EclipseBar = "Show eclipse bar"
--L.EclipseBar_Desc = "Show an eclipse bar above the player frame."
--L.EclipseBarIcons = "Show eclipse bar icons"
--L.EclipseBarIcons_Desc = "Show animated moon and sun icons on either end of the eclipse bar."
--L.FilterDebuffHighlight = "Filter debuff highlight"
--L.FilterDebuffHighlight_Desc = "Highlight frame borders only for debuffs you can dispe--L."
--L.Font = "Font"
--L.FrameHeight = "Base frame height"
--L.FrameHeight_Desc = "Set the base frame height."
--L.FrameWidth = "Base frame width"
--L.FrameWidth_Desc = "Set the base frame width. Some frames are proportionally wider or narrower."
--L.HealthBG = "Health bar background"
--L.HealthBG_Desc = "Change the relative brightness of the health bar background color."
--L.HealthColor = "Health bar color"
--L.HealthColor_Desc = "Change how health bars are colored."
--L.HealthColorCustom = "Custom health bar color"
--L.IgnoreOwnHeals = "Ignore own heals"
--L.IgnoreOwnHeals_Desc = "Show incoming heal bars only for heals cast by other players."
--L.MoreSettings = "More Settings"
--L.MoreSettings_Desc = "These settings will not take effect until the next time you reload your UI."
--L.None = "None"
--L.Options_Desc = "oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."
--L.Outline = "Text outline"
--L.PowerBG = "Power bar background"
--L.PowerBG_Desc = "Change the relative brightness of the power bar background color."
--L.PowerColor = "Power bar color"
--L.PowerColor_Desc = "Change how power bars are colored."
--L.PowerColorCustom = "Custom power bar color"
--L.PowerHeight = "Power bar height"
--L.PowerHeight_Desc = "Set the height of the power bar, as a percent of the total frame height."
--L.ReloadUI = "Reload UI"
--L.RuneBars = "Show rune bars"
--L.RuneBars_Desc = "Show cooldown timer bars for your runes above the player frame."
--L.Texture = "Bar texture"
--L.Thick = "Thick"
--L.Thin = "Thin"
--L.ThreatLevels = "Show threat levels"
--L.ThreatLevels_Desc = "Show more granular threat levels, instead of simple aggro status."
--L.TotemBars = "Show totem bars"
--L.TotemBars_Desc = "Show timer bars for your totems above the player frame."
