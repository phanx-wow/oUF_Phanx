--[[--------------------------------------------------------------------
	oUF_Phanx
	A layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	Copyright © 2009–2010 Phanx. See README for license terms.
----------------------------------------------------------------------]]

local OUF_PHANX, oUF_Phanx = ...

local colors = oUF.colors
local settings = oUF_Phanx.settings

local debug = oUF_Phanx.debug
local si = oUF_Phanx.si

local IsHealing = oUF_Phanx.IsHealing
local IsTanking = oUF_Phanx.IsTanking

local myClass = select(2, UnitClass("player"))
local myRealm = GetRealmName()

------------------------------------------------------------------------

local UpdateHealth = function(self, event, unit)
	if self.unit ~= unit then return end
	local health = self.Health

	local cur, max = UnitHealth(unit), UnitHealthMax(unit)

	health:SetMinMaxValues(0, max)

	local disconnected = not UnitIsConnected(unit)
	if disconnected then
		health:SetValue(max)
	else
		health:SetValue(cur)
	end

	local color
	if disconnected then
		color = oUF.colors.disconnected
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = oUF.colors.tapped
	elseif UnitIsDeadOrGhost(unit) then
		color = oUF.colors.dead
	elseif UnitIsUnit(unit, "pet") and GetPetHappiness() then
		color = oUF.colors.happiness[GetPetHappiness()]
	elseif UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = oUF.colors.class[class]
	elseif UnitReaction(unit, "player") then
		color = oUF.colors.reaction[UnitReaction(unit, "player")]
	else
		color = oUF.colors.health
	end

	local r, g, b = color[1], color[2], color[3]

	health:SetStatusBarColor(r * 0.2, g * 0.2, b * 0.2)
	health.bg:SetVertexColor(r, g, b)
	health.value:SetTextColor(r, g, b)

	if disconnected then
		health.value:SetText(L["Offline"])
	elseif UnitIsGhost(unit) then
		health.value:SetText(L["Dead"])
	elseif UnitIsDead(unit) then
		health.value:SetText(L["Ghost"])
	elseif cur == max then
		local name, realm = UnitName(unit)
		if realm and realm ~= "" and realm ~= myRealm then
			health.value:SetFormattedText("%s (*)", name)
		else
			health.value:SetText(name)
		end
	else
		if IsHealing() then
			health.value:SetFormattedText(si(cur - max))
		else
			health.value:SetFormattedText(si(cur))
		end
	end
end

------------------------------------------------------------------------

local UpdatePower = function(self, event, unit)
	if self.unit ~= unit then return end
	local power = self.Power

	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	power:SetMinMaxValues(0, max)

	local disconnected = not UnitIsConnected(unit)
	if disconnected then
		power:SetValue(0)
	else
		power:SetValue(cur)
	end

	local color
	if disconnected then
		color = oUF.colors.disconnected
	elseif UnitIsDeadOrGhost(unit) then
		color = oUF.colors.dead
	else
		local _, powerType = UnitPowerType(unit)
		color = oUF.colors.power[powerType] or oUF.colors.power.MANA
	end

	r, g, b = color[1], color[2], color[3]

	power:SetStatusBarColor(r, g, b)
	power.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)
end

------------------------------------------------------------------------

local Spawn = function(self, unit)
	local BORDER_SIZE = PhanxBorder and 2 or settings.borderSize
	local FONT = oUF_Phanx:GetFont(settings.font)
	local STATUSBAR = oUF_Phanx:GetStatusBarTexture(settings.statusbar)
	local WIDTH = settings.width * (powerUnits[unit] and 1 or 0.8) + (BORDER_SIZE + 1) * 2
	local HEIGHT = settings.height + (BORDER_SIZE + 1) * 2

	self.showOnMouseOver = { }

	self.menu = oUF_Phanx.menu

	self:SetScript("OnEnter", oUF_Phanx.OnEnter)
	self:SetScript("OnLeave", oUF_Phanx.OnLeave)

	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")

	self:SetAttribute("initial-width", WIDTH)
	self:SetAttribute("initial-height", HEIGHT)

	self:SetBackdrop(oUF_Phanx.BACKDROP)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(0, 0, 0, 0)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("BOTTOMLEFT", BORDER_SIZE + 1, BORDER_SIZE + 1)
	Health:SetPoint("BOTTOMRIGHT", -BORDER_SIZE - 1, BORDER_SIZE + 1)
	Health:SetPoint("TOP", Power, "BOTTOM", 0, -1)
	Health:SetStatusBarTexture(STATUSBAR)
	Health:GetStatusBarTexture():SetHorizTile(false)

	Health.bg = Health:CreateTexture(nil, "BACKGROUND")
	Health.bg:SetAllPoints(Health)
	Health.bg:SetTexture(STATUSBAR)

	Health.value = Health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	Health.value:SetPoint("LEFT", 4, 0)

	Health.Update = UpdateHealth

	self.Health = Health

	self:RegisterEvent("UNIT_NAME_UPDATE", UpdateHealth)

	local Leader = Health:CreateTexture(nil, "OVERLAY")
	Leader:SetPoint("LEFT", Health, "TOPLEFT", 0, -5)
	Leader:SetWidth(16)
	Leader:SetHeight(16)

	self.Leader = Leader

	local Assistant = Health:CreateTexture(nil, "OVERLAY")
	Assistant:SetPoint("LEFT", Health, "TOPLEFT", 0, -5)
	Assistant:SetWidth(16)
	Assistant:SetHeight(16)

	self.Assistant = Assistant

	local MasterLooter = Health:CreateTexture(nil, "OVERLAY")
	MasterLooter:SetWidth(16)
	MasterLooter:SetHeight(16)
	MasterLooter:SetPoint("LEFT", Leader, "RIGHT")

	self.MasterLooter = MasterLooter

	local LFDRole = Health:CreateTexture(nil, "OVERLAY")
	LFDRole:SetPoint("CENTER", Health, "LEFT")
	LFDRole:SetWidth(24)
	LFDRole:SetHeight(24)

	self.LFDRole = LFDRole

	local RaidIcon = Health:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetPoint("CENTER", Health, "TOP")
	RaidIcon:SetWidth(16)
	RaidIcon:SetHeight(16)

	self.RIcon = RaidIcon

	local Auras = CreateFrame("Frame", nil, self)
	Auras:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
	Auras:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 0, 0)
	Auras:SetWidth(HEIGHT * 7 + 5)

	Auras["spacing-x"] = 1
	Auras["growth-x"] = "LEFT"
	Auras.initialAnchor = "TOPRIGHT"
	Auras.size = HEIGHT
	Auras.gap = true
	Auras.numBuffs = 5
	Auras.numDebuffs = 1
	Auras.showDebuffType = true
	Auras.disableCooldown = true

	Auras.CustomAuraFilter = oUF_Phanx.CustomAuraFilter
	Auras.PostCreateIcon = oUF_Phanx.PostCreateAuraIcon
	Auras.PostUpdateIcon = oUF_Phanx.PostUpdateAuraIcon

	self.Auras = Auras

	if PhanxBorder then
		PhanxBorder.AddBorder(self)
		for i, t in ipairs(self.BorderTextures) do
			t:SetParent(self.Health)
		end
	end

	----------------------------
	-- Hack: Threat Highlight --
	----------------------------

	if not unit:match("^.+target$") then
		self.Threat = oUF_Phanx.fakeThreat
		self.OverrideUpdateThreat = oUF_Phanx.UpdateThreatHighlight
	end

	------------------------------
	-- Module: Dispel Highlight --
	------------------------------

	self.DispelHighlight = oUF_Phanx.UpdateDispelHighlight
	self.DispelHighlightFilter = true

	----------------------------
	-- Module: Incoming Heals --
	----------------------------

	if unit == "player" or (myClass == "DRUID" or myClass == "PALADIN" or myClass == "PRIEST" or myClass == "SHAMAN") then
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

	---------------------------
	-- Module: Resurrections --
	---------------------------

	if unit == "player" or (myClass == "DRUID" or myClass == "PALADIN" or myClass == "PRIEST" or myClass == "SHAMAN") then
		self.ResurrectionText = self.Health:CreateFontString(nil, "OVERLAY")
		self.ResurrectionText:SetFont(FONT, 20, settings.outline)
		self.ResurrectionText:SetPoint("BOTTOM", 0, 1)
	end

	---------------------
	-- Plugin: oUF_AFK --
	---------------------

	if select(4, GetAddOnInfo("oUF_AFK")) then
		self.AFK = self.Health:CreateFontString(nil, "OVERLAY")
		self.AFK:SetFont(FONT, 12, settings.outline)
		self.AFK:SetPoint("CENTER", self, "BOTTOM", 0, INSET)
		self.AFK.fontFormat = "AFK %s:%s"
	end

	----------------------------
	-- Plugin: oUF_ReadyCheck --
	----------------------------

	if select(4, GetAddOnInfo("oUF_ReadyCheck")) then
		self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetPoint("CENTER")
		self.ReadyCheck:SetWidth(32)
		self.ReadyCheck:SetHeight(32)

		self.ReadyCheck.delayTime = 5
		self.ReadyCheck.fadeTime = 1
	end

	------------------------------
	-- Disable oUF_QuickHealth2 --
	------------------------------

	if select(4, GetAddOnInfo("oUF_QuickHealth2")) then
		self.ignoreQuickHealth = true
	end

end

oUF:RegisterStyle("PhanxParty", Spawn)

oUF:Factory(function(self)
	settings = oUF_Phanx.settings -- update upvalue to catch saved vars which are loaded by now

	self:SetActiveStyle("PhanxParty")

	local GAP = PhanxBorder and 7 or settings.borderSize

--	local party = self:SpawnHeader(nil, nil, "raid,party,solo", "showParty", true, "yOffset", -GAP)
end)
