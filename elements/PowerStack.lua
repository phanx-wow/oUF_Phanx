--[[
	oUF_PowerStack
	by Phanx <addons@phanx.net>
	Adds a graphical counter element for stacking self-buffs such as
	Maelstrom Weapon and Shadow Orb.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	Basic example:

		self.PowerStack = {
			buff = GetSpellInfo(53817) -- Gets localized spell name for Maelstrom Weapon
		}
		for i = 1, 5 do
			self.PowerStack[i] = CreateTexture(nil, "OVERLAY")
			self.PowerStack[i]:SetSize(20, 20)
			if i == 1 then
				self.PowerStack[i]:SetPoint("LEFT", self, "BOTTOMLEFT", 5, 0)
			else
				self.PowerStack[i]:SetPoint("LEFT", self.PowerStack[i][i-1], "RIGHT", 0, 0)
			end
		end

	Additional notes:

		This element only works for buffs on the player unit, and
		currently only supports one buff per frame.

		Spell IDs are *not* currently supported, as the WoW aura API
		does not support looking up buffs directly by ID.

		You can override the default update function by adding an
		Override key in the PowerStack element table. PreUpdate and
		PostUpdate are *not* currently supported.

		The individual objects do not have to be textures. They can also
		be frames or font strings, or even basic tables, as long as they
		have Show, Hide, SetAlpha, and IsObjectType methods.

		If the counter objects are textures, but do not have a texture
		set, they will be given the standard combo point texture.

		The buff to track can be changed dynamically (for example, when
		the player's spec changes) by the layout.
--]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_PowerStack requires oUF.")

local UnitBuff = UnitBuff

local Update = function(self, event, unit)
	if unit ~= "player" then return end

	local element = self.PowerStack
	local max = #element

	local _, _, _, count = UnitBuff("player", element.buff)
	if not count then count = 0 end

	-- print("PowerStack: Update", event, unit, element.buff, count, max)

	if count == element.prev then return end

	if count == 0 then
		for i = 1, max do
			element[i]:Hide()
		end
	else
		for i = 1, max do
			local obj = element[i]
			obj:Show()
			if i <= count then
				obj:SetAlpha(1)
			else
				obj:SetAlpha(0.25)
			end
		end
	end

	element.prev = count
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

	for i = 1, #element do
		local obj = element[i]
		if obj:IsObjectType("Texture") and not obj:GetTexture() then
			obj:SetTexture([[Interface\ComboFrame\ComboPoint]])
			obj:SetTexCoord(0, 0.375, 0, 1)
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