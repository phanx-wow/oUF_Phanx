--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
	Copyright © 2007–2011. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curse.com/downloads/wow-addons/details/ouf-phanx.aspx
----------------------------------------------------------------------]]

local _, ns = ...
local config
local colors = oUF.colors
local playerClass = select(2, UnitClass("player"))
local playerUnits = { player = true, pet = true, vehicle = true }
local noop = function() return end

ns.frames, ns.headers, ns.objects, ns.fontstrings, ns.statusbars = { }, { }, { }, { }, { }

------------------------------------------------------------------------

ns.si = function(value)
	local absvalue = abs(value)

	if absvalue >= 10000000 then
		return ("%.1fm"):format(value / 1000000)
	elseif absvalue >= 1000000 then
		return ("%.2fm"):format(value / 1000000)
	elseif absvalue >= 100000 then
		return ("%.0fk"):format(value / 1000)
	elseif absvalue >= 1000 then
		return ("%.1fk"):format(value / 1000)
	end

	return value
end

local si = ns.si

------------------------------------------------------------------------

ns.UpdateBorder = function(self)
	local threat, debuff, dispellable = self.threatLevel, self.debuffType, self.debuffDispellable
	-- print("UpdateBorder", self.unit, "threatLevel", threat, "debuffType", debuff, "debuffDispellable", dispellable)

	local color
	if debuff and dispellable then
		-- print(self.unit, "has dispellable debuff:", debuff)
		color = colors.debuff[debuff]
	elseif threat and threat > 1 then
		-- print(self.unit, "has aggro:", threat)
		color = colors.threat[threat]
	elseif debuff and not config.dispelFilter then
		-- print(self.unit, "has debuff:", debuff)
		color = colors.debuff[debuff]
	elseif threat and threat > 0 then
		-- print(self.unit, "has high threat")
		color = colors.threat[threat]
	else
		-- print(self.unit, "is normal")
	end

	if color then
		self:SetBackdropBorderColor(color[1], color[2], color[3], 1)
	else
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end
end

------------------------------------------------------------------------

ns.PostUpdateHealth = function(self, unit, cur, max)
	if not UnitIsConnected(unit) then
		local color = colors.disconnected
		local power = self.__owner.Power
		if power then
			power:SetValue(0)
			if power.value then
				power.value:SetText(nil)
			end
		end
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		local color = colors.disconnected
		local power = self.__owner.Power
		if power then
			power:SetValue(0)
			if power.value then
				power.value:SetText(nil)
			end
		end
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, UnitIsGhost(unit) and GHOST or DEAD)
	end

	if cur > 0 then
		self:GetStatusBarTexture():SetTexCoord(0, cur / max, 0, 1)
	end

	local color
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = colors.class[class]
	elseif UnitIsUnit(unit, "pet") and GetPetHappiness() then
		color = colors.happiness[GetPetHappiness()]
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = colors.tapped
	elseif UnitIsEnemy(unit, "player") then
		color = colors.reaction[1]
	else
		color = colors.reaction[UnitReaction(unit, "player") or 5]
	end

	-- HEALER: deficit, percent on mouseover
	-- OTHER:  percent, current on mouseover

	if cur < max then
		if ns.isHealing and UnitCanAssist("player", unit) then
			if self.__owner.isMouseOver and not unit:match("^party") then
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(UnitHealth(unit)))
			else
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(UnitHealth(unit) - UnitHealthMax(unit)))
			end
		elseif self.__owner.isMouseOver then
			self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(UnitHealth(unit)))
		else
			self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.5))
		end
	elseif self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(UnitHealthMax(unit)))
	else
		self.value:SetText(nil)
	end
end

------------------------------------------------------------------------

ns.UpdateIncomingHeals = function(self, event, unit)
	if self.unit ~= unit then return end

	local bar = self.HealPrediction

	local incoming = UnitGetIncomingHeals(unit) or 0

	if incoming == 0 then
		return bar:Hide()
	end

	local health = self.Health:GetValue()
	local _, maxHealth = self.Health:GetMinMaxValues()

	if health == maxHealth then
		return bar:Hide()
	end

	if self.ignoreSelf then
		incoming = incoming - (UnitGetIncomingHeals(unit, "player") or 0)
	end

	if incoming == 0 then
		return bar:Hide()
	end

	bar:SetMinMaxValues(0, maxHealth)
	bar:SetValue(health + incoming)
	bar:Show()
end

------------------------------------------------------------------------

ns.PostUpdatePower = function(self, unit, cur, max)
	local shown = self:IsShown()
	if max == 0 then
		if shown then
			self:Hide()
		end
		return
	elseif not shown then
		self:Show()
	end

	if UnitIsDeadOrGhost(unit) then
		self:SetValue(0)
		if self.value then
			self.value:SetText(nil)
		end
		return
	end

	if cur > 0 then
		self:GetStatusBarTexture():SetTexCoord(0, cur / max, 0, 1)
	end

	if not self.value then return end

	local _, type = UnitPowerType(unit)
	local color = colors.power[type] or colors.power.FUEL
	if cur < max then
		if self.__owner.isMouseOver then
			self.value:SetFormattedText("%s.|cff%02x%02x%02x%s|r", si(UnitPower(unit)), color[1] * 255, color[2] * 255, color[3] * 255, si(UnitPowerMax(unit)))
		elseif type == "MANA" then
			self.value:SetFormattedText("%d|cff%02x%02x%02x%%|r", floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5), color[1] * 255, color[2] * 255, color[3] * 255)
		elseif cur > 0 then
			self.value:SetFormattedText("%d|cff%02x%02x%02x|r", floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5), color[1] * 255, color[2] * 255, color[3] * 255)
		else
			self.value:SetText(nil)
		end
	elseif type == "MANA" and self.__owner.isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(UnitPowerMax(unit)))
	else
		self.value:SetText(nil)
	end
end

------------------------------------------------------------------------

local AuraIconCD_OnShow = function(cd)
	local button = cd:GetParent()
	button:SetBorderParent(cd)
	button.count:SetParent(cd)
end

local AuraIconCD_OnHide = function(cd)
	local button = cd:GetParent()
	button:SetBorderParent(button)
	button.count:SetParent(button)
end

local AuraIconOverlay_SetBorderColor = function(overlay, r, g, b)
	if not r or not g or not b then
		r, g, b = unpack(config.borderColor)
	end
	overlay:GetParent():SetBorderColor(r, g, b)
end

ns.PostCreateAuraIcon = function(iconframe, button)
	ns.CreateBorder(button, 12)

	button.cd:SetReverse(true)
	button.cd:SetScript("OnHide", AuraIconCD_OnHide)
	button.cd:SetScript("OnShow", AuraIconCD_OnShow)
	if button.cd:IsShown() then AuraIconCD_OnShow(button.cd) end

	button.icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

	button.overlay:Hide()
	button.overlay.Hide = AuraIconOverlay_SetBorderColor
	button.overlay.SetVertexColor = AuraIconOverlay_SetBorderColor
	button.overlay.Show = noop

	button:SetScript("OnClick", nil) -- because oUF still tries to cancel buffs on right-click, and Blizzard thinks preventing this will stop botting?
end

ns.PostUpdateAuraIcon = function(iconframe, unit, button, index, offset)
	local name, _, texture, count, type, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID = UnitAura(unit, index, button.filter)

	if playerUnits[caster] then
		button.icon:SetDesaturated(false)
	else
		button.icon:SetDesaturated(true)
	end

	if button.timer then return end

	if OmniCC then
		for i = 1, button:GetNumChildren() do
			local child = select(i, button:GetChildren())
			if child.text and (child.icon == button.icon or child.cooldown == button.cd) then
				-- found it!
				child.ClearAllPoints = noop
				child.SetAlpha = noop
				child.SetPoint = noop
				child.SetScale = noop

				child.text:ClearAllPoints()
				child.text.ClearAllPoints = noop

				child.text:SetPoint("CENTER", button, "TOP", 0, 2)
				child.text.SetPoint = noop

				child.text:SetFont(config.font, unit:match("^party") and 14 or 18, config.fontOutline)
				child.text.SetFont = noop

				child.text:SetTextColor(1, 0.8, 0)
				child.text.SetTextColor = noop
				child.text.SetVertexColor = noop

				tinsert(ns.fontstrings, child.text)

				button.timer = child.text

				return
			end
		end
	else
		button.timer = true
	end
end

------------------------------------------------------------------------

ns.PostCastStart = function(self, unit, name, rank, castid)
	local r, g, b
	if UnitIsUnit(unit, "player") then
		r, g, b = unpack(colors.class[playerClass])
	elseif self.interrupt then
		r, g, b = unpack(colors.uninterruptible)
	elseif UnitIsFriend(unit, "player") then
		r, g, b = unpack(colors.reaction[5])
	else
		r, g, b = unpack(colors.reaction[1])
	end
	self:SetBackdropColor(r * 0.2, g * 0.2, b * 0.2)
	self:SetStatusBarColor(r * 0.6, g * 0.6, b * 0.6)

	if self.SafeZone then
		self:GetStatusBarTexture():SetDrawLayer("ARTWORK")
		self.SafeZone:SetDrawLayer("BORDER")
		self.SafeZone:ClearAllPoints()
		self.SafeZone:SetPoint("TOPRIGHT", self)
		self.SafeZone:SetPoint("BOTTOMRIGHT", self)
	end
end

ns.PostChannelStart = function(self, unit, name, rank, text)
	local r, g, b
	if UnitIsUnit(unit, "player") then
		r, g, b = unpack(colors.class[playerClass])
	elseif self.interrupt then
		r, g, b = unpack(colors.reaction[4])
	elseif UnitIsFriend(unit, "player") then
		r, g, b = unpack(colors.reaction[5])
	else
		r, g, b = unpack(colors.reaction[1])
	end
	self:SetBackdropColor(r * 0.2, g * 0.2, b * 0.2)
	self:SetStatusBarColor(r * 0.6, g * 0.6, b * 0.6)

	if self.SafeZone then
		self:GetStatusBarTexture():SetDrawLayer("BORDER")
		self.SafeZone:SetDrawLayer("ARTWORK")
		self.SafeZone:ClearAllPoints()
		self.SafeZone:SetPoint("TOPLEFT", self)
		self.SafeZone:SetPoint("BOTTOMLEFT", self)
	end
end

------------------------------------------------------------------------

ns.UpdateDispelHighlight = function(self, unit, debuffType, canDispel)
	-- print("UpdateDispelHighlight", unit, debuffType, canDispel)

	self:UpdateBorder()
end

------------------------------------------------------------------------

ns.UpdateThreatHighlight = function(self, unit, status)
	-- print("UpdateThreatHighlight", unit, status)

	if not config.threatLevels then
		status = status > 1 and 3 or 0
	end

	if self.threatLevel == status then return end
	-- print("New threat status:", status)

	self.threatLevel = status
	self:UpdateBorder()
end

------------------------------------------------------------------------

ns.UnitFrame_OnEnter = function(self)
	if IsShiftKeyDown() or not UnitAffectingCombat("player") then
		UnitFrame_OnEnter(self)
	end
	self.isMouseOver = true
	for _, element in ipairs(self.mouseovers) do
		element:ForceUpdate()
	end
end

ns.UnitFrame_OnLeave = function(self)
	UnitFrame_OnLeave(self)
	self.isMouseOver = nil
	for _, element in ipairs(self.mouseovers) do
		element:ForceUpdate()
	end
end

ns.UnitFrame_DropdownMenu = function(self)
	local unit = self.unit:sub(1, -2)
	if unit == "party" or unit == "partypet" then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame" .. self.id .. "DropDown"], "cursor", 0, 0)
	else
		local cunit = self.unit:gsub("^%l", string.upper)
		if cunit == "Vehicle" then
			cunit = "Pet"
		end
		if _G[cunit .. "FrameDropDown"] then
			ToggleDropDownMenu(1, nil, _G[cunit .. "FrameDropDown"], "cursor", 0, 0)
		end
	end
end

------------------------------------------------------------------------

ns.CreateFontString = function(parent, size, justify)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(config.font, size or 16, config.fontOutline)
	fs:SetJustifyH(justify or "LEFT")
	fs:SetShadowOffset(1, -1)

	tinsert(ns.fontstrings, fs)
	return fs
end

ns.SetStatusBarValue = function(self, cur)
	local min, max = self:GetMinMaxValues()
	self:GetStatusBarTexture():SetTexCoord(0, (cur - min) / (max - min), 0, 1)
	self.orig_SetValue(self, cur)
end

ns.CreateStatusBar = function(parent, size, justify, nohook)
	local sb = CreateFrame("StatusBar", nil, parent)
	sb:SetStatusBarTexture(config.statusbar)
	sb:GetStatusBarTexture():SetDrawLayer("BORDER")
	sb:GetStatusBarTexture():SetHorizTile(false)
	sb:GetStatusBarTexture():SetVertTile(false)

	sb.bg = sb:CreateTexture(nil, "BACKGROUND")
	sb.bg:SetTexture(config.statusbar)
	sb.bg:SetAllPoints(true)

	if size then
		sb.value = ns.CreateFontString(sb, size, justify)
	end

	if not nohook then
		sb.orig_SetValue = sb.SetValue
		sb.SetValue = ns.SetStatusBarValue
	end

	tinsert(ns.statusbars, sb)
	return sb
end

------------------------------------------------------------------------

ns.Spawn = function(self, unit, isSingle)
	if self:GetParent():GetAttribute("useOwnerUnit") then
		local suffix = self:GetParent():GetAttribute("unitsuffix")
		self:SetAttribute("useOwnerUnit", true)
		self:SetAttribute("unitsuffix", suffix)
		unit = unit .. suffix
	end

	print("Spawn", self:GetName(), unit)
	tinsert(ns.objects, self)

	self.mouseovers = { }

	self.menu = ns.UnitFrame_DropdownMenu

	self:HookScript("OnEnter", ns.UnitFrame_OnEnter)
	self:HookScript("OnLeave", ns.UnitFrame_OnLeave)

	self:RegisterForClicks("anyup")

	local FRAME_WIDTH  = config.width  * (ns.uconfig[unit].width  or 1)
	local FRAME_HEIGHT = config.height * (ns.uconfig[unit].height or 1)

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
	-- Health bar and text --
	-------------------------

	self.Health = ns.CreateStatusBar(self, 24, "RIGHT", true)
	self.Health:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2)
	self.Health:SetPoint("TOPRIGHT", self, "TOPRIGHT", -1, -2)
	self.Health:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)

	self.Health:GetStatusBarTexture():SetDrawLayer("ARTWORK")
	self.Health.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, config.height * config.powerHeight - 2)

	local mu = config.bgColorIntensity
	local r, g, b = unpack(config.borderColor)
	self.Health:SetStatusBarColor(r, g, b)
	self.Health.bg:SetVertexColor(r * mu, g * mu, b * mu)
	self.Health.bg.multiplier = mu

	self.Health.PostUpdate = ns.PostUpdateHealth
	tinsert(self.mouseovers, self.Health)

	---------------------------
	-- Predicted healing bar --
	---------------------------

	self.HealPrediction = ns.CreateStatusBar(self)
	self.HealPrediction:SetAllPoints(self.Health)
	self.HealPrediction:SetAlpha(0.25)
	self.HealPrediction:SetStatusBarColor(0, 1, 0)
	self.HealPrediction:Hide()

	self.HealPrediction:SetFrameLevel(self.Health:GetFrameLevel())

	self.HealPrediction.bg:ClearAllPoints()
	self.HealPrediction.bg:SetTexture("")
	self.HealPrediction.bg:Hide()
	self.HealPrediction.bg = nil

	self.HealPrediction.ignoreSelf = config.ignoreOwnHeals
	self.HealPrediction.maxOverflow = 1

	self.HealPrediction.Override = ns.UpdateIncomingHeals

	------------------------
	-- Power bar and text --
	------------------------

	if ns.uconfig[unit].power then
		self.Power = ns.CreateStatusBar(self, (ns.uconfig[unit].width or 1) > 0.75 and 16, "LEFT", true)
		self.Power:SetFrameLevel(self.Health:GetFrameLevel() + 2)
		self.Power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)
		self.Power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		self.Power:SetHeight(config.height * config.powerHeight)

		if self.Power.value then
			self.Power.value:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 4, config.height * config.powerHeight - 2)
			self.Power.value:SetPoint("BOTTOMRIGHT", self.Health.value, "BOTTOMLEFT", -8, 0)

			tinsert(self.mouseovers, self.Power)
		end

		self.Power.bg.multiplier = 0.5
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.frequentUpdates = (unit == "player")

		self.Power.PostUpdate = ns.PostUpdatePower
	end

	-----------------------------------------------------------
	-- Overlay to avoid reparenting stuff on powerless units --
	-----------------------------------------------------------

	self.overlay = CreateFrame("Frame", nil, self)
	self.overlay:SetAllPoints(self)
	self.overlay:SetFrameLevel(self.Health:GetFrameLevel() + (self.Power and 3 or 2))

	self.Health.value:SetParent(self.overlay)

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

		self.Name = ns.CreateFontString(self.overlay, 20, "LEFT")
		self.Name:SetPoint("BOTTOMLEFT", self.Level, "BOTTOMRIGHT", 0, -1)
		self.Name:SetPoint("BOTTOMRIGHT", self.Threat or self.Health, self.Threat and "BOTTOMLEFT" or "TOPRIGHT", self.Threat and -8 or -2, self.Threat and 0 or -4)

		self:Tag(self.Name, "[unitcolor][name]")
	end

	if unit == "targettarget" or unit == "focustarget" or unit == "party" or unit == "partypet" then
		self.Name = ns.CreateFontString(self.overlay, 20, "LEFT")
		self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2, -4)
		self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -2, -4)

		self:Tag(self.Name, "[unitcolor][name]")
	end

	-----------------
	-- Soul shards --
	-----------------
--[=[
	if unit == "player" and playerClass == "WARLOCK" then
		self.SoulShards = { }
		for i = 1, 3 do
			self.SoulShards[i] = self.overlay:CreateTexture(nil, "OVERLAY")
			self.SoulShards[i]:SetTexture([[Interface\PlayerFrame\UI-WarlockShard]])
			self.SoulShards[i]:SetTexCoord(2/128, 16/128, 2/64, 27/64)
		end
		self.SoulShards[2]:SetPoint("CENTER", self, "BOTTOM", 0, 0)
		self.SoulShards[1]:SetPoint("RIGHT", self.SoulShards[2], "LEFT", 0, 0)
		self.SoulShards[3]:SetPoint("LEFT", self.SoulShards[2], "RIGHT", 0, 0)
	end
--]=]
	-----------------------
	-- Combo points text --
	-----------------------

	if unit == "target" then
		self.ComboPointsText = ns.CreateFontString(self.overlay, 32, "RIGHT")
		self.ComboPointsText:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", -10, config.height * config.powerHeight - 6)
		self.ComboPointsText:SetTextColor(colors.class[playerClass][1], colors.class[playerClass][2], colors.class[playerClass][3])
		self:Tag(self.ComboPointsText, "[cpoints]")
	elseif unit == "player" then
		if playerClass == "PALADIN" then
			self.HolyPowerText = ns.CreateFontString(self.overlay, 32, "LEFT")
			self.HolyPowerText:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", 10, config.height * config.powerHeight - 6)
			self.HolyPowerText:SetTextColor(colors.class[playerClass][1], colors.class[playerClass][2], colors.class[playerClass][3])
			self:Tag(self.HolyPowerText, "[holypower]")
		elseif playerClass == "PRIEST" then
			self.ShadowOrbsText = ns.CreateFontString(self.overlay, 32, "LEFT")
			self.ShadowOrbsText:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", 10, config.height * config.powerHeight - 6)
			self.ShadowOrbsText:SetTextColor(colors.class[playerClass][1], colors.class[playerClass][2], colors.class[playerClass][3])
			self:Tag(self.ShadowOrbsText, "[shadoworbs]")
		elseif playerClass == "SHAMAN" then
			self.MaelstromText = ns.CreateFontString(self.overlay, 32, "LEFT")
			self.MaelstromText:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", 10, config.height * config.powerHeight - 6)
			self.MaelstromText:SetTextColor(colors.class[playerClass][1], colors.class[playerClass][2], colors.class[playerClass][3])
			self:Tag(self.MaelstromText, "[maelstrom]")
		elseif playerClass == "WARLOCK" then
			self.SoulShardsText = ns.CreateFontString(self.overlay, 32, "LEFT")
			self.SoulShardsText:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", 10, config.height * config.powerHeight - 6)
			self.SoulShardsText:SetTextColor(colors.class[playerClass][1], colors.class[playerClass][2], colors.class[playerClass][3])
			self:Tag(self.SoulShardsText, "[soulshards]")
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
		self.PhaseIcon:SetTexCoord(0.05, 0.95, 0.5-0.25*0.9, 0.5+0.25*0.9)
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
		self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, 24)
		self.Buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, 24)
		self.Buffs:SetHeight(config.height)

		self.Buffs["growth-x"] = "LEFT"
		self.Buffs["growth-y"] = "UP"
		self.Buffs["initialAnchor"] = "BOTTOMRIGHT"
		self.Buffs["num"] = floor((config.width - 4 + GAP) / (config.height + GAP))
		self.Buffs["size"] = config.height
		self.Buffs["spacing-x"] = GAP
		self.Buffs["spacing-y"] = GAP

		self.Buffs.CustomFilter   = ns.CustomAuraFilter
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

		self.Buffs.CustomFilter   = ns.CustomAuraFilter
		self.Buffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Buffs.PostUpdateIcon = ns.PostUpdateAuraIcon

		self.Buffs.parent = self
	elseif unit == "target" then
		local GAP = 6

		local MAX_ICONS = floor((config.width - 4 + GAP) / (config.height + GAP)) - 1
		local NUM_BUFFS = math.max(1, floor(MAX_ICONS * 0.2))
		local NUM_DEBUFFS = math.min(MAX_ICONS - 1, floor(MAX_ICONS * 0.8))

		self.Debuffs = CreateFrame("Frame", nil, self)

		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs["initialAnchor"] = "BOTTOMLEFT"
		self.Debuffs["num"] = NUM_DEBUFFS
		self.Debuffs["showType"] = true
		self.Debuffs["size"] = config.height
		self.Debuffs["spacing-x"] = GAP
		self.Debuffs["spacing-y"] = GAP * 2

		self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, 24)
		self.Debuffs:SetWidth( (config.height * NUM_DEBUFFS) + (GAP * (NUM_DEBUFFS - 1)) )
		self.Debuffs:SetHeight( (config.height * 2) + (GAP * 2) )

		self.Debuffs.CustomFilter   = ns.CustomAuraFilter
		self.Debuffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Debuffs.PostUpdateIcon = ns.PostUpdateAuraIcon

		self.Debuffs.parent = self

		self.Buffs = CreateFrame("Frame", nil, self)

		self.Buffs["growth-x"] = "LEFT"
		self.Buffs["growth-y"] = "UP"
		self.Buffs["initialAnchor"] = "BOTTOMRIGHT"
		self.Buffs["num"] = NUM_BUFFS
		self.Buffs["showType"] = false
		self.Buffs["size"] = config.height
		self.Buffs["spacing-x"] = GAP
		self.Buffs["spacing-y"] = GAP * 2

		self.Buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, 24)
		self.Buffs:SetWidth( (config.height * NUM_BUFFS) + (GAP * (NUM_BUFFS - 1)) )
		self.Buffs:SetHeight( (config.height * 2) + (GAP * 2) )

		self.Buffs.CustomFilter   = ns.CustomAuraFilter
		self.Buffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Buffs.PostUpdateIcon = ns.PostUpdateAuraIcon

		self.Buffs.parent = self
	end

	------------------------------
	-- Cast bar, icon, and text --
	------------------------------

	if ns.uconfig[unit].castbar then
		local height = config.height * (1 - config.powerHeight)

		self.Castbar = ns.CreateStatusBar(self)
		self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", height, -10)
		self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -10)
		self.Castbar:SetHeight(height)

		self.Castbar.bg:SetVertexColor(unpack(config.borderColor))

		self.Castbar.Icon = self.Castbar:CreateTexture(nil, "BACKDROP")
		self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar, "TOPLEFT", 0, 0)
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", 0, 0)
		self.Castbar.Icon:SetWidth(height)
		self.Castbar.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

		if unit == "player" then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "BORDER")
			self.Castbar.SafeZone:SetTexture(config.statusbar)
			self.Castbar.SafeZone:SetVertexColor(1, 0.5, 0, 0.75)

			self.Castbar.Time = ns.CreateFontString(self.Castbar, 20, "RIGHT")
			self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -4, 0)
		elseif (ns.uconfig[unit].width or 1) > 0.75 then
			self.Castbar.Text = ns.CreateFontString(self.Castbar, 16, "LEFT")
			self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 4, 0)
		end

		self.Castbar.PostCastStart = ns.PostCastStart
		self.Castbar.PostChannelStart = ns.PostChannelStart

		ns.CreateBorder(self.Castbar)
		for i, tex in ipairs(self.Castbar.BorderTextures) do
			tex:SetDrawLayer("OVERLAY")
		end

		local d = floor(config.borderSize / 2 + 0.5) - 2
		self.Castbar.BorderTextures[1]:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -d, d)
		self.Castbar.BorderTextures[4]:SetPoint("BOTTOMLEFT", self.Castbar.Icon, "BOTTOMLEFT", -d, -d)

		local o = self.Castbar.SetBorderSize
		self.Castbar.SetBorderSize = function(self, size, offset)
			o(self, size, offset)
			local d = floor(size / 2 + 0.5) - 2
			self.BorderTextures[1]:SetPoint("TOPLEFT", self.Icon, "TOPLEFT", -d, d)
			self.BorderTextures[4]:SetPoint("BOTTOMLEFT", self.Icon, "BOTTOMLEFT", -d, -d)
		end
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

	-------------------------
	-- Border and backdrop --
	-------------------------

	ns.CreateBorder(self, config.borderSize)
	self:SetBorderParent(self.overlay)
	self.UpdateBorder = ns.UpdateBorder

	self:SetBackdrop(config.backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(unpack(config.borderColor))

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

	if not unit:match("^.+target$") then
		self.Resurrection = ns.CreateFontString(self.overlay, 16, "CENTER")
		self.Resurrection:SetPoint("CENTER", self.Health)
	end

	------------------------
	-- Plugin: oUF_Smooth --
	------------------------

	if IsAddOnLoaded("oUF_Smooth") and not unit:match(".+target$") then
		self.Health.Smooth = true
		if self.Power then
			self.Power.Smooth = true
		end
	end
end

------------------------------------------------------------------------

oUF:Factory(function(oUF)
	config = ns.config

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
		local name = "oUFPhanx" .. u:gsub("%a", string.upper, 1):gsub("target", "Target"):gsub("pet", "Pet")
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
		f:SetPoint(p1, ns.headers[parent] or ns.frames[parent] or _G[parent] or UIParent, p2, tonumber(x) or 0, tonumber(y) or 0)
		f:Show()
	end
	for u, f in pairs(ns.headers) do
		local udata = ns.uconfig[u]
		local p1, parent, p2, x, y = string.split(" ", udata.point)
		f:SetPoint(p1, ns.headers[parent] or ns.frames[parent] or _G[parent] or UIParent, p2, tonumber(x) or 0, tonumber(y) or 0)
		f:Show()
	end

	for i = 1, 3 do
		local barname = "MirrorTimer" .. i
		local bar = _G[barname]

		for i, region in pairs({ bar:GetRegions() }) do
			if region.GetTexture and region:GetTexture() == "SolidTexture" then
				region:Hide()
			end
		end

		ns.CreateBorder(bar)

		bar:SetParent(UIParent)
		bar:SetWidth(225)
		bar:SetHeight(config.height * (1 - config.powerHeight))

		_G[barname .. "Border"]:Hide()

		_G[barname .. "Background"] = bar:CreateTexture(nil, "BACKGROUND")
		_G[barname .. "Background"]:SetAllPoints(bar)
		_G[barname .. "Background"]:SetTexture(config.statusbar)
		_G[barname .. "Background"]:SetVertexColor(0.2, 0.2, 0.2, 1)

		_G[barname .. "Text"]:ClearAllPoints()
		_G[barname .. "Text"]:SetPoint("LEFT", bar, 4, 1)
		_G[barname .. "Text"]:SetFont(config.font, 16, "OUTLINE")

		_G[barname .. "StatusBar"]:SetAllPoints(bar)
		_G[barname .. "StatusBar"]:SetStatusBarTexture(config.statusbar)
		_G[barname .. "StatusBar"]:SetAlpha(0.8)
	end
end)
