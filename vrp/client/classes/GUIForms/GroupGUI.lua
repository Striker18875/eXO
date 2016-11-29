-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupGUI.lua
-- *  PURPOSE:     Group GUI class
-- *
-- ****************************************************************************
GroupGUI = inherit(GUIForm)
inherit(Singleton, GroupGUI)

function GroupGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	--self.m_CloseButton.onHover = function () self.m_CloseButton:setColor(Color.LightRed) end
	--self.m_CloseButton.onUnhover = function () self.m_CloseButton:setColor(Color.White) end
	self.m_CloseButton.onLeftClick = function() self:close() end

	self.m_BackButton = GUILabel:new(self.m_Width-58, 0, 30, 28, "[←]", self):setFont(VRPFont(35))
	--self.m_BackButton.onHover = function () self.m_BackButton:setColor(Color.LightBlue) end
	--self.m_BackButton.onUnhover = function () self.m_BackButton:setColor(Color.White) end
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	-- Tab: Groups
	local tabGroups = self.m_TabPanel:addTab(_"Allgemein")
	self.m_TabGroups = tabGroups
	self.m_TypeLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Firma / Gang:", tabGroups)
	self.m_GroupsNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupsNameChangeLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.1, self.m_Height*0.06, _"(ändern)", tabGroups):setColor(Color.LightBlue)
	self.m_GroupsNameChangeLabel.onLeftClick = function()
		InputBox:new(_"Namen ändern", _"Bitte gib einen neuen Name für deine Firma / Gang ein! Dies kostet dich 5000$!", function (name) triggerServerEvent("groupChangeName", root, name) end)
		WarningBox:new(_"Achtung: Der Name ist nur alle 30 Tage änderbar!")
	end
	self.m_GroupsNameChangeLabel.onHover = function () self.m_GroupsNameChangeLabel:setColor(Color.White) end
	self.m_GroupsNameChangeLabel.onUnhover = function () self.m_GroupsNameChangeLabel:setColor(Color.LightBlue) end
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabGroups)
	self.m_GroupsKarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.14, self.m_Width*0.25, self.m_Height*0.06, _"Dein Rang:", tabGroups)
	self.m_GroupsRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.14, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupCreateLabel = GUILabel:new(self.m_Width*0.45, self.m_Height*0.14, self.m_Width*0.5, self.m_Height*0.06, _"Du kannst in der Stadthalle eine neue Firma oder Gang gründen!", tabGroups):setMultiline(true)
	self.m_GroupQuitButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.07, _"Verlassen", true, tabGroups):setBarColor(Color.Red)
	self.m_GroupDeleteButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.07, _"Löschen", true, tabGroups):setBarColor(Color.Red)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, _"Kasse:", tabGroups)
	self.m_GroupMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, "", tabGroups)
	--self.m_GroupMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.27, self.m_Height*0.07, tabGroups):setCaption(_"Betrag")
	--self.m_GroupMoneyDepositButton = VRPButton:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", true, tabGroups)
	--self.m_GroupMoneyWithdrawButton = VRPButton:new(self.m_Width*0.56, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", true, tabGroups)
	self.m_GroupPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.4, self.m_Height*0.5, tabGroups)
	self.m_GroupPlayersGrid:addColumn(_"Spieler", 0.7)
	self.m_GroupPlayersGrid:addColumn(_"Rang", 0.3)
	self.m_GroupAddPlayerButton = VRPButton:new(self.m_Width*0.43, self.m_Height*0.4, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", true, tabGroups):setBarColor(Color.Green)
	self.m_GroupRemovePlayerButton = VRPButton:new(self.m_Width*0.43, self.m_Height*0.48, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", true, tabGroups):setBarColor(Color.Red)
	self.m_GroupRankUpButton = VRPButton:new(self.m_Width*0.43, self.m_Height*0.56, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", true, tabGroups)
	self.m_GroupRankDownButton = VRPButton:new(self.m_Width*0.43, self.m_Height*0.64, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", true, tabGroups)

	self.m_GroupInvitationsLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.06, _"Einladungen:", tabGroups)
	self.m_GroupInvitationsGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.6, tabGroups)
	self.m_GroupInvitationsGrid:addColumn(_"Name", 1)
	self.m_GroupInvitationsAcceptButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "✓", tabGroups):setBackgroundColor(Color.Green)
	self.m_GroupInvitationsDeclineButton = GUIButton:new(self.m_Width*0.225, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "✕", tabGroups):setBackgroundColor(Color.Red)

	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
	self.m_GroupQuitButton.onLeftClick = bind(self.GroupQuitButton_Click, self)
	self.m_GroupDeleteButton.onLeftClick = bind(self.GroupDeleteButton_Click, self)
	--self.m_GroupMoneyDepositButton.onLeftClick = bind(self.GroupMoneyDepositButton_Click, self)
	--self.m_GroupMoneyWithdrawButton.onLeftClick = bind(self.GroupMoneyWithdrawButton_Click, self)
	self.m_GroupAddPlayerButton.onLeftClick = bind(self.GroupAddPlayerButton_Click, self)
	self.m_GroupRemovePlayerButton.onLeftClick = bind(self.GroupRemovePlayerButton_Click, self)
	self.m_GroupRankUpButton.onLeftClick = bind(self.GroupRankUpButton_Click, self)
	self.m_GroupRankDownButton.onLeftClick = bind(self.GroupRankDownButton_Click, self)
	self.m_GroupInvitationsAcceptButton.onLeftClick = bind(self.GroupInvitationsAcceptButton_Click, self)
	self.m_GroupInvitationsDeclineButton.onLeftClick = bind(self.GroupInvitationsDeclineButton_Click, self)


	local tabVehicles = self.m_TabPanel:addTab(_"Fahrzeuge")
	self.m_TabVehicles = tabVehicles
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Fahrzeuge:", tabVehicles)
	self.m_VehiclesGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.65, self.m_Height*0.4, tabVehicles)
	self.m_VehiclesGrid:addColumn(_"Name", 0.4)
	self.m_VehiclesGrid:addColumn(_"Standort", 0.6)
	GUILabel:new(self.m_Width*0.695, self.m_Height*0.09, self.m_Width*0.28, self.m_Height*0.06, _"Optionen:", tabVehicles):setColor(Color.LightBlue)
	self.m_VehicleLocateButton = GUIButton:new(self.m_Width*0.695, self.m_Height*0.16, self.m_Width*0.28, self.m_Height*0.07, _"Orten", tabVehicles):setFontSize(1.2)
	self.m_VehicleRespawnButton = GUIButton:new(self.m_Width*0.695, self.m_Height*0.25, self.m_Width*0.28, self.m_Height*0.07, _"Respawn", tabVehicles):setFontSize(1.2)
	self.m_VehicleLocateButton.onLeftClick = bind(self.VehicleLocateButton_Click, self)
	self.m_VehicleRespawnButton.onLeftClick = bind(self.VehicleRespawnButton_Click, self)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.53, self.m_Width*0.25, self.m_Height*0.06, _"Privat-Fahrzeuge:", tabVehicles)
	self.m_PrivateVehiclesGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.65, self.m_Height*0.31, tabVehicles)
	self.m_PrivateVehiclesGrid:addColumn(_"Name", 0.4)
	self.m_PrivateVehiclesGrid:addColumn(_"Standort", 0.6)
	GUILabel:new(self.m_Width*0.695, self.m_Height*0.6, self.m_Width*0.28, self.m_Height*0.06, _"Optionen:", tabVehicles):setColor(Color.LightBlue)
	self.m_VehicleConvertToGroupButton = GUIButton:new(self.m_Width*0.695, self.m_Height*0.67, self.m_Width*0.28, self.m_Height*0.07, _"Fahrzeug zur Firma/Gang hinzufügen", tabVehicles):setFontSize(1)
	self.m_VehicleConvertToGroupButton.onLeftClick = bind(self.VehicleConvertToGroupButton_Click, self)
	--GUILabel:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.4, self.m_Height*0.08, _"Fahrzeug-Info:", tabVehicles)

	self.m_TabLogs = self.m_TabPanel:addTab(_"Logs")

	self.m_LeaderTab = false

	addRemoteEvents{"groupRetrieveInfo", "groupInvitationRetrieve", "groupRetrieveLog"}
	addEventHandler("groupRetrieveInfo", root, bind(self.Event_groupRetrieveInfo, self))
	addEventHandler("groupInvitationRetrieve", root, bind(self.Event_groupInvitationRetrieve, self))
	addEventHandler("groupRetrieveLog", root, bind(self.Event_groupRetrieveLog, self))
	addEventHandler("vehicleRetrieveInfo", root, bind(self.Event_vehicleRetrieveInfo, self))
end

function GroupGUI:onShow()
	self:TabPanel_TabChanged()
end

function GroupGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabLogs.TabIndex then
		triggerServerEvent("groupRequestLog", root)
	else
		triggerServerEvent("groupRequestInfo", root)
	end
end

function GroupGUI:Event_groupRetrieveLog(players, logs)
	if not self.m_LogGUI then
		self.m_LogGUI = LogGUI:new(self.m_TabLogs, logs, players)
	else
		self.m_LogGUI:updateLog(players, logs)
	end
end

function GroupGUI:Event_groupRetrieveInfo(name, rank, money, players, karma, type, rankNames, rankLoans, vehicles, tuningEnabled)
	self:adjustGroupTab(rank or false)

	if name then
		local karma = math.floor(karma)
		local x, y = self.m_GroupsNameLabel:getPosition()
		self.m_GroupsNameChangeLabel:setPosition(x + dxGetTextWidth(name, self.m_GroupsNameLabel:getFontSize(), self.m_GroupsNameLabel:getFont()) + 10, y)
		self.m_GroupsNameLabel:setText(name)
		self.m_GroupsKarmaLabel:setText(tostring(karma > 0 and "+"..karma or karma))
		self.m_GroupsRankLabel:setText(rankNames[tostring(rank)])
		self.m_GroupMoneyLabel:setText(tostring(money).."$")
		self.m_GroupCreateLabel:setVisible(false)
		self.m_TypeLabel:setText(type..":")

		self.m_GroupPlayersGrid:clear()
		for playerId, info in pairs(players) do
			local item = self.m_GroupPlayersGrid:addItem(info.name, info.rank)
			item.Id = playerId
		end
		if rank >= GroupRank.Manager then
			self.m_RankNames = rankNames
			self.m_RankLoans = rankLoans
			self:addLeaderTab()
			self:refreshRankGrid()

			-- Update options
			local text = tuningEnabled and _"aktiviert" or _"deaktiviert"
			local x, y = self.m_VehicleTuningStatus:getPosition()
			self.m_VehicleTuningStatus:setText(text)
			self.m_VehicleTuningStatusChange:setPosition(x + dxGetTextWidth(text, self.m_VehicleTuningStatus:getFontSize(), self.m_VehicleTuningStatus:getFont()) + 10, y)
		end

		-- Group Vehicles
		self.m_VehiclesGrid:clear()
		if vehicles then
			for key, veh in pairs(vehicles) do
				local x, y, z = veh:getPosition()
				local item = self.m_VehiclesGrid:addItem(getVehicleName(veh), getZoneName(x, y, z, false))
				item.VehicleElement = veh
			end
		end
	else
		self.m_GroupCreateLabel:setVisible(true)
	end
end

function GroupGUI:Event_vehicleRetrieveInfo(vehiclesInfo)
	if vehiclesInfo then
		self.m_PrivateVehiclesGrid:clear()
		local vehInfo = {}
		for vehicleId, vehicleInfo in pairs(vehiclesInfo) do
			table.insert(vehInfo, {vehicleId, vehicleInfo})
		end
		table.sort(vehInfo, function (a, b) return (a[2][2] < b[2][2]) end)
		for i, vehicleInfo in ipairs(vehInfo) do
			local vehicleId, vehicleInfo = unpack(vehicleInfo)
			local element, positionType = unpack(vehicleInfo)
			local x, y, z = getElementPosition(element)
			if positionType == VehiclePositionType.World then
				positionType = getZoneName(x, y, z, false)
			elseif positionType == VehiclePositionType.Garage then
				positionType = _"Garage"
			elseif positionType == VehiclePositionType.Mechanic then
				positionType = _"Autohof"
			elseif positionType == VehiclePositionType.Hangar then
				positionType = _"Hangar"
			elseif positionType == VehiclePositionType.Harbor then
				positionType = _"Hafen"
			else
				positionType = _"Unbekannt"
			end
			local item = self.m_PrivateVehiclesGrid:addItem(element:getName(), positionType)
			item.VehicleId = vehicleId
			item.VehicleElement = element
			item.PositionType = vehicleInfo[2]
		end
	end
end

function GroupGUI:Event_groupInvitationRetrieve(groupId, name)
	local item = self.m_GroupInvitationsGrid:addItem(name)
	item.GroupId = groupId
end

function GroupGUI:adjustGroupTab(rank)
	local isInGroup = rank ~= false

	for k, element in ipairs(self.m_TabGroups:getChildren()) do
		if element ~= self.m_GroupCreateLabel then
			element:setVisible(isInGroup)
		end
	end
	self.m_GroupInvitationsLabel:setVisible(false)
	self.m_GroupInvitationsGrid:setVisible(false)
	self.m_GroupInvitationsAcceptButton:setVisible(false)
	self.m_GroupInvitationsDeclineButton:setVisible(false)

	if rank then
		if rank == GroupRank.Leader then
			self.m_GroupDeleteButton:setVisible(true)
		else
			self.m_GroupDeleteButton:setVisible(false)
		end
		if rank < GroupRank.Manager then
			--self.m_GroupMoneyWithdrawButton:setVisible(false)
			self.m_GroupAddPlayerButton:setVisible(false)
			self.m_GroupRemovePlayerButton:setVisible(false)
			self.m_GroupRankUpButton:setVisible(false)
			self.m_GroupRankDownButton:setVisible(false)
		end
	else
		-- We're not in a group, so show the invitation stuff
		self.m_GroupInvitationsLabel:setVisible(true)
		self.m_GroupInvitationsGrid:setVisible(true)
		self.m_GroupInvitationsAcceptButton:setVisible(true)
		self.m_GroupInvitationsDeclineButton:setVisible(true)
		self.m_TabVehicles:setVisible(false)
		self.m_TabLogs:setVisible(false)
		if self.m_LeaderTab then
			self.m_TabLeader:setVisible(false)
		end
	end
end

function GroupGUI:GroupQuitButton_Click()
	triggerServerEvent("groupQuit", root)
end

function GroupGUI:GroupDeleteButton_Click()
	QuestionBox:new(_"Möchtest du deine Firma/Gang wirklich löschen\n Es werden keine Kosten erstattet!", function()
		triggerServerEvent("groupDelete", root)
	end)
end

function GroupGUI:GroupMoneyDepositButton_Click()
	local amount = tonumber(self.m_GroupMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("groupDeposit", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function GroupGUI:GroupMoneyWithdrawButton_Click()
	local amount = tonumber(self.m_GroupMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("groupWithdraw", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function GroupGUI:GroupAddPlayerButton_Click()
	InviteGUI:new(
		function(player)
			triggerServerEvent("groupAddPlayer", root, player)
		end
	)
end

function GroupGUI:GroupRemovePlayerButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupDeleteMember", root, selectedItem.Id)
	else
		ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online")
	end
end

function GroupGUI:GroupRankUpButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupRankUp", root, selectedItem.Id)
	end
end

function GroupGUI:GroupRankDownButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupRankDown", root, selectedItem.Id)
	end
end

function GroupGUI:GroupInvitationsAcceptButton_Click()
	local selectedItem = self.m_GroupInvitationsGrid:getSelectedItem()
	if selectedItem then
		if selectedItem.GroupId then
			triggerServerEvent("groupInvitationAccept", resourceRoot, selectedItem.GroupId)
		end
		self.m_GroupInvitationsGrid:removeItemByItem(selectedItem)
	end
end

function GroupGUI:GroupInvitationsDeclineButton_Click()
	local selectedItem = self.m_GroupInvitationsGrid:getSelectedItem()
	if selectedItem then
		if selectedItem.GroupId then
			triggerServerEvent("groupInvitationDecline", resourceRoot, selectedItem.GroupId)
		end
		self.m_GroupInvitationsGrid:removeItemByItem(selectedItem)
	end
end

function GroupGUI:addLeaderTab()
	if self.m_LeaderTab == false then
		local tabLeader = self.m_TabPanel:addTab(_"Leader")
		self.m_TabLeader = tabLeader
		self.m_FactionRangGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.025, self.m_Width*0.4, self.m_Height*0.95, tabLeader)
		self.m_FactionRangGrid:addColumn(_"Rang", 0.2)
		self.m_FactionRangGrid:addColumn(_"Name", 0.8)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.06, _"Rangname:", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderRankName = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, tabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Gehalt: (in $)", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderLoan = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.28, self.m_Width*0.1, self.m_Height*0.06, tabLeader)
		self.m_LeaderLoan:setNumeric(true, true)

		self.m_SaveRank = VRPButton:new(self.m_Width*0.69, self.m_Height*0.28, self.m_Width*0.3, self.m_Height*0.06, _"Rang speichern", true, tabLeader)
		self.m_SaveRank.onLeftClick = bind(self.saveRank, self)
		self.m_SaveRank:setEnabled(false)

		GUIRectangle:new(self.m_Width*0.45, self.m_Height*0.36, self.m_Width*0.525, 2, Color.LightBlue, tabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.38, self.m_Width*0.4, self.m_Height*0.09, _"Optionen:", tabLeader):setColor(Color.LightBlue)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.48, self.m_Width*0.4, self.m_Height*0.06, _"Fahrzeug-Tuning:", tabLeader)
		self.m_VehicleTuningStatus = GUILabel:new(self.m_Width*0.7, self.m_Height*0.48, self.m_Width*0.4, self.m_Height*0.06, "", tabLeader)
		self.m_VehicleTuningStatusChange = GUILabel:new(self.m_Width*0.7, self.m_Height*0.48, self.m_Width*0.4, self.m_Height*0.06, _"(ändern)", tabLeader):setColor(Color.LightBlue)
		self.m_VehicleTuningStatusChange.onLeftClick = function () triggerServerEvent("groupUpdateVehicleTuning", root) end
		self.m_VehicleTuningStatusChange.onHover = function () self.m_VehicleTuningStatusChange:setColor(Color.White) end
		self.m_VehicleTuningStatusChange.onUnhover = function () self.m_VehicleTuningStatusChange:setColor(Color.LightBlue) end

		self:refreshRankGrid()
		self.m_LeaderTab = true
	end
end

function GroupGUI:saveRank()
	if self.m_SelectedRank then
		triggerServerEvent("groupSaveRank",localPlayer,self.m_SelectedRank,self.m_LeaderRankName:getText(),self.m_LeaderLoan:getText())
	end
end

function GroupGUI:refreshRankGrid()
	self.m_FactionRangGrid:clear()
	-- Todo: tempfix
	local tab = {}
	for i, v in pairs(self.m_RankNames) do
		tab[tonumber(i)+1] = v
	end
	for rank, name in ipairs(tab) do
		local rank = rank - 1
	--
		local item = self.m_FactionRangGrid:addItem(rank, name)
		item.Id = rank
		item.onLeftClick = function()
			self.m_SelectedRank = rank
			self:onSelectRank(name,rank)
		end

		if rank == self.m_SelectedRank then
			self.m_FactionRangGrid:onInternalSelectItem(item)
			item.onLeftClick()
		end
	end
end

function GroupGUI:onSelectRank(name,rank)
	self.m_LeaderRankName:setText(tostring(self.m_RankNames[tostring(rank)]))
	self.m_LeaderLoan:setText(tostring(self.m_RankLoans[tostring(rank)]))
	self.m_SaveRank:setEnabled(true)
end

function GroupGUI:VehicleRespawnButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	triggerServerEvent("vehicleRespawn", item.VehicleElement)
end

function GroupGUI:VehicleConvertToGroupButton_Click()
	local item = self.m_PrivateVehiclesGrid:getSelectedItem()
	if not item then
		ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	if item.PositionType == VehiclePositionType.Garage then
		ErrorBox:new(_"Das Fahrzeug darf sich nicht in der Garage befinden!")
		return
	end
	if item.PositionType == VehiclePositionType.Mechanic then
		ErrorBox:new(_"Das Fahrzeug darf sich nicht im Autohof befinden!")
		return
	end
	triggerServerEvent("groupConvertVehicle", localPlayer, item.VehicleElement)
end

function GroupGUI:VehicleLocateButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	local x, y, z = getElementPosition(item.VehicleElement)
	local blip = Blip:new("Waypoint.png", x, y,root,500)
	--[[if localPlayer has Item:'Find.dat.Car+' then]] -- TODO: add this item!
		ShortMessage:new(_("Dieses Fahrzeug befindet sich in %s!\n(Siehe Blip auf der Karte)\n(Klicke hier um das Blip zu löschen!)", getZoneName(x, y, z, false)), "Fahrzeug-Ortung+", Color.DarkLightBlue, -1)
		.m_Callback = function (this)
			if blip then
				delete(blip)
			end
			delete(this)
		end
	--else
		--setTimer(function () delete(blip) end, 5000, 1)
		--ShortMessage:new(_("Dieses Fahrzeug befindet sich in %s!\n(Siehe Blip auf der Karte)", getZoneName(x, y, z, false)), "Fahrzeug-Ortung", Color.DarkLightBlue)
	--end
end
