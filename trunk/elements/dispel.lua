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
		frame.DispelHighlight = true

	To highlight only debuffs you can dispel:
		frame.DispelHighlightFilter = true

	Advanced usage:
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

local colors = { ["Enrage"] = { 0.8, 0.2, 0 } }
oUF.colors.debuff = colors
for type, color in pairs( DebuffTypeColor ) do
	colors[ type ] = { color.r, color.g, color.b }
end

local enrageEffects = { [134] = true, [256] = true, [772] = true, [4146] = true, [8599] = true, [12880] = true, [14201] = true, [14202] = true, [14203] = true, [14204] = true, [15061] = true, [15716] = true, [18501] = true, [19451] = true, [19812] = true, [22428] = true, [23128] = true, [23257] = true, [23342] = true, [24689] = true, [25503] = true, [26041] = true, [26051] = true, [28371] = true, [29131] = true, [29340] = true, [30485] = true, [31540] = true, [31915] = true, [32714] = true, [33958] = true, [34392] = true, [34670] = true, [37605] = true, [37648] = true, [37975] = true, [38046] = true, [38166] = true, [38664] = true, [39031] = true, [39575] = true, [40076] = true, [40601] = true, [41254] = true, [41364] = true, [41447] = true, [42705] = true, [42745] = true, [43139] = true, [43292] = true, [43664] = true, [47399] = true, [48138] = true, [48142] = true, [48193] = true, [48391] = true, [48702] = true, [49029] = true, [50420] = true, [50636] = true, [51170] = true, [51513] = true, [51662] = true, [52071] = true, [52262] = true, [52309] = true, [52461] = true, [52470] = true, [52537] = true, [53361] = true, [54356] = true, [54427] = true, [54475] = true, [54508] = true, [54781] = true, [55285] = true, [55462] = true, [56646] = true, [56729] = true, [56769] = true, [57514] = true, [57516] = true, [57518] = true, [57519] = true, [57520] = true, [57521] = true, [57522] = true, [57733] = true, [58942] = true, [59465] = true, [59694] = true, [59697] = true, [59707] = true, [59828] = true, [60075] = true, [60177] = true, [60430] = true, [61369] = true, [62071] = true, [63147] = true, [63227] = true, [63848] = true, [66092] = true, [66759] = true, [67233] = true, [67657] = true, [67658] = true, [67659] = true, [68541] = true, [69052] = true, [70371] = true, [72143] = true, [72146] = true, [72147] = true, [72148] = true, [72203] = true, [75998] = true, [76100] = true, [76487] = true, [76691] = true, [76816] = true, [76862] = true, [77238] = true, [78722] = true, [78943] = true, [79420] = true, [80084] = true, [80158] = true, [80467] = true, [81706] = true, [81772] = true, [82033] = true, [82759] = true, [86736] = true, [90045] = true, [90872] = true, [91668] = true, [92946] = true, [95436] = true, [95459] = true, }
local invulnEffects = { [642] = true, [1022] = true, [45438] = true, }

local dispelPriority = { Curse = 3, Disease = 1, Magic = 4, Poison = 2 }
local canDispel, canPurge, canShatter, canSteal, canTranq = { }

local defaultPriority = { Curse = 2, Disease = 4, Magic = 1, Poison = 3 }
local prioritySort = function( a, b ) return dispelPriority[ a ] > dispelPriority[ b ] end

------------------------------------------------------------------------

local function applyDispelHighlight( self, unit )
	local debuffType = self.debuffType
	if debuffType then
		self:SetStatusBarColor( unpack( colors[ debuffType ] ) )
	end
end

local function Update( self, event, unit )
	if self.unit ~= unit then return end
	-- print( "DispelHighlight Update", event, unit )

	local debuffType

	if UnitCanAssist( "player", unit ) then
		local i = 1
		while true do
			local name, _, _, _, type = UnitAura( unit, i, "HARMFUL" )
			if not name then break end
			-- print( "UnitAura", unit, i, tostring( name ), tostring( type ) )
			if type and ( not debuffType or dispelPriority[ type ] > dispelPriority[ debuffType ] ) then
				-- print( "debuffType", type )
				debuffType = type
			end
			i = i + 1
		end
	elseif UnitCanAttack( "player", unit ) then
		local i = 1
		while true do
			local name, _, _, _, type, _, _, _, stealable, _, id = UnitAura( unit, i, "HELPFUL" )
			if not name then break end
			-- print( "UnitAura", unit, i, tostring( name ), tostring( type ) )
			if ( canSteal and stealable ) or ( canPurge and type == "Magic" ) or ( canTranq and enrageEffects[ id ] ) or ( canShatter and invulnEffects[ id ] ) then
				debuffType = type
				break
			end
			i = i + 1
		end
	end

	if self.debuffType == debuffType then return end
	-- print( "UpdateDispelHighlight", unit, tostring( self.debuffType ), "==>", tostring( debuffType ) )

	self.debuffType = debuffType
	self.debuffDispellable = debuffType and canDispel[ debuffType ]

	if type( self.DispelHighlight ) == "function" then
		self:DispelHighlight( unit, debuffType, canDispel[ debuffType ] )
	elseif debuffType and ( canDispel[ debuffType ] or not self.DispelHighlightFilter ) then
		applyDispelHighlight( self.Health, unit )
	end
end

------------------------------------------------------------------------

local function Enable( self )
	if not self.DispelHighlight or ( self.DispelHighlightFilter and class == "DEATHKNIGHT" ) then return end

	self:RegisterEvent( "UNIT_AURA", Update )

	if type( self.DispelHighlight ) ~= "function" then
		local o = self.Health.PostUpdate
		self.Health.PostUpdate = function( ... )
			if o then o( ... ) end
			applyDispelHighlight( ... )
		end
	end

	return true
end

local function Disable( self )
	if not self.DispelHighlight or ( self.DispelHighlightFilter and class == "DEATHKNIGHT" ) then return end

	self:UnregisterEvent( "UNIT_AURA", Update )
end

oUF:AddElement( "DispelHighlight", Update, Enable, Disable )

------------------------------------------------------------------------

local f = CreateFrame( "Frame" )
f:RegisterEvent( "PLAYER_TALENT_UPDATE" )
f:RegisterEvent( "SPELLS_CHANGED" )
f:SetScript( "OnEvent", function( self, event )
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
		canDispel.Disease = CheckSpell( 528 ) -- Cure Disease
		canDispel.Magic = CheckSpell( 527 ) -- Dispel Magic
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

	wipe( dispelPriority )
	for type, priority in pairs( defaultPriority ) do
		dispelPriority[ 1 + #dispelPriority ] = type
		dispelPriority[type] = ( canDispel[ type ] and 10 or 5 ) - priority
	end
	table.sort( dispelPriority, prioritySort )
--[[
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