--[[--------------------------------------------------------------------
	oUF_AFK
	Based on oUF_Smurf's AFK module by Merl@chainweb.net.
	Written and distributed with permission.

	Usage:
		self.AFK = self:CreateFontString(nil, "OVERLAY")
		self.AFK:SetFont("Fonts\\ARIALN.TTF", 10)
		self.AFK:SetPoint("BOTTOM", self, "TOP")
		self.AFK:SetWidth(10)
		self.AFK:SetHeight(10)
----------------------------------------------------------------------]]

if not oUF then return end
if IsAddOnLoaded("oUF_AFK") then return end

local times = { }
local objects = { }
local updater = CreateFrame("Frame")
local lastupdate = 0

updater:Hide()
updater:SetScript("OnUpdate", function(self, elapsed)
	lastupdate = lastupdate + elapsed
	if lastupdate < 0.2 then return end

	local n = 0

	for object, unit in pairs(objects) do
		local t = times[unit]
		if t then
			t = GetTime() - t
			object:SetFormattedText("AFK %d:%02.0f", floor(t / 60), mod(t, 60))
			n = n + 1
		else
			object:SetText(nil)
			objects[object] = nil
		end
	end

	if n == 0 then
		self:Hide()
	end

	lastupdate = 0
end)

local Update = function(self, event, unit)
	if unit ~= self.unit then return end

	local afk = UnitIsAFK(unit)

	if afk then
		if not times[unit] then
			times[unit] = GetTime()
		end
		objects[self.AFK] = unit
		updater:Show()
	else
		times[unit] = nil
	end
end

local Enable = function(self)
	if not self.AFK or not self.AFK.SetFormattedText then return end

	self:RegisterEvent("PLAYER_FLAGS_CHANGED", Update)
end

local Disable = function(self)
	if not self.AFK or not self.AFK.SetFormattedText then return end

	self:UnregisterEvent("PLAYER_FLAGS_CHANGED", Update)
end

oUF:AddElement("AFK", Update, Enable, Disable)