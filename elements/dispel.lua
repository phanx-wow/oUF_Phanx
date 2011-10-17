--[[--------------------------------------------------------------------
	oUF_DispelHighlight
	by Phanx <addons@phanx.net>
	Modified by Akkorian <akkorian@hotmail.com>
	Highlights oUF frames by dispellable debuff type.
	Originally based on oUF_DebuffHighlight by Ammo.
	Some code adapted from LibDispellable-1.0 by Adirelle.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	To enable:
		frame.DispelHighlight = frame.Health:CreateTexture( nil, "OVERLAY" )
		frame.DispelHighlight:SetAllPoints( frame.Health:GetStatusBarTexture() )

	To highlight only debuffs you can dispel:
		frame.DispelHighlight.filter = true

	Advanced alternate usage:
		frame.DispelHighlight = function( frame, event, unit, debuffType, canDispel )
			-- debuffType (string or nil) - type of highest priority debuff, nil if no debuffs
			-- canDispel  (boolean) - whether the player can dispel the debuff
		end
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

if select( 4, GetAddOnInfo( "oUF_DebuffHighlight" ) ) then return end

local class = select( 2, UnitClass( "player" ) )

local colors = {
	["Curse"] = { 0.8, 0, 1 },
	["Disease"] = { 0.8, 0.6, 0 },
	["Enrage"] = { 1.0, 0.2, 0.6 },
	["Invulnerability"] = { 1, 1, 0.4 },
	["Magic"] = { 0, 0.8, 1 },
	["Poison"] = { 0, 0.8, 0 },
}
--	for type, color in pairs( DebuffTypeColor ) do
--		colors[ type ] = { color.r, color.g, color.b }
--	end
oUF.colors.debuff = colors

local enrageEffects = { }
local invulnEffects = { [642] = true, [1022] = true, [45438] = true, }

------------------------------------------------------------------------

local canDispel, canPurge, canShatter, canSteal, canTranq = { }
local defaultPriority = { Curse = 2, Disease = 4, Magic = 1, Poison = 3 }
local dispelPriority = { Curse = 3, Disease = 1, Magic = 4, Poison = 2 }
local prioritySort = function( a, b ) return dispelPriority[ a ] > dispelPriority[ b ] end

------------------------------------------------------------------------

local scanUnit, scanIndex

do
	local scanTooltip

	local function CreateScanTooltip()
		scanTooltip = CreateFrame( "GameTooltip" )
		scanTooltip.left, scanTooltip.right = scanTooltip:CreateFontString(), scanTooltip:CreateFontString()
		scanTooltip.left:SetFontObject( GameFontNormal )
		scanTooltip.right:SetFontObject( GameFontNormal )
		scanTooltip:AddFontStrings( scanTooltip.left, scanTooltip.right )
		return scanTooltip
	end

	local function IsEnrageEffect( unit, index )
		scanTooltip = scanTooltip or CreateScanTooltip()
		scanTooltip:SetOwner( UIParent, "ANCHOR_NONE" )
		scanTooltip:ClearLines()
		scanTooltip:SetUnitBuff( unit, index )
		local name = scanTooltip.left:GetText()
		local type = scanTooltip.right:GetText()
		-- print( "Scanning", unit, index, type or "Unknown", "buff", name or "Unknown" )
		scanTooltip:Hide()
		return ( type == "Enrage" ), name
	end

	setmetatable( enrageEffects, { __index = function( enrageEffects, id )
		if not scanUnit or not scanIndex or type( id ) ~= "number" then return end
		local result, name = IsEnrageEffect( scanUnit, scanIndex )
		if result then
			-- print( "Found enrage effect", id, name )
			PoUFDB.enrageEffects = PoUFDB.enrageEffects or { }
			PoUFDB.enrageEffects[ id ] = name
		end
		rawset( enrageEffects, id, result )
		return result
	end } )
end

------------------------------------------------------------------------

local debuffTypeCache = { }

local function Update( self, event, unit )
	if unit ~= self.unit then return end
	-- print( "DispelHighlight Update", event, unit )

	local debuffType, dispellable

	if UnitCanAssist( "player", unit ) then
		local i = 1
		while true do
			local name, _, _, _, type = UnitDebuff( unit, i )
			if not name then break end
			-- print( "UnitDebuff", unit, i, tostring( name ), tostring( type ) )
			if type and ( not debuffType or dispelPriority[ type ] > dispelPriority[ debuffType ] ) then
				-- print( "debuffType", type )
				debuffType = type
				dispellable = canDispel[ type ]
			end
			i = i + 1
		end
	elseif UnitCanAttack( "player", unit ) then
		scanUnit = unit

		local i = 1
		while true do
			local name, _, _, _, type, _, _, _, stealable, _, id = UnitBuff( unit, i )
			if not name then break end
			if type and type:len() < 4 then type = nil end
			-- print( "UnitBuff", unit, i, tostring( name ), tostring( type ) )

			scanIndex = i
			if not type and enrageEffects[ id ] then
				type = "Enrage"
			end
			scanIndex = nil

			if canShatter and not type and invulnEffects[ id ] then
				type = "Invulnerability"
			end

			if ( canSteal and stealable ) or ( canPurge and type == "Magic" ) or ( canTranq and type == "Enrage" ) or ( type == "Invulnerability" ) then
				-- print( "debuffType", type )
				debuffType = type
				dispellable = true
				break
			end

			i = i + 1
		end

		scanUnit = nil
	end

	if debuffTypeCache[ unit ] == debuffType then return end

	-- print( "UpdateDispelHighlight", unit, tostring( debuffTypeCache[ unit ] ), "==>", tostring( debuffType ) )
	debuffTypeCache[ unit ] = debuffType

	local element = self.DispelHighlight
	if element.Override then
		element:Override( unit, debuffType, dispellable )
	elseif debuffType and ( dispellable or not element.filter ) then
		if element.SetVertexColor then
			element:SetVertexColor( unpack( colors[ debuffType ] ) )
		end
		element:Show()
	else
		element:Hide()
	end
end

------------------------------------------------------------------------

local ForceUpdate = function( element )
	return Update( element.__owner, "ForceUpdate", element.__owner.unit )
end

local function Enable( self )
	local element = self.DispelHighlight
	if not element then return end

	if type( element ) == "table" then
		if ( element.filter and class == "DEATHKNIGHT" ) or ( not element.Override and not element.Show ) then return end
	elseif type( element ) == "function" then
		self.DispelHighlight = { Override = element }
		element = self.DispelHighlight
	else
		return
	end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent( "UNIT_AURA", Update )

	if element.GetTexture and not element:GetTexture() then
		element:SetTexture( [[Interface\QuestFrame\UI-QuestTitleHighlight]] )
	end

	return true
end

local function Disable( self )
	if not self.DispelHighlight then return end

	self:UnregisterEvent( "UNIT_AURA", Update )

	if element.Override then
		element.Override( self, self.unit )
	else
		element:Hide()
	end
end

oUF:AddElement( "DispelHighlight", Update, Enable, Disable )

------------------------------------------------------------------------

local f = CreateFrame( "Frame" )
f:RegisterEvent( "PLAYER_TALENT_UPDATE" )
f:RegisterEvent( "SPELLS_CHANGED" )
f:SetScript( "OnEvent", function( self, event )
	if not self.initialized then
		PoUFDB.enrageEffects = PoUFDB.enrageEffects or { }
		for id in pairs( PoUFDB.enrageEffects ) do
			enrageEffects[ id ] = true
		end
		self.initialized = true
	end

	-- print( "DispelHighlight", event, "Checking capabilities..." )

	if class == "DRUID" then
		if IsSpellKnown( 2782 ) then -- Remove Corruption
			canDispel.Curse = true
			canDispel.Poison = true
			canDispel.Magic = ( select( 5, GetTalentInfo( 3, 17 ) ) or 0 ) >= 1 -- Nature's Cure
		end
		canTranq = IsSpellKnown( 2908 ) -- Soothe
	elseif class == "HUNTER" then
		canPurge = IsSpellKnown( 19801 ) -- Tranquilizing Shot
		canTranq = canPurge
	elseif class == "MAGE" then
		canDispel.Curse = IsSpellKnown( 475 ) -- Remove Curse
		canSteal = IsSpellKnown( 30449 ) -- Spellsteal
	elseif class == "PALADIN" then
		if IsSpellKnown( 4987 ) then -- Cleanse
			canDispel.Disease = true
			canDispel.Poison = true
			canDispel.Magic = ( select( 5, GetTalentInfo( 1, 14 ) ) or 0 ) >= 1 -- Sacred Cleansing
		end
	elseif class == "PRIEST" then
		canDispel.Disease = IsSpellKnown( 528 ) -- Cure Disease
		canDispel.Magic = IsSpellKnown( 527 ) -- Dispel Magic
		canPurge = canDispel.Magic
	elseif class == "ROGUE" then
		canTranq = IsSpellKnown( 5938 ) -- Shiv
	elseif class == "SHAMAN" then
		if IsSpellKnown( 51886 ) then -- Cleanse Spirit
			canDispel.Curse = true
			canDispel.Magic = ( select( 5, GetTalentInfo( 3, 12 ) ) or 0 ) >= 1 -- Improved Cleanse Spirit
		end
		canPurge = IsSpellKnown( 370 ) -- Purge
	elseif class == "WARLOCK" then
		canDispel.Magic = IsSpellKnown( 89808, true ) -- Singe Magic (Imp)
		canPurge = IsSpellKnown( 19505, true ) -- Devour Magic (Felhunter)
	elseif class == "WARRIOR" then
		canPurge = IsSpellKnown( 23922 ) -- Shield Slam
		canShatter = IsSpellKnown( 64382 ) -- Shattering Throw
	end

--[[#DEBUGGING
	canDispel.Curse, canDispel.Disease, canDispel.Magic, canDispel.Poison = false, false, false, false
	canPurge, canShatter, canSteal, canTranq = true, false, false, false
]]
	wipe( dispelPriority )
	for type, priority in pairs( defaultPriority ) do
		dispelPriority[ 1 + #dispelPriority ] = type
		dispelPriority[type] = ( canDispel[ type ] and 10 or 5 ) - priority
	end
	table.sort( dispelPriority, prioritySort )

--[[#DEBUGGING
	for i, v in ipairs( dispelPriority ) do
		print( "Can dispel " .. v .. "?", canDispel[ v ] and "YES" or "NO" )
	end
	print( "Can purge?", canPurge and "YES" or "NO" )
	print( "Can shatter?", canShatter and "YES" or "NO" )
	print( "Can steal?", canSteal and "YES" or "NO" )
	print( "Can tranquilize?", canTranq and "YES" or "NO" )
]]
	for i, object in ipairs( oUF.objects ) do
		if object.DispelHighlight and object:IsShown() then
			Update( object, event, object.unit )
		end
	end
end )