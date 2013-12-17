--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	German localization
	Contributors: Grafotz
----------------------------------------------------------------------]]

--if GetLocale() ~= "deDE" then return end
local _, private = ...
local L = private.L

L.AddAura = "Aura hinzufügen"
L.AddAura_Desc = "Um eine neue Aura hinzuzufügen, gib seine Zauber-ID ein, und drücke die Eingabetaste."
L.AddAura_Invalid = "Das ist keine gültige Zauber-ID!"
L.AddAura_Note = "Um die ID für einen Zauber zu finden, suche sie auf Wowhead.com, und kopiere die Nummer aus der URL."
L.Auras = "Auren"
L.Auras_Desc = "Neue Stärkungs- oder Schwächungszauber hinzufügen, oder ändern, wie die vordefinierten Auren werden gefiltert."
L.AuraFilter0 = "Zeigen nie"
L.AuraFilter1 = "Zeigen immer"
L.AuraFilter2 = "Zeigen nur meine"
L.AuraFilter3 = "Zeigen nur auf Freunde"
L.AuraFilter4 = "Zeigen nur auf mich selbst"
L.BorderColor = "Randfarbe"
L.BorderColor_Desc = "Standartrandfarbe ändern."
L.BorderSize = "Randbreite"
L.ColorClass = "Nach Klasse"
L.ColorCustom = "Benutzerdefinierte"
L.ColorHealth = "Nach Gesundheit"
L.ColorPower = "Nach Energieart"
L.Colors = "Farbe"
L.Colors_Desc = "Diese Optionen ändern die Farben, die für verschiedene Teile der Einheitfenster verwendet werden."
L.CombatText = "Kampfrückmeldungstext"
L.CombatText_Desc = "Schadens-, Heilungs- und anderen Kampftext auf den Einheitfenstern anzeigen."
L.DeleteAura = "Aura löschen"
L.DeleteAura_Desc = "Den benutzerdefinierten Filter für diese Aura löschen."
L.DruidManaBar = "Druidmanabalken"
L.DruidManaBar_Desc = "Eine zusätzliche Manabalken anzeigen, während Sie in Katzengestalt oder Bärengestalt sind."
L.EclipseBar = "Finsternisbalken"
L.EclipseBar_Desc = "Ein Finsternisbalken über dem Spielerfenster anzeigen."
L.EclipseBarIcons = "Finsternisbalkensymbole"
L.EclipseBarIcons_Desc = "Animierte Symbole von Mond und Sonne an beiden Enden der Finsternisbalken anzeigen."
L.FilterDebuffHighlight = "Schwächungszauber filtern"
L.FilterDebuffHighlight_Desc = "Hervorhebungen der Schwächungszauber nur anzeigen, die auch entfernt werden können."
L.Font = "Schriftart"
L.FrameHeight = "Basishöhe"
L.FrameHeight_Desc = "Die Basishöhe der Fenster festlegen."
L.FrameWidth = "Basisbreite"
L.FrameWidth_Desc = "Die Basisbreite der Fenster festlegen. Einige Fenster sind proportional breiter oder schmaler."
L.HealthBG = "Gesundheitsbalkenhintergrund"
L.HealthBG_Desc = "Die Helligkeit der Hintergrund des Gesundheitsbalkens festlegen, relativ zu seiner Vordergrund."
L.HealthColor = "Gesundheitsbalkenfarbe"
L.HealthColor_Desc = "Legt fest, wie die Gesundheitsbalken eingefärbt werden."
L.HealthColorCustom = "Benutzerdefinierte Farbe"
L.IgnoreOwnHeals = "Ignoriere eigene Heals"
L.IgnoreOwnHeals_Desc = "Zeige nur eingehende Heilungen anderer Spieler."
L.MoreSettings = "Weitere Einstellungen"
L.MoreSettings_Desc = "Um die Änderungen dieser Einstellungen anzuwenden, muss das UI erneut geladen werden."
L.None = "Nichts"
L.Options_Desc = "oUF_Phanx ist ein Layout für Haste's oUF Framework. Nutze diese Oberfläche um Grundeinstellungen zu konfigurieren."
L.Outline = "Schriftumriss"
L.PowerBG = "Ressourcenbalkenhintergrund"
L.PowerBG_Desc = "Die Helligkeit der Hintergrund des Ressourcenbalkens festlegen, relativ zu seiner Vordergrund."
L.PowerColor = "Ressourcenbalkenfarbe"
L.PowerColor_Desc = "Legt fest, wie die Ressourcenbalken eingefärbt werden."
L.PowerColorCustom = "Benutzerdefinierte Farbe"
L.PowerHeight = "Ressourcenbalkenhöhe"
L.PowerHeight_Desc = "Die Höhe des Ressourcenbalkens festlegen, als ein Prozent der Gesamthöhe des Fensters."
L.ReloadUI = "UI neuladen"
L.RuneBars = "Runenleiste anzeigen"
L.RuneBars_Desc = "Abklingzeitleisten für Ihre Runen über dem Spielerfenster anzeigen."
L.Texture = "Textur"
L.Thick = "Dick"
L.Thin = "Dünn"
L.ThreatLevels = "Bedrohungstufen anzeigen"
L.ThreatLevels_Desc = "Detaillierte Bedrohungstufen anzeigen, statt einer einfachen Aggro-Status."
L.TotemBars = "Totemleisten anzeigen"
L.TotemBars_Desc = "Zeitleisten für Ihre Totems über dem Spielerfenster anzeigen."
