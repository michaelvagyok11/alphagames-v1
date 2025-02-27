-- Once in how many frames should the data be refreshed?
local rpf = 4

local clr = tocolor(200, 100, 100)
local clr2 = tocolor(200, 100, 100)
local clrWhite = tocolor(255,255,255)
local rpmColorR, rpmColorG, rpmColorB = 50, 50, 50


local resp = guiGetScreenSize()/720 --4
local borderSize = 0.5
local number = 0

local drawing = false
local veh = false
local speed = false
local isRenderTarget = false
local minX = 2
local nosOn = false
local scrnX, scrnY = guiGetScreenSize()
local twoDMode = false

local mph = false

infNOSTeams = {
["Admin"] = true,
}

local font = dxCreateFont("files/fonts/speedoFont.ttf", 40, false, "antialiased")

function saveConf()
	local conf = fileCreate("speed.conf")
	if conf then
		fileWrite(conf, toJSON({mph,twoDMode}))
		fileClose(conf)
	else
		outputDebugString("Speedo: Creating conf file failed!")
	end
end

function loadConf()
	if fileExists("speed.conf") then
		local conf = fileOpen("speed.conf")
		if conf then
			local confString = fileRead(conf, fileGetSize(conf))
			local array = fromJSON(confString)
			if array then
				mph = array[1]
				twoDMode = array[2]
			end
		end
	else
		saveConf()
	end
end
loadConf()

addEventHandler("onClientVehicleEnter", root,
function(player, seat)
	if player == localPlayer and isElement(source) then --and getVehicleType(source) ~= "Plane" then
		toggleSpeed(true)
	end
end)

addEventHandler("onClientVehicleExit", root,
function(player, seat)
	if player == localPlayer and isElement(source) then
		toggleSpeed(false)
	end
end)

function toggleSpeed(setTo)
	drawing = setTo
	veh = getPedOccupiedVehicle(localPlayer)
	if setTo then
		minX = getElementBoundingBox(veh)
		i = 15
		if not isElement(isRenderTarget) then 
			isRenderTarget = dxCreateRenderTarget(232 * resp, 102 * resp, true) 
		end
		addEventHandler("onClientPreRender", root, onRender)
	end
end

function onRender()
	if drawing and isElement(veh) and getPedOccupiedVehicle(localPlayer) == veh then	
		if (getTickCount() % (rpf + 1)) == 0 then
			currentVehSpeed = getSpeed()

			if currentVehSpeed > 150 then
				local _, _, _, r2, g2, b2 = getVehicleColor(veh, true)
				r, g, b = interpolateBetween(255, 255, 255, r2, g2, b2, (currentVehSpeed - 150) / 40, "Linear")
			else
				r, g, b = 255, 255, 255
			end
			
			dxSetRenderTarget(isRenderTarget, true)
			local vehSpeed = tostring(math.floor((currentVehSpeed)))

			--exports.a_core:dxDrawRoundedRectangle(505, 175, 125, 90, tocolor(2, 2, 2, 125), 5)

			dxDrawText(vehSpeed, 0, 0, 220 * resp, 90 * resp, tocolor(r, g, b, 255), 1, font, "right", "bottom", false, false, false, true)
			dxDrawText("km/h", dxGetTextWidth(vehSpeed, 5, "default-bold"), 50, 220 * resp, 100 * resp, tocolor(200, 200, 200, 255), 3, "default-bold", "right", "bottom", true)

			w = math.floor(((100/9800)* getVehicleRPM(getPedOccupiedVehicle(getLocalPlayer()))) + 0.5)
			
			if w >= 35 then
				rpmColorR, rpmColorG, rpmColorB = 200, 100, 100
			else
				rpmColorR, rpmColorG, rpmColorB = 100, 100, 100
			end
			dxDrawRectangle(594, 175 + 82, 24, -104, tocolor(2, 2, 2, 200))
			dxDrawRectangle(596, 175 + 80, 20, -w, tocolor(rpmColorR, rpmColorG, rpmColorB, 200))
			dxSetRenderTarget()
		end
		if isRenderTarget then
			x, y, z, ox, oy, oz, x2, y2, z2 = getPositionFromElementOffset(0.5, -1.5, -3, -20)
			dxDrawMaterialLine3D(x2, y2, z2, x, y, z, isRenderTarget, 2, clrWhite, ox, oy, oz)
		end
	else
		removeEventHandler("onClientPreRender", root, onRender)
	end
end

function getVehicleRPM(vehicle)
local vehicleRPM = 0
    if (vehicle) then  
        if (getVehicleEngineState(vehicle) == true) then
            if getVehicleCurrentGear(vehicle) > 0 then             
                vehicleRPM = math.floor(((getElementSpeed(vehicle, "km/h")/getVehicleCurrentGear(vehicle))*180) + 0.5) 
                if (vehicleRPM < 650) then
                    vehicleRPM = math.random(650, 750)
                elseif (vehicleRPM >= 9800) then
                    vehicleRPM = math.random(9800, 9900)
                end
            else
                vehicleRPM = math.floor((getElementSpeed(vehicle, "km/h")*180) + 0.5)
                if (vehicleRPM < 650) then
                    vehicleRPM = math.random(650, 750)
                elseif (vehicleRPM >= 9800) then
                    vehicleRPM = math.random(9800, 9900)
                end
            end
        else
            vehicleRPM = 0
        end
        return tonumber(vehicleRPM)
    else
        return 0
    end
end

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function getSpeed()
	if veh then
		local x,y,z = getElementVelocity(veh)
		if mph then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100	--MPH
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 1.8 * 100	--KPH
		end
	else
		return 0
	end
end

function getPositionFromElementOffset(offX,offY,offX2,offY2)
	local offZ = -0.5
	local m = getElementMatrix ( veh )  -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	
	local x2 = offX2 * m[1][1] + offY2 * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y2 = offX2 * m[1][2] + offY2 * m[2][2] + offZ * m[3][2] + m[4][2]
	local z2 = offX2 * m[1][3] + offY2 * m[2][3] + offZ * m[3][3] + m[4][3]
	
	offZ = 0.5
	local x3 = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y3 = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z3 = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	
	return x, y, z, x2, y2, z2, x3, y3, z3                            -- Return the transformed point
end

function getType()
	return mph
end

function HSV(h, s, v)
 
  local r, g, b
 
  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)
 
  local switch = i % 6
  if switch == 0 then
    r = v g = t b = p
  elseif switch == 1 then
    r = q g = v b = p
  elseif switch == 2 then
    r = p g = v b = t
  elseif switch == 3 then
    r = p g = q b = v
  elseif switch == 4 then
    r = t g = p b = v
  elseif switch == 5 then
    r = v g = p b = q
  end
 
  return math.floor(r*255), math.floor(g*255), math.floor(b*255)
 
end

function dxDrawBorderedText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak,postGUI)
    for oX = -borderSize, borderSize do
        for oY = -borderSize, borderSize do
            dxDrawText(text, left + oX, top + oY, right + oX, bottom + oY, tocolor(0, 0, 0, 255), scale, font, alignX, alignY, clip, wordBreak,postGUI)
        end
    end
    dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI)
end

if getPedOccupiedVehicle(localPlayer) then toggleSpeed(true) end