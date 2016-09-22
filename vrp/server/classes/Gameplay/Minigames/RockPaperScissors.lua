-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/RockPaperScissors.lua
-- *  PURPOSE:     RockPaperScissors Game - Server
-- *
-- ****************************************************************************
RockPaperScissors = inherit(Object)
RockPaperScissors.Map = {}

RockPaperScissors.WinTable = {
	["Rock"] = {["Scissors"] = 1, ["Paper"] = 0},
	["Scissors"] = {["Paper"] = 1, ["Rock"] = 0},
	["Paper"] = {["Rock"] = 1, ["Scissors"] = 0},
}
addRemoteEvents{"rockPaperScissorsQuestion", "rockPaperScissorsStart", "rockPaperScissorsDecline", "rockPaperScissorsStart", "rockPaperScissorsSelect"}

function RockPaperScissors:constructor(player1, player2)
	self.m_Players = {[player1] = "none", [player2] = "none"}
	RockPaperScissors.Map[player1] = self
	RockPaperScissors.Map[player2] = self
	self:startRound()
end

function RockPaperScissors:startRound()
	for player, selection in pairs(self.m_Players) do
		player:triggerEvent("rockPaperScissorsSelection")
	end
end

function RockPaperScissors:setSelection(player, selection)
	self.m_Players[player] = selection
	self:checkReady(player)
end

function RockPaperScissors:checkReady(player)
	local count = 0
	for playerItem, selection in pairs(self.m_Players) do
		if selection ~= "none" then
			count = count + 1
		end
	end
	if count == 2 then
		self:checkResult()
	else
		player:sendInfo(_("Bitte warte einen kurzen Moment bis der Gegner seine Auswahl getroffen hat!", player))
	end
end

function RockPaperScissors:checkResult()
	local result = {}
	local resultPlayer = {}
	for playerItem, selection in pairs(self.m_Players) do
		result[#result+1] = selection
		resultPlayer[#resultPlayer+1] = playerItem
	end
	if result[1] == result[2] then
		self:showResult()
		return
	end

	if RockPaperScissors.WinTable[result[1]][result[2]] == 1 then
		self:showResult(resultPlayer[1])
	else
		self:showResult(resultPlayer[2])
	end
end

function RockPaperScissors:showResult(winner)
	for playerItem, selection in pairs(self.m_Players) do
		if winner then
			if winner == playerItem then
				playerItem:triggerEvent("rockPaperScissorsShowResult", "win", self.m_Players)
				setTimer(function()
					playerItem:giveAchievement(51)
				end, 9000, 1)
			else
				playerItem:triggerEvent("rockPaperScissorsShowResult", "loose", self.m_Players)
				setTimer(function()
					playerItem:giveAchievement(52)
				end, 9000, 1)
			end
		else
			playerItem:triggerEvent("rockPaperScissorsShowResult", "draw", self.m_Players)
			setTimer(function()
				playerItem:giveAchievement(53)
			end, 9000, 1)
		end
	end
end

addEventHandler("rockPaperScissorsQuestion", root, function(target)
	target:sendShortMessage(_("Der Spieler %s möchte mit dir spielen. Klicke hier um anzunehmen!", target, client.name), _("Schere Stein Papier", target), {50, 200, 255}, 10000, "rockPaperScissorsStart", "rockPaperScissorsDecline", client)
end)

addEventHandler("rockPaperScissorsStart", root, function(target)
	RockPaperScissors:new(client, target)
end)

addEventHandler("rockPaperScissorsDecline", root, function(target)
	client:sendError(_("Der Spieler %s hat das Schere Stein Papier abgelehnt oder nicht geantwortet!", client, target.name))
end)

addEventHandler("rockPaperScissorsSelect", root, function(selection)
	RockPaperScissors.Map[client]:setSelection(client, selection)
end)
