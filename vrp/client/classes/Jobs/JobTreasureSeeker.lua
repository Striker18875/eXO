-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobTreasureSeeker.lua
-- *  PURPOSE:     JobTreasureSeeker job
-- *
-- ****************************************************************************
JobTreasureSeeker = inherit(Job)
JobTreasureSeeker.Rope = {}

function JobTreasureSeeker:constructor()
	Job.constructor(self, 1, 714.30, -1703.26, 2.43, 270, "TreasureSeeker.png", "files/images/Jobs/HeaderFarmer.png", _(HelpTextTitles.Jobs.TreasureSeeker):gsub("Job: ", ""), _(HelpTexts.Jobs.TreasureSeeker), self.onInfo)
	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.TreasureSeeker):gsub("Job: ", ""), _(HelpTexts.Jobs.TreasureSeeker))

	addEventHandler("onClientRender", root, bind(self.drawRopes, self))
end

function JobTreasureSeeker:start()
	TreasureRadar:new()
end

function JobTreasureSeeker:stop()
	delete(TreasureRadar:getSingleton())
end

addRemoteEvents{"jobTreasureDrawRope"}
addEventHandler("jobTreasureDrawRope", root,function(engine, magnet)
	JobTreasureSeeker.Rope[engine] = magnet
end)

function JobTreasureSeeker:drawRopes()
	for engine, magnet in pairs(JobTreasureSeeker.Rope) do
		if isElement(engine) and isElement(magnet) then
			local pos1 = engine:getPosition()
			local pos2 = magnet:getPosition()
			dxDrawLine3D(pos1, pos2, tocolor(0, 0, 0), 2)
		else
			JobTreasureSeeker.Rope[engine] = nil
		end
	end
end
