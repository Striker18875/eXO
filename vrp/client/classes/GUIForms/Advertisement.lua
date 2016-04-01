-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Advertisement.lua
-- *  PURPOSE:     AdvertisementBox class
-- *
-- ****************************************************************************

AdvertisementBox = inherit(GUIForm)
inherit(Singleton, AdvertisementBox)

function AdvertisementBox:constructor()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.24/2, screenWidth*0.4, screenHeight*0.24)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Werbung schalten", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.17, self.m_Width*0.98, self.m_Height*0.15, "Bitte gib deinen gewünschten Werbe-Text ein:", self.m_Window)
	self.m_EditBox = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.32, self.m_Width*0.98, self.m_Height*0.15, self.m_Window)
	self.m_EditBox.onChange = function () self:calcCosts() end

	GUILabel:new(self.m_Width*0.01, self.m_Height*0.5, self.m_Width*0.2, self.m_Height*0.15, "Farbe:", self.m_Window)
	self.m_ColorChanger = GUIChanger:new(self.m_Width*0.15, self.m_Height*0.5, self.m_Width*0.3, self.m_Height*0.15, self.m_Window)
	for key, name in pairs(AD_COLORS) do
		self.m_ColorChanger:addItem(name)
	end
	self.m_ColorChanger.onChange = function () self:calcCosts() end


	GUILabel:new(self.m_Width*0.5, self.m_Height*0.5, self.m_Width*0.20, self.m_Height*0.15, "Dauer:", self.m_Window)
	self.m_DurationChanger = GUIChanger:new(self.m_Width*0.62, self.m_Height*0.5, self.m_Width*0.35, self.m_Height*0.15, self.m_Window)
	for name, duration in pairs(AD_DURATIONS) do
		self.m_DurationChanger:addItem(name)
	end
	self.m_DurationChanger.onChange = function () self:calcCosts() end

	self.m_InfoLabel = GUILabel:new(self.m_Width*0.01, self.m_Height*0.65, self.m_Width*0.98, self.m_Height*0.15, "Kosten: 0$", self.m_Window)

	self.m_SubmitButton = VRPButton:new(self.m_Width*0.64, self.m_Height*0.8, self.m_Width*0.35, self.m_Height*0.15, _"Werbung schalten", true, self.m_Window):setBarColor(Color.Green)
	self.m_SubmitButton.onLeftClick = function() triggerServerEvent("sanNewsAdvertisement", localPlayer, self.m_EditBox:getText(), self.m_ColorChanger:getIndex(), self.m_DurationChanger:getIndex()) end
	self:calcCosts()
end

function AdvertisementBox:calcCosts()
	local length = string.len(self.m_EditBox:getText())
	local selectedDuration = self.m_DurationChanger:getIndex()
	local durationExtra = (AD_DURATIONS[selectedDuration] - 20) * 2

	local colorMultiplicator = 1
	local selectedColor = self.m_ColorChanger:getIndex()
	if selectedColor ~= "Schwarz" then
		colorMultiplicator = 2
	end

	if length < 5 then
		self.m_InfoLabel:setText(_"Dein Werbetext ist zu kurz! Mindestens 5 Zeichen!")
		self.m_InfoLabel:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
	elseif length > 50 then
		self.m_InfoLabel:setText(_"Dein Werbetext ist zu lang! Maximal 50 Zeichen!")
		self.m_InfoLabel:setColor(Color.Red)
		self.m_SubmitButton:setEnabled(false)
	else
		local costs = (length*AD_COST_PER_CHAR + AD_COST + durationExtra) * colorMultiplicator
		self.m_InfoLabel:setText(_("Zeichenanzahl: %d Kosten: %d$", length, costs))
		self.m_InfoLabel:setColor(Color.Green)
		self.m_SubmitButton:setEnabled(true)
	end
end

local ColorTable = {
	["Schwarz"] = Color.Black,
	["Rot"] = Color.Red,
	["Grün"] = Color.Green,
	["Blau"] = Color.Blue
}

Advertisement = inherit(GUIForm)
inherit(Singleton, Advertisement)

function Advertisement:constructor(player, text, color, duration)
	if core:get("Ad", "Chat", 0) == 0 then
		GUIForm.constructor(self, 0, screenHeight-30, screenWidth, 30, false, true)
		self.m_Rectangle = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, ColorTable[color], self)
		self.m_Rectangle:setAlpha(220)

		self.m_Duration = AD_DURATIONS[duration]*1000
		self.m_Label = GUILabel:new(10, 0, self.m_Width-10, self.m_Height-2, _("Werbung von %s: %s", player:getName(), text), self):setFont(VRPFont(32)):setFontSize(1)
		self:setVisible(false)
		self:FadeIn()
	else
		local r,g,b = fromcolor(ColorTable[color])
		if color == "Schwarz" then r,g,b = 180,180,180 end
		outputChatBox(_("Werbung von %s:", player:getName()), r, g, b)
		outputChatBox(text, r, g, b)
	end
end

function Advertisement:FadeIn()
	GUIForm.fadeIn(self, 750)
	setTimer(bind(self.fadeOut, self), self.m_Duration, 1)
end

function Advertisement:FadeOut()
	GUIForm.fadeOut(self, 750)
	setTimer(function() delete(self) end, 750, 1)
end

addEvent("showAd", true)
addEventHandler("showAd", root, function(...)
	if Advertisement:isInstantiated() then delete(Advertisement:getSingleton()) end
	Advertisement:new(...)
end)
