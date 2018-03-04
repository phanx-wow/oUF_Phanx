--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright 2008-2018 Phanx <addons@phanx.net>. All rights reserved.
	https://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	https://www.curseforge.com/wow/addons/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
----------------------------------------------------------------------]]

local _, ns = ...
local Orbs, OrbStatusBar = {}, {}
ns.Orbs = Orbs

------------------------------------------------------------------------
--	Create a new orb group.
--
function Orbs.Create(parent, num, size, statusbar, orientation, reverse, style)
	-- normal direction is LTR or TTB, reverse is RTL or BTT
	local orbs = {}
	for i = 1, num do
		local orb = CreateFrame("Frame", "oUFPhanxOrb"..random(100000), parent)
		orb:SetSize(size or 20, size or 20)
		orb.size = size or 20

		orb.bg = orb:CreateTexture(nil, "BACKGROUND")
		orb.bg:SetAllPoints(true)
		orb.bg:SetTexture("Interface\\AddOns\\oUF_Phanx\\media\\OrbBG")

		orb.fg = orb:CreateTexture(nil, "ARTWORK")
		orb.fg:SetAllPoints(true)
		orb.fg:SetTexture("Interface\\AddOns\\oUF_Phanx\\media\\OrbFG")

		if i > 1 then
			if reverse then
				orb:SetPoint("LEFT", orbs[i-1], "RIGHT", -2, 0)
			else
				orb:SetPoint("RIGHT", orbs[i-1], "LEFT", 2, 0)
			end
		end

		if statusbar then
			local spiral = CreateFrame("Cooldown", nil, orb)
			spiral.noCooldownCount = true
			spiral.noOmniCC = true
			--spiral:SetDrawEdge(true)
			spiral:SetReverse(false)
			spiral:Hide()
			spiral:SetScript("OnUpdate", OrbStatusBar.Cooldown_OnUpdate)
			spiral.orb = orb
			orb.spiral = spiral

			for k, v in pairs(OrbStatusBar) do
				orb[k] = v
			end

			orb:SetOrientation(orientation)
			orb:SetReverseFill(reverse)
			orb:SetStyle(style)
		end

		orb.id = i
		orb.orbs = orbs
		orb.style = style or "StatusBar"
		orbs[i] = orb
	end

	orbs.areOrbs = true
	for k, v in pairs(Orbs) do
		if k ~= "Create" then
			orbs[k] = v
		end
	end

	return orbs
end

------------------------------------------------------------------------
--	Update an orb group
--
function Orbs.Update(orbs, cur, max)
	cur = cur or 0
	max = max or orbs.max or #orbs
	--print("Orbs.Update", cur, max)
	if cur == 0 or max == 0 then
		for i = 1, #orbs do
			orbs[i]:Hide()
		end
	else
		--local full = cur == max
		for i = 1, #orbs do
			local orb = orbs[i]
			if i <= cur then
				--print(i, "<= cur", cur)
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
	--print("SetValue", orb.id, value)
	orb.value = value

	if value == 0 then
		--print("ZERO VALUE")
		orb.bg:SetVertexColor(0.4, 0.4, 0.4)
		orb.bg:SetAlpha(0.5)

		orb.fg:ClearAllPoints()
		orb.fg:SetAllPoints(orb)
		orb.fg:SetTexCoord(0, 1, 0, 1)
		orb.fg:Hide()

		orb.spiral:Hide()
		return
	end

	orb.bg:SetVertexColor(0.25, 0.25, 0.25)
	orb.bg:SetAlpha(1)
	orb.fg:Show()

	-- Cooldown style
	if orb.style == "Cooldown" and value > 0 then
		return orb.spiral:Show()
	else
		orb.spiral:Hide()
	end

	-- StatusBar style
	local min, max = orb.minValue or 0, orb.maxValue or 1
	--print("min", min, "max", max)
	if value < min then
		value = min
	elseif value > max then
		value = max
	end

	local fg = orb.fg
	local size = orb.size
	local percent = (value - min) / (max - min)
	--print("percent", percent)
	if orb.orientation == "VERTICAL" then
		--print("VERTICAL", reverse)
		if orb.reverse then
			fg:ClearAllPoints()
			fg:SetPoint("TOPLEFT")
			fg:SetPoint("TOPRIGHT")
			fg:SetHeight(percent * size)
			fg:SetTexCoord(0, 1, 0, percent)
		else
			fg:ClearAllPoints()
			fg:SetPoint("BOTTOMLEFT")
			fg:SetPoint("BOTTOMRIGHT")
			fg:SetHeight(percent * size)
			fg:SetTexCoord(0, 1, 1 - percent, 1)
		end
	else -- default to HORIZONTAL
		--print("HORIZONTAL", reverse)
		if orb.reverse then
			fg:ClearAllPoints()
			fg:SetPoint("TOPRIGHT")
			fg:SetPoint("BOTTOMRIGHT")
			fg:SetWidth(percent * size)
			fg:SetTexCoord(1 - percent, 1, 0, 1)
		else
			fg:ClearAllPoints()
			fg:SetPoint("TOPLEFT")
			fg:SetPoint("BOTTOMLEFT")
			fg:SetWidth(percent * size)
			fg:SetTexCoord(0, percent, 0, 1)
		end
	end
end

function OrbStatusBar.SetMinMaxValues(orb, min, max)
	if not min or not max then min, max = 0, 1 end
	if min == orb.minValue and max == orb.maxValue then return end

	orb.minValue = min
	orb.maxValue = max

	local value = orb.value
	orb.value = nil
	orb:SetValue(value)
end

------------------------------------------------------------------------
--	Set statusbar properties

function OrbStatusBar.SetOrientation(orb, orientation)
	orb.orientation = orientation or orb.orientation or "HORIZONTAL"
end

function OrbStatusBar.SetReverseFill(orb, reverse)
	orb.reverse = reverse
end

------------------------------------------------------------------------
--	Switch between statusbar mode and cooldown mode

function OrbStatusBar.SetStyle(orb, style)
	if style and style:upper() == "COOLDOWN" then
		if value > 0 and orb.maxValue > 0 then

		end
		orb.style = "Cooldown"
		local value = orb.value
		orb:SetValue(0)
		orb:SetValue(value)
	else
		orb.style = "StatusBar"
		orb.spiral:Hide()
	end
end

------------------------------------------------------------------------
--	Update a cooldown spiral

local GetTime = GetTime

function OrbStatusBar.Cooldown_OnUpdate(spiral, elapsed)
	spiral:SetCooldown(GetTime() - spiral.orb.value, spiral.orb.maxValue)
end

------------------------------------------------------------------------
--	Shortcuts

function Orbs.SetOrientation(orbs, orientation)
	for i = 1, #orbs do
		orbs[i]:SetOrientation(orientation)
	end
end

function Orbs.GetOrientation(orbs)
	return orbs[i].orientation
end

function Orbs.SetReverseFill(orbs, reverse)
	for i = 1, #orbs do
		orbs[i]:SetReverseFill(reverse)
	end
end

function Orbs.GetReverseFill(orbs)
	return orbs[i].reverse
end

function Orbs.SetStyle(orbs, style)
	for i = 1, #orbs do
		orbs[i]:SetStyle(style)
	end
end

function Orbs.GetStyle(orbs)
	return orbs[i].style
end
