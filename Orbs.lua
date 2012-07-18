--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local Orbs, OrbStatusBar = {}, {}
ns.Orbs = Orbs

------------------------------------------------------------------------
--	Create a new orb group.
--
function Orbs.Create(parent, num, size, orientation, reverse)
	-- normal direction is LTR or TTB, reverse is RTL or BTT
	local orbs = {}
	for i = 1, num do
		local orb = CreateFrame("Frame", nil, parent)
		orb:SetSize(size or 20, size or 20)
		orb.size = size or 20

		orb.bg = orb:CreateTexture(nil, "BACKGROUND")
		orb.bg:SetAllPoints(true)
		orb.bg:SetTexture("Interface\\AddOns\\oUF_Phanx\\media\\OrbBG")

		orb.fg = orb:CreateTexture(nil, "ARTWORK")
		orb.fg:SetAllPoints(true)
		orb.fg:SetTexture("Interface\\AddOns\\oUF_Phanx\\media\\OrbFG")

		if orientation then
			orb.orientation = orientation
			orb.reverse = reverse
			for k, v in pairs(OrbStatusBar) do
				orb[k] = v
			end
		end

		orb.id = i
		orb.container = orbs
		orbs[i] = orb
	end
	orbs.Hide = Orbs.Hide
	orbs.Show = Orbs.Show
	orbs.Update = Orbs.Update
	return orbs
end

------------------------------------------------------------------------
--	Update an orb group
--
function Orbs.Update(orbs, num, max)
	max = max or orbs.max or #orbs
	--print("Orbs.Update", num, max)
	if num == 0 or max == 0 then
		for i = 1, #orbs do
			orbs[i]:Hide()
		end
	else
		--local full = num == max
		for i = 1, #orbs do
			local orb = orbs[i]
			if i <= num then
				--print(i, "<= num", num)
			--	if full then
			--		orb.bg:SetVertexColor(1, 0.9, 0.25)
			--	else
					orb.bg:SetVertexColor(0.25, 0.25, 0.25)
			--	end
				orb.bg:SetAlpha(1)
				orb.fg:Show()
				orb:Show()
			elseif i <= max then
				--print(i, "<= max", max)
				orb.bg:SetVertexColor(0.4, 0.4, 0.4)
				orb.bg:SetAlpha(0.5)
				orb.fg:Hide()
				orb:Show()
			else
				--print(i, "Hide")
				orb:Hide()
			end
		end
	end
end

------------------------------------------------------------------------
--	Hide all the orbs
--
function Orbs:Hide()
	for i = 1, #self do
		self[i]:Hide()
	end
end

------------------------------------------------------------------------
--	Show all the orbs
--
function Orbs:Show()
	for i = 1, #self do
		self[i]:Show()
	end
end

------------------------------------------------------------------------
--	Update individual orbs as status bars
--
function OrbStatusBar.GetValue(orb)
	return orb.value or orb.maxValue or 1
end

function OrbStatusBar.SetValue(orb, value)
	if value == orb.value then return end
	local min, max = orb.minValue or 0, orb.maxValue or 1
	local percent = (value - min) / (max - min)
	local size = orb.size
	if orientation == "VERTICAL" then
		if orb.reverse then
			orb.fg:SetPoint("TOPLEFT")
			orb.fg:SetPoint("TOPRIGHT")
			orb.fg:SetHeight(percent * size)
			orb.fg:SetWidth(size)
			orb.fg:SetTexCoord(0, 1, percent, 1)
		else
			orb.fg:SetPoint("BOTTOMLEFT")
			orb.fg:SetPoint("BOTTOMRIGHT")
			orb.fg:SetHeight(percent * orb.size)
			orb.fg:SetWidth(size)
			orb.fg:SetTexCoord(0, 1, 0, percent)
		end
	else -- default to HORIZONTAL
		if orb.reverse then
			orb.fg:SetPoint("TOPRIGHT")
			orb.fg:SetPoint("BOTTOMRIGHT")
			orb.fg:SetWidth(percent * orb.size)
			orb.fg:SetHeight(size)
			orb.fg:SetTexCoord(percent, 1, 0, 1)
		else
			orb.fg:SetPoint("TOPLEFT")
			orb.fg:SetPoint("BOTTOMLEFT")
			orb.fg:SetWidth(percent * orb.size)
			orb.fg:SetHeight(size)
			orb.fg:SetTexCoord(0, percent, 0, 1)
		end
	end
	orb.value = value
end

function OrbStatusBar.SetMinMaxValues(orb, min, max)
	orb.minValue = min or 0
	orb.maxValue = max or 1

	local value = orb.value
	orb.value = nil
	orb:SetValue(value)
end

function OrbStatusBar.SetOrientation(orb, direction)
	orb.direction = direction or orb.direction
end

function OrbStatusBar.SetReverseFill(orb, reverse)
	orb.reverse = reverse
end