--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx

	Please DO NOT upload this addon to other websites, or post modified
	versions of it. However, you are welcome to include a copy of it
	WITHOUT CHANGES in compilations posted on Curse and/or WoWInterface.
	You are also welcome to use any/all of its code in your own addon, as
	long as you do not use my name or the name of this addon ANYWHERE in
	your addon, including its name, outside of an optional attribution.
----------------------------------------------------------------------]]

local _, ns = ...
local L = ns.L

LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(L.Auras, "oUF Phanx", function(panel)
	local title, notes = panel:CreateHeader(panel.name, L.Auras_Desc)
	local showDefaults, showAllDefaults = {}

	local scrollFrame = CreateFrame("ScrollFrame", "oUFPCAuraScrollFrame", panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -16)
	scrollFrame:SetPoint("BOTTOMRIGHT", -38, 16)
	panel.ScrollFrame = scrollFrame

	scrollFrame.ScrollBar:EnableMouseWheel(true)
	scrollFrame.ScrollBar:SetScript("OnMouseWheel", function(self, delta)
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
	scrollFrame.ScrollBarBG = barBG

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(scrollFrame:GetWidth(), 100)
	scrollFrame:SetScrollChild(scrollChild)
	scrollFrame.scrollChild = scrollChild
	scrollFrame:SetScript("OnSizeChanged", function(self)
		scrollChild:SetWidth(self:GetWidth())
	end)
	scrollFrame.ScrollChild = scrollChild
--[[
	local scrollBG = scrollChild:CreateTexture(nil, "BACKGROUND")
	scrollBG:SetAllPoints(true)
	scrollBG:SetTexture(0, 1, 0, 0.1)
	scrollChild.BG = scrollBG
]]
	--------------------------------------------------------------------

	-- Dialog for adding an aura:
	local dialog = CreateFrame("Frame", nil, panel)
	dialog:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -16)
	dialog:SetPoint("BOTTOMRIGHT", -16, 16)
	dialog:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	})
	dialog:SetBackdropBorderColor(1, 0.82, 0, 0.8)
	panel.Dialog = dialog

	dialog.bg = dialog:CreateTexture(nil, "BACKGROUND")
	dialog.bg:SetPoint("BOTTOMLEFT", 3, 3)
	dialog.bg:SetPoint("TOPRIGHT", -3, -3)
	dialog.bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock", true, true)
	dialog.bg:SetHorizTile(true)
	dialog.bg:SetVertTile(true)
	dialog.bg:SetVertexColor(0.4, 0.4, 0.4, 0.8)

	dialog:Hide()
	dialog:SetScript("OnShow", function(self)
		self:GetParent().ScrollFrame:Hide()
		self.EditBox:SetText("")
		self.Text:SetText("")
		self.EditBox:SetFocus()
	end)
	dialog:SetScript("OnHide", function(self)
		self:GetParent().ScrollFrame:Show()
		self.EditBox:SetText("")
		self.Text:SetText("")
		panel.refresh()
	end)

	dialog.Title, dialog.Notes = panel.CreateHeader(dialog, L.AddAura, L.AddAura_Desc)
	dialog.Notes:SetHeight(16) -- only one line

	local dialogBox = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
	dialogBox:SetPoint("TOPLEFT", dialog.Notes, "BOTTOMLEFT", 6, -12)
	dialogBox:SetSize(160, 24)
	dialogBox:SetAltArrowKeyMode(false)
	dialogBox:SetAutoFocus(false)
	dialogBox:SetMaxLetters(6)
	dialogBox:SetNumeric(true)
	dialogBox:SetScript("OnTextChanged", function(self, userInput)
		if not userInput then return end

		local id = self:GetNumber()
		if id == 0 then
			dialog.Text:SetText("")
			dialog.Button:Disable()
			return
		end

		local name, _, icon = GetSpellInfo(id)
		if name and icon then
			if oUFPhanxAuraConfig[id] and oUFPhanxAuraConfig[id] ~= ns.defaultAuras[id] then
				dialog.Text:SetText(RED_FONT_COLOR_CODE .. L.AddAura_Duplicate .. "|r")
				dialog.Button:Disable()
			end
			dialog.Text:SetFormattedText("|T%s:0|t %s", icon, name)
			dialog.Button:Enable()
		else
			dialog.Text:SetText(RED_FONT_COLOR_CODE .. L.AddAura_Invalid .. "|r")
			dialog.Button:Disable()
		end
	end)
	dialogBox:SetScript("OnEnterPressed", function(self)
		if not dialog.Button:IsEnabled() then return end
		local id = self:GetNumber()
		if id and id > 0 and GetSpellInfo(id) then
			if ns.defaultAuras[id] then
				showDefaults[id] = true
			elseif not oUFPhanxConfig[id] then
				oUFPhanxAuraConfig[id] = ns.auraFilterValues.ALL
			end
			ns.UpdateAuraList()
			panel.refresh()
		end
	end)
	dialog.EditBox = dialogBox

	local dialogButton = CreateFrame("Button", "oUFPCAuraAddButton", dialog, "UIPanelButtonTemplate")
	dialogButton:SetPoint("LEFT", dialogBox, "RIGHT", 12, 0)
	dialogButton:SetWidth(80)
	dialogButton:SetText(OKAY)
	dialogButton:SetScript("OnClick", function()
		dialogBox:GetScript("OnEnterPressed")(dialogBox)
	end)
	dialog.Button = dialogButton

	local dialogText = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	dialogText:SetPoint("LEFT", dialogButton, "RIGHT", 12, 0)
	dialogText:SetPoint("RIGHT", dialog, -16, 0)
	dialogText:SetJustifyH("LEFT")
	dialogText:SetJustifyV("TOP")
	dialogText:SetText("")
	dialog.Text = dialogText

	local dialogHelp = dialog:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	dialogHelp:SetPoint("TOPLEFT", dialogBox, "BOTTOMLEFT", -6, -16)
	dialogHelp:SetPoint("RIGHT", dialog, -16, 0)
	dialogHelp:SetHeight(32)
	dialogHelp:SetJustifyH("LEFT")
	dialogHelp:SetJustifyV("TOP")
	dialogHelp:SetNonSpaceWrap(true)
	dialogHelp:SetText(L.AddAura_Note)
	dialog.HelpText = dialogHelp

	--------------------------------------------------------------------

	local add = CreateFrame("Button", "oUFPCAuraPanelButton", panel, "UIPanelButtonTemplate")
	add:SetText("|TInterface\\LFGFRAME\\LFGROLE_BW:0:0:0:0:64:16:48:64:0:16:255:255:153|t " .. L.AddAura)
	add:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -8)
	add:SetSize(160, 32)
	notes:SetPoint("TOPRIGHT", add, "TOPLEFT", -24, 0)
	panel.AddButton = add
	add:SetScript("OnClick", function(self)
		if dialog:IsShown() then
			dialog:Hide()
			self:SetText("|TInterface\\LFGFRAME\\LFGROLE_BW:0:0:0:0:64:16:48:64:0:16:255:255:153|t " .. L.AddAura)
		else
			dialog:Show()
			self:SetText(CANCEL)
		end
	end)

	local showAll = panel:CreateCheckbox(L.ShowDefaultAuras, L.ShowDefaultAuras_Desc)
	showAll:SetPoint("BOTTOMRIGHT", add, "TOPRIGHT", 4, 5)
	showAll.labelText:ClearAllPoints()
	showAll.labelText:SetPoint("RIGHT", showAll, "LEFT", -2, 1)
	showAll:SetHitRectInsets(-1 * min(186, max(showAll.labelText:GetStringWidth(), 100)), 0, 0, 0)
	function showAll:OnValueChanged(enable)
		showAllDefaults = enable
		panel.refresh()
	end

	--------------------------------------------------------------------

	local function Row_OnEnter(self)
		self.name:SetTextColor(1, 1, 1)
		self.highlight:Show()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT")
		GameTooltip:SetSpellByID(self.id)
		GameTooltip:Show()
	end
	local function Row_OnLeave(self)
		self.name:SetTextColor(1, 0.82, 0)
		self.highlight:Hide()
		GameTooltip:Hide()
	end
	local function Row_OnHide(self)
		self.id = 0
		self.icon:SetTexture(nil)
		self.name:SetText("")
		self.filter.valueText:SetText("")
	end

	-- Delete button functions:
	local function Delete_OnClick(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
		local id = self:GetParent().id
		oUFPhanxAuraConfig[id] = nil
		panel.refresh()
		ns.UpdateAuraList()
	end
	local function Delete_OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(L.DeleteAura_Desc)
		--[[
		GameTooltip:SetText(L.DeleteAura)
		GameTooltip:AddLine(L.DeleteAura_Desc)
		]]
		GameTooltip:Show()
	end

	-- Filter dropdown functions:
	local CURRENT_AURA, CURRENT_DROPDOWN
	local filterValues = {
		{ value = ns.auraFilterValues.ALL,       text = L["AuraFilter1"] },
		{ value = ns.auraFilterValues.BY_PLAYER, text = L["AuraFilter2"] },
		{ value = ns.auraFilterValues.ON_FRIEND, text = L["AuraFilter3"] },
		{ value = ns.auraFilterValues.ON_PLAYER, text = L["AuraFilter4"] },
		{ value = ns.auraFilterValues.DISABLE,   text = L["AuraFilter0"] },
	}
	local function Filter_Callback(self, value)
		oUFPhanxAuraConfig[CURRENT_AURA] = value
		ns.UpdateAuraList()
	end
	local function Filter_OnEnter(self)
		Row_OnEnter(self:GetParent())
	end
	local function Filter_OnLeave(self)
		Row_OnLeave(self:GetParent())
	end

	-- Rows:
	local rows = setmetatable({}, { __index = function(t, i)
		local row = CreateFrame("Frame", nil, scrollChild)
		row:SetHeight(40)
		row:SetPoint("LEFT")
		row:SetPoint("RIGHT")
		if i > 1 then
			row:SetPoint("TOP", t[i-1], "BOTTOM", 0, -4)
		else
			row:SetPoint("TOP")
		end

		row:EnableMouse(true)
		row:SetScript("OnEnter", Row_OnEnter)
		row:SetScript("OnLeave", Row_OnLeave)

		row:EnableMouseWheel(true)
		row:SetScript("OnMouseWheel", function(self, delta)
			ScrollFrameTemplate_OnMouseWheel(scrollFrame, delta)
		end)

		local highlight = row:CreateTexture(nil, "BACKGROUND")
		highlight:SetAllPoints(true)
		highlight:SetBlendMode("ADD")
		highlight:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
		highlight:SetVertexColor(0.2, 0.4, 0.8)
		highlight:Hide()
		row.highlight = highlight

		local delete = CreateFrame("Button", "oUFPCAuraDelete"..i, row, "UIPanelCloseButton")
		delete:SetPoint("LEFT", -2, -1)
		delete:SetSize(32, 32)
		delete:SetScript("OnClick", Delete_OnClick)
		delete:SetScript("OnEnter", Delete_OnEnter)
		delete:SetScript("OnLeave", GameTooltip_Hide)
		row.delete = delete

		local icon = row:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("LEFT", delete, "RIGHT", 2, 0)
		icon:SetSize(32, 32)
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		row.icon = icon

		local name = row:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
		row.name = name

		local filter = panel.CreateDropdown(row, nil, nil, filterValues)
		filter:SetPoint("RIGHT", 0, 5)
		filter:SetWidth(200)
		filter.OnEnter = Filter_OnEnter
		filter.OnLeave = Filter_OnLeave
		filter.OnValueChanged = Filter_OnValueChanged
		row.filter = filter

		t[i] = row
		return row
	end })
	panel.rows = rows

	--------------------------------------------------------------------

	-- OnShow for panel:
	local pool = {}
	local sortedAuras = {}
	local sortFunc = function(a, b)
		return a.name < b.name or (a.name == b.name and a.id < b.id)
	end
	panel.refresh = function()
		for i = #sortedAuras, 1, -1 do
			pool[tremove(sortedAuras, i)] = true
		end

		for id, filter in pairs(oUFPhanxAuraConfig) do
			local name, _, icon = GetSpellInfo(id)
			if name and icon and (showAllDefaults or showDefaults[id] or filter ~= ns.defaultAuras[id]) then
				local aura = next(pool) or {}
				pool[aura] = nil
				aura.name = name
				aura.icon = icon
				aura.id = id
				aura.filter = filter
				tinsert(sortedAuras, aura)
			end
		end
		table.sort(sortedAuras, sortFunc)

		if #sortedAuras > 0 then
			local height = 0
			for i = 1, #sortedAuras do
				local aura = sortedAuras[i]
				local row = rows[i]
				row.id = aura.id
				row.name:SetText(aura.name)
				row.icon:SetTexture(aura.icon)
				row.filter:SetValue(aura.filter)
				row:Show()
				height = height + 4 + row:GetHeight()
			end
			for i = #sortedAuras + 1, #rows do
				rows[i]:Hide()
			end
			scrollChild:SetHeight(height)
			dialog:Hide()
			add:Show()
		else
			for i = 1, #rows do
				rows[i]:Hide()
			end
			scrollChild:SetHeight(100)
			dialog:Show()
			add:Hide()
		end

		for i = 1, #oUF.objects do
			oUF.objects[i]:UpdateAllElements("OptionsRefresh")
		end
	end

end)