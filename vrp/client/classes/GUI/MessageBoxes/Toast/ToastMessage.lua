ToastMessage = inherit(DxElement)
inherit(GUIFontContainer, ToastMessage)

function ToastMessage:constructor(text, timeout)
	GUIFontContainer.constructor(self, text, 1, VRPFont(23))
	local x, y, w, h
	if MessageBoxManager.Mode then
		x, y, w, h = 20, (screenHeight - screenHeight*0.265) - 20, 340*screenWidth/1600+6, 41
	else
		x, y, w, h = 20, screenHeight - 5, 340*screenWidth/1600+6, 41
	end
	local textHeight = textHeight(self.m_Text, w - 70, self.m_Font, self.m_FontSize)
	h = h + textHeight
	y = y - h

	DxElement.constructor(self, x, y, w, h)

	self.m_Title = self:getDefaultTitle()
	self.m_TitleFont = VRPFont(28, Fonts.EkMukta_Bold)
	self.m_TextHeight = textHeight

	-- Alpha
	self:setAlpha(0)
	self.m_AlphaFaded = false

	playSound(self:getSoundPath())
	setTimer(function() delete(self) end, timeout or 5000, 1)

	table.insert(MessageBoxManager.Map, self)
	MessageBoxManager.resortPositions()
end

function ToastMessage:virtual_constructor(text, timeout)
	ToastMessage.constructor(self, text, timeout)
end

function ToastMessage:virtual_destructor()
	table.removevalue(MessageBoxManager.Map, self)
	MessageBoxManager.resortPositions()
end

function ToastMessage:drawThis()
	-- get color
	local color = self:getColor()

	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(color[1], color[2], color[3], self.m_Alpha))

	-- Draw image
	dxDrawImage(self.m_AbsoluteX + 20, self.m_AbsoluteY + self.m_Height/2 - 24/2, 24, 24, self:getImagePath(), 0, 0, 0, tocolor(255, 255, 255, self.m_Alpha))

	-- Draw title
	dxDrawText(self.m_Title, self.m_AbsoluteX + 60, self.m_AbsoluteY + 5, self.m_AbsoluteX + self.m_Width - 20, self.m_AbsoluteY + 15, tocolor(255, 255, 255, self.m_Alpha), self.m_FontSize, self.m_TitleFont)

	-- Draw text
	dxDrawText(self.m_Text, self.m_AbsoluteX + 60, self.m_AbsoluteY + 30, self.m_AbsoluteX + self.m_Width - 20, self.m_AbsoluteY + self.m_Height - 30 - 10, tocolor(255, 255, 255, self.m_Alpha), self.m_FontSize, self.m_Font, "left", "top", false, true)
end

--[[
function ToastMessage.resortPositions()
	local radar = HUDRadar:getSingleton()
	for i = #ToastMessage.Map, 1, -1 do
		local toast = ToastMessage.Map[i]
		local prevToast = ToastMessage.Map[i + 1]

		if toast.m_Animation then
			delete(toast.m_Animation)
		end

		if prevToast then
			toast.m_Animation = Animation.Move:new(toast, 1000, toast.m_AbsoluteX, prevToast.m_Animation.m_TY - toast.m_Height - 5)
		else
			toast.m_Animation = Animation.Move:new(toast, 1000, toast.m_AbsoluteX, radar.m_PosY + radar.m_Height + 18 - toast.m_Height)
		end
	end
end
--]]

ToastMessage.getImagePath    = pure_virtual
ToastMessage.getSoundPath    = pure_virtual
ToastMessage.getColor        = pure_virtual
ToastMessage.getDefaultTitle = pure_virtual
