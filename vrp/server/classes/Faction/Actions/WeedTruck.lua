-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/WeedTruck.lua
-- *  PURPOSE:     Weapon Truck Class
-- *
-- ****************************************************************************

WeedTruck = inherit(Object)
WeedTruck.LoadTime = 30*1000 -- in ms
WeedTruck.Time = 10*60*1000 -- in ms
WeedTruck.spawnPos = Vector3(-1105.76, -1621.55, 76.54)
WeedTruck.spawnRot = Vector3(0, 0, 270)
WeedTruck.Destination = Vector3(2181.59, -2626.35, 13.55)
WeedTruck.Weed = 2500

function WeedTruck:constructor(driver)
	self.m_Truck = TemporaryVehicle.create(456, WeedTruck.spawnPos, WeedTruck.spawnRot)
	self.m_Truck:setData("WeedTruck", true, true)
    self.m_Truck:setColor(0, 50, 0)
	self.m_Truck:setFrozen(true)
	self.m_Truck:setVariant(255, 255)
	self.m_Truck:setEngineState(true)
	self.m_StartTime = getTickCount()
	warpPedIntoVehicle(driver, self.m_Truck)
	self.m_StartPlayer = driver
	self.m_StartFaction = driver:getFaction()


	self.m_Destroyed = false
	self.m_DestroyFunc = bind(self.Event_OnWeedTruckDestroy,self)

	driver:triggerEvent("Countdown", math.floor(WeedTruck.LoadTime/1000))
	self.m_LoadTimer = setTimer(bind(self.truckLoaded, self), WeedTruck.LoadTime, 1)
	self.m_StartPlayer:sendInfo(_("Der Weed-Truck wird beladen! Bitte warten!", self.m_StartPlayer))

	PlayerManager:getSingleton():breakingNews("Ein Weed-Transport wurde soeben gestartet!")


	addEventHandler("onVehicleStartEnter",self.m_Truck,bind(self.Event_OnWeedTruckStartEnter,self))
	addEventHandler("onVehicleEnter",self.m_Truck,bind(self.Event_OnWeedTruckEnter,self))
	addEventHandler("onVehicleExit",self.m_Truck,bind(self.Event_OnWeedTruckExit,self))
	addEventHandler("onElementDestroy",self.m_Truck,self.m_DestroyFunc)
end

function WeedTruck:destructor()
	removeEventHandler("onElementDestroy",self.m_Truck,self.m_DestroyFunc)
	ActionsCheck:getSingleton():endAction()
	self.m_Truck:destroy()

	if isElement(self.m_DestinationMarker) then self.m_DestinationMarker:destroy() end
	if isElement(self.m_Blip) then self.m_Blip:delete() end
	if isElement(self.m_LoadMarker) then self.m_LoadMarker:destroy() end
	if isTimer(self.m_Timer) then self.m_Timer:destroy() end
	for index, value in pairs(self.m_Boxes) do
		if isElement(value) then value:destroy() end
	end
end


function WeedTruck:truckLoaded()
	self.m_StartPlayer:sendInfo(_("Der Weed-Truck ist vollständig beladen!", self.m_StartPlayer))
	self.m_Truck:setFrozen(false)
	self.m_Timer = setTimer(bind(self.timeUp, self), WeedTruck.Time, 1)
	self:Event_OnWeedTruckEnter(self.m_StartPlayer, 0)

end

function WeedTruck:timeUp()
	PlayerManager:getSingleton():breakingNews("Der Weed-Transport wurde beendet! Den Verbrechern ist die Zeit ausgegangen!")
	self:delete()
end

--Vehicle Events
function WeedTruck:Event_OnWeedTruckStartEnter(player,seat)
	if seat == 0 and not player:getFaction() then
		player:sendError(_("Den Weed-Truck können nur Fraktionisten fahren!",player))
		cancelEvent()
	end
end

function WeedTruck:Event_OnWeedTruckDestroy()
	if self and not self.m_Destroyed then
		self.m_Destroyed = true
		self:Event_OnWeedTruckExit(self.m_Driver,0)
		PlayerManager:getSingleton():breakingNews("Der Weed-LKW wurde soeben zerstört!")
		self:delete()
	end
end

function WeedTruck:Event_OnWeedTruckEnter(player, seat)
	if seat == 0 and player:getFaction() then
		local factionId = player:getFaction():getId()
		local destination = WeedTruck.Destination
		self.m_Driver = player
		player:triggerEvent("Countdown", math.floor((WeedTruck.Time-(getTickCount()-self.m_StartTime))/1000))
		player:triggerEvent("VehicleHealth")
		self.m_Blip = Blip:new("Waypoint.png", destination.x, destination.y, player)
		self.m_DestinationMarker = createMarker(destination,"cylinder",8)
		addEventHandler("onMarkerHit", self.m_DestinationMarker, bind(self.Event_onDestinationMarkerHit, self))
	end
end

function WeedTruck:Event_OnWeedTruckExit(player,seat)
	if seat == 0 then
		player:triggerEvent("CountdownStop")
		player:triggerEvent("VehicleHealthStop")
		self.m_Blip:delete()
		if isElement(self.m_DestinationMarker) then self.m_DestinationMarker:destroy() end
	end
end

function WeedTruck:Event_onDestinationMarkerHit(hitElement, matchingDimension)
	if isElement(hitElement) and hitElement.type == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction and faction:isEvilFaction() then
			if isPedInVehicle(hitElement) and hitElement:getOccupiedVehicle() == self.m_Truck then
				PlayerManager:getSingleton():breakingNews("Der Weed-Transport wurde erfolgreich abgeschlossen!")
				hitElement:sendInfo(_("Weed-Truck abgegeben! Du erhälst %d Gramm Weed!", hitElement, WeedTruck.Weed))
				hitElement:getInventory():giveItem("Weed", WeedTruck.Weed)
				self:Event_OnWeedTruckExit(hitElement,0)
				delete(self)
			end
		end
	end
end
