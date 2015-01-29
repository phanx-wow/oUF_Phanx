--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2015 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
----------------------------------------------------------------------]]
-- TODO:
-- If the list is empty, hide the list and make the add panel fullwidth.
-- Enable typing a known spell name into the editbox.
-- Enable shift-clicking spell names into the editbox.
-- Enable dragging and dropping spells and items onto the editbox?

local _, ns = ...
local L = ns.L

LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(L.Auras, "oUF Phanx", function(panel)
	local title, notes = panel:CreateHeader(panel.name, L.Auras_Desc)

	local showDefaults, showAllDefaults = {}
	local auraPanel, addPanel, listPanel, scrollFrame, scrollChild, addToggle, showAll, rows

	local handleFilters = {
		[ns.auraFilterValues.FILTER_ALL] = true,
		[ns.auraFilterValues.FILTER_BY_PLAYER] = true,
		[ns.auraFilterValues.FILTER_ON_FRIEND] = true,
		[ns.auraFilterValues.FILTER_ON_PLAYER] = true,
		[ns.auraFilterValues.FILTER_DISABLE] = true,
	}

	local filterValues = {
		{ value = ns.auraFilterValues.FILTER_ALL,       text = L["AuraFilter1"] },
		{ value = ns.auraFilterValues.FILTER_BY_PLAYER, text = L["AuraFilter2"] },
		{ value = ns.auraFilterValues.FILTER_ON_FRIEND, text = L["AuraFilter3"] },
		{ value = ns.auraFilterValues.FILTER_ON_PLAYER, text = L["AuraFilter4"] },
		{ value = ns.auraFilterValues.FILTER_DISABLE,   text = L["AuraFilter0"] },
	}

	local panelBackdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, right = 4, top = 4,  bottom = 4 },
	}

	---------------------------------------------------------------------
	-- Default text to see when no sub-panel is visible:

	local infoText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	infoText:SetPoint("TOPLEFT", notes, "BOTTOM", 36, -34)
	infoText:SetPoint("BOTTOMRIGHT", -36, 34)
	infoText:SetJustifyV("TOP")
	infoText:SetText("Select an aura on the left to configure it, or click the button above to add a new aura.")

	---------------------------------------------------------------------
	-- Sub-panel for adding an aura:

	addPanel = CreateFrame("Frame", nil, panel)
	addPanel:SetPoint("TOPLEFT", notes, "BOTTOM", 8, -12)
	addPanel:SetPoint("BOTTOMRIGHT", -16, 16)
	addPanel:SetBackdrop(panelBackdrop)
	addPanel:SetBackdropColor(0, 0, 0, 0.75)
	addPanel:SetBackdropBorderColor(0.8, 0.8, 0.8)
	do
		local title, notes = panel.CreateHeader(addPanel, L.AddAura, L.AddAura_Desc)

		local addButton = CreateFrame("Button", nil, addPanel, "UIPanelButtonTemplate")
		addButton:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -24)
		addButton:SetSize(80, 24)
		addButton:SetText(OKAY)

		local addBox = panel.CreateEditBox(addPanel)
		addBox:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -23)
		addBox:SetPoint("RIGHT", addButton, "LEFT", -4, 0)
		addBox:SetSize(160, 24)
		addBox:SetAltArrowKeyMode(false)
		addBox:SetAutoFocus(false)
		addBox:SetMaxLetters(6)
		addBox:SetNumeric(true)

		local addText = addPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		addText:SetPoint("TOPLEFT", addBox, "BOTTOMLEFT", 0, -4)
		addText:SetText(" ")

		local addHelp = addPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		addHelp:SetPoint("TOP", addText, "BOTTOM", 0, -24)
		addHelp:SetPoint("LEFT", addPanel, 24, 0)
		addHelp:SetPoint("RIGHT", addPanel, -24, 0)
		addHelp:SetHeight(48)
		addHelp:SetJustifyH("CENTER")
		addHelp:SetNonSpaceWrap(true)
		addHelp:SetText(L.AddAura_Note)

		addBox:SetScript("OnTextChanged", function(self, userInput)
			if not userInput then return end

			local id = self:GetNumber()
			if id == 0 then
				addText:SetText(" ")
				addButton:Disable()
				return
			end

			local name, _, icon = GetSpellInfo(id)
			if name and icon then
				if oUFPhanxAuraConfig.customFilters[id] and oUFPhanxAuraConfig.customFilters[id] ~= ns.defaultAuras[id] then
					addText:SetText(RED_FONT_COLOR_CODE .. L.AddAura_Duplicate .. "|r")
					addButton:Disable()
				end
				addText:SetFormattedText("|T%s:0|t %s", icon, name)
				addButton:Enable()
			else
				addText:SetText(RED_FONT_COLOR_CODE .. L.AddAura_Invalid .. "|r")
				addButton:Disable()
			end
		end)

		addBox:SetScript("OnEnterPressed", function(self)
			if not addButton:IsEnabled() then return end
			local id = self:GetNumber()
			if id and id > 0 and GetSpellInfo(id) then
				if ns.defaultAuras[id] then
					showDefaults[id] = true
				elseif not oUFPhanxAuraConfig.customFilters[id] then
					oUFPhanxAuraConfig.customFilters[id] = ns.auraFilterValues.FILTER_ALL
					oUFPhanxAuraConfig.deleted[id] = nil
				end
				ns.UpdateAuraList()
				panel.refresh()
			end
		end)

		addButton:SetScript("OnClick", function()
			addBox:GetScript("OnEnterPressed")(addBox)
		end)

		addPanel:Hide()

		addPanel:SetScript("OnShow", function(self)
			addToggle:SetText(CANCEL)
			addToggle:SetShown(not scrollChild.isEmpty)

			addText:SetText("")
			addBox:SetText("")
			addBox:SetFocus()

			auraPanel:Hide()
			infoText:Hide()
		end)

		addPanel:SetScript("OnHide", function(self)
			addToggle:SetText("|TInterface\\LFGFRAME\\LFGROLE_BW:0:0:0:0:64:16:48:64:0:16:255:255:153|t " .. L.AddAura)
			addToggle:Show()

			addText:SetText("")
			addBox:SetText("")

			infoText:SetShown(not auraPanel:IsVisible())
			panel.refresh()
		end)
	end

	---------------------------------------------------------------------
	-- Sub-panel for configuring an aura:

	auraPanel = CreateFrame("Frame", nil, panel)
	auraPanel:SetPoint("TOPLEFT", notes, "BOTTOM", 8, -16)
	auraPanel:SetPoint("BOTTOMRIGHT", -16, 16)
	auraPanel:SetBackdrop(panelBackdrop)
	auraPanel:SetBackdropColor(0, 0, 0, 0.75)
	auraPanel:SetBackdropBorderColor(0.8, 0.8, 0.8)
	auraPanel:Hide()
	do
		local icon = auraPanel:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT", 16, -16)
		icon:SetSize(32, 32)
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		local name = auraPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
		name:SetPoint("RIGHT", -16, 0)
		name:SetJustifyH("LEFT")

		local filter = panel.CreateDropdown(auraPanel, "Show this aura...")
		filter:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -48)
		filter:SetWidth(200)

		local delete = CreateFrame("Button", nil, auraPanel, "UIPanelButtonTemplate")
		delete:SetPoint("TOPLEFT", filter, "BOTTOMLEFT", 0, -48)
		delete:SetWidth(200)
		delete:SetText(DELETE)

		filter:SetList(filterValues)

		local CURRENT_AURA

		function filter:OnValueChanged(value)
			local isDefault = value == ns.defaultAuras[CURRENT_AURA]
			if isDefault then
				oUFPhanxAuraConfig.customFilters[CURRENT_AURA] = nil
				showDefaults[CURRENT_AURA] = true
			else
				oUFPhanxAuraConfig.customFilters[CURRENT_AURA] = value
			end
			ns.UpdateAuraList()
		end

		delete:SetScript("OnClick", function(self)
			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide()
			end
			oUFPhanxAuraConfig.customFilters[CURRENT_AURA] = nil
			if ns.defaultAuras[CURRENT_AURA] then
				oUFPhanxAuraConfig.deleted[CURRENT_AURA] = true
			end
			ns.UpdateAuraList()
			panel.refresh()
		end)

		delete:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:SetText(L.DeleteAura_Desc)
			GameTooltip:Show()
		end)

		delete:SetScript("OnLeave", GameTooltip_Hide)

		auraPanel:SetScript("OnShow", function()
			infoText:Hide()
			addPanel:Hide()
		end)

		auraPanel:SetScript("OnHide", function()
			infoText:SetShown(not addPanel:IsVisible())
		end)

		function auraPanel:SetAura(data)
			if not data then
				CURRENT_AURA = nil
				return self:Hide()
			end

			addPanel:Hide()
			CURRENT_AURA = data.id

			local nameText, _, iconPath = GetSpellInfo(id)
			icon:SetTexture(data.icon)
			name:SetFormattedText("%s %s(%d)", data.name, GRAY_FONT_COLOR_CODE, data.id)
			filter:SetValue(data.filter)

			self:Show()
		end

		function auraPanel:GetAura()
			return CURRENT_AURA
		end
	end

	---------------------------------------------------------------------
	-- List of existing aura filters:

	listPanel = CreateFrame("Frame", nil, panel)
	listPanel:SetPoint("TOPRIGHT", notes, "BOTTOM", 0, -16)
	listPanel:SetPoint("BOTTOMLEFT", 16, 16)
	listPanel:SetBackdrop(panelBackdrop)
	listPanel:SetBackdropColor(0, 0, 0, 0)
	listPanel:SetBackdropBorderColor(0.8, 0.8, 0.8)
	do
		scrollFrame = CreateFrame("ScrollFrame", "oUFPCAuraScrollFrame", listPanel, "UIPanelScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", 4, -4)
		scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4) -- x room for scrollbar

		local scrollBar = scrollFrame.ScrollBar
		scrollBar:EnableMouseWheel(true)
		scrollBar:SetScript("OnMouseWheel", function(self, delta)
			ScrollFrameTemplate_OnMouseWheel(scrollFrame, delta)
		end)

		local barBG = scrollFrame:CreateTexture(nil, "BACKGROUND", nil, -6)
		barBG:SetPoint("TOP")
		barBG:SetPoint("RIGHT", 25, 0)
		barBG:SetPoint("BOTTOM")
		barBG:SetWidth(26)
		barBG:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
		barBG:SetTexCoord(0, 0.45, 0.1640625, 1)
		barBG:SetAlpha(0.5)

		scrollChild = CreateFrame("Frame", nil, scrollFrame)
		scrollChild:SetSize(scrollFrame:GetWidth(), 100)
		scrollFrame:SetScrollChild(scrollChild)
		scrollFrame.scrollChild = scrollChild
		scrollFrame:SetScript("OnSizeChanged", function(self)
			scrollChild:SetWidth(self:GetWidth())
		end)
	end

	---------------------------------------------------------------------

	showAll = panel:CreateCheckbox(L.ShowDefaultAuras, L.ShowDefaultAuras_Desc)
	showAll:SetPoint("TOPRIGHT", -16, -24)
	showAll.labelText:ClearAllPoints()
	showAll.labelText:SetPoint("RIGHT", showAll, "LEFT", -2, 1)
	showAll:SetHitRectInsets(-1 * min(186, max(showAll.labelText:GetStringWidth(), 100)), 0, 0, 0)

	function showAll:OnValueChanged(enable)
		showAllDefaults = enable
		panel.refresh()
	end

	---------------------------------------------------------------------

	addToggle = CreateFrame("Button", "oUFPCAuraPanelButton", panel, "UIPanelButtonTemplate")
	addToggle:SetText("|TInterface\\LFGFRAME\\LFGROLE_BW:0:0:0:0:64:16:48:64:0:16:255:255:153|t " .. L.AddAura)
	addToggle:SetPoint("TOPRIGHT", showAll, "BOTTOMRIGHT", 0, -4)
	addToggle:SetSize(160, 32)

	notes:SetPoint("RIGHT", addToggle, "LEFT", -24, 0)

	addToggle:SetScript("OnClick", function(self)
		addPanel:SetShown(not addPanel:IsShown())
	end)

	---------------------------------------------------------------------

	do
		local function Select(self)
			self.highlight:Show()
			self.name:SetFontObject(GameFontHighlight)
		end

		local function Deselect(self)
			self.highlight:Hide()
			-- TODO: custom should override default
			if ns.defaultAuras[self.id] == ns.auraFilterValues.FILTER_DISABLE or oUFPhanxAuraConfig.customFilters[self.id] == ns.auraFilterValues.FILTER_DISABLE then
				self.name:SetFontObject(GameFontDisable)
			else
				self.name:SetFontObject(GameFontNormal)
			end
		end

		local function OnHide(self)
			self.id = nil
			self.selected = nil
			self.icon:SetTexture(nil)
			self.name:SetFontObject(GameFontDisable)
			self.name:SetText("")
			self.highlight:Hide()
		end

		local function OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT")
			GameTooltip:SetSpellByID(self.id)
			GameTooltip:AddLine(format(L.SpellID, self.id), 0.5, 0.8, 1)
			GameTooltip:Show()
			if not self.selected then
				Select(self)
			end
		end

		local function OnLeave(self)
			GameTooltip:Hide()
			if not self.selected then
				Deselect(self)
			end
		end

		function scrollChild:UpdateSelection()
			local selection = auraPanel:GetAura()
			for i = 1, #rows do
				local row = rows[i]
				if selection and selection == row.id then
					row.selected = true
					Select(row)
				else
					row.selected = nil
					Deselect(row)
				end
			end
		end

		local function OnClick(self)
			local selection = auraPanel:GetAura()
			if selection and selection == self.id then
				auraPanel:SetAura()
			else
				auraPanel:SetAura(self.data)
			end
			scrollChild:UpdateSelection()
		end

		local function OnMouseWheel(self, delta)
			ScrollFrameTemplate_OnMouseWheel(scrollFrame, delta)
		end

		rows = setmetatable({}, { __index = function(t, i)
			local row = CreateFrame("Button", nil, scrollChild)
			row:SetHeight(24)
			row:SetPoint("LEFT")
			row:SetPoint("RIGHT")
			if i > 1 then
				row:SetPoint("TOP", t[i-1], "BOTTOM", 0, -1)
			else
				row:SetPoint("TOP")
			end

			row:EnableMouse(true)
			row:EnableMouseWheel(true)
			row:SetScript("OnHide",  OnHide)
			row:SetScript("OnEnter", OnEnter)
			row:SetScript("OnLeave", OnLeave)
			row:SetScript("OnClick", OnClick)
			row:SetScript("OnMouseWheel", OnMouseWheel)

			local highlight = row:CreateTexture(nil, "BACKGROUND")
			highlight:SetAllPoints(true)
			highlight:SetBlendMode("ADD")
			highlight:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
			highlight:SetVertexColor(0.2, 0.4, 0.8)
			highlight:Hide()
			row.highlight = highlight

			local icon = row:CreateTexture(nil, "ARTWORK")
			icon:SetPoint("LEFT")
			icon:SetSize(24, 24)
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			row.icon = icon

			local name = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
			row.name = name

			t[i] = row
			return row
		end })
	end

	---------------------------------------------------------------------

	-- OnShow for panel:
	local pool = {}
	local sortedAuras = {}
	local FILTER_DISABLE = ns.auraFilterValues.FILTER_DISABLE
	local sortFunc = function(a, b)
	--[[
		return a.name < b.name or (a.name == b.name and a.id < b.id)
	]]
		local a_disabled = a.filter == FILTER_DISABLE
		local b_disabled = b.filter == FILTER_DISABLE
		if a_disabled == b_disabled then
			-- sort by name, fall back to ID
			return a.name < b.name or (a.name == b.name and a.id < b.id)
		elseif a_disabled then
			-- a disabled, b not
			return false
		else
			-- b disabled, a not
			return true
		end
	end

	panel.refresh = function()
		for i = #sortedAuras, 1, -1 do
			pool[tremove(sortedAuras, i)] = true
		end

		if showAllDefaults then
			for id, filter in pairs(ns.defaultAuras) do
				local name, _, icon = GetSpellInfo(id)
				if name and icon and handleFilters[filter] then
					local aura = next(pool) or {}
					pool[aura] = nil
					aura.name = name
					aura.icon = icon
					aura.id = id
					aura.filter = filter
					tinsert(sortedAuras, aura)
				end
			end
		else
			for id in pairs(showDefaults) do
				local filter = ns.defaultAuras[id]
				local name, _, icon = GetSpellInfo(id)
				if name and icon and handleFilters[filter] then
					local aura = next(pool) or {}
					pool[aura] = nil
					aura.name = name
					aura.icon = icon
					aura.id = id
					aura.filter = filter
					tinsert(sortedAuras, aura)
				end
			end
		end

		for id, filter in pairs(oUFPhanxAuraConfig.customFilters) do
			local name, _, icon = GetSpellInfo(id)
			if name and icon and handleFilters[filter] then
				local new, aura = true
				if ns.defaultAuras[id] then
					for i = 1, #sortedAuras do
						local t = sortedAuras[i]
						if t.id == id then
							aura = t
							new = nil
						end
					end
				end
				if not aura then
					aura = next(pool) or {}
					pool[aura] = nil
				end
				aura.name = name
				aura.icon = icon
				aura.id = id
				aura.filter = filter
				if new then
					tinsert(sortedAuras, aura)
				end
			end
		end
		sort(sortedAuras, sortFunc)

		if #sortedAuras > 0 then
			local height = 0
			for i = 1, #sortedAuras do
				local aura = sortedAuras[i]
				local row = rows[i]
				row.data = aura
				row.id = aura.id
				row.name:SetText(aura.name)
				row.icon:SetTexture(aura.icon)
				if aura.filter == ns.auraFilterValues.FILTER_DISABLE then
					row.name:SetFontObject(GameFontDisable)
				else
					row.name:SetFontObject(GameFontNormal)
				end
				row:Show()
				height = height + 1 + row:GetHeight()
			end
			for i = #sortedAuras + 1, #rows do
				rows[i]:Hide()
			end
			scrollChild:SetHeight(height)
			scrollChild:UpdateSelection()
			scrollChild.isEmpty = false
			addPanel:Hide()
		else
			for i = 1, #rows do
				rows[i]:Hide()
			end
			scrollChild:SetHeight(100)
			scrollChild.isEmpty = true
			addPanel:Show()
		end

		for i = 1, #oUF.objects do
			oUF.objects[i]:UpdateAllElements("OptionsRefresh")
		end
	end

end)