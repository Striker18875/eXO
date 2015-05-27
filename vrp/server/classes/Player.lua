-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
inherit(DatabasePlayer, Player)
registerElementClass("player", Player)
Player.ms_QuitHook = Hook:new()

addEvent("introFinished", true)
addEventHandler("introFinished", root, function()
	client.m_TutorialStage = 3 -- todo: character creation and tutorial mission
	client:spawn()
end)

function Player:constructor()
	setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	setElementFrozen(self, true)

	self.m_PrivateSync = {}
	self.m_PrivateSyncUpdate = {}
	self.m_PublicSync = {}
	self.m_PublicSyncUpdate = {}
	self.m_SyncListener = {}
	self.m_Achievements = {}
	self.m_LastGotWantedLevelTime = 0
	self.m_JoinTime = getTickCount()
	self.m_Crimes = {}

end

function Player:destructor()
	if self.m_JobVehicle and isElement(self.m_JobVehicle) then -- TODO: Move this to an appropriate position to be able to use the quit hook
		destroyElement(self.m_JobVehicle)
	end

	-- Call the quit hook (to clean up various things before saving)
	Player.ms_QuitHook:call(self)

	self:save()

	-- Unload stuff
	if self.m_Inventory then
		delete(self.m_Inventory)
	end
end

function Player:connect()
	if not Ban.checkBan(self) then return end
end

function Player:join()
end

function Player:sendNews()
	self:triggerEvent("ingamenews", Forum:getSingleton():getNews())
end

function Player:triggerEvent(ev, ...)
	triggerClientEvent(self, ev, self, ...)
end

function Player:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), self, r, g, b, true)
end

function Player:startNavigationTo(pos)
	self:triggerEvent("navigationStart", pos.x, pos.y, pos.z)
end

function Player:stopNavigation()
	self:triggerEvent("navigationStop")
end

function Player:loadCharacter()
	DatabasePlayer.Map[self.m_Id] = self
	self:loadCharacterInfo()

	-- Send infos to client
	local info = {
		Rank = self:getRank();
	}
	self:triggerEvent("retrieveInfo", info)

	-- Send initial sync
	self:sendInitialSync()

	-- Add binds
	self:initialiseBinds()

	-- Add command and event handler
	addCommandHandler("Group", Player.staticGroupChatHandler)
end

function Player:createCharacter()
	sql:queryExec("INSERT INTO ??_character(Id) VALUES(?);", sql:getPrefix(), self.m_Id)

	self.m_Inventory = Inventory.create()
end

function Player:loadCharacterInfo()
	if self:isGuest() then
		Blip.sendAllToClient(self)
		RadarArea.sendAllToClient(self)
		return
	end

	local row = sql:asyncQueryFetchSingle("SELECT Health, Armor, Weapons, UniqueInterior FROM ??_character WHERE Id = ?", sql:getPrefix(), self.m_Id)
	if not row then
		return false
	end

	-- Reset Name
	self:setName(self:getAccount():getName())

	-- Load non-element related data
	self:load()

	self.m_UniqueInterior = row.UniqueInterior

	-- Load health data
	self.m_Health = row.Health
	self.m_Armor = row.Armor

	-- Load weapons
	self.m_Weapons = fromJSON(row.Weapons) or {}

	-- Sync server objects to client
	Blip.sendAllToClient(self)
	RadarArea.sendAllToClient(self)
	if self.m_Inventory then
		self.m_Inventory:setInteractingPlayer(self)
		self.m_Inventory:sendFullSync()
	else
		outputDebugString("Inventory has not been instantiated successfully!")
	end

	self:setPrivateSync("LastPlayTime", self.m_LastPlayTime)
end

function Player:initialiseBinds()
	bindKey(self, "u", "down", "chatbox", "Group")
	bindKey(self, "l", "down", function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle then vehicle:toggleLight(player) end end)
	bindKey(self, "x", "down", function(player) local vehicle = getPedOccupiedVehicle(player) if vehicle and getPedOccupiedVehicleSeat(player) == 0 then vehicle:toggleEngine(player) end end)
end

function Player:save()
	if not self.m_Account or self:isGuest() then
		return
	end
	local x, y, z = getElementPosition(self)
	local interior = self:getInterior()

	-- Reset unique interior if interior or dimension doesn't match (ATTENTION: Dimensions must be unique as well)
	if interior == 0 or self:getDimension() ~= self.m_UniqueInterior then
		self.m_UniqueInterior = 0
	end

	local weapons = {}
	for slot = 0, 11 do -- exclude satchel detonator (slot 12)
		local weapon, ammo = getPedWeapon(self, slot), getPedTotalAmmo(self, slot)
		if ammo > 0 then
			weapons[#weapons + 1] = {weapon, ammo}
		end
	end

	sql:queryExec("UPDATE ??_character SET PosX = ?, PosY = ?, PosZ = ?, Interior = ?, UniqueInterior = ?, Health = ?, Armor = ?, Weapons = ?, InventoryId = ?, PlayTime = ? WHERE Id = ?;", sql:getPrefix(),
		x, y, z, interior, self.m_UniqueInterior, math.floor(self:getHealth()), math.floor(self:getArmor()), toJSON(weapons), self.m_Inventory:getId(), self:getPlayTime(), self.m_Id)

	if self:getInventory() then
		self:getInventory():save()
	end
	DatabasePlayer.save(self)
end

function Player:spawn()
	if self:isGuest() then
		-- set default data (fallback / guest)
		self:setMoney(0)
		self:setXP(0)
		self:setKarma(0)
		self:setWantedLevel(0)
		self:setJobLevel(0)
		self:setWeaponLevel(0)
		self:setVehicleLevel(0)
		self:setSkinLevel(0)

		-- spawn the player
		spawnPlayer(self, 2028, -1405, 18, self.m_Skin, self.m_SavedInterior, 0) -- Todo: change position
		self:setRotation(0, 0, 180)
	else
		if self.m_SpawnLocation == SPAWN_LOCATION_DEFAULT then
			spawnPlayer(self, self.m_SavedPosition.x, self.m_SavedPosition.y, self.m_SavedPosition.z, 0, self.m_Skin, self.m_SavedInterior, 0)
		elseif self.m_SpawnLocation == SPAWN_LOCATION_GARAGE and self.m_LastGarageEntrance ~= 0 then
			VehicleGarages:getSingleton():spawnPlayerInGarage(self, self.m_LastGarageEntrance)
		else
			outputServerLog("Invalid spawn location ("..self:getName()..")")
		end

		-- Teleport player into a "unique interior"
		if self.m_UniqueInterior ~= 0 then
			InteriorManager:getSingleton():teleportPlayerToInterior(self, self.m_UniqueInterior)
			self.m_UniqueInterior = 0
		end

		-- Apply and delete health data
		self:setHealth(self.m_Health)
		self:setArmor(self.m_Armor)
		self.m_Health, self.m_Armor = nil, nil

		-- Give weapons
		for k, info in pairs(self.m_Weapons) do
			giveWeapon(self, info[1], info[2])
		end
	end

	setElementFrozen(self, false)
	setCameraTarget(self, self)
	fadeCamera(self, true)
end

function Player:respawn(position, rotation)
	position = position or Vector3(2028, -1405, 18)
	rotation = rotation or 0

	spawnPlayer(self, position, rotation, self.m_Skin)
	setCameraTarget(self, self)
end

-- Message Boxes
function Player:sendError(text) 	self:triggerEvent("errorBox", text) 	end
function Player:sendWarning(text)	self:triggerEvent("warningBox", text) 	end
function Player:sendInfo(text)		self:triggerEvent("infoBox", text)		end
function Player:sendInfoTimeout(text, timeout) self:triggerEvent("infoBox", text, timeout) end
function Player:sendSuccess(text)	self:triggerEvent("successBox", text)	end
function Player:sendShortMessage(text) self:triggerEvent("shortMessageBox", text)	end
function Player:isActive() return true end

function Player:setPhonePartner(partner) self.m_PhonePartner = partner end

function Player.staticGroupChatHandler(self, command, ...)
	if self.m_Group then
		self.m_Group:sendMessage(("[GROUP] %s: %s"):format(getPlayerName(self), table.concat({...}, " ")))
	end
end

function Player:reportCrime(crimeType)
	JobPolice:getSingleton():reportCrime(self, crimeType)
end

function Player:setSkin(skin)
	self.m_Skin = skin
	setElementModel(self, skin)
end

function Player:setJobDutySkin(skin)
	if skin ~= nil then
		self.m_JobDutySkin = skin
		setElementModel(self, skin)
	else
		setElementModel(self, self.m_Skin)
	end
end

function Player:setKarma(karma)
	DatabasePlayer.setKarma(self, karma)
	self:setPublicSync("Karma", self.m_Karma)
end

function Player:setXP(xp)
	DatabasePlayer.setXP(self, xp)
	self:setPublicSync("XP", xp)

	-- Check if the player needs a level up
	local oldLevel = self:getLevel()
	if self:getLevel() > oldLevel then
		--self:triggerEvent("levelUp", self:getLevel())
		self:sendInfo(_("Du bist zu Level %d aufgestiegen", self, self:getLevel()))
	end
end

function Player:addBuff(buff,amount)
	Nametag:getSingleton():addBuff(self,buff,amount)
end

function Player:removeBuff(buff)
	Nametag:getSingleton():removeBuff(self,buff)
end

function Player:setPrivateSync(key, value)
	if self.m_PrivateSync[key] ~= value then
		self.m_PrivateSync[key] = value
		self.m_PrivateSyncUpdate[key] = key
	end
end

function Player:setPublicSync(key, value)
	if self.m_PublicSync[key] ~= value then
		self.m_PublicSync[key] = value
		self.m_PublicSyncUpdate[key] = true
	end
end

function Player:getPublicSync(key)
	return self.m_PublicSync[key]
end

function Player:getPrivateSync(key)
	return self.m_PrivateSync[key]
end

function Player:addSyncListener(player)
	self.m_SyncListener[player] = player
end

function Player:removeSyncListener(player)
	self.m_SyncListener[player] = nil
end

function Player:updateSync()
	local publicSync = {}
	for k, v in pairs(self.m_PublicSyncUpdate) do
		publicSync[k] = self.m_PublicSync[k]
	end
	self.m_PublicSyncUpdate = {}

	local privateSync = {}
	for k, v in pairs(self.m_PrivateSyncUpdate) do
		privateSync[k] = self.m_PrivateSync[k]
	end
	self.m_PrivateSyncUpdate = {}

	if table.size(privateSync) ~= 0 then
		triggerClientEvent(self, "PlayerPrivateSync", self, privateSync)
		for k, v in pairs(self.m_SyncListener) do
			triggerClientEvent(v, "PlayerPrivateSync", self, privateSync)
		end
	end

	if table.size(publicSync) ~= 0 then
		triggerClientEvent(root, "PlayerPublicSync", self, publicSync)
	end
end

function Player:sendInitialSync()
	triggerClientEvent(self, "PlayerPrivateSync", self, self.m_PrivateSync)

	-- Todo: Pack data and send only 1 event
	for k, player in pairs(getElementsByType("player")) do
		triggerClientEvent(self, "PlayerPublicSync", player, player.m_PublicSync)
	end
end

function Player:getLastGotWantedLevelTime()
	return self.m_LastGotWantedLevelTime
end

function Player:getJoinTime()
	return self.m_JoinTime
end

function Player:getPlayTime()
	return math.floor(self.m_LastPlayTime + (getTickCount() - self.m_JoinTime)/1000/60)
end

function Player:getCrimes()
	return self.m_Crimes
end

function Player:clearCrimes()
	self.m_Crimes = {}
end

function Player:addCrime(crimeType)
	self.m_Crimes[#self.m_Crimes + 1] = crimeType
end

function Player:giveMoney(money) -- Overriden
	DatabasePlayer.giveMoney(self, money)

	if money ~= 0 then
		self:sendShortMessage((money >= 0 and "+"..money or money).."$")
	end
end

function Player:takeMoney(money)
	self:giveMoney(-money)
end

function Player:startTrading(tradingPartner)
	if self == tradingPartner then
		return
	end

	self.m_TradingPartner = tradingPartner
	self.m_TradeItems = {}
	self.m_TradingStatus = false

	tradingPartner.m_TradingPartner = self
	tradingPartner.m_TradeItems = {}
	tradingPartner.m_TradingStatus = false

	self:triggerEvent("tradingStart", self:getInventory():getId())
	tradingPartner:triggerEvent("tradingStart", tradingPartner:getInventory():getId())
end

function Player:getTradingPartner()
	return self.m_TradingPartner
end

function Player.getQuitHook()
	return Player.ms_QuitHook
end

function Player:givePoints(p) -- Overriden
	DatabasePlayer.givePoints(self, p)

	if p ~= 0 then
		self:sendShortMessage((p >= 0 and "+"..p or p).._(" Punkte", self))
	end
end

function Player:setUniqueInterior(uniqueInteriorId)
	self.m_UniqueInterior = uniqueInteriorId
end
