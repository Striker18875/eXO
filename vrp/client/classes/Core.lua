Core = inherit(Object)

function Core:constructor()
	-- Small hack to get the global core immediately
	core = self

	-- Instantiate the localPlayer instance right now
	enew(localPlayer, LocalPlayer)

	self.m_Config = ConfigXML:new("config.xml")
	Version:new()
	Provider:new()

	Cursor = GUICursor:new()

	if HTTP_DOWNLOAD then -- In debug mode use old Provider
		showChat(false)

		Async.create( -- HTTPProvider needs asynchronous "context"
			function()
				fadeCamera(true)

				local dgi = HTTPDownloadGUI:getSingleton()
				local provider = HTTPProvider:new(FILE_HTTP_SERVER_URL, dgi)
				if provider:start() then -- did the download succeed
					delete(dgi)
					self:onDownloadComplete()
				end
			end
		)()
	else
		DownloadGUI:new()
		local dgi = DownloadGUI:getSingleton()
		Provider:getSingleton():requestFile("vrp.data", bind(DownloadGUI.onComplete, dgi), bind(DownloadGUI.onProgress, dgi))
		setAmbientSoundEnabled( "gunfire", false )
		showChat(true)
	end
end

function Core:onDownloadComplete()
	-- Instantiate all classes
	self:ready()

	-- create login gui
	lgi = LoginGUI:new()
	lgi:setVisible(false)
	lgi:fadeIn(750)

	local pwhash = core:get("Login", "password", "")
	local username = core:get("Login", "username", "")
	lgi.m_LoginEditUser:setText(username)
	lgi.m_LoginEditPass:setText(pwhash)
	lgi.usePasswordHash = pwhash
	lgi.m_LoginCheckbox:setChecked(pwhash ~= "")
	lgi:anyChange()

	-- other
	setAmbientSoundEnabled( "gunfire", false )
	showChat(true)
end

function Core:ready()
	-- Tell the server that we're ready to accept additional data
	triggerServerEvent("playerReady", root)

	TranslationManager:new()
	HelpTextManager:new()
	MTAFixes:new()
	ClickHandler:new()
	HoverHandler:new()
	CustomModelManager:new()
	--GangAreaManager:new()
	HelpBar:new()
	JobManager:new()
	Achievement:new()
	TippManager:new()
	--JailBreak:new()
	DimensionManager:new()
	Inventory:new()
	Guns:new()
	Casino:new()
	TrainManager:new()
	Fire:new()
	VehicleInteraction:new()
	EventManager:new()
	DMRaceEvent:new()
	DeathmatchEvent:new()
	StreetRaceEvent:new()
	VehicleGarages:new()
	ELSSystem:new()
	GasStationGUI:new()
	SkinShopGUI.initializeAll()
	ItemManager:new()
	--// Gangwar
	GangwarClient:new()
	GangwarStatistics:new()

	MostWanted:new()
	NoDm:new()
	FactionManager:new()
	CompanyManager:new()
	DeathmatchManager:new()
	Townhall:new()

	PlantWeed.initalize()
	ItemSellContract:new()
	Neon.initalize()
	AccessoireClothes:new()
	AccessoireClothes:triggerMode()
	MiamiSpawnGUI:new()

	Shaders.load()

	GroupProperty:new()
	GUIWindowsFocus:new()
	SprayWallManager:new()
	AntiClickSpam:new()

	ChessSession:new()

	triggerServerEvent("drivingSchoolRequestSpeechBubble",localPlayer)
end

function Core:afterLogin()
	-- Request Browser Domains
	Browser.requestDomains{"exo-reallife.de"}

	RadioGUI:new()
	KarmaBar:new()
	HUDSpeedo:new()
	Nametag:new()
	HUDRadar:getSingleton():show()
	HUDUI:getSingleton():show()
	Collectables:new()
	KeyBinds:new()

	if DEBUG then
		Debugging:new()
		DebugGUI.initalize()
	end

	SelfGUI:new()
	SelfGUI:getSingleton():close()
	addCommandHandler("self", function() SelfGUI:getSingleton():open() end)

	FactionGUI:new()
	FactionGUI:getSingleton():close()
	addCommandHandler("fraktion", function() FactionGUI:getSingleton():open() end)

	ScoreboardGUI:new()
	ScoreboardGUI:getSingleton():close()

	Phone:new()
	Phone:getSingleton():close()

	-- Pre-Instantiate important GUIS
	-- TODO: I think we have to improve this block, currently i don't have an idea. (In my tests this takes ~32ms, relevant?)
	GroupGUI:new()
	GroupGUI:getSingleton():close()
	TicketGUI:new()
	TicketGUI:getSingleton():close()
	CompanyGUI:new()
	CompanyGUI:getSingleton():close()
	FactionGUI:new()
	FactionGUI:getSingleton():close()
	MigratorPanel:new()
	MigratorPanel:getSingleton():close()
	KeyBindings:new()
	KeyBindings:getSingleton():close()
	Tour:new()

	if not localPlayer:getJob() then
		-- Change text in help menu (to the main text)
		HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
	end

	localPlayer:setPlayTime()

	setTimer(function()	NoDm:getSingleton():checkNoDm() end, 2500, 1)

	self:createBlips()
	PlantGUI.load()
	Fishing.load()
	GUIForm3D.load()
end

function Core:destructor()
	delete(Cursor)
	delete(self.m_Config)
end

function Core:getConfig()
	return self.m_Config
end

function Core:get(...)
	return self.m_Config:get(...)
end

function Core:set(...)
	return self.m_Config:set(...)
end

function Core:createBlips()
	Blip:new("Bank.png", 1660.4, -1272.8, 500)
end

function Core:throwInternalError(message)
	triggerServerEvent("Core.onClientInternalError", root, message)
end
