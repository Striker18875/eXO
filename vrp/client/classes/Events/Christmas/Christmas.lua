Christmas = inherit(Singleton)

function Christmas:constructor()
	SHADERS["Schnee"] = {["event"] = "switchSnow", ["enabled"] = true}
	self.m_QuestManager = QuestManager:new()

	-- Quest Ped
	local ped = Ped.create(68, Vector3(1468.66, -1706.78, 14.05), 270)
	ped:setData("NPC:Immortal", true)
	ped:setFrozen(true)
	ped.SpeakBubble = SpeakBubble3D:new(ped, "Weihnachten", "Quest")
	ped.SpeakBubble:setBorderColor(Color.Orange)
	ped.SpeakBubble:setTextColor(Color.Orange)
	setElementData(ped, "clickable", true)

	ped:setData("onClickEvent",
		function()
			triggerServerEvent("questOnPedClick", localPlayer)
		end
	)

	QuestPackageFind.togglePackages(false)
end
