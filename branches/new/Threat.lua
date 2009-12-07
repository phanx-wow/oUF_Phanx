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

	The current threat level of each frame's unit will be stored in
	the frame's "threatLevel" key:

		self.threatLevel = 3

----------------------------------------------------------------------]]

if not oUF then return end

------------------------------------------------------------------------

local unpack = unpack

------------------------------------------------------------------------

local threatColors = {
	{ 1, 1, 0.47 },	-- not tanking, high threat
	{ 1, 0.6, 0 },		-- tanking, insecure threat
	{ 1, 0, 0 },		-- tanking, secure threat
}

------------------------------------------------------------------------

local function applyThreatHighlight(frame, event, unit, bar)
	local threatLevel = frame.threatLevel

	if not threatLevel then return end

	if threatLevel > 0 then
		bar:SetStatusBarColor(unpack(threatColors(threatLevel)))
		return
	end
end

------------------------------------------------------------------------

local function hook(frame)
	if frame.unit and string.find(frame.unit, "target") then return end

	frame.threatLevel = 0

	if type(frame.ThreatHighlight) == "function" then
		return
	end

	local o = frame.PostUpdateHealth
	frame.PostUpdateHealth = function(...)
		if o then o(...) end
		applyThreatHighlight(...)
	end
end
for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event, unit)
	if event == "UNIT_THREAT_SITUATION_UPDATE" then
		local frame = oUF.units[unit]
		if not frame then return end
		if not frame.threatLevel then return end
		if not UnitCanAssist("player", unit) then return end

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
		if frame.threatLevel == hasThreat then return end

		frame.threatLevel = hasThreat or 0

		if type(frame.ThreatHighlight) == "function" then
			--print("frame.ThreatHighlight, " .. unit)
			frame:ThreatHighlight(event, unit)
		else
			--print("applyThreatHighlight, " .. unit)
			applyThreatHighlight(frame, event, unit, frame.Health)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		for i, frame in pairs(oUF.objects) do
			if frame:IsShown() then
				self:GetScript("OnEvent")(self, "UNIT_THREAT_SITUATION_UPDATE", frame.unit)
			end
		end
	end
end)

------------------------------------------------------------------------