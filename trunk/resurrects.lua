--[[----------------------------------------------------------------------
	oUF_ResComm
	Adds resurrection and soulstone status to oUF frames.
	Uses LibResComm-1.0. Compatible with oRA2 and CT_RaidAssist.

	Example:

	self.ResurrectionFeedback = self.Health:CreateFontString(nil, "OVERLAY")
	self.ResurrectionFeedback:SetPoint("CENTER", self.Health)
	self.ResurrectionFeedback:SetFont("Fonts\\FRIZQT__.ttf", 18, "OUTLINE")
------------------------------------------------------------------------]]

if not oUF then return end

local ResComm = LibStub and LibStub:GetLibrary("LibResComm-1.0", true)
if not ResComm then return end

------------------------------------------------------------------------

local FADE_TIME = COMBATFEEDBACK_FADEOUTTIME

local playerName = UnitName("player")

local frames = { }

------------------------------------------------------------------------

local function GetUnitFromName(name)
	local n, unit

	if playerName == name then return "player" end
	if UnitName("pet") == name then return "pet" end

	n = GetNumRaidMembers()
	if n > 0 then
		for i = 1, n do
			unit = "raid"..i
			if UnitName(unit) == name then return unit end
			unit = "raidpet"..i
			if UnitName(unit) == name then return unit end
		end
		return
	end

	n = GetNumPartyMembers()
	if n > 0 then
		for i = 1, n do
			unit = "party"..i
			if UnitName(unit) == name then return unit end
			unit = "partypet"..i
			if UnitName(unit) == name then return unit end
		end
		return
	end
end

------------------------------------------------------------------------

local fading = { }

local element = CreateFrame("Frame")
element:Hide()
element:SetScript("OnUpdate", function(self, elapsed)
	local i
	for k, v in pairs(fading) do

		i = i + 1
	end
	if i == 0 then
		self:Hide()
	end
end

------------------------------------------------------------------------

local function ResStart(event, _, _, target)
	local unit = GetUnitFromName(target)
	if not unit or not UnitIsDeadOrGhost(unit) or not frames[unit] then return end

	frames[unit].ResurrectionFeedback:SetText("Resurrecting...")
	frames[unit].ResurrectionFeedback:SetTextColor(0.2, 1, 0.2)
end

------------------------------------------------------------------------

local function ResEnd(event, _, target)
	local unit = GetUnitFromName(target)
	if not unit or not UnitIsDeadOrGhost(unit)  or not frames[unit] then return end

	frames[unit].ResurrectionFeedback:SetText()
end

------------------------------------------------------------------------

local function Expired(event, name)
	local unit = GetUnitFromName(name)
	if not unit or not UnitIsDeadOrGhost(unit)  or not frames[unit] then return end

	frames[unit].ResurrectionFeedback:SetText("Resurrected")
	frames[unit].ResurrectionFeedback:SetTextColor(1, 0.2, 0.2)

	fading[frames[unit]] = FADE_TIME
	element:Show()
end

------------------------------------------------------------------------

local function Ressed(event, name)
	local unit = GetUnitFromName(name)
	if not unit or not UnitIsDeadOrGhost(unit) or not frames[unit] then return end

	frames[unit].ResurrectionFeedback:SetText("Resurrected")
	frames[unit].ResurrectionFeedback:SetTextColor(0.2, 1, 0.2)
end

------------------------------------------------------------------------

local text = {
	["A"] = "Ankh",
	["S"] = "Soulstone",
	["T"] = "Twisting Nether",
}

local function CanRes(event, name, type)
	local unit = GetUnitFromName(name)
	if not unit or not UnitIsDeadOrGhost(unit) or not frames[unit] or frames[unit].ResurrectionFeedback.ignoreSoulstone then return end

	frames[unit].ResurrectionFeedback:SetText(text[type] or text["S"])
	frames[unit].ResurrectionFeedback:SetTextColor(0.2, 1, 0.2)
end

------------------------------------------------------------------------

local function hook(frame)
	if not frame.ResurrectionFeedback then return end
	frames[frame.unit] = frame

	do
		if not UnitIsDead(unit) then
			frame.ResurrectionFeedback:SetText()
		end
	end
end
for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

------------------------------------------------------------------------

ResComm.RegisterCallback(nil, "ResComm_ResStart", ResStart)
ResComm.RegisterCallback(nil, "ResComm_ResEnd", ResEnd)
ResComm.RegisterCallback(nil, "ResComm_Ressed", Ressed)
ResComm.RegisterCallback(nil, "ResComm_CanRes", CanRes)
ResComm.RegisterCallback(nil, "ResComm_Expired", Expired)

------------------------------------------------------------------------