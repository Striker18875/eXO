-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppOnOff.lua
-- *  PURPOSE:     Phone switch off app class
-- *
-- ****************************************************************************
AppOnOff = inherit(PhoneApp)

function AppOnOff:constructor()
	PhoneApp.constructor(self, "Ausschalten", "IconOff.png")
end

function AppOnOff:onOpen(form)
	if core:get("Phone", "On") == 1 then
		GUILabel:new(10, 10, 200, 35, _"Handy ausschalten", form):setColor(Color.Black)

		GUILabel:new(10, 60, 200, 20, _"Möchtest du das Handy ausschalten?", form):setColor(Color.Black)

		self.m_switchOffImage = GUIImage:new(form.m_Width/2-64/2, 120, 64, 64, "files/images/Phone/Apps_iPhone/IconOff.png", form)
		self.m_switchOffImage.onLeftClick = function() self:switchOff() end
		self.m_switchOffLabel = GUILabel:new(0, 190, form.m_Width, 20, _"Ja ausschalten", form):setColor(Color.Black):setAlignX("center")
		self.m_switchOffLabel.onLeftClick = function() self:switchOff() end
	else
		GUIRectangle:new(0, 0, form.m_Width, form.m_Height, Color.Black, form)
		GUILabel:new(0, 60, form.m_Width, 25, _"Dein Handy ist ausgeschaltet!", form):setAlignX("center")
		self.m_switchOnImage = GUIImage:new(form.m_Width/2-64/2, 120, 64, 64, "files/images/Phone/Apps_iPhone/IconOn.png", form)
		self.m_switchOnImage.onLeftClick = function() self:switchOn() end
		self.m_switchOnLabel = GUILabel:new(0, 190, form.m_Width, 20, _"einschalten!", form):setAlignX("center")
		self.m_switchOnLabel.onLeftClick = function() self:switchOn() end
	end
end

function AppOnOff:switchOff()
	Phone:getSingleton():switchOff()
end

function AppOnOff:switchOn()
	Phone:getSingleton():switchOn()
end

function AppOnOff:onClose()

end
