-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobLumberjack.lua
-- *  PURPOSE:     Lumberjack job class
-- *
-- ****************************************************************************
JobLumberjack = inherit(Job)

function JobLumberjack:constructor()
	Job.constructor(self)

	self.m_LoadUpMarker = createMarker(1038.9, -354.2, 72.9, "corona", 4)
	setElementVisibleTo(self.m_LoadUpMarker, root, false)
	addEventHandler("onMarkerHit", self.m_LoadUpMarker, bind(JobLumberjack.loadUpHit, self))

	self.m_DumpMarker = createMarker(-1969.8, -2432.6, 29.5, "corona", 4)
	setElementVisibleTo(self.m_DumpMarker, root, false)
	addEventHandler("onMarkerHit", self.m_DumpMarker, bind(JobLumberjack.dumpHit, self))

	self.m_VehicleSpawner = VehicleSpawner:new(1064.67, -300.79, 73, {"Flatbed"}, 180, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner:disable()

	self.m_Col = createColSphere(1022.550, -339.239, 73.992, 300)
		addEventHandler("onColShapeHit", self.m_Col, function(hitElement, dim)
		if hitElement.type == "player" and dim then
			if hitElement:getJob() == self then
				giveWeapon(hitElement, 9, 1, true)
			end
		end
	end)
	addEventHandler("onColShapeLeave", self.m_Col, function(hitElement, dim)
		if hitElement.type == "player" and dim then
			if hitElement:getJob() == self then
				takeWeapon(hitElement, 9)
			end
		end
	end)


	self.m_ResetDataBind = bind(self.onResetData, self)

	addEvent("lumberjackTreeCut", true)
	addEventHandler("lumberjackTreeCut", root, bind(JobLumberjack.Event_lumberjackTreeCut, self))
end

function JobLumberjack:start(player)
	giveWeapon(player, 9, 1, true)
	player:giveAchievement(11)
	self.m_VehicleSpawner:toggleForPlayer(player, true)
	setElementVisibleTo(self.m_LoadUpMarker, player, true)
	setElementVisibleTo(self.m_DumpMarker, player, true)
end

function JobLumberjack:stop(player)
	takeWeapon(player, 9)
	self.m_VehicleSpawner:toggleForPlayer(player, false)
	setElementVisibleTo(self.m_LoadUpMarker, player, false)
	setElementVisibleTo(self.m_DumpMarker, player, false)
end

function JobLumberjack:onVehicleSpawn(player, vehicleModel, vehicle)
	vehicle:setVariant(255, 255)
	vehicle:addCountdownDestroy(10)
	vehicle.LumberjackOwner = player
end

function JobLumberjack:checkRequirements(player)
	if not (player:getJobLevel() >= JOB_LEVEL_LUMBERJACK) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel %d", player, JOB_LEVEL_LUMBERJACK), 255, 0, 0)
		return false
	end
	return true
end

function JobLumberjack:loadUpHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		if hitElement:getJob() ~= self then
			return
		end

		local vehicle = getPedOccupiedVehicle(hitElement)
		if not vehicle or getElementModel(vehicle) ~= 455 then
			hitElement:sendMessage(_("Bitte benutze einen Flatbed", hitElement), 255, 0, 0)
			return
		end

		for k, v in pairs(getAttachedElements(vehicle)) do
			destroyElement(v)
		end

		local numTrees = hitElement:getData("lumberjack:Trees") or 0
		if numTrees == 0 then
			hitElement:sendMessage(_("Du musst erst Bäume fällen um welche aufladen zu können!", hitElement), 255, 0, 0)
			return
		end

		removeEventHandler("onElementDestroy", vehicle, self.m_ResetDataBind)
		removeEventHandler("onVehicleExplode", vehicle, self.m_ResetDataBind)
		addEventHandler("onElementDestroy", vehicle, self.m_ResetDataBind)
		addEventHandler("onVehicleExplode", vehicle, self.m_ResetDataBind)

		local loadedTrees = 0

		for i = 0, 2 do
			for j = 0, 3 do
				if loadedTrees < numTrees then
					local x, y, z = getElementPosition(vehicle)
					local object = createObject(837, x, y, z)
					attachElements(object, vehicle, -1 + j * 0.67, -2.1, 0.45 + i * 0.61, 90, 0, 0)
					object:setScale(0.9)
					object:setCollisionsEnabled(false)
					setElementParent(object, vehicle) -- Deletes the object automatically when the vehicle will be destroyed (e.g. by spawn system)
					loadedTrees = loadedTrees+1
				end
			end
		end

		hitElement:triggerEvent("lumberjackTreesLoadUp", root)
	end
end

function JobLumberjack:onResetData()
	local player = source.LumberjackOwner
	if player and isElement(player) then
		player:setData("lumberjack:Trees", 0)
	end
end

function JobLumberjack:dumpHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		local vehicle = getPedOccupiedVehicle(hitElement)
		if not vehicle or getElementModel(vehicle) ~= 455 then
			hitElement:sendMessage(_("Bitte steige in einen Flatbed ein", hitElement))
			return
		end
		if hitElement:getJob() ~= self then
			return
		end

		local numTrees = hitElement:getData("lumberjack:Trees")
		if not numTrees or numTrees == 0 then
			hitElement:sendMessage(_("Säge und lade zuerst einige Bäume auf!", hitElement), 255, 0, 0)
			return
		end

		removeEventHandler("onElementDestroy", vehicle, self.m_ResetDataBind)
		removeEventHandler("onVehicleExplode", vehicle, self.m_ResetDataBind)

		hitElement:setData("lumberjack:Trees", 0)

		-- Give money and experience points
		hitElement:giveMoney(numTrees * 40, "Holzfäller-Job") --// default *20
		hitElement:givePoints(numTrees)

		for k, v in pairs(getAttachedElements(vehicle)) do
			destroyElement(v)
		end
	end
end

function JobLumberjack:Event_lumberjackTreeCut()
	if client:getJob() ~= self then
		return
	end

	-- Todo: Check deltaTime (--> security)
	client:setData("lumberjack:Trees", (client:getData("lumberjack:Trees") or 0) + 1)
end
