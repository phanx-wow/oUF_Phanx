--[[--------------------------------------------------------------------
	oUF_Phanx
	A fully featured, healer oriented layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info-oUF_Phanx.html
	Copyright ©2008–2009 Alyssa "Phanx" Kinley
	See README for license terms and additional information.

	Features:
		Aggro highlighting
		Dispellable debuff highlighting
		Incoming heal display
		Resurrection display [NYI]

	Supported Units:
		Player
		Pet
		Target
		Target Target
		Focus
		Focus Target
		Party [NYI]
		Party Pet [NYI]

	Supported Plugins:
		oUF_AFK
		oUF_CombatFeedback
		oUF_GCD
		oUF_ReadyCheck
		oUF_Smooth

	Required Dependencies:
		oUF

	Optional Dependencies:
		LibHealComm-4.0 (required for incoming heal display)
		LibResComm-1.0 (required for resurrection display)
----------------------------------------------------------------------]]

assert(oUF, "oUF_Phanx requires oUF.")

local settings = {
------------------------------------------------------------------------
--	CONFIGURATION STARTS HERE
------------------------------------------------------------------------

	statusbar = "Interface\\AddOns\\SharedMedia\\statusbar\\HalJ",

	font = "Fonts\\FRIZQT__.ttf",

	outline = "OUTLINE",		-- NONE, OUTLINE, THICKOUTLINE

	borderStyle = "FLAT",		-- FLAT, GLOW, TEXTURE

	width = 200,
	height = 20,				-- This is the height of the health bar only.

	focusMirror = true,			-- true = opposite target, false = under target

	threatLevels = false,		-- true = threat levels, false = binary aggro

------------------------------------------------------------------------
--	CONFIGURATION ENDS HERE
--	No support will be provided for modifying anything past this line.
------------------------------------------------------------------------
}

------------------------------------------------------------------------
--	Localization
--	If there are not yet translations for your locale, rather than only
--	adding them here for yourself, please contact me and share your
--	translations so that other users can benefit too!
------------------------------------------------------------------------

local L = setmetatable({}, { __index = function(t, k) t[k] = k return k end })
--[[
if GetLocale() == "xxXX" then
	L["B"] = "B"		-- Boss
	L["E"] = "E"		-- Elite
	L["R"] = "R"		-- Rare

	L[" Be"] = " Be"	-- Beast
	L[" De"] = " De"	-- Demon
	L[" Dr"] = " Dr"	-- Dragonkin
	L[" El"] = " El"	-- Elemental
	L[" Gi"] = " Gi"	-- Giant
	L[" Hu"] = " Hu"	-- Humanoid
	L[" Me"] = " Me"	-- Mechanical
	L[" Un"] = " Un"	-- Undead
end
]]

------------------------------------------------------------------------

local playerClass = select(2, UnitClass("player"))

local MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]

local strings = {
	classification = {
		["elite"]		= "|cffffd700" .. L["E"] .. "|r",
		["rare"]		= "|cffc7c7cf" .. L["R"] .. "|r",
		["rareelite"]	= "|cffc7c7cf" .. L["R"] .. "|r|cffffd700" .. L["E"] .. "|r",
		["worldboss"]	= "|cffeda55f" .. L["B"] .. "|r",
	},
	creatureType = {
		["Beast"]		= L[" Be"],
		["Demon"]		= L[" De"],
		["Dragonkin"]	= L[" Dr"],
		["Elemental"]	= L[" El"],
		["Giant"]		= L[" Gi"],
		["Humanoid"]	= L[" Hu"],
		["Mechanical"]	= L[" Me"],
		["Undead"]	= L[" Un"],
	}
}

local usettings = {
	power = {
		player = true,
		target = true,
		focus = true,
	},
	reverse = {
		target = true,
		targettarget = true,
		focus = not settings.focusMirror,
		focustarget = not settings.focusMirror,
		party = true,
		partypet = true,
	},
}

local colors = oUF.colors
do
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
end

------------------------------------------------------------------------

local function debug(str, ...)
	do return end
	if select(1, ...) then str = str:format(...) end
	ChatFrame7:AddMessage("|cffff3333oUF_Phanx:|r " .. str)
end

------------------------------------------------------------------------

local function si(n)
	if type(n) ~= "number" then return n end

	if n >= 10000000 then
		return string.format("%.1fm", n / 1000000)
	elseif n >= 1000000 then
		return string.format("%.2fm", n / 1000000)
	elseif n >= 100000 then
		return string.format("%.0fk", n / 1000)
	elseif n >= 10000 then
		return string.format("%.1fk", n / 1000)
	else
		return n
	end
end

------------------------------------------------------------------------

local function GetDifficultyColor(level)
	if level < 1 then level = 100 end
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
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		return colors.tapped
	elseif UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		return colors.class[class] or colors.unknown
	elseif UnitIsPlayer(unit) or UnitPlayerControlled(unit) then
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

local BORDER_SIZE = 14

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
		size = BORDER_SIZE
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

	if self.threatLevel then
		-- debug("Checking for threat (" .. (IsTanking() and "tanking" or "not tanking") .. ")...")
		local threatPriority = IsTanking() and 10 or 5
		if priority < threatPriority and self.threatLevel > 0 then
			color = colors.threat[self.threatLevel]
			priority = threatPriority
			debug("hasThreat, %d, %d", self.threatLevel, priority)
		end
	end

	if settings.borderStyle == "TEXTURE" then
		local r, g, b = unpack(color or settings.borderColor)
		self:SetBorderColor(r, g, b, 1)
		self:SetBorderSize(BORDER_SIZE * (priority > 4 and 1.25 or 1))
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
		local text
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
		bar.value:SetTextColor(1, 1, 1)
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

	if max == 0 or UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
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
--	#UNUSED!

local function UpdateHappiness(self, event, unit)
	if self.unit ~= unit then return end
	--debug("UpdateHappiness: %s, %s", event, unit)

	local r, g, b
	if UnitIsDead(unit) then
		r, g, b = 0, 0, 0
	elseif GetPetHappiness() then
		r, g, b = unpack(colors.happiness[GetPetHappiness()])
	else
		local _, powertype = UnitPowerType(unit)
		r, g, b = unpack(colors.power.FOCUS)
	end

	if self.reverse then
		self.Power:SetStatusBarColor(r * .2, g * .2, b * .2)
		self.Power.bg:SetVertexColor(r, g, b)
	else
		self.Power:SetStatusBarColor(r, g, b)
		self.Power.bg:SetVertexColor(r * .2, g * .2, b * .2)
	end

end

------------------------------------------------------------------------

local function UpdateInfo(self, event, unit)
	if self.unit ~= unit then return end
	--debug("UpdateInfo: %s, %s", event, unit)

	local level = UnitLevel(unit)

	local r, g, b
	if not UnitIsFriend(unit, "player") then
		r, g, b = GetDifficultyColor(level)
	else
		r, g, b = 1, 1, 1
	end

	if level == -1 then
		level = "??"
	elseif level == MAX_LEVEL and UnitIsPlayer(unit) then
		level = ""
	end

	local creature
	if unit ~= "pet" and not UnitIsPlayer(unit) then
		creature = strings.creatureType[UnitCreatureType(unit)]
	end

	self.Info:SetFormattedText("|cff%02x%02x%02x%s|r%s%s", r * 255, g * 255, b * 255, level, strings.classification[UnitClassification(unit)] or "", creature or "")
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
		r, g, b = GetUnitColor(unit)
	end

	self.Name:SetText(UnitName(unit))
	self.Name:SetTextColor(r, g, b)

	if self.Info then
		UpdateInfo(self, event, unit)
	end

	UpdateBorder(self)
end

------------------------------------------------------------------------
--	#UNUSED!

local function UpdateDebuffHighlight(self, unit)
	if unit and unit ~= self.unit then return end
	-- debug("UpdateDebuffHighlight: %s", unit)

	UpdateBorder(self)
end

------------------------------------------------------------------------
--	#UNUSED!

local function UpdateThreatHighlight(self, event, unit, threatLevel)
	if unit and unit ~= self.unit then return end
	-- debug("UpdateThreatHighlight: %s", unit)

	UpdateBorder(self)
end

------------------------------------------------------------------------
--	Custom aura filtering for hunter pets
--	#UNUSED!

local petBuffWhitelist = {
	[GetSpellInfo(48443)] = true, -- Regrowth
	[GetSpellInfo(48441)] = true, -- Rejuvenation
	[GetSpellInfo(48068)] = true, -- Renew
	[GetSpellInfo(48451)] = true, -- Lifebloom

	[GetSpellInfo(49284)] = true, -- Earth Shield
	[GetSpellInfo(48066)] = true, -- Power Word: Shield
	[GetSpellInfo(53601)] = true, -- Sacred Shield
}

local petDebuffBlacklist = {
	[GetSpellInfo(57723)] = true, -- Exhaustion
	[GetSpellInfo(57724)] = true, -- Sated
}

local function PetCustomAuraFilter(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
	if caster == "player" or caster == "pet" then
		return true
	end
	for i, v in ipairs(icons) do
		if v.icon:GetTexture() == texture then
			if v.debuff then
				return not petDebuffBlacklist[name]
			else
				return petBuffWhitelist[name]
			end
			break
		end
	end
	return true
end

------------------------------------------------------------------------

local BACKDROP = {
	bgFile = "Interface\\Buttons\\WHITE8X8", tile = true, tileSize = 16,
	edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 3,
	insets = { top = 3, right = 3, bottom = 3, left = 3, },
}

local GLOW_BACKDROP = {
	edgeFile = "Interface\\AddOns\\oUF.Phanx\\media\\glow",
	edgeSize = 5,
	insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

local INSET = BACKDROP.insets.left + (settings.borderStyle == "TEXTURE" and -1 or 1)

local DIV = 5

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

local function Spawn(self, unit)
	if not unit then
		unit = string.match(self:GetParent():GetName():lower(), "^ouf_phanx(%a+)$")
	end

	self.reverse = usettings.reverse[unit]

	self.menu = menu
	self:SetAttribute("*type2", "menu")

	self:RegisterForClicks("anyup")

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)


	local width = INSET + settings.width + INSET
	local height = INSET + settings.height + INSET
	if usettings.power[unit] then
		height = height + 1 + (settings.height / DIV)
	end

	self:SetWidth(width)
	self:SetHeight(height)

	self:SetAttribute("initial-width", width)
	self:SetAttribute("initial-height", height)


	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function(self) self:StartMoving() end)
	self:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)


	self:SetFrameStrata("BACKGROUND")
	self:SetFrameLevel(1)


	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0, 0.85)
	self:SetBackdropBorderColor(0, 0, 0, 0)


	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetPoint("TOP", self, 0, -INSET)
	self.Health:SetWidth(settings.width)
	self.Health:SetHeight(settings.height)
	self.Health:SetStatusBarTexture(settings.statusbar)

	self.Health.bg = self.Health:CreateTexture(nil, "BACKGROUND")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(settings.statusbar)

	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	if self.reverse then
		self.Health.value:SetPoint("LEFT", self.Health, INSET, 0)
	else
		self.Health.value:SetPoint("RIGHT", self.Health, -INSET, 0)
	end
	self.Health.value:SetFont(settings.font, 24, settings.outline)
	self.Health.value:SetShadowOffset(0, 0)

	self.Health.frequentUpdates = true
	self.Health.Smooth = true

	self.OverrideUpdateHealth = UpdateHealth


	if usettings.power[unit] then
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetPoint("BOTTOM", self, 0, INSET)
		self.Power:SetWidth(settings.width)
		self.Power:SetHeight(settings.height / DIV)
		self.Power:SetStatusBarTexture(settings.statusbar)

		self.Power.bg = self.Power:CreateTexture(nil, "BACKGROUND")
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetTexture(settings.statusbar)

		self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
		if self.reverse then
			self.Power.value:SetPoint("RIGHT", self.Health, -INSET, -2)
			self.Power.value:SetPoint("LEFT", self.Health.value, "RIGHT", 0, -2)
			self.Power.value:SetJustifyH("RIGHT")
		else
			self.Power.value:SetPoint("LEFT", self.Health, -INSET, -2)
			self.Power.value:SetPoint("RIGHT", self.Health.value, "LEFT", 0, -2)
		end
		self.Power.value:SetFont(settings.font, 20, settings.outline)
		self.Power.value:SetShadowOffset(0, 0)

		self.frequentPower = unit == "player"
		self.OverrideUpdatePower = UpdatePower
	end


	if unit == "target" or unit == "focus" then
		local v1, v2 = "TOP", "BOTTOM"
		if unit == "focus" and not settings.focusMirror then
			v1, v2 = "BOTTOM", "TOP"
		end

		self.Name = self:CreateFontString(nil, "OVERLAY")
		if self.reverse then
			self.Name:SetPoint(v1 .. "LEFT", self, v2 .. "LEFT", INSET, -INSET - 1)
		else
			self.Name:SetPoint(v1 .. "RIGHT", self, v2 .. "LEFT", -INSET, -INSET - 1)
		end
		self.Name:SetFont(settings.font, 20, settings.outline)
		self.Name:SetShadowOffset(0, 0)

		self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)
		table.insert(self.__elements, UpdateName)


		self.Info = self:CreateFontString(nil, "OVERLAY")
		if self.reverse then
			self.Info:SetPoint(v1 .. "RIGHT", self, v2 .. "RIGHT", -INSET, -INSET)
		else
			self.Info:SetPoint(v1 .. "LEFT", self, v2 .. "LEFT", INSET, -INSET)
		end
		self.Info:SetFont(settings.font, 12, settings.outline)
		self.Info:SetShadowOffset(0, 0)

		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", UpdateInfo)
		self:RegisterEvent("UNIT_LEVEL", UpdateInfo)
	end


	self.overlay = CreateFrame("Frame", nil, self)
	self.overlay:SetAllPoints(self)
	self.overlay:SetFrameStrata("BACKGROUND")
	self.overlay:SetFrameLevel(self:GetFrameLevel() + 1)


	self.RaidIcon = self.overlay:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("CENTER", self, "TOP")
	self.RaidIcon:SetWidth(32)
	self.RaidIcon:SetHeight(32)


	if unit == "player" then
		self.Combat = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Combat:SetPoint("CENTER", self.Health, 3, 0)
		self.Combat:SetWidth(35)
		self.Combat:SetHeight(35)


		self.DruidMana = self.overlay:CreateFontString(nil, "OVERLAY")
		self.DruidMana:SetPoint("TOPRIGHT", self.Power.value, "BOTTOMRIGHT")
		self.DruidMana:SetFont(settings.font, 12, settings.outline)
		self.DruidMana:SetShadowOffset(0, 0)


		self.Resting = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Resting:SetPoint("CENTER", self, "BOTTOMRIGHT", settings.borderStyle == "TEXTURE" and 0 or -INSET, settings.borderStyle == "TEXTURE" and 0 or INSET)
		self.Resting:SetWidth(24)
		self.Resting:SetHeight(24)
	end


	if unit == "target" then
		self.CPoints = self.overlay:CreateFontString(nil, "OVERLAY")
		self.CPoints:SetPoint("RIGHT", self, "LEFT", settings.borderStyle == "TEXTURE" and 0 or INSET, 0)
		self.CPoints:SetFont(settings.font, 32, settings.outline)
		self.CPoints:SetShadowOffset(0, 0)
		self.CPoints:SetTextColor(unpack(colors.class.ROGUE))
	end


	if unit == "pet" then
		self.Happiness = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Happiness:SetPoint("TOPLEFT", self, INSET * 2, -INSET * 2)
		self.Happiness:SetPoint("BOTTOMLEFT", self, INSET * 2, INSET * 2)
		self.Happiness:SetWidth(self.Happiness:GetHeight())
	end


	if unit and (unit == "target" or not unit:match("target$")) then
		self.AFK = self.overlay:CreateFontString(nil, "OVERLAY")
		self.AFK:SetPoint("CENTER", self, "BOTTOM", 0, settings.borderStyle ~= "TEXTURE" and INSET or 0)
		self.AFK:SetFont(settings.font, 12, settings.outline)
		self.AFK:SetShadowOffset(0, 0)

		self.AFK.fontFormat = "AFK %s:%s"


		self.Leader = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Leader:SetPoint("BOTTOMLEFT", self, -INSET / 2, settings.borderStyle == "TEXTURE" and -INSET * 2 or -INSET / 2)
		self.Leader:SetWidth(16)
		self.Leader:SetHeight(16)


		self.Assistant = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Assistant:SetPoint("BOTTOMLEFT", self.Leader)
		self.Assistant:SetWidth(16)
		self.Assistant:SetHeight(16)


		self.MasterLooter = self.overlay:CreateTexture(nil, "OVERLAY")
		self.MasterLooter:SetPoint("BOTTOM", self.Leader, "TOP", -1, -2)
		self.MasterLooter:SetWidth(15)
		self.MasterLooter:SetHeight(15)
	end


	if settings.borderStyle == "TEXTURE" and PhanxMod and PhanxMod.AddBorder then
		PhanxMod:AddBorder(self)
		for i, tex in ipairs(self.borderTextures) do
			tex:SetParent(self.overlay)
		end
	elseif settings.borderStyle == "GLOW" then
		self.BorderGlow = CreateFrame("Frame", nil, self)
		self.BorderGlow:SetAllPoints(self)
		self.BorderGlow:SetFrameStrata("BACKGROUND")
		self.BorderGlow:SetFrameLevel(0)

		self.BorderGlow:SetBackdrop(GLOW_BACKDROP)
		self.BorderGlow:SetBackdropColor(0, 0, 0, 0)
		self.BorderGlow:SetBackdropBorderColor(0, 0, 0, 1)
	end


	self.Range = true
	self.inRangeAlpha = 1
	self.outsideRangeAlpha = 0.5


	--
	--	Module support: DebuffHighlight
	--
	self.DebuffHighlight = UpdateBorder


	--
	--	Module support: ThreatHighlight
	--
	self.ThreatHighlight = UpdateBorder
	self.ThreatHighlightLevels = settings.threatLevels


	--
	--	Module support: HealComm
	--
	if not unit or not unit:match("^(.+)target$") then
		self.HealCommBar = CreateFrame("StatusBar", nil, self.Health)
		self.HealCommBar:SetStatusBarTexture(settings.statusbar)
		self.HealCommBar:SetStatusBarColor(0, 1, 0, 0.25)
		self.HealCommBar:SetPoint(self.reverse and "RIGHT" or "LEFT", self.Health)

		self.HealCommText = self.overlay:CreateFontString(nil, "OVERLAY")
		self.HealCommIgnoreHoTs:SetPoint("CENTER", self.Health)
		self.HealCommIgnoreHoTs:SetFont(settings.font, 12, settings.outline)
		self.HealCommIgnoreHoTs:SetShadowOffset(0, 0)

		self.HealCommFilter = "ALL"
		self.HealCommIgnoreHoTs = true
		self.HealCommNoOverflow = true
	end


	--
	--	Module support: ResComm
	--
	if not unit or not unit:match("^(.+)target$") then
		self.ResCommText = self.overlay:CreateFontString(nil, "OVERLAY")
		self.ResCommText:SetPoint("CENTER", self.Health)
		self.ResCommText:SetFont(settings.font, 12, settings.outline)
		self.ResCommText:SetShadowOffset(0, 0)

		self.ResCommIgnoreSoulstone = false
		-- also ignores Reincarnation and Twisting Nether, as LibResComm-1.0 does not distinguish between self-res types
	end


	--
	--	Plugin support: oUF_CombatFeedback
	--
	if select(4, GetAddOnInfo("oUF_CombatFeedback")) and (unit == "player" or unit == "pet" or unit == "target" or unit == "focus") then
		self.CombatFeedbackText = self.overlay:CreateFontString(nil, "OVERLAY")
		self.CombatFeedbackText:SetPoint("CENTER", self)
		self.CombatFeedbackText:SetFont(settings.font, 16, settings.outline)
		self.CombatFeedbackText:SetShadowOffset(0, 0)

		self.CombatFeedbackText.maxAlpha = 0.8
		self.CombatFeedbackText.ignoreImmune = true
		self.CombatFeedbackText.ignoreOther = true
	end


	--
	--	Plugin support: oUF_GCD
	--
	if select(4, GetAddOnInfo("oUF_GCD")) and unit == "player" then
		self.GCD = CreateFrame("Frame", nil, self)
		self.GCD:SetAllPoints(self.Power or self)

		self.GCD.Spark = self.GCD:CreateTexture(nil, "OVERLAY")
		self.GCD.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		self.GCD.Spark:SetBlendMode("ADD")
		self.GCD.Spark:SetWidth(10)
		self.GCD.Spark:SetHeight(self.GCD:GetHeight())
	end


	--
	--	Plugin support: oUF_MoveableFrames
	--
	if select(4, GetAddOnInfo("oUF_MoveableFrames") then
		self.MoveableFrames = true
	end


	return self
end

------------------------------------------------------------------------

oUF_Phanx = CreateFrame("Frame")

oUF_Phanx.usettings = usettings
oUF_Phanx.strings = strings

oUF_Phanx.debug = debug
oUF_Phanx.si = si

oUF_Phanx.GetDifficultyColor = GetDifficultyColor
oUF_Phanx.GetUnitColor = GetUnitColor
oUF_Phanx.AddBorder = AddBorder
oUF_Phanx.SetBorderColor = SetBorderColor
oUF_Phanx.SetBorderSize = SetBorderSize
oUF_Phanx.UpdateBorder = UpdateBorder

oUF_Phanx:RegisterEvent("ADDON_LOADED")
oUF_Phanx:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "PhanxTest" then return end

	local function copytable(a, b)
		if not a then return { } end
		if not b then b = { } end
		for k, v in pairs(a) do
			if type(v) == "table" then
				b[k] = copyTable(v, b[k])
			elseif type(b[k]) ~= type(v) then
				b[k] = v
			end
		end
		return b
	end
	if not oUF_Phanx_Settings then
		oUF_PhanxSettings = { }
	end
	copyTable(settings, oUF_Phanx_Settings)
	settings = oUF_Phanx_Settings
	self.settings = settings


	oUF:RegisterStyle("Phanx", Spawn)
	oUF:SetActiveStyle("Phanx")

	local player = oUF:Spawn("player", "oUF_Player")
	player:SetPoint("TOP", UIParent, "CENTER", 0, -200)

	local pet = oUF:Spawn("pet", "oUF_Pet")
	pet:SetPoint("TOP", player, "BOTTOM", 0, settings.borderStyle == "TEXTURE" and -12 or 0)

	local target = oUF:Spawn("target", "oUF_Target")
	target:SetPoint("TOPLEFT", UIParent, "CENTER", 200, -100)

	local targettarget = oUF:Spawn("targettarget", "oUF_TargetTarget")
	targettarget:SetPoint("BOTTOM", target, "TOP", 0, settings.borderStyle == "TEXTURE" and 12 or 0)

	local focus = oUF:Spawn("focus", "oUF_Focus")
	if settings.focusMirror then
		focus:SetPoint("TOPRIGHT", UIParent, "CENTER", -200, -100)
	else
		focus:SetPoint("TOPLEFT", UIParent, "CENTER", 200, -300 + target:GetHeight())
	end

	local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
	if settings.focusMirror then
		focustarget:SetPoint("BOTTOM", focus, "TOP", 0, settings.borderStyle == "TEXTURE" and 12 or 0)
	else
		focustarget:SetPoint("TOP", focus, "BOTTOM", 0, settings.borderStyle == "TEXTURE" and -12 or 0)
	end


	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end)

------------------------------------------------------------------------

local function setFonts(t, file)
	for k, v in pairs(t) do
		if type(v) == "table" then
			if v.GetObjectType then
				if v.SetFont then
					v:SetFont(file)
				end
			else
				setFonts(v, file)
			end
		end
	end
end

function oUF_Phanx:SetAllFonts(file)
	for u, f in pairs(oUF.units) do
		setFonts(f, file)
	end
end

------------------------------------------------------------------------

local function setTextures(t, file)
	for k, v in pairs(t) do
		if type(v) == "table" then
			if v.GetObjectType then
				if v.SetStatusBarTexture then
					v:SetStatusBarTexture(file)
				end
			else
				setTextures(v, file)
			end
		end
	end
end

function oUF_Phanx:SetAllTextures(file)
	for u, f in pairs(oUF.units) do
		setTextures(f, file)
	end
end

------------------------------------------------------------------------