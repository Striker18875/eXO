-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery/BankLosSantos.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************

--Info 68 Tresors

BankLosSantos = inherit(BankRobbery)

function BankLosSantos:constructor()
	self.ms_FinishMarker = {
		Vector3(2766.84, 84.98, 18.39),
		Vector3(2561.50, -949.89, 81.77),
		Vector3(1935.24, 169.98, 36.28)
	}

	self.ms_BagSpawns = {
		Vector3(1429.65, -1003.55, 12.6),
		Vector3(1431.38, -1004.01, 12.6),
		Vector3(1432.82, -1004.07, 12.6),
		Vector3(1434.40, -1004.14, 12.6),
		Vector3(1435.68, -1004.20, 12.6),
		Vector3(1429.99, -998.54, 12.6),
		Vector3(1431.28, -998.14, 12.6),
		Vector3(1432.88, -998.29, 12.6),
		Vector3(1434.48, -998.44, 12.6),
		Vector3(1436.47, -998.62, 12.6),
		Vector3(1436.05, -1000.54, 12.6),
		Vector3(1434.45, -1000.62, 12.6),
		Vector3(1432.84, -1000.57, 12.6),
		Vector3(1431.92, -1000.53, 12.6),
		Vector3(1430.49, -1000.48, 12.6),
		Vector3(1429.35, -1000.44, 12.6),
		Vector3(1430.40, -998.86, 12.6),
		Vector3(1434.37, -1000.35, 12.6),
	}

	self:build()
end

function BankLosSantos:destructor()

end

function BankLosSantos:destroyRob()
end

function BankLosSantos:build()
	self.m_HackableComputer = createObject(2181, 1486.30, -980, 12.30, 0, 0, 270)
	self.m_HackableComputer:setAlpha(0)
	self.m_HackableComputer:setData("clickable", true, true)
	self.m_HackableComputer:setData("bankPC", true, true)

	self.m_SafeDoor = createObject(1930, 1438.4004, -999, 12.2, 0, 0, 0)
	self.m_SafeDoor.m_Open = false
	self.m_BankDoor = createObject(5020, 1455.10, -967.40, 13.80, 0, 0, 90)

	self.m_SecurityRoomShape = createColCuboid(2305.5, 5.3, 25.5, 11.5, 17, 4)
	self.m_Timer = false
	self.m_ColShape = createColSphere(self.m_BankDoor:getPosition(), 60)
	self.m_OnSafeClickFunction = bind(self.Event_onSafeClicked, self)
	self.m_Event_onBagClickFunc = bind(self.Event_onBagClick, self)

	self:spawnPed(295, Vector3(1464.64, -991.05, 26.83), 197.5)
	self:spawnGuards()
	self:createSafes()

	self.m_HelpColShape = createColSphere(2301.44, -15.98, 26.48, 5)
	self.m_HelpColFunc = bind(self.onHelpColHit, self)
	addEventHandler("onColShapeHit", self.m_HelpColShape, self.m_HelpColFunc)
	addEventHandler("onColShapeLeave", self.m_HelpColShape, self.m_HelpColFunc)

	addEventHandler("onColShapeHit", self.m_SecurityRoomShape, function(hitElement, dim)
		if hitElement:getType() == "player" and dim then
			hitElement:triggerEvent("clickSpamSetEnabled", false)
		end
	end)

	addEventHandler("onColShapeLeave", self.m_SecurityRoomShape, function(hitElement, dim)
		if hitElement:getType() == "player" and dim then
			hitElement:triggerEvent("clickSpamSetEnabled", true)
		end
	end)
end

function BankLosSantos:startRob(player)
	BankManager:getSingleton():startRob(self)

	ActionsCheck:getSingleton():setAction("Banküberfall")
	PlayerManager:getSingleton():breakingNews("Eine derzeit unbekannte Fraktion überfällt die Los Santos Bank!")

	local faction = player:getFaction()
	local pos = self.m_BankDoor:getPosition()
	self.m_BankDoor:move(3000, pos.x-5, pos.y, pos.z)
	self.m_RobPlayer = player
	self.m_RobFaction = faction
	self.m_IsBankrobRunning = true
	self.m_RobFaction:giveKarmaToOnlineMembers(-5, "Banküberfall gestartet!")

	StatisticsLogger:getSingleton():addActionLog("BankRobbery", "start", self.m_RobPlayer, self.m_RobFaction, "faction")

	triggerClientEvent("bankAlarm", root, 1457.67, -996.27, 26.83)
	self.m_Truck = TemporaryVehicle.create(428, 1413.79, -994.04, 31.62, 0, 0, 180)
	self.m_Truck:setData("BankRobberyTruck", true, true)
    self.m_Truck:setColor(0, 0, 0)
    self.m_Truck:setLocked(false)
	self.m_Truck:setEngineState(true)
	self.m_Truck:toggleRespawn(false)

	self.m_HackMarker = createMarker( 1486.43, -979.75, 15, "arrow", 0.8, 255, 255, 0)

	for markerIndex, destination in pairs(self.ms_FinishMarker) do
		self.m_Blip[markerIndex] = Blip:new("Waypoint.png", destination.x, destination.y, playeritem)
		self.m_DestinationMarker[markerIndex] = createMarker(destination, "cylinder", 8)
		addEventHandler("onMarkerHit", self.m_DestinationMarker[markerIndex], bind(self.Event_onDestinationMarkerHit, self))
	end
end

function BankLosSantos:openSafeDoor()
	local pos = self.m_SafeDoor:getPosition()
	self.m_SafeDoor:move(3000, pos, 0, 0, 140)
	self.m_SafeDoor.m_Open = true
end

function BankLosSantos:spawnGuards()
	self.m_GuardPed1 = GuardActor:new(Vector3(2315.25, 20.34, 26.53))
	self.m_GuardPed1:setRotation(270, 0, 270, "default", true)
	self.m_GuardPed1:setFrozen(true)
	self.m_GuardPed1.Colshape = createColCuboid(2314.4 ,1.15 ,25 ,2.5 ,21.45 , 4)
	addEventHandler("onColShapeHit", self.m_GuardPed1.Colshape, function(hitElement, dim)
		if dim and hitElement.type == "player" then
			if hitElement:getFaction() and hitElement:getFaction():isEvilFaction() then
				self.m_GuardPed1:startShooting(hitElement)
			end
		end

	end)
end

function BankLosSantos:createSafes()
	self.m_Safes = {
		createObject(2332, 1437.3, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1437.3, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1437.3, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1436.4, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1435.5, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1434.6, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1433.7, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1432.8, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1431.9, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1431.0, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1430.1, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1429.2, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1428.3, -996.20, 12.7, 0, 0, 0),
		createObject(2332, 1436.4, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1436.4, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1435.5, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1434.6, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1433.7, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1432.8, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1431.9, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1431.0, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1430.1, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1429.2, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1428.3, -996.20, 13.6, 0, 0, 0),
		createObject(2332, 1435.5, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1434.6, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1433.7, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1432.8, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1431.9, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1431.0, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1430.1, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1429.2, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1428.3, -996.20, 14.5, 0, 0, 0),
		createObject(2332, 1437.3, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1436.4, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1435.5, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1434.6, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1433.7, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1432.8, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1431.9, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1431.0, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1430.1, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1429.2, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1428.3, -1006, 12.7, 0, 0, 180),
		createObject(2332, 1437.3, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1436.4, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1435.5, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1434.6, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1433.7, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1432.8, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1431.9, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1431.0, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1430.1, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1429.2, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1428.3, -1006, 13.6, 0, 0, 180),
		createObject(2332, 1428.3, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1429.2, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1430.1, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1431.0, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1431.9, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1432.8, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1433.7, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1434.6, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1435.5, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1436.4, -1006, 14.5, 0, 0, 180),
		createObject(2332, 1437.3, -1006, 14.5, 0, 0, 180)
	}
	for index, safe in pairs(self.m_Safes) do
		safe:setData("clickable", true, true)
		addEventHandler("onElementClicked", safe, self.m_OnSafeClickFunction)
	end
end
