-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Elevator.lua
-- *  PURPOSE:     Elevator class
-- *
-- ****************************************************************************
Elevator = inherit(Object)
Elevator.Map = {}

addRemoteEvents{"elevatorDrive"}

function Elevator.drive(elevatorId, stationId)
	Elevator.Map[elevatorId]:driveToStation(client, stationId)
end
addEventHandler("elevatorDrive", root, Elevator.drive)

function Elevator:constructor()
	self.m_Stations = {}
	self.m_Id = #Elevator.Map+1

	Elevator.Map[self.m_Id] = self
end

function Elevator:addStation(name, position, rot, int, dim)
	local stationID = #self.m_Stations+1
	self.m_Stations[stationID] = {}
	self.m_Stations[stationID].name = name
	self.m_Stations[stationID].position = position
	self.m_Stations[stationID].interior = int or 0
	self.m_Stations[stationID].dimension = dim or 0
	self.m_Stations[stationID].rotation = rot or 0
	self.m_Stations[stationID].marker = createMarker(position, "corona", 1, 255, 255, 0, 125)
	self.m_Stations[stationID].marker.id = stationID
	if int then
		self.m_Stations[stationID].marker:setInterior(int)
	end
	if dim then
		self.m_Stations[stationID].marker:setDimension(dim)
	end
	addEventHandler("onMarkerHit", self.m_Stations[stationID].marker, bind(self.onStationMarkerHit, self) )
	addEventHandler("onMarkerLeave", self.m_Stations[stationID].marker, bind(self.onStationMarkerLeave, self) )
end

function Elevator:onStationMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if not hitElement.vehicle then
			if not hitElement.elevatorUsed then
				hitElement.curEl = self
				local pVec = self.m_Stations[source.id].position
				hitElement:triggerEvent("showElevatorGUI", self.m_Id, self.m_Stations[source.id].name, self.m_Stations, {pVec.x,pVec.y,pVec.z} , self.m_Stations[source.id].interior)
			end
		end
	end
end

function Elevator:onStationMarkerLeave(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		hitElement.elevatorUsed = false
		hitElement.curEl = false
	end
end

function Elevator:driveToStation(player, stationID)
	player.elevatorUsed = true
	player.curEl = false

	-- Workaround TODO
	nextframe(function()
		player:setInterior(self.m_Stations[stationID].interior)
		player:setPosition(self.m_Stations[stationID].position)
	end)
	player:setInterior(0)
	--

	player:setRotation(Vector3(0, 0, self.m_Stations[stationID].rotation))
	player:setDimension(self.m_Stations[stationID].dimension)
	setElementFrozen(player, false)
end
