-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppSettings.lua
-- *  PURPOSE:     Phone settings app class
-- *
-- ****************************************************************************
AppSettings = inherit(PhoneApp)

function AppSettings:constructor()
	PhoneApp.constructor(self, "Settings", "files/images/Phone/Apps/IconSettings.png")
end

function AppSettings:onOpen(form)
	self.m_Label = GUILabel:new(10, 10, 200, 50, "Settings", form)
	self.m_Label:setColor(Color.Black)

	GUILabel:new(10, 60, 200, 20, "Ringtones", form):setColor(Color.Black)
	self.m_RingtoneChanger = GUIChanger:new(10, 85, 200, 30, form)
	self.m_RingtoneChanger.onChange = function(text)
		if self.m_Sound and isElement(self.m_Sound) then
			destroyElement(self.m_Sound)
		end
		local path = "files/audio/Ringtones/"..text:gsub(" ", "")..".mp3"
		self.m_Sound = playSound(path)

		-- Save it
		core:getConfig():set("Phone", "Ringtone", path)
	end
	for i = 1, 3 do
		self.m_RingtoneChanger:addItem("Ringtone "..i)
	end
end

function AppSettings:onClose()
	if self.m_Sound and isElement(self.m_Sound) then
		destroyElement(self.m_Sound)
	end
end
