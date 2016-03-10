-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/KeyBindingsGUI.lua
-- *  PURPOSE:     KeyBindings GUI class
-- *
-- ****************************************************************************
KeyBindings = inherit(GUIForm)
inherit(Singleton, KeyBindings)

function KeyBindings:constructor()
  GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

  self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Tastenzuordnungen ändern", true, true, self)
  self.m_BackButton = GUILabel:new(self.m_Width-58, 0, 30, 28, "[←]", self):setFont(VRPFont(35))
  self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end
  self.m_KeyGridList = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.07, self.m_Width*0.39, self.m_Height*0.8, self)
  self.m_KeyGridList:addColumn(_"Name", 0.6)
  self.m_KeyGridList:addColumn(_"Taste", 0.4)
  self:loadGridList()

  GUILabel:new(self.m_Width*0.45, self.m_Height*0.07, self.m_Width*0.55, self.m_Height*0.08, _"Tastenzuordnungen", self.m_Window)
  GUILabel:new(self.m_Width*0.45, self.m_Height*0.15, self.m_Width*0.55, self.m_Height*0.05, _"Hier kannst du deine Tastenzuordnungen ändern. Klicke einfach die gewünschte Funktion links an.\nMit Klick auf den blauen Button kannst du die Zuordnung ändern.", self.m_Window):setMultiline(true)
  self.m_SelectedLabel = GUILabel:new(self.m_Width*0.45, self.m_Height*0.35, self.m_Width*0.35, self.m_Height*0.07, " ", self.m_Window):setVisible(false)
  self.m_SelectedButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.42, self.m_Width*0.35, self.m_Height*0.07, " ", self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2):setVisible(false)
  self.m_SelectedButton.onLeftClick = function () self:waitForKey() end
  self.m_DefaultButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.5, self.m_Width*0.35, self.m_Height*0.07, " ", self.m_Window):setBackgroundColor(Color.Red):setFontSize(1.2):setVisible(false)
  self.m_DefaultButton.onLeftClick =
  function ()
      local item = self.m_KeyGridList:getSelectedItem()
      self:changeKey(item.index, self.ms_Keys[item.index]["defaultKey"])
   end

  self.m_onKeyBind = bind(self.onKeyPressed, self)
end

function KeyBindings:loadGridList()
    self.m_KeyGridList:clear()
    self.ms_Keys = KeyBinds:getSingleton():getBindsList()
    local currKey
    for index, key in pairs(self.ms_Keys) do
        local currKey = core:get("KeyBindings", index) or key["defaultKey"]
        item = self.m_KeyGridList:addItem(key.name, currKey:upper())
        item.index = index
        item.onLeftClick = function() self:onKeySelect(index) end
    end
end

function KeyBindings:onKeySelect(key)
    self.m_SelectedLabel:setVisible(true)
    self.m_SelectedButton:setVisible(true)
    self.m_DefaultButton:setVisible(true)
    self.m_SelectedLabel:setText(self.ms_Keys[key].name)
    self.m_DefaultButton:setText(_("Standard verwenden (%s)", self.ms_Keys[key]["defaultKey"]:upper()))
    local currKey = core:get("KeyBindings", key) or self.ms_Keys[key]["defaultKey"]
    self.m_SelectedButton:setText(currKey:upper())
end

function KeyBindings:waitForKey ()
    self.m_SelectedButton:setText("...")
    addEventHandler("onClientKey", root, self.m_onKeyBind)
end

function KeyBindings:onKeyPressed(key, press)
    if press == false then
        local item = self.m_KeyGridList:getSelectedItem()
        self:changeKey(item.index, key)
        removeEventHandler("onClientKey", root, self.m_onKeyBind)
    end
end

function KeyBindings:changeKey (keyName, newKey)
  if newKey == "" or newKey == " " then return end
  if not self.ms_Keys[keyName] then return end

  KeyBinds:getSingleton():changeKey(keyName, newKey)
  self.m_SelectedButton:setText(newKey:upper())
  self:loadGridList()
  -- Todo: for bindings updates without a reconnect, we need a bindins class
end
