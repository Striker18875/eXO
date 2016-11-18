DrivingSchool = inherit(Company)
DrivingSchool.LicenseCosts = {["car"] = 1500, ["bike"] = 750, ["truck"] = 4000, ["heli"] = 15000, ["plane"] = 20000 }
DrivingSchool.TypeNames = {["car"] = "Autoführerschein", ["bike"] = "Motorradschein", ["truck"] = "LKW-Schein", ["heli"] = "Helikopterschein", ["plane"] = "Flugschein" }

function DrivingSchool:constructor()
    self:createDrivingSchoolMarker(Vector3(1362.04, -1663.74, 13.57))
	self:createSchoolPed(Vector3( -2035.32, -117.65, 1035.17))

    self.m_CurrentLessions = {}

    InteriorEnterExit:new(Vector3(1364.9, -1668.93, 13.56), Vector3(-2027.02, -105.10, 1035.17), 90, 90, 3, 0, false)

    VehicleBarrier:new(Vector3(1413.59, -1653.09, 13.30), Vector3(0, 90, 88)).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(1345.19, -1722.80, 13.39), Vector3(0, 90, 0)).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(1354.80, -1591.00, 13.39), Vector3(0, 90, 161), 0).onBarrierHit = bind(self.onBarrierHit, self)

    self.m_OnQuit = bind(self.Event_onQuit,self)

    local safe = createObject(2332, -2032.70, -113.70, 1036.20)
    safe:setInterior(3)
	self:setSafe(safe)

    addRemoteEvents{"drivingSchoolMenu", "drivingSchoolstartLessionQuestion", "drivingSchoolDiscardLession", "drivingSchoolStartLession", "drivingSchoolEndLession", "drivingSchoolReceiveTurnCommand","drivingSchoolPassTheory", "drivingSchoolStartTheory"}
    addEventHandler("drivingSchoolMenu", root, bind(self.Event_drivingSchoolMenu, self))
    addEventHandler("drivingSchoolDiscardLession", root, bind(self.Event_discardLession, self))
    addEventHandler("drivingSchoolstartLessionQuestion", root, bind(self.Event_startLessionQuestion, self))
    addEventHandler("drivingSchoolStartLession", root, bind(self.Event_startLession, self))
    addEventHandler("drivingSchoolEndLession", root, bind(self.Event_endLession, self))
    addEventHandler("drivingSchoolReceiveTurnCommand", root, bind(self.Event_receiveTurnCommand, self))
	addEventHandler("drivingSchoolPassTheory", root, bind(self.Event_passTheory, self))
    addEventHandler("drivingSchoolStartTheory", root, bind(self.Event_startTheory, self))

end

function DrivingSchool:destructor()
end

function DrivingSchool:onVehicleSpawn(veh)
    -- Adjust Color and Owner Text
    veh:setData("OwnerName", self:getName(), true)
    veh:setColor(255, 255, 255)

    -- Adjust variant
    if veh:getModel() == 521 then
        veh:setVariant(4, 4)
    end
end

function DrivingSchool:onVehiceEnter(player)
    if player:getCompany() ~= self or not player:getPublicSync("inDrivingLession") == true then
        player:sendError(_("Du darfst dieses Fahrzeug nicht fahren!", player))
        return false
    end
    return true
end

function DrivingSchool:onBarrierHit(player)
    if player:getCompany() ~= self then
        return false
    end
    return true
end

function DrivingSchool:createDrivingSchoolMarker(pos)
    self.m_DrivingSchoolPickup = createPickup(pos, 3, 1239)
    addEventHandler("onPickupHit", self.m_DrivingSchoolPickup,
        function(hitElement)
            if getElementType(hitElement) == "player" then
                hitElement:triggerEvent("showDrivingSchoolMenu",#self:getOnlinePlayers())
            end
            cancelEvent()
        end
    )
end

function DrivingSchool:createSchoolPed( pos )
	self.m_DrivingSchoolPed = createPed(295, pos,-90 )
    self.m_DrivingSchoolPed:setData("clickable", true, true)
	setElementInterior(self.m_DrivingSchoolPed, 3, pos)
    addEventHandler("onElementClicked", self.m_DrivingSchoolPed,
        function(button ,state ,player )
			if button == "left" and state == "up" then
				if source == self.m_DrivingSchoolPed then
					if not player.m_HasTheory then
                        if not player.isInTheory then
                            player:triggerEvent("questionBox", _("Möchtest du die Theorie-Prüfung starten? Kosten: 300$", player), "drivingSchoolStartTheory")
                        end
                    else
                        player:sendInfo("Du hast bereits die Theorieprüfung bestanden!")
					end
				end
			end
        end
    )
end

function DrivingSchool:Event_startTheory()
    if client:getMoney() >= 300 then
        client:triggerEvent("showDrivingSchoolTest")
        client:takeMoney(300, "Fahrschule")
        client.isInTheory = true
    else
        client:sendError(_("Du hast nicht genug Geld ( Kosten: 300)!", client))
    end
end

function DrivingSchool:Event_drivingSchoolMenu(func)
    if func == "callInstructor" then
        client:sendInfo(_("Alle Fahrlehrer werden gerufen!",client))
        self:sendMessage(_("Der Spieler %s sucht einen Fahrlehrer! Bitte melden!",client, client.name), 255, 125, 0)
    elseif func == "showInstructor" then
        outputChatBox(_("Folgende Fahrlehrer sind online:",client), client, 255, 255, 255)
        for k, player in pairs(self:getOnlinePlayers()) do
            outputChatBox(("%s %s"):format(player.name, player:getPublicSync("Company:Duty") and _("%s(Im Dienst)", client, "#357c01") or _("%s(Nicht im Dienst)", client, "#870000")), client, 255, 125, 0, true)
        end
    end
end

function DrivingSchool:checkPlayerLicense(player, type)
    if type == "car" then
        return player.m_HasDrivingLicense
    elseif type == "bike" then
        return player.m_HasBikeLicense
    elseif type == "truck" then
        return player.m_HasTruckLicense
    elseif type == "heli" then
        return player.m_HasPilotsLicense
    elseif type == "plane" then
        return player.m_HasPilotsLicense
    end
end

function DrivingSchool:setPlayerLicense(player, type, bool)
    if type == "car" then
        player.m_HasDrivingLicense = bool
    elseif type == "bike" then
        player.m_HasBikeLicense = bool
    elseif type == "truck" then
        player.m_HasTruckLicense = bool
    elseif type == "heli" then
        player.m_HasPilotsLicense = bool
    elseif type == "plane" then
        player.m_HasPilotsLicense = bool
    end
end

function DrivingSchool:Event_startLessionQuestion(target, type)
    local costs = DrivingSchool.LicenseCosts[type]
    if costs and target then
        if self:checkPlayerLicense(target, type) == false then
			if target.m_HasTheory then
				if target:getMoney() >= costs then
					if not target:getPublicSync("inDrivingLession") == true then
						if not self.m_CurrentLessions[client] then
							target:triggerEvent("questionBox", _("Der Fahrlehrer %s möchte mit dir die %s Prüfung starten!\nDiese kostet %d$! Möchtest du die Prüfung starten?", target, client.name, DrivingSchool.TypeNames[type], DrivingSchool.LicenseCosts[type]), "drivingSchoolStartLession", "drivingSchoolDiscardLession", client, target, type)
						else
							client:sendError(_("Du bist bereits in einer Fahrprüfung!", client))
						end
					else
						client:sendError(_("Der Spieler %s ist bereits in einer Prüfung!", client, target.name))
					end
				else
					client:sendError(_("Der Spieler %s hat nicht genug Geld dabei! (%d$)", client, target.name, costs))
				end
			else
                client:sendError(_("Der Spieler %s muss erst die theoretische Fahrprüfung bestehen!", client, target.name))
			end
		else
			client:sendError(_("Der Spieler %s hat den %s bereits!", client, target.name, DrivingSchool.TypeNames[type]))
		end
    else
        client:sendError(_("Interner Fehler: Argumente falsch @DrivingSchool:Event_startLessionQuestion!", client))
    end
end

function DrivingSchool:Event_discardLession(instructor, target, type)
    instructor:sendError(_("Der Spieler %s hat die %s Prüfung abgelehnt!", instructor, target.name, DrivingSchool.TypeNames[type]))
    target:sendError(_("Du hast die %s Prüfung mit %s abgelehnt!", target, DrivingSchool.TypeNames[type], instructor.name))
end

function DrivingSchool:Event_startLession(instructor, target, type)
    local costs = DrivingSchool.LicenseCosts[type]
    if costs and target then
        if self:checkPlayerLicense(target, type) == false then
            if target:getMoney() >= costs then
                if not target:getPublicSync("inDrivingLession") == true then
                    if not self.m_CurrentLessions[instructor] then
                        self.m_CurrentLessions[instructor] = {
                            ["target"] = target, ["type"] = type, ["instructor"] = instructor
                        }
                        target:takeMoney(costs, "Fahrschule")
                        self:giveMoney(math.floor(costs/5))
                        target:setPublicSync("inDrivingLession",true)
                        instructor:sendInfo(_("Du hast die %s Prüfung mit %s gestartet!", instructor, DrivingSchool.TypeNames[type], target.name))
                        target:sendInfo(_("Fahrlehrer %s hat die %s Prüfung mit dir gestartet, Folge seinen Anweisungen!", target, instructor.name, DrivingSchool.TypeNames[type]))
                        target:triggerEvent("showDrivingSchoolStudentGUI", DrivingSchool.TypeNames[type])
                        instructor:triggerEvent("showDrivingSchoolInstructorGUI", DrivingSchool.TypeNames[type], target)
                        addEventHandler("onPlayerQuit", instructor, self.m_OnQuit)
                        addEventHandler("onPlayerQuit", target, self.m_OnQuit)
                    else
                        instructor:sendError(_("Du bist bereits in einer Fahrprüfung!", instructor))
                    end
                else
                    instructor:sendError(_("Der Spieler %s ist bereits in einer Prüfung!", instructor, target.name))
                    target:sendError(_("Du bist bereits in einer Prüfung!", target))
                end
            else
                instructor:sendError(_("Der Spieler %s hat nicht genug Geld dabei! (%d$)", instructor, target.name, costs))
                target:sendError(_("Du hast nicht genug Geld dabei! (%d$)", target, costs))
            end
        else
            instructor:sendError(_("Der Spieler %s hat den %s bereits!", instructor, target.name, DrivingSchool.TypeNames[type]))
            target:sendError(_("Du hast den %s bereits!", target, DrivingSchool.TypeNames[type]))
        end
    else
        instructor:sendError(_("Interner Fehler: Argumente falsch @DrivingSchool:Event_startLession!", instructor))
    end
end

function DrivingSchool:getLessionFromStudent(player)
    for index, key in pairs(self.m_CurrentLessions) do
        if key["target"] == player then return key end
    end
    return false
end

function DrivingSchool:Event_onQuit()
    if self.m_CurrentLessions[source]["type"] then
        self:Event_endLession(self.m_CurrentLessions[source]["target"], false, source)
        lession["target"]:sendError(_("Der Fahrlehrer %s ist offline gegangen!",lession["target"], source.name))
    elseif self:getLessionFromStudent(source) then
        local lession = self:getLessionFromStudent(source)
        self:Event_endLession(source, false, lession["instructor"])
        lession["instructor"]:sendError(_("Der Fahrschüler %s ist offline gegangen!",lession["instructor"], source.name))
    else
    end
end

function DrivingSchool:Event_endLession(target, success, clientServer)
    if not client and clientServer then client = clientServer end
    local type = self.m_CurrentLessions[client]["type"]
    if success == true then
        self:setPlayerLicense(target, type, true)
        target:sendInfo(_("Du hast die %s Prüfung erfolgreich bestanden und den Schein erhalten!",target, DrivingSchool.TypeNames[type]))
        client:sendInfo(_("Du hast die %s Prüfung mit %s erfolgreich beendet!",client, DrivingSchool.TypeNames[type], target.name))
    else
        target:sendError(_("Du hast die %s Prüfung nicht geschaft! Viel Glück beim nächsten Mal!",target, DrivingSchool.TypeNames[type]))
        client:sendInfo(_("Du hast die %s Prüfung mit %s abgebrochen!",client, DrivingSchool.TypeNames[type], target.name))
    end

    target:triggerEvent("hideDrivingSchoolStudentGUI")
    client:triggerEvent("hideDrivingSchoolInstructorGUI")
    removeEventHandler("onPlayerQuit", client, self.m_OnQuit)
    removeEventHandler("onPlayerQuit", target, self.m_OnQuit)
    target:setPublicSync("inDrivingLession",false)
    self.m_CurrentLessions[client] = nil
end

function DrivingSchool:Event_receiveTurnCommand(turnCommand)
    local target = self.m_CurrentLessions[client]["target"]
    if target then
        target:triggerEvent("drivingSchoolChangeDirection", turnCommand)
    end
end

function DrivingSchool:Event_passTheory(pass)
    client.isInTheory = false
    if pass == true then
        client.m_HasTheory = true
        client:sendInfo(_("Gehe nun zur praktischen Prüfung!", client))
    else
        client:sendInfo(_("Du hast abgebrochen oder nicht bestanden! Versuche die Prüfung erneut!", client))
    end
end
