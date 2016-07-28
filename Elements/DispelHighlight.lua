--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
------------------------------------------------------------------------
	Element to highlight oUF frames by dispellable debuff type.
	Originally based on oUF_DebuffHighlight by Ammo.
	Some code adapted from LibDispellable-1.0 by Adirelle.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	Usage:
	frame.DispelHighlight = frame.Health:CreateTexture(nil, "OVERLAY")
	frame.DispelHighlight:SetAllPoints(frame.Health:GetStatusBarTexture())

	Options:
	frame.DispelHighlight.filter = true
	frame.DispelHighlight.PreUpdate = function(element) end
	frame.DispelHighlight.PostUpdate = function(element, debuffType, canDispel)
	frame.DispelHighlight.Override = function(element, debuffType, canDispel)
----------------------------------------------------------------------]]

if select(4, GetAddOnInfo("oUF_DebuffHighlight")) then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "DispelHighlight element requires oUF")

local _, playerClass = UnitClass("player")

local colors = { -- these are nicer than DebuffTypeColor
	Curse        = { 0.8, 0,   1   },
	Disease      = { 0.8, 0.6, 0   },
	Enrage       = { 1,   0.2, 0.6 },
	Invulnerable = { 1,   1,   0.4 },
	Magic        = { 0,   0.8, 1   },
	Poison       = { 0,   0.8, 0   },
}
oUF.colors.debuff = colors

-- IDs pulled from wowdb.com using Adirelle's script:
-- https://github.com/Adirelle/LibDispellable-1.0/blob/master/fetchEnrageList.sh
local EnrageEffects = {
	-- curl -s http://www.wowdb.com/spells?filter-dispel-type=9 | perl -ne 'm@http://www.wowdb.com/spells/(\d+)\-@ and print "$1\n";' | sort -nu
	[8599] = true, [12880] = true, [15061] = true, [15716] = true, [18499] = true, [18501] = true, [19451] = true, [19812] = true, [22428] = true, [23128] = true, [23257] = true, [23342] = true, [24689] = true, [26041] = true, [26051] = true, [28371] = true, [30485] = true, [31540] = true, [31915] = true, [32714] = true, [33958] = true, [34670] = true, [37605] = true, [37648] = true, [37975] = true, [38046] = true, [38166] = true, [38664] = true, [39031] = true, [39575] = true, [40076] = true, [41254] = true, [41447] = true, [42705] = true, [42745] = true, [43139] = true, [47399] = true, [48138] = true, [48142] = true, [48193] = true, [50420] = true, [51513] = true, [52262] = true, [52470] = true, [54427] = true, [55285] = true, [56646] = true, [57733] = true, [58942] = true, [59465] = true, [59697] = true, [59707] = true, [59828] = true, [60075] = true, [61369] = true, [63227] = true, [66092] = true, [68541] = true, [70371] = true, [72143] = true, [75998] = true, [76100] = true, [76862] = true, [77238] = true, [78722] = true, [78943] = true, [80084] = true, [80467] = true, [86736] = true, [102134] = true, [102989] = true, [106925] = true, [108169] = true, [109889] = true, [111220] = true, [115430] = true, [117837] = true, [119629] = true, [123936] = true, [124019] = true, [124309] = true, [126370] = true, [127823] = true, [127955] = true, [128231] = true, [129016] = true, [129874] = true, [130196] = true, [130202] = true, [131150] = true, [135524] = true, [135548] = true, [142760] = true, [148295] = true, [151553] = true, [154017] = true, [155620] = true, [164324] = true, [164835] = true, [175743] = true,
}
local InvulnerableEffects = {
	-- curl -s http://www.wowdb.com/spells?filter-mechanic=25 | perl -ne 'm@http://www.wowdb.com/spells/(\d+)\-@ and print "$1\n";' | sort -nu
	[25771] = true, [34518] = true, [38916] = true, [41625] = true, [84958] = true,
	-- curl -s http://www.wowdb.com/spells?filter-mechanic=29 | perl -ne 'm@http://www.wowdb.com/spells/(\d+)\-@ and print "$1\n";' | sort -nu
	[9192] = true, [9220] = true, [12774] = true, [44097] = true, [44098] = true, [44099] = true, [44100] = true, [44101] = true, [44102] = true, [44104] = true, [44105] = true, [44106] = true, [45209] = true, [50095] = true, [64830] = true, [64831] = true, [64832] = true, [64833] = true, [64834] = true, [64835] = true, [64836] = true, [64837] = true, [64838] = true, [64839] = true, [64885] = true, [64892] = true, [64893] = true, [65365] = true, [66382] = true, [66383] = true, [66384] = true, [66385] = true, [66386] = true, [66387] = true, [66804] = true, [69003] = true, [69007] = true, [69095] = true, [69096] = true, [69348] = true, [69349] = true, [69559] = true, [70233] = true, [70234] = true, [70235] = true, [70242] = true, [70243] = true, [70244] = true, [74461] = true, [74463] = true, [74929] = true, [77979] = true, [78532] = true, [78541] = true, [78552] = true, [78571] = true, [78604] = true, [78605] = true, [78607] = true, [86897] = true, [86910] = true, [86924] = true, [88400] = true, [88404] = true, [97608] = true, [97625] = true, [97626] = true, [97632] = true, [98026] = true, [98145] = true, [99121] = true, [101507] = true, [104659] = true, [104702] = true, [110162] = true, [133864] = true, [133937] = true, [133938] = true, [135965] = true, [135966] = true, [141652] = true, [142223] = true, [142224] = true, [142226] = true, [148206] = true, [148244] = true, [148245] = true, [148658] = true, [156736] = true, [160861] = true, [166700] = true, [168342] = true, [168343] = true, [171470] = true, [171479] = true, [171930] = true, [172745] = true, [172849] = true, [175357] = true, [177597] = true,
}

local DefaultDispelPriority = { Curse = 2, Disease = 4, Magic = 1, Poison = 3 }
local ClassDispelPriority   = { Curse = 3, Disease = 1, Magic = 4, Poison = 2 }

local canDispel, canPurge, canSteal = {}, {}
local debuffTypeCache = {}

------------------------------------------------------------------------

local Update, ForceUpdate, Enable, Disable

function Update(self, event, unit)
	if unit ~= self.unit then return end
	local element = self.DispelHighlight
	-- print("DispelHighlight Update", event, unit)

	local debuffType, dispellable

	if UnitCanAssist("player", unit) then
		if next(canDispel) then
			for i = 1, 40 do
				local name, _, _, _, type = UnitDebuff(unit, i)
				if not name then break end
				-- print("UnitDebuff", unit, i, tostring(name), tostring(type))
				if type and (not debuffType or ClassDispelPriority[type] > ClassDispelPriority[debuffType]) then
					-- print("debuffType", type)
					debuffType = type
					dispellable = canDispel[type]
				end
			end
		end
	elseif UnitCanAttack("player", unit) then
		if canSteal or next(canPurge) then
			for i = 1, 40 do
				local name, _, _, _, type, _, _, _, stealable, _, id = UnitBuff(unit, i)
				if not name then break end
				if (canSteal and stealable) or (type and canPurge[EnrageEffects[id] and "Enrage" or InvulnerableEffects[id] and "Invulnerable" or type]) then
					-- print("debuffType", type)
					debuffType = type
					dispellable = true
					break
				end
			end
		end
	end

	if debuffTypeCache[unit] == debuffType then return end

	-- print("UpdateDispelHighlight", unit, tostring(debuffTypeCache[unit]), "==>", tostring(debuffType))
	debuffTypeCache[unit] = debuffType

	if element.Override then
		element:Override(debuffType, dispellable)
		return
	end

	if element.PreUpdate then
		element:PreUpdate()
	end

	if debuffType and (dispellable or not element.filter) then
		element:SetVertexColor(unpack(colors[debuffType]))
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		element:PostUpdate(debuffType, dispellable)
	end
end

function ForceUpdate(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.DispelHighlight
	if not element then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent("UNIT_AURA", Update)

	if element.GetTexture and not element:GetTexture() then
		element:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	end

	return true
end

local function Disable(self)
	local element = self.DispelHighlight
	if not element then return end

	self:UnregisterEvent("UNIT_AURA", Update)

	element:Hide()
end

oUF:AddElement("DispelHighlight", Update, Enable, Disable)

------------------------------------------------------------------------

local function SortByPriority(a, b)
	return ClassDispelPriority[a] > ClassDispelPriority[b]
end

local f = CreateFrame("Frame")
f:RegisterEvent("SPELLS_CHANGED")
f:SetScript("OnEvent", function(self, event)
	-- print("DispelHighlight", event, "Checking capabilities...")
	wipe(canDispel)
	wipe(canPurge)

	if playerClass == "DEATHKNIGHT" then
		canPurge.Magic   = IsPlayerSpell(58631) or nil -- Glyph of Icy Touch

	elseif playerClass == "DRUID" then
		canDispel.Curse   = IsSpellKnown(88423) or IsSpellKnown(2782) or nil -- Nature's Cure or Remove Corruption
		canDispel.Magic   = IsSpellKnown(88423) or nil -- Nature's Cure
		canDispel.Poison  = canDispel.Curse
		canPurge.Enrage   = IsSpellKnown(2908) or nil -- Soothe

	elseif playerClass == "HUNTER" then
		canPurge.Magic    = IsSpellKnown(19801) or nil -- Tranquilizing Shot
		canPurge.Enrage   = canPurge.Magic

	elseif playerClass == "MAGE" then
		canDispel.Curse   = IsSpellKnown(475)   or nil -- Remove Curse
		canSteal          = IsSpellKnown(30449) or nil -- Spellsteal

	elseif playerClass == "MONK" then
		canDispel.Disease = IsSpellKnown(115450) or nil -- Detox
		canDispel.Magic   = IsSpellKnown(115451) or nil -- Internal Medicine
		canDispel.Poison  = canDispel.Disease

	elseif playerClass == "PALADIN" then
		canDispel.Disease = IsSpellKnown(4987)  or nil -- Cleanse
		canDispel.Magic   = IsSpellKnown(53551) or nil -- Sacred Cleansing
		canDispel.Poison  = canDispel.Disease

	elseif playerClass == "PRIEST" then
		canDispel.Disease = IsSpellKnown(527) -- Purify
		canDispel.Magic   = IsSpellKnown(527) or IsSpellKnown(32375) or nil -- Purify or Mass Dispel
		canPurge.Magic    = IsSpellKnown(528) -- Dispel Magic

	elseif playerClass == "ROGUE" then
		canPurge.Enrage   = IsSpellKnown(5938) -- Shiv

	elseif playerClass == "SHAMAN" then		
		canDispel.Curse   = IsSpellKnown(77130) or IsSpellKnown(51886) or nil -- Cleanse Spirit or Purify Spirit)
		canDispel.Magic   = IsSpellKnown(77130) or nil -- Purify Spirit
		canPurge.Magic    = IsSpellKnown(370)   or nil -- Purge

	elseif playerClass == "WARLOCK" then
		canDispel.Magic   = IsSpellKnown(132411) or IsSpellKnown(115276, true) or IsSpellKnown(89808, true) or nil -- Singe Magic (Imp with Grimoire of Sacrifice) or Sear Magic (Fel Imp) or Singe Magic (Imp)
		canPurge.Magic    = IsSpellKnown(19505, true) or nil -- Devour Magic (Felhunter)

	elseif playerClass == "WARRIOR" then
		canPurge.Magic        = IsSpellKnown(23922) or nil -- Shield Slam
		canPurge.Invulnerable = IsSpellKnown(64382) or nil -- Shattering Throw
	end

	wipe(ClassDispelPriority)
	for type, priority in pairs(DefaultDispelPriority) do
		ClassDispelPriority[1 + #ClassDispelPriority] = type
		ClassDispelPriority[type] = (canDispel[type] and 10 or 5) - priority
	end
	table.sort(ClassDispelPriority, SortByPriority)

	noDispels = not next(canDispel)
--[[
	for i, v in ipairs(ClassDispelPriority) do
		print("Can dispel " .. v .. "?", canDispel[v] and "YES" or "NO")
	end
	print("Can purge?", canPurge and "YES" or "NO")
	print("Can shatter?", canShatter and "YES" or "NO")
	print("Can steal?", canSteal and "YES" or "NO")
	print("Can tranquilize?", canTranq and "YES" or "NO")
]]
	for i = 1, #oUF.objects do
		local object = oUF.objects[i]
		if object.DispelHighlight and object:IsShown() then
			Update(object, event, object.unit)
		end
	end
end)