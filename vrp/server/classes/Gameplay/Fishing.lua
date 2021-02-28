-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Fishing.lua
-- *  PURPOSE:     Serverside Fishing Class
-- *
-- ****************************************************************************
Fishing = inherit(Singleton)
addRemoteEvents{"clientFishingRodCast", "clientFishHit", "clientFishCaught", "clientFishEscape", "clientRequestFishPricing", "clientRequestFishTrading", "clientSendFishTrading", "clientRequestFishStatistics", "clientAddFishingRodEquipment", "clientRemoveFishingRodEquipment"}

function Fishing:constructor()
	self.Random = Randomizer:new()
	self.m_Players = {}

	self:loadFishDatas()
	self:createDesertWater()
	self:updatePricing()
	self:updateStatistics()
	self.m_BankAccountServer = BankServer.get("gameplay.fishing")

	self.m_UpdatePricingPulse = TimedPulse:new(3600000)
	self.m_UpdatePricingPulse:registerHandler(bind(Fishing.updatePricing, self))
	self.m_UpdatePricingPulse:registerHandler(bind(Fishing.updateStatistics, self))

	addEventHandler("onPlayerQuit", root, bind(Fishing.onPlayerQuit, self))
	addEventHandler("clientFishingRodCast", root, bind(Fishing.FishingRodCast, self))
	addEventHandler("clientFishHit", root, bind(Fishing.FishHit, self))
	addEventHandler("clientFishCaught", root, bind(Fishing.FishCaught, self))
	addEventHandler("clientFishEscape", root, bind(Fishing.FishEscape, self))

	addEventHandler("clientRequestFishPricing", root, bind(Fishing.onFishRequestPricing, self))
	addEventHandler("clientRequestFishTrading", root, bind(Fishing.onFishRequestTrading, self))
	addEventHandler("clientSendFishTrading", root, bind(Fishing.clientSendFishTrading, self))
	addEventHandler("clientRequestFishStatistics", root, bind(Fishing.onFishRequestStatistics, self))

	addEventHandler("clientAddFishingRodEquipment", root, bind(Fishing.onAddFishingRodEquipment, self))
	addEventHandler("clientRemoveFishingRodEquipment", root, bind(Fishing.onRemoveFishingRodEquipment, self))
end

function Fishing:destructor()
end

function Fishing:loadFishDatas()
	local readFuncs = {
		["Name_DE"] = function (value) return utf8.escape(value) end,
		["Location"] = function(value) if fromJSON(value) then return fromJSON(value) else return value end end,
		["Season"] = function(value)  return fromJSON(value) end,
		["Times"] = function(value) return fromJSON(value) end,
		["Size"] = function(value) return fromJSON(value) end,
		["NeedEquipments"] = function(value) if value and fromJSON(value) then return fromJSON(value) else return value end end,
	}

	Fishing.Fish = sql:queryFetch("SELECT * FROM ??_fish_data", sql:getPrefix())
	Fishing.Statistics = sql:queryFetch("SELECT * FROM ??_fish_statistics", sql:getPrefix())

	for i, fish in pairs(Fishing.Fish) do
		for key, value in pairs(fish) do
			if readFuncs[key] then
				Fishing.Fish[i][key] = readFuncs[key](value)
			end
		end
	end
end

function Fishing:updateStatistics()
	self.m_Statistics = {}

	local result = sql:queryFetch("SELECT Id, FishCaught FROM ??_stats ORDER BY FishCaught DESC LIMIT 0, 10", sql:getPrefix())

	for key, value in pairs(result) do
		table.insert(self.m_Statistics, {Name = Account.getNameFromId(value.Id), FishCaught = value.FishCaught})
	end
end

function Fishing:getFish(location, timeOfDay, weather, season, playerLevel, fishingRodEquipments)
	local tmp = {}

	for _, v in pairs(Fishing.Fish) do
		local checkLocation = false
		local checkTime = false
		local checkWeather = false
		local checkSeason = false
		local checkEvent = false
		local checkPlayerLevel = false
		local checkEquipments = false

		-- Check Location
		if type(v.Location) == "table" then
			for key, value in pairs(v.Location) do
				if value == location then
					checkLocation = true
				end
			end
		elseif v.Location == location then
			checkLocation = true
		end

		-- Check Season
		if #v.Season == 1 and (v.Season[1] == season or v.Season[1] == 0) then
			checkSeason = true
		elseif type(v.Season) == "table" then
			for _, value in pairs(v.Season) do
				if value == season then
					checkSeason = true
				end
			end
		end

		-- Check time
		if #v.Times == 1 then
			checkTime = true
		else
			for i = 1, #v.Times, 2 do
				if timeOfDay >= v.Times[i] and timeOfDay <= v.Times[i+1] then
					checkTime = true
				end
			end
		end

		-- Check weather
		if v.Weather == 0 then			-- Any
			checkWeather = true
		elseif v.Weather == 1 then		-- Sunny
			if weather ~= 8 then
				checkWeather = true
			end
		elseif v.Weather == 2 then		-- Rainy
			if weather == 8 then
				checkWeather = true
			end
		end

		-- Check player level
		if v.MinLevel == 0 then
			checkPlayerLevel = true
		elseif playerLevel >= v.MinLevel then
			checkPlayerLevel = true
		end

		-- Check Equipments
		if type(v.NeedEquipments) == "table" then
			if self:checkEquipments(v.NeedEquipments, fishingRodEquipments) then
				checkEquipments = true
			end
		else
			checkEquipments = true
		end

		-- Check special event fish
		if v.Event == 0 then
			checkEvent = true
		elseif v.Event == FISHING_EVENT_ID.EASTER and EVENT_EASTER then
			checkEvent = true
		elseif v.Event == FISHING_EVENT_ID.HALLOWEEN and EVENT_HALLOWEEN then
			checkEvent = true
		elseif v.Event == FISHING_EVENT_ID.CHRISTMAS and EVENT_CHRISTMAS then
			checkEvent = true
		end

		-- Check all
		if checkLocation and checkTime and checkWeather and checkSeason and checkEvent and checkPlayerLevel and checkEquipments then
			table.insert(tmp, v)
		end
	end

	local availableFishCount = #tmp
	if availableFishCount > 0 and self.Random:get(1, 6) > math.max(1, 6 - availableFishCount) then
		return tmp[self.Random:get(1, availableFishCount)]
	else
		return false
	end
end

function Fishing:FishingRodCast()
	if not client.m_FishingRod then return end

	local fishingRodName = client.m_FishingRodType
	local fishingRodEquipments = self:getFishingRodEquipments(client, fishingRodName)
	local fishingRodItem = client:getInventory():getItem(fishingRodName)
	local fishingRodResult, fishingRodDestroyed = client:getInventory():decreaseItemDurability(fishingRodItem.Id, 1)

	local baitName = fishingRodEquipments["bait"] and fishingRodEquipments["bait"].TechnicalName or false
	local baitItem = client:getInventory():getItem(baitName)

	local accessorieName = fishingRodEquipments["accessories"] and fishingRodEquipments["accessories"].TechnicalName or false
	local accessorieItem = client:getInventory():getItem(accessorieName)
	if accessorieItem then
		accessorieResult, accessorieDestroyed = client:getInventory():decreaseItemDurability(accessorieItem.Id, 1)
	end

	
	if fishingRodDestroyed then
		client:sendWarning(_("Deine %s ist kaputt gegangen!", client, fishingRodItem.Name))
		client.m_FishingRod:destroy()
		client.m_FishingRod = nil
		client:triggerEvent("onFishingStop")
		return
	end

	if accessorieName and accessorieDestroyed then
		client:sendWarning(_("Dein %s an der Angel ist kaputt gegangen!", client, accessorieItem.Name))
		self:removeFishingRodEquipment(client, fishingRodName, accessorieName)
		self:updateFishingRodEquipments(client, fishingRodName)
	end

	if baitName then
		local playerInventory = client:getInventory()
		local itemAmount = playerInventory:getItemAmount(baitName)
		if itemAmount > 0 then
			local result, reason = playerInventory:takeItem(baitName, 1)

			if itemAmount == 1 then
				client:sendWarning(_("Das ist der letzte %s!", client, baitItem.Name))
				self:removeFishingRodEquipment(client, fishingRodName, baitName)
				self:updateFishingRodEquipments(client, fishingRodName)

				client.m_FishingLastBait = baitName
			end
		end
	end
end

function Fishing:FishHit(location, castPower)
	if not client.m_FishingRod then return end

	local time = tonumber(("%s%.2d"):format(getRealTime().hour, getRealTime().minute))
	local weather = getWeather()
	local season = getCurrentSeason()
	local playerLevel = client:getPrivateSync("FishingLevel")
	local fishingRodName = client.m_FishingRodType
	local baitName = false
	local accessorieName = false

	if client.m_FishingRodMeta then
		baitName = client.m_FishingRodMeta.bait or false
		accessorieName = client.m_FishingRodMeta.accessory or false
	end

	if client.m_FishingLastBait then
		baitName = client.m_FishingLastBait
		client.m_FishingLastBait = nil
	end

	local fish = self:getFish(location, time, weather, season, playerLevel, {baitName, accessorieName})
	if not fish then
		client:triggerEvent("onFishingBadCatch")
		local randomMessage
		if not client:isInSewer() then
			randomMessage = FISHING_BAD_CATCH_MESSAGES[self.Random:get(1, #FISHING_BAD_CATCH_MESSAGES)]
		else
			local index = self.Random:get(1, #FISHING_BAD_CATCH_MESSAGES_SEWERS)
			randomMessage = FISHING_BAD_CATCH_MESSAGES_SEWERS[index]
			if randomMessage ~= "nichts" then
				if math.random(1, 10) < 3 then
					if FISHING_BAD_CATCH_ITEMS_SEWERS[index] then
						client:getInventory():giveItem(FISHING_BAD_CATCH_ITEMS_SEWERS[index], 1)
					end
				else
					randomMessage = "nichts"
				end
			end
		end
		client:meChat(true, ("zieht %s aus dem Wasser!"):format(randomMessage))
		client:increaseStatistics("FishBadCatch")
		return
	end

	client:triggerEvent("fishingBobberBar", fish, fishingRodName, baitName, accessorieName)

	client.m_FishingLastFish = fish
	client.m_FishingLocation = location
	client.m_FishingCastPower = castPower
	client.m_FishingLastFishHit = getTickCount()
end

function Fishing:FishCaught()
	if not client.m_FishingRod then return end
	local playerLevel = client:getPrivateSync("FishingLevel")
	local timeToCatch = getTickCount() - client.m_FishingLastFishHit
	local size, isLegendary = self:getFishSize(playerLevel, client.m_FishingLastFish.Id, timeToCatch, client.m_FishingCastPower)
	local playerInventory = client:getInventory()
	local allBagsFull = false

	self:updatePlayerSkill(client, size)
	local newFishRecord = client:addFishSpecies(client.m_FishingLastFish.Id, size)
	client:increaseStatistics("FishCaught")

	if isLegendary then
		client:increaseStatistics("LegendaryFishCaught")
	end

	if client.m_FishingLastFish.Id == 37 then -- Blobfisch
		client:giveAchievement(101) -- Hässlichster Fisch der Welt
	end

	if client.m_FishingLastFish.Id == 73 or client.m_FishingLastFish.Id == 74 then
		client:giveAchievement(104) -- Mutantenfisch
	end

	local playerSpeciesCaughtCount = table.size(client:getFishSpeciesCaught())
	if playerSpeciesCaughtCount >= table.size(Fishing.Fish) then
		client:giveAchievement(95) -- Legendärer Angler
	elseif playerSpeciesCaughtCount >= 50 then
		client:giveAchievement(102) -- Angelmeister
	elseif playerSpeciesCaughtCount >= 24 then
		client:giveAchievement(94) -- Alter Seemann
	elseif playerSpeciesCaughtCount >= 10 then
		client:giveAchievement(93) -- Fischer
	end

	local fishCaughtCount = client:getStatistics("FishCaught")
	if fishCaughtCount >= 15000 then
		client:giveAchievement(103) -- Auf die Fische!
	elseif fishCaughtCount >= 500 then
		client:giveAchievement(97) -- Für Helene Fischer (hidden)
	elseif fishCaughtCount >= 150 then
		client:giveAchievement(96) -- Angelgott
	end

	for bagName, bagProperties in pairs(FISHING_BAGS) do
		local coolingBox = playerInventory:getItem(bagName)
		if coolingBox then
			local fishId = client.m_FishingLastFish.Id
			local fishName = client.m_FishingLastFish.Name_DE
			local fishItem = client.m_FishingLastFish.ItemName
			local itemData = {Metadata = {
				size = size, 
				quality = self:getFishQuality(fishId, size),
				Description = ("Größe: %dcm%s"):format(size, self:getFishQuality(fishId, size) > 0 and ("\n%d Sterne"):format(self:getFishQuality(fishId, size)) or "")
			}}
			local coolingBoxInventory = InventoryManager:getSingleton():getInventory(DbElementType.CoolingBox, coolingBox.Id, true)


			local result, reason = coolingBoxInventory:giveItem(fishItem, 1, itemData)

			if result then
				StatisticsLogger:getSingleton():addfishCaughtLogs(client, fishName, size, client.m_FishingLocation, fishId)
				client:sendInfo(("Du hast ein %s gefangen.\nGröße: %scm"):format(fishName, size, newFishRecord and "(Rekord!)" or ""))
				client:meChat(true, ("hat ein %s gefangen. Größe: %scm %s"):format(fishName, size, newFishRecord and "(Rekord!)" or ""))
				return
			end

			allBagsFull = true
		end
	end

	if allBagsFull then
		client:sendError("Deine Kühltaschen sind voll!")
		return
	end

	client:sendError("Du besitzt keine Kühltaschen, in der du deine Fische lagern kannst!")
end

function Fishing:FishEscape()
	if not client.m_FishingRod then return end
	client:meChat(true, "hat einen Fisch verloren!")
	client:increaseStatistics("FishLost")
end

function Fishing:getFishNameFromId(fishId)
	return Fishing.Fish[fishId].Name_DE
end

function Fishing:getFishIdFromItem(item)
	for k, v in pairs(Fishing.Fish) do
		if v.ItemName == item then
			return k
		end
	end
end

function Fishing:getFishSize(playerLevel, fishId, timeToCatch, castPower)
	local minFishSize = Fishing.Fish[fishId].Size[1]
	local maxFishSize = Fishing.Fish[fishId].Size[2]

	-- Check for a legendary fish
	if playerLevel >= LEGENDARY_MIN_LEVEL and self.Random:get(0, 200) <= playerLevel then
		return maxFishSize, true -- Normally we don't reach the maximum size due to time to catch reduction
	end

	local fishSizeTimeReduction = timeToCatch/2500
	local fishSizeLevelReduction = (self.Random:get(15, 15 + self.Random:get(0, playerLevel)) - playerLevel)*((maxFishSize-minFishSize)/self.Random:get(15, 25))

	local fishSize = math.max(minFishSize, (minFishSize + (maxFishSize - minFishSize) - (fishSizeTimeReduction + fishSizeLevelReduction))*castPower)

	return math.floor(fishSize)
end

function Fishing:updatePlayerSkill(player, skill)
	player:giveFishingSkill(skill)

	if player:getFishingLevel() < MAX_FISHING_LEVEL then
		if player:getFishingSkill() >= FISHING_LEVELS[player:getFishingLevel() + 1] then
			player:sendInfo("Fischer Level erhöht!")
			player:setFishingLevel(player:getFishingLevel() + 1)
			player:setFishingSkill(player:getFishingSkill() - FISHING_LEVELS[player:getFishingLevel()])
		end
	end
end

function Fishing:increaseFishCaughtCount(fishId)
	Fishing.Statistics[fishId].CaughtCount = Fishing.Statistics[fishId].CaughtCount + 1
	--sql:queryExec("UPDATE ??_fish_data SET CaughtCount = ? WHERE Id = ?", sql:getPrefix(), Fishing.Fish[fishId].CaughtCount, fishId)
	sql:queryExec("INSERT INTO ??_fish_statistics (FishId, CaughtCount, SoldCount) VALUES (?, 1, 0) ON DUPLICATE KEY UPDATE CaughtCount = CaughtCount + 1", sql:getPrefix(), fishId)
end

function Fishing:increaseFishSoldCount(fishId)
	Fishing.Statistics[fishId].SoldCount = Fishing.Statistics[fishId].SoldCount + 1
	--sql:queryExec("UPDATE ??_fish_data SET SoldCount = ? WHERE Id = ?", sql:getPrefix(), Fishing.Fish[fishId].SoldCount, fishId)
	sql:queryExec("INSERT INTO ??_fish_statistics (FishId, CaughtCount, SoldCount) VALUES (?, 0, 1) ON DUPLICATE KEY UPDATE SoldCount = SoldCount + 1", sql:getPrefix(), fishId)
end

function Fishing:onFishRequestPricing()
	local playerSpeciesCaught = client:getFishSpeciesCaught()
	client:triggerEvent("openFishPricingGUI", Fishing.Fish, playerSpeciesCaught)
end

function Fishing:onFishRequestTrading()
	local fishes = {}
	local playerInventory = client:getInventory()

	for bagName in pairs(FISHING_BAGS) do
		local coolingBox = playerInventory:getItem(bagName)
		if coolingBox then
			local coolingBoxInventory = InventoryManager:getSingleton():getInventory(DbElementType.CoolingBox, coolingBox.Id, true)
			local content = table.deepcopy(coolingBoxInventory.m_Items)

			for _, v in pairs(content) do
				v.fishId = self:getFishIdFromItem(v.TechnicalName)
			end

			table.insert(fishes, {name = coolingBox.Name, content = content})
		end
	end

	client:triggerEvent("openFishTradeGUI", fishes, Fishing.Fish)
end

function Fishing:clientSendFishTrading(list)
	local fishingLevel = client:getPrivateSync("FishingLevel")
	local fishingLevelMultiplicator = fishingLevel >= 10 and 1.5 or (fishingLevel >= 5 and 1.25 or 1)
	local totalPrice = 0

	for _, item in pairs(list) do
		local coolingBox = InventoryManager:getSingleton():getInventory(item.InventoryId, false, true)
		local result, reason = coolingBox:takeItem(item.Id, 1)
		if result then
			local default = Fishing.Fish[item.fishId].DefaultPrice
			local qualityMultiplicator = item.Metadata.quality == 3 and 2 or (item.Metadata.quality == 2 and 1.5 or (item.Metadata.quality == 1 and 1.25 or 1))
			local rareBonusMultiplicator = Fishing.Fish[item.fishId].RareBonus + 1

			local fishIncome = default*fishingLevelMultiplicator*qualityMultiplicator*rareBonusMultiplicator
			totalPrice = totalPrice + fishIncome

			self:increaseFishSoldCount(item.fishId)
			StatisticsLogger:getSingleton():addFishTradeLogs(client:getId(), 0, item.Name, item.Metadata.size, fishIncome, rareBonusMultiplicator)
		else
			client:sendError(_("Der Fisch '%s' mit einer Größe von %dcm konnte nicht verkauft werden!", client, item.Name, item.Metadata.size))
		end
	end

	if totalPrice > 0 then
		self.m_BankAccountServer:transferMoney(client, totalPrice, "Fischhandel", "Gampelay", "Fishing")
	end
end

function Fishing:getFishQuality(fishId, size)
	local minFishSize = Fishing.Fish[fishId].Size[1]
	local maxFishSize = Fishing.Fish[fishId].Size[2]
	local thirdSpan = (maxFishSize - minFishSize)/3

	if maxFishSize == size then
		return 3 -- Legendary
	elseif size < minFishSize + thirdSpan then
		return 0
	elseif size > maxFishSize - thirdSpan then
		return 2
	else
		return 1
	end
end

function Fishing:updatePricing()
	-- Create a sort table, otherwise we get trouble with Fish Ids
	local sortTable = {}
	for _, fish in pairs(Fishing.Statistics) do
		table.insert(sortTable, fish.SoldCount)
	end

	-- Calculate fish price depending by sold count
	table.sort(sortTable)

	-- Define price by the ratio with the average sold fish
	local averageSoldFish = sortTable[math.floor(#sortTable/3)]

	for _, fish in pairs(Fishing.Fish) do
		-- for i = 1, 5000000 do end -- otherwise the script is too fast to create random numbers
		fish.RareBonus = math.random(0, 10^6)/10^6 --math.max(1 - (Fishing.Statistics[fish.Id].SoldCount)/(averageSoldFish + 1), 0)
	end
end

function Fishing:onPlayerQuit()
	if source.m_FishingRod then
		local fishingRod = source.m_FishingRod.fishingRod
		if fishingRod then fishingRod:destroy() end
	end
end

function Fishing:onFishRequestStatistics()
	client:triggerEvent("openFisherStatisticsGUI", self.m_Statistics)
end

function Fishing:checkEquipments(needEquipments, fishingRodEquipments)
	for _, needEquipment in pairs(needEquipments) do
		for _, rodEquipment in pairs(fishingRodEquipments) do
			if needEquipment == rodEquipment then
				return true
			end
		end
	end
end

--- EQUIPMENT HANDLING (bait, accessories)
function Fishing:updateFishingRodEquipments(player, fishingRodName)
	local fishingRodEquipments = self:getFishingRodEquipments(player, fishingRodName)
	local baitName = fishingRodEquipments["bait"] or false
	local accessorieName = fishingRodEquipments["accessories"] or false
	player:triggerEvent("onFishingUpdateEquipments", baitName, accessorieName)
end

function Fishing:onAddFishingRodEquipment(fishingRod, equipmentName)
	if not (fishingRod and equipmentName) then return end

	if self:addFishingRodEquipment(client, fishingRod, equipmentName) then
		if client.m_FishingRod then
			self:updateFishingRodEquipments(client, fishingRod)
		end
	end
end

function Fishing:onRemoveFishingRodEquipment(fishingRod, equipmentName)
	if not (fishingRod and equipmentName) then return end

	if self:removeFishingRodEquipment(client, fishingRod, equipmentName) then
		if client.m_FishingRod then
			self:updateFishingRodEquipments(client, fishingRod)
		end
	end
end

function Fishing:getFishingRodEquipments(player, fishingRodName)
	local equipmentSlots = {["baitSlots"] = "bait", ["accessorieSlots"] = "accessories"}
	local equipements = {}

	for key, valueName in pairs(equipmentSlots) do
		if FISHING_RODS[fishingRodName][key] > 0 then
			local playerInventory = player:getInventory()
			local fishingRodItem = playerInventory:getItem(fishingRodName)
			local fishingRodMetadata = fishingRodItem.Metadata

			local equipment = playerInventory:getItem(fishingRodMetadata[valueName])
			if equipment and FISHING_EQUIPMENT[equipment.TechnicalName] then
				equipements[valueName] = equipment
			else
				equipements[valueName] = false
			end
		end
	end

	return equipements
end

function Fishing:isPlayerFishing(player) return isElement(player.m_FishingRod) end

function Fishing:addFishingRodEquipment(player, fishingRodName, equipment)
	local playerInventory = player:getInventory()
	local fishingRodItem = playerInventory:getItem(fishingRodName)
	local equipmentItem = playerInventory:getItem(equipment)
	if fishingRodItem and equipmentItem then
		local savingTable = FISHING_BAITS[equipment] and "bait" or "accessories"
		local fishingRodItem = playerInventory:getItem(fishingRodName)
		fishingRodItem.Metadata[savingTable] = equipment

		player:sendInfo(_("%s an %s angebracht!", player, equipmentItem.Name, fishingRodItem.Name))

		return true
	end
end

function Fishing:removeFishingRodEquipment(player, fishingRodName, equipment)
	local playerInventory = player:getInventory()
	if playerInventory:getItem(fishingRodName) then
		local savingTable = FISHING_BAITS[equipment.TechnicalName] and "bait" or "accessories"
		local fishingRodItem = playerInventory:getItem(fishingRodName)
		fishingRodItem.Metadata[savingTable] = nil

		return true
	end
end

--- Create water areas
function Fishing:createDesertWater()
	for _, position in pairs(FISHING_DESERT_WATER) do
		createWater(position.l, position.d, FISHING_DESERT_WATERHEIGHT, position.r, position.d, FISHING_DESERT_WATERHEIGHT, position.l, position.u, FISHING_DESERT_WATERHEIGHT, position.r, position.u, FISHING_DESERT_WATERHEIGHT)
	end

	for _, position in pairs(FISHING_CAVE_WATER) do
		createWater(position.l, position.d, FISHING_CAVE_WATERHEIGHT, position.r, position.d, FISHING_CAVE_WATERHEIGHT, position.l, position.u, FISHING_CAVE_WATERHEIGHT, position.r, position.u, FISHING_CAVE_WATERHEIGHT)
	end
end

function convertFishSpeciesCaught(target)
	local st = getTickCount()
	local prefix = sql:getPrefix()
	local result = sqlLogs:queryFetch("SELECT PlayerId, FishId, COUNT(*) AS Count, MAX(FishSize) AS MaxFishSize, UNIX_TIMESTAMP(MAX(Date)) AS LastCaught FROM vrpLogs_fishCaught GROUP BY PlayerId, FishId")

	local dataTable = {}
	for _, data in pairs(result) do
		if not dataTable[data.PlayerId] then dataTable[data.PlayerId] = {} end
		if data.FishId then
			dataTable[data.PlayerId][data.FishId] = {data.Count or 1, data.MaxFishSize or false, data.LastCaught or false}
		end
	end

	for playerId, data in pairs(dataTable) do
		sql:queryExec("UPDATE ??_character SET FishSpeciesCaught = ? WHERE Id = ?", prefix, toJSON(data), playerId)
	end

	outputConsole(("Operation done (%s ms)"):format(getTickCount()-st))
end

--[[
addCommandHandler("testFish",
	function(player, cmd, location, weather, season, level, bait, accessorie)
		local fish = Fishing:getSingleton()
		outputConsole(("Location: %s\nWeather: %s\nSeason: %s\nLevel: %s\nBait: %s\nAccessorie: %s"):format(location, weather, season, level, tostring(bait and bait or "keine"), tostring(accessorie and accessorie or "keine")))
		outputConsole("Uhrzeit, Anzahl")
		for i = 1, 24 do
			local time = tonumber(("%s%.2d"):format(i, 0))
			local count = fish:getFish(location, time, weather, tonumber(season), tonumber(level), {bait and bait or false, accessorie and accessorie or false})
			outputConsole(("%s, %s"):format(time, count))
		end
	end
)]]
