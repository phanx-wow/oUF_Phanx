--[[--------------------------------------------------------------------
	oUF_ThreatHighlight
	Colors oUF health bars based on threat.

	To activate this functionality for your frame:

		self.ThreatHighlight = true

	To also color your frame according to the threat thresholds used in
	the default UI:

		self.ThreatHighlightLevels = true

	To handle debuff indication yourself instead of having the health
	bar colored:

		self.ThreatHighlight = function(self, unit)
			-- do stuff here
		end
	
	The current threat level of your frame's unit will be stored in
	your frame's "hasThreat" key:

		self.hasThreat = 3

----------------------------------------------------------------------]]

if not oUF then return end

------------------------------------------------------------------------

local unpack = unpack

local validUnits = { }

------------------------------------------------------------------------

local threatColors = {
	{ 1, 1, 0.47 },	-- not tanking, high threat
	{ 1, 0.6, 0 },		-- tanking, insecure threat
	{ 1, 0, 0 },		-- tanking, secure threat
}
	
------------------------------------------------------------------------

local function applyThreatHighlight(frame, event, unit, bar)
	if not validUnits[unit] then return end

	if frame.hasThreat > 0 then
		bar:SetStatusBarColor(unpack(DebuffTypeColor(type)))
		return
	end
end

------------------------------------------------------------------------

local function hook(frame)
	if frame.unit then
		if string.find(frame.unit, "target") then return end
		validUnits[frame.unit] = true
	end

	frame.hasThreat = 0

	if type(frame.DebuffHighlight) == "function" then
		return
	end

	local o = frame.PostUpdateHealth
	frame.PostUpdateHealth = function(...)
		if o then o(...) end
		if validUnits[unit] then
			applyThreatHighlight(...)
		end
	end
end
for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event, unit)
	if not validUnits[unit] then return end
	if not UnitCanAssist("player", unit) then return end
	
	local frame = oUF.units[unit]
	if not frame then return end
	
	local hasThreat
	if frame.ThreatHighlightLevels then
		hasThreat = UnitThreatSituation(unit, unit.."target")
	else
		hasThreat = UnitThreatSituation(unit)
		if hasThreat and hasThreat > 1 then
			-- 2 or 3
			hasThreat = 3
		end
	end
	if frame.hasThreat == hasThreat then return end
	
	frame.hasThreat = hasThreat
	
	if type(frame.ThreatHighlight) == "function" then
		-- print("frame.ThreatHighlight, " .. unit)
		frame:ThreatHighlight(event, unit)
	else
		-- print("applyThreatHighlight, " .. unit)
		applyThreatHighlight(frame, event, unit, frame.Health)
	end
end)

------------------------------------------------------------------------