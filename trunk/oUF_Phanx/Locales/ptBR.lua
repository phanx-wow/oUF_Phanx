--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	ptBR | Português (Brasil) | Brazilian Portuguese
	Last updated:
----------------------------------------------------------------------]]

if not GetLocale():match("^pt") then return end

local _, ns = ...
local L = {}
ns.L = L

L["B"] = "J"
L["E"] = "E"
L["R"] = "R"

L[" Be"] = " Fe"
L[" De"] = " De"
L[" Dr"] = " Dr"
L[" El"] = " El"
L[" Gi"] = " Gi"
L[" Hu"] = " Hu"
L[" Me"] = " Me"
L[" Un"] = " Re"

L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = "oUF_Phanx é um esquema de quadros de unidade para oUF. Estas opções alterar algumas configurações básicas para os quadros."

L["Texture"] = "Textura"
L["Select a texture for health, power, and other bars."] = "Escolher uma textura para as barras da vida, de saúde, e outros."

L["Font"] = "Fonte"
L["Select a typeface for text on the frames."] = "Escolher uma fonte para o texto sobre os quadros."
L["Select an outline weight for text on the frames."] = "Escholer uma espessura de contorno para o texto sobre os quadros."
L["Font Outline"] = "Contorno de fonte"
L["None"] = "Nenhum"
L["Thin"] = "Fino"
L["Thick"] = "Grosso"

L["Border Size"] = "Tamanho da borda"
L["Change the size of the frame borders."] = "Alterar o tamanho da borda dos quadros."
L["Border color"] = "Cor da borda"
L["Change the default frame border color."] = "Alterar a cor padrão da borda dos quadros."

L["Filter debuff highlight"] = "Filtrar os penalidades em destaque"
L["Show the debuff highlight only for debuffs you can dispel."] = "Exibir somente penalidades dissipáveis em destaque."
L["Ignore own heals"] = "Ignorar própria cura"
L["Show only incoming heals cast by other players."] = "Mostrar apenas cura lançado por outros jogadores."
L["Show threat levels"] = "Níveis de ameaça"
L["Show threat levels instead of binary aggro status."] = "Mostrar os níveis de ameaça em vez de agro."

L["Show druid mana bar"] = "Mostrar a barra de mana em formas"
L["Show a mana bar while you are in Cat Form or Bear Form."] = "Mostrar uma barra de mana quando você está na Forma de Felino ou Urso."
L["Show eclipse bar"] = "Barra de eclipse"
L["Show eclipse bar icons"] = "Ícones na barra de eclipse"
L["Show an eclipse bar above the player frame."] = "Mostrar uma barra de eclipse acima do quadro do jogador."
L["Show animated moon and sun icons on either end of the eclipse bar."] = "Mostrar ícones animados da lua e do sol em cada extremidade da barra de eclipse."
L["This option will not take effect until the next time you log in or reload your UI."] = "Esta opção não terá efeito até que a próxima vez que você recarregar a interface ou conectar."

L["Bar Colors"] = "Cores de barras"
L["Use this panel to configure the colors used for different parts of the unit frames created by this layout."] = "Estas opções alteram as cores usadas nos quadros de unidade."

L["Health color mode"] = "Modo de coloração de saúde"
L["Change how health bars are colored."] = "Alterar a forma como as barras da vida são coloridos."
L["Health bar color"] = "Cor da barra da vida"
L["Change the health bar color."] = "Alterar a cor da barra da vida."
L["Health background intensity"] = "Brilho do fundo da vida"
L["Change the brightness of the health bar background color, relative to the foreground color."] = "Alterar o brilho do fundo da barra da vida, em comparação com o primeiro plano."

L["Power color mode"] = "Modo de coloração de poder"
L["Change how power bars are colored."] = "Alterar a forma como as barras de poder são coloridos."
L["Power bar color"] = "Cor da barra do poder"
L["Change the power bar color."] = "Alterar a cor da barra de poder."
L["Power background intensity"] = "Intensidade do fundo de poder"
L["Change the brightness of the power bar background color, relative to the foreground color."] = "Alterar o brilho do fundo da barra de poder, em comparação com o primeiro plano."

L["By Class"] = "Por classe"
L["By Health"] = "Por vida"
L["By Power Type"] = "Por tipo de poder"
L["Custom"] = "Personalizado"