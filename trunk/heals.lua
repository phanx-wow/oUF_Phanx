--[[--------------------------------------------------------------------
	oUF_HealBars
	Displays incoming health overlaid on oUF health bars.
	Based on oUF_HealEstimation, with permission from Sonomus.
----------------------------------------------------------------------]]

if select(4, GetAddOnInfo("oUF_HealComm")) then return end

assert(oUF, "oUF_IncomingHealth requires oUF!")

local HealComm = LibStub("LibHealComm-3.0", true)
assert(HealComm, "oUF_IncomingHealth requires LibHealComm-3.0!")

------------------------------------------------------------------------

local otherHealsColor =	{ 0, .781, 0, .3 }

local myOverHealColor = {
	[0]		= {   0,   1,   0,  .4 },
	[25]	= {   0,  .5,   0,  .4 },
	[50]	= {   1,   1,   0,  .5 },
	[75]	= {   1, .25,   0,  .5 },
	[100]	= {   1,   0,   0,  .6 }
}

local oUF_HealBars = {}

local playerName = UnitName("player")

local playerHealSize = 0
local playerHealLand = nil

local objects = { }

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local floor = math.floor
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local SecureButton_GetUnit = SecureButton_GetUnit
local curHP, maxHP, percHP, preHeal, postHeal, unitName, unit

local fullUnitName = function(unit)
	local name, server = UnitName(unit)
	if server then name = name.."-"..server end
	return name
end

local horizontalUpdate = function(frame, i, percInc, percHP)
	local w = percInc * frame.Health:GetWidth()
	if (w == 0) then
		w = 0.001
	end
	frame.HealEstimation.bars[i]:SetWidth(w)
	if (i == 1) then
		if frame.reverse then
			local w = frame.Health:GetWidth()
			frame.HealEstimation.bars[1]:SetPoint("RIGHT", frame.Health, "LEFT", w - (w * percHP), 0)
		else
			frame.HealEstimation.bars[1]:SetPoint("LEFT", frame.Health, "LEFT", frame.Health:GetWidth() * percHP, 0)
		end
	end
end

local verticalUpdate = function(frame, i, percInc, percHP)
	local h = percInc * frame.Health:GetHeight()
	if (h == 0) then h = 0.001 end
	frame.HealEstimation.bars[i]:SetHeight(h)
	if (i == 1) then
		if frame.reverse then
			local w = frame.Health:GetWidth()
			frame.HealEstimation.bars[1]:SetPoint("TOP", frame.Health, 0, "BOTTOM", w - (w * percHP))
		else
			frame.HealEstimation.bars[1]:SetPoint("BOTTOM", frame.Health, "BOTTOM", 0, frame.Health:GetHeight() * percHP)
		end
	end
end

local updatePlayerHealColor = function(maxHP, curHP, preHeal)
	local colorIndex = 0 -- Assume no overheal
	local hpMissing = maxHP - curHP - preHeal
	if hpMissing <= 0 then -- Full overheal
		colorIndex = 100
	else
		local percOH = hpMissing / playerHealSize
		if (percOH < 1) then
			colorIndex = 100 - ( floor((percOH + 0.125) * 4)*25 )
		end
	end
	return myOverHealColor[colorIndex]
end

local updateHealEstimationBars = function(...)
	local incHeal = {}
	for i = 1, select("#", ...) do
		unitName = fullUnitName( select(i, ...) )
		if unitName then
			curHP = UnitHealth(unitName)
			maxHP = UnitHealthMax(unitName)
			percHP = curHP / maxHP
			preHeal, postHeal = HealComm:UnitIncomingHealGet(unitName, playerHealLand or (GetTime() + 3))
			preHeal = preHeal or 0
			postHeal = postHeal or 0
			for _, object in pairs(objects) do
				local unit = SecureButton_GetUnit(object)
				if unit and fullUnitName(unit) == unitName then
					object.HealEstimation.SetHPValue(object, 1, preHeal/maxHP, percHP)

					object.HealEstimation.anyActive = false
					object.HealEstimation.preHeal = preHeal
					if preHeal > 0 then
						object.HealEstimation.bars[1]:Show()
						object.HealEstimation.anyActive = true
					else
						object.HealEstimation.bars[1]:Hide()
					end

					if object.HealEstimation.playerIsHealing then
						object.HealEstimation.SetHPValue(object, 2, playerHealSize/maxHP, percHP)
						object.HealEstimation.bars[2].texture:SetVertexColor(
							unpack(updatePlayerHealColor(maxHP, curHP, preHeal))
						)
						object.HealEstimation.bars[2]:Show()
						object.HealEstimation.anyActive = true
						postHeal = postHeal - playerHealSize
					else
						object.HealEstimation.bars[2]:Hide()
					end

					if postHeal > 0 then
						object.HealEstimation.SetHPValue(object, 3, postHeal/maxHP, percHP)
						object.HealEstimation.bars[3]:Show()
						object.HealEstimation.anyActive = true
					else
						object.HealEstimation.bars[3]:Hide()
					end
	            end
	        end
		end
	end
end

local unitHealthUpdate = function(object, unit)
	if not unit then return end
	if not object.HealEstimation.anyActive then return end

	if UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) or not(object.HealEstimation.playerIsHealing or select(3, HealComm:UnitIncomingHealGet(fullUnitName(unit), (GetTime() + 4)))) then
		object.HealEstimation.bars[1]:Hide()
		object.HealEstimation.bars[2]:Hide()
		object.HealEstimation.bars[3]:Hide()
		object.HealEstimation.anyActive = false
	else
		curHP = UnitHealth(unit)
		maxHP = UnitHealthMax(unit)
		percHP = curHP / maxHP
		if (object.HealEstimation.playerIsHealing) then
			object.HealEstimation.bars[2].texture:SetVertexColor(
				unpack(updatePlayerHealColor(maxHP, curHP, object.HealEstimation.preHeal	))
			)
		end
		object.HealEstimation.SetHPValue(object, 1, object.HealEstimation.preHeal/maxHP, percHP)
	end
end

local function hook(frame)
	if frame.ignoreHealEstimation or frame.ignoreIncomingHeal or not frame.Health then return end

	tinsert(objects, frame)

	local heb = { }
	heb.bars = { }
	local last = frame.Health

	for i = 1, 3 do
		local bar = CreateFrame("Frame", nil, frame)
		bar:SetFrameLevel(10)
		bar.texture = bar:CreateTexture(nil, "BORDER")
		bar.texture:SetTexture(frame.Health:GetStatusBarTexture():GetTexture())
		bar.texture:SetTexCoord(frame.Health:GetStatusBarTexture():GetTexCoord())
		bar.texture:SetVertexColor(unpack(otherHealsColor))
		bar.texture:SetAllPoints(bar)
		bar:SetParent(frame)

		if ( frame.Health:GetOrientation() == "VERTICAL" ) then
			bar:SetHeight(20)
			bar:SetWidth(frame.Health:GetWidth()) -- Same size as the Health bar
			if frame.reverse then
				bar:SetPoint("TOP", last, "BOTTOM") -- Assume the bar grows upwards
			else
				bar:SetPoint("BOTTOM", last, "TOP") -- Assume the bar grows upwards
			end
		else
			bar:SetHeight(frame.Health:GetHeight()) -- Same size as the Health bar
			bar:SetWidth(20)
			if frame.reverse then
				bar:SetPoint("RIGHT", last, "LEFT")
			else
				bar:SetPoint("LEFT", last, "RIGHT") -- Assume the bar grows towards right
			end
		end
		bar:Hide()
		last = bar

		heb.bars[i] = bar
	end

	if ( frame.Health:GetOrientation() == "HORIZONTAL" ) then
		heb.SetHPValue = horizontalUpdate
	else
		heb.SetHPValue = verticalUpdate
	end

    frame.HealEstimation = heb

	local o = frame.PostUpdateHealth
	frame.PostUpdateHealth = function(...)
		if o then o(...) end
		unitHealthUpdate(frame, fullUnitName(frame.unit)) -- When HP is updated, update color and hide outdated bars
	end
end

-- Append to all existing frames
for object in pairs(oUF.objects) do hook(object) end

-- Append to frames created later on
oUF:RegisterInitCallback(hook)

--set up LibHealComm callbacks
function oUF_HealBars:HealComm_DirectHealStart(event, healerName, healSize, endTime, ...)
	if healerName == playerName then
		for i = 1, select("#", ...) do
			unitName = select(i, ...)
	        -- Mark all frames we are healing
	        for _,object in pairs(objects) do
				unit = SecureButton_GetUnit(object)
	            if unit and fullUnitName(unit) == unitName then
	                object.HealEstimation.playerIsHealing = true
	            end
	        end
		end
		playerHealLand = endTime
		playerHealSize = healSize
	end
    updateHealEstimationBars(...)
end

function oUF_HealBars:HealComm_DirectHealUpdate(event, healerName, healSize, endTime, ...)
	if healerName == playerName then
		playerHealLand = endTime
		playerHealSize = healSize
	end
    updateHealEstimationBars(...)
end

function oUF_HealBars:HealComm_DirectHealStop(event, healerName, healSize, succeeded, ...)
	if healerName == playerName then
		-- Clear all player is healing flags
		for _,object in pairs(objects) do
			if object.HealEstimation then
				object.HealEstimation.playerIsHealing = false
			end
		end
		playerHealLand = nil
		playerHealSize = 0
	end
    updateHealEstimationBars(...)
end

function oUF_HealBars:HealComm_HealModifierUpdate(event, unit, targetName, healModifier)
    updateHealEstimationBars(unit)
end

HealComm.RegisterCallback(oUF_HealBars, "HealComm_DirectHealStart")
HealComm.RegisterCallback(oUF_HealBars, "HealComm_DirectHealUpdate")
HealComm.RegisterCallback(oUF_HealBars, "HealComm_DirectHealStop")
HealComm.RegisterCallback(oUF_HealBars, "HealComm_HealModifierUpdate")
