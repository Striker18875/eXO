-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
FishingLocation = inherit(Singleton)

FishingLocation.Map = {
	{location = "lake", func = createColCircle, args = {Vector2(-285.03, -607.24), 300}},
	{location = "lake", func = createColCircle, args = {Vector2(-749.62829589844, -1959.28), 120}}, --sump
	{location = "lake", func = createColCircle, args = {Vector2(2090.97, -163.12), 250}},
	{location = "lake", func = createColPolygon, args = {-887.59, 1977.73, -887.59, 1977.73, -1074.60, 2110.97, -1452.39, 2058.75, -1428.23, 2161.41, -1083.33, 2256.44, -1339.67, 2802.67, -1193.65, 2886.34, -862.18, 2721.25, -780.21, 2547.93, -826.14, 2308.55, -497.28, 2421.28, -446.44, 2208.16, -491.48, 1982.30, -621.76, 2042.06, -752.46, 2056.82}},

	{location = "river", func = createColCuboid, args = {Vector3(-1013.14, 1171.36, -2), 700, 900, 50}},
	{location = "river", func = createColCuboid, args = {Vector3(-749.46, 691.58, -2), 350, 500, 50}},
	{location = "river", func = createColCuboid, args = {Vector3(-979.76, -443.05, -2), 700, 200, 50}},
	{location = "river", func = createColCuboid, args = {Vector3(-154.55, -1541.09, -2), 300, 700, 50}},
	{location = "river", func = createColCuboid, args = {Vector3(699.28, -1928.70, -2), 50, 450, 50}},
	{location = "river", func = createColCuboid, args = {Vector3(-459.35, -1906.91, -2), 200, 80, 50}},
	{location = "river", func = createColCuboid, args = {Vector3(13.86, -614.20, -2), 1880, 650, 50}},
	{location = "river", func = createColCuboid, args = {Vector3(2091.12, 80.22, -2), 150, 240, 50}},
	{location = "river", func = createColPolygon, args = {-2863.18, -778.91, -2863.18, -778.91, -2306.00, -788.46, -992.86, -1936.82, -991.34, -2861.35, -1380.37, -2859.66, -2918.87, -1210.92}},
}

function FishingLocation:constructor()
	self.m_ColShapes = {}
	for k, v in pairs(FishingLocation.Map) do
		local colShape = v.func(unpack(v.args))
		table.insert(self.m_ColShapes, {colShape = colShape, location = v.location})
	end

	outputChatBox("Created ColShapes: " .. #self.m_ColShapes)
end

function FishingLocation:destructor()
	for index, value in pairs(self.m_ColShapes) do
		if value.colShape then
			value.colShape:destroy()
		end
	end
end

function FishingLocation:getLocation(element)
	for index, value in pairs(self.m_ColShapes) do
		if element:isWithinColShape(value.colShape) then
			return value.location
		end
	end
	return "ocean"
end


----------------------------
--DEV
----------------------------
local pol
local ptbl = {}
addCommandHandler("p",
	function(_, arg)
		if arg == "rm" then outputChatBox("rm " .. #ptbl) ptbl[#ptbl] = nil ptbl[#ptbl] = nil outputChatBox("done " .. #ptbl) return end
		local pos = localPlayer.position
		outputChatBox(("Vector2(%s, %s)"):format(pos.x, pos.y))
		table.insert(ptbl, pos.x)
		table.insert(ptbl, pos.y)
		if pol then pol:destroy() end
		if #ptbl >= 6 then
			pol = createColPolygon(pos.x, pos.y, unpack(ptbl))
		end
	end
)

addCommandHandler("polprint",
	function()
		outputConsole(table.concat(ptbl, ", "))
	end
)

local pos
local cub
addCommandHandler("c",
	function(_, width, depth, height)
		pos = localPlayer.position
		outputChatBox(("Vector3(%s, %s, %s), %s, %s, %s"):format(pos.x, pos.y, pos.z, width or "nil", depth or "nil", height or "nil"))
		if width and depth and height then
			if cub then cub:destroy() end
			cub = createColCuboid(pos, width, depth, height)
		end
	end
)


local kk
addCommandHandler("f",
	function(_, arg)
		pos = localPlayer.position
		outputChatBox(("Vector2(%s, %s)"):format(pos.x, pos.y))
		if arg and tonumber(arg) then
			if kk then destroyElement(kk) end
			kk = createColCircle(pos, tonumber(arg))
		end
	end
)

addCommandHandler("w",
	function()
		if pos then
			localPlayer:setPosition(pos)
		end
	end
)
