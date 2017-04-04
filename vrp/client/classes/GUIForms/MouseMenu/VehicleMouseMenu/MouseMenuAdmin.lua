-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/VehicleMouseMenuAdmin.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
VehicleMouseMenuAdmin = inherit(GUIMouseMenu)

function VehicleMouseMenuAdmin:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	local owner = getElementData(element, "OwnerName")
	if owner then
		self:addItem(_("Besitzer: %s (Admin)", owner)):setTextColor(Color.Red)
	end

	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)
	if getElementData(element, "OwnerType") ~= "faction" and getElementData(element, "OwnerType") ~= "company" then
		self:addItem(_"Respawnen / Parken >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenuRespawn:new(posX, posY, element), element)
				end
			end
		)
	else
		self:addItem(_"Respawn",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRespawn", self:getElement())
				end
			end
		)
	end
	if localPlayer:getRank() >= RANK.Moderator then
		self:addItem(_"Fahrzeug reparieren",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleRepair", self:getElement())
				end
			end
		)

		self:addItem(_"Fahrzeug despawnen",
			function()
				if not self:getElement() then return end
					triggerServerEvent("adminVehicleDespawn", self:getElement())
			end
		)

		self:addItem(_"Fahrzeug Handbremse lösen",
			function()
				if self:getElement() then
					triggerServerEvent("vehicleToggleHandbrake", self:getElement())
				end
			end
		)

		self:addItem(_"Fahrzeug löschen",
			function()
				if not self:getElement() then return end
				InputBox:new(_"Fahrzeug löschen", _"Aus welchem Grund möchtest du das Fahrzeug löschen?",
					function(reason)
						if self:getElement() then
							triggerServerEvent("vehicleDelete", self:getElement(), reason)
						end
					end
				)
			end
		)
	end
end
