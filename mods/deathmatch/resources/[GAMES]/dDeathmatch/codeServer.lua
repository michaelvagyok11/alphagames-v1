addEvent("a_RequestSessions", true)

local delayTimer = {};
local connection = exports.dMysql:getConnection()

function onStart()
    generateSessions()
    triggerClientEvent("syncSessionTable", root, createdSessions)

    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 1 then
            setElementData(v, "a.DMTeam", nil)
            --triggerClientEvent("showTeamselectorPanel", v, v)
            toggleControl(v, "fire", true)
            toggleControl(v, "action", true)
            --setElementData(v, "a.Protected", false)
        end
    end
end
setTimer(onStart, 100, 1)

local numberOfAutomaticGeneratedSessions = 10;
local createdSessions = {}

function generateSessions()
    for sessionCount = 1, numberOfAutomaticGeneratedSessions do
        local currentSessionRandomMapKey = math.random(1, #mapCache)
        local currentSessionRandomRoundTime = math.round(math.random(400, 600), -1) 
        local currentSessionRandomFantasyNameKey = math.random(1, #teamNames)
        local currentSessionRandomMoney = math.round(math.random(1000, 2000), -2)

        table.insert(createdSessions, {currentSessionRandomMapKey, currentSessionRandomRoundTime, currentSessionRandomFantasyNameKey, 0, currentSessionRandomMoney, 0, 0})

        exports.dMapLoader:createMapToDimension(currentSessionRandomMapKey, tonumber(100+sessionCount))
        triggerClientEvent("syncSessionTable", root, createdSessions)
    end 
    startTheTickTack()
end

function requestSessions(element)
    -- ** AC
    if not element or not isElement(element) or not getElementType(element) == "player" then
        return
    end
    local clientPlayer = client

    if not clientPlayer and not client == source then
        return
    end
    -- ** AC VÉGE

    triggerClientEvent("a_SendRequestedSessions", client, client, createdSessions)
end
addEventHandler("a_RequestSessions", getRootElement(), requestSessions)

function generateNewSessionForId(id)
    if id then
        local currentSessionRandomMapKey = math.random(1, #mapCache)
        local currentSessionRandomRoundTime = math.round(math.random(300, 600), -1)
        local currentSessionRandomFantasyNameKey = math.random(1, #teamNames)
        local currentSessionRandomMoney = math.round(math.random(1000, 2000), -2)

        createdSessions[id] = {currentSessionRandomMapKey, currentSessionRandomRoundTime, currentSessionRandomFantasyNameKey, 0, currentSessionRandomMoney, 0, 0}

        -- ** DOBJA KI AZ EMBEREKET ABBÓL A SESSIONBŐL ÉS VISSZA A VÁLASZTÓHOZ!!!!!! - 2024/07/16 dzseko

        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Current<DM>Session") == id then
                setElementData(v, "a.Current<DM>Session", false)

                --setElementFrozen(v, true)
                toggleAllControls(v, false)

                triggerClientEvent("removeCounterFromScreen", v, v)
                triggerClientEvent("a_SendRequestedSessions", v, v, createdSessions)
                triggerClientEvent("syncSessionTable", root, createdSessions)
            end
        end

        local sessionId = tonumber(100+id)
        callFunctionWithSleeps(destroyCurrentMapByDimension, sessionId)

        exports.dMapLoader:createMapToDimension(currentSessionRandomMapKey, sessionId)
    end
end

function destroyCurrentMapByDimension(session)
    for k, v in ipairs(getElementsByType("object")) do
        if isElement(v) and getElementType(v) == "object" then
            if getElementDimension(v) == tonumber(session) then
                destroyElement(v)
                sleep(250)
            end
        end
    end
end

function startTheTickTack()
    setTimer(countSeconds, 1000, 0)
end

function countSeconds()
    for i, v in ipairs(createdSessions) do
        createdSessions[i][2] = v[2] - 1
        if createdSessions[i][2] == 0 then
            generateNewSessionForId(i)
        end

        if i == #createdSessions then
            triggerClientEvent("syncSessionTable", root, createdSessions)
        end
    end
end

function onChange(key, oVal, nVal)
    if key == "a.Gamemode" then
        if nVal == 1 then
            --triggerClientEvent("showTeamselectorPanel", source, source)
        elseif nVal == nil or nVal == false then
            setElementData(source, "a.Team<DM>", nil)
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
end
addEventHandler("onElementDataChange", root, onChange)

function attemptToJoinSession(element, session)
    -- ** AC
    if not element or not session or not isElement(element) or not getElementType(element) == "player" then
        return
    end
    local clientPlayer = client

    if not clientPlayer and not client == source then
        return
    end
    -- ** AC VÉGE

    local currentFullnessOfSession = createdSessions[session][4]
    triggerClientEvent("syncSessionTable", root, createdSessions)
    if currentFullnessOfSession == 10 then
        outputChatBox("#E48F8Falphav2 ► Hiba: #FFFFFFNem tudsz csatlakozni a kiválasztott sessionhoz, mivel tele van.", element, 255, 255, 255, true)
    else
        joinSession(element, session)
    end
end
addEvent("attemptToJoinSession", true)
addEventHandler("attemptToJoinSession", root, attemptToJoinSession)

function joinSession(joinedElement, sessionToJoin)
    if joinedElement and sessionToJoin then
        setElementData(joinedElement, "a.Current<DM>Session", tonumber(sessionToJoin))
        setElementData(joinedElement, "a.inSession", true)
        setElementDimension(joinedElement, 100 + tonumber(sessionToJoin))

        local currentSessionMap = createdSessions[sessionToJoin][1]
        triggerClientEvent("syncSessionTable", root, createdSessions)

        local attackerCount = 0;
        local defenderCount = 0;
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Current<DM>Session") == tonumber(sessionToJoin) then
                if getElementData(v, "a.Team<DM>") == "Attacker" then
                    attackerCount = attackerCount + 1
                elseif getElementData(v, "a.Team<DM>") == "Defender" then
                    defenderCount = defenderCount + 1
                end
            end
        end

        if attackerCount == defenderCount then
            local randomTeam = math.random(1, 2)
            if randomTeam == 1 then
                setElementData(joinedElement, "a.Team<DM>", "Attacker")
                setElementPosition(joinedElement, mapCache[currentSessionMap]["mapRespawnPosition"][1], mapCache[currentSessionMap]["mapRespawnPosition"][2], mapCache[currentSessionMap]["mapRespawnPosition"][3])
                setElementData(joinedElement, "a.RespawnPosition", {mapCache[currentSessionMap]["mapRespawnPosition"][1], mapCache[currentSessionMap]["mapRespawnPosition"][2], mapCache[currentSessionMap]["mapRespawnPosition"][3]})
                setElementData(joinedElement, "a.Protected", false)

                outputChatBox("#8FC3E4alphav2 ► Sessions: #FFFFFFA rendszer besorolt Téged a #E48F8FTÁMADÓ #FFFFFFcsapatba.", joinedElement, 255, 255, 255, true)
            else
                setElementData(joinedElement, "a.Team<DM>", "Defender")
                setElementPosition(joinedElement, mapCache[currentSessionMap]["mapRespawnPosition"][4], mapCache[currentSessionMap]["mapRespawnPosition"][5], mapCache[currentSessionMap]["mapRespawnPosition"][6])
                setElementData(joinedElement, "a.RespawnPosition", {mapCache[currentSessionMap]["mapRespawnPosition"][4], mapCache[currentSessionMap]["mapRespawnPosition"][5], mapCache[currentSessionMap]["mapRespawnPosition"][6]})
                setElementData(joinedElement, "a.Protected", false)

                outputChatBox("#8FC3E4alphav2 ► Sessions: #FFFFFFA rendszer besorolt Téged a #9BE48FVÉDŐ #FFFFFFcsapatba.", joinedElement, 255, 255, 255, true)
            end
        elseif attackerCount > defenderCount then
            setElementData(joinedElement, "a.Team<DM>", "Defender")
            setElementPosition(joinedElement, mapCache[currentSessionMap]["mapRespawnPosition"][4], mapCache[currentSessionMap]["mapRespawnPosition"][5], mapCache[currentSessionMap]["mapRespawnPosition"][6])
            setElementData(joinedElement, "a.RespawnPosition", {mapCache[currentSessionMap]["mapRespawnPosition"][4], mapCache[currentSessionMap]["mapRespawnPosition"][5], mapCache[currentSessionMap]["mapRespawnPosition"][6]})
            setElementData(joinedElement, "a.Protected", false)

            outputChatBox("#8FC3E4alphav2 ► Sessions: #FFFFFFA rendszer besorolt Téged a #9BE48FVÉDŐ #FFFFFFcsapatba.", joinedElement, 255, 255, 255, true)
        else
            setElementData(joinedElement, "a.Team<DM>", "Attacker")
            setElementPosition(joinedElement, mapCache[currentSessionMap]["mapRespawnPosition"][1], mapCache[currentSessionMap]["mapRespawnPosition"][2], mapCache[currentSessionMap]["mapRespawnPosition"][3])
            setElementData(joinedElement, "a.RespawnPosition", {mapCache[currentSessionMap]["mapRespawnPosition"][1], mapCache[currentSessionMap]["mapRespawnPosition"][2], mapCache[currentSessionMap]["mapRespawnPosition"][3]})
            setElementData(joinedElement, "a.Protected", false)

            outputChatBox("#8FC3E4alphav2 ► Sessions: #FFFFFFA rendszer besorolt Téged a #E48F8FTÁMADÓ #FFFFFFcsapatba.", joinedElement, 255, 255, 255, true)
        end

        createdSessions[sessionToJoin][4] = createdSessions[sessionToJoin][4] + 1
        setElementData(joinedElement, "a.Gamemode", 1)
        --setElementFrozen(joinedElement, false)
        toggleAllControls(joinedElement, true)

        triggerClientEvent("joinSuccess", joinedElement, joinedElement)
    end
end

--[[function playerLeftSession(element)
    local currentSessionId = getElementData(element, "a.Current<DM>Session")
    if currentSessionId then
        createdSessions[currentSessionId][4] = createdSessions[currentSessionId][4] - 1
        setElementData(element, "a.Current<DM>Session", nil)
        setElementDimension(element, 0)

        triggerClientEvent("syncSessionTable", root, createdSessions)
    end
end
addEventHandler("onPlayerQuit", root, playerLeftSession)]] -- Eseménykezelő, amikor kilép a játékos

--playerLeftSession helyett
function onChange(key, oVal, nVal)
	if key == "a.inSession" and nVal == false then
        local currentSessionId = getElementData(source, "a.Current<DM>Session")

        setElementDimension(source, 0)

        if currentSessionId then
		    createdSessions[currentSessionId][4] = createdSessions[currentSessionId][4] - 1
            setElementDimension(source, 0)
        end
        
        triggerClientEvent("syncSessionTable", root, createdSessions)
	end
end
addEventHandler("onElementDataChange", root, onChange)


-- ** DEBUG COMMAND, KIVÉVE DZSEKI ÁLTAL - 2024/07/23
--[[addCommandHandler("givepoints", function(e)
    local currentSessionId = getElementData(e, "a.Current<DM>Session")
    if getElementData(e, "a.Team<DM>") == "Attacker" then
        createdSessions[currentSessionId][6] = createdSessions[currentSessionId][6] + 1
    elseif getElementData(e, "a.Team<DM>") == "Defender" then
        createdSessions[currentSessionId][7] = createdSessions[currentSessionId][7] + 1
    end
end)]]--

function onKillSomebody(ammo, killer, weapon, bodypart, stealth)
    if ammo and killer and weapon then
        if killer == source then return end
        if bodypart == 9 then
            bonus = math.random(75, 125)
        else
            bonus = math.random(25, 75)
        end

        --outputChatBox("#E48F8Falphav2 ► Ölés: #FFFFFFMegölted #8FC3E4" .. getPlayerName(source) .. "#ffffff játékost. #9BE48F(" .. bonus .. "#FFFFFF$)", killer, 255, 255, 255, true)

        setElementData(killer, "a.Kills", getElementData(killer, "a.Kills")+1)
        setElementData(source, "a.Deaths", getElementData(source, "a.Deaths")+1)
        setElementData(killer, "a.Money", getElementData(killer, "a.Money") + bonus)

        triggerClientEvent("addToKillFeed", root, killer, source, weapon)

        --exports.a_logs:createDCLog(getElementData(killer, "a.PlayerName") .. " megölte " .. getElementData(source, "a.PlayerName") .. "-t - (fegyver: " .. getWeaponNameFromID(weapon) .. ")", 5)
        
        if not (getElementData(killer, "a.Current<DM>Session") == getElementData(source, "a.Current<DM>Session")) then
            print("dDead -> A két element nem volt egy sessionben.")
            return
        end

        local currentSessionId = getElementData(killer, "a.Current<DM>Session")
        if getElementData(killer, "a.Team<DM>") == "Attacker" then
            createdSessions[currentSessionId][6] = createdSessions[currentSessionId][6] + 1
        elseif getElementData(killer, "a.Team<DM>") == "Defender" then
            createdSessions[currentSessionId][7] = createdSessions[currentSessionId][7] + 1
        end

        local chance = math.random(1, 100)
        if chance > 1 and chance < 70 then
            return
        elseif chance > 71 and chance < 100 and getElementData(killer, "a.VIP") == true then
            --outputChatBox("#e48f8f[Halloween Event]:#ffffff Mivel VIP vagy, ezért az ölésedért cserébe nagyobb eséllyel kaptál egy #e48f8fTököt#ffffff! Inventorydban megtalálod.", killer, 255, 255, 255, true)
            --exports.a_inventory:giveItem(killer, 58, 1, false, false, false, false, "alphagames.net", false)
        elseif chance > 96 and chance < 100 and getElementData(killer, "a.VIP") == false then
            --outputChatBox("#e48f8f[Halloween Event]:#ffffff Ölésért cserébe kaptál egy #e48f8fTököt#ffffff! Inventorydban megtalálod.", killer, 255, 255, 255, true)
            --exports.a_inventory:giveItem(killer, 58, 1, false, false, false, false, "alphagames.net", false)
        end

        if getElementData(killer, "a.Gamemode") == nil then
            --kickPlayer(killer, "A lobbyban nem szabad játékosokat ölni.")
            --iprint(getPlayerName(killer) .. " ölt lobbyban")
            cancelEvent()
        end

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

-- function onFire()
--     if getElementData(source, "a.Protected") then
--         setElementData(source, "a.Protected", false)
--         if isTimer(delayTimer[source]) then
--             killTimer(delayTimer[source]) 
--         end
--     end

--     if exports.see_items:hasItemWithData() then
--         local shotsRemaining = item.shotsRemaining

--         shotsRemaining = shotsRemaining - 1
-- 		print("lement egyet cigany")

--         if shotsRemaining <= 0 then
--             cancelEvent()
--             outputChatBox("[alphaGames - Fegyver] Nincs több lőszered ebben a fegyverben!", 255, 255, 255, true)
--         end
--     end
-- end
-- addEventHandler("onPlayerWeaponFire", root, onFire)

function math.round(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end

function callFunctionWithSleeps(calledFunction, ...) 
    local co = coroutine.create(calledFunction) --we create a thread 
    coroutine.resume(co, ...) --and start its execution 
end 
  
function sleep(time) 
    local co = coroutine.running() 
    local function resumeThisCoroutine() --since setTimer copies the argument values and coroutines cannot be copied, co cannot be passed as an argument, so we use a nested function with co as an upvalue instead 
        coroutine.resume(co) 
    end 
    setTimer(resumeThisCoroutine, time, 1) --we set a timer to resume the current thread later 
    coroutine.yield() --we pause the execution, it will be continued when the timer calls the resume function 
end 