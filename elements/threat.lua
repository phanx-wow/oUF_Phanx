--[[--------------------------------------------------------------------
	oUF_ThreatHighlight
	Highlights oUF frames by threat level.
	Highlights oUF frames by threat level.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone module.

	Simple usage:
		frame.ThreatHighlight = frame.Health:CreateTexture( nil, "OVERLAY" )
		frame.ThreatHighlight:SetAllPoints( frame.Health:GetStatusBarTexture() )

	Advanced usage:
		frame.ThreatHighlight = function( self, unit, status )
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local statusCache = { }

local function health_SetStatusBarColor( bar, r, g, b, a, override )
	if override then return end

	local status = statusCache[ unit ]
	if not status then return end

	local r, g, b = GetThreatStatusColor( status )
	bar:SetStatusBarColor( r, g, b, nil, true )
end

local function Update( self, event, unit )
	if self.unit ~= unit then return end

	local status = UnitThreatSituation( unit )
	-- print( "ThreatHighlight Update", event, unit, status )

	if element.Override then
		element.Override( self, unit, status )
	elseif status and status > 0 then
		if element.SetVertexColor then
			element:SetVertexColor( GetThreatStatusColor( status ) )
		end
		element:Show()
	else
		element:Hide()
	end
end

local ForceUpdate = function( element )
	return Update( element.__owner, "ForceUpdate", element.__owner.unit )
end

local function Enable( self )
	local threat = self.ThreatHighlight
	if not threat then return end

	if type( element ) == "function" then
		self.ThreatHighlight = {
			Override = element
		}
	end

	if type( element ) ~= "table"
	or ( not element.Override and not element.Show ) then
		self.ThreatHighlight = nil
		return
	end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent( "UNIT_THREAT_SITUATION_UPDATE", Update )

	if element.GetTexture and not element:GetTexture() then
		element:SetTexture( [[Interface\QuestFrame\UI-QuestTitleHighlight]] )
	end

	return true
end

local function Disable( self )
	local element = self.ThreatHighlight
	if not element then return end

	self:UnregisterEvent( "UNIT_THREAT_SITUATION_UPDATE", Update )

	if element.Override then
		element.Override( self, self.unit, 0 )
	else
		element:Hide()
	end
end

oUF:AddElement( "ThreatHighlight", Update, Enable, Disable )