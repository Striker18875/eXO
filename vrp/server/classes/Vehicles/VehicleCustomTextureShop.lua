-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleCustomTextureShop.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleCustomTextureShop = inherit(Singleton)
addEvent("vehicleCustomTextureBuy", true)
addEvent("vehicleCustomTextureAbbort", true)

function VehicleCustomTextureShop:constructor()
	self.m_Path = "http://picupload.pewx.de/textures/"

	self.m_GarageInfo = {
        -- Entrance - Exit (pos, rot) - Interior
        {
            Vector3(1851, -1856.4, 12.4), -- LS El Corona
            {Vector3(1839.3, -1856.7, 13.2), 90},
            Vector3(1010.9, -982.59998, 2436.1001)
        }
    }

    for garageId, info in pairs(self.m_GarageInfo) do
        local position = info[1]
        local colshape = createColSphere(position, 3)
        addEventHandler("onColShapeHit", colshape, bind(self.EntryColShape_Hit, self, garageId))

        Blip:new("TuningGarage.png", position.x, position.y,root,600)
    end

	--addEventHandler("vehicleCustomTextureBuy", root, bind(self.Event_vehicleTextureBuy, self))
    addEventHandler("vehicleCustomTextureAbbort", root, bind(self.Event_vehicleUpgradesAbort, self))
end

function VehicleCustomTextureShop:EntryColShape_Hit(garageId, hitElement, matchingDimension)
    if getElementType(hitElement) == "player" and matchingDimension then
        local vehicle = hitElement:getOccupiedVehicle()
        if not vehicle or hitElement:getOccupiedVehicleSeat() ~= 0 then return end

        if instanceof(vehicle, CompanyVehicle) then
          if not vehicle:canBeModified() then
              hitElement:sendError(_("Dieser Firmenwagen darf nicht getunt werden!", hitElement))
              return
          end
		elseif instanceof(vehicle, FactionVehicle) then
          if not vehicle:canBeModified() then
              hitElement:sendError(_("Dieser Fraktions-Wagen darf nicht getunt werden!", hitElement))
              return
          end
        elseif instanceof(vehicle, GroupVehicle) then
            if not vehicle:canBeModified() then
                hitElement:sendError(_("Dein Leader muss das Tunen von Fahrzeugen aktivieren! Im Firmen/Gangmenü unter Leader!", hitElement))
                return
            end
        elseif vehicle:isPermanent() then
            if vehicle:getOwner() ~= hitElement:getId() then
                hitElement:sendError(_("Du kannst nur deine eigenen Fahrzeuge tunen!", hitElement))
                return
            end
        else
            hitElement:sendWarning(_("Achtung! Du tunst gerade ein temporäres Fahrzeug!", hitElement))
        end

        -- Remove occupants
        for seat, player in pairs(vehicle:getOccupants() or {}) do
            if seat ~= 0 then
                player:removeFromVehicle()
            end
        end

        local vehicleType = vehicle:getVehicleType()
        if vehicleType == VehicleType.Automobile or vehicleType == VehicleType.Bike then
            self:openFor(hitElement, vehicle, garageId)
        else
            hitElement:sendError(_("Mit diesem Fahrzeugtyp kannst du die Tuningwerkstatt nicht betreten!", hitElement))
        end
    end
end

function VehicleCustomTextureShop:openFor(player, vehicle, garageId)
    player:triggerEvent("vehicleCustomTextureShopEnter", vehicle or player:getPedOccupiedVehicle(), self.m_Path, self:getTextures(player, vehicle))

    vehicle:setFrozen(true)
    player:setFrozen(true)
    local position = self.m_GarageInfo[garageId][3]
    vehicle:setPosition(position)
    setTimer(function() warpPedIntoVehicle(player, vehicle) end, 500, 1)
    player.m_VehicleTuningGarageId = garageId
end

function VehicleCustomTextureShop:closeFor(player, vehicle, doNotCallEvent)
    if not doNotCallEvent then
        player:triggerEvent("vehicleCustomTextureShopExit")
    end

    local garageId = player.m_VehicleTuningGarageId
    if garageId then
        local position, rotation = unpack(self.m_GarageInfo[garageId][2])
        if vehicle then
            vehicle:setFrozen(false)
            vehicle:setPosition(position)
            vehicle:setRotation(0, 0, rotation)
        end

        player:setPosition(position) -- Set player position also as it will not be updated automatically before quit
        player:setFrozen(false)
        player.m_VehicleTuningGarageId = nil

        -- Hackfix for MTA issue #4658
        if vehicle and getVehicleType(vehicle) == VehicleType.Bike then
            teleportPlayerNextToVehicle(player, vehicle)
            warpPedIntoVehicle(player, vehicle)
        end

    end
end

function VehicleCustomTextureShop:getTextures(player, vehicle)
	local result = sql:queryFetch("SELECT * FROM ??_textureshop", sql:getPrefix()) --DEVELOP
--	local result = sql:queryFetch("SELECT * FROM ??_textureshop WHERE Status = 1 AND Model = ? AND (UserId = ? OR Public = 1) ORDER BY Date DESC", sql:getPrefix(), vehicle:getModel(), player:getId())
    return result
end

function VehicleCustomTextureShop:Event_vehicleUpgradesAbort()
    self:closeFor(client, client:getOccupiedVehicle())
end
