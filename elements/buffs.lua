--[[--------------------------------------------------------------------
	oUF_BuffReminder
	by Phanx < addons@phanx.net >
	Shows buffs you should cast on oUF party frames.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	To enable:
		self.BuffReminder = self.Health:CreateTexture(nil, "OVERLAY")
		self.BuffReminder:SetPoint("CENTER", self)
		self.BuffReminder:SetSize(20, 20)
----------------------------------------------------------------------]]

local buffs, icon
local playerClass = select(2, UnitClass("player"))

local buffcheck = function(unit)
	local found
	for _, buff in ipairs(buffs) do
		if UnitBuff(unit, buff) then
			found = true
			break
		end
	end
	if not found then return icon end
end

if playerClass == "DRUID" then

	buffs = { (GetSpellInfo(48470)), (GetSpellInfo(48469)) } -- Gift, Mark
	icon = select(3, GetSpellInfo(48469))

elseif playerClass == "MAGE" then

	buffs = { (GetSpellInfo(23028)), (GetSpellInfo(61316)), (GetSpellInfo(1459)), (GetSpellInfo(61024)) } -- Brilliance, Dalaran Brilliance, Intellect, Dalaran Intellect
	icon = select(3, GetSpellInfo(1459))

elseif playerClass == "PALADIN" then

	buffs = { (GetSpellInfo(20217)), (GetSpellInfo(19740)), (GetSpellInfo(19742)), (GetSpellInfo(20911)) } -- Kings, Might, Wisdom, Sanctuary
	icon = select(3, GetSpellInfo(20217))

	buffcheck = function(unit)
		local found
		local numBlessings = 0
		for _, buff in ipairs(spells) do
			local exists, _, _, _, _, _, _, caster = UnitBuff(unit, buff)
			if exists then
				numBlessings = numBlessings + 1
				if UnitIsUnit(caster, "player") then
					found = true
				end
			end
		end
		if not found and numBlessings < 2 then
			return icon
		end
	end

elseif playerClass == "PRIEST" then

	buffs = { (GetSpellInfo(48162)), (GetSpellInfo(1243)) } -- Prayer, Power Word
	icon = select(3, GetSpellInfo(1243))

end

if not buffs then return end

local Update = function(self, event, unit)
	if unit and unit ~= self.unit then return end
	if not unit then unit = self.unit end

	if event == "PLAYER_REGEN_DISABLED" then
		print("BuffReminder Hide")
		return self.BuffReminder:SetTexture(nil)
	end

	print("BuffReminder Update", event, unit)

	self.BuffReminder:SetTexture(buffcheck(unit))
end

local Enable = function(self)
	if not self.BuffReminder or not self.BuffReminder.IsObjectType or not self.BuffReminder:IsObjectType("texture") then return end

	self:RegisterEvent("UNIT_AURA", Update)
end

local Disable = function(self)
	if not self.BuffReminder or not self.BuffReminder.IsObjectType or not self.BuffReminder:IsObjectType("texture") then return end

	self:UnregisterEvent("UNIT_AURA", Update)
end

oUF:AddElement("BuffReminder", Update, Enable, Disable)
