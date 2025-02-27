local connection = exports.a_mysql:getConnection()

function callServerInformations(element)
	if getElementData(element, "a.PlayerGroup") then
		local dbq = dbQuery( connection, "SELECT * FROM groups WHERE id=?", getElementData(element, "a.PlayerGroup"))
		local result = dbPoll(dbq, -1)
		if (#result > 0) then
			for k, v in ipairs(result) do
				groupname = v["groupName"]
				leaderaccid = v["groupMainLeader"]
				createdate = v["createDate"]
				syntax = v["groupSyntax"]
				hex = v["groupHex"]
				gid = v["id"]
			end
		end
		
		local dbq = dbQuery( connection, "SELECT * FROM accounts WHERE id=?", leaderaccid)
		local result = dbPoll(dbq, -1)
		if (#result > 0) then
			for k, v in ipairs(result) do
				leadername = v["playerName"]
			end
		end

		local members = {}
		local dbq = dbQuery(connection, "SELECT * FROM groupMembers WHERE groupid=?", getElementData(element, "a.PlayerGroup"))
		local result = dbPoll(dbq, -1)
		if (#result > 0) then
			for k, v in ipairs(result) do
				local dbq = dbQuery(connection, "SELECT * FROM accounts WHERE id =? ", v["accid"])
				local result = dbPoll(dbq, -1)
				if (#result > 0) then
					for k, v in ipairs(result) do
						table.insert(members, {v["playerName"], v["id"], v["kills"], v["deaths"]})
					end
				end
			end
		end

		triggerClientEvent(element, "sendInformation", element, "groups", {groupname, leadername, createdate, syntax, hex, gid}, members)
	end
end
addEvent("callServerInformations", true)
addEventHandler("callServerInformations", root, callServerInformations)

function kickPlayerFromGroup(element, targetaccid, name)
	if isElement(element) and tonumber(targetaccid) then
		db = dbExec(connection, "DELETE FROM groupMembers WHERE accid=?", tonumber(targetaccid))
		local targetPlayer = exports.a_core:findPlayer(element, name)
		if (targetPlayer) then
			setElementData(targetPlayer, "a.PlayerGroup", 0)
		end
	end
end
addEvent("kickPlayerFromGroup", true)
addEventHandler("kickPlayerFromGroup", root, kickPlayerFromGroup)

function addPlayerToGroup(element, target)
	if isElement(element) and isElement(target) then
		db = dbExec(connection, "INSERT INTO groupMembers SET name=?, accid=?, groupid=?", getElementData(target, "a.PlayerName"), getElementData(target, "a.accID"), getElementData(element, "a.PlayerGroup"))
		setElementData(target, "a.PlayerGroup", getElementData(element, "a.PlayerGroup"))
		dbExec(connection, "UPDATE accounts WHERE id = ? SET playerGroup = ?", getElementData(element, "a.accID"), getElementData(element, "a.PlayerGroup"))
	end
end
addEvent("addPlayerToGroup", true)
addEventHandler("addPlayerToGroup", root, addPlayerToGroup)

function requestServersideSave(element, argument, ...)
	if isElement(element) and argument then
		local serial = getPlayerSerial(element)
		if argument == "resetstat" then
			setElementData(element, "a.Deaths", 0)
			setElementData(element, "a.Kills", 0)
			dbExec(connection, "UPDATE accounts SET kills = 0 WHERE serial='" .. serial .. "'")
			dbExec(connection, "UPDATE accounts SET deaths = 0 WHERE serial='" .. serial .. "'")
		elseif argument == "crosshair" then
			id = tonumber(...)
			setElementData(element, "a.Crosshair", id)
			dbExec(connection, "UPDATE accounts SET crosshair = " .. id .. " WHERE serial = '" .. serial .. "'")
		elseif argument == "createclan" then
			args = {...}
			local query = dbQuery(connection, "SELECT * FROM groups WHERE groupName=?", args[1])
			local result = dbPoll(query, -1)
			if (#result > 0) then
				outputChatBox("#E48F8F[error]: #FFFFFFVan már ezzel a névvel egy klán létrehozva.", element, 255, 255, 255, true)
				return
			else
				local query = dbQuery(connection, "SELECT * FROM groups WHERE groupSyntax=?", args[2])
				local result = dbPoll(query, -1)
				if (#result > 0) then
					outputChatBox("#E48F8F[error]: #FFFFFFVan már ezzel a syntax-al egy klán létrehozva.", element, 255, 255, 255, true)
					return
				else
					setElementData(element, "a.Money", getElementData(element, "a.Money") - 100000)
					db = dbExec(connection, "INSERT INTO groups SET groupName = ?, groupMainLeader = ?, groupSyntax = ?, groupHex = ?, createDate = NOW()", args[1], getElementData(element, "a.accID"), args[2], args[3])
					if (db) then
						setElementData(element, "a.PlayerGroup", tonumber(getLastGroupID()))
						setElementData(element, "a.PlayerGroupLeader", tonumber(getLastGroupID()))
						dbExec(connection, "UPDATE accounts SET playerGroup = ? WHERE serial = '"..serial.."'", tonumber(getElementData(element, "a.PlayerGroup")))
						dbExec(connection, "UPDATE accounts SET playerLeaderInGroup = ? WHERE serial = '"..serial.."'", tonumber(getElementData(element, "a.PlayerGroupLeader")))
						dbExec(connection, "INSERT INTO groupMembers SET name = ?, accid = ?, groupid = ?", getElementData(element, "a.PlayerName"), getElementData(element, "a.accID"), getElementData(element, "a.PlayerGroup"))
					end
				end
			end
		end
	end
end
addEvent("requestServersideSave", true)
addEventHandler("requestServersideSave", root, requestServersideSave)

function getLastGroupID()
	local dbq = dbQuery( connection, "SELECT * FROM groups ORDER BY `id` DESC" )
	local result = dbPoll(dbq, -1)
	if (#result>0) then
		for _, row in ipairs ( result ) do
			id = tonumber(row["id"])
            return id
		end
	end
end

function checkForSameGroupName(groupNameToCheck)
	local dbq = dbQuery( connection, "SELECT groupName FROM groups" )
	local result = dbPoll(dbq, -1)
	local isTheSame = 0
	if (#result>0) then
		for _, row in ipairs ( result ) do
			groupName = tostring(row["groupName"])
			if groupName == groupNameToCheck then
				isTheSame = isTheSame + 1
			end
		end
	end
	if isTheSame > 0 then
		return true
	else
		return false
	end
end

function doesGroupExist(groupID)
	local dbq = dbQuery( connection, "SELECT * FROM groups WHERE id=?", groupID)
	local result = dbPoll(dbq, -1)
	if (#result>0) then
		for _, row in ipairs ( result ) do
			return true
		end
	else
		return false
	end
end

function isPlayerInGroup(player, groupID)
	if tonumber(getElementData(player, "a.PlayerGroup")) == tonumber(groupID) then
		return true
	else
		return false
	end
end

function onChange(key, oVal, nVal)
	if key == "a.PlayerGroup" and nVal > 0 then
		local query = dbQuery(connection, "SELECT * FROM groups WHERE id = ?", nVal)
		local result = dbPoll(query, -1)
		if (#result > 0) then
			for _, row in ipairs(result) do
				setElementData(source, "a.ClanSyntax", row["groupSyntax"])
				setElementData(source, "a.ClanHex", row["groupHex"])
			end
		end
	end
end
addEventHandler("onElementDataChange", root, onChange)