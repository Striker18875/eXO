-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/ItemManager.lua
-- *  PURPOSE:     Item manager class
-- *
-- ****************************************************************************
ItemManager = inherit(Singleton)
ItemManager.Map = {}

function ItemManager:constructor()
	addRemoteEvents{"onClientBreakItem"}
	self.m_ClassItems = {
		["Barrikade"] = ItemBarricade,
		["Blitzer"] = ItemSpeedCam,
		["Nagel-Band"] = ItemNails,
		["Radio"] = ItemRadio,
		["Sprengstoff"] = ItemBomb,
		["Weed"] = DrugsWeed,
		["Heroin"] = DrugsHeroin,
		["Shrooms"] = DrugsShroom,
		["Kokain"] = DrugsCocaine,
		["Burger"] = ItemFood,
		["Pizza"] = ItemFood,
		["Pilz"] = ItemFood,
		["Zigarette"] = ItemFood,
		["Donut"] = ItemFood,
		["Donutbox"] = ItemDonutBox,

		["Wuerfel"] = ItemDice,
		["Weed-Samen"] = PlantWeed,
		["Kanne"] = ItemCan,
		["Handelsvertrag"] = ItemSellContract,
		["Ausweis"] = ItemIDCard,
		["Benzinkanister"] = ItemFuelcan,
		["Reparaturkit"] = ItemRepairKit,
		--Alcohol
		["Bier"] = ItemAlcohol,
		["Whiskey"] = ItemAlcohol,
		["Sex on the Beach"] = ItemAlcohol,
		["Pina Colada"] = ItemAlcohol,
		["Monster"] = ItemAlcohol,
		["Shot"] = ItemAlcohol,
		["Cuba-Libre"] = ItemAlcohol,
		
		--//Wearables
		["Helm"] = WearableHelmet,
		["Motorcross-Helm"] = WearableHelmet,
		["Pot-Helm"] = WearableHelmet,
		["Gasmaske"] = WearableHelmet,
		["Kevlar"] = WearableShirt,
		["Tragetasche"] = WearableShirt,
		["Swatschild"] = WearablePortables,
	}

	self.m_Properties = {
	["Barrikade"] = {true} --// breakable,
}
	self.m_SpecialItems = {
		["Mautpass"] = true,
		["Kanne"] = true
	}

	for name, class in pairs(self.m_ClassItems) do
		local breakable = false
		if self.m_Properties[name] then
			breakable = true
		end
		local instance = class:new( )
		instance:setName(name)
		instance:loadItem()
		instance.m_Breakable = breakable
		ItemManager.Map[name] = instance
	end
	addEventHandler("onClientBreakItem",root, bind(self.Event_onItemBreak,self))
end

function ItemManager:Event_onItemBreak()
	if source and isElement(source) then
		if source.m_Super and source.m_Super.m_Breakable then
			delete(source.m_Super)
		end
	end
end

function ItemManager:getClassItems()
	return self.m_ClassItems
end

function ItemManager:getInstance(itemName)
	return ItemManager.Map[itemName]
end
