local dbCon = exports.a_mysql:getConnection()

function requestDatabaseSave(element, data)
	if element and isElement(element) and getElementType(element) == "player" then
		if data then
			local password, playerName = data[1], data[2]

			local playerAccID = getElementData(element, "a.accID")
			local query = dbQuery(dbCon, "SELECT * FROM accounts WHERE playerName = ?", playerName)
			local result = dbPoll(query, -1)
			if #result > 0 then
				triggerClientEvent("saveResponse", element, element)
			else
				local update = dbExec(dbCon, "UPDATE accounts SET playerName = ?, password = ? WHERE id = ?", tostring(playerName), base64Encode(tostring(password)), playerAccID)
				if (update) then
					setElementData(element, "a.PlayerName", tostring(playerName))
	
					local query = dbQuery(dbCon, "SELECT * FROM accounts WHERE id = ?", playerAccID)
					local result = dbPoll(query, -1)
					if #result > 0 then
						for _, v in ipairs(result) do
							triggerClientEvent("sendAccountDataToSave", element, element, {v["username"], v["password"]})
						end
					end
				end
			end
		end
	end
end
addEvent("requestDatabaseSave", true)
addEventHandler("requestDatabaseSave", root, requestDatabaseSave)

function checkForPlayerName(element)
	if element and isElement(element) and getElementType(element) == "player" then
		local playerAccID = getElementData(element, "a.accID")

		local query = dbQuery(dbCon, "SELECT * FROM accounts WHERE id = ?", playerAccID)
		local result = dbPoll(query, -1)
		if #result > 0 then
			for _, v in ipairs(result) do
				if (tostring(v["playerName"]) == "") then
					triggerClientEvent("playerNameResponse", element, element, false)
				else
					triggerClientEvent("playerNameResponse", element, element, true)				
				end
			end
		end
	end
end
addEvent("checkForPlayerName", true)
addEventHandler("checkForPlayerName", root, checkForPlayerName)