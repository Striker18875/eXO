-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
registerElementClass("player", Player)

function Player:virtual_constructor()
	self.m_Karma = 0

	self.m_PublicSync = {}
	self.m_PrivateSync = {}
	self.m_PrivateSyncChangeHandler = {}
end

function Player:getPublicSync(key)
	return self.m_PublicSync[key]
end

function Player:getPrivateSync(key)
	return self.m_PrivateSync[key]
end

function Player:onUpdateSync(private, public)
	for k, v in pairs(private or {}) do
		self.m_PrivateSync[k] = v
		
		local f = self.m_PrivateSyncChangeHandler[k]
		if f then f(v) end
	end
	for k, v in pairs(public or {}) do
		self.m_PublicSync[k] = v
	end
end

function Player:setPrivateSyncChangeHandler(key, handler)
	self.m_PrivateSyncChangeHandler[key] = handler
end

function Player:getXP()
	return self:getPublicSync("XP") or 0
end

function Player:getLevel()
	return calculatePlayerLevel(self:getXP())
end

function Player:getKarma()
	return self:getPublicSync("Karma") or 0
end

function Player:getGroupName()
	return self:getPublicSync("GroupName") or ""
end

function Player:getJobName()
	local job = JobManager:getSingleton():getFromId(self:getPublicSync("JobId"))
	if job then
		return job:getName()
	else
		return "-"
	end
end

addRemoteEvents{"PlayerPrivateSync", "PlayerPublicSync"}
addEventHandler("PlayerPrivateSync", root, function(private) source:onUpdateSync(private, nil) end)
addEventHandler("PlayerPublicSync", root, function(public) source:onUpdateSync(nil, public) end)
