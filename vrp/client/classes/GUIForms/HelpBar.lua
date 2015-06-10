-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HelpBar.lua
-- *  PURPOSE:     Help bar (slider) class
-- *
-- ****************************************************************************
HelpBar = inherit(GUIForm)
inherit(Singleton, HelpBar)

function HelpBar:constructor()
	GUIForm.constructor(self, screenWidth*0.84, 0, screenWidth*0.16, screenHeight)

	self.m_Icon = GUIImage:new(screenWidth-screenWidth*0.028/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4, screenWidth*0.03/ASPECT_RATIO_MULTIPLIER, screenHeight*0.1, "files/images/GUI/HelpIcon.png")
	self.m_Icon.onLeftClick = bind(self.HelpIcon_Click, self)
	self.m_Icon.onHover = function ()
		if self.m_BlinkTimer and isTimer(self.m_BlinkTimer) then
			killTimer(self.m_BlinkTimer)
		end

		self.m_Icon:setColor(Color.Yellow)
	end
	self.m_Icon.onUnhover = function () self.m_Icon:setColor(Color.White) end

	self.m_Rectangle = GUIRectangle:new(self.m_Width, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 200), self)
	self.m_TitleLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.01, self.m_Width*0.9, self.m_Height*0.1, _"Hilfe", self.m_Rectangle):setColor(Color.LightBlue)
	self.m_SubTitleLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.09, self.m_Width*0.9, self.m_Height*0.04, "Kein Text", self.m_Rectangle):setColor(Color.LightBlue)
	self.m_TextLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.15, self.m_Width*0.9, self.m_Height*0.8, "", self.m_Rectangle):setFont(VRPFont(self.m_Height*0.03))

	self.m_CloseButton = GUILabel:new(self.m_Width*0.8, self.m_Height*0.005, self.m_Width*0.2, self.m_Height*0.1, "⇛", self.m_Rectangle):setColor(Color.LightBlue)
	self.m_CloseButton.onLeftClick = function() self:fadeOut() end
	self.m_CloseButton.onHover = function () self.m_CloseButton:setColor(Color.White) end
	self.m_CloseButton.onUnhover = function () self.m_CloseButton:setColor(Color.LightBlue) end

	self.m_TutorialButton = GUILabel:new(self.m_Width*0.05, self.m_Height*0.93, self.m_Width, self.m_Height*0.05, _"Zeige Tutorial", self.m_Rectangle):setColor(Color.LightBlue)
	self.m_TutorialButton.onHover = function () self.m_TutorialButton:setColor(Color.White) end
	self.m_TutorialButton.onUnhover = function () self.m_TutorialButton:setColor(Color.LightBlue) end
	self.m_TutorialButton:setVisible(false)

	self.m_Visible = false
end

function HelpBar:fadeIn()
	self.m_Visible = true
	self.m_Rectangle:setPosition(self.m_Width, 0)
	Animation.Move:new(self.m_Rectangle, 500, 0, 0)

	self.m_Icon.onUnhover()
	self.m_Icon:setVisible(false)
end

function HelpBar:fadeOut()
	self.m_Rectangle:setPosition(0, 0)
	Animation.Move:new(self.m_Rectangle, 500, self.m_Width, 0)

	setTimer(function ()
		self.m_Icon:setVisible(true)
		self.m_Visible = false
	end, 500, 1)
end

function HelpBar:blink()
	local isFilled = true
	self.m_Icon:setColor(Color.Yellow)

	self.m_BlinkTimer = setTimer(
		function()
			isFilled = not isFilled

			if isFilled then
				self.m_Icon:setColor(Color.Yellow)
			else
				self.m_Icon:setColor(Color.White)
			end
		end, 400, 15
	)
end

function HelpBar:addText(title, text, blink, tutorial)
	localPlayer.m_oldHelp = {
		title = self.m_SubTitleLabel:getText();
		text = self.m_TextLabel:getText();
		tutorial = self.m_TutorialButton.onLeftClick
	}

	if isTimer(self.m_BlinkTimer) then
		killTimer(self.m_BlinkTimer)
		self.m_Icon:setColor(Color.White)
	end

	self.m_SubTitleLabel:setText(title)
	self.m_TextLabel:setText(text)

	if blink ~= false then
		self:blink()
	end

	if type(tutorial) == "function" then
		self.m_TutorialButton:setVisible(true)
		self.m_TutorialButton.onLeftClick = function ()
			self:fadeOut()
			QuestionBox:new(_"Willst du wirklich das Tutorial ansehen?", tutorial, bind(self.fadeIn, self))
		end
	else
		self.m_TutorialButton:setVisible(false)
		self.m_TutorialButton.onLeftClick = nil
	end
end

function HelpBar:addTempText(title, text, blink, tutorial, timeout, anim)
	self:addText(title, text, blink, tutorial)

	if anim then
		if not self.m_Visible then
			self:fadeIn()
		end
	end
	setTimer(
		function ()
			if anim then
				if self.m_Visible then
					self:fadeOut()
				end

				setTimer(
					function ()
						self:addText(localPlayer.m_oldHelp.title, localPlayer.m_oldHelp.text, false, localPlayer.m_oldHelp.tutorial)
					end, 550, 1
				)
			else
				self:addText(localPlayer.m_oldHelp.title, localPlayer.m_oldHelp.text, false, localPlayer.m_oldHelp.tutorial)
			end
		end, timeout or 10000, 1
	)
end

function HelpBar:HelpIcon_Click()
	self:fadeIn()
end
