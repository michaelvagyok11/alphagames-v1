local connection = exports.dMysql:getConnection()

local datas = {} 

function requestAction(element, type, ...)
    if not element or not type or not isElement(element) then
        return
    end
    -- ** AC
    if not element or not isElement(element) or not getElementType(element) == "player" then
        return
    end
    local clientPlayer = client

    if not clientPlayer and not client == source then
        return
    end
    -- ** AC VÉGE

    if type == "login" then
        args = {...}

        local currentPlayerSerial = getPlayerSerial(element)
        local username, password = args[1], args[2]
        local query = dbQuery(connection, "SELECT * FROM accounts WHERE username = ? AND password = ? AND serial = ?", username, base64Encode(password), currentPlayerSerial)
        local result = dbPoll(query, -1)
        if #result > 0 then
            triggerClientEvent("a.ServerResponse", element, element, "loginSuccess")
        else
            triggerClientEvent("a.ServerResponse", element, element, "loginError")
        end
    end
end
addEvent("a.RequestAction", true)
addEventHandler("a.RequestAction", root, requestAction)

function attemptRegister(element, ...)
    if not element or not isElement(element) then
        return
    end
    -- ** AC
    if not element or not isElement(element) or not getElementType(element) == "player" then
        return
    end
    local clientPlayer = client

    if not clientPlayer and not client == source then
        return
    end
    -- ** AC VÉGE

    if isElement(element) then
        if ... then
            args = {...}
            args = args[1]
            local username, password, playerName, serial, ip = args[1], args[2], args[3], getPlayerSerial(element), getPlayerIP(element)
            
            local query = dbQuery(connection, "SELECT * FROM accounts WHERE serial = ?", serial)
            local result = dbPoll(query, -1)
            if (#result > 0) then
                triggerClientEvent("a.ServerResponse", element, element, "registerError.serialExists")
            else
                local query = dbQuery(connection, "SELECT * FROM accounts WHERE playerName = ?", playerName)
                local result = dbPoll(query, -1)
                if (#result > 0) then
                    triggerClientEvent("a.ServerResponse", element, element, "registerError.playerNameExists")
                else
                    local query = dbQuery(connection, "SELECT * FROM accounts WHERE username = ?", username)
                    local result = dbPoll(query, -1)
                    if (#result > 0) then
                        triggerClientEvent("a.ServerResponse", element, element, "registerError.usernameExists")
                    else
                        local dbAction = dbExec(connection, "INSERT INTO accounts SET username = ?, password = ?, serial = ?, ip = ?, playerName = ?", username, base64Encode(password), serial, ip, playerName)
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

        datas.playerName = getPlayerName(sourcePlayer)
        dbExec(connection, "UPDATE accounts SET visibleName = ? WHERE id = ?", datas.playerName, getElementData(sourcePlayer, "a.accID"))

		datas.actionBarItems = table.concat(datas["actionBarItems"], ";")
        dbExec(connection, "UPDATE accounts SET actionBarItems = ? WHERE id = ?", datas.actionBarItems, getElementData(sourcePlayer, "a.accID"))
        iprint(datas.actionBarItems)
    end
)

function successLogin(element)
    if not element or not isElement(element) then
        return
    end
    local spawnQuery = dbPoll(dbQuery(connection, "SELECT * FROM accounts WHERE serial = ?", getPlayerSerial(element)), -1)
    if #spawnQuery > 0 then
        for _, v in ipairs(spawnQuery) do
            setElementData(element, "loggedIn", true)
            spawnPlayer(element, 2103.787109375, -103.365234375, 2.2389388084412)
            setCameraTarget(element, element)
            for _, stat in ipairs({ 24, 69, 70, 71, 72, 73, 74, 76, 77, 78, 79 }) do
                setPedStat(element, stat, 1000)
            end

            toggleControl(element, "fire", false)
            toggleControl(element, "action", false)

            setPedWalkingStyle(element, 118)
            setElementData(element, "a.accID", v["id"])           
            setElementModel(element, v["skin"])

            setElementData(element, "adminLevel", v["alevel"])
            setElementData(element, "adminNick", v["visibleName"])

            setElementData(element, "a.Skin", v["skin"])
            setElementData(element, "a.HUDshowed", true)
            setElementData(element, "a.NameShowing", false)
            setPlayerBlurLevel(element, 0)

            setElementData(element, "a.Kills", v["kills"])
            setElementData(element, "a.Deaths", v["deaths"])
            setElementData(element, "a.PlayerGroup", v["playerGroup"])
            setElementData(element, "a.Experience", v["xp"])
            setElementData(element, "a.Level", v["level"])
            setElementData(element, "a.Money", v["money"])
            setElementData(element, "a.PlayedMinutes", v["playedMinutes"])
            setElementData(element, "a.Gamemode", nil)

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

            setElementData(element, "a.Premiumpont", v["pp"])
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

            dbQuery(
				function (qh)
					local result = dbPoll(qh, 0)

					if result then
                        setElementData(element, "d/VipDuration", result[1].date)
                    end
                end,
            connection, "SELECT date FROM vips WHERE accid = '" .. getElementData(element, "a.accID") .. "'")

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