-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Casino.lua
-- *  PURPOSE:     Casino singleton class
-- *
-- ****************************************************************************
Casino = inherit(Singleton)

function Casino:constructor()
	InteriorEnterExit:new(Vector3(1471.36, -1178.09, 23.92), Vector3(2233.99, 1714.685, 1012.38), 180, 0, 1)
	Blip:new("Casino.png", 1471.36, -1178.09,root,300)

	Slotmachine:new(2244.2177734375, 1634.9814453125, 1008.7, 0, 0, 307.98718261719,1)
	Slotmachine:new(2228.0625, 1635.673828125, 1008.7, 0, 0, 47.892883300781,1)
	Slotmachine:new(2247.1669921875, 1594.1533203125, 1006.5, 0, 0, 90,1)
	Slotmachine:new(2247.169921875, 1587.5537109375, 1006.5, 0, 0, 90,1)
	Slotmachine:new(2214.0537109375, 1603.6689453125, 1006.7553955078, 0, 0, 90,1)
	Slotmachine:new(2278.8876953125, 1617.419921875, 1006.7782836914, 0, 0, 270,1)
	Slotmachine:new(2253.544921875, 1632.1376953125, 1008.959375, 0, 0, 0,1)
	Slotmachine:new(2260.9892578125, 1632.140625, 1008.959375, 0, 0, 360,1)
	Slotmachine:new(2222.984375, 1632.1484375, 1008.959375, 0, 0, 360,1)
	Slotmachine:new(2214.33984375, 1632.1474609375, 1008.959375, 0, 0, 360,1)
	Slotmachine:new(2223.2060546875, 1571.296875, 1008.959375, 0, 0, 120,1)
	Slotmachine:new(2229.0947265625, 1563.3232421875, 1008.959375, 0, 0, 120,1)

end
