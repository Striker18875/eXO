-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIPhoneTabPanel.lua
-- *  PURPOSE:     Phone Tab
-- *
-- ****************************************************************************

GUIPhoneTabPanel = inherit(GUIElement)

function GUIPhoneTabPanel:constructor(posX, posY, width, height, parent)
	checkArgs("GUIPhoneTabPanel:constructor", "number", "number", "number", "number")
	self.m_CurrentTab = false

	GUIElement.constructor(self, posX, posY, width, height, parent)
end

function GUIPhoneTabPanel:setTab(id)
	if self.m_CurrentTab then
		self[self.m_CurrentTab]:setVisible(false)
	end
	self[id]:setVisible(true)
	self.m_CurrentTab = id

	if self.onTabChanged then
		self.onTabChanged(id)
	end

	return self
end

function GUIPhoneTabPanel:setTabCallback(id)
	return bind(GUIPhoneTabPanel.setTab, self, id)
end

function GUIPhoneTabPanel:getCurrentTab()
	return self.m_CurrentTab
end

function GUIPhoneTabPanel:addTab(tabName, symbol)
	local tabButton = GUIButton:new(#self * 65, self.m_Height-50, 65, 50, "", self)
	local tabLabel = GUILabel:new(#self * 65, self.m_Height-16, 65, 15, tabName, self):setAlignX("center"):setFontSize(1)
	local tabIcon = GUILabel:new(#self * 65, self.m_Height-45, 65, 25, symbol, self):setAlignX("center"):setFont(FontAwesome(30))

	tabButton:setColor(Color.White)
	tabButton:setBackgroundColor(Color.Grey)
	tabButton:setBackgroundHoverColor(tocolor(0, 70, 100))
	tabButton:setFontSize(1)
	tabButton:setFont(VRPFont(26))

	local id = #self+1
	tabButton.onLeftClick = function()
		self:setTab(id)

		for k, v in ipairs(self.m_Children) do
			if instanceof(v, GUIButton) then
				v:setColor(Color.White)
				v:setBackgroundColor(Color.Grey)
			end
		end

		tabButton:setColor(Color.Grey)
		tabButton:setBackgroundColor(Color.LightBlue)
	end

	self[id] = GUIElement:new(0, 0, self.m_Width, self.m_Height-40, self)
	self[id].TabIndex = id
	if id ~= 1 then
		self[id]:setVisible(false)
	else
		self.m_CurrentTab = 1
		tabButton:setColor(Color.Grey)
		tabButton:setBackgroundColor(Color.LightBlue)
	end

	return self[id]
end

function GUIPhoneTabPanel:drawThis()
	-- Draw the background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150) --[[tocolor(255, 255, 255, 40)]])
end
