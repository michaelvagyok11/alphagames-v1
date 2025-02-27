local delayTimer = {};
local connection = exports.a_mysql:getConnection()

function onStart()
    currentMap = getRandomMap()
    --outputDebugString("Elindult egy új DM kör. (" .. mapCache[currentMap]["mapName"] .. ")", 0, 140, 195, 230)

    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 1 then
            setElementData(v, "a.DMTeam", nil)
            triggerClientEvent("showTeamselectorPanel", v, v)
            toggleControl(v, "fire", true)
            toggleControl(v, "action", true)
            --setElementData(v, "a.Protected", false)
        end
    end
    triggerClientEvent("startRound", root)
    
    seconds = 240
    setTimer(countTime, 1000, seconds)
end
setTimer(onStart, 100, 1)

function onChange(key, oVal, nVal)
    if key == "a.Gamemode" then
        if nVal == 1 then
            triggerClientEvent("showTeamselectorPanel", source, source)
        elseif nVal == nil then
            setElementData(source, "a.DMTeam", nil)
            setElementData(source, "a.RespawnPosition", nil)
            triggerClientEvent("removeCounterFromScreen", source, source)
        end
    end

    if key == "a.Kills" then
        dbExec(connection, "UPDATE accounts SET kills = '" .. nVal .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end
    if key == "a.Deaths" then
        dbExec(connection, "UPDATE accounts SET deaths = '" .. nVal .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end

    if key == "a.DMTeam" then
        if nVal == "Terrorists" then
            outputChatBox("#9BE48F[DM]: #FFFFFFKiválasztott csapat: #D6B370" .. mapCache[currentMap]["mapTeamNames"][1] .. " #FFFFFF- Jelenlegi pálya: #8FC3E4" .. mapCache[currentMap]["mapName"], source, 255, 255, 255, true)
            setElementPosition(source, mapCache[currentMap]["mapRespawnPosition"][1], mapCache[currentMap]["mapRespawnPosition"][2], mapCache[currentMap]["mapRespawnPosition"][3])
            setElementData(source, "a.RespawnPosition", {mapCache[currentMap]["mapRespawnPosition"][1], mapCache[currentMap]["mapRespawnPosition"][2], mapCache[currentMap]["mapRespawnPosition"][3]})
            setElementData(source, "a.Protected", false)
        elseif nVal == "Counter-Terrorists" then
            outputChatBox("#9BE48F[DM]: #FFFFFFKiválasztott csapat: #72ABCC" .. mapCache[currentMap]["mapTeamNames"][2] .. " #FFFFFF- Jelenlegi pálya: #8FC3E4" .. mapCache[currentMap]["mapName"], source, 255, 255, 255, true)
            setElementPosition(source, mapCache[currentMap]["mapRespawnPosition"][4], mapCache[currentMap]["mapRespawnPosition"][5], mapCache[currentMap]["mapRespawnPosition"][6])
            setElementData(source, "a.RespawnPosition", {mapCache[currentMap]["mapRespawnPosition"][4], mapCache[currentMap]["mapRespawnPosition"][5], mapCache[currentMap]["mapRespawnPosition"][6]})
            setElementData(source, "a.Protected", false)
        end
    end
end
addEventHandler("onElementDataChange", root, onChange)

function attemptToJoinTeam(element, team)
    if element and isElement(element) and team then
        local count_CT = 0
        for i, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Gamemode") == 1 and getElementData(v, "a.DMTeam") == "Terrorists" then
                count_CT = count_CT + 1
            end
        end

        local count_T = 0
        for i, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Gamemode") == 1 and getElementData(v, "a.DMTeam") == "Counter-Terrorists" then
                count_T = count_T + 1
            end
        end

        if team == 1 then
            if count_CT > count_T then
                triggerClientEvent("joinResponse", element, element, "return")
                return
            elseif count_T > count_CT then
                -- sikeres csat
                triggerClientEvent("joinResponse", element, element, "success")
                setElementData(element, "a.DMTeam", "Terrorists")
            elseif count_CT == count_T then
                -- sikeres csat
                triggerClientEvent("joinResponse", element, element, "success")
                setElementData(element, "a.DMTeam", "Terrorists")
            else
                error("A rendszer nem tudta besorolni " .. getElementData(element, "a.PlayerName") .. " játékost a DM csapatokba.")
                return
            end
        elseif team == 2 then
            if count_T > count_CT then
                triggerClientEvent("joinResponse", element, element, "return")
                return
            elseif count_CT > count_T then
                -- sikeres csat
                triggerClientEvent("joinResponse", element, element, "success")
                setElementData(element, "a.DMTeam", "Counter-Terrorists")
            elseif count_CT == count_T then
                -- sikeres csat
                triggerClientEvent("joinResponse", element, element, "success")
                setElementData(element, "a.DMTeam", "Counter-Terrorists")
            else
                error("A rendszer nem tudta besorolni " .. getElementData(element, "a.PlayerName") .. " játékost a DM csapatokba.")
                return
            end
        end
    end
end
addEvent("attemptToJoinTeam", true)
addEventHandler("attemptToJoinTeam", root, attemptToJoinTeam)


function onKillSomebody(ammo, killer, weapon, bodypart, stealth)
    if ammo and killer and weapon then
        if killer == source then return end
        if bodypart == 9 then
            bonus = math.random(75, 125)
        else
            bonus = math.random(25, 75)
        end

        local isPlayerVIP = getElementData(killer, "a.VIP")

        -- bonus = bonus * 2 --**EVENT

        if (isPlayerVIP) then
            bonus = bonus * 2
            outputChatBox("#E48F8F[Ölés]: #FFFFFFMegölted #8FC3E4" .. getElementData(source, "a.PlayerName") .. "#ffffff játékost. #9BE48F(" .. bonus .. "#FFFFFF$ - #C4CD5D2x#9BE48F)", killer, 255, 255, 255, true)
        else
            outputChatBox("#E48F8F[Ölés]: #FFFFFFMegölted #8FC3E4" .. getElementData(source, "a.PlayerName") .. "#ffffff játékost. #9BE48F(" .. bonus .. "#FFFFFF$)", killer, 255, 255, 255, true)
        end

        local clanID = getElementData(killer, "a.PlayerGroup")
        if clanID and clanID > 0 then
            bonus = bonus * 1.5
            outputChatBox("#E48F8F[Ölés]: #FFFFFFKlán szorzó: 1.5x.", killer, 255, 255, 255, true)
        end

        setElementData(killer, "a.Kills", getElementData(killer, "a.Kills")+1)
        setElementData(source, "a.Deaths", getElementData(source, "a.Deaths")+1)
        --outputChatBox("#E48F8F[Death]: #FFFFFFYou have killed #8FC3E4" .. getPlayerName(source) .. "#ffffff. You got #9BE48F" .. bonus .. "#FFFFFF$.", killer, 255, 255, 255, true)
        exports.a_interface:giveExperience(killer, source)
        setElementData(killer, "a.Money", getElementData(killer, "a.Money") + bonus)

        if getElementData(killer, "a.DMTeam") == "Terrorists" then
            triggerClientEvent("givePointToTeam", root, 1)
        elseif getElementData(killer, "a.DMTeam") == "Counter-Terrorists" then
            triggerClientEvent("givePointToTeam", root, 2)
        end

        local szinkodt = "#D6B370"
        local szinkodct = "#72ABCC"

        local szinkodk = getElementData(killer, "szinkod")
        local szinkods = getElementData(source, "szinkod")

        if getElementData(killer, "a.DMTeam") == "Terrorists" then
            setElementData(killer, "szinkod", szinkodt)
        elseif getElementData(killer, "a.DMTeam") == "Counter-Terrorists" then
            setElementData(killer, "szinkod", szinkodct)
        elseif getElementData(source, "a.DMTeam") == "Terrorists" then
            setElementData(source, "szinkod", szinkodt)
        elseif getElementData(source, "a.DMTeam") == "Counter-Terrorists" then
            setElementData(source, "szinkod", szinkodct)
        end


        triggerClientEvent("addToKillFeed", root, killer, source, weapon)

        exports.a_logs:createDCLog(getElementData(killer, "a.PlayerName") .. " megölte " .. getElementData(source, "a.PlayerName") .. "-t - (fegyver: " .. getWeaponNameFromID(weapon) .. ")", 5)

        local chance = math.random(1, 100)
        if chance > 1 and chance < 69 then
            return
        elseif chance > 70 and chance < 89 and getElementData(killer, "a.VIP") == true then
            outputChatBox("#e48f8f[Halloween Event]:#ffffff Mivel VIP vagy, ezért az ölésedért cserébe nagyobb eséllyel kaptál egy #e48f8fTököt#ffffff! Inventorydban megtalálod.", killer, 255, 255, 255, true)
            exports.a_inventory:giveItem(killer, 62, 1, false, false, false, false, "alphagames.net", false)
        elseif chance > 90 and chance < 100 and getElementData(killer, "a.VIP") == false then
            outputChatBox("#e48f8f[Halloween Event]:#ffffff Ölésért cserébe kaptál egy #e48f8fTököt#ffffff! Inventorydban megtalálod.", killer, 255, 255, 255, true)
            exports.a_inventory:giveItem(killer, 62, 1, false, false, false, false, "alphagames.net", false)
        end

        --[[if getElementData(killer, "a.Gamemode") == nil then
            kickPlayer(killer, "nem szabad lobbyban olni :D")
            iprint(getPlayerName(killer) .. " ölt lobbyban")
        end]]

        makeProtection(source, 5)
    end
end
addEventHandler("onPlayerWasted", root, onKillSomebody)

function countTime()
    if seconds - 1 < 1 then
        onStart()
    else
        seconds = seconds - 1
        triggerClientEvent("sendSeconds", root, seconds)
    end
end

function makeProtection(element, time)
    setElementData(element, "a.Protected", true)
    delayTimer[element] = setTimer(function()
        setElementData(element, "a.Protected", false)
    end, time*1000, 1)
end

function onFire()
    if getElementData(source, "a.Protected") then
        setElementData(source, "a.Protected", false)
        if isTimer(delayTimer[source]) then
            killTimer(delayTimer[source]) 
        end
    end
end
addEventHandler("onPlayerWeaponFire", root, onFire)

--[[function setMap(sourcePlayer, commandName, targetMapID)
    if getElementData(sourcePlayer, "adminLevel") >= 3 then
        if not targetMapID then
            outputChatBox(usageSyntax .. "/" .. commandName .. " [MapID]", sourcePlayer, 255, 255, 255, true)
            outputChatBox("1: Fallen Tree | 2: LS gyár | 3: LS Trains | 4: Willowfield | 5: LV Factory\n6: LV Docks | 7: LSPD | 8: SF Lakótelep | 9: LV Underground | 10: LV Lakótelep\n11: AWP India", sourcePlayer, 255, 255, 255, true)
            return
        end

        targetMapID = tonumber(targetMapID)
        currentMap = targetMapID
        setTargetMap(targetMapID)
        --triggerClientEvent("startRound", root)
        outputChatBox("#B4D95A► Siker: #FFFFFFSikeresen megváltoztattad a mapot a következőre: " .. mapCache[currentMap]["mapName"] .. ".", sourcePlayer, 255, 255, 255, true)
        outputAdminMessage("#8FC3E4"..getPlayerName(sourcePlayer).."#FFFFFF megváltoztatta a TDMA mapot a következőre: " .. mapCache[currentMap]["mapName"] .. ".")
        for i, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Gamemode") == 1 then
                outputChatBox("#5AB1D9► Info: #FFFFFF Egy admin megváltoztatta a mapot. Új map: " .. mapCache[currentMap]["mapName"] .. ".", v, 255, 255, 255, true)
                triggerClientEvent("startRound", root)
            end
        end
    end
end
addCommandHandler("changemap", setMap)]]