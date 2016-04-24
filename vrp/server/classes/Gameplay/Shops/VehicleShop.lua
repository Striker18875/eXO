-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/Shop.lua
-- *  PURPOSE:     Shop Super Class
-- *
-- ****************************************************************************
VehicleShop = inherit(Object)

function VehicleShop:constructor(id, name, marker, npc, spawn, image, owner, price, money)
	self.m_Id = id
	self.m_Name = name
	self.m_Image = image
	self.m_BuyAble = price > 0 and true or false
	self.m_OwnerId = owner
	self.m_Money = money

	self.m_Vehicles = {}

	local markerPos = split(marker,",")
	self.m_Marker = createMarker(markerPos[1], markerPos[2], markerPos[3]+0.5, "cylinder", 1, 255, 255, 0, 200)
	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onMarkerHit, self))
	self.m_Blip = Blip:new("CarShop.png", markerPos[1], markerPos[2])
	local npcData = split(npc,",")
	self.m_NPC = createPed(npcData[1], npcData[2], npcData[3], npcData[4], npcData[5])
	local spawnPos = split(spawn,",")
	self.m_Spawn = {spawnPos[1], spawnPos[2], spawnPos[3], spawnPos[4]}
end

function VehicleShop:getName()
	return self.m_Name
end

function VehicleShop:onMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		local vehicles = {}
		for index, vehicle in pairs(self.m_Vehicles) do
			vehicles[index] = {vehicle, vehicle.price, vehicle.level}
		end
		hitElement:triggerEvent("showVehicleShopMenu", self.m_Id, self.m_Name, self.m_Image, vehicles)
	end
end

function VehicleShop:buyVehicle(player, vehicleModel)
	local price, requiredLevel = self.m_Vehicles[vehicleModel].price, self.m_Vehicles[vehicleModel].level
	if not price then return end

	if player:getVehicleLevel() < requiredLevel then
		player:sendError(_("Für dieses Fahrzeug brauchst du min. Fahrzeuglevel %d", player, requiredLevel))
		return
	end

	if player:getMoney() < price then
		player:sendError(_("Du hast nicht genügend Geld!", player), 255, 0, 0)
		return
	end

	local spawnX, spawnY, spawnZ, rotation = unpack(self.m_Spawn)
	local vehicle = PermanentVehicle.create(player, vehicleModel, spawnX, spawnY, spawnZ, rotation)
	if vehicle then
		player:takeMoney(price)
		self:giveMoney(price)
		warpPedIntoVehicle(player, vehicle)
		player:triggerEvent("vehicleBought")
	else
		player:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin!", player), 255, 0, 0)
	end
end

function VehicleShop:giveMoney(amount, reason)
	if amount > 0 then self.m_Money = self.m_Money + amount end
end

function VehicleShop:takeMoney(amount, reason)
	if amount > 0 then self.m_Money = self.m_Money - amount end
end

function VehicleShop:getMoney()
	return self.m_Money
end

function VehicleShop:addVehicle(Id, Model, Name, Category, Price, Level, Pos, Rot)
	self.m_Vehicles[Model] = createVehicle(Model, Pos, Rot)
	self.m_Vehicles[Model].price = Price
	self.m_Vehicles[Model].level = Level
	local veh = self.m_Vehicles[Model]
	veh:setLocked(true)
	veh:setFrozen(true)
	veh:setColor(math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255))
end

function VehicleShop:save()
	if sql:queryExec("UPDATE ??_vehicle_shops SET Money = ?, Owner = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_Owner, self.m_Id) then
	else
		outputDebug(("Failed to save Vehicle-Shop '%s' (Id: %d)"):format(self.m_Name, self.m_Id))
	end
end
