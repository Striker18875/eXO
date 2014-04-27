-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/TemporaryVehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
TemporaryVehicle = inherit(Vehicle)

function TemporaryVehicle:constructor()
end

function TemporaryVehicle:destructor()
end

function TemporaryVehicle.create(model, posX, posY, posZ, rotation)
	rotation = tonumber(rotation) or 0
	local vehicle = createVehicle(model, posX, posY, posZ, 0, 0, rotation)
	enew(vehicle, TemporaryVehicle)
	return vehicle
end

function TemporaryVehicle:isPermanent()
	return false
end

function TemporaryVehicle:respawn()
	-- Remove
	destroyElement(self)
end
