-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDSpeedo.lua
-- *  PURPOSE:     HUD speedometer class
-- *
-- ****************************************************************************
HUDSpeedo = inherit(Singleton)

function HUDSpeedo:constructor()
	self.m_Size = 256
	self.m_FuelSize = 128
	self.m_Draw = bind(self.draw, self)
	self.m_Fuel = 100

	-- Add event handlers
	addEventHandler("onClientPlayerVehicleEnter", localPlayer,
		function(vehicle, seat)
			if seat == 0 then
				if VEHICLE_BIKES[vehicle:getModel()] then
					ShortMessage:new(_"Öffne das Fahrradschloss mit 'X'!")
				else
					self:show()
				end
			end
		end
	)
	addEventHandler("onClientPlayerVehicleExit", localPlayer,
		function(vehicle, seat)
			if seat == 0 then
				if not VEHICLE_BIKES[vehicle:getModel()] then
					self:hide()
				end
			end
		end
	)
	addEvent("vehicleFuelSync", true)
	addEventHandler("vehicleFuelSync", root,
		function(fuel)
			self.m_Fuel = fuel
		end
	)
end

function HUDSpeedo:show()
	addEventHandler("onClientRender", root, self.m_Draw, true, "high+10")
end

function HUDSpeedo:hide()
	removeEventHandler("onClientRender", root, self.m_Draw)
end

function HUDSpeedo:draw()
	if not isPedInVehicle(localPlayer) then
		self:hide()
		return
	end

	local vehicle = getPedOccupiedVehicle(localPlayer)
	local vehicleType = getVehicleType(vehicle)
	local handbrake = getElementData( vehicle, "Handbrake" )
	if not vehicle:getFuel() then return end
	local vx, vy, vz = getElementVelocity(vehicle)
	local speed = (vx^2 + vy^2 + vz^2) ^ 0.5 * 161
	local drawX, drawY = screenWidth - self.m_Size, screenHeight - self.m_Size - 10

	-- Set maximum
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter then
		if speed > 240 then
			speed = 240
		end
	else
		if speed > 220 then
			speed = 220
		end
	end

	--dxSetBlendMode("add")
	-- draw the main speedo
	if vehicleType ~= VehicleType.Plane and vehicleType ~= VehicleType.Helicopter then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main.png", 0, 0, 0, tocolor(255, 255, 255, 150))
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main_needle.png", speed * 270/240)
	else
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main_aviation.png", 0, 0, 0, tocolor(255, 255, 255, 150))
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main_needle.png", speed * 270/240)
	end
	-- draw the gear level
	--dxDrawText(getVehicleCurrentGear(vehicle), drawX+158, drawY+108, 20, 20, tocolor(255, 255, 255), 2.5, "default")

	-- draw the engine icon
	if getVehicleEngineState(vehicle) then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/engine.png", 0, 0, 0, Color.Green)
	elseif vehicle.EngineStart then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/engine.png")
	end

	if handbrake or getControlState("handbrake") or vehicle:isFrozen() then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/handbrake.png")
	end

	-- draw the fuel-o-meter
	dxDrawImage(drawX-100, drawY+115, self.m_FuelSize, self.m_FuelSize, "files/images/Speedo/fuel.png", 0, 0, 0, tocolor(255, 255, 255, 150))
	dxDrawImage(drawX-100, drawY+115, self.m_FuelSize, self.m_FuelSize, "files/images/Speedo/fuel_needle.png", self.m_Fuel * 180/100)
	--dxSetBlendMode("blend")
end
