-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MinigameGUI.lua
-- *  PURPOSE:     HighscoreGUI class
-- *
-- ****************************************************************************
MinigameGUI = inherit(GUIForm)
inherit(Singleton, MinigameGUI)

MinigameGUI.Data = {
	["ZombieSurvival"] = {
		["title"] = HelpTextTitles.Minigames.ZombieSurvival,
		["description"] = HelpTexts.Minigames.ZombieSurvival,
		["image"] = "files/images/Minigames/ZombieSurvival.png",
		["startFunction"] = function() triggerServerEvent("startZombieSurvival", localPlayer) end
	},
	["GoJump"] = {
		["title"] = HelpTextTitles.Minigames.GoJump,
		["description"] = HelpTexts.Minigames.GoJump,
		["image"] = "files/images/Minigames/GoJump.png",
		["startFunction"] = function() GoJump:new() end
	},
	["SideSwipe"] = {
		["title"] = HelpTextTitles.Minigames.SideSwipe,
		["description"] = HelpTexts.Minigames.SideSwipe,
		["image"] = "files/images/Minigames/SideSwipe.png",
		["startFunction"] = function() SideSwipe:new() end
	},
	["SniperGame"] = {
		["title"] = HelpTextTitles.Minigames.SniperGame,
		["description"] = HelpTexts.Minigames.SniperGame,
		["image"] = "files/images/Minigames/SniperGame.png",
		["startFunction"] = function() triggerServerEvent("startSniperGame", localPlayer) end
	},
}

addRemoteEvents{"showMinigameGUI"}

function MinigameGUI:constructor(game)
	local data = MinigameGUI.Data[game]

	GUIForm.constructor(self, screenWidth/2-600/2, screenHeight/2-250/2, 600, 250)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, data["title"], true, true, self)
	self.m_Image = GUIImage:new(10, 40, 300, 200, data["image"], self)
	self.m_Description = GUILabel:new(320, 40, 270, 100, data["description"], self):setFont(VRPFont(24))
	self.m_PlayButton = VRPButton:new(320, 175, 270, 30, _"Spielen", true, self):setBarColor(Color.Green)
	self.m_HighscoreButton = VRPButton:new(320, 210, 270, 30, _"Highscore zeigen", true, self):setBarColor(Color.LightBlue)

	self.m_PlayButton.onLeftClick = function()
		data["startFunction"]()
		delete(self)
	end
	self.m_HighscoreButton.onLeftClick = function()
		HighscoreGUI:new(game)
		delete(self)
	end

end

addEventHandler("showMinigameGUI", root,
	function(game)
		MinigameGUI:new(game)
	end
)
