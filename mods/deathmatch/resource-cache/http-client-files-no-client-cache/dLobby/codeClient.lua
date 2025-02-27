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

local font = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(10), false, "cleartype")
local signBigRegular = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(14), false, "cleartype")
local signBigBold = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(14), false, "cleartype")
local font2 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(9), false, "cleartype")
local robotoThin = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(9), false, "cleartype")

local panelSize = {respc(400), respc(240)}
local width = panelSize[1] - respc(20)
local delayTimer = {}
local clicked = {}
local r2, g2, b2 = 50, 50, 50

function onRender()
    if not (getElementDimension(localPlayer) == 0) then
        return
    end
    radius, z, alpha = interpolateBetween(0.3, 0.5, 255, 0.5, 0.8, 100, getTickCount()/7500, "SineCurve")

    dxDrawOctagon3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - z, radius, 1, tocolor(240, 220, 120, 200))
    dxDrawOctagon3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - z - 0.1, radius + 0.1, 1, tocolor(240, 220, 120, 200))
    dxDrawOctagon3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - z - 0.2, radius + 0.2, 1, tocolor(240, 220, 120, 200))

    local pX, pY, pZ = getElementPosition(localPlayer)
    local mX, mY, mZ = gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - 0.85
    local distanceFromMarker = getDistanceBetweenPoints3D(pX, pY, pZ, mX, mY, mZ)
    if distanceFromMarker < 10 then
        local x, y = getScreenFromWorldPosition(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1,  gmSelectorPoint[3] - 0.4, 0.06)
        if x and y then

            local maxDist = 10
            if distanceFromMarker > maxDist then
                return
            end
            local scale = 1 - distanceFromMarker / (maxDist * 2)

            local signX_1, signY_1, signX_2, signY_2 = x - 30*scale, y - 1 - respc(70)*scale + (z * 100), x - 28*scale, y - 1 - respc(70)*scale + (z * 100)

            dxDrawText("alpha", signX_1, signY_1, _, _, tocolor(200, 200, 200, 255*scale), 1*scale, signBigBold, "right", "center")
            dxDrawText("SELECTOR", signX_2, signY_2, _, _, tocolor(200, 200, 200, 255*scale), 1*scale, signBigRegular, "left", "center")
            dxDrawText("Itt tudsz játékmódot választani.", x + 1, y - 1 - respc(49)*scale + (z * 100), _, _, tocolor(20, 20, 20, ((alpha*0.5)*scale)), 0.7*scale, signBigRegular, "center", "center")
            dxDrawText("Itt tudsz játékmódot választani.", x, y - respc(50)*scale + (z * 100), _, _, tocolor(240, 220, 120, alpha*scale), 0.7*scale, signBigRegular, "center", "center")
        end
    end
end
setTimer(onRender, 5, 0)

local poppinsBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(15), false, "cleartype")
local poppinsRegularSmall = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(10), false, "cleartype")
local poppinsRegularSmall2 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(10), false, "cleartype")

local barlowBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(13), false, "cleartype")
local barlowLightBig = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(13), false, "cleartype")
gameModes = {
    -- ** TELJES NÉV, RÖVID NÉV, SZÍN, DEV STÁTUSZ
    {"DEATHMATCH", "DM", "#E48F8F", false},
    {"HOT PURSUIT", "HP", "#8FC3E4", true},
    {"DRIFT", "DRIFT", "#F1C176", true},
    {"DERBY", "DERBY", "#9BE48F", true},
}

local sizeX, sizeY = respc(10) + ((#gameModes-1)*respc(5)) + #gameModes*respc(200), respc(200)
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

function renderPanel()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - openTick
    local duration = elapsedTime / 300

    if panelState == "opened" then
        a, players_3, players_4 = interpolateBetween(0, 0, 0, 255, currentDriftPlayers, currentPursuitPlayers, duration, "Linear")
        players_1, players_2, startY = interpolateBetween(0, 0, sY / 2 - sizeY / 2 + respc(30), currentTDMAPlayers, currentFreeroamPlayers, sY / 2 - sizeY / 2, duration, "Linear")
    end

    dxDrawRoundedRectangle(startX, startY, sizeX, sizeY, 3, tocolor(35, 35, 35, a))
    dxDrawFadeRectangle(startX, startY, sizeX, sizeY, {20, 20, 20, a})

    dxDrawText("alpha", startX + respc(2), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldBig, "left", "center")
    dxDrawText("SELECTOR", startX + respc(3.5) + dxGetTextWidth("alpha", 1, barlowBoldBig), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowLightBig, "left", "center")

    --[[if isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
        dxDrawText("#E18C88X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, font2, "right", "center", false, false, false, true)
    else
        dxDrawText("#c8c8c8X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, font2, "right", "center", false, false, false, true)    
    end]]--

    for i, v in ipairs(gameModes) do
        local bW, bH = respc(200), sizeY - respc(10)
        local bX, bY = startX + respc(5) + (bW + respc(5))*(i-1), startY + respc(5)
        local gamemodeName = tostring(v[1])
        local titleWidth = dxGetTextWidth(gamemodeName, 1, poppinsBoldBig)
        local r, g, b = getColorFromString(v[3])

        if isMouseInPosition(bX, bY, bW, bH) then
            dxDrawRectangle(bX, bY, bW, bH, tocolor(55, 55, 55, a))

            if v[4] == true then
                dxDrawText(gamemodeName, bX + bW / 2, bY + bH / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center")
                dxDrawImage(bX + bW / 2 - respc(25), bY + respc(12), respc(50), respc(50), "files/icons/gamemodes/" .. i .. ".png", 0, 0, 0, tocolor(150, 150, 150, a))
                dxDrawImage(bX, bY + bH / 4 - respc(30), bW, bH/2, "files/icons/construction.png", 0, 0, 0, tocolor(255, 255, 255, a))
                dxDrawText("Fejlesztés alatt!", bX + bW / 2, bY + bH / 2 + respc(20), _, _, tocolor(200, 200, 200, a), 1, poppinsRegularSmall, "center", "top")

--                dxDrawRectangle(bX, bY + bH - respc(40), bW, respc(40), tocolor(55, 55, 55, a))
                dxDrawImage(bX, bY, bW, bH, ":dShop/files/img/bg.png", 0, 0, 0, tocolor(240, 220, 120, a*0.3))

                dxDrawText("NEM ELÉRHETŐ", bX + bW / 2, bY + bH - respc(20), _, _, tocolor(200, 200, 200, a), 1, poppinsRegularSmall2, "center", "center")
            else
--                dxDrawRectangle(bX, bY + bH - respc(40), bW, respc(40), tocolor(r, g, b, a*0.5))
                dxDrawImage(bX, bY, bW, bH, ":dShop/files/img/bg.png", 0, 0, 0, tocolor(r, g, b, a*0.5))

                dxDrawText("CSATLAKOZÁS", bX + bW / 2, bY + bH - respc(20), _, _, tocolor(200, 200, 200, a), 1, poppinsRegularSmall, "center", "center")
                dxDrawText(gamemodeName, bX + bW / 2, bY + bH / 2, _, _, tocolor(r, g, b, a), 1, poppinsBoldBig, "center", "center")
                dxDrawImage(bX + bW / 2 - respc(25), bY + respc(12), respc(50), respc(50), "files/icons/gamemodes/" .. i .. ".png", 0, 0, 0, tocolor(r, g, b, a))
                dxDrawText("Játszik: " .. players_1 .. " játékos", bX + bW / 2, bY + bH / 2 + respc(20), _, _, tocolor(150, 150, 150, a), 1, poppinsRegularSmall, "center", "top")
            end
        else
            dxDrawRectangle(bX, bY, bW, bH, tocolor(45, 45, 45, a))

            if v[4] == true then
                dxDrawText(gamemodeName, bX + bW / 2, bY + bH / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center")
                dxDrawImage(bX + bW / 2 - respc(25), bY + respc(12), respc(50), respc(50), "files/icons/gamemodes/" .. i .. ".png", 0, 0, 0, tocolor(150, 150, 150, a))
                dxDrawImage(bX, bY + bH / 4 - respc(30), bW, bH/2, "files/icons/construction.png", 0, 0, 0, tocolor(200, 200, 200, a))
                dxDrawText("Fejlesztés alatt!", bX + bW / 2, bY + bH / 2 + respc(20), _, _, tocolor(150, 150, 150, a), 1, poppinsRegularSmall, "center", "top")

                --dxDrawRectangle(bX, bY + bH - respc(40), bW, respc(40), tocolor(55, 55, 55, a))
                dxDrawImage(bX, bY, bW, bH, ":dShop/files/img/bg.png", 0, 0, 0, tocolor(240, 220, 120, a*0.3))

                dxDrawText("NEM ELÉRHETŐ", bX + bW / 2, bY + bH - respc(20), _, _, tocolor(150, 150, 150, a), 1, poppinsRegularSmall2, "center", "center")
            else
                --dxDrawRectangle(bX, bY + bH - respc(40), bW, respc(40), tocolor(55, 55, 55, a))
                dxDrawImage(bX, bY, bW, bH, ":dShop/files/img/bg.png", 0, 0, 0, tocolor(150, 150, 150, a*0.5))
                dxDrawText("CSATLAKOZÁS", bX + bW / 2, bY + bH - respc(20), _, _, tocolor(200, 200, 200, a), 1, poppinsRegularSmall, "center", "center")
                dxDrawText(gamemodeName, bX + bW / 2, bY + bH / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center")
                dxDrawImage(bX + bW / 2 - respc(25), bY + respc(12), respc(50), respc(50), "files/icons/gamemodes/" .. i .. ".png", 0, 0, 0, tocolor(150, 150, 150, a))
                dxDrawText("Játszik: " .. players_1 .. " játékos", bX + bW / 2, bY + bH / 2 + respc(20), _, _, tocolor(150, 150, 150, a), 1, poppinsRegularSmall, "center", "top")
            end
        end
    end
end

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "down" then
        for i, v in ipairs(gameModes) do
            local bW, bH = respc(200), sizeY - respc(10)
            local bX, bY = startX + respc(5) + (bW + respc(5))*(i-1), startY + respc(5)
            if isMouseInPosition(bX, bY, bW, bH) then
                if not (v[4] == true) then    
                    if i == 1 then
                        exports.dDeathmatch:showTeamselectorPanel(localPlayer)
                    else
                        exports.dInfobox:makeNotification(1, "Sikeresen csatlakoztál a kiválasztott játékmódhoz. Kilépni innen a /lobby parancs használatával tudsz.")
                        setElementData(localPlayer, "a.Gamemode", i)
                    end
                    removeEventHandler("onClientRender", root, renderPanel) 
                    removeEventHandler("onClientClick", root, onClick)
                else
                    exports.dInfobox:makeNotification(2, "Nem tudsz csatlakozni ehhez a játékmódhoz, mivel fejlesztés alatt áll.")
                end
            end
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
        playSound("files/open.wav")
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
    
    local attackerTeam = getElementData(attacker, "a.Team<DM>")
    local sourceTeam = getElementData(source, "a.Team<DM>")

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

local topTexture = dxCreateTexture("files/images/featherTop.dds", "dxt5", true, "clamp")
local sideTexture = dxCreateTexture("files/images/feather.dds", "dxt5", true, "clamp")
local cornerTexture = dxCreateTexture("files/images/corner.dds", "dxt5", true, "clamp")

function dxDrawFadeRectangle(x, y, w, h, color)

    x = x - 5
    y = y - 5
    w = w + 10
    h = h + 10
    if color[4] < 10 then
        return
    end
    
    dxDrawRectangle(x + 10, y + 10, w - 20, h - 20, tocolor(color[1], color[2], color[3], color[4] - 15))
    color = tocolor(color[1], color[2], color[3], color[4])
    dxDrawImage(x, y, 10, 10, cornerTexture, 270, 0, 0, color)
    dxDrawImage(x + w - 10, y, 10, 10, cornerTexture, 0, 0, 0, color)
    dxDrawImage(x, y + h - 10, 10, 10, cornerTexture, 180, 0, 0, color)
    dxDrawImage(x + w - 10, y + h - 10, 10, 10, cornerTexture, 90, 0, 0, color)

    dxDrawImage(x + 10, y + 10, w - 20, -10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + h - 10, w - 20, 10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + 10, -10, h - 20, sideTexture, 0, 0, 0, color)
    dxDrawImage(x + w - 10, y + 10, 10, h - 20, sideTexture, 0, 0, 0, color)
end