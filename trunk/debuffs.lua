--[[--------------------------------------------------------------------
	oUF_SmartDebuffHighlight
	Colors oUF health bars according to debuff type.

	To activate this functionality for your frame:

		self.DebuffHighlight = true

	To handle debuff indication yourself instead of having the health
	bar colored:

		self.DebuffHighlight = function(self, unit)
			-- do stuff here
		end
	
	The current debuffs on your frame's unit will be stored in your
	frame's "hasDebuff" key:

		self.hasDebuff = {
			Curse = true,
			Disease = false,
			Magic = false,
			Poison = false,
		}

----------------------------------------------------------------------]]

if not oUF then return end
if select(4, GetAddOnInfo("oUF_DebuffHighlight")) then return end

------------------------------------------------------------------------

local dispellable = {
	PRIEST = { Disease = true, Magic = true, },
	SHAMAN = { Curse = true, Disease = true, Poison = true, },
	PALADIN = { Disease = true, Magic = true, Poison = true, },
	MAGE = { Curse = true, },
	DRUID = { Curse = true, Poison = true, }
}
dispellable = dispellable[select(2, UnitClass("player"))] or { }

------------------------------------------------------------------------

local DispelPriority = {
	Curse = 2,
	Disease = 4,
	Magic = 1,
	Poison = 3,
}
do
	local t = { }
	for type in pairs(DispelPriority) do
		table.insert(t, type)
		t[type] = (dispellable[type] and 10 or 5) - DispelPriority[type]
	end
	table.sort(t, function(a, b) return t[a] > t[b] end)
	DispelPriority = t
end

------------------------------------------------------------------------

local DebuffTypeColor = { }
do
	for type, color in pairs(_G.DebuffTypeColor) do
		DebuffTypeColor[type] = { color.r, color.g, color.b }
	end
end

------------------------------------------------------------------------

local unpack = unpack

local validUnits = { }

------------------------------------------------------------------------

local function applyDebuffHighlight(frame, event, unit, bar)
	if not validUnits[unit] then return end

	for i, type in ipairs(DispelPriority) do
		if frame.hasDebuff[type] then
			bar:SetStatusBarColor(unpack(DebuffTypeColor(type)))
			return
		end
	end
end

------------------------------------------------------------------------

local function hook(frame)
	if frame.unit then
		if string.find(frame.unit, "target") then return end
		validUnits[frame.unit] = true
	end

	frame.hasDebuff = { Curse = false, Disease = false, Magic = false, Poison = false }
	frame.DebuffPriority = DispelPriority

	if type(frame.DebuffHighlight) == "function" then
		return
	end

	local o = frame.PostUpdateHealth
	frame.PostUpdateHealth = function(...)
		if o then o(...) end
		if validUnits[unit] then
			applyDebuffHighlight(...)
		end
	end
end
for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

------------------------------------------------------------------------

local hasDebuff = { }

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:SetScript("OnEvent", function(self, event, unit)
	if not validUnits[unit] then return end
	if not UnitCanAssist("player", unit) then return end

	local frame = oUF.units[unit]
	if not frame then return end

	if event == "UNIT_AURA" then
		wipe(hasDebuff)

		local i = 1
		while true do
			local _, _, texture, _, type = UnitAura(unit, i, "HARMFUL")
			if not texture then break end
			if type then
				-- debug("hasDebuff: " .. type)
				hasDebuff[type] = true
			end
			i = i + 1
		end

		local change
		for type, old in pairs(frame.hasDebuff) do
			local new = hasDebuff[type]
			if (old and not new) or (not old and new) then
				frame.hasDebuff[type] = new or false
				change = true
			end
		end

		if change then
			if type(frame.DebuffHighlight) == "function" then
				frame:DebuffHighlight(event, unit)
			else
				applyDebuffHighlight(frame, event, unit, frame.Health)
			end
		end
	elseif event == "UNIT_HEALTH" then
		if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
			local change
			for type, active in pairs(frame.hasDebuff) do
				if active then
					frame.hasDebuff[type] = false
					change = true
				end
			end
			if change then
				if type(frame.DebuffHighlight) == "function" then
					frame:DebuffHighlight(event, unit)
				else
					applyDebuffHighlight(frame, event, unit, frame.Health)
				end
			end
		end
	end
end)

------------------------------------------------------------------------