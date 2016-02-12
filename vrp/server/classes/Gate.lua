Gate = inherit(Object)

function Gate:constructor(model, pos, rot, openPos, customOffset)
    self.m_ClosedPos = pos
    self.m_OpenPos = openPos
    self.m_Gate = createObject(model, pos, rot)

    self:createColshapes(customOffset)

    addEventHandler("onColShapeHit", self.m_ColShape1, bind(self.Event_onColShapeHit, self))
    addEventHandler("onColShapeHit", self.m_ColShape2, bind(self.Event_onColShapeHit, self))
end

function Gate:createColshapes(customOffset)
    local model, pos, rot = self.m_Gate.model, self.m_Gate.position, self.m_Gate.rotation
    local x, y, x1, y1
    if model == 980 then
        x1, y1 = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+180)
        x2, y2 = getPointFromDistanceRotation(pos.x, pos.y, 4, rot.z)
    elseif model == 9093 then
        x1, y1 = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+80)
        x2, y2 = getPointFromDistanceRotation(pos.x, pos.y, 4, rot.z+60)
    end
    self.m_Marker1 = createMarker(Vector3(x1, y1, pos.z - 1.75) + self.m_Gate.matrix.forward*(customOffset and -customOffset or -2),"cylinder",1) -- Developement Test
    self.m_Marker2 = createMarker(Vector3(x2, y2, pos.z - 1.75) + self.m_Gate.matrix.forward*(customOffset or 2),"cylinder",1,255) -- Developement Test
    self.m_ColShape1 = ColShape.Sphere(Vector3(x1, y1, pos.z - 1.75) + self.m_Gate.matrix.forward*(customOffset and -customOffset or -2), 5)
    self.m_ColShape2 = ColShape.Sphere(Vector3(x2, y2, pos.z - 1.75) + self.m_Gate.matrix.forward*(customOffset or 2), 5)
end

function Gate:Event_onColShapeHit(hitEle, matchingDimension)
    if hitEle:getType() == "player" and matchingDimension then
        local player = hitEle
        if player:isInVehicle() and player:getOccupiedVehicleSeat() ~= 0 then
            return
        end
        if self.m_Timer and isTimer(self.m_Timer) then
            killTimer(self.m_Timer)
        end
        if self.onGateHit and self.onGateHit(player) == false then
            return
        end
        if self.m_Closed then
            self.m_Gate:move(1250, self.m_OpenPos)
            self.m_Closed = false

            self.m_Timer = setTimer(bind(self.Event_onColShapeHit, self, player, true), 10000, 1)
            --outputDebug("Opening: "..(0-rot.y).." ["..rot.y.."; 0]")
        else
            self.m_Gate:move(1250, self.m_ClosedPos)
            self.m_Closed = true
            --outputDebug("Closing: "..(-rot.y+90).." ["..rot.y.."; 90]")
         end
     end
end

function Gate:setGateScale(scale)
    self.m_Gate:setScale(scale)
end
