--[[--------------------------------------------------------------------
	oUF_Phanx
	A fully featured, healer oriented layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info-oUF_Phanx.html
	Copyright ©2008–2009 Alyssa "Phanx" Kinley
	See README for license terms and additional information.

	This file adds support for party and partypet units.
----------------------------------------------------------------------]]

if not oUF_Phanx then return end

------------------------------------------------------------------------
--	Configuration starts here
------------------------------------------------------------------------

oUF_Phanx.settings.units.party = {
	width = 100,
	height = 25,
	power = true,
	reverse = true,
	point = { "BOTTOMLEFT", 150 + 200 + 60, -150 - 60 },
	header = true,
	attributes = {
		"showParty", true,
		"showRaid", false,
		"point", "BOTTOM",
		"xOffset", 0,
		"yOffset", 10
	},
}

oUF_Phanx.settings.units.partypet = {
	width = 100,
	height = 20,
	reverse = true,
	point = { "BOTTOMLEFT", 150 + 200 + 60 + 100 + 30, -150 - 60 },
	header = true,
	template = "SecureGroupPetHeaderTemplate",
	attributes = {
		"showParty", true,
		"showRaid", false,
		"point", "BOTTOM",
		"xOffset", 0,
		"yOffset", 10
	},
}

------------------------------------------------------------------------
--	Configuration ends here
------------------------------------------------------------------------

local debug = oUF_Phanx.debug

local colors = oUF_Phanx.colors
local settings = oUF_Phanx.settings

local AbbreviateValue = oUF_Phanx.AbbreviateValue
local GetUnitColor = oUF_Phanx.GetUnitColor

------------------------------------------------------------------------
--	Update health bar and text
------------------------------------------------------------------------

local function UpdateHealth(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	--debug("UpdateHealth: %s, %s", event, unit)

	local r, g, b

	if not UnitIsConnected(unit) then
		r, g, b = unpack(colors.offline)
		bar:SetValue(self.reverse and 0 or max)
		bar.value:SetText(L["Offline"])
		bar.value:SetTextColor(r, g, b)
	elseif UnitIsDeadOrGhost(unit) then			
		if UnitIsGhost(unit) then
			r, g, b = unpack(colors.ghost)
			bar:SetValue(self.reverse and 0 or max)
			bar.value:SetText(L["Ghost"])
			bar.value:SetTextColor(r, g, b)
		elseif UnitIsDead(unit) then
			r, g, b = unpack(colors.dead)
			bar:SetValue(self.reverse and 0 or max)
			bar.value:SetText(L["Dead"])
			bar.value:SetTextColor(r, g, b)
		end
		if self.resurrectionStatus then
			bar.value:SetText(self.resurrectionStatus)
			bar.value:SetTextColor(unpack(self.resurrectionStatusColor))
		end
	else
		r, g, b = unpack(GetUnitColor(unit))
		bar:SetValue(self.reverse and max - min or min)
		local text
		if min < max then
			bar.value:SetText(AbbreviateValue(max - min))
		else
			bar.value:SetText(UnitName(unit):sub(1, 4))
		end
		bar.value:SetTextColor(1, 1, 1)
	end

	if self.reverse then
		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * .2, g * .2, b * .2)
	else
		bar:SetStatusBarColor(r * .2, g * .2, b * .2)
		bar.bg:SetVertexColor(r, g, b)
	end
end

------------------------------------------------------------------------
--	Update power bar and text
------------------------------------------------------------------------

local function UpdatePower(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	--debug("UpdatePower: %s, %s", event, unit)

	if max == 0 or UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)
		bar:SetStatusBarColor(0, 0, 0)
		bar.bg:SetVertexColor(0, 0, 0)
		if bar.value then
			bar.value:SetText()
		end
		return
	end

	local r, g, b = unpack(colors.power[type])

	if bar.value and UnitPowerType(unit) == 0 then
		if min < max then
			bar.value:SetFormattedText("%s|cff%02x%02x%02x.%s|r", AbbreviateValue(min), r * 255, g * 255, b * 255, AbbreviateValue(max))
		else
			bar.value:SetText(max)
		end
	end

	if self.reverse then
		bar:SetValue(max - min)

		bar:SetStatusBarColor(r * .2, g * .2, b * .2)
		bar.bg:SetVertexColor(r, g, b)
	else
		bar:SetValue(min)

		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * .2, g * .2, b * .2)
	end
end

------------------------------------------------------------------------
--	Setup a frame
------------------------------------------------------------------------

local BORDER_GAP = settings.backdrop.edgeSize - 1 -- +1 instead for Grid style border

local function Spawn(self, unit)
	-- debug("Spawn: %s", unit)

	self.disallowVehicleSwap = true

	local unit_settings
	if not unit then
		unit_settings = settings.units[string.match(self:GetParent():GetName():lower(), "^ouf_phanx(%a+)$")]
	else
		unit_settings = settings.units[unit]
	end

	self.reverse = unit_settings.reverse

	self.menu = oUF_Phanx.menu
	self:SetAttribute("*type2", "menu")

	self:RegisterForClicks("anyup")

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	local width = unit_settings.width + (BORDER_GAP * 2)
	self:SetAttribute("initial-width", width)
	self:SetWidth(width)

	local height = unit_settings.height + (BORDER_GAP * 2) + (unit_settings.power and 1 or 0)
	self:SetAttribute("initial-height", height)
	self:SetHeight(height)

	self:SetFrameStrata("BACKGROUND")
	self:SetFrameLevel(0)
	self:SetBackdrop(settings.backdrop)
	self:SetBackdropColor(unpack(settings.backdropColor))
	self:SetBackdropBorderColor(0, 0, 0, 0)

	self.overlay = CreateFrame("Frame", nil, self)
	self.overlay:SetFrameStrata("BACKGROUND")
	self.overlay:SetFrameLevel(2)
	self.overlay:SetAllPoints(self)

	-------------------------------------------------------------------
	--	Health bar, health text

	local hp = CreateFrame("StatusBar", nil, self)
	hp:SetFrameStrata("BACKGROUND")
	hp:SetFrameLevel(1)
	hp:SetStatusBarTexture(settings.statusbar)
	if unit_settings.vertical then
		hp:SetPoint("TOPLEFT", BORDER_GAP, -BORDER_GAP)
		hp:SetPoint("BOTTOMLEFT", BORDER_GAP, BORDER_GAP)
		hp:SetHeight(unit_settings.power and unit_settings.width / 5 * 4 or unit_settings.width)
		hp:SetStatusBarOrientation("VERTICAL")
	else
		hp:SetPoint("BOTTOMLEFT", BORDER_GAP, BORDER_GAP)
		hp:SetPoint("BOTTOMRIGHT", -BORDER_GAP, BORDER_GAP)
		hp:SetHeight(unit_settings.power and unit_settings.height / 5 * 4 or unit_settings.height)
	end

	hp.bg = hp:CreateTexture(nil, "BORDER")
	hp.bg:SetAllPoints(hp)
	hp.bg:SetTexture(settings.statusbar)

	hp.value = hp:CreateFontString(nil, "OVERLAY")
	hp.value:SetFont(settings.font, 20, "OUTLINE")
	hp.value:SetShadowOffset(0, 0)
	hp.value:SetTextColor(1, 1, 1)
	if not unit then
		hp.value:SetPoint("CENTER")
	elseif self.reverse then
		hp.value:SetPoint("LEFT", hp:GetHeight() / 2 - 8, 0)
	else
		hp.value:SetPoint("RIGHT", -hp:GetHeight() / 2 + 8, 0)
	end

	hp.frequentUpdates = true
	hp.Smooth = true

	self.Health = hp
	self.OverrideUpdateHealth = UpdateHealth

	-------------------------------------------------------------------
	--	Power bar

	if unit_settings.power then
		local pp = CreateFrame("StatusBar", nil, self)
		pp:SetFrameStrata("BACKGROUND")
		pp:SetFrameLevel(1)
		pp:SetStatusBarTexture(settings.statusbar)
		if unit_settings.vertical then
			pp:SetPoint("TOPRIGHT", -BORDER_GAP, -BORDER_GAP)
			pp:SetPoint("BOTTOMRIGHT", -BORDER_GAP, -BORDER_GAP)
			pp:SetHeight(unit_settings.width / 5)
			pp:SetStatusBarOrientation("VERTICAL")
		else
			pp:SetPoint("TOPLEFT", BORDER_GAP, -BORDER_GAP)
			pp:SetPoint("TOPRIGHT", -BORDER_GAP, -BORDER_GAP)
			pp:SetHeight(unit_settings.height / 5)
		end

		pp.bg = pp:CreateTexture(nil, "BORDER")
		pp.bg:SetAllPoints(pp)
		pp.bg:SetTexture(settings.statusbar)

		pp.Smooth = true

		self.Power = pp
		self.OverrideUpdatePower = UpdatePower
	end

	-------------------------------------------------------------------
	--	Resurrection status (oUF_ResurrectionStatus)

	self.ResurrectionStatus = UpdateHealth

	-------------------------------------------------------------------
	--	Group leader icon

	self.Leader = self.overlay:CreateTexture(nil, "OVERLAY")
	self.Leader:SetPoint("CENTER", self, "BOTTOMLEFT")
	self.Leader:SetWidth(16)
	self.Leader:SetHeight(16)
	self.Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")

	-------------------------------------------------------------------
	--	Raid target icon

	self.RaidIcon = self.overlay:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("CENTER", self, "TOP")
	self.RaidIcon:SetWidth(16)
	self.RaidIcon:SetHeight(16)
	self.RaidIcon:SetTexture("Interface\\GroupFrame\\UI-RaidTargetingIcons")

	-------------------------------------------------------------------
	--	Border and highlighting

	oUF_Phanx.AddBorder(self)
	for i, tex in ipairs(self.borderTextures) do
		tex:SetParent(self.Health)
	end

	self.DebuffHighlight = oUF_Phanx.UpdateBorder

	self.ThreatHighlight = oUF_Phanx.UpdateBorder
	self.ThreatHighlightLevels = false

	-------------------------------------------------------------------
	--	Range checking

	self.Range = true
	self.inRangeAlpha = 1
	self.outsideRangeAlpha = 0.5

	-------------------------------------------------------------------
	--	That's all, folks!

	return self
end

------------------------------------------------------------------------
--	Spawn more overlords!
------------------------------------------------------------------------

oUF:RegisterStyle("PhanxParty", Spawn)
oUF:SetActiveStyle("Phanx")
for unit, data in pairs(settings.units) do
	local p, x, y = unpack(data.point)
	local name = "oUF_Phanx" .. unit:gsub("target", "Target"):gsub("pet", "Pet", 1):gsub("%a", string.upper, 1)

	local f = oUF:Spawn("header", name, data.template)
	f:SetPoint(p, UIParent, "CENTER", x, y)
	f:SetManyAttributes(unpack(data.attributes))
	f:Show()
end

------------------------------------------------------------------------
--	Requires more vespene gas!
------------------------------------------------------------------------

local partyToggle = CreateFrame("Frame")
partyToggle:RegisterEvent("PLAYER_LOGIN")
partyToggle:RegisterEvent("PARTY_LEADER_CHANGED")
partyToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
partyToggle:RegisterEvent("RAID_ROSTER_UPDATE")
partyToggle:RegisterEvent("CVAR_UPDATE")
partyToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if GetNumRaidMembers() > 0 and GetCVar("hidePartyInRaid") == "1" then
			debug("Hiding party...")
			oUF_PhanxParty:Hide()
			oUF_PhanxPartyPet:Hide()
		else
			debug("Showing party...")
			oUF_PhanxParty:Show()
			oUF_PhanxPartyPet:Show()
		end
	end
end)

------------------------------------------------------------------------
--	The end.
------------------------------------------------------------------------