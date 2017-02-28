-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/DeathmatchLobby.lua
-- *  PURPOSE:     Deathmatch Lobby class
-- *
-- ****************************************************************************

DeathmatchLobby = inherit(Object)
DeathmatchLobby.Types = {[1] = "permanent", [2] = "temporary",
						 ["permanent"] = 1, ["temporary"] = 2}

function DeathmatchLobby:constructor(id, name, owner, map, weapons, mode, maxPlayer, password)
	self.m_Id = id
	self.m_Type = owner == "Server" and DeathmatchLobby.Types[1] or DeathmatchLobby.Types[2]
	self.m_Name = name
	self.m_Map = map
	self.m_Weapons = weapons
	self.m_Mode = mode
	self.m_MaxPlayer = maxPlayer
	self.m_Password = password or ""
	self.m_Players = {}

	self.m_LeaveBind = bind(self.removePlayer, self)
	self.m_ColShapeLeaveBind = bind(self.onColshapeLeave, self)

	self:loadMap()

	if self.m_Type == DeathmatchLobby.Types[1] then
		self.m_Owner = "Server"
		self.m_OwnerName = "eXo-RL"
	else
		self.m_Owner = owner
		self.m_OwnerName = owner:getName()
		self:addPlayer(owner)
	end
end

function DeathmatchLobby:destructor()
	self.m_Colshape:destroy()
	DeathmatchManager:getSingleton():unregisterLobby(self.m_Id)
end


function DeathmatchLobby:loadMap()
	if not DeathmatchManager.Maps[self.m_Map] then
		outputDebugString("DeathmatchLobby: Invalid Map")
		return
	end
	local map = DeathmatchManager.Maps[self.m_Map]
	self.m_MapName = map.Name
	self.m_MapData = {}
	self.m_MapData["dim"] = 2000+self.m_Id
	self.m_MapData["int"] = map.Interior
	self.m_MapData["spawns"] = map.Spawns
	self.m_Colshape = createColSphere(self.m_MapData["spawns"][1], 100)
	self.m_Colshape:setDimension(self.m_MapData["dim"])
	self.m_Colshape:setInterior(self.m_MapData["int"])
	addEventHandler("onColShapeLeave", self.m_Colshape, self.m_LeaveBind)
end

function DeathmatchLobby:getPlayers()
	local players = {}
	local count = 0
	for player, data in pairs(self.m_Players) do
		if isElement(player) then
			players[player] = data
			count = count + 1
		else
			self:removePlayer(player)
		end
	end
	return players, count
end

function DeathmatchLobby:sendShortMessage(text, ...)
	for player, data in pairs(self:getPlayers()) do
		player:sendShortMessage(_(text, player), "Deathmatch-Lobby", {255, 125, 0}, ...)
	end
end

function DeathmatchLobby:getPlayerString()
	local playerString = ""
	for player, data in pairs(self:getPlayers()) do
		playerString = playerString..player:getName()..", "
	end

	return string.sub(playerString, 0, #playerString-2)
end

function DeathmatchLobby:getWeaponString()
	local weaponString = ""
	for index, weaponId in pairs(self.m_Weapons) do
		weaponString = weaponString..WEAPON_NAMES[weaponId]..", "
	end
	return string.sub(weaponString, 0, #weaponString-2)
end

function DeathmatchLobby:getPlayerCount()
	local _, count = self:getPlayers()
	return count
end

function DeathmatchLobby:isValidWeapon(weapon)
	for index, id in pairs(self.m_Weapons) do
		if weapon == id then
			return true
		end
	end
	return false
end

function DeathmatchLobby:refreshGUI()
	for player, data in pairs(self:getPlayers()) do
		player:triggerEvent("deathmatchRefreshGUI", self.m_Players)
	end
end

function DeathmatchLobby:increaseKill(player, weapon)
	if not self:isValidWeapon(weapon) then return end
	self.m_Players[player]["Kills"] = self.m_Players[player]["Kills"] + 1
	self:refreshGUI()
end

function DeathmatchLobby:increaseDead(player, weapon)
	if not self:isValidWeapon(weapon) then return end
	self.m_Players[player]["Deaths"] = self.m_Players[player]["Deaths"] + 1
	self:refreshGUI()
end

function DeathmatchLobby:addPlayer(player)
	self.m_Players[player] = {
		["Kills"] = 0,
		["Deaths"] = 0
	}
	takeAllWeapons(player)
	giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
	player.m_RemoveWeaponsOnLogout = true
	player.disableWeaponStorage = true
	self:respawnPlayer(player)
	player.deathmatchLobby = self
	self:sendShortMessage(player:getName().." ist beigetreten!")
	self:refreshGUI()
end

function DeathmatchLobby:respawnPlayer(player, dead, killer, weapon)
	local pos = Randomizer:getRandomTableValue(self.m_MapData["spawns"])
	if dead then
		player:triggerEvent("deathmatchStartDeathScreen", killer or player, true)
		if killer then

			self:increaseKill(killer, weapon)
			self:increaseDead(player, weapon)
		end
		fadeCamera(player, false, 2)
		player:triggerEvent("Countdown", 10, "Respawn in")
		setTimer(function()
			local skin = player:getModel()
			spawnPlayer(player, pos, 0, skin, self.m_MapData["int"], self.m_MapData["dim"])
			player:setHealth(100)
			player:setArmor(0)
			player:setHeadless(false)
			player:setCameraTarget(player)
			player:fadeCamera(true, 1)
			player:triggerEvent("CountdownStop", "Respawn in")
			giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
		end,10000,1)
	else
		player:setDimension(self.m_MapData["dim"])
		player:setInterior(self.m_MapData["int"])
		player:setPosition(pos)
		player:setHealth(100)
		player:setHeadless(false)
		player:setArmor(0)
		giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
	end
end

function DeathmatchLobby:removePlayer(player, isServerStop)
	self.m_Players[player] = nil
	if isElement(player) then
		takeAllWeapons(player)
		player.m_RemoveWeaponsOnLogout = nil
		player.disableWeaponStorage = nil
		player:setDimension(0)
		player:setInterior(0)
		player:setPosition(1325.21, -1559.48, 13.54)
		player:setHeadless(false)
		player:setHealth(100)
		player:setArmor(0)
		player.deathmatchLobby = nil
		if not isServerStop then
			self:sendShortMessage(player:getName().." hat die Lobby verlassen!")
			player:sendShortMessage(_("Du hast die Lobby verlassen!", player), "Deathmatch-Lobby", {255, 125, 0})
			player:triggerEvent("deathmatchCloseGUI")
		end
	end

	if self.m_Type == DeathmatchLobby.Types[2] and self:getPlayerCount() == 0 then
		delete(self)
	end

	if not isServerStop then
		self:refreshGUI()
	end
end

function DeathmatchLobby:onColshapeLeave(player, dim)
	if dim then
		self:removePlayer(player)
	end
end

function DeathmatchLobby:onPlayerChat(player, text, type)
	if type == 0 then
		for playeritem, data in pairs(self.m_Players) do
			playeritem:sendMessage(("#00ffff[%s] #808080%s: %s"):format(self.m_Name, player:getName(), text))
		end

		return true
	end
end
