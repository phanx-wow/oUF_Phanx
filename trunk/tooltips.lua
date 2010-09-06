--[[--------------------------------------------------------------------
	oUF_Phanx
	An oUF layout.
	by Phanx < addons@phanx.net >
	Copyright © 2008–2010 Phanx. See README file for license terms.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curseforge.com/addons/ouf-phanx/
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
