-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIButtonMenu.lua
-- *  PURPOSE:     GUIButtonMenu class
-- *
-- ****************************************************************************
GUIButtonMenu = inherit(GUIForm)

function GUIButtonMenu:constructor(text)
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(150/2), 300, 300)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, text, true, true, self)
	self.m_Window:setCloseOnClose(true)
	self.m_Items = {}
end

function GUIButtonMenu:addItem(text, color, callback)
	self.m_Window:setSize(self.m_Width, 5+40+(#self.m_Items+1)*45)

	local item = GUIButton:new(10, 40 + #self.m_Items*45, self.m_Width - 20, 40, text, self)
	item:setBackgroundColor(color):setFont(VRPFont(28)):setFontSize(1)
	if callback then
		item.onLeftClick = function(item) callback(item) end
	end
	table.insert(self.m_Items, item)

	return item
end

function GUIButtonMenu:removeItem(item)
	local idx = table.find(self.m_Items, item)
	if idx then
		-- Delete old item
		delete(self.m_Items[idx])
		table.remove(self.m_Items, idx)

		-- Resize the Window
		self.m_Window:setSize(self.m_Width, 5+40+(#self.m_Items)*45)
		for i, v in pairs(self.m_Items) do
			local x, y = v:getPosition()
			v:setPosition(x, y - 45)
		end
	else
		outputDebug("ITEM NOT FOUND! "..item:getText():upper())
	end
end
