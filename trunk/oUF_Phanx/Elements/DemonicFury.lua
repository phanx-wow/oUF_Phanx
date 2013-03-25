
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF is missing!")

local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY
local WARLOCK_METAMORPHOSIS = GetSpellInfo(WARLOCK_METAMORPHOSIS)

local UpdateVisibility, Update, Path, ForceUpdate, Enable, Disable

function UpdateVisibility(self, event, unit)
	local element = self.DemonicFury

	self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
	self:UnregisterEvent("UNIT_POWER", Path)

	element:Hide()

	element.disabled = true

	if SecureCmdOptionParse("[overridebar][possessbar][vehicleui][@vehicle,exists]hide") == "hide" then
		return
	end
	if GetSpecialization() ~= SPEC_WARLOCK_DEMONOLOGY then
		return
	end

	element.disabled = nil

	element:Show()

	self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
	self:RegisterEvent("UNIT_POWER", Path)
	element:ForceUpdate()
end

function Update(self, event, unit, powerType)
	if unit ~= self.unit or (powerType and powerType ~= SPELL_POWER_DEMONIC_FURY) then return end
	if not powerType then powerType = SPELL_POWER_DEMONIC_FURY end
	local element = self.DemonicFury
	if element.disabled then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local fury = UnitPower(unit, powerType)
	local furyMax = UnitPowerMax(unit, powerType)

	element:SetMinMaxValues(0, furyMax)
	element:SetValue(fury)

	element.activated = not not UnitBuff(unit, WARLOCK_METAMORPHOSIS)

	if element.PostUpdate then
		element:PostUpdate(fury, furyMax, powerType)
	end
end

function Path(self, ...)
	return (self.DemonicFury.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self, unit)
	local element = self.DemonicFury
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility, true)
		self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
		self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

		UpdateVisibility(self, nil, "player")

		return true
	end
end

function Disable(self)
	local element = self.DemonicFury
	if element then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)

		self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateVisibility)
		self:UnregisterEvent("UNIT_ENTERING_VEHICLE", UpdateVisibility)
		self:UnregisterEvent("UNIT_EXITED_VEHICLE", UpdateVisibility)

		element:Hide()
	end
end

oUF:AddElement("DemonicFury", Path, Enable, Disable)
