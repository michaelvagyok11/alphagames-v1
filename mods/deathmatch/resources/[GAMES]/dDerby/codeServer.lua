function onStart()
    currentMap = getRandomMap()

    outputDebugString("Elindult egy új DERBY kör. (" .. mapCache[currentMap]["mapName"] .. ")", 0, 140, 195, 230)

    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 4 then
            startGamemodeForPlayer(v)
        end
    end
end
setTimer(onStart, 500, 1)

function onJoin(key, oVal, nVal)
    if key == "a.Gamemode" and nVal == 4 then
        if matchInProgress then
            outputChatBox("#F1C176[DERBY]: #FFFFFFJelenleg folyamatban van egy kör, addig a lobbyban várakozhatsz.", element, 255, 255, 255, true)
        else
            startGamemodeForPlayer(source)
        end
    end
end
addEventHandler("onElementDataChange", root, onJoin)

function startGamemodeForPlayer(element)
    local positionInt = math.random(1, #mapCache[currentMap]["mapSpawnPositions"])
    local x, y, z = mapCache[currentMap]["mapSpawnPositions"][positionInt][1], mapCache[currentMap]["mapSpawnPositions"][positionInt][2], mapCache[currentMap]["mapSpawnPositions"][positionInt][3]
    --setElementPosition(element, x, y, z)

    local vehicleInt = math.random(1, #allowedVehicles)
    local chosenVehicle = allowedVehicles[vehicleInt]
    createdVehicle = createVehicle(chosenVehicle, x, y, z)
    warpPedIntoVehicle(element, createdVehicle)

    outputChatBox("#F1C176[DERBY]: #FFFFFFJelenlegi pálya: #9BE48F" .. mapCache[currentMap]["mapName"] .. " #FFFFFF- Járműved: #9BE48F" .. getVehicleNameFromModel(chosenVehicle), element, 255, 255, 255, true)
end