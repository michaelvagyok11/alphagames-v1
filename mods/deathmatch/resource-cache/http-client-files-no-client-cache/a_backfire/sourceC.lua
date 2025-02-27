local vehBackfires = {}

local vehicleFireTick = 0
local enabledVehicles = {
	[527] = true,
	[503] = true,
	[426] = true,
	[566] = true,
	[579] = true,
	[540] = true,
	[489] = true,
	[602] = true,
	[541] = true,
	[402] = true,
}

function getPositionFromElementOffset(element, x, y, z)
	local m = getElementMatrix(element)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		   x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		   x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end


function getElementSpeed(element)
	local vx,vy,vz = getElementVelocity(element)
    return (vx * vx + vy * vy + vz * vz) * 0.5
end

function isHaveBackfire(vehicle)
  return vehBackfires[vehicle]
end

addEvent("onBackFire", true)
addEventHandler("onBackFire", getRootElement(), 
	function()
		if isElement(source) then
			if not getElementData(source, "vehicle.backfire") then 
      			return 
      		end
			local s = playSound3D("sound/" .. math.random(1,12) .. ".wav", getElementPosition(source))
			setElementDimension(s, getElementDimension(localPlayer))
			local length = 200
			setSoundVolume(s, 0.7)
			local fireTexNum = math.random(1,8)
			for k = 1, 2 do 
				local vehX, vehY, vehZ = getElementPosition(source)
				local exhaustX, exhaustY, exhaustZ = getVehicleModelExhaustFumesPosition((getElementModel(source)))
				table.insert(vehBackfires, {
					fireTexNum,
					source,
					getTickCount(),
					exhaustX, 
					exhaustY, 
					exhaustZ,
					length
				})
			end
			if bitAnd(getVehicleHandling(source).modelFlags, 8192) == 8192 then
				for k = 1, 2 do
					local vehX, vehY, vehZ = getElementPosition(source)
					local exhaustX, exhaustY, exhaustZ = getVehicleModelExhaustFumesPosition((getElementModel(source)))
					table.insert(vehBackfires, {
						fireTexNum,
						source,
						getTickCount(),
						-exhaustX,
						exhaustY,
						exhaustZ,
						length
					})
				end
			end
		end
	end
)

local fireTex = false
local sparkTex = false
addEventHandler("onClientResourceStart", resourceRoot,
	function()
		fireTex = dxCreateTexture("images/fire.dds", "dxt3")
		sparkTex = dxCreateTexture("images/spark.dds", "dxt3")
	end
)

addEventHandler("onClientElementDataChange", getRootElement(), 
	function(_ARG_0_)
  		if source == getPedOccupiedVehicle(localPlayer) and (string.find(_ARG_0_, "vehicle.tuning") or _ARG_0_ == "vehicle.backfire") then
			vehicleTuning = 0
			vehicleTuning = vehicleTuning + (getElementData(source, "vehicle.tuning.ECU") or 0)
			vehicleTuning = vehicleTuning + (getElementData(source, "vehicle.tuning.Engine") or 0)
			vehicleTuning = vehicleTuning + (getElementData(source, "vehicle.tuning.Turbo") or 0)
			vehicleTuning = vehicleTuning + (getElementData(source, "vehicle.tuning.Transmission") or 0)
			if getElementData(source, "vehicle.backfire") ~= 1 then
				vehicleTuning = 0
			end
		end
	end
)

addCommandHandler("bf", function() 

	--triggerServerEvent("onBackFire", getPedOccupiedVehicle(localPlayer), getElementsByType("player", getRootElement(), true))
end)

function processBackfire()
	for k = 1, #vehBackfires do
    	if vehBackfires[k] then
      		if isElement(vehBackfires[k][2]) then
      			if getPedOccupiedVehicle(localPlayer) then
	      			if not getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.backfire") then 
	      				return 
	      			end
	      		end
				local startX, startY, startZ = getPositionFromElementOffset(vehBackfires[k][2], vehBackfires[k][4], vehBackfires[k][5], vehBackfires[k][6])
				local startX2, startY2, startZ2 = getPositionFromElementOffset(vehBackfires[k][2], vehBackfires[k][4], vehBackfires[k][5] - 0.4, vehBackfires[k][6])
				local endX, endY, endZ = getPositionFromElementOffset(vehBackfires[k][2], vehBackfires[k][4], vehBackfires[k][5] - 0.8, vehBackfires[k][6])
				local endX2, endY2, endZ2 = endX, endY, endZ
				local faceX, faceY, faceZ = 0, 0, 0
				local camX, camY, camZ = getCameraMatrix()
				local rot = Vector3(getElementRotation(vehBackfires[k][2]))
				
				local angleStep = 360 / 8
				local elapsedTime = getTickCount() - vehBackfires[k][3]
				local random = math.random(1,8)
				for i = 1, 8 do
					local angle = math.rad(angleStep * i) + (random/22.5)
					local x = math.sin(angle)
					local y = math.cos(angle)
					faceX, faceY, faceZ = getPositionFromElementOffset(vehBackfires[k][2], vehBackfires[k][4] + x, vehBackfires[k][5], vehBackfires[k][6] + y)
					local v = 0
					local vsize = 256
					local halfTime = vehBackfires[k][7]/2
					if (getTickCount() - vehBackfires[k][3]) >= vehBackfires[k][7]/2 then
						endX2, endY2, endZ2 = interpolateBetween(endX, endY, endZ, startX2, startY2, startZ2, (elapsedTime-halfTime)/(vehBackfires[k][7] - halfTime), "Linear")
						v = interpolateBetween(0, 0, 0, 128, 0, 0, (elapsedTime-halfTime)/(vehBackfires[k][7] - halfTime), "Linear")
					else
						vsize = ((256/vehBackfires[k][7]) * elapsedTime)*2
					end
					if vsize > 256 then
						vsize = 256
					elseif vsize < 0 then
						vsize = 0
					end
					if v > 128 then
						v = 128
					elseif v < 0 then
						v = 0
					end
					dxSetBlendMode("add")
					dxDrawMaterialSectionLine3D(
						endX2, endY2, endZ2,
						startX, startY, startZ,
						128 * (vehBackfires[k][1] - 1), v, 128, vsize,
						fireTex, 0.4, tocolor(255, 255, 255, 120),
						faceX, faceY, faceZ
					)
					dxSetBlendMode("blend")
				end
				
				if getTickCount() - vehBackfires[k][3] > vehBackfires[k][7] then
					vehBackfires[k] = nil
				end
			else
				vehBackfires[k] = nil
			end
		end
	end
	if getPedOccupiedVehicle(localPlayer) and getPedOccupiedVehicleSeat(localPlayer) == 0 then
		if getPedOccupiedVehicle(localPlayer) ~= vehGearSecond then
			vehGearFirst, vehGearSecond = getVehicleCurrentGear((getPedOccupiedVehicle(localPlayer))), getPedOccupiedVehicle(localPlayer)
			vehicleTuning = 0
			vehicleTuning = vehicleTuning + (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.tuning.ECU") or 0)
			vehicleTuning = vehicleTuning + (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.tuning.Engine") or 0)
			vehicleTuning = vehicleTuning + (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.tuning.Turbo") or 0)
			vehicleTuning = vehicleTuning + (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.tuning.Transmission") or 0)
			if getElementData(getPedOccupiedVehicle(localPlayer), "vehicle.backfire") ~= 1 then
				vehicleTuning = 0
			end
		end
		if vehicleTuning >= 16 and (getElementModel((getPedOccupiedVehicle(localPlayer))) == 549 or getElementModel((getPedOccupiedVehicle(localPlayer))) == 602  or getElementModel((getPedOccupiedVehicle(localPlayer))) == 502 or getElementModel((getPedOccupiedVehicle(localPlayer))) == 494) and getPedControlState("accelerate") and (getPedControlState("handbrake") or getPedControlState("brake_reverse")) and getTickCount() - vehicleFireTick > 100 then
			vehicleFireTick = getTickCount()
			triggerServerEvent("onBackFire", getPedOccupiedVehicle(localPlayer), getElementsByType("player", getRootElement(), true))
		end
		if vehGearFirst ~= getVehicleCurrentGear((getPedOccupiedVehicle(localPlayer))) then
			vehGearFirst = getVehicleCurrentGear((getPedOccupiedVehicle(localPlayer)))
			if vehicleTuning >= 16 then
				triggerServerEvent("onBackFire", getPedOccupiedVehicle(localPlayer), getElementsByType("player", getRootElement(), true))
				if getElementData(getPedOccupiedVehicle(localPlayer), "driveSelectorMode") == 4 then
					if not getPedControlState("accelerate") then
						if math.random(1, 2) == 1 then
							setTimer(
								function()
									triggerServerEvent("onBackFire", getPedOccupiedVehicle(localPlayer), getElementsByType("player", getRootElement(), true))
								end, 200, math.random(3,8)
							)
						end
					end
				end
				--[[if math.random(0, 10) >= 4 then
					setTimer(
						function()
							triggerServerEvent("onBackFire", getPedOccupiedVehicle(localPlayer), getElementsByType("player", getRootElement(), true))
						end, 500, math.random(1,2)
					)
					if math.random(0, 10) == 4 then
						setTimer(
							function()
								triggerServerEvent("onBackFire", getPedOccupiedVehicle(localPlayer), getElementsByType("player", getRootElement(), true))
							end, 200, math.random(5,10)
						)
					end
				end]]
			end
		end
	end
end
addEventHandler("onClientPreRender", getRootElement(), processBackfire)

addEventHandler("onClientElementStreamOut", getRootElement(), 
	function()
		if isElement(vehBackfires[source]) then
			destroyElement(vehBackfires[source])
		end
		vehBackfires[source] = nil
	end
)
addEventHandler("onClientElementDestroy", getRootElement(), 
	function()
		if isElement(vehBackfires[source]) then
			destroyElement(vehBackfires[source])
		end
		vehBackfires[source] = nil
	end
)