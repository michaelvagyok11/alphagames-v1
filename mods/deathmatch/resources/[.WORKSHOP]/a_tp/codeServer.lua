function teleportPlayer(element, position)
    if element and isElement(element) then
        if position then
            if isPedInVehicle(element) then
                local vehicle = getPedOccupiedVehicle(element)
                setElementPosition(vehicle, position[1], position[2], position[3])
            else
                setElementPosition(element, position[1], position[2], position[3])
            end
            setElementData(element, "a.Money", (getElementData(element, "a.Money") - 500))
        end
    end
end
addEvent("teleportPlayer", true)
addEventHandler("teleportPlayer", root, teleportPlayer)