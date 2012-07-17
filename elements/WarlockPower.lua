--[[ Element: Shadow Orbs
 Toggles visibility of the players Shadow Orbs.

 Widget

 WarlockPower - An array consisting of three UI widgets.

 Notes

 The default shadow orbs texture will be applied to textures within the WarlockPower
 array that don't have a texture or color defined.

 Examples

   local WarlockPower = {}
   for index = 1, PRIEST_BAR_NUM_ORBS do
      local Orb = self:CreateTexture(nil, 'BACKGROUND')

      -- Position and size of the orb.
      Orb:SetSize(14, 14)
      Orb:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Orb:GetWidth(), 0)

      WarlockPower[index] = Orb
   end

   -- Register with oUF
   self.WarlockPower = WarlockPower

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local WARLOCK_SOULBURN = WARLOCK_SOULBURN
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS

local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
local WARLOCK_METAMORPHOSIS = WARLOCK_METAMORPHOSIS
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY

local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local WARLOCK_BURNING_EMBERS = WARLOCK_BURNING_EMBERS
local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local MAX_POWER_PER_EMBER = MAX_POWER_PER_EMBER

local Update = function(self, event, unit, powerType)
	if self.unit ~= unit or (powerType and powerType ~= "SOUL_SHARDS" and powerType ~= "BURNING_EMBERS" and powerType ~= "DEMONIC_FURY") then return end

	local element = self.WarlockPower
	if element.PreUpdate then
		element:PreUpdate()
	end

	if not powerType then
		local _
		_, powerType = UnitDisplayPower(unit)
	end

	local num, max

	-- Affliction
	if powerType == "SOUL_SHARDS" then
		num = UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
		max = UnitPowerMax(unit, SPELL_POWER_SOUL_SHARDS)

		if element.SetValue then
			element:SetMinMaxValues(0, max)
			element:SetValue(num)
		else
			for i = 1, #element do
				local shard = element[i]
				if i <= num then
					if shard.SetValue then
						shard:SetValue(1)
					end
					shard:SetAlpha(1)
					shard:Show()
				elseif i <= max then
					if shard.SetValue then
						shard:SetValue(0)
						shard:SetAlpha(1)
					else
						shard:SetAlpha(0.25)
					end
					shard:Show()
				else
					shard:Hide()
				end
			end
		end

	-- Demonology
	elseif powerType = "DEMONIC_FURY" then
		num = UnitPower(unit, SPELL_POWER_DEMONIC_FURY)
		max = UnitPowerMax(unit, SPELL_POWER_DEMONIC_FURY)

		local activated
		for i = 1, 40 do
			local name, _, _, _, _, _, _, _, _, _, spell = UnitBuff(unit, i)
			if not spell then
				break
			end
			if spell == WARLOCK_METAMORPHOSIS then
				activated = true
				break
			end
		end
		if element.SetValue then
			element:SetMinMaxValues(num, max)
			element:SetValue(num)
		else
			local parts = #element * num / max
			local wholeParts = floor(parts)
			for i = 1, #element do
				local part = element[i]
				if i <= wholeParts then
					if part.SetValue then
						part:SetValue(1)
					end
					part:SetAlpha(1)
					part:Show()
				else
					if part.SetValue then
						part:SetValue(parts - wholeParts)
						part:SetAlpha(1)
					else
						part:SetAlpha(1 - (0.75 * (parts - wholeParts)))
					end
					part:Show()
				end
			end
		end

	-- Destruction
	elseif powerType == "BURNING_EMBERS" then
		num = UnitPower(unit, SPELL_POWER_BURNING_EMBERS, true)
		max = UnitPowerMax(unit, SPELL_POWER_BURNING_EMBERS, true)

		local numWhole = math.floor(num / MAX_POWER_PER_EMBER)
		local maxWhole = math.floor(max / MAX_POWER_PER_EMBER)

		if element.SetValue then
			element:SetMinMaxValues(0, max)
			element:SetValue(num)
		else
			for i = 1, #element do
				local ember = element[i]
				if i <= numWhole then
					if ember.SetValue then
						ember:SetValue(1)
					end
					ember[i]:SetAlpha(1)
					element[i]:Show()
				elseif i == numWhole + 1 then
					local partial = num % MAX_POWER_PER_EMBER
					if ember.SetValue then
						ember:SetValue(partial)
						ember:SetAlpha(1)
					else
						ember:SetAlpha(1 - (0.75 * partial))
					end
					ember[i]:Show()
				else
					ember:Hide()
				end
			end
		end
	end

	if element.PostUpdate then
		return element:PostUpdate(num, max, powerType)
	end
end

local Visibility = function(self, event, unit)
	local spec = GetSpecialization()

	local show
	if spec == SPEC_WARLOCK_AFFLICTION then
		if IsPlayerSpell(WARLOCK_SOULBURN) then
			show = true
		else
			self.spellID = WARLOCK_SOULBURN
			self:RegisterEvent("SPELLS_CHANGED", Visibility, true)
		end
	elseif spec == SPEC_WARLOCK_DEMONOLOGY then
		show = true
	elseif spec == SPEC_WARLOCK_DESTRUCTION then
		if IsPlayerSpell(WARLOCK_BURNING_EMBERS) then
			show = true
		else
			self.spellID = WARLOCK_BURNING_EMBERS
			self:RegisterEvent("SPELLS_CHANGED", Visibility, true)
		end
	end

	local element = self.WarlockPower

	if show then
		if element.Show then
			element:Show()
		end
		element:ForceUpdate("Visibility", "player")
	else
		if element.Hide then
			element:Hide()
		else
			for i = 1, #element do
				element[i]:Hide()
			end
		end
	end
end

local Path = function(self, ...)
	return (self.WarlockPower.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self, unit)
	local element = self.WarlockPower
	if(element and unit == "player") then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_POWER", Path)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility, true)
--[[
		for index = 1, PRIEST_BAR_NUM_ORBS do
			local orb = element[index]
			if(orb:IsObjectType"Texture" and not orb:GetTexture()) then
				orb:SetTexture[[Interface\PlayerFrame\Priest-ShadowUI]]
				orb:SetTexCoord(0.45703125, 0.60546875, 0.44531250, 0.73437500)
			end
		end
]]
		return true
	end
end

local Disable = function(self)
	local element = self.WarlockPower
	if(element) then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	end
end

oUF:AddElement("WarlockPower", Path, Enable, Disable)
