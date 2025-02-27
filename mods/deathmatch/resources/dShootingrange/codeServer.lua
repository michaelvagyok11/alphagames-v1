local shootingRangeEnter = {}
local shootingRangeExit = {}

function onStart()
    enterColshape = createColSphere(colshapePosition[1], colshapePosition[2], colshapePosition[3], 1)
    setElementData(enterColshape, "a.ShootingRangeCol", true)

    exitColshape = createColSphere(exitPosition[1], exitPosition[2], exitPosition[3], 1)
    setElementInterior(exitColshape, interiorID)
    setElementData(exitColshape, "a.ShootingRangeExit", true)

    setTimer(function()
        for k, v in ipairs(getElementsByType("object")) do
            if getElementData(v, "a.ShootingRangeObj") then
                destroyElement(v)
            end
        end

        local objects = {}
        local randomI = {}
        for index, value in pairs(rowPositions) do
            randomI[index] = math.random(1, #rowPositions[index])
            for k, v in ipairs(rowPositions[index]) do
                if k == randomI[index] then 
                    objects[k] = createObject(objectIDs[math.random(1, #objectIDs)][1], v[1], v[2], v[3] - 0.75)
                    setObjectScale(objects[k], 0.75)
                    setElementRotation(objects[k], 0, 0, 90)
                    setElementInterior(objects[k], interiorID)
                    setElementData(objects[k], "a.ShootingRangeObj", true)
                end
            end
        end
        objectsRemained = 8
    end, 100, 1)
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function goToShootingRange(executerElement, commandName)
    setElementInterior(executerElement, 4)
    setElementPosition(executerElement, interiorPosition[1], interiorPosition[2], interiorPosition[3])
end
addCommandHandler("shoot", goToShootingRange)

function changePosition(element, type)
    if isElement(element) then
        if type == "entry" then
            setElementInterior(element, interiorID)
            setElementPosition(element, interiorPosition[1], interiorPosition[2], interiorPosition[3])
            toggleControl(element, "fire", true)
            toggleControl(element, "action", true)
        elseif type == "exit" then
            setElementInterior(element, 0)
            setElementPosition(element, 1535.8994, -1356.6641, 329.45789)
        end
    end
end
addEvent("changePosition", true)
addEventHandler("changePosition", root, changePosition)

function destroyObject(element, model)
    if isElement(element) and isElement(model) then
        if objectsRemained - 1 < 1 then
            for k, v in ipairs(getElementsByType("object")) do
                if getElementData(v, "a.ShootingRangeObj") then
                    destroyElement(v)
                end
            end
    
            local objects = {}
            local randomI = {}
            for index, value in pairs(rowPositions) do
                randomI[index] = math.random(1, #rowPositions[index])
                for k, v in ipairs(rowPositions[index]) do
                    if k == randomI[index] then 
                        objects[k] = createObject(objectIDs[math.random(1, #objectIDs)][1], v[1], v[2], v[3] - 0.75)
                        setObjectScale(objects[k], 0.75)
                        setElementRotation(objects[k], 0, 0, 90)
                        setElementInterior(objects[k], interiorID)
                        setElementData(objects[k], "a.ShootingRangeObj", true)
                    end
                end
            end
            objectsRemained = 8
        else
            for index, value in pairs(rowPositions) do
                randomI[index] = math.random(1, #rowPositions[index])
                for k, v in ipairs(rowPositions[index]) do
                    if k == randomI[index] then 
                        objects[k] = createObject(objectIDs[math.random(1, #objectIDs)][1], v[1], v[2], v[3] - 0.75)
                        setObjectScale(objects[k], 0.75)
                        setElementRotation(objects[k], 0, 0, 90)
                        setElementInterior(objects[k], interiorID)
                        setElementData(objects[k], "a.ShootingRangeObj", true)
                        break
                    end
                    break
                end
            end
            --objectsRemained = objectsRemained - 1
            destroyElement(model)
        end
        destroyElement(model)
    end
end
addEvent("destroyObject", true)
addEventHandler("destroyObject", root, destroyObject)