--[[function onPreFunction( sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ... )
    if not sourceResource then
        triggerServerEvent("onFaltoro", localPlayer)
        return "skip"
    end

    local args = { ... }
    if functionName == "setElementData" then
        if not (args[1] == localPlayer) then
            triggerServerEvent("onFaltoro", localPlayer)
            return "skip"
        end

        if (args[2] == "adminLevel") then
            triggerServerEvent("onFaltoro", localPlayer)
            return "skip"
        end
    end

    if functionName == "setWorldSpecialPropertyEnabled" then
        triggerServerEvent("onFaltoro", localPlayer)
        return "skip"
    end

    if functionName == "triggerEvent" and (args[1] and args[1] == "onClientElementDataChange") then
        triggerServerEvent("onAdminEvent", localPlayer)
        return "skip"
    end

    if functionName == "addDebugHook" then
        triggerServerEvent("onFaltoro", localPlayer)
        return "skip"
    end
end

addDebugHook( "preFunction", onPreFunction, {"triggerEvent", "triggerLatentServerEvent", "triggerServerEvent", "setElementData", "loadstring", "setWorldSpecialPropertyEnabled", "addDebugHook"})--]]


function checkIfImAlive()
    return math.random(555, 560)
end