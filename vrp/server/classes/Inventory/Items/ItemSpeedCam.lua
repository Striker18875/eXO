-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemSpeedCam.lua
-- *  PURPOSE:     Speed Cam item class
-- *
-- ****************************************************************************
ItemSpeedCam = inherit(Item)
ItemSpeedCam.Map = {}

local MAX_SPEEDCAMS = 3


function ItemSpeedCam:constructor()

end

function ItemSpeedCam:destructor()

end

function ItemSpeedCam:use(player)
	if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
		if self:count() < MAX_SPEEDCAMS then
			local result = self:startObjectPlacing(player,
				function(item, position, rotation)
					if item ~= self then return end
					if (position - player:getPosition()).length > 20 then
						player:sendError(_("Du musst in der Nähe der Zielposition sein!", player))
						return
					end

					local worldItem = self:place(player, position, rotation)

					player:getInventory():removeItem(self:getName(), 1)

					local object = worldItem:getObject()
					setElementData(object, "earning", 0)
					ItemSpeedCam.Map[#ItemSpeedCam.Map+1] = object

					object.col = createColSphere(position, 8)
					object.col.object = object
					addEventHandler("onColShapeHit", object.col, bind(self.onColShapeHit, self))
					local pos = player:getPosition()
					FactionState:getSingleton():sendShortMessage(_("%s hat einen Radar bei %s/%s aufgestellt!", player, player:getName(), getZoneName(pos), getZoneName(pos, true)))

				end
			)
		else
			player:sendError(_("Es sind bereits %d/%d Anlagen aufgestellt!", player, self:count(), MAX_SPEEDCAMS))
		end
	else
		player:sendError(_("Du bist nicht berechtigt! Das Item wurde abgenommen!", player))
		player:getInventory():removeItem(self:getName(), 1)
	end
end

function ItemSpeedCam:count()
	local count = 0
	for index, cam in pairs(ItemSpeedCam.Map) do
		count = count + 1
	end
	return count
end

function ItemSpeedCam:onColShapeHit(element, dim)
  if dim then
    if element:getType() == "vehicle" then
		if element:getSpeed() > 85 then
			if element:getOccupant() then
				local player = element:getOccupant()

				if player:isFactionDuty() then return end

				local speed = math.floor(element:getSpeed())
				local costs = (speed-80)*50
				player:takeBankMoney(costs, "Blitzer-Strafe")
				FactionManager:getSingleton():getFromId(1):giveMoney(costs, "Blitzer-Strafe")
      			player:sendShortMessage(_("Du wurdest mit %d km/H geblitzt!\nStrafe: %d$", player, speed, costs), "SA Police Department")

				setElementData(source.object, "earning", getElementData(source.object, "earning") + costs)
			end
		end
    end
  end
end

function ItemSpeedCam:onClick(player, worldItem)
	if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
		triggerClientEvent(player, "ItemSpeedCamMenu", worldItem:getObject())
	else
		player:sendError(_("Du hast keine Befugnisse dieses Item zu nutzen!", player))
	end
end

function ItemSpeedCam:isCollectAllowed(player, worlditem)
	if player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
		return true
	end
	return false
end

function ItemSpeedCam:removeFromWorld(player, worlditem)
	player:sendInfo(_("Du hast den Blitzer abgebaut!", player))
end
