-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIImage.lua
-- *  PURPOSE:     GUI image class
-- *
-- ****************************************************************************
GUIImage = inherit(GUIElement)
inherit(GUIColorable, GUIImage)
inherit(GUIRotatable, GUIImage)

function GUIImage:constructor(posX, posY, width, height, path, parent)
	self.m_Image = path

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self)
	GUIRotatable.constructor(self)
end

function GUIImage:drawThis()
	dxSetBlendMode("modulate_add")
	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end
	if self.m_Image then
		dxDrawImage(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY), self.m_Width, self.m_Height, self.m_Image, self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0, self.m_RotationCenterOffsetY or 0, self:getColor() or 0)
	end
	dxSetBlendMode("blend")
end

function GUIImage:setImage(path)
	assert(type(path) == "string", "Bad argument @ GUIImage.setImage")

	self.m_Image = path
	self:anyChange()
	return self
end

function GUIImage:fitBySize(width, height)
    local origW, origH = self:getSize()
    local origPx, origPy = self:getPosition()
    local origAs = origW/origH
    local as = width/height
    if as > origAs then --fit image to left/right of grid
        self:setPosition(origPx, origPy + (origH/2 - (origW/as)/2))
        self:setSize(origW, origW/as)
    elseif as < origAs then --fit image to top/bottom of grid
        self:setPosition(origPx + (origW/2 - (origH*as)/2), origPy)
        self:setSize(origH*as, origH)
    --else do not fit as the aspect ratio fits
    end
    return self
end

function GUIImage.fitImageSizeToCenter(path, maxWidth, maxHeight)
	local imageWidth, imageHeight = getImageSize(path)
	local x, y, width, height = 0, 0, maxWidth, maxHeight

	if imageWidth < maxWidth or imageHeight < maxHeight then
		x = (maxWidth - imageWidth) / 2
		y = (maxHeight - imageHeight) / 2
		width = imageWidth
		height = imageHeight
	elseif imageWidth > maxWidth or imageHeight > maxHeight then
		if imageWidth > imageHeight then
			local scale = maxWidth / imageWidth

			y = (maxHeight - imageHeight * scale) / 2
			height = imageHeight * scale
		else
			local scale = maxHeight / imageHeight

			x = (maxWidth - imageWidth * scale) / 2
			width = imageWidth * scale
		end
	end

	return x, y, width, height
end