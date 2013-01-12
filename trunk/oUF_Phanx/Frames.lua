--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local config
local colors = oUF.colors
local playerClass = select(2, UnitClass("player"))

ns.frames, ns.headers, ns.objects, ns.fontstrings, ns.statusbars = {}, {}, {}, {}, {}

function ns.Spawn(self, unit, isSingle)
	if self:GetParent():GetAttribute("useOwnerUnit") then
		local suffix = self:GetParent():GetAttribute("unitsuffix")
		self:SetAttribute("useOwnerUnit", true)
		self:SetAttribute("unitsuffix", suffix)
		unit = unit .. suffix
	end

	local uconfig = ns.uconfig[unit]
	self.spawnunit = unit

	unit = gsub(unit, "%d", "") -- turn "boss2" into "boss" for example

	-- print("Spawn", self:GetName(), unit)
	tinsert(ns.objects, self)

	self.mouseovers = {}

	self.menu = ns.UnitFrame_DropdownMenu

	self:HookScript("OnEnter", ns.UnitFrame_OnEnter)
	self:HookScript("OnLeave", ns.UnitFrame_OnLeave)

	self:RegisterForClicks("anyup")

	local FRAME_WIDTH  = config.width  * (uconfig.width  or 1)
	local FRAME_HEIGHT = config.height * (uconfig.height or 1)

	if isSingle then
		self:SetAttribute("*type2", "menu")

		self:SetAttribute("initial-width", FRAME_WIDTH)
		self:SetAttribute("initial-height", FRAME_HEIGHT)

		self:SetWidth(FRAME_WIDTH)
		self:SetHeight(FRAME_HEIGHT)
	else
		-- used for aura filtering
		self.isGroupFrame = true
	end

	-------------------------
	-- Border and backdrop --
	-------------------------

	ns.CreateBorder(self)
	self:SetBorderParent(self.overlay)
	self.UpdateBorder = ns.UpdateBorder

	self:SetBackdrop(config.backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(unpack(config.borderColor))

	-------------------------
	-- Health bar and text --
	-------------------------

	local health = ns.CreateStatusBar(self, 24, "RIGHT", true)
	health:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
	health:SetPoint("TOPRIGHT", self, "TOPRIGHT", -1, -1)
	health:SetPoint("BOTTOM", self, "BOTTOM", 0, 1)
	self.Health = health

	health:GetStatusBarTexture():SetDrawLayer("ARTWORK")
	health.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, config.height * config.powerHeight - 2)

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

	health.PostUpdate = ns.PostUpdateHealth
	tinsert(self.mouseovers, health)

	---------------------------
	-- Predicted healing bar --
	---------------------------

	local heals = ns.CreateStatusBar(self)
	heals:SetAllPoints(self.Health)
	heals:SetAlpha(0.25)
	heals:SetStatusBarColor(0, 1, 0)
	heals:Hide()
	self.HealPrediction = heals

	heals:SetFrameLevel(self.Health:GetFrameLevel())

	heals.bg:ClearAllPoints()
	heals.bg:SetTexture("")
	heals.bg:Hide()
	heals.bg = nil

	heals.ignoreSelf = config.ignoreOwnHeals
	heals.maxOverflow = 1

	heals.Override = ns.UpdateIncomingHeals

	------------------------
	-- Power bar and text --
	------------------------

	if uconfig.power then
		local power = ns.CreateStatusBar(self, (uconfig.width or 1) > 0.75 and 16, "LEFT", true)
		power:SetFrameLevel(self.Health:GetFrameLevel() + 2)
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		power:SetHeight(config.height * config.powerHeight)
		self.Power = power

		health:SetPoint("BOTTOM", power, "TOP", 0, 1)

		if power.value then
			power.value:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 4, config.height * config.powerHeight - 2)
			power.value:SetPoint("BOTTOMRIGHT", self.Health.value, "BOTTOMLEFT", -8, 0)

			tinsert(self.mouseovers, power)
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

		power.frequentUpdates = unit == "player"
		power.PostUpdate = ns.PostUpdatePower
	end

	-----------------------------------------------------------
	-- Overlay to avoid reparenting stuff on powerless units --
	-----------------------------------------------------------

	self.overlay = CreateFrame("Frame", nil, self)
	self.overlay:SetAllPoints(self)
	self.overlay:SetFrameLevel(self.Health:GetFrameLevel() + (self.Power and 3 or 2))

	health.value:SetParent(self.overlay)

	--------------------------
	-- Element: Threat text -- NOT YET IMPLEMENTED
	--------------------------
--[[
	if unit == "target" then
		self.ThreatText = ns.CreateFontString(self.overlay, 20, "RIGHT")
		self.ThreatText:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -2, -4)
	end
]]
	---------------------------
	-- Name text, Level text --
	---------------------------

	if unit == "target" or unit == "focus" then
		self.Level = ns.CreateFontString(self.overlay, 16, "LEFT")
		self.Level:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2, -3)

		self:Tag(self.Level, "[difficulty][level][shortclassification]")
--[[
		if unit == "target" then
			self.RareElite = self.overlay:CreateTexture(nil, "ARTWORK")
			self.RareElite:SetPoint("TOPRIGHT", self, "TOPRIGHT", 10, 10)
			self.RareElite:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 10, -10)
			self.RareElite:SetTexture("Interface\\AddOns\\oUF_Phanx\\media\\Elite")
		end
]]
		self.Name = ns.CreateFontString(self.overlay, 20, "LEFT")
		self.Name:SetPoint("BOTTOMLEFT", self.Level, "BOTTOMRIGHT", 0, -1)
		self.Name:SetPoint("BOTTOMRIGHT", self.Threat or self.Health, self.Threat and "BOTTOMLEFT" or "TOPRIGHT", self.Threat and -8 or -2, self.Threat and 0 or -4)

		self:Tag(self.Name, "[unitcolor][name]")
	elseif unit ~= "player" and not unit:match("pet") then
		self.Name = ns.CreateFontString(self.overlay, 20, "LEFT")
		self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2, -4)
		self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -2, -4)

		self:Tag(self.Name, "[unitcolor][name]")
	end

	------------------
	-- Combo points --
	------------------

	if unit == "target" then
		local t = ns.Orbs.Create(self.overlay, MAX_COMBO_POINTS, 20)
		for i = MAX_COMBO_POINTS, 1, -1 do
			local orb = t[i]
			if i == 1 then
				orb:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -2, 5)
			else
				orb:SetPoint("BOTTOMLEFT", t[i - 1], "BOTTOMRIGHT", -2, 0)
			end
			orb.bg:SetVertexColor(0.25, 0.25, 0.25)
			orb.fg:SetVertexColor(1, 0.8, 0)
		end
		self.CPoints = t
		self.CPoints.Override = ns.UpdateComboPoints
	end

	------------------------------
	-- Class-specific resources --
	------------------------------

	if unit == "player" and (playerClass == "MONK" or playerClass == "PALADIN" or playerClass == "PRIEST" or playerClass == "WARLOCK") then
		local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[playerClass]

		local element, max, power, update, statusbar = "ClassIcons", 5

		---------
		-- Chi --
		---------
		if playerClass == "MONK" then
			power = SPELL_POWER_LIGHT_FORCE
			update = ns.UpdateChi
		----------------
		-- Holy power --
		----------------
		elseif playerClass == "PALADIN" then
			power = SPELL_POWER_HOLY_POWER
			update = ns.UpdateHolyPower
		-----------------
		-- Shadow orbs --
		-----------------
		elseif playerClass == "PRIEST" then
			power = SPELL_POWER_SHADOW_ORBS
			update = ns.UpdateShadowOrbs
		-----------------------------------------------
		-- Soul shards, demonic fury, burning embers --
		-----------------------------------------------
		elseif playerClass == "WARLOCK" then
			element = "WarlockPower" -- "SoulShards"
			max = 4
			power = SPELL_POWER_SOUL_SHARDS
			statusbar = true
		end

		local function SetAlpha(self, alpha)
			--print("SetAlpha", self.id, alpha)
			if alpha == 1 then
				self.bg:SetVertexColor(0.25, 0.25, 0.25)
				self.bg:SetAlpha(1)
				self.fg:Show()
			else
				self.bg:SetVertexColor(0.4, 0.4, 0.4)
				self.bg:SetAlpha(0.5)
				self.fg:Hide()
			end
		end

		local t = ns.Orbs.Create(self.overlay, max, 20, statusbar)
		for i = 1, max do
			local orb = t[i]
			if i == 1 then
				orb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 2, 5)
			else
				orb:SetPoint("BOTTOMRIGHT", t[i - 1], "BOTTOMLEFT", 2, 0)
			end
			orb.bg:SetVertexColor(0.25, 0.25, 0.25)
			orb.fg:SetVertexColor(color.r, color.g, color.b)
			if not statusbar then
				orb.SetAlpha = SetAlpha
			end
		end
		t.powerType = power
		t.Override = update
		t.UpdateTexture = function() return end -- fuck off oUF >:(
		self[element] = t

		if CUSTOM_CLASS_COLORS then
			CUSTOM_CLASS_COLORS:RegisterCallback(function()
				local color = CUSTOM_CLASS_COLORS[playerClass]
				for i = 1, #t do
					t.fg:SetVertexColor(color.r, color.g, color.b)
				end
			end)
		end
	end

	--------------------
	-- Stacking buffs --
	--------------------

	if unit == "player" and playerClass == "SHAMAN" then
		local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[playerClass]

		local function SetAlpha(orb, alpha)
			if alpha == 1 then
				orb.bg:SetVertexColor(0.25, 0.25, 0.25)
				orb.bg:SetAlpha(1)
				orb.fg:Show()
			else
				orb.bg:SetVertexColor(0.4, 0.4, 0.4)
				orb.bg:SetAlpha(0.5)
				orb.fg:Hide()
			end
		end

		local t = ns.Orbs.Create(self.overlay, 5, 20)
		for i = 1, 5 do
			local orb = t[i]
			if i == 1 then
				orb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 2, 5)
			else
				orb:SetPoint("BOTTOMRIGHT", t[i - 1], "BOTTOMLEFT", 2, 0)
			end
			orb.bg:SetVertexColor(0.25, 0.25, 0.25)
			orb.fg:SetVertexColor(color.r, color.g, color.b)
			orb.SetAlpha = SetAlpha
		end

		t.buff = GetSpellInfo(53817)
		self.PowerStack = t

		if CUSTOM_CLASS_COLORS then
			CUSTOM_CLASS_COLORS:RegisterCallback(function()
				local color = CUSTOM_CLASS_COLORS[playerClass]
				for i = 1, #t do
					t.fg:SetVertexColor(color.r, color.g, color.b)
				end
			end)
		end
	end

	-----------------------
	-- Status icons --
	-----------------------

	if unit == "player" then
		self.Status = ns.CreateFontString(self.overlay, 16, "LEFT")
		self.Status:SetPoint("LEFT", self.Health, "TOPLEFT", 2, 2)

		self:Tag(self.Status, "[leadericon][mastericon]")

		self.Resting = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Resting:SetPoint("LEFT", self.Health, "BOTTOMLEFT", 0, -2)
		self.Resting:SetSize(20, 20)

		self.Combat = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Combat:SetPoint("RIGHT", self.Health, "BOTTOMRIGHT", 0, -2)
		self.Combat:SetSize(24, 24)
	elseif unit == "party" or unit == "target" then
		self.Status = ns.CreateFontString(self.overlay, 16, "RIGHT")
		self.Status:SetPoint("RIGHT", self.Health, "BOTTOMRIGHT", -2, 0)

		self:Tag(self.Status, "[mastericon][leadericon]")
	end

	----------------
	-- Phase icon --
	----------------

	if unit == "party" or unit == "target" or unit == "focus" then
		self.PhaseIcon = self.overlay:CreateTexture(nil, "OVERLAY")
		self.PhaseIcon:SetPoint("TOP", self, "TOP", 0, -4)
		self.PhaseIcon:SetPoint("BOTTOM", self, "BOTTOM", 0, 4)
		self.PhaseIcon:SetWidth(self.PhaseIcon:GetHeight())
		self.PhaseIcon:SetTexture([[Interface\Icons\Spell_Frost_Stun]])
		self.PhaseIcon:SetTexCoord(0.05, 0.95, 0.5 - 0.25 * 0.9, 0.5 + 0.25 * 0.9)
		self.PhaseIcon:SetDesaturated(true)
		self.PhaseIcon:SetBlendMode("ADD")
		self.PhaseIcon:SetAlpha(0.5)
	end

	---------------------
	-- Quest boss icon --
	---------------------

	if unit == "target" then
		self.QuestIcon = self.overlay:CreateTexture(nil, "OVERLAY")
		self.QuestIcon:SetPoint("CENTER", self, "LEFT", 0, 0)
		self.QuestIcon:SetSize(32, 32)
	end

	-----------------------
	-- Raid target icons --
	-----------------------

	self.RaidIcon = self.overlay:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("CENTER", self, 0, 0)
	self.RaidIcon:SetSize(32, 32)

	----------------------
	-- Ready check icon --
	----------------------

	if unit == "player" or unit == "party" then
		self.ReadyCheck = self.overlay:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetPoint("CENTER", self)
		self.ReadyCheck:SetSize(config.height, config.height)
	end

	----------------
	-- Role icons --
	----------------

	if unit == "player" or unit == "party" then
		self.LFDRole = self.overlay:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetPoint("CENTER", self, unit == "player" and "LEFT" or "RIGHT", unit == "player" and -2 or 2, 0)
		self.LFDRole:SetSize(16, 16)
	end

	----------------
	-- Aura icons --
	----------------

	if unit == "player" then
		local GAP = 6

		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
		self.Buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 24)
		self.Buffs:SetHeight(config.height)

		self.Buffs["growth-x"] = "LEFT"
		self.Buffs["growth-y"] = "UP"
		self.Buffs["initialAnchor"] = "BOTTOMRIGHT"
		self.Buffs["num"] = floor((config.width + GAP) / (config.height + GAP))
		self.Buffs["size"] = config.height
		self.Buffs["spacing-x"] = GAP
		self.Buffs["spacing-y"] = GAP

		self.Buffs.CustomFilter   = ns.CustomAuraFilters.player
		self.Buffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Buffs.PostUpdateIcon = ns.PostUpdateAuraIcon
		self.Buffs.PostUpdate     = ns.PostUpdateAuras -- required to detect Dead => Ghost

		self.Buffs.parent = self
	elseif unit == "pet" then
		local GAP = 6

		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
		self.Buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 24)
		self.Buffs:SetHeight(config.height)

		self.Buffs["growth-x"] = "LEFT"
		self.Buffs["growth-y"] = "UP"
		self.Buffs["initialAnchor"] = "BOTTOMRIGHT"
		self.Buffs["num"] = floor((config.width * uconfig.width + GAP) / (config.height + GAP))
		self.Buffs["size"] = config.height
		self.Buffs["spacing-x"] = GAP
		self.Buffs["spacing-y"] = GAP

		self.Buffs.CustomFilter   = ns.CustomAuraFilters.pet
		self.Buffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Buffs.PostUpdateIcon = ns.PostUpdateAuraIcon

		self.Buffs.parent = self
	elseif unit == "party" then
		local GAP = 6

		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("RIGHT", self, "LEFT", -10, 0)
		self.Buffs:SetHeight(config.height)
		self.Buffs:SetWidth((config.height * 4) + (GAP * 3))

		self.Buffs["growth-x"] = "LEFT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs["initialAnchor"] = "RIGHT"
		self.Buffs["num"] = 4
		self.Buffs["size"] = config.height
		self.Buffs["spacing-x"] = GAP
		self.Buffs["spacing-y"] = GAP

		self.Buffs.CustomFilter   = ns.CustomAuraFilters.party
		self.Buffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Buffs.PostUpdateIcon = ns.PostUpdateAuraIcon
		self.Buffs.PostUpdate     = ns.PostUpdateAuras -- required to detect Dead => Ghost

		self.Buffs.parent = self
	elseif unit == "target" then
		local GAP = 6

		local MAX_ICONS = floor((config.width + GAP) / (config.height + GAP)) - 1
		local NUM_BUFFS = math.max(2, floor(MAX_ICONS * 0.25))
		local NUM_DEBUFFS = math.min(MAX_ICONS - 2, floor(MAX_ICONS * 0.75))
		local ROW_HEIGHT = (config.height * 2) + (GAP * 2)

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
		self.Debuffs:SetWidth((config.height * NUM_DEBUFFS) + (GAP * (NUM_DEBUFFS - 1)))
		self.Debuffs:SetHeight(ROW_HEIGHT)

		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs["initialAnchor"] = "BOTTOMLEFT"
		self.Debuffs["num"] = NUM_DEBUFFS
		self.Debuffs["showType"] = true
		self.Debuffs["size"] = config.height
		self.Debuffs["spacing-x"] = GAP
		self.Debuffs["spacing-y"] = GAP * 2

		self.Debuffs.CustomFilter   = ns.CustomAuraFilters.target
		self.Debuffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Debuffs.PostUpdateIcon = ns.PostUpdateAuraIcon
		self.Debuffs.PostUpdate     = ns.PostUpdateAuras -- required to detect Dead => Ghost

		self.Debuffs.parent = self

		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 24)
		self.Buffs:SetWidth((config.height * NUM_BUFFS) + (GAP * (NUM_BUFFS - 1)))
		self.Buffs:SetHeight(ROW_HEIGHT)

		self.Buffs["growth-x"] = "LEFT"
		self.Buffs["growth-y"] = "UP"
		self.Buffs["initialAnchor"] = "BOTTOMRIGHT"
		self.Buffs["num"] = NUM_BUFFS
		self.Buffs["showType"] = false
		self.Buffs["size"] = config.height
		self.Buffs["spacing-x"] = GAP
		self.Buffs["spacing-y"] = GAP * 2

		self.Buffs.CustomFilter   = ns.CustomAuraFilters.target
		self.Buffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Buffs.PostUpdateIcon = ns.PostUpdateAuraIcon

		self.Buffs.parent = self

		self.updateOnRoleChange = self.updateOnRoleChange or {}
		tinsert(self.updateOnRoleChange, function(self, role)
			if role == "HEAL" then
				self.Debuffs:ClearAllPoints()
				self.Debuffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 24)
				self.Debuffs:SetWidth((config.height * NUM_BUFFS) + (GAP * (NUM_BUFFS - 1)))
				self.Debuffs["growth-x"] = "LEFT"
				self.Debuffs["growth-y"] = "UP"
				self.Debuffs["initialAnchor"] = "BOTTOMRIGHT"
				self.Debuffs["num"] = NUM_BUFFS

				self.Buffs:ClearAllPoints()
				self.Buffs:SetWidth((config.height * NUM_DEBUFFS) + (GAP * (NUM_DEBUFFS - 1)))
				self.Buffs["growth-x"] = "RIGHT"
				self.Buffs["growth-y"] = "UP"
				self.Buffs["initialAnchor"] = "BOTTOMLEFT"
				self.Buffs["num"] = NUM_DEBUFFS
			else
				self.Debuffs:ClearAllPoints()
				self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
				self.Debuffs:SetWidth((config.height * NUM_DEBUFFS) + (GAP * (NUM_DEBUFFS - 1)))
				self.Debuffs["growth-x"] = "RIGHT"
				self.Debuffs["growth-y"] = "UP"
				self.Debuffs["initialAnchor"] = "BOTTOMLEFT"
				self.Debuffs["num"] = NUM_DEBUFFS

				self.Buffs:ClearAllPoints()
				self.Buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 24)
				self.Buffs:SetWidth((config.height * NUM_BUFFS) + (GAP * (NUM_BUFFS - 1)))
				self.Buffs["growth-x"] = "LEFT"
				self.Buffs["growth-y"] = "UP"
				self.Buffs["initialAnchor"] = "BOTTOMRIGHT"
				self.Buffs["num"] = NUM_BUFFS
			end
		end)
	end

	---------------
	-- DruidMana --
	---------------

	if unit == "player" and playerClass == "DRUID" and config.druidMana then
		local druidMana = ns.CreateStatusBar(self, 16, "CENTER")
		druidMana:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
		druidMana:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 0)
		druidMana:SetHeight(config.height * config.powerHeight)

		local druidManaText = druidMana.value
		druidManaText:SetPoint("CENTER", 0, 1)
		druidManaText:Hide()
		table.insert(self.mouseovers, druidManaText)

		druidMana.colorPower = true
		druidMana.bg.multiplier = config.powerBG
		druidMana.PostUpdate = ns.PostUpdateDruidMana

		self.DruidMana = druidMana
--[[
		ns.CreateBorder(druidMana)
]]
		local o = self.SetBorderSize
		function self:SetBorderSize(size, offset)
			o(self, size, offset)
			if druidMana:IsShown() then
				local size, offset = self:GetBorderSize()
				local inset = floor(size * -0.2)
				self.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", druidMana, -offset, offset + 1)
				self.BorderTextures.TOPRIGHT:SetPoint("TOPRIGHT", druidMana, offset, offset + 1)
			end
		end
		druidMana:SetScript("OnShow", function(self)
			local frame = self.__owner
			frame:SetBorderParent(self)
			frame:SetBorderSize()
		end)

		druidMana:SetScript("OnHide", function(self)
			local frame = self.__owner
			frame:SetBorderParent(frame.overlay)
			frame:SetBorderSize()
		end)
	end

	----------------
	-- EclipseBar --
	----------------

	if unit == "player" and playerClass == "DRUID" and config.eclipseBar then
		local eclipseBar = ns.CreateEclipseBar(self, config.statusbar, config.eclipseBarIcons)
		eclipseBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
		eclipseBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 0)
		eclipseBar:SetHeight(config.height * config.powerHeight + 1)

		table.insert(ns.statusbars, eclipseBar.bg)
		table.insert(ns.statusbars, eclipseBar.lunarBG)
		table.insert(ns.statusbars, eclipseBar.solarBG)

		local eclipseText = ns.CreateFontString(eclipseBar, 16, "CENTER")
		eclipseText:SetPoint("CENTER", eclipseBar, "CENTER", 0, 1)
		eclipseText:Hide()
		self:Tag(eclipseText, "[pereclipse]%")
		table.insert(self.mouseovers, eclipseText)
		eclipseBar.value = eclipseText
--[[
		ns.CreateBorder(eclipseBar)
		eclipseBar.BorderTextures.LEFT:Hide()
		eclipseBar.BorderTextures.RIGHT:Hide()
]]
		local o = self.SetBorderSize
		function self:SetBorderSize(size, offset)
			o(self, size, offset)
			if eclipseBar:IsShown() then
				local _, offset = self:GetBorderSize()
				local inset = floor(size * -0.2)
				self.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", eclipseBar, -offset, offset)
				self.BorderTextures.TOPRIGHT:SetPoint("TOPRIGHT", eclipseBar, offset, offset)
			end
		end
		eclipseBar:SetScript("OnShow", function(self)
			local frame = self.__owner
			frame:SetBorderParent(self)
			frame:SetBorderSize()
		end)

		eclipseBar:SetScript("OnHide", function(self)
			local frame = self.__owner
			frame:SetBorderParent(frame.overlay)
			frame:SetBorderSize()
		end)

		eclipseBar:SetScript("OnEnter", ns.UnitFrame_OnEnter)
		eclipseBar:SetScript("OnLeave", ns.UnitFrame_OnLeave)

		self.EclipseBar = eclipseBar
	end

	-----------
	-- Runes --
	-----------

	if unit == "player" and playerClass == "DEATHKNIGHT" and config.runeBars then
		local Runes = ns.CreateRunes(self)
		Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		Runes:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -1)
		Runes:SetHeight(config.height * config.powerHeight + 2)

		Runes:SetBackdrop(config.backdrop)
		Runes:SetBackdropColor(0, 0, 0, 1)
		Runes:SetBackdropBorderColor(unpack(config.borderColor))

		local N = #Runes
		local RUNE_WIDTH = (FRAME_WIDTH - (1 * (N + 1))) / N

		for i = 1, N do
			local bar = Runes[i]
			bar:SetWidth(RUNE_WIDTH)
			bar:EnableMouse(false)
			bar.bg.multiplier = config.powerBG
			if i > 1 then
				bar:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
				bar:SetPoint("BOTTOMLEFT", Runes[i-1], "BOTTOMRIGHT", 1, 0)
			else
				bar:SetPoint("TOPLEFT", Runes, 1, -1)
				bar:SetPoint("BOTTOMLEFT", Runes, 1, 1)
			end
		end

		tinsert(self.mouseovers, function(self, isMouseOver)
			local script = isMouseOver and "OnEnter" or "OnLeave"
			for i = 1, N do
				Runes[i]:GetScript(script)(Runes[i])
			end
		end)

		local o = self.SetBorderSize
		function self:SetBorderSize(size, offset)
			o(self, size, offset)
			self:SetBorderParent(Runes[N])

			local size, offset = self:GetBorderSize()
			local inset = floor(size * -0.2)
			self.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", Runes, -offset, offset)
			self.BorderTextures.TOPRIGHT:SetPoint("TOPRIGHT", Runes, offset, offset)
		end
		self:SetBorderSize()

		self.Runes = Runes
	end

	------------
	-- Totems --
	------------

	if unit == "player" and playerClass == "SHAMAN" and config.totemBars then
		local Totems = ns.CreateTotems(self)

		local N = #Totems
		local TOTEM_WIDTH = (FRAME_WIDTH - (1 * (N + 1))) / N

		Totems:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		Totems:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -1)
		Totems:SetHeight(config.height * config.powerHeight + 2)

		Totems:SetBackdrop(config.backdrop)
		Totems:SetBackdropColor(0, 0, 0, 1)
		Totems:SetBackdropBorderColor(unpack(config.borderColor))

		for i = 1, N do
			local bar = Totems[i]
			bar:SetWidth(TOTEM_WIDTH)

			bar.iconFrame:SetSize(TOTEM_WIDTH / 2, TOTEM_WIDTH / 2)
			ns.CreateBorder(bar.iconFrame)

			bar.bg.multiplier = config.powerBG

			bar.bg:SetParent(Totems)
			bar.bg:SetVertexColor(oUF.colors.totems[i][1] * config.powerBG, oUF.colors.totems[i][2] * config.powerBG, oUF.colors.totems[i][3] * config.powerBG)
			bar.bg:Show()

			if i > 1 then
				bar:SetPoint("TOPLEFT", Totems[i-1], "TOPRIGHT", 1, 0)
				bar:SetPoint("BOTTOMLEFT", Totems[i-1], "BOTTOMRIGHT", 1, 0)
			else
				bar:SetPoint("TOPLEFT", Totems, 1, -1)
				bar:SetPoint("BOTTOMLEFT", Totems, 1, 1)
			end
		end

		tinsert(self.mouseovers, function(self, isMouseOver)
			if isMouseOver then
				for i =1, N do
					Totems[i].value:Show()
				end
			else
				for i = 1, N do
					Totems[i].value:Hide()
				end
			end
		end)

		local function UpdateTotemBorders()
			if Totems:IsShown() then
				local totem
				for i = 1, N do
					if Totems[i]:IsShown() then
						totem = Totems[i]
					end
				end
				self:SetBorderParent(totem)

				local size, offset = self:GetBorderSize()
				local inset = floor(size * -0.2)
				self.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", Totems, -offset, offset)
				self.BorderTextures.TOPRIGHT:SetPoint("TOPRIGHT", Totems, offset, offset)
			else
				self:SetBorderParent(self.overlay)
				if not self.changingBorderSize then
					self.changingBorderSize = true
					self:SetBorderSize()
					self.changingBorderSize = nil
				end
			end
		end

		local p = Totems.PostUpdate
		function Totems:PostUpdate(...)
			p(self, ...)
			UpdateTotemBorders()
		end

		local o = self.SetBorderSize
		function self:SetBorderSize(size, offset)
			o(self, size, offset)
			UpdateTotemBorders()
		end
		self:SetBorderSize()

		self.Totems = Totems
	end

	------------------------------
	-- Cast bar, icon, and text --
	------------------------------

	if uconfig.castbar then
		local height = config.height * (1 - config.powerHeight)

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

		if unit == "player" then
			local SafeZone = Castbar:CreateTexture(nil, "BORDER")
			SafeZone:SetTexture(config.statusbar)
			SafeZone:SetVertexColor(1, 0.5, 0, 0.75)
			Castbar.SafeZone = SafeZone

			Castbar.Time = ns.CreateFontString(Castbar, 20, "RIGHT")
			Castbar.Time:SetPoint("RIGHT", Castbar, "RIGHT", -4, 0)

		elseif (uconfig.width or 1) > 0.75 then
			Castbar.Text = ns.CreateFontString(Castbar, 16, "LEFT")
			Castbar.Text:SetPoint("LEFT", Castbar, "LEFT", 4, 0)
		end

		ns.CreateBorder(Castbar, nil, nil, nil, "OVERLAY")

		local _, d = Castbar:GetBorderSize()
		Castbar.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", Castbar.Icon, "TOPLEFT", -d, d)
		Castbar.BorderTextures.BOTTOMLEFT:SetPoint("BOTTOMLEFT", Castbar.Icon, "BOTTOMLEFT", -d, -d)

		local o = Castbar.SetBorderSize
		function Castbar:SetBorderSize(size, offset)
			o(self, size, offset)

			local _, d = Castbar:GetBorderSize()
			self.BorderTextures.TOPLEFT:SetPoint("TOPLEFT", self.Icon, "TOPLEFT", -d, d)
			self.BorderTextures.BOTTOMLEFT:SetPoint("BOTTOMLEFT", self.Icon, "BOTTOMLEFT", -d, -d)
		end

		Castbar.PostCastStart = ns.PostCastStart
		Castbar.PostChannelStart = ns.PostChannelStart
		Castbar.CustomDelayText = ns.CustomDelayText
		Castbar.CustomTimeText = ns.CustomTimeText

		self.Castbar = Castbar
	end

	-----------
	-- Range --
	-----------

	if unit == "pet" or unit == "party" or unit == "partypet" then
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = 0.5,
		}
	end

	----------------------
	-- Element: AFK text --
	----------------------

	if unit == "player" or unit == "party" then
		self.AFK = ns.CreateFontString(self.overlay, 12, "CENTER")
		self.AFK:SetPoint("CENTER", self.Health, "BOTTOM", 0, -2)
		self.AFK.fontFormat = "AFK %s:%s"
	end

	-------------------------------
	-- Element: Dispel highlight --
	-------------------------------

	self.DispelHighlight = ns.UpdateDispelHighlight
	self.DispelHighlightFilter = true

	-------------------------------
	-- Element: Threat highlight --
	-------------------------------

	self.threatLevel = 0
	self.ThreatHighlight = ns.UpdateThreatHighlight

	--------------------------------
	-- Element: Resurrection text --
	--------------------------------

	if not strmatch(unit, ".+target$") and not strmatch(unit, "^arena") and not strmatch(unit, "^boss") then
		self.Resurrection = ns.CreateFontString(self.overlay, 16, "CENTER")
		self.Resurrection:SetPoint("CENTER", self.Health)
	end

	--------------------------------
	-- Plugin: oUF_CombatFeedback --
	--------------------------------

	if IsAddOnLoaded("oUF_CombatFeedback") and not unit:match("^(.+)target$") then
		local cft = ns.CreateFontString(self.overlay, 24, "CENTER")
		cft:SetPoint("CENTER", 0, 1)
		self.CombatFeedbackText = cft
	end

	------------------------
	-- Plugin: oUF_Smooth --
	------------------------

	if IsAddOnLoaded("oUF_Smooth") and not unit:match(".+target$") then
		self.Health.Smooth = true
		if self.Power then
			self.Power.Smooth = true
		end
		if self.DruidMana then
			self.DruidMana.Smooth = true
		end
	end

	----------------------------
	-- Plugin: oUF_SpellRange --
	----------------------------

	if IsAddOnLoaded("oUF_SpellRange") and not self.Range then
		self.SpellRange = {
			insideAlpha = 1,
			outsideAlpha = 0.5,
		}
	end
end

------------------------------------------------------------------------

oUF:Factory(function(oUF)
	config = ns.config

	for _, menu in pairs(UnitPopupMenus) do
		for i = #menu, 1, -1 do
			local name = menu[i]
			if name == "SET_FOCUS" or name == "CLEAR_FOCUS" or name:match("^LOCK_%u+_FRAME$") or name:match("^UNLOCK_%u+_FRAME$") or name:match("^MOVE_%u+_FRAME$") or name:match("^RESET_%u+_FRAME_POSITION") then
				table.remove(menu, i)
			end
		end
	end

	oUF:RegisterStyle("Phanx", ns.Spawn)
	oUF:SetActiveStyle("Phanx")

	local initialConfigFunction = [[
		self:SetAttribute("*type2", "menu")
		self:SetAttribute("initial-width", %d)
		self:SetWidth(%d)
		self:SetAttribute("initial-height", %d)
		self:SetHeight(%d)
	]]

	for u, udata in pairs(ns.uconfig) do
		local name = "oUFPhanx" .. u:gsub("%a", strupper, 1):gsub("target", "Target"):gsub("pet", "Pet")
		if udata.point then
			if udata.attributes then
				-- print("generating header for", u)
				local w = config.width  * (udata.width  or 1)
				local h = config.height * (udata.height or 1)

				ns.headers[u] = oUF:SpawnHeader(name, nil, udata.visible,
					"oUF-initialConfigFunction", initialConfigFunction:format(w, w, h, h),
					unpack(udata.attributes))
			else
				-- print("generating frame for", u)
				ns.frames[u] = oUF:Spawn(u, name)
			end
		end
	end

	for u, f in pairs(ns.frames) do
		local udata = ns.uconfig[u]
		local p1, parent, p2, x, y = string.split(" ", udata.point)
		f:ClearAllPoints()
		f:SetPoint(p1, ns.headers[parent] or ns.frames[parent] or _G[parent] or UIParent, p2, tonumber(x) or 0, tonumber(y) or 0)
	end
	for u, f in pairs(ns.headers) do
		local udata = ns.uconfig[u]
		local p1, parent, p2, x, y = string.split(" ", udata.point)
		f:ClearAllPoints()
		f:SetPoint(p1, ns.headers[parent] or ns.frames[parent] or _G[parent] or UIParent, p2, tonumber(x) or 0, tonumber(y) or 0)
	end

	for i = 1, 3 do
		local barname = "MirrorTimer" .. i
		local bar = _G[barname]

		for i, region in pairs({ bar:GetRegions() }) do
			if region.GetTexture and region:GetTexture() == "SolidTexture" then
				region:Hide()
			end
		end

		bar:SetParent(UIParent)
		bar:SetWidth(225)
		bar:SetHeight(config.height * (1 - config.powerHeight))

		bar.bg = bar:GetRegions()
		bar.bg:ClearAllPoints()
		bar.bg:SetAllPoints(bar)
		bar.bg:SetTexture(config.statusbar)
		bar.bg:SetVertexColor(0.2, 0.2, 0.2, 1)

		bar.text = _G[barname .. "Text"]
		bar.text:ClearAllPoints()
		bar.text:SetPoint("LEFT", bar, 4, 0)
		bar.text:SetFont(config.font, 16, config.fontOutline)

		bar.border = _G[barname .. "Border"]
		bar.border:Hide()

		bar.bar = _G[barname .. "StatusBar"]
		bar.bar:SetAllPoints(bar)
		bar.bar:SetStatusBarTexture(config.statusbar)
		bar.bar:SetAlpha(0.8)

		ns.CreateBorder(bar, nil, nil, bar.bar, "OVERLAY")
	end

	local fixer = CreateFrame("Frame")
	fixer.timer = 2
	fixer:SetScript("OnUpdate", function(self, elapsed)
		self.timer = self.timer - elapsed
		if self.timer <= 0 then
			self:Hide()
			self:SetScript("OnUpdate", nil)
			self.timer = nil
			for _, object in pairs(ns.objects) do
				object:UpdateAllElements("ForceUpdate")
			end
		end
	end)
end)