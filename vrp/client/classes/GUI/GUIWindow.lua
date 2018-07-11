-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIWindow.lua
-- *  PURPOSE:     GUI window class
-- *
-- ****************************************************************************
GUIWindow = inherit(GUIElement)
inherit(GUIMovable, GUIWindow)

function GUIWindow:constructor(posX, posY, width, height, title, hasTitlebar, hasCloseButton, parent)
	checkArgs("GUIWindow:constructor", "number", "number", "number", "number", "string")
	-- Call base class ctors
	GUIElement.constructor(self, posX, posY, width, height, parent)

	self.m_HasTitlebar = hasTitlebar
	self.m_HasCloseButton = hasCloseButton
	self.m_CloseOnClose = true
	self.m_MovingEnabled = true
	self.m_BGColor = Color.Background

	self.m_Parent:bringToFront() --don't bring the window itself to front but rather the GUIForm parent
	self.onLeftClickDown = function()
		self.m_Parent:bringToFront() --also bring it to the front if somebody clicks inside
	end
	-- Create dummy titlebar element (to be able to retrieve clicks)
	if self.m_HasTitlebar then
		--self.m_TitlebarDummy = GUIElement:new(0, 0, self.m_Width, 30, self)
		self.m_TitlebarDummy = GUIRectangle:new(0, 0, self.m_Width, 30, Color.Primary, self)
		self.m_TitlebarDummy.onLeftClickDown = function()
			if not self.m_MovingEnabled then return end
			self:startMoving()
		end
		self.m_TitlebarDummy.onLeftClick = function()
			if not self.m_MovingEnabled then return end
			self:stopMoving()
		end
		self.m_TitleBarAccentStripe = GUIRectangle:new(0, 30, self.m_Width, 2, Color.Accent, self)

		self.m_TitleLabel = GUILabel:new(0, 0, self.m_Width, 30, title, self)
			:setAlignX("center")
			:setAlignY("center")
	end

	if self.m_HasCloseButton then
		self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBarEnabled(false):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
		self.m_CloseButton.onLeftClick = bind(GUIWindow.CloseButton_Click, self)
	end
end

function GUIWindow:drawThis()
	-- Moving test
	--[[if self:isMoving() then
		self:updateMoveArea()
	end]]

	dxSetBlendMode("modulate_add")

	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/Window.png")
	-- Draw border (no longer a rectangle as causes issues with alpha)
	--dxDrawLine(self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY)
	--dxDrawLine(self.m_AbsoluteX + self.m_Width - 1, self.m_AbsoluteY, self.m_AbsoluteX + self.m_Width - 1, self.m_AbsoluteY + self.m_Height - 1)
	--dxDrawLine(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height - 1, self.m_AbsoluteX + self.m_Width, self.m_AbsoluteY + self.m_Height - 1)
	--dxDrawLine(self.m_AbsoluteX, self.m_AbsoluteY, self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height - 1)

	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_BGColor)

	dxSetBlendMode("blend")
end

function GUIWindow:CloseButton_Click()
	if self.m_CloseOnClose then
		self:close()
	else
		(self.m_Parent or self):setVisible(false) -- Todo: if self.m_Parent == cacheroot then problem() end
		Cursor:hide()
	end
end

function GUIWindow:setTitleBarText (text)
	self.m_TitleLabel:setText(text)
	return self
end

function GUIWindow:addTabPanel(tabs)
	if not self.m_TabPanel then
		self.m_TitleBarAccentStripe:hide()
		self.m_TabPanel = GUITabPanel:new(0, 30, self.m_Width, self.m_Height-30, self)

		local tabElements = {}
		for i,v in ipairs(tabs) do
			tabElements[i] = self.m_TabPanel:addTab(v, true)
		end
		self.m_TabPanel:resizeTabs()
		return tabElements, self.m_TabPanel
	end
end

--- Closes the window
function GUIWindow:close()
	-- Jusonex: Destroy or close, I dunno what's better
	delete(self.m_Parent or self)
end

function GUIWindow:deleteOnClose(close) -- Todo: Find a better name
	self.m_CloseOnClose = close
	return self
end

function GUIWindow:addBackButton(callback)
	local x = self.m_TitlebarButton and self.m_Width-90 or self.m_Width-60
	self.m_BackButton = GUIButton:new(x, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function()
		self:close()
		if type(callback) == "function" then
			callback()
			Cursor:show()
		else
			outputDebug("Invalid back function")
		end
	end
end

function GUIWindow:addTitlebarButton(faIcon, callback)
	if type(callback) == "function" then
		self.m_TitlebarButton = GUIButton:new(self.m_Width-60, 0, 30, 30, faIcon, self):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
		self.m_TitlebarButton.onLeftClick = function()
			if type(callback) == "function" then
				callback()
			else
				outputDebug("Invalid back function")
			end
		end
	else
		outputDebug("Invalid back function")
	end
end

function GUIWindow:toggleMoving(state)
	self.m_MovingEnabled = state
end

function GUIWindow:removeBackButton()
	if self.m_BackButton then
		delete(self.m_BackButton)
	end
end

function GUIWindow.updateGrid(withTabs)
	grid("reset", true)
	grid("offset", withTabs and 50 or 30)
end
