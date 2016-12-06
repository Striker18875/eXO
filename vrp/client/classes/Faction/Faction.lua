-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Faction.lua
-- *  PURPOSE:     Faction Client
-- *
-- ****************************************************************************

FactionManager = inherit(Singleton)
FactionManager.Map = {}

function FactionManager:constructor()
	triggerServerEvent("getFactions", localPlayer)

	self.m_NeedHelpBlip = {}

	addRemoteEvents{"loadClientFaction", "stateFactionNeedHelp", "factionStateStartCuff","stateFactionOfferTicket"}
	addEventHandler("loadClientFaction", root, bind(self.loadFaction, self))
	addEventHandler("factionStateStartCuff", root, bind(self.stateFactionStartCuff, self))
	addEventHandler("stateFactionNeedHelp", root, bind(self.stateFactionNeedHelp, self))
	addEventHandler("stateFactionOfferTicket", root, bind(self.stateFactionOfferTicket, self))
end

function FactionManager:loadFaction(Id, name, name_short, rankNames, factionType, color)
	FactionManager.Map[Id] = Faction:new(Id, name, name_short, rankNames, factionType, color)
end

function FactionManager:stateFactionStartCuff( target )
	if target then 
		local timer = localPlayer.stateCuffTimer 
		if timer then
			if isTimer(timer) then 
				killTimer(timer)
			end
		end
		localPlayer.m_CuffTarget = target
		localPlayer.stateCuffTimer = setTimer( self.endStateFactionCuff, 5000, 1)
	end
end

function FactionManager:stateFactionOfferTicket( cop )
	ShortMessage:new(_(cop:getName().." bietet dir ein Ticket für den Erlass eines Wanteds für $2000 an. Klicke hier um es anzunehmen!"), "Wanted-Ticket", Color.DarkLightBlue, 15000)
	.m_Callback = function (this)	triggerServerEvent("factionStateAcceptTicket", localPlayer); delete(this)	end

end

function FactionManager:endStateFactionCuff( )
	if localPlayer.m_CuffTarget then 
		if getDistanceBetweenPoints3D( localPlayer.m_CuffTarget:getPosition(), localPlayer:getPosition()) <= 5 then 
			triggerServerEvent("stateFactionSuccessCuff", localPlayer,localPlayer.m_CuffTarget)
		end
	end
end

function FactionManager:stateFactionNeedHelp(player)
	local pos = player:getPosition()

	if self.m_NeedHelpBlip[player] then delete(self.m_NeedHelpBlip[player]) end
	self.m_NeedHelpBlip[player] = Blip:new("NeedHelp.png", pos.x, pos.y, 9999)
	self.m_NeedHelpBlip[player]:attachTo(player)
	self.m_NeedHelpBlip[player]:setStreamDistance(2000)

	setTimer(function(player)
		if self.m_NeedHelpBlip[player] then delete(self.m_NeedHelpBlip[player]) end
	end, 20000, 1, player)
end

function FactionManager:getFromId(id)
	return FactionManager.Map[id]
end

function FactionManager:getFactionNames()
	local table = {}
	for id, faction in pairs(FactionManager.Map) do
		table[id] = faction:getShortName()
	end
	return table
end

Faction = inherit(Object)

function Faction:constructor(Id, name, name_short, rankNames, factionType, color)
	self.m_Id = Id
	self.m_Name = name
	self.m_NameShort = name_short
	self.m_RankNames = rankNames
	self.m_Type = factionType
	self.m_Color = color
end

function Faction:getId()
	return self.m_Id
end

function Faction:isStateFaction()
	return self.m_Type == "State"
end

function Faction:isEvilFaction()
	return self.m_Type == "Evil"
end

function Faction:getName()
	return self.m_Name
end

function Faction:getShortName()
	return self.m_NameShort
end

function Faction:getColor()
	return self.m_Color
end
