--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Simplified Chinese localization
	Last updated 2011-12-25 by wowuicn
	***
----------------------------------------------------------------------]]

if GetLocale() ~= "zhCN" then return end
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
L.BorderColor = "边框颜色"
L.BorderColor_Desc = "修改默认框体边框的颜色。"
L.BorderSize = "边框大小"
L.ColorClass = "按职业"
L.ColorCustom = "自定义"
L.ColorHealth = "按生命值"
L.ColorPower = "按能力值类型"
L.Colors = "条颜色"
L.Colors_Desc = "使用这个面板来配置这个头像的不同部分的颜色。"
--L.DeleteAura = "Delete Aura"
--L.DeleteAura = "Remove your custom filter for this aura."
L.DruidManaBar = "显示德鲁伊法力条"
L.DruidManaBar_Desc = "当你在猫或熊形态时显示法力条。"
L.EclipseBar = "显示月蚀条"
L.EclipseBar_Desc = "在玩家头像上面显示月蚀条。"
L.EclipseBarIcons = "显示月蚀条图标"
L.EclipseBarIcons_Desc = "在月蚀条的左右2侧显示动态月亮和太阳图标。"
L.FilterDebuffHighlight = "过滤Debuff高亮"
L.FilterDebuffHighlight_Desc = "仅高亮显示你可以驱散的Debuff。"
L.Font = "字体"
L.HealthBG = "生命背景亮度"
L.HealthBG_Desc = "修改生命条背景颜色的亮度, 相对于前景色。"
L.HealthColor = "生命颜色模式"
L.HealthColor_Desc = "修改生命条的着色。"
L.HealthColorCustom = "生命条颜色"
L.IgnoreOwnHeals = "忽略自身的治疗"
L.IgnoreOwnHeals_Desc = "仅显示其他玩家施放的你所接受的治疗。"
L.None = "无"
L.OptionRequiresReload = "这个选项将在你重新登录或重载插件后生效。"
L.Options_Desc = "oUF_Phanx是oUF头像的一款布局模块. 使用这个面板来做一些选项配置。"
L.Outline = "字体描边"
L.PowerBG = "能力背景亮度"
L.PowerBG_Desc = "修改能力条背景颜色的亮度, 相对于前景色。"
L.PowerColor = "能力颜色模式"
L.PowerColor_Desc = "修改能力条的着色。"
L.PowerColorCustom = "能力条颜色"
--L.RuneBars = "Show rune bars"
--L.RuneBars_Desc = "Show cooldown timer bars for your runes above the player frame."
L.Texture = "材质"
L.Thick = "粗"
L.Thin = "细"
L.ThreatLevels = "显示仇恨等级"
L.ThreatLevels_Desc = "显示仇恨等级。"
--L.TotemBars = "Show totem bars"
--L.TotemBars_Desc = "Show timer bars for your totems above the player frame."