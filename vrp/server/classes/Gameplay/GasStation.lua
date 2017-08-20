-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
GasStation = inherit(Object)
GasStation.Map = {}

function GasStation:constructor(stations, accessible, name)
	self.m_Stations = {}
	self.m_Accessible = accessible
	self.m_Name = name

	for _, station in pairs(stations) do
		local position, rotation, maxHoses = unpack(station)
		local object = createObject(1676, position, 0,0, rotation)

		self.m_Stations[object] = {maxHoses = maxHoses, players = {}}
		GasStation.Map[object] = self

		if self.m_Name then
			object:setData("Name", self.m_Name, true)
		end
	end
end

function GasStation:destructor()
end

function GasStation:addShopRef(shop)
	self.m_Shop = shop
end

function GasStation:getShop()
	return self.m_Shop
end

function GasStation:getName()
	return self.m_Name
end

function GasStation:hasPlayerAccess(player)
	if self.m_Accessible[1] == 0 then return true end

	if self.m_Accessible[1] == 1 then
		if self.m_Accessible[2] == 0 and player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
			return true
		end

		if player:getFaction() and player:getFaction():getId() == self.m_Accessible[2] and (player:getFaction():isEvilFaction() or player:isFactionDuty()) then
			return true
		end
	elseif self.m_Accessible[1] == 2 then
		if player:getCompany() and player:getCompany():getId() == self.m_Accessible[2] and player:isCompanyDuty() then
			return true
		end
	end
end

function GasStation:takeFuelNozzle(player, element)
	if not self:hasPlayerAccess(player) then
		player:sendError("Du bist nicht berechtigt diese Tankstelle zu nutzen!")
		return
	end

	if table.size(self.m_Stations[element].players) >= self.m_Stations[element].maxHoses then
		player:sendError("Diese Zapfsäule ist bereits belegt!")
		return
	end

	player.gs_fuelNozzle = createObject(1909, player.position)
	player.gs_fuelNozzle:setData("attachedGasStation", element, true)
	player.gs_fuelNozzle:setData("attachedPlayer", player, true)
	client:setPrivateSync("hasGasStationFuelNozzle", true)
	player.gs_usingFuelStation = element

	exports.bone_attach:attachElementToBone(player.gs_fuelNozzle, player, 12, -0.03, 0.02, 0.05, 180, 320, 0)
	toggleControl(player, "fire", false)

	self.m_Stations[element].players[player] = true
end

function GasStation:rejectFuelNozzle(player, element)
	self.m_Stations[element].players[player] = nil

	player:setPrivateSync("hasGasStationFuelNozzle", false)
	player:triggerEvent("forceCloseVehicleFuel")
	player.gs_usingFuelStation = nil
	player.gs_fuelNozzle:destroy()
	toggleControl(player, "fire", true)
end
