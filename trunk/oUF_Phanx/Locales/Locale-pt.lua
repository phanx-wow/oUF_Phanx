--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Portuguese localization
	Last updated 2012-11-30 by Phanx
	***
----------------------------------------------------------------------]]

if not strmatch(GetLocale(), "^pt") then return end
local _, private = ...
local L = private.L

L.BorderColor = "Cor da borda"
L.BorderColor_Desc = "Alterar a cor padrão da borda dos quadros."
L.BorderSize = "Tamanho da borda"
L.ColorClass = "Colore por classe"
L.ColorCustom = "Use uma cor personalizada"
L.ColorHealth = "Colore por vida"
L.ColorPower = "Colore por tipo de poder"
L.Colors = "Cores"
L.Colors_Desc = "Estas opções alteram as cores usadas nos quadros de unidade."
L.DruidManaBar = "Barra de mana em formas"
L.DruidManaBar_Desc = "Mostrar uma barra de mana quando você está na Forma de Felino ou Urso."
L.EclipseBar = "Barra de eclipse"
L.EclipseBar_Desc = "Mostrar uma barra de eclipse acima do quadro do jogador."
L.EclipseBarIcons = "Ícones na barra de eclipse"
L.EclipseBarIcons_Desc = "Mostrar ícones animados da lua e do sol em cada extremidade da barra de eclipse."
L.FilterDebuffHighlight = "Filtrar o destaque das penalidades"
L.FilterDebuffHighlight_Desc = "Destaque a borda do quadro apenas para penalidades que você pode dissipar."
L.Font = "Fonte"
L.HealthBG = "Brilho do fundo da vida"
L.HealthBG_Desc = "Alterar o brilho do fundo da barra da vida, em comparação com o primeiro plano."
L.HealthColor = "Coloração da barra da vida"
L.HealthColor_Desc = "Alterar a forma como as barras da vida são coloridos."
L.HealthColorCustom = "Cor personalizada de vida"
L.IgnoreOwnHeals = "Ignorar própria cura"
L.IgnoreOwnHeals_Desc = "Mostrar apenas cura lançado por outros jogadores."
L.None = "Nenhum"
L.OptionRequiresReload = "Esta opção não terá efeito até que a próxima vez que você recarregar a interface ou conectar."
L.Options_Desc = "oUF_Phanx é um esquema de quadros de unidade para oUF. Estas opções alterar algumas configurações básicas para os quadros."
L.Outline = "Contorno de text"
L.PowerBG = "Brilho do fundo de poder"
L.PowerBG_Desc = "Alterar o brilho do fundo da barra de poder, em comparação com o primeiro plano."
L.PowerColor = "Coloração da barra de poder"
L.PowerColor_Desc = "Alterar a forma como as barras de poder são coloridos."
L.PowerColorCustom = "Cor personalizada de poder"
--L.RuneBars = "Show rune bars"
--L.RuneBars_Desc = "Show cooldown timer bars for your runes above the player frame."
L.Texture = "Textura das barras"
L.Thick = "Grosso"
L.Thin = "Fino"
L.ThreatLevels = "Níveis de ameaça"
L.ThreatLevels_Desc = "Show more granular threat levels, instead of simple aggro status."
--L.TotemBars = "Show totem bars"
--L.TotemBars_Desc = "Show timer bars for your totems above the player frame."