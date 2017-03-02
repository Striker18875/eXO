-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/MultiAccount.lua
-- *  PURPOSE:     MultiAccount class
-- *
-- ****************************************************************************
local MAX_MULTIACCOUNTS = 2
MultiAccount = {}

function MultiAccount.addSerial(Id, serial)
	local row = sql:queryFetchSingle("SELECT ID FROM ??_account_to_serial WHERE PlayerId = ? AND Serial = ?;", sql:getPrefix(), Id, serial)
	if not row then
		sql:queryExec("INSERT INTO ??_account_to_serial (PlayerId, Serial) VALUES (?, ?);", sql:getPrefix(), Id, serial)
	end
end

function MultiAccount.isSerialUsed(serial)
	local row = sql:queryFetchSingle("SELECT PlayerId FROM ??_account_to_serial WHERE Serial = ?;", sql:getPrefix(), serial)
	return row and row.PlayerId or false
end

function MultiAccount.getSerialsById(Id)
	return sql:queryFetch("SELECT Serial FROM ??_account_to_serial WHERE PlayerId = ?;", sql:getPrefix(), Id)
end

function MultiAccount.getAccountsBySerial(serial)
	return sql:queryFetch("SELECT PlayerId FROM ??_account_to_serial WHERE Serial = ?;", sql:getPrefix(), serial)
end

function MultiAccount.getLinkedAccountsForSerial(serial)
	local row = sql:queryFetchSingle("SELECT LinkedTo FROM ??_account_multiaccount WHERE Serial = ?;", sql:getPrefix(), serial)
	if row and row.LinkedTo then
		return fromJSON(row.LinkedTo)
	end
end

function MultiAccount.isAccountLinkedToSerial(Id, serial)
	local linkedAccounts = MultiAccount.getLinkedAccountsForSerial(serial)
	if linkedAccounts then
		for _, playerId in pairs(linkedAccounts) do
			if playerId == Id then
				return true
			end
		end
	end
	return false
end

function MultiAccount.allowedToCreateAnMultiAccount(serial)
	local row = sql:queryFetchSingle("SELECT allowCreate FROM ??_account_multiaccount WHERE Serial = ?;", sql:getPrefix(), serial)

	if toboolean(row.allowCreate) then
		local linkedAccounts = MultiAccount.getLinkedAccountsForSerial(serial)
		if linkedAccounts and #linkedAccounts >= MAX_MULTIACCOUNTS then
			return false
		end

		return true
	end
end

function MultiAccount.linkAccountToSerial(Id, serial)
end


--
function MultiAccount.performCheck(Id, serial)
end
