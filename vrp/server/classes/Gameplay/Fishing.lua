-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Fishing.lua
-- *  PURPOSE:     Serverside Fishing Class
-- *
-- ****************************************************************************
Fishing = inherit(Singleton)
addRemoteEvents{"clientFishHit", "clientFishCaught", "clientFishEscape", "clientRequestFishPricing", "clientRequestFishTrading", "clientSendFishTrading", "clientRequestFishStatistics", "clientAddFishingRodEquipment", "clientRemoveFishingRodEquipment", "clientDecreaseFishingEquipment"}

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
	addEventHandler("clientFishHit", root, bind(Fishing.FishHit, self))
	addEventHandler("clientFishCaught", root, bind(Fishing.FishCaught, self))
	addEventHandler("clientFishEscape", root, bind(Fishing.FishEscape, self))
	addEventHandler("clientRequestFishPricing", root, bind(Fishing.onFishRequestPricing, self))
	addEventHandler("clientRequestFishTrading", root, bind(Fishing.onFishRequestTrading, self))
	addEventHandler("clientSendFishTrading", root, bind(Fishing.clientSendFishTrading, self))
	addEventHandler("clientRequestFishStatistics", root, bind(Fishing.onFishRequestStatistics, self))

	addEventHandler("clientAddFishingRodEquipment", root, bind(Fishing.onAddFishingRodEquipment, self))
	addEventHandler("clientRemoveFishingRodEquipment", root, bind(Fishing.onRemoveFishingRodEquipment, self))
	addEventHandler("clientDecreaseFishingEquipment", root, bind(Fishing.onDecreaseFishingEquipment, self))
end

function Fishing:destructor()
end

function Fishing:loadFishDatas()
	local readFuncs = {
		["Name_DE"] = function (value) return utf8.escape(value) end,
		["Location"] = function(value) if fromJSON(value) then return fromJSON(value) else return value end end,
		["Season"] = function(value) if fromJSON(value) then return fromJSON(value) end end,
		["Times"] = function(value) return fromJSON(value) end,
		["Size"] = function(value) return fromJSON(value) end,
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

function Fishing:getFish(location, timeOfDay, weather, season, playerLevel, bait)
	local tmp = {}

	for _, v in pairs(Fishing.Fish) do
		local checkLocation = false
		local checkTime = false
		local checkWeather = false
		local checkSeason = false
		local checkEvent = false
		local checkPlayerLevel = false
		local checkBait = false

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
		if type(v.Season) == "table" then
			for _, value in pairs(v.Season) do
				if value == season then
					checkSeason = true
				end
			end
		elseif v.Season == 0 or v.Season == season then
			checkSeason = true
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

		-- Check bait
		if v.NeedBait == 0 then
			checkBait = true
		elseif v.NeedBait == 1 and bait then
			checkBait = true
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
		if checkLocation and checkTime and checkWeather and checkSeason and checkEvent and checkPlayerLevel and checkBait then
			table.insert(tmp, v)
		end
	end

	local availableFishCount = #tmp

	-- TODO DEV [[
	--outputChatBox("count: " .. availableFishCount)
	if true then return tmp[self.Random:get(1, availableFishCount)] end
	--- TODO DEV ]]

	if self.Random:get(1, 6) > math.max(1, 6 - availableFishCount) then
		return tmp[self.Random:get(1, availableFishCount)]
	else
		return false
	end
end

function Fishing:FishHit(location, castPower)
	if not self.m_Players[client] then return end

	local time = tonumber(("%s%.2d"):format(getRealTime().hour, getRealTime().minute))
	local weather = getWeather()
	local season = getCurrentSeason()
	local playerLevel = client:getPrivateSync("FishingLevel")
	local fishingRodName = self.m_Players[client].fishingRodName
	local bait = self:checkBait(client, location)

	local fish = self:getFish(location, time, weather, season, playerLevel, bait)
	if not fish then
		client:triggerEvent("onFishingBadCatch")
		local randomMessage = FISHING_BAD_CATCH_MESSAGES[self.Random:get(1, #FISHING_BAD_CATCH_MESSAGES)]
		client:meChat(true, ("hat %s geangelt!"):format(randomMessage))
		client:increaseStatistics("FishBadCatch")
		return
	end

	client:triggerEvent("fishingBobberBar", fish, fishingRodName, bait)

	self.m_Players[client].lastFish = fish
	self.m_Players[client].location = location
	self.m_Players[client].castPower = castPower
	self.m_Players[client].lastFishHit = getTickCount()
end

function Fishing:FishCaught()
	if not self.m_Players[client] then return end
	local playerLevel = client:getPrivateSync("FishingLevel")
	local tbl = self.m_Players[client]
	local timeToCatch = getTickCount() - tbl.lastFishHit
	local size, isLegendary = self:getFishSize(playerLevel, tbl.lastFish.Id, timeToCatch, tbl.castPower)
	local playerInventory = client:getInventory()
	local allBagsFull = false

	self:updatePlayerSkill(client, size)
	client:addFishSpecies(tbl.lastFish.Id)
	client:increaseStatistics("FishCaught")

	if isLegendary then
		client:increaseStatistics("LegendaryFishCaught")
	end

	if tbl.lastFish.Id == 37 then -- Blobfisch
		client:giveAchievement(101) -- Hässlichster Fisch der Welt
	end

	local playerSpeciesCaughtCount = client:getFishSpeciesCaughtCount()
	if playerSpeciesCaughtCount >= #Fishing.Fish then
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
		if playerInventory:getItemAmount(bagName) > 0 then
			local place = playerInventory:getItemPlacesByName(bagName)[1][1]
			local fishId = tbl.lastFish.Id
			local fishName = tbl.lastFish.Name_DE
			local currentValue = playerInventory:getItemValueByBag(FISHING_INVENTORY_BAG, place)
			currentValue = fromJSON(currentValue) or {}

			if #currentValue < bagProperties.max then
				table.insert(currentValue, {Id = fishId, size = size, quality = self:getFishQuality(fishId, size), timestamp = getRealTime().timestamp})
				playerInventory:setItemValueByBag(FISHING_INVENTORY_BAG, place, toJSON(currentValue))

				self:increaseFishCaughtCount(fishId)

				StatisticsLogger:getSingleton():addfishCaughtLogs(client, fishName, size, tbl.location)
				client:sendInfo(("Du hast ein %s gefangen.\nGröße: %scm"):format(fishName, size))
				client:meChat(true, ("hat ein %s gefangen. Größe: %scm"):format(fishName, size))
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
	if not self.m_Players[client] then return end
	client:meChat(true, "hat einen Fisch verloren!")
	client:increaseStatistics("FishLost")
end

function Fishing:getFishNameFromId(fishId)
	return Fishing.Fish[fishId].Name_DE
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
	-- Todo: Only trigger specific datas
	client:triggerEvent("openFishPricingGUI", Fishing.Fish)
end

function Fishing:onFishRequestTrading()
	local fishes = {}
	local playerInventory = client:getInventory()

	for bagName in pairs(FISHING_BAGS) do
		if playerInventory:getItemAmount(bagName) > 0 then
			local place = playerInventory:getItemPlacesByName(bagName)[1][1]
			local currentValue = playerInventory:getItemValueByBag(FISHING_INVENTORY_BAG, place)
			currentValue = fromJSON(currentValue) or {}

			for _, v in pairs(currentValue) do
				v.fishName = self:getFishNameFromId(v.Id)
			end

			table.insert(fishes, {name = bagName, content = currentValue})
		end
	end

	client:triggerEvent("openFishTradeGUI", fishes, Fishing.Fish)
end

function Fishing:clientSendFishTrading(list)
	local fishingLevel = client:getPrivateSync("FishingLevel")
	local fishingLevelMultiplicator = fishingLevel >= 10 and 1.5 or (fishingLevel >= 5 and 1.25 or 1)
	local totalPrice = 0

	for _, item in pairs(list) do
		local fish = self:getFishInCoolingBag(item.fishId, item.fishSize)
		if fish then
			local default = Fishing.Fish[fish.Id].DefaultPrice
			local qualityMultiplicator = fish.quality == 3 and 2 or (fish.quality == 2 and 1.5 or (fish.quality == 1 and 1.25 or 1))
			local rareBonusMultiplicator = Fishing.Fish[fish.Id].RareBonus + 1

			local fishIncome = default*fishingLevelMultiplicator*qualityMultiplicator*rareBonusMultiplicator
			totalPrice = totalPrice + fishIncome

			self:removeFrishFromCoolingBag(fish.Id, fish.size)
			self:increaseFishSoldCount(fish.Id)
			StatisticsLogger:getSingleton():addFishTradeLogs(client:getId(), 0, fish.fishName, fish.size, fishIncome, rareBonusMultiplicator)
		end
	end

	if totalPrice > 0 then
		self.m_BankAccountServer:transferMoney(client, totalPrice, "Fischhandel", "Gampelay", "Fishing")
	end
end

function Fishing:getFishInCoolingBag(fishId, fishSize)
	local playerInventory = client:getInventory()

	for bagName in pairs(FISHING_BAGS) do
		if playerInventory:getItemAmount(bagName) > 0 then
			local place = playerInventory:getItemPlacesByName(bagName)[1][1]
			local currentValue = playerInventory:getItemValueByBag(FISHING_INVENTORY_BAG, place)
			currentValue = fromJSON(currentValue) or {}

			for _, fish in pairs(currentValue) do
				if fish.Id == fishId and fish.size == fishSize then
					return fish
				end
			end
		end
	end
end

function Fishing:removeFrishFromCoolingBag(fishId, fishSize)
	local playerInventory = client:getInventory()

	for bagName in pairs(FISHING_BAGS) do
		if playerInventory:getItemAmount(bagName) > 0 then
			local place = playerInventory:getItemPlacesByName(bagName)[1][1]
			local currentValue = playerInventory:getItemValueByBag(FISHING_INVENTORY_BAG, place)
			currentValue = fromJSON(currentValue) or {}

			for index, fish in pairs(currentValue) do
				if fish.Id == fishId and fish.size == fishSize then
					table.remove(currentValue, index)
					playerInventory:setItemValueByBag(FISHING_INVENTORY_BAG, place, toJSON(currentValue))
					return
				end
			end
		end
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
		fish.RareBonus = math.max(1 - (Fishing.Statistics[fish.Id].SoldCount)/(averageSoldFish + 1), 0)
	end
end

function Fishing:inventoryUse(player, fishingRodName)
	if self.m_Players[player] then
		local fishingRod = self.m_Players[player].fishingRod
		if fishingRod then fishingRod:destroy() end
		self.m_Players[player] = nil

		player:triggerEvent("onFishingStop")
		return
	end

	local baitName = self:getFishingRodEquipments(player, fishingRodName)["bait"]
	local fishingRod = createObject(1826, player.position)
	player:attachPlayerObject(fishingRod)

	self.m_Players[player] = {
		fishingRod = fishingRod,
		fishingRodName = fishingRodName,
		baitName = baitName,
	}

	player:triggerEvent("onFishingStart", fishingRod, fishingRodName, baitName)
end

function Fishing:onPlayerQuit()
	if self.m_Players[source] then
		local fishingRod = self.m_Players[source].fishingRod
		if fishingRod then fishingRod:destroy() end
	end
end

function Fishing:onFishRequestStatistics()
	client:triggerEvent("openFisherStatisticsGUI", self.m_Statistics)
end

function Fishing:checkBait(player, location)
	local lastBait = self.m_Players[player].lastBait
	local baitName = self.m_Players[player].baitName

	if not (lastBait or baitName) then return false end

	self.m_Players[player].lastBait = nil
	local checkBait = lastBait and lastBait or baitName

	for _, baitLocation in pairs(FISHING_BAITS[checkBait].location) do
		if baitLocation == location then
			return checkBait
		end
	end

	return false
end

--- EQUIPMENT HANDLING (bait, accessories)
function Fishing:onAddFishingRodEquipment(fishingRod, equipmentName)
	if not (fishingRod and equipmentName) then return end

	if self:addFishingRodEquipment(client, fishingRod, equipmentName) then
		if self.m_Players[client] and FISHING_BAITS[equipmentName] then
			self.m_Players[client].baitName = equipmentName
			self.m_Players[client].lastBait = nil
			client:triggerEvent("onFishingUpdateBaits", equipmentName, 1)
		end
	end
end

function Fishing:onRemoveFishingRodEquipment(fishingRod, equipmentName)
	if not (fishingRod and equipmentName) then return end

	if self:removeFishingRodEquipment(client, fishingRod, equipmentName) then
		if self.m_Players[client] then
			self.m_Players[client].baitName = false
		end
	end
end

function Fishing:onDecreaseFishingEquipment(baitName) --  TODO: Add support for accessories
	if not self.m_Players[client] then return end
	if self.m_Players[client].baitName ~= baitName then outputChatBox("INVALID decreasing equipment!") return end

	local playerInventory = client:getInventory()
	local fishingRodName = self.m_Players[client].fishingRodName
	local baitName = self.m_Players[client].baitName

	self.m_Players[client].lastBait = nil

	if FISHING_BAITS[baitName] then
		local itemAmount = playerInventory:getItemAmount(baitName)
		if itemAmount > 0 then
			playerInventory:removeItem(baitName, 1)

			if itemAmount == 1 then -- To avaid a stupid calculation lel 1337
				client:sendWarning(_("Das ist der letzte %s!", client, baitName))
				client:triggerEvent("onFishingUpdateBaits", baitName, 0) -- Tell now. It will just used for the next throw.
				self:removeFishingRodEquipment(client, fishingRodName, baitName)

				self.m_Players[client].lastBait = baitName
				self.m_Players[client].baitName = false
			end
		end
	end
end

function Fishing:getFishingRodEquipments(player, fishingRodName)
	local equipmentSlots = {["baitSlots"] = "bait", ["accessorieSlots"] = "accessories"}
	local equipements = {}

	for key, valueName in pairs(equipmentSlots) do
		if FISHING_RODS[fishingRodName][key] > 0 then
			local playerInventory = player:getInventory()
			local place = playerInventory:getItemPlacesByName(fishingRodName)[1][1]
			local fishingRodValue = playerInventory:getItemValueByBag(FISHING_INVENTORY_BAG, place)
			fishingRodValue = fromJSON(fishingRodValue) or {}

			local equipment = fishingRodValue[valueName]
			if FISHING_EQUIPMENT[equipment] and playerInventory:getItemAmount(equipment) > 0 then
				equipements[valueName] = equipment
			else
				equipements[valueName] = false
			end
		else
			equipements[valueName] = false
		end
	end

	return equipements
end

function Fishing:addFishingRodEquipment(player, fishingRodName, equipment)
	local playerInventory = player:getInventory()
	if playerInventory:getItemAmount(fishingRodName) > 0 and playerInventory:getItemAmount(equipment) > 0 then
		local savingTable = FISHING_BAITS[equipment] and "bait" or "accessories"
		local place = playerInventory:getItemPlacesByName(fishingRodName)[1][1]
		local fishingRodValue = playerInventory:getItemValueByBag(FISHING_INVENTORY_BAG, place)
		fishingRodValue = fromJSON(fishingRodValue) or {}
		fishingRodValue[savingTable] = equipment

		playerInventory:setItemValueByBag(FISHING_INVENTORY_BAG, place, toJSON(fishingRodValue))
		player:sendInfo(_("%s an %s angebracht!", player, equipment, fishingRodName))

		return true
	end
end

function Fishing:removeFishingRodEquipment(player, fishingRodName, equipment)
	local playerInventory = player:getInventory()
	if playerInventory:getItemAmount(fishingRodName) > 0 then
		local savingTable = FISHING_BAITS[equipment] and "bait" or "accessories"
		local place = playerInventory:getItemPlacesByName(fishingRodName)[1][1]
		local fishingRodValue = playerInventory:getItemValueByBag(FISHING_INVENTORY_BAG, place)
		fishingRodValue = fromJSON(fishingRodValue) or {}
		fishingRodValue[savingTable] = nil

		playerInventory:setItemValueByBag(FISHING_INVENTORY_BAG, place, toJSON(fishingRodValue))

		return true
	end
end


--- Create some water areas (TODO: CAVE!)
function Fishing:createDesertWater()
	for _, position in pairs(FISHING_DESERT_WATER) do
		createWater(position.l, position.d, FISHING_DESERT_WATERHEIGHT, position.r, position.d, FISHING_DESERT_WATERHEIGHT, position.l, position.u, FISHING_DESERT_WATERHEIGHT, position.r, position.u, FISHING_DESERT_WATERHEIGHT)
	end
end
