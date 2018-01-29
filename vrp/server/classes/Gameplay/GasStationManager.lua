-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/GasStationManager.lua
-- *  PURPOSE:     Gas Station Manager
-- *
-- ****************************************************************************
GasStationManager = inherit(Singleton)
GasStationManager.Shops = {}
addRemoteEvents{"gasStationTakeFuelNozzle", "gasStationRejectFuelNozzle", "gasStationStartTransaction", "gasStationConfirmTransaction", "gasStationRepairVehicle"}

GAS_STATION_SHOP_PLAYER_PAYMENT = 20
GAS_STATION_SHOP_FCT_CMP_PAYMENT = 10

function GasStationManager:constructor()
	self.m_PendingTransaction = {}

	for _, station in pairs(GAS_STATIONS) do
		local instance = GasStation:new(station.stations, station.accessible, station.name, station.nonInterior, station.serviceStation, station.fuelTypes)

		if station.name then
			GasStationManager.Shops[station.name] = instance
		end
	end

	PlayerManager:getSingleton():getQuitHook():register(bind(self.onPlayerQuit, self))
	self.m_BankAccountServer = BankServer.get("vehicle.gasstation")

	addEventHandler("gasStationTakeFuelNozzle", root, bind(GasStationManager.takeFuelNozzle, self))
	addEventHandler("gasStationRejectFuelNozzle", root, bind(GasStationManager.rejectFuelNozzle, self))
	--addEventHandler("gasStationStartTransaction", root, bind(GasStationManager.startTransaction, self))
	addEventHandler("gasStationConfirmTransaction", root, bind(GasStationManager.confirmTransaction, self))
	addEventHandler("gasStationRepairVehicle", root, bind(GasStationManager.serviceStationRepairVehicle, self))
end

function GasStationManager:destructor()
end

function GasStationManager:onPlayerQuit(player)
	if isElement(player.gs_fuelNozzle) then
		local element = player.gs_fuelNozzle:getData("attachedGasStation")
		if GasStation.Map[element] then
			GasStation.Map[element]:rejectFuelNozzle(player, element)
		end
	end
end

function GasStationManager:takeFuelNozzle(element, fuelType)
	if GasStation.Map[element] then
		if isElement(client.gs_fuelNozzle) then
			GasStation.Map[element]:rejectFuelNozzle(client, element)
			return
		end

		GasStation.Map[element]:takeFuelNozzle(client, element, fuelType)
	end
end

function GasStationManager:rejectFuelNozzle()
	local element = client.gs_usingFuelStation

	if GasStation.Map[element] then
		if isElement(client.gs_fuelNozzle) then
			GasStation.Map[element]:rejectFuelNozzle(client, element)
		end
	end
end

--[[function GasStationManager:startTransaction(vehicle, fuel, station)
	if GasStation.Map[station] then
		self.m_PendingTransaction[client] = {station = station, vehicle = vehicle, fuel = math.round(fuel)}
	end
end]]
function GasStationManager:confirmTransaction(vehicle, fuel, station, opticalFuel, price)
	local station = GasStation.Map[station]
	if station then
		if instanceof(vehicle, PermanentVehicle, true) or instanceof(vehicle, GroupVehicle, true) or instanceof(vehicle, FactionVehicle, true) or instanceof(vehicle, CompanyVehicle, true) then
			local fuel = vehicle:getFuel() + fuel > 100 and 100 - vehicle:getFuel() or fuel
			if fuel == 0 then
				client:sendError("Dein Fahrzeug ist bereits vollgetankt!")
				return
			end
			local price = math.round(price)
			if station:isUserFuelStation() then
				local playedPayed = false
				local faction = client:getFaction()
				local company = client:getCompany()
				if faction and (faction:isEvilFaction() or client:isFactionDuty()) and instanceof(vehicle, FactionVehicle, true) then
					if faction:getMoney() >= price then
						client:sendInfo(_("Das Fahrzeug wurde getankt!", client))
						faction:transferMoney(self.m_BankAccountServer, price, "Tanken", "Vehicle", "Refill")
						faction:addLog(client, "Tanken", ("hat das Fahrzeug %s (%s) für %s$ betankt!"):format(vehicle:getName(), vehicle:getPlateText(), price))
						vehicle:setFuel(vehicle:getFuel() + fuel)

						client:triggerEvent("gasStationReset")
					else
						client:sendError("In der Fraktionskasse ist nicht genug Geld!")
						return
					end
				elseif company and client:isCompanyDuty() and instanceof(vehicle, CompanyVehicle, true) then
					if company:getMoney() >= price then
						company:transferMoney(self.m_BankAccountServer, price, "Tanken", "Vehicle", "Refill")
						client:sendInfo(_("Das Fahrzeug wurde getankt!", client))
						company:addLog(client, "Tanken", ("hat das Fahrzeug %s (%s) für %s$ betankt!"):format(vehicle:getName(), vehicle:getPlateText(), price))
						vehicle:setFuel(vehicle:getFuel() + fuel)

						client:triggerEvent("gasStationReset")
					else
						client:sendError("In der Unternehmenskasse ist nicht genug Geld!")
						return
					end
				elseif client:getMoney() >= price then
					playedPayed = true
					client:transferMoney(self.m_BankAccountServer, price, "Tanken", "Vehicle", "Refill")
					vehicle:setFuel(vehicle:getFuel() + fuel)

					client:triggerEvent("gasStationReset")
				else
					client:sendError("Du hast nicht genügend Geld dabei!")
					return
				end

				if station:getShop() then
					local shopMoney = price * GAS_STATION_SHOP_PLAYER_PAYMENT / 100
					if not playedPayed then
						shopMoney = price * GAS_STATION_SHOP_FCT_CMP_PAYMENT / 100
					end
					client:sendInfo(_("%s bedankt sich für deinen Einkauf!", client, station:getName()))
					self.m_BankAccountServer:transferMoney(station:getShop().m_BankAccount, shopMoney, "Betankung", "Vehicle", "Refill")
				end
			elseif station:isFactionFuelStation() then
				if not instanceof(vehicle, FactionVehicle, true) then client:sendWarning("Dieses Fahrzeug darf hier nicht getankt werden!") return end

				if station:hasPlayerAccess(client) then
					local faction = client:getFaction()
					if faction:getMoney() >= price then
						client:sendInfo(_("Das Fahrzeug wurde getankt!", client))
						faction:transferMoney(self.m_BankAccountServer, price, "Tanken", "Vehicle", "Refill")
						faction:addLog(client, "Tanken", ("hat das Fahrzeug %s (%s) für %s$ betankt!"):format(vehicle:getName(), vehicle:getPlateText(), price))
						vehicle:setFuel(vehicle:getFuel() + fuel)

						client:triggerEvent("gasStationReset")
					end
				end
			elseif station:isCompanyFuelStation() then
				if not instanceof(vehicle, CompanyVehicle, true) then client:sendWarning("Dieses Fahrzeug darf hier nicht getankt werden!") return end

				if station:hasPlayerAccess(client) then
					local company = client:getCompany()
					if company:getMoney() >= price then
						client:sendInfo(_("Das Fahrzeug wurde getankt!", client))
						company:transferMoney(self.m_BankAccountServer, price, "Tanken", "Vehicle", "Refill")
						company:addLog(client, "Tanken", ("hat das Fahrzeug %s (%s) für %s$ betankt!"):format(vehicle:getName(), vehicle:getPlateText(), price))
						vehicle:setFuel(vehicle:getFuel() + fuel)
						client:triggerEvent("gasStationReset")
					end
				end
			end
		end
	end
end

function GasStationManager:serviceStationRepairVehicle(element)
	if GasStation.Map[element] and GasStation.Map[element]:hasPlayerAccess(client) then
		if not client.vehicle then return end

		if (client.vehicle.position - element.position).length > 10 then
			client:sendError(_("Du bist zu weit entfernt!", client))
			return
		end

		local price = math.floor(client.vehicle:getMaxHealth() - client.vehicle:getHealth()) * SERVICE_REPAIR_PRICE_MULTIPLICATOR

		client.vehicle:fix()
		client:getFaction():transferMoney(self.m_BankAccountServer, price, "Fahrzeug-Reparatur", "Vehicle", "Repair")
	end
end

-- accessible: {type, id} || type: 0 = all, 1 = faction, 2 = company || id = faction or company id (0 == state faction)
GAS_STATIONS = {
	{
		name = "Tankstelle Temple",
		stations = {
			{Vector3(1000.23, -937.42, 42.86), 8, 2},
			{Vector3(1006.91, -936.43, 42.86), 8, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "San Fierro Downtown",
		stations = {
			{Vector3(-1676.68, 419.11, 7.90), 223, 2},
			{Vector3(-1681.68, 413.94, 7.90), 223, 2},
			{Vector3(-1675.17, 407.36, 7.90), 223, 2},
			{Vector3(-1669.84, 412.59, 7.90), 223, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "San Fierro Juniper Hill",
		stations = {
			{Vector3(-2410.8994, 972, 46), 90, 2},
			{Vector3(-2410.8994, 979, 46), 90, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Angle Pine",
		stations = {
			{Vector3(-2246.67, -2559.59, 32.6), 243, 1},
			{Vector3(-2241.68, -2562.21, 32.6), 243, 1},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Tankstelle Dillimore",
		stations = {
			{Vector3(655.68, -569.92, 16.6), 90, 2},
			{Vector3(655.68, -559.91, 16.6), 90, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Tankstelle Flint County",
		stations = {
			{Vector3(-85.41, -1165.00, 2.9), 65, 2},
			{Vector3(-90.01, -1175.99, 2.81), 65, 2},
			{Vector3(-92.22, -1162.38, 3), 65, 2},
			{Vector3(-96.84, -1173.24, 3), 65, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "The Emerald Isle",
		stations = {
			{Vector3(2196.89, 2480, 11.5), 90, 2},
			{Vector3(2196.89, 2475, 11.5), 90, 2},
			{Vector3(2196.89, 2469.8, 11.5), 90, 2},
			{Vector3(2207.69, 2469.8, 11.5), 90, 2},
			{Vector3(2207.69, 2475, 11.5), 90, 2},
			{Vector3(2207.69, 2480, 11.5), 90, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Red Sands West",
		stations = {
			{Vector3(1596.2, 2193.7, 11.5), 0, 2},
			{Vector3(1596.1, 2204.5, 11.5), 0, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Spinybed",
		stations = {
			{Vector3(2147.64, 2753.28, 11.4), 0, 2},
			{Vector3(2147.63, 2742.5, 11.4), 0, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Las Venturas 2",
		stations = {
			{Vector3(2114.80, 925.53, 11.45), 0, 2},
			{Vector3(2114.8999, 914.72, 11.45), 0, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Valle Ocultado",
		stations = {
			{Vector3(-740.41, 2753.35, 47.7), 90, 1},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Tierra Roboda 2",
		stations = {
			{Vector3(-1328.1, 2680.2, 51), 354, 1},
			{Vector3(-1328.84, 2674.84, 51), 354, 1},
			{Vector3(-1327.72, 2685.76, 51), 354, 1},
			{Vector3(-1329.68, 2669.25, 51), 354, 1},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Idlewood",
		stations = {
			{Vector3(1941.7, -1776.6, 14.17), 90, 2},
			{Vector3(1941.7, -1769.4, 14.17), 90, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Fort Carson",
		stations = {
			{Vector3(68.1, 1221.3, 19.6), 252, 1},
			{Vector3(73.80, 1219.45, 19.6), 252, 1},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Whetstone",
		stations = {
			{Vector3(-1611.35, -2720.47, 49.4), 324, 1},
			{Vector3(-1607.80, -2716.16, 49.4), 324, 1},
			{Vector3(-1604.70, -2711.75, 49.4), 324, 1},
			{Vector3(-1601.41, -2707.17, 49.4), 324, 1},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Last Venturas East",
		stations = {
			{Vector3(2639.9, 1100.9, 11.5), 0, 2},
			{Vector3(2639.9, 1111.83, 11.5), 0, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Montgomery",
		stations = {
			{Vector3(1379.81, 460.5, 20.8), 155.5, 2},
			{Vector3(1384.36, 458.6, 20.8), 155.5, 2},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Bone County",
		stations = {
			{Vector3(624.06, 1677.63, 7.7), 35.5, 1},
			{Vector3(620.85, 1682.64, 7.7), 35.5, 1},
			{Vector3(617.42, 1687.44, 7.7), 35.5, 1},
			{Vector3(613.90, 1692.40, 7.7), 35.5, 1},
			{Vector3(610.33, 1697.42, 7.7), 35.5, 1},
			{Vector3(606.91, 1702.24, 7.7), 35.5, 1},
			{Vector3(603.53, 1707, 7.7), 35.5, 1},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "Tierra Roboda 1",
		stations = {
			{Vector3(-1465.5, 1868.2, 33.3), 3.24, 1},
			{Vector3(-1464.78, 1860.43, 33.3), 3.24, 1},
			{Vector3(-1477.91, 1859.74, 33.3), 3.24, 1},
			{Vector3(-1478.72, 1867.25, 33.3), 3.24, 1},
		},
		accessible =  {0, 0},
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	{
		name = "LS-Airport Tankstelle",
		stations = {
			{Vector3(1606.10, -2445.5, 14.1), 0, 1}
		},
		accessible = {0, 0},
		fuelTypes = {"petrol_plus", "jetfuel"},
	},
	{
		name = "Tankstelle Ocean Docks",
		stations = {
			{Vector3(2370.29, -2557.2, 2.5), 90, 1}
		},
		accessible = {0, 0},
		nonInterior = true,
		fuelTypes = {"diesel"},

	},
	-- Company fuelstations
	{
		name = "M&T",
		stations = {
			{Vector3(877, -1184.6, 17.8), 90, 1},
		},
		accessible =  {2, CompanyStaticId.MECHANIC},
		nonInterior = true,
		fuelTypes = {"petrol", "diesel", "petrol_plus"},
	},
	-- Faction fuelstations
	{
		name = "Staat Service Station",
		stations = {
			{Vector3(1564.10, -1616.77, 13.96), 0, 1}, -- LSPD #1
			{Vector3(1552.89, -1616.77, 13.96), 0, 1}, -- LSPD #2
			{Vector3(2292.8, 2461, 4), 90, 1}, -- LVT
			{Vector3(127, 1908, 19.3), 90, 1}, -- Area
			{Vector3(-1622.8, 664.8, -4.5), 0, 1}, -- SFPD
			{Vector3(-1526, 458.1, 7.6), 90, 1}, -- SF Army
			{Vector3(1209.800, -1824.200, 14.075), 0, 1}, -- FBI
		},
		accessible =  {1, 0},
		nonInterior = true,
		serviceStation = true,
		fuelTypes = {"petrol", "diesel"},
	},
	{
		name = "Rescue Service Station",
		stations = {
			{Vector3(1798.14, -1743.11, 6.8), 180, 1}, -- Rescue #1
			{Vector3(1713.32, -1780.45, 14.08), 0, 1}, -- Rescue #2
		},
		accessible =  {1, FactionStaticId.RESCUE},
		nonInterior = true,
		serviceStation = true,
		fuelTypes = {"petrol", "diesel"},
	},
}
