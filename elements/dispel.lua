--[[--------------------------------------------------------------------
	oUF_DispelHighlight
	by Phanx < addons@phanx.net >
	Highlights oUF frames by dispellable debuff type.
	Originally based on Ammo's oUF_DebuffHighlight.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	To enable :
		frame.DispelHighlight = true

	Advanced usage:
		frame.DispelHighlight = function(frame, event, unit, debuffType, canDispel)
			-- debuffType (string or nil) - type of highest priority debuff, nil if no debuffs
			-- canDispel  (boolean) - whether the player can dispel the debuff
		end

	To highlight only debuffs you can dispel:
		frame.DispelHighlightFilter = true
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

if select(4, GetAddOnInfo("oUF_DebuffHighlight")) then return end

local class = select(2, UnitClass("player"))

local canSteal = class == "MAGE"
local canPurge = class == "PRIEST" or class == "SHAMAN" or class == "WARLOCK" or class == "WARRIOR"
local canDispel = {
	Curse = class == "DRUID" or class == "MAGE" or class == "SHAMAN",
	Disease = class == "PALADIN" or class == "PRIEST" or class == "SHAMAN",
	Magic = class == "PALADIN" or class == "PRIEST",
	Poison = class == "DRUID" or class == "PALADIN" or class == "SHAMAN",
}

------------------------------------------------------------------------

local dispelPriority = { }
for type, priority in pairs({ Curse = 2, Disease = 4, Magic = 1, Poison = 3 }) do
	table.insert(dispelPriority, type)
	dispelPriority[type] = (canDispel[type] and 10 or 5) - priority
end
table.sort(dispelPriority, function(a, b) return dispelPriority[a] > dispelPriority[b] end)

local colors = { }
for type, color in pairs(DebuffTypeColor) do
	colors[type] = { color.r, color.g, color.b }
end
oUF.colors.debuff = colors

------------------------------------------------------------------------

local function applyDispelHighlight(self, unit)
	local debuffType = self.debuffType
	if debuffType then
		self:SetStatusBarColor(unpack(colors[debuffType]))
	end
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end
	-- print("DispelHighlight Update", event, unit)

	local debuffType

	if UnitCanAssist("player", unit) then
		local i = 1
		while true do
			local name, _, _, _, type = UnitAura(unit, i, "HARMFUL")
			if not name then break end
			-- print("UnitAura", unit, i, tostring(name), tostring(type))
			if type and (not debuffType or dispelPriority[type] > dispelPriority[debuffType]) then
				-- print("debuffType", type)
				debuffType = type
			end
			i = i + 1
		end
	elseif UnitCanAttack("player", unit) then
		local i = 1
		while true do
			local name, _, _, _, type, _, _, _, stealable = UnitAura(unit, i, "HELPFUL")
			if not name then break end
			-- print("UnitAura", unit, i, tostring(name), tostring(type))
			if (canPurge and type == "MAGIC") or (canSteal and stealable) then
				debuffType = type
				break
			end
			i = i + 1
		end
	end

	if self.debuffType == debuffType then return end
	-- print("UpdateDispelHighlight", unit, tostring(self.debuffType), "==>", tostring(debuffType))

	self.debuffType = debuffType
	self.debuffDispellable = debuffType and canDispel[debuffType]

	if type(self.DispelHighlight) == "function" then
		self:DispelHighlight(unit, debuffType, canDispel[debuffType])
	elseif debuffType and (canDispel[debuffType] or not self.DispelHighlightFilter) then
		applyDispelHighlight(self.Health, unit)
	end
end

local function Enable(self)
	if not self.DispelHighlight or (self.DispelHighlightFilter and (class == "DEATHKNIGHT" or class == "HUNTER" or class == "ROGUE")) then return end

	self:RegisterEvent("UNIT_AURA", Update)

	if type(self.DispelHighlight) ~= "function" then
		local o = self.Health.PostUpdate
		self.Health.PostUpdate = function(...)
			if o then o(...) end
			applyDispelHighlight(...)
		end
	end

	return true
end

local function Disable(self)
	if not self.DispelHighlight or (self.DispelHighlightFilter and (class == "DEATHKNIGHT" or class == "HUNTER" or class == "ROGUE")) then return end

	self:UnregisterEvent("UNIT_AURA", Update)
end

oUF:AddElement("DispelHighlight", Update, Enable, Disable)
