local sX, sY = guiGetScreenSize()
local timeSize = {200, 75}
local startX, startY = sX / 2 - timeSize[1] / 2, 10

local sX, sY = guiGetScreenSize()

function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(sX, 720, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

function getResponsiveMultipler()
	return responsiveMultipler
end

local robotoBold = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 20, false, "antialiased")
local robotoBold13 = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 15, false, "cleartype")
local robotoBold12 = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 13, false, "cleartype")
local poppinsBold = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(12), false, "cleartype")
local poppinsBold2 = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(16), false, "cleartype")
local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(25), false, "cleartype")

function onTimeRender()
    if getElementData(localPlayer, "a.Gamemode") == 4 then
        if isPanelMoving then
            local cX, cY = getCursorPosition()
            startX, startY = cX * sX - timeSize[1] + 16, cY * sY - 8
        else
            startX, startY = startX, startY
        end
        
        runnerCount = 0
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.HPTeam") == 1 then
                runnerCount = runnerCount + 1
            end
        end

        chaserCount = 0
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.HPTeam") == 2 then
                chaserCount = chaserCount + 1
            end
        end

        --exports.a_core:dxDrawRoundedRectangle(startX, startY, timeSize[1], timeSize[2], tocolor(65, 65, 65, 150), 5)
        --exports.a_core:dxDrawRoundedRectangle(startX - 2, startY - 2, timeSize[1] + 4, timeSize[2] + 4, tocolor(30, 30, 30, 100), 5)
        
        if getElementData(localPlayer, "a.HPTeam") == 1 then
            a = 200
        else
            a = 100
        end

        if getElementData(localPlayer, "a.HPTeam") == 2 then
            a2 = 200
        else
            a2 = 100
        end
        
        local startX, startY = sX / 2, respc(25)

        dxDrawText(secondsToTime(seconds) or "n/a", startX + 1, startY + respc(25) + 1, _, _, tocolor(2, 2, 2, 200), 1, poppinsBold2, "center", "center")
        dxDrawText(secondsToTime(seconds) or "n/a", startX, startY + respc(25), _, _, tocolor(200, 200, 200, 200), 1, poppinsBold2, "center", "center")

        dxDrawImage(startX - respc(35) - respc(100), startY, respc(100), respc(50), "files/img/header.png", 180, 0, 0, tocolor(215/2, 180/2, 115/2, 150))
        dxDrawText("Menekülők", startX - respc(44), startY - respc(14), _, _, tocolor(2, 2, 2, 200), 1, poppinsBold, "right", "top", false, false, false, true)
        dxDrawText("Menekülők", startX - respc(45), startY - respc(15), _, _, tocolor(200, 200, 200, 200), 1, poppinsBold, "right", "top", false, false, false, true)
        dxDrawText(runnerCount, startX - respc(55), startY + respc(25), _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldBig, "right", "center", false, false, false, true)

        dxDrawImage(startX + respc(35), startY, respc(100), respc(50), "files/img/header.png", 0, 0, 0, tocolor(115/2, 170/2, 205/2, 150))
        dxDrawText("Rendőrök", startX + respc(46), startY - respc(14), _, _, tocolor(2, 2, 2, 200), 1, poppinsBold, "left", "top", false, false, false, true)
        dxDrawText("Rendőrők", startX + respc(45), startY - respc(15), _, _, tocolor(200, 200, 200, 200), 1, poppinsBold, "left", "top", false, false, false, true)
        dxDrawText(chaserCount, startX + respc(55), startY + respc(25), _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldBig, "left", "center", false, false, false, true)
    end
end
addEventHandler("onClientRender", root, onTimeRender)

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and getElementData(localPlayer, "a.Gamemode") == 4 then
        if state == "down" then
            if isMouseInPosition(startX + timeSize[1] - 20, startY + 5, 16, 16) then
                isPanelMoving = true
            end
        end

        if state == "up" then
            isPanelMoving = false
        end
    end
end
addEventHandler("onClientClick", root, onClick)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function giveCounterC(sec)
    seconds = sec
end
addEvent("giveCounterC", true)
addEventHandler("giveCounterC", root, giveCounterC)

function startRoundClient()
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 4 then
            local veh = getPedOccupiedVehicle(v)
            disableCollision(veh)
            disableCollision(v)
        end
    end

    setTimer(function()
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Gamemode") == 4 then
                local veh = getPedOccupiedVehicle(v)
                enableCollision(v)
                enableCollision(veh)
            end
        end
    end, 10000, 1)
end
addEvent("startRoundClient", true)
addEventHandler("startRoundClient", root, startRoundClient)

function secondsToTime(seconds)
	local seconds = tonumber(seconds)
    if not tonumber(seconds) then return "00:00" end
  	if seconds <= 0 then
		return "00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return mins..":"..secs
    end
end


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
addEvent("disableCollision", true)
addEventHandler("disableCollision", root, disableCollision)

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
addEvent("enableCollision", true)
addEventHandler("enableCollision", root, enableCollision)

--** 3D BLIP

function onChange(key, oval, nval)
    if key == "a.HPTeam" then
        if nval == 2 then
            addEventHandler("onClientRender", root, process3DBlip)
            addEventHandler("onClientRender", root, process3DBlip2)
            if isTimer(blipTimer) then
                killTimer(blipTimer)
            end
            blipTimer = setTimer(function()
                if not (getElementData(localPlayer, "a.HPTeam") == 2) then
                    return
                end
                if isEventHandlerAdded("onClientRender", root, process3DBlip2) then
                    exports.a_interface:makeNotification(3, "Most #E48F8Fnem#c8c8c8 láthatod a menekülőt 15 másodpercig.")
                    --outputChatBox("#E48F8F[hotpursuit]: #FFFFFFNow you #E48F8Fcan't#FFFFFF see the runner for 15 seconds.", 255, 255, 255, true)
                    removeEventHandler("onClientRender", root, process3DBlip2)
                else
                    exports.a_interface:makeNotification(3, "Mostmár #9BE48Fláthatod#c8c8c8 a menekülőt 15 másodpercig.")
                    --outputChatBox("#9BE48F[hotpursuit]: #FFFFFFNow you #9BE48Fcan#FFFFFF see the runner for 15 seconds with a 3D blip.", 255, 255, 255, true)
                    addEventHandler("onClientRender", root, process3DBlip2)
                end
            end, 15000, 0)
        elseif nval == 0 and oval == 2 then
            removeEventHandler("onClientRender", root, process3DBlip)
        end
    end
end
addEventHandler("onClientElementDataChange", root, onChange)

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

local chaserPositions = {}

function process3DBlip()
    if not (getElementData(localPlayer, "a.HPTeam") == 2) then
        return
    end
    local nowTick = getTickCount()
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.HPTeam") == 2 then
            if isPedInVehicle(v) then
                veh = getPedOccupiedVehicle(v)
                posX, posY, posZ = getElementPosition(veh)
            else
                posX, posY, posZ = getElementPosition(v)
                posZ = posZ - 1
            end
            local x, y = getScreenFromWorldPosition(posX, posY, posZ + 3)

            local lX, lY, lZ = getElementPosition(localPlayer)
            local dist = getDistanceBetweenPoints3D(lX, lY, lZ, posX, posY, posZ)
            if x and y then
                text = getPlayerName(v)
                textwidth = dxGetTextWidth(removeHex(text, 6), 1, robotoBold12)

                dxDrawText(getPlayerName(v), x, y, _, _, tocolor(200, 200, 200, 255), 1, robotoBold12, "center", "center", false, false, false, true)
                dxDrawText(math.floor(dist) .. "m", x, y + 20, _, _, tocolor(200, 200, 200, 255), 1, robotoBold12, "center", "center", false, false, false, true)
                dxDrawImage(x - textwidth / 2 - 20, y - 8, 16, 16, "files/img/badge.png", 0, 0, 0, tocolor(140, 195, 230, 255))
            end
        end
    end
end

function process3DBlip2()
    if not (getElementData(localPlayer, "a.HPTeam") == 2) then
        return
    end
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.HPTeam") == 1 then
            if isPedInVehicle(v) then
                runnerX, runnerY, runnerZ = getElementPosition( getPedOccupiedVehicle(v) )
            else
                runnerX, runnerY, runnerZ = getElementPosition(v)
                runnerZ = runnerZ - 1
            end
            local x, y = getScreenFromWorldPosition(runnerX, runnerY, runnerZ + 3)

            local lX, lY, lZ = getElementPosition(localPlayer)
            local dist = getDistanceBetweenPoints3D(lX, lY, lZ, runnerX, runnerY, runnerZ)
            if x and y then
                text = getPlayerName(v)
                textwidth = dxGetTextWidth(removeHex(text, 6), 1, robotoBold12)

                dxDrawText(getPlayerName(v), x, y, _, _, tocolor(200, 200, 200, 255), 1, robotoBold12, "center", "center", false, false, false, true)
                dxDrawText(math.floor(dist) .. "m", x, y + 20, _, _, tocolor(200, 200, 200, 255), 1, robotoBold12, "center", "center", false, false, false, true)

                dxDrawImage(x - textwidth / 2 - 20, y - 8, 16, 16, "files/img/runner.png", 0, 0, 0, tocolor(230, 140, 140, 255))
            end
        end
    end
end

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end

local robotoBold10 = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 10, false, "cleartype")
local robotoBold12 = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 13, false, "cleartype")
local panelSize = {600, 265}

function openPursuitPanel()
    if isPursuitPanelRendered then
        isPursuitPanelRendered = false
        removeEventHandler("onClientRender", root, onPursuitPanelRender)
        removeEventHandler("onClientKey", root, onScrolling)
        removeEventHandler("onClientClick", root, onPursuitClick)

        exports.a_3dview:processSkinPreview()
        skinPreview = false
    else
        isPursuitPanelRendered = true
        openTick = getTickCount()
        skinPreview = false

        local vehTable = getElementData(localPlayer, "a.HPVehicle")
        local skinTable = getElementData(localPlayer, "a.HPSkin")

        currentSelectedSkin = {}
        currentSelectedVehicle = {}
        

        vehiclesScrolling = 0
        maxVehiclesShowing = 5
        skinsScrolling = 0
        maxSkinsShowing = 5  

        for k, v in ipairs(vehiclesToBuy) do
            if v[1] == vehTable[1] then
                currentSelectedVehicle[1] = k
            end
            if v[1] == vehTable[2] then
                currentSelectedVehicle[2] = k
            end
        end

        for k, v in ipairs(skinsToBuy) do
            if v[1] == skinTable[1] then
                currentSelectedSkin[1] = k
            end
            if v[1] == skinTable[2] then
                currentSelectedSkin[2] = k
            end
        end

        addEventHandler("onClientRender", root, onPursuitPanelRender)
        addEventHandler("onClientKey", root, onScrolling)
        addEventHandler("onClientClick", root, onPursuitClick)
    end
end
addCommandHandler("pursuit", openPursuitPanel)

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

function onPursuitPanelRender()
    if not isPursuitPanelRendered then
        return
    end

    local startX, startY = sX / 2 - panelSize[1] / 2, sY / 2 - panelSize[2] / 2
    
    local nowTick = getTickCount()
    local elapsedTime = nowTick - openTick
    local duration = elapsedTime / 2000
    a = interpolateBetween(0, 0, 0, 240, 0, 0, duration, "Linear")

    exports.a_core:dxDrawRoundedRectangle(startX, startY, panelSize[1], panelSize[2], tocolor(65, 65, 65, a), 5)
    exports.a_core:dxDrawRoundedRectangle(startX + 2, startY + 2, panelSize[1] - 4, panelSize[2] - 4, tocolor(35, 35, 35, a), 5)
    exports.a_core:dxDrawRoundedRectangle(startX, startY, panelSize[1], 25, tocolor(65, 65, 65, a), 5)
    dxDrawText("#D19D6Balpha#c8c8c8Games - #E48F8FHot Pursuit", startX + 5, startY + 25 / 2, _, _, tocolor(200, 200, 200, a), 1, robotoBold10, "left", "center", false, false, false, true)
    
    if isMouseInPosition(startX + panelSize[1] - 24, startY + 7, 13, 13) then
        dxDrawImage(startX + panelSize[1] - 24, startY + 7, 13, 13, "files/img/close.png", 0, 0, 0, tocolor(240, 100, 100, a))
    else
        dxDrawImage(startX + panelSize[1] - 24, startY + 7, 13, 13, "files/img/close.png", 0, 0, 0, tocolor(200, 200, 200, a))
    end

    exports.a_core:dxDrawRoundedRectangle(startX + 7, startY + 35, panelSize[1]/2 - 14, panelSize[2] - 45, tocolor(25, 25, 25, a), 10)
    exports.a_core:dxDrawRoundedRectangle(startX + 15, startY + 40, panelSize[1]/2 - 14 - 16, 30, tocolor(45, 45, 45, a), 15)
    dxDrawText("Vehicles", startX + 15 + (panelSize[1]/2 - 14 - 16)/2, startY + 40 + 30/2, _, _, tocolor(200, 200, 200, a), 1, robotoBold12, "center", "center", false, false, false, true)
    
    exports.a_core:dxDrawRoundedRectangle(startX + 7 + panelSize[1]/2, startY + 35, panelSize[1]/2 - 14, panelSize[2] - 45, tocolor(25, 25, 25, a), 10)
    exports.a_core:dxDrawRoundedRectangle(startX + 7 + panelSize[1]/2 + 8, startY + 40, panelSize[1]/2 - 14 - 16, 30, tocolor(45, 45, 45, a), 15)
    dxDrawText("Skins", startX + 7 + panelSize[1]/2 + 8 + (panelSize[1]/2 - 14 - 16)/2, startY + 40 + 30/2, _, _, tocolor(200, 200, 200, a), 1, robotoBold12, "center", "center", false, false, false, true)
    
    for k, v in ipairs(vehiclesToBuy) do
        if k <= maxVehiclesShowing and (k > vehiclesScrolling) then
            if isMouseInPosition(startX + 15, startY + 40 + (k-vehiclesScrolling)*35, panelSize[1]/2 - 14 - 16, 30) then
                exports.a_core:dxDrawRoundedRectangle(startX + 15, startY + 40 + (k-vehiclesScrolling)*35, panelSize[1]/2 - 14 - 16, 30, tocolor(50, 50, 50, a), 5)
            else
                exports.a_core:dxDrawRoundedRectangle(startX + 15, startY + 40 + (k-vehiclesScrolling)*35, panelSize[1]/2 - 14 - 16, 30, tocolor(40, 40, 40, a), 5)
            end

            exports.a_core:dxDrawRoundedRectangle(startX + panelSize[1]/2 - 45, startY + 40 + (k-vehiclesScrolling)*35 + 5, 20, 20, tocolor(75, 75, 75, a), 5)
            if k == currentSelectedVehicle[1] then
                dxDrawImage(startX + panelSize[1]/2 - 43, startY + 40 + (k-vehiclesScrolling)*35 + 7.5, 16, 16, "files/img/tick.png", 0, 0, 0, tocolor(100, 100, 240, a))
            end

            if k == currentSelectedVehicle[2] then
                dxDrawImage(startX + panelSize[1]/2 - 43, startY + 40 + (k-vehiclesScrolling)*35 + 7.5, 16, 16, "files/img/tick.png", 0, 0, 0, tocolor(240, 100, 100, a))
            end

            if isValueInTable(getElementData(localPlayer, "a.HPBoughtVehs"), v[1], k) then
                dxDrawImage(startX + panelSize[1]/2 - 70, startY + 40 + (k-vehiclesScrolling)*35 + 7.5, 14, 14, "files/img/tick.png", 0, 0, 0, tocolor(100, 240, 100, a/2))
            else
                if (v[4] == true) then
                    if isMouseInPosition(startX + panelSize[1]/2 - 90, startY + 40 + (k-vehiclesScrolling)*35, 40, 20) then
                        dxDrawText("VIP", startX + panelSize[1]/2 - 50, startY + 40 + (k-vehiclesScrolling)*35 + 30/2,  _, _, tocolor(200, 200, 140, a), 1, robotoBold10, "right", "center", false, false, false, true)
                    else
                        dxDrawText("VIP", startX + panelSize[1]/2 - 50, startY + 40 + (k-vehiclesScrolling)*35 + 30/2,  _, _, tocolor(200, 200, 200, a), 1, robotoBold10, "right", "center", false, false, false, true)
                    end
                else
                    if isMouseInPosition(startX + panelSize[1]/2 - 90, startY + 40 + (k-vehiclesScrolling)*35, 40, 20) then
                        dxDrawText("BUY", startX + panelSize[1]/2 - 50, startY + 40 + (k-vehiclesScrolling)*35 + 30/2,  _, _, tocolor(140, 200, 140, a), 1, robotoBold10, "right", "center", false, false, false, true)
                    else
                        dxDrawText("BUY", startX + panelSize[1]/2 - 50, startY + 40 + (k-vehiclesScrolling)*35 + 30/2,  _, _, tocolor(200, 200, 200, a), 1, robotoBold10, "right", "center", false, false, false, true)
                    end
                end
            end

            if v[4] == false then
                if isValueInTable(getElementData(localPlayer, "a.HPBoughtVehs"), v[1], k) then
                    dxDrawText(v[2], startX + 50, startY + 40 + (k-vehiclesScrolling)*35 + 30/2,  _, _, tocolor(200, 200, 200, a), 1, robotoBold10, "left", "center", false, false, false, true)
                else
                    dxDrawText(v[2] .. " #9BE48F(" .. v[5] .. "$)", startX + 50, startY + 40 + (k-vehiclesScrolling)*35 + 30/2,  _, _, tocolor(200, 200, 200, a), 1, robotoBold10, "left", "center", false, false, false, true)
                end
            else
                dxDrawText(v[2], startX + 50, startY + 40 + (k-vehiclesScrolling)*35 + 30/2,  _, _, tocolor(200, 200, 90, a), 1, robotoBold10, "left", "center", false, false, false, true)
            end

            if v[3] == "runner" then
                dxDrawImage(startX + 25, startY + 40 + (k-vehiclesScrolling)*35 + 30/4, 16, 16, "files/img/runner.png", 0, 0, 0, tocolor(230, 140, 140, a))
            else
                dxDrawImage(startX + 25, startY + 40 + (k-vehiclesScrolling)*35 + 30/4, 16, 16, "files/img/badge.png", 0, 0, 0, tocolor(140, 195, 230, a))
            end
        end
    end

    for k, v in ipairs(skinsToBuy) do
        if k <= maxSkinsShowing and (k > skinsScrolling) then
            if isMouseInPosition(startX + 7 + panelSize[1]/2 + 10, startY + 40 + (k-skinsScrolling)*35, panelSize[1]/2 - 14 - 16, 30) then
                exports.a_core:dxDrawRoundedRectangle(startX + 7 + panelSize[1]/2 + 10, startY + 40 + (k-skinsScrolling)*35, panelSize[1]/2 - 14 - 16, 30, tocolor(50, 50, 50, a), 5)
            else
                exports.a_core:dxDrawRoundedRectangle(startX + 7 + panelSize[1]/2 + 10, startY + 40 + (k-skinsScrolling)*35, panelSize[1]/2 - 14 - 16, 30, tocolor(40, 40, 40, a), 5)
            end

            exports.a_core:dxDrawRoundedRectangle(startX + panelSize[1]/2 + panelSize[1]/2 - 45, startY + 40 + (k-skinsScrolling)*35 + 5, 20, 20, tocolor(75, 75, 75, a), 5)
            
            if k == currentSelectedSkin[1] then
                dxDrawImage(startX +  panelSize[1]/2 + panelSize[1]/2 - 43, startY + 40 + (k-skinsScrolling)*35 + 7.5, 16, 16, "files/img/tick.png", 0, 0, 0, tocolor(100, 100, 240, a))
            end

            if k == currentSelectedSkin[2] then
                dxDrawImage(startX + panelSize[1]/2 + panelSize[1]/2 - 43, startY + 40 + (k-skinsScrolling)*35 + 7.5, 16, 16, "files/img/tick.png", 0, 0, 0, tocolor(240, 100, 100, a))
            end

            if isMouseInPosition(startX + panelSize[1] - 70, startY + 40 + (k-skinsScrolling)*35 + 7.5, 14, 14) then
                dxDrawImage(startX + panelSize[1] - 70, startY + 40 + (k-skinsScrolling)*35 + 7.5, 14, 14, "files/img/eye.png", 0, 0, 0, tocolor(200, 200, 200, a/2))
            else
                dxDrawImage(startX + panelSize[1] - 70, startY + 40 + (k-skinsScrolling)*35 + 7.5, 14, 14, "files/img/eye.png", 0, 0, 0, tocolor(150, 150, 150, a/2))
            end

            if v[4] == false then
                dxDrawText(v[2], startX + 7 + panelSize[1]/2 + 50, startY + 40 + (k-skinsScrolling)*35 + 30/2,  _, _, tocolor(200, 200, 200, a), 1, robotoBold10, "left", "center", false, false, false, true)
            else
                dxDrawText(v[2], startX + 7 + panelSize[1]/2 + 50, startY + 40 + (k-skinsScrolling)*35 + 30/2,  _, _, tocolor(200, 200, 90, a), 1, robotoBold10, "left", "center", false, false, false, true)
            end

            if v[3] == "runner" then
                dxDrawImage(startX + 7 + panelSize[1]/2 + 20, startY + 40 + (k-skinsScrolling)*35 + 30/4, 16, 16, "files/img/runner.png", 0, 0, 0, tocolor(230, 140, 140, a))
            else
                dxDrawImage(startX + 7 + panelSize[1]/2 + 20, startY + 40 + (k-skinsScrolling)*35 + 30/4, 16, 16, "files/img/badge.png", 0, 0, 0, tocolor(140, 195, 230, a))
            end
        end
    end

    if skinPreview then
        exports.a_3dview:setSkinProjection(startX + panelSize[1], startY + 10, 250, 250, a)
    end
end

function onScrolling(key, state)
    local startX, startY = sX / 2 - panelSize[1] / 2, sY / 2 - panelSize[2] / 2

    if isMouseInPosition(startX + 7, startY + 35, panelSize[1]/2 - 14, panelSize[2] - 45) then
        if key == "mouse_wheel_up" then
            if vehiclesScrolling > 0  then
                vehiclesScrolling = vehiclesScrolling - 1
                maxVehiclesShowing = maxVehiclesShowing - 1
            end
        elseif key == "mouse_wheel_down" then
            if maxVehiclesShowing < #vehiclesToBuy then
                vehiclesScrolling = vehiclesScrolling + 1
                maxVehiclesShowing = maxVehiclesShowing + 1
            end
        end
    end
    if isMouseInPosition(startX + 7 + panelSize[1]/2, startY + 35, panelSize[1]/2 - 14, panelSize[2] - 45) then
        if key == "mouse_wheel_up" then
            if skinsScrolling > 0  then
                skinsScrolling = skinsScrolling - 1
                maxSkinsShowing = maxSkinsShowing - 1
            end
        elseif key == "mouse_wheel_down" then
            if maxSkinsShowing < #skinsToBuy then
                skinsScrolling = skinsScrolling + 1
                maxSkinsShowing = maxSkinsShowing + 1
            end
        end
    end
end

function onPursuitClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    local startX, startY = sX / 2 - panelSize[1] / 2, sY / 2 - panelSize[2] / 2

    if button == "left" and state == "down" then
        if isMouseInPosition(startX + panelSize[1] - 24, startY + 7, 13, 13) then
            isPursuitPanelRendered = false
            removeEventHandler("onClientRender", root, onPursuitPanelRender)
            removeEventHandler("onClientKey", root, onScrolling)
            removeEventHandler("onClientClick", root, onPursuitClick)
    
            exports.a_3dview:processSkinPreview()
            skinPreview = false
        end

        for k, v in ipairs(vehiclesToBuy) do
            if k <= maxVehiclesShowing and (k > vehiclesScrolling) then
                if isMouseInPosition(startX + panelSize[1]/2 - 45, startY + 40 + (k-vehiclesScrolling)*35 + 5, 20, 20) then
                    if v[4] == true then
                        if getElementData(localPlayer, "a.VIP") == true then
                            if v[3] == "chaser" then
                                currentSelectedVehicle[1] = k
                                triggerServerEvent("requestSave", localPlayer, localPlayer, "saveveh", 1, v[1])
                            else
                                currentSelectedVehicle[2] = k
                                triggerServerEvent("requestSave", localPlayer, localPlayer, "saveveh", 2, v[1])
                            end
                        else
                            exports.a_interface:makeNotification(2, "This vehicle is only for VIP members.")
                        end
                    else
                        if v[3] == "chaser" then
                            local boughtVehicles = getElementData(localPlayer, "a.HPBoughtVehs")
                            if isValueInTable(boughtVehicles, v[1], k) then
                                currentSelectedVehicle[1] = k
                                triggerServerEvent("requestSave", localPlayer, localPlayer, "saveveh", 1, v[1])
                            else
                                expprintorts.a_interface:makeNotification(2, "You have to buy this vehicle first.")
                            end
                        else
                            local boughtVehicles = getElementData(localPlayer, "a.HPBoughtVehs")
                            if isValueInTable(boughtVehicles, v[1], k) then
                                currentSelectedVehicle[2] = k
                                triggerServerEvent("requestSave", localPlayer, localPlayer, "saveveh", 2, v[1])
                            else
                                exports.a_interface:makeNotification(2, "You have to buy this vehicle first.")
                            end
                        end
                    end
                end
                if isMouseInPosition(startX + panelSize[1]/2 - 90, startY + 40 + (k-vehiclesScrolling)*35, 40, 20) then
                    local boughtVehicles = getElementData(localPlayer, "a.HPBoughtVehs")
                    if not (isValueInTable(boughtVehicles, v[1], k)) and v[4] == false then
                        local playerMoney = getElementData(localPlayer, "a.Money")
                        if playerMoney >= v[5] then
                            exports.a_interface:makeNotification(1, "You have successfully bought the " .. v[2] .. ".")
                            triggerServerEvent("requestSave", localPlayer, localPlayer, "buyveh", v[1])
                            setElementData(localPlayer, "a.Money", playerMoney - v[5])
                        else
                            exports.a_interface:makeNotification(2, "You don't have enough money to buy this.")
                        end
                    end
                end
            end
        end
        for k, v in ipairs(skinsToBuy) do
            if k <= maxSkinsShowing and (k > skinsScrolling) then
                if isMouseInPosition(startX + panelSize[1]/2 + panelSize[1]/2 - 45, startY + 40 + (k-skinsScrolling)*35 + 5, 20, 20) then
                    if v[4] == true and getElementData(localPlayer, "a.VIP") == false then
                        exports.a_interface:makeNotification(2, "This skin is only for VIP members.")
                    else
                        if v[3] == "chaser" then
                            currentSelectedSkin[1] = k
                            triggerServerEvent("requestSave", localPlayer, localPlayer, "saveskin", 1, v[1])
                        else
                            currentSelectedSkin[2] = k
                            triggerServerEvent("requestSave", localPlayer, localPlayer, "saveskin", 2, v[1])
                        end
                    end
                end

                if isMouseInPosition(startX + panelSize[1] - 70, startY + 40 + (k-skinsScrolling)*35 + 7.5, 14, 14) then
                    exports.a_3dview:setSkin(v[1])
                    if not (skinPreview) then
                        skinPreview = true
                        exports.a_3dview:processSkinPreview(v[1], startX + panelSize[1] + 20, sY / 2, 300, 500)
                    end
                end
            end
        end
    end
end

function onDamage(attacker)
    if getElementData(attacker, "a.Gamemode") == 4 and getElementData(source, "a.Gamemode") == 4 then
        local attackerTeam = getElementData(attacker, "a.HPTeam");
        local sourceTeam = getElementData(source, "a.HPTeam");
        if attackerTeam == sourceTeam then
            cancelEvent()
        end
    end
end
addEventHandler("onClientPlayerDamage", root, onDamage)

function disableDamage(attacker)
    if not isElement(attacker) then
        return
    end
    if getElementData(attacker, "a.Gamemode") == 4 and getElementDimension(source) == 4 then
        local attackerTeam = getElementData(attacker, "a.HPTeam");
        local vehTeam = getElementData(source, "a.HPTeam_Veh")
        if attackerTeam == vehTeam then
            cancelEvent()
        end
    end 
end
addEventHandler("onClientVehicleDamage", root, disableDamage)