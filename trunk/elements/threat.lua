--[[--------------------------------------------------------------------
	oUF_ThreatHighlight
	Highlights oUF frames by threat level.

	Simple usage:
		self.ThreatHighlight = true

	Advanced usage:
		self.ThreatHighlight = function(self, unit, status) end
----------------------------------------------------------------------]]

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
	-- print("ThreatHighlight: Update", event, unit)
	if unit and unit ~= self.unit then return end
	if not unit then unit = self.unit end

	local status = UnitThreatSituation(unit)
	-- print("UnitThreatSituation", status)

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
end

local function Disable(self)
	if not self.ThreatHighlight then return end

	self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE", Update)
end

oUF:AddElement("ThreatHighlight", Update, Enable, Disable)
