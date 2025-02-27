local connection = exports.dMysql:getConnection();

function changePlayerName(element, name)
    if element and isElement(element) and name then
        setElementData(element, "a.PlayerName", tostring(name))
        dbExec(connection, "UPDATE accounts SET playerName = ? WHERE id = ?", tostring(name), getElementData(element, "a.accID"))
    end
end
addEvent("changePlayerName", true)
addEventHandler("changePlayerName", root, changePlayerName)

function onLogin(key, oVal, nVal)
    if key == "loggedIn" and nVal == true then
        local query = dbQuery(connection, "SELECT * FROM accounts WHERE serial = ?", getPlayerSerial(source))
        local result = dbPoll(query, -1)
        if (#result) > 0 then
            for _, row in ipairs(result) do 
                if tostring(row["playerName"]) == "" then
                    setElementData(source, "a.PlayerName", tostring("Játékos " .. getElementData(source, "playerid")))
                    triggerClientEvent("showNamePanel", source, source, source)
                else
                    setElementData(source, "a.PlayerName", row["playerName"])
                end
            end
        end
    end
end
addEventHandler("onElementDataChange", root, onLogin)
