-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearableHelmet.lua
-- *  PURPOSE:     Wearable Helmets
-- *
-- ****************************************************************************
WearableHelmet = inherit( Item )

WearableHelmet.objectTable = 
{
	["Helm"] = {2052, 0.05, 0.05, 1, 5, 180, "Integral-Helm"},
	["Motorcross-Helm"] = {2799, 0.09, 0.02, 0.9, 10, 180,"Motocross-Helm"},
	["Pot-Helm"] = {3911,0.1, 0, 1, 0, 180, "Biker-Helm"},
	["Gasmaske"] = {3890,0, 0.15, 0.9, 0, 90, "Gasmaske"},
}

function WearableHelmet:constructor()
	self.m_Helmets = {}
end

function WearableHelmet:destructor()

end

function WearableHelmet:use(player, itemId, bag, place, itemName)
	local inventory = InventoryManager:getSingleton():getPlayerInventory(player)
	local value = inventory:getItemValueByBag( bag, place)
	if value then --// for texture usage later
		
	end
	if not player.m_IsWearingHelmet and not player.m_Helmet then --// if the player clicks onto the helmet without currently wearing one
		if isElement(player.m_Helmet) then 
			destroyElement(player.m_Helmet)
		end
		local x,y,z = getElementPosition(player)
		local dim = getElementDimension(player)
		local int = getElementInterior(player)
		local model, zOffset, yOffset, scale, rotX, rotZ  = WearableHelmet.objectTable[itemName][1] or WearableHelmet.objectTable["Helm"][1],  WearableHelmet.objectTable[itemName][2] or WearableHelmet.objectTable["Helm"][2], WearableHelmet.objectTable[itemName][3] or WearableHelmet.objectTable["Helm"][3], WearableHelmet.objectTable[itemName][4] or WearableHelmet.objectTable["Helm"][4], WearableHelmet.objectTable[itemName][5] or WearableHelmet.objectTable["Helm"][5],  WearableHelmet.objectTable[itemName][6] or WearableHelmet.objectTable["Helm"][6]
		local obj = createObject(model,x,y,z)
		local objName =  WearableHelmet.objectTable[itemName][7]
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		setObjectScale(obj, scale)
		setElementDoubleSided(obj,true)
		exports.bone_attach:attachElementToBone(obj, player, 1, 0, yOffset, zOffset, rotX , 0, rotZ)
		player.m_Helmet = obj
		player.m_IsWearingHelmet = itemName
		player:meChat(true, "zieht "..objName.." an!")
	elseif player.m_IsWearingHelmet == itemName and player.m_Helmet then --// if the player clicks onto the same helmet once more remove it
		destroyElement(player.m_Helmet)
		self.m_Helmets[player] = nil
		player.m_IsWearingHelmet = false
		player.m_Helmet = false
		player:meChat(true, "setzt "..WearableHelmet.objectTable[itemName][7].." ab!")
	else --// else the player must have clicked on another helmet otherwise this instance of the class would have not been called
		if isElement(player.m_Helmet) then 
			destroyElement(player.m_Helmet)
		end
		local x,y,z = getElementPosition(player)
		local model, zOffset, yOffset, scale, rotX, rotZ  = WearableHelmet.objectTable[itemName][1] or WearableHelmet.objectTable["Helm"][1],  WearableHelmet.objectTable[itemName][2] or WearableHelmet.objectTable["Helm"][2], WearableHelmet.objectTable[itemName][3] or WearableHelmet.objectTable["Helm"][3], WearableHelmet.objectTable[itemName][4] or WearableHelmet.objectTable["Helm"][4], WearableHelmet.objectTable[itemName][5] or WearableHelmet.objectTable["Helm"][5],  WearableHelmet.objectTable[itemName][6] or WearableHelmet.objectTable["Helm"][6]
		local obj = createObject(model,x,y,z)
		local dim = getElementDimension(player)
		local int = getElementInterior(player)
		setElementDimension(obj, dim)
		setElementInterior(obj, int)
		setObjectScale(obj, scale)
		exports.bone_attach:attachElementToBone(obj, player, 1, 0, yOffset, zOffset, rotX, 0, rotZ)
		player.m_Helmet = obj
		player.m_IsWearingHelmet = itemName
		player:meChat(true, "setzt "..WearableHelmet.objectTable[itemName][7].." ab!")
	end
end
