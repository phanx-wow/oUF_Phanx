--[[--------------------------------------------------------------------
	oUF_Resurrection
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

local ResComm = LibStub and LibStub("LibResComm-1.0", true)
if not ResComm then return end

local displayText = {
	CASTING = "|cffffff00RES|r",
	FINISHED = "|cff00ff00RES|r",
	SOULSTONE = "|cffff00ffSS|r",
}

------------------------------------------------------------------------

local resTarget = { }
local resStatus = { }
local unitName = { }

local UNIT_HEALTH
function UNIT_HEALTH( self, event, unit )
	if unit ~= self.unit then return end

	local name = unitName[ unit ]
	if name and not UnitIsDead( unit ) then
		unitName[ unit ] = nil
		resStatus[ name ] = nil
		self.Resurrection:SetText( nil )
		self:UnregisterEvent( "UNIT_HEALTH", UNIT_HEALTH )
	end
end

local Update = function( self, event, unit )
	if not unit then return end -- frame doesn't currently have a unit (eg. nonexistent party member)
	-- print( "Resurrection Update", unit )
	local element = self.Resurrection

	local name, realm = UnitName( unit )
	if realm and realm ~= "" then
		name = ("%s-%s"):format( name, realm )
	end
	unitName[ unit ] = name

	local status = resStatus[ name ]
	local text = status and displayText[ status ]

	if status ~= "SOULSTONE" or not element.ignoreSoulstone then
		element:SetText( text )
	end

	if element.PostUpdate then
		element:PostUpdate( unit, status, text )
	end

	self:RegisterEvent( "UNIT_HEALTH", UNIT_HEALTH )
end

local ForceUpdate = function( element )
	return Update( element.__owner, "ForceUpdate", element.__owner.unit )
end

------------------------------------------------------------------------

local Enable = function( self )
	local element = self.Resurrection
	if not element or not element.SetText then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	return true
end

local Disable = function( self )
	local element = self.Resurrection
	if not element or not element.SetText then return end

	element:Hide()

	return true
end

oUF:AddElement( "Resurrection", Update, Enable, Disable )

------------------------------------------------------------------------

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