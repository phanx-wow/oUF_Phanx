--[[--------------------------------------------------------------------
	oUF_RuneFrame
	Adds a rune frame to oUF frames for the player unit.
	Based on oUF/Runes.lua by Haste and RecRunes by Recluse.
----------------------------------------------------------------------]]

if not oUF then return end
if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

oUF.colors.runes = {
	{.8, 0, 0}, -- Blood
	{ 0,.8, 0}, -- Unholy
	{ 0,.8, 1}, -- Frost
	{.8, 0, 1}, -- Death
}

local function OnUpdate(self, elapsed)
	local duration = self.duration + elapsed
	if duration >= self.max then
		return self:SetScript("OnUpdate", nil)
	else
		self.duration = duration
		return self.timer:SetText(math.ceil(duration))
	end
end

local UpdateType = function(self, event, i, alt)
	local color = self.colors.runes[GetRuneType(i) or alt]

	local rune = self.RuneFrame[i]
	if rune then
		local r, g, b = color[1], color[2], color[3]
		local _, _, ready = GetRuneCooldown(i) -- rune:GetID()
		rune:SetBackdropColor(r, g, b, ready and 1 or 0.2)
	end
end

local Update = function(self, event, i, usable)
	local rune = self.RuneFrame[i]
	if rune then
		local start, duration, runeReady = GetRuneCooldown(i) -- rune:GetID()
		if runeReady then
			rune.timer:SetText(nil)
			rune.max = duration

			local r, g, b = rune:GetBackdropColor()
			rune:SetBackdropColor(r, g, b, 1)

			rune:SetScript("OnUpdate", nil)
		else
			rune.duration = GetTime() - start
			rune.max = duration

			local r, g, b = rune:GetBackdropColor()
			rune:SetBackdropColor(r, g, b, 0.2)

			rune:SetScript("OnUpdate", OnUpdate)
		end
	end
end

local function EnterCombat(self)
	if InCombatLockdown() or self.RuneFrame:IsShown() then return end

	self.RuneFrame:Show()
	self:SetHeight(self:GetHeight() + 1 + self.RuneFrame:GetHeight())
end

local function LeaveCombat(self)
	if InCombatLockdown() or not self.RuneFrame:IsShown() then return end

	self.RuneFrame:Hide()
	self:SetHeight(self:GetHeight() - 1 - self.RuneFrame:GetHeight())
end

local function Enable(self, unit)
	if not self.RuneFrame or unit ~= "player" then return end

	self.RuneFrame = CreateFrame("Frame", nil, self)
	local runes = self.RuneFrame

	runes:SetWidth(self.Health:GetWidth())
	runes:SetHeight(self.Health:GetHeight())

	runes:SetPoint("TOP", self.Health, "BOTTOM", 0, -1)

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
	self.Health:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -1)

	local runeBackdrop = { bgFile = self.Health.bg:GetTexture() }
	for i = 1, 6 do
		local r = CreateFrame("Frame", nil, runes)
		r:SetBackdrop(runeBackdrop)
		r:SetWidth((self.Health:GetWidth() - 5) / 6)
		r:SetHeight(self.Health:GetHeight())

		r.timer = r:CreateFontString(nil, "OVERLAY")
		r.timer:SetFont(self.Health.value:GetFont())
		r.timer:SetPoint("CENTER")

		r:SetID(i)
		UpdateType(self, nil, i, math.floor((i + 1) / 2))

		runes[i] = r
	end

	runes[3], runes[5] = runes[5], runes[3]
	runes[4], runes[6] = runes[6], runes[4]

	for i = 1, 6 do
		if i == 1 then
			runes[i]:SetPoint("LEFT", runes, 0, 0)
		else
			runes[i]:SetPoint("LEFT", runes[i - 1], "RIGHT", 1, 0)
		end
	end

	runes[3], runes[5] = runes[5], runes[3]
	runes[4], runes[6] = runes[6], runes[4]

	self:RegisterEvent("RUNE_POWER_UPDATE", Update)
	self:RegisterEvent("RUNE_TYPE_UPDATE", UpdateType)

	self:RegisterEvent("PLAYER_REGEN_DISABLED", EnterCombat)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", LeaveCombat)

	RuneFrame.oShow = RuneFrame.Show
	RuneFrame.Show = RuneFrame.Hide
	RuneFrame:UnregisterAllEvents()
	RuneFrame:Hide()

	return true
end

local Disable = function(self)
	self.RuneFrame:Hide()
	self:SetHeight(self:GetHeight() - 1 - self.RuneFrame:GetHeight())

	RuneFrame:RegisterEvent("RUNE_POWER_UPDATE")
	RuneFrame:RegisterEvent("RUNE_TYPE_UPDATE")
	RuneFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	RuneFrame.Show = RuneFrame.oShow
	RuneFrame:Show()
	RuneFrame_OnEvent(RuneFrame, "PLAYER_ENTERING_WORLD")

	self:UnregisterEvent("RUNE_POWER_UPDATE", Update)
	self:UnregisterEvent("RUNE_TYPE_UPDATE", UpdateType)

	self:UnregisterEvent("PLAYER_REGEN_DISABLED", EnterCombat)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED", LeaveCombat)
end

oUF:AddElement("RuneFrame", Update, Enable, Disable)