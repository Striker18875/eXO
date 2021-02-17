-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIElement.lua
-- *  PURPOSE:     Base class for all GUI elements
-- *
-- ****************************************************************************

GUIElement = inherit(DxElement)

function GUIElement:constructor(posX, posY, width, height, parent)
	DxElement.constructor(self, posX, posY, width, height, parent)

	-- Hover / Click Events
	self.m_LActive = false
	self.m_RActive = false
	self.m_Hover  = false
end

function GUIElement:destructor(...)
	DxElement.destructor(self, ...)
end

function GUIElement:performChecks(mouse1, mouse2, cx, cy)
	if not self.m_Visible then
		return
	end

	local isDirectlyHovered = (not GUIElement.ms_HoveredElement or self.m_Parent == GUIElement.ms_HoveredElement or self.m_Parent.m_ChildrenByObject[GUIElement.ms_HoveredElement])
	self.m_DirectlyHovered = isDirectlyHovered
	local absoluteX, absoluteY = self.m_AbsoluteX, self.m_AbsoluteY
	if self.m_CacheArea then
		absoluteX = absoluteX + self.m_CacheArea.m_AbsoluteX
		absoluteY = absoluteY + self.m_CacheArea.m_AbsoluteY
	end

	local tick = getTickCount()
	local leftState, leftClickHandled, leftX, leftY = Cursor:getLeftMouseState()
	local leftInside = leftState and (absoluteX <= leftX and absoluteY <= leftY and absoluteX + self.m_Width > leftX and absoluteY + self.m_Height > leftY) or false
	local inside = (absoluteX <= cx and absoluteY <= cy and absoluteX + self.m_Width > cx and absoluteY + self.m_Height > cy) and isDirectlyHovered

	if self.m_LActive and not mouse1 and (not self.ms_ClickProcessed or GUIElement.ms_CacheAreaRetrievedClick == self.m_CacheArea) then
		if self.onLeftClick			then self:onLeftClick(cx, cy)			end
		if self.onInternalLeftClick	then self:onInternalLeftClick(cx, cy)	end
		self.m_LActive = false

		if self ~= GUIRenderer.cacheroot then
			GUIElement.ms_ClickProcessed = true
			GUIElement.ms_CacheAreaRetrievedClick = self.m_CacheArea
		end
		--return true
	end
	if self.m_RActive and not mouse2 and (not self.ms_ClickProcessed or GUIElement.ms_CacheAreaRetrievedClick == self.m_CacheArea) then
		if self.onRightClick			then self:onRightClick(cx, cy)			end
		if self.onInternalRightClick	then self:onInternalRightClick(cx, cy)	end
		self.m_RActive = false

		if self ~= GUIRenderer.cacheroot then
			GUIElement.ms_ClickProcessed = true
			GUIElement.ms_CacheAreaRetrievedClick = self.m_CacheArea
		end
		--return true
	end

	if not inside then
		-- Call on*Events (disabling)
		if self.m_Hover then
			if self.onUnhover		  then self:onUnhover(cx, cy)         end
			if self.onInternalUnhover then self:onInternalUnhover(cx, cy) end
			if self.m_TooltipInfo	  then self:hideTooltip()             end
			self.m_Hover = false
			self.m_LActive = false
			self.m_RActive = false

			-- Unhover down the tree (otherwise the unhover routine won't be executed)
			unhoverChildren = function(parent)
				if parent and type(parent) == "table" then
					if parent.m_Children then
						for k, child in ipairs(parent.m_Children) do
							if child.performChecks then --only update if it it a GUI element (because DxElements don't have checks)
								if child.onUnhover		   then child:onUnhover(cx, cy)         end
								if child.onInternalUnhover then child:onInternalUnhover(cx, cy) end
								if child.m_TooltipInfo	   then child:hideTooltip()             end
								child.m_Hover = false
								if child.m_Children then
									unhoverChildren(child)
								end
							end
						end
					end
				end
			end
			unhoverChildren(self)
		end

		return
	end

	-- Set hovered element (do it every time because it gets reset before each processing iteration)
	--only when element is directly, via parent or via neighbour hovered
	if isDirectlyHovered then
		GUIElement.ms_HoveredElement = self

		-- Call on*Events (enabling)
		if not self.m_Hover then
			if self.onHover			then self:onHover(cx, cy)			end
			if self.onInternalHover then self:onInternalHover(cx, cy)   end
			if self.m_TooltipInfo   then self:showTooltip() 			end
			self.m_Hover = true
		end
		if mouse1 and not self.m_LActive and (not GUIElement.ms_ClickDownProcessed or GUIElement.ms_CacheAreaRetrievedClick == self.m_CacheArea) and leftInside then
			if self.onLeftClickDown			then self:onLeftClickDown(cx, cy)			end
			if self.onInternalLeftClickDown then self:onInternalLeftClickDown(cx, cy) 	end
			self.m_LActive = true
			Cursor:setLeftClickHandled()

			if self ~= GUIRenderer.cacheroot then
				GUIElement.ms_ClickDownProcessed = true
				GUIElement.ms_CacheAreaRetrievedClick = self.m_CacheArea
			end

			if EVENT_HALLOWEEN and self.m_Blood and core:get("Event", "HalloweenBloodClick", true) then
				Cursor:drawClickBlood()
			end

			-- Check whether the focus changed

			if not GUIInputControl.SelectionInProgress then
				GUIInputControl.checkFocus(self)
				--return
			end
		end
		if mouse2 and not self.m_RActive and (not GUIElement.ms_ClickDownProcessed or GUIElement.ms_CacheAreaRetrievedClick == self.m_CacheArea) then
			if self.onRightClickDown			then self:onRightClickDown(cx, cy)			end
			if self.onInternalRightClickDown	then self:onInternalRightClickDown(cx, cy)	end
			self.m_RActive = true

			if self ~= GUIRenderer.cacheroot then
				GUIElement.ms_ClickDownProcessed = true
				GUIElement.ms_CacheAreaRetrievedClick = self.m_CacheArea
			end
		end


		if self.m_LActive and not mouse1 then
			self.m_LActive = false
		end

		if self.m_RActive and not mouse2 then
			self.m_RActive = false
		end

		-- Check on children
		for k, v in ipairs(self.m_Children) do
			if v.performChecks and v:performChecks(mouse1, mouse2, cx, cy) then
				--break
			end
		end
	end
end

function GUIElement.unhoverAll()
	local self = GUIElement.ms_HoveredElement
	while self do
		if self.m_Hover then
			local relCursorX, relCursorY = getCursorPosition()
			if not relCursorX then return end
			local cursorX, cursorY = relCursorX * screenWidth, relCursorY * screenHeight

			if self.onUnhover		  then self:onUnhover(cursorX, cursorY)         end
			if self.onInternalUnhover then self:onInternalUnhover(cursorX, cursorY) end
			if self.m_TooltipInfo     then self:hideTooltip()						end
			self.m_Hover = false
		end
		self = self.m_Parent
	end
	GUIElement.ms_HoveredElement = false
end

function GUIElement:updateInput()
	-- Check for hovers, clicks, ...
	local relCursorX, relCursorY = getCursorPosition()
	if relCursorX then
		local cursorX, cursorY = relCursorX * screenWidth, relCursorY * screenHeight

		self:performChecks(getKeyState("mouse1"), getKeyState("mouse2"), cursorX, cursorY)
	end
end

function GUIElement.getHoveredElement()
	return GUIElement.ms_HoveredElement
end

function GUIElement:isHovered()
	return self.m_Hover
end

function GUIElement:setTooltip(text, position, lineColor)
	if text then
		self.m_TooltipInfo = {text=text, position=position, lineColor=lineColor}
		if self:isHovered() then
			self:hideTooltip()
			self:showTooltip()
		end
	else
		self.m_TooltipInfo = nil
		self:hideTooltip()
	end
	return self
end

function GUIElement:showTooltip()
	self.m_Tooltip = GUITooltip.create(self.m_TooltipInfo.text, self, self.m_TooltipInfo.position, self.m_TooltipInfo.lineColor)
end

function GUIElement:hideTooltip()
	if self.m_Tooltip then
		delete(self.m_Tooltip)
	end
end