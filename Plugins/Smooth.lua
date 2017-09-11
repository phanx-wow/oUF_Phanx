local NAME, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, NAME.." was unable to locate oUF install.")

local f = CreateFrame('Frame')
local smoothing = {}
local abs, min, max, next = math.abs, math.min, math.max, next

f:SetScript('OnUpdate', function()
	local limit = 30 / GetFramerate()
	for bar, value in next, smoothing do
		local cur = bar:GetValue()
		local new = cur + min((value-cur)/3, max(value-cur, limit))
		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end
		bar:SetValue_(new)
		if cur == value or abs(new - value) < 2 then
			bar:SetValue_(value)
			smoothing[bar] = nil
		end
	end
end)

local function Smooth(self, value)
	local cur = self:GetValue()
	local _, max = self:GetMinMaxValues()
	if value == cur or (self._max and self._max ~= max) or (abs(value - cur) / max > 0.5) then
		smoothing[self] = nil
		self:SetValue_(value)
	else
		smoothing[self] = value
	end
	self._max = max
end

local function SmoothBar(self, bar, unset)
	if unset and bar.SetValue_ then
		bar.SetValue = bar.SetValue_
		bar.SetValue_ = nil
	elseif not unset and not bar.SetValue_ then
		bar.SetValue_ = bar.SetValue
		bar.SetValue = Smooth
	end
end

oUF:RegisterMetaFunction('SmoothBar', SmoothBar)
