--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	French localization
	Last updated 2012-12-07 by Strigx
	***
----------------------------------------------------------------------]]

if GetLocale() ~= "frFR" then return end
local _, private = ...
local L = private.L

--L.AddAura = "Add Aura"
--L.AddAura_Info = "Enter a Spell ID and press Enter."
--L.AddAura_Invalid = "That is not a valid Spell ID!"
--L.AddAura_Note = "To find the Spell ID for a spell, look it up on Wowhead.com and copy the number out of the UR--L."
--L.Auras = "Auras"
--L.Auras_Info = "Add new buffs and debuffs to show, or change the filtering behavior of predefined auras."
--L.AuraFilter0 = "Never show"
--L.AuraFilter1 = "Always show"
--L.AuraFilter2 = "Only show mine"
--L.AuraFilter3 = "Only show on friendly units"
--L.AuraFilter4 = "Only show on myself"
L.BorderColor = "Couleur de bordure"
L.BorderColor_Desc = "Modifie la couleur par défaut de la bordure du cadre."
L.BorderSize = "Taille de bordure"
L.ColorClass = "Par classe"
L.ColorCustom = "Personnalisé"
L.ColorHealth = "Par vie"
L.ColorPower = "Par type de puissance"
L.Colors = "Couleurs"
L.Colors_Desc = "Utiliser ce panneau pour configurer les couleurs des différentes parties de l'interface créée par ce layout."
--L.DeleteAura = "Delete Aura"
--L.DeleteAura = "Remove your custom filter for this aura."
L.DruidManaBar = "Barre de mana druidique"
L.DruidManaBar_Desc = "Affiche la barre de mana en forme de Chat ou d'Ours."
L.EclipseBar = "Barre d'éclipse"
L.EclipseBar_Desc = "Affiche une barre d'éclipse au-dessus du cadre du joueur."
L.EclipseBarIcons = "Icônes d'éclipse"
L.EclipseBarIcons_Desc = "Affiche des icônes animées à chaque extrémité de la bar d'éclipse."
L.FilterDebuffHighlight = "Filtre des débuffs"
L.FilterDebuffHighlight_Desc = "Affiche la mise en évidence des débuffs uniquement pour ceux que vous pouvez dissiper."
L.Font = "Police"
L.HealthBG = "Fond de barre de vie"
L.HealthBG_Desc = "Modifie la luminosité de la couleur de fond de la barre de vie, relativement à la couleur d'avant-plan."
L.HealthColor = "Couleur de barre de vie"
L.HealthColor_Desc = "Modifie la manière dont les barres de vie sont colorées."
L.HealthColorCustom = "Couleur personnalisée de vie"
L.IgnoreOwnHeals = "Ignorer propre soins"
L.IgnoreOwnHeals_Desc = "Indique uniquement les soins incantés par les autres joueurs."
L.None = "Aucun"
L.OptionRequiresReload = "Cette option ne prendra effet qu'après une reconnexion ou un rechargement d'interface."
L.Options_Desc = "oUF_Phanx est un layout pour oUF par Haste. Utilisez ce panneau pour configurer des options basiques de ce layout."
L.Outline = "Contour de police"
L.PowerBG = "Fond de barre de puissance"
L.PowerBG_Desc = "Modifie la luminosité de la couleur de fond de la barre de puissance, relativement à la couleur d'avant-plan."
L.PowerColor = "Couleur de barre de puissance"
L.PowerColor_Desc = "Modifie la manière dont les barres de puissance sont colorées."
L.PowerColorCustom = "Couleur personnalisée de puissance"
L.RuneBars = "Barres de runes"
L.RuneBars_Desc = "Affiche des barres de temps pour vos runes au-dessus du cadre du joueur."
L.Texture = "Texture"
L.Thick = "Epais"
L.Thin = "Fin"
L.ThreatLevels = "Niveaux de menace"
L.ThreatLevels_Desc = "Affiche les niveaux de menace au lieu d'un statut binaire."
L.TotemBars = "Barres de totems"
L.TotemBars_Desc = "Affiche des barres de temps pour vos totems au-dessus du cadre du joueur."