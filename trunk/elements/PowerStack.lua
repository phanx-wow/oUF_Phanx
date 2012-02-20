--[[
	oUF_PowerStack
	by Phanx <addons@phanx.net>
	Adds a graphical counter element for Maelstrom Weapon or Shadow Orb.
--]]

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local UnitBuff = UnitBuff

local prev = 0

local Update = function(self, event, unit)
	if unit ~= "player" then return end

	local element = self.PowerStack

	local _, _, _, count = UnitBuff("player", element.buffName)
	if not count then count = 0 end

	if count == prev then return end

	if count == 0 then
		for i = 1, #element do
			element[i]:Hide()
		end
	else
		for i = 1, #element do
			local obj = element[i]
			obj:Show()
			if i <= count then
				obj:SetAlpha(1)
			else
				obj:SetAlpha(0.25)
			end
		end
	end
end

local Path = function(self, ...)
	return (self.PowerStack.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(self)
	local element = self.PowerStack
	if not element then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent("UNIT_AURA", Path)

	for i = 1, 5 do
		local e = elements[i]
		if e:IsObjectType("Texture") and not e:GetTexture() then
			e:SetTexture([[Interface\ComboFrame\ComboPoint]])
			e:SetTexCoord(0, 0.375, 0, 1)
		end
	end

	return true
end

local Disable = function(self)
	local element = self.PowerStack
	if not element then return end

	self:UnregisterEvent("UNIT_AURA", Path)
end

oUF:AddElement("PowerStack", Path, Enable, Disable)