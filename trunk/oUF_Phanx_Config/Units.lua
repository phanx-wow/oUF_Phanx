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
local L = ns.L

local unitLabel = {
	player = L.Unit_Player,
	pet = L.Unit_Pet,
	target = L.Unit_Target,
	targettarget = L.Unit_TargetTarget,
	focus = L.Unit_Focus,
	focustarget = L.Unit_FocusTarget,
	party = L.Unit_Party,
	partypet = L.Unit_PartyPet,
	boss = L.Unit_Boss,
	arena = L.Unit_Arena,
	arenapet = L.Unit_ArenaPet,
}

local unitType = {
	player = "single",
	pet = "single",
	target = "single",
	targettarget = "single",
	focus = "single",
	focustarget = "single",
	party = "group",
	partypet = "group",
	boss = { "boss1", "boss2", "boss3", "boss4" },
	arena = { "arena1", "arena2", "arena3", "arena4", "arena5" },
	arenapet = { "arenapet1", "arenapet2", "arenapet3", "arenapet4", "arenapet5" },
}

local function GetUnitConfig(unit, key)
	local children = unitType[unit]
	if type(children) == "table" then
		return oUFPhanxUnitConfig[children[1]][key]
	else
		return oUFPhanxUnitConfig[unit][key]
	end
end

local function SetUnitConfig(unit, key, value)
	--print("SetUnitConfig", unit, key, type(value), tostring(value))
	local children = unitType[unit]
	if type(children) == "table" then
		for i = 1, #children do
			oUFPhanxUnitConfig[children[i]][key] = value
		end
	else
		oUFPhanxUnitConfig[unit][key] = value
	end
end

------------------------------------------------------------------------

LibStub("PhanxConfig-OptionsPanel"):New(L.UnitSettings, "oUF Phanx", function(panel)
	local title, notes = panel:CreateHeader(panel.name, L.UnitSettings_Desc .. "\n" .. L.MoreSettings_Desc)

	---------------------------------------------------------------------

	local unitList = CreateFrame("Frame", nil, panel)
	unitList:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -16)
	unitList:SetPoint("BOTTOMLEFT", 16, 16)
	unitList:SetWidth(150)

	local AddUnit
	do
		local function OnEnter(self)
			if panel.selectedUnit ~= self.unit then
				self.highlight:Show()
			end
		end

		local function OnLeave(self)
			if panel.selectedUnit ~= self.unit then
				self.highlight:Hide()
			end
		end

		local function OnClick(self)
			panel:SetSelectedUnit(self.unit)
		end

		function AddUnit(unit, text)
			local button = CreateFrame("Button", nil, unitList)
			button:SetHeight(20)
			if #unitList > 0 then
				button:SetPoint("TOPLEFT", unitList[#unitList], "BOTTOMLEFT")
				button:SetPoint("TOPRIGHT", unitList[#unitList], "BOTTOMRIGHT")
			else
				button:SetPoint("TOPLEFT")
				button:SetPoint("TOPRIGHT")
			end

			button:EnableMouse(true)
			button:SetScript("OnEnter", OnEnter)
			button:SetScript("OnLeave", OnLeave)
			button:SetScript("OnClick", OnClick)

			local highlight = button:CreateTexture(nil, "BACKGROUND")
			highlight:SetAllPoints(true)
			highlight:SetBlendMode("ADD")
			highlight:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
			highlight:SetVertexColor(0.2, 0.4, 0.8)
			highlight:Hide()
			button.highlight = highlight

			local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetPoint("LEFT")
			label:SetPoint("RIGHT")
			label:SetJustifyH("LEFT")
			label:SetText(text or unitLabel[unit])
			button.label = label

			button.unit = unit
			unitList[#unitList+1] = button
			return button
		end
	end

	AddUnit("player")
	AddUnit("pet")
	AddUnit("target")
	AddUnit("targettarget")
	AddUnit("focus")
	AddUnit("focustarget")
	AddUnit("party")
	AddUnit("partypet")
	AddUnit("boss")
	AddUnit("arena")
	AddUnit("arenapet")
	AddUnit("global", L.Unit_Global) -- TODO: localize

	---------------------------------------------------------------------

	local unitSettings = CreateFrame("Frame", nil, panel)
	unitSettings:SetPoint("TOPLEFT", unitList, "TOPRIGHT", 12, 0)
	unitSettings:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -12)
	unitSettings:SetPoint("BOTTOMRIGHT", -15, 15)
	unitSettings:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
	unitSettings:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	unitSettings:Hide()

	local unitTitle = panel.CreateHeader(unitSettings, UNKNOWN)

	local enable = panel.CreateCheckbox(unitSettings, L.EnableUnit, L.EnableUnit_Desc)
	enable:SetPoint("TOPLEFT", unitTitle, "BOTTOMLEFT", 0, -12)
	function enable:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "disable", not value)
	end

	local power = panel.CreateCheckbox(unitSettings, L.Power, L.Power_Desc)
	power:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -12)
	function power:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "power", value)
	end

	local castbar = panel.CreateCheckbox(unitSettings, L.Castbar, L.Castbar_Desc)
	castbar:SetPoint("TOPLEFT", power, "BOTTOMLEFT", 0, -12)
	function castbar:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "castbar", value)
	end

	local combatText = panel.CreateCheckbox(unitSettings, L.CombatText, L.CombatText_Desc)
	combatText:SetPoint("TOPLEFT", castbar, "BOTTOMLEFT", 0, -12)
	function combatText:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "combatText", value)
	end

	local classHeader = unitSettings:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	classHeader:SetPoint("TOPLEFT", combatText, "BOTTOMLEFT", 0, -24)
	do
		local offset, left, right, bottom, top = 0.025, unpack(CLASS_BUTTONS[playerClass])
		local classIcon = format([[|TInterface\Glues\CharacterCreate\UI-CharacterCreate-Classes:14:14:0:0:256:256:%s:%s:%s:%s|t]], (left + offset) * 256, (right - offset) * 256, (bottom + offset) * 256, (top - offset) * 256)
		classHeader:SetFormattedText("%s |c%s%s|r", classIcon, (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[playerClass].colorStr, format(L.ClassFeatures, UnitClass("player")))
	end

	local classFeatures = {}

	if playerClass == "DEATHKNIGHT" then

		local runeBars = panel.CreateCheckbox(unitSettings, L.RuneBars, L.RuneBars_Desc)
		runeBars:SetPoint("TOPLEFT", classHeader, "BOTTOMLEFT", 0, -12)
		function runeBars:OnValueChanged(value)
			oUFPhanxConfig.runeBars = value
		end
		runeBars.checkedKey = "runeBars"
		tinsert(classFeatures, runeBars)

	elseif playerClass == "DRUID" then

		local druidMana = panel.CreateCheckbox(unitSettings, L.DruidManaBar, L.DruidManaBar_Desc)
		druidMana:SetPoint("TOPLEFT", classHeader, "BOTTOMLEFT", 0, -12)
		function druidMana:OnValueChanged(value)
			oUFPhanxConfig.druidMana = value
		end
		druidMana.checkedKey = "druidMana"
		tinsert(classFeatures, druidMana)

		local eclipseBar = panel.CreateCheckbox(unitSettings, L.EclipseBar, L.EclipseBar_Desc)
		eclipseBar:SetPoint("TOPLEFT", druidMana, "BOTTOMLEFT", 0, -12)
		function eclipseBar:OnValueChanged(value)
			oUFPhanxConfig.eclipseBar = value
			EclipseBarIcons:SetEnabled(value)
		end
		eclipseBar.checkedKey = "eclipseBar"
		tinsert(classFeatures, eclipseBar)

		local eclipseBarIcons = panel.CreateCheckbox(unitSettings, L.EclipseBarIcons, L.EclipseBarIcons_Desc)
		eclipseBarIcons:SetPoint("TOPLEFT", eclipseBar, "BOTTOMLEFT", 0, -12)
		function eclipseBarIcons:OnValueChanged(value)
			oUFPhanxConfig.eclipseBarIcons = value
		end
		eclipseBarIcons.checkedKey = "eclipseBarIcons"
		eclipseBarIcons.enabledKey = "eclipseBar"
		tinsert(classFeatures, eclipseBarIcons)

	elseif playerClass == "MONK" then

		local staggerBar = panel.CreateCheckbox(unitSettings, L.StaggerBar, L.StaggerBar_Desc)
		staggerBar:SetPoint("TOPLEFT", classHeader, "BOTTOMLEFT", 0, -12)
		function staggerBar:OnValueChanged(value)
			oUFPhanxConfig.staggerBar = value
		end
		staggerBar.checkedKey = "staggerBar"
		tinsert(classFeatures, staggerBar)

	elseif playerClass == "SHAMAN" then

		local totemBars = panel.CreateCheckbox(unitSettings, L.TotemBars, L.TotemBars_Desc)
		totemBars:SetPoint("TOPLEFT", classHeader, "BOTTOMLEFT", 0, -12)
		function totemBars:OnValueChanged(value)
			oUFPhanxConfig.totemBars = value
		end
		totemBars.checkedKey = "totemBars"
		tinsert(classFeatures, totemBars)

	end

	---------------------------------------------------------------------

	local width = panel.CreateSlider(unitSettings, L.Width, L.Width_Desc, 0.25, 2, 0.05, true)
	width:SetPoint("TOPLEFT", unitTitle, "BOTTOM", 8, -16)
	width:SetPoint("TOPRIGHT", unitTitle, "BOTTOMRIGHT", 0, -16)
	function width:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "width", value)
	end

	local height = panel.CreateSlider(unitSettings, L.Height, L.Height_Desc, 0.25, 2, 0.05, true)
	height:SetPoint("TOPLEFT", width, "BOTTOMLEFT", 0, -24)
	height:SetPoint("TOPRIGHT", width, "BOTTOMRIGHT", 0, -24)
	function height:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "height", value)
	end

	---------------------------------------------------------------------

	local globalSettings = CreateFrame("Frame", nil, panel)
	globalSettings:SetPoint("TOPLEFT", unitList, "TOPRIGHT", 12, 0)
	globalSettings:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -12)
	globalSettings:SetPoint("BOTTOMRIGHT", -15, 15)
	globalSettings:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
	globalSettings:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

	local globalTitle = panel.CreateHeader(globalSettings, L.Unit_Global) -- TODO: localize

	local frameWidth = panel.CreateSlider(globalSettings, L.FrameWidth, L.FrameWidth_Desc, 100, 400, 20)
	frameWidth:SetPoint("TOPLEFT", globalTitle, "BOTTOMLEFT", -4, -16)
	frameWidth:SetPoint("TOPRIGHT", globalTitle, "BOTTOM", -8, -16)
	function frameWidth:OnValueChanged(value)
		oUFPhanxConfig.width = value
	end

	local frameHeight = panel.CreateSlider(globalSettings, L.FrameHeight, L.FrameHeight_Desc, 10, 60, 5)
	frameHeight:SetPoint("TOPLEFT", frameWidth, "BOTTOMLEFT", 0, -24)
	frameHeight:SetPoint("TOPRIGHT", frameWidth, "BOTTOMRIGHT", 0, -24)
	function frameHeight:OnValueChanged(value)
		oUFPhanxConfig.height = value
	end

	local powerHeight = panel.CreateSlider(globalSettings, L.PowerHeight, L.PowerHeight_Desc, 0.1, 0.5, 0.05, true)
	powerHeight:SetPoint("TOPLEFT", frameHeight, "BOTTOMLEFT", 0, -24)
	powerHeight:SetPoint("TOPRIGHT", frameHeight, "BOTTOMRIGHT", 0, -24)
	function powerHeight:OnValueChanged(value)
		oUFPhanxConfig.powerHeight = value
	end

	---------------------------------------------------------------------

	local reload = CreateFrame("Button", "oUFPhanxOptionsUnitsReloadButton", panel, "UIPanelButtonTemplate")
	reload:SetPoint("BOTTOMLEFT", 16, 16)
	reload:SetSize(150, 22)
	reload:SetText(L.ReloadUI)
	reload:Disable()
	reload:SetMotionScriptsWhileDisabled(true)
	reload:SetScript("OnEnter", function(self) self:Enable() end)
	reload:SetScript("OnLeave", function(self) self:Disable() end)
	reload:SetScript("OnClick", ReloadUI)

	---------------------------------------------------------------------

	function panel:SetSelectedUnit(unit)
		if not unit or (unit ~= "global" and not unitType[unit]) then
			unit = "global"
		end
		panel.selectedUnit = unit
		panel:refresh()
	end

	function panel:refresh()
		--print("unit panel refresh", self.selectedUnit)

		local unit = self.selectedUnit
		if not unit then
			return self:SetSelectedUnit("player")
		end

		for i = 1, #unitList do
			local button = unitList[i]
			if button.unit == unit then
				button.highlight:Show()
				button.label:SetFontObject(GameFontHighlight)
			else
				button.highlight:SetShown(button:IsMouseOver())
				button.label:SetFontObject(GameFontNormal)
			end
		end

		if unit == "global" then
			unitSettings:Hide()
			globalSettings:Show()

			frameWidth:SetValue(oUFPhanxConfig.width)
			frameHeight:SetValue(oUFPhanxConfig.height)
			powerHeight:SetValue(oUFPhanxConfig.powerHeight)
		else
			globalSettings:Hide()
			unitSettings:Show()

			unitTitle:SetText(unitLabel[unit])

		   enable:SetValue(not GetUnitConfig(unit, "disable"))
			power:SetValue(GetUnitConfig(unit, "power"))
			castbar:SetValue(GetUnitConfig(unit, "castbar"))
			combatText:SetValue(GetUnitConfig(unit, "combatText"))

			width:SetValue(GetUnitConfig(unit, "width") or 1)
			height:SetValue(GetUnitConfig(unit, "height") or 1)

			if unit == "player" then
				classHeader:SetShown(#classFeatures > 0)
				for i = 1, #classFeatures do
					local box = classFeatures[i]
					box:Show()
					box:SetChecked(oUFPhanxConfig[box.checkedKey])
					if box.enabledKey then
						box:SetEnabled(oUFPhanxConfig[box.enabledKey])
					end
				end
			else
				classHeader:Hide()
				for i = 1, #classFeatures do
					classFeatures[i]:Hide()
				end
			end
		end
	end
end)

------------------------------------------------------------------------

local LAP = LibStub("LibAboutPanel", true)
if LAP then
	LAP.new("oUF Phanx", "oUF_Phanx")
end