MechanicTow = inherit(Company)
addRemoteEvents{"mechanicRepair", "mechanicRepairConfirm", "mechanicRepairCancel", "mechanicDetachFuelTank", "mechanicTakeFuelNozzle", "mechanicRejectFuelNozzle", "mechanicTakeVehicle", "mechanicOpenTakeGUI", "mechanicVehicleRequestFill"}

function MechanicTow:constructor()
	self:createTowLot()
	self.m_PendingQuestions = {}

	local safe = createObject(2332, 857.594, -1182.628, 17.569, 0, 0, 270)
	safe:setScale(0.7)
	self:setSafe(safe)

	local x, y, z, rot

	self.m_NonCollissionCols = {}
	for index, pos in pairs(MechanicTow.SpawnPositions) do
		x, y, z, rot = unpack(pos)
		self.m_NonCollissionCols[index] = createColSphere(x, y, z, 10)
		self.m_NonCollissionCols[index]:setData("NonCollidingSphere", true, true)
	end

	local blip = Blip:new("CarLot.png", 913.83, -1234.65, root, 400)
		blip:setOptionalColor({150, 150, 150})
		blip:setDisplayText("Autohof", BLIP_CATEGORY.VehicleMaintenance)

	local id = self:getId()
	local blip = Blip:new("House.png", 857.594, -1182.628, {company = id}, 400, {companyColors[id].r, companyColors[id].g, companyColors[id].b})
	blip:setDisplayText(self:getName(), BLIP_CATEGORY.Company)

	self.m_FillAccept = bind(MechanicTow.FillAccept, self)
	self.m_FillDecline = bind(MechanicTow.FillDecline, self)

	addEventHandler("mechanicRepair", root, bind(self.Event_mechanicRepair, self))
	addEventHandler("mechanicRepairConfirm", root, bind(self.Event_mechanicRepairConfirm, self))
	addEventHandler("mechanicRepairCancel", root, bind(self.Event_mechanicRepairCancel, self))
	addEventHandler("mechanicDetachFuelTank", root, bind(self.Event_mechanicDetachFuelTank, self))
	addEventHandler("mechanicTakeFuelNozzle", root, bind(self.Event_mechanicTakeFuelNozzle, self))
	addEventHandler("mechanicRejectFuelNozzle", root, bind(self.Event_mechanicRejectFuelNozzle, self))
	addEventHandler("mechanicVehicleRequestFill", root, bind(self.Event_mechanicVehicleRequestFill, self))
	addEventHandler("mechanicTakeVehicle", root, bind(self.Event_mechanicTakeVehicle, self))
	addEventHandler("mechanicOpenTakeGUI", root, bind(self.VehicleTakeGUI, self))

	PlayerManager:getSingleton():getQuitHook():register(bind(self.onPlayerQuit, self))
end

function MechanicTow:destuctor()
end

function MechanicTow:onPlayerQuit(player)
	if isElement(player.fuelNozzle) then
		player.fuelNozzle:destroy()
	end
end

function MechanicTow:respawnVehicle(vehicle)
	outputDebug("Respawning vehicle in mechanic base")
	local occs = vehicle:getOccupants()
	if occs then
		for i, occ in pairs(occs) do
			occ:removeFromVehicle()
		end
	end
	vehicle:setPositionType(VehiclePositionType.Mechanic)
	vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
	vehicle:fix()
end

function MechanicTow:VehicleTakeGUI(vehicleType)
	local vehicleTable = {}

	if vehicleType == "permanentVehicle" then
		vehicleTable = VehicleManager:getSingleton():getPlayerVehicles(client)
	elseif vehicleType == "groupVehicle" then
		local group = client:getGroup()
		if not group then client:sendError(_("Du bist in keiner Gruppe!", client)) return end
		vehicleTable = group:getVehicles()
	end

	-- Get a list of vehicles that need manual repairing
	local vehicles = {}
	for _, vehicle in pairs(vehicleTable) do
		if vehicle:getPositionType() == VehiclePositionType.Mechanic then
			table.insert(vehicles, vehicle)
		end
	end

	if #vehicles > 0 then
		-- Open "vehicle take GUI"
		-- Todo: Probably better: Trigger a vehicle table with different vehicle types and add specific tabs to VehicleTakeGUI
		client:triggerEvent("vehicleTakeMarkerGUI", vehicles, "mechanicTakeVehicle")
	else
		client:sendInfo(_("Keine abholbaren Fahrzeuge vorhanden!", client))
	end
end

function MechanicTow:Event_mechanicRepair()
	if client:getCompany() ~= self then
		return
	end
	if not client:isCompanyDuty() then
		client:sendError(_("Du bist nicht im Dienst!", client))
		return
	end

	local driver = source:getOccupant(0)
	if not driver then
		client:sendError(_("Jemand muss sich auf dem Fahrersitz befinden!", client))
		return
	end
	if driver == client then
		client:sendError(_("Du kannst dein eigenes Fahrzeug nicht reparieren!", client))
		return
	end
	if source:getHealth() > 950 then
		client:sendError(_("Dieses Fahrzeug hat keine nennenswerten Beschädigungen!", client))
		return
	end

	if not source:isRepairAllowed() then
		client:sendError(_("Dieses Fahrzeug kann nicht repariert werden!", client))
		return
	end

	source.PendingMechanic = client
	local price = math.floor((1000 - getElementHealth(source))*0.5)

	if self.m_PendingQuestions[client] and not timestampCoolDown(self.m_PendingQuestions[client], 20) then
		client:sendError(_("Du kannst nur jede Minute eine Reparatur-Anfrage stellen!", client))
		return
	end

	self.m_PendingQuestions[client] = getRealTime().timestamp
	QuestionBox:new(client, driver,  _("Darf %s dein Fahrzeug reparieren? Dies kostet dich zurzeit %d$!\nBeim nächsten Pay'n'Spray zahlst du einen Aufschlag von +33%%!", driver, getPlayerName(client), price), "mechanicRepairConfirm", "mechanicRepairCancel", source)
end

function MechanicTow:Event_mechanicRepairConfirm(vehicle)
	local price = math.floor((1000 - getElementHealth(vehicle))*0.5)
	if source:getMoney() >= price then
		vehicle:fix()
		source:takeMoney(price, "Mech&Tow Reperatur")

		if vehicle.PendingMechanic then
			if source ~= vehicle.PendingMechanic then
				self.m_PendingQuestions[vehicle.PendingMechanic] = getRealTime().timestamp

				vehicle.PendingMechanic:giveMoney(math.floor(price*0.3), "Mech&Tow Reparatur")
				vehicle.PendingMechanic:givePoints(2)
				vehicle.PendingMechanic:sendInfo(_("Du hast das Fahrzeug von %s erfolgreich repariert! Du hast %s$ verdient!", vehicle.PendingMechanic, getPlayerName(source), price))
				source:sendInfo(_("%s hat dein Fahrzeug erfolgreich repariert!", source, getPlayerName(vehicle.PendingMechanic)))

				self:giveMoney(math.floor(price*0.7), "Reparatur", true)
			else
				source:sendInfo(_("Du hat dein Fahrzeug erfolgreich repariert!", source))
			end
			vehicle.PendingMechanic = nil
		end
	else
		source:sendError(_("Du hast nicht genügend Geld! Benötigt werden %d$!", source, price))
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
		client:takeMoney(500, "Mech&Tow")
		self:giveMoney(500, "Fahrzeug freikauf", true)
		source:fix()

		-- Spawn vehicle in non-collision zone
		source:setPositionType(VehiclePositionType.World)
		source:setDimension(0)
		local x, y, z, rotation = unpack(Randomizer:getRandomTableValue(self.SpawnPositions))


		if source:getVehicleType() == VehicleType.Plane then
			x, y, z, rotation = 871.285, -1264.624, 15.5, 0
		elseif source:getVehicleType() == VehicleType.Helicopter then
			x, y, z, rotation =  912.602, -1252.053, 16, 0
		end

		source:setPosition(x, y, z)
		source:setRotation(0, 0, rotation)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end

function MechanicTow:createTowLot()
	self.m_TowColShape = createColRectangle(861.296, -1258.862, 14, 17)
	addEventHandler("onColShapeHit", self.m_TowColShape, bind( self.onEnterTowLot, self ))
	addEventHandler("onColShapeLeave", self.m_TowColShape, bind( self.onLeaveTowLot, self ))
	addEventHandler("onTrailerAttach", getRootElement(), bind(self.onAttachVehicleToTow, self))
	addEventHandler("onTrailerDetach", getRootElement(), bind( self.onDetachVehicleFromTow, self ))
end

function MechanicTow:onEnterTowLot(hitElement)
	if hitElement:getType() == "player" then
		if hitElement.vehicle then
			local veh = hitElement.vehicle
			if hitElement:getCompany() == self then
				if instanceof(veh, CompanyVehicle) and veh:getCompany() == self then
					if veh:getModel() == 525 then
						hitElement.m_InTowLot = true
						hitElement:sendInfo(_("Du kannst hier abgeschleppte Fahrzeuge abladen!", hitElement))
					end
				end
			end
		end
	end
end

function MechanicTow:sendWarning(text, header, withOffDuty, pos, ...)
	for k, player in pairs(self:getOnlinePlayers(false, not withOffDuty)) do
		player:sendWarning(_(text, player, ...), 30000, header)
	end
	if pos and pos.x then pos = {pos.x, pos.y, pos.z} end -- serialiseVector conversion
	if pos and pos[1] and pos[2] then
		local blip = Blip:new("Fire.png", pos[1], pos[2], {company = self:getId()}, 4000, BLIP_COLOR_CONSTANTS.Orange)
			blip:setDisplayText(header)
		if pos[3] then
			blip:setZ(pos[3])
		end
		setTimer(function()
			blip:delete()
		end, 30000, 1)
	end
end

function MechanicTow:onLeaveTowLot(hitElement)
	hitElement.m_InTowLot = false
end

function MechanicTow:onAttachVehicleToTow(towTruck)
	local driver = getVehicleOccupant(towTruck)
	if driver then
		if towTruck.getCompany and towTruck:getCompany() == self and towTruck:getModel() == 525 then
			if instanceof(source, PermanentVehicle, true) or instanceof(source, GroupVehicle, true) or source.burned then
				source:toggleRespawn(false)
			else
				driver:sendInfo(_("Dieses Fahrzeug kann nicht abgeschleppt werden!", driver))
			end
		end
	end
end

function MechanicTow:onDetachVehicleFromTow( towTruck )
	source:toggleRespawn(true)

	local driver = getVehicleOccupant(towTruck)
	if driver and driver.m_InTowLot then
		if towTruck.getCompany and towTruck:getCompany() == self then
			if instanceof(source, PermanentVehicle, true) or instanceof(source, GroupVehicle, true) or source.burned then
				if not source.burned then
					self:respawnVehicle(source)
					driver:sendInfo(_("Das Fahrzeug ist nun abgeschleppt!", driver))
					StatisticsLogger:getSingleton():vehicleTowLogs(driver, source)
					self:addLog(driver, "Abschlepp-Logs", ("hat ein Fahrzeug (%s) von %s abgeschleppt!"):format(source:getName(), getElementData(source, "OwnerName") or "Unbekannt"))
				else
					source:destroy()
					driver:sendInfo(_("Du hast erfolgreich ein Fahrzeug-Wrack abgeschleppt!", driver))
					driver:giveMoney(200, "Fahrzeug-Wrack")
				end
			else
				driver:sendError(_("Dieses Fahrzeug kann nicht abgeschleppt werden!", driver))
			end
		end
	end
end

function MechanicTow:Event_mechanicDetachFuelTank(vehicle)
	if client:getCompany() ~= self then
		return
	end
	if not client:isCompanyDuty() then
		client:sendError(_("Du bist nicht im Dienst!", client))
		return
	end

	if vehicle.getCompany and vehicle:getCompany() == self then
		vehicle:detachTrailer()
	end
end

function MechanicTow:Event_mechanicTakeFuelNozzle(vehicle)
	if client:getCompany() ~= self then
		return
	end
	if not client:isCompanyDuty() then
		client:sendError(_("Du bist nicht im Dienst!", client))
		--return
	end

	if vehicle.getCompany and vehicle:getCompany() == self then
		if isElement(client.fuelNozzle) then
			toggleControl(client, "fire", true)
			client:setPrivateSync("hasFuelNozzle", false)
			client:triggerEvent("closeFuelTankGUI")
			client.fuelNozzle:destroy()
			return
		end

		if not vehicle.towingVehicle then return end

		client.fuelNozzle = createObject(1909, client.position)
		client.fuelNozzle:setData("attachedToVehicle", vehicle, true)
		client.fuelNozzle.vehicle = vehicle
		exports.bone_attach:attachElementToBone(client.fuelNozzle, client, 12, -0.03, 0.02, 0.05, 180, 320, 0)

		client:setPrivateSync("hasFuelNozzle", vehicle)
		client:triggerEvent("showFuelTankGUI", vehicle, vehicle:getFuel())
		toggleControl(client, "fire", false)
	end
end

function MechanicTow:Event_mechanicRejectFuelNozzle()
	if isElement(client.fuelNozzle) then
		toggleControl(client, "fire", true)
		client:setPrivateSync("hasFuelNozzle", false)
		client:triggerEvent("closeFuelTankGUI")
		client.fuelNozzle:destroy()
		return
	end
end

function MechanicTow:Event_mechanicVehicleRequestFill(vehicle, fuel)
	if client:getCompany() ~= self then return end
	if not client:isCompanyDuty() then client:sendError(_("Du bist nicht im Dienst!", client)) return end
	if not vehicle then return end
	if not vehicle.controller then return end

	if vehicle.controller.fillRequest then
		client:sendError("Der Spieler hat bereits eine Anfrage bekommen")
		return
	end

	local fuel = vehicle:getFuel() + fuel > 100 and math.floor(100 - vehicle:getFuel()) or math.floor(fuel)
	local price = math.floor(fuel * 1.5)

	if fuel == 0 then
		client:sendError("Das Fahrzeug ist bereits vollgetankt!")
		return
	end

	local fuelTank = client:getPrivateSync("hasFuelNozzle")
	if fuel > fuelTank:getFuel()*5 then
		client:sendError("Im Tankanhänger ist nicht genügend Benzin!")
		return
	end

	QuestionBox:new(client, vehicle.controller,  _("%s möchte dein Fahrzeug tanken. %s Liter zum Preis von %s$", vehicle.controller, client:getName(), fuel, price), self.m_FillAccept, self.m_FillDecline, client, vehicle.controller, vehicle, fuel, price)
	client:sendInfo("Dem Spieler wurde dein Service angeboten..")
	vehicle.controller.fillRequest = true
end

function MechanicTow:FillAccept(player, target, vehicle, fuel, price)
	target.fillRequest = false

	local fuelTank = player:getPrivateSync("hasFuelNozzle")
	if fuel > fuelTank:getFuel()*5 then
		player:sendError("Im Tankanhänger ist nicht genügend Benzin!")
		return
	end

	if target:getMoney() >= price then
		target:takeMoney(price, "Mech&Tow tanken")
		vehicle:setFuel(vehicle:getFuel() + fuel)

		player:giveMoney(math.floor(price*0.3), "Mech&Tow tanken")
		self:giveMoney(math.floor(price*0.7), "Tanken")

		fuelTank:setFuel(fuelTank:getFuel() - fuel/5)
		player:triggerEvent("updateFuelTankGUI", fuelTank:getFuel())
	else
		target:sendError(_("Du hast nicht genügend Geld! Benötigt werden %d$!", target, price))
		player:sendError(_("Der Spieler hat nicht genügend Geld!", player))
	end
end

function MechanicTow:FillDecline(player, target)
	target.fillRequest = false
	player:sendError(_("Der Spieler möchte deinen Service nicht nutzen.", player))
end

MechanicTow.SpawnPositions = {
	{904.833, -1183.605, 16.65, 180},
	{900.833, -1183.605, 16.65, 180},
	--{833.2, -1198.1, 17.70, 180},
	--{1091.7, -1198.3, 17.70, 180},
	--
}
