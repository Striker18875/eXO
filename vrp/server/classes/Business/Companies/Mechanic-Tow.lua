MechanicTow = inherit(Company)
addRemoteEvents{"mechanicRepair", "mechanicRepairConfirm", "mechanicRepairCancel", "mechanicTakeVehicle"}

function MechanicTow:constructor()
	self.m_VehicleTakeMarker = Marker.create(920.614, -1176.063, 16.2, "cylinder", 1, 255, 255, 0)
	addEventHandler("onMarkerHit", self.m_VehicleTakeMarker, bind(self.VehicleTakeMarker_Hit, self))

	addEventHandler("mechanicRepair", root, bind(self.Event_mechanicRepair, self))
	addEventHandler("mechanicRepairConfirm", root, bind(self.Event_mechanicRepairConfirm, self))
	addEventHandler("mechanicRepairCancel", root, bind(self.Event_mechanicRepairCancel, self))
	addEventHandler("mechanicTakeVehicle", root, bind(self.Event_mechanicTakeVehicle, self))
end

function MechanicTow:destuctor()

end

function MechanicTow:respawnVehicle(vehicle)
	outputDebug("Respawning vehicle in mechanic base")

	vehicle:setPositionType(VehiclePositionType.Mechanic)
	vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
	vehicle:fix()
end

function MechanicTow:VehicleTakeMarker_Hit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		-- Get a list of vehicles that need manual repairing
		local vehicles = {}
		for k, vehicle in pairs(VehicleManager:getSingleton():getPlayerVehicles(hitElement)) do
			if vehicle:getPositionType() == VehiclePositionType.Mechanic then
				vehicles[#vehicles + 1] = vehicle
			end
		end

		if #vehicles > 0 then
			-- Open "vehicle take GUI"
			hitElement:triggerEvent("vehicleTakeMarkerGUI", vehicles, "mechanicTakeVehicle")
		else
			hitElement:sendWarning(_("Keine abholbaren Fahrzeuge vorhanden!", hitElement))
		end
	end
end

function MechanicTow:Event_mechanicRepair()
	if client:getCompany() ~= self then
		return
	end

	local driver = source:getOccupant(0)
	if not driver then
		client:sendError(_("Jemand muss sich auf dem Fahrersitz befinden!", client))
		return
	end
	--[[if driver == client then
		client:sendError(_("Du kannst dein eigenes Fahrzeug nicht reparieren!", client))
		return
	end]]
	if source:getHealth() > 950 then
		client:sendError(_("Dieses Fahrzeug hat keine nennenswerten Beschädigungen!", client))
		return
	end

	source.PendingMechanic = client
	local price = math.floor((1000 - getElementHealth(source))*0.5)
	driver:triggerEvent("questionBox", _("Darf %s dein Fahrzeug reparieren? Dies kostet dich zurzeit %d$!\nBeim nächsten Pay'n'Spray zahlst du einen Aufschlag von +33%%!", client, getPlayerName(client), price), "mechanicRepairConfirm", "mechanicRepairCancel", source)
end

function MechanicTow:Event_mechanicRepairConfirm(vehicle)
	local price = math.floor((1000 - getElementHealth(vehicle))*0.5)
	if client:getMoney() >= price then
		fixVehicle(vehicle)
		client:takeMoney(price)

		if vehicle.PendingMechanic then
			if client ~= vehicle.PendingMechanic then
				vehicle.PendingMechanic:giveMoney(price)
				vehicle.PendingMechanic:givePoints(5)
				vehicle.PendingMechanic:sendInfo(_("Du hast das Fahrzeug von %s erfolgreich repariert! Du hast %s$ verdient!", vehicle.PendingMechanic, getPlayerName(client), price))
				client:sendInfo(_("%s hat dein Fahrzeug erfolgreich repariert!", client, getPlayerName(vehicle.PendingMechanic)))

				self.m_BankAccount:addMoney(price*0.01)
			else
				client:sendInfo(_("Du hat dein Fahrzeug erfolgreich repariert!", client))
			end
			vehicle.PendingMechanic = nil
		end
	else
		client:sendError(_("Du hast nicht genügend Geld! Benötigt werden %d$!", client, price))
	end
end

function MechanicTow:Event_mechanicRepairCancel(vehicle)
	if vehicle.PendingMechanic then
		vehicle.PendingMechanic:sendWarning(_("Der Reperaturvorgang wurde von der Gegenseite abgebrochen!", vehicle.PendingMechanic))
		vehicle.PendingMechanic = nil
	end
end

function MechanicTow:Event_mechanicTakeVehicle()
	if client:getMoney() >= 500 then
		client:takeMoney(500)
		source:fix()

		-- Spawn vehicle in non-collision zone
		source:setPositionType(VehiclePositionType.World)
		source:setDimension(0)
		local x, y, z, rotation = unpack(Randomizer:getRandomTableValue(self.SpawnPositions))
		source:setPosition(x, y, z)
		source:setRotation(0, 0, rotation)
		client:warpIntoVehicle(source)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end

MechanicTow.SpawnPositions = {
	{894.370, -1187.525, 16.704, 180},
	{924.837, -1192.842, 16.704, 90},
	--{1097.2, -1198.1, 17.70, 180},
	--{1091.7, -1198.3, 17.70, 180},
	--
}
