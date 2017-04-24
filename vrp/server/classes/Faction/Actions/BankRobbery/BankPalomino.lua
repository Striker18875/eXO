-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************

--Info 68 Tresors

BankPalomino = inherit(BankRobbery)
BankPalomino.Map = {}

local BOMB_TIME = 20*1000

function BankPalomino:constructor()
	self.m_PedPosition = {Vector3(2310.28, -10.87, 26.74), 180}

	self.ms_FinishMarker = {
		Vector3(2766.84, 84.98, 18.39),
		Vector3(2561.50, -949.89, 81.77),
		Vector3(1935.24, 169.98, 36.28)
	}

	self.ms_BagSpawns = {
		Vector3(2307.25, 17.90, 26),
		Vector3(2306.88, 19.09, 26),
		Vector3(2306.97, 20.38, 26),
		Vector3(2308.34, 20.20, 26),
		Vector3(2308.46, 19.16, 26),
		Vector3(2308.46, 17.92, 26),
		Vector3(2309.82, 17.77, 26),
		Vector3(2310.09, 18.91, 26),
		Vector3(2310.11, 20.13, 26),
		Vector3(2311.48, 20.26, 26),
		Vector3(2311.57, 18.95, 26),
		Vector3(2311.55, 17.89, 26),
		Vector3(2312.69, 17.80, 26),
		Vector3(2312.73, 19.90, 26),
		Vector3(2313.57, 20.89, 26),
		Vector3(2313.59, 17.27, 26),
		Vector3(2312.19, 18.31, 26),
		Vector3(2309.27, 19.14, 26),
	}

	self:build()
end

function BankPalomino:destroyRob()
	local tooLatePlayers = getElementsWithinColShape(self.m_SecurityRoomShape, "player")
	if tooLatePlayers then
		for key, player in pairs( tooLatePlayers) do
			killPed(player)
			player:sendInfo("Du bist im abgeschlossenen Raum verendet!")
		end
	end
	triggerClientEvent("bankAlarmStop", root)
	if self.m_DestinationMarker then
		for index, marker in pairs(self.m_DestinationMarker) do
			if isElement(marker) then destroyElement(marker) end
		end
	end
	if self.m_Safes then
		for index, safe in pairs(self.m_Safes) do if isElement(safe) then destroyElement(safe) end	end
	end
	if self.m_BombableBricks then
		for index, brick in pairs(self.m_BombableBricks) do	if isElement(brick) then destroyElement(brick) end end
	end
	if self.m_MoneyBags then
		for index, bag in pairs(self.m_MoneyBags) do	if isElement(bag) then destroyElement(bag) end end
	end

	if self.m_Blip then
		for index, blip in pairs(self.m_Blip) do delete(blip) end
	end
	if isElement(self.m_BankDoor) then destroyElement(self.m_BankDoor) end
	if isElement(self.m_SafeDoor) then destroyElement(self.m_SafeDoor) end
	if isElement(self.m_ColShape) then destroyElement(self.m_ColShape) end
	if isElement(self.m_Ped) then destroyElement(self.m_Ped) end
	if isElement(self.m_Truck) then destroyElement(self.m_Truck) end
	if isElement(self.m_BackDoor) then destroyElement(self.m_BackDoor) end
	if isElement(self.m_HackMarker) then destroyElement(self.m_HackMarker) end
	if isElement(self.m_SecurityRoomShape) then destroyElement( self.m_SecurityRoomShape) end
	self.m_HackableComputer:setData("clickable", false, true)
	self.m_HackableComputer:setData("bankPC", false, true)
	if isElement(self.m_HackableComputer) then destroyElement(self.m_HackableComputer) end
	if self.m_GuardPed1 then destroyElement( self.m_GuardPed1 ) end

	killTimer(self.m_Timer)
	killTimer(self.m_UpdateBreakingNewsTimer)

	local onlinePlayers = self.m_RobFaction:getOnlinePlayers()
	if onlinePlayers then
		for index, playeritem in pairs(self.m_RobFaction:getOnlinePlayers()) do
			playeritem:triggerEvent("CountdownStop", "Bank-Überfall")
			playeritem:triggerEvent("forceCircuitBreakerClose")
		end
	end
	if self.m_CircuitBreakerPlayers then
		for player, bool in pairs(self.m_CircuitBreakerPlayers) do
			if isElement(player) then
				player:triggerEvent("forceCircuitBreakerClose")
				self.m_CircuitBreakerPlayers[player] = nil
				player.m_InCircuitBreak = false
			end
		end
	end

	removeEventHandler("onColShapeHit", self.m_HelpColShape, self.m_ColFunc)
	removeEventHandler("onColShapeLeave", self.m_HelpColShape, self.m_HelpCol)

	ActionsCheck:getSingleton():endAction()
	StatisticsLogger:getSingleton():addActionLog("BankRobbery", "stop", self.m_RobPlayer, self.m_RobFaction, "faction")
	self:build()
end

function BankPalomino:build()
	self.m_Blip = {}
	self.m_DestinationMarker = {}
	self.m_MoneyBags = {}

	self.m_HackableComputer = createObject(2181, 2313.3999, 11.9, 25.5, 0, 0, 270)
	self.m_HackableComputer:setData("clickable", true, true)
	self.m_HackableComputer:setData("bankPC", true, true)

	self.m_SafeDoor = createObject(2634, 2314.1, 18.94, 26.7, 0, 0, 270)
	self.m_SafeDoor.m_Open = false
	self.m_BankDoor = createObject(1495, 2314.885, 0.70, 25.70)
	self.m_BankDoor:setScale(0.88)

	self.m_BackDoor = createObject(1492, 2316.95, 22.90, 25.5, 0, 0, 180)
	self.m_BackDoor:setFrozen(true)

	self.m_BombAreaPosition = Vector3(2318.43, 11.37, 26.48)
	self.m_BombAreaTarget = createObject(3108, 2317.8, 11.3, 26.8, 0, 90, 0):setScale(0.2)
	self.m_BombArea = BombArea:new(self.m_BombAreaPosition, bind(self.BombArea_Place, self), bind(self.BombArea_Explode, self), BOMB_TIME)
	self.m_BombColShape = createColSphere(self.m_BombAreaPosition, 10)
	self.m_SecurityRoomShape = createColCuboid(2305.5, 5.3, 25.5, 11.5, 17, 4)
	self.m_Timer = false
	self.m_ColShape = createColSphere(self.m_BombAreaPosition, 60)
	self.m_OnSafeClickFunction = bind(self.Event_onSafeClicked, self)
	self.m_Event_onBagClickFunc = bind(self.Event_onBagClick, self)

	self.m_CircuitBreakerPlayers = {}

	self:spawnPed(295, Vector3(2310.28, -10.87, 26.74), 180)
	self:spawnGuards()
	self:createSafes()
	self:createBombableBricks()

	self.m_HelpColShape = createColSphere(2301.44, -15.98, 26.48, 5)
	self.m_ColFunc = bind(self.onHelpColHit, self)
	self.m_HelpCol = bind(self.onHelpColHit, self)

	addEventHandler("onColShapeHit", self.m_HelpColShape, self.m_ColFunc)
	addEventHandler("onColShapeLeave", self.m_HelpColShape, self.m_HelpCol)

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

function BankPalomino:startRob(player)
	BankManager:getSingleton():startRob("Palomino")

	ActionsCheck:getSingleton():setAction("Banküberfall")
	PlayerManager:getSingleton():breakingNews("Eine derzeit unbekannte Fraktion überfällt die Palomino-Creek Bank!")

	local faction = player:getFaction()
	local pos = self.m_BankDoor:getPosition()
	self.m_BankDoor:move(3000, pos.x+1.1, pos.y, pos.z)
	self.m_RobPlayer = player
	self.m_RobFaction = faction
	self.m_IsBankrobRunning = true
	self.m_BackDoor:setFrozen(false)
	self.m_RobFaction:giveKarmaToOnlineMembers(-5, "Banküberfall gestartet!")

	StatisticsLogger:getSingleton():addActionLog("BankRobbery", "start", self.m_RobPlayer, self.m_RobFaction, "faction")

	triggerClientEvent("bankAlarm", root, 2318.43, 11.37, 26.48)
	self.m_Truck = TemporaryVehicle.create(428, 2337.54, 16.67, 26.61, 0)
	self.m_Truck:setData("BankRobberyTruck", true, true)
    self.m_Truck:setColor(0, 0, 0)
    self.m_Truck:setLocked(false)
	self.m_Truck:setEngineState(true)
	self.m_Truck:toggleRespawn(false)

	self.m_HackMarker = createMarker(2313.4, 11.61, 28.5, "arrow", 0.8, 255, 255, 0)

	for markerIndex, destination in pairs(self.ms_FinishMarker) do
		self.m_Blip[markerIndex] = Blip:new("Waypoint.png", destination.x, destination.y, playeritem)
		self.m_DestinationMarker[markerIndex] = createMarker(destination, "cylinder", 8)
		addEventHandler("onMarkerHit", self.m_DestinationMarker[markerIndex], bind(self.Event_onDestinationMarkerHit, self))
	end
end

function BankPalomino:spawnGuards()
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

function BankPalomino:openSafeDoor()
	local pos = self.m_SafeDoor:getPosition()
	self.m_SafeDoor:move(3000, pos.x, pos.y+1.5, pos.z, 0, 0, 0)
	self.m_SafeDoor.m_Open = true
end

function BankPalomino:createSafes()
	self.m_Safes = {
		createObject(2332, 2305.5, 19.12012, 26.85, 0, 0, 90),
		createObject(2332, 2305.5, 18.29004, 26.85, 0, 0, 90),
		createObject(2332, 2305.5, 17.45898, 26.85, 0, 0, 90),
		createObject(2332, 2312.83984, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2312.0127, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2311.1836, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2310.3525, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2309.5215, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2308.6904, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2307.8604, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2307.0313, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2306.2002, 21.5, 27.7085, 0, 0, 0),
		createObject(2332, 2305.5, 20.78027, 27.7085, 0, 0, 90),
		createObject(2332, 2305.5, 19.94922, 27.7085, 0, 0, 90),
		createObject(2332, 2305.5, 19.12012, 27.7085, 0, 0, 90),
		createObject(2332, 2305.5, 18.29004, 27.7085, 0, 0, 90),
		createObject(2332, 2305.5, 17.45898, 27.7085, 0, 0, 90),
		createObject(2332, 2310.3711, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2306.2002, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2309.5215, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2308.6904, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2307.8604, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2307.0313, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2306.2002, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2312.8398, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2312.0127, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2311.1836, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2307.0313, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2307.8604, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2308.6904, 16.73047, 26, 0, 0, 180),
		createObject(2332, 2309.5215, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2310.3525, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2311.1836, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2312.0127, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2312.8398, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2306.2002, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2307.0313, 16.73047, 26.85, 0, 0, 180),
		createObject(2332, 2307.8604, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2308.6904, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2309.5215, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2310.3525, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2311.1836, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2312.0127, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2312.8398, 16.73047, 27.7085, 0, 0, 180),
		createObject(2332, 2310.3525, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2311.1836, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2312.0127, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2312.8398, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2305.5, 20.78027, 26.85, 0, 0, 90),
		createObject(2332, 2306.2002, 21.5, 26, 0, 0, 0),
		createObject(2332, 2305.5, 20.78, 26, 0, 0, 90),
		createObject(2332, 2305.5, 19.94922, 26, 0, 0, 90),
		createObject(2332, 2305.5, 19.12, 26, 0, 0, 90),
		createObject(2332, 2305.5, 18.29004, 26, 0, 0, 90),
		createObject(2332, 2305.5, 17.45897, 26, 0, 0, 90),
		createObject(2332, 2305.5, 19.95, 26.85, 0, 0, 90),
		createObject(2332, 2307.0313, 21.5, 26, 0, 0, 0),
		createObject(2332, 2307.8601, 21.5, 26, 0, 0, 0),
		createObject(2332, 2308.6899, 21.5, 26, 0, 0, 0),
		createObject(2332, 2309.521, 21.5, 26, 0, 0, 0),
		createObject(2332, 2310.3525, 21.5, 26, 0, 0, 0),
		createObject(2332, 2311.1836, 21.5, 26, 0, 0, 0),
		createObject(2332, 2312.0127, 21.5, 26, 0, 0, 0),
		createObject(2332, 2312.8398, 21.5, 26, 0, 0, 0),
		createObject(2332, 2306.2002, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2307.0313, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2307.8604, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2308.6904, 21.5, 26.85, 0, 0, 0),
		createObject(2332, 2309.52, 21.5, 26.85, 0, 0, 0),
	}
	for index, safe in pairs(self.m_Safes) do
		safe:setData("clickable", true, true)
		addEventHandler( "onElementClicked", safe, self.m_OnSafeClickFunction)
	end
end

function BankPalomino:createBombableBricks()
	self.m_BombableBricks = {
		createObject(9131, 2317.334, 10.25, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 10.25, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 11, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 11, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 11.75, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 11.75, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 12.5, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 12.5, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 13.25, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 13.25, 28.87, 0, 0, 270),
		createObject(9131, 2317.334, 14, 26.6, 0, 0, 270),
		createObject(9131, 2317.334, 9.5, 26.6, 0, 0, 270),
	}
end

function BankPalomino:BombArea_Place(bombArea, player)
	if not player:getFaction() then
		player:sendError(_("Banken kannst du nur ausrauben wenn du Mitglied einer bösen Fraktion bist", player))
		return false
	end

	if not ActionsCheck:getSingleton():isActionAllowed(player) then	return false end

	if not DEBUG and FactionState:getSingleton():countPlayers() < 5 then
		player:sendError(_("Um den Überfall starten zu können müssen mindestens 5 Staats-Fraktionisten online sein!", player))
		return false
	end

	for k, player in pairs(getElementsWithinColShape(self.m_BombColShape, "player")) do
		player:triggerEvent("Countdown", BOMB_TIME/1000, "Bombe zündet")

		local faction = player:getFaction()
		if faction and faction:isEvilFaction() then
			player:reportCrime(Crime.BankRobbery)

		end
	end
	return true
end

function BankPalomino:BombArea_Explode(bombArea, player)
	self:startRob(player)
	for index, brick in pairs(self.m_BombableBricks) do
		brick:destroy()
	end
end
