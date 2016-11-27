-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/CompanyVehicle.lua
-- *  PURPOSE:     Company Vehicle class
-- *
-- ****************************************************************************
CompanyVehicle = inherit(PermanentVehicle)

-- This function converts a normal (User/PermanentVehicle) to an CompanyVehicle
function CompanyVehicle.convertVehicle(vehicle, Company)
	if vehicle:isPermanent() then
		if not vehicle:isInGarage() then
			local position = vehicle:getPosition()
			local rotation = vehicle:getRotation()
			local model = vehicle:getModel()
			local health = vehicle:getHealth()
			local r, g, b = getVehicleColor(vehicle, true)
			local tunings = false
			if Company:canVehiclesBeModified() then
				tunings = getVehicleUpgrades(vehicle) or {}
			end

			if vehicle:purge() then
				local vehicle = CompanyVehicle.create(Company, model, position.x, position.y, position.z, rotation)
				vehicle:setHealth(health)
				vehicle:setColor(r, g, b)
				if Company:canVehiclesBeModified() then
					for k, v in pairs(tunings or {}) do
						addVehicleUpgrade(vehicle, v)
					end
				end
				return vehicle:save()
			end
		end
	end

	return false
end

function CompanyVehicle:constructor(Id, company, color, health, posionType, tunings, mileage)
  self.m_Id = Id
  self.m_Company = company
  self.m_PositionType = positionType or VehiclePositionType.World
  self.m_Position = self:getPosition()
  self.m_Rotation = self:getRotation()
  setElementData(self, "OwnerName", self.m_Company:getName())
  setElementData(self, "OwnerType", "company")

  self:setHealth(health)
  self:setLocked(true)

  local a, r, g, b
  if color and color > 0 then
  	a, r, g, b = getBytesInInt32(color)
  else
  	local companyId = self.m_Company:getId()
	r, g, b = companyColors[companyId]["r"], companyColors[companyId]["g"], companyColors[companyId]["b"]
  end
  setVehicleColor(self, r, g, b, r, g, b)

  for k, v in pairs(tunings or {}) do
    addVehicleUpgrade(self, v)
  end

  if self.m_PositionType ~= VehiclePositionType.World then
    -- Move to unused dimension | Todo: That's probably a bad solution
    setElementDimension(self, PRIVATE_DIMENSION_SERVER)
  end
  self:setMileage(mileage)

	if self.m_Company.m_Vehicles then
		table.insert(self.m_Company.m_Vehicles, self)
	end

	addEventHandler("onVehicleEnter",self, bind(self.onEnter, self))
	addEventHandler("onVehicleExit",self, bind(self.onExit, self))

	addEventHandler("onVehicleStartEnter",self, bind(self.onStartEnter, self))
end

function CompanyVehicle:destructor()

end

function CompanyVehicle:getId()
	return self.m_Id
end

function CompanyVehicle:getCompany()
  return self.m_Company
end

function CompanyVehicle:onStartEnter(player,seat)
	if seat == 0 then
		if player:getCompany() == self.m_Company or (self:getCompany():getId() == 1 and player:getPublicSync("inDrivingLession") == true) then

		else
			cancelEvent()
			player:sendError(_("Du darfst dieses Fahrzeug nicht benutzen!", player))
		end
	else
		if self:getCompany():getId() == 4 then
			self:getCompany():onVehiceStartEnter(source, player, seat)
		end
	end
end

function CompanyVehicle:onEnter(player, seat)
	if self:getCompany():getId() == 4 then
		self:getCompany():onVehiceEnter(source, player, seat)
	end
end

function CompanyVehicle:onExit(player, seat)
	if self:getCompany():getId() == 4 then
		self:getCompany():onVehiceExit(source, player, seat)
	end
end


function CompanyVehicle:create(Company, model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	if sql:queryExec("INSERT INTO ??_company_vehicles (Company, Model, PosX, PosY, PosZ, Rotation, Health) VALUES(?, ?, ?, ?, ?, ?, 1000)", sql:getPrefix(), Company:getId(), model, posX, posY, posZ, rotation) then
		local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
		enew(vehicle, CompanyVehicle, sql:lastInsertId(), Company, nil, 1000)
    VehicleManager:getSingleton():addRef(vehicle)
		return vehicle
	end
	return false
end

function CompanyVehicle:purge()
	if sql:queryExec("DELETE FROM ??_company_vehicles WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		VehicleManager:getSingleton():removeRef(self)
		destroyElement(self)
		return true
	end
	return false
end

function CompanyVehicle:save()
	local tunings = getVehicleUpgrades(self) or {}

	return sql:queryExec("UPDATE ??_company_vehicles SET Company = ?, Tunings = ?, Mileage = ? WHERE Id = ?", sql:getPrefix(),
		self.m_Company:getId(), toJSON(tunings), self:getMileage(), self.m_Id)
end

function CompanyVehicle:hasKey(player)
  if self:isPermanent() then
    if player:getCompany() == self:getCompany() then
      return true
    end
  end

  return false
end

function CompanyVehicle:addKey(player)
  return false
end

function CompanyVehicle:removeKey(player)
  return false
end

function CompanyVehicle:canBeModified()
  return self:getCompany():canVehiclesBeModified()
end

function CompanyVehicle:respawn()
	if self:getHealth() <= 310 and not force then
		self:getFaction():sendShortMessage("Fahrzeug-respawn ["..self.getNameFromModel(self:getModel()).."] ist fehlgeschlagen!\nFahrzeug muss zuerst repariert werden!")
		return false
	end

	-- Teleport to Spawnlocation
	self.m_LastUseTime = math.huge

	if self:getOccupants() then -- For Trailers
		for _, player in pairs(self:getOccupants()) do
			return false
		end
	end

	self:setEngineState(false)
	self:setPosition(self.m_Position)
	self:setRotation(self.m_Rotation)
	self:fix()

	return true
end
