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

local poppinsBoldVeryBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(20), false, "cleartype")
local poppinsRegularVeryBig = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(15), false, "cleartype")

local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(15), false, "cleartype")
local poppinsLightBig = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(14), false, "cleartype")

local sizeX, sizeY = respc(400), respc(300)
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2

local scrollingValue = 0
local maxSkinsShowed = 8

local previewEnabled = false
local currentSelectedSkin = 1

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)

function onRender()
    if not (getElementDimension(localPlayer) == 0) then
        return
    end
    r, g, b = interpolateBetween(75, 178, 213, 103, 179, 213, getTickCount()/4000, "SineCurve")
    a, radius = interpolateBetween(150, 0.5, 0, 250, 0.6, 0, getTickCount()/7500, "SineCurve")

    dxDrawCircle3D(skinShopMarker[1] - 1, skinShopMarker[2] - 1, skinShopMarker[3] - 0.9, radius, 8, tocolor(r, g, b, a), 1)
    dxDrawCircle3D(skinShopMarker[1] - 1, skinShopMarker[2] - 1, skinShopMarker[3] - 0.9, radius + 0.1, 8, tocolor(r, g, b, a), 1)
    dxDrawCircle3D(skinShopMarker[1] - 1, skinShopMarker[2] - 1, skinShopMarker[3] - 0.9, radius + 0.2, 8, tocolor(r, g, b, a), 1)

    local pX, pY, pZ = getElementPosition(localPlayer)
    local mX, mY, mZ = skinShopMarker[1] - 1, skinShopMarker[2] - 1, skinShopMarker[3] - 0.85
    local distanceFromMarker = getDistanceBetweenPoints3D(pX, pY, pZ, mX, mY, mZ)
    if distanceFromMarker < 5 then
        local x, y = getScreenFromWorldPosition(skinShopMarker[1] - 1, skinShopMarker[2] - 1,  skinShopMarker[3] - 0.4, 0.06)
        if x and y then
            posY = interpolateBetween(y - respc(130), 0, 0, y - respc(110), 0, 0, getTickCount()/4000, "CosineCurve")

           dxDrawText("Skinshop", x + 1, posY + respc(90) + 1, _, _, tocolor(20, 20, 20), 1, poppinsBoldVeryBig, "center", "center")
           dxDrawText("Skinshop", x, posY + respc(90), _, _, tocolor(200, 200, 200), 1, poppinsBoldVeryBig, "center", "center")
           dxDrawText("Itt tudsz kinézetet vásárolni magadnak.", x, posY + respc(110), _, _, tocolor(200, 200, 200, 150), 1, poppinsRegularVeryBig, "center", "center")

           dxDrawImage(x - respc(25) + 1, posY + respc(25) - respc(15) + 1, respc(50), respc(50), ":a_lobby/files/icons/arrow.png", 90, 0, 0, tocolor(20, 20, 20, 200))
           dxDrawImage(x - respc(25) + 1, posY + respc(25), respc(50) + 1, respc(50), ":a_lobby/files/icons/arrow.png", 90, 0, 0, tocolor(20, 20, 20, 200))

           dxDrawImage(x - respc(25), posY + respc(25) - respc(15), respc(50), respc(50), ":a_lobby/files/icons/arrow.png", 90, 0, 0, tocolor(r, g, b, 200))
           dxDrawImage(x - respc(25), posY + respc(25), respc(50), respc(50), ":a_lobby/files/icons/arrow.png", 90, 0, 0, tocolor(r, g, b, 200))
        end
    end
end
setTimer(onRender, 5, 0)

function onRender()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - colTick
    local duration = elapsedTime / 500

    if panelState == "open" then
        a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")
    elseif panelState == "close" then
        a = interpolateBetween(a, 0, 0, 0, 0, 0, duration, "Linear")
        if a == 0 then
            removeEventHandler("onClientRender", root, onRender)
        end
    end

    dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
    dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))

    dxDrawText("#E48F8Falpha", startX + respc(2), startY - respc(8.5), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "left", "center", false, false, false, true)
    dxDrawText("SKINSHOP", startX + respc(4) + dxGetTextWidth("alpha", 1, poppinsBoldBig), startY - respc(8.5), _, _, tocolor(200, 200, 200, a), 1, poppinsLightBig, "left", "center", false, false, false, true)

    -- ** SKINLISTA
    dxDrawRectangle(startX + respc(5), startY + respc(5), (sizeX - respc(15)) / 2 + respc(3), sizeY - respc(10) - respc(1), tocolor(25, 25, 25, a))
    for k, v in ipairs(skins) do
        if (k <= maxSkinsShowed) and (k > scrollingValue) then
            if isMouseInPosition(startX + respc(10), startY + respc(10) + (k - 1 - scrollingValue) * respc(35), (sizeX - respc(15)) / 2 - respc(10), respc(30)) or currentSelectedSkin == k then
                dxDrawRectangle(startX + respc(10), startY + respc(10) + (k - 1 - scrollingValue) * respc(35), (sizeX - respc(15)) / 2 - respc(10), respc(30), tocolor(65, 65, 65, a))
                dxDrawText(k, startX + respc(35), startY + respc(25) + (k - 1 - scrollingValue) * respc(35)+ 1, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center")
                dxDrawText(v[2] .. "$", startX + respc(150), startY + respc(25) + (k - 1 - scrollingValue) * respc(35) + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center")
            else
                dxDrawRectangle(startX + respc(10), startY + respc(10) + (k - 1 - scrollingValue) * respc(35), (sizeX - respc(15)) / 2 - respc(10), respc(30), tocolor(45, 45, 45, a))
                dxDrawText(k, startX + respc(35), startY + respc(25) + (k - 1 - scrollingValue) * respc(35)+ 1, _, _, tocolor(150, 150, 150, a), 1, poppinsBoldBig, "center", "center")
                dxDrawText(v[2] .. "$", startX + respc(150), startY + respc(25) + (k - 1 - scrollingValue) * respc(35) + 1, _, _, tocolor(150, 150, 150, a), 1, poppinsBoldBig, "center", "center")
            end
        end
    end

    local maxVariable = 8
	if #skins > maxVariable then
		local listHeight = maxVariable * respc(35) - respc(5)
		local visibleItems = (#skins - maxVariable) + 1

		scrollbarHeight = (listHeight / visibleItems)

		if scrollTick then
			scrollbarY = interpolateBetween(scrollbarY, 0, 0, startY + respc(10) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 500, "Linear")
		else
			scrollbarY = startY + respc(10) + (scrollingValue * scrollbarHeight)
		end
		dxDrawRectangle(startX + respc(2) + (sizeX - respc(15)) / 2, startY + respc(10), respc(4), listHeight, tocolor(65, 65, 65, 200))
		dxDrawRectangle(startX + respc(2) + (sizeX - respc(15)) / 2 + 1, scrollbarY + 1, respc(2), scrollbarHeight - 2, tocolor(120, 120, 120, 200))
	end

    dxDrawRectangle(startX + respc(10) + (sizeX - respc(15)) / 2, startY + respc(5), (sizeX - respc(15)) / 2 - respc(2), sizeY - respc(55), tocolor(25, 25, 25, a))
    
    -- ** VÁSÁRLÁS
    if isMouseInPosition(startX + respc(10) + (sizeX - respc(15)) / 2, startY + respc(5) + sizeY - respc(50), (sizeX - respc(15)) / 2 - respc(2), respc(35)) then
        dxDrawRectangle(startX + respc(10) + (sizeX - respc(15)) / 2, startY + respc(5) + sizeY - respc(50), (sizeX - respc(15)) / 2 - respc(2), respc(35), tocolor(60, 60, 60, a))
    else
        dxDrawRectangle(startX + respc(10) + (sizeX - respc(15)) / 2, startY + respc(5) + sizeY - respc(50), (sizeX - respc(15)) / 2 - respc(2), respc(35), tocolor(50, 50, 50, a))
    end
    dxDrawText("Vásárlás", startX + respc(10) + (sizeX - respc(15)) / 2 + ((sizeX - respc(15)) / 2 - respc(2)) / 2, startY + respc(5) + sizeY - respc(50) + (respc(35))/2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center")

    if previewEnabled then
        exports.a_3dview:setSkinProjection(startX + respc(10) + (sizeX - respc(15)) / 2 - respc(25), startY + respc(5) - respc(35), (sizeX - respc(15)) / 2 - respc(2) + respc(50), sizeY - respc(50)+ respc(50), 255)
    else
        dxDrawText("ELŐNÉZET", startX + respc(10) + (sizeX - respc(15)) / 2 + ((sizeX - respc(15)) / 2) / 2, startY + respc(5) + (sizeY - respc(50)) / 2, _, _, tocolor(150, 150, 150, a), 1, poppinsLightBig, "center", "center")
    end
end

addEventHandler("onClientKey", getRootElement(), function(button, press)
	if press and panelState == "open" then
		if isMouseInPosition(startX, startY, sizeX, sizeY) then
			if button == "mouse_wheel_up" then
				if scrollingValue > 0  then
					scrollingValue = scrollingValue -1
					maxSkinsShowed = maxSkinsShowed -1
				end
			elseif button == "mouse_wheel_down" then
				if maxSkinsShowed < #skins then
					scrollingValue = scrollingValue +1
					maxSkinsShowed = maxSkinsShowed +1
                end
			end
		end
    end
end)

local skinID = nil

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if panelState == "open" and button == "left" and state == "down" then
        for k, v in ipairs(skins) do
            if (k <= maxSkinsShowed) and (k > scrollingValue) then
                if isMouseInPosition(startX + respc(10), startY + respc(10) + (k - 1 - scrollingValue) * respc(35), (sizeX - respc(15)) / 2 - respc(10), respc(30)) then
                    currentSelectedSkin = k                    
                    previewEnabled = true
                    exports.a_3dview:setSkin(v[1])
                end
            end
		end
        if isMouseInPosition(startX + respc(10) + (sizeX - respc(15)) / 2, startY + respc(5) + sizeY - respc(50), (sizeX - respc(15)) / 2 - respc(2), respc(35)) then
            if not tonumber(currentSelectedSkin) then
                exports.a_interface:makeNotification(2, "Először válaszd ki melyik skint szeretnéd megvásárolni.")
                return
            end

            local currentPlayerMoney = getElementData(localPlayer, "a.Money")
            if currentPlayerMoney >= skins[currentSelectedSkin][2] then  
                local skinID = skins[currentSelectedSkin][1]
                triggerServerEvent("changePlayerSkin", localPlayer, localPlayer, tonumber(skinID))

                outputChatBox("#9BE48F► Siker: #FFFFFFSikeresen megvetted a kiválasztott kinézetet. #9BE48F(Skin ID: " .. tonumber(skinID) .. ")", 255, 255, 255, true)
                exports.a_interface:makeNotification(1, "Sikeresen megvetted a kiválasztott kinézetet.")
                
                colTick = getTickCount()
                panelState = "close"
                exports.a_3dview:processSkinPreview()
                triggerServerEvent("changeDataSync", localPlayer, "a.Money", currentPlayerMoney - skins[currentSelectedSkin][2])
            else
                exports.a_interface:makeNotification(2, "Nincs elég pénzed a művelet végrehajtásához.")
            end
        end
	end
end
addEventHandler("onClientClick", root, onClick)

function onColHit(element, dim)
    if getElementData(source, "a.SkinshopCol") == true and element == localPlayer and dim then
        colTick = getTickCount()
        panelState = "open"

        addEventHandler("onClientRender", root, onRender)
        previewEnabled = true

        exports.a_3dview:processSkinPreview(skins[currentSelectedSkin][1], startX + respc(10) + (sizeX - respc(15)) / 2, startY + respc(5), (sizeX - respc(15)) / 2 - respc(2), sizeY - respc(50))
    end
end
addEventHandler("onClientColShapeHit", root, onColHit)

function onColLeave(element, dim)
    if getElementData(source, "a.SkinshopCol") == true and element == localPlayer then
        colTick = getTickCount()
        panelState = "close"
        exports.a_3dview:processSkinPreview()
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

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end