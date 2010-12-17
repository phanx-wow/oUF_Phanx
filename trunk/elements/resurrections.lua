--[[--------------------------------------------------------------------
	oUF_Resurrection
	Adds resurrection status text to oUF frames.
	Loosely based on GridStatusRes.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	Usage:
		frame.Resurrection = frame.Health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.Resurrection:SetPoint("CENTER", frame)

	Advanced Usage:
		frame.Resurrection.ignoreSoulstone = true
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local ResComm = LibStub and LibStub("LibResComm-1.0", true)
if not ResComm then return end

local text = {
	CASTING = "|cffffff00RES|r",
	FINISHED = "|cff00ff00RES|r",
	SOULSTONE = "|cffff00ffSS|r",
}

local resStatus = { }
local resTarget = { }

local Update = function(self, event, unit)
	if not unit then return end -- frame currently not used (party/partypet)

	local name, realm = UnitName(unit)
	if realm and realm ~= "" then
		name = ("%s-%s"):format(name, realm)
	end

	local status = resStatus[name]
	self.resStatus = status

	if status ~= "SOULSTONE" or not self.Resurrection.ignoreSoulstone then
		self.Resurrection:SetText(status and text[status])
	end
end

local Enable = function(self)
	if not self.Resurrection then return end

	self.Health.parent = self

	local o = self.Health.PostUpdate
	self.Health.PostUpdate = function(self, unit, min, max)
		if o then
			o(self, unit, min, max)
		end
		if min > 0 and self.parent.resStatus then
			local name, realm = UnitName(unit)
			if realm and realm ~= "" then
				name = ("%s-%s"):format(name, realm)
			end
			resStatus[name] = nil
			self.parent.Resurrection:SetText(nil)
		end
	end

	return true
end

oUF:AddElement("Resurrection", Update, Enable, Disable)

local UpdateAll = function(event)
	for _, frame in ipairs(oUF.objects) do
		if frame.Resurrection then
			Update(frame, event, frame.unit)
		end
	end
end

ResComm.RegisterCallback("oUF_Resurrection", "ResComm_ResStart", function(event, caster, _, target)
	if target and not resStatus[target] then
		resStatus[target] = "CASTING"
		UpdateAll(event)
		resTarget[caster] = target
	end
end)

ResComm.RegisterCallback("oUF_Resurrection", "ResComm_ResEnd", function(event, caster, target)
	if target and resStatus[target] == "CASTING" then
		resStatus[target] = nil
		UpdateAll(event)
		resTarget[caster] = nil
	elseif resTarget[caster] and resStatus[resTarget[caster]] == "CASTING" then
		resStatus[resTarget[caster]] = nil
		resTarget[caster] = nil
		UpdateAll(event)
	end
end)

ResComm.RegisterCallback("oUF_Resurrection", "ResComm_Ressed", function(event, target)
	if target then
		resStatus[target] = "FINISHED"
		UpdateAll(event)
	end
end)

ResComm.RegisterCallback("oUF_Resurrection", "ResComm_ResExpired", function(event, target)
	if target then
		resStatus[target] = nil
		UpdateAll(event)
	end
end)

ResComm.RegisterCallback("oUF_Resurrection", "ResComm_CanRes", function(event, target)
	if target then
		resStatus[target] = "SOULSTONE"
		UpdateAll(event)
	end
end)