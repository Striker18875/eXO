-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionState.lua
-- *  PURPOSE:     Faction State Class
-- *
-- ****************************************************************************

function switchPlayersRandom()
	local cacheTable = {}
	for i, player in ipairs(getElementsByType("player")) do
		if player.m_LoggedIn then
			local pV = getPedOccupiedVehicle(player)
			if pV then
				local vID = getElementModel(pV)
				local vP = {getElementPosition(pV)}
				local vR = {getElementRotation(pV)}
				local vV = {getElementVelocity(pV)}
				local vTV = {getVehicleTurnVelocity(pV)}
				local ID = #cacheTable + 1
				cacheTable[ID] = {}
				cacheTable[ID].player = player
				cacheTable[ID].vID = vID
				cacheTable[ID].pos = vP
				cacheTable[ID].rot = vR
				cacheTable[ID].velocity = vV
				cacheTable[ID].turnVelocity = vTV
				cacheTable[ID].done = false
			end
		end
	end
	for i, player in ipairs(getElementsByType("player")) do
		if player.m_LoggedIn then
			local pV = getPedOccupiedVehicle(player)
			if pV then
				local rnd = math.random(1, #cacheTable)
				while cacheTable[rnd].done do
					rnd = math.random(1, #cacheTable)
				end

				local targetPlayer = cacheTable[rnd].player
				local vehicleID = cacheTable[rnd].vID
				local x, y, z = unpack(cacheTable[rnd].pos)
				local xr, yr, zr = unpack(cacheTable[rnd].rot)
				local xv, yv, zv = unpack(cacheTable[rnd].velocity)
				local xtv, ytv, ztv = unpack(cacheTable[rnd].turnVelocity)

				setElementModel(pV, vehicleID)
				setElementPosition(pV, x, y, z)
				setElementRotation(pV, xr, yr, zr)
				setElementVelocity(pV, xv, yv, zv)
				setVehicleTurnVelocity(pV, xtv, ytv, ztv)
				cacheTable[rnd].done = true
			end
		end
	end
end

FactionState = inherit(Singleton)

  -- implement by children

function FactionState:constructor()
	self:createArrestZone(1564.92, -1693.55, 5.89) -- PD Garage
	self:createArrestZone(255.19, 84.75, 1002.45, 6)-- PD Zellen
	self:createArrestZone(163.05, 1904.10, 18.67) -- Area
	self:createArrestZone(-1589.91, 715.65, -5.24) -- SF
	self:createArrestZone(2281.71, 2431.59, 3.27) --lv

	self:createGasStation(Vector3(2295.80, 2460.90, 2.30)) -- LVT
	self:createGasStation(Vector3(124.90, 1908.10, 17.9)) -- Area
	self:createGasStation(Vector3(-1623.30, 662.30, -5.80)) -- SF PD
	self:createGasStation(Vector3(-1528.10, 458.10, 6.20)) -- SF Army
	self:createGasStation(Vector3(-1609.10,286.10,6.20), 5) -- SF Army Flug
	self:createGasStation(Vector3(2763.88,-2386.90,13.0), 5) -- LS Army
	self:createGasStation(Vector3(1563.98,-1614.40, 12.5)) -- LS PD
	self:createGasStation(Vector3(1552.93,-1614.40, 12.5)) -- LS PD

	self.m_Bugs = {}

	for i = 1, FACTION_FBI_BUGS do
		self.m_Bugs[i] = {}
	end

	self.m_SelfBailMarker = {}
	self:createSelfArrestMarker(249.67, 69.19, 1003.64, 6,0)
	self.m_Items = {
		["Barrikade"] = 0,
		["Nagel-Band"] = 0,
		["Blitzer"] = 0
	}

	nextframe( -- Todo workaround
		function ()
			self:loadLSPD(1)
			self:loadFBI(2)
			self:loadArmy(3)
		end
	)

	addRemoteEvents{
	"factionStateArrestPlayer", "factionStateGiveWanteds", "factionStateClearWanteds", "factionStateLoadJailPlayers", "factionStateFreePlayer", "playerSelfArrestConfirm",
	"factionStateChangeSkin", "factionStateRearm", "factionStateSwat","factionStateToggleDuty", "factionStateStorageWeapons",
	"factionStateGrabPlayer", "factionStateFriskPlayer", "stateFactionSuccessCuff", "factionStateAcceptTicket",
	"factionStateShowLicenses", "factionStateAcceptShowLicense", "factionStateDeclineShowLicense",
	"factionStateTakeDrugs", "factionStateTakeWeapons", "factionStateGivePANote", "factionStatePutItemInVehicle", "factionStateTakeItemFromVehicle",
	"factionStateFillRepairVehicle", "factionStateLoadBugs", "factionStateAttachBug", "factionStateBugAction", "factionStateCheckBug"
	}
	addCommandHandler("suspect",bind(self.Command_suspect, self))
	addCommandHandler("su",bind(self.Command_suspect, self))
	addCommandHandler("m",bind(self.Command_megaphone, self))
	addCommandHandler("tie",bind(self.Command_tie, self))
	addCommandHandler("needhelp",bind(self.Command_needhelp, self))
	addCommandHandler("bail",bind(self.Command_bail, self))
	addCommandHandler("cuff",bind(self.Command_cuff, self))
	addCommandHandler("uncuff",bind(self.Command_uncuff, self))
	addCommandHandler("ticket",bind(self.Command_ticket, self))

	addEventHandler("factionStateArrestPlayer", root, bind(self.Event_JailPlayer, self))
	addEventHandler("factionStateChangeSkin", root, bind(self.Event_FactionChangeSkin, self))
	addEventHandler("factionStateRearm", root, bind(self.Event_FactionRearm, self))
	addEventHandler("factionStateSwat", root, bind(self.Event_toggleSwat, self))
	addEventHandler("factionStateToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("factionStateStorageWeapons", root, bind(self.Event_storageWeapons, self))
	addEventHandler("factionStateGiveWanteds", root, bind(self.Event_giveWanteds, self))
	addEventHandler("factionStateClearWanteds", root, bind(self.Event_clearWanteds, self))
	addEventHandler("factionStateGrabPlayer", root, bind(self.Event_grabPlayer, self))
	addEventHandler("factionStateFriskPlayer", root, bind(self.Event_friskPlayer, self))
	addEventHandler("factionStateShowLicenses", root, bind(self.Event_showLicenses, self))
	addEventHandler("factionStateTakeDrugs", root, bind(self.Event_takeDrugs, self))
	addEventHandler("factionStateTakeWeapons", root, bind(self.Event_takeWeapons, self))
	addEventHandler("factionStateAcceptShowLicense", root, bind(self.Event_acceptShowLicense, self))
	addEventHandler("factionStateDeclineShowLicense", root, bind(self.Event_declineShowLicense, self))
	addEventHandler("factionStateGivePANote", root, bind(self.Event_givePANote, self))
	addEventHandler("factionStatePutItemInVehicle", root, bind(self.Event_putItemInVehicle, self))
	addEventHandler("factionStateTakeItemFromVehicle", root, bind(self.Event_takeItemFromVehicle, self))
	addEventHandler("factionStateLoadJailPlayers", root, bind(self.Event_loadJailPlayers, self))
	addEventHandler("factionStateFreePlayer", root, bind(self.Event_freePlayer, self))
	addEventHandler("factionStateLoadBugs", root, bind(self.Event_loadBugs, self))
	addEventHandler("factionStateAttachBug", root, bind(self.Event_attachBug, self))
	addEventHandler("factionStateBugAction", root, bind(self.Event_bugAction, self))
	addEventHandler("factionStateCheckBug", root, bind(self.Event_checkBug, self))



	addEventHandler("stateFactionSuccessCuff", root, bind(self.Event_CuffSuccess, self))
	addEventHandler("factionStateAcceptTicket", root, bind(self.Event_OnTicketAccept, self))
	addEventHandler("playerSelfArrestConfirm", root, bind(self.Event_OnConfirmSelfArrest, self))
	addEventHandler("factionStateFillRepairVehicle", root, bind(self.Event_fillRepairVehicle, self))

	-- Prepare the Area51
	self:createDefendActors(
		{
			{Vector3(128.396, 1954.551, 19.428), Vector3(0, 0, 354.965), 287, 31, 25};
			{Vector3(340.742, 1793.668, 18.140), Vector3(0, 0, 216.25), 287, 31, 25};
			{Vector3(350.257, 1800.481, 18.577), Vector3(0, 0, 227.407), 287, 31, 25};
			{Vector3(281.812, 1816.380, 17.970), Vector3(0, 0, 359.113), 287, 31, 25};
			{Vector3(97.468, 1942.034, 34.378), Vector3(0, 0, 19.822), 287, 34, 80};
			{Vector3(161.950, 1935.313, 33.898), Vector3(0, 0, 0.349), 287, 34, 80};
			{Vector3(111.469, 1812.475, 33.898), Vector3(0, 0, 135.428), 287, 34, 80};
			{Vector3(262.044, 1805.083, 33.898), Vector3(0, 0, 173.677), 287, 34, 80};
			{Vector3(384.456, 1961.135, 33.278), Vector3(0, 0, 266.788), 287, 34, 80};
			{Vector3(277.512, 2061.715, 33.678), Vector3(0, 0, 358.1), 287, 34, 80};
		}
	)

	self.onTiedExitBind = bind(self.onTiedExit, self)
end

function FactionState:destructor()
end


function FactionState:createSelfArrestMarker( x,y,z, int, dim )
	local ped = createPed(280, Vector3(251.257, 69.094, 1003.641))
	ped:setRotation(0, 0, 90)
	ped:setInterior(int)
	local marker = createPickup(x,y,z,3,1247,10)
	setElementInterior(marker, int)
	setElementDimension(marker, dim)
	self.m_SelfBailMarker[#self.m_SelfBailMarker+1] = marker
	addEventHandler("onPickupHit",marker, function(hE, bDim)
		if getElementDimension(hE) == getElementDimension(source) then
			if getElementType(hE) == "player" then
				if hE:getWantedLevel() > 0 then
					hE:triggerEvent("playerSelfArrest")
				end
			end
		end
	end)
end

function FactionState:Event_OnConfirmSelfArrest()
	local bailcosts = 0
	local wantedLevel = client:getWantedLevel()
	local jailTime = wantedLevel * 5
	local factionBonus = JAIL_COSTS[wantedLevel]
	bailcosts = BAIL_PRICES[wantedLevel]
	client:setJailTime(jailTime)
	client:setWantedLevel(0)
	client:moveToJail(CUTSCENE)
	self:uncuffPlayer( client)
	client:clearCrimes()
	bailcosts = BAIL_PRICES[wantedLevel]
	client:setJailBail(bailcosts)
	StatisticsLogger:getSingleton():addArrestLog(client, wantedLevel, jailTime, client, bailcosts)
	self:sendMessage("Der Spieler "..client:getName().." hat sich gestellt!", 0, 0,200)
end

function FactionState:loadLSPD(factionId)
	self:createDutyPickup(252.6, 69.4, 1003.64, 6) -- PD Interior
	self:createDutyPickup(1530.21, -1671.66, 6.22) -- PD Garage

	self:createTakeItemsPickup(Vector3(1543.96, -1707.26, 5.89))

	Blip:new("Police.png", 1552.278, -1675.725, root, 400)

	VehicleBarrier:new(Vector3(1544.70, -1630.90, 13.10), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierGateHit, self) -- PD Barrier
	VehicleBarrier:new(Vector3(283.900390625, 1817.7998046875, 17.400001525879), Vector3(0, 90, 90)).onBarrierHit = bind(self.onBarrierGateHit, self) -- Army Barrier

	local gate = Gate:new(9093, Vector3(1588.80, -1638.30, 14.50), Vector3(0, 0, 270), Vector3(1598.80, -1638.30, 14.50))
	gate.onGateHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	gate:setGateScale(1.25)

	local door = Door:new(2949, Vector3(1584.09, -1638.09, 12.30), Vector3(0, 0, 270))
	door.onDoorHit = bind(self.onBarrierGateHit, self) -- PD Garage Gate
	door:setDoorScale(1.1)

	--InteriorEnterExit:new(Vector3(1525.16, -1678.17, 5.89), Vector3(259.22, 73.73, 1003.64), 0, 0, 6, 0) -- LSPD Garage
	--InteriorEnterExit:new(Vector3(1564.84, -1666.84, 28.40), Vector3(226.65, 75.95, 1005.04), 0, 0, 6, 0) -- LSPD Roof

	local elevator = Elevator:new()
	elevator:addStation("UG Garage", Vector3(1525.16, -1678.17, 5.89), 270)
	elevator:addStation("Erdgeschoss", Vector3(259.22, 73.73, 1003.64), 84, 6)
	elevator:addStation("Dach - Heliports", Vector3(1564.84, -1666.84, 28.40), 90)


	local safe = createObject(2332, 241, 77.70, 1004.50, 0, 0, 270)
	safe:setInterior(6)
	FactionManager:getSingleton():getFromId(1):setSafe(safe)

end

function FactionState:loadFBI(factionId)
	self:createDutyPickup(234.04456, 111.82722, 1003.22571, 10, 23) -- FBI Base
	self:createDutyPickup(1510.67871, -1479.12988, 9.50000)

	local safe = createObject(2332, 226.80, 128.50, 1010.20)
	safe:setInterior(10)
	FactionManager:getSingleton():getFromId(1):setSafe(safe)

	local elevator = Elevator:new()
	elevator:addStation("UG Garage", Vector3(1513.28772, -1461.14819, 9.50), 180)
	elevator:addStation("Erdgeschoss", Vector3(266.70, 107.80, 1008.80), 270, 10, 23)
	elevator:addStation("Dach - Heliports", Vector3(1536.08386,-1460.68518,63.8593), 90)


	Gate:new(2938, Vector3(1534.6999511719,-1451.5,15), Vector3(0, 0, 270), Vector3(1534.6999511719,-1451.5,20)).onGateHit = bind(self.onBarrierGateHit, self)
	InteriorEnterExit:new(Vector3(1518.55298,-1452.88684,14.20313), Vector3(238.30, 114.9, 1010.207), 0, 0, 10, 23)
end

function FactionState:loadArmy(factionId)
	self:createDutyPickup(2743.75, -2453.81, 13.86) -- Army-LS
	self:createDutyPickup(247.05, 1859.38, 14.08) -- Army Area

	local safe = createObject(2332, 242.38, 1862.32, 14.08, 0, 0, 0 )
	FactionManager:getSingleton():getFromId(1):setSafe(safe)

	local areaGate = Gate:new(971, Vector3(130.3, 1934.8, 19.1), Vector3(0, 0, 180), Vector3(130.3, 1934.8, 13.7))
	areaGate:addGate(971, Vector3(139.2, 1934.8, 19.1), Vector3(0, 0, 180), Vector3(139.3, 1934.8, 13.7))
	areaGate:addCustomShapes(Vector3(134.93, 1927.58, 19.20), Vector3(135.27, 1941.85, 19.32))
	areaGate.onGateHit = bind(self.onBarrierGateHit, self)

	local areaGarage = Gate:new(7657, Vector3(208, 1875.90, 13.86), Vector3(0, 0, 180), Vector3(200, 1875.90, 13.86))
	areaGarage:addCustomShapes(Vector3(213.97, 1872.14, 13.14), Vector3(213.92, 1880.12, 13.14))
	areaGarage.onGateHit = bind(self.onBarrierGateHit, self)

end

function FactionState:createTakeItemsPickup(pos)
	local pickup = createPickup(pos, 3, 1239, 0)
	addEventHandler("onPickupHit", pickup, function(hitElement)
		if hitElement:getType() == "player" then
			if hitElement.vehicle then
				if hitElement:isFactionDuty() and hitElement:getFaction() and hitElement:getFaction():isStateFaction() == true then
					local veh = hitElement.vehicle
					if instanceof(veh, FactionVehicle) and veh:getFaction():isStateFaction() then
						hitElement:triggerEvent("showStateItemGUI")
						triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, 0, self.m_Items)
					else
						hitElement:sendError(_("Ungültiges Fahrzeug!", hitElement))
					end
				else
					hitElement:sendError(_("Du bist nicht im Dienst!", hitElement))
				end
			else
				hitElement:sendError(_("Du brauchst ein Fahrzeug zum einladen!", hitElement))
			end
		end
	end)

end

function FactionState:countPlayers()
	local count = #self:getOnlinePlayers()
	return count
end

function FactionState:Command_ticket(source, cmd, target)
	if target then
		if type(target) == "string" then
			local targetPlayer = PlayerManager:getSingleton():getPlayerFromPartOfName(target, source)
			if targetPlayer then
				local faction = source:getFaction()
				if not faction then return end
				if not faction:isStateFaction() then return end
				if getDistanceBetweenPoints3D(source:getPosition(), targetPlayer:getPosition()) <= 5 then
					if source ~= targetPlayer then
						if targetPlayer:getWantedLevel() == 1 then
							if targetPlayer:getMoney() >= TICKET_PRICE then
								source.m_CurrentTicket = targetPlayer
								targetPlayer:triggerEvent("stateFactionOfferTicket", source)
								source:sendSuccess(_("Du hast %s ein Ticket für %d$ angeboten!", source,  targetPlayer:getName(), TICKET_PRICE))
							else
								source:sendError(_("%s hat nicht genug Geld dabei! (%d$)", source, targetPlayer:getName(), TICKET_PRICE))
							end
						else
							source:sendError("Der Spieler hat kein oder ein zu hohes Fahndungslevel!")
						end
					else
						source:sendError("Du kannst dir kein Ticket anbieten!")
					end
				else
					source:sendError("Du bist zu weit weg!")
				end
			else
				source:sendError("Ziel nicht gefunden!")
			end
		end
	else outputChatBox("Syntax: Für Staatsbeamte -> /ticket [ziel]", source, 200, 0,0)
	end
end

function FactionState:Event_OnTicketAccept(cop)
	if client then
		if client:getMoney() >= TICKET_PRICE then
			if client:getWantedLevel() == 1 then
				if cop and isElement(cop) then
					cop:sendSuccess(_("%s hat dein Ticket angenommen und bezahlt!", cop, client:getName()))
					cop:getFaction():giveMoney(TICKET_PRICE, "Ticket")
				end
				client:sendSuccess(_("Du hast das Ticket angenommen! Dir wurde 1 Wanted erlassen!", client))
				client:setWantedLevel(0)
				client:takeMoney(TICKET_PRICE, "[SAPD] Kautionsticket")

			end
		end
	end
end
function FactionState:Command_cuff( source, cmd, target )
	if target then
		if type(target) == "string" then
			local targetPlayer = PlayerManager:getSingleton():getPlayerFromPartOfName(target, source)
			if targetPlayer then
				if getDistanceBetweenPoints3D(source:getPosition(), targetPlayer:getPosition()) <= 5 then
					local faction = source:getFaction()
					if faction then
						if faction:isStateFaction() then
							if source ~= targetPlayer then
								if source:isFactionDuty() then
									if not targetPlayer.vehicle then
										source.m_CurrentCuff = targetPlayer
										source:triggerEvent("factionStateStartCuff", targetPlayer)
										targetPlayer:triggerEvent("CountdownStop",  10, "Gefesselt in")
										targetPlayer:triggerEvent("Countdown", 10, "Gefesselt in")
										source:triggerEvent("CountdownStop", 10, "Gefesselt in")
										source:triggerEvent("Countdown", 10, "Gefesselt in")
									else
										source:sendError("Du kommst nicht an den Spieler heran!")
									end
								else
									source:sendError("Du bist nicht im Dienst!")
								end
							else
								source:sendError("Du kannst dich nicht selbst fesseln!")
							end
						else
							source:sendError("Du hast keine Handschellen dabei!")
						end
					end
				else
					source:sendError("Du bist zu weit weg!")
				end
			else
				source:sendError("Ziel nicht gefunden!")
			end
		end
	else outputChatBox("Syntax: /cuff [ziel]", source, 200, 0,0)
	end
end

function FactionState:Command_uncuff( source, cmd, target )
	if target then
		if type(target) == "string" then
			local targetPlayer = PlayerManager:getSingleton():getPlayerFromPartOfName(target, source)
			if targetPlayer then
				if getDistanceBetweenPoints3D(source:getPosition(), targetPlayer:getPosition()) <= 5 then
					local faction = source:getFaction()
					if faction then
						if source ~= targetPlayer then
							if faction:isStateFaction() then
								if source:isFactionDuty() then
									self:uncuffPlayer( targetPlayer )
									source:meChat(true,"nimmt die Handschellen von "..targetPlayer:getName().." ab!")
									targetPlayer:triggerEvent("updateCuffImage", false)
								else
									source:sendError("Du hast keine Handschellen dabei!")
								end
							else
								source:sendError("Du hast keine Handschellen dabei!")
							end
						end
					else
						source:sendError("Du kannst dich nicht selbst entfesseln!")
					end
				else
					source:sendError("Du bist zu weit weg!")
				end
			else
				source:sendError("Ziel nicht gefunden!")
			end
		end
	else outputChatBox("Syntax: /uncuff [ziel]", source, 200, 0,0)
	end
end

function FactionState:uncuffPlayer( player)
	toggleControl(player, "sprint", true)
	toggleControl(player, "jump", true)
	toggleControl(player, "fire", true)
	toggleControl(player, "aim_weapon", true)
	player:triggerEvent("updateCuffImage", false)
	setPedWalkingStyle(player, 0)
end

function FactionState:Event_CuffSuccess( target )
	if client then
		if client.m_CurrentCuff == target then
			if getDistanceBetweenPoints3D(target:getPosition() , client:getPosition()) <= 5 then
				if not target.vehicle then
					toggleControl(target, "sprint", false)
					toggleControl(target, "jump", false)
					toggleControl(target, "fire", false)
					toggleControl(target, "aim_weapon", false)
					setPedWalkingStyle(target, 123)
					source:meChat(true,"legt "..target:getName().." Handschellen an!")
					source:triggerEvent("CountdownStop", "Gefesselt in", 10)
					target:triggerEvent("CountdownStop", "Gefesselt in", 10)
					target:triggerEvent("updateCuffImage", true)
				end
			end
		end
	end
end
function FactionState:getOnlinePlayers()
	local factions = self:getFactions()
	local players = {}
	for index,faction in pairs(factions) do
		for index, value in pairs(faction:getOnlinePlayers()) do
			table.insert(players, value)
		end
	end
	return players
end

function FactionState:giveKarmaToOnlineMembers(karma, reason)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:giveKarma(karma)
		player:sendShortMessage(_("%s\nDu hast %d Karma erhalten!", player, reason, karma), "Karma")
	end
end

function FactionState:getFactions()
	local factions = FactionManager:getSingleton():getAllFactions()
	local returnFactions = {}
	for i, faction in pairs(factions) do
		if faction:isStateFaction() then
			table.insert(returnFactions, faction)
		end
	end
	return returnFactions
end

function FactionState:onBarrierGateHit(player)
    if player:getFaction() and player:getFaction():isStateFaction() then
		return true
	else
		return false
	end

end

function FactionState:createDutyPickup(x,y,z,int, dim)
	self.m_DutyPickup = createPickup(x,y,z, 3, 1275) --PD
	setElementInterior(self.m_DutyPickup, int or 0)
	setElementDimension ( self.m_DutyPickup, dim or 0)
	addEventHandler("onPickupHit", self.m_DutyPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction then
					if faction:isStateFaction() == true then
						hitElement:triggerEvent("showStateFactionDutyGUI")
						hitElement:getFaction():updateStateFactionDutyGUI(hitElement)
					end
				end
			end
			cancelEvent()
		end
	)
end

function FactionState:createArrestZone(x, y, z, int, dim)
	local pickup = createPickup(x,y,z, 3, 1318)
	local col = createColSphere(x,y,z, 4)
	if int then
		pickup:setInterior(int)
		col:setInterior(int)
	end

	if dim then
		pickup:setDimension(dim)
		col:setDimension(dim)
	end
	addEventHandler("onPickupHit", pickup,
	function(hitElement)
		if getElementType(hitElement) == "player" then
			local faction = hitElement:getFaction()
			if faction then
				if faction:isStateFaction() == true then
					if hitElement:isFactionDuty() then
						hitElement:triggerEvent("showStateFactionArrestGUI", col)
					end
				end
			end
		end
		cancelEvent()
	end
	)
end

function FactionState:createGasStation(pos, size)
	local marker = createMarker(pos, "cylinder", size or 2, 255, 255, 0, 170)
	addEventHandler("onMarkerHit", marker ,
		function(hitElement, dim)
			if hitElement:getType() == "player" and dim then
				if hitElement.vehicle and hitElement.vehicleSeat == 0 then
					if hitElement:getFaction() and hitElement:getFaction():isStateFaction() and hitElement:isFactionDuty() then
						if hitElement.vehicle and hitElement.vehicle:getFaction() and hitElement.vehicle:getFaction():isStateFaction() then
							hitElement.stateGasStation = source
							hitElement:triggerEvent("showStateFactionGasStationGUI")
						else
							hitElement:sendError(_("Nur für Fahrzeuge des Staates!", hitElement))
						end
					else
						hitElement:sendError(_("Nur für Staatsfraktionisten im Dienst!", hitElement))
					end
				end
			end
		end
	)
end

function FactionState:Event_fillRepairVehicle(type)
	if client.vehicle then
		if client:getFaction() and client:getFaction():isStateFaction() and client:isFactionDuty() then
			if client.vehicle and client.vehicle:getFaction() and client.vehicle:getFaction():isStateFaction() then
				if client.stateGasStation and getDistanceBetweenPoints3D(client:getPosition(), client.stateGasStation:getPosition()) <= 3 then
					local costs
					if type == "fill" then
						costs = math.floor((100-client.vehicle:getFuel())*5)
						client.vehicle:setFuel(100)
						client:sendShortMessage(_("Das Fahrzeug wurde für %d$ betankt!", client, costs))
						client:getFaction():takeMoney(costs, "Fahrzeug-Betankung")
					elseif type == "repair" then
						costs = math.floor((1000-client.vehicle:getHealth()))
						fixVehicle(client.vehicle)
						client:sendShortMessage(_("Das Fahrzeug wurde für %d$ repariert!", client, costs))
						client:getFaction():takeMoney(costs, "Fahrzeug-Reparatur")
					end
				else
					client:sendError(_("Du bist zuweit entfernt!", client))
				end
			else
				client:sendError(_("Nur für Fahrzeuge des Staates!", client))
			end
		else
			client:sendError(_("Nur für Staatsfraktionisten im Dienst!", client))
		end
	else
		client:sendError(_("Du musst in einem Fahrzeug sitzen!", client))
	end
end


function FactionState:getFullReasonFromShortcut(reason)
	if string.lower(reason) == "bs" or string.lower(reason) == "wn" then
		reason = "Beschuss/Waffennutzung"
	elseif string.lower(reason) == "db" then
		reason = "Drogenbesitz"
	elseif string.lower(reason) == "br" then
		reason = "Banküberfall"
	elseif string.lower(reason) == "mt" then
		reason = "Mats-Truck"
	elseif string.lower(reason) == "wt" then
		reason = "Waffen-Truck"
	elseif string.lower(reason) == "dt" then
		reason = "Drogen-Truck"
	elseif string.lower(reason) == "gt" then
		reason = "Geldtruck-Überfall"
	elseif string.lower(reason) == "kh" then
		reason = "Knasthack/Knastausbruch"
	elseif string.lower(reason) == "swt" then
		reason = "Staatswaffentruck-Überfall"
	elseif string.lower(reason) == "illad" then
		reason = "Illegale Werbung"
	elseif string.lower(reason) == "kpv" then
		reason = "Körperverletzung"
	elseif string.lower(reason) == "garage" or string.lower(reason) == "pdgarage" then
		reason = "Einbruch-in-die-PD-Garage"
	elseif string.lower(reason) == "wd" then
		reason = "Waffen-Drohung"
	elseif string.lower(reason) == "bh" then
		reason = "Beihilfe einer Straftat"
	elseif string.lower(reason) == "vw" then
		reason = "Verweigerung-zur-Durchsuchung"
	elseif string.lower(reason) == "bb" or string.lower(reason) == "beleidigung" then
		reason = "Beamtenbeleidigung"
	elseif string.lower(reason) == "flucht" or string.lower(reason) == "fvvk" or string.lower(reason) == "vk" then
		reason = "Flucht aus Kontrolle"
	elseif string.lower(reason) == "kt" then
		reason = "Koks-Truck"
	elseif string.lower(reason) == "zt" then
		reason = "Überfall auf Zeugenschutz"
	elseif string.lower(reason) == "bv" then
		reason = "Befehlsverweigerung"
	elseif string.lower(reason) == "sb" then
		reason = "Sachbeschädigung"
	elseif string.lower(reason) == "rts" then
		reason = "Shop-Überfall"
	elseif string.lower(reason) == "eöä" then
		reason = "Erregung öffentlichen Ärgernisses"
	elseif string.lower(reason) == "vd" then
		reason = "versuchter Diebstahl"
	elseif string.lower(reason) == "fof" then
		reason = "Fahren ohne Führerschein"
	end
	return reason
end

function FactionState:sendShortMessage(text, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendShortMessage(_(text, player), "Staat", {11, 102, 8}, ...)
	end
end

function FactionState:sendMessage(text, r, g, b, ...)
	for k, player in pairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function FactionState:sendStateChatMessage(sourcePlayer, message)
	local faction = sourcePlayer:getFaction()
	if faction and faction:isStateFaction() == true then
	--	if sourcePlayer:isFactionDuty() then
			local playerId = sourcePlayer:getId()
			local rank = faction:getPlayerRank(playerId)
			local rankName = faction:getRankName(rank)
			local r,g,b = 200, 100, 100
			local receivedPlayers = {}
			local text = ("%s %s: %s"):format(rankName,getPlayerName(sourcePlayer), message)
			for k, player in pairs(self:getOnlinePlayers()) do
				player:sendMessage(text, r, g, b)
				if player ~= sourcePlayer then
					receivedPlayers[#receivedPlayers+1] = player:getName()
				end
			end
			StatisticsLogger:getSingleton():addChatLog(sourcePlayer, "state", message, toJSON(receivedPlayers))
	--	else
	--		sourcePlayer:sendError(_("Du bist nicht im Dienst!", sourcePlayer))
	--	end
	end
end

function FactionState:Command_megaphone(player, cmd, ...)
	local faction = player:getFaction()
	if faction and faction:isStateFaction() == true then
		if player:isFactionDuty() then
			if player:getOccupiedVehicle() and player:getOccupiedVehicle():getFaction() and player:getOccupiedVehicle():isStateVehicle() then
				local playerId = player:getId()
				local playersToSend = player:getPlayersInChatRange(2)
				local text = ("[[ %s %s: %s ]]"):format(faction:getShortName(), player:getName(), table.concat({...}, " "))
				for index = 1,#playersToSend do
					playersToSend[index]:sendMessage(text, 255, 255, 0)
				end
			else
				player:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function FactionState:Command_suspect(player,cmd,target,amount,...)
	if player:isFactionDuty() and player:getFaction() and player:getFaction():isStateFaction() == true then
		local amount = tonumber(amount)
		if amount and amount >= 1 and amount <= 6 then
			local reason = self:getFullReasonFromShortcut(table.concat({...}, " "))
			local target = PlayerManager:getSingleton():getPlayerFromPartOfName(target,player)
			if isElement(target) then
				if not isPedDead(target) then
					if string.len(reason) > 2 and string.len(reason) < 50 then
						target:giveWantedLevel(amount)
						outputChatBox(("Verbrechen begangen: %s, %s Wanteds, Gemeldet von: %s"):format(reason,amount,player:getName()), target, 255, 255, 0 )
						local msg = ("%s hat %s %d Wanteds wegen %s gegeben!"):format(player:getName(),target:getName(),amount, reason)
						StatisticsLogger:getSingleton():addTextLog("wanteds", msg)
						player:getFaction():addLog(player, "Wanteds", "hat "..target:getName().." "..amount.." Wanteds wegen "..reason.." gegeben!")
						self:sendMessage(msg, 255,0,0)
					else
						player:sendError(_("Der Grund ist ungültig!", player))
					end
				else
					player:sendError(_("Der Spieler ist tot!", player))
				end
			end
		else
			player:sendError(_("Die Anzahl muss zwischen 1 und 6 liegen!", player))
		end
	else
		player:sendError(_("Du bist nicht im Dienst!", player))
	end
end

function FactionState:Command_tie(player, cmd, tname, bool)
	local faction = player:getFaction()
	if faction and faction:isStateFaction() then
		if player:isFactionDuty() then
			local vehicle = player:getOccupiedVehicle()
			if player:getOccupiedVehicle() and vehicle and isElement(vehicle) and vehicle.getFaction and vehicle:getFaction() and vehicle:isStateVehicle() then
				if tname then
					local target = PlayerManager:getSingleton():getPlayerFromPartOfName(tname, player)
					if isElement(target) then
						if target == player then
							player:sendError(_("Du kannst dich nicht selbst fesseln!", player))
							return
						end
						if target:getOccupiedVehicle() and target:getOccupiedVehicle() == vehicle then
							if isControlEnabled(target, "enter_exit") or bool == true then
								player:sendInfo(_("Du hast %s gefesselt", player, target:getName()))
								target:sendInfo(_("Du wurdest von %s gefesselt", target, player:getName()))
								toggleControl(target, "enter_exit", false)
								toggleControl(target, "fire", false)
								addEventHandler("onPlayerVehicleExit", target, self.onTiedExitBind)
							else
								player:sendInfo(_("Du hast %s entfesselt", player, target:getName()))
								target:sendInfo(_("Du wurdest von %s entfesselt", target, player:getName()))
								toggleControl(target, "enter_exit", true)
								toggleControl(target, "fire", true)
								removeEventHandler("onPlayerVehicleExit", target, self.onTiedExitBind)
							end
						else
							player:sendError(_("Der Spieler ist nicht in deinem Fahrzeug!", player))
						end
					end
				else
					player:sendError(_("Kein Ziel angegeben! Befehl: /tie [NAME]!", player))
				end
			else
				player:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function FactionState:onTiedExit(vehicle, seat, jacked)
	source:warpIntoVehicle(vehicle, seat)
end

function FactionState:Command_needhelp(player)
	local faction = player:getFaction()
	if faction and faction:isStateFaction() then
		if player:isFactionDuty() then
			if player:getInterior() == 0 and player:getDimension() == 0 then
				local rankName = faction:getRankName(faction:getPlayerRank(player))
				local zoneName = getZoneName(player:getPosition()).."/"..getZoneName(player:getPosition(), true)
				for k, onlineplayer in pairs(self:getOnlinePlayers()) do
					onlineplayer:sendMessage(_("%s %s benötigt Unterstützung! Ort: %s", onlineplayer, rankName, player:getName(), zoneName), 50, 200, 255)
					onlineplayer:sendMessage(_("Begib dich dort hin! Der Ort wird auf der Karte markiert!", onlineplayer), 50, 200, 255)
					onlineplayer:triggerEvent("stateFactionNeedHelp", player)
				end
			else
				player:sendError(_("Du kannst hier keine Hilfe anfordern!", player))
			end
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	else
		player:sendError(_("Du bist in keiner Staatsfraktion!", player))
	end
end

function FactionState:Event_JailPlayer(player, bail, CUTSCENE, police)
	local policeman = police or client
	if policeman:getFaction() and policeman:getFaction():isStateFaction() then
		if policeman:isFactionDuty() then
			if player:getWantedLevel() > 0 then
				local bailcosts = 0
				local wantedLevel = player:getWantedLevel()
				local jailTime = wantedLevel * 5
				local factionBonus = JAIL_COSTS[wantedLevel]

				if bail then
					bailcosts = BAIL_PRICES[wantedLevel]
					player:setJailBail(bailcosts)
				end

				if player:getMoney() < JAIL_COSTS[wantedLevel] then
					factionBonus = player:getMoney()
				end
				self:Command_tie(policeman, "tie", player:getName(), false)
				player:takeMoney(factionBonus, "Knast Strafe")
				player:giveKarma(-wantedLevel)
				player:setJailTime(jailTime)
				player:setWantedLevel(0)
				player:moveToJail(CUTSCENE)
				self:uncuffPlayer( player)
				player:clearCrimes()

				-- Pay some money to faction and karma, xp to the policeman
				policeman:getFaction():giveMoney(factionBonus, "Arrest")
				policeman:giveKarma(wantedLevel)
				policeman:givePoints(wantedLevel)
				PlayerManager:getSingleton():sendShortMessage(_("%s wurde soeben von %s für %d Minuten eingesperrt! Strafe: %d$", player, player:getName(), policeman:getName(), jailTime, factionBonus), "Staat")
				StatisticsLogger:getSingleton():addArrestLog(player, wantedLevel, jailTime, policeman, bailcosts)
				policeman:getFaction():addLog(policeman, "Knast", "hat "..player:getName().." für "..jailTime.."min. eingesperrt!")
				-- Give Achievements
				if wantedLevel > 4 then
					policeman:giveAchievement(48)
				else
					policeman:giveAchievement(47)
				end

				setTimer(function (player) -- (delayed)
					if isElement(player) then player:giveAchievement(31) end
				end, 14000, 1, player)

			else
				policeman:sendError(_("Der Spieler wird nicht gesucht!", player))
			end
		else
			policeman:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function FactionState:Command_bail(player)
	if player.m_JailTimer then
		if player.m_Bail and player.m_JailTime then
			if player.m_Bail > 0 then
				local money = player:getBankMoney()
				if money >= player.m_Bail then

					player:takeBankMoney(player.m_Bail, "Kaution")
					FactionManager:getSingleton():getFromId(1):giveMoney(player.m_Bail, "Kaution")

					player:sendInfo(_("Sie haben sich mit der Kaution von %s$ freigekauft!", player, player.m_Bail))
					player.m_Bail = 0
					self:freePlayer(player)
				else
					player:sendError("Sie haben nicht genügend Geld!")
				end
			end
		end
	end
end

function FactionState:freePlayer(player)
	player:setData("inJail",false, true)
	player:setDimension(0)
	player:setInterior(0)
	player:setPosition(1539.7, -1659.5 + math.random(-3, 3), 13.6)
	player:setRotation(0, 0, 90)
	player:setWantedLevel(0)
	player:toggleControl("fire", true)
	player:toggleControl("jump", true)
	player:toggleControl("aim_weapon ", true)
	player:toggleControl("enter_exit ", true)
	if isTimer(player.m_JailTimer) then
		killTimer( player.m_JailTimer )
	end
	player.m_JailTimer = nil
	player:setJailTime(0)
	player.m_Bail = 0
	player:triggerEvent("playerLeftJail")
	player:triggerEvent("checkNoDm")
end


function FactionState:Event_toggleSwat()
	if client:isFactionDuty() then
		local faction = client:getFaction()
		local swat = client:getPublicSync("Faction:Swat")
		if swat == true then
			faction:changeSkin(client)
			client:setPublicSync("Faction:Swat",false)
			client:sendInfo(_("Du hast den Swat-Modus beendet!", client))
			faction:updateStateFactionDutyGUI(client)
		else
			client:setJobDutySkin(285)
			client:setPublicSync("Faction:Swat",true)
			client:sendInfo(_("Du bist in den Swat-Modus gewechselt!", client))
			faction:updateStateFactionDutyGUI(client)
		end
	end
end

function FactionState:Event_FactionChangeSkin()
	if client:isFactionDuty() then
		if client.m_SpawnWithFactionSkin then
			client:getFaction():changeSkin(client)
		else
			setElementModel( self, self.m_AltSkin or self.m_Skin)
		end
	end
end

function FactionState:Event_FactionRearm()
	if client:isFactionDuty() then
		client:triggerEvent("showFactionWeaponShopGUI",client:getFaction().m_ValidWeapons)
		client:setHealth(100)
		client:setArmor(100)
	end
end

function FactionState:Event_toggleDuty(wasted)
	if wasted then client:removeFromVehicle() end

	if getPedOccupiedVehicle(client) then
		return client:sendError("Steige erst aus dem Fahrzeug aus!")
	end
	local faction = client:getFaction()
	if faction:isStateFaction() then
		if client:isFactionDuty() then
			client:setDefaultSkin()
			client.m_FactionDuty = false
			takeAllWeapons(client)
			faction:updateStateFactionDutyGUI(client)
			client:sendInfo(_("Du bist nicht mehr im Dienst!", client))
			client:setPublicSync("Faction:Duty",false)
			client:getInventory():removeAllItem("Barrikade")
			client:getInventory():removeAllItem("Nagel-Band")
			client:getInventory():removeAllItem("Blitzer")
		else
			if client:getPublicSync("Company:Duty") and client:getCompany() then
				client:sendWarning(_("Bitte beende zuerst deinen Dienst im Unternehmen!", client))
				return false
			end

			faction:changeSkin(client)
			client.m_FactionDuty = true
			client:setHealth(100)
			client:setArmor(100)
			takeAllWeapons(client)
			faction:updateStateFactionDutyGUI(client)
			client:sendInfo(_("Du bist nun im Dienst!", client))
			client:setPublicSync("Faction:Duty",true)
			client:getInventory():removeAllItem("Barrikade")
			client:getInventory():giveItem("Barrikade", 10)
			client:triggerEvent("showFactionWeaponShopGUI")

		end
	else
		client:sendError(_("Du bist in keiner Staatsfraktion!", client))
		return false
	end
end

function FactionState:Event_storageWeapons()
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local depot = faction:getDepot()
			for i= 1, 12 do
				if client:getWeapon(i) > 0 then
					local weaponId = client:getWeapon(i)
					local clipAmmo = getWeaponProperty(weaponId, "pro", "maximum_clip_ammo") or 1
					local magazines = math.floor(client:getTotalAmmo(i)/clipAmmo)-1

					local depotWeapons, depotMagazines = faction:getDepot():getWeapon(weaponId)
					local depotMaxWeapons, depotMaxMagazines = faction.m_WeaponDepotInfo[weaponId]["Waffe"], faction.m_WeaponDepotInfo[weaponId]["Magazine"]
					if depotWeapons+1 <= depotMaxWeapons then
						depot:addWeaponD(weaponId, 1)
						if magazines > 0 and depotMagazines + magazines <= depotMaxMagazines then
							depot:addMagazineD(weaponId, magazines)
						else
							client:sendError(_("Im Depot ist nicht Platz für %s %s Magazin/e!", client, magazines, WEAPON_NAMES[weaponId]), 0, 255, 0)
						end
						takeWeapon(client, weaponId)
						client:sendMessage(_("Du hast eine/n %s mit %s Magazin/e ins Depot gelegt!", client, WEAPON_NAMES[weaponId], magazines), 0, 255, 0)
					else
						client:sendError(_("Im Depot ist nicht Platz für eine/n %s!", client, WEAPON_NAMES[weaponId]), 0, 255, 0)
					end
				end
			end
		end
	end
end

-- Area 51
function FactionState:createDefendActors(Actors)
	for i, v in pairs(Actors or {}) do
		local actor = DefendActor:new(v[1], v[3], v[4], v[5])
		actor:setRotation(v[2])
		actor:setFrozen(true)
		actor.onAttackRangeHit = function (actor, ele)
			if ele then
				local ele = ele
				if ele:getType() == "vehicle" or ele:getType() == "player" then
					if ele:getType() == "vehicle" then
						ele = ele:getOccupant()
						if not ele then -- Do not attack emtpy vehicles
							return true
						end
					end
					if ele:getType() == "player" then
						if ele:getFaction() and ele:getFaction():isStateFaction() then
							return true
						end
					end
				else
					return true -- Only attack Vehicles and Players
				end
			end

			return false
		end
	end
end

function FactionState:checkLogout(player)
	local pos = player:getPosition()
	local col = createColSphere(pos, 20)
	local colPlayers = getElementsWithinColShape(col, "player")
	col:destroy()
	for index, cop in pairs(colPlayers) do
		if cop:getFaction() and cop:getFaction():isStateFaction() and cop:isFactionDuty() then
			self:Event_JailPlayer(player, false, false, cop)
			player:addOfflineMessage( "Sie wurden offline eingesperrt!", 1)
			return
		end
	end

end


function FactionState:Event_giveWanteds(target, amount, reason)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:giveWantedLevel(amount)
			outputChatBox(("Verbrechen begangen: %s, %s Wanted/s, Gemeldet von: %s"):format(reason, amount, client:getName()), target, 255, 255, 0 )
			local msg = ("%s hat %s %d Wanted/s wegen %s gegeben!"):format(client:getName(), target:getName(), amount, reason)
			faction:addLog(client, "Wanteds", "hat "..target:getName().." "..amount.." Wanteds gegeben! Grund: "..reason)
			self:sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:Event_clearWanteds(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:takeWantedLevel(6)
			outputChatBox(("Dir wurden alle Wanteds von %s erlassen"):format(client:getName()), target, 255, 255, 0 )
			local msg = ("%s hat %s alle Wanteds erlassen!"):format(client:getName(), target:getName())
			faction:addLog(client, "Wanteds", "hat "..target:getName().." alle Wanteds erlassen!")
			self:sendMessage(msg, 255,0,0)
		end
	end
end

function FactionState:Event_grabPlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local vehicle = client:getOccupiedVehicle()
			if client:getOccupiedVehicle() and vehicle and isElement(vehicle) and vehicle.getFaction and vehicle:isStateVehicle() then
				if target.isTasered == true and not target:isDead() then
					for seat = 1, getVehicleMaxPassengers(vehicle) do
						if not vehicle:getOccupant(seat) then
							warpPedIntoVehicle(target, vehicle, seat)
							client:sendInfo(_("%s wurde in dein Fahrzeug gezogen!", client, target:getName()))
							target:sendInfo(_("Du wurdest von %s in das Fahrzeug gezogen!", target, client:getName()))
							self:Command_tie(client, "tie", target:getName(), true)
							return
						end
					end
					client:sendError(_("Du hast keinen Platz in deinem Fahrzeug!", client))
				else
					client:sendError(_("Der Spieler ist nicht getazert oder Tod!", client))
				end
			else
				client:sendError(_("Du sitzt in keinem Fraktions-Fahrzeug!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_friskPlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:sendMessage(_("Der Staatsbeamte %s durchsucht dich!", target, client:getName()), 255, 255, 0)
			local DrugItems = {"Kokain", "Weed", "Heroin", "Shrooms"}
			local inv = target:getInventory()
			local targetDrugs, targetWeapons = false, false
			for index, item in pairs(DrugItems) do
				if inv:getItemAmount(item) > 0 then
					if not targetDrugs then targetDrugs = {} end
					if not targetDrugs[item] then targetDrugs[item] = 0 end
					targetDrugs[item] = targetDrugs[item] + inv:getItemAmount(item)
				end
			end
			if targetDrugs then
				client:sendMessage(_("%s hat folgende Drogen dabei:", client, target:getName()), 255, 255, 0)
				target:sendMessage(_("Du hast folgende Drogen dabei:", target), 255, 255, 0)
				for drug, amount in pairs(targetDrugs) do
					client:sendMessage(_("%dg %s", client, amount, drug), 255, 125, 0)
					target:sendMessage(_("%dg %s", target, amount, drug), 255, 125, 0)
				end
			else
				client:sendMessage(_("%s hat keine Drogen dabei!", client, target:getName()), 0, 255, 0)
				target:sendMessage(_("Du hast keine Drogen dabei!", target), 0, 255, 0)
			end

			for i=1, 12 do
				if getPedWeapon(target,i) > 0 then
					if not targetWeapons then targetWeapons = {} end
					targetWeapons[getPedWeapon(target,i)] = true
				end
			end

			if targetWeapons then
				client:sendMessage(_("%s hat folgende Waffen dabei:", client, target:getName()), 255, 255, 0)
				target:sendMessage(_("Du hast folgende Waffen dabei:", target), 255, 255, 0)
				for weaponID, bool in pairs(targetWeapons) do
					client:sendMessage(_("%s", client, WEAPON_NAMES[weaponID]), 255, 125, 0)
					target:sendMessage(_("%s", target, WEAPON_NAMES[weaponID]), 255, 125, 0)
				end
			else
				client:sendMessage(_("%s hat keine Waffen dabei!", client, target:getName()), 0, 255, 0)
				target:sendMessage(_("Du hast keine Waffen dabei!", target), 0, 255, 0)
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_showLicenses(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			target:triggerEvent("questionBox", _("Staatsbeamter %s fordert dich auf deinen Führerschein zu zeigen! Zeigst du ihm deinen Führerschein?", client, getPlayerName(client)), "factionStateAcceptShowLicense", "factionStateDeclineShowLicense", client, target)
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_acceptShowLicense(player, target)
	player:triggerEvent("showIDCard", target)
	target:sendMessage(_("%s sieht sich deinen Führerschein an!", target, player:getName()), 255, 255, 0)
end

function FactionState:Event_declineShowLicense(player, target)
	player:sendMessage(_("%s will dir seinen Führerschein nicht zeigen!", player, target:getName()), 255, 255, 0)
end

function FactionState:Event_givePANote(target, note)
	local faction = client:getFaction()
	if faction and faction:getId() == 1 then
		if client:isFactionDuty() then
			if faction:getPlayerRank(client) < FactionRank.Manager then
				client:sendError(_("Du bist nicht berechtig PA-Noten auszuteilen!", client))
				return
			end
			if client == target then
				client:sendError(_("Du darfst dir nicht selber eine PA-Noten setzen!", client))
				return
			end
			if note > 0 and note <= 100 then
				target:sendInfo(_("%s hat dir eine PA-Note von %d gegeben!", target, client:getName(), note))
				client:sendInfo(_("Du hast %s eine PA-Note von %d gegeben!", client, target:getName(), note))
				target:setPaNote(note)
				StatisticsLogger:getSingleton():addTextLog("paNote", ("%s hat %s eine PA-Note von %d gegeben!"):format(client:getName(), target:getName(), note))
			else
				client:sendError(_("Ungültige PA-Note!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	else
		client:sendError(_("Du bist nicht im SAPD!", client))
	end
end

function FactionState:Event_takeDrugs(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			local DrugItems = {"Kokain", "Weed", "Heroin", "Shrooms"}
			client:sendMessage(_("Du hast %s folgende Drogen abgenommen:", client, target:getName()), 255, 255, 0)
			target:sendMessage(_("%s hat dir folgende Drogen abgenommen:", target, client:getName()), 255, 255, 0)
			local drugsTaken = false
			local amount = 0
			local inv = target:getInventory()
			for index, item in pairs(DrugItems) do
				if inv:getItemAmount(item) > 0 then
					amount = inv:getItemAmount(item)
					drugsTaken = true
					client:sendMessage(_("%dg %s", client, amount, item), 255, 125, 0)
					target:sendMessage(_("%dg %s", target, amount, item), 255, 125, 0)
					inv:removeAllItem(item)
				end
			end
			if not drugsTaken then
				client:sendMessage(_("Keine", client), 255, 125, 0)
				target:sendMessage(_("Keine", target), 255, 125, 0)
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_takeWeapons(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() then
			client:sendMessage(_("Du hast %s entwaffnet!", client, target:getName()), 255, 255, 0)
			target:sendMessage(_("%s hat dich entwaffnet!", target, client:getName()), 255, 255, 0)
			takeAllWeapons(target)
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function FactionState:Event_putItemInVehicle(itemName, amount, inventory)
	if client.vehicle or inventory then
		if client:isFactionDuty() and client:getFaction() and client:getFaction():isStateFaction() == true then
			local veh = inventory and source or client.vehicle
			if veh:getFaction() and veh:getFaction():isStateFaction() then
				veh:loadFactionItem(client, itemName, amount, inventory)
			else
				client:sendError(_("Ungültiges Fahrzeug!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	else
		client:sendError(_("Du brauchst ein Fahrzeug zum einladen!", client))
	end
end


function FactionState:Event_takeItemFromVehicle(itemName)
	if client:isFactionDuty() and client:getFaction() and client:getFaction():isStateFaction() == true then
		local veh = source
		if veh:getFaction() and veh:getFaction():isStateFaction() then
			veh:takeFactionItem(client, itemName)
		else
			client:sendError(_("Ungültiges Fahrzeug!", client))
		end
	else
		client:sendError(_("Du bist nicht im Dienst!", client))
	end
end

function FactionState:Event_loadJailPlayers()
	local players = {}
	for index, playeritem in pairs(getElementsByType("player")) do
		if playeritem.m_JailTime and playeritem.m_JailTimer and playeritem.m_JailTime > 0 then
			local timeLeft = playeritem.m_JailTimer:getDetails()/1000/60
			players[playeritem] = ("%.1f / %smin"):format(timeLeft, playeritem.m_JailTime)
		end
	end
	client:triggerEvent("receiveJailPlayers", players)
end

function FactionState:Event_freePlayer(target)
	local faction = client:getFaction()
	if faction and faction:isStateFaction() then
		if client:isFactionDuty() and faction:getPlayerRank(client) >= FactionRank.Rank3 then
			if target and isElement(target) then
				outputChatBox(("Du wurdest von %s aus dem Knast entlassen!"):format(client:getName()), target, 255, 255, 0 )
				local msg = ("%s hat %s aus dem Knast entlassen!"):format(client:getName(), target:getName())
				self:sendMessage(msg, 255,0,0)
				faction:addLog(client, "Knast", "hat "..target:getName().." aus dem Knast entlassen!")
				self:freePlayer(target)
			else
				client:sendError(_("Spieler nicht gefunden!", client))
			end
		else
			client:sendError(_("Du bist nicht berechtigt! Ab Rang %d!", client, FactionRank.Rank3))
		end
	end
end

function FactionState:addBugLog(player, func, msg)
	if not self:isBugActive() then return end
	local colSize = CHAT_TALK_RANGE

	if func == "flüstert" then
		colSize = CHAT_WHISPER_RANGE
	elseif func == "schreit" then
		colSize = CHAT_SCREAM_RANGE
	end

	local col = createColSphere(player:getPosition(), colSize)
	local elements = col:getElementsWithin()
	col:destroy()

	for i=1, #elements do
		if elements[i] and isElement(elements[i]) and elements[i].BugId then
			local id = elements[i].BugId

			if self.m_Bugs[id] then
				local logId = #self.m_Bugs[id]["log"]+1
				self.m_Bugs[id]["log"][logId] = player:getName().." "..func..": "..msg
				self:sendShortMessage("Wanze "..id.." hat etwas empfangen!\n(Drücke F4)")

			end
		end
	end
end

function FactionState:Event_loadBugs()
	client:triggerEvent("receiveBugs", self.m_Bugs)
end

function FactionState:getFreeBug()
	for id, bugData in ipairs(self.m_Bugs) do
		if not bugData["active"] or bugData["active"] == false then
			return id
		end
	end
	return false
end

function FactionState:isBugActive()
	for id, bugData in pairs(self.m_Bugs) do
		if bugData["active"] and bugData["active"] == true then
			return true
		end
	end
	return false
end

function FactionState:Event_attachBug()
	local id = self:getFreeBug()
	if id then
		local typeName = source:getType() == "vehicle" and "Fahrzeug" or "Spieler"

		self.m_Bugs[id] = {
			["element"] = source,
			["log"] = {},
			["active"] = true
		}
		source.BugId = id
		source:setData("Wanze", true, true)
		client:triggerEvent("receiveBugs", self.m_Bugs)
		self:sendShortMessage(client:getName().." hat Wanze "..id.." an ein/en "..typeName.." angebracht!")
	else
		client:sendError(_("Alle verfügbaren Wanzen sind aktiv!", client))
	end
end

function FactionState:Event_bugAction(action, id)
	if self.m_Bugs[id] then
		if action == "disable" then
			self.m_Bugs[id]["element"].BugId = nil
			self.m_Bugs[id]["element"]:setData("Wanze", false, true)

			self.m_Bugs[id] = {}
			self:sendShortMessage(client:getName().." hat Wanze "..id.." deaktiviert!")
		elseif action == "clearLog" then
			self.m_Bugs[id]["log"] = {}
			client:sendSuccess(_("Du hast den Log der Wanze %d gelöscht!", client, id))
		end
		client:triggerEvent("receiveBugs", self.m_Bugs)
	else
		client:sendError(_("Wanze nicht verfügbar!", client))
	end
end

function FactionState:Event_checkBug(element)
	local checkElement = client
	local text = _("deinem Körper", client)
	local price = 25
	if element then
		checkElement = element
		text = _("deinem Fahrzeug", client)
		price = 50
	end
	if client:getMoney() >= price then
		client:takeMoney(price, "Wanzen-Check")
		CompanyManager:getSingleton():getFromId(CompanyStaticId.MECHANIC):giveMoney(math.floor(price/2), "Wanzen-Check")
		if checkElement:getData("Wanze") == true and checkElement.BugId then
			local id = checkElement.BugId
			self.m_Bugs[id]["element"].BugId = nil
			self.m_Bugs[id]["element"]:setData("Wanze", false, true)
			self.m_Bugs[id] = {}
			self:sendShortMessage("Wanze "..id.." wurde entdeckt und entfernt!")
			client:sendShortMessage(_("Oha! Ich habe eine Wanze von %s entfernt!", client, text))
		else
			client:sendShortMessage(_("Ich habe keine Wanze an %s gefunden!", client, text))
		end
	else
		client:sendError(_("Du hast nicht genug Geld dabei! (%d$)", client, price))
	end
end

