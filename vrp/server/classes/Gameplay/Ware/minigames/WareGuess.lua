-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareGuess.lua
-- *  PURPOSE:     WareGuess class
-- *
-- ****************************************************************************
WareGuess = inherit(Object)
WareGuess.modeDesc = "Rate die Anzahl der Fahrzeuge!"
WareGuess.timeScale = 0.7
WareGuess.vehicleIds = {
   602, 496, 401, 518, 527, 589, 419, 462, 509, 522, 598, 583, 482
}

function WareGuess:constructor( super )
	self.m_Super = super
	local x,y,z,width,height = unpack(self.m_Super.m_Arena)
	for key, p in ipairs(self.m_Super.m_Players) do
		showChat(p, true)
		setCameraMatrix(p, x, y, z+15, x+width*0.5, y+height*0.5, z)
		setElementAlpha(p, 0)
	end
	self.m_WrongPlayers = {}
	self.m_Winners = {}
	self:spawnCars()
end

function WareGuess:spawnCars() 
	self.m_Cars = {}
	local x,y,z,width,height = unpack(self.m_Super.m_Arena)
	local randomNumber = math.random(4, 25)
	local randomVehicle
	local rx, ry, rz
	for i = 1, randomNumber do 
		randomVehicle =  math.random(1, #WareGuess.vehicleIds)
		rx = math.random(1, width*0.5)
		ry = math.random(1, height*0.5)
		rz = math.random(1, 5)
		rx = x + width*0.2 + rx
		ry = y + height*0.2 + ry
		self.m_Cars[#self.m_Cars+1] = createVehicle(WareGuess.vehicleIds[randomVehicle], rx, ry, z+rz )
		setVehicleDamageProof(self.m_Cars[#self.m_Cars], true)
	end
	self.m_RightAnswer = randomNumber
end

function WareGuess:onChat(player, text, type)
	if tonumber(text) == self.m_RightAnswer then
		if not self.m_WrongPlayers[player] then
			self.m_Super:addPlayerToWinners(player)
			self.m_Winners[player] = true
		end
	else
		if not self.m_Winners[player] then
			self.m_WrongPlayers[player] = true
			player:triggerEvent("onClientWareFail")
		end
	end
end

function WareGuess:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do
		showChat(p, false)
		setCameraTarget(p, p)
		setElementAlpha(p, 255)
	end
	for i = 1, #self.m_Cars do 
		destroyElement(self.m_Cars[i])
	end
end
