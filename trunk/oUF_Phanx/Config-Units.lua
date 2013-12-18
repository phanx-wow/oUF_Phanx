--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local _, playerClass = UnitClass("player")
local L = ns.L

L.UnitSettings = "Units"
-- Einheiten
L.UnitSettings_Desc = "Change settings for individual unit frames."
-- Einstellungen der einzelnen Einheitfenster ändern.
L.Unit_Player = "Player"
-- Spieler
L.Unit_Pet = "Pet"
-- Haustier
L.Unit_Target = "Target"
-- Ziel
L.Unit_TargetTarget = "Target of Target"
L.Unit_Focus = "Focus"
L.Unit_FocusTarget = "Target of Focus"
L.Unit_Party = "Party"
-- Gruppe
L.Unit_PartyPet = "Party Pets"
-- Gruppenhaustiere
L.Unit_Boss = "Bosses"
L.Unit_Arena = "Arena Enemies"
L.Unit_ArenaPet = "Arena Pets"
L.EnableUnit = "Enable"
-- Aktivieren
L.EnableUnit_Desc = "You can disable the oUF Phanx frame for this unit if you prefer to use the frame provided by the default UI or another addon."
-- Das Fenster dieser Einheit von oUF Phanx könnt Ihr deaktivieren, wann Ihr vorzieht, um das Fenster von den Standard-UI oder ein anderen Addon verwenden.
L.Width = "Width"
L.Width_Desc = "Set the width of this unit's frame relative to the layout's base width."
L.Height = "Height"
L.Height_Desc = "Set the height of this unit's frame relative to the layout's base height."
L.Power = "Show power bar"
L.Power_Desc = "Show a power bar on the frame for this unit."
L.Castbar = "Show cast bar"
L.Castbar_Desc = "Show a cast bar on the frame for this unit."

L.CombatText_Desc = "Show combat feedback text on the frame for this unit."

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
		return ns.uconfig[children[1]][key]
	else
		return ns.uconfig[unit][key]
	end
end

local function SetUnitConfig(unit, key, value)
	--print("SetUnitConfig", unit, key, type(value), tostring(value))
	local children = unitType[unit]
	if type(children) == "table" then
		for i = 1, #children do
			ns.uconfig[children[i]][key] = value
		end
	else
		ns.uconfig[unit][key] = value
	end
end

------------------------------------------------------------------------

LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(L.UnitSettings, "oUF Phanx", function(panel)
	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateSlider = LibStub("PhanxConfig-Slider").CreateSlider

	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L.UnitSettings_Desc .. "\n" .. L.MoreSettings_Desc)

	--------------------------------------------------------------------

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

		function AddUnit(unit)
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
			label:SetText(unitLabel[unit])
			button.label = label

			button.unit = unit
			unitList[#unitList+1] = button
			return button
		end
	end

	AddUnit("player", L.UnitPlayer)
	AddUnit("pet", L.UnitPet)
	AddUnit("target", L.UnitTarget)
	AddUnit("targettarget", L.UnitTargetTarget)
	AddUnit("focus", L.UnitFocus)
	AddUnit("focustarget", L.UnitFocusTarget)
	AddUnit("party", L.UnitParty)
	AddUnit("partypet", L.UnitPartyPet)
	AddUnit("boss", L.UnitBoss)
	AddUnit("arena", L.UnitArena)
	AddUnit("arenapet", L.UnitArenaPet)

	--------------------------------------------------------------------

	local unitSettings = CreateFrame("Frame", nil, panel)
	unitSettings:SetPoint("TOPLEFT", unitList, "TOPRIGHT", 12, 0)
	unitSettings:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -12)
	unitSettings:SetPoint("BOTTOMRIGHT", -15, 15)
	unitSettings:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
	unitSettings:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

	local unitTitle = LibStub("PhanxConfig-Header").CreateHeader(unitSettings, UNKNOWN)

	local enable = CreateCheckbox(unitSettings, L.EnableUnit, L.EnableUnit_Desc)
	enable:SetPoint("TOPLEFT", unitTitle, "BOTTOMLEFT", 0, -12)
	function enable:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "disable", not value or nil)
	end

	local power = CreateCheckbox(unitSettings, L.Power, L.Power_Desc)
	power:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -12)
	function power:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "power", value or nil)
	end

	local castbar = CreateCheckbox(unitSettings, L.Castbar, L.Castbar_Desc)
	castbar:SetPoint("TOPLEFT", power, "BOTTOMLEFT", 0, -12)
	function castbar:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "castbar", value or nil)
	end

	local combatText = CreateCheckbox(unitSettings, L.CombatText, L.CombatText_Desc)
	combatText:SetPoint("TOPLEFT", castbar, "BOTTOMLEFT", 0, -12)
	function combatText:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "combatText", value or nil)
	end


	local width = CreateSlider(unitSettings, L.Width, L.Width_Desc, 0.25, 2, 0.05, true)
	width:SetPoint("TOPLEFT", unitTitle, "BOTTOM", 8, -16)
	width:SetPoint("TOPRIGHT", unitTitle, "BOTTOMRIGHT", 0, -16)
	function width:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "width", value ~= 1 and value or nil)
	end

	local height = CreateSlider(unitSettings, L.Height, L.Height_Desc, 0.25, 2, 0.05, true)
	height:SetPoint("TOPLEFT", width, "BOTTOMLEFT", 0, -24)
	height:SetPoint("TOPRIGHT", width, "BOTTOMRIGHT", 0, -24)
	function height:OnValueChanged(value)
		SetUnitConfig(panel.selectedUnit, "height", value ~= 1 and value or nil)
	end

	--------------------------------------------------------------------

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
		if not unit or not unitType[unit] then
			unit = "player"
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

		 unitTitle:SetText(unitLabel[unit])

		    enable:SetValue(not GetUnitConfig(unit, "disable"))
		     power:SetValue(GetUnitConfig(unit, "power"))
		   castbar:SetValue(GetUnitConfig(unit, "castbar"))
		combatText:SetValue(GetUnitConfig(unit, "combatText"))

		     width:SetValue(GetUnitConfig(unit, "width") or 1)
		    height:SetValue(GetUnitConfig(unit, "height") or 1)
	end
end)