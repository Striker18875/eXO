-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PlayerManager.lua
-- *  PURPOSE:     Player manager class
-- *
-- ****************************************************************************
PlayerManager = inherit(Singleton)
addRemoteEvents{"playerReady", "playerSendMoney", "requestPointsToKarma", "requestWeaponLevelUp", "requestVehicleLevelUp", "requestSkinLevelUp", "requestJobLevelUp"}

function PlayerManager:constructor()
	self.m_WastedHooks = {}

	-- Register events
	addEventHandler("onPlayerConnect", root, bind(self.playerConnect, self))
	addEventHandler("onPlayerJoin", root, bind(self.playerJoin, self))
	addEventHandler("onPlayerWasted", root, bind(self.playerWasted, self))
	addEventHandler("onPlayerChat", root, bind(self.playerChat, self))

	addEventHandler("onPlayerChangeNick", root, function() cancelEvent() end)
	addEventHandler("playerReady", root, bind(self.Event_playerReady, self))
	addEventHandler("playerSendMoney", root, bind(self.Event_playerSendMoney, self))
	addEventHandler("requestPointsToKarma", root, bind(self.Event_requestPointsToKarma, self))
	addEventHandler("requestWeaponLevelUp", root, bind(self.Event_requestWeaponLevelUp, self))
	addEventHandler("requestVehicleLevelUp", root, bind(self.Event_requestVehicleLevelUp, self))
	addEventHandler("requestSkinLevelUp", root, bind(self.Event_requestSkinLevelUp, self))
	addEventHandler("requestJobLevelUp", root, bind(self.Event_requestJobLevelUp, self))

	self.m_SyncPulse = TimedPulse:new(500)
	self.m_SyncPulse:registerHandler(bind(PlayerManager.updatePlayerSync, self))
end

function PlayerManager:destructor()
	for k, v in ipairs(getElementsByType("player")) do
		delete(v)
	end
end

function PlayerManager:updatePlayerSync()
	for k, v in pairs(getElementsByType("player")) do
		v:updateSync()
	end
end

function PlayerManager:registerWastedHook(hookFunc)
	self.m_WastedHooks[#self.m_WastedHooks + 1] = hookFunc
end


-----------------------------------------
--------       Event zone       ---------
-----------------------------------------
function PlayerManager:playerConnect(name)
	local player = getPlayerFromName(name)
	Async.create(Player.connect)(player)
end

function PlayerManager:playerJoin()
	-- Set a random nick to prevent blocking nicknames
	source:setName(getRandomUniqueNick())

	source:join()
end

function PlayerManager:Event_playerReady()
	local player = client

	-- Send sync
	for k, v in pairs(getElementsByType("player")) do
		if isElement(v) and v.sendInitalSyncTo then
			v:sendInitalSyncTo(player)
		end
	end
end

function PlayerManager:playerWasted()
	-- Call wasted hooks
	for k, hookFunc in pairs(self.m_WastedHooks) do
		-- Cancel if hook function returned false
		if hookFunc(source) then
			return
		end
	end

	source:sendInfo(_("Du hattest Glück und hast die Verletzungen überlebt. Doch pass auf, dass es nicht wieder passiert!", source))
	source:triggerEvent("playerWasted")
	setTimer(function(player) if player and isElement(player) then player:respawn() end end, 8000, 1, source)
end

function PlayerManager:playerChat(message, messageType)
	if messageType == 0 then
		local phonePartner = source:getPhonePartner()
		if not phonePartner then
			outputChatBox(getPlayerName(source)..": "..message, root, 255, 255, 0)
		else
			-- Send handy message
			outputChatBox(_("%s from phone: %s", phonePartner, getPlayerName(source), message), phonePartner, 0, 255, 0)
			outputChatBox(_("%s from phone: %s", source, getPlayerName(source), message), source, 0, 255, 0)
		end
		cancelEvent()
	end
end

function PlayerManager:Event_playerSendMoney(amount)
	if not client then return end
	amount = math.floor(amount)
	if amount <= 0 then return end
	if client:getMoney() >= amount then
		client:takeMoney(amount)
		source:giveMoney(amount)
	end
end

function PlayerManager:Event_requestPointsToKarma(positive)
	if client:getPoints() >= 400 then
		client:giveKarma(1, (positive and 1 or -1), true)
		client:givePoints(-400)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_requestWeaponLevelUp()
	if client:getWeaponLevel() >= MAX_WEAPON_LEVEL then
		client:sendError(_("Du hast das zurzeit mögliche Maximallevel erreicht!", client))
		return
	end

	local requiredPoints = calculatePointsToNextLevel(client:getWeaponLevel())
	if client:getPoints() >= requiredPoints then
		client:incrementWeaponLevel()
		client:givePoints(-requiredPoints)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_requestVehicleLevelUp()
	if client:getVehicleLevel() >= MAX_VEHICLE_LEVEL then
		client:sendError(_("Du hast das zurzeit mögliche Maximallevel erreicht!", client))
		return
	end

	local requiredPoints = calculatePointsToNextLevel(client:getVehicleLevel())
	if client:getPoints() >= requiredPoints then
		client:incrementVehicleLevel()
		client:givePoints(-requiredPoints)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_requestSkinLevelUp()
	if client:getSkinLevel() >= MAX_SKIN_LEVEL then
		client:sendError(_("Du hast das zurzeit mögliche Maximallevel erreicht!", client))
		return
	end

	local requiredPoints = calculatePointsToNextLevel(client:getSkinLevel())
	if client:getPoints() >= requiredPoints then
		client:incrementSkinLevel()
		client:givePoints(-requiredPoints)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_requestJobLevelUp()
	if client:getJobLevel() >= MAX_JOB_LEVEL then
		client:sendError(_("Du hast das zurzeit mögliche Maximallevel erreicht!", client))
		return
	end

	local requiredPoints = calculatePointsToNextLevel(client:getJobLevel())
	if client:getPoints() >= requiredPoints then
		client:incrementJobLevel()
		client:givePoints(-requiredPoints)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end
