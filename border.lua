--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
	Copyright © 2007–2011. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://wow.curse.com/downloads/wow-addons/details/ouf-phanx.aspx
----------------------------------------------------------------------]]

local _, ns = ...

ns.borderedObjects = { }

ns.CreateBorder = function(self, size, offset)
	if type(self) ~= "table" or not self.CreateTexture or self.BorderTextures then return end

	local t = { }

	for i = 1, 8 do
		t[i] = self:CreateTexture(nil, "ARTWORK")
		t[i]:SetTexture([[Interface\AddOns\oUF_Phanx\media\Border-SimpleSquare]])
	end

	t[1].name = "TOPLEFT"
	t[1]:SetTexCoord(0, 1/3, 0, 1/3)

	t[2].name = "TOPRIGHT"
	t[2]:SetTexCoord(2/3, 1, 0, 1/3)

	t[3].name = "TOP"
	t[3]:SetTexCoord(1/3, 2/3, 0, 1/3)

	t[4].name = "BOTTOMLEFT"
	t[4]:SetTexCoord(0, 1/3, 2/3, 1)

	t[5].name = "BOTTOMRIGHT"
	t[5]:SetTexCoord(2/3, 1, 2/3, 1)

	t[6].name = "BOTTOM"
	t[6]:SetTexCoord(1/3, 2/3, 2/3, 1)

	t[7].name = "LEFT"
	t[7]:SetTexCoord(0, 1/3, 1/3, 2/3)

	t[8].name = "RIGHT"
	t[8]:SetTexCoord(2/3, 1, 1/3, 2/3)

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
	ns.SetBorderSize(self, size, offset)
end

ns.SetBorderColor = function(self, r, g, b, a)
	local t = self.BorderTextures
	if not t then return end

	if not r or not g or not b or a == 0 then
		r, g, b = unpack(ns.config.borderColor)
	end

	for i, tex in ipairs(t) do
		tex:SetVertexColor(r, g, b)
	end
end

ns.SetBorderParent = function(self, parent)
	local t = self.BorderTextures
	if not t then return end

	for i, tex in ipairs(t) do
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

	for i, tex in ipairs(t) do
		tex:SetSize(size, size)
	end

	t[1]:SetPoint("TOPLEFT", self, -d, d)

	t[2]:SetPoint("TOPRIGHT", self, d, d)

	t[3]:SetPoint("LEFT", t[1], "TOPRIGHT")
	t[3]:SetPoint("TOPRIGHT", t[2], "TOPLEFT")

	t[4]:SetPoint("BOTTOMLEFT", self, -d, -d)

	t[5]:SetPoint("BOTTOMRIGHT", self, d, -d)

	t[6]:SetPoint("BOTTOMLEFT", t[4], "BOTTOMRIGHT")
	t[6]:SetPoint("BOTTOMRIGHT", t[5], "BOTTOMLEFT")

	t[7]:SetPoint("TOPLEFT", t[1], "BOTTOMLEFT")
	t[7]:SetPoint("BOTTOMLEFT", t[4], "TOPLEFT")

	t[8]:SetPoint("TOPRIGHT", t[2], "BOTTOMRIGHT")
	t[8]:SetPoint("BOTTOMRIGHT", t[5], "TOPRIGHT")
end
