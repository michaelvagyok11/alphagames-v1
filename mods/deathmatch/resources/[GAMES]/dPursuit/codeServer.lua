local spawnPosition = {1877.861328125, -1367.0380859375, 14.640625};
local isRoundInProgress = false

function onChange(key, oVal, nVal)
    if key == "a.Gamemode" then
        if nVal == 4 then
            setElementDimension(source, 4)
            
            playerCount = 0
            for i, v in ipairs(getElementsByType("player")) do
                if getElementData (v, "a.Gamemode") == 4 then
                    playerCount = playerCount + 1
                end
            end

            if playerCount == 2 then
                callFunctionWithSleeps(startRound)
            else
                setElementData(source, "a.HPTeam", nil)
                setElementPosition(source, 1775.2926025391, -1302.4283447266, 120.26425170898)
            end
        end
        if oVal == 2 then
            setElementData(source, "a.HPTeam", nil)
        end
    end
end
addEventHandler("onElementDataChange", root, onChange)

local noCollisionTimer = {}

addEventHandler("onElementDataChange", getRootElement(),
    function (dataName, oldVal, newVal)
        if dataName == "alphaSettings" then
            for k, v in pairs(getElementsByType("vehicle")) do 
                if getElementData(v, "a.HPTeam_Veh") == 1 or getElementData(v, "a.HPTeam_Veh") == 2 then
                    setElementAlpha(v, 255)
                end
            end
        end
    end 
)

addEvent("restoreAlpha", true)
addEventHandler("restoreAlpha", getRootElement(),
    function (vehicle)
        if vehicle then 
            --setElementAlpha(vehice, 255)
        end    
    end 
)

function restartRound(sourcePlayer, commandName, ...)
    if getElementData(sourcePlayer, "adminLevel") >= 5 then
        if not ... then
            outputChatBox("#E48F8F► Hiba: #FFFFFFNincs indok megadva!", sourcePlayer, 255, 255, 255, true)
            return
        end

        local adminName = getPlayerName(sourcePlayer)

        startRound()
        outputChatBox("#B4D95A► Siker: #FFFFFFÚjraindítottad a kört.", sourcePlayer, 255, 255, 255, true)
        export.aAdmin:outputAdminMessage("#5AB1D9"..adminName.." újraindította a pursuit kört.")
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Gamemode") == 4 then
                outputChatBox("#5AB1D9► Info: #FFFFFFÚjraindult a kör #5AB1D9".. adminName .."#FFFFFF által.", v, 255, 255, 255, true)
            end
        end
    end
end
addCommandHandler("restartpursuit", restartRound)

function startRound()
    currentMap = math.random(1, #startPositions)
    addEventHandler("onVehicleStartExit", root, disableExit)


    for k, v in pairs(getElementsByType("player")) do 
        if getElementData(v, "a.Gamemode") == 4 then 
            --outputChatBox(getPlayerName(v) .. ":true")
            toggleControl(v, "fire", true)
            toggleControl(v, "action", true)
            setElementData(v, "a.Protected", false)
        end
    end

    setTimer(function()
        removeEventHandler("onVehicleStartExit", root, disableExit)
    end, 10000, 1)
    playerCount = 0;
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 4 then
            playerCount = playerCount + 1
        end
    end

    if playerCount == 1 then
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Gamemode") == 4 then
                if isPedInVehicle(v) then
                    removePedFromVehicle( v )
                end
                setElementData(v, "a.HPTeam", nil)
                outputChatBox("#E48F8F[error]: #ffffffEz a játékmód nem játszható 1 játékossal.", v, 255, 255, 255, true)
                setElementPosition(v, 1775.2926025391, -1302.4283447266, 120.26425170898)
                setElementInterior(v, 0)
                setElementData(v, "a.Protected", true)
            end
        end
        return
    end
    
    for k, v in ipairs(getElementsByType("player")) do
        setElementData(v, "a.HPTeam", nil)
        setElementData(v, "a.Protected", true)
    end

    for k, v in ipairs(getElementsByType("vehicle")) do
        if getElementDimension(v) == 4 then
            destroyElement(v)
        end
    end

    local playerCache = {}
    for _, v in ipairs(getElementsByType("player")) do
        table.insert(playerCache, v)
    end

    shuffle(playerCache)
    for i, v in ipairs(playerCache) do
        if getElementData(v, "a.Gamemode") == 4 then
            sleep(250)
            sortPlayerIntoTeam(v)
            sleep(250)
        end
    end
    triggerClientEvent("startRoundClient", root, root)
    isRoundInProgress = true
    processTimer()
    chaserCount = 0
    runnerCount = 0
end 
addEvent("startRound", true)
addEventHandler("startRound", root, startRound)

function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function processTimer()
    if isTimer(secondTimer) then
        killTimer(secondTimer)
    end
    seconds = 300    
    secondTimer = setTimer(function()
        seconds = seconds - 1
        triggerClientEvent("giveCounterC", root, seconds)
        if seconds == 0 then
            setTimer(function()
                callFunctionWithSleeps(startRound)
            end, 5000, 1)
        end
    end, 1000, 300)
end

local freezeTimer = {}

function sortPlayerIntoTeam(p)
    if isElement(p) then
        setElementHealth(p, 100)
        runnerCount = 0
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.HPTeam") == 1 then
                runnerCount = runnerCount + 1
                setElementData(v, "a.Protected", false)
            end
        end

        chaserCount = 0
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.HPTeam") == 2 then
                chaserCount = chaserCount + 1
                setElementData(v, "a.Protected", false)
            end
        end

        playerCount = 0;
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.HPTeam") == 1 or getElementData(v, "a.HPTeam") == 2 then
                playerCount = playerCount + 1
                setElementData(v, "a.Protected", false)
            end
        end

        setElementDimension(p, 4)
        skinTable = getElementData(p, "a.HPSkin") or {1, 2}
        vehTable = getElementData(p, "a.HPVehicle") or {445, 596}

        if runnerCount == 0 then
            setElementData(p, "a.HPTeam", 1)
            setElementData(p, "a.IsInInterior", false)
            setElementInterior(p, 0)
            setElementDimension(p, 4)
            outputChatBox("#9BE48F[hotpursuit]: #FFFFFFA rendszer automatikusan kiválasztotta a csapatodat. Te egy #E48F8Fmenekülő#FFFFFF vagy, menj és menekülj el a #8FC3E4rendőrök#FFFFFF elől.", p, 255, 255, 255, true)
            setElementData(p, "a.Protected", false)

            --** SKIN
            setElementModel(p, skinTable[2])

            posInt = math.random(1, #startPositions[currentMap]["runner"])
            
            veh = createVehicle(vehTable[2], startPositions[currentMap]["runner"][posInt][1], startPositions[currentMap]["runner"][posInt][2], startPositions[currentMap]["runner"][posInt][3] + 0.3)
            
            triggerClientEvent(p, "disableCollision", resourceRoot, veh)
            triggerClientEvent(p, "disableCollision", resourceRoot, p)

            setElementDimension(veh, 4)
            setElementData(veh, "a.HPTeam_Veh", 1)
            setElementRotation(veh, 0, 0, startPositions[currentMap]["rotation"])
            warpPedIntoVehicle(p, veh)
            setElementFrozen(veh, true)
            setElementAlpha(veh, 155)
        else
            if (playerCount % 5) == 0 then
                setElementData(p, "a.HPTeam", 1)
                setElementData(p, "a.IsInInterior", false)
                setElementInterior(p, 0)
                setElementDimension(p, 4)
                outputChatBox("#9BE48F[hotpursuit]: #FFFFFFA rendszer automatikusan kiválasztotta a csapatodat. Te egy #E48F8Fmenekülő#FFFFFF vagy, menj és menekülj el a #8FC3E4rendőrök#FFFFFF elől.", p, 255, 255, 255, true)
                setElementData(p, "a.Protected", false)

                --** SKIN
                setElementModel(p, skinTable[2])

                posInt = math.random(1, #startPositions[currentMap]["runner"])
                
                veh = createVehicle(vehTable[2], startPositions[currentMap]["runner"][posInt][1], startPositions[currentMap]["runner"][posInt][2], startPositions[currentMap]["runner"][posInt][3] + 0.3)
                
                triggerClientEvent(p, "disableCollision", resourceRoot, veh)
                triggerClientEvent(p, "disableCollision", resourceRoot, p)

                setElementAlpha(veh, 155)
                setElementData(veh, "a.HPTeam_Veh", 2)

                setElementDimension(veh, 4)
                setElementRotation(veh, 0, 0, startPositions[currentMap]["rotation"])
                warpPedIntoVehicle(p, veh)
                setElementFrozen(veh, true)
            else
                setElementData(p, "a.HPTeam", 2)
                setElementData(p, "a.IsInInterior", false)
                setElementInterior(p, 0)
                setElementDimension(p, 4)
                outputChatBox("#9BE48F[hotpursuit]: #FFFFFFA rendszer automatikusan kiválasztotta a csapatodat. Te #8FC3E4rendőr#FFFFFF vagy, menj és kapd el a #E48F8Fmenekülőket#FFFFFF.", p, 255, 255, 255, true)
                setElementData(p, "a.Protected", false)

                --** SKIN
                setElementModel(p, skinTable[1])

                posInt = math.random(1, #startPositions[currentMap]["chaser"])
                
                veh = createVehicle(vehTable[1], startPositions[currentMap]["chaser"][posInt][1], startPositions[currentMap]["chaser"][posInt][2], startPositions[currentMap]["chaser"][posInt][3] + 0.3)
                setElementData(veh, "a.HPTeam_Veh", 2)

                setElementDimension(veh, 4)
                setElementRotation(veh, 0, 0, startPositions[currentMap]["rotation"])
                warpPedIntoVehicle(p, veh)
                setElementFrozen(veh, true)
                setElementAlpha(veh, 155)

                if getVehicleSirensOn(veh) == false then
                    setVehicleSirensOn(veh, true)
                end
            end
        end

        freezeTimer[p] = setTimer(function()
            setElementFrozen(getPedOccupiedVehicle(p), false)
        end, 3000, 1)
    end
end

function onDeath(ammo, attacker)
    if getElementData(source, "a.HPTeam") == 1 then
        if isRoundInProgress == false then
            return
        end
        setElementData(source, "a.HPTeam", 0)
        setElementData(source, "a.Protected", true)
        runnerCount = 0
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData (v, "a.HPTeam") == 1 then
                runnerCount = runnerCount + 1
            end
        end
        --setTimer(function()
            if runnerCount == 0 then
                isRoundInProgress = false
                setTimer(function()
                    callFunctionWithSleeps(startRound)
                end, 5000, 1)
                for k, v in ipairs(getElementsByType("player")) do
                    if getElementData(v, "a.Gamemode") == 4 then
                        if getElementData(v, "a.HPTeam") == 2 then
                            outputChatBox("#9BE48F[hotpursuit]: #FFFFFFA #8FC3E4rendőrök #FFFFFFnyertek.", v, 255, 255, 255, true)
                        else
                            outputChatBox("#9BE48F[hotpursuit]: #FFFFFFA #8FC3E4rendőrök #FFFFFFnyertek.", v, 255, 255, 255, true)
                        end
                    end
                end
            end
        --end, 500, 1)
    elseif getElementData(source, "a.HPTeam") == 2 then
        if isRoundInProgress == false then
            return
        end
        setElementData(source, "a.HPTeam", 0)
        chaserCount = 0
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.HPTeam") == 2 then
                chaserCount = chaserCount + 1
            end
        end

        --setTimer(function()
            if chaserCount == 0 then
                isRoundInProgress = false
                setTimer(function()
                    callFunctionWithSleeps(startRound)
                end, 5000, 1)
                for k, v in ipairs(getElementsByType("player")) do
                    if getElementData(v, "a.Gamemode") == 4 then
                        if getElementData(v, "a.HPTeam") == 1 then
                            outputChatBox("#9BE48F[hotpursuit]: #FFFFFFA #8FC3E4menekülők #FFFFFFnyertek.", v, 255, 255, 255, true)
                        else
                            outputChatBox("#9BE48F[hotpursuit]: #FFFFFFA #8FC3E4menekülők #FFFFFFnyertek.", v, 255, 255, 255, true)
                        end
                    end
                end
            end
        --end, 500, 1)
    end
end
addEventHandler("onPlayerWasted", root, onDeath)

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

setTimer(function()
    callFunctionWithSleeps(startRound)
end, 1000, 1)

local delayTimer = {}

function onQuit(key, oVal, nVal)
    if key == "a.Gamemode" then
        if oVal == 4 then
            setElementData(source, "a.HPTeam", nil)
            runnerCount = 0;
            for k, v in ipairs(getElementsByType("player")) do
                if getElementData(v, "a.Gamemode") == 4 and getElementData(v, "a.HPTeam") == 1 then
                    runnerCount = runnerCount + 1
                end
            end

            chaserCount = 0;
            for k, v in ipairs(getElementsByType("player")) do
                if getElementData(v, "a.Gamemode") == 4 and getElementData(v, "a.HPTeam") == 2 then
                    chaserCount = chaserCount + 1
                end
            end

            if runnerCount == 0 then
                delayTimer[source] = setTimer(function()
                    callFunctionWithSleeps(startRound)
                end, 5000, 1)
            else
                if chaserCount == 0 then
                    delayTimer[source] = setTimer(function()
                        callFunctionWithSleeps(startRound)
                    end, 5000, 1)
                end
            end
        end
    end
end
addEventHandler("onElementDataChange", root, onQuit)

function onQuitPlayer()
    setElementData(source, "a.Gamemode", nil)
end
addEventHandler("onPlayerQuit", root, onQuitPlayer)

local connection = exports.a_mysql:getConnection()

function requestSave(element, arg1, ...)
    if isElement(element) and getElementData(element, "loggedIn") then
        if arg1 == "saveskin" then
            args = {...}
            if args[1] == 1 then
                local skinTable = getElementData(element, "a.HPSkin")
                skinTable = {args[2], skinTable[2]}
                setElementData(element, "a.HPSkin", skinTable)
                dbExec(connection, "UPDATE accounts SET hpSkin = ? WHERE serial = ?", toJSON(getElementData(element, "a.HPSkin")), getPlayerSerial(element))
            elseif args[1] == 2 then
                local skinTable = getElementData(element, "a.HPSkin")
                skinTable = {skinTable[1], args[2]}
                setElementData(element, "a.HPSkin", skinTable)
                dbExec(connection, "UPDATE accounts SET hpSkin = ? WHERE serial = ?", toJSON(getElementData(element, "a.HPSkin")), getPlayerSerial(element))
            end
        elseif arg1 == "saveveh" then
            args = {...}
            if tonumber(args[1]) == 1 then
                local vehTable = getElementData(element, "a.HPVehicle")
                vehTable = {args[2], vehTable[2]}
                setElementData(element, "a.HPVehicle", vehTable)
                dbExec(connection, "UPDATE accounts SET hpVeh = ? WHERE serial = ?", toJSON(getElementData(element, "a.HPVehicle")), getPlayerSerial(element))
            elseif tonumber(args[1]) == 2 then
                local vehTable = getElementData(element, "a.HPVehicle")
                vehTable = {vehTable[1], args[2]}
                setElementData(element, "a.HPVehicle", vehTable)
                dbExec(connection, "UPDATE accounts SET hpVeh = ? WHERE serial = ?", toJSON(getElementData(element, "a.HPVehicle")), getPlayerSerial(element))
            end
        elseif arg1 == "buyveh" then
            args = {...}
            if tonumber(args[1]) then
                local boughtVehicles = getElementData(element, "a.HPBoughtVehs")
                table.insert(boughtVehicles, args[1])
                setElementData(element, "a.HPBoughtVehs", boughtVehicles)
                dbExec(connection, "UPDATE accounts SET hpBoughtVehs = ? WHERE serial = ?", toJSON(getElementData(element, "a.HPBoughtVehs")), getPlayerSerial(element))
            end
        end
    end
end
addEvent("requestSave", true)
addEventHandler("requestSave", root, requestSave)

function disableExit(element)
    if getElementData(element, "a.Gamemode") == 4 then
        cancelEvent()
    end
end