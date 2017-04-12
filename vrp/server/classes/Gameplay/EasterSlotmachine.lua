-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/EasterSlotmachine.lua
-- *  PURPOSE:     EasterSlotmachine class - from iLife
-- *
-- ****************************************************************************
EasterSlotmachine = inherit(Object)
EasterSlotmachine.Slots = {
	[1] = "VIP",
	[2] = "Easter_Egg",
	[3] = "Mr. Whoopee",
	[4] = "Money",
	[5] = "Easter_Eggs",
	[6] = "Bunny_Ears",
}
slot_machines = {}

function EasterSlotmachine:constructor(x, y, z, rx, ry, rz, int, dim)
	if not int then
		int = 0
	end
	if not dim then
		dim = 0
	end

	self.ms_Settings = {}

	-- Methods
	self.m_ResultFunc = bind(self.doResult, self)
	self.m_ResetFunc = bind(self.reset, self)
	self.m_StartFunc = bind(self.startPlayer, self)
	self.m_HebelClickFunc = function(btn, state, player)
		local dist = getDistanceBetweenPoints3D(source:getPosition(), player:getPosition())
		if dist <= 5 then
			if btn == "left" and state == "down" then
				self:startPlayer(player)
			end
		end
	end;
	-- Instances

	self.m_Objects = {}

	self.m_Objects.rolls = {}
	-- self.hebel
	-- self.wood
	-- self.gun
	self.canSpin = true

	self.ms_Settings.iconNames = {
		[900] = EasterSlotmachine.Slots[1],
		[1100] = EasterSlotmachine.Slots[1],
		[1300] = EasterSlotmachine.Slots[2],
		[1400] = EasterSlotmachine.Slots[4],
		[1500] = EasterSlotmachine.Slots[4],
		[1600] = EasterSlotmachine.Slots[4],
		[1700] = EasterSlotmachine.Slots[6],
		[1800] = EasterSlotmachine.Slots[3],
		[1900] = EasterSlotmachine.Slots[6],
		[2000] = EasterSlotmachine.Slots[4],
		[2100] = EasterSlotmachine.Slots[6],
		[2300] = EasterSlotmachine.Slots[6],
		[2140] = EasterSlotmachine.Slots[5],
	}

	-- Objects
	-- EasterSlotmachine


	self.m_Objects.slotmachine = createObject(2325, x, y, z, rx, ry, rz)
	self.m_Objects.slotmachine:setData("Easter", true, true)

	setObjectScale(self.m_Objects.slotmachine, 2)

	slot_machines[self.m_Objects.slotmachine] = self.m_Objects.slotmachine;
	-- Rolls

	for i = 1, 3, 1 do
		self.m_Objects.rolls[i] = createObject(2348, x, y, z)
		setObjectScale(self.m_Objects.rolls[i], 2)
		attachElements(self.m_Objects.rolls[i], self.m_Objects.slotmachine, -0.45+i/4, 0, 0)
	end

	-- Lever ( Hebel )

	self.m_Objects.hebel = createObject(1319, x, y, z)
	attachElements(self.m_Objects.hebel, self.m_Objects.slotmachine, 0.9, -0.3, 0, 50, 0, rz*(360)/90)
	setElementFrozen(self.m_Objects.hebel, true)
	setElementData(self.m_Objects.hebel, "SLOTMACHINE:LEVER", true)
	self.m_Objects.hebel:setData("clickable", true, true)

	-- Wood

	self.m_Objects.wood = createObject(3260, x, y, z)
	setObjectScale(self.m_Objects.wood, 0.7)
	attachElements(self.m_Objects.wood, self.m_Objects.slotmachine, 0, 0.5, -0.5)


	-- Dimension and Interior

	for index, object in pairs(self.m_Objects) do
		if type(object) == "table" then
			for index, e1 in pairs(object) do
				setElementInterior(e1, int)
				setElementDimension(e1, dim)
			end
		else
			setElementInterior(object, int)
			setElementDimension(object, dim)
		end
	end

--	outputDebugString("[CALLING] EasterSlotmachine: Constructor")

	-- Events --
	addEventHandler("onElementClicked", self.m_Objects.hebel, self.m_HebelClickFunc)
	setElementData(self.m_Objects.hebel, "SLOTMACHINE:ID", self) -- Store the Object in the element data
end

-- ///////////////////////////////
-- ///// reset		 		//////
-- ///// Returns: bool		//////
-- ///////////////////////////////

function EasterSlotmachine:reset()
	if self.canSpin == false then
		self.canSpin = true

		return true;
	end
end

function EasterSlotmachine:calculateSpin()
	local rnd = tonumber(math.random(1, 9))
	local rnd2
	local grad = 0
	if rnd == 1 then
		rnd2 = math.random(0, 5)
		if rnd2 == 1 then
			grad = 1100				-- SLOT1 - Premium
		elseif rnd2 == 2 then
			grad = 1800				-- SLOT3 - Wopee
		else
			grad = 2140				-- SLOT5 - OSTERHASE ?
		end
	elseif rnd == 2 then
		rnd2 = math.random(0, 5)
		if rnd2 == 1 then
			grad = 1100				-- SLOT1 - Premium
		elseif rnd2 == 2 then
			grad = 1800				-- SLOT3 - Wopee
		else
			grad = 2140				-- SLOT5 - OSTERHASE ?
		end
	elseif rnd == 3 then
		grad = 1600					-- SLOT4 - Geld
	elseif rnd == 4 or rnd == 5 then
		grad = 1900					-- SLOT5 - OSTERHASE ?
	elseif rnd == 6 or rnd == 7 then
		grad = 1300					-- SLOT2 - Osterei
	elseif rnd == 8 or rnd == 9 then
		grad = 1700					-- SLOT6 - Hasenohren
	end

	return grad, self.ms_Settings.iconNames[grad];
end

function EasterSlotmachine:moveLever(player)
	local x, y, z = getElementPosition(self.m_Objects.hebel)
	local _, _, _, rx, ry, rz = getElementAttachedOffsets(self.m_Objects.hebel)
	local _, _, rz = getElementRotation(self.m_Objects.slotmachine)
	detachElements(self.m_Objects.hebel)

	setElementPosition(self.m_Objects.hebel, x, y, z)
	setElementRotation(self.m_Objects.hebel, rx, ry, rz)

	moveObject(self.m_Objects.hebel, 450, x, y, z, 50, 0, 0, "InQuad")

	setTimer(
		function()
			moveObject(self.m_Objects.hebel, 450, x, y, z, -50, 0, 0, "InQuad")
		end, 450, 1
	)

	local int, dim = self.m_Objects.slotmachine:getInterior(), self.m_Objects.slotmachine:getDimension()
	setTimer(triggerClientEvent, 150, 1, getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "start_machine", int, dim)


	setTimer(function() self:spin(player) end, 500, 1, player)

	return true;
end

function EasterSlotmachine:spin(player)
	local ergebnis = {}
	for i = 1, 3, 1 do
		local grad, icon = self:calculateSpin()
		--	grad, icon = 900, "69"
		local x, y, z = getElementPosition(self.m_Objects.rolls[i])
		local _, _, _, rx, ry, rz = getElementAttachedOffsets(self.m_Objects.rolls[i])
		--if rx == 0 then
		rx, _, _ = getElementRotation(self.m_Objects.rolls[i])
		--end
		local _, _, rz = getElementRotation(self.m_Objects.slotmachine)
		if isElementAttached(self.m_Objects.rolls[i]) then
			detachElements(self.m_Objects.rolls[i])

			setElementPosition(self.m_Objects.rolls[i], x, y, z)
			setElementRotation(self.m_Objects.rolls[i], rx, ry, rz)

		end
		--	outputChatBox(grad-rx)

		--	outputChatBox(rx-grad)
		local s = moveObject(self.m_Objects.rolls[i], 2500+(i*600), x, y, z, grad, 0, 0, "InQuad")

		ergebnis[i] = icon
	end
	setTimer(self.m_ResultFunc, 4100, 1, ergebnis, player)
	return true;
end

function EasterSlotmachine:checkRolls()
	for i = 1, 3, 1 do
		local x, y, z = getElementPosition(self.m_Objects.rolls[i])
		if not isElementAttached(self.m_Objects.rolls[i]) then
			local rx, ry, _ = getElementRotation(self.m_Objects.rolls[i])

			moveObject(self.m_Objects.rolls[i], 100, x, y, z, -rx, 0, 0, "InQuad")
		end
	end
end

function EasterSlotmachine:start(player)
	if self.canSpin == true then
		self.canSpin = false;
		self:checkRolls()
		setTimer(function()
			self:moveLever(player)
		end, 100, 1)
	end
end

function EasterSlotmachine:giveWin(player, name, x, y, z)
	--outputChatBox("Won: " .. name)
	triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_stuff")
	--StatisticsLogger:addCasino( player, name, ...)

	if name == "Money" then
		local rnd = math.random(250, 15000)
		player:sendInfo(_("Du hast %d$ gewonnen!", player, rnd))
		player:giveMoney(rnd, "EasterSlotmaschine")
		--todo StatisticsLogger
	elseif name == "Ostereier5" then
		player:sendInfo("Du hast 5 Ostereier gewonnen!")
		player:getInventory():giveItem("Osterei", 5)
		-- todo StatisticsLogger
	elseif name == "Ostereier20" then
		player:sendInfo("Du hast 20 Ostereier gewonnen!")
		player:getInventory():giveItem("Osterei", 20)
		-- todo StatisticsLogger
	elseif name == "Premium" then
		player:sendInfo("Du hast einen Monat Premium gewonnen! Gratulation!")
		player.m_Premium:giveEasterMonth()
	elseif name == "Hasenohren" then
		player:getInventory():giveItem("Hasenohren", 1)
	elseif name == "MrWhoopee" then
		player:sendInfo("Du hast einen Mr. Whoopee gewonnen! Gückwunsch!")
		local vehicle = PermanentVehicle.create(player, 423, 1513.77, -1771.50, 13.57, 0, nil, true)
		if vehicle then
			warpPedIntoVehicle(player, vehicle)
			player:triggerEvent("vehicleBought")
		else
			player:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin!", player), 255, 0, 0)
		end
	else
		player:sendError(_("Unknown Win! %s", player, name))
	end
end

function EasterSlotmachine:doResult(ergebnis, player)
	local x, y, z = getElementPosition(self.m_Objects.slotmachine)

	local result = {}
	for index, name in pairs(EasterSlotmachine.Slots) do
		result[name] = 0
	end

	for _, data in pairs(ergebnis) do
		result[data] = result[data]+1
	end

	if result["VIP"] == 3 then
		self:giveWin(player, "Premium", x, y, z)
	elseif result["Easter_Egg"] == 3 then
		self:giveWin(player, "Ostereier5", x, y, z)
	elseif result["Mr. Whoopee"] == 3 then
		self:giveWin(player, "MrWhoopee", x, y, z)
	elseif result["Money"] == 3 then
		self:giveWin(player, "Money", x, y, z)
	elseif result["Easter_Eggs"] == 3 then
		self:giveWin(player, "Ostereier20", x, y, z)
	elseif result["Bunny_Ears"] == 3 then
		self:giveWin(player, "HasenOhren", x, y, z)
	else
		player:sendInfo(_("Du hast leider nichts gewonnen!", player))
		triggerClientEvent(getRootElement(), "onSlotmachineSoundPlay", getRootElement(), x, y, z, "win_nothing")
	end

	setTimer(self.m_ResetFunc, 1500, 1)
end

function EasterSlotmachine:startPlayer(player)
	if not self.canSpin then return end

	if player:getInventory():getItemAmount("Osterei") >= 5 then
		player:getInventory():removeItem("Osterei", 5)
		self:start(player)
	else
		player:sendWarning(_("Du brauchst mind. 5 Ostereier, um spielen zu können", player))
	end
end
