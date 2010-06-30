--[[--------------------------------------------------------------------
	oUF_Phanx
	A layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	Copyright © 2009–2010 Phanx. See README for license terms.
------------------------------------------------------------------------
	This file provides base layout functionality, and generates
	layouts for player, pet, target, targettarget, and focus.
----------------------------------------------------------------------]]

local OUF_PHANX, oUF_Phanx = ...

local L = oUF_Phanx.L
local colors = oUF.colors
local settings = oUF_Phanx.settings

local debug = oUF_Phanx.debug
local si = oUF_Phanx.si

local IsHealing = oUF_Phanx.IsHealing
local IsTanking = oUF_Phanx.IsTanking

local myClass = select(2, UnitClass("player"))
local myRealm = GetRealmName()

------------------------------------------------------------------------

local UpdateName = function(self, event, unit)
	if self.unit ~= unit then return end

	local name, realm = UnitName(unit)
	if realm and realm ~= "" and realm ~= myRealm then
		self.Name:SetFormattedText("%s (*)", name)
	else
		self.Name:SetText(name)
	end

	self.Health.Update(self, "UpdateName", unit)
end

------------------------------------------------------------------------

local UpdateHealth = function(self, event, unit)
	if self.unit ~= unit then return end
	local health = self.Health

	local cur, max = UnitHealth(unit), UnitHealthMax(unit)

	health:SetMinMaxValues(0, max)

	local disconnected, dead = not UnitIsConnected(unit)
	if disconnected then
		health:SetValue(max)
	else
		health:SetValue(cur)
		dead = UnitIsDeadOrGhost(unit)
	end

	local color
	if disconnected then
		color = oUF.colors.disconnected
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = oUF.colors.tapped
	elseif dead then
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

	if self.Name then
		self.Name:SetTextColor(r, g, b)
	end

	if disconnected then
		health.value:SetText(L["Offline"])
	elseif UnitIsDeadOrGhost(unit) then
		health.value:SetText(L["Dead"])
	elseif cur < max then
		if self.isMouseOver then
			health.value:SetFormattedText("%d%%", cur / max * 100 + 0.5)
		elseif IsHealing() then
			health.value:SetText(si(cur - max))
		else
			health.value:SetText(si(cur))
		end
	else
		health.value:SetText(self.isMouseOver and si(max))
	end
end

------------------------------------------------------------------------

local UpdatePower = function(self, event, unit)
	if self.unit ~= unit then return end
	local power = self.Power

	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	if max > 0 then
		power:Show()
		power:SetMinMaxValues(0, max)
		self.Health:SetPoint("TOP", power, "BOTTOM", 0, -1)
	else
		power:Hide()
		self.Health:SetPoint("TOP", self, "TOP", 0, PhanxBorder and -2 or (-settings.borderSize - 1))
		return
	end

	local disconnected = not UnitIsConnected(unit)
	if disconnected then
		power:SetValue(0)
	else
		power:SetValue(cur)
	end

	local _, powerType = UnitPowerType(unit)

	local color
	if disconnected then
		color = oUF.colors.disconnected
	elseif UnitIsDeadOrGhost(unit) then
		color = oUF.colors.dead
	else
		color = oUF.colors.power[powerType] or oUF.colors.power.MANA
	end

	r, g, b = color[1], color[2], color[3]

	power:SetStatusBarColor(r, g, b)
	power.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)

	power.value:SetTextColor(r, g, b)

	if disconnected or UnitIsDeadOrGhost(unit) then
		power.value:SetText()
	elseif powerType == "MANA" or powerType == "ENERGY" or powerType == "FOCUS" then
		if cur < max then
			power.value:SetText(si(cur))
		else
			power.value:SetText(self.isMouseOver and si(max))
		end
	elseif powerType == "RAGE" or powerType == "RUNIC_POWER" then
		power.value:SetText(cur > 0 and cur)
	else
		-- vehicle of some kind
		power.value:SetText(si(cur))
	end
end

------------------------------------------------------------------------

local DoNothing = function() end

local SetBorderColorFromOverlay = function(overlay, r, g, b)
	overlay:GetParent():SetBorderColor(r, g, b)
end

local PostCreateAuraIcon = function(icons, button)
	if PhanxBorder then
		PhanxBorder.AddBorder(button)
	end

	button.icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

	button.overlay.Show = DoNothing
	button.overlay.Hide = SetBorderColorFromOverlay
	button.overlay.SetVertexColor = SetBorderColorFromOverlay
end

oUF_Phanx.PostCreateAuraIcon = PostCreateAuraIcon

------------------------------------------------------------------------

local auraIconMap = oUF_Phanx.auraIconMap

local playerUnits = {
	player = true,
	pet = true,
	vehicle = true,
}

local PostUpdateAuraIcon = function(icons, unit, button, index, offset, filter, isDebuff)
	if auraIconMap and settings.remapAuraIcons then
		local name = UnitAura(unit, index, filter)
		local icon = name and auraIconMap[name]
		if icon then
			button.icon:SetTexture("Interface\\Icons\\" .. icon)
		end
	end

	if playerUnits[button.owner] then
		button.icon:SetDesaturated(false)
	else
		button.icon:SetDesaturated(true)
	end
end

oUF_Phanx.PostUpdateAuraIcon = PostUpdateAuraIcon

------------------------------------------------------------------------

local function UpdateBorder(self)
	local color
	if self.debuffDispellable then
		color = colors.debuff[self.debuffType]
	elseif self.threatLevel > 1 then
		color = colors.threat[self.threatLevel]
	elseif self.debuffType then
		color = colors.debuff[self.debuffType]
	elseif self.threatLevel > 0 then
		color = colors.threat[self.threatLevel]
	end

	if color then
		self:SetBackdropBorderColor(color[1], color[2], color[3], 1)
	else
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end
end

oUF_Phanx.UpdateBorder = UpdateBorder

------------------------------------------------------------------------

local function UpdateDispelHighlight(self, event, unit, debuffType, canDispel)
	if self.unit ~= unit then return end
	-- debug("UpdateDispelHighlight", unit, tostring(debuffType), tostring(canDispel))

	if self.debuffType == debuffType then return end

	self.debuffType = debuffType
	self.debuffDispellable = canDispel
	self:UpdateBorder()
end

oUF_Phanx.UpdateDispelHighlight = UpdateDispelHighlight

------------------------------------------------------------------------

local function UpdateThreatHighlight(self, event, unit)
	if self.unit ~= unit then return end
	local status = UnitThreatSituation(unit)

	-- debug("UpdateThreatHighlight", unit, tostring(status))

	if settings.threatLevels then
		status = status or 0
	else
		status = (status and status > 1) and 3 or 0
	end

	if self.threatStatus ~= status then return end

	self.threatStatus = status
	self:UpdateBorder()
end

oUF_Phanx.UpdateThreatHighlight = UpdateThreatHighlight

------------------------------------------------------------------------

local BACKDROP = {
	bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8,
	edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = settings.borderSize,
	insets = {
		left = settings.borderSize - 1,
		right = settings.borderSize - 1,
		top = settings.borderSize - 1,
		bottom = settings.borderSize - 1,
	},
}
if PhanxBorder then
	BACKDROP.edgeSize = 0
	BACKDROP.insets.left = 0
	BACKDROP.insets.right = 0
	BACKDROP.insets.top = 0
	BACKDROP.insets.bottom = 0
end

oUF_Phanx.BACKDROP = BACKDROP

------------------------------------------------------------------------

local fakeThreat
do
	local DoNothing = function() return end
	fakeThreat = { GetTexture = DoNothing, Hide = DoNothing, IsObjectType = DoNothing, SetVertexColor = DoNothing, }
end

oUF_Phanx.fakeThreat = fakeThreat

------------------------------------------------------------------------

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("^%l", string.upper)

	if cunit == "Vehicle" then
		cunit = "Pet"
	end

	if unit == "party" or unit == "partypet" then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

oUF_Phanx.menu = menu

------------------------------------------------------------------------

local OnEnter = function(self)
	if IsShiftKeyDown() or not UnitAffectingCombat("player") then
		UnitFrame_OnEnter(self)
	end

	self.isMouseOver = true

	for i, obj in ipairs(self.showOnMouseOver) do
		obj:Show()
	end

	self.Health.Update(self, "UNIT_HEALTH", self.unit)
	if self.Power then
		self.Power.Update(self, "UNIT_MANA", self.unit)
	end
end

oUF_Phanx.OnEnter = OnEnter

------------------------------------------------------------------------

local OnLeave = function(self)
	UnitFrame_OnLeave(self)

	self.isMouseOver = false

	for i, obj in ipairs(self.showOnMouseOver) do
		obj:Show()
	end

	self.Health.Update(self, "UNIT_HEALTH", self.unit)
	if self.Power then
		self.Power.Update(self, "UNIT_MANA", self.unit)
	end
end

oUF_Phanx.OnLeave = OnLeave

------------------------------------------------------------------------

local powerUnits = {
	player = true,
	pet = true,
	target = true,
	focus = true,
}

local Spawn = function(self, unit)
	local BORDER_SIZE = PhanxBorder and 1 or settings.borderSize
	local FONT = oUF_Phanx:GetFont(settings.font)
	local STATUSBAR = oUF_Phanx:GetStatusBarTexture(settings.statusbar)
	local WIDTH = settings.width * (powerUnits[unit] and 1 or 0.8) + (BORDER_SIZE + 1) * 2
	local HEIGHT = settings.height + (BORDER_SIZE + 1) * 2 - (powerUnits[unit] and 0 or 5)

	self.showOnMouseOver = { }

	self.menu = menu

	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)

	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")

	self:SetAttribute("initial-width", WIDTH)
	self:SetAttribute("initial-height", HEIGHT)

	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(0, 0, 0, 0)

	if powerUnits[unit] then
		local Power = CreateFrame("StatusBar", nil, self)
		Power:SetPoint("TOPLEFT", BORDER_SIZE + 1, -BORDER_SIZE - 1)
		Power:SetPoint("TOPRIGHT", -BORDER_SIZE - 1, -BORDER_SIZE - 1)
		Power:SetHeight(4)
		Power:SetStatusBarTexture(STATUSBAR)
		Power:GetStatusBarTexture():SetHorizTile(false)

		Power.bg = Power:CreateTexture(nil, "BACKGROUND")
		Power.bg:SetAllPoints(Power)
		Power.bg:SetTexture(STATUSBAR)

		Power.Update = UpdatePower

		self.Power = Power
	end

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("BOTTOMLEFT", BORDER_SIZE + 1, BORDER_SIZE + 1)
	Health:SetPoint("BOTTOMRIGHT", -BORDER_SIZE - 1, BORDER_SIZE + 1)
	Health:SetPoint("TOP", Power, "BOTTOM", 0, -1)
	Health:SetStatusBarTexture(STATUSBAR)
	Health:GetStatusBarTexture():SetHorizTile(false)

	Health.bg = Health:CreateTexture(nil, "BACKGROUND")
	Health.bg:SetAllPoints(Health)
	Health.bg:SetTexture(STATUSBAR)

	Health.value = oUF_Phanx:CreateFontString(Health, 18)
	Health.value:SetPoint("LEFT", 4, 0)

	Health.Update = UpdateHealth

	self.Health = Health

	if self.Power then
		self.Power.value = oUF_Phanx:CreateFontString(Health, 18)
		self.Power.value:SetPoint("RIGHT", -3, 0)
		self.Power.value:SetPoint("LEFT", Health.value, "RIGHT", 3, 0)
		self.Power.value:SetJustifyH("RIGHT")

		if unit ~= "player" then
			table.insert(self.showOnMouseOver, self.Power.value)
			self.Power.value:Hide()
		end
	end

	if unit == "player" then
		local Combat = Health:CreateTexture(nil, "OVERLAY")
		Combat:SetPoint("CENTER")
		Combat:SetWidth(32)
		Combat:SetHeight(32)

		self.Combat = Combat

		local Resting = Health:CreateTexture(nil, "OVERLAY")
		Resting:SetPoint("CENTER", Health, "BOTTOMRIGHT")
		Resting:SetWidth(24)
		Resting:SetHeight(24)
		Resting:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		Resting:SetTexCoord(.5, 0, 0, .421875)

		self.Resting = Resting
	end

	if unit == "player" or unit == "target" then
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
	end

	local RaidIcon = Health:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetPoint("CENTER", Health, "TOP")
	RaidIcon:SetWidth(16)
	RaidIcon:SetHeight(16)

	self.RIcon = RaidIcon

	if unit == "target" or unit == "focus" then
		local Name = oUF_Phanx:CreateFontString(Health, 24)
		Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -3)
		Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -3)
		Name:SetJustifyH("LEFT")

--		self:RegisterEvent("UNIT_FACTION", UpdateName)
--		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", UpdateName)
--		self:RegisterEvent("UNIT_LEVEL", UpdateName)
		self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)
		table.insert(self.__elements, UpdateName)

		self.Name = Name
	end

	if unit == "target" then
		local ComboPoints = oUF_Phanx:CreateFontString(Health, 30)
		ComboPoints:SetPoint("RIGHT", Health, "LEFT", -5, 1)

		self.ComboPoints = ComboPoints
	end

	if unit == "target" then
		local GAP = PhanxBorder and 5 or 1

		local Auras = CreateFrame("Frame", nil, self)
		Auras:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
		Auras:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
		Auras:SetHeight((WIDTH - (GAP * 7)) / 8 * 4 + (GAP * 3))

		Auras["spacing-x"] = GAP
		Auras["spacing-y"] = GAP
		Auras["growth-x"] = "LEFT"
		Auras["growth-y"] = "DOWN"
		Auras.initialAnchor = "TOPRIGHT"
		Auras.size = (WIDTH - (GAP * 7)) / 8
		Auras.gap = true
		Auras.numBuffs = 16
		Auras.numDebuffs = 16
		Auras.showDebuffType = true
		Auras.disableCooldown = true

		Auras.CustomFilter = settings.filterAuras and oUF_Phanx.CustomAuraFilter
		Auras.PostCreateIcon = PostCreateAuraIcon
		Auras.PostUpdateIcon = PostUpdateAuraIcon

		self.Auras = Auras
	end

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
		local Threat = fakeThreat
		Threat.Update = UpdateThreatHighlight

		self.Threat = Threat
	end

	------------------------------
	-- Module: Dispel Highlight --
	------------------------------

	self.DispelHighlight = UpdateDispelHighlight
	self.DispelHighlightFilter = true

	-----------------------------
	-- Module: Global Cooldown --
	-----------------------------
--[[
	if unit == "player" then
		local GCD = CreateFrame("Frame", nil, self.Power)
		GCD:SetAllPoints(self.Power)

		GCD.spark = self.GlobalCooldown:CreateTexture(nil, "OVERLAY")
		GCD.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		GCD.spark:SetBlendMode("ADD")
		GCD.spark:SetHeight(self.GlobalCooldown:GetHeight() * 5)
		GCD.spark:SetWidth(10)

		self.GlobalCooldown = GCD
	end
]]
	----------------------------
	-- Module: Incoming Heals --
	----------------------------

	if unit == "player" or (myClass == "DRUID" or myClass == "PALADIN" or myClass == "PRIEST" or myClass == "SHAMAN") then
		self.HealCommBar = Health:CreateTexture(nil, "OVERLAY")
		self.HealCommBar:SetTexture(STATUSBAR)
		self.HealCommBar:SetVertexColor(0, 1, 0)
		self.HealCommBar:SetAlpha(0.35)
		self.HealCommBar:SetHeight(Health:GetHeight())

		self.HealCommIgnoreHoTs = true
		self.HealCommNoOverflow = true
	end
--[[
	self.IncomingHeals = { }
	for i = 1, 3 do
		self.IncomingHeals[i] = self.Health:CreateTexture(nil, "OVERLAY")
		self.IncomingHeals[i]:SetTexture(STATUSBAR)
		self.IncomingHeals[i]:SetHeight(Health:GetHeight())
	end
	self.IncomingHeals.hideOverflow = true
	self.IncomingHeals.ignoreBombs = true
	self.IncomingHeals.ignoreHoTs = true
]]
	---------------------------
	-- Module: Resurrections --
	---------------------------

	if unit == "player" or (myClass == "DRUID" or myClass == "PALADIN" or myClass == "PRIEST" or myClass == "SHAMAN") then
		local Resurrection = oUF_Phanx:CreateFontString(Health, 24)
		Resurrection:SetPoint("CENTER", 0, 0)

		self.Resurrection = Resurrection
	end

	-------------------
	-- Module: Runes --
	-------------------

	if myClass == "DEATHKNIGHT" then
		self.RuneFrame = true
	end

	---------------------
	-- Plugin: oUF_AFK --
	---------------------

	if select(4, GetAddOnInfo("oUF_AFK")) and unit == "player" then
		local AFK = oUF_Phanx:CreateFontString(Health, 12)
		AFK:SetPoint("CENTER", self, "BOTTOM", 0, 1)
		AFK.fontFormat = "AFK %s:%s"

		self.AFK = AFK
	end

	----------------------------
	-- Plugin: oUF_ReadyCheck --
	----------------------------

	if select(4, GetAddOnInfo("oUF_ReadyCheck")) and unit == "player" then
		local ReadyCheck = Health:CreateTexture(nil, "OVERLAY")
		ReadyCheck:SetPoint("CENTER")
		ReadyCheck:SetWidth(32)
		ReadyCheck:SetHeight(32)

		ReadyCheck.delayTime = 5
		ReadyCheck.fadeTime = 1

		self.ReadyCheck = ReadyCheck
	end

	------------------------------
	-- Disable oUF_QuickHealth2 --
	------------------------------

	if select(4, GetAddOnInfo("oUF_QuickHealth2")) then
		self.ignoreQuickHealth = true
	end

end

oUF:RegisterStyle("Phanx", Spawn)

oUF:Factory(function(self)
	self:SetActiveStyle("Phanx")

	local GAP = PhanxBorder and 7 or settings.borderSize

	local player = self:Spawn("player")
	player:SetPoint("TOP", UIParent, "CENTER", 0, -263)

	local pet = self:Spawn("pet")
	pet:SetPoint("TOP", player, "BOTTOM", 0, -GAP)

	local target = self:Spawn("target")
	target:SetPoint("TOPLEFT", UIParent, "CENTER", 118 + target:GetAttribute("initial-height") + 2, -184)

	local targettarget = self:Spawn("targettarget")
	targettarget:SetPoint("TOPRIGHT", target, "BOTTOMRIGHT", 0, -GAP)

--	local focus = self:Spawn("focus")
end)
