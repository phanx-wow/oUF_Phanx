--[[--------------------------------------------------------------------
	oUF_Phanx
	An oUF layout.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Phanx. See README file for license terms.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
----------------------------------------------------------------------]]

local _, ns = ...
local colors, config = oUF.colors, ns.config
local playerClass = select(2, UnitClass("player"))
local playerUnits = { player = true, pet = true, vehicle = true }
local noop = function() return end

ns.frames, ns.headers, ns.fontstrings, ns.statusbars = { }, { }, { }, { }

------------------------------------------------------------------------

ns.si = function(value)
	local absvalue = abs(value)

	if absvalue >= 10000000 then
		return ("%.1fm"):format(value / 1000000)
	elseif absvalue >= 1000000 then
		return ("%.2fm"):format(value / 1000000)
	elseif absvalue >= 100000 then
		return ("%.0fk"):format(value / 1000)
	elseif absvalue >= 10000 then
		return ("%.1fk"):format(value / 1000)
	end

	return value
end

local si = ns.si

------------------------------------------------------------------------

ns.UpdateBorder = function(self)
	local threat, debuff, dispellable = self.threatLevel, self.debuffType, self.debuffDispellable
	-- print("UpdateBorder", self.unit, "threat", threat, "debuff", debuff, "dispellable", dispellable)

	local color
	if dispellable or (debuff and threat == 0) then
		-- print(self.unit, "has dispellable debuff:", debuff)
		color = colors.debuff[debuff]
	elseif threat > 1 then
		-- print(self.unit, "has aggro:", threat)
		color = colors.threat[threat]
	elseif debuff and not config.dispellableDebuffsOnly then
		-- print(self.unit, "has debuff:", debuff)
		color = colors.debuff[debuff]
	elseif threat > 0 then
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
	if unit ~= self.unit then return end

	if not UnitIsConnected(unit) then
		local color = colors.disconnected
		local power = self:GetParent().Power
		if power then
			power:SetValue(0)
			if power.value then
				power.value:SetText(nil)
			end
		end
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		local color = colors.disconnected
		local power = self:GetParent().Power
		if power then
			power:SetValue(0)
			if power.value then
				power.value:SetText(nil)
			end
		end
		return self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, UnitIsGhost(unit) and GHOST or DEAD)
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
		if ns.isHealer and UnitCanAssist("player", unit) then
			if self:GetParent().isMouseOver then
				self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.5))
			else
				self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(UnitHealth(unit) - UnitHealthMax(unit)))
			end
		elseif self:GetParent().isMouseOver then
			self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(UnitHealth(unit)))
		else
			self.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", color[1] * 255, color[2] * 255, color[3] * 255, floor(UnitHealth(unit) / UnitHealthMax(unit) * 100 + 0.5))
		end
	elseif self:GetParent().isMouseOver then
		self.value:SetFormattedText("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, si(UnitHealthMax(unit)))
	else
		self.value:SetText(nil)
	end
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

	if not self.value then return end

	local _, type = UnitPowerType(unit)
	local color = colors.power[type] or colors.power.FUEL
	if cur < max then
		if self:GetParent().isMouseOver then
			self.value:SetFormattedText("%s.|cff%02x%02x%02x%s|r", si(UnitPower(unit)), color[1] * 255, color[2] * 255, color[3] * 255, si(UnitPowerMax(unit)))
		elseif type == "MANA" then
			self.value:SetFormattedText("%d|cff%02x%02x%02x%%|r", floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5), color[1] * 255, color[2] * 255, color[3] * 255)
		elseif cur > 0 then
			self.value:SetFormattedText("%d|cff%02x%02x%02x|r", floor(UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.5), color[1] * 255, color[2] * 255, color[3] * 255)
		else
			self.value:SetText(nil)
		end
	elseif type == "MANA" and self:GetParent().isMouseOver then
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
			if child.text and child.icon then
				-- found it!
				button.timer = child.text

				button.timer:ClearAllPoints()
				button.timer:SetPoint("CENTER", button, "TOP", 0, 2)

				button.timer:SetFont(config.font, 18, config.fontOutline)
				button.timer.SetFont = noop

				button.timer:SetTextColor(1, 0.8, 0)
				button.timer.SetTextColor = noop

				tinsert(ns.fontstrings, button.timer)

				return
			end
		end
	end

	button.timer = true
end

------------------------------------------------------------------------

ns.PostCastStart = function(self, unit, name, rank, castid)
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
		self.SafeZone:SetDrawLayer("ARTWORK")
		self.SafeZone:ClearAllPoints()
		self.SafeZone:SetPoint("TOPLEFT", self.Castbar)
		self.SafeZone:SetPoint("BOTTOMLEFT", self.Castbar)
	end
end

ns.CustomDelayText = function(self, duration)
	self.Time:SetFormattedText("+%.1f %.1f", self.delay, duration)
end

ns.CustomTimeText = function(self, duration)
	self.Time:SetFormattedText("%.1f", duration)
end

------------------------------------------------------------------------

ns.UpdateDispelHighlight = function(self, unit, debuffType, canDispel)
	-- print("UpdateDispelHighlight", unit, debuffType, canDispel)

	if self.debuffType == debuffType then return end

	self.debuffType = debuffType
	self.debuffDispellable = canDispel

	-- print("New debuff type:", debuffType, canDispel and "dispellable" or "not dispellable")
	self:UpdateBorder()
end

------------------------------------------------------------------------

ns.UpdateThreatHighlight = function(self, unit, status)
	-- print("UpdateThreatHighlight", unit, status)

	if not config.threatLevels then
		status = status > 1 and 3 or 0
	end

	if self.threatLevel == status then return end

	self.threatLevel = status
	-- print("New threat status:", status)
	self:UpdateBorder()
end

------------------------------------------------------------------------

ns.UnitFrame_OnEnter = function(self)
	if IsShiftKeyDown() or not UnitAffectingCombat("player") then
		UnitFrame_OnEnter(self)
	end
	self.isMouseOver = true
	for _, element in ipairs(self.mouseovers) do
		self:UpdateElement(element)
	end
end

ns.UnitFrame_OnLeave = function(self)
	UnitFrame_OnLeave(self)
	self.isMouseOver = nil
	for _, element in ipairs(self.mouseovers) do
		self:UpdateElement(element)
	end
end

ns.UnitFrame_DropdownMenu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("^%l", string.upper)
	if cunit == "Vehicle" then cunit = "Pet" end
	if unit == "party" or unit == "partypet" then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame" .. self.id .. "DropDown"], "cursor", 0, 0)
	elseif _G[cunit .. "FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[cunit .. "FrameDropDown"], "cursor", 0, 0)
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

ns.CreateStatusBar = function(parent, size, justify)
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

	tinsert(ns.statusbars, sb)
	return sb
end

------------------------------------------------------------------------

ns.Spawn = function(self, unit)
	-- print("Spawn", unit, self:GetName())

	self.mouseovers = { }

	self.menu = ns.UnitFrame_DropdownMenu

	self:SetScript("OnEnter", ns.UnitFrame_OnEnter)
	self:SetScript("OnLeave", ns.UnitFrame_OnLeave)

	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")

	self:SetAttribute("initial-width",  config.width *  (ns.uconfig[unit].width  or 1))
	self:SetAttribute("initial-height", config.height * (ns.uconfig[unit].height or 1))

	-------------------------
	-- Health bar and text --
	-------------------------

	self.Health = ns.CreateStatusBar(self, 24, "RIGHT")
	self.Health:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -1)
	self.Health:SetPoint("TOPRIGHT", self, "TOPRIGHT", -1, -1)
	self.Health:SetPoint("BOTTOM", self, "BOTTOM", 0, 1)
	self.Health:SetStatusBarColor(unpack(config.borderColor))

	self.Health.bg:SetVertexColor(0.3, 0.3, 0.3)

	self.Health.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, config.height * config.powerHeight - 2)

	self.Health.PostUpdate = ns.PostUpdateHealth
	tinsert(self.mouseovers, "Health")

	------------------------
	-- Power bar and text --
	------------------------

	if ns.uconfig[unit].power then
		self.Power = ns.CreateStatusBar(self, (ns.uconfig[unit].width or 1) > 0.75 and 16, "LEFT")
		self.Power:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		self.Power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)
		self.Power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		self.Power:SetHeight(config.height * config.powerHeight)

		self.Power.bg.multiplier = 0.5

		if self.Power.value then
			self.Power.value:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 4, config.height * config.powerHeight - 2)
			self.Power.value:SetPoint("BOTTOMRIGHT", self.Health.value, "BOTTOMLEFT", -8, 0)

			tinsert(self.mouseovers, "Power")
		end

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
	self.overlay:SetFrameLevel(max(self.Health:GetFrameLevel(), self.Power and self.Power:GetFrameLevel() or 0) + 1)

	self.Health.value:SetParent(self.overlay)

	--------------------------
	-- Element: Threat text --
	--------------------------

	if unit == "target" then
		self.ThreatText = ns.CreateFontString(self.overlay, 20, "RIGHT")
		self.ThreatText:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -2, -4)
	end

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

	if unit == "targettarget" or unit == "party" then
		self.Name = ns.CreateFontString(self.overlay, 20, "LEFT")
		self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2, -4)
		self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -2, -4)

		self:Tag(self.Name, "[unitcolor][name]")
	end

	-----------------------
	-- Combo points text --
	-----------------------

	if unit == "target" then
		self.ComboPoints = ns.CreateFontString(self.overlay, 32, "RIGHT")
		self.ComboPoints:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", -10, config.height * config.powerHeight - 6)
		self.ComboPoints:SetTextColor(colors.class[playerClass][1], colors.class[playerClass][2], colors.class[playerClass][3])

		self:Tag(self.ComboPoints, "[cpoints]")
	elseif unit == "player" and playerClass == "SHAMAN" then
		self.Maelstrom = ns.CreateFontString(self.overlay, 32, "LEFT")
		self.Maelstrom:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", 10, config.height * config.powerHeight - 6)
		self.Maelstrom:SetTextColor(colors.class[playerClass][1], colors.class[playerClass][2], colors.class[playerClass][3])

		self:Tag(self.Maelstrom, "[maelstrom]")
	end

	-----------------------
	-- Status icons --
	-----------------------

	if unit == "player" then
		self.GroupStatus = ns.CreateFontString(self.overlay, 16, "LEFT")
		self.GroupStatus:SetPoint("LEFT", self.Health, "TOPLEFT", 2, 2)

		self:Tag(self.GroupStatus, "[leadericon][mastericon]")

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
	-- Raid icons --
	----------------

	self.RaidIcon = self.overlay:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("CENTER", self, "TOPLEFT", 0, 0)
	self.RaidIcon:SetSize(16, 16)

	------------------------
	-- Dungeon Role icons --
	------------------------

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
	elseif unit == "target" then
		local GAP = 6

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, 24)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 24)
		self.Debuffs:SetHeight(config.height * 2 + GAP)

		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs["initialAnchor"] = "BOTTOMLEFT"
		self.Debuffs["num"] = floor((config.width - 4 + GAP) / (config.height + GAP))
		self.Debuffs["showDebuffType"] = true
		self.Debuffs["size"] = config.height
		self.Debuffs["spacing-x"] = GAP
		self.Debuffs["spacing-y"] = GAP

		self.Debuffs.CustomFilter   = ns.CustomAuraFilter
		self.Debuffs.PostCreateIcon = ns.PostCreateAuraIcon
		self.Debuffs.PostUpdateIcon = ns.PostUpdateAuraIcon
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

			self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -4, 0)
			self.Castbar.Time:SetFont(config.font, 20, "OUTLINE")
			self.Castbar.Time:SetJustifyH("RIGHT")
			self.Castbar.Time:SetShadowOffset(1, -1)

			self.Castbar.CustomDelayText = ns.CustomDelayText
			self.Castbar.CustomTimeText = ns.CustomTimeText
		elseif (ns.uconfig[unit].width or 1) > 0.75 then
			self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 4, 0)
			self.Castbar.Text:SetFont(config.font, 16, "OUTLINE")
			self.Castbar.Text:SetJustifyH("LEFT")
			self.Castbar.Text:SetShadowOffset(1, -1)
		end

		self.Castbar.PostCastStart = ns.PostCastStart
		self.Castbar.PostChannelStart = ns.PostChannelStart

		ns.CreateBorder(self.Castbar)
		self.Castbar.BorderTextures[1]:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -6, 6)
		self.Castbar.BorderTextures[4]:SetPoint("BOTTOMLEFT", self.Castbar.Icon, "BOTTOMLEFT", -6, -6)
	end

	-----------
	-- Range --
	-----------

	if unit ~= "player" and not unit:match("target") then
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

	-------------------------------
	-- Element: Dispel highlight --
	-------------------------------

	self.DispelHighlight = ns.UpdateDispelHighlight
	self.DispelHighlightFilter = true

	-------------------------------
	-- Element: Threat highlight --
	-------------------------------

	if not unit:match("^.+target$") then
		self.threatLevel = 0
		self.ThreatHighlight = ns.UpdateThreatHighlight
	end

	---------------------------
	-- Plugin: oUF_HealComm4 --
	---------------------------

	if IsAddOnLoaded("oUF_HealComm4") and (unit == "player" or (playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "PRIEST" or playerClass == "SHAMAN")) then
		self.HealCommBar = ns.CreateStatusBar(self.Health)
		self.HealCommBar:SetAllPoints(self.Health)
		self.HealCommBar:SetStatusBarColor(0.2, 1, 0.2, 0.5)

		self.allowHealCommOverflow = false
	elseif (unit == "player" or (playerClass == "DRUID" or playerClass == "PALADIN" or playerClass == "PRIEST" or playerClass == "SHAMAN")) then
		self.Heals = ns.CreateStatusBar(self.Health)
		self.Heals:SetHeight(self.Health:GetHeight() - (self.Power and self.Power:GetHeight() or 0))
		self.Heals:SetStatusBarColor(0.2, 1, 0.2, 0.5)

		self.Heals.allowOverflow = false
		self.Heals.anchor = "LEFT"
		self.Heals.ignoreHoTs = true
		self.Heals.ignoreOwnHeals = false
	end

	----------------------------
	-- Plugin: oUF_ReadyCheck --
	----------------------------

	if IsAddOnLoaded("oUF_ReadyCheck") and unit == "player" or unit == "party" then
		self.ReadyCheck = self.overlay:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetPoint("CENTER", self)
		self.ReadyCheck:SetSize(config.height, config.height)

		self.ReadyCheck.delayTime = 5
		self.ReadyCheck.fadeTime = 1
	end

	------------------------
	-- Plugin: oUF_Smooth --
	------------------------

	if IsAddOnLoaded("oUF_Smooth") and unit ~= "party" and unit ~= "partypet" then
		self.Health.Smooth = true
		if self.Power then
			self.Power.Smooth = true
		end
	end

end

------------------------------------------------------------------------

oUF:RegisterStyle("Goat", ns.Spawn)

oUF:Factory(function(oUF)
	oUF:SetActiveStyle("Goat")

	for u, udata in pairs(ns.uconfig) do
		if udata.attributes then
			ns.headers[u] = oUF:SpawnHeader(nil, nil, u, unpack(udata.attributes))
		else
			ns.frames[u] = oUF:Spawn(u)
		end
	end

	for u, f in pairs(ns.frames) do
		local udata = ns.uconfig[u]
		local p1, parent, p2, x, y = string.split(" ", udata.point)
		f:SetPoint(p1, ns.frames[parent] or _G[parent] or UIParent, p2, tonumber(x) or 0, tonumber(y) or 0)
	end
	for u, f in pairs(ns.headers) do
		local udata = ns.uconfig[u]
		local p1, parent, p2, x, y = string.split(" ", udata.point)
		f:SetPoint(p1, ns.frames[parent] or _G[parent] or UIParent, p2, tonumber(x) or 0, tonumber(y) or 0)
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
		_G[barname .. "Text"]:SetPoint("LEFT", bar, 0, 1)
		_G[barname .. "Text"]:SetFont(config.font, 16, "OUTLINE")

		_G[barname .. "StatusBar"]:SetAllPoints(bar)
		_G[barname .. "StatusBar"]:SetStatusBarTexture(config.statusbar)
		_G[barname .. "StatusBar"]:SetAlpha(0.8)
	end
end)
