--[[--------------------------------------------------------------------
	oUF_Phanx_HealComm
	Shows incoming heals with text and a statusbar overlay.
	Based on oUF_HealComm4 by EvilPaul, oUF_HealComm by Krage.
	Modified by Phanx to support reverse orientations and ignoring HoTs.
	Distributed with oUF_Phanx with permission from EvilPaul.

	Elements handled:
		.HealCommBar  (Texture)
		.HealCommText (FontString)

	Optional:
		.HealCommFilter       (string)  - SELF, OTHER, ALL
		.HealCommIgnoreHoTs   (boolean) - Ignore HoTs and show only direct and channeled heals
		.HealCommNoOverflow   (boolean) - Prevent the HealComm bar from extending beyond the end of the Health bar

	Functions that can be overridden from within a layout:
		:HealCommTextFormat   (value) - Formats the heal amount passed for display on .HealCommText
----------------------------------------------------------------------]]

if not oUF then return end

local HealComm = LibStub("LibHealComm-4.0", true)
if not HealComm then return end

if select(4, GetAddOnInfo("oUF_HealComm")) then return end
if select(4, GetAddOnInfo("oUF_HealComm4")) then return end

------------------------------------------------------------------------

local unitMap = HealComm:GetGUIDUnitMapTable()

local function Hide(self)
	if self.HealCommBar then
		self.HealCommBar:Hide()
	end
	if self.HealCommText then
		self.HealCommText:SetText(nil)
	end
end

local function Update(self)
	if not self.unit or UnitIsDeadOrGhost(self.unit) or not UnitIsConnected(self.unit) then
		return Hide(self)
	end

	local maxHP = UnitHealthMax(self.unit) or 0
	if maxHP == 0 or maxHP == 100 then
		return Hide(self)
	end

	local guid = UnitGUID(self.unit)
	local incHeals = 0
	if self.HealCommFilter = "SELF" then
		incHeals = HealComm:GetHealAmount(guid, self.HealCommFlag) - HealComm:GetOthersHealAmount(guid, self.HealCommFlag)
	elseif self.HealCommFilter = "OTHER" then
		incHeals = HealComm:GetOthersHealAmount(guid, self.HealCommFlag)
	else
		incHeals = HealComm:GetHealAmount(guid, self.HealCommFlag)
	end
	if incHeals == 0 then
		return Hide(self)
	end

	incHeals = incHeals * HealComm:GetHealModifier(guid)

	if self.HealCommBar then
		local curHP = UnitHealth(self.unit)
		local percHP = curHP / maxHP
		local percInc = (self.HealCommNoOverflow and math.min(incHeals, maxHP - curHP) or incHeals) / maxHP

		self.HealCommBar:ClearAllPoints()

		if self.Health:GetOrientation() == "VERTICAL" then
			self.HealCommBar:SetHeight(percInc * self.Health:GetHeight())
			self.HealCommBar:SetWidth(self.Health:GetWidth())
			if self.reverse then
				self.HealCommBar:SetPoint("TOP", self.Health, "TOP", 0, -self.Health:GetHeight() * percHP)
			else
				self.HealCommBar:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, self.Health:GetHeight() * percHP)
			end
		else
			self.HealCommBar:SetHeight(self.Health:GetHeight())
			self.HealCommBar:SetWidth(percInc * self.Health:GetWidth())
			if self.reverse then
				self.HealCommBar:SetPoint("RIGHT", self.Health, "RIGHT", -self.Health:GetWidth() * percHP, 0)
			else
				self.HealCommBar:SetPoint("LEFT", self.Health, "LEFT", self.Health:GetWidth() * percHP, 0)
			end
		end

		self.HealCommBar:Show()
	end

	if self.HealCommText then
		self.HealCommText:SetText(self.HealCommTextFormat and self.HealCommTextFormat(incHeals) or format("%d", incHeals))
	end
end

local function Enable(self)
	local bar, text = self.HealCommBar, self.HealCommText
	if not bar and not text or not self.unit then return end

	if bar then
		self:RegisterEvent("UNIT_HEALTH", Update)
		self:RegisterEvent("UNIT_MAXHEALTH", Update)

		if not bar:GetStatusBarTexture() then
			bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		self.HealCommFlag = self.HealCommIgnoreHoTs and HealComm.CASTED_HEALS or HealComm.ALL_HEALS
	end

	return true
end

local function Disable(self)
	if self.unit and (self.HealCommBar or self.HealCommText) then
		self:UnregisterEvent("UNIT_HEALTH", Update)
		self:UnregisterEvent("UNIT_MAXHEALTH", Update)
	end
end

oUF:AddElement("HealComm", Update, Enable, Disable)

------------------------------------------------------------------------

local function UpdateMultiple(...)
	for i = 1, select("#", ...) do
		for _, frame in ipairs(oUF.objects) do
			if frame.unit and (frame.HealCommBar or frame.HealCommText) and UnitGUID(frame.unit) == select(i, ...) then
				Update(frame)
			end
		end
	end
end

local function HealComm_Heal_Update(event, casterGUID, spellID, healType, _, ...)
	UpdateMultiple(...)
end

local function HealComm_Modified(event, guid)
	UpdateMultiple(guid)
end

------------------------------------------------------------------------

HealComm.RegisterCallback("oUF_HealComm4", "HealComm_HealStarted", HealComm_Heal_Update)
HealComm.RegisterCallback("oUF_HealComm4", "HealComm_HealUpdated", HealComm_Heal_Update)
HealComm.RegisterCallback("oUF_HealComm4", "HealComm_HealDelayed", HealComm_Heal_Update)
HealComm.RegisterCallback("oUF_HealComm4", "HealComm_HealStopped", HealComm_Heal_Update)
HealComm.RegisterCallback("oUF_HealComm4", "HealComm_ModifierChanged", HealComm_Modified)
HealComm.RegisterCallback("oUF_HealComm4", "HealComm_GUIDDisappeared", HealComm_Modified)

------------------------------------------------------------------------