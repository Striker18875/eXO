-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SelfGUI.lua
-- *  PURPOSE:     Self menu GUI class
-- *
-- ****************************************************************************
SelfGUI = inherit(GUIForm)
inherit(Singleton, SelfGUI)

function SelfGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	--self.m_CloseButton.onHover = function () self.m_CloseButton:setColor(Color.LightRed) end
	--self.m_CloseButton.onUnhover = function () self.m_CloseButton:setColor(Color.White) end
	self.m_CloseButton.onLeftClick = function() self:close() end

	-- Tab: Allgemein
	local tabGeneral = self.m_TabPanel:addTab(_"Allgemein")
	self.m_TabGeneral = tabGeneral
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.10, _"Allgemein", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.11, self.m_Width*0.25, self.m_Height*0.06, _"Spielzeit:", tabGeneral)
	self.m_PlayTimeLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.11, self.m_Width*0.4, self.m_Height*0.06, _"0 Stunde(n) 0 Minute(n)", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.17, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabGeneral)
	self.m_GeneralKarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.17, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, _"Unternehmen:", tabGeneral)
	self.m_CompanyNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	self.m_CompanyEditLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.125, self.m_Height*0.06, _"(anzeigen)", tabGeneral):setColor(Color.LightBlue)
	self.m_CompanyEditLabel.onHover = function () self.m_CompanyEditLabel:setColor(Color.White) end
	self.m_CompanyEditLabel.onUnhover = function () self.m_CompanyEditLabel:setColor(Color.LightBlue) end
	self.m_CompanyEditLabel.onLeftClick = bind(self.CompanyMenuButton_Click, self)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.06, _"Aktueller Job:", tabGeneral)
	self.m_JobNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	self.m_JobQuitButton = GUILabel:new(self.m_Width*0.7, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.06, _"(Job kündigen)", tabGeneral):setColor(Color.Red)
	self.m_JobQuitButton.onHover = function () self.m_JobQuitButton:setColor(Color.White) end
	self.m_JobQuitButton.onUnhover = function () self.m_JobQuitButton:setColor(Color.Red) end
	self.m_JobQuitButton.onLeftClick = bind(self.JobQuitButton_Click, self)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.35, self.m_Width*0.25, self.m_Height*0.06, _"Aktuelle AFK-Zeit:", tabGeneral)
	self.m_AFKTimeLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.35, self.m_Width*0.4, self.m_Height*0.06, _"0 Minute(n)", tabGeneral)

	self.m_AdButton = VRPButton:new(self.m_Width*0.73, self.m_Height*0.05, self.m_Width*0.25, self.m_Height*0.07, _"Werbung schalten", true, tabGeneral)
	self.m_AdButton.onLeftClick = bind(self.AdButton_Click, self)

	self.m_TicketButton = VRPButton:new(self.m_Width*0.73, self.m_Height*0.13, self.m_Width*0.25, self.m_Height*0.07, _"Tickets", true, tabGeneral):setBarColor(Color.Green)
	self.m_TicketButton.onLeftClick = bind(self.TicketButton_Click, self)

	self.m_MigrationButton = VRPButton:new(self.m_Width*0.73, self.m_Height*0.21, self.m_Width*0.25, self.m_Height*0.07, _"Account-Migration", true, tabGeneral):setBarColor(Color.Yellow)
	self.m_MigrationButton.onLeftClick = bind(self.MigratorButton_Click, self)

	self.m_WarnButton = VRPButton:new(self.m_Width*0.73, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Warns anzeigen", true, tabGeneral):setBarColor(Color.Yellow)
	self.m_WarnButton.onLeftClick = function() self:close() WarnManagement:new(localPlayer) end

	if localPlayer:getRank() > 0 then
		self.m_AdminButton = VRPButton:new(self.m_Width*0.73, self.m_Height*0.37, self.m_Width*0.25, self.m_Height*0.07, _"Adminmenü", true, tabGeneral):setBarColor(Color.Red)
		self.m_AdminButton.onLeftClick = bind(self.AdminButton_Click, self)
	end

	addRemoteEvents{"companyRetrieveInfo", "companyInvitationRetrieve"}
	addEventHandler("companyRetrieveInfo", root, bind(self.Event_companyRetrieveInfo, self))

	--addEventHandler("companyInvitationRetrieve", root, bind(self.Event_companyInvitationRetrieve, self))

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.25, self.m_Height*0.10, _"Fraktion", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.49, self.m_Width*0.25, self.m_Height*0.06, _"Aktuelle Fraktion:", tabGeneral)
	self.m_FactionNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.49, self.m_Width*0.64, self.m_Height*0.06, "", tabGeneral)
	self.m_FactionMenuButton = GUILabel:new(self.m_Width*0.3, self.m_Height*0.49, self.m_Width*0.4, self.m_Height*0.06, _"(anzeigen)", tabGeneral):setColor(Color.LightBlue)
	self.m_FactionMenuButton.onHover = function () self.m_FactionMenuButton:setColor(Color.White) end
	self.m_FactionMenuButton.onUnhover = function () self.m_FactionMenuButton:setColor(Color.LightBlue) end
	--self.m_FactionMenuButton = GUIButton:new(self.m_Width*0.7, self.m_Height*0.49, self.m_Width*0.25, self.m_Height*0.06, _"Fraktions-Menü", tabGeneral):setBackgroundColor(Color.Blue)
	--self.m_FactionMenuButton:setFontSize(1.2)
	self.m_FactionMenuButton:setVisible(false)
	self.m_FactionMenuButton.onLeftClick = bind(self.FactionMenuButton_Click, self)
	self.m_FactionInvationLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.55, self.m_Width*0.8, self.m_Height*0.06, "", tabGeneral)
	self.m_FactionInvationLabel:setVisible(false)
	self.m_FactionInvitationsAcceptButton = GUIButton:new(self.m_Width*0.8, self.m_Height*0.55, self.m_Width*0.08, self.m_Height*0.06, "✓", tabGeneral):setBackgroundColor(Color.Green)
	self.m_FactionInvitationsAcceptButton:setVisible(false)
	self.m_FactionInvitationsDeclineButton = GUIButton:new(self.m_Width*0.9, self.m_Height*0.55, self.m_Width*0.08, self.m_Height*0.06, "✕", tabGeneral):setBackgroundColor(Color.Red)
	self.m_FactionInvitationsDeclineButton:setVisible(false)
	self.m_FactionInvitationsAcceptButton.onLeftClick = bind(self.FactionInvitationsAcceptButton_Click, self)
	self.m_FactionInvitationsDeclineButton.onLeftClick = bind(self.FactionInvitationsDeclineButton_Click, self)
	addRemoteEvents{"factionRetrieveInfo", "factionInvitationRetrieve"}
	addEventHandler("factionRetrieveInfo", root, bind(self.Event_factionRetrieveInfo, self))
	addEventHandler("factionInvitationRetrieve", root, bind(self.Event_factionInvitationRetrieve, self))

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.9, self.m_Height*0.10, _"Private Firma / Gang:", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.69, self.m_Width*0.25, self.m_Height*0.06, _"Firma / Gang:", tabGeneral)
	self.m_GroupNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.69, self.m_Width*0.35, self.m_Height*0.06, "", tabGeneral)
	self.m_GroupMenuButton = GUILabel:new(self.m_Width*0.3, self.m_Height*0.69, self.m_Width*0.135, self.m_Height*0.06, _"(verwalten)", tabGeneral):setColor(Color.LightBlue)
	self.m_GroupMenuButton.onHover = function () self.m_GroupMenuButton:setColor(Color.White) end
	self.m_GroupMenuButton.onUnhover = function () self.m_GroupMenuButton:setColor(Color.LightBlue) end
	self.m_GroupMenuButton.onLeftClick = bind(self.GroupMenuButton_Click, self)
	self.m_GroupInvitationsLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.79, self.m_Width*0.8, self.m_Height*0.06, "", tabGeneral)
	self.m_GroupInvitationsLabel:setVisible(false)
	addRemoteEvents{"groupRetrieveInfo", "groupInvitationRetrieve"}
	addEventHandler("groupRetrieveInfo", root, bind(self.Event_groupRetrieveInfo, self))
	addEventHandler("groupInvitationRetrieve", root, bind(self.Event_groupInvitationRetrieve, self))

	-- Tab: Statistics
	local tabStatistics = self.m_TabPanel:addTab(_"Statistiken")
	self.m_TabStatistics = tabStatistics

	-- Tab: Vehicles
	local tabVehicles = self.m_TabPanel:addTab(_"Fahrzeuge")
	self.m_TabVehicles = tabVehicles
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Fahrzeuge:", tabVehicles)
	self.m_VehiclesGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.65, self.m_Height*0.6, tabVehicles)
	self.m_VehiclesGrid:addColumn(_"Name", 0.4)
	self.m_VehiclesGrid:addColumn(_"Standort", 0.6)
	self.m_VehicleGarages = GUILabel:new(self.m_Width*0.02, self.m_Height*0.75, self.m_Width*0.5, self.m_Height*0.06, _"Garage:", tabVehicles)
	self.m_VehicleGarageUpgradeButton = GUILabel:new(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleGarages:getText(), self.m_VehicleGarages:getFontSize(), self.m_VehicleGarages:getFont()) + 5, self.m_Height*0.75, self.m_Width*0.17, self.m_Height*0.06, _"(Kaufen: 0$)", tabVehicles):setColor(Color.LightBlue)
	self.m_VehicleGarageUpgradeButton.onHover = function () self.m_VehicleGarageUpgradeButton:setColor(Color.White) end
	self.m_VehicleGarageUpgradeButton.onUnhover = function () self.m_VehicleGarageUpgradeButton:setColor(Color.LightBlue) end
	self.m_VehicleHangar = GUILabel:new(self.m_Width*0.02, self.m_Height*0.81, self.m_Width*0.5, self.m_Height*0.06, _"Hangar:", tabVehicles)
	self.m_VehicleHangarButton = GUILabel:new(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleGarages:getText(), self.m_VehicleGarages:getFontSize(), self.m_VehicleGarages:getFont()) + 5, self.m_Height*0.81, self.m_Width*0.17, self.m_Height*0.06, _"(Kaufen: 0$)", tabVehicles):setColor(Color.LightBlue)
	self.m_VehicleHangarButton.onHover = function () self.m_VehicleHangarButton:setColor(Color.White) end
	self.m_VehicleHangarButton.onUnhover = function () self.m_VehicleHangarButton:setColor(Color.LightBlue) end
	self.m_VehicleLocateButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.09, self.m_Width*0.28, self.m_Height*0.07, _"Orten", true, tabVehicles)
	self.m_VehicleSellButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.18, self.m_Width*0.28, self.m_Height*0.07, _"Verkaufen", true, tabVehicles)
 	GUILabel:new(self.m_Width*0.695, self.m_Height*0.30, self.m_Width*0.28, self.m_Height*0.06, _"Respawnen:", tabVehicles):setColor(Color.LightBlue)
 	self.m_VehicleRespawnButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.37, self.m_Width*0.28, self.m_Height*0.07, _"in Garage", true, tabVehicles)
 	self.m_VehicleWorldRespawnButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.46, self.m_Width*0.28, self.m_Height*0.07, _"an Parkposition", true, tabVehicles)

	self.m_VehicleGarageUpgradeButton.onLeftClick = bind(self.VehicleGarageUpgradeButton_Click, self)
	self.m_VehicleHangarButton.onLeftClick = bind(self.VehicleHangarButton_Click, self)
	self.m_VehicleLocateButton.onLeftClick = bind(self.VehicleLocateButton_Click, self)
	self.m_VehicleSellButton.onLeftClick = bind(self.VehicleSellButton_Click, self)
	self.m_VehicleRespawnButton.onLeftClick = bind(self.VehicleRespawnButton_Click, self)
	self.m_VehicleWorldRespawnButton.onLeftClick = bind(self.VehicleWorldRespawnButton_Click, self)
	addRemoteEvents{"vehicleRetrieveInfo"}
	addEventHandler("vehicleRetrieveInfo", root, bind(self.Event_vehicleRetrieveInfo, self))

	-- Tab: Points
	local tabPoints = self.m_TabPanel:addTab(_"Punkte")
	self.m_TabPoints = tabPoints
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Punkte:", tabPoints):setColor(Color.Yellow)
	self.m_PointsLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "0", tabPoints):setColor(Color.Yellow)
	localPlayer:setPrivateSyncChangeHandler("Points", function(value) self.m_PointsLabel:setText(tostring(value)) end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabPoints)
	self.m_KarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.1, self.m_Width*0.4, self.m_Height*0.06, "+0", tabPoints)
	localPlayer:setPrivateSyncChangeHandler("KarmaLevel", function(value) self.m_KarmaLabel:setText(tostring(math.floor(value))) end)
	self.m_KarmaLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.1, self.m_Width*0.15, self.m_Height*0.06, "+ (200P)", tabPoints):setBackgroundColor(Color.Green)
	self.m_KarmaLevelButton.onLeftClick = function() triggerServerEvent("requestPointsToKarma", resourceRoot, true) end
	self.m_KarmaLevelButton = GUIButton:new(self.m_Width*0.55, self.m_Height*0.1, self.m_Width*0.15, self.m_Height*0.06, "- (200P)", tabPoints):setBackgroundColor(Color.Red)
	self.m_KarmaLevelButton.onLeftClick = function() triggerServerEvent("requestPointsToKarma", resourceRoot, false) end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.06, _"Skinlevel:", tabPoints)
	self.m_SkinLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.18, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getSkinLevel(), tabPoints)
	self.m_SkinLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.18, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_SkinLevelButton.onLeftClick = function() triggerServerEvent("requestSkinLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("SkinLevel", function(value)
		self.m_SkinLevelLabel:setText(tostring(value))
		if value >= MAX_SKIN_LEVEL then
			self.m_SkinLevelButton:setText("Max. Level"):setEnabled(false)
		else
			self.m_SkinLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())))
		end
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.26, self.m_Width*0.25, self.m_Height*0.06, _"Fahrzeuglevel:", tabPoints)
	self.m_VehicleLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.26, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getVehicleLevel(), tabPoints)
	self.m_VehicleLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.26, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_VehicleLevelButton.onLeftClick = function() triggerServerEvent("requestVehicleLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("VehicleLevel", function(value)
		self.m_VehicleLevelLabel:setText(tostring(value))
		if value >= MAX_VEHICLE_LEVEL then
			self.m_VehicleLevelButton:setText("Max. Level"):setEnabled(false)
		else
			self.m_VehicleLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())))
		end
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.42, self.m_Width*0.25, self.m_Height*0.06, _"Waffenlevel:", tabPoints)
	self.m_WeaponLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.42, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getWeaponLevel(), tabPoints)
	GUILabel:new(self.m_Width*0.4, self.m_Height*0.42, self.m_Width*0.6, self.m_Height*0.06, "Trainiere dein Waffenlevel im LSPD", tabPoints)
	localPlayer:setPrivateSyncChangeHandler("WeaponLevel", function(value)
		self.m_WeaponLevelLabel:setText(tostring(value))
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.34, self.m_Width*0.25, self.m_Height*0.06, _"Joblevel:", tabPoints)
	self.m_JobLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.34, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getJobLevel(), tabPoints)
	self.m_JobLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.34, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_JobLevelButton.onLeftClick = function() triggerServerEvent("requestJobLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("JobLevel", function(value)
		self.m_JobLevelLabel:setText(tostring(value))
		if value >= MAX_JOB_LEVEL then
			self.m_JobLevelButton:setText("Max. Level"):setEnabled(false)
		else
			self.m_JobLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())))
		end
	end)

	-- Tab: Settings
	local tabSettings = self.m_TabPanel:addTab(_"Einstellungen")
	self.m_TabSettings = tabSettings
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"HUD / Radar", tabSettings)
	self.m_RadarChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.35, self.m_Height*0.07, tabSettings)
	for i, v in ipairs(RadarDesign) do
		self.m_RadarChange:addItem(v)
	end
	self.m_RadarChange.onChange = function(text, index) HUDRadar:getSingleton():setDesignSet(index) end
	self.m_RadarChange:setIndex(core:get("HUD", "RadarDesign") or 2, true)

	self.m_RadarCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.19, self.m_Width*0.35, self.m_Height*0.04, _"Radar aktivieren?", tabSettings)
	self.m_RadarCheckBox:setFont(VRPFont(25))
	self.m_RadarCheckBox:setFontSize(1)
	self.m_RadarCheckBox:setChecked(core:get("HUD", "showRadar", true))
	self.m_RadarCheckBox.onChange = function (state)
		core:set("HUD", "showRadar", state)
		HUDRadar:getSingleton():setEnabled(state)
	end

	self.m_BlipCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.25, self.m_Width*0.35, self.m_Height*0.04, _"Blips anzeigen?", tabSettings)
	self.m_BlipCheckBox:setFont(VRPFont(25))
	self.m_BlipCheckBox:setFontSize(1)
	self.m_BlipCheckBox:setChecked(core:get("HUD", "drawBlips", true))
	self.m_BlipCheckBox.onChange = function (state)
		core:set("HUD", "drawBlips", state)
	end

	self.m_GangAreaCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.31, self.m_Width*0.35, self.m_Height*0.04, _"Gangareas anzeigen?", tabSettings)
	self.m_GangAreaCheckBox:setFont(VRPFont(25))
	self.m_GangAreaCheckBox:setFontSize(1)
	self.m_GangAreaCheckBox:setChecked(core:get("HUD", "drawGangAreas", true))
	self.m_GangAreaCheckBox.onChange = function (state)
		core:set("HUD", "drawGangAreas", state)
		HUDRadar:getSingleton():updateMapTexture()
	end

	GUILabel:new(self.m_Width*0.5, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"HUD / UI", tabSettings)
	self.m_UIChange = GUIChanger:new(self.m_Width*0.5, self.m_Height*0.09, self.m_Width*0.35, self.m_Height*0.07, tabSettings)
	for i, v in ipairs(UIStyle) do
		self.m_UIChange:addItem(v)
	end
	self.m_UIChange.onChange = function(text, index)
		core:set("HUD", "UIStyle", index)
		HUDUI:getSingleton():setUIMode(index)
		if index == UIStyle.vRoleplay then
			self.m_LifeArmor:setVisible(true)
			self.m_ZoneName:setVisible(true)
			self.m_LabelHUDScale1:setVisible(false);
			self.m_LabelHUDScale2:setVisible(false);
			self.m_LabelHUDScale3:setVisible(false);
			self.m_HUDScale:setVisible(false);
		elseif index == UIStyle.eXo then
			self.m_LabelHUDScale1:setVisible(true);
			self.m_LabelHUDScale2:setVisible(true);
			self.m_LabelHUDScale3:setVisible(true);
			self.m_HUDScale:setVisible(true);
			self.m_LifeArmor:setVisible(false)
			self.m_ZoneName:setVisible(false)
		else
			self.m_LifeArmor:setVisible(false)
			self.m_ZoneName:setVisible(false)
			self.m_LabelHUDScale1:setVisible(false);
			self.m_LabelHUDScale2:setVisible(false);
			self.m_LabelHUDScale3:setVisible(false);
			self.m_HUDScale:setVisible(false);
		end
	end
	self.m_UIChange:setIndex(core:get("HUD", "UIStyle", UIStyle.vRoleplay), true)

	self.m_UICheckBox = GUICheckbox:new(self.m_Width*0.5, self.m_Height*0.19, self.m_Width*0.35, self.m_Height*0.04, _"UI aktivieren?", tabSettings)
	self.m_UICheckBox:setFont(VRPFont(25))
	self.m_UICheckBox:setFontSize(1)
	self.m_UICheckBox:setChecked(core:get("HUD", "showUI", true))
	self.m_UICheckBox.onChange = function (state)
		core:set("HUD", "showUI", state)
		HUDUI:getSingleton():setEnabled(state)
	end

	self.m_ChatCheckBox = GUICheckbox:new(self.m_Width*0.5, self.m_Height*0.25, self.m_Width*0.35, self.m_Height*0.04, _"Chat aktivieren?", tabSettings)
	self.m_ChatCheckBox:setFont(VRPFont(25))
	self.m_ChatCheckBox:setFontSize(1)
	self.m_ChatCheckBox:setChecked(isChatVisible())
	self.m_ChatCheckBox.onChange = function (state) showChat(state) end

	self.m_Reddot = GUICheckbox:new(self.m_Width*0.5, self.m_Height*0.31, self.m_Width*0.35, self.m_Height*0.04, _"Rotpunkt aktivieren?", tabSettings)
	self.m_Reddot:setFont(VRPFont(25))
	self.m_Reddot:setFontSize(1)
	self.m_Reddot:setChecked(core:get("HUD", "reddot", false))
	self.m_Reddot.onChange = function (state)
		core:set("HUD", "reddot", state)
		HUDUI:getSingleton():toggleReddot(state)
	end

	self.m_ShortMessageCTC = GUICheckbox:new(self.m_Width*0.5, self.m_Height*0.37, self.m_Width*0.4, self.m_Height*0.04, _"ShortMessage-CTC aktivieren?", tabSettings)
	self.m_ShortMessageCTC:setFont(VRPFont(25))
	self.m_ShortMessageCTC:setFontSize(1)
	self.m_ShortMessageCTC:setChecked(core:get("HUD", "shortMessageCTC", false))
	self.m_ShortMessageCTC.onChange = function (state)
		core:set("HUD", "shortMessageCTC", state)
	end

	self.m_ShortMessageCTCInfo = GUILabel:new(self.m_Width*0.9, self.m_Height*0.37, self.m_Width*0.025, self.m_Height*0.04, "(?)", tabSettings)
	self.m_ShortMessageCTCInfo:setFont(VRPFont(22.5))
	self.m_ShortMessageCTCInfo:setFontSize(1)
	self.m_ShortMessageCTCInfo:setColor(Color.LightBlue)
	self.m_ShortMessageCTCInfo.onHover = function () self.m_ShortMessageCTCInfo:setColor(Color.White) end
	self.m_ShortMessageCTCInfo.onUnhover = function () self.m_ShortMessageCTCInfo:setColor(Color.LightBlue) end
	self.m_ShortMessageCTCInfo.onLeftClick = function ()
		ShortMessage:new(_(HelpTexts.Settings.ShortMessageCTC), _(HelpTextTitles.Settings.ShortMessageCTC), nil, 25000)
	end

	self.m_StartIntro = GUICheckbox:new(self.m_Width*0.5, self.m_Height*0.43, self.m_Width*0.35, self.m_Height*0.04, _"Zeitbildschirm am Login", tabSettings)
	self.m_StartIntro:setFont(VRPFont(25))
	self.m_StartIntro:setFontSize(1)
	self.m_StartIntro:setChecked(core:get("HUD", "startScreen", true))
	self.m_StartIntro.onChange = function (state)
		core:set("HUD", "startScreen", state)
	end

	self.m_LifeArmor = GUICheckbox:new(self.m_Width*0.5, self.m_Height*0.49, self.m_Width*0.35, self.m_Height*0.04, _"Leben/Weste am HUD", tabSettings)
	self.m_LifeArmor:setFont(VRPFont(25))
	self.m_LifeArmor:setFontSize(1)
	self.m_LifeArmor:setChecked(core:get("HUD", "defaultHealthArmor", true))
	if core:get("HUD", "UIStyle") ~= UIStyle.vRoleplay then self.m_LifeArmor:setVisible(false) end
	self.m_LifeArmor.onChange = function (state)
		core:set("HUD", "defaultHealthArmor", state)
		HUDUI:getSingleton():toggleDefaultHealthArmor(state)
	end

	self.m_ZoneName = GUICheckbox:new(self.m_Width*0.5, self.m_Height*0.55, self.m_Width*0.35, self.m_Height*0.04, _"Zone-Name im Radar", tabSettings)
	self.m_ZoneName:setFont(VRPFont(25))
	self.m_ZoneName:setFontSize(1)
	self.m_ZoneName:setChecked(core:get("HUD", "drawZone", true))
	if core:get("HUD", "UIStyle") ~= UIStyle.vRoleplay then self.m_ZoneName:setVisible(false) end
	self.m_ZoneName.onChange = function (state)
		core:set("HUD", "drawZone", state)
	end


	self.m_HUDScale = GUIHorizontalScrollbar:new(self.m_Width*0.5, self.m_Height*0.61, self.m_Width*0.35, self.m_Height*0.04, tabSettings)
	self.m_HUDScale:setScrollPosition( core:get("HUD","scaleScroll",0.75))
	self.m_HUDScale.onScroll = function() local scale = self.m_HUDScale:getScrollPosition(); HUDUI:getSingleton():setScale( scale ); core:set("HUD","scaleScroll",scale*0.75) end
	self.m_LabelHUDScale1 = GUILabel:new(self.m_Width*0.5, self.m_Height*0.61, self.m_Width*0.35, self.m_Height*0.04, _"HUD-Skalierung", tabSettings):setAlignX("center")
	self.m_LabelHUDScale2 = GUILabel:new(self.m_Width*0.5, self.m_Height*0.61, self.m_Width*0.35, self.m_Height*0.04, _"0", tabSettings):setAlignX("left")
	self.m_LabelHUDScale3 = GUILabel:new(self.m_Width*0.5, self.m_Height*0.61, self.m_Width*0.35, self.m_Height*0.04, _"1", tabSettings):setAlignX("right")
	if core:get("HUD", "UIStyle") ~= UIStyle.eXo then self.m_HUDScale:setVisible(false); self.m_LabelHUDScale1:setVisible(false); self.m_LabelHUDScale2:setVisible(false); self.m_LabelHUDScale3:setVisible(false); end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.38, self.m_Width*0.8, self.m_Height*0.07, _"Cursor Modus", tabSettings)
	self.m_RadarChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.45, self.m_Width*0.35, self.m_Height*0.07, tabSettings)
	self.m_RadarChange:addItem("Normal")
	self.m_RadarChange:addItem("Instant")
	self.m_RadarChange.onChange = function(text, index)
		core:set("HUD", "CursorMode", index - 1)
		Cursor:setCursorMode(toboolean(index - 1))
	end
	self.m_RadarChange:setIndex(core:get("HUD", "CursorMode", 0) + 1, true)

	self.m_SkinSpawn = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.55, self.m_Width*0.8, self.m_Height*0.04, _"Mit Fraktionsskin spawnen", tabSettings)
	self.m_SkinSpawn:setFont(VRPFont(25))
	self.m_SkinSpawn:setFontSize(1)
	self.m_SkinSpawn:setChecked(core:get("HUD", "spawnFactionSkin", true))
	self.m_SkinSpawn.onChange = function (bool)
		core:set("HUD", "spawnFactionSkin", bool)
		triggerServerEvent("switchSpawnWithFactionSkin",localPlayer, bool)
	end
	--GUILabel:new(self.m_Width*0.02, self.m_Height*0.55, self.m_Width*0.8, self.m_Height*0.07, _"Werbung (ad)", tabSettings)
	--self.m_AdChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.62, self.m_Width*0.35, self.m_Height*0.07, tabSettings)
	--self.m_AdChange:addItem("als Box unten")
	--self.m_AdChange:addItem("im Chat")
	--self.m_AdChange.onChange = function(text, index)
	--	core:set("Ad", "Chat", index - 1)
	--end

	local tourText = Tour:getSingleton():isActive() and _"Server-Tour beenden" or _"Server-Tour starten"

	self.m_ServerTour = GUIButton:new(self.m_Width*0.6, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.07, tourText, tabSettings):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
	self.m_ServerTour.onLeftClick = function()
		if not Tour:getSingleton():isActive() then
		QuestionBox:new(
			_("Möchtest du eine Servertour starten? Diese bringt dir Erfahrung und eine kleine Belohnungen!"),
			function() triggerServerEvent("tourStart", localPlayer, true) end)
			self:close()
		else
			triggerServerEvent("tourStop", localPlayer)
		end
	end

	self.m_KeyBindingsButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.8, self.m_Width*0.35, self.m_Height*0.07, _"Tastenzuordnungen ändern", tabSettings):setBackgroundColor(Color.Orange):setFontSize(1.2)
	self.m_KeyBindingsButton.onLeftClick = bind(self.KeyBindsButton_Click, self)

	self.m_ShaderButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.8, self.m_Width*0.35, self.m_Height*0.07, _"Shader-Einstellungen", tabSettings):setBackgroundColor(Color.Orange):setFontSize(1.2)
	self.m_ShaderButton.onLeftClick = bind(self.ShaderButton_Click, self)

	--[[ TODO: Do we require this?
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.49, self.m_Width*0.8, self.m_Height*0.07, _"Tipps", tabSettings)
	self.m_EnableTippsBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.57, self.m_Width*0.35, self.m_Height*0.04, _"Tipps aktivieren?", tabSettings)
	self.m_EnableTippsBox:setFont(VRPFont(25))
	self.m_EnableTippsBox:setFontSize(1)
	self.m_EnableTippsBox:setChecked(core:get("Tipps", "enableTipps", true))
	localPlayer.m_showTipps = core:get("Tipps", "enableTipps", true) -- Todo: Find a better position
	self.m_EnableTippsBox.onChange = function (state)
		localPlayer.m_showTipps = state
		core:set("Tipps", "enableTipps", state)

		if not state then
			delete(TippManager:getSingleton())
		else
			if not TippManager:isInstantiated() then
				TippManager:new()
			end
		end
	end

	self.m_TippResetButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.64, self.m_Width*0.35, self.m_Height*0.07, _"Tipps zurücksetzen", tabSettings):setBackgroundColor(Color.Red):setFontSize(1.2)
	self.m_TippResetButton.onLeftClick = function ()
		if localPlayer.m_showTipps then
			self:close()
			QuestionBox:new(_"Wirklich fortfahren?\nDadurch werden alle Tipps erneut angezeigt!", function()
				core:set("Tipps", "lastTipp", 0)
				if not TippManager:isInstantiated() then
					TippManager:new()
				end
				SuccessBox:new(_"Tipps wurden erfolgreich zurückgesetzt!")

				self:open()
			end, function()
				self:open()
			end)
		else
			ErrorBox:new(_"Tipps wurden deaktiviert!")
		end
	end
	--]]


end

function SelfGUI:onShow()
	-- Update VehicleTab
	if localPlayer.m_SelfShader then
		delete(localPlayer.m_SelfShader)
		localPlayer.m_SelfShader = nil
	end
	localPlayer.m_SelfShader =  RadialShader:new()
	self:TabPanel_TabChanged(self.m_TabGeneral.TabIndex)
	self:TabPanel_TabChanged(self.m_TabVehicles.TabIndex)

	-- Initialize all the stuff
	if localPlayer:getJobLevel() >= MAX_JOB_LEVEL then
		self.m_JobLevelButton:setText("Max. Level"):setEnabled(false)
	else
		self.m_JobLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())))
	end
	if localPlayer:getSkinLevel() >= MAX_SKIN_LEVEL then
		self.m_SkinLevelButton:setText("Max. Level"):setEnabled(false)
	else
		self.m_SkinLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())))
	end
	if localPlayer:getVehicleLevel() >= MAX_VEHICLE_LEVEL then
		self.m_VehicleLevelButton:setText("Max. Level"):setEnabled(false)
	else
		self.m_VehicleLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())))
	end

	local hours, minutes = math.floor(localPlayer:getPlayTime()/60), (localPlayer:getPlayTime() - math.floor(localPlayer:getPlayTime()/60)*60)
	self.m_PlayTimeLabel:setText(_("%s Stunde(n) %s Minute(n)", hours, minutes))
	self.m_AFKTimeLabel:setText(_("%s Minute(n)", math.floor((localPlayer.m_AFKTime + localPlayer.m_CurrentAFKTime)/60/1000)))

	self.m_ServerTour:setText(Tour:getSingleton():isActive() and _"Server-Tour beenden" or _"Server-Tour starten")

	local x, y = self.m_JobNameLabel:getPosition()
	if localPlayer:getJob() then
		self.m_JobNameLabel:setText(localPlayer:getJob():getName())
		self.m_JobQuitButton:setPosition(x + dxGetTextWidth(self.m_JobNameLabel:getText(), self.m_JobQuitButton:getFontSize(), self.m_JobQuitButton:getFont()) + 10, y)
		self.m_JobQuitButton:setVisible(true)
	else
		self.m_JobNameLabel:setText("-")
		self.m_JobQuitButton:setPosition(x + dxGetTextWidth(self.m_JobNameLabel:getText(), self.m_JobQuitButton:getFontSize(), self.m_JobQuitButton:getFont()) + 10, y)
		self.m_JobQuitButton:setVisible(false)
	end
	if localPlayer:getKarma() then
		local karma = localPlayer:getKarma()
		self.m_GeneralKarmaLabel:setText(tostring(karma > 0 and "+"..karma or karma))
	end
end

function SelfGUI:onHide()
	if localPlayer.m_SelfShader then
		delete(localPlayer.m_SelfShader)
		localPlayer.m_SelfShader = nil
	end
end

function SelfGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabGeneral.TabIndex then
		triggerServerEvent("companyRequestInfo", root)
		triggerServerEvent("factionRequestInfo", root)
		triggerServerEvent("groupRequestInfo", root)
	elseif tabId == self.m_TabVehicles.TabIndex then
		triggerServerEvent("vehicleRequestInfo", root)
	end
end

function SelfGUI:adjustGeneralTab(name)
	local isInCompany = name ~= nil
	self.m_CompanyEditLabel:setVisible(isInCompany)
end

function SelfGUI:Event_companyRetrieveInfo(id, name)
	self:adjustGeneralTab(name)

	if name then
		self.m_CompanyNameLabel:setText(name)
		local x, y = self.m_CompanyNameLabel:getPosition()
		self.m_CompanyEditLabel:setPosition(x + dxGetTextWidth(name, self.m_CompanyNameLabel:getFontSize(), self.m_CompanyNameLabel:getFont()) + 10, y)
	else
		self.m_CompanyNameLabel:setText("-")
	end
end

function SelfGUI:JobQuitButton_Click()
	triggerServerEvent("jobQuit", root)
	self.m_JobNameLabel:setText("-")
	self.m_JobQuitButton:setVisible(false)
	localPlayer:giveAchievement(26)
end

function SelfGUI:CompanyMenuButton_Click()
	self:close()
	CompanyGUI:getSingleton():open()
end

function SelfGUI:GroupMenuButton_Click()
	self:close()
	GroupGUI:getSingleton():open()
end

function SelfGUI:FactionMenuButton_Click()
	self:close()
	FactionGUI:getSingleton():open()
end

function SelfGUI:TicketButton_Click()
	self:close()
	TicketGUI:getSingleton():open()
end

function SelfGUI:AdminButton_Click()
	self:close()
	triggerServerEvent("openAdminGUI", localPlayer)
end

function SelfGUI:MigratorButton_Click()
	self:close()
	MigratorPanel:getSingleton():open()
end

function SelfGUI:AdButton_Click()
	self:close()
	AdvertisementBox:getSingleton():open()
end


function SelfGUI:KeyBindsButton_Click()
	self:close()
	KeyBindings:getSingleton():open()
end

function SelfGUI:ShaderButton_Click()
	self:close()
	ShaderPanel:getSingleton():open()
end

function SelfGUI:Event_factionRetrieveInfo(id, name, rank)
	if rank then
		self.m_FactionNameLabel:setText(_("%s - Rang: %d", name, rank))
		self.m_FactionInvationLabel:setVisible(false)
		self.m_FactionMenuButton:setVisible(true)
		self.m_InvationFactionId = 0

		if rank >= 5 then
			self.m_FactionMenuButton:setText(_"(verwalten)")
		else
			self.m_FactionMenuButton:setText(_"(anzeigen)")
		end
		local x, y = self.m_FactionNameLabel:getPosition()
		self.m_FactionMenuButton:setPosition(x + dxGetTextWidth(_("%s - Rang: %d", name, rank), self.m_FactionNameLabel:getFontSize(), self.m_FactionNameLabel:getFont()) + 10, y)
	else
		self.m_FactionNameLabel:setText(_"- keine Fraktion -")
		self.m_FactionInvationLabel:setVisible(true)
		self.m_FactionMenuButton:setVisible(false)

		if self.m_InvationFactionId and self.m_InvationFactionId > 0 then
			self.m_FactionInvationLabel:setVisible(true)
			self.m_FactionInvitationsAcceptButton:setVisible(true)
			self.m_FactionInvitationsDeclineButton:setVisible(true)
		end
	end
end

function SelfGUI:Event_factionInvitationRetrieve(factionId, name)
	if factionId > 0 then
		ShortMessage:new(_("Du wurdest in die Fraktion '%s' eingeladen. Öffne das Spielermenü, um die Einladung anzunehmen", name))
		self.m_FactionInvationLabel:setVisible(true)
		self.m_FactionInvitationsAcceptButton:setVisible(true)
		self.m_FactionInvitationsDeclineButton:setVisible(true)
		self.m_FactionInvationLabel:setText("Du wurdest in die Fraktion \""..name.."\" eingeladen!")
		self.m_InvationFactionId = factionId
	end
end


function SelfGUI:Event_groupInvitationRetrieve(groupId, name)
	ShortMessage:new(_("Du wurdest in die Firma/Gang '%s' eingeladen. Öffne das Spielermenü, um die Einladung anzunehmen", name))
	self.m_GroupInvitationsLabel:setText("Du hast eine Einladungen für eine private Firma/Gang erhalten, öffne das Menü um diese anzunehmen!")
	self.m_GroupInvitationsLabel:setVisible(true)
	self.m_HasGroupInvation = true
end

function SelfGUI:Event_groupRetrieveInfo(name, rank, __, __, __, __, rankNames)
	local x, y = self.m_GroupNameLabel:getPosition()
	if rank and rank > 0 then
		self.m_GroupNameLabel:setText(_("%s - Rang: %s", name, rankNames[tostring(rank)]))
		self.m_GroupMenuButton:setVisible(true)
		self.m_GroupInvitationsLabel:setVisible(false)
		self.m_HasGroupInvation = false
		self.m_GroupMenuButton:setPosition(x + dxGetTextWidth(_("%s - Rang: %s", name, rankNames[tostring(rank)]), self.m_GroupNameLabel:getFontSize(), self.m_GroupNameLabel:getFont()) + 10, y)
	else
		self.m_GroupNameLabel:setText(_"- keine Firma/Gang -")
		self.m_GroupMenuButton:setPosition(x + dxGetTextWidth(_("- keine Firma/Gang -"), self.m_GroupNameLabel:getFontSize(), self.m_GroupNameLabel:getFont()) + 10, y)
		self.m_GroupInvitationsLabel:setVisible(true)

		if self.m_HasGroupInvation then
			self.m_GroupInvitationsLabel:setVisible(true)
		end
	end
end

function SelfGUI:FactionInvitationsAcceptButton_Click()
	if self.m_InvationFactionId then
		triggerServerEvent("factionInvitationAccept", resourceRoot, self.m_InvationFactionId)
		self.m_FactionInvationLabel:setVisible(false)
		self.m_FactionInvitationsAcceptButton:setVisible(false)
		self.m_FactionInvitationsDeclineButton:setVisible(false)
		self.m_FactionInvationLabel:setText("")
		self.m_InvationFactionId = 0
	end
end

function SelfGUI:FactionInvitationsDeclineButton_Click()
	if self.m_InvationFactionId then
		triggerServerEvent("factionInvitationDecline", resourceRoot, self.m_InvationFactionId)
		self.m_FactionInvationLabel:setVisible(false)
		self.m_FactionInvitationsAcceptButton:setVisible(false)
		self.m_FactionInvitationsDeclineButton:setVisible(false)
		self.m_FactionInvationLabel:setText("")
		self.m_InvationFactionId = 0
	end
end



function SelfGUI:Event_vehicleRetrieveInfo(vehiclesInfo, garageType, hangarType)
	if vehiclesInfo then
		self.m_VehiclesGrid:clear()
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
			local item = self.m_VehiclesGrid:addItem(element:getName(), positionType)
			item.VehicleId = vehicleId
			item.VehicleElement = element
			item.PositionType = vehicleInfo[2]
		end
	end

	if garageType then
		localPlayer.m_GarageType = garageType
		self.m_VehicleGarages:setText(_(GARAGE_UPGRADES_TEXTS[garageType]))

		local price = GARAGE_UPGRADES_COSTS[garageType + 1] or "-"
		if localPlayer.m_GarageType == 0 then
			self.m_VehicleGarageUpgradeButton:setText(_("(Kaufen: %s$)", price))
		else
			self.m_VehicleGarageUpgradeButton:setText(_("(Upgrade: %s$)", price))
		end
		self.m_VehicleGarageUpgradeButton:setPosition(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleGarages:getText(), self.m_VehicleGarages:getFontSize(), self.m_VehicleGarages:getFont()) + 5, self.m_Height*0.75)
		self.m_VehicleGarageUpgradeButton:setSize(dxGetTextWidth(self.m_VehicleGarageUpgradeButton:getText(), self.m_VehicleGarageUpgradeButton:getFontSize(), self.m_VehicleGarageUpgradeButton:getFont()), self.m_Height*0.06)
	end

	if hangarType then
		localPlayer.m_HangarType = hangarType
		self.m_VehicleHangar:setText(_(HANGAR_UPGRADES_TEXTS[hangarType]))

		local price = HANGAR_UPGRADES_COSTS[hangarType + 1] or "-"
		if localPlayer.m_HangarType == 0 then
			self.m_VehicleHangarButton:setText(_("(Kaufen: %s$)", price))
		else
			self.m_VehicleHangarButton:setText(_("(Upgrade: %s$)", price))
		end
		self.m_VehicleHangarButton:setPosition(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleHangar:getText(), self.m_VehicleHangar:getFontSize(), self.m_VehicleHangar:getFont()) + 5, self.m_Height*0.81)
		self.m_VehicleHangarButton:setSize(dxGetTextWidth(self.m_VehicleHangarButton:getText(), self.m_VehicleHangarButton:getFontSize(), self.m_VehicleHangarButton:getFont()), self.m_Height*0.06)
	end
end

function SelfGUI:VehicleGarageUpgradeButton_Click()
	triggerServerEvent("vehicleUpgradeGarage", root)
end

function SelfGUI:VehicleHangarButton_Click()
	if localPlayer:getRank() >= RANK.Developer then
		triggerServerEvent("vehicleUpgradeHangar", root)
	else
		outputChatBox("Not implemented!", 255, 0, 0)
	end
end

function SelfGUI:VehicleLocateButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	if item.PositionType == VehiclePositionType.World then
		local x, y, z = getElementPosition(item.VehicleElement)
		local blip = Blip:new("Waypoint.png", x, y,9999)
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
	elseif item.PositionType == VehiclePositionType.Garage then
 		ShortMessage:new(_"Dieses Fahrzeug befindet sich in deiner Garage!", "Fahrzeug-Ortung", Color.DarkLightBlue)
	elseif item.PositionType == VehiclePositionType.Mechanic then
		ShortMessage:new(_"Dieses Fahrzeug befindet sich im Autohof (Mechanic Base)!", "Fahrzeug-Ortung", Color.DarkLightBlue)
	elseif item.PositionType == VehiclePositionType.Hangar then
		ShortMessage:new(_"Dieses Flugzeug befindet sich im Hangar!", "Fahrzeug-Ortung", Color.DarkLightBlue)
	elseif item.PositionType == VehiclePositionType.Harbor then
		ShortMessage:new(_"Dieses Boot befindet sich im Industrie-Hafen (Logistik-Job)!", "Fahrzeug-Ortung", Color.DarkLightBlue)
	else
		ErrorBox:new(_"Es ist ein interner Fehler aufgetreten!")
	end
end

function SelfGUI:VehicleWorldRespawnButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	triggerServerEvent("vehicleRespawnWorld", item.VehicleElement)
end

function SelfGUI:VehicleRespawnButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	triggerServerEvent("vehicleRespawn", item.VehicleElement, true)
end

function SelfGUI:VehicleSellButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	triggerServerEvent("vehicleSell", item.VehicleElement)
end
