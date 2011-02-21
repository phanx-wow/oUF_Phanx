--[[--------------------------------------------------------------------
	oUF_ThreatHighlight
	Highlights oUF frames by threat level.
	Highlights oUF frames by threat level.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone module.

	Health bar color highlight:
		self.ThreatHighlight = true

	Colored texture highlight:
		self.ThreatHighlight = UIOBJECT -- texture, fontstring, etc.

	Custom highlight:
		self.ThreatHighlight = {
			Override = function(self, unit, status) end
		}
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local unitThreatStatus = { }

local function health_SetStatusBarColor( bar, r, g, b, a, override )
	if override then return end

	local status = unitThreatStatus[ unit ]
	if not status then return end

	local r, g, b = GetThreatStatusColor( status )
	bar:SetStatusBarColor( r, g, b, nil, true )
end

--[[
local function applyThreatHighlight( bar, unit, status )
	local status = unitThreatStatus[ unit ]
	if status then
		local r, g, b = GetThreatStatusColor( status )
		bar:SetStatusBarColor( r, g, b )
	end
end
--]]

local function Update( self, event, unit )
	if self.unit ~= unit then return end

	local status = UnitThreatSituation( unit )
	-- print( "ThreatHighlight Update", event, unit, status )

	local threat = self.ThreatHighlight
	if threat.Override then
		threat.Override( self, unit, ( status and status > 0 ) and status or 0 )
	elseif threat.SetVertexColor then
		if status and status > 0 then
			if threat.SetVertexColor then
				local r, g, b = GetThreatStatusColor( status )
				threat:SetVertexColor( r, g, b )
			end
			threat:Show()
		else
			threat:Hide()
		end
--[[
	else
		unitThreatStatus[ unit ] = status
		if status and status > 0 then
			applyThreatHighlight( self.Health, unit )
		else
			local health = self.Health
			health:SetStatusBarColor( unpack( health.prethreat_color ) )
			health:ForceUpdate()
		end
-]]
	end
end

local ForceUpdate = function( element )
	return Update( element.__owner, "ForceUpdate", element.__owner.unit )
end

local function Enable( self )
	local threat = self.ThreatHighlight
	if not threat then return end

	if type(threat) ~= "table" then
		threat = { }
	end

	threat.__owner = self
	threat.ForceUpdate = ForceUpdate

	self:RegisterEvent( "UNIT_THREAT_SITUATION_UPDATE", Update )

	if threat.SetTexture then
		if not threat:GetTexture() then
			threat:SetTexture( "Interface\\QuestFrame\\UI-QuestTitleHighlight" )
		end
	elseif not threat.SetVertexColor and not threat.Override then
		hooksecurefunc( self.Health, "SetStatusBarColor", health_SetStatusBarColor )
--[[
		local r, g, b = self.Health:GetStatusBarColor()
		self.Health.prethreat_color = { r, g, b }

		local o = self.Health.PostUpdate
		self.Health.prethreat_PostUpdate = o
		self.Health.PostUpdate = function( ... )
			if o then o( ... ) end
			applyThreatHighlight( ... )
		end
--]]
	end

	return true
end

local function Disable( self )
	local threat = self.ThreatHighlight
	if not threat then return end

	self:UnregisterEvent( "UNIT_THREAT_SITUATION_UPDATE", Update )

	if threat.Override then
		threat.Override( self, self.unit, 0 )
--[[
	elseif threat.colorHealthBar then
		local health = self.Health

		if health.prethreat_PostUpdate then
			health.PostUpdate = self.Health.prethreat_PostUpdate
			health.prethreat_PostUpdate = nil
		end

		health:SetStatusBarColor( unpack( health.prethreat_color ) )
		health.preethreat_color = nil

		health:ForceUpdate()
--]]
	elseif threat.SetVertexColor then
		threat:Hide()
	end
end

oUF:AddElement( "ThreatHighlight", Update, Enable, Disable )