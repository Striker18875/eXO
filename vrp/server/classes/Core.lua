Core = inherit(Object)
addEvent("Core.onClientInternalError", true)

function Core:constructor()
	outputServerLog("Initializing core...")

	-- Small hack to get the global core immediately
	core = self
	self.m_Failed = false
	self.ms_StopHook = Hook:new()

	if DEBUG then
		Debugging:new()
	end

	Config:new()

	-- Update MySQL DB if this is not the testserver/releaseserver
	if not IS_TESTSERVER then
		--MYSQL_DB = "vrp_local"
	end

	-- Establish database connection
	sql = MySQL:new(Config.get('mysql')['main']['host'], Config.get('mysql')['main']['port'], Config.get('mysql')['main']['username'], Config.get('mysql')['main']['password'], Config.get('mysql')['main']['database'], Config.get('mysql')['main']['socket'])
	sql:setPrefix("vrp")
	board = MySQL:new(Config.get('mysql')['board']['host'], Config.get('mysql')['board']['port'], Config.get('mysql')['board']['username'], Config.get('mysql')['board']['password'], Config.get('mysql')['board']['database'], Config.get('mysql')['board']['socket'])
	sqlPremium = MySQL:new(Config.get('mysql')['premium']['host'], Config.get('mysql')['premium']['port'], Config.get('mysql')['premium']['username'], Config.get('mysql')['premium']['password'], Config.get('mysql')['premium']['database'], Config.get('mysql')['premium']['socket'])
	sqlLogs = MySQL:new(Config.get('mysql')['logs']['host'], Config.get('mysql')['logs']['port'], Config.get('mysql')['logs']['username'], Config.get('mysql')['logs']['password'], Config.get('mysql')['logs']['database'], Config.get('mysql')['logs']['socket'])
	sqlLogs:setPrefix("vrpLogs")

	-- Create ACL user for web-access
	self.m_ACLAccount = addAccount("exo_web", "tp&Qy?d{SbS*~By]")

	local aclGroup = aclGetGroup("web")
    if not aclGroup then aclGroup = aclCreateGroup("web") end

	local acl = aclGet("web")
    if not acl then acl = aclCreate("web") end

	aclGroupAddACL(aclGroup, acl)
	acl:setRight("general.http", true)
	acl:setRight("function.callRemote", true)
	acl:setRight("function.fetchRemote", true)

	aclGroup:addObject("user.exo_web")
	ACLGroup.get("Admin"):addObject("resource.admin_exo")

	if GIT_BRANCH == "release/production" then
		setServerPassword()
	end

	-- Instantiate classes (Create objects)
	if not self.m_Failed then
		AntiCheat:new()
		ModdingCheck:new()
		TranslationManager:new()
		GlobalTimer:new()
		MTAFixes:new()
		VehicleManager:new()
		Admin:new()
		StatisticsLogger:new()
		--WhiteList:new()
		PhoneInteraction:new()
		PlayerManager:new()
		JobManager:new()
		BankManager:new()
		Async.create(function() Forum:new() end)()
		--WantedSystem:new()
		Provider:new()
		GroupManager:new()
		GroupPropertyManager:new()
		HouseManager:new()
		AmmuNationManager:new()
		--Police:new()
		EventManager:new()
		--GangAreaManager:new()
		Weather:new()
		--JailBreak:new()
		Nametag:new()
		Collectables:new()
		Achievement:new()
		SkinShops:new()
		--Deathmatch:new() Not finished
		VehicleTuningShop:new()
		DimensionManager:new()
		ActorManager:new()
		InteriorManager:new()
		FactionManager:new()
		CompanyManager:new()
		Guns:new()
		InventoryManager:new()
		ItemManager:new()
		Casino:new()
		ActionsCheck:new()
		TrainManager:new()
		FireManager:new()
		ShopManager:new()
		Jail:new()
		VehicleInteraction:new()
		VehicleHarbor:new()
		Tour:new()
		GrowableManager:new()
		MinigameManager:new()
		Townhall:new()
		BeggarPedManager:new()
		Fishing:new()
		ShootingRanch:new()
		DeathmatchManager:new()
		SkydivingManager:new()
		Kart:new()
		HorseRace:new()
		BoxManager:new()
		self.m_TeamspeakAPI = TSConnect:new("https://exo-reallife.de/ingame/TSConnect/ts_connect.php", "exoServerBot", "wgCGAoO8", 10011, "ts.exo-reallife.de", 9987)

		VehicleManager.loadVehicles()
		VendingMachine.initializeAll()
		VehicleGarages.initalizeAll()
		VehicleSpawner.initializeAll()
		PayNSpray.initializeAll()
		TollStation.initializeAll()
		Depot.initalize()

		BankRobbery:new()

		ChessSessionManager:new()
		-- Generate Missions
		--MStealWeaponTruck:new()

		-- Missions
		MWeaponTruck:new()
		MWeedTruck:new()

		--// Gangwar
		Gangwar:new()
		GangwarStatistics:new()
		--SprayWallManager:new()

		-- Disable Heathaze-Effect (causes unsightly effects on 3D-GUIs e.g. SpeakBubble3D)
		setHeatHaze(0)

		-- Generate Package
		if not HTTP_DOWNLOAD then -- not required in HTTP-Download mode
			local xml = xmlLoadFile("meta.xml")
			local files = {}
			for k, v in pairs(xmlNodeGetChildren(xml)) do
				if xmlNodeGetName(v) == "vrpfile" then
					files[#files+1] = xmlNodeGetAttribute(v, "src")
				end
			end
			Package.save("vrp.data", files)
			Provider:getSingleton():offerFile("vrp.data")
		end

		-- Refresh all players
		for k, v in pairs(getElementsByType("player")) do
			Async.create(Player.connect)(v)
		end
		for k, v in pairs(getElementsByType("player")) do
			Async.create(Player.join)(v)
		end

		local realtime = getRealTime()
		setTime(realtime.hour, realtime.minute)
		setMinuteDuration(60000)

		setOcclusionsEnabled(false)

		addEventHandler("Core.onClientInternalError", root, bind(self.onClientInternalError, self))

		-- Prepare unit tests
		if DEBUG then
			addCommandHandler("runtests", bind(self.runTests, self))
		end

		Blip:new("North.png", 0, 6000, root, 12000)

		GlobalTimer:getSingleton():registerEvent(function()
			outputChatBox("Achtung: Der Server wird in 10 Minuten neu gestartet!", root, 255, 0, 0)
		end, "Server Restart Message 1", nil, 04, 50)
		GlobalTimer:getSingleton():registerEvent(function()
			outputChatBox("Achtung: Der Server wird in 5 Minuten neu gestartet!", root, 255, 0, 0)
		end, "Server Restart Message 2", nil, 04, 55)

		GlobalTimer:getSingleton():registerEvent(function()
			getThisResource():restart()
		end, "Server Restart", nil, 05, 00)

	end
end

function Core:onClientInternalError (msg)
	outputDebug(("[%s] Internal Client Error occurred: %s"):format(getPlayerName(client), msg))
	kickPlayer(client, "Server - Error Handler", ("Internal Error occurred: %s"):format(msg))
end

function Core:destructor()
	if not self.m_Failed then
		ACLGroup.get("Admin"):removeObject("user.exo_web")
		if self.m_ACLAccount then
			removeAccount(self.m_ACLAccount)
		end

		delete(VehicleManager:getSingleton())
		delete(PlayerManager:getSingleton())
		delete(GroupManager:getSingleton())
		if HouseManager:isInstantiated() then
			delete(HouseManager:getSingleton())
		end
		delete(FactionManager:getSingleton())
		delete(CompanyManager:getSingleton())
		delete(InventoryManager:getSingleton())
		delete(ShopManager:getSingleton())
		delete(GrowableManager:getSingleton())
		delete(GangwarStatistics:getSingleton())
		delete(GroupPropertyManager:getSingleton())
		delete(Admin:getSingleton())
		delete(StatisticsLogger:getSingleton())
		delete(sql) -- Very slow
	end
end

function Core:runTests()
	-- Instantiates tests here
	UtilsTest:new("UtilsTest")
	--GroupTest:new("GroupTest") // Throws an Erorr
	PromiseTest:new("PromiseTest")
end

function Core:getVersion()
	if self.m_Version == nil then
		local file = File.Open("version.txt")
		if file then
			self.m_Version = file:getContent()
			file:close()
		else
			self.m_Version = false
		end
	end
	return self.m_Version
end

function Core:getStopHook()
	return self.ms_StopHook
end
