--[[--------------------------------------------------------------------
	oUF_DispelHighlight
	by Phanx <addons@phanx.net>
	Highlights oUF frames by dispellable debuff type.
	Originally based on oUF_DebuffHighlight by Ammo.
	Some code adapted from LibDispellable-1.0 by Adirelle.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	To enable:
		frame.DispelHighlight = frame.Health:CreateTexture(nil, "OVERLAY")
		frame.DispelHighlight:SetAllPoints(frame.Health:GetStatusBarTexture())

	To highlight only debuffs you can dispel:
		frame.DispelHighlight.filter = true

	Advanced alternate usage:
		frame.DispelHighlight = function(frame, event, unit, debuffType, canDispel)
			-- debuffType (string or nil) - type of highest priority debuff, nil if no debuffs
			-- canDispel  (boolean) - whether the player can dispel the debuff
		end
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

if select(4, GetAddOnInfo("oUF_DebuffHighlight")) then return end

local class = select(2, UnitClass("player"))

local colors = {
	["Curse"] = { 0.8, 0, 1 },
	["Disease"] = { 0.8, 0.6, 0 },
	["Enrage"] = { 1.0, 0.2, 0.6 },
	["Invulnerability"] = { 1, 1, 0.4 },
	["Magic"] = { 0, 0.8, 1 },
	["Poison"] = { 0, 0.8, 0 },
}
--	for type, color in pairs(DebuffTypeColor) do
--		colors[type] = { color.r, color.g, color.b }
--	end
oUF.colors.debuff = colors

local invulnEffects = { [642] = true, [1022] = true, [45438] = true, }

------------------------------------------------------------------------

local canDispel, canPurge, canShatter, canSteal, canTranq, noDispels = {}
local defaultPriority = { Curse = 2, Disease = 4, Magic = 1, Poison = 3 }
local dispelPriority = { Curse = 3, Disease = 1, Magic = 4, Poison = 2 }

local function prioritySort(a, b)
	return dispelPriority[a] > dispelPriority[b]
end

------------------------------------------------------------------------

local debuffTypeCache = {}

local function Update(self, event, unit)
	if unit ~= self.unit then return end
	-- print("DispelHighlight Update", event, unit)

	local debuffType, dispellable

	if not noDispels and UnitCanAssist("player", unit) then
		for i = 1, 32 do
			local name, _, _, _, type = UnitDebuff(unit, i)
			if not name then break end
			-- print("UnitDebuff", unit, i, tostring(name), tostring(type))
			if type and (not debuffType or dispelPriority[type] > dispelPriority[debuffType]) then
				-- print("debuffType", type)
				debuffType = type
				dispellable = canDispel[type]
			end
		end
	elseif (canSteal or canPurge or canTranq) and UnitCanAttack("player", unit) then
		for i = 1, 32 do
			local name, _, _, _, type, _, _, _, stealable, _, id = UnitBuff(unit, i)
			if not name then break end

			if type == "" then
				type = "Enrage"
			end

			if canShatter and not type and invulnEffects[id] then
				type = "Invulnerability"
			end

			if (canSteal and stealable) or (canPurge and type == "Magic") or (canTranq and type == "Enrage") or (type == "Invulnerability") then
				-- print("debuffType", type)
				debuffType = type
				dispellable = true
				break
			end
		end
	end

	if debuffTypeCache[unit] == debuffType then return end

	-- print("UpdateDispelHighlight", unit, tostring(debuffTypeCache[unit]), "==>", tostring(debuffType))
	debuffTypeCache[unit] = debuffType

	local element = self.DispelHighlight
	if element.Override then
		element:Override(unit, debuffType, dispellable)
	elseif debuffType and (dispellable or not element.filter) then
		if element.SetVertexColor then
			element:SetVertexColor(unpack(colors[debuffType]))
		end
		element:Show()
	else
		element:Hide()
	end
end

------------------------------------------------------------------------

local function ForceUpdate(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.DispelHighlight
	if not element then return end

	if type(element) == "table" then
		if (element.filter and class == "DEATHKNIGHT") or (not element.Override and not element.Show) then return end
	elseif type(element) == "function" then
		self.DispelHighlight = { Override = element }
		element = self.DispelHighlight
	else
		return
	end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent("UNIT_AURA", Update)

	if element.GetTexture and not element:GetTexture() then
		element:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	end

	return true
end

local function Disable(self)
	if not self.DispelHighlight then return end

	self:UnregisterEvent("UNIT_AURA", Update)

	if element.Override then
		element.Override(self, self.unit)
	else
		element:Hide()
	end
end

oUF:AddElement("DispelHighlight", Update, Enable, Disable)

------------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("SPELLS_CHANGED")
f:SetScript("OnEvent", function(self, event)
	wipe(canDispel)

	-- print("DispelHighlight", event, "Checking capabilities...")

	if class == "DEATHKNIGHT" then
		for i = 1, GetNumGlyphSockets() do
			local enabled, _, _, id = GetGlyphSocketInfo(i)
			if id == 58631 then
				canPurge = true -- Glyph of Icy Touch
				break
			end
		end

	elseif class == "DRUID" then
		canDispel.Curse = IsSpellKnown(2782) -- Remove Corruption
		canDispel.Magic = GetSpecialization() == 4 and UnitLevel("player") >= 22 -- Nature's Cure (88423)
		canDispel.Poison = canDispel.Curse
		canTranq = IsSpellKnown(2908) -- Soothe

	elseif class == "HUNTER" then
		canPurge = IsSpellKnown(19801) -- Tranquilizing Shot
		canTranq = canPurge

	elseif class == "MAGE" then
		canDispel.Curse = IsSpellKnown(475) -- Remove Curse
		canSteal = IsSpellKnown(30449) -- Spellsteal

	elseif class == "MONK" then
		canDispel.Disease = IsPlayerSpell(115450) -- Detox
		canDispel.Magic = GetSpecialization() == 2 and UnitLevel("player") >= 20 -- Internal Medicine (115451)
		canDispel.Poison = canDispel.Disease

	elseif class == "PALADIN" then
		canDispel.Disease = IsSpellKnown(4987) -- Cleanse
		canDispel.Magic = GetSpecialization() == 1 and UnitLevel("player") >= 20 -- Sacred Cleansing (53551)
		canDispel.Poison = canDispel.Disease

	elseif class == "PRIEST" then
		local spec = GetSpecialization()
		local level = UnitLevel("player")
		canDispel.Disease = spec == 2 and level >= 22 -- Purify (527)
		canDispel.Magic = IsPlayerSpell(32375) or (spec == 2 and level >= 22) -- Mass Dispel, or Purify (527)
		canPurge = IsPlayerSpell(528) -- Dispel Magic

	elseif class == "ROGUE" then
		canTranq = IsSpellKnown(5938) -- Shiv

	elseif class == "SHAMAN" then
		canDispel.Curse = IsPlayerSpell(51886) -- Cleanse Spirit (upgrades to Purify Spirit)
		canDispel.Magic = GetSpecialization() == 3 and UnitLevel("player") >= 18 -- Purify Spirit (77130)
		canPurge = IsSpellKnown(370) -- Purge

	elseif class == "WARLOCK" then
		canDispel.Magic = IsSpellKnown(89808, true) -- Singe Magic (Imp)
		canPurge = IsSpellKnown(19505, true) -- Devour Magic (Felhunter)

	elseif class == "WARRIOR" then
		canPurge = IsSpellKnown(23922) -- Shield Slam
		canShatter = IsSpellKnown(64382) -- Shattering Throw
	end

--[[#DEBUGGING
	canDispel.Curse, canDispel.Disease, canDispel.Magic, canDispel.Poison = false, false, false, false
	canPurge, canShatter, canSteal, canTranq = true, false, false, false
]]
	wipe(dispelPriority)
	for type, priority in pairs(defaultPriority) do
		dispelPriority[1 + #dispelPriority] = type
		dispelPriority[type] = (canDispel[type] and 10 or 5) - priority
	end
	table.sort(dispelPriority, prioritySort)

	noDispels = true
	for type in pairs(canDispel) do
		noDispels = nil
	end

--[[#DEBUGGING
	for i, v in ipairs(dispelPriority) do
		print("Can dispel " .. v .. "?", canDispel[v] and "YES" or "NO")
	end
	print("Can purge?", canPurge and "YES" or "NO")
	print("Can shatter?", canShatter and "YES" or "NO")
	print("Can steal?", canSteal and "YES" or "NO")
	print("Can tranquilize?", canTranq and "YES" or "NO")
]]
	for i, object in ipairs(oUF.objects) do
		if object.DispelHighlight and object:IsShown() then
			Update(object, event, object.unit)
		end
	end
end)