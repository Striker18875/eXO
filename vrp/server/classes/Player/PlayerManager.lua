-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/PlayerManager.lua
-- *  PURPOSE:     Player manager class
-- *
-- ****************************************************************************
PlayerManager = inherit(Singleton)
addRemoteEvents{"playerReady", "playerSendMoney", "requestPointsToKarma", "requestWeaponLevelUp", "requestVehicleLevelUp",
"requestSkinLevelUp", "requestJobLevelUp", "setPhoneStatus", "toggleAFK", "startAnimation", "passwordChange",
"requestGunBoxData", "gunBoxAddWeapon", "gunBoxTakeWeapon","Event_ClientNotifyWasted", "Event_getIDCardData"}

function PlayerManager:constructor()
	self.m_WastedHook = Hook:new()
	self.m_ReadyPlayers = {}

	-- Register events
	addEventHandler("onPlayerConnect", root, bind(self.playerConnect, self))
	addEventHandler("onPlayerJoin", root, bind(self.playerJoin, self))
	addEventHandler("onPlayerQuit", root, bind(self.playerQuit, self))
	addEventHandler("Event_ClientNotifyWasted", root, bind(self.playerWasted, self))
	addEventHandler("onPlayerChat", root, bind(self.playerChat, self))
	addEventHandler("onPlayerChangeNick", root, function() cancelEvent() end)
	addEventHandler("playerReady", root, bind(self.Event_playerReady, self))
	addEventHandler("playerSendMoney", root, bind(self.Event_playerSendMoney, self))
	addEventHandler("requestPointsToKarma", root, bind(self.Event_requestPointsToKarma, self))
	addEventHandler("requestWeaponLevelUp", root, bind(self.Event_requestWeaponLevelUp, self))
	addEventHandler("requestVehicleLevelUp", root, bind(self.Event_requestVehicleLevelUp, self))
	addEventHandler("requestSkinLevelUp", root, bind(self.Event_requestSkinLevelUp, self))
	addEventHandler("requestJobLevelUp", root, bind(self.Event_requestJobLevelUp, self))
	addEventHandler("playerRequestTrading", root, bind(self.Event_playerRequestTrading, self))
	addEventHandler("setPhoneStatus", root, bind(self.Event_setPhoneStatus, self))
	addEventHandler("toggleAFK", root, bind(self.Event_toggleAFK, self))
	addEventHandler("startAnimation", root, bind(self.Event_startAnimation, self))
	addEventHandler("passwordChange", root, bind(self.Event_passwordChange, self))
	addEventHandler("requestGunBoxData", root, bind(self.Event_requestGunBoxData, self))
	addEventHandler("gunBoxAddWeapon", root, bind(self.Event_gunBoxAddWeapon, self))
	addEventHandler("gunBoxTakeWeapon", root, bind(self.Event_gunBoxTakeWeapon, self))
	addEventHandler("Event_getIDCardData", root, bind(self.Event_getIDCardData, self))




	addCommandHandler("s",bind(self.Command_playerScream, self))
	addCommandHandler("l",bind(self.Command_playerWhisper, self))
	addCommandHandler("BeamtenChat", Player.staticStateFactionChatHandler)
	addCommandHandler("g", Player.staticStateFactionChatHandler)
	addCommandHandler("Fraktion", Player.staticFactionChatHandler)
	addCommandHandler("t", Player.staticFactionChatHandler)
	addCommandHandler("Unternehmen", Player.staticCompanyChatHandler)
	addCommandHandler("u", Player.staticCompanyChatHandler)
	addCommandHandler("Firma/Gang", Player.staticGroupChatHandler)
	addCommandHandler("f", Player.staticGroupChatHandler)

	self.m_PaydayPulse = TimedPulse:new(60000)
	self.m_PaydayPulse:registerHandler(bind(self.checkPayday, self))

	self.m_SyncPulse = TimedPulse:new(500)
	self.m_SyncPulse:registerHandler(bind(PlayerManager.updatePlayerSync, self))

	self.m_AnimationStopFunc = bind(self.stopAnimation, self)
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

function PlayerManager:checkPayday()
	for k, v in pairs(getElementsByType("player")) do
		if v.m_LastPlayTime then
			if v.m_NextPayday == v:getPlayTime() then
				v:payDay()
			end
		end
	end
end

function PlayerManager:getWastedHook()
	return self.m_WastedHook
end

function PlayerManager:getReadyPlayers()
	return self.m_ReadyPlayers
end

function PlayerManager:startPaydayDebug(player)
	player:payDay()
end

function PlayerManager:breakingNews(text, ...)
	for k, v in pairs(getElementsByType("player")) do
		local textFinish = _(text, v, ...)
		v:triggerEvent("breakingNews", textFinish)
	end
end

function PlayerManager:getPlayerFromPartOfName(name, sourcePlayer,noOutput)
	if name and sourcePlayer then
		local matches = {}
		for i, v in ipairs(getElementsByType('player')) do
			if getPlayerName(v) == name then
				return v
			end
			if string.find(string.lower(getPlayerName(v)), string.lower(name), 0, false) then
				table.insert(matches, v)
			end
		end
		if #matches == 1 then
			return matches[1]
		elseif #matches >= 2 then
			if not noOutput then
				outputChatBox('Es wurden '..#matches..' Spieler gefunden! Bitte genauer angeben!', sourcePlayer, 255, 0, 0)
			end
		else
			if not noOutput then
				outputChatBox('Es wurden kein Spieler gefunden!', sourcePlayer, 255, 0, 0)
			end
		end
	end
	return false
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

function PlayerManager:playerQuit()
	local index = table.find(self.m_ReadyPlayers, source)
	if index then
		table.remove(self.m_ReadyPlayers, index)
	end
end

function PlayerManager:Event_playerReady()
	local player = client

	self.m_ReadyPlayers[#self.m_ReadyPlayers + 1] = player

	-- Send server version info
	local version = core:getVersion()
	if version then
		player:triggerEvent("versionReceive", version)
	end
end

function PlayerManager:playerWasted( killer, killerWeapon, bodypart )
	if killer and killer:getType() == "player" then
		if killer ~= source then
			if killer:isFactionDuty() and not source:isFactionDuty() then
				local wantedLevel = source:getWantedLevel()
				if wantedLevel > 0 then
					source:sendInfo(_("Du wurdest ins Gefängnis gesteckt!", source))
					FactionState:getSingleton():Event_JailPlayer(source, false, true, killer)
					return
				end
			end
		end
	end
		-- Call wasted hook
	if self.m_WastedHook:call(source) then
		return
	end

	source:triggerEvent("playerWasted")

	if FactionRescue:getSingleton():countPlayers() > 0 then
		if not source.m_DeathPickup then
			FactionRescue:getSingleton():createDeathPickup(source)
			return true
		else -- This should never never happen!
			outputDebug("Internal Error! Player died while he is Dead. Dafuq?")
		end
	end

	return false
	--source:sendInfo(_("Du hattest Glück und hast die Verletzungen überlebt. Doch pass auf, dass es nicht wieder passiert!", source))
	--source:triggerEvent("playerSendToHospital")
	--setTimer(function(player) if player and isElement(player) then player:respawn() end end, 60000, 1, source)
end


function PlayerManager:playerChat(message, messageType)
	if Player.getChatHook():call(source, message, messageType) then
		cancelEvent()
		return
	end

	-- Look for special Chars (e.g. '@l': Local Chat, at Interview)
	if message:sub(1, 2):lower() == "@l" then
		message = message:sub(3, #message)
	end

	if messageType == 0 then
		local phonePartner = source:getPhonePartner()
		if not phonePartner then
			local playersToSend = source:getPlayersInChatRange( 1 )
			for index = 1,#playersToSend do
				outputChatBox(getPlayerName(source).." sagt: #FFFFFF"..message, playersToSend[index], 220, 220, 220,true)
			end
		else
			-- Send handy message
			outputChatBox(_("%s (Telefon): %s", phonePartner, getPlayerName(source), message), phonePartner, 0, 255, 0)
			outputChatBox(_("%s (Telefon): %s", source, getPlayerName(source), message), source, 0, 255, 0)
		end
		cancelEvent()
	elseif messageType == 1 then
		source:meChat(false, message)
		cancelEvent()
	end
end

function PlayerManager:Command_playerScream(source , cmd, ...)
	local argTable = { ... }
	local text = table.concat ( argTable , " " )
	local playersToSend = source:getPlayersInChatRange(2)
	for index = 1,#playersToSend do
		outputChatBox(getPlayerName(source).." schreit: #FFFFFF"..text, playersToSend[index], 240, 240, 240,true)
	end
end

function PlayerManager:Command_playerWhisper(source , cmd, ...)
	local argTable = { ... }
	local text = table.concat(argTable , " ")
	local playersToSend = source:getPlayersInChatRange(0)
	for index = 1,#playersToSend do
		outputChatBox(getPlayerName(source).." flüstert: #FFFFFF"..text, playersToSend[index], 140, 140, 140,true)
	end
end

function PlayerManager:Event_playerSendMoney(amount)
	if not client then return end
	amount = math.floor(amount)
	if amount <= 0 then return end
	if client:getMoney() >= amount then
		client:takeMoney(amount, "Spieler-Zahlung")
		source:giveMoney(amount, "Spieler-Zahlung")
		source:sendShortMessage(_("Du hast %d$ von %s bekommen!", source, amount, client:getName()))
	end
end

function PlayerManager:Event_requestPointsToKarma(positive)
	if client:getPoints() >= 200 then
		client:giveKarma(1, (positive and 1 or -1), true)
		client:givePoints(-200)
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

function PlayerManager:Event_playerRequestTrading()
	-- TODO: Add accept prompt box
	client:startTrading(source)
end

function PlayerManager:Event_setPhoneStatus(state)
	client:togglePhone(state)
end

function PlayerManager:Event_toggleAFK(state, teleport)
	client:setPublicSync("AFK", state)
	if state == true then
		client:startAFK()
		if client:isInVehicle() then client:removeFromVehicle() end
		client:setInterior(4)
		client:setDimension(0)
		local afkPos = AFK_POSITIONS[math.random(0, #AFK_POSITIONS)]
		if teleport then
			client:setPosition(afkPos.x, afkPos.y, 999.5546875)
		end
	else
		client:endAFK()
	end
end

function PlayerManager:Event_startAnimation(animation)
	if ANIMATIONS[animation] then
		local ani = ANIMATIONS[animation]
		client:setAnimation(ani["block"], ani["animation"], -1, ani["loop"], true, ani["interruptable"], ani["freezeLastFrame"])
		bindKey(client, "space", "down", self.m_AnimationStopFunc)
	else
		client:sendError("Internal Error! Animation nicht gefunden!")
	end
end

function PlayerManager:stopAnimation(player)
	player:setAnimation(false)
	unbindKey(player, "space", "down", self.m_AnimationStopFunc)

	-- Tell the client
	player:triggerEvent("onClientAnimationStop")
end

function PlayerManager:Event_passwordChange(old, new1, new2)
	--Todo: Kurzfristig deaktiviert wegen Forum Login
	client:sendError("Funktion deaktiviert!", client)
	if true then return false end

	if new1 == new2 then
		local row = sql:queryFetchSingle("SELECT Id, Salt, Password FROM ??_account WHERE Name = ? ", sql:getPrefix(), client:getName())
		if row then
			local oldPwhash = sha256(row.Salt..old)
			if oldPwhash == row.Password then
				local newSalt = md5(math.random())
				local newPwhash = sha256(newSalt..new1)
				sql:queryExec("UPDATE ??_account SET Password = ?, Salt = ? WHERE Name = ? ", sql:getPrefix(), newPwhash, newSalt, client:getName())
				client:sendInfo("Dein neues Passwort wurde gespeichert!", client)
				client:triggerEvent("passwordChangeSuccess")
			else
				client:sendError("Dein bisheriges Passwort ist nicht korrekt!", client)
			end
		else
			client:sendError("Internal Error @Password Change!", client)
		end
	else
		client:sendError("Die beiden eingegebenen neuen Passwörter sind nicht identisch!", client)
	end
end

function PlayerManager:Event_requestGunBoxData()
	client:triggerEvent("receiveGunBoxData", client.m_GunBox)
end

function PlayerManager:Event_gunBoxAddWeapon(weaponId, muni)
	for i= 1, 6 do
		if not client.m_GunBox[tostring(i)] then
			client.m_GunBox[tostring(i)] = {}
			client.m_GunBox[tostring(i)]["WeaponId"] = 0
			client.m_GunBox[tostring(i)]["Amount"] = 0
		end
		local slot = client.m_GunBox[tostring(i)]
		if slot["WeaponId"] == 0 then
			local weaponSlot = getSlotFromWeapon(weaponId)
			if client:getWeapon(weaponSlot) > 0 then
				if client:getTotalAmmo(weaponSlot) >= muni then
					client:takeWeapon(weaponId)
					slot["WeaponId"] = weaponId
					slot["Amount"] = muni
					client:sendInfo(_("Du hast eine/n %s mit %d Schuss in deine Waffenbox (Slot %d) gelegt!", client, WEAPON_NAMES[weaponID], muni, i))
					client:triggerEvent("receiveGunBoxData", client.m_GunBox)
					return
				else
					client:sendInfo(_("Du hast nicht genug %s Munition!", client, WEAPON_NAMES[weaponID]))
					client:triggerEvent("receiveGunBoxData", client.m_GunBox)
					return
				end
			else
				client:sendInfo(_("Du hast keine/n %s!", client, WEAPON_NAMES[weaponID]))
				client:triggerEvent("receiveGunBoxData", client.m_GunBox)
				return
			end
		end
	end
	client:sendError(_("Du hast keinen freien Waffen-Slot in deiner Waffenbox!", client))
end

function PlayerManager:Event_gunBoxTakeWeapon(slotId)
	local slot = client.m_GunBox[tostring(slotId)]
	if slot then
		if slot["WeaponId"] > 0 then
			if slot["Amount"] > 0 then
				local weaponId = slot["WeaponId"]
				local amount = slot["Amount"]
				if client:getWeapon(getSlotFromWeapon(weaponId)) == 0 then
					slot["WeaponId"] = 0
					slot["Amount"] = 0
					client:giveWeapon(weaponId, amount)
					client:sendInfo(_("Du hast eine/n %s mit %d Schuss aus deiner Waffenbox (Slot %d) genommen!", client, WEAPON_NAMES[weaponId], amount, slotId))
					client:triggerEvent("receiveGunBoxData", client.m_GunBox)
					return
				else
					client:sendError(_("Du hast bereits eine Waffe dieser Art dabei!", client))
					client:triggerEvent("receiveGunBoxData", client.m_GunBox)
					return
				end
			else
				client:sendError("Internal Error Amount to low", client)
				client:triggerEvent("receiveGunBoxData", client.m_GunBox)
				return
			end
		else
			client:sendError(_("Du hast keine Waffe in diesem Slot!", client))
			client:triggerEvent("receiveGunBoxData", client.m_GunBox)
			return
		end
	end
end

function PlayerManager:Event_getIDCardData(target)
	client:triggerEvent("Event_receiveIDCardData",
		target:hasDrivingLicense(), target:hasBikeLicense(), target:hasTruckLicense(), target:hasPilotsLicense(),
		target:getRegistrationDate(),
		target:getJobLevel(), target:getWeaponLevel(), target:getVehicleLevel(), target:getSkinLevel()
	)
end
