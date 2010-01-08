--[[--------------------------------------------------------------------
	oUF_DispelHighlight
	Highlights oUF frames by dispellable debuff type.
	Originally based on Ammo's oUF_DebuffHighlight.

	To have your frame's health bar highlighted:
		frame.DispelHighlight = true

	To use your own highlighting function:
		frame.DispelHighlight = function(frame, event, unit, debuffType, canDispel)
			-- debuffType : string or nil : type of the highest priority debuff, nil if no debuffs
			-- canDispel : boolean : indicates whether the player can dispel the debuff
		end

	To highlight only debuffs you can dispel:
		frame.DispelHighlightFilter = true

----------------------------------------------------------------------]]

if not oUF then return end
if select(4, GetAddOnInfo("oUF_DispelHighlight")) then return end

local _, playerClass = UnitClass("player")

local canDispel
if playerClass == "DRUID" then
	canDispel = { Curse = true, Poison = true }
elseif playerClass == "MAGE" then
	canDispel = { Curse = true }
elseif playerClass == "PALADIN" then
	canDispel = { Disease = true, Magic = true, Poison = true }
elseif playerClass == "PRIEST" then
	canDispel = { Disease = true, Magic = true }
elseif playerClass == "SHAMAN" then
	canDispel = { Curse = true, Disease = true, Poison = true }
end

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

------------------------------------------------------------------------

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

	if not UnitCanAssist("player", unit) then return end
	-- print("not UnitCanAssist")

	local debuffType

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

	if unitDebuffType[unit] ~= debuffType then
		-- print("unitDebuffType", unitDebuffType[unit] or "NONE", "debuffType", debuffType or "NONE")

		unitDebuffType[unit] = debuffType

		if type(self.DispelHighlight) == "function" then
			self:DispelHighlight(event, unit, debuffType, canDispel[debuffType])
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
		local o = self.PostUpdateHealth
		self.PostUpdateHealth = function(...)
			if o then o(...) end
			applyDispelHighlight(...)
		end
	end
end

local function Disable(self)
	if not self.DispelHighlight or not canDispel then return end

	self:UnregisterEvent("UNIT_AURA", Update)
end

oUF:AddElement("DispelHighlight", Update, Enable, Disable)
