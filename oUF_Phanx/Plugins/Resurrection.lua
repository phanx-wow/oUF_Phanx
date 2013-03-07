--[[--------------------------------------------------------------------
	oUF_ResInfo
	by Phanx <addons@phanx.net>
	Adds resurrection status text to oUF frames.
	Loosely based on GridStatusRes.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	Usage

	frame.ResInfo = frame.Health:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.ResInfo:SetPoint("CENTER")

	Options

	frame.ResInfo.ignoreSoulstone = true -- NOT YET IMPLEMENTED
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_ResInfo requires oUF")

local LibResInfo = LibStub("LibResInfo-1.0", true)
assert(LibResInfo, "oUF_ResInfo requires LibResInfo-1.0")

local Update, Path, ForceUpdate, Enable, Disable

local displayText = {
	CASTING = "|cffffff00RES|r",
	PENDING = "|cff00ff00RES|r",
	SELFRES = "|cffff00ffSS|r",
}

function Update(self, event, unit)
	if unit ~= self.unit then return end
	local element = self.ResInfo

	if element.PreUpdate then
		element:PreUpdate(unit)
	end

	local status, endTime, casterUnit, casterGUID = LibStub("LibResInfo-1.0"):UnitHasIncomingRes(unit)
	local text = status and displayText[status]

	element:SetText(text)

	if element.PostUpdate then
		element:PostUpdate(unit, status, text)
	end
end

function Path(self, ...)
	return (self.ResInfo.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local element = self.ResInfo
	if not element or not element.SetText then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	return true
end

function Disable(self)
	local element = self.ResInfo
	if not element then return end

	element:Hide()

	return true
end

oUF:AddElement("ResInfo", Update, Enable, Disable)

------------------------------------------------------------------------

local function UpdateAll(event, unit, guid)
	for i = 1, #oUF.objects do
		local frame = oUF.objects[i]
		if frame.unit and frame.ResInfo then
			Update(frame, event, frame.unit)
		end
	end
end

LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResCastStarted", UpdateAll)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResCastCancelled", UpdateAll)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResPending", UpdateAll)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResUsed", UpdateAll)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResExpired", UpdateAll)