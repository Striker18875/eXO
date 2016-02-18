-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankRobbery.lua
-- *  PURPOSE:     Bank robbery class
-- *
-- ****************************************************************************
BankRobbery = inherit(Object)
BankRobbery.Map = {}
BankRobbery.FinishMarker = {Vector3(2766.84, 84.98, 19.39), Vector3(2561.50, -949.89, 82.77), Vector3(1935.24, 169.98, 37.28)}
local HOLD_TIME = 30*1000 --4*60*1000
local MONEY_PER_SAFE_MIN = 100
local MONEY_PER_SAFE_MAX = 200
local MAX_MONEY_PER_BAG = 2000

function BankRobbery:constructor()
	self.m_SafeDoor = createObject(2634, 2314.1, 18.94, 26.7, 0, 0, 270)
	self.m_BombAreaPosition = Vector3(2318.43, 11.37, 26.48)
	self.m_BombAreaTarget = createObject(3108, 2317.8, 11.3, 26.8, 0, 90, 0):setScale(0.2)
	self.m_HackableComputer = createObject(2181, 2313.3999, 11.9, 25.5, 0, 0, 270)
	self.m_BankDoor = createObject(1495, 2314.885, 0.70, 25.70)
	self.m_BankDoor:setScale(0.88)
	addEventHandler( "onElementClicked", self.m_HackableComputer, bind(self.Event_onComputerClicked,self))

	self.m_Blip = {}
	self.m_DestinationMarker = {}

	self.m_MoneyBags = {}

	self.m_RobFaction = nil

	self.m_Ped = ShopNPC:new(295, 2310.28, -10.87, 26.74, 180)
	self.m_Ped.onTargetted = bind(self.Ped_Targetted, self)

	self:spawnGuards()

	table.insert(BankRobbery.Map, self)

	self.m_LastRobbery = 0
	self.m_Timer = false
	self.m_BombArea = BombArea:new(self.m_BombAreaPosition, bind(self.BombArea_Place, self), bind(self.BombArea_Explode, self), HOLD_TIME)
	self.m_ColShape = createColSphere(self.m_BombAreaPosition, 30)

	--1829 Offen mit Geld -- DEV NOTICE
	--2004 Offen ohne Geld -- DEV NOTICE
	self.m_OnSafeClickFunction = bind(self.Event_onSafeClicked,self)
	self.m_Event_onBagClickFunc = bind(self.Event_onBagClick,self)

	self:createSafes()
	self:createBombableBricks()


	addEventHandler("onColShapeLeave", self.m_ColShape,
		function(element, matchingDimension)
			if getElementType(element) == "player" and matchingDimension then
				-- Stop the countdown if all evil people were eliminated
				if self:countEvilPeople() == 0 then
					if self:countPolicePeople() > 0 then
						-- Give some money to the good people for defending the bank successfully
						for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
							if player:getFaction() and player:getFaction():isStateFaction() then
								player:giveMoney(700)
							end

							player:triggerEvent("CountdownStop")
						end
					end
					if self.m_Timer and isTimer(self.m_Timer) then
						killTimer(self.m_Timer)
					end
				end
			end
		end
	)
end

function BankRobbery:Ped_Targetted(ped, attacker)
	local faction = attacker:getFaction()
	if faction and faction:isEvilFaction() then
		if not ActionsCheck:getSingleton():isActionAllowed(attacker) then
			return false
		end
		self:startRob(attacker)
		local pos = self.m_BankDoor:getPosition()
		self.m_BankDoor:move(3000, pos.x+1.1, pos.y, pos.z)
		outputChatBox(_("Bankangestellter sagt: Hilfe! Ich öffne Ihnen die Tür zum Tresorraum!", attacker),attacker,255,255,255)
		outputChatBox(_("Bankangestellter sagt: Bitte tun sie mir nichts!", attacker),attacker,255,255,255)

	else
		attacker:sendError(_("Nur Mitglieder einer bösen Fraktion können die Bank ausrauben!",attacker))
	end
end


function BankRobbery:destructor()
	for index, safe in pairs(self.m_Safes) do
		if isElement(safe) then safe:destroy() end
	end
	for index, brick in pairs(self.m_BombableBricks) do
		if isElement(brick) then brick:destroy() end
	end
	for index, blip in pairs(self.m_Blip) do
		blip:delete()
	end
	for index, marker in pairs(self.m_DestinationMarker) do
		marker:destroy()
	end


	ActionsCheck:getSingleton():endAction()
	self:initializeAll()
end

function BankRobbery:startRob(player)
	ActionsCheck:getSingleton():setAction("Banküberfall")
	local faction = player:getFaction()
	outputChatBox("Die Bank in Palomino Creek wird überfallen!",rootElement,255,0,0)
	self.m_RobFaction = faction
	faction:sendMessage(_("Euer Spieler %s startet einen Banküberfall! Der Truck wurde gespawnt!", player, player.name),0,255,0)
	triggerClientEvent("bankAlarm", root, 2318.43, 11.37, 26.48)
	self.m_Truck = TemporaryVehicle.create(428, 2330.77, 11.33, 26.60, 270)
	self.m_Truck:setData("BankRobberyTruck", true, true)
    self.m_Truck:setColor(0, 0, 0)
    self.m_Truck:setLocked(false)
	self.m_Truck:setEngineState(true)

	for markerIndex, destination in pairs(BankRobbery.FinishMarker) do
		for index, playeritem in pairs(faction:getOnlinePlayers()) do
			self.m_Blip[markerIndex] = Blip:new("Waypoint.png", destination.x, destination.y, playeritem)
			self.m_DestinationMarker[markerIndex] = createMarker(destination,"cylinder",8)
			addEventHandler("onMarkerHit", self.m_DestinationMarker[markerIndex], bind(self.Event_onDestinationMarkerHit, self))
		end
	end

	addRemoteEvents{"bankRobberyLoadBag", "bankRobberyDeloadBag"}

	addEventHandler("bankRobberyLoadBag",root, bind(self.Event_LoadBag,self))
	addEventHandler("bankRobberyDeloadBag",root, bind(self.Event_DeloadBag,self))

	addEventHandler("onVehicleStartEnter",self.m_Truck,bind(self.Event_OnTruckStartEnter,self))
	addEventHandler("onVehicleEnter",self.m_Truck,bind(self.Event_OnTruckEnter,self))
	addEventHandler("onVehicleExit",self.m_Truck,bind(self.Event_OnTruckExit,self))
end

function BankRobbery:spawnGuards()
	self.m_GuardPed1 = GuardActor:new(Vector3(2315.25, 20.34, 26.53))
	self.m_GuardPed1:setRotation(270,0,270,"default",true)
	self.m_GuardPed1:setFrozen(true)
end

function BankRobbery:createSafes()
	self.m_Safes = {}
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
		addEventHandler( "onElementClicked", safe, self.m_OnSafeClickFunction)
	end


end


function BankRobbery:createBombableBricks()

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

function BankRobbery:countEvilPeople()
	local amount = 0
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getFaction() and player:getFaction():isEvilFaction() then
			amount = amount + 1
		end
	end
	return amount
end

function BankRobbery:countPolicePeople()
	local amount = 0
	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		if player:getFaction() and player:getFaction():isStateFaction() then
			amount = amount + 1
		end
	end
	return amount
end

function BankRobbery:BombArea_Place(bombArea, player)
	if not player:getFaction() then
		player:sendError(_("Banken kannst du nur, wenn du Mitglied einer bösen Fraktion bist, ausrauben", player))
		return false
	end

	if not ActionsCheck:getSingleton():isActionAllowed(player) then
		return false
	end

	if not DEBUG and FactionState:getSingleton():countPlayers() < 5 then
		player:sendError(_("Um den Überfall starten zu können, müssen mindestens 5 Polizisten online sein!", player))
		return false
	end

	for k, player in pairs(getElementsWithinColShape(self.m_ColShape, "player")) do
		player:triggerEvent("Countdown", HOLD_TIME/1000)

		local faction = player:getFaction()
		if faction and faction:isEvilFaction() then
			player:reportCrime(Crime.BankRobbery)

		end
	end
	return true
end

function BankRobbery:BombArea_Explode(bombArea, player)
	-- Destroy Bricks
		self:startRob(player)
		for index, brick in pairs(self.m_BombableBricks) do
			brick:destroy()
		end
end

function BankRobbery:Event_onHackSuccessful(player)
	player:sendSuccess(_("Du hast das Sicherheitssystem geknackt! Die Safetür ist offen",player))
	local pos = self.m_SafeDoor:getPosition()
	self.m_SafeDoor:move(3000, pos.x, pos.y+1.5, pos.z, 0, 0, 0)
end

function BankRobbery:Event_onComputerClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and player:getFaction():isEvilFaction() then
			outputChatBox("Todo Hacking in Developement by PewX",player,255,0,0)

			setTimer(function()
				self:Event_onHackSuccessful(player)
			end,3000,1)
		end
	end
end

function BankRobbery:Event_onSafeClicked(button, state, player)
	if button == "left" and state == "down" then
		if player:getFaction() and player:getFaction():isEvilFaction() then
			local position = source:getPosition()
			local rotation = source:getRotation()
			local model = source:getModel()
			source:destroy()
			if model == 2332 then
				local obj = createObject(1829, position, rotation)
				addEventHandler( "onElementClicked", obj, self.m_OnSafeClickFunction)
			elseif model == 1829 then
				createObject(2003, position, rotation)
				local money = math.random(MONEY_PER_SAFE_MIN, MONEY_PER_SAFE_MAX)
				self:addMoneyToBag(player, money)
			end

		end
	end
end

function BankRobbery:Event_onBagClick(button, state, player)
	if button == "left" and state == "down" then
		if getDistanceBetweenPoints3D(player:getPosition(), source:getPosition()) < 3 then
			self:attachBagToPlayer(player,source)
		else
			player:sendError(_("Du bist zuweit von dem Geldsack entfernt!", player))
		end
	end
end

function BankRobbery:getAttachedBag(element)
	for key, value in pairs (getAttachedElements(element)) do
		if value:getModel() == 1550 then
			return value
		end
	end
	return false
end

function BankRobbery:getAttachedBagsCount(element)
	local count = 0
	for key, value in pairs (getAttachedElements(element)) do
		if value:getModel() == 1550 then
			count = count+1
		end
	end
	return count
end

function BankRobbery:attachBagToPlayer(player,bag)
	if not self:getAttachedBag(player) then
		player:toggleControlsWhileObjectAttached(false)
		bag:setCollisionsEnabled(false)
		bag:attach(player, 0, -0.3, 0.3, 0, 0, 180)
		player:sendShortMessage(_("Drücke 'x' um den Geldsack abzulegen!", player))
		bindKey(player, "x", "down", function(player, key, keyState, obj, bag)
			bag:detach(player)
			bag:setCollisionsEnabled(true)
			player:toggleControlsWhileObjectAttached(true)
			unbindKey(player, "x")
		end, self, bag)
	end
end

function BankRobbery:addMoneyToBag(player, money)
	for i, bag in pairs(self.m_MoneyBags) do
		if bag:getData("Money") + money < MAX_MONEY_PER_BAG then
			bag:setData("Money", bag:getData("Money") + money, true)
			player:sendShortMessage(_("%d$ in den Geldsack %d gepackt!",player, money, i))
			return
		end
	end

	local pos = Vector3(2307 + #self.m_MoneyBags, 18.87, 26)
	local newBag = createObject(1550, pos)
	table.insert(self.m_MoneyBags, newBag)
	newBag:setData("Money", money, true)
	newBag:setData("MoneyBag", true, true)
	addEventHandler("onElementClicked", newBag, self.m_Event_onBagClickFunc)
	player:sendShortMessage(_("%d$ in eine Geldsack %d gepackt!",player, money, #self.m_MoneyBags))
	self.m_MoneyBagCount = #self.m_MoneyBags
end

function BankRobbery:Event_DeloadBag(veh)
	if client:getFaction() then
		if VEHICLE_BAG_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position, client.position) < 7 then
				if not client.vehicle then
					for key, bag in pairs (getAttachedElements(veh)) do
						if bag.model == 1550 then
							bag:detach(self.m_Truck)
							self:attachBagToPlayer(client,bag)
							return
						end
					end
					client:sendError(_("Es befindet sich kein Geldsack im Truck!",client))
					return
				else
					client:sendError(_("Du darfst in keinem Fahrzeug sitzen!",client))
				end
			else
				client:sendError(_("Du bist zuweit vom Truck entfernt!",client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht entladen werden!",client))
		end
	else
		client:sendError(_("Nur Fraktionisten können Geldsäcke abladen!",client))
	end
end

function BankRobbery:Event_OnTruckStartEnter(player,seat)
	if seat == 0 and not player:getFaction() then
		player:sendError(_("Den Bank-Überfall Truck können nur Fraktionisten fahren!",player))
		cancelEvent()
	end
end

function BankRobbery:Event_OnTruckEnter(player,seat)
	if seat == 0 and player:getFaction() then
		local factionId = player:getFaction():getId()
		--local destination = factionWTDestination[factionId]
		self.m_Driver = player
		--player:triggerEvent("Countdown", math.floor((WeaponTruck.Time-(getTickCount()-self.m_StartTime))/1000))
		--player:triggerEvent("VehicleHealth")
		--self.m_Blip = Blip:new("Waypoint.png", destination.x, destination.y, player)
		--self.m_DestinationMarker = createMarker(destination,"cylinder",8)
		--addEventHandler("onMarkerHit", self.m_DestinationMarker, bind(self.Event_onDestinationMarkerHit, self))
	end
end

function BankRobbery:Event_OnTruckExit(player,seat)
	if seat == 0 then
		--player:triggerEvent("CountdownStop")
		--player:triggerEvent("VehicleHealthStop")
		--self.m_Blip:delete()
		--if isElement(self.m_DestinationMarker) then self.m_DestinationMarker:destroy() end
	end
end

function BankRobbery:Event_LoadBag(veh)
	if client:getFaction() then
		if VEHICLE_BAG_LOAD[veh.model] then
			if getDistanceBetweenPoints3D(veh.position,client.position) < 7 then
				if not client.vehicle then
					local bag = self:getAttachedBag(client)
					if self:getAttachedBagsCount(veh) < VEHICLE_BAG_LOAD[veh.model]["count"] then
						if bag then
							local count = #getAttachedElements(veh)
							bag:detach(client)
							bag:attach(veh, VEHICLE_BAG_LOAD[veh.model][count+1])

							client:toggleControlsWhileObjectAttached(true)
						else
							client:sendError(_("Du hast keinen Geldsack dabei!",client))
						end
					else
						client:sendError(_("Das Fahrzeug ist bereits voll beladen!",client))
					end
				else
					client:sendError(_("Du darfst in keinem Fahrzeug sitzen!",client))
				end
			else
				client:sendError(_("Du bist zuweit vom Truck entfernt!",client))
			end
		else
			client:sendError(_("Dieses Fahrzeug kann nicht beladen werden!",client))
		end
	else
		client:sendError(_("Nur Fraktionisten können Geldäcke abladen!",client))
	end
end

function BankRobbery:getRemainingBagAmount()
	local count = 0
	for i,k in pairs(self.m_MoneyBags) do
		if isElement(k) then
			count = count +1
		end
	end
	return count
end

function BankRobbery:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and matchingDimension then
		if hitElement.type == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if faction:isEvilFaction() then
					if (isPedInVehicle(hitElement) and self:getAttachedBag(getPedOccupiedVehicle(hitElement))) or self:getAttachedBag(hitElement) then
						local bags, amount
						local totalAmount = 0
						if isPedInVehicle(hitElement) and getPedOccupiedVehicle(hitElement) == self.m_Truck then
							bags = getAttachedElements(self.m_Truck)
							outputChatBox(_("Der Bankraub wurde erfolgreich abgeschlossen!",hitElement),rootElement,255,0,0)
							hitElement:sendInfo(_("Du hast den Bank-Überfall Truck erfolgreich abgegeben! Das Geld ist nun in eurer Kasse!",hitElement))
							self:Event_OnTruckExit(hitElement,0)
						elseif self:getAttachedBag(hitElement) then
							bags = getAttachedElements(hitElement)
							outputChatBox(_("Ein Geldsack wurde abgegeben! (%d/%d)",hitElement,self:getRemainingBagAmount(),self.m_MoneyBagCount),rootElement,255,0,0)
							hitElement:sendInfo(_("Du hast erfolgreich einen Geldsack abgegeben! Das Geld ist nun in eurer Kasse!",hitElement))
						end
						for key, value in pairs (bags) do
							if value:getModel() == 1550 then
								amount = value:getData("Money")
								totalAmount = totalAmount + amount
								faction:giveMoney(amount)
								value:destroy()
							end
						end
						outputChatBox(_("Es wurden %d$ in die Kasse gelegt!", hitElement, totalAmount),hitElement,255,255,255)

						if self:getRemainingBagAmount() == 0 then
							self:delete()
						end
					end
				end
			end
		end
	end
end

function BankRobbery.initializeAll()
	BankRobbery:new()
end
