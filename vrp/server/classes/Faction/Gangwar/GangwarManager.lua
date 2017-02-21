-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarManager.lua
-- *  PURPOSE:     Gangwar Class
-- *
-- ****************************************************************************

Gangwar = inherit(Singleton)


--// RESET VARIABLE //
GANGWAR_RESET_AREAS = false --// NUR IM FALLE VON GEBIET-RESET


--// Gangwar - Constants //--
GANGWAR_MATCH_TIME = 15
GANGWAR_CENTER_HOLD_RANGE = 15
GANGWAR_MIN_PLAYERS = 1 --// Default 3
GANGWAR_ATTACK_PAUSE = 1 --// DAY Default 2
GANGWAR_CENTER_TIMEOUT = 20 --// SEKUNDEN NACH DEM DIE FLAGGE NICHT GEHALTEN IST
GANGWAR_DUMP_COLOR = setBytesInInt32(240, 0, 200, 200)
GANGWAR_ATTACK_PICKUPMODEL =  1313
GANGWAR_PAYOUT_PER_AREA = 1250
UNIX_TIMESTAMP_24HRS = 86400
--//

addRemoteEvents{ "onLoadCharacter", "onDeloadCharacter", "Gangwar:onClientRequestAttack", "GangwarQuestion:disqualify", "gangwarGetAreas" }
function Gangwar:constructor( )
	if GANGWAR_RESET_AREAS then
		self:RESET()
	end
	self.m_Areas = {	}
	self.m_CurrentAttack = nil
	local sql_query = "SELECT * FROM ??_gangwar"
	local rows = sql:queryFetch(sql_query, sql:getPrefix())
	if rows then
		for i, row in ipairs( rows ) do
			self.m_Areas[#self.m_Areas+1] = Area:new(row, self)
			addEventHandler("onPickupHit", self.m_Areas[#self.m_Areas].m_Pickup, bind(Gangwar.Event_OnPickupHit, self))
		end
	end
	addEventHandler("onLoadCharacter", root, bind(self.onPlayerJoin, self))
	addEventHandler("onDeloadCharacter", root, bind(self.onPlayerQuit, self))
	addEventHandler("Gangwar:onClientRequestAttack", root, bind(self.attackReceiveCMD, self))
	addEventHandler("onClientWasted", root, bind( Gangwar.onPlayerWasted, self))
	addEventHandler("GangwarQuestion:disqualify", root, bind(self.onPlayerAbort, self))
	addEventHandler("gangwarGetAreas", root, bind(self.getAreas, self))
	GlobalTimer:getSingleton():registerEvent(bind(self.onAreaPayday, self), "Gangwar-Payday",false,false,0)
end

function Gangwar:onAreaPayday() 
	local payouts = {}
	local m_Owner
	for index, area in pairs( self.m_Areas ) do
		m_Owner = area.m_Owner
		if not payouts[m_Owner] then payouts[m_Owner] = 0 end
		payouts[m_Owner] = payouts[m_Owner] + 1
	end
	local amount = 0
	local facObj
	for faction, count in pairs( payouts ) do 
		amount = count * GANGWAR_PAYOUT_PER_AREA
		facObj = FactionManager:getSingleton():getFromId(faction)
		if facObj then 
			facObj:giveMoney(amount, "Gangwar-Payday")
			facObj:sendMessage("Gangwar-Payday: #FFFFFFEure Fraktion erhält: "..amount.." $", 0, 200, 0, true)
		end
	end
end

function Gangwar:Event_OnPickupHit( player )
	local dim = getElementDimension(source)
	local pDim = getElementDimension(player)
	local mArea = player.m_InsideArea
	if dim == pDim then
		if mArea then
			player:triggerEvent("Gangwar_shortMessageAttack" , mArea)
		end
	end
end

function Gangwar:RESET()
	local sql_query = "UPDATE ??_gangwar SET Besitzer='5'"
	sql:queryFetch(sql_query,  sql:getPrefix())
	outputDebugString("Gangwar-areas were reseted!")
end

function Gangwar:destructor( )
	for index = 1,  #self.m_Areas do
		self.m_Areas[index]:delete()
	end
end

function Gangwar:isPlayerInGangwar(player)
	local active, disq = self:getCurrentGangwarPlayers()
	for index, gwPlayer in pairs(active) do
		if gwPlayer and player and player == gwPlayer then
			return true
		end
	end
	for index, gwPlayerName in pairs(disq) do
		if gwPlayerName and player and player.name == gwPlayerName then
			return true
		end
	end
	return false
end

function Gangwar:getCurrentGangwarPlayers()
	local currentPlayers = {}
	local attackSession
	local disqualifiedPlayers =  {}
	if self.m_CurrentAttack then
		attackSession = self.m_CurrentAttack.m_AttackSession
		for index, gwPlayer in pairs(attackSession.m_Participants) do
			currentPlayers[#currentPlayers+1] = gwPlayer
		end
		disqualifiedPlayers = {}
		for index, gwPlayer in pairs(attackSession.m_Disqualified) do
			disqualifiedPlayers[#disqualifiedPlayers+1] = gwPlayer
		end
	end
	return currentPlayers, disqualifiedPlayers
end

function Gangwar:getAreas()
	for index, area in pairs(self.m_Areas) do
		client:triggerEvent("gangwarLoadArea", area:getName(), area:getPosition(), area:getOwnerId(), area:getLastAttack())
	end
end

function Gangwar:onPlayerJoin()
	local factionObj = source.m_Faction
	if factionObj then
		if self.m_CurrentAttack then
			local faction1,  faction2 = self.m_CurrentAttack:getMatchFactions()
			if faction1 == factionObj or faction2 == factionObj then
				local area = self.m_CurrentAttacks
				area.m_AttackSession:joinPlayer( source )
			end
		end
	end
end

function Gangwar:onPlayerQuit()
	local factionObj = source.m_Faction
	if factionObj then
		if self.m_CurrentAttack then
			local faction1,  faction2 = self.m_CurrentAttack:getMatchFactions()
			if faction1 == factionObj or faction2 == factionObj then
				local area = self.m_CurrentAttack
				area.m_AttackSession:quitPlayer( source )
			end
		end
	end
end

function Gangwar:onPlayerWasted(  killer, weapon , bodypart, loss )
	if self.m_CurrentAttack then
		if self.m_CurrentAttack.m_AttackSession then
			self.m_CurrentAttack.m_AttackSession:onPlayerWasted( source, killer, weapon, bodypart, loss)
		end
	end
end

function Gangwar:onPlayerAbort( bAFK )
	if client then
		if client == source then
			if self.m_CurrentAttack then
				self.m_CurrentAttack.m_AttackSession:onPurposlyDisqualify( source , bAFK )
			end
		end
	end
end

function Gangwar:addAreaToAttacks(  )
	self.m_CurrentAttack = pArea
end

function Gangwar:removeAreaFromAttacks()
	if self.m_CurrentAttack then
		self.m_CurrentAttack = false
	end
end

function Gangwar:getCurrentGangwar( )
	return self.m_CurrentAttack
end

function Gangwar:attackReceiveCMD( )
	if client then
		if client == source then
			self:attackArea( client )
		end
	end
end

function Gangwar:attackArea( player )
	local faction = player.m_Faction
	if faction then
		if faction:isStateFaction() == true or faction.m_Id == 4 then
			return player:sendError(_("Du bist nicht berechtigt am Gangwar teilzunehmen!",  player))
		end
		local id = player.m_Faction.m_Id
		local mArea = player.m_InsideArea
		if mArea then
			local bWithin = isElementWithinColShape(player,  mArea.m_CenterSphere)
			if bWithin then
				local areaOwner = mArea.m_Owner
				local faction2 = FactionManager:getSingleton():getFromId(areaOwner)
				if areaOwner ~= id then
					local factionCount = #faction:getOnlinePlayers()
					local factionCount2 = #faction2:getOnlinePlayers()
					if factionCount >= GANGWAR_MIN_PLAYERS then
						if factionCount2 >= GANGWAR_MIN_PLAYERS then
							local activeGangwar = self:getCurrentGangwar()
							local acFaction1,  acFaction2
							if not activeGangwar then
								local lastAttack = mArea.m_LastAttack
								local currentTimestamp = getRealTime().timestamp
								local nextAttack = lastAttack + ( GANGWAR_ATTACK_PAUSE*UNIX_TIMESTAMP_24HRS)
								if nextAttack <= currentTimestamp then
									mArea:attack(faction, faction2)
								else
									player:sendError(_("Dieses Gebiet ist noch nicht attackierbar!",  player))
								end
							else 
								player:sendError(_("Es läuft zurzeit ein Gangwar!",  player))
							end
						else
							player:sendError(_("Es müssen mind. "..GANGWAR_MIN_PLAYERS.." aus der Gegner-Fraktion online sein!",  player))
						end
					else
						player:sendError(_("Es müssen mind. "..GANGWAR_MIN_PLAYERS.." aus deiner Fraktion online sein!",  player))
					end
				else
					player:sendError(_("Du kannst dich nicht selbst angreifen!",  player))
				end
			else
				player:sendError(_("Du bist an keinem Gebiet!",  player))
			end
		else
			player:sendError(_("Du bist an keinem Gebiet!",  player))
		end
	else
		player:sendError(_("Du bist in keiner Fraktion!",  player))
	end
end
