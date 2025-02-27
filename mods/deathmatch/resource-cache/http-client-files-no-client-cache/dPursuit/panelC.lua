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

local barlowRegularBig = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(13), false, "cleartype")
local barlowBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(13), false, "cleartype")
local barlowLightBig = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(13), false, "cleartype")
local barlowLightRegular = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(10), false, "cleartype")
local barlowRegular = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(10), false, "cleartype")
local barlowBold = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(10), false, "cleartype")

local sizeX, sizeY = respc(750), respc(400);
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

local isPanelOpened = false;

local maxVehiclesOnScreen = 10;
local vehicleScrollingValue = 0;

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

function openPanel()
    if not getPlayerSerial(localPlayer) == "53987DDB582C0AC8B9CCD506656ACD13" then
        return
    end

    if isPanelOpened then
        isPanelOpened = false
        removeEventHandler("onClientRender", root, onRender)
        removeEventHandler("onClientClick", root, onClick)
        removeEventHandler("onClientKey", root, onKey)
    else
        isPanelOpened = true
        panelOpenTick = getTickCount()
        
        currentSelectedHeadCategory = "vehicles"
        currentSelectedItem = 1

        addEventHandler("onClientRender", root, onRender)
        addEventHandler("onClientClick", root, onClick)
        addEventHandler("onClientKey", root, onKey)
    end
end
addCommandHandler("pursuitpanel", openPanel)

function onRender()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - panelOpenTick
    local duration = elapsedTime / 500
    local a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

    dxDrawText("alpha", startX + respc(2), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldBig, "left", "center")
    dxDrawText("PURSUIT", startX + respc(3.5) + dxGetTextWidth("alpha", 1, barlowBoldBig), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowLightBig, "left", "center")

    dxDrawRoundedRectangle(startX, startY, sizeX, sizeY, 3, tocolor(35, 35, 35, a))
    if isMouseInPosition(startX + sizeX - respc(17), startY - respc(16), respc(12), respc(12)) then
        dxDrawImage(startX + sizeX - respc(17), startY - respc(16), respc(12), respc(12), "files/img/close.png", 0, 0, 0, tocolor(200, 200, 200, a))
        if getKeyState('mouse1') then
            isPanelOpened = false
            removeEventHandler("onClientRender", root, onRender)
            removeEventHandler("onClientClick", root, onClick)
            removeEventHandler("onClientKey", root, onKey)
        end
    else
        dxDrawImage(startX + sizeX - respc(17), startY - respc(16), respc(12), respc(12), "files/img/close.png", 0, 0, 0, tocolor(200, 200, 200, a*0.75))
    end

    if isMouseInPosition(startX + respc(5), startY + respc(5), (sizeX - respc(15))/2, respc(35)) or currentSelectedHeadCategory == "vehicles" then
        dxDrawRoundedRectangle(startX + respc(5), startY + respc(5), (sizeX - respc(15))/2, respc(35), 3, tocolor(140, 195, 230, a*0.5))
        dxDrawText("JÁRMŰVEK", startX + respc(5) + (sizeX - respc(15))/4, startY + respc(5) + respc(35)/2 - 1, _, _, tocolor(255, 255, 255, a), 1, barlowBoldBig, "center", "center", false, false, false, true)
    else
        dxDrawRoundedRectangle(startX + respc(5), startY + respc(5), (sizeX - respc(15))/2, respc(35), 3, tocolor(45, 45, 45, a))
        dxDrawText("JÁRMŰVEK", startX + respc(5) + (sizeX - respc(15))/4, startY + respc(5) + respc(35)/2 - 1, _, _, tocolor(200, 200, 200, a), 1, barlowRegularBig, "center", "center", false, false, false, true)
    end

    if isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2, startY + respc(5), (sizeX - respc(15))/2, respc(35)) or currentSelectedHeadCategory == "skins" then
        dxDrawRoundedRectangle(startX + respc(10) + (sizeX - respc(15))/2, startY + respc(5), (sizeX - respc(15))/2, respc(35), 3, tocolor(155, 230, 140, a*0.5))
        dxDrawText("KINÉZETEK", startX + respc(10) + (sizeX - respc(15))/2 + (sizeX - respc(15))/4, startY + respc(5) + respc(35)/2 - 1, _, _, tocolor(255, 255, 255, a), 1, barlowBoldBig, "center", "center")
    else
        dxDrawRoundedRectangle(startX + respc(10) + (sizeX - respc(15))/2, startY + respc(5), (sizeX - respc(15))/2, respc(35), 3, tocolor(45, 45, 45, a))
        dxDrawText("KINÉZETEK", startX + respc(10) + (sizeX - respc(15))/2 + (sizeX - respc(15))/4, startY + respc(5) + respc(35)/2 - 1, _, _, tocolor(200, 200, 200, a), 1, barlowRegularBig, "center", "center")
    end

    if currentSelectedHeadCategory == "vehicles" then
        dxDrawRectangle(startX + respc(5), startY + respc(45), (sizeX - respc(15))/2, sizeY - respc(50), tocolor(30, 30, 30, a))
        for i, v in ipairs(vehiclesToBuy) do
            if (i <= maxVehiclesOnScreen) and (i > vehicleScrollingValue) then
                if isMouseInPosition(startX + respc(10), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34), (sizeX - respc(15))/2 - respc(15), respc(30)) or currentSelectedItem == i then
                    dxDrawRectangle(startX + respc(10), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34), (sizeX - respc(15))/2 - respc(15), respc(30), tocolor(45, 45, 45, a))
                    dxDrawText("#" .. i, startX + respc(15), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(15) - 1, _, _, tocolor(150, 150, 150, a), 1, barlowLightRegular, "left", "center")
                    dxDrawText(v[2], startX + respc(50), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(15) - 1, _, _, tocolor(175, 175, 175, a), 1, barlowBold, "left", "center")

                    if v[4] == true then
                        dxDrawImage(startX + respc(315), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(17)/2 - 1, respc(15), respc(15), "files/panel/img/star.png", 0, 0, 0, tocolor(240, 220, 120, a*0.7))
                    else
                        dxDrawImage(startX + respc(315), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(17)/2 - 1, respc(15), respc(15), "files/panel/img/star.png", 0, 0, 0, tocolor(100, 100, 100, a*0.7))
                    end

                    dxDrawImage(startX + respc(345), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(17)/2 - 1, respc(15), respc(15), "files/panel/img/arrow.png", 0, 0, 0, tocolor(200, 200, 200, a*0.7))
                else
                    dxDrawRectangle(startX + respc(10), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34), (sizeX - respc(15))/2 - respc(15), respc(30), tocolor(35, 35, 35, a))
                    dxDrawText("#" .. i, startX + respc(15), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(15) - 1, _, _, tocolor(100, 100, 100, a), 1, barlowLightRegular, "left", "center")
                    dxDrawText(v[2], startX + respc(50), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(15) - 1, _, _, tocolor(150, 150, 150, a), 1, barlowRegular, "left", "center")

                    if v[4] == true then
                        dxDrawImage(startX + respc(315), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(17)/2 - 1, respc(15), respc(15), "files/panel/img/star.png", 0, 0, 0, tocolor(240, 220, 120, a*0.5))
                    else
                        dxDrawImage(startX + respc(315), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(17)/2 - 1, respc(15), respc(15), "files/panel/img/star.png", 0, 0, 0, tocolor(100, 100, 100, a*0.5))
                    end

                    dxDrawImage(startX + respc(345), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34) + respc(17)/2 - 1, respc(15), respc(15), "files/panel/img/arrow.png", 0, 0, 0, tocolor(170, 170, 170, a*0.5))
                end
            end
        end

        local maxVariable = 10
        if #vehiclesToBuy > maxVariable then
            local listHeight = maxVariable * respc(34) - respc(5)
            local visibleItems = (#vehiclesToBuy - maxVariable) + 1
    
            local scrollbarHeight = (listHeight / visibleItems)
    
            if scrollTick2 then
                scrollbarY2 = interpolateBetween(scrollbarY2, 0, 0, startY + respc(50) + (vehicleScrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick2) / 200, "Linear")
            else
                scrollbarY2 = startY + respc(50) + (vehicleScrollingValue * scrollbarHeight)
            end
            dxDrawRectangle(startX + respc(5) + (sizeX - respc(15))/2 - respc(6), startY + respc(50), respc(3), listHeight, tocolor(45, 45, 45, a))
            dxDrawRectangle(startX + respc(5) + (sizeX - respc(15))/2 - respc(6) + 1, scrollbarY2 + 1, respc(1), scrollbarHeight - 2, tocolor(100, 100, 100, a))
        end

        if currentSelectedItem then
            dxDrawRectangle(startX + respc(10) + (sizeX - respc(15))/2, startY + respc(45), (sizeX - respc(15))/2, sizeY - respc(50), tocolor(30, 30, 30, a))
            dxDrawImage(startX + respc(15) + (sizeX - respc(15))/2 + (sizeX - respc(15))/4 - respc(64), startY + respc(30), respc(128), respc(128), "files/panel/img/car.png", 0, 0, 0, tocolor(100, 100, 100, a*0.5))
            dxDrawText(vehiclesToBuy[currentSelectedItem][2], startX + respc(15) + (sizeX - respc(15))/2 + (sizeX - respc(15))/4, startY + respc(140), _, _, tocolor(175, 175, 175, a), 1, barlowBold, "center", "center")
            
            
            if vehiclesToBuy[currentSelectedItem][4] == true then
                dxDrawRectangle(startX + respc(15) + (sizeX - respc(15))/2, startY + respc(160), (sizeX - respc(15))/2 - respc(10), sizeY - respc(170), tocolor(25, 25, 25, a))
                if getElementData(localPlayer, "a.VIP") then
                else
                    dxDrawImage(startX + respc(15) + (sizeX - respc(15))/2 + (sizeX - respc(15))/4 - respc(16), startY + respc(160) + (sizeY - respc(170))/2 - respc(84), respc(32), respc(32), "files/panel/img/star.png", 0, 0, 0, tocolor(240, 220, 120, a))
                    dxDrawText("#F1DB76VIP #c8c8c8EXKLUZÍV JÁRMŰ", startX + respc(15) + (sizeX - respc(15))/2 + (sizeX - respc(15))/4, startY + respc(160) + (sizeY - respc(170))/2 - respc(30), _, _, tocolor(200, 200, 200, a), 1, barlowBoldBig, "center", "center", false, false, false, true)
                    dxDrawText("VIP rang vásárlására a Discord szerverünkön\nvan lehetőség.\n#B2A7ECdiscord.io/alphagamesmta", startX + respc(15) + (sizeX - respc(15))/2 + (sizeX - respc(15))/4, startY + respc(160) + (sizeY - respc(170))/2 + respc(25), _, _, tocolor(200, 200, 200, a), 1, barlowRegular, "center", "center", false, false, false, true)
                end
            else
                dxDrawRectangle(startX + respc(15) + (sizeX - respc(15))/2, startY + respc(160), (sizeX - respc(15))/2 - respc(10), sizeY - respc(170) - respc(70), tocolor(25, 25, 25, a))
                if isMouseInPosition(startX + respc(15) + (sizeX - respc(15))/2, startY + respc(325), (sizeX - respc(15))/2 - respc(10), respc(30)) then
                    dxDrawRoundedRectangle(startX + respc(15) + (sizeX - respc(15))/2, startY + respc(325), (sizeX - respc(15))/2 - respc(10), respc(30), 3, tocolor(155, 230, 140, a*0.5))
                    dxDrawText("VÁSÁRLÁS", startX + respc(15) + (sizeX - respc(15))/2 + ((sizeX - respc(15))/2 - respc(10))/2, startY + respc(325) + respc(15), _, _, tocolor(255, 255, 255, a), 1, barlowBoldBig, "center", "center")
                else
                    dxDrawRoundedRectangle(startX + respc(15) + (sizeX - respc(15))/2, startY + respc(325), (sizeX - respc(15))/2 - respc(10), respc(30), 3, tocolor(155, 230, 140, a*0.3))
                    dxDrawText("VÁSÁRLÁS", startX + respc(15) + (sizeX - respc(15))/2 + ((sizeX - respc(15))/2 - respc(10))/2, startY + respc(325) + respc(15), _, _, tocolor(200, 200, 200, a), 1, barlowRegularBig, "center", "center")
                end
    
                if isMouseInPosition(startX + respc(15) + (sizeX - respc(15))/2, startY + respc(360), (sizeX - respc(15))/2 - respc(10), respc(30)) then
                    dxDrawRoundedRectangle(startX + respc(15) + (sizeX - respc(15))/2, startY + respc(360), (sizeX - respc(15))/2 - respc(10), respc(30), 3, tocolor(140, 195, 230, a*0.5))
                    dxDrawText("AKTIVÁLÁS", startX + respc(15) + (sizeX - respc(15))/2 + ((sizeX - respc(15))/2 - respc(10))/2, startY + respc(360) + respc(15), _, _, tocolor(255, 255, 255, a), 1, barlowBoldBig, "center", "center")
                else
                    dxDrawRoundedRectangle(startX + respc(15) + (sizeX - respc(15))/2, startY + respc(360), (sizeX - respc(15))/2 - respc(10), respc(30), 3, tocolor(140, 195, 230, a*0.3))
                    dxDrawText("AKTIVÁLÁS", startX + respc(15) + (sizeX - respc(15))/2 + ((sizeX - respc(15))/2 - respc(10))/2, startY + respc(360) + respc(15), _, _, tocolor(200, 200, 200, a), 1, barlowRegularBig, "center", "center")
                end

                dxDrawText("ÁR", startX + respc(15) + (sizeX - respc(15))/2 + respc(10), startY + respc(180), _, _, tocolor(150, 150, 150, a), 1, barlowBold, "left", "center")
                dxDrawText("#9BE48F" .. vehiclesToBuy[currentSelectedItem][5] .. "$", startX + respc(15) + (sizeX - respc(15))/2 + respc(10), startY + respc(195), _, _, tocolor(150, 150, 150, a), 1, barlowRegular, "left", "center", false, false, false, true)

                dxDrawText("STÁTUSZ", startX + respc(15) + (sizeX - respc(15))/2 + respc(10), startY + respc(220), _, _, tocolor(150, 150, 150, a), 1, barlowBold, "left", "center")
                dxDrawText("#F1C176Nincs kiválasztva", startX + respc(15) + (sizeX - respc(15))/2 + respc(10), startY + respc(235), _, _, tocolor(150, 150, 150, a), 1, barlowRegular, "left", "center", false, false, false, true)
            end
        end 
    end
end

function onClick(button, state)
    if not isPanelOpened then
        return
    end

    if button == "left" and state == "down" then
        if isMouseInPosition(startX + respc(5), startY + respc(5), (sizeX - respc(15))/2, respc(35)) then
            currentSelectedHeadCategory = "vehicles"
        end

        if isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2, startY + respc(5), (sizeX - respc(15))/2, respc(35)) then
            currentSelectedHeadCategory = "skins"
        end

        if currentSelectedHeadCategory == "vehicles" then
            for i, v in ipairs(vehiclesToBuy) do
                if (i <= maxVehiclesOnScreen) and (i > vehicleScrollingValue) then
                    if isMouseInPosition(startX + respc(10), startY + respc(50) + (i - vehicleScrollingValue - 1) * respc(34), (sizeX - respc(15))/2 - respc(15), respc(30)) then
                        currentSelectedItem = i
                    end
                end
            end
        end
    end
end

function onKey(key, state)
    if not isPanelOpened then
        return
    end

    if currentSelectedHeadCategory == "vehicles" then
        if isMouseInPosition(startX + respc(5), startY + respc(45), (sizeX - respc(15))/2, sizeY - respc(50)) then
            if key == "mouse_wheel_up" then
                scrollTick2 = getTickCount()
                if vehicleScrollingValue > 0  then
                    vehicleScrollingValue = vehicleScrollingValue - 1
                    maxVehiclesOnScreen = maxVehiclesOnScreen - 1
                end
            elseif key == "mouse_wheel_down" then
                scrollTick2 = getTickCount()
                if maxVehiclesOnScreen < #vehiclesToBuy then
                    vehicleScrollingValue = vehicleScrollingValue + 1
                    maxVehiclesOnScreen = maxVehiclesOnScreen + 1
                end
            end
        end
    end
end

setTimer(openPanel, 500, 1)