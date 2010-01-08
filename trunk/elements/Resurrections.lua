--[[--------------------------------------------------------------------
	oUF_Resurrections
	Shows incoming resurrections using LibResComm-1.0.
	Based on GridStatusRes.

	Elements handled:
		.ResurrectionText (FontString)

	Optional:
		.ResurrectionIgnoreSoulstone (boolean) - do not show soulstones or other self-resurrection abilities
----------------------------------------------------------------------]]

if not oUF then return end

local ResComm = LibStub("LibResComm-1.0", true)
if not ResComm then return end

local oUF_Resurrections = { }

local displayText = {
	["RES"]    = "|cffffcc00RES|r",
	["RESSED"] = "|cff33ff00RES|r",
	["CANRES"] = "|cffcc00ffSS|r",
}

------------------------------------------------------------------------

local function Update(self, event, unit)
	if self.unit ~= unit then return end

	if self.resurrectionStatus and not UnitIsDead(unit) then
		self.resurrectionStatus = nil
		self.ResurrectionText:SetText()
	end
end

local function CheckHealth(self, event, unit)
	if self.unit ~= unit then return end

	if self.resurrectionStatus and not UnitIsDead(unit) then
		self.resurrectionStatus = nil
		Update(self, event, unit)
	end
end

local function Enable(self)
	if not self.ResurrectionText then return end

	ResComm.RegisterCallback(oUF_Resurrections, "ResComm_ResStart")
	ResComm.RegisterCallback(oUF_Resurrections, "ResComm_ResEnd")
	ResComm.RegisterCallback(oUF_Resurrections, "ResComm_Ressed")
	ResComm.RegisterCallback(oUF_Resurrections, "ResComm_ResExpired")

	if not self.ResurrectionIgnoreSoulstone then
		ResComm.RegisterCallback(oUF_Resurrections, "ResComm_CanRes")
	end

	self:RegisterEvent("UNIT_HEALTH", Update)
end

local function Disable(self)
	if not self.ResurrectionText then return end

	ResComm.UnregisterCallback(oUF_Resurrections, "ResComm_ResStart")
	ResComm.UnregisterCallback(oUF_Resurrections, "ResComm_ResEnd")
	ResComm.UnregisterCallback(oUF_Resurrections, "ResComm_Ressed")
	ResComm.UnregisterCallback(oUF_Resurrections, "ResComm_ResExpired")

	if not self.ResurrectionIgnoreSoulstone then
		ResComm.UnregisterCallback(oUF_Resurrections, "ResComm_CanRes")
	end

	self:UnregisterEvent("UNIT_HEALTH", Update)
end

oUF:AddElement("Resurrections", Update, Enable, Disable)

------------------------------------------------------------------------

local function UpdateByName(name, status)
	for unit, frame in pairs(oUF.units) do
		if UnitName(unit) == name then
			frame.resurrectionStatus = status
			if status then
				frame.ResurrectionText:SetText(displayText[status])
			else
				frame.ResurrectionText:SetText()
			end
		end
	end
end

function oUF_Resurrections:ResComm_ResStart(event, _, _, name)
	UpdateByName(name, "RES")
end

function oUF_Resurrections:ResComm_ResEnd(event, _, name)
	UpdateByName(name, nil)
end

function oUF_Resurrections:ResComm_Ressed(event, name)
	UpdateByName(name, "RESSED")
end

function oUF_Resurrections:ResComm_ResExpired(event, name)
	UpdateByName(name, nil)
end

function oUF_Resurrections:ResComm_CanRes(event, name)
	UpdateByName(name, "CANRES")
end
