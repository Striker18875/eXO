--WEB (PHP mtasdk)

function phpSDKGetPlayers()
	local name
	local players = {}
	local i = 1
	for index, player in pairs(getElementsByType("player")) do
		players[i]={}
		players[i]["pname"] = player:getName()
		i = i+1
	end
	return players
end

function phpSDKSendChatBox(type, target, message, r, g, b)
	if type == "admin" then
		Admin:getSingleton():sendMessage(message, r, g, b, type(target) == "number" and target or 1)
	elseif type == "player" then
		local target = getPlayerFromName(target)
		if isElement(target) then
			target:outputChat(message, r, g, b)
		end
	end
	return
end

function phpSDKLoadCharacterInfo(targetName) -- Cause of Migrator
	local target = getPlayerFromName(targetName)
	if isElement(target) then
		target:loadMigratorData()
	end
end

function phpSDKSendActivationMailCallback(answer)
	outputChatBox("phpSDKSendActivationMailCallback: "..answer)
end

function phpSDKSendActivationMail(userID, username)
	callRemote(INGAME_WEB_PATH .. "/ingame/boardActivation.php", phpSDKSendActivationMailCallback, userID, username)
end

function phpSDKSendOnlinePlayers()
	local players = {}
	local i = 1

	for index, player in pairs(getElementsByType("player")) do
		if player.isActive and player:isActive() then
			players[i]= {
				["Name"] = player:getName(),
				["Id"] = player:getId() or 0,
				["Faction"] = player:getFaction() and player:getFaction():getId() or 0,
				["Company"] = player:getCompany() and player:getCompany():getId() or 0,
				["GroupId"] = player:getGroup() and player:getGroup():getId() or 0,
				["PlayTime"] = player:getPlayTime() or 0,
			}
			i = i+1
		end
	end
	return players
end

function phpSDKGiveQRAchievement(playerId)
	Async.create(
		function()
			local player, isOffline = DatabasePlayer.get(playerId)
			if isOffline then
				player:load()
				delete(player)
				return false
			else
				player:giveAchievement(78)
				return true
			end
		end
	)()
end

function phpSDKKickPlayer(adminId, targetId, reason)
	local target = DatabasePlayer.Map[targetId]

	if not isElement(target) or target:getType() ~= "player" then
		local data = toJSON({status = "ERROR", error = "TARGET_OFFLINE"}, true)
		outputServerLog(data:sub(2, #data-1))
		return data:sub(2, #data-1)
	end

	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		outputServerLog(data:sub(2, #data-1))
		return data:sub(2, #data-1)
	end

	if not duration then
		local data = toJSON({status = "ERROR", error = "DURATION_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	Admin:getSingleton():sendShortMessage(_("%s hat %s gekickt! Grund: %s", nil, adminName, targetName, reason))
	outputChatBox("Der Spieler "..targetName.." wurde von "..adminName.." gekickt!",root, 200, 0, 0)
	outputChatBox("Grund: "..reason,root, 200, 0, 0)

	if isElement(admin) then
		kickPlayer(target, admin, reason)
	else
		kickPlayer(target, reason)
	end

	if aCreated then
		delete(admin)
	end

	if tCreated then
		delete(target)
	end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKBanPlayer(adminId, targetId, duration, reason)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	if not duration then
		local data = toJSON({status = "ERROR", error = "DURATION_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local duration = tonumber(duration)

	if not duration or duration < 0 then
		local data = toJSON({status = "ERROR", error = "DURATION_INVALID"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	if duration == 0 then -- perma
		Admin:getSingleton():sendShortMessage(_("%s hat %s permanent gebannt! Grund: %s", nil, adminName,targetName, reason))
		Admin:getSingleton():addPunishLog(adminId, targetId, "permabanCP", reason, 0)
		outputChatBox(_("Der Spieler %s  wurde von %s gebannt!", nil, targetName, adminName), root, 200, 0, 0)
		outputChatBox(_("Grund: %s", nil, reason), root, 200, 0, 0)
		Ban.addBan(targetId, adminId, reason, 0, adminName)
	else -- time
		Admin:getSingleton():sendShortMessage(_("%s hat %s für %d Stunden gebannt! Grund: %s", nil, adminName, targetName, duration, reason))
		Admin:getSingleton():addPunishLog(adminId, targetId, "timebanCP", reason, duration * 60 * 60)
		outputChatBox(_("Der Spieler %s  wurde von %s für %d Stunden gebannt!", nil, targetName, adminName, duration), root, 200, 0, 0)
		outputChatBox(_("Grund: %s", nil, reason), root, 200, 0, 0)
		Ban.addBan(targetId, adminId, reason, duration * 60 * 60, adminName)
	end

	if aCreated then
		delete(admin)
	end

	if tCreated then
		delete(target)
	end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKUnbanPlayer(adminId, targetId, reason)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	Admin:getSingleton():sendShortMessage(_("%s hat %s offline entbannt!", nil, adminName, targetName))
	Admin:getSingleton():addPunishLog(adminId, targetId, "offlineUnbanCP", reason, 0)
	sql:queryExec("DELETE FROM ??_bans WHERE serial = ? OR player_id = ?;", sql:getPrefix(), Account.getLastSerialFromId(targetId), targetId)
	outputChatBox(_("Der Spieler %s wurde von %s entbannt!", nil, targetName, adminName), root, 200, 0, 0)

	if aCreated then
		delete(admin)
	end

	if tCreated then
		delete(target)
	end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKAddWarn(adminId, targetId, duration, reason)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	if not duration then
		local data = toJSON({status = "ERROR", error = "DURATION_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local duration = tonumber(duration)

	if not duration or duration < 0 then
		local data = toJSON({status = "ERROR", error = "DURATION_INVALID"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	Warn.addWarn(targetId, adminId, reason, duration*60*60*24)
	Admin:getSingleton():addPunishLog(adminId, targetId, "offlineWarnCP", reason, duration*60*60*24)
	Admin:getSingleton():sendShortMessage(_("%s hat %s verwarnt! Ablauf in %d Tagen, Grund: %s", nil, adminName, targetName, duration, reason))

	if target and isElement(target) then
		target:sendMessage(_("Du wurdest von %s verwarnt! Ablauf in %s Tagen, Grund: %s", target, adminName, duration, reason), 255, 0, 0)
	end

	if aCreated then
		delete(admin)
	end

	if tCreated then
		delete(target)
	end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKRemoveWarn(adminId, targetId, warnId)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	Warn.removeWarn(targetId, warnId)
	Admin:getSingleton():addPunishLog(adminId, targetId, "removeOfflineWarnCP", nil, 0)
	Admin:getSingleton():sendShortMessage(_("%s hat einen Warn von %s entfernt!", nil, adminName, targetName))

	if aCreated then
		delete(admin)
	end

	if tCreated then
		delete(target)
	end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKTakeScreenShot(userId)
	local player = DatabasePlayer.Map[userId]

	if player and isElement(player) then
		local tag = string.random(128)
		local status = player:takeScreenShot(800, 600, "cp:" .. tag, 30, 1024 * 512, 500)
		if status then
			local data = toJSON({status = "SUCCESS", tag = tag}, true)
			return data:sub(2, #data-1)
		else
			local data = toJSON({status = "ERROR", error = "FAILED"}, true)
			return data:sub(2, #data-1)
		end
	else
		local data = toJSON({status = "ERROR", error = "PLAYER_IS_OFFLINE"}, true)
		return data:sub(2, #data-1)
	end
end


addEventHandler("onPlayerScreenShot", root, function(resource, status, pixels, timestamp, tag)
	if resource == getThisResource() then
		if tag:sub(0, 3) == "cp:" then
			local tag = tag:sub(4, #tag)
			if status == "ok" then
				fetchRemote("https://cp.exo-reallife.de/api/admin/screenshots", {
					method = "POST",
					formFields = {
						status = "SUCCESS",
						data = pixels,
						tag = tag
					}
				}, function() end)
			elseif status == "minimized" then
				fetchRemote("https://cp.exo-reallife.de/api/admin/screenshots", {
					method = "POST",
					formFields = {
						status = "ERROR",
						error = "MINIMIZED",
						tag = tag
					}
				}, function() end)
			elseif status == "disabled" then
				fetchRemote("https://cp.exo-reallife.de/api/admin/screenshots", {
					method = "POST",
					formFields = {
						status = "ERROR",
						error = "DISABLED",
						tag = tag
					}
				}, function() end)
			end
		end
	end
end)
