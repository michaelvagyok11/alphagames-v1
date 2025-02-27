local createdVehicle = {}
local delayTimer = {}
local connection = exports.a_mysql:getConnection()

function makeVehicle(element, modelid)
    if isElement(element) and tonumber(modelid) then
        id = tonumber(modelid)
        x, y, z = getElementPosition(element)
        rx, ry, rz = getElementRotation(element)
        int, dim = getElementInterior(element), getElementDimension(element)
        createdVehicle[element] = createVehicle(id, x + 2, y + 2, z, rx, ry, rz, (getPlayerName(element) or "alpha"))
        setElementInterior(createdVehicle[element], int)
        setElementDimension(createdVehicle[element], dim)

        setElementData(createdVehicle[element], "a.Owner", element)
        setElementCollisionsEnabled(createdVehicle[element], false)
        delayTimer[element] = setTimer(function()
            setElementCollisionsEnabled(createdVehicle[element], true)
        end, 5000, 1)
        count = 0
        for k, v in ipairs(getElementsByType("vehicle")) do
            count = count + 1
        end
        setElementData(createdVehicle[element], "a.VehID", count)

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

--[[function onVehEnter(element, seat)
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
addEventHandler("onVehicleStartEnter", root, onVehEnter)]]

function countOccupants(vehicle)
	if vehicle and getElementType(vehicle) == "vehicle" then
		local ppl = getVehicleOccupants(vehicle)
		if not ppl then
			return false
		else
			local counter = 0
			for seat, player in pairs(ppl) do
				counter = counter + 1
			end
			return counter
		end
	end
end

function destroyInactiveVehicles ()
    for k, v in ipairs(getElementsByType("vehicle")) do
        if v then
            local emptyVehicles = countOccupants(v)

            if not emptyVehicles or emptyVehicles == 0 then
                destroyElement(v)
            end
        end
    end
    outputChatBox("#D9B45A[alphaGames]: #ffffffTörlésre kerültek az üres járművek.", root, 255, 255, 255, true)
end
addCommandHandler("kurvaanyadkocsitorles", destroyInactiveVehicles)

setTimer(
    function ()
        destroyInactiveVehicles()
        outputChatBox("#D9B45A[alphaGames]: #ffffffTörlésre kerültek az üres járművek.", root, 255, 255, 255, true)
    end,
1800000, 0)

setTimer(
    function ()
        outputChatBox("#D9B45A[alphaGames]: FIGYELEM!\n[alphaGames]: #ffffffMinden jármű amiben nem ül senki törlésre kerül fél percen belül!", root, 255, 255, 255, true)
    end,
1770000, 0)