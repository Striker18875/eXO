-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/LocalPlayer.lua
-- *  PURPOSE:     Local player class
-- *
-- ****************************************************************************
LocalPlayer = inherit(Player)
addRemoteEvents{"retrieveInfo", "playerWasted", "playerRescueWasted", "playerCashChange", "setSupportDamage", "playerSendToHospital", "abortDeathGUI", "sendTrayNotification" }

function LocalPlayer:constructor()
	self.m_Locale = "de"
	self.m_Job = false
	self.m_Rank = 0
	self.m_LoggedIn = false
	self.m_JoinTime = getTickCount()
	self.m_AFKCheckCount = 0
	self.m_LastPositon = self:getPosition()
	self.m_AFKTimer = setTimer ( bind(self.checkAFK, self), 5000, 0)
	self.m_PlayTime = setTimer(bind(self.setPlayTime, self), 60000, 0)
	-- Since the local player exist only once, we can add the events here
	addEventHandler("retrieveInfo", root, bind(self.Event_retrieveInfo, self))
	addEventHandler("onClientPlayerWasted", root, bind(self.playerWasted, self))
	addEventHandler("playerWasted", root, bind(self.Event_playerWasted, self))
	addEventHandler("playerCashChange", self, bind(self.playCashChange, self))
	addEventHandler("setSupportDamage", self, bind( self.toggleDamage, self ))
	addEventHandler("abortDeathGUI", self, bind( self.abortDeathGUI, self ))
	addEventHandler("sendTrayNotification", self, bind( self.sendTrayNotification, self ))

	addCommandHandler("noafk", bind(self.onAFKCodeInput, self))
end

function LocalPlayer:destructor()
end

-- Short getters
function LocalPlayer:getLocale()	return self.m_Locale 	end
function LocalPlayer:getJob()		return self.m_Job 		end

-- Short setters
function LocalPlayer:setLocale(locale)	self.m_Locale = locale 	end
function LocalPlayer:setJob(job)		self.m_Job = job		end


function LocalPlayer:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), r, g, b, true)
end

function LocalPlayer:getRank()
	return self.m_Rank
end

function LocalPlayer:getPlayTime()
	return (self:getPrivateSync("LastPlayTime") and self.m_JoinTime and math.floor(self:getPrivateSync("LastPlayTime") + (getTickCount()-self.m_JoinTime)/1000/60)) or 0
end

function LocalPlayer:setPlayTime()
	setElementData(self, "playingTime", self:getPlayTime())
end

function LocalPlayer:isLoggedIn()
	return self.m_LoggedIn
end

function LocalPlayer:getPoints()
	return self:getPrivateSync("Points")
end

function LocalPlayer:getWeaponLevel()
	return self:getPrivateSync("WeaponLevel") or 0
end

function LocalPlayer:getVehicleLevel()
	return self:getPrivateSync("VehicleLevel") or 0
end

function LocalPlayer:getSkinLevel()
	return self:getPrivateSync("SkinLevel") or 0
end

function LocalPlayer:getJobLevel()
	return self:getPrivateSync("JobLevel") or 0
end

function LocalPlayer:getSessionId()
	return self:getPrivateSync("SessionID") or ""
end

function LocalPlayer:playCashChange( )
	playSound( "files/audio/cash_register.ogg" )
end

function LocalPlayer:toggleDamage( bstate )
	if bstate then
		addEventHandler( "onClientPlayerDamage", localPlayer, cancelEvent)
	else
		removeEventHandler( "onClientPlayerDamage", localPlayer, cancelEvent)
	end
end

function LocalPlayer:playerWasted( killer, weapon, bodypart)
	if source == localPlayer then
		triggerServerEvent("Event_ClientNotifyWasted", localPlayer, killer, weapon, bodypart)
	end
end

function LocalPlayer:startHalleluja()
	setCameraTarget(localPlayer)
	localPlayer:setHeadless(false)
	playSound("files/audio/Halleluja.mp3")
	local x, y, z = 2028, -1405, 110
	-- Disable damage while resurrecting
	addEventHandler("onClientPlayerDamage", root, cancelEvent)
	addEventHandler("onClientPreRender", root,
	function(deltaTime)
		z = z-0.005*deltaTime
		localPlayer:setPosition(x, y, z)
		localPlayer:setRotation(0, 0, 225)
		if z <= 18 then
			removeEventHandler("onClientPreRender", root, getThisFunction())
			removeEventHandler("onClientPlayerDamage", root, cancelEvent)
		end
	end
	)
end

function LocalPlayer:Event_playerWasted()
	local callback = function (sound)
		if isElement(sound) then
			sound:destroy()
		end

		local time = self:getPublicSync("DeathTime")-6000

		fadeCamera(false, 1)
		self.m_WastedTimer2 = setTimer( -- Todo: Remove later
			function ()
				fadeCamera(true,0.5)
				self.m_DeathGUI = DeathGUI:new(time)
				self.m_WastedTimer3 = setTimer(function()
					HUDRadar:getSingleton():show()
					HUDUI:getSingleton():show()
					showChat(true)
					-- Trigger it back to the Server (TODO: Maybe is this Event unsafe..?)
					triggerServerEvent("factionRescueWastedFinished", localPlayer)
				end, time, 1)

			end, 3000, 1
		)
	end

	-- Hide UI Elements
	HUDRadar:getSingleton():hide()
	HUDUI:getSingleton():hide()
	showChat(false)

	-- Move camera into the Sky
	setCameraInterior(0)
	local pos = self:getPosition()
	local add = 0
	local sound = Sound("files/audio/Halleluja.mp3")
	local soundStart = getTickCount()
	local soundLength = sound:getLength()
	ShortMessage:new(_"Dir konnte leider niemand mehr helfen..! Du bist Tod.\n\nBut... have a good flight into the Heaven!", (soundLength-1)*1000)
	addEventHandler("onClientPreRender", root,
		function(deltaTime)
			add = add+0.005*deltaTime
			setCameraMatrix(pos.x, pos.y, pos.z + add, pos)

			if (getTickCount()-soundStart) >= (soundLength*1000) then
				-- Play knock out effect
				self.m_FadeOutShader = FadeOutShader:new()
				self.m_WastedTimer1 = setTimer(callback, 4000, 1, sound, start)
				self.m_DeathRender = getThisFunction()
				removeEventHandler("onClientPreRender", root, getThisFunction())
			end
		end
	)
end

function LocalPlayer:abortDeathGUI()
	if self.m_FadeOutShader then delete(self.m_FadeOutShader) end
	if self.m_WastedTimer1 and isTimer(self.m_WastedTimer1) then killTimer(self.m_WastedTimer1) end
	if self.m_WastedTimer2 and isTimer(self.m_WastedTimer2) then killTimer(self.m_WastedTimer2) end
	if self.m_WastedTimer3 and isTimer(self.m_WastedTimer3) then killTimer(self.m_WastedTimer3) end
	HUDUI:getSingleton():show()
	showChat(true)
	if self.m_DeathGUI then delete(self.m_DeathGUI) end
	removeEventHandler("onClientPreRender", root, self.m_DeathRender)
end

function LocalPlayer:checkAFK()
	if not self:isLoggedIn() then return end

	if not self:getPublicSync("AFK") == true then
		local pos = self:getPosition()
		local distance = getDistanceBetweenPoints3D(pos, self.m_LastPositon) or 0
		self.m_LastPositon = pos

		if self:getInterior() == 4 and getDistanceBetweenPoints3D(pos, Vector3(449.03, -88.86, 999.55)) < 50 then
			self:toggleAFK(true, false)
			return
		end

		self.m_AFKCheckCount = self.m_AFKCheckCount + 1
		if distance > 15 then
			self.m_AFKCheckCount = 0
			triggerServerEvent("toggleAFK", localPlayer, false)
			removeEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
			return
		end
		if self.m_AFKCheckCount == 60 then
			outputChatBox ( "WARNUNG: Du wirst in einer Minute zum AFK-Cafe befördert!", 255, 0, 0 )
			self:sendTrayNotification("WARNUNG: Du wirst in einer Minute zum AFK-Cafe befördert!", "warning", true)
			self:generateAFKCode()
			return
		elseif self.m_AFKCheckCount == 72 then
			self:toggleAFK(true, true)
			return
		end

	else
		if self:getInterior() == 0 then
			self:toggleAFK(false)
		end
	end
end

function LocalPlayer:toggleAFK(state, teleport)
	if not self:isLoggedIn() then return end

	if state == true then
		self.m_AFKCode = false
		GUIForm.closeAll()
		InfoBox:new(_"Du wurdest ins AFK-Cafe teleportiert!")
		triggerServerEvent("toggleAFK", localPlayer, true, teleport)
		addEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
	else
		InfoBox:new(_("Willkommen zurück, %s!", localPlayer:getName()))
		triggerServerEvent("toggleAFK", localPlayer, false)
		removeEventHandler ( "onClientPedDamage", localPlayer, cancelEvent)
	end
end

function LocalPlayer:generateAFKCode()
	local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4","5","6","7","8","9"}
	local code = {}
	for z = 1,4 do
		a = math.random(1,#char)
		x = string.lower(char[a])
		table.insert(code, x)
	end
	local fcode = table.concat(code)
	self.m_AFKCode = fcode
	outputChatBox("Um nicht ins AFK-Cafe zu kommen, gib folgenden Befehl ein: /noafk "..fcode,255,0,0)
end

function LocalPlayer:onAFKCodeInput(cmd, code)
	if self.m_AFKCode then
		if self.m_AFKCode == code then
			outputChatBox("Vorgang abgebrochen.", 255, 0, 0)
			self.m_AFKCheckCount = 0
			self.m_AFKCode = false
		else
			ErrorBox:new(_"Der eingegeben Code ist falsch!")
		end
	else
		ErrorBox:new(_"Der Code ist nicht mehr gültig!")
	end
end

-- Events
function LocalPlayer:Event_retrieveInfo(info)
	self.m_Rank = info.Rank
	self.m_LoggedIn = true
end

function LocalPlayer:sendTrayNotification(text, icon, sound)
	createTrayNotification("eXo-RL: "..text, icon, sound)
end
