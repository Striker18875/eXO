-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ChangerBox.lua
-- *  PURPOSE:     Generic ChangerBox class
-- *
-- ****************************************************************************
ChangerBox = inherit(GUIForm)

function ChangerBox:constructor(title, text,items, callback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.18/2, screenWidth*0.4, screenHeight*0.18)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.17, text, self.m_Window)
	self.m_Changer = GUIChanger:new(self.m_Width*0.01, self.m_Height*0.4, self.m_Width*0.98, self.m_Height*0.2, self.m_Window)
	local item
	for k,v in ipairs(items) do
		item = self.m_Changer:addItem(v)
	end
	self.m_SubmitButton = VRPButton:new(self.m_Width*0.01, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.2, _"Bestätigen", true, self.m_Window):setBarColor(Color.Green)
	
	self.m_SubmitButton.onLeftClick = function() 
		if callback then 
			local name,item = self.m_Changer:getIndex()
			callback(item)
		end 
		delete(self) 
	end
end
