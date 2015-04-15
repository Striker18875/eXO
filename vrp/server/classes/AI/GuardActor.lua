-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/GuardActor.lua
-- *  PURPOSE:     Guard actor class
-- *
-- ****************************************************************************
GuardActor = inherit(Actor)

function GuardActor:constructor()
    self:setModel(161)
    self:giveWeapon(23, 999999999, true)

    -- Start tasks
    self:startIdleTask()
end

function GuardActor:getIdleTask()
    return TaskGuard
end
