-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/HelpGUI.lua
-- *  PURPOSE:     HelpGUI GUI
-- *
-- ****************************************************************************
HelpGUI = inherit(GUIForm)
inherit(Singleton, HelpGUI)

function HelpGUI:constructor()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.5/2, screenHeight/2 - screenHeight*0.65/2, screenWidth*0.5, screenHeight*0.65)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Hilfe", true, true, self)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.9, self.m_Window)
	self.m_Grid:addColumn("", 0.95)
	self.m_ContentLabel = GUIScrollableText:new(self.m_Width*0.28, self.m_Height*0.08, self.m_Width*0.7, self.m_Height*0.9, "", self.m_Height*0.05, self.m_Window)

	for category, texts in pairs(HelpTextManager:getSingleton():getTexts()) do
		self.m_Grid:addItemNoClick(category)

		for title, text in pairs(texts) do
			local item = self.m_Grid:addItem("  "..title)
			item.onLeftClick = function()
					if HUDUI:getSingleton().m_Visible then
						HUDUI:getSingleton():refreshHandler()
						HUDUI:setEnabled(false)
					end
				self.m_Window:setTitleBarText(title.." - Hilfe")
				self.m_ContentLabel:setText(text)
			end
		end
	end

	local item = self.m_Grid:getItems()[2]
	self.m_Grid:onInternalSelectItem(item)
	item.onLeftClick()
end

function HelpGUI:isBackgroundBlurred()
	return true
end
