SQL = inherit(Object)

function SQL:virtual_constructor()
	self.m_Async = true
end

function SQL:destructor()
	destroyElement(self.m_DBHandle)
end

function SQL:queryExec(query, ...)
	return dbExec(self.m_DBHandle, query, ...)
end

-- The prefix is to be used in all table names
-- Use ??_$tablename in SQL Statements
function SQL:getPrefix()
	return self.m_Prefix
end

function SQL:setPrefix(prefix)
	self.m_Prefix = prefix
end

-- Overloaded Function
-- Possible Signatures:
-- SQL:queryFetch(function callback, string query, ...) [[ asyncronous processing ]]
-- SQL:queryFetch(query, ...) [[ waits ]]
function SQL:queryFetch(...)
	local args = {...}
	if type(args[1]) == "string" then
		return self.dbPoll(dbQuery(self.m_DBHandle, ...), -1)
	else
		local query = args[2]
		local callback = args[1]

		-- Remove query and the callback from args
		table.remove(args, 1)
		table.remove(args, 1) -- 1 is correct here as after removing callback, query will be at position 1

		dbQuery(
			function(qh)
				local callbackArgs = { self.dbPoll(qh, -1) }
				callback(unpack(callbackArgs))
			end,
			self.m_DBHandle,
			query,
			unpack(args)
		)
	end
end

-- Overloaded Function
-- Possible Signatures:
-- SQL:queryFetchSingle(function callback, string query, ...) [[ asyncronous processing ]]
-- SQL:queryFetchSingle(query, ...) [[ waits ]]
function SQL:queryFetchSingle(...)
	local args = {...}
	if type(args[1]) == "string" then
		return self.dbPoll(dbQuery(self.m_DBHandle, ...), -1)[1]
	else
		local query = args[2]
		local callback = args[1]

		-- Remove query and the callback from args
		table.remove(args, 1)
		table.remove(args, 1) -- 1 is correct here as after removing callback, query will be at position 1

		dbQuery(
			function(qh)
				local callbackArgs = { self.dbPoll(qh, -1)[1] }
				callback(unpack(callbackArgs))
			end,
			self.m_DBHandle,
			query,
			unpack(args)
		)
	end
end

function SQL:asyncQueryFetch(...)
	if self.m_Async then
		self:queryFetch(Async.waitFor(), ...)
		return Async.wait()
	else
		return self:queryFetch(...)
	end
end

function SQL:asyncQueryFetchSingle(...)
	if self.m_Async then
		self:queryFetchSingle(Async.waitFor(), ...)
		return Async.wait()
	else
		return self:queryFetchSingle(...)
	end
end

function SQL:setAsyncEnabled(enabled)
	self.m_Async = enabled
end

function SQL:promiseQueryFetch(...)
	if self.m_UsePromise then
		local args = {...} -- cause inside the promise we're in a new function (so we cant use ...)
		return Promise:new(function (fullfill, reject)
			sql:queryFetch(function (result, num_affected_rows, last_insert_id)
				if result ~= false then
					fullfill(result, num_affected_rows, last_insert_id)
				else
					reject(num_affected_rows, last_insert_id)
				end
			end, unpack(args))
		end)
	else
		return self:queryFetch(...)
	end
end

function SQL:promiseQueryFetchSingle(...)
	if self.m_UsePromise then
		local args = {...} -- cause inside the promise we're in a new function (so we cant use ...)
		return Promise:new(function (fullfill, reject)
			sql:queryFetchSingle(function (result, num_affected_rows, last_insert_id)
				if result ~= false then
					fullfill(result, num_affected_rows, last_insert_id)
				else
					reject(num_affected_rows, last_insert_id)
				end
			end, unpack(args))
		end)
	else
		return self:queryFetch(...)
	end
end

function SQL:setPromisesEnabled(enabled)
	self.m_UsePromise = enabled
end





function SQL:testPromiseQuery()
	sql:setPromisesEnabled(true)

	sql:promiseQueryFetchSingle("SELECT Id FROM ??_account WHERE Name = '[eXo]StiviK';", sql:getPrefix()).next(
		function(result)
			return sql:queryFetchSingle("SELECT GroupId FROM ??_character WHERE Id = ?", sql:getPrefix(), result.Id) -- not handled by .done(onRejected)
		end
	).next(
		function(result2)
			return sql:queryFetchSingle("SELECT Name FROM ??_groups WHERE Id = ?;", sql:getPrefix(), result2.GroupId) -- not handled by .done(onRejected)
		end
	).done(
		function(fin_result)
			outputTable(fin_result)
		end,
		function ()
			outputDebug("first Query failed!")
		end
	)
end

-- The following method have to be implemented according to the underlying database type
SQL.dbPoll 			= pure_virtual
SQL.lastInsertId 	= pure_virtual
SQL.constructor 	= pure_virtual
