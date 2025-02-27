local createdLights = {}
local lightNum = 1

function makeLightToPos(x, y, z, r, g, b)
    createdLights[lightNum] = createLight(0, x, y, z, 4, r, g, b)
    lightNum = lightNum + 1
end
addEvent("makeLightToPos", true)
addEventHandler("makeLightToPos", root, makeLightToPos)

function destroyLightsToTime()
    callFunctionWithSleeps(destroyLights)
end
addEvent("destroyLightsToTime", true)
addEventHandler("destroyLightsToTime", root, destroyLightsToTime)

function destroyLights()
    for k, v in ipairs(createdLights) do
        destroyElement(v)
        sleep(250)
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