-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Color.lua
-- *  PURPOSE:     Static color "pseudo-class"
-- *
-- ****************************************************************************

Color = {
	Clear     = {0, 0, 0, 0   },
	Black     = {0,     0,   0},
	White     = {255, 255, 255},
	Grey	  = {0x23, 0x23, 0x23, 230},
	LightGrey = {128, 128, 128, 255},
	Red       = {178,  35,  33}, --{255,   0,   0},
	Yellow    = {255, 255,   0},
	Green     = {11,  102,   8}, --{0,   255,   0},
	Blue      = {0,     0, 255},
	DarkBlue  = {0,    32,  63},
	DarkBlueAlpha   = {0,32,  63, 200},
    DarkLightBlue = {0, 50, 100, 255},
	Brown     = {189, 109, 19},
	BrownAlpha= {189, 109, 19, 180},
	LightBlue = {50, 200, 255},
	Orange    = {254, 138, 0},
	LightRed  = {242, 0, 86},
}

AdminColor = {
	[0] = {255,255,255},
	[1] = {0,128,0},
	[2] = {4,95,180},
	[3] = {4,95,180},
	[4] = {4,95,180},
	[5] = {255,0,0},
	[6] = {255,0,0},
	[7] = {255,0,0},
	[8] = {255,0,0},
	[9] = {255,0,0},
}

for k,v in pairs(AdminColor) do
	AdminColor[k] = tocolor(unpack(v))
end

for k, v in pairs(Color) do
	Color[k] = tocolor(unpack(v))
end
