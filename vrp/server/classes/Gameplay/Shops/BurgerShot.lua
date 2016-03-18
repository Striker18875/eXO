-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/BurgerShot.lua
-- *  PURPOSE:     BurgerShot Class
-- *
-- ****************************************************************************
BurgerShot = inherit(Shop)

function BurgerShot:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)

	self.m_Type = "BurgerShot"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 30, ["Health"] = 30},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 80, ["Health"] = 80},
		["Healthy"] = {["Name"] = "Vegetarier Menü", ["Price"] = 50, ["Health"] = 50}
	}
	self.m_Items = {["Burger"] = 50}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))
end
