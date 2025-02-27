local connection = exports.a_mysql:getConnection()
local tuningMarker = {}

function onStart()
    for k, v in ipairs(tuningMarkerPositions) do
        tuningMarker[k] = createMarker(v[1], v[2], v[3] - 0.9, "cylinder", 3, 50, 120, 255, 30)
        setElementDimension(tuningMarker[k], 3)
        setElementData(tuningMarker[k], "a.Tuningmarker", true)
        setElementData(tuningMarker[k], "a.TuningmarkerID", tonumber(k))
        setElementData(tuningMarker[k], "a.TuningMarkerInUse", false)
    end
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function serverSideResponse(element, arg1, ...)
    if isElement(element) then
        local vehicle = getPedOccupiedVehicle(element)
        if vehicle and arg1 == "saveOpticalTuning" then
            args = {...}
            number = args[1]
            if number == 0 then
                number = number + 1
                local upgradeTable = getVehicleCompatibleUpgrades(vehicle, args[2])
                removeVehicleUpgrade(vehicle, upgradeTable[number])

                local optics = {}
				for index = 0, 16 do
					optics[index] = getVehicleUpgradeOnSlot(vehicle, index)
				end
				local opticsUpgrades = toJSON{optics[0], optics[1], optics[2], optics[3], optics[4], optics[5], optics[6], optics[7], optics[8], optics[9], optics[10], optics[11], optics[12], optics[13], optics[14], optics[15]}
				
				setElementData(vehicle,"a.OpticalTuning", opticsUpgrades)
            else
                local upgradeTable = getVehicleCompatibleUpgrades(vehicle, args[2])
                addVehicleUpgrade(vehicle, upgradeTable[number])

                local optics = {}
				for index = 0, 16 do
					optics[index] = getVehicleUpgradeOnSlot(vehicle, index)
				end
				local opticsUpgrades = toJSON{optics[0], optics[1], optics[2], optics[3], optics[4], optics[5], optics[6], optics[7], optics[8], optics[9], optics[10], optics[11], optics[12], optics[13], optics[14], optics[15]}
				
				setElementData(vehicle,"a.OpticalTuning", opticsUpgrades)
            end
        elseif vehicle and arg1 == "airride" then
            args = {...}
            if args[1] == 1 then
                setElementData(vehicle, "a.Airride", true)
            else
                setElementData(vehicle, "a.Airride", false)
            end
        elseif vehicle and arg1 == "nitro" then
            args = {...}
            if args[1] == 1 then
                setElementData(vehicle, "a.Nitro", true)
            else
                setElementData(vehicle, "a.Nitro", false)
            end
        elseif vehicle and arg1 == "bf" then
            args = {...}
            if args[1] == 1 then
                setElementData(vehicle, "a.Backfire", true)
            else
                setElementData(vehicle, "a.Backfire", false)
            end
        elseif vehicle and arg1 == "drivetype" then
            args = {...}
            if args[1] == 1 then
                setElementData(vehicle, "a.Drivetype", true)
            else
                setElementData(vehicle, "a.Drivetype", false)
            end
        --[[elseif vehicle and arg1 == "repaint" then
            args = {...}
            local r, g, b, r2, g2, b2, _, _, _, _, _, _ = getVehicleColor(vehicle, true)
            outputChatBox(args[2] .. " " .. args[3] .. " " .. args[4], element, 255, 255, 255)
            if args[1] == 1 then
                setVehicleColor(vehicle, args[2], args[3] , args[4])
            elseif args[1] == 2 then
                setVehicleColor(vehicle, r, g, b, args[2], args[3], args[4])
            end]]--
        elseif vehicle and arg1 == "bodykit" then
            args = {...}
            if args[1] == 0 then
                setVehicleVariant(vehicle, 255, 255)
                setElementData(vehicle, "a.Bodykit", 0)
            else
                setVehicleVariant(vehicle, args[1], 0)
                setElementData(vehicle, "a.Bodykit", args[1])
            end
        end
    end
end
addEvent("serverResponse", true)
addEventHandler("serverResponse", root, serverSideResponse)

local delayTimer = {}

function saveTuningPreset(element)
    if isElement(element) then
        local veh = getPedOccupiedVehicle(element)
        if veh then
            delayTimer[element] = setTimer(function()
                local modelid = getElementModel(veh)
                local optical = getElementData(veh, "a.OpticalTuning") or "[[ ]]"

                local r, g, b, r2, g2, b2 = getVehicleColor(veh, true)
                local currentColor = {}
                table.insert(currentColor, r)
                table.insert(currentColor, g)
                table.insert(currentColor, b)
                table.insert(currentColor, r2)
                table.insert(currentColor, g2)
                table.insert(currentColor, b2)
                local color = toJSON(currentColor)

                local airride = getElementData(veh, "a.Airride")
                if airride == true then
                    air = 1
                else
                    air = 0
                end

                local nitro = getElementData(veh, "a.Nitro")
                if nitro == true then
                    nitroo = 1
                else
                    nitroo = 0
                end

                local backfire = getElementData(veh, "a.Backfire")
                if backfire == true then
                    bf = 1
                else
                    bf = 0
                end

                local drivetype = getElementData(veh, "a.Drivetype")
                if drivetype == true then
                    dt = 1
                else
                    dt = 0
                end

                local bodykit = getElementData(veh, "a.Bodykit")

                local facelift = getElementData(veh, "a.Facelift")
                if facelift == true then
                    facelift = 1
                else
                    facelift = 0
                end

                local paintjob = getElementData(veh, "a.Paintjob")
                if paintjob == true then
                    paintjob = 1
                else
                    paintjob = 0
                end

                local wheelw = getElementData(veh, "a.WheelWidth")
                if wheelw == true then
                    wheelw = 1
                else
                    wheelw = 0
                end

                local query = dbQuery(connection, "SELECT * FROM tuningPresets WHERE accID = ? and modelID = ?", getElementData(element, "a.accID"), modelid)
                local result = dbPoll(query, -1)
                if (#result > 0) then
                    db = dbExec(connection, "UPDATE tuningPresets SET optical=?, color=?, airride=?, nitro=?, backfire=?, drivetype=?, bodykit=?, facelift=?, paintjob=?, wheelW=? WHERE accID = ? and modelID = ?", optical, color, air, nitroo, bf, dt, bodykit, facelift, paintjob, wheelw, getElementData(element, "a.accID"), modelid)
                else
                    db = dbExec(connection, "INSERT INTO tuningPresets SET accID=?, modelID=?, optical=?, color=?, airride=?, nitro=?, backfire=?, drivetype=?, bodykit=?, facelift=?, paintjob=?, wheelW=?", getElementData(element, "a.accID"), modelid, optical, color, air, nitroo, bf, dt, bodykit, facelift, paintjob, wheelw, getElementData(element, "a.accID"), modelid)
                end
            end, 250, 1)
        end
    end
end
addEvent("saveTuningPreset", true)
addEventHandler("saveTuningPreset", root, saveTuningPreset)

function interpolateAirride()
	local nowTick2 = getTickCount()
	local elapsedTime = nowTick2 - airrideTick
	local duration = elapsedTime / 2500
	airlevel = interpolateBetween(currentAir, 0, 0, targetAir, 0, 0, duration, "Linear")
	setVehicleHandling(getPedOccupiedVehicle(player), "suspensionLowerLimit", airlevel)
end

local renderTimer = {}
local changeTimer = {}

function changeAirride(element, target)
    if isTimer(changeTimer[element]) then
        return
    end
    player = element
    targetAir = target
    airrideTick = getTickCount()
    model = getElementModel(getPedOccupiedVehicle(player))
    currentAir = getOriginalHandling(model)
    currentAir = getElementData(getPedOccupiedVehicle(player), "a.AirrideFloat") or currentAir["suspensionLowerLimit"]
    renderTimer[element] = setTimer(interpolateAirride, 50, 0)
    setElementData(getPedOccupiedVehicle(element), "a.AirrideFloat", targetAir)
    changeTimer[element] = setTimer(function()
        if isTimer(renderTimer[element]) then
            killTimer(renderTimer[element])
        end
    end, 2500, 1)
end
addEvent("changeAirride", true)
addEventHandler("changeAirride", root, changeAirride)

function setVehicleHandlingFlags(vehicle, byte, value)
	if vehicle then
		local handlingFlags = string.format("%X", getVehicleHandling(vehicle)["handlingFlags"])
		local reversedFlags = string.reverse(handlingFlags) .. string.rep("0", 8 - string.len(handlingFlags))
		local currentByte, flags = 1, ""
		
		for values in string.gmatch(reversedFlags, ".") do
			if type(byte) == "table" then
				for _, v in ipairs(byte) do
					if currentByte == v then
						values = string.format("%X", tonumber(value))
					end
				end
			else
				if currentByte == byte then
					values = string.format("%X", tonumber(value))
				end
			end
			
			flags = flags .. values
			currentByte = currentByte + 1
		end
		
		setVehicleHandling(vehicle, "handlingFlags", tonumber("0x" .. string.reverse(flags)), false)
	end
end

function testCommand2(e, c, type)
    setVehicleHandlingFlags(getPedOccupiedVehicle(e), {3, 4}, tonumber(type))
end
addCommandHandler("testwide", testCommand2)

--[[addEvent("tuning->WheelWidth", true)
addEventHandler("tuning->WheelWidth", root, function(vehicle, side, type)
	if vehicle then
		if type then
			if type == "verynarrow" then type = 1
				elseif type == "narrow" then type = 2
				elseif type == "wide" then type = 4
				elseif type == "verywide" then type = 8
				elseif type == "default" then type = 0
			end
			if side then
				if side == "front" then
					setVehicleHandlingFlags(vehicle, 3, type)
				elseif side == "rear" then
					setVehicleHandlingFlags(vehicle, 4, type)
				else
					setVehicleHandlingFlags(vehicle, {3, 4}, type)
				end
			else
				setVehicleHandlingFlags(vehicle, {3, 4}, type)
			end

			dbExec(mysql, "UPDATE vehicle SET ??=? WHERE id = ?", "wheelSize_"..side, type, vehicle:getData("veh:id"))
			vehicle:setData("veh:wheelSize_"..side, type)
		else
			--setVehicleHandlingFlags(vehicle, {3, 4}, 0)
		end
	end
end)

function loadWheelSize(vehicle)
	setVehicleHandlingFlags(vehicle, 3, vehicle:getData("veh:wheelSize_front") or 0)
	setVehicleHandlingFlags(vehicle, 4, vehicle:getData("veh:wheelSize_rear") or 0)
end]]--

function onChange(key, oVal, nVal)
    if key == "a.Bodykit" then
        if nVal == 0 then
            setVehicleVariant(source, 255, 255)
        else
            setVehicleVariant(source, nVal, 0)
        end
    end
end
addEventHandler("onElementDataChange", root, onChange)

function disableQuit(ped, seat)
    if ped and seat == 0 then
        if getElementData(ped, "a.TuningProgress") == true then
            cancelEvent()
        end
    end
end
addEventHandler("onVehicleStartExit", root, disableQuit)