function onKey(key, state)
    if key == "l" and state and isPedInVehicle(localPlayer) then
        if isChatBoxInputActive() or isConsoleActive() then
            return
        end
        local veh = getPedOccupiedVehicle(localPlayer)
        if getElementData(veh, "a.Lights") == 0 then
            triggerServerEvent("changeDataSync", veh, "a.Lights", 1)
        else
            triggerServerEvent("changeDataSync", veh, "a.Lights", 0)
        end
    end
end
addEventHandler("onClientKey", root, onKey)

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)