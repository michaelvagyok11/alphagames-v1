-- Converted on mtaclub.eu

-- SETTINGS ---------------
local ASYNC   = false -- Enable async loading 
local STEPS   = 250 -- How much to load at one period (if 'ASYNC' enabled)
local TIMEOUT = 1000 -- Waiting time (ms) between two periods (if 'ASYNC' enabled)
---------------------------


local cor     = nil
local counter = 0

local wait = function()
    counter = counter + 1
    return counter >= STEPS and setTimer(function()
        counter = 0
        coroutine.resume(cor)
    end, TIMEOUT, 1)
end

local loadMap = function(mapIndex, mapDimension)
    if convertedMapData and mapIndex and mapDimension then
        --print("Loaded a map with the index of " .. mapIndex .. " to the dimension " .. mapDimension .. ".")
        for k, v in ipairs(convertedMapData[mapIndex]) do
            local e = createObject(v.model, v.x, v.y, v.z, v.rx, v.ry, v.rz)
            setElementInterior(e, v.interior)
            setElementDimension(e, mapDimension)
            setElementDoubleSided(e, v.doublesided)
            setElementFrozen(e, v.frozen)
            setObjectScale(e, v.scale)
            setElementAlpha(e, v.alpha)
            setElementCollisionsEnabled(e, v.collisions)
            sleep(25)
        end
    end

    if objectremoves[mapIndex] then
        for i = 1, #objectremoves[mapIndex] do
            local v = objectremoves[mapIndex][i]
            --print("removed model ".. i)
            removeWorldModel(v.model, v.radius, v.x, v.y, v.z)
            sleep(25)
        end
    end
end

function createMapToDimension(map, dimensiontoload)
    if map and dimensiontoload then
        --loadMap(tonumber(map), tonumber(dimensiontoload))
        callFunctionWithSleeps(loadMap, tonumber(map), tonumber(dimensiontoload))
        --print("Loaded a map with the index of " .. map .. " to the dimension " .. dimensiontoload .. ".")
    end
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