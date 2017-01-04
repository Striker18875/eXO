HTTPDownloadGUI = inherit(GUIForm)
inherit(Singleton, HTTPDownloadGUI)

function HTTPDownloadGUI:constructor()
	self.m_Failed = false
	self.m_FileCount = 0
	self.m_CurrentFile = 0

	GUIForm.constructor(self, 0, 0, screenWidth, screenHeight)
	self.m_Logo = GUIImage:new(screenWidth/2 - 350/2, screenHeight/2 - 200/2 - 120, 350, 167, "files/images/Logo.png", self)
	self.m_Text = GUILabel:new(0, screenHeight - 150 - 60/2, screenWidth, 60, "downloading files...", self):setAlignX("center")
	self.m_DownloadBar = GUIRectangle:new(screenWidth/6, screenHeight - 75 - 25/2, screenWidth - screenWidth/3, 25, tocolor(0, 125, 255, 150), self)
	self.m_CurrentState = GUILabel:new(screenWidth/6 + 10, screenHeight - 75 - 20/2, screenWidth - screenWidth/3, 20, "", self)
	self.m_CurrentState:setFont(FontAwesome(20))

	fadeCamera(false, 0.1)
end

function HTTPDownloadGUI:destructor()
	GUIForm.destructor(self)
	fadeCamera(true)
end

function HTTPDownloadGUI:setStateText(text)
	self.m_CurrentState:setText(text)
end

function HTTPDownloadGUI:setCurrentFile(file)
	if file:sub(-9, #file) == "index.xml" then
		self:setStateText("downloading file-index")
	else
		self:setStateText(("downloaded %d of %d files. current file: %s"):format(self.m_CurrentFile, self.m_FileCount, file))
		self.m_CurrentFile = self.m_CurrentFile + 1
	end
end

function HTTPDownloadGUI:markAsFailed(reason)
	self.m_Failed = true
	self:setStateText(("A error occured while downloading files: %s (Please try again later, or contact an Administrator)"):format(reason))
	self.m_DownloadBar:setColor(tocolor(125, 0, 0, 255))
end

function HTTPDownloadGUI:setStatus(status, arg)
	if status == "failed" then
		self:markAsFailed(arg)
	elseif status == "file count" then
		self.m_FileCount = arg
	elseif status == "current file" then
		self:setCurrentFile(arg)
	elseif status == "unpacking" then
		self:setStateText(arg)
		self.m_DownloadBar:setColor(tocolor(0, 125, 0, 255))
		self.m_Text:setText("unpacking packages...")
	elseif status == "waiting" then
		self.m_DownloadBar:setColor(tocolor(0, 125, 0, 255))
		self:setStateText(arg)
		--self.m_Text:setText("")
	end
end
