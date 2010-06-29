--[[--------------------------------------------------------------------
	oUF_Phanx_GlobalCooldown
	Based on oUF_GCD by Exactly of Turalyon US

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	Elements handled:
		.GlobalCooldown         (table)
		.GlobalCooldown.spark   (texture)

	Optional:
		.GlobalCooldown.spell   (number)   - Spell ID to use instead of autodetection

	Example:
		local gcd = CreateFrame("Frame", nil, self.Power)
		gcd:SetAllPoints(self.Power)

		gcd.spark = gcd:CreateTexture(nil, "OVERLAY")
		gcd.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		gcd.spark:SetBlendMode("ADD")
		gcd.spark:SetHeight(gcd:GetHeight() * 5)
		gcd.spark:SetWidth(10)

		self.GlobalCooldown = gcd
----------------------------------------------------------------------]]

local start, duration, referenceSpell = 0, 0

local checkSpells = {
	43308, -- Find Fish
	2383,  -- Find Herbs
	2580,  -- Find Minerals
	2481,  -- Find Treasure

	49892, -- Death Coil
	66215, -- Blood Strike
	5176,  -- Wrath
	1978,  -- Serpent Sting
	5504,  -- Conjure Water
	19740, -- Blessing of Might
	585,   -- Smite
	1752,  -- Sinister Strike
	331,   -- Healing Wave
	172,   -- Corruption
	772,   -- Rend
}

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("SPELLS_CHANGED")
f:SetScript("OnEvent", function(self)
	for i, id in ipairs(checkSpells) do
		local name = GetSpellInfo(id)
		if name and GetSpellInfo(name) then
			referenceSpell = name
			break
		end
	end
	if referenceSpell then
		self:UnregisterAllEvents()
		self:SetScript("OnEvent", nil)
		checkSpells = nil
	end
end)

local function OnUpdate(self)
	local perc = (GetTime() - startTime) / duration
	if perc < 1 then
		self.spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * perc, 0)
	else
		self:Hide()
	end
end

local function Update(self)
	if referenceSpell then
		startTime, duration = GetSpellCooldown(referenceSpell)
		if not startTime then return end
		if not duration then duration = 0 end

		if (duration <= 0 or duration > 1.5) and self.GlobalCooldown:IsShown() then
			self.GlobalCooldown:Hide()
		else
			self.GlobalCooldown:Show()
		end
	end
end

local function Enable(self)
	if self.unit ~= "player" or not self.GlobalCooldown then return end

	local gcd = self.GlobalCooldown
	if not gcd.spark then
		gcd.spark = gcd:CreateTexture(nil, "OVERLAY")
	end
	if not gcd.spark:GetTexture() then
		gcd.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		gcd.spark:SetBlendMode("ADD")
		gcd.spark:SetHeight(gcd:GetHeight() * 5)
		gcd.spark:SetWidth(10)
	end

	gcd:Hide()
	gcd:SetScript("OnUpdate", OnUpdate)
	gcd.startTime = 0
	gcd.duration = 0

    self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Update)

    return true
end

local function Disable(self)
	if self.unit ~= "player" or not self.GlobalCooldown then return end

	self.GlobalCooldown:Hide()
	self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Update)
end

oUF:AddElement("GlobalCooldown", Update, Enable, Disable)
