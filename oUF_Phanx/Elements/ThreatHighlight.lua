--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Element to highlight oUF frames by threat level.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone module.

	Usage:
	frame.ThreatHighlight = frame.Health:CreateTexture(nil, "OVERLAY")
	frame.ThreatHighlight:SetAllPoints(true)

	Supports Override. Does not support PreUpdate/PostUpdate.
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "ThreatHighlight element requires oUF")

local Update, ForceUpdate, Enable, Disable

function Update(self, event, unit)
	if not unit or self.unit ~= unit then return end
	local element = self.ThreatHighlight

	local ok, status = pcall(UnitThreatSituation, unit)
	if not ok then return end -- WTF???
	-- print("ThreatHighlight Update", event, unit, status)

	if element.Override then
		return element:Override(status)
	end

	if status and status > 0 then
		element:SetVertexColor(GetThreatStatusColor(status))
		element:Show()
	else
		element:Hide()
	end
end

function ForceUpdate(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local element = self.ThreatHighlight
	if not element then return end

	if type(element) == "function" then
		element = { Override = element }
		self.ThreatHighlight = element
	end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)

	if element.GetTexture and not element:GetTexture() then
		element:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	end

	return true
end

function Disable(self)
	local element = self.ThreatHighlight
	if not element then return end

	self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)

	if element.Hide then
		element:Hide()
	end
end

oUF:AddElement("ThreatHighlight", Update, Enable, Disable)
