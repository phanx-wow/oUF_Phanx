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

if not oUF then return end
if select(4, GetAddOnInfo("oUF_DebuffHighlight")) then return end

local class = select(2, UnitClass("player"))
local canDispel = {
	Curse = class == "DRUID" or class == "MAGE" or class == "SHAMAN",
	Disease = class == "PALADIN" or class == "PRIEST" or class == "SHAMAN",
	Magic = class == "PALADIN" or class == "PRIEST",
	Poison = class == "DRUID" or class == "PALADIN" or class == "SHAMAN",
}

local DebuffPriority = { }
for type, priority in pairs({ Curse = 2, Disease = 4, Magic = 1, Poison = 3 }) do
	table.insert(DebuffPriority, type)
	DebuffPriority[type] = ((canDispel and canDispel[type]) and 10 or 5) - priority
end
table.sort(DebuffPriority, function(a, b) return DebuffPriority[a] > DebuffPriority[b] end)

local DebuffTypeColor = { }
for type, color in pairs(_G.DebuffTypeColor) do
	DebuffTypeColor[type] = { color.r, color.g, color.b }
end

local unitDebuffType = { }

local function applyDispelHighlight(self, event, unit, bar)
	local debuffType = unitDebuffType[unit]
	if debuffType then
		bar:SetStatusBarColor(unpack(DebuffTypeColor[debuffType]))
	end
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end
	-- print("Update", unit)

	local debuffType

	if UnitCanAssist("player", unit) then
		local i = 1
		while true do
			local name, _, _, _, type = UnitAura(unit, i, "HARMFUL")
			if not name then break end
			-- print("UnitAura", unit, i, name or "NONE", type or "NONE")
			if type and (not debuffType or DebuffPriority[type] > DebuffPriority[debuffType]) then
				-- print("debuffType", type)
				debuffType = type
			end
			i = i + 1
		end
	end

	if unitDebuffType[unit] ~= debuffType then
		-- print("unitDebuffType", unitDebuffType[unit] or "NONE", "debuffType", debuffType or "NONE")

		unitDebuffType[unit] = debuffType

		if type(self.DispelHighlight) == "function" then
			self:DispelHighlight(event, unit, debuffType, canDispel and canDispel[debuffType])
		else
			if debuffType and self.DispelHighlightFilter and not (canDispel and canDispel[debuffType]) then return end
			applyDispelHighlight(self, event, unit, self.Health)
		end
	end
end

local function Enable(self)
	if not self.DispelHighlight or (self.DispelHighlightFilter and not canDispel) then return end

	self:RegisterEvent("UNIT_AURA", Update)

	if type(self.DispelHighlight) ~= "function" then
		local o = self.Health.PostUpdate
		self.Health.PostUpdate = function(...)
			if o then o(...) end
			applyDispelHighlight(...)
		end
	end
end

local function Disable(self)
	if not self.DispelHighlight or (self.DispelHighlightFilter and not canDispel) then return end

	self:UnregisterEvent("UNIT_AURA", Update)
end

oUF:AddElement("DispelHighlight", Update, Enable, Disable)
