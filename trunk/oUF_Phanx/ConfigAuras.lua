--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...
local L = ns.L

L.Auras = "Auras"
L.Auras_Info = "Add new buffs and debuffs to show, or change the filtering behavior of predefined ones."
L.AuraFilter0 = "Never show"
L.AuraFilter1 = "Always show"
L.AuraFilter2 = "Only show mine"
L.AuraFilter3 = "Only show on friendly units"
L.AuraFilter4 = "Only show on myself"
L.NewAura = "New Aura"
L.NewAura_Info = "Add an aura to customize."

LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel(L.Auras, "oUF Phanx", function(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L.Auras_Info)

	local add = CreateFrame("Button", "$parentAddButton", panel, "UIPanelButtonTemplate")
	add:SetText("|TInterface\\LFGFRAME\\LFGROLE_BW:0:0:0:0:64:16:48:64:0:16:255:255:153|t " .. L.NewAura)
	add:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -8)
	add:SetSize(160, 32)
	notes:SetPoint("TOPRIGHT", add, "TOPLEFT", -24, 0)
	panel.addButton = add

	local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -16)
	scrollFrame:SetPoint("BOTTOMRIGHT", -38, 16)

	local barBG = scrollFrame:CreateTexture(nil, "BACKGROUND", nil, -6)
	barBG:SetPoint("TOP")
	barBG:SetPoint("RIGHT", 25, 0)
	barBG:SetPoint("BOTTOM")
	barBG:SetWidth(26)
	barBG:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	barBG:SetTexCoord(0, 0.45, 0.1640625, 1)
	barBG:SetAlpha(0.5)
	scrollFrame.barBG = barBG

	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(scrollFrame:GetWidth(), 100)
	scrollFrame:SetScrollChild(scrollChild)
	scrollFrame.scrollChild = scrollChild
	scrollFrame:SetScript("OnSizeChanged", function(self)
		scrollChild:SetWidth(self:GetWidth())
	end)

	local scrollBG = scrollChild:CreateTexture(nil, "BACKGROUND")
	scrollBG:SetAllPoints(true)
	scrollBG:SetTexture(0, 1, 0, 0.3)

	--------------------------------------------------------------------

	-- Dialog for adding an aura:
	local dialog = CreateFrame("Frame", nil, scrollFrame)
	dialog:SetPoint("BOTTOMLEFT")
	dialog:SetPoint("TOPRIGHT", barBG)
	dialog:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Backdrop", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	dialog:SetBackdropColor(0, 0, 0, 1)
	dialog:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	panel.dialog = dialog

	local dialogTitle, dialogNotes = LibStub("PhanxConfig-Header").CreateHeader(dialog, L.NewAura, L.NewAura_Info)

	local editBox = CreateFrame("EditBox", nil, dialog, "UIPanelEditBoxTemplate")

	dialog:Hide()

	--------------------------------------------------------------------

	-- OnClick for delete button:
	local function DeleteAura(self)
		local aura = self:GetParent().aura
		oUFPhanxAuraConfig[aura] = nil
		panel.refresh()
		ns.UpdateAuraList()
	end

	-- OnEnter for icon:
	local function ShowAuraTooltip(self)
		local aura = self:GetParent().aura
		GameTooltip:SetAnchor(icon, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPRIGHT", icon, "TOPLEFT")
		GameTooltip:SetSpellByID(aura)
		GameTooltip:Show()
	end

	-- Dropdown functions:
	local CURRENT_AURA, CURRENT_DROPDOWN
	local function SetAuraFilter(info)
		oUFPhanxAuraConfig[CURRENT_AURA] = info.value
		CURRENT_DROPDOWN:SetValue(info.value, info.text)
		ns.UpdateAuraLists()
	end
	local function UpdateFilterDrop(self, level) -- self is the dropdown menu
		CURRENT_AURA = self:GetParent().aura
		CURRENT_DROPDOWN = self
		local info = UIDropDownMenu_CreateInfo()
		for i = 0, 4 do
			info.text = L["AuraFilter"..i]
			info.value = i
			info.func = SetAuraFilter
			UIDropDownMenu_AddButton(info, level)
		end
	end

	-- Rows:
	local rows = setmetatable({}, { __index = function(t, i)
		local row = CreateFrame("Frame", nil, scrollChild)
		row:SetHeight(32)
		row:SetPoint("LEFT")
		row:SetPoint("RIGHT")
		if i > 1 then
			row:SetPoint("TOP", rows[i-1], "BOTTOM", 0, -2)
		else
			row:SetPoint("TOP")
		end

		local delete = CreateFrame("Button", nil, row)
		delete:SetPoint("LEFT")
		delete:SetSize(24, 24)
		delete:SetScript("OnClick", DeleteAura)
		row.delete = delete

		local icon = CreateFrame("Button", nil, row)
		icon:SetPoint("LEFT", delete, "RIGHT", 0, 8)
		icon:SetSize(32, 32)
		icon:EnableMouse(true)
		icon:SetScript("OnEnter", ShowAuraTooltip)
		icon:SetScript("OnLeave", GameTooltip_Hide)
		row.icon = icon

		local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		name:SetPoint("LEFT", icon, "RIGHT", 0, 8)
		row.name = name

		local filters = LibStub("PhanxConfig-Dropdown").CreateDropdown(row, nil, nil, UpdateFilterDrop)
		filters:SetPoint("RIGHT")
		filters:SetWidth(200)
		row.filters = filters

		t[i] = row
		return row
	end })
	panel.rows = rows

	--------------------------------------------------------------------

	-- OnShow for panel:
	local pool = {}
	local sortedAuras = {}
	local sortFunc = function(a, b)
		return a[2] < b[2] or (a[2] == b[2] and a[1] < b[1])
	end
	panel.refresh = function()
		for i = #sortedAuras, 1, -1 do
			pool[i] = tremove(sortedAuras, i)
		end

		for aura in pairs(oUFPhanxAuraConfig) do
			local name, _, icon = GetSpellInfo(aura)
			if name and icon then
				local t = next(pool) or {}
				pool[t] = nil
				t.name = name
				t.icon = icon
				t.id = aura
				tinsert(sortedAuras, t)
			end
		end
		table.sort(sortedAuras, sortFunc)

		local height = 0
		for i, aura in ipairs(sortedAuras) do
			local row = rows[i]
			row.aura = aura[1]
			row.name:SetText(aura[2])
			row.icon:SetNormalTexture(aura[3])
			row:Show()
			height = height + row:GetHeight() + 2
		end
		for i = #sortedAuras + 1, #rows do
			row:Hide()
		end
		scrollChild:SetHeight(height)
	end

end)