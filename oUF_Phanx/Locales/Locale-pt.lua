--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Portuguese localization
	***
----------------------------------------------------------------------]]

if not strmatch(GetLocale(), "^pt") then return end
local _, private = ...
local L = private.L

--L.AddAura = "Add Aura"
--L.AddAura_Desc = "Enter a Spell ID and press Enter."
--L.AddAura_Invalid = "That is not a valid Spell ID!"
--L.AddAura_Note = "To find the Spell ID for a spell, look it up on Wowhead.com and copy the number out of the UR--L."
--L.Auras = "Auras"
--L.Auras_Desc = "Add new buffs and debuffs to show, or change the filtering behavior of predefined auras."
--L.AuraFilter0 = "Never show"
--L.AuraFilter1 = "Always show"
--L.AuraFilter2 = "Only show mine"
--L.AuraFilter3 = "Only show on friendly units"
--L.AuraFilter4 = "Only show on myself"
L.BorderColor = "Cor da borda"
L.BorderColor_Desc = "Alterar a cor padrão da borda dos quadros."
L.BorderSize = "Tamanho da borda"
L.ColorClass = "Colore por classe"
L.ColorCustom = "Use uma cor personalizada"
L.ColorHealth = "Colore por vida"
L.ColorPower = "Colore por tipo de poder"
L.Colors = "Cores"
L.Colors_Desc = "Estas opções alteram as cores usadas nos quadros de unidade."
--L.DeleteAura = "Delete Aura"
--L.DeleteAura_Desc = "Remove your custom filter for this aura."
L.DruidManaBar = "Barra de mana em formas"
L.DruidManaBar_Desc = "Mostrar uma barra de mana quando você está na Forma de Felino ou Urso."
L.EclipseBar = "Barra de eclipse"
L.EclipseBar_Desc = "Mostrar uma barra de eclipse acima do quadro do jogador."
L.EclipseBarIcons = "Ícones na barra de eclipse"
L.EclipseBarIcons_Desc = "Mostrar ícones animados da lua e do sol em cada extremidade da barra de eclipse."
L.FilterDebuffHighlight = "Filtrar o destaque das penalidades"
L.FilterDebuffHighlight_Desc = "Destaque a borda do quadro apenas para penalidades que você pode dissipar."
L.Font = "Fonte"
--L.FrameHeight = "Base Height"
--L.FrameHeight_Desc = "Set the base frame height."
--L.FrameWidth = "Base Width"
--L.FrameWidth_Desc = "Set the base frame width. Some frames are proportionally wider or narrower."
L.HealthBG = "Brilho do fundo da vida"
L.HealthBG_Desc = "Alterar o brilho do fundo da barra da vida, em comparação com o primeiro plano."
L.HealthColor = "Coloração da barra da vida"
L.HealthColor_Desc = "Alterar a forma como as barras da vida são coloridos."
L.HealthColorCustom = "Cor personalizada de vida"
L.IgnoreOwnHeals = "Ignorar própria cura"
L.IgnoreOwnHeals_Desc = "Mostrar apenas cura lançado por outros jogadores."
--L.MoreSettings = "More Settings"
--L.MoreSettings_Desc = "Estas opções não terão efeito até que a próxima vez que você recarregar a interface ou conectar."
L.None = "Nenhum"
L.Options_Desc = "oUF_Phanx é um esquema de quadros de unidade para oUF. Estas opções alterar algumas configurações básicas para os quadros."
L.Outline = "Contorno de text"
L.PowerBG = "Brilho do fundo de poder"
L.PowerBG_Desc = "Alterar o brilho do fundo da barra de poder, em comparação com o primeiro plano."
L.PowerColor = "Coloração da barra de poder"
L.PowerColor_Desc = "Alterar a forma como as barras de poder são coloridos."
L.PowerColorCustom = "Cor personalizada de poder"
--L.PowerHeight = "Power Bar Height"
--L.PowerHeight_Desc = "Set the height of the power bar, as a percent of the total frame height."
--L.ReloadUI = "Reload UI"
L.RuneBars = "Barras das runas"
L.RuneBars_Desc = "Mostrar barras dos tempos de recarga de suas runas acima do quadro do jogador."
L.Texture = "Textura das barras"
L.Thick = "Grosso"
L.Thin = "Fino"
L.ThreatLevels = "Níveis de ameaça"
L.ThreatLevels_Desc = "Show more granular threat levels, instead of simple aggro status."
L.TotemBars = "Barras dos totens"
L.TotemBars_Desc = "Mostrar barras das durações de seus totens acima do quadro do jogador."
