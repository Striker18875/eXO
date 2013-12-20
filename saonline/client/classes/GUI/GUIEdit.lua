-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIEdit.lua
-- *  PURPOSE:     GUI edit class
-- *
-- ****************************************************************************

GUIEdit = inherit(GUIElement)
inherit(GUIFontContainer, GUIEdit)
inherit(GUIColorable, GUIEdit)

local GUI_EDITBOX_BORDER_MARGIN = 6

function GUIEdit:constructor(posX, posY, width, height, parent)
	checkArgs("CGUIEdit:constructor", "number", "number", "number", "number")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, "", 1)
	GUIColorable.constructor(self, Color.DarkBlue)

	self.m_Caret = 1
	self.m_DrawCursor = false
end

function GUIEdit:drawThis()
	dxSetBlendMode("modulate_add")

	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.White)
	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/Editbox.png")

	local text = #self.m_Text > 0 and self.m_Text or self.m_Caption or ""
	if text ~= self.m_Caption and self.m_MaskChar then
		text = self.m_MaskChar:rep(#text)
	end

	dxDrawText(text, self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY, 
				self.m_AbsoluteX+self.m_Width - 2*GUI_EDITBOX_BORDER_MARGIN, self.m_AbsoluteY + self.m_Height, 
				self:getColor(), self:getFontSize(), self:getFont(), "left", "center", true, false, false, false)
	
	if self.m_DrawCursor then
		local textBeforeCursor = text:sub(0, self.m_Caret)
		dxDrawRectangle(self.m_AbsoluteX + GUI_EDITBOX_BORDER_MARGIN + dxGetTextWidth(textBeforeCursor, self:getFontSize(), self:getFont()), self.m_AbsoluteY + 6, 2, self.m_Height - 12, Color.Black)
	end

	dxSetBlendMode("blend")
end

function GUIEdit:onInternalEditInput(caret)
	-- Todo: Remove the following condition as soon as guiGetCaretIndex is backported
	if not caret then
		self.m_Caret = #self.m_Text
		return
	end 
	self.m_Caret = caret
end

function GUIEdit:onInternalLeftClick(absoluteX, absoluteY)
	local relativeX, relativeY = absoluteX - self.m_AbsoluteX, absoluteY - self.m_AbsoluteY
	local index = self:getIndexFromPixel(relativeX, relativeY)
	self:setCaretPosition(index)
	
	GUIInputControl.setFocus(self, index)
end

function GUIEdit:onInternalFocus()
	self:setCursorDrawingEnabled(true)
end

function GUIEdit:onInternalLooseFocus()
	self:setCursorDrawingEnabled(false)
end

function GUIEdit:setCaretPosition(pos)
	self.m_Caret = math.min(math.max(pos, 1), #self.m_Text+1)
	self:anyChange()
	return self
end

--[[function GUIEdit:getSelectionRange()
	return self.m_SelectionStart, self.m_Caret
end]]

function GUIEdit:getCaretPosition(pos)
	return self.m_Caret
end

function GUIEdit:setCaption(caption)
	assert(type(caption) == "string", "Bad argument @ GUIEdit.setCaption")

	self.m_Caption = caption
	self:anyChange()
	return self
end

function GUIEdit:setMasked(maskChar)
	self.m_MaskChar = maskChar or "*"
end

function GUIEdit:setCursorDrawingEnabled(state)
	self.m_DrawCursor = state
	self:anyChange()
end

function GUIEdit:getIndexFromPixel(posX, posY)
	outputDebug(("GUIEdit:getIndexFromPixel(%d, %d)"):format(posX, posY))

	local text = self:getText()
	local size = self:getFontSize()
	local font = self:getFont()
	
	for i = 0, #text do
		local extent = dxGetTextWidth(text:sub(0, i), size, font)
		if extent > posX then
			return i-1
		end
	end
	return #text
end
