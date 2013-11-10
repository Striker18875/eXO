-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Jobs/JobLogistician.lua
-- *  PURPOSE:     Logistician job
-- *
-- ****************************************************************************
JobLogistician = inherit(Job)

function JobLogistician:constructor()
	Job.constructor(self, 0, 0, 3, "files/images/Blips/Logistician.png", "files/images/Jobs/HeaderTrashman.png", LOREM_IPSUM)
end
