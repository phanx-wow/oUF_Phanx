--[[--------------------------------------------------------------------
	oUF_Resurrection
	by Phanx <addons@phanx.net>
	Adds resurrection status text to oUF frames.
	Loosely based on GridStatusRes.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	Usage:
		frame.Resurrection = frame.Health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.Resurrection:SetPoint("CENTER")

	Options:
		frame.Resurrection.ignoreSoulstone = true
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local LibResInfo = LibStub and LibStub("LibResInfo-1.0", true)
if not LibResInfo then return end

local displayText = {
	CASTING = "|cffffff00RES|r",
	PENDING = "|cff00ff00RES|r",
	SELFRES = "|cffff00ffSS|r",
}

------------------------------------------------------------------------

local function Update(self, event, unit)
	if not unit then return end -- frame doesn't currently have a unit (eg. nonexistent party member)

	local guid = UnitGUID(unit)
	if not guid then return end
	--print(event, unit)

	local status, endTime, casterGUID, casterUnit = LibStub("LibResInfo-1.0"):UnitHasIncomingRes(guid)
	--print(status)

	local element = self.Resurrection
	element:SetText(status and displayText[status] or nil)

	if element.PostUpdate then
		element:PostUpdate(unit, status, text)
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

------------------------------------------------------------------------

local function Enable(self)
	local element = self.Resurrection
	if not element or not element.SetText then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	return true
end

local function Disable(self)
	local element = self.Resurrection
	if not element then return end

	element:Hide()

	return true
end

oUF:AddElement("Resurrection", Update, Enable, Disable)

------------------------------------------------------------------------

local function UpdateAll(event, guid, unit)
	for _, frame in ipairs(oUF.objects) do
		if frame.Resurrection then
			Update(frame, event, frame.unit)
		end
	end
end

LibResInfo.RegisterCallback("oUF_Resurrection", "LibResInfo_ResCastStarted", UpdateAll)
LibResInfo.RegisterCallback("oUF_Resurrection", "LibResInfo_ResCastCancelled", UpdateAll)
LibResInfo.RegisterCallback("oUF_Resurrection", "LibResInfo_ResPending", UpdateAll)
LibResInfo.RegisterCallback("oUF_Resurrection", "LibResInfo_ResUsed", UpdateAll)
LibResInfo.RegisterCallback("oUF_Resurrection", "LibResInfo_ResExpired", UpdateAll)