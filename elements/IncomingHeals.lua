--[[--------------------------------------------------------------------
	oUF_IncomingHeals
	Shows incoming heals with text and a statusbar overlay.
	Based on oUF_HealComm4 by EvilPaul, oUF_HealComm by Krage.
	Modified by Phanx to support reverse orientations, support ignoring
		HoTs, and use a texture instead of a frame.

	You may embed this module in your own layout, but please do not
		distribute it as a standalone plugin.

	Elements handled:
		.IncomingHealsBar  (Texture)
		.IncomingHealsText (FontString)

	Optional:
		.IncomingHealsFilter       (string)  - one of: SELF, OTHER, ALL
		.IncomingHealsIgnoreHoTs   (boolean) - ignore HoTs and show only direct and channeled heals
		.IncomingHealsNoOverflow   (boolean) - prevent the HealComm bar from extending beyond the end of the Health bar

	Functions that can be overridden from within a layout:
		:HealCommTextFormat        (value)  - formats the heal amount passed for display on .IncomingHealsText
----------------------------------------------------------------------]]

if not oUF then return end

local HealComm = LibStub("LibHealComm-4.0", true)
if not HealComm then return end

if select(4, GetAddOnInfo("oUF_HealComm")) then return end
if select(4, GetAddOnInfo("oUF_HealComm4")) then return end

------------------------------------------------------------------------

local unitMap = HealComm:GetGUIDUnitMapTable()

local function Hide(self)
	if self.IncomingHealsBar then
		self.IncomingHealsBar:Hide()
	end
	if self.IncomingHealsText then
		self.IncomingHealsText:SetText(nil)
	end
end

local function Update(self)
	local unit = self.unit

	if not unit or UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return Hide(self)
	end

	local maxHP = UnitHealthMax(unit) or 0
	if maxHP == 0 or maxHP == 100 then
		return Hide(self)
	end

	local guid = UnitGUID(unit)
	local incHeals
	if self.IncomingHealsFilter == "SELF" then
		incHeals = HealComm:GetHealAmount(guid, self.IncomingHealsFlag) - HealComm:GetOthersHealAmount(guid, self.IncomingHealsFlag)
	elseif self.IncomingHealsFilter == "OTHER" then
		incHeals = HealComm:GetOthersHealAmount(guid, self.IncomingHealsFlag)
	else
		incHeals = HealComm:GetHealAmount(guid, self.IncomingHealsFlag)
	end

	if not incHeals then
		return Hide(self)
	end

	incHeals = incHeals * HealComm:GetHealModifier(guid)

	if self.IncomingHealsBar then
		local curHP = UnitHealth(unit)
		local percHP = curHP / maxHP
		local percInc = (self.IncomingHealsNoOverflow and math.min(incHeals, maxHP - curHP) or incHeals) / maxHP

		self.IncomingHealsBar:ClearAllPoints()

		if self.Health:GetOrientation() == "VERTICAL" then
			self.IncomingHealsBar:SetHeight(percInc * self.Health:GetHeight())
			self.IncomingHealsBar:SetWidth(self.Health:GetWidth())
			if self.reverse then
				self.IncomingHealsBar:SetPoint("TOP", self.Health, "TOP", 0, -self.Health:GetHeight() * percHP)
			else
				self.IncomingHealsBar:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, self.Health:GetHeight() * percHP)
			end
		else
			self.IncomingHealsBar:SetHeight(self.Health:GetHeight())
			self.IncomingHealsBar:SetWidth(percInc * self.Health:GetWidth())
			if self.reverse then
				self.IncomingHealsBar:SetPoint("RIGHT", self.Health, "RIGHT", -self.Health:GetWidth() * percHP, 0)
			else
				self.IncomingHealsBar:SetPoint("LEFT", self.Health, "LEFT", self.Health:GetWidth() * percHP, 0)
			end
		end

		self.IncomingHealsBar:Show()
	end

	if self.IncomingHealsText then
		self.IncomingHealsText:SetText(self.IncomingHealsTextFormat and self.IncomingHealsTextFormat(incHeals) or format("%d", incHeals))
	end
end

local function Enable(self)
	local bar, text = self.IncomingHealsBar, self.IncomingHealsText
	if not bar and not text or not self.unit then return end

	if bar and not bar:GetTexture() then
		bar:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
	end

	self:RegisterEvent("UNIT_HEALTH", Update)
	self:RegisterEvent("UNIT_MAXHEALTH", Update)

	self.IncomingHealsFlag = self.IncomingHealsIgnoreHoTs and HealComm.CASTED_HEALS or HealComm.ALL_HEALS

	return true
end

local function Disable(self)
	local bar, text = self.IncomingHealsBar, self.IncomingHealsText
	if not bar and not text or not self.unit then return end

	if bar then
		bar:SetTexture("")
		bar:Hide()
	end
	if text then
		text:SetText(nil)
		text:Hide()
	end

	self:UnregisterEvent("UNIT_HEALTH", Update)
	self:UnregisterEvent("UNIT_MAXHEALTH", Update)
end

oUF:AddElement("IncomingHeals", Update, Enable, Disable)

------------------------------------------------------------------------

local function UpdateMultiple(...)
	for i = 1, select("#", ...) do
		for _, frame in ipairs(oUF.objects) do
			if frame.unit and (frame.IncomingHealsBar or frame.IncomingHealsText) and UnitGUID(frame.unit) == select(i, ...) then
				Update(frame)
			end
		end
	end
end

local function HealComm_Heal_Update(event, casterGUID, spellID, healType, _, ...)
	UpdateMultiple(...)
end

local function HealComm_Modified(event, casterGUID)
	UpdateMultiple(casterGUID)
end

------------------------------------------------------------------------

HealComm.RegisterCallback("oUF_IncomingHeals", "HealComm_HealStarted", HealComm_Heal_Update)
HealComm.RegisterCallback("oUF_IncomingHeals", "HealComm_HealUpdated", HealComm_Heal_Update)
HealComm.RegisterCallback("oUF_IncomingHeals", "HealComm_HealDelayed", HealComm_Heal_Update)
HealComm.RegisterCallback("oUF_IncomingHeals", "HealComm_HealStopped", HealComm_Heal_Update)
HealComm.RegisterCallback("oUF_IncomingHeals", "HealComm_ModifierChanged", HealComm_Modified)
HealComm.RegisterCallback("oUF_IncomingHeals", "HealComm_GUIDDisappeared", HealComm_Modified)

------------------------------------------------------------------------