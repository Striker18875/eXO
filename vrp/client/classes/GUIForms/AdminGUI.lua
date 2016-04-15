-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminGUI.lua
-- *  PURPOSE:     Admin GUI class
-- *
-- ****************************************************************************

AdminGUI = inherit(GUIForm)
AdminGUI.playerFunctions = {"gethere", "goto", "kick", "prison", "timeban", "permaban", "setCompany", "setFaction"}

inherit(Singleton, AdminGUI)

addRemoteEvents{"showAdminMenu"}

function AdminGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-200, 600, 400, false, true)

	self.m_adminButton = {}

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	--self.m_CloseButton.onHover = function () self.m_CloseButton:setColor(Color.LightRed) end
	--self.m_CloseButton.onUnhover = function () self.m_CloseButton:setColor(Color.White) end
	self.m_CloseButton.onLeftClick = function() self:delete() end

	self.m_BackButton = GUILabel:new(self.m_Width-58, 0, 30, 28, "[←]", self):setFont(VRPFont(35))
	--self.m_BackButton.onHover = function () self.m_BackButton:setColor(Color.LightBlue) end
	--self.m_BackButton.onUnhover = function () self.m_BackButton:setColor(Color.White) end
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")
	GUILabel:new(10, 10, 150, 30, _"Adminansage:", tabAllgemein):setColor(Color.White)
	self.m_AdminAnnounceText = GUIEdit:new(150, 10, 330, 30,tabAllgemein)
	self.m_AnnounceButton = GUIButton:new(490, 10, 100, 30, _"senden",  tabAllgemein)
	self.m_AnnounceButton.onLeftClick = bind(self.AnnounceButton_Click, self)
	--self:addAdminButton("supportMode", "Support-Modus aktivieren", 10, 50, 200, 30, Color.Green, tabAllgemein)
	GUILabel:new(self.m_Width-150, 50, 140, 20, _"selbst teleportieren:", tabAllgemein):setColor(Color.White):setAlignX("right")
	self.m_portNorth = GUIButton:new(self.m_Width-105, 75, 30, 30, _"N",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portNorth.onLeftClick = function () self:portAdmin("N") end
	self.m_portEast = GUIButton:new(self.m_Width-70, 110, 30, 30, _"O",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portEast.onLeftClick = function () self:portAdmin("O") end
	self.m_portSouth = GUIButton:new(self.m_Width-105, 145, 30, 30, _"S",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portSouth.onLeftClick = function () self:portAdmin("S") end
	self.m_portWest = GUIButton:new(self.m_Width-140, 110, 30, 30, _"W",  tabAllgemein):setBackgroundColor(Color.Orange)
	self.m_portWest.onLeftClick = function () self:portAdmin("W") end
	self.m_portUp = GUIButton:new(self.m_Width-70, 75, 60, 30, _"Rauf",  tabAllgemein):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_portUp.onLeftClick = function () self:portAdmin("U") end
	self.m_portDown = GUIButton:new(self.m_Width-70, 145, 60, 30, _"Runter",  tabAllgemein):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_portDown.onLeftClick = function () self:portAdmin("D") end

	local tabSpieler = self.m_TabPanel:addTab(_"Spieler")
	self.m_PlayersGrid = GUIGridList:new(10, 10, 200, 380, tabSpieler)
	self.m_PlayersGrid:addColumn(_"Spieler", 1)

	self.m_PlayerNameLabel = GUILabel:new(220, 10, 180, 20, _"Spieler: -", tabSpieler)
	self.m_PlayerTimeLabel = GUILabel:new(220, 35, 180, 20, _"Spielstunden: -", tabSpieler)
	self.m_PlayerJobLabel = GUILabel:new(220, 60, 180, 20, _"Job: -", tabSpieler)
	self.m_PlayerFactionLabel = GUILabel:new(410, 10, 180, 20, _"Fraktion: -", tabSpieler)
	self.m_PlayerCompanyLabel = GUILabel:new(410, 35, 180, 20, _"Unternehmen: -", tabSpieler)
	self.m_PlayerGroupLabel = GUILabel:new(410, 60, 180, 20, _"Gang/Firma: -", tabSpieler)

	self:addAdminButton("goto", "hin porten", 220, 170, 180, 30, Color.Green, tabSpieler)
	self:addAdminButton("gethere", "her porten", 410, 170, 180, 30, Color.Green, tabSpieler)
	self:addAdminButton("kick", "kicken", 220, 210, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("prison", "ins Prison", 220, 250, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("warn", "Warn geben", 220, 290, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("timeban", "Timeban", 410, 210, 180, 30, Color.Red, tabSpieler)
	self:addAdminButton("permaban", "Permaban", 410, 250, 180, 30, Color.Red, tabSpieler)
	self:addAdminButton("setFaction", "in Fraktion setzen", 220, 330, 180, 30, Color.Blue, tabSpieler)
	self:addAdminButton("setCompany", "in Unternehmen setzen", 410, 330, 180, 30, Color.Blue, tabSpieler)

	local tabTicket = self.m_TabPanel:addTab(_"Tickets")
	self.m_WebView = GUIWebView:new(0, 0, self.m_Width, self.m_Height, "http://exo-reallife.de/ingame/ticketSystem/admin.php?player="..getPlayerName(getLocalPlayer()).."&sessionID="..self:generateSessionId(), true, tabTicket)


	for key, playeritem in ipairs(getElementsByType("player")) do
		local item = self.m_PlayersGrid:addItem(playeritem:getName())
		item.player = playeritem
		item.onLeftClick = function()
			self:onSelectPlayer(playeritem)
		end
	end

	self:refreshButtons()
end

function AdminGUI:addAdminButton(func, text, x, y, width, height, color, parent)
	self.m_adminButton[func] = GUIButton:new(x, y, width, height, _(text),  parent):setFontSize(1):setBackgroundColor(color)
	self.m_adminButton[func].func = func
	self.m_adminButton[func].onLeftClick = function () self:onButtonClick(func) end
	self.m_adminButton[func]:setEnabled(false)
end

function AdminGUI:onSelectPlayer(player)
	self.m_PlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	local hours, minutes = math.floor(player:getPlayTime()/60), (player:getPlayTime() - math.floor(player:getPlayTime()/60)*60)
	self.m_PlayerTimeLabel:setText(_("Spielzeit: %s:%s h", hours, minutes))
	self.m_PlayerFactionLabel:setText(_("Fraktion: %s", player:getShortFactionName()))
	self.m_PlayerCompanyLabel:setText(_("Unternehmen: %s", player:getShortCompanyName()))
	self.m_PlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	self.m_PlayerJobLabel:setText(_("Job: %s", player:getJobName()))

	self:refreshButtons()
end

function AdminGUI:portAdmin(direction)
	local element = localPlayer

	if localPlayer:getOccupiedVehicle() then element = localPlayer:getOccupiedVehicle()	end

	local pos = element:getPosition()
		if direction == "N" then pos.y = pos.y+2
	elseif direction == "O" then pos.x = pos.x+2
	elseif direction == "S" then pos.y = pos.y-2
	elseif direction == "W" then pos.x = pos.x-2
	elseif direction == "U" then pos.z = pos.z+2
	elseif direction == "D" then pos.z = pos.z-2
	end
	element:setPosition(pos)
end

function AdminGUI:refreshButtons()
	for index, btn in pairs(self.m_adminButton) do
		if localPlayer:getRank() < ADMIN_RANK_PERMISSION[btn.func] then
			btn:setEnabled(false)
		else
			btn:setEnabled(true)
		end
	end
end

function AdminGUI:onButtonClick(func)
	if table.find(AdminGUI.playerFunctions, func) then
		if not self.m_PlayersGrid:getSelectedItem() then
			ErrorBox:new(_"Kein Spieler ausgewählt!")
			return
		else
			local selectedPlayer = self.m_PlayersGrid:getSelectedItem().player
		end
	end
	local selectedPlayer = self.m_PlayersGrid:getSelectedItem().player
	if func == "gethere" or func == "goto" then
		triggerServerEvent("adminTriggerFunction", root, func, selectedPlayer)
	elseif func == "kick" then
		InputBox:new(_("Spieler %s kicken", selectedPlayer:getName()),
				_("Aus welchem Grund möchtest du den Spieler %s vom Server kicken?", selectedPlayer:getName()),
				function (reason)
					triggerServerEvent("adminTriggerFunction", root, func, selectedPlayer, reason)
				end)
	elseif func == "prison" then
		AdminInputBox:new(
				_("Spieler %s ins Prison schicken", selectedPlayer:getName()),
				_"Dauer in Minuten:",
				function (reason, duration)
					triggerServerEvent("adminTriggerFunction", root, func, selectedPlayer, reason, duration)
				end)
	elseif func == "timeban" then
		AdminInputBox:new(
				_("Spieler %s time bannen", selectedPlayer:getName()),
				_"Dauer in Stunden:",
				function (reason, duration)
					triggerServerEvent("adminTriggerFunction", root, func, selectedPlayer, reason, duration)
				end)
	elseif func == "permaban" then
		InputBox:new(_("Spieler %s permanent Bannen", selectedPlayer:getName()),
				_("Aus welchem Grund möchtest du den Spieler %s permanent bannen?", selectedPlayer:getName()),
				function (reason)
					triggerServerEvent("adminTriggerFunction", root, func, selectedPlayer, reason)
				end)
	elseif func == "setCompany" then
		local companyTable = {[0] = "Kein Unternehmen", [1] = "Fahrschule", [2] = "Mech & Tow", [3] = "San News", [4] = "Public Transport"}
		ChangerBox:new(_"Unternehmen setzten",
				_"Bitte wähle das gewünschte Unternehmen aus:",companyTable,
				function (companyId)
					triggerServerEvent("adminSetPlayerCompany", root, selectedPlayer,companyId)
				end)
	elseif func == "setFaction" then
		local factionTable = {[0] = "Keine Fraktion", [1] = "SAPD", [2] = "FBI", [3] = "SA Army", [4] = "Rescue Team", [5] = "Cosa Nostra", [6] = "Yakuza"}
		ChangerBox:new(_"Fraktion setzten",
				_"Bitte wähle die gewünschte Fraktion aus:",factionTable,
				function (factionId)
					triggerServerEvent("adminSetPlayerFaction", root, selectedPlayer,factionId)
				end)
	else
		outputDebug("Under Developement", 255, 0 ,0)
	end
end

function AdminGUI:AnnounceButton_Click()
	local announceString = self.m_AdminAnnounceText:getText()
	if announceString ~= "" and #announceString > 0 then
		--triggerServerEvent("adminAnnounce", root, announceString)
		self:AnnounceText( announceString )
		self.m_AdminAnnounceText:setText(" ")
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function AdminGUI:AnnounceText( message )
	if self.m_MoveText == nil then
		self.m_MoveText = GUIMovetext:new(0, 0, screenWidth, screenHeight*0.05,message,"",1,(screenWidth*0.1)*-1, self,"files/images/GUI/megafone.png",true)
	end
end


function AdminGUI:generateSessionId()
	return md5(localPlayer:getName()..localPlayer:getSerial()) -- ToDo: generate serverside with lastlogin timestamp for more security
end


addEventHandler("showAdminMenu", root,
	function(...)
		AdminGUI:new()
	end
)

AdminInputBox = inherit(GUIForm)

function AdminInputBox:constructor(title, durationText, callback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.2/2, screenWidth*0.4, screenHeight*0.2)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.24, self.m_Width*0.5, self.m_Height*0.17, durationText, self.m_Window)
	self.m_DurationBox = GUIEdit:new(self.m_Width*0.5, self.m_Height*0.24, self.m_Width*0.45, self.m_Height*0.2, self.m_Window)
	self.m_DurationBox:setNumeric(true)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.46, self.m_Width*0.5, self.m_Height*0.17, _"Grund:", self.m_Window)
	self.m_ReasonBox = GUIEdit:new(self.m_Width*0.5, self.m_Height*0.46, self.m_Width*0.45, self.m_Height*0.2, self.m_Window)
	self.m_SubmitButton = VRPButton:new(self.m_Width*0.5, self.m_Height*0.75, self.m_Width*0.45, self.m_Height*0.2, _"Bestätigen", true, self.m_Window):setBarColor(Color.Green)

	self.m_SubmitButton.onLeftClick =
	function()
		if callback then
			callback(self.m_ReasonBox:getText(), tonumber(self.m_DurationBox:getText()))
		end
		delete(self)
	end
end
