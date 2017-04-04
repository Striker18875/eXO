
TexturePreviewGUI = inherit(GUIForm)
inherit(Singleton, TexturePreviewGUI)
addRemoteEvents{"texturePreviewLoadTextures"}

function TexturePreviewGUI:constructor()
	GUIForm.constructor(self, 10, 10, screenWidth/4/ASPECT_RATIO_MULTIPLIER, screenHeight/1.5)

	self.m_Path = "http://picupload.pewx.de/textures/"
	self.m_Admin = localPlayer:getRank() >= ADMIN_RANK_PERMISSION["vehicleTexture"] and true or false

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug-Textur Vorschau", false, true, self)
	self.m_Window:deleteOnClose( true )
	self.m_TextureList = GUIGridList:new(0, 40, self.m_Width, self.m_Height*0.6, self.m_Window)
	self.m_TextureList:addColumn(_"Name", 1)

	self.m_VehiclePosition = Vector3(1944.97, -2307.69, 14.54)
	self.m_PlayerPosition = Vector3(1948.85, -2320.42, 17.11)
	setCameraMatrix(self.m_PlayerPosition, self.m_VehiclePosition)

	self.m_CreatorLabel = GUILabel:new(self.m_Width*0.01, self.m_Height*0.8, self.m_Width*0.98, self.m_Height*0.05, "", self.m_Window)

	if self.m_Admin then
		self.m_AcceptButton = GUIButton:new(self.m_Width*0.01, self.m_Height*0.86, self.m_Width*0.98, self.m_Height*0.05, _"Freischalten", self.m_Window):setBackgroundColor(Color.Green)
		self.m_AcceptButton.onLeftClick = function()
			if self.m_SelectedID then
				triggerServerEvent("texturePreviewUpdateStatus", localPlayer, self.m_SelectedID, 1)
			end
		end
		self.m_DeclineButton = GUIButton:new(self.m_Width*0.01, self.m_Height*0.92, self.m_Width*0.98, self.m_Height*0.05, _"Ablehnen", self.m_Window):setBackgroundColor(Color.Red)
		self.m_DeclineButton.onLeftClick = function()
			if self.m_SelectedID then
				triggerServerEvent("texturePreviewUpdateStatus", localPlayer, self.m_SelectedID, 2)
			end
		end
	end

	triggerServerEvent("texturePreviewRequestTextures", localPlayer, self.m_Admin)

	addEventHandler("texturePreviewLoadTextures", root, bind(self.initTextures, self))

	showChat(false)

	self.m_RotateBind = bind(self.rotateVehicle, self)
	addEventHandler("onClientPreRender", root, self.m_RotateBind)
end

function TexturePreviewGUI:destructor(closedByServer)
	setCameraTarget(localPlayer)
	removeEventHandler("onClientPreRender", root, self.m_RotateBind)
	GUIForm.destructor(self)
end

function TexturePreviewGUI:rotateVehicle()
	if localPlayer:getData("TexturePreviewCar") and isElement(localPlayer:getData("TexturePreviewCar")) then
		local rot = localPlayer:getData("TexturePreviewCar"):getRotation()
		rot.z = rot.z+1
		rot.z = rot.z > 360 and rot.z-360 or rot.z
		localPlayer:getData("TexturePreviewCar"):setRotation(rot)
	end
end

function TexturePreviewGUI:initTextures(textures)
    -- Add 'special properties' (e.g. color)
    for _, row in ipairs(textures) do
        local item = self.m_TextureList:addItem(row["Name"])
        item.Url = self.m_Path..row["Image"]
        item.Id = row["Id"]
		item.Model = row["Model"]
		item.Creator = row["UserName"] or "Unknown"
		item.onLeftClick = bind(self.Texture_Click, self)
    end
end

function TexturePreviewGUI:Texture_Click(item)
    if item.Url then
		self.m_SelectedID = item.Id
		self.m_CreatorLabel:setText(_("Ersteller: %s", item.Creator))
		triggerServerEvent("texturePreviewStartPreview", localPlayer, item.Url, item.Model)
	end
end
