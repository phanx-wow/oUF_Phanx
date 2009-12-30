--[[--------------------------------------------------------------------
	oUF_Phanx_ResComm
	Shows incoming resurrections using LibResComm-1.0.

	Elements handled:
		.ResCommText (FontString)

	Optional:
		.ResCommIgnoreSoulstone   (boolean) - Ignore soulstones and other self-resurrection abilities
----------------------------------------------------------------------]]

if not oUF then return end

local ResComm = LibStub("LibResComm-1.0", true)
if not ResComm then return end

------------------------------------------------------------------------