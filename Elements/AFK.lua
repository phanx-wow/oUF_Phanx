--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2017 Phanx <addons@phanx.net>. All rights reserved.
	https://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
------------------------------------------------------------------------
	Element to display AFK times on oUF frames.
	Based on code from oUF_Smurf by Merl@chainweb.net.
	Written and distributed with permission.

	Minimal usage:
	frame.AFK = frame:CreateFontString(nil, "OVERLAY")
	frame.AFK:SetPoint("CENTER")
----------------------------------------------------------------------]]

if select(4, GetAddOnInfo("oUF_AFK")) then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "AFK element requires oUF")

local times = {}
local elements = {}

local updater = CreateFrame("Frame")
updater:Hide()

local lastUpdate = 0
local floor, mod, next, pairs, GetTime = floor, mod, next, pairs, GetTime
updater:SetScript("OnUpdate", function(self, elapsed)
	lastUpdate = lastUpdate + elapsed
	if lastUpdate > 0.2 then
		lastUpdate = 0
		if not next(times) then
			self:Hide()
		end
		for element, unit in pairs(elements) do
			local t = times[unit]
			if t then
				t = GetTime() - t
				element:SetFormattedText("AFK %d:%02.0f", floor(t / 60), mod(t, 60))
			else
				elements[element] = nil
				element:SetText("") -- nil gives it 0 height which might disturb the layout
			end
		end
	end
end)

local function Update(self, event, unit)
	if unit ~= self.unit then return end

	local element = self.AFK
	local afk = UnitIsAFK(unit)
	--print("AFK", event, unit, afk, times[unit])

	if afk and not times[unit] then
		times[unit] = GetTime()
		elements[element] = unit
		updater:Show()
	elseif times[unit] and not afk then
		times[unit] = nil
		element:SetText("")
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.AFK
	if not element then return end

	element.__owner = self
	element.ForceUpdate = Update

	if not element:GetFont() then
		element:SetFontObject("GameFontHighlightSmall")
	end

	self:RegisterEvent("PLAYER_FLAGS_CHANGED", Update)
	return true
end

local function Disable(self)
	local element = self.AFK
	if not element then return end

	self:UnregisterEvent("PLAYER_FLAGS_CHANGED", Update)
	element:Hide()
end

oUF:AddElement("AFK", Update, Enable, Disable)