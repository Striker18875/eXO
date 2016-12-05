-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/KeyBindManager.lua
-- *  PURPOSE:     KeyBindings Mangager class
-- *
-- ****************************************************************************
KeyBinds = inherit(Singleton)

function KeyBinds:constructor()
	self.m_TogglePhone = bind(self.togglePhone, self)
	self.m_HelpMenu = bind(self.helpMenu, self)
	self.m_AnimationMenu = bind(self.animationMenu, self)
	self.m_PolicePanel = bind(self.policePanel, self)
	self.m_SelfMenu = bind(self.selfMenu, self)
	self.m_ScoreboardTrigger = bind(self.scoreboardGUI, self)
	self.m_CustomMap = bind(self.customMap, self)
	self.m_Inventory = bind(self.inventory, self)

	self.m_Keys = {
	  ["KeyTogglePhone"]         = {["defaultKey"] = "u", ["name"] = "Handy", ["func"] = self.m_TogglePhone};
	  ["KeyTogglePolicePanel"]   = {["defaultKey"] = "F4", ["name"] = "Polizei Computer", ["func"] = self.m_PolicePanel};
	  ["KeyToggleSelfGUI"]       = {["defaultKey"] = "F2", ["name"] = "Self-Menü", ["func"] = self.m_SelfMenu};
	  ["KeyToggleHelpGUI"]       = {["defaultKey"] = "F1", ["name"] = "Hilfe-Menü", ["func"] = self.m_HelpMenu};
	  ["KeyToggleAnimationMenu"] = {["defaultKey"] = "F3", ["name"] = "Animations-Menü", ["func"] = self.m_AnimationMenu};
	  ["KeyToggleScoreboard"]    = {["defaultKey"] = "TAB", ["name"] = "Spielerliste", ["func"] = self.m_ScoreboardTrigger, ["trigger"] = "both"};
	  ["KeyToggleCustomMap"]     = {["defaultKey"] = "F11", ["name"] = "Karte", ["func"] = self.m_CustomMap};
	  ["KeyToggleInventory"]     = {["defaultKey"] = "i", ["name"] = "Inventar", ["func"] = self.m_Inventory};
	  ["KeyToggleCursor"]        = {["defaultKey"] = "b", ["name"] = "Cursor", ["load"] = function () Cursor:loadBind() end, ["unload"] = function () Cursor:unloadBind() end};

	  --Disabled cause of MTA Bug #9178
	--  ["KeyChatFaction"]         = {["defaultKey"] = "1", ["name"] = "Chat: Fraktion", ["func"] = "chatbox", ["extra"] = "Fraktion"};
	--  ["KeyChatCompany"]         = {["defaultKey"] = "2", ["name"] = "Chat: Unternehmen", ["func"] = "chatbox", ["extra"] = "Unternehmen"};
	--  ["KeyChatGroup"]           = {["defaultKey"] = "3", ["name"] = "Chat: Firma/Gang", ["func"] = "chatbox", ["extra"] = "Firma/Gang"};
	}
	self:unloadBinds()
	self:loadBinds()
end

function KeyBinds:loadBinds()
	--outputChatBox("-------------", 0,255,0)
	for index, key in pairs(self.m_Keys) do
		--if key["func"] == "chatbox" then
			--local trigger = key["trigger"] or "down"
			--local keyName = core:get("KeyBindings", index, key["defaultKey"])
			--outputChatBox("Bind: Key: "..keyName.." Trigger: "..trigger.." Func: "..tostring(key["func"].." Extra: "..key["extra"]))
		--end
		if not key["load"] then
			bindKey(core:get("KeyBindings", index, key["defaultKey"]), key["trigger"] or "down", key["func"], key["extra"])
		else
			key["load"]()
		end
	end
	--outputChatBox("-------------", 0,255,0)

end

function KeyBinds:unloadBinds()
	--outputChatBox("-------------", 255,0,0)
	for index, key in pairs(self.m_Keys) do
		--if key["func"] == "chatbox" then
		--	local trigger = key["trigger"] or "down"
		--	local keyName = core:get("KeyBindings", index, key["defaultKey"])
		--	outputChatBox("Unbind: Key: "..keyName.." Trigger: "..trigger.." Func: "..tostring(key["func"].." Extra: "..key["extra"]))
		--end
		if not key["unload"] then
			unbindKey(core:get("KeyBindings", index, key["defaultKey"]), key["trigger"] or "down", key["func"])
		else
			key["unload"]()
		end
	end
--	outputChatBox("-------------", 255,0,0)
end

function KeyBinds:changeKey(keyName, newKey)
	self:unloadBinds()
	core:set("KeyBindings", keyName, newKey)
	self:loadBinds()
end

function KeyBinds:getBindsList()
	return self.m_Keys
end

function KeyBinds:inventory()
	Inventory:getSingleton():toggle()
end

function KeyBinds:togglePhone()
	Phone:getSingleton():toggle()
end

function KeyBinds:customMap()
	CustomF11Map:getSingleton():toggle()
end

function KeyBinds:selfMenu()
	if SelfGUI:getSingleton():isVisible() then
		SelfGUI:getSingleton():close()
	elseif CompanyGUI:getSingleton():isVisible() then
		CompanyGUI:getSingleton():close()
	elseif FactionGUI:getSingleton():isVisible() then
		FactionGUI:getSingleton():close()
	elseif GroupGUI:getSingleton():isVisible() then
		GroupGUI:getSingleton():close()
	elseif TicketGUI:getSingleton():isVisible() then
		TicketGUI:getSingleton():close()
	elseif AdminGUI:getSingleton():isVisible() then
		AdminGUI:getSingleton():close()
	elseif MigratorPanel:getSingleton():isVisible() then
		MigratorPanel:getSingleton():close()
	elseif KeyBindings:getSingleton():isVisible() then
		KeyBindings:getSingleton():close()
	else
		SelfGUI:getSingleton():open()
	end
end

function KeyBinds:animationMenu()
	if not localPlayer:isInVehicle() then
		if not AnimationGUI:isInstantiated() then
			AnimationGUI:new()
		else
			delete(AnimationGUI:getSingleton())
		end
	end
end

function KeyBinds:policePanel()
	if not PolicePanel:isInstantiated() then
		if localPlayer:getFactionId() == 1 or localPlayer:getFactionId() == 2 or localPlayer:getFactionId() == 3 then
			if localPlayer:getPublicSync("Faction:Duty") == true then
				PolicePanel:new()
			else
				ErrorBox:new(_"Du bist nicht im Dienst!")
			end
		end
	else
		delete(PolicePanel:getSingleton())
	end
end

function KeyBinds:helpMenu()
	if not HelpGUI:isInstantiated() then
		HelpGUI:new()
		if localPlayer.m_SelfShader then
			delete(localPlayer.m_SelfShader)
			localPlayer.m_SelfShader = nil
		end
		localPlayer.m_SelfShader =  RadialShader:new()
	else
		delete(HelpGUI:getSingleton())
		if localPlayer.m_SelfShader then
			delete(localPlayer.m_SelfShader)
			localPlayer.m_SelfShader = nil
		end
	end
end

function KeyBinds:scoreboardGUI(_, keyState)
	if keyState == "down" then
		ScoreboardGUI:getSingleton():setVisible(true):bringToFront()
	else
		ScoreboardGUI:getSingleton():setVisible(false)
	end
end

--[[
addCommandHandler("checkKeys",function()
	local keyTable = { "mouse1", "mouse2", "mouse3", "mouse4", "mouse5", "mouse_wheel_up", "mouse_wheel_down", "arrow_l", "arrow_u",
	 "arrow_r", "arrow_d", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
	 "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "num_0", "num_1", "num_2", "num_3", "num_4", "num_5",
	 "num_6", "num_7", "num_8", "num_9", "num_mul", "num_add", "num_sep", "num_sub", "num_div", "num_dec", "F1", "F2", "F3", "F4", "F5",
	 "F6", "F7", "F8", "F9", "F10", "F11", "F12", "backspace", "tab", "lalt", "ralt", "enter", "space", "pgup", "pgdn", "end", "home",
	 "insert", "delete", "lshift", "rshift", "lctrl", "rctrl", "[", "]", "pause", "capslock", "scroll", ";", ",", "-", ".", "/", "#", "\\", "=" }
	 outputChatBox("Bounded chatbox command keys: ", 255, 255, 0)
	for _,key in ipairs(keyTable)do --loop through keyTable
		local commands = getCommandsBoundToKey(key, "down")
		if commands and type(commands) == "table" then
			for command, state in pairs (commands) do
				if command == "chatbox" then
					outputChatBox(key..": "..command)
				end
			end
		end
	end
end)
]]
