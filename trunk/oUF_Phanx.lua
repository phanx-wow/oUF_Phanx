--[[------------------------------------------------------------
	oUF_Phanx
	Phanx's layout for oUF.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info????-oUF_Phanx.html
	See README for license terms and other information.
--------------------------------------------------------------]]

if not oUF then return end

local FONT = "Fonts\\FRIZQT__.ttf" -- "Interface\\AddOns\\SharedMedia\\font\\AkzidenzGroteskLightBold.ttf"
local STATUSBAR = "Interface\\AddOns\\SharedMedia\\statusbar\\Armory" -- "Interface\\AddOns\\SharedMedia\\statusbar\\Savant1"

local FMT_DEFICIT = "-%s"
local FMT_DEFICIT_FULL = "%s|cffffeeee-%s|r"
local FMT_PERCENT = "%d%%"
local FMT_PERCENT_FULL = "%s (%d%%)"
local FMT_POWER_FULL = "%s|cff%02x%02x%02x.%s|r"

local INFO_STRING = "|cff%02x%02x%02x%s|r%s |cffffffff%s|r"

local classification = {
	["elite"] = "|cffffd700E|r",
	["rare"] = "|cffc7c7cfR|r",
	["rareelite"] = "|cffc7c7cfR|r|cffffd700E|r",
	["worldboss"] = "|cffeda55fB|r",
}

local creaturetype = {
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
}

local colors = oUF.colors
do
	colors.unknown = { 1, 0.5, 1 }

	colors.dead = { .6, .6, .6 }
	colors.ghost = { .6, .6, .6 }
	colors.offline = { .6, .6, .6 }

	colors.civilian = { 0, 0, 1 }
	colors.friendly = { FACTION_BAR_COLORS[6].r, FACTION_BAR_COLORS[6].g, FACTION_BAR_COLORS[6].b }
	colors.hostile = { FACTION_BAR_COLORS[2].r, FACTION_BAR_COLORS[2].g, FACTION_BAR_COLORS[2].b }
	colors.neutral = { FACTION_BAR_COLORS[4].r, FACTION_BAR_COLORS[4].g, FACTION_BAR_COLORS[4].b }

	colors.power.MANA = { 0, .82, 1 } -- 144/255
	colors.power.RUNIC_POWER = { .41, .41, 1 }
end

local EDGEGLOW_WIDTH = 20

local BORDER_WIDTH = 4

local BACKDROP = {
	bgFile = "Interface\\Addons\\Grid\\white16x16", tile = true, tileSize = 16,
	edgeFile = "Interface\\Addons\\Grid\\white16x16", edgeSize = 3,
	insets = {left = 3, right = 3, top = 3, bottom = 3},
}

local BORDER_COLOR = { r = 0, g = 0, b = 0, a = 0 }
local AGGRO_COLOR = { r = 1, g = 0, b = 0, a = 1 }

local playerClass = select(2, UnitClass("player"))
local MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()] or 80

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

local function GetUnitColor(unit)
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		return colors.tapped
	elseif UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		return colors.class[class] or colors.unknown
	elseif UnitPlayerControlled(unit) then
		local class = UnitCreatureType(unit)
		local name = UnitName(unit)
		if class == "Beast" then
			return colors.class.HUNTER
		elseif class == "Demon" then
			return colors.class.WARLOCK
		elseif class == "Humanoid" or name == "Shadowfiend" then
			return colors.class.PRIEST
		elseif class == "Elemental" or name:match("Totem$") or name:match("^Totem") then
			return colors.class.SHAMAN
		end
	end
	return GetReactionColor(unit)
end

local function UpdateEdgeGlowPosition(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end

	if min == max then
		return bar.edge:Hide()
	end

	local x
	if self.reverse then
		x = bar:GetWidth() - (bar:GetWidth() * (min / max)) - bar.edge:GetWidth()
	else
		x = bar:GetWidth() * (min / max) - bar.edge:GetWidth()
	end
	if x < 0 then
		bar.edge:Hide()
	else
		bar.edge:SetPoint("LEFT", bar, "LEFT", x, 0)
		bar.edge:Show()
	end
end

local function UpdateHealth(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end

	local t, r, g, b

	if UnitIsDead(unit) then
		r, g, b = unpack(colors.dead)
		bar:SetValue(self.reverse and 0 or max)
		bar.value:SetText("Dead")
	elseif UnitIsGhost(unit) then
		r, g, b = unpack(colors.ghost)
		bar:SetValue(self.reverse and 0 or max)
		bar.value:SetText("Ghost")
	elseif not UnitIsConnected(unit) then
		r, g, b = unpack(colors.offline)
		bar:SetValue(self.reverse and 0 or max)
		bar.value:SetText("Offline")
	else
		r, g, b = unpack(GetUnitColor(unit))
		bar:SetValue(self.reverse and max - min or min)
		if min < max then
			if unit == "player" or unit == "pet" then
				t = string.format(FMT_DEFICIT, AbbreviateValue(max - min))
			elseif unit == "targettarget" or unit == "focustarget" then
				t = string.format(FMT_PERCENT, floor(min / max * 100))
			elseif UnitPlayerControlled(unit) and UnitIsFriend(unit, "player") then
				t = string.format(FMT_DEFICIT_FULL, AbbreviateValue(max - min), AbbreviateValue(max))
			else
				t = string.format(FMT_PERCENT_FULL, AbbreviateValue(min), floor(min / max * 100))
			end
		elseif unit == "target" or unit == "focus" then
			t = AbbreviateValue(max)
		end
		bar.value:SetText(t)
	end

	bar.value:SetTextColor(r / 2 + 0.5, g / 2 + 0.5, b / 2 + 0.5)
	if self.Name then
		self.Name:SetTextColor(r, g, b)
	end

	if self.reverse then
		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * .2, g * .2, b * .2)
	else
		bar:SetStatusBarColor(r * .2, g * .2, b * .2)
		bar.bg:SetVertexColor(r, g, b)
	end

	if bar.edge then
		bar.edge:SetVertexColor(r / 2 + 0.5, g / 2 + 0.5, b / 2 + 0.5)
		UpdateEdgeGlowPosition(self, event, unit, bar, min, max)
	end
end

local function UpdatePower(self, event, unit, bar, min, max)
	if self.unit ~= unit then return end

	if max == 0 or UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)
		bar:SetStatusBarColor(0, 0, 0)
		bar.bg:SetVertexColor(0, 0, 0)
		if bar.value then
			bar.value:SetText()
		end
		return
	end

	local t, r, g, b
	if self.reverse then
		bar:SetValue(max - min)
	else
		bar:SetValue(min)
	end
	if unit == "pet" and playerClass == "HUNTER" then
		r, g, b = unpack(colors.happiness[GetPetHappiness()] or colors.power.FOCUS)
		if min < max then
			t = min
		end
	else
		local _, powertype = UnitPowerType(unit)
		r, g, b = unpack(colors.power[powertype])
		if unit == "player" or unit == "pet" then
			if self.DruidMana then
				if powertype == "MANA" then
					self.DruidMana:SetText()
				else
					local manamin, manamax = UnitPower("player", SPELL_POWER_MANA), UnitPowerMax("player", SPELL_POWER_MANA)
					if manamin < manamax then
						self.DruidMana:SetFormattedText("%d (%d%%)", manamin, math.floor(manamin / manamax * 100))
					end
				end
			end
			if powertype == "RAGE" or powertype == "RUNIC_POWER" then
				if min > 0 then
					t = min
				end
			else -- MANA, FOCUS, ENERGY
				if min < max then
					t = AbbreviateValue(min)
				end
			end
		else
			if powertype == "MANA" then
				if min < max then
					t = string.format(FMT_POWER_FULL, AbbreviateValue(min), r * 255, g * 255, b * 255, AbbreviateValue(max))
				else
					t = max
				end
			elseif powertype == "ENERGY" then
				if min < max then
					t = min
				end
			else
				if min > 0 then
					t = min
				end
			end
		end
	end
	if self.reverse then
		bar:SetStatusBarColor(r * .2, g * .2, b * .2)
		bar.bg:SetVertexColor(r, g, b)
	else
		bar:SetStatusBarColor(r, g, b)
		bar.bg:SetVertexColor(r * .2, g * .2, b * .2)
	end
	if bar.value then
		bar.value:SetText(t)
		bar.value:SetTextColor(r / 2 + 0.5, g / 2 + 0.5, b / 2 + 0.5)
	end
end

local function UpdateHappiness(self, event, unit)
	if self.unit ~= unit then return end

	local bar = self.Power
	local r, g, b
	if UnitIsDead(unit) then
		r, g, b = 0, 0, 0
	elseif GetPetHappiness() then
		r, g, b = unpack(colors.happiness[GetPetHappiness()])
	else
		local _, powertype = UnitPowerType(unit)
		r, g, b = unpack(colors.power.FOCUS)
	end
	bar:SetStatusBarColor(r, g, b)
	bar.bg:SetVertexColor(r * .2, g * .2, b * .2)
	bar.value:SetTextColor(r / 2 + 0.5, g / 2 + 0.5, b / 2 + 0.5)
end

local function UpdateInfo(self, event, unit)
	if unit ~= self.unit then return end

	local level = UnitLevel(unit)

	local r, g, b
	if not UnitIsFriend(unit, "player") then
		r, g, b = GetDifficultyColor(level)
	else
		r, g, b = 1, 1, 1
	end

	if level == -1 then
		level = "??"
	elseif UnitLevel("player") == MAX_LEVEL and level == MAX_LEVEL and UnitIsPlayer(self.unit) then
		level = ""
	end

	local creature
	if unit ~= "pet" and not UnitIsPlayer(unit) then
		creature = creaturetype[UnitCreatureType(unit)]
	end

	self.Info:SetFormattedText(INFO_STRING, r * 255, g * 255, b * 255, level, classification[UnitClassification(unit)] or "", creature or "")
end

local function UpdateName(self, event, unit)
	if self.unit ~= unit then return end

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
end

--
-- Color the frame border appropriately under various conditions
--

local function rgb2hex(r, g, b)
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local DispelType = {}
for dispeltype, color in pairs(DebuffTypeColor) do
	DispelType[rgb2hex(color.r, color.b, color.g)] = dispeltype
end

local CanDispel = {
	DRUID = { Curse = true, Poison = true, },
	MAGE = { Curse = true, },
	PALADIN = { Magic = true, Poison = true, Disease = true, },
	PRIEST = { Magic = true, Disease = true, },
	SHAMAN = { Curse = true, Poison = true, Disease = true, },
}
CanDispel = CanDispel[playerClass] or {}

local function UpdateBorderColor(self)
	local c
	if self.hasDebuff and CanDispel(self.hasDebuff) then
		c = DebuffTypeColor[self.hasDebuff]
	elseif hasAggro then
		c = AGGRO_COLOR
	elseif self.hasDebuff then
		c = DebuffTypeColor[self.hasDebuff]
	else
		c = BORDER_COLOR
	end
	self:SetBackdropBorderColor(c.r, c.g, c.b, c.a or 1)
end

--
-- Handle callbacks from oUF_Banzai
--

local function UpdateAggro(self, unit, aggro)
	if self.unit ~= unit then return end

	if aggro == 1 then
		self.hasAggro = false
	else
		self.hasAggro = true
	end

	UpdateBorderColor(self)
end

--
-- This is a hack to make oUF_DebuffHighlight color the frame's border
-- instead of the background.
--

local function SetBackdropColorToBorder(self, r, g, b, a)
	local color = rgb2hex(r, g, b)
	local dispeltype = DispelType[rgb2hex(r, g, b)]
	if dispeltype then
		self.hasDebuff = dispeltype
	else
		self.hasDebuff = false
	end
	UpdateBorderColor(self)
end

local function menu(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local function new(settings, self, unit)
	self.menu = menu

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks("anyup")
	self:SetAttribute("*type2", "menu")

	self:SetAttribute("initial-width", settings.width + (BORDER_WIDTH * 2))
	self:SetAttribute("initial-height", settings.height + (BORDER_WIDTH * 2))

	self:SetFrameStrata("BACKGROUND")
	self:SetFrameLevel(0)
	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(0, 0, 0, 0)

	self.reverse = settings.reverse

	self.overlay = CreateFrame("Frame")
	self.overlay:SetParent(self)
	self.overlay:SetFrameStrata("BACKGROUND")
	self.overlay:SetFrameLevel(2)
	self.overlay:SetAllPoints(self)
	
	local hp = CreateFrame("StatusBar")
	hp:SetParent(self)
	hp:SetFrameStrata("BACKGROUND")
	hp:SetFrameLevel(1)
	hp:SetPoint("BOTTOM", self, 0, BORDER_WIDTH)
	hp:SetWidth(settings.width)
	if settings.nopower then
		hp:SetHeight(settings.height)
	else
		hp:SetHeight(settings.height / 5 * 4)
	end
	hp:SetStatusBarTexture(STATUSBAR)

	hp.bg = hp:CreateTexture(nil, "BORDER")
	hp.bg:SetAllPoints(hp)
	hp.bg:SetTexture(STATUSBAR)

	hp.value = hp:CreateFontString(nil, "OVERLAY")
	hp.value:SetFont(FONT, 16, "OUTLINE")
	if self.reverse then
		hp.value:SetPoint("LEFT", BORDER_WIDTH + 2, 0)
	else
		hp.value:SetPoint("RIGHT", -BORDER_WIDTH - 2, 0)
	end
--[[
	hp.edge = hp:CreateTexture(nil, "OVERLAY")
	hp.edge:SetWidth(EDGEGLOW_WIDTH)
	hp.edge:SetHeight(hp:GetHeight())
	hp.edge:SetAlpha(0.4)
	hp.edge:SetTexture("Interface\\AddOns\\oUF_HolySmurf\\textures\\SmurfStripe")
	if self.reverse then
		hp.edge:SetTexCoord(0, 1, 0, 1)
	else
		hp.edge:SetTexCoord(1, 0, 0, 1)
	end
	hp.edge:SetBlendMode("ADD")
	hp.edge:Hide()
]]
	hp.frequentUpdates = false
	hp.Smooth = true

	self.Health = hp
	self.OverrideUpdateHealth = UpdateHealth

	if not settings.nopower then
		local pp = CreateFrame("StatusBar")
		pp:SetParent(self)
		pp:SetFrameStrata("BACKGROUND")
		pp:SetFrameLevel(1)
		pp:SetPoint("TOP", self, 0, -BORDER_WIDTH)
		pp:SetWidth(settings.width)
		pp:SetHeight(settings.height / 5)
		pp:SetStatusBarTexture(STATUSBAR)

		pp.bg = pp:CreateTexture(nil, "BORDER")
		pp.bg:SetAllPoints(pp)
		pp.bg:SetTexture(STATUSBAR)

		if unit then
			pp.value = pp:CreateFontString(nil, "OVERLAY")
			pp.value:SetFont(FONT, 16, "OUTLINE")
			if settings.reverse then
				pp.value:SetPoint("RIGHT", hp, -BORDER_WIDTH - 2, 0)
			else
				pp.value:SetPoint("LEFT", hp, BORDER_WIDTH + 2, 0)
			end
		end

		if unit == "pet" and playerClass == "HUNTER" then
			self.UNIT_HAPPINESS = UpdateHappiness
			self:RegisterEvent("UNIT_HAPPINESS")
		end

		if unit == "player" and playerClass ~= "DEATHKNIGHT" and playerClass ~= "ROGUE" and playerClass ~= "WARRIOR" then
			local ps = pp:CreateTexture(nil, "OVERLAY")
			ps:SetHeight(pp:GetHeight() * 2)
			ps:SetWidth(pp:GetHeight())
			ps:SetBlendMode("ADD")
			ps:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			ps:SetVertexColor(1, 1, 1, 1)

			ps.rtl = true

			self.Spark = ps
		end

		if unit == "player" and playerClass == "DRUID" then
			local dm = pp:CreateFontString(nil, "OVERLAY")
			dm:SetPoint("RIGHT", -BORDER_WIDTH - 2, 0)
			dm:SetFont(FONT, 12, "OUTLINE")
			dm:SetTextColor(unpack(colors.power.MANA))

			self.DruidMana = dm
		end

		pp.frequentUpdates = true
		pp.Smooth = true

		self.Power = pp
		self.OverrideUpdatePower = UpdatePower
	end

	if unit == "target" then
		self.Info = self:CreateFontString(nil, "OVERLAY")
		self.Info:SetFont(FONT, 12, "OUTLINE")
		self.Info:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -BORDER_WIDTH + 3, -3)
		self.Info:SetJustifyH("RIGHT")

		self.UNIT_CLASSIFICATION_CHANGED = UpdateInfo
		self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
		self.UNIT_LEVEL = UpdateInfo
		self:RegisterEvent("UNIT_LEVEL")
	end

	if unit == "target" or unit == "focus" then
		self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
		self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", BORDER_WIDTH - 3, -BORDER_WIDTH - 1)
		if self.Info then
			self.Name:SetPoint("BOTTOMRIGHT", self.Info, "BOTTOMLEFT", -BORDER_WIDTH - 4, -BORDER_WIDTH + 2)
		else
			self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -BORDER_WIDTH + 3, -BORDER_WIDTH - 1)
		end
		self.Name:SetFont(FONT, 18, "OUTLINE")
		self.Name:SetJustifyH("LEFT")

		self.UNIT_NAME_UPDATE = UpdateName
	elseif unit == "targettarget" or unit == "focustarget" then
		self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
		self.Name:SetPoint("LEFT", hp, "LEFT", BORDER_WIDTH + 2, 0)
		self.Name:SetPoint("RIGHT", hp.value, "LEFT", -4, 0)
		self.Name:SetFont(FONT, 14, "OUTLINE")
		self.Name:SetJustifyH("LEFT")

		self.UNIT_NAME_UPDATE = UpdateName
	end

	if unit == "target" and playerClass == "DRUID" or playerClass == "ROGUE" then
		self.CPoints = self.overlay:CreateFontString(nil, "OVERLAY")
		self.CPoints:SetPoint("CENTER")
		self.CPoints:SetFont(FONT, 34, "OUTLINE")
		self.CPoints:SetTextColor(unpack(colors.class[playerClass]))
	end

	self.AFK = self.overlay:CreateFontString(nil, "OVERLAY")
	self.AFK:SetPoint("CENTER", self, "BOTTOM", 0, BORDER_WIDTH)
	self.AFK:SetFont(FONT, 12, "OUTLINE")
	self.AFK.fontFormat = "AFK %s:%s"

	if unit == "player" or unit == "pet" or unit == "target" or unit == "focus" then
		self.CombatFeedbackText = self.overlay:CreateFontString(nil, "OVERLAY")
		self.CombatFeedbackText:SetPoint("CENTER", self)
		self.CombatFeedbackText:SetFont(FONT, 16, "OUTLINE")

		self.CombatFeedbackText.maxAlpha = 0.8
		self.CombatFeedbackText.ignoreImmune = true
		self.CombatFeedbackText.ignoreOther = true
	end

	self.HealingFeedback = self.overlay:CreateFontString(nil, "OVERLAY")
	self.HealingFeedback:SetPoint("CENTER", self)
	self.HealingFeedback:SetFont(FONT, 16, "OUTLINE")

	self.IncomingRes = self.overlay:CreateFontString(nil, "OVERLAY")
	self.IncomingRes:SetPoint("CENTER", self)
	self.IncomingRes:SetFont(FONT, 12, "OUTLINE")

	if unit == "player" then
		self.Combat = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Combat:SetPoint("CENTER", self, "BOTTOMRIGHT", -BORDER_WIDTH + 2, BORDER_WIDTH)
		self.Combat:SetWidth(32)
		self.Combat:SetHeight(32)
		self.Combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
		self.Combat:SetTexCoord(0.55, 1, 0, 0.45)

		if UnitLevel("player") < MAX_LEVEL then
			self.Resting = self.overlay:CreateTexture(nil, "OVERLAY")
			self.Resting:SetPoint("CENTER", self, "BOTTOMRIGHT", -BORDER_WIDTH + 2, BORDER_WIDTH)
			self.Resting:SetWidth(24)
			self.Resting:SetHeight(24)
			self.Resting:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
			self.Resting:SetTexCoord(0.45, 0, 0, 0.45)

			self.PLAYER_LEVEL_UP = function(self)
				if UnitLevel("player") == MAX_LEVEL then
					self.Resting:Hide()
					self.Resting = nil
					self:UnregisterEvent("PLAYER_LEVEL_UP")
					self.PLAYER_LEVEL_UP = nil
				end
			end
			self:RegisterEvent("PLAYER_LEVEL_UP")
		end
	end

	if not unit or unit == "player" or unit == "target" then
		self.Leader = self.overlay:CreateTexture(nil, "OVERLAY")
		self.Leader:SetPoint("CENTER", self, "BOTTOMLEFT", BORDER_WIDTH, BORDER_WIDTH)
		self.Leader:SetWidth(16)
		self.Leader:SetHeight(16)
		self.Leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	end

	self.RaidIcon = self.overlay:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("CENTER", self, "TOP", 0, -BORDER_WIDTH)
	self.RaidIcon:SetWidth(32)
	self.RaidIcon:SetHeight(32)
	self.RaidIcon:SetTexture("Interface\\GroupFrame\\UI-RaidTargetingIcons")

	if unit == "target" then
		local buffs = CreateFrame("Frame", nil, self)
		buffs:SetPoint("BOTTOM", self, "TOP", 0, 20)
		buffs:SetHeight(20)
		buffs:SetWidth(settings.width)

		buffs.size = 20
		buffs.num = math.floor(settings.width / buffs.size + .5)
		--buffs.filter = true

		self.Buffs = buffs

		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetPoint("BOTTOM", self, "TOP", 0, 40)
		debuffs:SetHeight(20)
		debuffs:SetWidth(settings.width)

		debuffs.size = 20
		debuffs.showDebuffType = true
		debuffs.num = math.floor(settings.width / debuffs.size + .5)
		buffs.filter = true

		self.Debuffs = debuffs
	end

	if not unit then
		self.Range = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = 0.5
	end

	self.Banzai = UpdateAggro

	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightAlpha = 0.8
	self.DebuffHighlightFilter = true

	self.SetBackdropColor = SetBackdropColorToBorder

	return self
end

oUF:RegisterStyle("Phanx Player", setmetatable({
	width = 200,
	height = 25,
}, { __call = new }))

oUF:RegisterStyle("Phanx Target", setmetatable({
	width = 200,
	height = 25,
	reverse = true,
}, { __call = new }))

oUF:RegisterStyle("Phanx Target Target", setmetatable({
	width = 200,
	height = 20,
	nopower = true,
	reverse = true,
}, { __call = new }))

oUF:RegisterStyle("Phanx Party", setmetatable({
	width = 160,
	height = 25,
	reverse = true,
}, { __call = new }))

oUF:RegisterStyle("Phanx Party Pet", setmetatable({
	width = 160,
	height = 20,
	nopower = true,
	reverse = true,
}, { __call = new }))

oUF:SetActiveStyle("Phanx Player")
oUF:Spawn("player"):SetPoint("TOPRIGHT", UIParent, "CENTER", -150, -150)
oUF:Spawn("pet"):SetPoint("TOPRIGHT", oUF.units.player, "BOTTOMRIGHT", 0, 0)

oUF:SetActiveStyle("Phanx Target")
oUF:Spawn("target"):SetPoint("TOPLEFT", UIParent, "CENTER", 150, -150)

oUF:SetActiveStyle("Phanx Target Target")
oUF:Spawn("targettarget"):SetPoint("TOPLEFT", oUF.units.target, "BOTTOMLEFT", 0, 0)

oUF:SetActiveStyle("Phanx Party")
local party = oUF:Spawn("header", "oUF_Party")
party:SetPoint("BOTTOMRIGHT", oUF.units.target, "BOTTOMRIGHT", 240 + (BORDER_WIDTH * 2), 0)
party:SetManyAttributes(
	"showParty", true,
	"point", "BOTTOM",
	"sortMethod", "NAME",
	"sortDir", "DESC",
	"xOffset", 0,
	"yOffset", 45
)
party:Show()

oUF:SetActiveStyle("Phanx Party Pet")
local partypets = {}
for i = 1, 4 do
	table.insert(partypets, oUF:Spawn("partypet"..i))
	partypets[i]:SetPoint("TOPRIGHT", oUF.units["party"..i], "BOTTOMRIGHT", 0, 0)
end
--[[
local partyToggle = CreateFrame("Frame")
partyToggle:RegisterEvent("PLAYER_LOGIN")
partyToggle:RegisterEvent("PARTY_LEADER_CHANGED")
partyToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
partyToggle:RegisterEvent("RAID_ROSTER_UPDATE")
partyToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if GetNumRaidMembers() > 0 then
			party:Hide()
			for i, f in ipairs(partypets) do
				UnregisterUnitWatch("partypet"..i, f)
				f:Hide()
			end
		else
			party:Show()
			for i, f in ipairs(partypets) do
				RegisterUnitWatch("partypet"..i, f)
				f:Show()
			end
		end
	end
end)]]