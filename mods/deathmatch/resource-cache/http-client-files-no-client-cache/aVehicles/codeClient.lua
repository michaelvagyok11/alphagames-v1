function onKey(key, state)
    if key == "l" and state and isPedInVehicle(localPlayer) then
        if isChatBoxInputActive() or isConsoleActive() then
            return
        end
        local veh = getPedOccupiedVehicle(localPlayer)
        if getElementData(veh, "a.Lights") == 0 then
            setElementData(veh, "a.Lights", 1)
        else
            setElementData(veh, "a.Lights", 0)
        end
    end
end
addEventHandler("onClientKey", root, onKey)