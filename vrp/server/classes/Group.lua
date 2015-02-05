-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Group.lua
-- *  PURPOSE:     Group class
-- *
-- ****************************************************************************
Group = inherit(Object)

function Group:constructor(Id, name, money, players)
	self.m_Id = Id
	
	self.m_Players = players or {}
	self.m_Name = name
	self.m_Money = money
	self.m_ProfitProportion = 0.5 -- Amount of money for the group fund
	self.m_Invitations = {}
end

function Group:destructor()
end

function Group.create(name)
	if sql:queryExec("INSERT INTO ??_groups (Name) VALUES(?)", sql:getPrefix(), name) then
		local group = Group:new(sql:lastInsertId(), name, 0)
		
		-- Add refernece
		GroupManager:getSingleton():addRef(group)
		
		return group
	end
	return false
end

function Group:purge()
	if sql:queryExec("DELETE FROM ??_groups WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		-- Remove all players
		for playerId in pairs(self.m_Players) do
			self:removePlayer(playerId)
		end
		
		-- Remove reference
		GroupManager:getSingleton():removeRef(self)
		
		-- Free owned gangareas
		GangAreaManager:getSingleton():freeAreas()
		
		return true
	end
	return false
end

function Group:getId()
	return self.m_Id
end

function Group:getName()
	return self.m_Name
end

function Group:getKarma()
	local karmaSum = 0
	local onlinePlayers = self:getOnlinePlayers()
	
	for k, player in pairs(onlinePlayers) do
		karmaSum = karmaSum + player:getKarma()
	end
	
	return karmaSum / #onlinePlayers
end

function Group:isEvil()
	return self:getKarma() < 0
end

function Group:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end
	
	rank = rank or 0
	self.m_Players[playerId] = rank
	local player = Player.getFromId(playerId)
	if player then
		player:setGroup(self)
	end
	
	sql:queryExec("UPDATE ??_character SET GroupId = ?, GroupRank = ? WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)
end

function Group:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end
	
	self.m_Players[playerId] = nil
	local player = Player.getFromId(playerId)
	if player then
		player:setGroup(nil)
	end
	
	sql:queryExec("UPDATE ??_character SET GroupId = 0, GroupRank = 0 WHERE Id = ?", sql:getPrefix(), playerId)
end

function Group:invitePlayer(player)
	player:triggerEvent("groupInvitationRetrieve", self:getId(), self:getName())
	
	self.m_Invitations[player] = true
end

function Group:removeInvitation(player)
	self.m_Invitations[player] = nil
end

function Group:hasInvitation(player)
	return self.m_Invitations[player]
end

function Group:isPlayerMember(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end
	
	return self.m_Players[playerId] ~= nil
end


function Group:getPlayerRank(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end
	
	return self.m_Players[playerId]
end

function Group:setPlayerRank(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end
	
	self.m_Players[playerId] = rank
	sql:queryExec("UPDATE ??_character SET GroupRank = ? WHERE Id = ?", sql:getPrefix(), rank, playerId)
end

function Group:getMoney()
	return self.m_Money
end

function Group:giveMoney(amount)
	self:setMoney(self.m_Money + amount)
end

function Group:takeMoney(amount)
	self:setMoney(self.m_Money - amount)
end

function Group:setMoney(amount)
	self.m_Money = amount
	
	sql:queryExec("UPDATE ??_groups SET Money = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_Id)
end

function Group:getPlayers()
	local temp = {}
	for playerId, rank in pairs(self.m_Players) do
		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank}
	end
	return temp
end

function Group:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player then
			table.insert(players, player)
		end
	end
	return players
end

function Group:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Group:distributeMoney(amount)
	local moneyForFund = amount * self.m_ProfitProportion
	self:giveMoney(moneyForFund)
	
	local moneyForPlayers = amount - moneyForFund
	local onlinePlayers = self:getOnlinePlayers()
	local amountPerPlayer = moneyForPlayers / #onlinePlayers
	
	for k, player in pairs(onlinePlayers) do
		player:giveMoney(amountPerPlayer)
	end
end
