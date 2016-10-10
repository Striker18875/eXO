-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/AmmuNation.lua
-- *  PURPOSE:     Weapon shop class
-- *
-- ****************************************************************************
AmmuNation = inherit(Object)

AmmuNation.INTERIORID = 7
AmmuNation.ENTERPOS = { X = 315.15640, Y = -142.49582, Z = 999.60156 }

function AmmuNation:constructor(name)
	self.m_Name = name or "NO NAME"
end

function AmmuNation:addEnter(x, y, z, dimension)
	local interiorEnter = InteriorEnterExit:new(Vector3(x, y, z), Vector3(AmmuNation.ENTERPOS.X, AmmuNation.ENTERPOS.Y, AmmuNation.ENTERPOS.Z), 0, 0, AmmuNation.INTERIORID, dimension)
	local guiMarker = createMarker(308.3, -141.1, 998.6, "cylinder", 1.2, 255, 0, 0, 125)
	guiMarker:setInterior(AmmuNation.INTERIORID)
	guiMarker:setDimension(dimension)
	Blip:new("AmmuNation.png", x, y)

	addEventHandler ("onMarkerHit", interiorEnter:getEnterMarker(),
		function(hitElement, matchingDimension)
			if hitElement:getType() == "player" and matchingDimension and not hitElement:isInVehicle() then
				hitElement:sendShortMessage(("Willkommen %s, im Ammu Nation \"%s\""):format(getPlayerName(hitElement), self.m_Name))
				hitElement:setUniqueInterior(dimension)
			end
		end
	)
	addEventHandler("onMarkerHit", guiMarker,
		function(hitElement, matchingDimension)
			if hitElement:getType() == "player" and matchingDimension then
				hitElement:triggerEvent("openAmmuNationGUI")
			end
		end
	)
end
