TextureReplacer = inherit(Object)
TextureReplacer.Map = {
	SERVER_ELEMENTS = {},
	SHARED_ELEMENTS = {},
	TEXTURE_CACHE = {}
}
TextureReplacer.Status = {
	SUCCESS = 1,
	FAILURE = 2,
	DELAYED = 3
}
TextureReplacer.Queue = Queue:new()

-- abstract methods
TextureReplacer.load   = pure_virtual
TextureReplacer.unload = pure_virtual

-- normal methods
function TextureReplacer:constructor(element, textureName, options)
	assert(isElement(element), "Bad Argument @ TextureReplacer:constructor #1")

	self.m_Element     = element
	self.m_TextureName = textureName
	self.m_LoadingMode = core:get("Other", "TextureMode", 1)
	self.m_Active      = true

	self.m_OnElementDestory   = bind(delete, self)
	self.m_OnElementStreamIn  = bind(self.onStramIn, self)
	self.m_OnElementStreamOut = bind(self.onStramOut, self)

	addEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestory)
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		addEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
		addEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
	elseif self.m_LoadingMode == TEXTURE_LOADING_MODE.PERMANENT then
		self:addToLoadingQeue()
	elseif self.m_LoadingMode == TEXTURE_LOADING_MODE.NONE then
		self.m_Active = false
	end

	-- Save instance to map
	TextureReplacer.addRef(self)
end

function TextureReplacer:destructor()
	-- Remove Map ref
	TextureReplacer.removeRef(self)

	-- Unload texture
	self:unload()

	-- Remove events
	if isElement(self.m_Element) then -- does the element still exist?
		removeEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestory)
		if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
			removeEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
			removeEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
		end
	end
end

function TextureReplacer:onStramIn()
	if not self.m_Active then return false end
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		self:addToLoadingQeue()
	end
end

function TextureReplacer:onStramOut()
	if not self.m_Active then return false end
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		outputDebug("TextureReplacer:onStreamOut")
		outputDebug("TextureReplacer:onStreamOut:Result("..self:unload()..")")
	end
end

function TextureReplacer:attach()
	if not self.m_Texture then return TextureReplacer.Status.FAILURE end
	if self.m_Shader then return TextureReplacer.Status.FAILURE end

	self.m_Shader = DxShader("files/shader/texreplace.fx")
	if not self.m_Shader then
		self.m_Active = false
		error(("Error @ TextureReplacer:attach, shader failed to create! [Element: %s]"):format(inspect(self.m_Element)))
	end

	self.m_Shader:setValue("gTexture", self.m_Texture)
	local status = self.m_Shader:applyToWorldTexture(self.m_TextureName, self.m_Element)

	-- process next texture
	if DEBUG then
		nextframe(self.loadNext, self)
	else
		setTimer(self.loadNext, 250, 1, self)
	end

	return status and TextureReplacer.Status.SUCCESS or TextureReplacer.Status.FAILURE
end

function TextureReplacer:detach()
	if not self.m_Shader or not isElement(self.m_Shader) then return TextureReplacer.Status.FAILURE end

	self.m_Shader:destroy()
	if self.m_Shader then self.m_Shader = nil end
	if self.m_Texture then self.m_Texture = nil end
	return TextureReplacer.Status.SUCCESS
end

-- Cache methods
function TextureReplacer.getCached(path)
	if not TextureReplacer.Map.TEXTURE_CACHE[path] then
		local pixels = path
		if path:find(".pixels") then
			pixels = TextureReplacer.getPixels(path) -- if we dont have a pixels file use normal load
		end
		TextureReplacer.Map.TEXTURE_CACHE[path] = {
			texture = DxTexture(pixels),
			counter = 0,
			tick    = getTickCount(),
		}
	end

	TextureReplacer.Map.TEXTURE_CACHE[path].counter = TextureReplacer.Map.TEXTURE_CACHE[path].counter + 1
	return TextureReplacer.Map.TEXTURE_CACHE[path].texture
end

function TextureReplacer.removeCached(path)
	if TextureReplacer.Map.TEXTURE_CACHE[path] then
		TextureReplacer.Map.TEXTURE_CACHE[path].counter = TextureReplacer.Map.TEXTURE_CACHE[path].counter - 1
		if TextureReplacer.Map.TEXTURE_CACHE[path].counter <= 0 then
			TextureReplacer.Map.TEXTURE_CACHE[path].texture:destroy()
			TextureReplacer.Map.TEXTURE_CACHE[path] = nil
		end

		return true
	end

	return false
end

-- // Helper
function TextureReplacer.getPixels(path)
	local pixels = false
	if fileExists(path) then
		local file = fileOpen(path)
		if file then
			pixels = fileRead(file, fileGetSize(file))
			fileClose(file)
		end
	end

	return pixels
end

function TextureReplacer.addRef(instance)
	if not TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element] then
		TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element] = {}
	end
	TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element][instance.m_TextureName] = instance
end

function TextureReplacer.removeRef(instance)
	outputConsole(inspect(TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element][instance.m_TextureName]))
	TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element][instance.m_TextureName] = nil
end

function TextureReplacer.deleteFromElement(element)
	if not TextureReplacer.Map.SHARED_ELEMENTS[element] then return false end
	for i, v in pairs(TextureReplacer.Map.SHARED_ELEMENTS[element]) do
		delete(v)
	end
	TextureReplacer.Map.SHARED_ELEMENTS[element] = nil
end

--// Queue
function TextureReplacer:addToLoadingQeue()
	TextureReplacer.Queue:push_back(self)
	TextureReplacer.Queue.m_Count = (TextureReplacer.Queue.m_Count or 0) + 1
	if not TextureReplacer.Queue:locked() then
		TextureReplacer.Queue:lock()

		TextureReplacer.Queue.m_CurrentLoaded = 0
		TextureReplacer.Queue.m_ShortMessage = ShortMessage:new(_("Achtung: Custom Texturen werden geladen, dies kann einen kleinen Lag verursachen!\nStatus: 0 / 1 Textur(en)"), nil, nil, math.huge)

		self:loadNext()
	end
end

function TextureReplacer:loadNext()
	if TextureReplacer.Queue:empty() then
		TextureReplacer.Queue:unlock()

		if TextureReplacer.Queue.m_ShortMessage then
			TextureReplacer.Queue.m_Count = 0
			delete(TextureReplacer.Queue.m_ShortMessage)
		end
	else
		TextureReplacer.Queue.m_CurrentLoaded = TextureReplacer.Queue.m_CurrentLoaded + 1
		TextureReplacer.Queue.m_ShortMessage.m_Text = _("Achtung: Custom Texturen werden geladen, dies kann einen kleinen Lag verursachen!\nStatus: %d / %d Textur(en)", TextureReplacer.Queue.m_CurrentLoaded, TextureReplacer.Queue.m_Count)
		TextureReplacer.Queue.m_ShortMessage:anyChange()

		return TextureReplacer.Queue:pop_back(1):load()
	end
end