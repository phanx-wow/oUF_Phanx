--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	zhCN | 简体中文 | Simplified Chinese
	Last updated: 2011-12-25 by wowuicn @ CurseForge
----------------------------------------------------------------------]]

if GetLocale() ~= "zhCN" then return end

local _, ns = ...
local L = {}
ns.L = L

L["B"] = " 首领"
L["E"] = " 精英"
L["R"] = " 罕见"

L[" Be"] = " 野兽"
L[" De"] = " 恶魔"
L[" Dr"] = " 龙类"
L[" El"] = " 元素"
L[" Gi"] = " 巨人"
L[" Hu"] = " 人型"
L[" Me"] = " 机械"
L[" Un"] = " 亡灵"

L["oUF_Phanx is a layout for Haste's oUF framework. Use this panel to configure some basic options for this layout."] = "oUF_Phanx是oUF头像的一款布局模块. 使用这个面板来做一些选项配置。"

L["Texture"] = "材质"
L["Select a texture for health, power, and other bars."] = "选择生命条, 能力条和其他条的材质。"

L["Font"] = "字体"
L["Select a typeface for text on the frames."] = "选择所用的字体。"
L["Font Outline"] = "字体描边"
L["Select an outline weight for text on the frames."] = "选择字体描边方式。"
L["None"] = "无"
L["Thin"] = "细"
L["Thick"] = "粗"

L["Border Size"] = "边框大小"
L["Change the size of the frame borders."] = "修正框体边框的大小。"
L["Border color"] = "边框颜色"
L["Change the default frame border color."] = "修改默认框体边框的颜色。"

L["Filter debuff highlight"] = "过滤Debuff高亮"
L["Show the debuff highlight only for debuffs you can dispel."] = "仅高亮显示你可以驱散的Debuff。"
L["Ignore own heals"] = "忽略自身的治疗"
L["Show only incoming heals cast by other players."] = "仅显示其他玩家施放的你所接受的治疗。"
L["Show threat levels"] = "显示仇恨等级"
L["Show threat levels instead of binary aggro status."] = "显示仇恨等级。"

L["Show druid mana bar"] = "显示德鲁伊法力条"
L["Show a mana bar while you are in Cat Form or Bear Form."] = "当你在猫或熊形态时显示法力条。"
L["Show eclipse bar"] = "显示月蚀条"
L["Show an eclipse bar above the player frame."] = "在玩家头像上面显示月蚀条。"
L["Show eclipse bar icons"] = "显示月蚀条图标"
L["Show animated moon and sun icons on either end of the eclipse bar."] = "在月蚀条的左右2侧显示动态月亮和太阳图标。"
L["This option will not take effect until the next time you log in or reload your UI."] = "这个选项将在你重新登录或重载插件后生效。"

L["Bar Colors"] = "条颜色"
L["Use this panel to configure the colors used for different parts of the unit frames created by this layout."] = "使用这个面板来配置这个头像的不同部分的颜色。"

L["Health color mode"] = "生命颜色模式"
L["Change how health bars are colored."] = "修改生命条的着色。"
L["Health bar color"] = "生命条颜色"
L["Change the health bar color."] = "修改生命条颜色。"
L["Health background intensity"] = "生命背景亮度"
L["Change the brightness of the health bar background color, relative to the foreground color."] = "修改生命条背景颜色的亮度, 相对于前景色。"

L["Power color mode"] = "能力颜色模式"
L["Change how power bars are colored."] = "修改能力条的着色。"
L["Power bar color"] = "能力条颜色"
L["Change the power bar color."] = "修改能力条颜色。"
L["Power background intensity"] = "能力背景亮度"
L["Change the brightness of the power bar background color, relative to the foreground color."] = "修改能力条背景颜色的亮度, 相对于前景色。"

L["By Class"] = "按职业"
L["By Health"] = "按生命值"
L["By Power Type"] = "按能力值类型"
L["Custom"] = "自定义"