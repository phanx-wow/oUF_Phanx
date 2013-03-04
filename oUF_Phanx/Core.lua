--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, private = ...
local _, playerClass = UnitClass("player")
local colors = oUF.colors
local noop = function() return end
local playerUnits = { player = true, pet = true, vehicle = true }

------------------------------------------------------------------------

local function si(value, raw)
	local absvalue = abs(value)

	local str, val

	if absvalue >= 10000000 then
		str, val = "%.1fm", value / 1000000
	elseif absvalue >= 1000000 then
		str, val = "%.2fm", value / 1000000
	elseif absvalue >= 100000 then
		str, val = "%.0fk", value / 1000
	elseif absvalue >= 1000 then
		str, val = "%.1fk", value / 1000
	else
		str, val = "%d", value
	end

	if raw then
		return str, val
	else
		return format(str, val)
	end
end

private.si = si

------------------------------------------------------------------------

function private.CreateFontString(parent, size, justify)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(private.config.font, size or 16, private.config.fontOutline)
	fs:SetJustifyH(justify or "LEFT")
	fs:SetShadowOffset(1, -1)

	tinsert(private.fontstrings, fs)
	return fs
end

------------------------------------------------------------------------

function private.SetStatusBarValue(self, cur)
	local min, max = self:GetMinMaxValues()
	self:GetStatusBarTexture():SetTexCoord(0, (cur - min) / (max - min), 0, 1)
	self.orig_SetValue(self, cur)
end

function private.CreateStatusBar(parent, size, justify, nohook)
	local sb = CreateFrame("StatusBar", nil, parent)
	sb:SetStatusBarTexture(private.config.statusbar)
	sb:GetStatusBarTexture():SetDrawLayer("BORDER")
	sb:GetStatusBarTexture():SetHorizTile(false)
	sb:GetStatusBarTexture():SetVertTile(false)

	sb.bg = sb:CreateTexture(nil, "BACKGROUND")
	sb.bg:SetTexture(private.config.statusbar)
	sb.bg:SetAllPoints(true)

	if size then
		sb.value = private.CreateFontString(sb, size, justify)
	end

	if not nohook then
		sb.orig_SetValue = sb.SetValue
		sb.SetValue = private.SetStatusBarValue
	end

	tinsert(private.statusbars, sb)
	return sb
end

------------------------------------------------------------------------

function private.UpdateBorder(self)
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
	elseif debuff and not private.config.dispelFilter then
		-- print(self.unit, "has debuff:", debuff)
		color = colors.debuff[debuff]
	elseif threat and threat > 0 then
		-- print(self.unit, "has high threat")
		color = colors.threat[threat]
	else
		-- print(self.unit, "is normal")
	end

	if color then
		self:SetBackdropBorderColor(color[1], color[2], color[3], 1, glow and private.config.borderGlow)
	else
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end
end

function private.UpdatePlayerRole(self, role)
	if self.updateOnRoleChange then
		for _, func in pairs(self.updateOnRoleChange) do
			func(self, role)
		end
	end
end

------------------------------------------------------------------------
--	Health
------------------------------------------------------------------------

function private.PostUpdateHealth(self, unit, cur, max)
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
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = colors.tapped
	elseif UnitIsEnemy(unit, "player") then
		color = colors.reaction[1]
	else
		color = colors.reaction[UnitReaction(unit, "player") or 5] or colors.reaction[5]
	end

	-- HEALER: deficit, percent on mouseover
	-- OTHER:  percent, current on mouseover

	if cur < max then
		if private.GetPlayerRole() == "HEAL" and UnitCanAssist("player", unit) then
			if self.__owner.isMouseOver and not strmatch(unit, "party%d") then
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
--	IncomingHeals
------------------------------------------------------------------------

function private.UpdateIncomingHeals(self, event, unit)
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
--	Power
------------------------------------------------------------------------

function private.PostUpdatePower(self, unit, cur, max)
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
--	DruidMana
------------------------------------------------------------------------

function private.PostUpdateDruidMana(bar, unit, mana, maxMana)
	bar.value:SetFormattedText(si(mana, true))
end

------------------------------------------------------------------------
--	Mushrooms (druid)
------------------------------------------------------------------------

local MAX_MUSHROOMS = 3

function private.UpdateMushrooms(self, event)
	if unit ~= self.unit or (powerType and powerType ~= "CHI") then return end

	local num = 0
	for i = 1, MAX_MUSHROOMS do
		local exists, name, start, duration, icon = GetTotemInfo(slot)
		if duration > 0 then
			num = i
		end
	end

	--print("UpdateMushrooms", num, max)
	private.Orbs.Update(self.Mushrooms, num, MAX_MUSHROOMS)
end

------------------------------------------------------------------------
--	ClassIcons (monk)
------------------------------------------------------------------------

local SPELL_POWER_CHI = SPELL_POWER_CHI

function private.UpdateChi(self, event, unit, powerType)
	if unit ~= self.unit or (powerType and powerType ~= "CHI") then return end

	local num = UnitPower("player", SPELL_POWER_CHI)
	local max = UnitPowerMax("player", SPELL_POWER_CHI)

	--print("UpdateChi", num, max)
	private.Orbs.Update(self.ClassIcons, num, max)
end

------------------------------------------------------------------------
--	ClassIcons (paladin)
------------------------------------------------------------------------

local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER

function private.UpdateHolyPower(self, event, unit, powerType)
	if unit ~= self.unit or (powerType and powerType ~= "HOLY_POWER") then return end

	local num = UnitPower("player", SPELL_POWER_HOLY_POWER)
	local max = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)

	--print("UpdateHolyPower", num, max)
	private.Orbs.Update(self.ClassIcons, num, max)
end

------------------------------------------------------------------------
--	ClassIcons (priest)
------------------------------------------------------------------------

local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS
local PRIEST_BAR_NUM_ORBS = PRIEST_BAR_NUM_ORBS

function private.UpdateShadowOrbs(self, event, unit, powerType)
	if unit ~= self.unit or (powerType and powerType ~= "SHADOW_ORBS") then return end

	local num = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
	local max = UnitPowerMax("player", SPELL_POWER_SHADOW_ORBS)

	--print("UpdateShadowOrbs", num, max)
	private.Orbs.Update(self.ClassIcons, num, max)
end

------------------------------------------------------------------------
--	CPoints
------------------------------------------------------------------------

function private.UpdateComboPoints(self, event, unit)
	if unit == "pet" then return end

	local cp
	if UnitHasVehicleUI("player") then
		cp = GetComboPoints("vehicle", "target")
	else
		cp = GetComboPoints("player", "target")
	end

	private.Orbs.Update(self.CPoints, cp)
end

------------------------------------------------------------------------
--	Auras, Buffs, Debuffs
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
		local color = private.config.borderColor
		r, g, b = color[1], color[2], color[3]
	end
	overlay:GetParent():SetBorderColor(r, g, b)
end

function private.PostCreateAuraIcon(element, button)
	private.CreateBorder(button, 12)

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

function private.PostUpdateAuraIcon(element, unit, button, index, offset)
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

				child.text:SetFont(private.config.font, unit:match("^party") and 14 or 18, private.config.fontOutline)
				child.text.SetFont = noop

				child.text:SetTextColor(1, 0.8, 0)
				child.text.SetTextColor = noop
				child.text.SetVertexColor = noop

				tinsert(private.fontstrings, child.text)

				button.timer = child.text

				return
			end
		end
	else
		button.timer = true
	end
end

function private.PostUpdateAuras(self, unit)
	self.__owner.Health:ForceUpdate() -- required to detect Dead => Ghost
end

------------------------------------------------------------------------
--	Castbar
------------------------------------------------------------------------

function private.PostCastStart(self, unit, name, rank, castid)
	local color
	if UnitIsUnit(unit, "player") then
		color = colors.class[playerClass]
	elseif self.interrupt then
		color = colors.uninterruptible
	elseif UnitIsFriend(unit, "player") then
		color = colors.reaction[5]
	else
		color = colors.reaction[1]
	end
	local r, g, b = color[1], color[2], color[3]
	self:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
	self.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)

	local safezone = self.SafeZone
	if safezone then
		local width = safezone:GetWidth()
		if width and width > 0 and width <= self:GetWidth() then
			self:GetStatusBarTexture():SetDrawLayer("ARTWORK")
			safezone:SetDrawLayer("BORDER")
			safezone:SetWidth(width)
		else
			safezone:Hide()
		end
	end
end

function private.PostChannelStart(self, unit, name, rank, text)
	local color
	if UnitIsUnit(unit, "player") then
		color = colors.class[playerClass]
	elseif self.interrupt then
		color = colors.reaction[4]
	elseif UnitIsFriend(unit, "player") then
		color = colors.reaction[5]
	else
		color = colors.reaction[1]
	end
	local r, g, b = color[1], color[2], color[3]
	self:SetStatusBarColor(r * 0.6, g * 0.6, b * 0.6)
	self.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)

	local safezone = self.SafeZone
	if safezone then
		local width = safezone:GetWidth()
		if width and width > 0 and width <= self:GetWidth() then
			self:GetStatusBarTexture():SetDrawLayer("BORDER")
			safezone:SetDrawLayer("ARTWORK")
			safezone:SetWidth(width)
		else
			safezone:Hide()
		end
	end
end

function private.CustomDelayText(self, duration)
	self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", self.max - duration, self.delay)
end

function private.CustomTimeText(self, duration)
	self.Time:SetFormattedText("%.1f", self.max - duration)
end

------------------------------------------------------------------------
--	DispelHighlight
------------------------------------------------------------------------

function private.UpdateDispelHighlight(self, unit, debuffType, canDispel)
	-- print("UpdateDispelHighlight", unit, debuffType, canDispel)

	local frame = self.__owner
	frame.debuffType = debuffType
	frame.debuffDispellable = canDispel
	frame:UpdateBorder()
end

------------------------------------------------------------------------
--	ThreatHighlight
------------------------------------------------------------------------

function private.UpdateThreatHighlight(self, unit, status)
	if not status then status = 0 end
	-- print("UpdateThreatHighlight", unit, status)

	if not private.config.threatLevels then
		status = status > 1 and 3 or 0
	end

	if self.threatLevel == status then return end
	-- print("New threat status:", status)

	self.threatLevel = status
	self:UpdateBorder()
end

------------------------------------------------------------------------
--	Frames
------------------------------------------------------------------------

function private.UnitFrame_OnEnter(self)
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
	for _, element in pairs(self.mouseovers) do
		if type(element) == "function" then
			element(self, true)
		elseif element.ForceUpdate then
			element:ForceUpdate()
		else
			element:Show()
		end
	end

	if IsShiftKeyDown() and not UnitAffectingCombat("player") then
		local buffs = self.Buffs or self.Auras
		if buffs and buffs.CustomFilter then
			buffs.__CustomFilter = buffs.CustomFilter
			buffs.CustomFilter = nil
			buffs:ForceUpdate()
		end
	end
end

function private.UnitFrame_OnLeave(self)
	if self.__owner then
		self = self.__owner
	end

	UnitFrame_OnLeave(self)

	self.isMouseOver = nil
	for _, element in pairs(self.mouseovers) do
		if type(element) == "function" then
			element(self)
		elseif element.ForceUpdate then
			element:ForceUpdate()
		else
			element:Hide()
		end
	end

	local buffs = self.Buffs or self.Auras
	if buffs and buffs.__CustomFilter then
		buffs.CustomFilter = buffs.__CustomFilter
		buffs.__CustomFilter = nil
		buffs:ForceUpdate()
	end
end

function private.UnitFrame_DropdownMenu(self)
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