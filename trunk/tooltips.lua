--[[--------------------------------------------------------------------
oUF_Phanx
Fully-featured PVE-oriented layout for oUF.

http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
http://wow.curseforge.com/addons/ouf-phanx/

Copyright © 2007–2010 Phanx < addons@phanx.net >

I, the copyright holder of this work, hereby release it into the public
domain. This applies worldwide. In case this is not legally possible:
I grant anyone the right to use this work for any purpose, without any
conditions, unless such conditions are required by law.
----------------------------------------------------------------------]]

local _, ns = ...

table.insert(ns.loadFuncs, function()

	if not ns.config.modifySpellTooltips then return end

	local MANA_COST_PATTERN = MANA_COST:replace("%d", "(%d+)")
	local MANA_COST_TEXT = MANA_COST:replace("%d", "%d%%")

	GameTooltip:HookScript("OnTooltipSetSpell", function()
		for i = 2, 4 do
			local line = _G["GameTooltipTextLeft" .. i]
			local text = line:GetText()
			if not text then return end
			local cost = text:match(MANA_COST_PATTERN)
			if cost then
				local unit = UnitInVehicle("player") and "vehicle" or "player"
				return line:SetFormattedText(MANA_COST_TEXT, floor(tonumber(cost) / UnitManaMax(unit) * 100 + 0.5))
			end
		end
	end)

end)
