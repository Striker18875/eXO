-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StateEvidenceGUI.lua
-- *  PURPOSE:     StateEvidenceGUI class
-- *
-- ****************************************************************************
StateEvidenceGUI = inherit(GUIForm)
inherit(Singleton, StateEvidenceGUI)

addRemoteEvents{"State:sendEvidenceItems","State:clearEvidenceItems"}
function StateEvidenceGUI:constructor( evidenceTable )
	GUIForm.constructor(self, screenWidth/2-(500/2), screenHeight/2-(370/2), 500, 370)
	self.m_Window = GUIWindow:new(0,0,500,370,_"Asservatenkammer",true,true,self)

	self.m_List = GUIGridList:new(30, 50, self.m_Width-60, 270, self.m_Window)
	self.m_List:addColumn(_"Objekt", 0.2)
	self.m_List:addColumn(_"Menge", 0.2)
	self.m_List:addColumn(_"Besitzer", 0.2)
	self.m_List:addColumn(_"Von", 0.2)
	self.m_List:addColumn(_"Datum", 0.2)
	self.m_EvidenceTable = evidenceTable

--[[
	self.m_mitKaution = GUIButton:new(30, 265, self.m_Width-60, 35,_"mit Kaution einknasten", self.m_Window)
	self.m_mitKaution:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_mitKaution.onLeftClick = bind(self.factionArrestMitKaution,self)
]]

	self:refreshGrid()
	self.m_DestroyEvidenceButton= VRPButton:new( (self.m_Width/2) - 90, 330, 180, 30, "Geld-Transport starten", true, self.m_Window)
	self.m_DestroyEvidenceButton.onLeftClick = function ()
		QuestionBox:new(_"Möchtest du wirklich einen Asservaten Geld-Truck starten?", function()
			triggerServerEvent("State:startEvidenceTruck", localPlayer)
		end)
	end
end

function StateEvidenceGUI:clearList()
	self.m_EvidenceTable = {}
	self.m_List:clear()
end

function StateEvidenceGUI:refreshGrid()
	self.m_List:clear()
	local type_, var1, var2, var3, cop, timeStamp
	local item
	for key,evidenceItems in ipairs(self.m_EvidenceTable) do
		type_, var1, var2, var3, cop, timeStamp = evidenceItems[1], evidenceItems[2], evidenceItems[3], evidenceItems[4], evidenceItems[5], evidenceItems[6]
		if var1 then
			if type_ == "Waffe" then var1 = getWeaponNameFromID(var1) or "Unbekannt"end
			item = self.m_List:addItem(var1 or "Unbekannt", var2 or 1, var3 or "Unbekannt", cop or "Unbekannt", getOpticalTimestamp(tonumber(timeStamp) or getRealTime().timestamp))
			item.onLeftClick = function() end
		end
	end
end

addEventHandler("State:sendEvidenceItems", root,
		function( ev )
			StateEvidenceGUI:new( ev )
		end
	)

addEventHandler("State:clearEvidenceItems", root,
	function( )
		if StateEvidenceGUI:isInstantiated() then
			StateEvidenceGUI:getSingleton():clearList()
		end
	end
)
