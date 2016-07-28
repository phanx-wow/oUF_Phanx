--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
----------------------------------------------------------------------]]

local _, ns = ...

ns.borderedObjects = {}

local sections = { "TOPLEFT", "TOPRIGHT", "TOP", "BOTTOMLEFT", "BOTTOMRIGHT", "BOTTOM", "LEFT", "RIGHT" }

------------------------------------------------------------------------

local function SetBorderColor(self, r, g, b, a, glow)
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

local function GetBorderColor(self)
	return self.BorderTextures and self.BorderTextures.TOPLEFT:GetVertexColor()
end

------------------------------------------------------------------------

local function SetBorderLayer(self, layer)
	local t = self.BorderTextures
	if not t then return end

	for pos, tex in pairs(t) do
		tex:SetDrawLayer(layer or "ARTWORK")
	end
end

local function GetBorderLayer(self)
	return self.BorderTextures and self.BorderTextures.TOPLEFT:GetDrawLayer()
end

------------------------------------------------------------------------

local function SetBorderParent(self, parent)
	local t = self.BorderTextures
	if not t then return end
	if not parent then
		parent = type(self.overlay) == "Frame" and self.overlay or self
	end
	for pos, tex in pairs(t) do
		tex:SetParent(parent)
	end
	self:SetBorderSize(self:GetBorderSize())
end

local function GetBorderParent(self)
	return self.BorderTextures and self.BorderTextures.TOPLEFT:GetParent()
end

------------------------------------------------------------------------

local function SetBorderSize(self, size, dL, dR, dT, dB)
	local t = self.BorderTextures
	if not t then return end

	size = size or ns.config.borderSize
	dL, dR, dT, dB = dL or t.LEFT.offset or 0, dR or t.RIGHT.offset or 0, dT or t.TOP.offset or 0, dB or t.BOTTOM.offset or 0

	for pos, tex in pairs(t) do
		tex:SetSize(size, size)
	end

	local d = floor(size * 7 / 16 + 0.5)
	local parent = t.TOPLEFT:GetParent()

	t.TOPLEFT:SetPoint("TOPLEFT", parent, -d - dL, d + dT)
	t.TOPRIGHT:SetPoint("TOPRIGHT", parent, d + dR, d + dT)
	t.BOTTOMLEFT:SetPoint("BOTTOMLEFT", parent, -d - dL, -d - dB)
	t.BOTTOMRIGHT:SetPoint("BOTTOMRIGHT", parent, d + dR, -d - dB)

	t.LEFT.offset, t.RIGHT.offset, t.TOP.offset, t.BOTTOM.offset = dL, dR, dT, dB
end

local function GetBorderSize(self)
	local t = self.BorderTextures
	if not t then return end
	return t.TOPLEFT:GetWidth(), t.LEFT.offset, t.RIGHT.offset, t.TOP.offset, t.BOTTOM.offset
end

------------------------------------------------------------------------

function ns.CreateBorder(self, size, offset, parent, layer)
	if type(self) ~= "table" or not self.CreateTexture or self.BorderTextures then return end

	local t = {}

	for i = 1, #sections do
		local x = self:CreateTexture(nil, layer or "ARTWORK")
		x:SetTexture([[Interface\AddOns\oUF_Phanx\media\SimpleSquare]])
		t[sections[i]] = x
	end

	t.TOPLEFT:SetTexCoord(0, 1/3, 0, 1/3)
	t.TOP:SetTexCoord(1/3, 2/3, 0, 1/3)
	t.TOPRIGHT:SetTexCoord(2/3, 1, 0, 1/3)
	t.RIGHT:SetTexCoord(2/3, 1, 1/3, 2/3)
	t.BOTTOMRIGHT:SetTexCoord(2/3, 1, 2/3, 1)
	t.BOTTOM:SetTexCoord(1/3, 2/3, 2/3, 1)
	t.BOTTOMLEFT:SetTexCoord(0, 1/3, 2/3, 1)
	t.LEFT:SetTexCoord(0, 1/3, 1/3, 2/3)

	t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT")
	t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT")

	t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT")
	t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT")

	t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT")
	t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT")

	t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT")
	t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT")

	self.BorderTextures = t

	self.SetBorderColor  = SetBorderColor
	self.SetBorderLayer  = SetBorderLayer
	self.SetBorderParent = SetBorderParent
	self.SetBorderSize   = SetBorderSize

	self.GetBorderColor  = GetBorderColor
	self.GetBorderLayer  = GetBorderLayer
	self.GetBorderParent = GetBorderParent
	self.GetBorderSize   = GetBorderSize

	if self.GetBackdrop then
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
		self.SetBackdropBorderColor = SetBorderColor
	end
--[[
	local glow = self:CreateTexture(nil, "BACKGROUND")
	glow:SetPoint("CENTER")
	glow:SetTexture("Interface\\AddOns\\oUF_Phanx\\media\\frameGlow")
	glow:SetWidth(self:GetWidth() / 225 * 256)
	glow:SetHeight(self:GetHeight() / 30 * 64)
	glow:Hide()
	self.Glow = glow
]]
	tinsert(ns.borderedObjects, self)

	self:SetBorderColor()
	self:SetBorderParent(parent)
	self:SetBorderSize(size, offset)

	return true
end

_G.CreateBorder = ns.CreateBorder