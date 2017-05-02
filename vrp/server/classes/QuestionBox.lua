-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Provider.lua
-- *  PURPOSE:     Custom resource files provider class
-- *
-- ****************************************************************************
QuestionBox = inherit(Object)
QuestionBox.Map = {}
QuestionBox.Count = 0

function QuestionBox.initalize()
	addRemoteEvents{"questionBoxAccept", "questionBoxDiscard"}
	addEventHandler("questionBoxAccept", root, QuestionBox.Accept)
	addEventHandler("questionBoxDiscard", root, QuestionBox.Discard)
	outputChatBox("initalize")
end

function QuestionBox:constructor(player, target, msg, yesEvent, noEvent, ...)
	local additionalParameters = {...}
	local id = QuestionBox.Count+1
	QuestionBox.Map[id] = {
		["player"] = player,
		["target"] = target,
		["yesEvent"] = yesEvent,
		["noEvent"] = noEvent,
		["additionalParameters"] = additionalParameters,
		["object"] = self
	}

	target:triggerEvent("questionBox", id, msg)
end

function QuestionBox.Accept(id)
outputChatBox("yesTry")
	if QuestionBox.Map[id]["target"] == client and QuestionBox.Map[id]["yesEvent"] then
		triggerEvent(QuestionBox.Map[id]["yesEvent"], client, unpack(QuestionBox.Map[id]["additionalParameters"]))
		delete(QuestionBox.Map[id]["object"])
		outputChatBox("yes")

	end
end

function QuestionBox.Discard(id)
	outputChatBox("noTry")

	if QuestionBox.Map[id]["target"] == client and QuestionBox.Map[id]["noEvent"] then
		triggerEvent(QuestionBox.Map[id]["noEvent"], client, unpack(QuestionBox.Map[id]["additionalParameters"]))
		delete(QuestionBox.Map[id]["object"])
				outputChatBox("no")

	end
end


