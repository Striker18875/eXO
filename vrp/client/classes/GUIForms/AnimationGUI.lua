-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AnimationGUI.lua
-- *  PURPOSE:     Animation GUI Class
-- *
-- ****************************************************************************
AnimationGUI = inherit(GUIForm)
inherit(Singleton, AnimationGUI)
addRemoteEvents{"onClientAnimationStop"}

function AnimationGUI:constructor()
	GUIForm.constructor(self, screenWidth-270, screenHeight/2-500/2, 250, 500, true, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Animationen", true, true, self)

	self.m_AnimationList = GUIGridList:new(5, 35, self.m_Width-10, self.m_Height-60, self)
	self.m_AnimationList:addColumn(_"Name", 1)
	--self.m_StartAnimation = GUIButton:new(5, self.m_Height-35, self.m_Width-10, 30, "Animation ausführen", self):setBackgroundColor(Color.Green)
	--self.m_StartAnimation.onLeftClick = function() self:startAnimation() end
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, "↕", self.m_Window):setAlignX("right")
	GUILabel:new(6, self.m_Height-self.m_Height/16.5, self.m_Width-12, self.m_Height/15.5, _"Doppelklick zum ausführen", self.m_Window):setFont(VRPFont(self.m_Height*0.04)):setAlignY("center"):setColor(Color.Red)

	local item
	for groupIndex, group in pairs(ANIMATION_GROUPS) do
		self.m_AnimationList:addItemNoClick(_(group))
		for index, animation in pairs(ANIMATIONS) do
			if animation["group"] == group then
				item = self.m_AnimationList:addItem(_(index))
				item.Name = index
				item.onLeftDoubleClick = function () self:startAnimation() end
			end
		end
	end

	-- Events
	self.m_InfoMessage = false
	addEventHandler("onClientAnimationStop", root, bind(self.onAnimationStop, self))
end

function AnimationGUI:startAnimation()
	if ANIMATIONS[self.m_AnimationList:getSelectedItem().Name] then
		if not self.m_InfoMessage then
			self.m_InfoMessage = ShortMessage:new(_"Benutze 'Leertaste' zum beenden der Animation!", -1)
		end
		triggerServerEvent("startAnimation", localPlayer, self.m_AnimationList:getSelectedItem().Name)
	end
end

function AnimationGUI:onAnimationStop()
	if self.m_InfoMessage then
		delete(self.m_InfoMessage)
	end
end
