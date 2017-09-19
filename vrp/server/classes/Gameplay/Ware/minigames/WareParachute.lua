-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareParachute.lua
-- *  PURPOSE:     WareParachute class
-- *
-- ****************************************************************************
WareParachute = inherit(Object)
WareParachute.modeDesc = "Lande auf der Plattform!"
WareParachute.timeScale = 2

function WareParachute:constructor( super )
	self.m_Super = super
	self:createPlatform()
	self:portPlayers(200)

end

function WareParachute:createPlatform()
	if self.m_Super.m_Arena then
		local x,y,z,width,height = unpack(self.m_Super.m_Arena)
		if x and y and z and width and height then
			self.m_PlatformObj = createObject(3095,x+5+math.random(width*0.5),y+5+math.random(height*0.5),z+8)
			setElementDimension(self.m_PlatformObj,self.m_Super.m_Dimension)
		end
	end
end

function WareParachute:portPlayers(zOffset)
	local x, y, z, width, height = unpack(self.m_Super.m_Arena)
	for key, p in ipairs(self.m_Super.m_Players) do
		p:triggerEvent("PlatformEnv:toggleColShapeHitRespawn", false)
		p:triggerEvent("PlatformEnv:toggleWallCollission", false)
		p:setPosition((x+5)+ math.random(0,width-5), (y+5)+ math.random(0,height-5),z+zOffset)
		p:giveWeapon(46, 1, true)
	end
end

function WareParachute:destructor()
	self:portPlayers(0)
	for key, p in ipairs(self.m_Super.m_Players) do
		if getPedContactElement(p) == self.m_PlatformObj then
			self.m_Super:addPlayerToWinners( p )
		end
		p:triggerEvent("PlatformEnv:toggleColShapeHitRespawn", true)
		p:triggerEvent("PlatformEnv:toggleWallCollission", true)

	end
	if self.m_PlatformObj then
		destroyElement(self.m_PlatformObj)
	end
end
