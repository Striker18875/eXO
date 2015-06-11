-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobPolice.lua
-- *  PURPOSE:     Police job class
-- *
-- ****************************************************************************
JobPolice = inherit(Job)

function JobPolice:constructor()
	Job.constructor(self, 1549.5, -1681.6, 12.6, "Police.png", "files/images/Jobs/HeaderPolice.png",_(HelpTextTitles.Jobs.Police):gsub("Job: ", ""), _(HelpTexts.Jobs.Police))

	-- add job to help menu
	HelpTextManager:getSingleton():addText("Jobs", _(HelpTextTitles.Jobs.Police):gsub("Job: ", ""), _(HelpTexts.Jobs.Police))
end

function JobPolice:start()
	-- Show text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.Jobs.Police), _(HelpTexts.Jobs.Police))
end

function JobPolice:stop()
	-- Reset text in help menu
	HelpBar:getSingleton():addText(_(HelpTextTitles.General.Main), _(HelpTexts.General.Main), false)
end

local jailCountdownGUI
addEvent("playerJailed", true)
addEventHandler("playerJailed", root,
	function(jailTime)
		local jailedTime = getTickCount()

		-- Play arrest cutscene
		CutscenePlayer:getSingleton():playCutscene("Arrest",
			function()
				local remainingTime = math.floor(jailTime - (getTickCount() - jailedTime)/1000)

				InfoBox:new(_("Willkommen im Gefängnis! Hier wirst du nun für die nächsten %ds verweilen!", remainingTime))
				jailCountdownGUI = JailCountdownGUI:new(remainingTime)
			end
		)
	end
)

addEvent("playerLeftJail", true)
addEventHandler("playerLeftJail", root,
	function()
		if jailCountdownGUI then
			delete(jailCountdownGUI)
			jailCountdownGUI = nil
		end
	end
)
