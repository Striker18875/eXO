-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/VehicleMouseMenuDetails.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
VehicleMouseMenuDetails = inherit(GUIMouseMenu)

function VehicleMouseMenuDetails:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)

		self:addItem(_("Kategorie: %s", element:getCategoryName())):setTextColor(Color.White)
		self:addItem(_("Steuern: %s $ / PayDay", element:getTax())):setTextColor(Color.White)
		self:addItem(_("Sprittyp: %s", FUEL_NAME[element:getFuelType()])):setTextColor(Color.White)
		self:addItem(_("Tankgröße: %s Liter", element:getFuelTankSize())):setTextColor(Color.White)
		self:addItem(_("Tankinhalt: %s  Liter (%s%%)",element:getFuel()/100*element:getFuelTankSize(), element:getFuel())):setTextColor(Color.White)
		self:addItem(_("Verbrauchsmult.: %s",element:getFuelConsumptionMultiplicator())):setTextColor(Color.White)
	

	self:adjustWidth()
end
