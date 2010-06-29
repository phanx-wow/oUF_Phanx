--[[--------------------------------------------------------------------
	oUF_Resurrection
	by Phanx < addons@phanx.net >
	Shows incoming resurrections using LibResComm-1.0.
	Based on GridStatusRes.

	You may embed this module in your own layout, but please do not
		distribute it as a standalone plugin.

	Elements handled:
		frame.Resurrection (FontString)

	Optional:
		frame.Resurrection.ignoreSoulstone (boolean) - do not show soulstones or other self-resurrection abilities
----------------------------------------------------------------------]]

if not oUF then return end

local ResComm = LibStub("LibResComm-1.0", true)
if not ResComm then return end

local displayText = {
	["RES"]    = "|cffffcc00RES|r",
	["RESSED"] = "|cff33ff00RES|r",
	["CANRES"] = "|cffcc00ffSS|r",
}

local statusForUnit = { }

local function Update(self, event, unit)
	if self.unit ~= unit then return end

	local status = statusForUnit[unit]
	if status and UnitIsDead(unit) then
		self.Resurrection:SetText(displayText[status])
	else
		statusForUnit[unit] = nil
		self.Resurrection:SetText(nil)
	end
end

local function UpdateByName(name, status)
	for unit, frame in pairs(oUF.units) do
		if frame.Resurrection and UnitName(unit) == name then
			statusForUnit[unit] = status
			Update(frame, nil, unit)
		end
	end
end

local function ResComm_ResStart(a, b, c, d, name)
	print("ResComm_CanRes", a, b, c, d, name)
	UpdateByName(name, "RES")
end

local function ResComm_ResEnd(a, b, c, name)
	print("ResComm_CanRes", a, b, c, name)
	UpdateByName(name, nil)
end

local function ResComm_Ressed(a, b, name)
	print("ResComm_CanRes", a, b, name)
	UpdateByName(name, "RESSED")
end

local function ResComm_ResExpired(a, b, name)
	print("ResComm_CanRes", a, b, name)
	UpdateByName(name, nil)
end

local function ResComm_CanRes(a, b, name)
	print("ResComm_CanRes", a, b, name)
	UpdateByName(name, "CANRES")
end

local function Enable(self)
	if not self.Resurrection then return end

	ResComm.RegisterCallback("oUF_Resurrections", "ResComm_ResStart", ResComm_ResStart)
	ResComm.RegisterCallback("oUF_Resurrections", "ResComm_ResEnd", ResComm_ResEnd)
	ResComm.RegisterCallback("oUF_Resurrections", "ResComm_Ressed", ResComm_Ressed)
	ResComm.RegisterCallback("oUF_Resurrections", "ResComm_ResExpired", ResComm_ResExpired)

	if not self.Resurrection.ignoreSoulstone then
		ResComm.RegisterCallback("oUF_Resurrections", "ResComm_CanRes", ResComm_CanRes)
	end

	self:RegisterEvent("UNIT_HEALTH", Update)
end

local function Disable(self)
	if not self.Resurrection then return end

	ResComm.UnregisterCallback("oUF_Resurrections", "ResComm_ResStart", ResComm_ResStart)
	ResComm.UnregisterCallback("oUF_Resurrections", "ResComm_ResEnd", ResComm_ResEnd)
	ResComm.UnregisterCallback("oUF_Resurrections", "ResComm_Ressed", ResComm_Ressed)
	ResComm.UnregisterCallback("oUF_Resurrections", "ResComm_ResExpired", ResComm_ResExpired)

	if not self.Resurrection.ignoreSoulstone then
		ResComm.UnregisterCallback("oUF_Resurrections", "ResComm_CanRes", ResComm_CanRes)
	end

	self:UnregisterEvent("UNIT_HEALTH", Update)
end

oUF:AddElement("Resurrections", Update, Enable, Disable)
