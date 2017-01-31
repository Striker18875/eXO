-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PolicePanel.lua
-- *  PURPOSE:     PolicePanel form class
-- *
-- ****************************************************************************

PolicePanel = inherit(GUIForm)
inherit(Singleton, PolicePanel)

local ElementLocateBlip, ElementLocateTimer

addRemoteEvents{"receiveJailPlayers", "receiveBugs"}

function PolicePanel:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)

	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	self.m_CloseButton.onLeftClick = function() self:close() end

	self.m_TabSpieler = self.m_TabPanel:addTab(_"Spieler")

	self.m_PlayersGrid = GUIGridList:new(10, 10, 300, 370, self.m_TabSpieler)
	self.m_PlayersGrid:addColumn(_"Spieler", 0.5)
	self.m_PlayersGrid:addColumn(_"Fraktion", 0.3)

	GUIWebView:new(360, 10, 100, 135, "http://exo-reallife.de/images/fraktionen/"..localPlayer:getFactionId().."-logo.png", true, self.m_TabSpieler)

	self.m_Skin = GUIWebView:new(490, 10, 100, 220, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php", true, self.m_TabSpieler)

	self.m_PlayerNameLabel = 	GUILabel:new(320, 150, 180, 20, _"Spieler: -", self.m_TabSpieler)
	self.m_PlayerFactionLabel = GUILabel:new(320, 175, 180, 20, _"Fraktion: -", self.m_TabSpieler)
	self.m_PlayerCompanyLabel = GUILabel:new(320, 200, 180, 20, _"Unternehmen: -", self.m_TabSpieler)
	self.m_PlayerGroupLabel = 	GUILabel:new(320, 225, 180, 20, _"Gang/Firma: -", self.m_TabSpieler)
	self.m_PhoneStatus = 		GUILabel:new(320, 250, 180, 20, _"Handy: -", self.m_TabSpieler)

	self.m_RefreshBtn = GUIButton:new(10, 380, 300, 30, "Aktualisieren", self.m_TabSpieler):setBackgroundColor(Color.LightBlue)
	self.m_RefreshBtn.onLeftClick = function() self:loadPlayers() end

	self.m_StopLocateBtn = GUIButton:new(320, 275, 250, 30, "Orten beenden", self.m_TabSpieler):setBackgroundColor(Color.Orange)
	self.m_StopLocateBtn.onLeftClick = function() self:stopLocating() end

	self.m_LocatePlayerBtn = GUIButton:new(320, 310, 250, 30, "Spieler orten", self.m_TabSpieler):setBackgroundColor(Color.Green)
	self.m_LocatePlayerBtn.onLeftClick = function() self:locatePlayer() end

	self.m_AddWantedsBtn = GUIButton:new(320, 345, 250, 30, "Wanteds geben", self.m_TabSpieler)
	self.m_AddWantedsBtn.onLeftClick = function() self:giveWanteds() end


	self.m_DeleteWantedsBtn = GUIButton:new(320, 380, 250, 30, "Wanteds löschen", self.m_TabSpieler):setBackgroundColor(Color.Red)
	self.m_DeleteWantedsBtn.onLeftClick = function() QuestionBox:new(
		_("Möchtest du wirklich alle Wanteds von %s löschen?", self.m_SelectedPlayer:getName()),
		function() triggerServerEvent("factionStateClearWanteds", localPlayer, self.m_SelectedPlayer) end)
	end

	self.m_TabJail = self.m_TabPanel:addTab(_"Knast")

	self.m_JailPlayersGrid = GUIGridList:new(10, 10, 300, 370, self.m_TabJail)
	self.m_JailPlayersGrid:addColumn(_"Spieler", 0.5)
	self.m_JailPlayersGrid:addColumn(_"Knastzeit", 0.3)

	GUIWebView:new(360, 10, 100, 135, "http://exo-reallife.de/images/fraktionen/"..localPlayer:getFactionId().."-logo.png", true, self.m_TabJail)

	self.m_JailSkin = GUIWebView:new(490, 10, 100, 220, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php", true, self.m_TabJail)

	self.m_JailPlayerNameLabel = 	GUILabel:new(320, 150, 180, 20, _"Spieler: -", self.m_TabJail)
	self.m_JailPlayerFactionLabel = GUILabel:new(320, 175, 180, 20, _"Fraktion: -", self.m_TabJail)
	self.m_JailPlayerCompanyLabel = GUILabel:new(320, 200, 180, 20, _"Unternehmen: -", self.m_TabJail)
	self.m_JailPlayerGroupLabel = 	GUILabel:new(320, 225, 180, 20, _"Gang/Firma: -", self.m_TabJail)
	self.m_JailPhoneStatus = 		GUILabel:new(320, 250, 180, 20, _"Handy: -", self.m_TabJail)

	self.m_JailRefreshBtn = GUIButton:new(10, 380, 300, 30, "Aktualisieren", self.m_TabJail):setBackgroundColor(Color.LightBlue)
	self.m_JailRefreshBtn.onLeftClick = function()
		triggerServerEvent("factionStateLoadJailPlayers", root)
	end

	self.m_FreePlayerBtn = GUIButton:new(320, 305, 250, 30, "Spieler frei lassen", self.m_TabJail):setBackgroundColor(Color.Green)
	self.m_FreePlayerBtn.onLeftClick = function()
		if self.m_JailSelectedPlayer and isElement(self.m_JailSelectedPlayer) then
			QuestionBox:new(
				_("Möchtest du %s wirklich aus dem Knast befreien?", self.m_JailSelectedPlayer:getName()),
				function()
					triggerServerEvent("factionStateFreePlayer", localPlayer, self.m_JailSelectedPlayer)
				end
			)
		else
			ErrorBox:new(_"Der Spieler ist nicht mehr online!")
		end
	end

	self:loadPlayers()


	self.m_TabBugs = self.m_TabPanel:addTab(_"Wanzen")
	self.m_BugsGrid = GUIGridList:new(10, 10, 150, 370, self.m_TabBugs)
	self.m_BugsGrid:addColumn(_"Wanze", 0.5)
	self.m_BugsGrid:addColumn(_"Aktiv", 0.5)

	self.m_BugState = GUILabel:new(170, 10, 240, 25, _"Status: -", self.m_TabBugs)
	self.m_BugType = GUILabel:new(170, 35, 350, 25, _"angebracht an: -", self.m_TabBugs)
	self.m_BugOwner = GUILabel:new(170, 60, 350, 25, _"Besitzer: -", self.m_TabBugs)

	self.m_BugLogGrid = GUIGridList:new(170, 100, 390, 275, self.m_TabBugs)
	self.m_BugLogGrid:setItemHeight(20)
	self.m_BugLogGrid:setFont(VRPFont(20))
	self.m_BugLogGrid:addColumn(_"Log", 1)

	self.m_BugLocate = GUIButton:new(430, 10, 140, 25, _"orten", self.m_TabBugs)
	self.m_BugLocate:setBackgroundColor(Color.Green)
	self.m_BugLocate:setEnabled(false)
	self.m_BugLocate.onLeftClick = function() self:bugAction("locate") end

	self.m_BugClearLog = GUIButton:new(430, 40, 140, 25, _"Log löschen", self.m_TabBugs)
	self.m_BugClearLog:setBackgroundColor(Color.Blue)
	self.m_BugClearLog:setEnabled(false)
	self.m_BugClearLog.onLeftClick = function() self:bugAction("clearLog") end

	self.m_BugRefresh = GUIButton:new(400, 70, 25, 25, FontAwesomeSymbols.Refresh, self.m_TabBugs):setFont(FontAwesome(12))
	self.m_BugRefresh:setBackgroundColor(Color.LightBlue)
	self.m_BugRefresh:setEnabled(false)
	self.m_BugRefresh.onLeftClick = function()
		triggerServerEvent("factionStateLoadBugs", root)
	end

	self.m_BugDisable = GUIButton:new(430, 70, 140, 25, _"deaktivieren", self.m_TabBugs)
	self.m_BugDisable:setBackgroundColor(Color.Red)
	self.m_BugDisable:setEnabled(false)
	self.m_BugDisable.onLeftClick = function() self:bugAction("disable") end

	self.m_TabWantedRules = self.m_TabPanel:addTab(_"W. Regeln")
	GUIWebView:new(10, 10, self.m_Width-20, self.m_Height-20, "http://exo-reallife.de/ingame/other/wanteds.php", true, self.m_TabWantedRules)

	addEventHandler("receiveJailPlayers", root, bind(self.receiveJailPlayers, self))
	addEventHandler("receiveBugs", root, bind(self.receiveBugs, self))
end

function PolicePanel:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabJail.TabIndex then
		triggerServerEvent("factionStateLoadJailPlayers", root)
	elseif tabId == self.m_TabBugs.TabIndex then
		triggerServerEvent("factionStateLoadBugs", root)
	end
end

function PolicePanel:loadPlayers()
	self.m_PlayersGrid:clear()
	self.m_Players = {}
	for i=0, 6 do
		for Id, player in pairs(Element.getAllByType("player")) do
			if player:getWanteds() == i then
				if not self.m_Players[i] then self.m_Players[i] = {} end
				self.m_Players[i][player] = true
			end
		end
	end
	for i = 6, 0, -1 do
		if self.m_Players[i] then
			self.m_PlayersGrid:addItemNoClick(i.." Wanteds", "")
			for player, bool in pairs(self.m_Players[i]) do
				if isElement(player) then
					local item = self.m_PlayersGrid:addItem(player:getName(), player:getFaction() and player:getFaction():getShortName() or "- Keine -")
					item.player = player
					item.onLeftClick = function()
						self:onSelectPlayer(player)
					end
				end
			end
		end
	end
end

function PolicePanel:receiveJailPlayers(playerTable)
	self.m_JailPlayersGrid:clear()
	for player, jailtime in pairs(playerTable) do
		local item = self.m_JailPlayersGrid:addItem(player:getName(), jailtime)
		item.player = player
		item.onLeftClick = function()
			self:onSelectJailPlayer(player)
		end
	end
end


function PolicePanel:receiveBugs(bugTable)
	self.m_BugsGrid:clear()
	self.m_BugData = bugTable

	local pos, active = ""

	for id, bugData in ipairs(bugTable) do

		active = _"Nein"
		if bugData["element"] and isElement(bugData["element"]) then
			active = "Ja"
		end

		local item = self.m_BugsGrid:addItem(id, active)

		if id == self.m_CurrentSelectedBugId  then
			item:onInternalLeftClick()
			self:onSelectBug(id)
		end

		item.onLeftClick = function()
			triggerServerEvent("factionStateLoadBugs", root)
			self:onSelectBug(id)
		end
	end
end

function PolicePanel:onSelectBug(id)
	self.m_CurrentSelectedBugId = id
	if self.m_BugData and self.m_BugData[id] and self.m_BugData[id]["element"] and isElement(self.m_BugData[id]["element"]) then
		local owner, ownerType, item
		local element = self.m_BugData[id]["element"]

		if element:getType() == "vehicle" then
			owner = element:getData("OwnerName") or "Unbekannt"
			ownerType = "Fahrzeug"
		elseif element:getType() == "player" then
			owner = element:getName() or "Unbekannt"
			ownerType = "Spieler"
		end

		self.m_BugOwner:setText("angebracht an: "..ownerType)
		self.m_BugType:setText("Besitzer: "..owner)
		self.m_BugState:setText(_"Status: aktiv")
		self.m_BugState:setColor(Color.Green)

		self.m_BugLogGrid:clear()
		for index, msg in pairs(self.m_BugData[id]["log"]) do
			item = self.m_BugLogGrid:addItem(msg)
			item:setFont(VRPFont(20))
		end

		self.m_BugDisable:setEnabled(true)
		self.m_BugClearLog:setEnabled(true)
		self.m_BugLocate:setEnabled(true)
		self.m_BugRefresh:setEnabled(true)

	else
		self.m_BugLogGrid:clear()
		self.m_BugState:setText(_"Status: deaktiviert")
		self.m_BugState:setColor(Color.Red)
		self.m_BugDisable:setEnabled(false)
		self.m_BugClearLog:setEnabled(false)
		self.m_BugLocate:setEnabled(false)
		self.m_BugRefresh:setEnabled(false)
	end

end

function PolicePanel:bugAction(func)
	if self.m_CurrentSelectedBugId and self.m_CurrentSelectedBugId > 0 then
		local id = self.m_CurrentSelectedBugId

		if self.m_BugData and self.m_BugData[id] and self.m_BugData[id]["active"] and self.m_BugData[id]["active"] == true then
			if func == "locate" then
				if self.m_BugData[id]["element"] and isElement(self.m_BugData[id]["element"]) then
					self:locateElement(self.m_BugData[id]["element"])
				else
					ErrorBox:new(_"Die Wanze wurde nicht gefunden!")
				end
			else
				triggerServerEvent("factionStateBugAction", localPlayer, func, id)
			end
		else
			ErrorBox:new("Diese Wanze ist nicht aktiviert!")
		end
	else
		ErrorBox:new("Keine Wanze ausgewählt!")
	end
end

function PolicePanel:onSelectPlayer(player)
	self.m_PlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	self.m_PlayerFactionLabel:setText(_("Fraktion: %s", player:getFaction() and player:getFaction():getShortName() or "- Keine -"))
	self.m_PlayerCompanyLabel:setText(_("Unternehmen: %s", player:getCompany() and player:getCompany():getShortName() or "- Keine -"))
	self.m_PlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	self.m_SelectedPlayer = player
	local phone = "Ausgeschaltet"
	if player:getPublicSync("Phone") == true then phone = "Eingeschaltet" end
	self.m_PhoneStatus:setText(_("Handy: %s", phone))

	self.m_Skin:loadURL("http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..player:getModel())
end

function PolicePanel:onSelectJailPlayer(player)
	self.m_JailPlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	self.m_JailPlayerFactionLabel:setText(_("Fraktion: %s", player:getFaction() and player:getFaction():getShortName() or "- Keine -"))
	self.m_JailPlayerCompanyLabel:setText(_("Unternehmen: %s", player:getCompany() and player:getCompany():getShortName() or "- Keine -"))
	self.m_JailPlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	self.m_JailSelectedPlayer = player
	local phone = "Ausgeschaltet"
	if player:getPublicSync("Phone") == true then phone = "Eingeschaltet" end
	self.m_JailPhoneStatus:setText(_("Handy: %s", phone))

	self.m_JailSkin:loadURL("http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..player:getModel())
end

function PolicePanel:locatePlayer()
	local item = self.m_PlayersGrid:getSelectedItem()
	local player = item.player
	if isElement(player) then
		if player:getPublicSync("Phone") == true then
			self:locateElement(player)
		else
			ErrorBox:new(_"Der Spieler konnte nicht geortet werden!\n Sein Handy ist ausgeschaltet!")
		end
	else
		ErrorBox:new(_"Spieler nicht mehr online!")
	end
end

function PolicePanel:locateElement(element)
	local elementText = element:getType() == "player" and _"Der Spieler" or _"Die Wanze"

	if getElementDimension(element) == 0 and getElementInterior(element) == 0 then
		self:stopLocating()

		local pos = element:getPosition()
		ElementLocateBlip = Blip:new("Locate.png", pos.x, pos.y, 9999)
		ElementLocateBlip:attachTo(element)
		localPlayer.m_LocatingElement = element
		InfoBox:new(_("%s wurde geortet! Folge dem Blip auf der Karte!", elementText))

		ElementLocateTimer = setTimer(function()
			if localPlayer.m_LocatingElement and isElement(localPlayer.m_LocatingElement) then
				if not localPlayer:getPublicSync("Faction:Duty") then
					self:stopLocating()
				end

				local int = getElementInterior(localPlayer.m_LocatingElement)
				local dim = getElementDimension(localPlayer.m_LocatingElement)
				if int > 0 or dim > 0 then
					ErrorBox:new(_("%s ist in einem Gebäude!", elementText))
					self:stopLocating()
				end
				if element:getType() == "player" then
					if not element:getPublicSync("Phone") == true then
						ErrorBox:new(_"Ortung beendet: Der Spieler hat sein Handy ausgeschaltet!")
						self:stopLocating()
					end
				else
					if not element:getData("Wanze") == true then
						ErrorBox:new(_"Ortung beendet: Die Wanze ist nicht mehr verfügbar!")
						self:stopLocating()
					end
				end
			else
				self:stopLocating()
			end
		end, 1000, 0)
	else
		ErrorBox:new(_"Der Spieler konnte nicht geortet werden!\n Er ist in einem Gebäude!")
	end
end

function PolicePanel:stopLocating()
	if ElementLocateBlip then delete(ElementLocateBlip) end
	if isTimer(ElementLocateTimer) then killTimer(ElementLocateTimer) end
	localPlayer.m_LocatingElement = false
end

function PolicePanel:giveWanteds()
	local item = self.m_PlayersGrid:getSelectedItem()
	if item then
		local player = item.player
		GiveWantedBox:new(player)
	else
		ErrorBox:new(_"Kein Spieler ausgewählt!")
	end
end

GiveWantedBox = inherit(GUIForm)

function GiveWantedBox:constructor(player)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.2/2, screenWidth*0.4, screenHeight*0.2)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("%s Wanteds geben", player:getName()), true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.24, self.m_Width*0.5, self.m_Height*0.17, "Anzahl:", self.m_Window)
	self.m_Changer = GUIChanger:new(self.m_Width*0.5, self.m_Height*0.24, self.m_Width*0.2, self.m_Height*0.2, self.m_Window)
	for i = 1, 6 do
		self.m_Changer:addItem(tostring(i))
	end
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.46, self.m_Width*0.5, self.m_Height*0.17, _"Grund:", self.m_Window)
	self.m_ReasonBox = GUIEdit:new(self.m_Width*0.5, self.m_Height*0.46, self.m_Width*0.45, self.m_Height*0.2, self.m_Window)
	self.m_SubmitButton = VRPButton:new(self.m_Width*0.5, self.m_Height*0.75, self.m_Width*0.45, self.m_Height*0.2, _"Bestätigen", true, self.m_Window):setBarColor(Color.Green)
	self.m_SubmitButton.onLeftClick =
	function()
		triggerServerEvent("factionStateGiveWanteds", localPlayer, player, self.m_Changer:getIndex(), self.m_ReasonBox:getText())
		delete(self)
	end
end
