-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Admin.lua
-- *  PURPOSE:     Admin class
-- *
-- ****************************************************************************
Admin = inherit(Singleton)

function Admin:constructor()
    self.m_OnlineAdmins = {}
    self.m_SupportArrow = {}
    self.m_RankNames = {
        [1] = "Supporter",
        [2] = "Moderator",
        [3] = "Super-Moderator",
        [4] = "Administrator",
        [5] = "Projektleiter"
    }

    addRemoteEvents{"adminSetPlayerFaction", "adminSetPlayerCompany", "adminTriggerFunction"}

    addCommandHandler("admins", bind(self.onlineList, self))
    addCommandHandler("a", bind(self.chat, self))
    addCommandHandler("o", bind(self.ochat, self))
    addCommandHandler("adminmenu", bind(self.openAdminMenu, self))
    addCommandHandler("goto", bind(self.goToPlayer, self))
    addCommandHandler("gethere", bind(self.getHerePlayer, self))
    addCommandHandler("tp", bind(self.teleportTo, self))
    addCommandHandler("addFactionVehicle", bind(self.addFactionVehicle, self))
    addCommandHandler("addCompanyVehicle", bind(self.addCompanyVehicle, self))
    addCommandHandler("addCompanyVehicle", bind(self.addCompanyVehicle, self))

    local adminCommandBind = bind(self.command, self)

    addCommandHandler("timeban", adminCommandBind)
    addCommandHandler("permaban", adminCommandBind)
    addCommandHandler("prison", adminCommandBind)
    addCommandHandler("smode", adminCommandBind)
    addCommandHandler("rkick", adminCommandBind)
    addCommandHandler("warn", adminCommandBind)


    addEventHandler("adminSetPlayerFaction", root, bind(self.Event_adminSetPlayerFaction, self))
    addEventHandler("adminSetPlayerCompany", root, bind(self.Event_adminSetPlayerCompany, self))
    addEventHandler("adminTriggerFunction", root, bind(self.Event_adminTriggerFunction, self))
end

function Admin:destructor()
	removeCommandHandler("admins", bind(self.onlineList, self))
    removeCommandHandler("timeban", adminCommandBind)
    removeCommandHandler("permaban", adminCommandBind)
    removeCommandHandler("prison", adminCommandBind)
    removeCommandHandler("smode", adminCommandBind)
    removeCommandHandler("rkick", adminCommandBind)
    removeCommandHandler("warn", adminCommandBind)
	removeCommandHandler("a", bind(self.chat, self))
	removeCommandHandler("o", bind(self.ochat, self))
end

function Admin:addAdmin(player,rank)
	outputDebug("Added Admin "..player:getName())
	self.m_OnlineAdmins[player] = rank
end

function Admin:removeAdmin(player)
	self.m_OnlineAdmins[player] = nil
end

function Admin:openAdminMenu( player )
	if self.m_OnlineAdmins[player] > 0 then
		triggerClientEvent(player,"showAdminMenu",player)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:command(admin, cmd, targetName, arg1, arg2)
    if cmd == "smode" then
        self:Event_adminTriggerFunction(cmd, nil, nil, nil, admin)
    else
        if targetName and arg1 then
            local target = PlayerManager:getSingleton():getPlayerFromPartOfName(targetName, admin)
            if isElement(target) then
                if cmd == "rkick" then
                    self:Event_adminTriggerFunction(cmd, target, arg1, 0, admin)
                else
                    if arg2 then
                        self:Event_adminTriggerFunction(cmd, target, arg2, arg1, admin)
                    else
                        admin:sendError(_("Befehl: /%s [Ziel] [Dauer] [Grund]", admin, cmd))
                    end
                end
            end
        else
            if cmd == "rkick" then
                admin:sendError(_("Befehl: /%s [Ziel] [Grund]", admin, cmd))
            else
                admin:sendError(_("Befehl: /%s [Ziel] [Dauer] [Grund]", admin, cmd))
            end
        end
    end
end

function Admin:Event_adminTriggerFunction(func, target, reason, duration, admin)
    if client and isElement(client) then
        admin = client
    elseif isElement(admin) then
        admin = admin
    else
        outputDebug("Event_adminTriggerFunction Error - Admin not found")
        return
    end

    if admin:getRank() >= ADMIN_RANK_PERMISSION[func] then
        if func == "goto" then
            self:goToPlayer(admin, func, target:getName())
        elseif func == "gethere" then
            self:getHerePlayer(admin, func, target:getName())
        elseif func == "kick" or func == "rkick" then
            self:sendShortMessage(_("%s hat %s gekickt! Grund: %s", admin, admin:getName(), target:getName(), reason))
            target:kick(admin, reason)
        elseif func == "prison" then
            duration = tonumber(duration)
            self:sendShortMessage(_("%s hat %s für %d Minuten ins Prison gesteckt! Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
            target:setPrison(duration*60)
            self:addPunishLog(admin, target, func, reason, duration*60)
        elseif func == "timeban" then
            duration = tonumber(duration)
            self:sendShortMessage(_("%s hat %s für %d Stunden gebannt! Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
            Ban.addBan(target, admin, reason, duration*60*60)
            self:addPunishLog(admin, target, func, reason, duration*60*60)
        elseif func == "permaban" then
            self:sendShortMessage(_("%s hat %s permanent gebannt! Grund: %s", admin, admin:getName(), target:getName(), reason))
            Ban.addBan(target, admin, reason)
            self:addPunishLog(admin, target, func, reason, 0)
        elseif func == "addWarn" or func == "warn" then
            self:sendShortMessage(_("%s hat %s verwarnt! Ablauf in %d Tagen, Grund: %s", admin, admin:getName(), target:getName(), duration, reason))
            Warn.addWarn(target, admin, reason, duration*60*60*24)
            target:sendMessage(_("Du wurdest von %s verwarnt! Ablauf in %s Tagen, Grund: %s", target, admin:getName(), duration, reason), 255, 0, 0)
            self:addPunishLog(admin, target, func, reason, duration*60*60*24)
        elseif func == "removeWarn" then
            self:sendShortMessage(_("%s hat einen Warn von %s entfernt!", admin, admin:getName(), target:getName()))
            local id = reason
            Warn.removeWarn(target, id)
            self:addPunishLog(admin, target, func, "", 0)
        elseif func == "supportMode" or func == "smode" then
            self:toggleSupportMode(admin)
        end
    else
        admin:sendError(_("Du darst diese Aktion nicht ausführen!", admin))
    end
end

function Admin:chat(player,cmd,...)
	if player:getRank() >= RANK.Supporter then
		local msg = table.concat( {...}, " " )
		if self.m_RankNames[player:getRank()] then
			local text = ("[ %s %s ]: %s"):format(_(self.m_RankNames[player:getRank()], player), player:getName(), msg)
			self:sendMessage(text,255,255,0)
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:toggleSupportMode(player)
    if not player:getPublicSync("supportMode") then
        player:setPublicSync("supportMode", true)
        player:sendInfo(_("Support Modus aktiviert!", player))
        self:sendShortMessage(_("%s hat den Support Modus aktiviert!", player, player:getName()))
        player:setModel(260)
        player:triggerEvent("playerToggleDamage", true)
        self:toggleSupportArrow(player, true)
    else
        player:setPublicSync("supportMode", false)
        player:sendInfo(_("Support Modus deaktiviert!", player))
        self:sendShortMessage(_("%s hat den Support Modus deaktiviert!", player, player:getName()))
        player:setDefaultSkin()
        player:triggerEvent("playerToggleDamage", false)
        self:toggleSupportArrow(player, false)
    end
end

function Admin:toggleSupportArrow(player, state)
	if state == true then
		if isElement(self.m_SupportArrow[player]) then self.m_SupportArrow[player]:destroy() end
        local pos = player:getPosition()
		self.m_SupportArrow[player] = createMarker(pos, "arrow" ,0.5, 255, 255, 0)
        self.m_SupportArrow[player]:attach(player, 0, 0, 1.5)
        self.m_DeleteArrowBind = bind(self.deleteArrow, self)
		addEventHandler("onPlayerQuit", player, self.m_DeleteArrowBind)
		addEventHandler("onPlayerWasted", player, self.m_DeleteArrowBind)
	elseif state == false then
        if isElement(self.m_SupportArrow[player]) then self.m_SupportArrow[player]:destroy() end
        removeEventHandler("onPlayerQuit", player, self.m_DeleteArrowBind)
		removeEventHandler("onPlayerWasted", player, self.m_DeleteArrowBind)
	end
end

function Admin:deleteArrow()
    if isElement(self.m_SupportArrow[source]) then self.m_SupportArrow[source]:destroy() end
end

function Admin:sendMessage(msg,r,g,b)
	for key, value in pairs(self.m_OnlineAdmins) do
		outputChatBox(msg, key, r,g,b)
	end
end

function Admin:sendShortMessage(text, ...)
	for player, rank in pairs(self.m_OnlineAdmins) do
		player:sendShortMessage(("Admin: %s"):format(text), ...)
	end
end

function Admin:ochat(player,cmd,...)
	if player:getRank() >= RANK.Supporter then
		local rankName = self.m_RankNames[player:getRank()]
		local msg = table.concat( {...}, " " )
		outputChatBox(("[ %s %s ]: %s"):format(_(rankName, player), player:getName(), msg), root, 50, 200, 255)
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:onlineList(player)
	outputChatBox("Folgende Teammitglieder sind derzeit online:",player,50,200,255)
	for key, value in pairs(self.m_OnlineAdmins) do
		outputChatBox(self.m_RankNames[value].." "..key:getName(),player,255,255,255)
	end
end

function Admin:goToPlayer(player,cmd,target)
	if player:getRank() >= RANK.Supporter then
		if target then
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
                self:sendShortMessage(_("%s hat %s zu sich geportet!", player, player:getName(), target:getName()))
                local dim,int = target:getDimension(), target:getInterior()
				local pos = target:getPosition()
				pos.x = pos.x + 0.01
				if player:isInVehicle() then player:removeFromVehicle() end
				player:setPosition(pos)
				player:setDimension(dim)
				player:setInterior(int)
			end
		else
			player:sendError(_("Kein Ziel eingegeben!", player))
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:getHerePlayer(player, cmd, target)
	if player:getRank() >= RANK.Supporter then
		if target then
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
                self:sendShortMessage(_("%s hat %s zu sich geportet!", player, player:getName(), target:getName()))
                local dim,int = player:getDimension(), player:getInterior()
				local pos = player:getPosition()
				pos.x = pos.x + 0.01
				if target:isInVehicle() then target:removeFromVehicle() end
				target:setPosition(pos)
				target:setDimension(dim)
				target:setInterior(int)
			end
		else
			player:sendError(_("Kein Ziel eingegeben!", player))
		end
	else
		player:sendError(_("Du bist kein Admin!", player))
	end
end

function Admin:teleportTo(player,cmd,ort)
	local tpTable = {
		["noobspawn"] = 	{["x"]= 1481.288, ["y"]=-1753.393, ["z"]=13.54687,["typ"] = "Orte"},
		["mountchilliard"] ={["x"]=-2321.659, ["y"]=-1638.790, ["z"]=483.7031,["typ"] = "Orte"},
		["startower"] = 	{["x"]=1544.0634, ["y"]=-1352.865, ["z"]=329.4750,["typ"] = "Orte"},
		["buehne"] = 		{["x"]=318.84375, ["y"]=-1801.556, ["z"]=4.633217,["typ"] = "Orte"},
		["casino"] = 		{["x"]=1821.6538, ["y"]=-1684.816, ["z"]=13.38281,["typ"] = "Orte"},
		["paintball"] = 	{["x"]=1849.3808, ["y"]=-1257.169, ["z"]=13.39062,["typ"] = "Orte"},
		["ammu"] = 			{["x"]=1357.5644, ["y"]=-1280.081, ["z"]=13.29938,["typ"] = "Orte"},
		["sannews"] = 		{["x"]=757.33300, ["y"]=-1400.400, ["z"]=13.36718,["typ"] = "Unternehmen"},
		["fahrschule"] = 	{["x"]=1372.3007, ["y"]=-1655.556, ["z"]=13.38281,["typ"] = "Unternehmen"},
		["mech"] = 			{["x"]=886.21777, ["y"]=-1220.473, ["z"]=16.97656,["typ"] = "Unternehmen"},
		["pt"] = 			{["x"]=1821.6269, ["y"]=-1886.315, ["z"]=13.35982,["typ"] = "Unternehmen"},
		["rnd"] = 			{["x"]=2898.3359, ["y"]=-774.2070, ["z"]=10.84404,["typ"] = "Unternehmen"},
		["grove"] = 		{["x"]=2492.4296, ["y"]=-1664.581, ["z"]=13.34375,["typ"] = "Fraktionen"},
		["army"] = 			{["x"]=2706.7177, ["y"]=-2405.295, ["z"]=13.51257,["typ"] = "Fraktionen"},
		["atzecas"] = 		{["x"]=382.73831, ["y"]=2232.8793, ["z"]=42.09375,["typ"] = "Fraktionen"},
		["lcn"] = 			{["x"]=722.83886, ["y"]=-1196.875, ["z"]=19.12306,["typ"] = "Fraktionen"},
		["rescue"] = 		{["x"]=1795.0996, ["y"]=-1757.618, ["z"]=13.54687,["typ"] = "Fraktionen"},
		["yakuza"] = 		{["x"]=757.33300, ["y"]=-1400.400, ["z"]=13.36718,["typ"] = "Fraktionen"},
		["fbi"] = 			{["x"]=1634.0410, ["y"]=-1739.902, ["z"]=13.53907,["typ"] = "Fraktionen"},
		["lspd"] = 			{["x"]=1535.3554, ["y"]=-1673.450, ["z"]=13.38281,["typ"] = "Fraktionen"},
		["vatos"] = 		{["x"]=2691.6318, ["y"]=-2003.450, ["z"]=13.39194,["typ"] = "Fraktionen"},
		["biker"] = 		{["x"]=667.99609, ["y"]=-485.0830, ["z"]=16.18750,["typ"] = "Fraktionen"},
		["area"] = 			{["x"]=112.34863, ["y"]=1963.3906, ["z"]=18.98105,["typ"] = "Fraktionen"},
		["lv"] = 			{["x"]=1797.1542, ["y"]=843.14648, ["z"]=10.63281,["typ"] = "Städte"},
		["sf"] = 			{["x"]=1991.0194, ["y"]=154.79472, ["z"]=27.53906,["typ"] = "Städte"},
		["ls"] =			{["x"]=1507.3977, ["y"]=-959.6733, ["z"]=36.24750,["typ"] = "Städte"}
	}
	local x,y,z = 0,0,0
	if ort then
		for k,v in pairs(tpTable) do
			if ort == k then
				if isPedInVehicle(player) then removePedFromVehicle(player) end
				setElementPosition(player,v["x"],v["y"],v["z"])
				return
			end
		end
		player:sendError(_("Ungültiger Ort! Tippe /tp um alle Orte zu sehen!", player))
	else
		outputChatBox("Hier sind alle Orte aufgelistet:", player, 255, 255, 255 )
		local strings = {}
		for k,v in pairs(tpTable) do
			if not strings[v["typ"]] then strings[v["typ"]] = "" end
			strings[v["typ"]] = strings[v["typ"]]..k.."|"
		end
		for v in pairs(strings) do
			outputChatBox(v..": "..strings[v], player, 0, 125, 0 )
		end
	end
end

function Admin:addPunishLog(admin, player, type, reason, duration)
    StatisticsLogger:getSingleton():addPunishLog(admin, player, type, reason, duration)

end

function Admin:Event_adminSetPlayerFaction(targetPlayer,Id)
	if client:getRank() >= RANK.Supporter then

        if targetPlayer:getFaction() then targetPlayer:getFaction():removePlayer(targetPlayer) end

        if Id == 0 then
            client:sendInfo(_("Du hast den Spieler aus seiner Fraktion entfernt!", client))
        else
            local faction = FactionManager:getSingleton():getFromId(Id)
    		if faction then
    			faction:addPlayer(targetPlayer,6)
    			client:sendInfo(_("Du hast den Spieler in die Fraktion "..faction:getName().." gesetzt!", client))
    		else
    			client:sendError(_("Fraktion nicht gefunden!", client))
    		end
        end

	end
end

function Admin:Event_adminSetPlayerCompany(targetPlayer,Id)
	if client:getRank() >= RANK.Supporter then
        if targetPlayer:getCompany() then targetPlayer:getCompany():removePlayer(targetPlayer) end
        if Id == 0 then
            client:sendInfo(_("Du hast den Spieler aus seinem Unternehmen entfernt!", client))
        else
            local company = CompanyManager:getSingleton():getFromId(Id)
    		if company then
    			company:addPlayer(targetPlayer,5)
    			client:sendInfo(_("Du hast den Spieler in das Unternehmen "..company:getName().." gesetzt!", client))
    		else
    			client:sendError(_("Unternehmen nicht gefunden!", client))
    		end
        end
	end
end

function Admin:addFactionVehicle(player, cmd, factionID)
	if player:getRank() >= RANK.Supporter then
		if isPedInVehicle(player) then
			if factionID then
				factionID = tonumber(factionID)
				local faction = FactionManager:getFromId(factionID)
				if faction then
					local veh = getPedOccupiedVehicle(player)
					local model = getElementModel(veh)
					local posX, posY, posZ = getElementPosition(veh)
					local rotX, rotY, rotZ = getElementRotation(veh)
					FactionVehicle:create(faction, model, posX, posY, posZ, rotZ)
				else
					player:sendError(_("Fraktion nicht gefunden!", player))
				end
			else
				player:sendError(_("Befehl: /addFactionVehicle [FactionID]!", player))
			end
		else
			player:sendError(_("Du sitzt in keinem Fahrzeug!", player))
		end
	end
end

function Admin:addCompanyVehicle(player, cmd, companyID)
	if player:getRank() >= RANK.Supporter then
		if isPedInVehicle(player) then
			if companyID then
				companyID = tonumber(companyID)
				local company = CompanyManager:getFromId(companyID)
				if company then
					local veh = getPedOccupiedVehicle(player)
					local posX, posY, posZ = getElementPosition(veh)
					local rotX, rotY, rotZ = getElementRotation(veh)
					CompanyVehicle:create(company, veh.model, posX, posY, posZ, rotZ)
				else
					player:sendError(_("Unternehmen nicht gefunden!", player))
				end
			else
				player:sendError(_("Befehl: /addCompanyVehicle [CompanyID]!", player))
			end
		else
			player:sendError(_("Du sitzt in keinem Fahrzeug!", player))
		end
	end
end
