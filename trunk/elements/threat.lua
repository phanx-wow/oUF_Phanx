--[[--------------------------------------------------------------------
	oUF_ThreatHighlight
	Highlights oUF frames by threat level.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone module.

	Simple usage:
		self.ThreatHighlight = true

	Advanced usage:
		self.ThreatHighlight = function(self, unit, status) end
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local unitThreatStatus = { }

local function applyThreatHighlight(self, unit)
	local status = unitThreatStatus[unit]
	if status then
		local r, g, b = GetThreatStatusColor(status)
		self:SetStatusBarColor(r, g, b)
	end
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end

	local status = UnitThreatSituation(unit)
	-- local status = UnitIsFriend(unit, "player") and UnitThreatSituation(unit) or UnitThreatSituation("player", unit)
	-- print("ThreatHighlight Update", event, unit, status)

	if status and status > 0 then
		if type(self.ThreatHighlight) == "function" then
			self.ThreatHighlight(self, unit, status)
		else
			unitThreatStatus[unit] = status
			applyThreatHighlight(self.Health, unit)
		end
	elseif type(self.ThreatHighlight) == "function" then
		self.ThreatHighlight(self, unit, 0)
	end
end

local function Enable(self)
	if not self.ThreatHighlight then return end

	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)

	if type(self.ThreatHighlight) ~= "function" then
		local o = self.Health.PostUpdate
		self.Health.PostUpdate = function(...)
			if o then o(...) end
			applyThreatHighlight(...)
		end
	end

	return true
end

local function Disable(self)
	if not self.ThreatHighlight then return end

	self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)
end

oUF:AddElement("ThreatHighlight", Update, Enable, Disable)