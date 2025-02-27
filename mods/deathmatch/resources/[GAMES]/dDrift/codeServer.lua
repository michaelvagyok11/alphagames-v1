local databaseConnection = exports.dMysql:getConnection()
local spawnPosition = {-323.4208984375, 1522.7822265625, 75.359375};

function onChange(key, oVal, nVal)
    if (key == "a.Gamemode") then
        if (nVal == 3) then
            setElementDimension(source, 3)
            setElementPosition(source, spawnPosition[1], spawnPosition[2], spawnPosition[3])
			setElementData(source, "a.DMRespawnpos", spawnPosition)
        end

		if (nVal == 3) then
			toggleControl(source, "fire", false)
			toggleControl(source, "action", false)
		end
    end
end
addEventHandler("onElementDataChange", root, onChange)

function vehicleSpawner(hitElement,matchingDimension)
	if getElementType(hitElement) == "player" then
		if getPedOccupiedVehicle(hitElement) == false then
		local x,y,z = getElementPosition(hitElement)
			local veh = createVehicle(562, x,y,z)
			warpPedIntoVehicle(hitElement,veh)
		end
	end 
end 
addEventHandler("onMarkerHit",vehMark,vehicleSpawner)

function setTotalDriftServer(totalDriftResult)
	dbExec(databaseConnection, "UPDATE accounts SET totalDrift = '" .. totalDriftResult .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
end

addEvent ("updateTotalDrift", true)
addEventHandler ("updateTotalDrift", root, setTotalDriftServer)

function setBestDriftServer(bestDriftResult)
	dbExec(databaseConnection, "UPDATE accounts SET bestDrift = '" .. bestDriftResult .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
end

addEvent ("updateBestDrift", true)
addEventHandler ("updateBestDrift", root, setBestDriftServer)