--[[--------------------------------------------------------------------
	oUF_Phanx
	A layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	Copyright ©2009–2010 Alyssa "Phanx" Kinley. All rights reserved.
	See README for license terms and additional information.
----------------------------------------------------------------------]]

local OUF_PHANX, namespace = ...
local oUF_Phanx = namespace.oUF_Phanx
if not oUF_Phanx then return end

local L = namespace.L

local debug = oUF_Phanx.debug
local si = oUF_Phanx.si
local AddBorder = oUF_Phanx.AddBorder
local SetBorderColor = oUF_Phanx.SetBorderColor
local SetBorderSize = oUF_Phanx.SetBorderSize
local UpdateBorder = oUF_Phanx.UpdateBorder
local UpdateDispelHighlight = oUF_Phanx.UpdateDispelHighlight
local UpdateThreatHighlight = oUF_Phanx.UpdateThreatHighlight

local playerClass = select(2, UnitClass("player"))

local settings
local SharedMedia

------------------------------------------------------------------------

local function UpdateName(self, event, unit)
	if self.unit ~= unit then return end
	-- debug("UpdateName: %s, %s", event, unit)

	local r, g, b
	if UnitIsDead(unit) then
		r, g, b = unpack(colors.dead)
	elseif UnitIsGhost(unit) then
		r, g, b = unpack(colors.ghost)
	elseif not UnitIsConnected(unit) then
		r, g, b = unpack(colors.offline)
	else
		local _, class = UnitClass(unit)
		r, g, b = unpack(colors.class[class] or colors.unknown)
	end

	self.Name:SetText(UnitName(unit))
	self.Name:SetTextColor(r, g, b)
end

------------------------------------------------------------------------

local function UpdateHealth(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	-- debug("UpdateHealth: %s, %s", event, unit)

	local r, g, b

	if not UnitIsConnected(unit) then
		r, g, b = unpack(colors.offline)
		bar:SetValue(self.reverse and 0 or max)
		bar.value:SetText("Offline")
		bar.value:SetTextColor(r, g, b)
	elseif UnitIsGhost(unit) then
		r, g, b = unpack(colors.ghost)
		bar:SetValue(self.reverse and 0 or max)
		bar.value:SetText("Ghost")
		bar.value:SetTextColor(r, g, b)
	elseif UnitIsDead(unit) then
		r, g, b = unpack(colors.dead)
		bar:SetValue(self.reverse and 0 or max)
		bar.value:SetText("Dead")
		bar.value:SetTextColor(r, g, b)
	else
		local _, class = UnitClass(unit)
		r, g, b = unpack(colors.class[class] or colors.unknown)
		bar:SetValue(self.reverse and max - min or min)
		if min < max then
			bar.value:SetFormattedText("%s|cffff6666-%s|r", si(max), si(max - min))
		else
			bar.value:SetText()
		end
		bar.value:SetTextColor(r, g, b)
	end

	if self.reverse then
		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * .2, g * .2, b * .2)
	else
		bar:SetStatusBarColor(r * .2, g * .2, b * .2)
		bar.bg:SetVertexColor(r, g, b)
	end

	if self.Name then
		self.Name:SetTextColor(r, g, b)
	end
end

------------------------------------------------------------------------

local function UpdatePower(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	-- debug("UpdatePower: %s, %s", tostring(event), tostring(unit))

	if max == 0 then
		self.Health:SetPoint("TOP", self.Power, "TOP")
		bar:Hide()
		bar.hidden = true
		return
	elseif self.Power.hidden then
		self.Health:SetPoint("TOP", self.Power, "BOTTOM", 0, -1)
		bar:Show()
		bar.hidden = nil
	end

	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)
		bar:SetStatusBarColor(0, 0, 0)
		bar.bg:SetVertexColor(0, 0, 0)
		return
	end

	local r, g, b

	local _, type = UnitPowerType(unit)
	r, g, b = unpack(colors.power[type] or colors.unknown)

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

local usettings = {
	party = {
		width = 160,
		height = 24,
		power = true,
		func = function(self)
			if self.reverse then
				self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, settings.borderStyle == "TEXTURE" and -5 or -7)
				self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, settings.borderStyle == "TEXTURE" and -5 or -7)
				self.Name:SetJustifyH("RIGHT")

				self.Health.value:SetPoint("TOPLEFT", self, 3, 0)
			else
				self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, settings.borderStyle == "TEXTURE" and -5 or -7)
				self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, settings.borderStyle == "TEXTURE" and -5 or -7)
				self.Name:SetJustifyH("LEFT")

				self.Health.value:SetPoint("TOPRIGHT", self, -3, 0)
			end
		end,
	},
	partypet = {
		width = 160,
		height = 16,
		func = function(self)
			if self.reverse then
				self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, settings.borderStyle == "TEXTURE" and -5 or -7)
				self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, settings.borderStyle == "TEXTURE" and -5 or -7)
				self.Name:SetJustifyH("RIGHT")

				self.Health.value:SetPoint("TOPLEFT", self, 3, 0)
			else
				self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, settings.borderStyle == "TEXTURE" and -5 or -7)
				self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, settings.borderStyle == "TEXTURE" and -5 or -7)
				self.Name:SetJustifyH("LEFT")

				self.Health.value:SetPoint("TOPRIGHT", self, -3, 0)
			end
		end,
	},
}

------------------------------------------------------------------------

local INSET = oUF_Phanx.INSET
local H_DIV = oUF_Phanx.H_DIV

------------------------------------------------------------------------

local function Spawn(self, unit)
	if not unit then
		local template = self:GetParent():GetAttribute("template")
		if template == "SecureUnitButtonTemplate" then
			unit = "party"
		else
			unit = "partypet"
		end
	end
	-- debug("Spawn", unit)

	self.menu = oUF_Phanx.menu

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")

	self.reverse = true

	local c = usettings[unit]
	local hasPower = c.power

	local FONT = oUF_Phanx:GetFont(settings.font)
	local STATUSBAR = oUF_Phanx:GetStatusBarTexture(settings.statusbar)

	local width = INSET + c.width + INSET
	local height = INSET + c.height + INSET
	if hasPower then
		height = height + 1
	end

	self:SetAttribute("initial-width", width)
	self:SetAttribute("initial-height", height)

	self:SetFrameStrata("BACKGROUND")

	self:SetBackdrop(oUF_Phanx.backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(0, 0, 0, 0)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetPoint("BOTTOMLEFT", INSET, INSET)
	self.Health:SetPoint("BOTTOMRIGHT", -INSET, INSET)
	self.Health:SetHeight(c.height - (hasPower and (c.height / H_DIV) or 0))
	self.Health:SetStatusBarTexture(STATUSBAR)
	self.Health:GetStatusBarTexture():SetHorizTile(false)
	self.Health:GetStatusBarTexture():SetVertTile(false)

	self.Health.bg = self.Health:CreateTexture(nil, "BACKGROUND")
	self.Health.bg:SetTexture(STATUSBAR)
	self.Health.bg:SetAllPoints(self.Health)

	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetFont(FONT, 26, settings.outline)
	self.Health.value:SetShadowOffset(1, -1)

	self.Health.smoothUpdates = true
	self.OverrideUpdateHealth = UpdateHealth

	if hasPower then
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetPoint("TOPLEFT", INSET, -INSET)
		self.Power:SetPoint("TOPRIGHT", -INSET, -INSET)
		self.Power:SetHeight(c.height / H_DIV)
		self.Power:SetStatusBarTexture(STATUSBAR)
		self.Power:GetStatusBarTexture():SetHorizTile(false)
		self.Power:GetStatusBarTexture():SetVertTile(false)

		self.Power.bg = self.Power:CreateTexture(nil, "BACKGROUND")
		self.Power.bg:SetTexture(STATUSBAR)
		self.Power.bg:SetAllPoints(self.Power)

		self.Power.smoothUpdates = true
		self.OverrideUpdatePower = UpdatePower
	end

	if unit == "party" then
		self.Name = self.Health:CreateFontString(nil, "OVERLAY")
		self.Name:SetFont(FONT, 20, settings.outline)
		self.Name:SetShadowOffset(1, -1)

		self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)
		table.insert(self.__elements, UpdateName)

		self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
		self.Assistant:SetPoint("LEFT", self.Health, "BOTTOMLEFT", 1, settings.borderStyle == "TEXTURE" and -1 or 1)
		self.Assistant:SetWidth(16)
		self.Assistant:SetHeight(16)

		self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetPoint("LEFT", self.Health, "BOTTOMLEFT", 1, settings.borderStyle == "TEXTURE" and -1 or 1)
		self.Leader:SetWidth(16)
		self.Leader:SetHeight(16)

		self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
		self.MasterLooter:SetPoint("BOTTOMLEFT", self.Leader, "BOTTOMRIGHT", 0, 2)
		self.MasterLooter:SetWidth(14)
		self.MasterLooter:SetHeight(14)

		self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetPoint("CENTER", self, unit == "player" and "LEFT" or "RIGHT", unit == "player" and INSET or -INSET, 0)
		self.LFDRole:SetWidth(20)
		self.LFDRole:SetHeight(20)
	end

	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("CENTER", self, "BOTTOM", -INSET, 0)
	self.RaidIcon:SetWidth(24)
	self.RaidIcon:SetHeight(24)

	self.Range = true
	self.inRangeAlpha = 1
	self.outsideRangeAlpha = 0.65

	self.Threat = oUF_Phanx.fakeThreat
	self.OverrideUpdateThreat = oUF_Phanx.UpdateThreatHighlight

	if settings.borderStyle == "TEXTURE" then
		oUF_Phanx.AddBorder(self)
		for i, tex in ipairs(self.borderTextures) do
			tex:SetParent(self.Health)
		end
	elseif settings.borderStyle == "GLOW" then
		self.BorderGlow = CreateFrame("Frame", nil, self)
		self.BorderGlow:SetFrameStrata("BACKGROUND")
		self.BorderGlow:SetFrameLevel(self:GetFrameLevel() - 1)
		self.BorderGlow:SetAllPoints(self)
		self.BorderGlow:SetBackdrop(oUF_Phanx.backdrop_glow)
		self.BorderGlow:SetBackdropColor(0, 0, 0, 0)
		self.BorderGlow:SetBackdropBorderColor(0, 0, 0, 1)
	end
	self.UpdateBorder = oUF_Phanx.UpdateBorder

	if c.func then
		c.func(self)
	end

	--
	-- Module: DispelHighlight
	--
	self.DispelHighlight = oUF_Phanx.UpdateDispelHighlight

	--
	-- Module: IncomingHeals
	-- Only on player frame for non-healing classes.
	--
	if playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "PRIEST" or playerClass == "SHAMAN" then
		self.HealCommBar = self.Health:CreateTexture(nil, "OVERLAY")
		self.HealCommBar:SetTexture(STATUSBAR)
		self.HealCommBar:SetVertexColor(0, 1, 0)
		self.HealCommBar:SetAlpha(0.35)
		self.HealCommBar:SetHeight(self.Health:GetHeight())

		self.HealCommIgnoreHoTs = true
		self.HealCommNoOverflow = true
	end
	--[[
	self.IncomingHeals = { }
	for i = 1, 3 do
		self.IncomingHeals[i] = self.Health:CreateTexture(nil, "OVERLAY")
		self.IncomingHeals[i]:SetTexture(STATUSBAR)
		self.IncomingHeals[i]:SetHeight(self.Health:GetHeight())
	end
	self.IncomingHeals.hideOverflow = true
	self.IncomingHeals.ignoreBombs = true
	self.IncomingHeals.ignoreHoTs = true
	]]

	--
	-- Module: Resurrection
	--
	if playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "PRIEST" or playerClass == "SHAMAN" then
		self.ResurrectionText = self.Health:CreateFontString(nil, "OVERLAY")
		self.ResurrectionText:SetFont(FONT, 20, settings.outline)
		self.ResurrectionText:SetPoint("BOTTOM", 0, 1)
	end

	--
	-- Plugin: oUF_AFK
	--
	if select(4, GetAddOnInfo("oUF_AFK")) and (unit == "player" or unit == "party") then
		self.AFK = self.Health:CreateFontString(nil, "OVERLAY")
		self.AFK:SetFont(FONT, 12, settings.outline)
		self.AFK:SetPoint("CENTER", self, "BOTTOM", 0, INSET)
		self.AFK.fontFormat = "AFK %s:%s"
	end

	--
	-- Plugin: oUF_ReadyCheck
	--
	if select(4, GetAddOnInfo("oUF_ReadyCheck")) and (unit == "player" or unit == "party") then
		self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetPoint("CENTER")
		self.ReadyCheck:SetWidth(32)
		self.ReadyCheck:SetHeight(32)

		self.ReadyCheck.delayTime = 5
		self.ReadyCheck.fadeTime = 1
	end

	--
	-- Disable plugin: oUF_QuickHealth2
	-- Worthless waste of resources.
	--
	if select(4, GetAddOnInfo("oUF_QuickHealth2")) then
		self.ignoreQuickHealth = true
	end

	return self
end

------------------------------------------------------------------------

function oUF_Phanx:SpawnPartyFrames()
	settings = self.settings
	SharedMedia = LibStub("LibSharedMedia-3.0", true)

	oUF:RegisterStyle("PhanxParty", Spawn)
	oUF:SetActiveStyle("PhanxParty")

	local party = oUF:Spawn("header", "oUF_Phanx_Party")
	party:SetPoint("BOTTOMLEFT", oUF.units.target, "BOTTOMRIGHT", 60, 0)
	party:SetManyAttributes(
		"showParty", true,
		"showPlayer", true,
		"sortDir", "DESC",
		"point", "BOTTOM",
		"yOffset", 40
	)

	local partypet = oUF:Spawn("header", "oUF_Phanx_PartyPet", true)
	party:SetPoint("BOTTOMLEFT", oUF.units.target, "BOTTOMRIGHT", 60, -24)
	partypet:SetManyAttributes(
		"showParty", true,
		"showPlayer", true,
		"sortDir", "DESC",
		"point", "BOTTOM",
		"yOffset", 48
	)

	self:SetScript("OnEvent", function(self, event)
		if GetCVarBool("hidePartyInRaid") and GetNumRaidMembers() > 0 then
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			else
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				party:Hide()
				partypet:Hide()
			end
		else
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			else
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				party:Show()
				partypet:Show()
			end
		end
	end)
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:RegisterEvent("PARTY_MEMBER_CHANGED")
	if IsLoggedIn() then
		self:GetScript("OnEvent")(self, "PLAYER_LOGIN")
	else
		self:RegisterEvent("PLAYER_LOGIN")
	end
end

namespace.party = true