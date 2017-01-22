-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BankGUI.lua
-- *  PURPOSE:     Bank (ATM) GUI class
-- *
-- ****************************************************************************
BankGUI = inherit(GUIForm)
inherit(Singleton, BankGUI)
addEvent("bankMoneyBalanceRetrieve", true)

function BankGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.35, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Bank ATM", true, true, self)
	self.m_HeaderImage = GUIImage:new(self.m_Width*0.01, self.m_Height*0.11, self.m_Width*0.98, self.m_Height*0.25, "files/images/Shops/BankHeader.png", self.m_Window)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.37, self.m_Width*0.25, self.m_Height*0.07, _"Kontostand:", self.m_Window):setColor(Color.Green)
	self.m_AccountBalanceLabel = GUILabel:new(self.m_Width*0.25, self.m_Height*0.37, self.m_Width*0.34, self.m_Height*0.07, "Loading...", self.m_Window)

	self.m_TabPanel = GUITabPanel:new(self.m_Width*0.02, self.m_Height*0.45, self.m_Width-2*self.m_Width*0.02, self.m_Height*0.52, self.m_Window)
	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
	local tabWidth, tabHeight = self.m_TabPanel:getSize()

	self.m_TabWithdraw = self.m_TabPanel:addTab(_"Auszahlen")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Betrag:", self.m_TabWithdraw)
	self.m_WithdrawAmountEdit = GUIEdit:new(tabWidth*0.25, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabWithdraw)
	self.m_WithdrawAmountEdit:setNumeric(true, true)
	self.m_WithdrawButton = VRPButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Auszahlen", true, self.m_TabWithdraw)
	self.m_WithdrawButton.onLeftClick = bind(self.WithdrawButton_Click, self)

	self.m_TabDeposit = self.m_TabPanel:addTab(_"Einzahlen")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Betrag:", self.m_TabDeposit)
	self.m_DepositAmountEdit = GUIEdit:new(tabWidth*0.25, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabDeposit)
	self.m_DepositAmountEdit:setNumeric(true, true)
	self.m_DepositButton = VRPButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Einzahlen", true, self.m_TabDeposit)
	self.m_DepositButton.onLeftClick = bind(self.DepositButton_Click, self)

	self.m_TabTransfer = self.m_TabPanel:addTab(_"Überweisen")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.2, tabHeight*0.15, _"Empfänger:", self.m_TabTransfer)
	self.m_TransferToEdit = GUIEdit:new(tabWidth*0.25, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabTransfer)
	GUILabel:new(tabWidth*0.03, tabHeight*0.28, tabWidth*0.2, tabHeight*0.15, _"Betrag:", self.m_TabTransfer)
	self.m_TransferAmountEdit = GUIEdit:new(tabWidth*0.25, tabHeight*0.28, tabWidth*0.5, tabHeight*0.15, self.m_TabTransfer)
	self.m_TransferAmountEdit:setNumeric(true, true)
	self.m_TransferButton = VRPButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Überweisen", true, self.m_TabTransfer)
	self.m_TransferButton.onLeftClick = bind(self.TransferButton_Click, self)

	if localPlayer:getGroupId() and localPlayer:getGroupId() > 0 then
		self.m_TabGroup = self.m_TabPanel:addTab(_("%s-Konto", localPlayer:getGroupType()))
	end

	-- add money receiv event
	addEventHandler("bankMoneyBalanceRetrieve", root, bind(self.Event_OnMoneyReceive, self))
end

function BankGUI:onShow()
	triggerServerEvent("bankMoneyBalanceRequest", root)

	self.m_TabPanel:forceTab(self.m_TabWithdraw.TabIndex)
end

function BankGUI:Event_OnMoneyReceive(amount)
	self.m_AccountBalanceLabel:setText(tostring(amount).."$")
end

function BankGUI:WithdrawButton_Click()
	local amount = tonumber(self.m_WithdrawAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("bankWithdraw", root, amount)
		self.m_WithdrawAmountEdit:setText("0")
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function BankGUI:DepositButton_Click()
	local amount = tonumber(self.m_DepositAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("bankDeposit", root, amount)
		self.m_DepositAmountEdit:setText("0")
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function BankGUI:TransferButton_Click()
	local amount = tonumber(self.m_TransferAmountEdit:getText())
	local toCharName = self.m_TransferToEdit:getText()
	if amount and amount > 0 then
		triggerServerEvent("bankTransfer", root, toCharName, amount)
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function BankGUI:TabPanel_TabChanged(tabId)
	if self.m_TabGroup then
		if tabId == self.m_TabGroup.TabIndex then
			self:close()
			triggerServerEvent("groupOpenBankGui", localPlayer)
		end
	end
end
