-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/MWeaponTruck.lua
-- *  PURPOSE:     Weapon Truck Manager Class
-- *
-- ****************************************************************************

MWeaponTruck = inherit(Singleton)


function MWeaponTruck:constructor()
	self:createStartPoint(-1869.14, 1421.49, 6.5, "evil")
	self:createStartPoint(117.28, 1884.58, 17, "state")
	self.m_IsCurrentWT = false
	self.m_CurrentType = ""
	addRemoteEvents{"onWeaponTruckLoad"}
	addEventHandler("onWeaponTruckLoad", root, bind(self.Event_onWeaponTruckLoad, self))
end

function MWeaponTruck:destructor()
end

function MWeaponTruck:createStartPoint(x, y, z, type)
	--self.m_Blip = Blip:new("Waypoint.png", x, y, self.m_Driver)
	local marker = createMarker(x, y, z, "cylinder",1)
	marker.type = type
	addEventHandler("onMarkerHit", marker, bind(self.onStartPointHit, self))
end

function MWeaponTruck:onStartPointHit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local faction = hitElement:getFaction()
		if faction then
			if (faction:isEvilFaction() and source.type == "evil") or (faction:isStateFaction() and source.type == "state") then
				if ActionsCheck:getSingleton():isActionAllowed(hitElement) then
					hitElement:triggerEvent("showFactionWTLoadGUI")
					self.m_CurrentType = source.type
				end
			else
				if source.type == "evil" then
					hitElement:sendError(_("Den Waffentruck können nur Mitglieder böser Fraktionen starten!",hitElement))
				elseif source.type == "state" then
					hitElement:sendError(_("Den Staats-Waffentruck können nur Mitglieder von Staats-Fraktionen starten!",hitElement))
				end
			end
		else
			hitElement:sendError(_("Den Waffentruck können nur Fraktions-Mitglieder starten!",hitElement))
		end
	end
end

function MWeaponTruck:Event_onWeaponTruckLoad(weaponTable)
	local faction = client:getFaction()
	local totalAmount = 0
	if faction then
		for weaponID,v in pairs(weaponTable) do
			for typ,amount in pairs(weaponTable[weaponID]) do
				if amount > 0 then
					if typ == "Waffe" then
						totalAmount = totalAmount + faction.m_WeaponDepotInfo[weaponID]["WaffenPreis"] * amount
					elseif typ == "Munition" then
						totalAmount = totalAmount + faction.m_WeaponDepotInfo[weaponID]["MagazinPreis"] * amount
					end
				end
			end
		end
		if client:getMoney() >= totalAmount then
			if totalAmount > 0 then
				if ActionsCheck:getSingleton():isActionAllowed(client) then
					client:takeMoney(totalAmount)
					client:sendInfo(_("Die Ladung steht bereit! Klicke die Kisten an und bringe sie zum Waffen-Truck! Gesamtkosten: %d$",client,totalAmount))
					self.m_CurrentWT = WeaponTruck:new(client, weaponTable, totalAmount, self.m_CurrentType)
					PlayerManager:getSingleton():breakingNews("Ein %s wird beladen", WEAPONTRUCK_NAME[self.m_CurrentType])
					ActionsCheck:getSingleton():setAction(WEAPONTRUCK_NAME[self.m_CurrentType])
				end
			else
				client:sendError(_("Du hast zuwenig augeladen! Mindestens: %d$",client,self.m_AmountPerBox))
			end
		else
			client:sendError(_("Du hast nicht ausreichend Geld! (%d$)",client,totalAmount))
		end
	else
		client:sendError(_("Du bist in keiner Fraktion!",client))
	end
end
