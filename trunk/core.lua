--[[--------------------------------------------------------------------
	oUF_Phanx
	A fully featured, healer oriented layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info-oUF_Phanx.html
	Copyright ©2008–2009 Alyssa "Phanx" Kinley
	See README for license terms and additional information.

	Features:
		Aggro highlighting (and optionally threat levels)
		Dispellable debuff highlighting
		Estimated cast latency (Quartz style) (NYI)
		Incoming heals (NYI)
		Incoming resurrections (NYI)

	Units:
		player, pet, target, targettarget, focus

	Notes:
		Support for additional units is planned, but is not a high
		priority as I currently use Grid for party and raid frames.

	Required Dependencies:
		oUF

	Optional Dependencies:
		LibHealComm-3.0
		LibResComm-3.0
		oUF_CombatFeedback
		oUF_GCD
		oUF_ReadyCheck
		oUF_Smooth

----------------------------------------------------------------------]]

assert(oUF, "oUF_Phanx is just a layout. You need the base oUF addon too!")

local function debug(str, ...)
	do return end
	if select(1, ...) then str = str:format(...) end
	ChatFrame7:AddMessage("|cffff3333oUF_Phanx:|r " .. str)
end

------------------------------------------------------------------------
--	Configuration starts here								--
------------------------------------------------------------------------

local settings = {
	-- Disable this if you use a separate castbar addon
	castBars = true,

	-- Color pets using the color of the class most likely to own them
	-- e.g. beasts are assumed to be hunter pets
	guessPetColors = true,

	-- Use the Blizzard threat levels to color borders based on threat
	-- thresholds, instead of binary aggro coloring
	threatLevels = false,

	-- These should be obvious
	font = "Fonts\\FRIZQT__.ttf",
	statusbar = "Interface\\AddOns\\SharedMedia\\statusbar\\Neal",
	border = "Interface\\AddOns\\oUF_Phanx\\media\\border",
	borderColor = { 0.3, 0.3, 0.3, 1 },
	backdropColor = { 0.1, 0.1, 0.1, 1 },

	-- Don't change the insets
	backdrop = {
		bgFile = "Interface\\Addons\\Grid\\white16x16", tile = true, tileSize = 16,
		edgeFile = "Interface\\Addons\\Grid\\white16x16", edgeSize = 3,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }, -- All to 3 for Grid-style border
	},

	-- Unit configuration
	-- Required:	width (number), height (number), point (table)
	-- Optional:	power (boolean), reverse (boolean), vertical (boolean)
	-- Special:	header (boolean), attributes (table), template (string)
	-- Points are relative to CENTER of the UIParent
	units = {
		player = {
			width = 200,
			height = 25,
			power = true,
			point = { "TOPRIGHT", -208, -105 },
		},
		pet = {
			width = 200,
			height = 25,
			power = true,
			point = { "TOPRIGHT", -208, -145 },
		},
		target = {
			width = 200,
			height = 25,
			power = true,
			reverse = true,
			point = { "TOPLEFT", 208, -105 },
		},
		targettarget = {
			width = 200,
			height = 20,
			reverse = true,
			point = { "TOPLEFT", 208, -145 },
		},
		focus = {
			width = 200,
			height = 25,
			point = { "TOPLEFT", 587, -105 },
		},
		focustarget = {
			width = 200,
			height = 20,
			reverse = true,
			point = { "TOPLEFT", 587, -145 },
		},
--[[
		maintank = {
			width = 100,
			height = 25,
			reverse = true,
			point = { "BOTTOMLEFT", 150 + 200 + 60 + 50 + 30, -150 - 60 },
			header = true,
			attributes = { "showRaid", true, "groupFilter", "MAINTANK", "yOffset", 10 },
		},
		mainassist = {
			width = 100,
			height = 25,
			reverse = true,
			point = { "BOTTOMLEFT", 150 + 200 + 60 + 50 + 30, -150 - 60 },
			header = true,
			attributes = { "showRaid", true, "groupFilter", "MAINASSIST", "yOffset", 10 },
		},
]]
	},
}

local L = setmetatable({}, { __index = function(t, k) return k end })

-- These only need editing if you play in a non-English locale.
local strings = {
	classification = {
		["elite"] = "|cffffd700E|r",
		["rare"] = "|cffc7c7cfR|r",
		["rareelite"] = "|cffc7c7cfR|r|cffffd700E|r",
		["worldboss"] = "|cffeda55fB|r",
	},
	creaturetype = {
		["Beast"] = "Be",
		["Demon"] = "De",
		["Dragonkin"] = "Dr",
		["Elemental"] = "El",
		["Giant"] = "Gi",
		["Humanoid"] = "Hu",
		["Mechanical"] = "Me",
		["Undead"] = "Un",
		["Critter"] = "",
		["Non-combat Pet"] = "",
		["Not specified"] = "",
		["Unknown"] = "",
	},
}

-- These don't really need editing at all.
local colors = oUF.colors
do
	colors.threat = {
		{ 1, 1, 0.47 },	-- not tanking, high threat
		{ 1, 0.6, 0 },		-- tanking, insecure threat
		{ 1, 0, 0 },		-- tanking, secure threat
	}

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
end

------------------------------------------------------------------------
--	Configuration ends here									--
------------------------------------------------------------------------

colors.debuff = { }
for type, color in pairs(DebuffTypeColor) do
	if type ~= "none" then
		colors.debuff[type] = { color.r, color.g, color.b }
	end
end

if CUSTOM_CLASS_COLORS then
	for k, v in CUSTOM_CLASS_COLORS:IterateClasses() do
		colors.class[k][1] = v.r
		colors.class[k][2] = v.g
		colors.class[k][3] = v.b
	end
	CUSTOM_CLASS_COLORS:RegisterCallback(function()
		for k, v in CUSTOM_CLASS_COLORS:IterateClasses() do
			colors.class[k][1] = v.r
			colors.class[k][2] = v.g
			colors.class[k][3] = v.b
		end
	end)
end

-- colors.class.SHAMAN = { 0, 0.86, 0.72 }

------------------------------------------------------------------------

local MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]
local PLAYER_CLASS = select(2, UnitClass("player"))

--[[--------------------------------------------------------------------
	AbbreviateValue
	arguments:
		value (number)
	returns:
		value (string) - nicely formatted value for display
----------------------------------------------------------------------]]

local function AbbreviateValue(value)
	if value >= 10000000 then
		return string.format("%.1fm", value / 1000000)
	elseif value >= 1000000 then
		return string.format("%.2fm", value / 1000000)
	elseif value >= 100000 then
		return string.format("%.0fk", value / 1000)
	elseif value >= 10000 then
		return string.format("%.1fk", value / 1000)
	else
		return value
	end
end

--[[--------------------------------------------------------------------
	GetDifficultyColor
	arguments:
		unit (string) - any valid unit token
	returns:
		r (number)
		g (number)
		b (number)
----------------------------------------------------------------------]]

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

--[[--------------------------------------------------------------------
	GetReactionColor
	arguments:
		unit (string) - any valid unit token
	returns:
		color (table) - array with r, g, b values
----------------------------------------------------------------------]]

local function GetReactionColor(unit)
	if UnitIsPlayer(unit) or UnitPlayerControlled(unit) then
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

--[[--------------------------------------------------------------------
	GetUnitColor
	arguments:
		unit (string) - any valid unit token
	returns:
		color (table) - an array containing r, g, b values
	notes:
		Class for players, most likely owner class for pets, tapped or
		reaction for NPCs.
----------------------------------------------------------------------]]

local function GetUnitColor(unit)
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		return colors.tapped
	elseif UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		return colors.class[class] or colors.unknown
	elseif settings.guessPetColors and UnitPlayerControlled(unit) then
		if unit == "pet" then
			return colors.class[PLAYER_CLASS]
		end

		local owner = unit:match("^(.+)pet$")
		if owner then
			local _, class = UnitClass(owner)
			if class then
				return colors.class[class]
			end
		end

		local class = UnitCreatureType(unit)
		if class == L["Beast"] then
			return colors.class.HUNTER
		end
		if class == L["Demon"] then
			return colors.class.WARLOCK
		end
		if class == L["Undead"] then
			return colors.class.DEATHKNIGHT
		end
		if class == L["Totem"] or class == L["Elemental"] then
			return colors.class.SHAMAN
		end

		local name = UnitName(unit)
		if name == L["Shadowfiend"] then
			return colors.class.PRIEST
		end
	end
	return GetReactionColor(unit)
end

------------------------------------------------------------------------
--	Add and update nifty borders
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
		size = 16
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
	SetBorderSize(frame)

	frame.SetBorderColor = SetBorderColor
	frame.SetBorderSize = SetBorderSize
end

------------------------------------------------------------------------
--	Border management
------------------------------------------------------------------------

local function UpdateBorder(self)
	if not self.unit:match("target$") then debug("UpdateBorder: %s", self.unit) end
	local priority, color = 0

	if self.DebuffPriority then
		debug("Checking for debuffs...")
		for i, type in ipairs(self.DebuffPriority) do
			if self.hasDebuff[type] then
				color = colors.debuff[type]
				priority = self.DebuffPriority[type]
				debug("hasDebuff, %s, %d", type, priority)
			end
		end
	end

	if self.hasThreat then
		debug("Checking for threat...")
		if priority < 6 and self.hasThreat > 0 then
			color = colors.threat[self.hasThreat]
			priority = 5
			debug("hasThreat, %d, %d", self.hasThreat, priority)
		end
	end

	if priority > 4 then
		self:SetBorderSize(20)
	else
		self:SetBorderSize(16)
	end

	self:SetBorderColor(unpack(color or settings.borderColor))
end

------------------------------------------------------------------------
--	Update health bar and text
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
				bar.value:SetFormattedText("-%s", AbbreviateValue(max - min))
			elseif unit == "targettarget" or unit == "focustarget" then
				bar.value:SetFormattedText("%s%%", floor(min / max * 100))
			elseif UnitPlayerControlled(unit) and UnitIsFriend(unit, "player") then
				bar.value:SetFormattedText("%s|cffff9999 - %s|r", AbbreviateValue(max), AbbreviateValue(max - min))
			else
				bar.value:SetFormattedText("%s (%d%%)", AbbreviateValue(min), floor(min / max * 100))
			end
		elseif unit == "target" or unit == "focus" then
			bar.value:SetText(AbbreviateValue(max))
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
--	Update druid mana text
------------------------------------------------------------------------

local UpdateDruidMana
do
	local time = 0
	function UpdateDruidMana(self, elapsed)
		time = time + (elapsed or 1000)
		if time > 0.5 then
			--debug("UpdateDruidMana")

			if self.shapeshifted then
				local min, max = UnitPower("player", SPELL_POWER_MANA), UnitPowerMax("player", SPELL_POWER_MANA)
				if min < max then
					return self.DruidMana:SetFormattedText("%d%%", min, floor(min / max * 100))
				end
			end
			self.DruidMana:SetText()
			time = 0
		end
	end
end

------------------------------------------------------------------------
--	Update power bar and text
------------------------------------------------------------------------

local function UpdatePower(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end
	--debug("UpdatePower: %s, %s", event, unit)

	if max == 0 or UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)
		bar:SetStatusBarColor(0, 0, 0)
		bar.bg:SetVertexColor(0, 0, 0)
		if bar.value then
			bar.value:SetText()
		end
		return
	end

	local r, g, b

	if unit == "pet" and PLAYER_CLASS == "HUNTER" and self.power then
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
					UpdateDruidMana(self)
				end
			else
				if not self.shapeshifted then
					self.shapeshifted = true
					UpdateDruidMana(self)
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
						bar.value:SetText(AbbreviateValue(min))
					else
						bar.value:SetText()
					end
				end
			else
				if powertype == "MANA" then
					if min < max then
						bar.value:SetFormattedText("%s|cff%02x%02x%02x.%s|r", AbbreviateValue(min), r * 255, g * 255, b * 255, AbbreviateValue(max))
					else
						bar.value:SetText(max)
					end
				elseif powertype == "ENERGY" then
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
--	Update hunter pet happiness
------------------------------------------------------------------------

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
--	Update info text
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
		creature = strings.creaturetype[UnitCreatureType(unit)]
	end

	self.Info:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r * 255, g * 255, b * 255, level, strings.classification[UnitClassification(unit)] or "", creature or "")
end

------------------------------------------------------------------------
--	Update name text
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
--	Debuff highlighting
------------------------------------------------------------------------

local function UpdateDebuffHighlight(self, unit)
	if unit and unit ~= self.unit then return end
	-- debug("UpdateDebuffHighlight: %s", unit)

	UpdateBorder(self)
end

------------------------------------------------------------------------
--	Threat highlighting
------------------------------------------------------------------------

local function UpdateThreatHighlight(self, event, unit, threatLevel)
	if unit and unit ~= self.unit then return end
	-- debug("UpdateThreatHighlight: %s", unit)

	UpdateBorder(self)
end

------------------------------------------------------------------------
--	Skin aura icons
------------------------------------------------------------------------

local function DontReallyHide(self)
	self:SetVertexColor(unpack(settings.borderColor))
end

local function PostCreateAuraIcon(self, button, icons, index, isDebuff)
	--debug("PostCreateAuraIcon: %s, %s, %s", self.unit, index, isDebuff)
	
	button.icon:SetTexCoord(.07, .93, .07, .93)
	button.icon:SetPoint("TOPLEFT", button, 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", button, -1, 1)

--	button.icon:ClearAllPoints()
--	button.icon:SetPoint("TOPLEFT", button, 2, -2)
--	button.icon:SetPoint("BOTTOMRIGHT", button, -2, 2)
--	button.icon:SetTexCoord(0.04, 0.96, 0.04, 0.96)

	button.cd:SetReverse()
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", button, 1, -1)
	button.cd:SetPoint("BOTTOMRIGHT", button, -1, 1)

	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOM", button, 0, 2)

	button.overlay:SetTexture(settings.border)
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay:ClearAllPoints()
	button.overlay:SetPoint("TOPLEFT", button, -1, 1)
	button.overlay:SetPoint("BOTTOMRIGHT", button, 1, -1)

	button.overlay.Hide = DontReallyHide
end

------------------------------------------------------------------------
--	Bla bla boring stuff
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
--	Setup a frame
------------------------------------------------------------------------

local BORDER_GAP = settings.backdrop.edgeSize - 1 -- +1 instead for Grid style border

local function Spawn(self, unit)
	-- debug("Spawn: %s", unit)

	-- self.disallowVehicleSwap = true

	local config
	if not unit then
		config = settings.units[string.match(self:GetParent():GetName():lower(), "^ouf_phanx(%a+)$")]
	else
		config = settings.units[unit]
	end

	self.reverse = config.reverse

	self.menu = menu
	self:SetAttribute("*type2", "menu")

	self:RegisterForClicks("anyup")

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	local width = config.width + (BORDER_GAP * 2)
	self:SetAttribute("initial-width", width)
	self:SetWidth(width)

	local height = config.height + (BORDER_GAP * 2) + (config.power and 1 or 0)
	self:SetAttribute("initial-height", height)
	self:SetHeight(height)

	self:SetFrameStrata("BACKGROUND")
	self:SetFrameLevel(0)
	self:SetBackdrop(settings.backdrop)
	self:SetBackdropColor(unpack(settings.backdropColor))
	self:SetBackdropBorderColor(0, 0, 0, 0)

	self.overlay = CreateFrame("Frame", nil, self)
	self.overlay:SetFrameStrata("BACKGROUND")
	self.overlay:SetFrameLevel(2)
	self.overlay:SetAllPoints(self)

	-------------------------------------------------------------------
	--	Health bar, health text

	local hp = CreateFrame("StatusBar", nil, self)
	hp:SetFrameStrata("BACKGROUND")
	hp:SetFrameLevel(1)
	hp:SetStatusBarTexture(settings.statusbar)
	if config.vertical then
		hp:SetPoint("TOPLEFT", BORDER_GAP, -BORDER_GAP)
		hp:SetPoint("BOTTOMLEFT", BORDER_GAP, BORDER_GAP)
		hp:SetHeight(config.power and config.width / 5 * 4 or config.width)
		hp:SetStatusBarOrientation("VERTICAL")
	else
		hp:SetPoint("BOTTOMLEFT", BORDER_GAP, BORDER_GAP)
		hp:SetPoint("BOTTOMRIGHT", -BORDER_GAP, BORDER_GAP)
		hp:SetHeight(config.power and config.height / 5 * 4 or config.height)
	end

	hp.bg = hp:CreateTexture(nil, "BORDER")
	hp.bg:SetAllPoints(hp)
	hp.bg:SetTexture(settings.statusbar)

	hp.value = hp:CreateFontString(nil, "OVERLAY")
	hp.value:SetFont(settings.font, 20, "OUTLINE")
	hp.value:SetShadowOffset(0, 0)
	hp.value:SetTextColor(1, 1, 1)
	if self.reverse and not (unit and unit:match("^%a+target$")) then
		hp.value:SetPoint("LEFT", hp:GetHeight() / 2 - 8, 0)
	else
		hp.value:SetPoint("RIGHT", -hp:GetHeight() / 2 + 8, 0)
	end

	hp.frequentUpdates = true
	hp.Smooth = true

	self.Health = hp
	self.OverrideUpdateHealth = UpdateHealth

	-------------------------------------------------------------------
	--	Power bar, power text, druid mana text

	if config.power then
		local pp = CreateFrame("StatusBar", nil, self)
		pp:SetFrameStrata("BACKGROUND")
		pp:SetFrameLevel(1)
		pp:SetStatusBarTexture(settings.statusbar)
		if config.vertical then
			pp:SetPoint("TOPRIGHT", -BORDER_GAP, -BORDER_GAP)
			pp:SetPoint("BOTTOMRIGHT", -BORDER_GAP, -BORDER_GAP)
			pp:SetHeight(config.width / 5)
			pp:SetStatusBarOrientation("VERTICAL")
		else
			pp:SetPoint("TOPLEFT", BORDER_GAP, -BORDER_GAP)
			pp:SetPoint("TOPRIGHT", -BORDER_GAP, -BORDER_GAP)
			pp:SetHeight(config.height / 5)
		end

		pp.bg = pp:CreateTexture(nil, "BORDER")
		pp.bg:SetAllPoints(pp)
		pp.bg:SetTexture(settings.statusbar)

		pp.value = pp:CreateFontString(nil, "OVERLAY")
		pp.value:SetFont(settings.font, 16, "OUTLINE")
		pp.value:SetShadowOffset(0, 0)
		if self.reverse then
			pp.value:SetPoint("RIGHT", hp, -hp:GetHeight() / 2 + 8, 0)
		else
			pp.value:SetPoint("LEFT", hp, hp:GetHeight() / 2 - 8, 0)
		end

		if unit == "player" then
			if playerClass ~= "DEATHKNIGHT" and playerClass ~= "ROGUE" and playerClass ~= "WARRIOR" then
				local ps = pp:CreateTexture(nil, "OVERLAY")
				ps:SetHeight(pp:GetHeight() * 2)
				ps:SetWidth(pp:GetHeight())
				ps:SetBlendMode("ADD")
				ps:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
				ps:SetVertexColor(1, 1, 1, 1)

				ps.rtl = self.reverse

				self.Spark = ps
			end

			if playerClass == "DRUID" then
				local dm = pp:CreateFontString(nil, "OVERLAY")
				dm:SetPoint("TOP")
				dm:SetFont(FONT, 12, "OUTLINE")
				dm:SetShadowOffset(0, 0)
				dm:SetTextColor(unpack(colors.power.MANA))

				self.DruidMana = dm
			end
		end

		if unit == "pet" and playerClass == "HUNTER" then
			self.UNIT_HAPPINESS = UpdateHappiness
			self:RegisterEvent("UNIT_HAPPINESS")
		end

		pp.frequentUpdates = unit == "player"
		pp.Smooth = true

		self.Power = pp
		self.OverrideUpdatePower = UpdatePower
	end

	-------------------------------------------------------------------
	--	Global cooldown spark (oUF_GCD)

	if unit == "player" then
		local gcd = CreateFrame("Frame", nil, self)
		gcd:SetAllPoints(config.power and self.Power or self)

		local spark = gcd:CreateTexture(nil, "OVERLAY")
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetBlendMode("ADD")
		spark:SetWidth(10)
		spark:SetHeight(gcd:GetHeight())

		self.GCD = gcd
		self.GCD.Spark = spark
	end

	-------------------------------------------------------------------
	--	Info text

	if unit == "target" then
		local info = self.overlay:CreateFontString(nil, "OVERLAY")
		info:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -1)
		info:SetFont(settings.font, 14, "OUTLINE")
		info:SetShadowOffset(0, 0)
		info:SetJustifyH("RIGHT")

		self.Info = info
		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", UpdateInfo)
		self:RegisterEvent("UNIT_LEVEL", UpdateInfo)
	end

	-------------------------------------------------------------------
	--	Name text

	if unit == "target" or unit == "focus" then
		local name = self.overlay:CreateFontString(nil, "OVERLAY")
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -2)
		if self.Info then
			name:SetPoint("BOTTOMRIGHT", self.Info, "BOTTOMLEFT", 0, -1)
		else
			name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -2)
		end
		name:SetFont(settings.font, 18, "OUTLINE")
		name:SetShadowOffset(0, 0)
		name:SetJustifyH("LEFT")

		self.Name = name
		self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)
		table.insert(self.__elements, UpdateName)
	elseif unit == "targettarget" or unit == "focustarget" then
		local name = hp:CreateFontString(nil, "OVERLAY")
		name:SetPoint("LEFT", hp, "LEFT", hp:GetHeight() / 2 - 7, 0)
		name:SetPoint("RIGHT", hp.value, "LEFT", -hp:GetHeight() + 14, 0)
		name:SetFont(settings.font, 16, "OUTLINE")
		name:SetShadowOffset(0, 0)
		name:SetJustifyH("LEFT")

		self.Name = name
		self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)
		table.insert(self.__elements, UpdateName)
	end

	-------------------------------------------------------------------
	--	Combo points text

	if unit == "target" then
		local cp = self.overlay:CreateFontString(nil, "OVERLAY")
		cp:SetPoint("CENTER")
		cp:SetFont(settings.font, 34, "OUTLINE")
		cp:SetShadowOffset(0, 0)
		cp:SetTextColor(unpack(colors.class[PLAYER_CLASS]))

		self.CPoints = cp
	end

	-------------------------------------------------------------------
	--	AFK/DND text

	if unit == "player" or not unit or not unit:match("target$") then
		self.AFK = self.overlay:CreateFontString(nil, "OVERLAY")
		self.AFK:SetPoint("CENTER", self, "BOTTOM")
		self.AFK:SetFont(settings.font, 12, "OUTLINE")
		self.AFK:SetShadowOffset(0, 0)
		self.AFK.fontFormat = "AFK %s:%s"
	end

	-------------------------------------------------------------------
	--	Combat feedback text (oUF_CombatFeedback / oUF_HealingFeedback)

	if unit == "player" or unit == "pet" or unit == "target" or unit == "focus" then
		local cf = self.overlay:CreateFontString(nil, "OVERLAY")
		cf:SetPoint("CENTER", self)
		cf:SetFont(settings.font, 16, "OUTLINE")
		cf:SetShadowOffset(0, 0)

		cf.maxAlpha = 0.8
		cf.ignoreImmune = true
		cf.ignoreOther = true

		self.CombatFeedbackText = cf
	end

	-------------------------------------------------------------------
	--	Resurrection status text (oUF_ResComm / oUF_ResurrectionStatus)

	if not unit or not unit:match("^(.+)target$") then
		local rs = self.overlay:CreateFontString(nil, "OVERLAY")
		rs:SetPoint("CENTER")
		rs:SetFont(settings.font, 12, "OUTLINE")
		rs:SetShadowOffset(0, 0)

		rs.ignoreSoulstone = true
		-- also includes Reincarnation and Twisting Nether, as LibResComm-1.0 does not distinguish between self-res types

		self.ResurrectionFeedback = rs
	end

	-------------------------------------------------------------------
	--	Combat icon

	if unit == "player" then
		self.Combat = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Combat:SetPoint("CENTER", self, "BOTTOMRIGHT")
		self.Combat:SetWidth(32)
		self.Combat:SetHeight(32)
		self.Combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
		self.Combat:SetTexCoord(0.55, 1, 0, 0.45)
	end

	-------------------------------------------------------------------
	--	Rest icon

	if unit == "player" then
		self.Resting = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Resting:SetPoint("CENTER", self, "BOTTOMRIGHT")
		self.Resting:SetWidth(24)
		self.Resting:SetHeight(24)
		self.Resting:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
		self.Resting:SetTexCoord(0.45, 0, 0, 0.45)
	end

	-------------------------------------------------------------------
	--	Group leader icon

	if unit == "player" or unit == "target" then
		self.Leader = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Leader:SetPoint("CENTER", self, "BOTTOMLEFT")
		self.Leader:SetWidth(16)
		self.Leader:SetHeight(16)
		self.Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	end

	-------------------------------------------------------------------
	--	Master looter icon
--[[
	if unit == "player" or unit == "target" then
		self.Looter = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Looter:SetPoint("CENTER", self, "BOTTOMLEFT")
		self.Looter:SetWidth(16)
		self.Looter:SetHeight(16)
		self.Looter:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	end
]]
	-------------------------------------------------------------------
	--	Raid target icon

	self.RaidIcon = self.overlay:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("CENTER", self, "TOP")
	self.RaidIcon:SetWidth(32)
	self.RaidIcon:SetHeight(32)
	self.RaidIcon:SetTexture("Interface\\GroupFrame\\UI-RaidTargetingIcons")

	-------------------------------------------------------------------
	--	Auras

	if unit == "player" then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 15)
		self.Debuffs.size = 36
		self.Debuffs:SetHeight(self.Debuffs.size)
		self.Debuffs:SetWidth(self.Debuffs.size * 5)
		self.Debuffs.initialAnchor = "BOTTOMRIGHT"
		self.Debuffs["growth-y"] = "TOP"
		self.Debuffs["growth-x"] = "LEFT"
		self.Debuffs.num = 10
		self.Debuffs.spacing = 3
		self.Debuffs.showDebuffType = true

		self.PostCreateAuraIcon = PostCreateAuraIcon

	elseif unit == "pet" then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -15)
		self.Debuffs.size = 36
		self.Debuffs:SetHeight(self.Debuffs.size)
		self.Debuffs:SetWidth(self.Debuffs.size * 5)
		self.Debuffs.initialAnchor = "TOPRIGHT"
		self.Debuffs["growth-y"] = "BOTTOM"
		self.Debuffs["growth-x"] = "LEFT"
		self.Debuffs.num = 10
		self.Debuffs.spacing = 3
		self.Debuffs.showDebuffType = true

		self.PostCreateAuraIcon = PostCreateAuraIcon

	elseif unit == "target" then
		self.Auras = CreateFrame("Frame", nil, self)
		self.Auras.size = 24
		self.Auras.spacing = 3
		self.Auras.gap = true
		self.Auras:SetHeight(self.Auras.size)
		self.Auras:SetWidth(self.Auras.size * 10)
		self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -4, 15)
		self.Auras.initialAnchor = "TOPLEFT"
		self.Auras["growth-y"] = "TOP"
		self.Auras.numBuffs = 40
		self.Auras.numDebuffs = 40
		self.Auras.showDebuffType = true

		self.PostCreateAuraIcon = PostCreateAuraIcon
	end

	-------------------------------------------------------------------
	--	Border and highlighting

	AddBorder(self)
	for i, tex in ipairs(self.borderTextures) do
		tex:SetParent(self.Health)
	end

	self.DebuffHighlight = UpdateBorder

	self.ThreatHighlight = UpdateBorder
	self.ThreatHighlightLevels = false

	-------------------------------------------------------------------
	--	Cast bar

	if settings.castBars and (unit == "player" or unit == "target" or unit == "focus" or unit == "pet") then
		local Castbar = CreateFrame("StatusBar", nil, self)
		Castbar:SetWidth(300)
		Castbar:SetHeight(20)
		Castbar:SetStatusBarTexture(settings.statusbar)
		Castbar:SetStatusBarColor(unpack(colors.power.MANA))

		if unit == "player" then
			Castbar:SetPoint("TOP", UIParent, "CENTER", 0, -350)
		elseif unit == "target" then
			Castbar:SetPoint("TOP", UIParent, "CENTER", 0, 100)
		elseif unit == "focus" then
			Castbar:SetPoint("TOP", UIParent, "CENTER", 0, 70)
		elseif unit == "pet" then
			Castbar:SetPoint("TOP", UIParent, "CENTER", 0, -330)
			Castbar:SetWidth(300)
			Castbar:SetHeight(15)
			Castbar:SetStatusBarColor(unpack(colors.power.FOCUS))
		end

		local bg = Castbar:CreateTexture(nil, "BACKGROUND")
		bg:SetTexture(settings.statusbar)
		bg:SetAllPoints(Castbar)
		bg:SetVertexColor(0, 0, 0, 0.75)

		local Time = Castbar:CreateFontString(nil, "OVERLAY")
		Time:SetPoint("RIGHT", Castbar, "RIGHT", -4.5, 0.5)
		Time:SetFont(settings.font, 20, "OUTLINE")
		Time:SetShadowOffset(0, 0)
		Time:SetJustifyH("RIGHT")

		local Text = Castbar:CreateFontString(nil, "OVERLAY")
		if unit == "pet" or unit == "focus" then
			Text:SetPoint("TOPLEFT", Castbar, "BOTTOMLEFT", 0, 0)
		else
			Text:SetPoint("BOTTOMLEFT", Castbar, "TOPLEFT", 0, 0)
		end
		Text:SetFont(settings.font, 18, "OUTLINE")
		Text:SetShadowOffset(0, 0)
		Text:SetJustifyH("LEFT")
		if unit == "player" or unit == "pet" then
			Text:SetTextColor(unpack(colors.class[PLAYER_CLASS]))
		else
			Text:SetTextColor(1, 0.8, 0)
		end

		local sR, sG, sB = Castbar:GetStatusBarColor()
		local sF = 1 / math.max(sR, sG, sB)
		sR, sG, sB = sR * sF, sG * sF, sB * sF

		local Spark = Castbar:CreateTexture(nil, "OVERLAY")
		Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		Spark:SetVertexColor(sR, sG, sB)
		Spark:SetBlendMode("ADD")

		if unit == "player" then
			local SafeZone = Castbar:CreateTexture(nil, "BORDER")
			SafeZone:SetTexture(settings.statusbar)
			SafeZone:SetVertexColor(1, 0.4, 0)

			Castbar.SafeZone = SafeZone
		end

		AddBorder(Castbar)

		Castbar.bg = bg
		Castbar.Time = Time
		Castbar.Text = Text
		Castbar.Spark = Spark
		self.Castbar = Castbar
	end

	-------------------------------------------------------------------
	--	That's all, folks!

	return self
end

------------------------------------------------------------------------
--	Spawn more overlords!
------------------------------------------------------------------------

oUF:RegisterStyle("Phanx", Spawn)
oUF:SetActiveStyle("Phanx")
for unit, data in pairs(settings.units) do
	local p, x, y = unpack(data.point)
	local name = "oUF_Phanx" .. unit:gsub("target", "Target"):gsub("pet", "Pet", 1):gsub("%a", string.upper, 1)

	local f = oUF:Spawn(unit, name)
	f:SetPoint(p, UIParent, "CENTER", x, y)
end

------------------------------------------------------------------------
--	Sharing is caring?
------------------------------------------------------------------------

oUF_Phanx = {
	L = L,
	colors = colors,
	debug = debug,
	menu = menu,
	settings = settings,
	strings = strings,
	AbbreviateValue = AbbreviateValue,
	AddBorder = AddBorder,
	GetDifficultyColor = GetDifficultyColor,
	GetReactionColor = GetReactionColor,
	GetUnitColor = GetUnitColor,
	PostCreateAuraIcon = PostCreateAuraIcon,
	SetBorderColor = SetBorderColor,
	SetBorderSize = SetBorderSize,
	UpdateBorder = UpdateBorder,
	UpdateDebuffHighlight = UpdateDebuffHighlight,
	UpdateThreatHighlight = UpdateThreatHighlight,
}

------------------------------------------------------------------------
--	The end.
------------------------------------------------------------------------