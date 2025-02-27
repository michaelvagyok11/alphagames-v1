local connection = exports.a_mysql:getConnection()

local datas = {}

function requestAction(element, type, ...)
    if not element or not type or not isElement(element) then
        return
    end

    if type == "login" then
        args = {...}
        local username, password = args[1], args[2]
        local query = dbQuery(connection, "SELECT * FROM accounts WHERE username = ? AND password = ?", username, base64Encode(password))
        -- ** BUGFIX, NEM ZÁRTA LE A KAPCSOLATOT
        local result = dbPoll(query, -1)
        if #result > 0 then
            checkCloneAccounts(element, username, password)
            triggerClientEvent("a.ServerResponse", element, element, "loginSuccess")
        else
            triggerClientEvent("a.ServerResponse", element, element, "loginError")
        end
    end
end
addEvent("a.RequestAction", true)
addEventHandler("a.RequestAction", root, requestAction)

function checkCloneAccounts(element, username, password)
    if element and isElement(element) and username and password then
        local elementSerial = getPlayerSerial(element);
        if elementSerial then
            local un, pw = tostring(username), tostring(base64Encode(password))
            local query = dbQuery(connection, "SELECT * FROM accounts WHERE serial = ?", elementSerial)
            local result = dbPoll(query, -1)
            if #result == 1 then
                -- ** A rendszer nem talált klón felhasználót.
            else
                for _, v in ipairs(result) do
                    if not (v["username"] == un and v["password"] == pw) then
                        -- ** A régi klón fiókok törlésre kerülnek.
                        dbExec(connection, "DELETE FROM accounts WHERE username = ? AND password = ?", v["username"], v["password"])
                        exports.a_logs:createDCLog("DELETED ONE ACCOUNT WITH USERNAME: **" .. v["username"] .. "** - PASSWORD: **" .. v["password"] .. "** - AT SERIAL: **" .. v["serial"] .. "**", 7)
                    end
                end
            end
        end
    end
end

function attemptRegister(element, ...)
    if not element or not isElement(element) then
        return
    end
    if isElement(element) then
        if ... then
            args = {...}
            args = args[1]
            local username, password, visibleName, serial, ip = args[1], args[2], args[3], getPlayerSerial(element), getPlayerIP(element)
            
            local query = dbQuery(connection, "SELECT * FROM accounts WHERE serial = ?", serial)
            local result = dbPoll(query, -1)
            if (#result > 0) then
                triggerClientEvent("a.ServerResponse", element, element, "registerError.serialExists")
            else
                local query = dbQuery(connection, "SELECT * FROM accounts WHERE username = ?", username)
                local result = dbPoll(query, -1)
                if (#result > 0) then
                    triggerClientEvent("a.ServerResponse", element, element, "registerError.usernameExists")
                else
                    local query = dbQuery(connection, "SELECT * FROM accounts WHERE playerName = ?", visibleName)
                    local result = dbPoll(query, -1)
                    if (#result > 0) then
                        triggerClientEvent("a.ServerResponse", element, element, "registerError.nameExists")
                    else
                        local dbAction = dbExec(connection, "INSERT INTO accounts SET username = ?, password = ?, serial = ?, ip = ?, playerName = ?", username, base64Encode(password), serial, ip, visibleName)
                        if (dbAction) then
                            triggerClientEvent("a.ServerResponse", element, element, "registerSuccess")
                        end
                    end
                end
            end
        end
    end
end
addEvent("attemptRegister", true)
addEventHandler("attemptRegister", root, attemptRegister)

addEventHandler("onPlayerQuit", getRootElement(),
    function ()
		-- ** Actionbar itemek

        sourcePlayer = source

		local actionBarItemsTable = getElementData(sourcePlayer, "actionBarItems") or {}
	    datas.actionBarItems = {}

		for i = 1, 6 do
			if actionBarItemsTable[i] then
				table.insert(datas["actionBarItems"], tostring(actionBarItemsTable[i]))
			else
				table.insert(datas["actionBarItems"], "-")
			end
		end

        datas.premiumPoints = getElementData(sourcePlayer, "a.Premiumpont")
        dbExec(connection, "UPDATE accounts SET pp = ? WHERE id = ?", datas.premiumPoints, getElementData(sourcePlayer, "a.accID"))

        -- :))))))))))
        datas.dutchyhook = getElementData(sourcePlayer, "dutchyhook")
        dbExec(connection, "UPDATE accounts SET dutchyhook = ? WHERE id = ?", datas.dutchyhook, getElementData(sourcePlayer, "a.accID"))

        -- ** Kilépésnél visibleName mentés ** --

        datas.playerName = getPlayerName(sourcePlayer)
        dbExec(connection, "UPDATE accounts SET visibleName = ? WHERE id = ?", datas.playerName, getElementData(sourcePlayer, "a.accID"))

		datas.actionBarItems = table.concat(datas["actionBarItems"], ";")
        dbExec(connection, "UPDATE accounts SET actionBarItems = ? WHERE id = ?", datas.actionBarItems, getElementData(sourcePlayer, "a.accID"))
        iprint(datas.actionBarItems)
    end
)

function onJoin()
    dbExec(connection, "DELETE FROM bans WHERE date<NOW()")
    dbExec(connection, "DELETE FROM vips WHERE date<NOW()")
end
addEventHandler("onResourceStart", getRootElement(), onJoin)

function successLogin(element)
    if not element or not isElement(element) then
        return
    end
    local spawnQuery = dbPoll(dbQuery(connection, "SELECT * FROM accounts WHERE serial = ?", getPlayerSerial(element)), -1)
    if #spawnQuery > 0 then
        for _, v in ipairs(spawnQuery) do
            setElementData(element, "loggedIn", true)
            spawnPlayer(element, 260.6982421875, 1816.28125, 4.7031307220459)
            
            for _, stat in ipairs({ 24, 69, 70, 71, 72, 73, 74, 76, 77, 78, 79 }) do
                setPedStat(element, stat, 1000)
            end

            setPedWalkingStyle(element, 118)
            setElementData(element, "a.accID", v["id"])           
            setElementModel(element, v["skin"])

            setElementData(element, "adminLevel", v["alevel"])
            setElementData(element, "adminNick", v["visibleName"])
            setElementData(element, "a.Premiumpont", v["pp"])

            setElementData(element, "visibleName", v["visibleName"])
            setElementData(element, "a.PlayerName", v["playerName"])
            setElementData(element, "a.PlayerGroup", v["playerGroup"])
            setElementData(element, "a.PlayerGroupLeader", v["playerLeaderInGroup"])

            setElementData(element, "a.Skin", v["skin"])
            setElementData(element, "a.HUDshowed", true)
            setElementData(element, "a.NameShowing", false)
            setElementData(element, "isInLobby", true)
            setPlayerBlurLevel(element, 0)

            setElementData(element, "a.eventKills", v["eventKills"])

            setElementData(element, "a.Kills", v["kills"])
            setElementData(element, "a.Deaths", v["deaths"])
            setElementData(element, "a.elementGroup", v["elementGroup"])
            setElementData(element, "a.Experience", v["xp"])
            setElementData(element, "a.Level", v["level"])
            setElementData(element, "a.Money", v["money"])
            setElementData(element, "a.PlayedMinutes", v["playedMinutes"])
            setElementData(element, "a.Gamemode", nil)
            setElementData(element, "dutchyhook", v["dutchyhook"])

            datas.playerName = getPlayerName(element)
            dbExec(connection, "UPDATE accounts SET visibleName = ? WHERE id = ?", datas.playerName, getElementData(element, "a.accID"))

            if tonumber(v["vip"]) == 1 then
                setElementData(element, "a.VIP", true)
            else
                setElementData(element, "a.VIP", false)
            end

            if v.actionBarItems and utfLen(v.actionBarItems) > 0 then
                iprint(v.actionBarItems)
                local items = split(v.actionBarItems, ";")
                local temp = {}

                for i = 1, 6 do
                    if items[i] then
                        temp[i] = tonumber(items[i])
                    else
                        temp[i] = false
                    end
                end

                setElementData(element, "actionBarItems", temp)
            end

            setElementData(element, "a.Dueloffered", false)
            setElementData(element, "a.Crosshair", v["crosshair"])
            setElementData(element, "a.totalDrift", v["totalDrift"])
            setElementData(element, "a.lastDrift", 0)
            setElementData(element, "a.bestDrift", v["bestDrift"])
            if tonumber(v["muted"]) == 1 then
                setElementData(element, "a.Muted", true)
                setElementData(element, "a.Mutetime", v["mutetime"])
            else
                setElementData(element, "a.Muted", false)
            end

            local vehTable = fromJSON(v["unlockedVehs"]) or {}
            setElementData(element, "a.BoughtVehs", vehTable)


            dbQuery(function(handler)
                local result = dbPoll(handler, 0)
                if #result == 0 then
                    setElementData(element, "a.VIP", false)
                end
            end, connection, "SELECT * FROM vips WHERE accid = '" .. getElementData(element, "a.accID") .. "'")

            local hpVehTable = fromJSON(v["hpVeh"]) or {596, 445}
            setElementData(element, "a.HPVehicle", hpVehTable)

            local hpSkinTable = fromJSON(v["hpSkin"]) or {51, 55}
            setElementData(element, "a.HPSkin", hpSkinTable)

            local hpBoughtVehs = fromJSON(v["hpBoughtVehs"]) or {596, 445}
            setElementData(element, "a.HPBoughtVehs", hpBoughtVehs)

            setElementData(element, "a.GuardLevel", v["guardLevel"])
        end
    end
end
addEvent("a.LoginSuccess", true)
addEventHandler("a.LoginSuccess", root, successLogin)