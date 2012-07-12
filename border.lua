--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2011 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...

ns.borderedObjects = {}

local sections = { "TOPLEFT", "TOPRIGHT", "TOP", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM", "LEFT", "RIGHT" }

ns.CreateBorder = function(self, size, offset, parent, layer)
	if type(self) ~= "table" or not self.CreateTexture or self.BorderTextures then return end

	local t = {}

	for i = 1, #sections do
		local x = self:CreateTexture(nil, layer or "ARTWORK")
		x:SetTexture([[Interface\AddOns\oUF_Phanx\media\SimpleSquare]])
		t[sections[i]] = x
	end

	t.TOPLEFT:SetTexCoord(0, 1/3, 0, 1/3)
	t.TOPRIGHT:SetTexCoord(2/3, 1, 0, 1/3)
	t.TOP:SetTexCoord(1/3, 2/3, 0, 1/3)
	t.BOTTOMLEFT:SetTexCoord(0, 1/3, 2/3, 1)
	t.BOTTOMRIGHT:SetTexCoord(2/3, 1, 2/3, 1)
	t.BOTTOM:SetTexCoord(1/3, 2/3, 2/3, 1)
	t.LEFT:SetTexCoord(0, 1/3, 1/3, 2/3)
	t.RIGHT:SetTexCoord(2/3, 1, 1/3, 2/3)

	self.BorderTextures = t

	self.SetBorderColor = ns.SetBorderColor
	self.SetBorderParent = ns.SetBorderParent
	self.SetBorderSize = ns.SetBorderSize

	do
		local backdrop = self:GetBackdrop()
		if type(backdrop) == "table" then
			if backdrop.edgeFile then
				backdrop.edgeFile = nil
			end
			if backdrop.insets then
				backdrop.insets.top = 0
				backdrop.insets.right = 0
				backdrop.insets.bottom = 0
				backdrop.insets.left = 0
			end
			self:SetBackdrop(backdrop)
		end
	end

	if self.SetBackdropBorderColor then
		self.SetBackdropBorderColor = ns.SetBorderColor
	end

	tinsert(ns.borderedObjects, self)

	ns.SetBorderColor(self)
	ns.SetBorderParent(self, parent)
	ns.SetBorderSize(self, size, offset)
end

ns.SetBorderColor = function(self, r, g, b, a)
	local t = self.BorderTextures
	if not t then return end

	if not r or not g or not b or a == 0 then
		r, g, b = unpack(ns.config.borderColor)
	end

	for pos, tex in pairs(t) do
		tex:SetVertexColor(r, g, b)
	end
end

ns.SetBorderLayer = function(self, layer)
	local t = self.BorderTextures
	if not t then return end

	for pos, tex in pairs(t) do
		tex:SetDrawLayer(layer or "ARTWORK")
	end
end

ns.SetBorderParent = function(self, parent)
	local t = self.BorderTextures
	if not t then return end

	for pos, tex in pairs(t) do
		tex:SetParent(parent or self)
	end
end

ns.SetBorderSize = function(self, size, offset)
	local t = self.BorderTextures
	if not t then return end

	if not size then
		size = ns.config.borderSize
	end

	local d = offset or (floor(size / 2 + 0.5) - 2)

	for pos, tex in pairs(t) do
		tex:SetSize(size, size)
	end

	t.TOPLEFT:SetPoint("TOPLEFT", self, -d, d)

	t.TOPRIGHT:SetPoint("TOPRIGHT", self, d, d)

	t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT")
	t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT")

	t.BOTTOMLEFT:SetPoint("BOTTOMLEFT", self, -d, -d)

	t.BOTTOMRIGHT:SetPoint("BOTTOMRIGHT", self, d, -d)

	t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT")
	t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT")

	t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT")
	t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT")

	t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT")
	t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT")
end