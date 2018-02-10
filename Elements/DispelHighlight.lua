--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2018 Phanx <addons@phanx.net>. All rights reserved.
	https://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	https://www.curseforge.com/wow/addons/ouf-phanx
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
	Invulnerable = { 1,   1,   0.4 },
	Magic        = { 0,   0.8, 1   },
	Poison       = { 0,   0.8, 0   },
}
for debuffType, color in pairs(colors) do
	oUF.colors.debuff[debuffType] = color
end


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
				if (canSteal and stealable) or (type and canPurge[type]) then
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

	elseif playerClass == "HUNTER" then
		canPurge.Magic    = IsSpellKnown(19801) or nil -- Tranquilizing Shot

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

	elseif playerClass == "SHAMAN" then		
		canDispel.Curse   = IsSpellKnown(77130) or IsSpellKnown(51886) or nil -- Cleanse Spirit or Purify Spirit)
		canDispel.Magic   = IsSpellKnown(77130) or nil -- Purify Spirit
		canPurge.Magic    = IsSpellKnown(370)   or nil -- Purge

	elseif playerClass == "WARLOCK" then
		canDispel.Magic   = IsSpellKnown(132411) or IsSpellKnown(115276, true) or IsSpellKnown(89808, true) or nil -- Singe Magic (Imp with Grimoire of Sacrifice) or Sear Magic (Fel Imp) or Singe Magic (Imp)
		canPurge.Magic    = IsSpellKnown(19505, true) or nil -- Devour Magic (Felhunter)

	elseif playerClass == "WARRIOR" then
		canPurge.Magic        = IsSpellKnown(23922) or nil -- Shield Slam
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