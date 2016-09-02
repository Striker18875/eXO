PRIVATE_DIMENSION_SERVER = 65535 -- This dimension should not be used for playing
PRIVATE_DIMENSION_CLIENT = 2 -- This dimension should be used for things which
							 -- happen while the player is in PRIVATE_DIMENSION on the server

RANK = {}
RANK[-1] = "Banned"
RANK[0] = "User"
RANK[1] = "Supporter"
RANK[2] = "Moderator"
RANK[3] = "SuperModerator"
RANK[4] = "Administrator"
RANK[5] = "Developer"

local r2 = {}
for k, v in pairs(RANK) do
	r2[k] = v
	r2[v] = k
end
RANK = r2

ADMIN_RANK_PERMISSION = {
	["kick"] = RANK.Supporter,
	["rkick"] = RANK.Supporter,
	["prison"] = RANK.Supporter,
	["spect"] = RANK.Supporter,
	["unprison"] = RANK.Supporter,
	["gethere"] = RANK.Supporter,
	["goto"] = RANK.Supporter,
	["showVehicles"] = RANK.Supporter,
	["warn"] = RANK.Supporter,
	["supportMode"] = RANK.Supporter,
	["smode"] = RANK.Supporter,
	["warn"] = RANK.Supporter,
	["addWarn"] = RANK.Supporter,
	["timeban"] = RANK.Moderator,
	["offlineTimeban"] = RANK.SuperModerator,
	["adminAnnounce"] = RANK.Moderator,
	["permaban"] = RANK.SuperModerator,
	["offlinePermaban"] = RANK.SuperModerator,
	["nickchange"] = RANK.SuperModerator,
	["setFaction"] = RANK.SuperModerator,
	["setCompany"] = RANK.SuperModerator,
	["removeWarn"] = RANK.SuperModerator
}

BankStat = {
	Transfer = 0,
	Income = 1,
	Payment = 2,
	Withdrawal = 3,
	Deposit = 4,
	Job = 5,
}

GroupRank = {
	Normal = 0,
	Manager = 1,
	Leader = 2
}

FactionRank = {
	Normal = 0,
	Manager = 5,
	Leader = 6
}

CompanyRank = {
	Normal = 0,
	Manager = 4,
	Leader = 5
}


local r3 = {}
for k, v in pairs(GroupRank) do
	r3[k] = v
	r3[v] = k
end
GroupRank = r3

Crime = {
	Kill = {id = 1, text = "Mord", maxwanted = 4, maxdistance = 1500},
	Hotwire = {id = 2, text = "Fahrzeug kurzgeschlossen", maxwanted = 2, maxdistance = 400},
	BankRobbery = {id = 3, text = "Banküberfall", maxwanted = 6, maxdistance = math.huge},
	JailBreak = {id = 4, text = "Gefängnisausbruch", maxwanted = 4, maxdistance = math.huge},
	PlacingBomb = {id = 5, text = "Legen einer Bombe", maxwanted = 6, maxdistance = 5000},
	HouseRob = {id = 6, text = "Einbruch", maxwanted = 3, maxdistance = math.huge},
	ShopRob = {id = 7, text = "Raubüberfall", maxwanted = 5, maxdistance = math.huge}
}

AmmuNationInfo = {
	[30] = { -- AK-47
		Magazine = {price=30,amount=30},
		Weapon = 1850,
		MinLevel = 7,
	},
	[31] = { -- M4A1
		Magazine = {price=60,amount=50},
		Weapon = 2500,
		MinLevel = 7,
	},
	[29] = { -- MP5
		Magazine = {price=40,amount=30},
		Weapon = 1000,
		MinLevel = 6,
	},
	[25] = { -- Shotgun
		Magazine = {price=2,amount=1},
		Weapon = 900,
		MinLevel = 5,
	},
	[33] = { -- Rifle
		Magazine = {price=4,amount=1},
		Weapon = 1250,
		MinLevel = 6,
	},
	[22] = { -- Pistol
		Magazine = {price=15,amount=17},
		Weapon = 450,
		MinLevel = 3,
	},
	[24] = { -- Desert Eagle
		Magazine = {price=7,amount=7},
		Weapon = 1150,
		MinLevel = 3,
	},
	[1] = { -- Brass Knuckles
		Weapon = 50,
		MinLevel = 0,
	},
	[0] = { -- Armor
		Weapon = 150,
		MinLevel = 0,
	},
}

DEFAULT_GANGAREA_RESOURCES = 500
GangAreaData = {
	{wallPosition = Vector3(2512.3999, -1683.4, 13.9), wallRotation = 129, areaPosition = Vector3(2419.7507, -1627.7887, 15), width = 122, height = 99},
	{wallPosition = Vector3(2080.5, -1597.1, 13.8), wallRotation = 269.5, areaPosition = Vector3(2052.886, -1538.6737, 30), width = 52, height = 70},
	{wallPosition = Vector3(1758.7, -1938.9, 14), wallRotation = 0, areaPosition = Vector3(1683.1904, -1828.8699, 30), width = 125, height = 179},
	{wallPosition = Vector3(1761.5, -1350.2, 16), wallRotation = 0, areaPosition = Vector3(1720.04, -1306.9941, 30), width = 120, height = 150},
	{wallPosition = Vector3(1913.1, -1361.5, 14), wallRotation = 267, areaPosition = Vector3(1854.2794, -1344.212, 30), width = 131, height = 112},
	{wallPosition = Vector3(1959.6, -1173.6, 20.4), wallRotation = 179.5, areaPosition = Vector3(1860.3521, -1140.6764, 30), width = 208, height = 117},
	{wallPosition = Vector3(2215.5, -1173.9, 26.1), wallRotation = 89.75, areaPosition = Vector3(2185.2979, -1130.2002, 30), width = 82, height = 85},
	{wallPosition = Vector3(2768.2, -1625, 11.3), wallRotation = 0, areaPosition = Vector3(2743.6201, -1495.0059, 30), width = 111, height = 155},
	--{wallPosition = Vector3(920.29999, -1231.7, 17.3), wallRotation = 87, areaPosition = Vector3(801.5957, -1154.6094, 30), width = 139, height = 155},
	{wallPosition = Vector3(1237.9, -916.40002, 43.1), wallRotation = 280, areaPosition = Vector3(1156.7124, -850.0401, 30), width = 185, height = 75},
	{wallPosition = Vector3(382.70001, -1875.7, 8.2), wallRotation = 92, areaPosition = Vector3(342.92822, -1796.2261, 30), width = 75, height = 320},
	{wallPosition = Vector3(1065.2, -1617.6, 21.1), wallRotation = 0, areaPosition = Vector3(1035.9404, -1575.9678, 30), width = 111, height = 90},
	{wallPosition = Vector3(474.60001, -1517.6, 20.8), wallRotation = 0, areaPosition = Vector3(425.46933, -1443.4115, 30), width = 102, height = 135},
	{wallPosition = Vector3(2808.8999, -1426.1, 40.5), wallRotation = 270.75, areaPosition = Vector3(2786.498, -1422.0381, 30), width = 43, height = 55},
	{wallPosition = Vector3(2822.2, -2383.2, 12.5), wallRotation = 180.25, areaPosition = Vector3(2805.8359, -2314.9021, 30), width = 53, height = 230},
	{wallPosition = Vector3(2274.7, -68.9, 27), wallRotation = 0, areaPosition = Vector3(2221.5364, -25.009064, 30), width = 122, height = 75},
	{wallPosition = Vector3(731.29999, -1337.2, 13.9), wallRotation = 0, areaPosition = Vector3(636.13751, -1316.6031, 30), width = 162, height = 80},
	{wallPosition = Vector3(1084.5, -1219.5, 18.2), wallRotation = 0, areaPosition = Vector3(1061.6533, -1147.5967, 30), width = 160, height = 135},
	{wallPosition = Vector3(2761.8999, -2015.6, 13.9), wallRotation = 0, areaPosition = Vector3(2720.2043, -1893.7759, 30), width = 100, height = 155},


	-- Regex to get table from map file
	--[[
		areaY=(.*) height=(.*) areaX=(.*) maxZ=(.*) width=(.*) posX=(.*) posY=(.*) posZ=(.*) rotX=(.*) rotY=(.*) rotZ=(.*)
		1			2			3			4			5		6			7			8		9			10		11
		{wallPosition = Vector3\(\6, \7, \8\), wallRotation = \11, areaPosition = Vector3\(\3, \1, \4\), width = \5, height = \2},
	]]
}
-- Fix positions (creation tool is wrong, but I'm too lazy to fix the coordinates manually)
for k, v in pairs(GangAreaData) do
	GangAreaData[k].areaPosition = Vector3(v.areaPosition.x, v.areaPosition.y - v.height, v.areaPosition.z)
end

TURFING_STOPREASON_LEAVEAREA = 1
TURFING_STOPREASON_NEWOWNER = 2
TURFING_STOPREASON_DEFENDED = 3

SkinInfo = {
	-- skinId -- skinName -- skinPrice
	[0] = {"CJ", 5000},
	[2] = {"Weißer Hut", 50},
	[7] = {"Jeans-Jacke", 50},
	[14] = { "Hawai-Shirt", 50},
	[15] = { "Karriertes Hemd", 70},
	[17] = {"Buisiness", 120},
	[18] = {"Strandboy",20},
	[19] = {"Rapper", 50},
	[20] = {"Gelbes Shirt",90},
	[21] = {"Blau karriertes Hemd", 80},
	[22] = {"Rapper 2", 100},
	[23] = {"Skater", 50},
	[24] = {"Los Santos Jacke",60},
	[25] = {"College Jacke", 80},
	[26] = {"Camper", 100},
	[28] = {"Tank top",60},
	[29] = {"Hoodie",50},
	[30] = {"Tanktop Kreuz", 100},
	[32] = {"Augenklappe", 80},
	[33] = {"Trenchcoat", 100},
	[34] = {"Cowboy", 80},
	[35] = {"Anglerhut", 90},
	[36] = {"Baseball Cap",100},
	[37] = {"Baseball Cap2",90},
	[43] = {"Daddy cool",100},
	[46] = {"Weißes Hemd, Kette", 120},
	[47] = {"Grünes Hemd", 100},
	[48] = {"Blau weiß gestreift",90},
	[57] = { "Anzug ( Asiate )", 100},
	[58] = {"Zinkrot Hemd ( Asiate )", 80},
	[59] = {"Gestreiftes Hemd", 70},
	[60] = {"Pullover, Jeans", 90},
	[66] = {"College Jacke2", 80},
	[73] = {"Army jeans, Sandalen", 100},
	[94] = {"Golf Outfit", 90},
	[97] = {"Strand 2", 40},
	[98] = {"Polo-Hemd, jeans", 100},
	[100] = {"Biker", 130},
	[101] = {"Parker-Jacke", 120},
	[133] = {"Trucker, rote Cap", 140},
	[136] = {"Ganja-Mütze, rote jeans", 80},
	[142] = {"Festtagsgewand ( Afrikaner )", 100},
	[143] = {"Sonnenbrille, blaue jacke", 100},
	[144] = {"Maske, Afro", 120},
	[146] = {"Maske, Sandalen", 130},
	[147] = {"Business-Anzug, Grau",160},
	[154] = {"Strand3", 40},
	[158] = {"Cowboy 2", 60},
	[161] = {"Cowboy 3", 70},
	[170] = {"Roter Pullover", 90},
	[171] = {"Anzug, Fliege", 170},
	[177] = {"Frasier-Schnitt, blaues shirt", 90},
	[176] = {"Blaues Shirt", 120},
	[179] = {"Army tanktop, Dogtags", 90},
	[180] = {"Basketball-Shirt", 60},
	[184] = {"Blau weiß Schwarzes Shirt", 90},
	[206] = {"Olives Shirt", 100},

}

MAX_KARMA_LEVEL = 150

VehicleSpecialProperty = {Color = -1, LightColor = -2, Color2 = -3, Shader = -4, Horn = -5, Neon = -6, NeonColor = -7}

Tasks = {
	TASK_GUARD = 1,
	TASK_SHOOT_TARGET = 2,
	TASK_GETTING_TARGETTED = 3,
}

VehiclePositionType = {World = 0, Garage = 1, Mechanic = 2, Hangar = 3, Harbor = 4}
VehicleType = {Automobile = 0, Plane = 1, Bike = 2, Helicopter = 3, Boat = 4, Trailer = 5}
NO_LICENSE_VEHICLES = {509, 481, 462, 510, 448}
TRUCK_MODELS =  {499, 609, 498, 524, 532, 578, 486, 406, 573, 455, 588, 403, 514, 423, 414, 443, 515, 531, 456, 433, 427, 407, 544, 432, 431, 437, 408}


GROUP_RENAME_TIMEOUT = 60*60*24*30 -- 30 Days (in seconds)

GARAGE_UPGRADES_COSTS = {[1] = 200000, [2] = 250000, [3] = 500000}
HANGAR_UPGRADES_COSTS = {[1] = 9999999, [2] = 0, [3] = 0}
GARAGE_UPGRADES_TEXTS = {[0] = "Garage: keine Garage", [1] = "Garage: Standard Garage", [2] = "Garage: Komfortable Garage", [3] = "Garage: Luxus Garage"}
HANGAR_UPGRADES_TEXTS = {[0] = "Hangar: kein Hangar", [1] = "Hangar: Unkown Hangar", [2] = "Hangar: Unkown Hangar", [3] = "Hangar: Unkown Hangar"}

WEAPONTRUCK_MAX_LOAD = 10000

PlayerAttachObjects = {
	[1550] = {["model"] = 1550, ["name"] = "Geldsack", ["pos"] = Vector3(0, -0.3, 0.3), ["rot"] = Vector3(0, 0, 180)},
	[2912] = {["model"] = 2912, ["name"] = "Waffenkiste", ["pos"] = Vector3(-0.09, 0.35, 0.45), ["rot"] = Vector3(10, 0, 0)}
}

VEHICLE_SPECIAL_SMOKE = {[512] = true, [513] = true}
VEHICLE_SPECIAL_TEXTURE = {
	[560] = "#emapsultanbody256",
	[561] = "#emapstratum292body256",
	[495] = "vehiclegrunge256",
	[575] = "remapbroadway92body128",
	[565] = "#emapflash92body256",
	[536] = "#emapblade92body128",
	[483] = "#emapcamperbody256",
	[415] = "#vehiclegrunge256",
	[411] = "vehiclegrunge256",
	[562] = "#emapelegybody128",
	[562] = "#emapelegybody128",
	[535] = "#emapslamvan92body128",
	[559] = "#emapjesterbody256",
}

COROUTINE_STATUS_RUNNING = "running"
COROUTINE_STATUS_SUSPENDED = "suspended"
COROUTINE_STATUS_DEAD = "dead"

THREAD_PRIORITY_LOW = 500
THREAD_PRIORITY_MIDDLE = 250
THREAD_PRIORITY_HIGH = 150
THREAD_PRIORITY_HIGHEST = 50

AD_COST = 30
AD_COST_PER_CHAR = 3
AD_BREAK_TIME = 30 -- In Seconds

AD_COLORS = {"Orange", "Grün", "Hell-Blau"}

AD_DURATIONS = {
	["20 Sekunden"] = 20,
	["30 Sekunden"] = 30,
	["45 Sekunden"] = 45
}

WEAPON_NAMES = {
	[0] = "Faust",
	[1] = "Schlagring",
	[2] = "Golfschläger",
	[3] = "Schlagstock",
	[4] = "Messer",
	[5] = "Baseball Schläger",
	[6] = "Schaufel",
	[7] = "Billiard Queue",
	[8] = "Katana",
	[9] = "Kettensäge",
	[10] = "Langer Pinker Dildo",
	[11] = "Kurzer Dildo",
	[12] = "Vibrator",
	[14] = "Blumen",
	[15] = "Gehstock",
	[16] = "Granaten",
	[17] = "Tränengas",
	[18] = "Molotov Cocktails",
	[22] = "9mm Pistole",
	[23] = "Taser",
	[24] = "Desert Eagle",
	[25] = "Schrotflinte",
	[26] = "Abgesägte Schrotflinte",
	[27] = "SPAZ-12 Spezialwaffe",
	[28] = "Uzi",
	[29] = "MP5",
	[30] = "AK-47",
	[31] = "M4",
	[32] = "TEC-9",
	[33] = "Jagd Gewehr",
	[34] = "Sniper",
	[35] = "Raketenwerfer",
	[36] = "RPG",
	[37] = "Flammenwerfer",
	[38] = "Minigun",
	[39] = "Rucksack-Bomben",
	[40] = "Bomben Auslöser",
	[41] = "Spray-Dose",
	[42] = "Feuerlöscher",
	[43] = "Kamera",
	[44] = "Nachtsicht-Gerät",
	[45] = "Wärmesicht-Gerät",
	[46] = "Fallschrirm"
}

WEAPON_IDS = {}
for id, name in pairs(WEAPON_NAMES) do
	WEAPON_IDS[name] = id
end

DEATH_TIME = 36000
DEATH_TIME_PREMIUM = 21000
DEATH_TIME_ADMIN = 11000
