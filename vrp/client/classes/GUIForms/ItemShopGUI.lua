-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ItemShopGUI.lua
-- *  PURPOSE:     Item shop GUI class
-- *
-- ****************************************************************************
ItemShopGUI = inherit(GUIForm)
inherit(Singleton, ItemShopGUI)

addRemoteEvents{"showItemShopGUI", "refreshItemShopGUI", "showStateItemGUI", "showBarGUI"}

function ItemShopGUI:constructor(callback)
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3*0.5, screenHeight/2-screenHeight*0.4*0.5, screenWidth*0.3, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Shop", true, true, self)
	self.m_Preview = GUIImage:new(self.m_Height*0.08, self.m_Height*0.12, self.m_Width*0.2, self.m_Width*0.2, false, self.m_Window)
	self.m_LabelDescription = GUILabel:new(self.m_Width*0.02, self.m_Width*0.3, self.m_Width*0.45, self.m_Height-self.m_Width*0.76, "", self.m_Window) -- use width to align correctly
	self.m_LabelDescription:setFont(VRPFont(self.m_Height*0.07)):setMultiline(true)

	self.m_Grid = GUIGridList:new(self.m_Width*0.5, self.m_Height*0.12, self.m_Width*0.48, self.m_Height*0.7, self.m_Window)
	self.m_Grid:addColumn(_"Name", 0.7)
	self.m_Grid:addColumn(_"Preis", 0.3)

	GUILabel:new(self.m_Width*0.08, self.m_Height*0.8, self.m_Width*0.2, self.m_Height*0.1, "Anzahl:", self.m_Window)
	self.m_EditAmount = GUIEdit:new(self.m_Width*0.26, self.m_Height*0.8, self.m_Width*0.1, self.m_Height*0.1, self.m_Window)
	self.m_EditAmount:setNumeric(true, true)
	self.m_EditAmount:setText("1")

	self.m_ButtonBuy = VRPButton:new(self.m_Width*0.65, self.m_Height*0.85, self.m_Width*0.33, self.m_Height*0.12, _"auswählen", true, self.m_Window):setBarColor(Color.Green)
	self.m_ButtonBuy.onLeftClick = bind(self.ButtonBuy_Click, self)

	addEventHandler("refreshItemShopGUI", root, bind(self.refreshItemShopGUI, self))
	self.m_CallBack = callback
end

function ItemShopGUI:refreshItemShopGUI(shopId, items)
	self.m_Shop = shopId or 0
	local item
	local itemData = Inventory:getSingleton():getItemData()
	if itemData then
		self.m_Grid:clear()
		for name, price in pairs(items) do
			item = self.m_Grid:addItem(name, tostring(price.."$"))
			item.Id = name
				item.onLeftClick = function()
				self.m_Preview:setImage("files/images/Inventory/items/"..itemData[name]["Icon"])
				self.m_LabelDescription:setText(itemData[name]["Info"])
			end
		end
	end
end

function ItemShopGUI:ButtonBuy_Click()
	if not self.m_Grid:getSelectedItem() then
		ErrorBox:new(_"Bitte wähle zuerst ein Item aus")
		return
	end

	local itemName = self.m_Grid:getSelectedItem().Id
	if not itemName then
		core:throwInternalError("Unknown itemName @ ItemShopGUI")
		return
	end
	local amount = tonumber(self.m_EditAmount:getText())
	if not amount then
		ErrorBox:new(_"Bitte gebe einen gültige Anzahl ein!")
		return
	end

	self.m_CallBack(self.m_Shop, itemName, amount)
end

addEventHandler("showItemShopGUI", root,
	function()
		if ItemShopGUI:isInstantiated() then delete(ItemShopGUI:getSingleton()) end
		local callback = function(shop, itemName, amount)
			triggerServerEvent("shopBuyItem", root, shop, itemName, amount)
		end
		ItemShopGUI:new(callback)
	end
)

addEventHandler("showBarGUI", root,
	function()
		if ItemShopGUI:isInstantiated() then delete(ItemShopGUI:getSingleton()) end
		local callback = function(shop, itemName, amount)
			triggerServerEvent("barBuyDrink", root, shop, itemName, amount)
		end
		ItemShopGUI:new(callback)
	end
)

addEventHandler("showItemShopGUI", root,
	function()
		if ItemShopGUI:isInstantiated() then delete(ItemShopGUI:getSingleton()) end
		local callback = function(shop, itemName, amount)
			triggerServerEvent("shopBuyItem", root, shop, itemName, amount)
		end
		ItemShopGUI:new(callback)
	end
)

addEventHandler("showStateItemGUI", root,
	function()
		if ItemShopGUI:isInstantiated() then delete(ItemShopGUI:getSingleton()) end
		local callback = function(shop, itemName, amount)
			triggerServerEvent("factionStatePutItemInVehicle", root, itemName, amount)
		end
		ItemShopGUI:new(callback)
	end
)
