-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/SkyscraperManager.lua
-- *  PURPOSE:    Skyscraper Manager class
-- *
-- ****************************************************************************
SkyscraperManager = inherit(Singleton)

addRemoteEvents{"Skyscraper:requestHouseInfos"}
SkyscraperManager.Map = {}

function SkyscraperManager:constructor()
	local query = sql:queryFetch("SELECT * FROM ??_skyscrapers", sql:getPrefix())

	for key, value in pairs(query) do
        local query2 = sql:queryFetch("SELECT Id FROM ??_houses WHERE skyscraperID = ?", sql:getPrefix(), value["Id"])
		SkyscraperManager.Map[value["Id"]] = Skyscraper:new(value["Id"], Vector3(value["PosX"], value["PosY"], value["PosZ"]), query2)
	end
	
	addEventHandler("Skyscraper:requestHouseInfos", root, bind(self.Event_requestHouseInfos, self))
	addCommandHandler("createskyscraper", bind(self.newSkyscraper, self))
	addCommandHandler("addhousetoskyscraper", bind(self.addHouseToSkyscraper, self))
	addCommandHandler("removehousefromskyscraper", bind(self.removeHouseFromSkyscraper, self))
end

function SkyscraperManager:destructor()
	for i, skyscraper in pairs(SkyscraperManager.Map) do
		skyscraper:save()
	end
end

function SkyscraperManager:Event_requestHouseInfos(houseId)
	client.visitingHouse = houseId
	HouseManager:getSingleton().m_Houses[houseId]:showGUI(client)
end

function SkyscraperManager:newSkyscraper(player, cmd)
	if player:getRank() >= ADMIN_RANK_PERMISSION["createSkyscraper"] then		
		local pos = player:getPosition()
		sql:queryExec("INSERT INTO ??_skyscrapers (x,y,z) VALUES (?,?,?)", sql:getPrefix(), pos.x, pos.y, pos.z)
		local Id = sql:lastInsertId()
		SkyscraperManager.Map[Id] = Skyscraper:new(Id, pos, false)
	end
end

function SkyscraperManager:deleteSkyscraper()
	if player:getRank() >= ADMIN_RANK_PERMISSION["createSkyscraper"] then	
	end
end

function SkyscraperManager:addHouseToSkyscraper(player, cmd, houseId, skyscraperId)
	houseId = tonumber(houseId)
	skyscraperId = tonumber(skyscraperId)
	if player:getRank() >= ADMIN_RANK_PERMISSION["addHouseToSkyscraper"] then
		if not skyscraperId then player:sendMessage("Syntax: HouseId, SkyscraperId",255,0,0) return false end
		if table.find(SkyscraperManager.Map[skyscraperId].m_Houses, houseId) then return end

		HouseManager:getSingleton().m_Houses[houseId].m_SkyscraperId = skyscraperId
		HouseManager:getSingleton().m_Houses[houseId].m_IsInSkyscraper = true
		HouseManager:getSingleton().m_Houses[houseId]:setPosition(SkyscraperManager.Map[skyscraperId].m_Position)
		HouseManager:getSingleton().m_Houses[houseId].m_Pickup:destroy()
		HouseManager:getSingleton().m_Houses[houseId].m_Pickup = nil
		table.insert(SkyscraperManager.Map[skyscraperId].m_Houses, houseId)
		SkyscraperManager.Map[skyscraperId]:updatePickup()
	end
end

function SkyscraperManager:removeHouseFromSkyscraper(player, cmd, houseId, skyscraperId)
	houseId = tonumber(houseId)
	skyscraperId = tonumber(skyscraperId)
	if player:getRank() >= ADMIN_RANK_PERMISSION["addHouseToSkyscraper"] then
		if not skyscraperId then player:sendMessage("Syntax: HouseId, SkyscraperId",255,0,0) return false end
		if not table.find(SkyscraperManager.Map[skyscraperId].m_Houses, houseId) then return end
		local pos = player:getPosition()

		HouseManager:getSingleton().m_Houses[houseId].m_SkyscraperId = 0
		HouseManager:getSingleton().m_Houses[houseId].m_IsInSkyscraper = false
		HouseManager:getSingleton().m_Houses[houseId]:setPosition(pos)
		table.removevalue(SkyscraperManager.Map[skyscraperId].m_Houses, houseId)
		SkyscraperManager.Map[skyscraperId]:updatePickup()
	end
end