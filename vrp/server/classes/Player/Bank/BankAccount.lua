-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Player/BankManager.lua
-- *  PURPOSE:     Bank account class
-- *
-- ****************************************************************************
BankAccount = inherit(Object)
BankAccount.Map = {}

function BankAccount.create(OwnerType, OwnerId)
  sql:queryExec("INSERT INTO ??_bank_accounts(OwnerType, OwnerId, Money, CreationTime) VALUES (?, ?, 0, NOW());", sql:getPrefix(), OwnerType, OwnerId)

  local Id = sql:lastInsertId()
  BankAccount.Map[Id] = BankAccount:new(Id, 0)
  return BankAccount.Map[Id]
end

function BankAccount.load(Id)
  if BankAccount.Map[Id] then return BankAccount.Map[Id] end

  local row = sql:queryFetchSingle("SELECT OwnerType, OwnerId, Money FROM ??_bank_accounts WHERE Id = ?;", sql:getPrefix(), Id)
  if not row then
    return false
  end

  BankAccount.Map[Id] = BankAccount:new(Id, row.Money, row.OwnerType, row.OwnerId)
  return BankAccount.Map[Id]
end

function BankAccount:constructor(Id, Money, OwnerType, OwnerId)
  self.m_Id = Id
  self.m_Money = Money
  self.m_Activity = ""
  self.m_OwnerType = OwnerType
  self.m_OwnerId = OwnerId
end

function BankAccount:destructor()
  self:save()
end

function BankAccount:save()
  return sql:queryExec("UPDATE ??_bank_accounts SET Money = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_Id)
end

function BankAccount:update()
  if self.m_OwnerType == BankAccountTypes.Player then
    local player, isOffline = DatabasePlayer.getFromId(self.m_OwnerId)
    if isOffline then -- We do not require offline Players here
      player:load()
      delete(player)
    end

    if player:isActive() then
        player:setPrivateSync("BankMoney", self:getMoney())
    end
  elseif self.m_OwnerType == BankAccountTypes.Faction then
    return false
  elseif self.m_OwnerType == BankAccountTypes.Company then
    return false
  end
end

function BankAccount:getId()
  return self.m_Id
end

function BankAccount:setMoney(amount)
  self.m_Money = amount

  if self.m_OwnerType == BankAccountTypes.Company then
    CompanyManager:getSingleton():getFromId(self.m_OwnerId):sendMessage(("%s$"):format(self.m_Money))
  elseif self.m_OwnerType == BankAccountTypes.Faction then
    FactionManager:getSingleton():getFromId(self.m_OwnerId):sendMessage(("%s$"):format(self.m_Money))
  end
  self:update()
end

function BankAccount:getMoney()
  return tonumber(self.m_Money)
end

function BankAccount:addMoney(money)
  self.m_Money = self.m_Money + money

  if self.m_OwnerType == BankAccountTypes.Company then
    CompanyManager:getSingleton():getFromId(self.m_OwnerId):sendMessage(("+%s$ (%s$)"):format(money, self.m_Money))
  elseif self.m_OwnerType == BankAccountTypes.Faction then
    FactionManager:getSingleton():getFromId(self.m_OwnerId):sendMessage(("+%s$ (%s$)"):format(money, self.m_Money))
  end
  self:update()
end

function BankAccount:takeMoney(money)
  self.m_Money = self.m_Money - money

  if self.m_OwnerType == BankAccountTypes.Company then
    CompanyManager:getSingleton():getFromId(self.m_OwnerId):sendMessage(("-%s$ (%s$)"):format(money, self.m_Money))
  elseif self.m_OwnerType == BankAccountTypes.Faction then
    FactionManager:getSingleton():getFromId(self.m_OwnerId):sendMessage(("-%s$ (%s$)"):format(money, self.m_Money))
  end
  self:update()
end
