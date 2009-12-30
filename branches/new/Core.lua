--[[--------------------------------------------------------------------
	oUF_Phanx
----------------------------------------------------------------------]]

local settings = {

	font           = [[Interface\AddOns\SharedMedia\font\Paralucent-Light.ttf]], -- VAGRoundedStd-Bold.ttf]], -- [[Fonts\ARIALN__.ttf]],
	fontOutline    = "OUTLINE", -- NONE, OUTLINE, THICKOUTLINE

	statusbar      = [[Interface\AddOns\Grid\gradient32x32]], -- [[Interface\TargetingFrame\UI-StatusBar]],

	borderStyle    = "GLOW", -- GLOW, NONE, TEXTURE
	borderColor    = { 0.5, 0.5, 0.5 }, -- only applies to TEXTURE border
	borderSize     = 14, -- only applies to TEXTURE border

	focusPlacement = "LEFT", -- LEFT, RIGHT

	threatLevels   =  true,

}

------------------------------------------------------------------------

local _, namespace = ...
if not namespace.L then namespace.L = { } end

local L = setmetatable(namespace.L, { __index = function(t, k) t[k] = k return k end })
L["Dead"]    = DEAD
L["Ghost"]   = GetSpellInfo(8326)
L["Offline"] = PLAYER_OFFLINE

------------------------------------------------------------------------

local colors = oUF.colors

colors.dead = { 0.6, 0.6, 0.6 }
colors.ghost = { 0.6, 0.6, 0.6 }
colors.offline = { 0.6, 0.6, 0.6 }

colors.civilian = { 0.2, 0.4, 1 }
colors.friendly = { 0.2, 1, 0.2 }
colors.hostile = { 1, 0.1, 0.1 }
colors.neutral = { 1, 1, 0.2 }

colors.power.AMMOSLOT = { 0.8, 0.6, 0 }
colors.power.ENERGY = { 1, 1, 0.2 }
colors.power.FOCUS = { 1, 0.5, 0.25 }
colors.power.FUEL = { 0, 0.5, 0.5 }
colors.power.MANA = { 0, 0.8, 1 }
colors.power.RAGE = { 1, 0.2, 0.2 }
colors.power.RUNIC_POWER = { 0.4, 0.4, 1 }

colors.unknown = { 1, 0.2, 1 }

colors.threat = {
	{ 1, 1, 0.47 }, -- not tanking, high threat
	{ 1, 0.6, 0 },  -- tanking, insecure threat
	{ 1, 0, 0 },    -- tanking, secure threat
}

colors.debuff = { }
for type, color in pairs(DebuffTypeColor) do
	if type ~= "none" then
		colors.debuff[type] = { color.r, color.g, color.b }
	end
end

------------------------------------------------------------------------

local playerClass = select(2, UnitClass("player"))
local MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]

------------------------------------------------------------------------

local function debug(str, ...)
	if ... then
		if str:match("%%") then
			str = str:format(...)
		else
			str = string.join(", ", str, ...)
		end
	end
	print(("|cffffcc00[DEBUG] oUF_Phanx:|r %s"):format(str))
end

------------------------------------------------------------------------

local function si(n, plus)
	if type(n) ~= "number" then return n end

	local sign
	if n < 0 then
		sign = "-"
		n = -n
	elseif plus then
		sign = "+"
	else
		sign = ""
	end

	if n >= 10000000 then
		return ("%s%.1fm"):format(sign, n / 1000000)
	elseif n >= 1000000 then
		return ("%s%.2fm"):format(sign, n / 1000000)
	elseif n >= 100000 then
		return ("%s%.0fk"):format(sign, n / 1000)
	elseif n >= 10000 then
		return ("%s%.1fk"):format(sign, n / 1000)
	else
		return ("%s%d"):format(sign, n)
	end
end

------------------------------------------------------------------------

local function GetDifficultyColor(level)
	if level < 1 then
		level = 100
	end
	local levelDiff = level - UnitLevel("player")
	if levelDiff >= 5 then
		return 1.00, 0.10, 0.10
	elseif levelDiff >= 3 then
		return 1.00, 0.50, 0.25
	elseif levelDiff >= -2 then
		return 1.00, 1.00, 0.00
	elseif -levelDiff <= GetQuestGreenRange() then
		return 0.25, 0.75, 0.25
	end
	return 0.70, 0.70, 0.70
end

------------------------------------------------------------------------

local function GetUnitColor(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		return colors.class[class] or colors.unknown
	elseif UnitPlayerControlled(unit) then
		if UnitCanAttack(unit, "player") then
			-- they can attack me
			if UnitCanAttack("player", unit) then
				-- and I can attack them
				return colors.hostile
			else
				-- but I can't attack them
				return colors.civilian
			end
		elseif UnitCanAttack("player", unit) then
			-- they can't attack me, but I can attack them
			return colors.neutral
		elseif UnitIsPVP(unit) and not UnitIsPVPSanctuary(unit) and not UnitIsPVPSanctuary("player") then
			-- on my team
			return colors.friendly
		else
			-- either enemy or friend, no violence
			return colors.civilian
		end
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		return colors.tapped
	else
		local reaction = UnitReaction(unit, "player")
		if reaction then
			if reaction >= 5 then
				return colors.friendly
			elseif reaction == 4 then
				return colors.neutral
			else
				return colors.hostile
			end
		else
			return colors.unknown
		end
	end
end

------------------------------------------------------------------------

local AddBorder

local function SetBorderColor(self, r, g, b)
	if not self or type(self) ~= "table" then return end
	if not self.borderTextures then
		AddBorder(self)
	end
	if not r then
		r, g, b = unpack(settings.borderColor)
	end
	--debug("SetBorderColor: %s, %s, %s", r, g, b)

	for i, tex in ipairs(self.borderTextures) do
		tex:SetVertexColor(r, g, b)
	end
end

local function SetBorderSize(self, size)
	if not self or type(self) ~= "table" then return end
	if not self.borderTextures then
		AddBorder(self, size)
	end
	if not size then
		size = settings.borderSize
	end
	--debug("SetBorderSize: %s", size)

	local x = size / 2 - 6
	local t = self.borderTextures

	for i, tex in ipairs(t) do
		tex:SetWidth(size)
		tex:SetHeight(size)
	end

	t[1]:SetPoint("TOPLEFT", self, -4 - x, 4 + x)
	t[2]:SetPoint("TOPRIGHT", self, 4 + x, 4 + x)

	t[3]:SetPoint("TOPLEFT", t[1], "TOPRIGHT")
	t[3]:SetPoint("TOPRIGHT", t[2], "TOPLEFT")

	t[4]:SetPoint("BOTTOMLEFT", self, -4 - x, -4 - x)
	t[5]:SetPoint("BOTTOMRIGHT", self, 4 + x, -4 - x)

	t[6]:SetPoint("BOTTOMLEFT", t[4], "BOTTOMRIGHT")
	t[6]:SetPoint("BOTTOMRIGHT", t[5], "BOTTOMLEFT")

	t[7]:SetPoint("TOPLEFT", t[1], "BOTTOMLEFT")
	t[7]:SetPoint("BOTTOMLEFT", t[4], "TOPLEFT")

	t[8]:SetPoint("TOPRIGHT", t[2], "BOTTOMRIGHT")
	t[8]:SetPoint("BOTTOMRIGHT", t[5], "TOPRIGHT")
end

function AddBorder(frame, size)
	if not frame or type(frame) ~= "table" or frame.borderTextures then return end
	--debug("AddBorder: %s", frame.unit or "")

	frame.borderTextures = { }

	local t = frame.borderTextures
	for i = 1, 8 do
		t[i] = frame:CreateTexture(nil, "OVERLAY")
		t[i]:SetTexture(settings.border)
	end

	t[1].id = "TOPLEFT"
	t[1]:SetTexCoord(0, 1/3, 0, 1/3)

	t[2].id = "TOPRIGHT"
	t[2]:SetTexCoord(2/3, 1, 0, 1/3)

	t[3].id = "TOP"
	t[3]:SetTexCoord(1/3, 2/3, 0, 1/3)

	t[4].id = "BOTTOMLEFT"
	t[4]:SetTexCoord(0, 1/3, 2/3, 1)

	t[5].id = "BOTTOMRIGHT"
	t[5]:SetTexCoord(2/3, 1, 2/3, 1)

	t[6].id = "BOTTOM"
	t[6]:SetTexCoord(1/3, 2/3, 2/3, 1)

	t[7].id = "LEFT"
	t[7]:SetTexCoord(0, 1/3, 1/3, 2/3)

	t[8].id = "RIGHT"
	t[8]:SetTexCoord(2/3, 1, 1/3, 2/3)

	SetBorderColor(frame, unpack(settings.borderColor))
	SetBorderSize(frame, size)

	frame.SetBorderColor = SetBorderColor
	frame.SetBorderSize = SetBorderSize
end

------------------------------------------------------------------------

local IsTanking
if playerClass == "DEATHKNIGHT" then
	function IsTanking() return GetShapeshiftForm() == 2 end
elseif playerClass == "DRUID" then
	function IsTanking() return GetShapeshiftForm() == 1 end
elseif playerClass == "PALADIN" then
	local RIGHTEOUS_FURY = GetSpellInfo(25780)
	function IsTanking() return UnitBuff("player", RIGHTEOUS_FURY) and true end
elseif playerClass == "WARRIOR" then
	function IsTanking() return GetShapeshiftForm() == 1 end
else
	function IsTanking() return false end
end

local function UpdateBorder(self)
	-- if not self.unit:match("target$") then debug("UpdateBorder: %s", self.unit) end
	local priority, color = 0

	if self.DebuffPriority then
		-- debug("Checking for debuffs...")
		for i, type in ipairs(self.DebuffPriority) do
			if self.DebuffStatus[type] then
				color = colors.debuff[type]
				priority = self.DebuffPriority[type]
				debug("hasDebuff, %s, %d", type, priority)
			end
		end
	end

	if self.threatStatus then
		-- debug("Checking for threat (" .. (IsTanking() and "tanking" or "not tanking") .. ")...")
		local threatPriority = IsTanking() and 10 or 5
		if priority < threatPriority and self.threatStatus > 0 then
			color = colors.threat[self.threatStatus]
			priority = threatPriority
			-- debug("hasThreat, %d, %d", self.threatStatus, priority)
		end
	end

	if settings.borderStyle == "TEXTURE" then
		local r, g, b = unpack(color or settings.borderColor)
		self:SetBorderColor(r, g, b, 1)
		self:SetBorderSize(settings.borderSize * (priority > 4 and 1.25 or 1))
	else
		if priority > 4 then
			local r, g, b = unpack(color or settings.borderColor)
			self:SetBackdropBorderColor(r, g, b, 1)
		elseif priority > 0 then
			local r, g, b = unpack(color or settings.borderColor)
			self:SetBackdropBorderColor(r, g, b, 0.5)
		else
			self:SetBackdropBorderColor(0, 0, 0, 0)
		end
		if settings.borderStyle == "GLOW" then
			if priority > 0 then
				self.BorderGlow:SetPoint("TOPLEFT", -3, 3)
				self.BorderGlow:SetPoint("BOTTOMRIGHT", 3, -3)
			else
				self.BorderGlow:SetPoint("TOPLEFT", 0, 0)
				self.BorderGlow:SetPoint("BOTTOMRIGHT", 0, 0)
			end
		end
	end
end

------------------------------------------------------------------------

local function UpdateName(self, event, unit)
	if self.unit ~= unit then return end
	--debug("UpdateName: %s, %s", event, unit)

	local r, g, b
	if UnitIsDead(unit) then
		r, g, b = unpack(colors.dead)
	elseif UnitIsGhost(unit) then
		r, g, b = unpack(colors.ghost)
	elseif not UnitIsConnected(unit) then
		r, g, b = unpack(colors.offline)
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		r, g, b = unpack(colors.tapped)
	else
		r, g, b = unpack(GetUnitColor(unit))
	end

	self.Name:SetText(UnitName(unit))
	self.Name:SetTextColor(r, g, b)

--	if self.Info then
--		UpdateInfo(self, event, unit)
--	end

--	UpdateBorder(self)
end

------------------------------------------------------------------------

local function UpdateHealth(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	--debug("UpdateHealth: %s, %s", event, unit)

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
		r, g, b = unpack(GetUnitColor(unit))
		bar:SetValue(self.reverse and max - min or min)
		if min < max then
			if unit == "player" or unit == "pet" then
				bar.value:SetFormattedText("-%s", si(max - min))
			elseif unit == "targettarget" or unit == "focustarget" then
				bar.value:SetFormattedText("%s%%", ceil(min / max * 100))
			elseif (UnitIsPlayer(unit) or UnitPlayerControlled(unit)) and UnitIsFriend(unit, "player") then
				bar.value:SetFormattedText("%s|cffff6666-%s|r", si(max), si(max - min))
			else
				bar.value:SetFormattedText("%s (%d%%)", si(min), ceil(min / max * 100))
			end
		elseif unit == "target" or unit == "focus" then
			bar.value:SetText(si(max))
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

local UpdateDruidMana
do
	local time = 0
	local SPELL_POWER_MANA = SPELL_POWER_MANA
	function UpdateDruidMana(self, elapsed)
		time = time + (elapsed or 1000)
		if time > 0.5 then
			--debug("UpdateDruidMana")
			local frame = self:GetParent()
			if frame.shapeshifted then
				local min, max = UnitPower("player", SPELL_POWER_MANA), UnitPowerMax("player", SPELL_POWER_MANA)
				if min < max then
					return frame.DruidMana:SetText(si(min))
				--	return frame.DruidMana:SetFormattedText("%d%%", floor(min / max * 100))
				end
			end
			frame.DruidMana:SetText()
			time = 0
		end
	end
end

------------------------------------------------------------------------

local function UpdatePower(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	-- debug("UpdatePower: %s, %s", tostring(event), tostring(unit))

	if max == 0 then
		self.Power.hidden = true
		bar:Hide()
		self.Health:SetHeight(25)
		return
	elseif self.Power.hidden then
		self.Health:SetHeight(20)
		bar:Show()
		self.Power.hidden = nil
	end

	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)
		bar:SetStatusBarColor(0, 0, 0)
		bar.bg:SetVertexColor(0, 0, 0)
		if bar.value then
			bar.value:SetText()
		end
		if bar.DruidMana then
			self.shapeshifted = false
			self.overlay:SetScript("OnUpdate", nil)
			UpdateDruidMana(self.overlay)
		end
		return
	end

	local r, g, b

	if unit == "pet" and playerClass == "HUNTER" and self.power then
		r, g, b = unpack(colors.happiness[GetPetHappiness()] or colors.power.FOCUS)
		if min < max and bar.value then
			bar.value:SetText(min)
		end
	else
		local _, type = UnitPowerType(unit)
		r, g, b = unpack(colors.power[type] or colors.unknown)
		if self.DruidMana then
			if type == "MANA" then
				if self.shapeshifted then
					self.shapeshifted = false
					self.overlay:SetScript("OnUpdate", nil)
					UpdateDruidMana(self.overlay)
				end
			else
				if not self.shapeshifted then
					self.shapeshifted = true
					self.overlay:SetScript("OnUpdate", UpdateDruidMana)
					UpdateDruidMana(self.overlay)
				end
			end
		end
		if bar.value then
			if unit == "player" or unit == "pet" then
				if type == "RAGE" or type == "RUNIC_POWER" then
					if min > 0 then
						bar.value:SetText(min)
					else
						bar.value:SetText()
					end
				else
					if min < max then
						bar.value:SetText(si(min))
					else
						bar.value:SetText()
					end
				end
			else
				if type == "MANA" then
					if min < max then
						if UnitHealth(unit) == UnitHealthMax(unit) then
							bar.value:SetFormattedText("%s|cff%02x%02x%02x.%s|r", si(min), r * 255, g * 255, b * 255, si(max))
						else
							bar.value:SetText(si(min))
						end
					else
						bar.value:SetText(si(max))
					end
				elseif type == "ENERGY" then
					if min < max then
						bar.value:SetText(min)
					else
						bar.value:SetText()
					end
				else -- FOCUS, RAGE, or RUNIC_POWER
					if min > 0 then
						bar.value:SetText(min)
					else
						bar.value:SetText()
					end
				end
			end
			bar.value:SetTextColor(r, g, b)
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

local function UpdateDispelHighlight(self, event, unit)
	if self.unit ~= unit then return end

	-- self.DebuffPriority
	-- self.dispelStatus

	UpdateBorder(self)
end

------------------------------------------------------------------------

local function UpdateThreatHighlight(self, event, unit, status)
	if self.unit ~= unit then return end

	if status and status > 1 and not settings.threatLevel then
		status = 3
	end

	if self.threatStatus == status then return end

	self.threatStatus = status or 0

	UpdateBorder(self)
end

------------------------------------------------------------------------

local usettings = {
	player = {
		width = 200,
		height = 20,
		func = function(self)
			self.Health.value:SetPoint("BOTTOMRIGHT", -2, -2)
			self.Health.value:SetJustifyH("RIGHT")

			self.Power.value:SetPoint("BOTTOMLEFT", self.Health, 2, 0)
			self.Power.value:SetPoint("BOTTOMRIGHT", self.Health.value, "BOTTOMLEFT", -2, 2)
			self.Power.value:SetJustifyH("LEFT")
		end,
	},
	pet = {
		width = 200,
		height = 16,
	},
	target = {
		width = 200,
		height = 20,
		func = function(self)
			self.Health.value:SetPoint("BOTTOMLEFT", 2, -2)
			self.Health.value:SetJustifyH("LEFT")

			self.Power.value:SetPoint("BOTTOMRIGHT", self.Health, -2, 0)
			self.Power.value:SetPoint("BOTTOMLEFT", self.Health.value, "BOTTOMRIGHT", 2, 2)
			self.Power.value:SetJustifyH("RIGHT")

			self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, -7)
			self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, -7)
			self.Name:SetJustifyH("RIGHT")
		end,
	},
	targettarget = {
		width = 160,
		height = 16,
		func = function(self)
			self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, -11)
			self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, -11)
			self.Name:SetJustifyH("RIGHT")

			self.Health.value:SetPoint("TOPLEFT", 2, 2)
		end,
	},
	focus = {
		width = 200,
		height = 20,
		func = function(self)
			if self.reverse then
				self.Health.value:SetPoint("BOTTOMLEFT", 2, -2)
				self.Health.value:SetJustifyH("LEFT")

				self.Power.value:SetPoint("BOTTOMRIGHT", self.Health, -2, 0)
				self.Power.value:SetPoint("BOTTOMLEFT", self.Health.value, "BOTTOMRIGHT", 2, 2)
				self.Power.value:SetJustifyH("RIGHT")

				self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, -7)
				self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, -7)
				self.Name:SetJustifyH("RIGHT")
			else
				self.Health.value:SetPoint("BOTTOMRIGHT", -2, -2)
				self.Health.value:SetJustifyH("RIGHT")

				self.Power.value:SetPoint("BOTTOMLEFT", self.Health, 2, 0)
				self.Power.value:SetPoint("BOTTOMRIGHT", self.Health.value, "BOTTOMLEFT", -2, 2)
				self.Power.value:SetJustifyH("LEFT")

				self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, -7)
				self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, -7)
				self.Name:SetJustifyH("LEFT")
			end
		end,
	},
	focustarget = {
		width = 160,
		height = 16,
		func = function(self)
			if self.reverse then
				self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, -11)
				self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, -11)
				self.Name:SetJustifyH("RIGHT")

				self.Health.value:SetPoint("TOPRIGHT", -2, 0)
			else
				self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, -11)
				self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, -11)
				self.Name:SetJustifyH("LEFT")

				self.Health.value:SetPoint("TOPLEFT", 2, 0)
			end
		end,
	},
	party = {
		width = 160,
		height = 20,
	},
	partypet = {
		width = 160,
		height = 16,
	},
}

------------------------------------------------------------------------

local backdrop = {
	bgFile = "Interface\\AddOns\\Grid\\white16x16", tile = true, tileSize = 16,
	edgeFile = "Interface\\AddOns\\Grid\\white16x16", edgeSize = 3,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local backdrop_glow = {
	edgeFile = "Interface\\AddOns\\oUF_Phanx\\media\\glow",
	edgeSize = 5,
	insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

local INSET = backdrop.insets.left + (settings.borderStyle == "TEXTURE" and -1 or 1)

------------------------------------------------------------------------

local fakeThreat
do
	local noop = function() return end
	fakeThreat = { Hide = noop, GetTexture = noop, IsObjectType = noop }
end

------------------------------------------------------------------------

local function menu(self)
	local unit = self.unit:sub(1, -2)
	if unit == "party" or unit == "partypet" then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	else
		local cunit = self.unit:gsub("(.)", string.upper, 1)
		if _G[cunit.."FrameDropDown"] then
			ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
		end
	end
end

------------------------------------------------------------------------

settings.div = 5

local function Spawn(self, unit)
	if not unit then
		local template = self:GetParent():GetAttribute("template")
		if template == "SecureUnitButtonTemplate" then
			unit = "party"
		else
			unit = "partypet"
		end
	end

	self.menu = menu

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")

	self.reverse = not (unit == "player" or unit == "pet" or (settings.focusPlacement == "LEFT" and unit:match("^focus")))

	local c = usettings[unit]
	local hasPower = unit == "player" or unit == "pet" or unit == "target" or unit == "focus" or unit == "party"

	local width = INSET + c.width + INSET
	local height = INSET + c.height + INSET
	if hasPower then
		height = height + 1 + (c.height / settings.div)
	end

	self:SetAttribute("initial-width", width)
	self:SetAttribute("initial-height", height)

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(0, 0, 0, 0)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(settings.statusbar)
	self.Health:SetPoint("BOTTOMLEFT", INSET, INSET)
	self.Health:SetPoint("BOTTOMRIGHT", -INSET, INSET)
	self.Health:SetHeight(c.height)

	self.Health.bg = self.Health:CreateTexture(nil, "BACKGROUND")
	self.Health.bg:SetTexture(settings.statusbar)
	self.Health.bg:SetAllPoints(self.Health)

	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetFont(settings.font, 32, settings.fontOutline)
	self.Health.value:SetShadowOffset(1, -1)

	self.OverrideUpdateHealth = UpdateHealth

	if hasPower then
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetStatusBarTexture(settings.statusbar)
		self.Power:SetPoint("TOPLEFT", INSET, -INSET)
		self.Power:SetPoint("TOPRIGHT", -INSET, -INSET)
		self.Power:SetPoint("BOTTOM", self.Health, "TOP", 0, 1)

		self.Power.bg = self.Power:CreateTexture(nil, "BACKGROUND")
		self.Power.bg:SetTexture(settings.statusbar)
		self.Power.bg:SetAllPoints(self.Power)

		self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
		self.Power.value:SetFont(settings.font, 20, settings.fontOutline)
		self.Power.value:SetShadowOffset(1, -1)

		self.frequentPower = unit == "player" or unit == "pet"

		self.OverrideUpdatePower = UpdatePower
	end

	if unit ~= "player" and unit ~= "pet" then
		self.Name = self.Health:CreateFontString(nil, "OVERLAY")
		self.Name:SetFont(settings.font, 24, settings.fontOutline)
		self.Name:SetShadowOffset(1, -1)

		self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)
		table.insert(self.__elements, UpdateName)
	end

	if unit == "target" then
		self.CPoints = self.Health:CreateFontString(nil, "OVERLAY")
		self.CPoints:SetFont(settings.font, 32, settings.fontOutline)
		self.CPoints:SetShadowOffset(1, -1)
		self.CPoints:SetPoint("RIGHT", self, "LEFT", 0, 0)
	end

	if unit == "player" or unit == "pet" or unit == "target" then
		self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
		self.Assistant:SetPoint("LEFT", self, "BOTTOMLEFT", INSET, INSET)
		self.Assistant:SetWidth(20)
		self.Assistant:SetHeight(20)

		self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetPoint("LEFT", self, "BOTTOMLEFT", INSET, INSET)
		self.Leader:SetWidth(20)
		self.Leader:SetHeight(20)

		self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
		self.MasterLooter:SetPoint("LEFT", self, "BOTTOMLEFT", INSET + 20, INSET)
		self.MasterLooter:SetWidth(20)
		self.MasterLooter:SetHeight(20)
	end

	if unit == "player" then
		self.Combat = self.Health:CreateTexture(nil, "OVERLAY")
		self.Combat:SetPoint("RIGHT", self, "BOTTOMRIGHT", -INSET, INSET)
		self.Combat:SetWidth(24)
		self.Combat:SetHeight(24)

		self.Resting = self.Health:CreateTexture(nil, "OVERLAY")
		self.Resting:SetPoint("RIGHT", self, "TOPRIGHT", -INSET, -INSET)
		self.Resting:SetWidth(20)
		self.Resting:SetHeight(20)
	end

	if unit == "player" or unit == "party" then
		self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		self.LFDRole:SetPoint("CENTER", self, unit == "player" and "LEFT" or "RIGHT", unit == "player" and INSET or -INSET, 0)
		self.LFDRole:SetWidth(20)
		self.LFDRole:SetHeight(20)
	end

	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("CENTER", self, "BOTTOM", -INSET, 0)
	self.RaidIcon:SetWidth(24)
	self.RaidIcon:SetHeight(24)

	if unit == "pet" or unit == "party" or unit == "partypet" then
		self.Range = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = 0.65
	end

	if not unit:match("^.+target$") then
		self.Threat = fakeThreat
		self.OverrideUpdateThreat = UpdateThreatHighlight
	end

	-- Module: oUF_DispelHighlight
	self.DispelHighlight = UpdateDispelHighlight

	-- Module: oUF_HealBars
	self.HealBars = { }
	for i = 1, 3 do
		self.HealBars[i] = self.Health:CreateTexture(nil, "OVERLAY")
		self.HealBars[i]:SetTexture(settings.statusbar)
	end
	self.HealBars.ignoreBombs = true
	self.HealBars.ignoreHoTs = true

	-- Module: oUF_Resurrection
	self.ResText = self.Health:CreateFontString(nil, "OVERLAY")
	self.ResText:SetFont(settings.font, 20, settings.fontOutline)
	self.ResText:SetPoint("TOP", 0, -3)

	-- Plugin: oUF_AFK
	if select(4, GetAddOnInfo("oUF_AFK")) and (unit == "player" or unit == "party") then
		self.AFK = self.Health:CreateFontString(nil, "OVERLAY")
		self.AFK:SetFont(settings.font, 16, settings.fontOutline)
		self.AFK:SetPoint("CENTER", self, "BOTTOM", 0, INSET)
		self.AFK.fontFormat = "AFK %s:%s"
	end

	-- Plugin: oUF_GCD -- ## TEMPORARY ##
	if select(4, GetAddOnInfo("oUF_GCD")) and unit == "player" then
		self.GCD = CreateFrame("Frame", nil, self.Power)
		self.GCD:SetAllPoints(self.Power)

		self.GCD.Spark = self.GCD:CreateTexture(nil, "OVERLAY")
		self.GCD.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		self.GCD.Spark:SetBlendMode("ADD")
		self.GCD.Spark:SetPoint("LEFT", -5, 0)
		self.GCD.Spark:SetWidth(10)
		self.GCD.Spark:SetHeight(self.Power:GetHeight() * 1.5)
    end

	-- Plugin: oUF_HealComm4 -- ## TEMPORARY ##
	if select(4, GetAddOnInfo("oUF_HealComm4")) then
		self.HealCommBar = CreateFrame("StatusBar", nil, self.Health)
		self.HealCommBar:SetStatusBarTexture(settings.statusbar)
		self.HealCommBar:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealCommOthersOnly = true
		self.allowHealCommOverflow = true
	end

	-- Plugin: oUF_ReadyCheck
	if select(4, GetAddOnInfo("oUF_ReadyCheck")) and (unit == "player" or unit == "party") then
		self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		self.ReadyCheck:SetPoint("CENTER")
		self.ReadyCheck:SetWidth(32)
		self.ReadyCheck:SetHeight(32)

		self.ReadyCheck.delayTime = 5
		self.ReadyCheck.fadeTime = 1
	end

	-- Plugin: oUF_Smooth
	if select(4, GetAddOnInfo("oUF_Smooth")) then
		self.Health.Smooth = true
		if self.Power then
			self.Power.Smooth = true
		end
	end

	if settings.borderStyle == "TEXTURE" then
		AddBorder(self)
		for i, tex in ipairs(self.borderTextures) do
			tex:SetParent(self.Health)
		end
	elseif settings.borderStyle == "GLOW" then
		self.BorderGlow = CreateFrame("Frame", nil, self)
		self.BorderGlow:SetFrameStrata("BACKGROUND")
		self.BorderGlow:SetFrameLevel(self:GetFrameLevel() - 1)
		self.BorderGlow:SetAllPoints(self)
		self.BorderGlow:SetBackdrop(backdrop_glow)
		self.BorderGlow:SetBackdropColor(0, 0, 0, 0)
		self.BorderGlow:SetBackdropBorderColor(0, 0, 0, 1)
	end

	if c.func then
		c.func(self)
	end

	return self
end

oUF:RegisterStyle("Phanx", Spawn)
oUF:SetActiveStyle("Phanx")

oUF:Spawn("player"):SetPoint("TOP", UIParent, "CENTER", 0, -200)
oUF:Spawn("pet"):SetPoint("TOP", oUF.units.player, "BOTTOM", 0, -16) -- settings.borderStyle == "TEXTURE" and -16 or 0)

oUF:Spawn("target"):SetPoint("TOPLEFT", UIParent, "CENTER", 200, -100)
oUF:Spawn("targettarget"):SetPoint("BOTTOMRIGHT", oUF.units.target, "TOPRIGHT", 0, 16) -- settings.borderStyle == "TEXTURE" and 16 or 0)

if settings.focusPlacement == "LEFT" then
	oUF:Spawn("focus"):SetPoint("TOPRIGHT", UIParent, "CENTER", -200, -100)
	oUF:Spawn("focustarget"):SetPoint("BOTTOMLEFT", oUF.units.focus, "TOPLEFT", 0, 16) -- settings.borderStyle == "TEXTURE" and 16 or 0)
else
	oUF:Spawn("focus"):SetPoint("TOPLEFT", UIParent, "CENTER", 200, -300 + target:GetHeight())
	oUF:Spawn("focustarget"):SetPoint("TOPRIGHT", oUF.units.focus, "BOTTOMRIGHT", 0, -16) -- settings.borderStyle == "TEXTURE" and -16 or 0)
end

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI
