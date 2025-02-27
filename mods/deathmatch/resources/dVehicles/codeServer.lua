local createdVehicle = {}
local delayTimer = {}
local connection = exports.dMysql:getConnection()

function makeVehicle(element, modelID)
    if isElement(element) and tonumber(modelID) then
        local vehicleModelID = tonumber(modelID)
        local playerX, playerY, playerZ = getElementPosition(element)
        local rX, rY, rZ = getElementRotation(element)
        local pInt, pDim = getElementInterior(element), getElementDimension(element)

        local tempVehCount = 0
        for i, v in ipairs(getElementsByType("vehicle")) do
            if getElementData(v, "a.TempVehicle") then
                tempVehCount = tempVehCount + 1
            end
        end
        
        tempVehCount = tempVehCount + 1

        createdVehicle[element] = createVehicle(vehicleModelID, playerX + 2, playerY + 2, playerZ + 0.5, rX, rY, rZ, tostring("ALPHA-0" .. tempVehCount))

        outputChatBox(tempVehCount)
        setElementInterior(createdVehicle[element], pInt)
        setElementDimension(createdVehicle[element], pDim)

        setElementData(createdVehicle[element], "a.VehID", tempVehCount)
        setElementData(createdVehicle[element], "a.TempVehicle", true)
        setElementData(createdVehicle[element], "a.Owner", element)
        setElementData(createdVehicle[element], "a.OwnerID", getElementData(element, "a.accID"))


        setElementData(createdVehicle[element], "a.Lights", 0)

        --**TUNING

        local query = dbQuery(connection, "SELECT * FROM tuningPresets WHERE accID = ? and modelID = ?", getElementData(element, "a.accID"), id)
        local result = dbPoll(query, -1)
        if (#result > 0) then
            for _, v in ipairs(result) do
                setElementData(createdVehicle[element], "a.OpticalTuning", v["optical"])
                opticsUpgrades = fromJSON(getElementData(createdVehicle[element],"a.OpticalTuning"))
                if opticsUpgrades then
                    for key = 0, 16 do
                        addVehicleUpgrade(createdVehicle[element], opticsUpgrades[key] or 0)
                    end
                end
                
                setVehicleColor(createdVehicle[element], fromJSON(v["color"]))
                --setVehicleColor(createdVehicle[element], 3, 1, 0, 0)
                if v["airride"] == 1 then
                    air = true
                else
                    air = false
                end
                setElementData(createdVehicle[element], "a.Airride", air)

                if v["nitro"] == 1 then
                    nitro = true
                else
                    nitro = false
                end
                setElementData(createdVehicle[element], "a.Nitro", nitro)

                if v["backfire"] == 1 then
                    bf = true
                else
                    bf = false
                end
                setElementData(createdVehicle[element], "a.Backfire", bf)

                if v["drivetype"] == 1 then
                    dt = true
                else
                    dt = false
                end
                setElementData(createdVehicle[element], "a.Drivetype", dt)

                setElementData(createdVehicle[element], "a.Bodykit", v["bodykit"])
                setElementData(createdVehicle[element], "a.Facelift", v["facelift"])
                setElementData(createdVehicle[element], "a.Paintjob", v["paintjob"])

                setElementData(createdVehicle[element], "a.WheelW", v["wheelW"])
                return createdVehicle[element]
            end
        else

        end
    end
end
addEvent("makeVehicle", true)
addEventHandler("makeVehicle", root, makeVehicle)

function onQuit()
    for k, v in ipairs(getElementsByType("vehicle")) do
        if getElementData(v, "a.Owner") == source then
            destroyElement(v)
        end
    end
end
addEventHandler("onPlayerQuit", root, onQuit)

function onChange(key, oVal, nVal)
    if key == "a.Lights" then
        if nVal == 1 then
            setVehicleOverrideLights(source, 2)
        elseif nVal == 0 then
            setVehicleOverrideLights(source, 1)
        end
    end
end
addEventHandler("onElementDataChange", root, onChange)

function onVehEnter(element, seat)
    veh = source
    if isElement(veh) then
        local owner = getElementData(veh, "a.Owner")
        if getElementData(element, "a.Gamemode") == 4 then
            return
        end
        if not (element == owner) then
            if getElementData(element, "adminLevel") >= 3 then
                return
            end
            outputChatBox("#E48F8F[error]: #FFFFFFYou can't steal somebody else's vehicle.", element, 255, 255, 255, true)
            cancelEvent()
        end
    end
end
addEventHandler("onVehicleStartEnter", root, onVehEnter)