-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/WearableManager.lua
-- *  PURPOSE:     WearableManager class
-- *
-- ****************************************************************************

WearableManager = inherit( Singleton )

--[[
	*WearableManager handles WearableItems.*
	
	 ________________________________________
	|	inventory_slots						|	
	|---------------------------------------|
	|	+id									|
	|	+...								|
	|	+Value (metainfo: textureurl+...)	|
	|_______________________________________|
					|
					|
					|
					------> 	Value will be a url for the texture that will get 
								applied to the wearableItem.
							
								Example: 
								_____________________
								|	Helmet 			|
								|	id: 1			|
								|	...				|
								|	Value: tex.png	|
								____________________
	

]]
function WearableManager:constructor() 
	addEventHandler("onElementInteriorChange",root, bind(self.Event_onElementInteriorChange,self))
	addEventHandler("onElementDimensionChange",root, bind ( self.Event_onElementDimensionChange, self))
	addEventHandler("onPlayerQuit",root, bind ( self.Event_onPlayerQuit, self))
end

function WearableManager:destructor() 
end

function WearableManager:checkReference( sData )
	
end

function WearableManager:Event_onElementInteriorChange( int )
	local obj = false
	if source.m_Helmet then 
		setElementInterior(source.m_Helmet, int)
		obj = source.m_Helmet
	end
	if source.m_Shirt then 
		setElementInterior(source.m_Shirt, int)
		obj = source.m_Shirt
	end
	if source.m_Portables then 
		setElementInterior(source.m_Portables, int)
		obj = source.m_Portables
	end
	if obj then 
		local x,y,z = getElementPosition(source)
		setElementPosition(obj, x,y,z)
	end
end

function WearableManager:Event_onElementDimensionChange( dim )
	local obj = false
	if source.m_Helmet then 
		setElementDimension(source.m_Helmet, dim)
		obj = source.m_Helmet
	end
	if source.m_Shirt then 
		setElementDimension(source.m_Shirt, dim)
		obj = source.m_Shirt
	end
	if source.m_Portables then 
		setElementDimension(source.m_Portables, dim)
		obj = source.m_Portables
	end
	if obj then 
		local x,y,z = getElementPosition(source)
		setElementPosition(obj, x,y,z)
	end
end

function WearableManager:Event_onPlayerQuit(  )
	if source.m_Helmet then 
		destroyElement(source.m_Helmet)
	end
	if source.m_Shirt then 
		destroyElement(source.m_Shirt)
	end
		if source.m_Portables then 
		destroyElement(source.m_Portables)
	end
end