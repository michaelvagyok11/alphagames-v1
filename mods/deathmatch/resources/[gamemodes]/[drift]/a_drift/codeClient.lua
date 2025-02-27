local screenWidth,screenHeight = guiGetScreenSize();
local score = 0;
local multiplier = 1;
local failedDrift = false;
local fps = getFPSLimit();
local vehicle;
local inVehicle = false;
local red = tocolor(255, 0, 0);
local serverColor = tocolor(210, 160, 110);
local font = dxCreateFont("files/fonts/font.otf", 20, false, "antialiased");

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)

if fileExists("codeClient.lua") then
	fileDelete("codeClient.lua")
end

local function convertNumber (number)
	local formatted = number
	while (true) do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
		if (k == 0) then
			break
		end
	end
	return formatted
end

local function driftEnd (endscore)
	local oldBestDrift = getElementData(localPlayer,"a.bestDrift") or 0
	local oldTotalDrift = getElementData(localPlayer,"a.totalDrift") or 0
	score = 0
	
	if (endscore ~= 0) then
		local totalDriftResult = math.floor(endscore+oldTotalDrift)
		triggerServerEvent("changeDataSync", localPlayer, "a.totalDrift", math.floor(endscore+oldTotalDrift))
		triggerServerEvent("updateTotalDrift", localPlayer, totalDriftResult)
		triggerServerEvent("changeDataSync", localPlayer, "a.lastDrift", math.floor(endscore))
		local driftMoneyReward = getElementData(localPlayer, "a.lastDrift") / 250 --500
		local driftXPReward = getElementData(localPlayer, "a.lastDrift") / 375 --750

		local isPlayerVIP = getElementData(localPlayer, "a.VIP")

		if (isPlayerVIP) then
			driftMoneyReward = driftMoneyReward * 3
			driftXPReward = driftXPReward * 3
			outputChatBox("#E48F8F[Drift]: #FFFFFFElőző drift pontod: #8FC3E4" .. convertNumber(getElementData(localPlayer, "a.lastDrift")) .. "#ffffff. Kaptál: #9BE48F" .. math.round(driftMoneyReward, 0) .. "$#FFFFFF és #8FC3E4" .. math.round(driftXPReward, 0) .. "XP#FFFFFF. #C4CD5D(VIP bónusz 2x)", 255, 255, 255, true)
			triggerServerEvent("changeDataSync", localPlayer, "a.Money", getElementData(localPlayer, "a.Money") + math.round(driftMoneyReward, 0))
			triggerServerEvent("changeDataSync", localPlayer, "a.Experience", getElementData(localPlayer, "a.Experience") + math.round(driftXPReward, 0))
		else
			outputChatBox("#E48F8F[Drift]: #FFFFFFElőző drift pontod: #8FC3E4" .. convertNumber(getElementData(localPlayer, "a.lastDrift")) .. "#ffffff. Kaptál: #9BE48F" .. math.round(driftMoneyReward, 0) .. "$#FFFFFF és #8FC3E4" .. math.round(driftXPReward, 0) .. "XP#FFFFFF. (2x szorzó)", 255, 255, 255, true)
			triggerServerEvent("changeDataSync", localPlayer, "a.Money", getElementData(localPlayer, "a.Money") + math.round(driftMoneyReward, 0))
			triggerServerEvent("changeDataSync", localPlayer, "a.Experience", getElementData(localPlayer, "a.Experience") + math.round(driftXPReward, 0))
		end
	end

	if (endscore > oldBestDrift) then
		triggerServerEvent("changeDataSync", localPlayer, "a.bestDrift", endscore)
		triggerServerEvent("updateBestDrift", localPlayer, endscore)
		outputChatBox("#E48F8F[Drift]: #FFFFFFNew record: #8FC3E4" .. convertNumber(getElementData(localPlayer, "a.bestDrift")) .. "", 255, 255, 255, true)
	end
end

local function calculateAngle ()
	if not (isVehicleOnGround(vehicle)) then 
		return 0,0 
	end

	if (failedDrift) then 
		return 0,0
	end
	
	local vx,vy,vz = getElementVelocity(vehicle)
	local rx,ry,rz = getElementRotation(vehicle)
	local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
	local speed = (vx^2 + vy^2 + vz^2)^(0.5)
	local modV = math.sqrt(vx*vx + vy*vy)
	local cosX = (sn*vx + cs*vy)/modV
	
	if (modV <= 0.2) then 
		return 0,0
	end

	if (cosX > 0.966) or (cosX < 0) then 
		return 0,0 
	end
	
	return math.deg(math.acos(cosX))*0.5,speed
end

local function updateFPS(msSinceLastFrame)
    fps = (1 / msSinceLastFrame) * 1000
end

local function resetFail()
	failedDrift = false
	showScore=false
end

local function onCollide(attacker)
	if (attacker) or (failedDrift) then 
		return 
	end
	failedDrift = true
	driftEnd(0,0)
	setTimer(resetFail,2000,1)
end

local function drawMeter ()
	if localPlayer.vehicle ~= vehicle then
		removeEventHandler("onClientVehicleDamage",vehicle,onCollide)
		removeEventHandler("onClientElementDestroy",vehicle,checkVehicle)
		removeEventHandler("onClientPlayerWasted",localPlayer,checkVehicle)
		removeEventHandler("onClientRender",root,drawMeter)
		removeEventHandler("onClientPreRender", root, updateFPS)
		vehicle=nil
		inVehicle=false
		checkVehicle()
		return
	end
	
	local angle,speed = calculateAngle()
	if isTimer (resetTimer) and angle ~= 0 then
		killTimer(resetTimer)
		showScore = true
	end
	if angle == 0 then
		--dxDrawText("ANGLE 0", 500, 500, _, _)
		if not isTimer(resetTimer) then
			resetTimer = setTimer (function()
				if score == 0 then return end
				driftEnd (score)
				score = 0
				showScore = false
				
			end,2000,1)
		end
	end
	local gameSpeed = getGameSpeed()
	local fpsMultiplier = 100/fps
	local angleScore = angle/2
	local speedScore = speed*3
	local driftScore = angleScore*speedScore
	local addScore = math.floor(driftScore*multiplier)
	local gameSpeedFixedScore = math.floor(gameSpeed*addScore)
	score = score + math.floor(fpsMultiplier*gameSpeedFixedScore)
	if showScore then
		finalScore = convertNumber(score)
		local color = (failedDrift and red or serverColor)
        dxDrawBorderedText (1, finalScore, screenWidth/2,-100,screenWidth/2,screenHeight/4,color,0.95,font,"center","center")
	end
end

function checkVehicle(vehicleEntered)
	if (getElementData(localPlayer, "a.Gamemode") ~= 3) then return end
	if localPlayer.inVehicle == inVehicle then return end

	local tempVehicle = vehicleEntered or getPedOccupiedVehicle(localPlayer)
	local seat = getPedOccupiedVehicleSeat(localPlayer)
	inVehicle = ((seat == 0) and (localPlayer.inVehicle or false) or false)
	if (inVehicle) and (seat == 0) then
		vehicle = tempVehicle
		addEventHandler("onClientVehicleDamage",vehicle,onCollide)
		addEventHandler("onClientElementDestroy",vehicle,checkVehicle)
		addEventHandler("onClientPlayerWasted",localPlayer,checkVehicle)
		addEventHandler("onClientRender",root,drawMeter)
		addEventHandler("onClientPreRender", root, updateFPS)
	elseif not (inVehicle) and (vehicle) then
		removeEventHandler("onClientVehicleDamage",vehicle,onCollide)
		removeEventHandler("onClientElementDestroy",vehicle,checkVehicle)
		removeEventHandler("onClientPlayerWasted",localPlayer,checkVehicle)
		removeEventHandler("onClientRender",root,drawMeter)
		removeEventHandler("onClientPreRender", root, updateFPS)
		vehicle=nil
	end
end

function dxDrawBorderedText (outline, text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    for oX = (outline * -1), outline do
        for oY = (outline * -1), outline do
            dxDrawText (text, left + oX, top + oY, right + oX, bottom + oY, tocolor(0, 0, 0, 255), scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
        end
    end
    dxDrawText (text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end

function math.round(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end

local function initScript()
	checkVehicle()
	addEventHandler("onClientPlayerVehicleEnter",localPlayer,checkVehicle)
	addEventHandler("onClientPlayerVehicleExit",localPlayer,checkVehicle)
end

addEventHandler("onClientResourceStart",resourceRoot,initScript)

function onChange(key, oval, nval)
	if key == "a.Gamemode" then
		if nval == 3 then
			disableCollision(source)
		else
			enableCollision(source)
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

function onEnterVeh(ped)
	if getElementData(ped, "a.Gamemode") == 3 then
		disableCollision(source)
		disableCollision(ped)
	end
end
addEventHandler("onClientVehicleEnter", root, onEnterVeh)

function onExitVeh(ped)
	if getElementData(ped, "a.Gamemode") == 3 then
		enableCollision(source)
		enableCollision(ped)
	end
end
addEventHandler("onClientVehicleExit", root, onExitVeh)

function disableCollision(element)
    if getElementType(element) == "player" then
        for k, v in ipairs(getElementsByType("player")) do
            setElementCollidableWith(v, element, false)
        end
    elseif getElementType(element) == "vehicle" then
        for k, v in ipairs(getElementsByType("vehicle")) do
            setElementCollidableWith(v, element, false)
        end
    end
end

function enableCollision(element)
    if getElementType(element) == "player" then
        for k, v in ipairs(getElementsByType("player")) do
            setElementCollidableWith(v, element, true)
        end
    elseif getElementType(element) == "vehicle" then
        for k, v in ipairs(getElementsByType("vehicle")) do
            setElementCollidableWith(v, element, true)
        end
    end
end