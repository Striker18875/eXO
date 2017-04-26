-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Faction.lua
-- *  PURPOSE:     Faction Client
-- *
-- ****************************************************************************
local w,h = guiGetScreenSize()
FactionManager = inherit(Singleton)
FactionManager.Map = {}

function FactionManager:constructor()
	triggerServerEvent("getFactions", localPlayer)

	self.m_NeedHelpBlip = {}

	addRemoteEvents{"loadClientFaction", "stateFactionNeedHelp","stateFactionShowRob", "factionStateStartCuff","stateFactionOfferTicket"; "updateCuffImage","playerSelfArrest", "factionEvilStartRaid","SpeedCam:showSpeeder"}
	addEventHandler("loadClientFaction", root, bind(self.loadFaction, self))
	addEventHandler("factionStateStartCuff", root, bind(self.stateFactionStartCuff, self))
	addEventHandler("factionEvilStartRaid", root, bind(self.factionEvilStartRaid, self))
	addEventHandler("stateFactionNeedHelp", root, bind(self.stateFactionNeedHelp, self))
	addEventHandler("stateFactionShowRob", root, bind(self.stateFactionShowRob, self))
	addEventHandler("stateFactionOfferTicket", root, bind(self.stateFactionOfferTicket, self))
	addEventHandler("updateCuffImage", root, bind(self.Event_onPlayerCuff, self))
	addEventHandler("playerSelfArrest", localPlayer, bind(self.Event_selfArrestMarker, self))
	addEventHandler("SpeedCam:showSpeeder", localPlayer, bind(self.Event_OnSpeederCatch,self))
	
	self.m_DrawSpeed = bind(self.OnRenderSpeed, self)
	self.m_DrawCuffFunc = bind(self.drawCuff, self)
end

function FactionManager:loadFaction(Id, name, name_short, rankNames, factionType, color)
	FactionManager.Map[Id] = Faction:new(Id, name, name_short, rankNames, factionType, color)
end

function FactionManager:stateFactionStartCuff( target )
	if target then
		local timer = localPlayer.stateCuffTimer
		if timer then
			if isTimer(timer) then
				killTimer(timer)
			end
		end
		localPlayer.m_CuffTarget = target
		localPlayer.stateCuffTimer = setTimer( self.endStateFactionCuff, 10000, 1)
	end
end


function FactionManager:factionEvilStartRaid(target)
	if target then
		local timer = localPlayer.evilRaidTimer
		if timer then
			if isTimer(timer) then
				killTimer(timer)
			end
		end
		localPlayer.m_evilRaidTarget = target
		localPlayer.evilRaidTimer = setTimer(self.endEvilFactionRaid, 15000, 1)
	end
end

function FactionManager:endEvilFactionRaid()
	if localPlayer.m_evilRaidTarget then
		if getDistanceBetweenPoints3D( localPlayer.m_evilRaidTarget:getPosition(), localPlayer:getPosition()) <= 5 then
			triggerServerEvent("factionEvilSuccessRaid", localPlayer,localPlayer.m_evilRaidTarget)
		else
			triggerServerEvent("factionEvilFailedRaid", localPlayer,localPlayer.m_evilRaidTarget)
		end
	end
end

function FactionManager:Event_onPlayerCuff( bool )
	removeEventHandler("onClientRender",root, self.m_DrawCuffFunc)
	if bool then
		addEventHandler("onClientRender",root, self.m_DrawCuffFunc)
	end
end

function FactionManager:drawCuff()
	dxDrawImage(w*0.88, h - w*0.1, w*0.08,w*0.0436,"files/images/Other/cuff.png")
end

function FactionManager:Event_selfArrestMarker( client )
	if not localPlayer.m_selfArrest then
		localPlayer.m_selfArrest = true
		QuestionBox:new(
			_"Möchtest du dich mit Kaution stellen?",
			function ()
				triggerServerEvent("playerSelfArrestConfirm", root )
				localPlayer.m_selfArrest = false
			end,
			function ()
				localPlayer.m_selfArrest = false
			end)
	end
end

function FactionManager:Event_OnSpeederCatch( speed, vehicle)
	removeEventHandler("onClientRender", root, self.m_DrawSpeed)
	local now = getTickCount()
	self.m_SpeedCamSpeed = speed
	self.m_SpeedCamVehicle = vehicle
	self.m_DrawStart = now + 2000
	self.m_RemoveDraw = self.m_DrawStart + 5000
	self.m_bLineChecked = false
	self.m_PlaySoundOnce = false
	addEventHandler("onClientRender", root, self.m_DrawSpeed)
end

function FactionManager:OnRenderSpeed()
	local now = getTickCount()
	if now <= self.m_RemoveDraw then
		if now >= self.m_DrawStart then
			if self.m_SpeedCamSpeed and self.m_SpeedCamVehicle then 
				if self.m_bLineChecked == self.m_SpeedCamVehicle then
					local speed = math.floor(self.m_SpeedCamSpeed)
					local plate = getVehicleName(self.m_SpeedCamVehicle)
					local text = "Radar: "..speed.." KM/H".." bei "..plate.." !"
					dxDrawText(text,0,1, w, h*0.8+1, tocolor(0,0,0,255),2,"default-bold","center","bottom")
					dxDrawText(text,1,1, w+1, h*0.8+1, tocolor(0,0,0,255),2,"default-bold","center","bottom")
					dxDrawText(text,0,0, w, h*0.8, tocolor(0,150,0,255),2,"default-bold","center","bottom")
					local speeder = getVehicleOccupant(self.m_SpeedCamVehicle)
					if speeder then
						local px,py,pz = getPedBonePosition(speeder,8)
						local dx,dy = getScreenFromWorldPosition(px,py,pz)
						if dx and dy then
							dxDrawText(speed.." KM/H", dx,dy+1,dx,dy+1,tocolor(0,0,0,255),1,"default-bold")
							dxDrawText(speed.." KM/H", dx,dy,dx,dy,tocolor(230,0,0,255),1,"default-bold")
						end
					end
					if not self.m_PlaySoundOnce then
						playSoundFrontEnd(5)
						self.m_PlaySoundOnce = true
					end
				else 
					local localVeh = getPedOccupiedVehicle(localPlayer)
					if localVeh then
						local speeder = getVehicleOccupant(self.m_SpeedCamVehicle)
						if speeder then
							local x,y,z = getElementPosition(localVeh)
							local px,py,pz = getPedBonePosition(speeder,8)
							local bLineCheck = isLineOfSightClear (x, y, z, px, py, pz, true, false, false, true)
							if bLineCheck then
								self.m_bLineChecked = self.m_SpeedCamVehicle
								self.m_RemoveDraw = self.m_DrawStart + 10000	
							end
						end
					end
				end
			end
		else 
			if self.m_SpeedCamSpeed and self.m_SpeedCamVehicle then 
				local localVeh = getPedOccupiedVehicle(localPlayer)
				if localVeh then
					local speeder = getVehicleOccupant(self.m_SpeedCamVehicle)
					if speeder then
						local x,y,z = getElementPosition(localVeh)
						local px,py,pz = getPedBonePosition(speeder,8)
						local bLineCheck = isLineOfSightClear (x, y, z, px, py, pz, true, false, false, true)
						if bLineCheck then
							self.m_bLineChecked = self.m_SpeedCamVehicle
							self.m_RemoveDraw = self.m_DrawStart + 10000	
							if not self.m_PlaySoundSnap then
								playSound("files/audio/speedcam.ogg")
								self.m_PlaySoundSnap = true
							end
						end
					end
				end
			end
		end
	else 
		removeEventHandler("onClientRender", root, self.m_DrawSpeed)
	end
end

function FactionManager:stateFactionOfferTicket( cop )
	ShortMessage:new(_(cop:getName().." bietet dir ein Ticket für den Erlass eines Wanteds für $2000 an. Klicke hier um es anzunehmen!"), "Wanted-Ticket", Color.DarkLightBlue, 15000)
	.m_Callback = function (this)	triggerServerEvent("factionStateAcceptTicket", localPlayer, cop); delete(this)	end

end

function FactionManager:endStateFactionCuff( )
	if localPlayer.m_CuffTarget then
		if getDistanceBetweenPoints3D( localPlayer.m_CuffTarget:getPosition(), localPlayer:getPosition()) <= 5 then
			triggerServerEvent("stateFactionSuccessCuff", localPlayer,localPlayer.m_CuffTarget)
		end
	end
end

function FactionManager:stateFactionNeedHelp(player)
	if self.m_NeedHelpBlip[player] then delete(self.m_NeedHelpBlip[player]) end
	if not localPlayer:getPublicSync("Faction:Duty") then return end
	local pos = player:getPosition()
	self.m_NeedHelpBlip[player] = Blip:new("NeedHelp.png", pos.x, pos.y, 9999)
	self.m_NeedHelpBlip[player]:attachTo(player)
	self.m_NeedHelpBlip[player]:setStreamDistance(2000)

	setTimer(function(player)
		if self.m_NeedHelpBlip[player] then delete(self.m_NeedHelpBlip[player]) end
	end, 20000, 1, player)
end

function FactionManager:stateFactionShowRob(pickup)
	if self.m_NeedHelpBlip[pickup] then delete(self.m_NeedHelpBlip[pickup]) end
	if not localPlayer:getPublicSync("Faction:Duty") then return end
	local pos = pickup:getPosition()
	self.m_NeedHelpBlip[pickup] = Blip:new("NeedHelp.png", pos.x, pos.y, 9999)
	self.m_NeedHelpBlip[pickup]:attachTo(pickup)
	self.m_NeedHelpBlip[pickup]:setStreamDistance(2000)

	setTimer(function(pickup)
		if self.m_NeedHelpBlip[pickup] then delete(self.m_NeedHelpBlip[pickup]) end
	end, 270000, 1, pickup)
end

function FactionManager:getFromId(id)
	return FactionManager.Map[id]
end

function FactionManager:getFactionNames()
	local table = {}
	for id, faction in pairs(FactionManager.Map) do
		table[id] = faction:getShortName()
	end
	return table
end

Faction = inherit(Object)

function Faction:constructor(Id, name, name_short, rankNames, factionType, color)
	self.m_Id = Id
	self.m_Name = name
	self.m_NameShort = name_short
	self.m_RankNames = rankNames
	self.m_Type = factionType
	self.m_Color = color
end

function Faction:getId()
	return self.m_Id
end

function Faction:isStateFaction()
	return self.m_Type == "State"
end

function Faction:isEvilFaction()
	return self.m_Type == "Evil"
end

function Faction:isRescueFaction()
	return self.m_Type == "Rescue"
end

function Faction:getName()
	return self.m_Name
end

function Faction:getShortName()
	return self.m_NameShort
end

function Faction:getColor()
	return self.m_Color
end
