--[[--------------------------------------------------------------------
	oUF Smooth Update
	by Xuerian
	http://www.wowinterface.com/downloads/info11503-oUFSmoothUpdate.html

	Fixed by Gotan on WoWInterface
	http://pastey.net/111986

	Modified by Phanx to avoid conflicts with official version.
----------------------------------------------------------------------]]

if not oUF then return end

local smoothing = {}
local function Smooth(self, value)
	if value ~= self:GetValue() or value == 0 then
		smoothing[self] = value
	else
		smoothing[self] = nil
	end
end

local function hook(frame)
	for k, obj in pairs(frame) do
		if type(obj) == "table" and obj.smoothUpdates then
			obj.realSetValue = obj.SetValue
			obj.SetValue = Smooth
		end
	end
end

for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

local min, max = math.min, math.max
CreateFrame("Frame"):SetScript("OnUpdate", function()
	local limit = 30 / GetFramerate()
	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + min((value - cur) / 3, max(value - cur, limit))
		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end
		bar:realSetValue(new)
		if cur == value or abs(new - value) < 2 then
			bar:realSetValue(value)
			smoothing[bar] = nil
		end
	end
end)