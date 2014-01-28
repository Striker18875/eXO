Core = inherit(Object)

function Core:constructor()
	-- Small hack to get the global core immediately
	core = self
	
	-- Instantiate the localPlayer instance right now
	enew(localPlayer, LocalPlayer)
	
	if DEBUG then
		Debugging:new()
	end
	
	self.m_Config = ConfigXML:new("config.xml")
	Version:new()
	TranslationManager:new()
	JobManager:new()
	MTAFixes:new()
	ClickHandler:new()
	RadioGUI:new()
	KarmaBar:new()
	CustomModelManager:new()
	
	-- HUD
	--HUDRadar:new()
	HUDSpeedo:new()
	
	-- Phone
	Phone:new()
	Phone:getSingleton():close()
	bindKey("k", "down",
		function()
			Phone:getSingleton():setVisible(not Phone:getSingleton():isVisible())
		end
	)
	
	PolicePanel:getSingleton():close()
	bindKey("f2", "down",
		function()
			PolicePanel:getSingleton():setVisible(not PolicePanel:getSingleton():isVisible())
		end
	)
	
	SelfGUI:new()
	SelfGUI:getSingleton():close()
	
	-- Vehicle shops
	VehicleShop.createShops()
end

function Core:destructor()

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
