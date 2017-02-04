-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/utils.lua
-- *  PURPOSE:     Clientside utility functions
-- *
-- ****************************************************************************
function updateCameraMatrix(x, y, z, lx, ly, lz, r, fov)
	local _x, _y, _z, _lx, _ly, _lz, _r, _fov = getCameraMatrix()
	setCameraMatrix(x or _x, y or _y, z or _z, lx or _lx, ly or _ly, lz or _lz, r or _r, fov or _fov)
end

function fontHeight(font, size)
	return dxGetFontHeight(size, font) * 1.75
end
function fontWidth(text, font, size)
	return dxGetTextWidth(text, size or 1, font or "default")
end

function textHeight(text, lineWidth, font, size)
	--[[
	Breaks words. Lines are automatically broken between words if a word would
	extend past the edge of the rectangle specified by the pRect parameter.
	A carriage return/line feed sequence also breaks the line.
	]]
	local start = 1
	local height = dxGetFontHeight(size, font)
	for pos = 1, text:len() do
		if dxGetTextWidth(text:sub(start, pos), size, font) > lineWidth or text:sub(pos, pos) == "\n" then
			local fh = dxGetFontHeight(size, font)
			height = height + fh
			start = pos - 1
		end
	end
	return height
end

--[[local text = "BlaBlaBlaBla\nfffasdfasdfasdf\nasdf"
local lineWidth = 200
local h = textHeight(text, lineWidth, "arial", 3)
outputDebug("h:"..h)
addEventHandler("onClientRender", root,
	function()

		dxDrawRectangle(300, 300, lineWidth, 100, tocolor(255, 255, 0, 255))
		dxDrawRectangle(300, 300, lineWidth, h, tocolor(0, 0, 255, 255))
		dxDrawText(text, 300, 300, 300+lineWidth, 500, tocolor(255, 0, 0), 3, "arial", "left", "top", false, true)

	end
)]]

_guiCreateScrollBar = guiCreateScrollBar
function guiCreateScrollBar(...) return GUIScrollbarHorizontaloooooooo(...) or _guiCreateScrollBar(...) end

function getElementBehindCursor(worldX, worldY, worldZ)
    local x, y, z = getCameraMatrix()
    local hit, hitX, hitY, hitZ, element = processLineOfSight(x, y, z, worldX, worldY, worldZ, false, true, true, true, false)

    return element
end

-- For easy use with: https://atom.io/packages/color-picker
function rgb(r, g, b)
	return tocolor(r, g, b)
end

function rgba(r, g, b, a)
	return tocolor(r, g, b, a*255)
end

function dxDrawImage3D(x,y,z,w,h,m,c,r,...)
	local lx, ly, lz = x+w, y+h, (z+tonumber(r or 0)) or z
	return dxDrawMaterialLine3D(x,y,z, lx, ly, lz, m, h, c or tocolor(255,255,255,255), ...)
end

function getFreeSkinDimension()
	local dim = math.random(1, 60000)
	for key, player in ipairs( getElementsByType("player") ) do
		if getElementDimension( player ) == dim then
			return getFreeSkinDimension()
		end
	end
	return dim
end

function rectangleCollision2D(rax, ray, raw, rah, rbx, rby, rbw, rbh)
	local RectA = {X1 = rax, X2 = rax + raw, Y1 = ray, Y2 = ray + rah}
	local RectB = {X1 = rbx, X2 = rbx + rbw, Y1 = rby, Y2 = rby + rbh}

	if RectA.X1 <= RectB.X2 and RectA.X2 >= RectB.X1 and RectA.Y1 <= RectB.Y2 and RectA.Y2 >= RectB.Y1 then
		return true
	end
end

function calcDxFontSize(text, width, font, max)
	for i = max, 0.1, -0.1 do
		if dxGetTextWidth(text, i, font) <= width then
			return i
		end
	end
	return max
end

function timeMsToTimeText(timeMs, hideMinutes)
	local minutes	= math.floor( timeMs / 60000 )
	timeMs			= timeMs - minutes * 60000;

	local seconds	= math.floor( timeMs / 1000 )
	local ms		= timeMs - seconds * 1000;

	if hideMinutes and minutes < 1 then
		return ("%02d.%03d"):format(seconds, ms)
	end

	return ("%02d:%02d.%03d"):format(minutes, seconds, ms)
end
