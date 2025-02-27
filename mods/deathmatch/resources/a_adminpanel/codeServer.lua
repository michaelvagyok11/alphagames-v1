local connection = exports.a_mysql:getConnection()

function onJoin()
	dbExec(connection, "UPDATE accounts SET visibleName = ? WHERE serial = ?", removeHex(getPlayerName(source), 6), getPlayerSerial(source))
end
addEventHandler("onPlayerJoin", root, onJoin)

function onQuit()
	dbExec(connection, "UPDATE accounts SET visibleName = ? WHERE serial = ?", removeHex(getPlayerName(source), 6), getPlayerSerial(source))
end
addEventHandler("onPlayerQuit", root, onQuit)

function requestAccountData(e)
	local query = dbQuery(connection, "SELECT * FROM accounts")
	local result = dbPoll(query, -1)
	local accountData = {}
	for k, v in ipairs(result) do
		if v["visibleName"] == nil then
			visibleName = v["username"]
		else
			visibleName = v["visibleName"]
		end
		table.insert(accountData, {k, v["username"], v["serial"], v["alevel"], v["anick"], v["skin"], v["kills"], v["deaths"], v["playerGroup"], v["xp"], v["money"], v["vip"], v["pp"], v["mutetime"], visibleName})
	end
	triggerClientEvent("sendAccountData", e, e, accountData)
end
addEvent("requestAccountData", true)
addEventHandler("requestAccountData", root, requestAccountData)

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end