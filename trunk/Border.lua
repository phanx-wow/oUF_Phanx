--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
----------------------------------------------------------------------]]

local _, ns = ...

ns.borderedObjects = {}

local sections = { "TOPLEFT", "TOPRIGHT", "TOP", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM", "LEFT", "RIGHT" }

function ns.CreateBorder(self, size, offset, parent, layer)
	if type(self) ~= "table" or not self.CreateTexture or self.BorderTextures then return end

	local t = {}

	for i = 1, #sections do
		local x = self:CreateTexture(nil, layer or "ARTWORK")
		--x:SetTexture([[Interface\AddOns\oUF_Phanx\media\SimpleSquare]])
		x:SetTexture([[Interface\AddOns\PhanxMedia\LerbUI\bordernp]])
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

	local glow = self:CreateTexture(nil, "BACKGROUND")
	glow:SetPoint("CENTER")
	glow:SetTexture([[Interface\AddOns\oUF_Phanx\media\frameGlow]])
	glow:SetWidth(self:GetWidth() / 225 * 256)
	glow:SetHeight(self:GetHeight() / 30 * 64)
	glow:Hide()
	self.Glow = glow

	return true
end

function ns.SetBorderColor(self, r, g, b, a, glow)
	local t = self.BorderTextures
	if not t then return end

	if not r or not g or not b or a == 0 then
		r, g, b = unpack(ns.config.borderColor)
	end

	for pos, tex in pairs(t) do
		tex:SetVertexColor(r, g, b)
	end

	if self.Glow then
		if glow then
			self.Glow:SetVertexColor(r, g, b, a)
			self.Glow:Show()
		else
			self.Glow:SetVertexColor(1, 1, 1, 1)
			self.Glow:Hide()
		end
	end
end

function ns.SetBorderLayer(self, layer)
	local t = self.BorderTextures
	if not t then return end

	for pos, tex in pairs(t) do
		tex:SetDrawLayer(layer or "ARTWORK")
	end
end

function ns.SetBorderParent(self, parent)
	local t = self.BorderTextures
	if not t then return end

	for pos, tex in pairs(t) do
		tex:SetParent(parent or self)
	end
end

function ns.SetBorderSize(self, size, offset)
	local t = self.BorderTextures
	if not t then return end

	if not size then
		size = ns.config.borderSize * 2
	end

	local d = offset or floor(size * 0.25 + 0.5) -- (floor(size / 2 + 0.5) - 2)

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

	if self.SetHitRectInsets then
		local x = floor(size * 0.2)
		self:SetHitRectInsets(-x, -x, -x, -x)
	end
end