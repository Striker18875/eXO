-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleManager.lua
-- *  PURPOSE:     Vehicle manager class
-- *
-- ****************************************************************************
VehicleManager = inherit(Singleton)
VehicleManager.sPulse = TimedPulse:new(5*1000)

function VehicleManager:constructor()
	self.m_Vehicles = {}
	self.m_TemporaryVehicles = {}
	self.m_CompanyVehicles = {}
	self.m_GroupVehicles = {}
	self.m_FactionVehicles = {}
	self:setSpeedLimits()

	-- Add events
	addRemoteEvents{"vehicleLock", "vehicleRequestKeys", "vehicleAddKey", "vehicleRemoveKey",
		"vehicleRepair", "vehicleRespawn", "vehicleDelete", "vehicleSell", "vehicleRequestInfo",
		"vehicleUpgradeGarage", "vehicleHotwire", "vehicleEmpty", "vehicleSyncMileage", "vehicleBreak", "vehicleUpgradeHangar"}
	addEventHandler("vehicleLock", root, bind(self.Event_vehicleLock, self))
	addEventHandler("vehicleRequestKeys", root, bind(self.Event_vehicleRequestKeys, self))
	addEventHandler("vehicleAddKey", root, bind(self.Event_vehicleAddKey, self))
	addEventHandler("vehicleRemoveKey", root, bind(self.Event_vehicleRemoveKey, self))
	addEventHandler("vehicleRepair", root, bind(self.Event_vehicleRepair, self))
	addEventHandler("vehicleRespawn", root, bind(self.Event_vehicleRespawn, self))
	addEventHandler("vehicleDelete", root, bind(self.Event_vehicleDelete, self))
	addEventHandler("vehicleSell", root, bind(self.Event_vehicleSell, self))
	addEventHandler("vehicleRequestInfo", root, bind(self.Event_vehicleRequestInfo, self))
	addEventHandler("vehicleUpgradeGarage", root, bind(self.Event_vehicleUpgradeGarage, self))
	addEventHandler("vehicleHotwire", root, bind(self.Event_vehicleHotwire, self))
	addEventHandler("vehicleEmpty", root, bind(self.Event_vehicleEmpty, self))
	addEventHandler("vehicleSyncMileage", root, bind(self.Event_vehicleSyncMileage, self))
	addEventHandler("vehicleBreak", root, bind(self.Event_vehicleBreak, self))
	addEventHandler("vehicleUpgradeHangar", root, bind(self.Event_vehicleUpgradeHangar, self))

	-- Check Licenses
	addEventHandler("onVehicleStartEnter", root,
		function (player, seat)
			if seat == 0 then
				self:checkVehicle(source)

				if not source:isLocked() then
					local vehicleType = source:getVehicleType()
					if (vehicleType == VehicleType.Plane or vehicleType == VehicleType.Helicopter) and not player:hasPilotsLicense() then
						player:removeFromVehicle(source)
						player:setPosition(source.matrix:transformPosition(-1.5, 5, 0))
						player:sendShortMessage(_("Du hast keinen Flugschein!", player))
					elseif vehicleType == Vehicle.Automobile and not player:hasDrivingLicense() then
						player:sendShortMessage(_("Du hast keinen Führerschein! Lass dich nicht erwischen!", player))
					end
				end
			end
		end
	)

	-- Prevent the engine from being turned on
	addEventHandler("onVehicleEnter", root,
		function(player, seat, jackingPlayer)
			if seat == 0 then
				self:checkVehicle(source)

				setVehicleEngineState(source, source:getEngineState())
				player:triggerEvent("vehicleFuelSync", source:getFuel())
			end
		end
	)
	VehicleManager.sPulse:registerHandler(bind(VehicleManager.removeUnusedVehicles, self))

	setTimer(bind(self.updateFuelOfPermanentVehicles, self), 60*1000, 0)
end

function VehicleManager:destructor()
	for ownerId, vehicles in pairs(self.m_Vehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
		end
	end
	outputServerLog("Saved vehicles")

	for companyId, vehicles in pairs(self.m_CompanyVehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
		end
	end
	outputServerLog("Saved company vehicles")
	for groupId, vehicles in pairs(self.m_GroupVehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
		end
	end
	outputServerLog("Saved Group vehicles")
	for factionId, vehicles in pairs(self.m_FactionVehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
		end
	end
	outputServerLog("Saved faction vehicles")
end

function VehicleManager:getFactionVehicles(factionId)
	return self.m_FactionVehicles[factionId]
end

function VehicleManager:getGroupVehicles(groupId)
	return self.m_GroupVehicles[groupId]
end

function VehicleManager.loadVehicles()
	outputServerLog("Loading vehicles...")
	local result = sql:queryFetch("SELECT * FROM ??_vehicles", sql:getPrefix())
	for i, row in pairs(result) do
		local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation)
		enew(vehicle, PermanentVehicle, tonumber(row.Id), row.Owner, fromJSON(row.Keys or "[ [ ] ]"), row.Color, row.Color2, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage, row.LightColor, row.TrunkId, row.TexturePath)
		VehicleManager:getSingleton():addRef(vehicle, false)
	end
	outputServerLog("Loading company vehicles")
	local result = sql:queryFetch("SELECT * FROM ??_company_vehicles", sql:getPrefix())
	for i, row in pairs(result) do
		local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation)
		enew(vehicle, CompanyVehicle, tonumber(row.Id), CompanyManager:getSingleton():getFromId(row.Company), row.Color, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage)
		VehicleManager:getSingleton():addRef(vehicle, false)
	end
	outputServerLog("Loading faction vehicles")
	local result = sql:queryFetch("SELECT * FROM ??_faction_vehicles", sql:getPrefix())
	for i, row in pairs(result) do
		if FactionManager:getFromId(row.Faction) then
			local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation)
			enew(vehicle, FactionVehicle, tonumber(row.Id), FactionManager:getFromId(row.Faction), row.Color, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage)
			VehicleManager:getSingleton():addRef(vehicle, false)
		end
	end
	outputServerLog("Loading group vehicles")
	local result = sql:queryFetch("SELECT * FROM ??_group_vehicles", sql:getPrefix())
	for i, row in pairs(result) do
		if GroupManager:getFromId(row.Group) then
			local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation)
			enew(vehicle, GroupVehicle, tonumber(row.Id), GroupManager:getFromId(row.Group), row.Color, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage)
			VehicleManager:getSingleton():addRef(vehicle, false)
		else
			sql:queryExec("DELETE FROM ??_group_vehicles WHERE ID = ?", sql:getPrefix(), row.Id)
		end
	end
end

function VehicleManager:addRef(vehicle, isTemp)
	if isTemp then
		self.m_TemporaryVehicles[#self.m_TemporaryVehicles+1] = vehicle
		return
	end
	if instanceof(vehicle, CompanyVehicle) then
		local companyId = vehicle:getCompany() and vehicle:getCompany():getId()
		assert(companyId, "Bad company specified")

		if not self.m_CompanyVehicles[companyId] then
			self.m_CompanyVehicles[companyId] = {}
		end

		table.insert(self.m_CompanyVehicles[companyId], vehicle)
		return
	end
	if instanceof(vehicle, GroupVehicle) then
		local groupId = vehicle:getGroup() and vehicle:getGroup():getId()
		assert(groupId, "Bad group specified")

		if not self.m_GroupVehicles[groupId] then
			self.m_GroupVehicles[groupId] = {}
		end

		table.insert(self.m_GroupVehicles[groupId], vehicle)
		return
	end
	if instanceof(vehicle, FactionVehicle) and vehicle:getFaction() then
		local factionId = vehicle:getFaction() and vehicle:getFaction():getId()
		assert(factionId, "Bad owner specified")

		if not self.m_FactionVehicles[factionId] then
			self.m_FactionVehicles[factionId] = {}
		end

		table.insert(self.m_FactionVehicles[factionId], vehicle)
		return
	end

	local ownerId = vehicle:getOwner()
	assert(ownerId, "Bad owner specified")

	if not self.m_Vehicles[ownerId] then
		self.m_Vehicles[ownerId] = {}
	end

	table.insert(self.m_Vehicles[ownerId], vehicle)
end

function VehicleManager:removeRef(vehicle, isTemp)
	if isTemp then
		local idx = table.find(self.m_TemporaryVehicles, vehicle)
		if idx then
			table.remove(self.m_TemporaryVehicles, idx)
		end
		return
	end
	if instanceof(vehicle, CompanyVehicle) and vehicle:getCompany() then
		local companyId = vehicle:getCompany() and vehicle:getCompany():getId()
		assert(companyId, "Bad company specified")

		if self.m_CompanyVehicles[companyId] then
			local idx = table.find(self.m_CompanyVehicles[companyId], vehicle)
			if idx then
				table.remove(self.m_CompanyVehicles[companyId], idx)
			end
		end
		return
	end

	if instanceof(vehicle, GroupVehicle) and vehicle:getGroup() then
		local groupId = vehicle:getGroup() and vehicle:getGroup():getId()
		assert(groupId, "Bad company specified")

		if self.m_GroupVehicles[groupId] then
			local idx = table.find(self.m_GroupVehicles[groupId], vehicle)
			if idx then
				table.remove(self.m_GroupVehicles[groupId], idx)
			end
		end
		return
	end

	if instanceof(vehicle, FactionVehicle) and vehicle:getFaction() then
		local factionId = vehicle:getFaction() and vehicle:getFaction():getId()
		assert(factionId, "Bad faction specified")

		if self.m_FactionVehicles[factionId] then
			local idx = table.find(self.m_FactionVehicles[factionId], vehicle)
			if idx then
				table.remove(self.m_FactionVehicles[factionId], idx)
			end
		end
		return
	end

	local ownerId = vehicle:getOwner()
	assert(ownerId, "Bad owner specified")

	if self.m_Vehicles[ownerId] then
		local idx = table.find(self.m_Vehicles[ownerId], vehicle)
		if idx then
			table.remove(self.m_Vehicles[ownerId], idx)
		end
	end
end

function VehicleManager:sendTexturesToClient(client)
	for ownerid, vehicles in pairs(self.m_Vehicles) do
		for i, v in pairs(vehicles) do
			if v.m_Texture and v.m_Texture ~= "0" then
				triggerClientEvent(client, "changeElementTexture", client, {{vehicle = v, textureName = false, texturePath = v.m_Texture}})
			end
		end
	end
end

function VehicleManager:removeUnusedVehicles()
	-- ToDo: Lateron, do not loop through all vehicles
	for ownerid, data in pairs(self.m_Vehicles) do
		for k, vehicle in pairs(data) do
			if vehicle:getLastUseTime() < getTickCount() - 30*1000*60 then
				vehicle:respawn()
			end
		end
	end

	for k, vehicle in pairs(self.m_TemporaryVehicles) do
		if vehicle:getHealth() < 0.1 and vehicle:getLastUseTime() < getTickCount() - 1*60*1000 then
			vehicle:respawn()
		else
			if vehicle:getLastUseTime() < getTickCount() - 2*60*1000 then
				if vehicle:getModel() == 435 then
					if vehicle:getTowingVehicle() then
						return
					end
				end

				vehicle:respawn()
			end
		end
	end
end

function VehicleManager:getPlayerVehicles(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	return self.m_Vehicles[player] or {}
end

function VehicleManager:loadPlayerVehicles(player)
	if player:getId() then
		local result = sql:queryFetch("SELECT * FROM ??_vehicles WHERE Owner = ?", sql:getPrefix(), player:getId())
		for i, row in pairs(result) do
			local vehicle = createVehicle(row.Model, row.PosX, row.PosY, row.PosZ, 0, 0, row.Rotation)
			enew(vehicle, PermanentVehicle, tonumber(row.Id), row.Owner, fromJSON(row.Keys or "[ [ ] ]"), row.Color, row.Health, row.PositionType, fromJSON(row.Tunings or "[ [ ] ]"), row.Mileage, row.LightColor)
			VehicleManager:getSingleton():addRef(vehicle, false)
		end
	end
end

function VehicleManager:updateFuelOfPermanentVehicles()
	for k, player in pairs(getElementsByType("player")) do
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle and vehicle.getFuel and vehicle:getEngineState() then
			vehicle:setFuel(vehicle:getFuel() - 0.5)
		end
	end
end

function VehicleManager:checkVehicle(vehicle)
	-- Lightweight instanceof(vehicle, Vehicle)
	if not vehicle.toggleLight then
		-- Make a temporary vehicle if vehicle is not yet instance of any class
		enew(vehicle, TemporaryVehicle)
	end
end

function VehicleManager:setSpeedLimits()
	setModelHandling(462, "maxVelocity", 50) -- Faggio
	setModelHandling(509, "maxVelocity", 50) -- Bike
	setModelHandling(481, "maxVelocity", 50) -- BMX
	setModelHandling(510, "maxVelocity", 50) -- Mountain Bike
end

function VehicleManager:Event_vehicleLock()
	if not source or not isElement(source) then return end
	self:checkVehicle(source)

	if source:hasKey(client) or client:getRank() >= RANK.Moderator then
		source:playLockEffect()
		source:setLocked(not source:isLocked())
		return
	end

	client:sendError(_("Du hast keinen Schlüssel für dieses Fahrzeug", client))
end

function VehicleManager:Event_vehicleRequestKeys()
	if not instanceof(source, PermanentVehicle, true) then
		triggerClientEvent(client, "vehicleKeysRetrieve", source, false)
		return
	end

	local names = source:getKeyNameList()
	triggerClientEvent(client, "vehicleKeysRetrieve", source, names)
end

function VehicleManager:Event_vehicleAddKey(player)
	if not player or not isElement(player) then return end
	if not player:isLoggedIn() then return end
	if not instanceof(source, PermanentVehicle, true) then return end

	if not source:isPermanent() then
		client:sendError(_("Nur permanente Fahrzeuge können Schlüssel haben!", client))
		return
	end

	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end

	if source:hasKey(player:getId()) then
		client:sendWarning(_("Dieser Spieler besitzt bereits einen Schlüssel!", client))
		return
	end

	-- Finally, add the key
	source:addKey(player)

	-- Tell the client that we added a new key
	triggerClientEvent(client, "vehicleKeysRetrieve", source, source:getKeyNameList())
end

function VehicleManager:Event_vehicleRemoveKey(characterId)
	if not source:hasKey(characterId) then
		client:sendWarning(_("The specified player is not in possession of a key", client))
		return
	end

	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end

	-- Finally, remove the key
	source:removeKey(characterId)

	-- Tell the client that we removed the key
	triggerClientEvent(client, "vehicleKeysRetrieve", source, source:getKeyNameList())
end

function VehicleManager:Event_vehicleRepair()
	if client:getRank() < RANK.Moderator then
		AntiCheat:getSingleton():report(client, "DisallowedEvent", CheatSeverity.High)
		return
	end

	fixVehicle(source)
end

function VehicleManager:Event_vehicleRespawn()
	if not instanceof(source, PermanentVehicle) then
		client:sendError(_("Das ist kein permanentes Server Fahrzeug!", client))
		return
	end

	-- Todo: (Re-)move this block
	if instanceof(source, FactionVehicle) then
		if (not client:getFaction()) or source:getFaction():getId() ~= client:getFaction():getId() then
			client:sendError(_("Dieses Fahrzeug ist nicht von deiner Fraktion!", client))
			return
		end

		source:respawn(client:getRank() >= RANK.Moderator)
		return
	end

	if instanceof(source, CompanyVehicle) then
		if (not client:getCompany()) or source:getCompany():getId() ~= client:getCompany():getId() then
			client:sendError(_("Diese Fahrzeug ist nicht von deiner Firma!", client))
			return
		end

		source:respawn(client:getRank() >= RANK.Moderator)
		return
	end

	if instanceof(source, GroupVehicle) then
		if (not client:getGroup()) or source:getGroup():getId() ~= client:getGroup():getId() then
			client:sendError(_("Diese Fahrzeug ist nicht von deiner Gruppe!", client))
			return
		end

		source:respawn(client:getRank() >= RANK.Moderator)
		return
	end
	--

	if source:getPositionType() == VehiclePositionType.Mechanic then
		client:sendError(_("Das Fahrzeug wurde abgeschleppt! Hole es an der Mech&Tow Base ab!", client))
		return
	end

	if source:getOwner() ~= client:getId() and client:getRank() < RANK.Moderator then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end
	if client:getMoney() < 100 then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end
	if source:isInGarage() then
		fixVehicle(source)
		client:takeMoney(100, "Fahrzeug-Respawn")
		client:sendShortMessage(_("Fahrzeug repariert!", client))
		return
	end
	local occupants = getVehicleOccupants(source)
	for seat, player in pairs(occupants) do
		removePedFromVehicle(player)
	end

	source:respawn()
	if client:getRank() < RANK.Moderator or source:getOwner() == client:getId() then
		client:takeMoney(100, "Fahrzeug-Respawn")
	end
	source:fix()

	-- Refresh location in the self menu
	local vehicles = {}
	for k, vehicle in pairs(self:getPlayerVehicles(client)) do
		vehicles[vehicle:getId()] = {vehicle, vehicle:getPositionType()}
	end
	client:triggerEvent("vehicleRetrieveInfo", vehicles)
end

function VehicleManager:Event_vehicleDelete()
	self:checkVehicle(source)

	if client:getRank() < RANK.Moderator then
		-- Todo: Report cheat attempt
		return
	end

	if source:isPermanent() then
		source:purge()
	else
		destroyElement(source)
	end
end

function VehicleManager:Event_vehicleSell()
	if not instanceof(source, PermanentVehicle, true) then return end
	if source:getOwner() ~= client:getId() then	return end

	-- Search for price in vehicle shops table
	local getPrice = function(model)
		for shopId, shop in pairs(ShopManager.VehicleShopsMap) do
			if shop:getVehiclePrice(model) then
				return shop:getVehiclePrice(model)
			end
		end
		return false
	end

	local price = getPrice(source:getModel())
	if price then
		source:purge()
		client:giveMoney(math.floor(price * 0.75), "Fahrzeug-Verkauf")

		self:Event_vehicleRequestInfo()
	else
		client:sendError("Beim verkauf dieses Fahrzeuges ist ein Fehler aufgetreten!")
	end
end

function VehicleManager:Event_vehicleRequestInfo()
	local vehicles = {}
	for k, vehicle in pairs(self:getPlayerVehicles(client)) do
		vehicles[vehicle:getId()] = {vehicle, vehicle:getPositionType()}
	end

	client:triggerEvent("vehicleRetrieveInfo", vehicles, client:getGarageType(), client:getHangarType())
end

function VehicleManager:Event_vehicleUpgradeGarage()
	local currentGarage = client:getGarageType()
	if currentGarage >= 0 then
		local price = GARAGE_UPGRADES_COSTS[currentGarage + 1]
		if price then
			if client:getMoney() >= price then
				client:takeMoney(price, "Garagen-Upgrade")
				client:setGarageType(currentGarage + 1)

				client:triggerEvent("vehicleRetrieveInfo", false, client:getGarageType(), client:getHangarType())
			else
				client:sendError(_("Du hast nicht genügend Geld, um deine Garage zu upgraden", client))
			end
		else
			client:sendError(_("Deine Garage ist bereits auf dem höchsten Level", client))
		end
	else
		client:sendError(_("Du besitzt keine gültige Garage!", client))
	end
end

function VehicleManager:Event_vehicleUpgradeHangar()
	local currentHangar = client:getHangarType()
	if currentHangar >= 0 then
		local price = HANGAR_UPGRADES_COSTS[currentHangar + 1]
		if price then
			if client:getMoney() >= price then
				client:takeMoney(price, "Hangar-Upgrade")
				client:setHangarType(currentHangar + 1)

				client:triggerEvent("vehicleRetrieveInfo", false, client:getGarageType(), client:getHangarType())
			else
				client:sendError(_("Du hast nicht genügend Geld, um dein Hangar zu upgraden", client))
			end
		else
			client:sendError(_("Deine Hangar ist bereits auf dem höchsten Level", client))
		end
	else
		client:sendError(_("Du besitzt keinen gültigen Hangar!", client))
	end
end

function VehicleManager:Event_vehicleHotwire()
	if client:getInventory():hasItem(ITEM_HOTWIREKIT) then
		if source:isBroken() then
			client:sendError(_("Dieses Fahrzeug ist kaputt und kann nicht kurzgeschlossen werden!", client))
			return
		end
		client:sendInfoTimeout(_("Schließe kurz...", client), 20000)
		client:reportCrime(Crime.Hotwire)
		client:giveKarma(-0.1)

		setTimer(
			function(source)
				if isElement(source) then
					source:setEngineState(true)
				end
			end, 20000, 1, source
		)
	else
		client:sendWarning(_("Hierfür brauchst du ein Kurzschließkit!", client))
	end
end

function VehicleManager:Event_vehicleEmpty()
	if source:hasKey(client) or client:getRank() >= RANK.Moderator then
		for seat, occupant in pairs(getVehicleOccupants(source) or {}) do
			if seat ~= 0 then
				removePedFromVehicle(occupant)
			end
		end
		client:sendShortMessage(_("Mitfahrer wurden herausgeworfen!", client))
	else
		client:sendError(_("Hierzu hast du keine Berechtigungen!", client))
	end
end

function VehicleManager:Event_vehicleSyncMileage(diff)
	if diff < -0.001 then
		AntiCheat:getSingleton():report(client, "Sent invalid mileage", CheatSeverity.Middle)
		return
	end

	local vehicle = client:getOccupiedVehicle()
	if vehicle then
		vehicle:setMileage(vehicle:getMileage() + diff)
	end
end

function VehicleManager:Event_vehicleBreak()
	self:checkVehicle(source)
	outputDebug("Vehicle has been broken by "..client:getName())
	-- TODO: The following behavior is pretty bad in terms of security, so fix it asap (without breaking its behavior)
	source:setBroken(true)


end
