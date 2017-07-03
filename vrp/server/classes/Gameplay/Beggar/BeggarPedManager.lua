BeggarPedManager = inherit(Singleton)
BeggarPedManager.Map = {}
addRemoteEvents{"robBeggarPed", "giveBeggarPedMoney", "giveBeggarItem", "acceptTransport", "sellBeggarWeed",
"adminPedPlaced", "adminPedRequestData", "adminCreatePed"}

function BeggarPedManager:constructor()
	-- Spawn Peds
	self:loadPositions()
	self:spawnPeds()

	self.m_TimedPulse = TimedPulse:new(30*60*1000)
	self.m_TimedPulse:registerHandler(bind(self.spawnPeds, self))

	-- Event Zone
	addEventHandler("robBeggarPed", root, bind(self.Event_robBeggarPed, self))
	addEventHandler("giveBeggarPedMoney", root, bind(self.Event_giveBeggarMoney, self))
	addEventHandler("giveBeggarItem", root, bind(self.Event_giveBeggarItem, self))
	addEventHandler("acceptTransport", root, bind(self.Event_acceptTransport, self))
	addEventHandler("sellBeggarWeed", root, bind(self.Event_sellWeed, self))
	addEventHandler("adminPedRequestData", root, bind(self.Event_adminRequestData, self))
	addEventHandler("adminCreatePed", root, bind(self.Event_createPed, self))
	addEventHandler("adminPedPlaced", root, bind(self.Event_pedPlaced, self))

end

function BeggarPedManager:destructor()
	if self.m_TimedPulse then
		delete(self.m_TimedPulse)
	end
end

function BeggarPedManager:addRef(ref)
	BeggarPedManager.Map[ref:getId()] = ref
end

function BeggarPedManager:removeRef(ref)
	BeggarPedManager.Map[ref:getId()] = nil
end

function BeggarPedManager:loadPositions()
	self.m_Positions = {}
	local result = sql:queryFetch("SELECT * FROM ??_npc", sql:getPrefix())
 	for i, row in pairs(result) do
	 	self.m_Positions[row.Id] = {
			 ["Pos"] = Vector3(row.PosX, row.PosY, row.PosZ),
			 ["Rot"] = Vector3(0, 0, row.Rot),
			 ["Roles"] = row.Roles and fromJSON(row.Roles) or {}
			}
	end
end

function BeggarPedManager:spawnPeds()
	-- Delete current Peds
	for i, v in pairs(self.Map) do
		if not v.vehicle then
			v:destroy()
		end
	end

	-- Create new Peds
	for i, v in pairs(self.m_Positions) do
		if chance(50) then -- They only spawn with a probability of 50%
			local ped = BeggarPed:new(v.Pos, v.Rot, i, v.Roles)
			self:addRef(ped)
		end
	end
end

function BeggarPedManager:getPhrase(beggarType, phraseType, arg1)
	if phraseType == BeggarPhraseTypes.Help then
		return Randomizer:getRandomTableValue(BeggarHelpPhrases[beggarType])
	elseif phraseType == BeggarPhraseTypes.Thanks then
		return Randomizer:getRandomTableValue(BeggarThanksPhrases[beggarType])
	elseif phraseType == BeggarPhraseTypes.NoHelp then
		return Randomizer:getRandomTableValue(BeggarNoHelpPhrases)
	elseif phraseType == BeggarPhraseTypes.Rob then
		return Randomizer:getRandomTableValue(BeggarRobPhrases)
	elseif phraseType == BeggarPhraseTypes.Decline then
		return Randomizer:getRandomTableValue(BeggarDeclinePhrases)
		elseif phraseType == BeggarPhraseTypes.InVehicle then
		return Randomizer:getRandomTableValue(BeggarInVehiclePhrases)
	elseif phraseType == BeggarPhraseTypes.NoTrust then
		return Randomizer:getRandomTableValue(BeggarNoTrustPhrases)
	elseif phraseType == BeggarPhraseTypes.Destination then
		return Randomizer:getRandomTableValue(BeggarDestinationPhrases):format(arg1)
	end
end

function BeggarPedManager:Event_robBeggarPed()
	if not instanceof(source, BeggarPed) then return end
	source:rob(client)
end

function BeggarPedManager:Event_giveBeggarMoney(amount)
	if not instanceof(source, BeggarPed) then return end
	source:giveMoney(client, amount)
end

function BeggarPedManager:Event_giveBeggarItem(item)
	if not instanceof(source, BeggarPed) then return end
	source:giveItem(client, item)
end

function BeggarPedManager:Event_acceptTransport()
	if not instanceof(source, BeggarPed) then return end
	source:acceptTransport(client)
end

function BeggarPedManager:Event_sellWeed(amount)
	if not instanceof(source, BeggarPed) then return end
	source:sellWeed(client, amount)
end

function BeggarPedManager:Event_createPed()
	if client:getRank() < ADMIN_RANK_PERMISSION["pedMenu"] then
		client:sendError(_("Du darfst diese Funktion nicht nutzen!!", client))
		return
	end

	-- Start the object placer on the client
	client:triggerEvent("objectPlacerStart", Randomizer:getRandomTableValue(BeggarSkins), "adminPedPlaced", false, true)
	return true
end

function BeggarPedManager:Event_pedPlaced(x, y, z, rotation)
	if client:getRank() < ADMIN_RANK_PERMISSION["pedMenu"] then
		client:sendError(_("Du darfst diese Funktion nicht nutzen!!", client))
		return
	end

	if client.m_PlacingInfo then
		client:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", client))
		return false
	end

	if sql:queryExec("INSERT INTO ??_npc (PosX, PosY, PosZ, Rot) VALUES (?, ?, ?, ?)", sql:getPrefix(), x, y, z, rotation) then
		local ped = BeggarPed:new(Vector3(x, y, z), Vector3(0, 0, rotation), sql:lastInsertId(), {}, {})
		self:addRef(ped)
		client:sendInfo(_("Neuen NPC hinzugefügt!", client))
		self:loadPositions()
	end
end

function BeggarPedManager:Event_adminRequestData()
	if client:getRank() < ADMIN_RANK_PERMISSION["pedMenu"] then
		client:sendError(_("Du darfst diese Funktion nicht nutzen!!", client))
		return
	end

	local table = {}
	for i, v in pairs(self.m_Positions) do
		table[i] = {}
		table[i]["Pos"] = serialiseVector(v.Pos)
		table[i]["Rot"] = serialiseVector(v.Rot)
		table[i]["Name"] = BeggarPedManager.Map[i] and BeggarPedManager.Map[i].m_Name or "- nicht geladen"
		table[i]["Roles"] = v.Roles
		table[i]["Spawned"] = BeggarPedManager.Map[i] and true or false
	end
	client:triggerEvent("adminPedReceiveData", table)
end

