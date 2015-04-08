-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMoveable.lua
-- *  PURPOSE:     GUI moveable super class
-- *
-- ****************************************************************************
GUIMovable = {}

function GUIMovable:virtual_constructor()
	self.m_CursorMoveHandler = bind(GUIMovable.Event_CursorMove, self)
end

function GUIMovable:startMoving()
	local cursorX, cursorY = getCursorPosition()
	cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
	local element = self.m_CacheArea or self

	self.m_CursorOffsetX, self.m_CursorOffsetY = cursorX - element.m_AbsoluteX, cursorY - element.m_AbsoluteY
	addEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
end

function GUIMovable:stopMoving()
	removeEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
end

function GUIMovable:Event_CursorMove(cursorX, cursorY, absoluteX, absoluteY)
	local moveElement = self.m_CacheArea or self
	if moveElement == GUIRenderer.cacheroot then
		--moveElement = self
		return
	end
	moveElement:setAbsolutePosition(absoluteX - self.m_CursorOffsetX, absoluteY - self.m_CursorOffsetY)
end
