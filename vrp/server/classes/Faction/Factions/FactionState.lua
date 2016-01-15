-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Factionmanager Class
-- *
-- ****************************************************************************

FactionState = inherit(Faction)
  -- implement by children


function FactionState:constructor(Id, Name_Short, Name, Money, players)
	outputServerLog("FactionState loaded")
	self:createDutyPickups()
end

function FactionState:destructor()
  outputDebug("FactionState.destructor")
end

function FactionState:getClassId()
  return 1
end

function FactionState:createDutyPickups()
	self.m_DutyPickup = createPickup(252.6, 69.4, 1003.64, 3, 1275) --PD
	setElementInterior(self.m_DutyPickup, 6)
	addEventHandler("onPickupHit", self.m_DutyPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" then
				local faction = hitElement:getFaction()
				if faction:isStateFaction() == true then
					outputChatBox("Duty Marker")
				end
			end
			cancelEvent()
		end
	)
end