local sX, sY = guiGetScreenSize();

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

local poppinsBoldVeryBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(20), false, "cleartype")
local poppinsRegularVeryBig = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(15), false, "cleartype")

local poppinsBoldRegular = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(13), false, "cleartype")

local robotoThin = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(12), false, "cleartype")

local font = poppinsBoldRegular
local font2 = poppinsBoldRegular

local panelSize = {respc(400), respc(240)}
local width = panelSize[1] - respc(20)

local delayTimer = {}
local clicked = {}
local r2, g2, b2 = 50, 50, 50

function onRender()
    if not (getElementDimension(localPlayer) == 0) then
        return
    end
    r, g, b = interpolateBetween(240, 140, 100, 200, 100, 100, getTickCount()/4000, "SineCurve")
    a, radius = interpolateBetween(150, 0.5, 0, 250, 0.6, 0, getTickCount()/7500, "SineCurve")

    dxDrawCircle3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - 0.9, radius, 8, tocolor(r, g, b, a), 1)
    dxDrawCircle3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - 0.9, radius + 0.1, 8, tocolor(r, g, b, a), 1)
    dxDrawCircle3D(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - 0.9, radius + 0.2, 8, tocolor(r, g, b, a), 1)

    local pX, pY, pZ = getElementPosition(localPlayer)
    local mX, mY, mZ = gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1, gmSelectorPoint[3] - 0.85
    local distanceFromMarker = getDistanceBetweenPoints3D(pX, pY, pZ, mX, mY, mZ)

    if distanceFromMarker < 5 then
        local x, y = getScreenFromWorldPosition(gmSelectorPoint[1] - 1, gmSelectorPoint[2] - 1,  gmSelectorPoint[3] - 0.4, 0.06)
        if x and y then
            posY = interpolateBetween(y - respc(130), 0, 0, y - respc(110), 0, 0, getTickCount()/4000, "CosineCurve")

           dxDrawText("Játékmód választó", x + 1, posY + respc(90) + 1, _, _, tocolor(20, 20, 20), 1, poppinsBoldVeryBig, "center", "center")
           dxDrawText("Játékmód választó", x, posY + respc(90), _, _, tocolor(200, 200, 200), 1, poppinsBoldVeryBig, "center", "center")
           dxDrawText("Itt tudod kiválasztani a játékmódot, ahol játszani szeretnél.", x, posY + respc(110), _, _, tocolor(200, 200, 200, 150), 1, poppinsRegularVeryBig, "center", "center")

           dxDrawImage(x - respc(25) + 1, posY + respc(25) - respc(15) + 1, respc(50), respc(50), "files/icons/arrow.png", 90, 0, 0, tocolor(20, 20, 20, 200))
           dxDrawImage(x - respc(25) + 1, posY + respc(25), respc(50) + 1, respc(50), "files/icons/arrow.png", 90, 0, 0, tocolor(20, 20, 20, 200))

           dxDrawImage(x - respc(25), posY + respc(25) - respc(15), respc(50), respc(50), "files/icons/arrow.png", 90, 0, 0, tocolor(r, g, b, 200))
           dxDrawImage(x - respc(25), posY + respc(25), respc(50), respc(50), "files/icons/arrow.png", 90, 0, 0, tocolor(r, g, b, 200))
        end
    end
end
setTimer(onRender, 5, 0)

local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(15), false, "cleartype")
local poppinsLightBig = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(14), false, "cleartype")
local poppinsLightBig2 = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(12), false, "cleartype")
local sizeX, sizeY = respc(400), respc(250)
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

local colorCache = {
    [1] = {230, 140, 140},
    [2] = {155, 230, 140},
    [3] = {240, 195, 120},
    [4] = {140, 195, 230},
}

function renderPanel()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - colTick
    local duration = elapsedTime / 500

    if panelState == "open" then
        a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

        tdmaPlayers = interpolateBetween(0, 0, 0, currentTDMAPlayers, 0, 0, duration/1.5, "Linear")
        ffaPlayers = interpolateBetween(0, 0, 0, currentFreeroamPlayers, 0, 0, duration/1.5, "Linear")
        driftPlayers = interpolateBetween(0, 0, 0, currentDriftPlayers, 0, 0, duration/1.5, "Linear")
        pursuitPlayers = interpolateBetween(0, 0, 0, currentPursuitPlayers, 0, 0, duration/1.5, "Linear")

    elseif panelState == "close" then
        a = interpolateBetween(a, 0, 0, 0, 0, 0, duration, "Linear")
        if a == 0 then
            removeEventHandler("onClientRender", root, renderPanel)
            removeEventHandler("onClientClick", root, onClick)
        end
    end

    dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
    dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))

    dxDrawText("#E48F8Falpha", startX + respc(2), startY - respc(8.5), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "left", "center", false, false, false, true)
    dxDrawText("SELECTOR", startX + respc(4) + dxGetTextWidth("alpha", 1, poppinsBoldBig), startY - respc(8.5), _, _, tocolor(200, 200, 200, a), 1, poppinsLightBig, "left", "center", false, false, false, true)

    gm = 1
    for k, v in ipairs(gameModes) do
        k = k - 1
        if k < 2 then
            box_W, box_H = (sizeX - respc(15)) / 2, (sizeY - respc(15)) / 2
            box_X, box_Y = startX + respc(5) + (k * (box_W + respc(5))), startY + respc(5)
        else
            k = k - 2
            box_W, box_H = (sizeX - respc(15)) / 2, (sizeY - respc(15)) / 2
            box_X, box_Y = startX + respc(5) + (k * (box_W + respc(5))), startY + box_H + respc(10)
        end

        if isMouseInPosition(box_X, box_Y, box_W, box_H) then
            dxDrawRectangle(box_X, box_Y, box_W, box_H, tocolor(75, 75, 75, a))
        
            -- ** NYÍL ANIMÁCIÓ
            rot = 0
            progress, a2, rot = interpolateBetween(-respc(10), 0, rot, 0, 255, rot + 10, nowTick / 2500, "SineCurve")


            dxDrawImage(box_X + respc(10) + progress, box_Y + box_H / 2 - respc(12), respc(24), respc(24), "files/icons/arrow.png", 0, 0, 0, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a2))
            dxDrawImage(box_X + respc(10) + progress + respc(10), box_Y + box_H / 2 - respc(12), respc(24), respc(24), "files/icons/arrow.png", 0, 0, 0, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a2))

            dxDrawImage(box_X + box_W - respc(34) - progress, box_Y + box_H / 2 - respc(12), respc(24), respc(24), "files/icons/arrow.png", 180, 0, 0, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a2))
            dxDrawImage(box_X + box_W - respc(34) - progress - respc(10), box_Y + box_H / 2 - respc(12), respc(24), respc(24), "files/icons/arrow.png", 180, 0, 0, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a2))
        else
            rot = 0
            dxDrawRectangle(box_X, box_Y, box_W, box_H, tocolor(50, 50, 50, a))
        end

        dxDrawText("BELÉPÉS", box_X + box_W / 2, box_Y + box_H - respc(15), _, _, tocolor(150, 150, 150, a), 1, poppinsBoldBig, "center", "center", false, false, false, true)

        if v[1] == "Deathmatch" then
            dxDrawImage(box_X + box_W / 2 - respc(15), box_Y + box_H / 2 - respc(50), respc(30), respc(30), "files/icons/gamemodes/dm.png", rot, 0, 0, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a))
            dxDrawText("#E48F8F" .. string.upper(v[1]), box_X + box_W / 2, box_Y + box_H / 2 - respc(5), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center", false, false, false, true)
            dxDrawText("" .. math.floor(tdmaPlayers) .. " #6A6A6Ajátékos", box_X + box_W / 2, box_Y + box_H / 2 + respc(15), _, _, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a), 1, poppinsLightBig2, "center", "center", false, false, false, true)
        elseif v[1] == "Freeroam" then
            dxDrawImage(box_X + box_W / 2 - respc(15), box_Y + box_H / 2 - respc(50), respc(30), respc(30), "files/icons/gamemodes/froam.png", rot, 0, 0, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a))
            dxDrawText("#9BE48F" .. string.upper(v[1]), box_X + box_W / 2, box_Y + box_H / 2 - respc(5), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center", false, false, false, true)
            dxDrawText("" .. math.floor(ffaPlayers) .. " #6A6A6Ajátékos", box_X + box_W / 2, box_Y + box_H / 2 + respc(15), _, _, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a), 1, poppinsLightBig2, "center", "center", false, false, false, true)
        elseif v[1] == "Drift" then
            dxDrawImage(box_X + box_W / 2 - respc(15), box_Y + box_H / 2 - respc(50), respc(30), respc(30), "files/icons/gamemodes/drift.png", rot, 0, 0, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a))
            dxDrawText("#F1C176" .. string.upper(v[1]), box_X + box_W / 2, box_Y + box_H / 2 - respc(5), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center", false, false, false, true)
            dxDrawText("" .. math.floor(driftPlayers) .. " #6A6A6Ajátékos", box_X + box_W / 2, box_Y + box_H / 2 + respc(15), _, _, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a), 1, poppinsLightBig2, "center", "center", false, false, false, true)
        elseif v[1] == "Hot Pursuit" then
            dxDrawImage(box_X + box_W / 2 - respc(15), box_Y + box_H / 2 - respc(50), respc(30), respc(30), "files/icons/gamemodes/pursuit.png", rot, 0, 0, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a))
            dxDrawText("#8FC3E4" .. string.upper(v[1]), box_X + box_W / 2, box_Y + box_H / 2 - respc(5), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center", false, false, false, true)
            dxDrawText("" .. math.floor(pursuitPlayers) .. " #6A6A6Ajátékos", box_X + box_W / 2, box_Y + box_H / 2 + respc(15), _, _, tocolor(colorCache[gm][1], colorCache[gm][2], colorCache[gm][3], a), 1, poppinsLightBig2, "center", "center", false, false, false, true)
        end

        gm = gm + 1
    end
end

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if button == "left" and state == "down" then
        gm = 1
        for k, v in ipairs(gameModes) do
            k = k - 1
            if k < 2 then
                box_W, box_H = (sizeX - respc(15)) / 2, (sizeY - respc(15)) / 2
                box_X, box_Y = startX + respc(5) + (k * (box_W + respc(5))), startY + respc(5)
            else
                k = k - 2
                box_W, box_H = (sizeX - respc(15)) / 2, (sizeY - respc(15)) / 2
                box_X, box_Y = startX + respc(5) + (k * (box_W + respc(5))), startY + box_H + respc(10)
            end

            if isMouseInPosition(box_X, box_Y, box_W, box_H) then
                triggerServerEvent("changeDataSync", localPlayer, "a.Gamemode", gm)
                colTick = getTickCount()
                panelState = "close"
            end
            gm = gm + 1
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

function isInBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
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
        colTick = getTickCount()
        clickTick = getTickCount()
        panelState = "open"
        for k, v in ipairs(gameModes) do
            clicked[v] = false
        end
        if isEventHandlerAdded("onClientRender", root, renderPanel) then
            removeEventHandler("onClientRender", root, renderPanel) 
        end
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
        colTick = getTickCount()
        panelState = "close"
    end
end
addEventHandler("onClientColShapeLeave", root, onColLeave)

function dxDrawCircle3D( x, y, z, radius, segments, color, width ) 
    segments = segments or 16; -- circle is divided into segments -> higher number = smoother circle = more calculations 
    color = color or tocolor( 255, 255, 0 ); 
    width = width or 1; 
    local segAngle = 360 / segments; 
    local fX, fY, tX, tY; -- drawing line: from - to 
    for i = 1, segments do 
        fX = x + math.cos( math.rad( segAngle * i ) ) * radius; 
        fY = y + math.sin( math.rad( segAngle * i ) ) * radius; 
        tX = x + math.cos( math.rad( segAngle * (i+1) ) ) * radius; 
        tY = y + math.sin( math.rad( segAngle * (i+1) ) ) * radius; 
        dxDrawLine3D( fX, fY, z, tX, tY, z, color, width ); 
    end 
end 

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end	

		if (not bgColor) then
			bgColor = borderColor;
		end

		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
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
end
)

function createLogo()
    local id = 3674
    local txd = engineLoadTXD("files/mods/alphagames.txd")
    local dff = engineLoadDFF("files/mods/alphagames.dff")
    engineImportTXD(txd, id)
    engineReplaceModel(dff, id)
    local object = createObject(id, 238.6, 1819.4580078125, 6.6109375)
    setElementCollisionsEnabled(object, false)
    setElementRotation(object, 90, 90, 0)
    setElementInterior(object, 0)
    setElementDimension(object, 0)
end
addEventHandler("onClientResourceStart", getResourceRootElement(), createLogo)

local col = createColSphere(1797.765625, -1296.8310546875, 120.56524658203, 50)
setElementDimension(col, 4)

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)

addEventHandler("onClientColShapeHit", col, 
    function (theElement, hitElement)
        if theElement == localPlayer then 
            triggerServerEvent("changeDataSync", localPlayer, "fasz", true)
            toggleControl("fire", false)
            toggleControl("action", false)
        end
    end
)

addEventHandler("onClientColShapeLeave", col, 
    function (theElement)
        if theElement == localPlayer then 
            triggerServerEvent("changeDataSync", localPlayer, "fasz", false)
            toggleControl("fire", true)
            toggleControl("action", true)
            print("leave")
        end 
    end
)

ColorSwitches = {}
LastColorSwitches = {}
StartColorSwitch = {}
LastColorConcat = {}
activeButton = false
b = false

function createButton(Name, Text, PosX, PosY, SizeX, SizeY, Color)
	if Name and Text and PosX and PosY and SizeX and SizeY and Color then
		buttons = {}

		buttons[Name] = {PosX, PosY, SizeX, SizeY}
		
		local CursorX, CursorY = getCursorPosition()

		if tonumber(CursorX) then
			CursorX = CursorX * screenX
			CursorY = CursorY * screenY
		end

		if isCursorShowing() then
			for Key, Value in pairs(buttons) do
				if CursorX >= Value[1] and CursorX <= Value[1] + Value[3] and CursorY >= Value[2] and CursorY <= Value[2] + Value[4] then
					activeButton = Key
					break
				end
			end
		end

		if activeButton == Name then
			ButtonData = {ProcessColorSwitchEffect(Name, {Color[1], Color[2], Color[3], 240, 4})}
		else
			ButtonData = {ProcessColorSwitchEffect(Name, {Color[1], Color[2], Color[3], 190, 0})}
		end

		PosX, PosY, SizeX, SizeY = PosX - ButtonData[5] / 2, PosY - ButtonData[5] / 2, SizeX + ButtonData[5], SizeY + ButtonData[5]
		dxDrawRectangle(PosX, PosY, SizeX, SizeY, tocolor(ButtonData[1], ButtonData[2], ButtonData[3], ButtonData[4]))
		dxDrawText(Text, PosX + SizeX / 2, PosY + SizeY / 2, nil, nil, tocolor(200, 200, 200, 240), 0.8, Rubik, "center", "center")

		if activeButton then 
			b = true
		else
			b = false 
		end
	end
end

function ProcessColorSwitchEffect(Key, Color)
	if not ColorSwitches[Key] then
		if not Color[4] then
			Color[4] = 255
		end
		
		ColorSwitches[Key] = Color
		LastColorSwitches[Key] = Color
		
		LastColorConcat[Key] = table.concat(Color)
	end
		
	if LastColorConcat[Key] ~= table.concat(Color) then
		LastColorConcat[Key] = table.concat(Color)
		LastColorSwitches[Key] = Color
		StartColorSwitch[Key] = getTickCount()
	end
		
	if StartColorSwitch[Key] then
		local Progress = (getTickCount() - StartColorSwitch[Key]) / 300
		
		local Red, Green, Blue = interpolateBetween(
			ColorSwitches[Key][1], ColorSwitches[Key][2], ColorSwitches[Key][3],
			Color[1], Color[2], Color[3],
			Progress, "Linear"
		)
		
		Alpha, Size = interpolateBetween(ColorSwitches[Key][4], ColorSwitches[Key][5], 0, Color[4], Color[5], 0, Progress, "Linear")
		
		ColorSwitches[Key][1] = Red
		ColorSwitches[Key][2] = Green
		ColorSwitches[Key][3] = Blue
		ColorSwitches[Key][4] = Alpha
		ColorSwitches[Key][5] = Size
		
		if Progress >= 1 then
			StartColorSwitch[Key] = false
		end
	end
		
	return ColorSwitches[Key][1], ColorSwitches[Key][2], ColorSwitches[Key][3], ColorSwitches[Key][4], ColorSwitches[Key][5]
end