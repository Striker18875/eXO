-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Item.lua
-- *  PURPOSE:     Item Super Class
-- *
-- ****************************************************************************
Item = inherit(Object)

function Item:constructor()
end

function Item:setName(name)
	self.m_ItemName = name
end

function Item:loadItem()
	local itemData = InventoryManager:getSingleton():getItemDataForItem(self.m_ItemName)
	self.m_ItemTasche = itemData["Tasche"]
	self.m_ItemIcon = itemData["Icon"]
	self.m_ItemItemMax = itemData["Item_Max"]
	self.m_ItemWegwerf = itemData["Wegwerf"]
	self.m_ItemHandel = itemData["Handel"]
	self.m_ItemStack_max = itemData["Stack_max"]
	self.m_ItemVerbraucht = itemData["Verbraucht"]
	self.m_ItemModel = itemData["ModelID"]
end

function Item:getName()
	return self.m_ItemName
end

function Item:expire()
end

function Item:getModelId()
	return self.m_ItemModel ~= 0 and self.m_ItemModel or 2969
end

function Item:place(owner, pos, rotation, amount)
	local worldItem = WorldItem:new(self, owner, pos, rotation)
	return worldItem
end

function Item:startObjectPlacing(player, callback)
	if player.m_PlacingInfo then
		player:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", player))
		return false
	end

	-- Start the object placer on the client
	player:triggerEvent("objectPlacerStart", self:getModelId(), "itemPlaced")
	player.m_PlacingInfo = {item = self, callback = callback}
	return true
end

addEvent("itemPlaced", true)
addEventHandler("itemPlaced", root,
	function(x, y, z, rotation)
		local placingInfo = client.m_PlacingInfo
		if placingInfo then
			placingInfo.callback(placingInfo.item, Vector3(x, y, z), rotation)
			client.m_PlacingInfo = nil
		end
	end
)
