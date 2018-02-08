--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2017 Phanx <addons@phanx.net>. All rights reserved.
	https://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	https://www.curseforge.com/wow/addons/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")
local colors = oUF.colors
local config

ns.frames, ns.headers, ns.objects = {}, {}, {}

local function Spawn(self, unit, isSingle)
	if self:GetParent():GetAttribute("useOwnerUnit") then
		local suffix = self:GetParent():GetAttribute("unitsuffix")
		self:SetAttribute("useOwnerUnit", true)
		self:SetAttribute("unitsuffix", suffix)
		unit = unit .. suffix
	end

	local uconfig = ns.uconfig[unit]
	self.spawnunit = unit

	-- print("Spawn", self:GetName(), unit)
	tinsert(ns.objects, self)

	-- turn "boss2" into "boss" for example
	unit = gsub(unit, "%d", "")

	self.menu = ns.UnitFrame_DropdownMenu

	self:HookScript("OnEnter", ns.UnitFrame_OnEnter)
	self:HookScript("OnLeave", ns.UnitFrame_OnLeave)

	self:RegisterForClicks("anyup")

	local FRAME_WIDTH  = config.width  * (uconfig.width  or 1)
	local FRAME_HEIGHT = config.height * (uconfig.height or 1)
	local POWER_HEIGHT = FRAME_HEIGHT * config.powerHeight

	local BAR_TEXTURE = LibStub("LibSharedMedia-3.0"):Fetch("statusbar", config.statusbar) or "Interface\\TargetingFrame\\UI-StatusBar"

	if isSingle then
		self:SetAttribute("initial-width", FRAME_WIDTH)
		self:SetAttribute("initial-height", FRAME_HEIGHT)
		self:SetWidth(FRAME_WIDTH)
		self:SetHeight(FRAME_HEIGHT)
	else
		-- used for aura filtering
		self.isGroupFrame = true
	end

	for k, v in pairs(ns.framePrototype) do
		self[k] = v
	end

	-------------------------
	-- Border and backdrop --
	-------------------------
	ns.CreateBorder(self)
	self.UpdateBorder = ns.UpdateBorder

	self:SetBackdrop(config.backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(unpack(config.borderColor))

	-----------------------------------------------------------
	-- Overlay to avoid reparenting stuff on powerless units --
	-----------------------------------------------------------
	self.overlay = CreateFrame("Frame", nil, self)
	self.overlay:SetAllPoints(true)

	--health.value:SetParent(self.overlay)
	self:SetBorderParent(self.overlay)

	-------------------------
	-- Health bar and text --
	-------------------------
	local health = ns.CreateStatusBar(self, 24, "RIGHT")
	health:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
	health:SetPoint("TOPRIGHT", self, "TOPRIGHT", -1, -1)
	health:SetPoint("BOTTOM", self, "BOTTOM", 0, 1)

	health.fg:SetDrawLayer("ARTWORK")

	health.value:SetParent(self.overlay)
	health.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, FRAME_HEIGHT * config.powerHeight - 4)

	local healthColorMode = config.healthColorMode
	health.colorClass = healthColorMode == "CLASS"
	health.colorReaction = healthColorMode == "CLASS"
	health.colorSmooth = healthColorMode == "HEALTH"

	local healthBG = config.healthBG
	health.bg.multiplier = healthBG

	if healthColorMode == "CUSTOM" then
		local r, g, b = unpack(config.healthColor)
		health:SetStatusBarColor(r, g, b)
		health.bg:SetVertexColor(r * healthBG, g * healthBG, b * healthBG)
	end

	health.frequentUpdates = true
	health.PostUpdate = ns.Health_PostUpdate
	self:RegisterForMouseover(health)
	self:SmoothBar(health)
	self.Health = health

	---------------------------------
	-- Predicted healing & absorbs --
	---------------------------------
	do
		local healing = ns.CreateStatusBar(health, nil, nil, true)
		healing:SetWidth(FRAME_WIDTH - 2) -- health:GetWidth() doesn't work for some reason
		healing:SetPoint("TOPLEFT", health.fg, "TOPRIGHT")
		healing:SetPoint("BOTTOMLEFT", health.fg, "BOTTOMRIGHT")
		healing:SetStatusBarColor(0.25, 1, 0.25, 0.5)

		local spark = healing:CreateTexture(nil, "OVERLAY")
		spark:SetPoint("TOP", healing, "TOPLEFT")
		spark:SetPoint("BOTTOM", healing, "BOTTOMLEFT")
		spark:SetWidth(16)
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetTexCoord(0, 1, 0.35, 0.6)
		spark:SetBlendMode("ADD")
		spark:SetAlpha(0.25)
		healing.spark = spark

		local cap = self.overlay:CreateTexture(nil, "OVERLAY")
		cap:SetPoint("CENTER", health, "RIGHT")
		cap:SetSize(16, 32)
		cap:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		cap:SetBlendMode("ADD")
		cap:SetAlpha(0.75)
		healing.cap = cap

		local absorbs = ns.CreateStatusBar(health, nil, nil, true)
		absorbs:SetWidth(FRAME_WIDTH - 2) -- health:GetWidth() doesn't work for some reason
		absorbs:SetPoint("TOPLEFT", healing.fg, "TOPRIGHT")
		absorbs:SetPoint("BOTTOMLEFT", healing.fg, "BOTTOMRIGHT")
		absorbs:SetStatusBarColor(0.25, 0.8, 1, 0.5)

		local spark = absorbs:CreateTexture(nil, "OVERLAY")
		spark:SetPoint("TOP", absorbs, "TOPLEFT")
		spark:SetPoint("BOTTOM", absorbs, "BOTTOMLEFT")
		spark:SetWidth(16)
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetTexCoord(0, 1, 0.35, 0.6)
		spark:SetBlendMode("ADD")
		spark:SetAlpha(0.25)
		absorbs.spark = spark

		local cap = self.overlay:CreateTexture(nil, "OVERLAY")
		cap:SetPoint("CENTER", health, "RIGHT")
		cap:SetSize(16, 32)
		cap:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		cap:SetBlendMode("ADD")
		cap:SetAlpha(0.75)
		cap:SetDesaturated(true)
		cap:SetVertexColor(0, 1, 0)
		absorbs.cap = cap

		self.HealthPrediction = {
			healingBar = healing,
			absorbsBar = absorbs,
			Override = ns.HealthPrediction_Override,
		}
	end

	------------------------
	-- Power bar and text --
	------------------------
	if uconfig.power then
		local power = ns.CreateStatusBar(self, (uconfig.width or 1) > 0.75 and 16, "LEFT")
		--power:SetFrameLevel(self.Health:GetFrameLevel() + 2)
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		power:SetHeight(POWER_HEIGHT)

		health:SetPoint("BOTTOM", power, "TOP", 0, 1)

		if power.value then
			power.value:SetParent(self.overlay)
			power.value:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 4, FRAME_HEIGHT * config.powerHeight - 2)
			power.value:SetPoint("BOTTOMRIGHT", self.Health.value, "BOTTOMLEFT", -8, 0)
			self:RegisterForMouseover(power)
		end

		local powerColorMode = config.powerColorMode
		power.colorClass = powerColorMode == "CLASS"
		power.colorReaction = powerColorMode == "CLASS"
		power.colorPower = powerColorMode == "POWER"

		local powerBG = config.powerBG
		power.bg.multiplier = powerBG

		if powerColorMode == "CUSTOM" then
			local r, g, b = unpack(config.powerColor)
			power:SetStatusBarColor(r, g, b)
			power.bg:SetVertexColor(r / powerBG, g / powerBG, b / powerBG)
		end

		power.frequentUpdates = true
		power.PostUpdate = ns.Power_PostUpdate
		self:SmoothBar(power)
		self.Power = power
	end

	---------------------------
	-- Name text, Level text --
	---------------------------
	if unit == "target" or unit == "focus" then
		self.Level = ns.CreateFontString(self.overlay, 16, "LEFT")
		self.Level:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2, -4)
		self:Tag(self.Level, "[difficulty][level][shortclassification]")

		self.Name = ns.CreateFontString(self.overlay, 20, "LEFT")
		self.Name:SetPoint("LEFT", self.Level, "RIGHT", 0, 0)
		self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -2, -4)
		self:Tag(self.Name, "[unitcolor][name]")

	elseif unit ~= "player" and not strmatch(unit, "pet") then
		self.Name = ns.CreateFontString(self.overlay, 20, "LEFT")
		self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2, -4)
		self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -2, -4)
		self:Tag(self.Name, "[unitcolor][name]")
	end

	-----------------
	-- Threat text --
	-----------------
	if unit == "target" then
		self.ThreatText = ns.CreateFontString(self.overlay, 16, "RIGHT")
		self.ThreatText:SetPoint("CENTER", self, "BOTTOM", 0, 0)
		self:Tag(self.ThreatText, "[threatpct]")
	end

	------------------------------
	-- Class-specific resources --
	------------------------------
	if unit == "player" then
		local ClassPower = ns.Orbs.Create(self.overlay, 10, 20, true)
		ClassPower[1]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 2, 5)

		ClassPower.PostUpdate = ns.ClassPower_PostUpdate
		ClassPower.UpdateColor = nop -- override for oUF
		self.ClassPower = ClassPower

		local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[playerClass]
		for i = 1, 5 do
			ClassPower[i].bg:SetVertexColor(0.25, 0.25, 0.25)
			ClassPower[i].fg:SetVertexColor(color.r, color.g, color.b)
		end

		if CUSTOM_CLASS_COLORS then
			CUSTOM_CLASS_COLORS:RegisterCallback(function()
				local color = CUSTOM_CLASS_COLORS[playerClass]
				for i = 1, #ClassPower do
					ClassPower[i].fg:SetVertexColor(color.r, color.g, color.b)
				end
			end)
		end
	end

	-----------
	-- Runes --
	-----------
	if unit == "player" and playerClass == "DEATHKNIGHT" and config.runeBars then
		self.Runes = ns.CreateRunes(self)

		local powerColorMode = config.powerColorMode
		self.Runes.colorClass = powerColorMode == "CLASS"
		self.Runes.colorPower = powerColorMode == "POWER"

		if powerColorMode == "CUSTOM" then
			local r, g, b = unpack(config.powerColor)
			for i = 1, #self.Runes do
				local bar = self.Runes[i]
				bar:SetStatusBarColor(r, g, b)
				local mu = bar.bg.multiplier
				bar.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	------------
	-- Totems --
	------------
	if unit == "player" and playerClass == "SHAMAN" and config.totemBars then
		self.Totems = ns.CreateTotems(self)

		local powerColorMode = config.powerColorMode
		self.Totems.colorClass = powerColorMode == "CLASS"
		self.Totems.colorPower = powerColorMode == "POWER"

		if powerColorMode == "CUSTOM" then
			local r, g, b = unpack(config.powerColor)
			for i = 1, #self.Totems do
				local bar = self.Totems[i]
				bar:SetStatusBarColor(r, g, b)
				local mu = bar.bg.multiplier
				bar.bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	-------------------------
	-- Secondary power bar --
	-------------------------
	if unit == "player" and ns.configPC.druidMana then
		local AdditionalPower = ns.CreateStatusBar(self, 16, "CENTER")
		AdditionalPower:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
		AdditionalPower:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 0)
		AdditionalPower:SetHeight(FRAME_HEIGHT * config.powerHeight)

		AdditionalPower.value:SetPoint("CENTER", AdditionalPower, 0, 1)

		AdditionalPower.value:Hide()
		self:RegisterForMouseover(AdditionalPower.value)

		AdditionalPower:Hide()
		AdditionalPower:SetScript("OnShow", ns.ExtraBar_OnShow)
		AdditionalPower:SetScript("OnHide", ns.ExtraBar_OnHide)
		AdditionalPower.borderOffset = 2

		AdditionalPower.colorPower = true
		AdditionalPower.bg.multiplier = config.powerBG

		AdditionalPower.PostUpdate = ns.AdditionalPower_PostUpdate
		self:SmoothBar(AdditionalPower)
		self.AdditionalPower = AdditionalPower
	end

	-----------------------
	-- Status icons --
	-----------------------
	if unit == "player" then
		self.Status = ns.CreateFontString(self.overlay, 16, "LEFT")
		self.Status:SetPoint("LEFT", self, "BOTTOMLEFT", 2, 2)
		self:Tag(self.Status, "[leadericon][mastericon]")

		self.RestingIndicator = self.overlay:CreateTexture(nil, "OVERLAY")
		self.RestingIndicator:SetPoint("LEFT", self, "TOPLEFT", 0, 6)
		self.RestingIndicator:SetSize(30, 28)

		self.CombatIndicator = self.overlay:CreateTexture(nil, "OVERLAY")
		self.CombatIndicator:SetPoint("RIGHT", self, "TOPRIGHT", 0, 6)
		self.CombatIndicator:SetSize(32, 32)
	elseif unit == "party" or unit == "target" then
		self.Status = ns.CreateFontString(self.overlay, 16, "RIGHT")
		self.Status:SetPoint("RIGHT", self, "BOTTOMRIGHT", -2, 0)
		self:Tag(self.Status, "[mastericon][leadericon]")
	end

	----------------
	-- Phase icon --
	----------------
	if unit == "party" or unit == "target" or unit == "focus" then
		local phase = self.Health:CreateTexture(nil, "OVERLAY")
		phase:SetPoint("TOP", self)
		phase:SetPoint("BOTTOM", self)
		phase:SetWidth(FRAME_HEIGHT * 2.5)
		phase:SetTexture("Interface\\Icons\\Spell_Frost_Stun")
		phase:SetTexCoord(0.05, 0.95, 0.5 - 0.25 * 0.9, 0.5 + 0.25 * 0.9)
		phase:SetAlpha(0.5)
		phase:SetBlendMode("ADD")
		phase:SetDesaturated(true)
		phase:SetVertexColor(0.4, 0.8, 1)
		phase.PostUpdate = ns.PhaseIndicator_PostUpdate
		self.PhaseIndicator = phase
	end

	---------------------
	-- Quest boss icon --
	---------------------
	if unit == "target" then
		self.QuestIndicator = self.overlay:CreateTexture(nil, "OVERLAY")
		self.QuestIndicator:SetPoint("CENTER", self, "LEFT", 0, 0)
		self.QuestIndicator:SetSize(32, 32)
	end

	-----------------------
	-- Raid target icons --
	-----------------------
	self.RaidTargetIndicator = self.overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("CENTER", self, 0, 0)
	self.RaidTargetIndicator:SetSize(32, 32)

	----------------------
	-- Ready check icon --
	----------------------
	if unit == "player" or unit == "party" then
		self.ReadyCheckIndicator = self.overlay:CreateTexture(nil, "OVERLAY")
		self.ReadyCheckIndicator:SetPoint("CENTER", self)
		self.ReadyCheckIndicator:SetSize(FRAME_HEIGHT, FRAME_HEIGHT)
	end

	----------------
	-- Role icons --
	----------------
	if unit == "player" or unit == "party" then
		local GroupRoleIndicator = self.overlay:CreateTexture(nil, "OVERLAY")
		GroupRoleIndicator:SetPoint("CENTER", self, unit == "player" and "LEFT" or "RIGHT", unit == "player" and -2 or 2, 0)
		GroupRoleIndicator:SetSize(16, 16)
		GroupRoleIndicator:SetTexture("Interface\\LFGFRAME\\LFGROLE")
		GroupRoleIndicator.Override = ns.GroupRoleIndicator_Override
		self.GroupRoleIndicator = GroupRoleIndicator
	end

	---------------
	-- PvP icons --
	---------------
	if unit == "target" then -- unit == "player" or unit == "target" or unit == "party" then
		local pvp = self.overlay:CreateTexture(nil, "OVERLAY")
		pvp:SetPoint("CENTER", self, "TOPLEFT", -3, 2)
		pvp:SetSize(15, 15)
		pvp.SetTexCoord = nop
		pvp.PostUpdate = ns.PvPIndicator_PostUpdate
		self.PvPIndicator = pvp
	end

	----------------
	-- Aura icons --
	----------------
	if unit == "player" then
		local GAP = 6
		local ROWS = 2

		local buffs = CreateFrame("Frame", nil, self)
		buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
		buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 24)
		buffs:SetHeight((FRAME_HEIGHT * ROWS) + (GAP * (ROWS - 1)))

		buffs["growth-x"] = "LEFT"
		buffs["growth-y"] = "UP"
		buffs["initialAnchor"] = "BOTTOMRIGHT"
		buffs["num"] = floor((FRAME_WIDTH + GAP) / (FRAME_HEIGHT + GAP)) * ROWS
		buffs["size"] = FRAME_HEIGHT
		buffs["spacing-x"] = GAP
		buffs["spacing-y"] = GAP

		buffs.CustomFilter   = ns.CustomAuraFilters.player
		buffs.PostCreateIcon = ns.Auras_PostCreateIcon
		buffs.PostUpdateIcon = ns.Auras_PostUpdateIcon
		buffs.PostUpdate     = ns.Auras_PostUpdate -- required to detect Dead => Ghost

		self.Buffs = buffs
	elseif unit == "pet" then
		local GAP = 6

		local auras = CreateFrame("Frame", nil, self)
		auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
		auras:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 24)
		auras:SetHeight(FRAME_HEIGHT)

		auras["gap"] = true
		auras["growth-x"] = "LEFT"
		auras["growth-y"] = "UP"
		auras["initialAnchor"] = "BOTTOMRIGHT"
		auras["num"] = floor((FRAME_WIDTH + GAP) / (FRAME_HEIGHT + GAP))
		auras["size"] = FRAME_HEIGHT
		auras["spacing-x"] = GAP
		auras["spacing-y"] = GAP

		auras.CustomFilter   = ns.CustomAuraFilters.pet
		auras.PostCreateIcon = ns.Auras_PostCreateIcon
		auras.PostUpdateIcon = ns.Auras_PostUpdateIcon

		self.Auras = auras
	elseif unit == "party" then
		local GAP = 6
		local MAX_ICONS = 5

		local auras = CreateFrame("Frame", nil, self)
		auras:SetPoint("RIGHT", self, "LEFT", -10, 0)
		auras:SetHeight(FRAME_HEIGHT)
		auras:SetWidth((FRAME_HEIGHT * (MAX_ICONS + 1)) + (GAP * MAX_ICONS))

		auras["growth-x"] = "LEFT"
		auras["growth-y"] = "DOWN"
		auras["initialAnchor"] = "RIGHT"
		auras["num"] = MAX_ICONS
		auras["size"] = FRAME_HEIGHT
		auras["spacing-x"] = GAP

		auras.CustomFilter   = ns.CustomAuraFilters.party
		auras.PostCreateIcon = ns.Auras_PostCreateIcon
		auras.PostUpdateIcon = ns.Auras_PostUpdateIcon
		auras.PostUpdate     = ns.Auras_PostUpdate -- required to detect Dead => Ghost

		self.Auras = auras
	elseif unit == "target" then
		local GAP = 6
		local ROWS = 3

		local ICONS_PER_ROW   = floor((FRAME_WIDTH + GAP) / (FRAME_HEIGHT + GAP))
		local BUFFS_PER_ROW   = 2
		local DEBUFFS_PER_ROW = ICONS_PER_ROW - BUFFS_PER_ROW
		local MAX_BUFFS       = ROWS * BUFFS_PER_ROW
		local MAX_DEBUFFS     = ROWS * DEBUFFS_PER_ROW

		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight((FRAME_HEIGHT * ROWS) + (GAP * 2 * (ROWS - 1)))

		debuffs["growth-y"] = "UP"
		debuffs["showType"] = true
		debuffs["size"] = FRAME_HEIGHT
		debuffs["spacing-x"] = GAP
		debuffs["spacing-y"] = GAP * 2

		debuffs.CustomFilter   = ns.CustomAuraFilters.target
		debuffs.PostCreateIcon = ns.Auras_PostCreateIcon
		debuffs.PostUpdateIcon = ns.Auras_PostUpdateIcon
		debuffs.PostUpdate     = ns.Auras_PostUpdate -- required to detect Dead => Ghost

		self.Debuffs = debuffs

		local buffs = CreateFrame("Frame", nil, self)
		buffs:SetHeight((FRAME_HEIGHT * ROWS) + (GAP * 2 * (ROWS - 1)))

		buffs["growth-y"] = "UP"
		buffs["showType"] = false
		buffs["size"] = FRAME_HEIGHT
		buffs["spacing-x"] = GAP
		buffs["spacing-y"] = GAP * 2

		buffs.CustomFilter   = ns.CustomAuraFilters.target
		buffs.PostCreateIcon = ns.Auras_PostCreateIcon
		buffs.PostUpdateIcon = ns.Auras_PostUpdateIcon

		self.Buffs = buffs

		local function UpdateAurasForRole(self, role, initial)
			--print("Updating auras for new role:", role)

			local a, b
			if role == "HEALER" then
				a, b = self.Buffs, self.Debuffs
			else
				a, b = self.Debuffs, self.Buffs
			end

			a:ClearAllPoints()
			a:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, 24)
			a:SetWidth((FRAME_HEIGHT * DEBUFFS_PER_ROW) + (GAP * (DEBUFFS_PER_ROW - 1)))
			a["growth-x"] = "RIGHT"
			a["initialAnchor"] = "BOTTOMLEFT"
			a["num"] = MAX_DEBUFFS

			b:ClearAllPoints()
			b:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 24)
			b:SetWidth((FRAME_HEIGHT * BUFFS_PER_ROW) + (GAP * (BUFFS_PER_ROW - 1)))
			b["growth-x"] = "LEFT"
			b["initialAnchor"] = "BOTTOMRIGHT"
			b["num"] = MAX_BUFFS

			if not initial then
				a:ForceUpdate()
				b:ForceUpdate()
			end
		end

		self:RegisterForRoleChange(UpdateAurasForRole)
		UpdateAurasForRole(self, ns.GetPlayerRole(), true) -- default is DAMAGER
	end

	------------------------------
	-- Cast bar, icon, and text --
	------------------------------
	if uconfig.castbar then
		self.Castbar = ns.AddCastbar(self, unit)
	end

	------------
	-- Threat --
	------------
	self.Threat = {
		Hide = nop, -- oUF stahp
		IsObjectType = nop,
		Override = ns.Threat_Override,
	}

	-------------------------------------
	-- Range || Plugin: oUF_SpellRange --
	-------------------------------------
	local ranger
	if IsAddOnLoaded("oUF_SpellRange") then
		ranger = "SpellRange"
	elseif unit == "pet" or unit == "party" or unit == "partypet" then
		ranger = "Range"
	end
	if ranger then
		self[ranger] = { insideAlpha = 1, outsideAlpha = 0.5 }
	end

	----------------------
	-- Element: AFK text --
	----------------------
	if unit == "player" or unit == "party" then
		self.AFK = ns.CreateFontString(self.overlay, 14, "CENTER")
		self.AFK:SetPoint("CENTER", self, "BOTTOM", 0, -3)
		self.AFK.fontFormat = "AFK %s:%s"
	end

	--------------------------
	-- Element: Combat text --
	--------------------------
	if uconfig.combatText and not strmatch(unit, ".target$") then
		self.CombatText = ns.CreateFontString(self.overlay, 22, "CENTER")
		if unit == "pet" or unit == "party" then
			self.CombatText:SetPoint("LEFT", 2, -1)
		else
			self.CombatText:SetPoint("CENTER", 0, -1)
		end
	end

	-------------------------------
	-- Element: Dispel highlight --
	-------------------------------
	self.DispelHighlight = {
		Override = ns.DispelHighlight_Override,
		filter = true,
	}

	---------------------------
	-- Element: ResInfo text --
	---------------------------
	if unit ~= "arena" and unit ~= "boss" and not strmatch(unit, ".target$") then
		self.ResInfo = ns.CreateFontString(self.overlay, 16, "CENTER")
		self.ResInfo:SetPoint("CENTER", 0, 1)
	end

	-----------
	-- Done! --
	-----------
	local maxLevel
	for k, v in pairs(self) do
		if k ~= "overlay" and type(v) == "table" and v.GetFrameLevel then
			maxLevel = max(v:GetFrameLevel(), maxLevel or 0)
		end
	end
	self.overlay:SetFrameLevel(maxLevel + 1)
end

------------------------------------------------------------------------

function ns.Factory(oUF)
	config = ns.config
	uconfig = ns.uconfig

	-- Remove irrelevant rightclick menu entries
	for _, menu in pairs(UnitPopupMenus) do
		for i = #menu, 1, -1 do
			local name = menu[i]
			if name == "SET_FOCUS" or name == "CLEAR_FOCUS" or name:match("^LOCK_%u+_FRAME$") or name:match("^UNLOCK_%u+_FRAME$") or name:match("^MOVE_%u+_FRAME$") or name:match("^RESET_%u+_FRAME_POSITION") then
				tremove(menu, i)
			end
		end
	end

	-- SPAWN MORE OVERLORDS!
	oUF:RegisterStyle("Phanx", Spawn)
	oUF:SetActiveStyle("Phanx")

	local initialConfigFunction = [[
		self:SetAttribute("initial-width", %d)
		self:SetAttribute("initial-height", %d)
		self:SetWidth(%d)
		self:SetHeight(%d)
	]] -- self:SetAttribute("*type2", "menu")

	for unit, udata in pairs(uconfig) do
		if not udata.disable then
			local name = "oUFPhanx" .. unit:gsub("%a", strupper, 1):gsub("target", "Target"):gsub("pet", "Pet")
			if udata.point then
				if udata.attributes then
					-- print("generating header for", unit)
					local w = config.width  * (udata.width  or 1)
					local h = config.height * (udata.height or 1)
					ns.headers[unit] = oUF:SpawnHeader(name, nil, udata.visible,
						"oUF-initialConfigFunction", format(initialConfigFunction, w, h, w, h),
						unpack(udata.attributes))
				else
					-- print("generating frame for", unit)
					ns.frames[unit] = oUF:Spawn(unit, name)
				end
			end
		end
	end

	for unit, object in pairs(ns.frames) do
		local udata = uconfig[unit]
		local p1, parent, p2, x, y = string.split(" ", udata.point)
		object:ClearAllPoints()
		object:SetPoint(p1, ns.headers[parent] or ns.frames[parent] or _G[parent] or UIParent, p2, tonumber(x) or 0, tonumber(y) or 0)
	end
	for unit, object in pairs(ns.headers) do
		local udata = uconfig[unit]
		local p1, parent, p2, x, y = string.split(" ", udata.point)
		object:ClearAllPoints()
		object:SetPoint(p1, ns.headers[parent] or ns.frames[parent] or _G[parent] or UIParent, p2, tonumber(x) or 0, tonumber(y) or 0)
	end

	local FONT_FILE = LibStub("LibSharedMedia-3.0"):Fetch("font", config.font) or STANDARD_TEXT_FONT
	local BAR_TEXTURE = LibStub("LibSharedMedia-3.0"):Fetch("statusbar", config.statusbar) or "Interface\\TargetingFrame\\UI-StatusBar"

	-- Fix default mirror timers to mach
	for i = 1, 3 do
		local barname = "MirrorTimer" .. i
		local bar = _G[barname]

		for _, region in pairs({ bar:GetRegions() }) do
			if region.GetTexture and region:GetTexture() == "SolidTexture" then
				region:Hide()
			end
		end

		bar:SetParent(UIParent)
		bar:SetWidth(225)
		bar:SetHeight(config.height * (1 - config.powerHeight))

		bar.bar = bar:GetChildren()
		bar.bg, bar.text, bar.border = bar:GetRegions()

		bar.bar:SetAllPoints(bar)
		bar.bar:SetStatusBarTexture(BAR_TEXTURE)

		bar.bg:ClearAllPoints()
		bar.bg:SetAllPoints(bar)
		bar.bg:SetTexture(BAR_TEXTURE)
		bar.bg:SetVertexColor(0.2, 0.2, 0.2, 1)

		bar.text:ClearAllPoints()
		bar.text:SetPoint("LEFT", bar, 4, 0)
		bar.text:SetFont(FONT_FILE, 16, config.fontOutline)

		bar.border:Hide()

		ns.CreateBorder(bar, nil, nil, bar.bar, "OVERLAY")
	end
end
