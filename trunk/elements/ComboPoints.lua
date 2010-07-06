--[[--------------------------------------------------------------------
	oUF_ComboPointsText
	Adds a textual combo points element to oUF frames.

	Direct rip of oUF's default CPoints element with minor changes to
	support font strings as oUF 1.3 and lower did. Does not support
	textures; if you want textures, use the default CPoints element.

	Usage:
		frame.ComboPoints = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
		frame.ComboPoints:SetPoint("LEFT", frame, "RIGHT", 5, 0)
----------------------------------------------------------------------]]

local GetComboPoints = GetComboPoints
local UnitExists = UnitExists

local Update = function(self, event, unit)
	if unit == "pet" then return end

	local ComboPoints = self.ComboPoints
	local cp = GetComboPoints(UnitExists("vehicle") and "vehicle" or "player", "target")

	ComboPoints:SetText(cp > 0 and cp)

	if ComboPoints.variableAlpha then
		ComboPoints:SetAlpha(cp * 0.2)
	end
end

local Enable = function(self)
	local ComboPoints = self.ComboPoints
	if ComboPoints  then
		local Update = ComboPoints.Update or Update
		self:RegisterEvent("UNIT_COMBO_POINTS", Update)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update)
		return true
	end
end

local Disable = function(self)
	local ComboPoints = self.ComboPoints
	if ComboPoints then
		local Update = ComboPoints.Update or Update
		self:UnregisterEvent("UNIT_COMBO_POINTS", Update)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update)
	end
end

oUF:AddElement("ComboPoints", Update, Enable, Disable)
