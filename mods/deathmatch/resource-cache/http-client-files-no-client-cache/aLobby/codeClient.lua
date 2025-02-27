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

local font = dxCreateFont("files/fonts/font.otf", respc(13), false, "cleartype")
local font3 = dxCreateFont("files/fonts/font.otf", respc(17), false, "cleartype")
local font2 = dxCreateFont("files/fonts/font.otf", respc(10), false, "cleartype")
local robotoThin = dxCreateFont("files/fonts/Roboto-Condensed.otf", respc(10), false, "cleartype")

local panelSize = {respc(400), respc(240)}
local width = panelSize[1] - respc(20)
local delayTimer = {}
local clicked = {}
local r2, g2, b2 = 50, 50, 50

function onRender()
    if not (getElementDimension(localPlayer) == 0) then
        return
    end
    radius, z = interpolateBetween(0.3, 0.5, 0, 0.5, 0.8, 0, getTickCount()/7500, "SineCurve")

    dxDrawOctagon3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - z, radius, 1, tocolor(255, 255, 255, 255))
    dxDrawOctagon3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - z - 0.1, radius + 0.1, 1, tocolor(255, 255, 255, 255))
    dxDrawOctagon3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - z - 0.2, radius + 0.2, 1, tocolor(255, 255, 255, 255))

    local pX, pY, pZ = getElementPosition(localPlayer)
    local mX, mY, mZ = gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - 0.85
    local distanceFromMarker = getDistanceBetweenPoints3D(pX, pY, pZ, mX, mY, mZ)
    if distanceFromMarker < 5 then
        local x, y = getScreenFromWorldPosition(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1,  gmSelectorPoint[3] - 0.4, 0.06)
        if x and y then
           dxDrawText("Játékmód választó", x + 1, y - 1 - respc(74) + (z * 100), _, _, tocolor(20, 20, 20), 1, font3, "center", "center")
           dxDrawText("Játékmód választó", x, y - respc(75) + (z * 100), _, _, tocolor(255, 255, 255), 1, font3, "center", "center")
        end
    end
end
setTimer(onRender, 5, 0)

local poppinsBoldBig = dxCreateFont("files/fonts/Roboto-BoldCondensed.otf", respc(17), false, "cleartype")
local poppinsRegularSmall = dxCreateFont("files/fonts/Roboto-Condensed.otf", respc(12), false, "cleartype")
local sizeX, sizeY = respc(600), respc(350)
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

function renderPanel()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - openTick
    local duration = elapsedTime / 500

    if panelState == "opened" then
        a, players_3, players_4 = interpolateBetween(0, 0, 0, 255, currentDriftPlayers, currentPursuitPlayers, duration, "Linear")
        players_1, players_2 = interpolateBetween(0, 0, 0, currentTDMAPlayers, currentFreeroamPlayers, 0, duration, "Linear")
    end

    dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
    dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
    dxDrawRectangle(startX, startY, sizeX, respc(20), tocolor(65, 65, 65, a))

    dxDrawText("#E18C88alpha#c8c8c8Games - Játékmód választó", startX + respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, font2, "left", "center", false, false, false, true)
    
    if isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
        dxDrawText("#E18C88X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, font2, "right", "center", false, false, false, true)
    else
        dxDrawText("#c8c8c8X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, font2, "right", "center", false, false, false, true)    
    end

    local bW, bH = (sizeX - respc(30)) / 2, (sizeY - respc(50)) / 2

    for i, v in ipairs(gameModes) do
        if i > 2 then
            bY = startY + respc(30) + bH + respc(10)
            if i == 3 then
                bX = startX + respc(10)
            else
                bX = startX + respc(20) + bW
            end
        else
            bY = startY + respc(30)
            if i == 1 then
                bX = startX + respc(10)
            else
                bX = startX + respc(20) + bW
            end
        end

        local gamemodeName = tostring(v[1])
        local titleWidth = dxGetTextWidth(gamemodeName, 1, poppinsBoldBig)

        if isMouseInPosition(bX, bY, bW, bH) then
            dxDrawRectangle(bX, bY, bW, bH, tocolor(55, 55, 55, a))
        else
            dxDrawRectangle(bX, bY, bW, bH, tocolor(45, 45, 45, a))
        end

        dxDrawImage(bX + bW / 2 - respc(16), bY + respc(12), respc(32), respc(32), "files/icons/gamemodes/" .. i .. ".png", 0, 0, 0, tocolor(150, 150, 150, a))
        dxDrawText(gamemodeName, bX + bW / 2, bY + bH / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center")
        dxDrawText("Jelenleg " .. players_1 .. " játékos játszik.", bX + bW / 2, bY + bH / 2 + respc(20), _, _, tocolor(150, 150, 150, a), 1, poppinsRegularSmall, "center", "top")
    end
end

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    local sizeX, sizeY = respc(600), respc(350)

    local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
    local bW, bH = (sizeX - respc(30)) / 2, (sizeY - respc(50)) / 2
    if isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
        removeEventHandler("onClientRender", root, renderPanel) 
        removeEventHandler("onClientClick", root, onClick)
    end

    for i, v in ipairs(gameModes) do
        if i > 2 then
            bY = startY + respc(30) + bH + respc(10)
            if i == 3 then
                bX = startX + respc(10)
            else
                bX = startX + respc(20) + bW
            end
        else
            bY = startY + respc(30)
            if i == 1 then
                bX = startX + respc(10)
            else
                bX = startX + respc(20) + bW
            end
        end
        if isMouseInPosition(bX, bY, bW, bH) then  
            setElementData(localPlayer, "a.Gamemode", i)
            removeEventHandler("onClientRender", root, renderPanel) 
            removeEventHandler("onClientClick", root, onClick)
        end
    end
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

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

function onColHit(element, dim)
    if getElementData(source, "a.GMselector") == true and element == localPlayer then
        if not (getElementDimension(element) == 0) then
            return
        end
        openTick = getTickCount()
        panelState = "opened"

        addEventHandler("onClientRender", root, renderPanel)
        addEventHandler("onClientClick", root, onClick)

        currentTDMAPlayers = 0;
        currentFreeroamPlayers = 0;
        currentDriftPlayers = 0;
        currentPursuitPlayers = 0;
        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Gamemode") == 1 then
                currentTDMAPlayers = currentTDMAPlayers + 1
            end
            if getElementData(v, "a.Gamemode") == 2 then
                currentFreeroamPlayers = currentFreeroamPlayers + 1
            end
            if getElementData(v, "a.Gamemode") == 3 then
                currentDriftPlayers = currentDriftPlayers + 1
            end
            if getElementData(v, "a.Gamemode") == 4 then
                currentPursuitPlayers = currentPursuitPlayers + 1
            end
        end
    end
end
addEventHandler("onClientColShapeHit", root, onColHit)

function onColLeave(element, dim)
    if getElementData(source, "a.GMselector") == true and element == localPlayer then
        panelState = "closed"
        removeEventHandler("onClientClick", root, onClick)
        removeEventHandler("onClientRender", root, renderPanel)
    end
end
addEventHandler("onClientColShapeLeave", root, onColLeave)

function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false
	end

	local radius = radius or 1
	local radius2 = radius/math.sqrt(2)
	local width = width or 1
	local color = color or tocolor(255,255,255,150)

	point = {}

		for i=1,8 do
			point[i] = {}
		end

		point[1].x = x
		point[1].y = y-radius
		point[2].x = x+radius2
		point[2].y = y-radius2
		point[3].x = x+radius
		point[3].y = y
		point[4].x = x+radius2
		point[4].y = y+radius2
		point[5].x = x
		point[5].y = y+radius
		point[6].x = x-radius2
		point[6].y = y+radius2
		point[7].x = x-radius
		point[7].y = y
		point[8].x = x-radius2
		point[8].y = y-radius2
		
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2, color, width)
	end
	return true
end

addEventHandler("onClientPlayerDamage", root, function(att)
    if getElementData(source, "a.isPlayerInLobbyColShape") == true then
        cancelEvent()
    end

    if getElementData(source, "a.Maintenance") == true then
        cancelEvent()
    end

    if getElementData(source, "a.Protected") == true then
        cancelEvent()
    end
end)


function onDamage(attacker)
    if not (attacker) then
        return
    end

    if not (getElementData(attacker, "a.Gamemode") == 1) then
        return
    end
    
    local attackerTeam = getElementData(attacker, "a.DMTeam")
    local sourceTeam = getElementData(source, "a.DMTeam")

    if attackerTeam == sourceTeam then
        cancelEvent()
        return
    end
end
addEventHandler("onClientPlayerDamage", root, onDamage)

function onChange(key, oval, nval)
    if key == "a.isPlayerInLobbyColShape" then
        if nval == true then
            disableCollision(source)
        else
            enableCollision(source)
        end
    end

    if key == "a.Gamemode" then
        if nval == nil then
            disableCollision(source)
        else
            enableCollision(source)
        end
    end
end
addEventHandler("onClientElementDataChange", root, onChange)

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

addEventHandler("onClientPedDamage", root,
function()
    if getElementDimension(source) == 0 then
        cancelEvent()
        return
    end
end)