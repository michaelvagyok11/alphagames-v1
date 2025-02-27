local connection = exports.a_mysql:getConnection();

function requestServerResponse(element, str, ...)
    if isElement(element) and tostring(str) then
        if isPedInVehicle(element) then
            vehicle = getPedOccupiedVehicle(element)
        end
        if str == "fixveh" and vehicle then
            fixVehicle(vehicle)
            outputChatBox("Successful fix.", element, 255, 255, 255, true)
        elseif str == "buyveh" then
            if isPedInVehicle(element) then
                return
            end
            args = {...}
            local vehTable = getElementData(element, "a.BoughtVehs") or {}
            if isValueInTable(vehTable, tonumber(args[1]), 0) then
                outputChatBox("#E48F8F► Hiba: #FFFFFFMár megvásároltad ez a járművet.", 255, 255, 255, true)
                return
            else
                table.insert(vehTable, args[1])
                setElementData(element, "a.BoughtVehs", vehTable)
                dbExec(connection, "UPDATE accounts SET unlockedVehs = '" .. toJSON(getElementData(element, "a.BoughtVehs")) .. "' WHERE serial = '" .. getPlayerSerial(element) .. "'")
                outputChatBox("#9BE48F► Siker: #FFFFFFSikeresen megvásároltad ezt a járművet, mostmár le tudod hívni, ha mégegyszer a nevére kattintasz.", element, 255, 255, 255, true)
                setElementData(element, "a.Money", getElementData(element, "a.Money") - tonumber(args[2]))
            end
        elseif str == "requestveh" then
            if isPedInVehicle(element) then
                return
            end
            args = {...}
            exports.a_vehicles:makeVehicle(element, tonumber(args[1]))
        elseif str == "unflip" and vehicle then
            setElementRotation(vehicle, 0, 0, 0)
            outputChatBox("#9BE48F► Siker: #FFFFFFSikeresen visszafordítottad a járművedet.", element, 255, 255, 255, true)
        elseif str == "repaint" and vehicle and (...) then
            args = {...}
            local vehColorR, vehColorG, vehColorB, vehColorR2, vehColorG2, vehColorB2, _, _, _, _, _, _ = getVehicleColor(vehicle, true)
            if args[1] == "first" then
                setVehicleColor(vehicle, args[2], args[3], args[4], vehColorR2, vehColorG2, vehColorB2)
                --outputChatBox("Vehicle first color set to " .. args[2] .. ", " .. args[3] .. ", " .. args[4], element)
            elseif args[1] == "second" then
                setVehicleColor(vehicle, vehColorR, vehColorG, vehColorB, args[2], args[3], args[4])
                --outputChatBox("Vehicle second color set to " .. args[2] .. ", " .. args[3] .. ", " .. args[4], element)
            elseif args[1] == "lights" then
                setVehicleHeadLightColor(vehicle, args[2], args[3], args[4])
                --outputChatBox("Vehicle headlight color set to " .. args[2] .. ", " .. args[3] .. ", " .. args[4], element)
            end
            --local vehColorR, vehColorG, vehColorB, vehColorR2, vehColorG2, vehColorB2, _, _, _, _, _, _ = getVehicleColor(vehicle, true)
           -- outputChatBox("CURRENT COLOR: " .. vehColorR .. " " .. vehColorG .. " " .. vehColorB .. " " .. vehColorR2 .. " " .. vehColorG2 .. " " .. vehColorB2)
        elseif str == "driftmode" and vehicle and (...) then
            args = {...}
            setElementData(element, "a.Driftmode", tostring(args[1]))
            if args[1] == "on" then
                setVehicleHandling(vehicle, "driveType", "rwd")
                setVehicleHandling(vehicle, "tractionMultiplier", 0.8)
                setVehicleHandling(vehicle, "tractionBias", 0.4)
            end
        else
            --outputChatBox("mia gecim van ezzel a fossal")
        end
    end
end
addEvent("requestServerResponse", true)
addEventHandler("requestServerResponse", root, requestServerResponse)

function lightSwitch(element, commandname)
    if isElement(element) and isPedInVehicle(element) then
        local veh = getPedOccupiedVehicle(element);
        if getVehicleLightState(veh, 0) == 1 or getVehicleLightState(veh, 1) == 1 then
            setVehicleOverrideLights(veh, 1)
        else
            setVehicleOverrideLights(veh, 2)
        end
    end
end
addCommandHandler("lights", lightSwitch)

function testDim(e, cmd)
    outputChatBox("server:" .. getElementDimension(e), e, 255, 200, 200, true)
end
addCommandHandler("testdim", testDim)

function isValueInTable(theTable,value,columnID)
    assert(theTable, "Bad argument 1 @ isValueInTable (table expected, got " .. type(theTable) .. ")")
    local checkIsTable = type(theTable)
    assert(checkIsTable == "table", "Invalid value type @ isValueInTable (table expected, got " .. checkIsTable .. ")")
    assert(value, "Bad argument 2 @ isValueInTable (value expected, got " .. type(value) .. ")")
    assert(columnID, "Bad argument 3 @ isValueInTable (number expected, got " .. type(columnID) .. ")")
    local checkIsID = type(columnID)
    assert(checkIsID == "number", "Invalid value type @ isValueInTable (number expected, got " ..checkIsID .. ")")
    for i,v in ipairs (theTable) do
        if v == value then
            return true,i
        end
    end
    return false
end