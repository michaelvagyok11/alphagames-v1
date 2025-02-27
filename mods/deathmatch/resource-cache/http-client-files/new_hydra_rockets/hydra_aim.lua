local specialAim = false
local timer

local function dxDrawCircle( posX, posY, radius, width, angleAmount, startAngle, stopAngle, color, postGUI )
	if ( type( posX ) ~= "number" ) or ( type( posY ) ~= "number" ) then
		return false
	end
	
	local function clamp( val, lower, upper )
		if ( lower > upper ) then lower, upper = upper, lower end
		return math.max( lower, math.min( upper, val ) )
	end
	
	radius = type( radius ) == "number" and radius or 50
	width = type( width ) == "number" and width or 5
	angleAmount = type( angleAmount ) == "number" and angleAmount or 1
	startAngle = clamp( type( startAngle ) == "number" and startAngle or 0, 0, 360 )
	stopAngle = clamp( type( stopAngle ) == "number" and stopAngle or 360, 0, 360 )
	color = color or tocolor( 255, 255, 255, 200 )
	postGUI = type( postGUI ) == "boolean" and postGUI or false
	
	if ( stopAngle < startAngle ) then
		local tempAngle = stopAngle
		stopAngle = startAngle
		startAngle = tempAngle
	end
	
	for i = startAngle, stopAngle, angleAmount do
		local startX = math.cos( math.rad( i ) ) * ( radius - width )
		local startY = math.sin( math.rad( i ) ) * ( radius - width )
		local endX = math.cos( math.rad( i ) ) * ( radius + width )
		local endY = math.sin( math.rad( i ) ) * ( radius + width )
	
		dxDrawLine( startX + posX, startY + posY, endX + posX, endY + posY, color, width, postGUI )
	end
	
	return true
end

local function renderHydraAim()

	if not localPlayer.vehicle then return end
	if localPlayer.vehicle.model ~= 520 then return end
	
	local hydra = localPlayer.vehicle
	local vector = hydra.matrix.position + hydra.matrix.forward*200
	local x,y,z = vector.x,vector.y,vector.z
	if x and y and z then
		local sx,sy = getScreenFromWorldPosition(x,y,z)
		if sx and sy then
			dxDrawCircle(sx,sy,2.5,2.5)
		end
	end

end

local function shootMissile()
	if not specialAim then return end
	if getControlState("handbrake") then return end
	if localPlayer.vehicle.model ~= 520 then return end
	if timer and isTimer(timer) then return end
	timer = setTimer(function() end,500,1)
	
	local hydra = localPlayer.vehicle
	createProjectile(localPlayer,19,hydra.matrix.position+hydra.matrix.forward*15,0,nil,hydra.matrix.rotation,15*hydra.matrix.forward)

end

local function toggleForLock(key,state)
	
	if not specialAim then return end
	toggleControl("vehicle_secondary_fire",(state == "down" and true or false))

end

local function switchMod()

	specialAim = not specialAim
	
	if specialAim then
		addEventHandler("onClientRender",root,renderHydraAim)
		bindKey("vehicle_secondary_fire","down",shootMissile)
		bindKey("handbrake","down",toggleForLock)
		bindKey("handbrake","up",toggleForLock)
		toggleControl("vehicle_secondary_fire",false)
	else
		removeEventHandler("onClientRender",root,renderHydraAim)
		unbindKey("vehicle_secondary_fire","down",shootMissile)
		unbindKey("handbrake","down",toggleForLock)
		unbindKey("handbrake","up",toggleForLock)
		toggleControl("vehicle_secondary_fire",true)
	end

end

local function updateVehicle(vehicle)

	if vehicle and isElement(vehicle) and vehicle.model ~= 520 and eventName ~= "onClientPlayerWasted" then return end

	if eventName == "onClientPlayerVehicleEnter" then
		bindKey("mouse_wheel_up","down",switchMod)
		bindKey("mouse_wheel_down","down",switchMod)
		removeEventHandler("onClientPlayerVehicleEnter",localPlayer,updateVehicle)
		addEventHandler("onClientPlayerVehicleExit",localPlayer,updateVehicle)
		addEventHandler("onClientPlayerWasted",localPlayer,updateVehicle)
		if specialAim then switchMod() end
	elseif eventName == "onClientPlayerVehicleExit" or eventName == "onClientPlayerWasted" then
		unbindKey("mouse_wheel_up","down",switchMod)
		unbindKey("mouse_wheel_down","down",switchMod)
		addEventHandler("onClientPlayerVehicleEnter",localPlayer,updateVehicle)
		removeEventHandler("onClientPlayerVehicleExit",localPlayer,updateVehicle)
		removeEventHandler("onClientPlayerWasted",localPlayer,updateVehicle)
		if specialAim then switchMod() end
	end

end

local function initScript()

	if localPlayer.vehicle and localPlayer.vehicle.model == 520 then
		addEventHandler("onClientPlayerVehicleExit",localPlayer,updateVehicle)
		addEventHandler("onClientPlayerWasted",localPlayer,updateVehicle)
		bindKey("mouse_wheel_up","down",switchMod)
		bindKey("mouse_wheel_down","down",switchMod)
		removeEventHandler("onClientPlayerVehicleEnter",localPlayer,updateVehicle)
	else
		addEventHandler("onClientPlayerVehicleEnter",localPlayer,updateVehicle)
	end

end

addEventHandler("onClientResourceStart",resourceRoot,initScript)