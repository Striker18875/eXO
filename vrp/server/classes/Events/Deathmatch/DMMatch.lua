-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/Deathmatch/DMMatch.lua
-- *  PURPOSE:     Deathmatch match class
-- *
-- ****************************************************************************
DeathmatchMatch = inherit(Deathmatch)

function DeathmatchMatch:constructor (...)
	local args = {...}
	outputDebug("Creating a new Match #"..args[1].."...")

	self.m_ID = args[1]
	self.m_Data = {
		Type = args[3];
		Status = 1;
		Map = args[6];
		Weapon = args[5];
		Passworded = args[4][1];
		Password = args[4][2];
	}
	self.m_Players = {args[2]}
	self.m_Host = args[2]
end

function DeathmatchMatch:destructor ()
	outputDebug("Deleting Match #"..self.m_ID.."...")

	if self.m_Data["Status"] == 2 or self.m_Data["Status"] == 3 then
		self:stopMatch()
	end
end

function DeathmatchMatch:deleteMatch ()
	Deathmatch:getSingleton():deleteMatch(self.m_ID)
end

function DeathmatchMatch:getMatchData ()
	return {
		id = self.m_ID;
		type = self.m_Data["Type"];
		status = self.m_Data["Status"];
		map = self.m_Data["Map"];
		weapon = self.m_Data["Weapon"];
		passworded = self.m_Data["Passworded"];
		password = self.m_Data["Password"];
		players = self.m_Players;
		host = self.m_Host;
	}
end

function DeathmatchMatch:setStatus (status, ...)
	if not Deathmatch.Status[status] then return end
	self.m_Data["Status"] = status
	if status == 2 then
		self:startMatch(...)
	end

	Deathmatch:getSingleton():syncData()
end

function DeathmatchMatch:addPlayer (player)
	player:setMatchID(self.m_ID)
	table.insert(self.m_Players, player)

	-- at the end -> sync it
	Deathmatch:getSingleton():syncData()
end

function DeathmatchMatch:removePlayer (player)
	player:setMatchID(0)
	table.removevalue(self.m_Players, player)


	-- at the end -> sync it
	Deathmatch:getSingleton():syncData()
end

function DeathmatchMatch:startMatch ()
	self.m_MatchDimension = DimensionManager:getSingleton():getFreeDimension()
	for i, v in pairs(self.m_Players) do
		v:triggerEvent("DeathmatchEvent.closeGUIForm")
		v:setFrozen(false)
		v:setDimension(self.m_MatchDimension)
	end
end

function DeathmatchMatch:stopMatch ()
	DimensionManager:getSingleton():freeDimension(self.m_MatchDimension)

	for i, v in pairs(self.m_Players) do
		v:setDimension(0)
	end
end

-- DEBUG
addCommandHandler("testf", function ()
	local instance = Deathmatch:getSingleton():newMatch(getRandomPlayer(), math.random(3), {true, "hallo"}, 1, 3)
	addCommandHandler("testf2", function ()
		instance:setStatus(2)
	end)
end)

addCommandHandler("testb", function ()
	Deathmatch:getSingleton():getMatchFromID(1):deleteMatch()
end)
