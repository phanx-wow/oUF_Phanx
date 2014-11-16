--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx

	Please DO NOT upload this addon to other websites, or post modified
	versions of it. However, you are welcome to include a copy of it
	WITHOUT CHANGES in compilations posted on Curse and/or WoWInterface.
	You are also welcome to use any/all of its code in your own addon, as
	long as you do not use my name or the name of this addon ANYWHERE in
	your addon, including its name, outside of an optional attribution.
----------------------------------------------------------------------]]

local _, ns = ...
local colors = oUF.colors
local _, playerClass = UnitClass("player")

------------------------------------------------------------------------

local prototype = {}

function prototype:PostCastStart(unit, name, rank, castid)
	if unit == "focus" and UnitIsUnit("focus", "target") then
		self.duration = self.casting and self.max or 0
		return
	end

	local color
	if UnitIsUnit(unit, "player") then
		color = colors.class[playerClass]
	elseif self.interrupt then
		color = colors.uninterruptible
	elseif UnitIsFriend(unit, "player") then
		color = colors.reaction[5]
	else
		color = colors.reaction[1]
	end
	local r, g, b = color[1], color[2], color[3]
	self:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
	self.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)

	local safezone = self.SafeZone
	if safezone then
		local width = safezone:GetWidth()
		if width and width > 0 and width <= self:GetWidth() then
			self:GetStatusBarTexture():SetDrawLayer("ARTWORK")
			safezone:SetDrawLayer("BORDER")
			safezone:SetWidth(width)
		else
			safezone:Hide()
		end
	end
	self.__castType = "CAST"
end

function prototype:PostChannelStart(unit, name, rank, text)
	local color
	if UnitIsUnit(unit, "player") then
		color = colors.class[playerClass]
	elseif self.interrupt then
		color = colors.reaction[4]
	elseif UnitIsFriend(unit, "player") then
		color = colors.reaction[5]
	else
		color = colors.reaction[1]
	end
	local r, g, b = color[1], color[2], color[3]
	self:SetStatusBarColor(r * 0.6, g * 0.6, b * 0.6)
	self.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)

	local safezone = self.SafeZone
	if safezone then
		local width = safezone:GetWidth()
		if width and width > 0 and width <= self:GetWidth() then
			self:GetStatusBarTexture():SetDrawLayer("BORDER")
			safezone:SetDrawLayer("ARTWORK")
			safezone:SetWidth(width)
		else
			safezone:Hide()
		end
	end
	self.__castType = "CHANNEL"
end

function prototype:CustomDelayText(duration)
	self.Time:SetFormattedText("%.1f|cffff0000%.1f|r", self.max - duration, -self.delay)
end

function prototype:CustomTimeText(duration)
	self.Time:SetFormattedText("%.1f", self.max - duration)
end

------------------------------------------------------------------------

function ns.AddCastbar(self)
	local unit = self.spawnunit
	local config = ns.config
	local uconfig = ns.uconfig[unit]
	local height = config.height * (uconfig.height or 1) * (1 - config.powerHeight)

	local Castbar = ns.CreateStatusBar(self)
	Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", height, -10)
	Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -10)
	Castbar:SetHeight(height)

	local Icon = Castbar:CreateTexture(nil, "BACKDROP")
	Icon:SetPoint("TOPRIGHT", Castbar, "TOPLEFT", 0, 0)
	Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", 0, 0)
	Icon:SetWidth(height)
	Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	Castbar.Icon = Icon

	local Spark = Castbar:CreateTexture(nil, "OVERLAY")
	Spark:SetSize(height, height * 2.5)
	Spark:SetAlpha(0.5)
	Spark:SetBlendMode("ADD")
	Castbar.Spark = Spark

	if unit == "player" then
		local SafeZone = Castbar:CreateTexture(nil, "BORDER")
		SafeZone:SetTexture(Castbar.texture:GetTexture())
		SafeZone:SetVertexColor(1, 0.5, 0, 0.75)
		tinsert(ns.statusbars, SafeZone)
		Castbar.SafeZone = SafeZone

		Castbar.Time = ns.CreateFontString(Castbar, 20, "RIGHT")
		Castbar.Time:SetPoint("RIGHT", Castbar, "RIGHT", -4, 0)

	elseif (uconfig.width or 1) > 0.75 then
		Castbar.Text = ns.CreateFontString(Castbar, 16, "LEFT")
		Castbar.Text:SetPoint("LEFT", Castbar, "LEFT", 4, 0)
	end

	ns.CreateBorder(Castbar, nil, nil, nil, "OVERLAY")
	Castbar:SetBorderSize(nil, height, 0, 0, 0)

	for k, v in pairs(prototype) do
		Castbar[k] = v
	end

	return Castbar
end