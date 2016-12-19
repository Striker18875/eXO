-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu.lua
-- *  PURPOSE:     Player mouse menu class
-- *
-- ****************************************************************************
BeggarPedMouseMenu = inherit(GUIMouseMenu)

function BeggarPedMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	self:addItem(("%s (Obdachloser)"):format(element:getData("BeggarName"))):setTextColor(Color.Orange)

	if element:getData("BeggarType") == BeggarTypes.Money then
		self:addItem("Geld geben",
			function ()
				SendMoneyGUI:new(
					function (amount)
						triggerServerEvent("giveBeggarPedMoney", self:getElement(), amount)
					end
				)
			end
		)
	elseif element:getData("BeggarType") == BeggarTypes.Food then
		self:addItem("Burger geben",
			function ()
				triggerServerEvent("giveBeggarItem", self:getElement(), "Burger")
			end
		)
	elseif element:getData("BeggarType") == BeggarTypes.Transport then
		self:addItem("Obdachlosen transportieren",
			function ()
				triggerServerEvent("acceptTransport", self:getElement())
			end
		)
	end

	self:addItem("Ausrauben",
		function ()
			triggerServerEvent("robBeggarPed", self:getElement())
		end
	)
end
