--[[--------------------------------------------------------------------
	oUF_ThreatHighlight
	by Phanx <addons@phanx.net>
	Highlights oUF frames by threat level.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone module.

	Simple usage:
		frame.ThreatHighlight = frame.Health:CreateTexture(nil, "OVERLAY")
		frame.ThreatHighlight:SetAllPoints(frame.Health:GetStatusBarTexture())

	Advanced usage:
		frame.ThreatHighlight = function(self, unit, status)
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_ThreatHighlight requires oUF")

local Update, Path, ForceUpdate, Enable, Disable

function Update(self, event, unit)
	if not unit or self.unit ~= unit then return end
	local element = self.ThreatHighlight

	local status = UnitThreatSituation(unit)
	-- print("ThreatHighlight Update", event, unit, status)

	if status and status > 0 then
		if element.SetVertexColor then
			element:SetVertexColor(GetThreatStatusColor(status))
		end
		element:Show()
	else
		element:Hide()
	end
end

function Path(self, ...)
	return (self.ThreatHighlight.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local element = self.ThreatHighlight
	if not element then return end

	if type(element) == "function" then
		self.ThreatHighlight = {
			Override = element
		}
		element = self.ThreatHighlight
	elseif type(element) ~= "table" or (not element.Show and not element.Override) then
		return
	end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)

	if element.GetTexture and not element:GetTexture() then
		element:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	end

	return true
end

function Disable(self)
	local element = self.ThreatHighlight
	if not element then return end

	self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Path)

	element:Hide()
end

oUF:AddElement("ThreatHighlight", Path, Enable, Disable)