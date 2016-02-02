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
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Gruppe:", tabGroups)
	self.m_GroupsNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupsNameChangeLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.1, self.m_Height*0.06, _"(ändern)", tabGroups):setColor(Color.LightBlue)
	self.m_GroupsNameChangeLabel.onLeftClick = function() InputBox:new(_"Gruppennamen ändern", _"Bitte gib einen neuen Name für deine Gruppe ein! Dies kostet dich 20000$!", function (name) triggerServerEvent("groupChangeName", root, name) end) end
	self.m_GroupsNameChangeLabel.onHover = function () self.m_GroupsNameChangeLabel:setColor(Color.White) end
	self.m_GroupsNameChangeLabel.onUnhover = function () self.m_GroupsNameChangeLabel:setColor(Color.LightBlue) end
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabGroups)
	self.m_GroupsKarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.14, self.m_Width*0.25, self.m_Height*0.06, _"Gruppenrang:", tabGroups)
	self.m_GroupsRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.14, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupCreateButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Erstellen", true, tabGroups):setBarColor(Color.Green)
	self.m_GroupQuitButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.07, _"Verlassen", true, tabGroups):setBarColor(Color.Red)
	self.m_GroupDeleteButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.07, _"Löschen", true, tabGroups):setBarColor(Color.Red)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, _"Kasse:", tabGroups)
	self.m_GroupMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, "", tabGroups)
	self.m_GroupMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.27, self.m_Height*0.07, tabGroups):setCaption(_"Betrag")
	self.m_GroupMoneyDepositButton = VRPButton:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", true, tabGroups)
	self.m_GroupMoneyWithdrawButton = VRPButton:new(self.m_Width*0.56, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", true, tabGroups)
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
	self.m_GroupInvitationsAcceptButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "?", tabGroups):setBackgroundColor(Color.Green)
	self.m_GroupInvitationsDeclineButton = GUIButton:new(self.m_Width*0.225, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "?", tabGroups):setBackgroundColor(Color.Red)

	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
	self.m_GroupCreateButton.onLeftClick = bind(self.GroupCreateButton_Click, self)
	self.m_GroupQuitButton.onLeftClick = bind(self.GroupQuitButton_Click, self)
	self.m_GroupDeleteButton.onLeftClick = bind(self.GroupDeleteButton_Click, self)
	self.m_GroupMoneyDepositButton.onLeftClick = bind(self.GroupMoneyDepositButton_Click, self)
	self.m_GroupMoneyWithdrawButton.onLeftClick = bind(self.GroupMoneyWithdrawButton_Click, self)
	self.m_GroupAddPlayerButton.onLeftClick = bind(self.GroupAddPlayerButton_Click, self)
	self.m_GroupRemovePlayerButton.onLeftClick = bind(self.GroupRemovePlayerButton_Click, self)
	self.m_GroupRankUpButton.onLeftClick = bind(self.GroupRankUpButton_Click, self)
	self.m_GroupRankDownButton.onLeftClick = bind(self.GroupRankDownButton_Click, self)
	self.m_GroupInvitationsAcceptButton.onLeftClick = bind(self.GroupInvitationsAcceptButton_Click, self)
	self.m_GroupInvitationsDeclineButton.onLeftClick = bind(self.GroupInvitationsDeclineButton_Click, self)
	addRemoteEvents{"groupRetrieveInfo", "groupInvitationRetrieve"}
	addEventHandler("groupRetrieveInfo", root, bind(self.Event_groupRetrieveInfo, self))
	addEventHandler("groupInvitationRetrieve", root, bind(self.Event_groupInvitationRetrieve, self))

	local tabVehicles = self.m_TabPanel:addTab(_"Fahrzeuge")
	self.m_GroupVehicleGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.55, tabVehicles)
	self.m_GroupVehicleGrid:addColumn(_"Fahrzeuge", 1)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.4, self.m_Height*0.08, _"Fahrzeug-Info:", tabVehicles)

	self.m_VehicleLocateButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.09, self.m_Width*0.28, self.m_Height*0.07, _"Orten", true, tabVehicles)
	self.m_VehicleRespawnButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.18, self.m_Width*0.28, self.m_Height*0.07, _"Respawn", true, tabVehicles)
	self.m_VehicleMakeGroupVehicleButton = GUIButton:new(self.m_Width*0.695, self.m_Height*0.27, self.m_Width*0.28, self.m_Height*0.07, _"Fahrzeug zur Firma/Gang hinzufügen", tabVehicles):setFontSize(1)
	self.m_VehicleLocateButton.onLeftClick = bind(self.VehicleLocateButton_Click, self)
	self.m_VehicleRespawnButton.onLeftClick = bind(self.VehicleRespawnButton_Click, self)
	addRemoteEvents{"groupVehicleRetrieveInfo"}
	addEventHandler("groupVehicleRetrieveInfo", root, bind(self.Event_vehicleRetrieveInfo, self))
end

function GroupGUI:onShow()
	self:TabPanel_TabChanged()
end

function GroupGUI:TabPanel_TabChanged()
	triggerServerEvent("groupRequestInfo", root)
end

function GroupGUI:Event_groupRetrieveInfo(name, rank, money, players, karma)
	self:adjustGroupTab(rank or false)

	if name then
		local karma = math.floor(karma)
		local x, y = self.m_GroupsNameLabel:getPosition()
		self.m_GroupsNameChangeLabel:setPosition(x + dxGetTextWidth(name, self.m_GroupsNameLabel:getFontSize(), self.m_GroupsNameLabel:getFont()) + 10, y)
		self.m_GroupsNameLabel:setText(name)
		self.m_GroupsKarmaLabel:setText(tostring(karma > 0 and "+"..karma or karma))
		self.m_GroupsRankLabel:setText(GroupRank[rank])
		self.m_GroupMoneyLabel:setText(tostring(money).."$")

		self.m_GroupPlayersGrid:clear()
		for playerId, info in pairs(players) do
			local item = self.m_GroupPlayersGrid:addItem(info.name, info.rank)
			item.Id = playerId
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
		if element ~= self.m_GroupCreateButton then
			element:setVisible(isInGroup)
		end
	end
	self.m_GroupInvitationsLabel:setVisible(false)
	self.m_GroupInvitationsGrid:setVisible(false)
	self.m_GroupInvitationsAcceptButton:setVisible(false)
	self.m_GroupInvitationsDeclineButton:setVisible(false)

	if rank then
		if rank ~= GroupRank.Leader then
			self.m_GroupDeleteButton:setVisible(false)
		end
		if rank < GroupRank.Manager then
			self.m_GroupMoneyWithdrawButton:setVisible(false)
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
	end
end

function GroupGUI:GroupCreateButton_Click()
	GroupCreationGUI:new()
end

function GroupGUI:GroupQuitButton_Click()
	triggerServerEvent("groupQuit", root)
end

function GroupGUI:GroupDeleteButton_Click()
	triggerServerEvent("groupDelete", root)
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
	GroupInviteGUI:new()
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


function GroupGUI:Event_vehicleRetrieveInfo()

end

function GroupGUI:VehicleRespawnButton_Click()

end

function GroupGUI:VehicleLocateButton_Click()

end
