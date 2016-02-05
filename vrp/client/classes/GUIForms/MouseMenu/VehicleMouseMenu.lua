-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu.lua
-- *  PURPOSE:     Vehicle mouse menu class
-- *
-- ****************************************************************************
VehicleMouseMenu = inherit(GUIMouseMenu)

function VehicleMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	if getElementData(element, "OwnerName") then
		self:addItem(_("Besitzer: %s", getElementData(element, "OwnerName"))):setTextColor(Color.Red)
	end

	self:addItem(_"Auf-/Zuschließen",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleLock", self:getElement())
			end
		end
	)
	self:addItem(_"Respawn",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleRespawn", self:getElement())
			end
		end
	)
	if getElementData(element, "OwnerName") then
		self:addItem(_"Schlüssel",
			function()
				if self:getElement() then
					VehicleKeyGUI:new(self:getElement())
				end
			end
		)
	end

	self:addItem(_"Fahrzeug leeren",
		function()
			if self:getElement() then
				triggerServerEvent("vehicleEmpty", self:getElement())
			end
		end
	)

	if localPlayer:isInVehicle() then
		self:addItem(_"Kurzschließen",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleHotwire", self:getElement())
				end
			end
		)
	end

	if getElementData(element,"WeaponTruck") then
		self:addItem(_"Kiste abladen",
			function()
				if self:getElement() then
					triggerServerEvent("weaponTruckDeloadBox", self:getElement())
				end
			end
		)
	end

	if localPlayer:getJob() == JobMechanic:getSingleton() then
		self:addItem(_"Mechaniker: Reparieren",
			function()
				if self:getElement() then
					triggerServerEvent("mechanicRepair", self:getElement())
				end
			end
		)
	end

	if localPlayer:getRank() >= RANK.Moderator then
		self:addItem(_"Admin: Reparieren",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRepair", self:getElement())
				end
			end
		)
		self:addItem(_"Admin: Löschen",
			function()
				if not self:getElement() then return end
				QuestionBox:new(_"Möchtest du dieses Auto wirklich löschen?",
					function()
						if self:getElement() then
							triggerServerEvent("vehicleDelete", self:getElement())
						end
					end
				)
			end
		)
	end
end
