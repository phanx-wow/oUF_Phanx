--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")
local colors = oUF.colors
local noop = function() return end
local playerUnits = { player = true, pet = true, vehicle = true }
local si = ns.si
ns.noop = noop

------------------------------------------------------------------------

ns.framePrototype = {
	RegisterForMouseover = function(self, element)
		if not self.mouseovers then
			self.mouseovers = {}
		else
			for i = 1, #self.mouseovers do
				if self.mouseovers[i] == element then
					return
				end
			end
		end
		tinsert(self.mouseovers, element)
	end,
	RegisterForRoleChange = function(self, func)
		if not self.updateOnRoleChange then
			self.updateOnRoleChange = {}
		else
			for i = 1, #self.updateOnRoleChange do
				if self.updateOnRoleChange[i] == func then
					return
				end
			end
		end
		tinsert(self.updateOnRoleChange, func)
	end,
}

------------------------------------------------------------------------
--	General utility
------------------------------------------------------------------------

if playerClass == "HUNTER" or playerClass == "MAGE" or playerClass == "ROGUE" or playerClass == "WARLOCK" then
	function ns.GetPlayerRole()
		return "DAMAGER"
	end
else
	function ns.GetPlayerRole()
		local spec = GetSpecialization()
		local role = spec and spec > 0 and select(6, GetSpecializationInfo(spec))
		return role or "DAMAGER"
	end
end

------------------------------------------------------------------------
--	Border
------------------------------------------------------------------------

function ns.ExtraBar_OnShow(self) --if self.__name then print("Show", self.__name) end
	local frame = self.__owner
	local _, dL, dR, dT, dB = frame:GetBorderSize()
	frame:SetBorderSize(nil, dL, dR, dT + (self:GetHeight() - 1), dB)
	if self.value then
		return self.value:SetParent(frame.overlay)
	end
	for i = 1, #self do
		local v = self[i]
		if type(v) == "table" and v.value then
			v.value:SetParent(frame.overlay)
		end
	end
end

function ns.ExtraBar_OnHide(self) --if self.__name then print("Hide", self.__name) end
	local frame = self.__owner
	local _, dL, dR, dT, dB = frame:GetBorderSize()
	frame:SetBorderSize(nil, dL, dR, max(0, dT - (self:GetHeight() - 1)), dB)
	if self.value then
		return self.value:SetParent(self)
	end
	for i = 1, #self do
		local v = self[i]
		if type(v) == "table" and v.value then
			v.value:SetParent(self)
		end
	end
end

function ns.UpdateBorder(self)
	local threat, debuff, dispellable = self.threatLevel, self.debuffType, self.debuffDispellable
	-- print("UpdateBorder", self.unit, "threatLevel", threat, "debuffType", debuff, "debuffDispellable", dispellable)

	local color, glow
	if debuff and dispellable then
		-- print(self.unit, "has dispellable debuff:", debuff)
		color = colors.debuff[debuff]
		glow = true
	elseif threat and threat > 1 then
		-- print(self.unit, "has aggro:", threat)
		color = colors.threat[threat]
		glow = true
	elseif debuff and not ns.config.dispelFilter then
		-- print(self.unit, "has debuff:", debuff)
		color = colors.debuff[debuff]
	elseif threat and threat > 0 then
		-- print(self.unit, "has high threat")
		color = colors.threat[threat]
	end

	if color then
		self:SetBackdropBorderColor(color[1], color[2], color[3], 1, glow and ns.config.borderGlow)
	else
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end
end

------------------------------------------------------------------------
--	Health
------------------------------------------------------------------------

do
	local GHOST = GetSpellInfo(8326)
	if GetLocale() == "deDE" then
		GHOST = "Geist" -- TOO LONG OMG
	end

	local UnitIsConnected, UnitIsGhost, UnitIsDead, UnitIsPlayer, UnitClass, UnitIsTapped, UnitIsTappedByPlayer, UnitIsTappedByAllThreatList, UnitIsEnemy, UnitReaction, UnitCanAssist
		 = UnitIsConnected, UnitIsGhost, UnitIsDead, UnitIsPlayer, UnitClass, UnitIsTapped, UnitIsTappedByPlayer, UnitIsTappedByAllThreatList, UnitIsEnemy, UnitReaction, UnitCanAssist

	function ns.Health_PostUpdate(bar, unit, cur, max)
		local frame = bar.__owner

		ns.HealPrediction_Override(frame, "Health_PostUpdate", unit)

		local absent = not UnitIsConnected(unit) and PLAYER_OFFLINE or UnitIsGhost(unit) and GHOST or UnitIsDead(unit) and DEAD
		if absent then
			bar:SetValue(0) -- 5.2: UnitHealth is sometimes > 0 for dead units
			local power = frame.Power
			if power then
				power:SetValue(0)
				if power.value then
					power.value:SetText(nil)
				end
			end
			local color = colors.disconnected
			if frame.isMouseOver and max > 0 then -- max is 0 for offline units
				return bar.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(max))
			else
				return bar.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, absent)
			end
		end

		local color
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			color = colors.class[class]
		elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) then
			color = colors.tapped
		elseif UnitIsEnemy(unit, "player") then
			color = colors.reaction[1]
		else
			color = colors.reaction[UnitReaction(unit, "player") or 5] or colors.reaction[5]
		end
		if not color then
			color = colors.fallback
		end

		-- HEALER: deficit, percent on mouseover
		-- OTHER:  percent, current on mouseover

		if cur < max then
			if ns.GetPlayerRole() == "HEALER" and UnitCanAssist("player", unit) then
				if frame.isMouseOver and not frame.isGroupFrame then
					-- don't change text on party frames, it's annoying for click-cast or mouseover healing
					bar.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(cur))
				else
					bar.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(cur - max))
				end
			elseif frame.isMouseOver then
				bar.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(cur))
			else
				bar.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(cur / max * 100 + 0.5))
			end
		elseif frame.isMouseOver then
			bar.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(max))
		else
			bar.value:SetText(nil)
		end
	end
end

------------------------------------------------------------------------
--	HealPrediction
------------------------------------------------------------------------

do
	local UnitHealth, UnitHealthMax, UnitGetTotalAbsorbs, UnitGetIncomingHeals, UnitIsDeadOrGhost
	    = UnitHealth, UnitHealthMax, UnitGetTotalAbsorbs, UnitGetIncomingHeals, UnitIsDeadOrGhost

	function ns.HealPrediction_Override(self, event, unit)
		--print("HealPrediction Override", event, unit)
		local element = self.HealPrediction
		local parent = self.Health

		if UnitIsDeadOrGhost(unit) then
			element.healingBar:Hide()
			element.healingBar.cap:Hide()
			element.absorbsBar:Hide()
			element.absorbsBar.cap:Hide()
			return
		end

		local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
		local missing = maxHealth - health

		local healing = UnitGetIncomingHeals(unit) or 0
		if healing > 0 and ns.config.ignoreOwnHeals then
			healing = healing - (UnitGetIncomingHeals(unit, "player") or 0)
		end

		if missing > 0 and (healing / maxHealth) >= 0.1 then
			local bar = element.healingBar
			bar:Show()
			bar:SetMinMaxValues(0, maxHealth)
			if healing > missing then
				bar:SetValue(missing)
				bar.cap:SetShown((healing - missing) / maxHealth > 0.05)
				missing = 0
			else
				bar:SetValue(healing)
				bar.cap:Hide()
				missing = missing - healing
			end
			parent = bar
		else
			element.healingBar:Hide()
			element.healingBar.cap:SetShown(healing / maxHealth > 0.05)
		end

		local absorbs = UnitGetTotalAbsorbs(unit) or 0
		if missing > 0 and (absorbs / maxHealth) >= 0.1 then
			local bar = element.absorbsBar
			bar:Show()
			bar:SetPoint("TOPLEFT", parent.texture, "TOPRIGHT")
			bar:SetPoint("BOTTOMLEFT", parent.texture, "BOTTOMRIGHT")
			bar:SetMinMaxValues(0, maxHealth)
			bar.spark:SetShown(parent == element.healingBar)
			if absorbs > missing then
				bar:SetValue(missing)
				bar.cap:SetShown((absorbs - missing) / maxHealth > 0.05)
			else
				bar:SetValue(absorbs)
				bar.cap:Hide()
			end
		else
			element.absorbsBar:Hide()
			element.absorbsBar.cap:SetShown(absorbs / maxHealth > 0.05)
		end
	end
end

------------------------------------------------------------------------
--	Power
------------------------------------------------------------------------

do
	local UnitIsDeadOrGhost, UnitPowerType, UnitPower, UnitPowerMax
	    = UnitIsDeadOrGhost, UnitPowerType, UnitPower, UnitPowerMax

	function ns.Power_PostUpdate(self, unit, cur, max)
		if max == 0 then
			self.__owner.Health:SetPoint("BOTTOM", self.__owner, "BOTTOM", 0, 1)
			return self:Hide()
		else
			self.__owner.Health:SetPoint("BOTTOM", self, "TOP", 0, 1)
			self:Show()
		end

		if UnitIsDeadOrGhost(unit) then
			self:SetValue(0)
			if self.value then
				self.value:SetText(nil)
			end
			return
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
end

------------------------------------------------------------------------
--	Combo points
-- NOT CURRENTLY USED
------------------------------------------------------------------------

function ns.ComboPoints_Override(self, event, unit)
end

------------------------------------------------------------------------
--	Druid mushrooms
------------------------------------------------------------------------

local MAX_MUSHROOMS = 3

function ns.WildMushrooms_Override(self, event)
	local num = 0
	for i = 1, MAX_MUSHROOMS do
		local exists, name, start, duration, icon = GetTotemInfo(i)
		if duration > 0 then
			num = num + 1
		end
	end
	--print("UpdateMushrooms", num, MAX_MUSHROOMS)
	ns.Orbs.Update(self.WildMushrooms, num, MAX_MUSHROOMS)
end

------------------------------------------------------------------------
-- Monk chi
------------------------------------------------------------------------

local SPELL_POWER_CHI = SPELL_POWER_CHI

function ns.Chi_Override(self, event, unit, powerType)
	if unit ~= self.unit or (powerType and powerType ~= "CHI") then return end

	local num = UnitPower("player", SPELL_POWER_CHI)
	local max = UnitPowerMax("player", SPELL_POWER_CHI)

	--print("UpdateChi", num, max)
	ns.Orbs.Update(self.ClassIcons, num, max)
end

------------------------------------------------------------------------
--	Paladin holy power
------------------------------------------------------------------------

local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER

function ns.HolyPower_Override(self, event, unit, powerType)
	if unit ~= self.unit or (powerType and powerType ~= "HOLY_POWER") then return end

	local num = UnitPower("player", SPELL_POWER_HOLY_POWER)
	local max = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)

	--print("UpdateHolyPower", num, max)
	ns.Orbs.Update(self.ClassIcons, num, max)
end

------------------------------------------------------------------------
--	Priest shadow orbs
------------------------------------------------------------------------

local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS
local PRIEST_BAR_NUM_ORBS = PRIEST_BAR_NUM_ORBS

function ns.ShadowOrbs_Override(self, event, unit, powerType)
	if unit ~= self.unit or (powerType and powerType ~= "SHADOW_ORBS") then return end

	local num = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
	local max = UnitPowerMax("player", SPELL_POWER_SHADOW_ORBS)

	--print("UpdateShadowOrbs", num, max)
	ns.Orbs.Update(self.ClassIcons, num, max)
end

------------------------------------------------------------------------
--	Demonic fury
------------------------------------------------------------------------

function ns.DemonicFury_PostUpdate(bar, fury, maxFury, inMetamorphosis)
	--print("DemonicFury PostUpdate", fury, maxFury, inMetamorphosis)
	bar.value:SetFormattedText("%.0f%%", fury / maxFury)
end

------------------------------------------------------------------------
--	Druid mana
------------------------------------------------------------------------

function ns.DruidMana_PostUpdate(bar, unit, mana, maxMana)
	bar.value:SetFormattedText(si(mana, true))
end

------------------------------------------------------------------------
--	Stagger
------------------------------------------------------------------------

function ns.Stagger_PostUpdate(bar, maxHealth, stagger, staggerPercent, r, g, b)
	if staggerPercent < 5 then
		return bar:Hide()
	end
	print("Stagger PostUpdate", stagger, staggerPercent)
	bar.value:SetFormattedText("%.0f%%", staggerPercent)
	bar:Show()
end

------------------------------------------------------------------------
--	PvP icon
------------------------------------------------------------------------

local PLAYER_FACTION = UnitFactionGroup("player")

function ns.PvP_PostUpdate(element, status)
	--print("PvP PostUpdate", element.__owner.unit, status)
	if not status then return end
	if status == PLAYER_FACTION then
		return element:Hide()
	elseif status == "ffa" then
		return element:SetTextColor(0.8, 0.4, 0, 0.75)
	elseif status == "Alliance" then
		return element:SetTextColor(0.2, 0.4, 1, 0.75)
	elseif status == "Horde" then
		return element:SetTextColor(0.6, 0, 0, 0.75)
	end
end

------------------------------------------------------------------------
--	Buffs & debuffs
------------------------------------------------------------------------

local function AuraIconCD_OnShow(cd)
	local button = cd:GetParent()
	button:SetBorderParent(cd)
	button.count:SetParent(cd)
end

local function AuraIconCD_OnHide(cd)
	local button = cd:GetParent()
	button:SetBorderParent(button)
	button.count:SetParent(button)
end

local function AuraIconOverlay_SetBorderColor(overlay, r, g, b)
	if not r or not g or not b then
		local color = ns.config.borderColor
		r, g, b = color[1], color[2], color[3]
	end
	overlay:GetParent():SetBorderColor(r, g, b)
end

function ns.Auras_PostCreateIcon(element, button)
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
end

local function FindAuraTimer(button, unit)
	if not OmniCC then
		return true
	end
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

			child.text:SetFont(ns.config.font, unit:match("^party") and 14 or 18, ns.config.fontOutline)
			child.text.SetFont = noop

			child.text:SetTextColor(1, 0.8, 0)
			child.text.SetTextColor = noop
			child.text.SetVertexColor = noop

			tinsert(ns.fontstrings, child.text)

			return child.text
		end
	end
end

function ns.Auras_PostUpdateIcon(element, unit, button, index, offset)
	local name, _, texture, count, type, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID = UnitAura(unit, index, button.filter)

	if playerUnits[caster] then
		button.icon:SetDesaturated(false)
	else
		button.icon:SetDesaturated(true)
	end

	if not button.timer then
		button.timer = FindAuraTimer(button, unit)
	end
end

function ns.Auras_PostUpdate(self, unit)
	self.__owner.Health:ForceUpdate() -- required to detect Dead => Ghost
end

------------------------------------------------------------------------
--	Threat
------------------------------------------------------------------------

function ns.Threat_Override(frame, event, unit)
	unit = unit or frame.unit
	if not unit then return end

	local status = UnitThreatSituation(unit)
	if not status then
		status = 0
	elseif not ns.config.threatLevels then
		status = status > 1 and 3 or 0
	end

	if frame.threatLevel == status then return end
	--print("ThreatHighlightOverride", frame.unit, status)

	frame.threatLevel = status
	frame:UpdateBorder()
end

------------------------------------------------------------------------
--	Dispel highlight
------------------------------------------------------------------------

function ns.DispelHighlight_Override(element, debuffType, canDispel)
	local frame = element.__owner

	if frame.debuffType == debuffType then return end
	-- print("DispelHighlightOverride", unit, debuffType, canDispel)

	frame.debuffType = debuffType
	frame.debuffDispellable = canDispel
	frame:UpdateBorder()
end

------------------------------------------------------------------------
--	Frames
------------------------------------------------------------------------

function ns.UnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end

	if IsShiftKeyDown() or not UnitAffectingCombat("player") then
		local noobTips = SHOW_NEWBIE_TIPS == "1"
		if noobTips and self.unit == "player" then
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
			GameTooltip_AddNewbieTip(self, PARTY_OPTIONS_LABEL, 1, 1, 1, NEWBIE_TOOLTIP_PARTYOPTIONS)
		elseif noobTips and self.unit == "target" and UnitPlayerControlled("target") and not UnitIsUnit("target", "player") and not UnitIsUnit("target", "pet") then
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
			GameTooltip_AddNewbieTip(self, PLAYER_OPTIONS_LABEL, 1, 1, 1, NEWBIE_TOOLTIP_PLAYEROPTIONS)
		else
			UnitFrame_OnEnter(self)
		end
	end

	self.isMouseOver = true
	if self.mouseovers then
		for _, element in pairs(self.mouseovers) do
			if type(element) == "function" then
				element(self, true)
			elseif element.ForceUpdate then
				element:ForceUpdate()
			else
				element:Show()
			end
		end
	end
end

function ns.UnitFrame_OnLeave(self)
	if self.__owner then
		self = self.__owner
	end

	UnitFrame_OnLeave(self)

	self.isMouseOver = nil
	if self.mouseovers then
		for _, element in pairs(self.mouseovers) do
			if type(element) == "function" then
				element(self)
			elseif element.ForceUpdate then
				element:ForceUpdate()
			else
				element:Hide()
			end
		end
	end
end

function ns.UnitFrame_DropdownMenu(self)
	local unit = self.unit:sub(1, -2)
	if unit == "party" or unit == "partypet" then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame" .. self.id .. "DropDown"], "cursor", 0, 0)
	else
		local cunit = gsub(self.unit, "^%l", strupper)
		if cunit == "Vehicle" then
			cunit = "Pet"
		end
		if _G[cunit .. "FrameDropDown"] then
			ToggleDropDownMenu(1, nil, _G[cunit .. "FrameDropDown"], "cursor", 0, 0)
		end
	end
end