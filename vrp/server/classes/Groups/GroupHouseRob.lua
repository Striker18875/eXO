-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupHouseRob.lua
-- *  PURPOSE:     Group HouseRob class
-- *
-- ****************************************************************************
local findItems = 
{
	"TV-Reciever",
	"Handy", 
	"Armbanduhr",
	"Bargeld",
	"Kreditkarte",
	"Radio",
	"Schmuckkette",
	"Goldring",
	"Tablet",
	"Laptop",	
}

local sellerPeds = 
{
	{{2344.76, -1233.29, 22.50, 74}, "Piotr Scherbakow", {2348.10, -1232.54, 22.62,240},44, "Du siehst mir aus wie jemand der etwas loswerden will!"},
	{{ 2759.16, -1177.98, 69.40, 74}, "Jorvan Krajewski", {2762.65, -1178.32, 69.52,262}, 73, "Komme hierhin, zeig Sache ich mach Preis!"},
	{ { 2275.59, -1031.20, 51.43,244}, "Machiavelli Johnson", { 2274.86, -1027.57, 52.17,14}, 143, "Komm mal ran, du willst doch sicherlich n' bisschen Geld hu?"},
	{ {1730.60, -2148.86, 13.55,109}, "Carlos Peralta", {1734.09, -2147.95, 13.68,280}, 114, "Ese, zeig deine Sachen oder verschwinde."},
}

GroupHouseRob = inherit( Singleton )
GroupHouseRob.MAX_ROBS_PER_GROUP = 5
GroupHouseRob.COOLDOWN_TIME = 1000*60*15
function GroupHouseRob:constructor() 
	self.m_GroupsRobbed = {}
	self.m_GroupsRobCooldown = {}
	self.m_HousesRobbed = {}
	self.m_SellerPeds = {}
	self.m_OnSellerClick = bind(self.Event_onClickPed, self)
	self.m_OnColShapeHit = bind(self.Event_onColHit, self)
	local pedPos, pedName, vehPos, skin, ped, sellvehicle, greetText
	for i = 1,#sellerPeds do 
		pedPos = sellerPeds[i][1]
		pedName = sellerPeds[i][2]
		vehPos = sellerPeds[i][3]
		skin = sellerPeds[i][4]
		ped = createPed(skin, pedPos[1],pedPos[2],pedPos[3],pedPos[4])
		sellvehicle = createVehicle(482,vehPos[1],vehPos[2],vehPos[3],0,0,vehPos[4])
		greetText = sellerPeds[i][5]
		setVehicleDoorOpenRatio(sellvehicle, 4,1)
		setVehicleDoorOpenRatio(sellvehicle, 5,1)
		setVehicleDoorOpenRatio(sellvehicle, 1,1)
		setElementCollisionsEnabled ( sellvehicle, false)
		setVehicleColor(sellvehicle, 100,100, 100,100,100,100)
		setElementFrozen(sellvehicle,true)
		ped:setData("Ped:Name", pedName)
		ped:setData("Ped:greetText", greetText)
		setElementData(ped, "Ped:fakeNameTag", pedName)
		setElementData(ped,"NPC:Immortal_serverside",true)
		setPedAnimation(ped, "dealer", "dealer_idle",-1, true, false, false)
		ped.m_ColShape = createColSphere ( pedPos[1],pedPos[2],pedPos[3], 10)
		setElementData(ped.m_ColShape, "colPed", ped)
		ped.m_LastOutPut = -10000 --// nur alle 10sekunden eine begr��ung vom ped
		addEventHandler("onColShapeHit", ped.m_ColShape, self.m_OnColShapeHit)
		self.m_SellerPeds[i] = ped
		addEventHandler("onElementClicked", ped, self.m_OnSellerClick)
	end
end

function GroupHouseRob:Event_onColHit( hE, matchDim ) 
	if getElementType(hE) == "player" then 
		if matchDim then 
			local ped = getElementData(source, "colPed")
			if ped then 
				if ped.m_LastOutPut + 10000 <= getTickCount() then 
					ped.m_LastOutPut = getTickCount()
					hE:sendPedChatMessage( ped:getData("Ped:Name"),ped:getData("Ped:greetText", greetText))
				end
			end
		end
	end
end


function GroupHouseRob:Event_onClickPed(  m, s, player)
	if m == "left" then 
		if s == "up" then 
			local inv = player:getInventory()
			if inv then 
				local thiefItems = inv:getItemAmount("Diebesgut")
				if thiefItems > 0 then 
					player:meChat(true, "nickt mit dem Kopf.")
					player:sendPedChatMessage( source:getData("Ped:Name"), "lass mich sehen!")
				else 
					player:meChat(true, "sch�ttelt den Kopf.")
					player:sendPedChatMessage( source:getData("Ped:Name"), "hmm... Komm wieder wenn du etwas hast!")
				end
			end
		end
	end
end

function GroupHouseRob:startNewRob( house, player ) 
	if player then 
		local group = player:getGroup() 
		if group:getType() == "Gang" then 
			if not self.m_GroupsRobbed[group] then 
				self.m_GroupsRobbed[group] = 0
			end
			if self.m_GroupsRobbed[group] < GroupHouseRob.MAX_ROBS_PER_GROUP then 
				if not self.m_HousesRobbed[house] then
					local tick = getTickCount()
					if not self.m_GroupsRobCooldown[group] then 
						self.m_GroupsRobCooldown[group]  = 0 - GroupHouseRob.COOLDOWN_TIME
					end
					if self.m_GroupsRobCooldown[group] + GroupHouseRob.COOLDOWN_TIME <= tick then
						self.m_GroupsRobbed[group] = self.m_GroupsRobbed[group] + 1
						self.m_GroupsRobCooldown[group]  = tick
						self.m_HousesRobbed[house] = true
						return true
					else 
						outputChatBox("Ihr k�nnt noch nicht wieder ein Haus ausrauben!", player, 200,0,0)
					end
				else 
					outputChatBox("Dieses Haus wurde bereits ausgeraubt!", player, 200,0,0)
				end
			else 
				outputChatBox("Ihr habt schon zu viele H�user heute ausgeraubt!", player, 200,0,0)
			end
		end
	end 
	return false
end



function GroupHouseRob:getRandomItem() 
	return findItems[math.random(1,#findItems)]
end

function GroupHouseRob:destructor() 

end

