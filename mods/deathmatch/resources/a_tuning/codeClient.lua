local tuningRender = false;
local sX, sY = guiGetScreenSize();
local tuningPanel = {350, 160}
local currentValue = {}

local menuThings = {
    {"Optical"},
    --{"Repaint"},
    {"Extras"},
}
local subMenuThings = {
    [1] = {
        {"Hood", 7},
        {"Wheels", 12},
        {"Wing", 2},
        {"Front bumper", 14},
        {"Rear bumper", 15},
        {"Exhaust", 13},
        {"Skirt", 3},
    },
    --
    [2] = {
        {"Airride", "airride", 1, "a.Airride"},
        {"Nitro", "nitro", 1, "a.Nitro"},
        {"Backfire", "bf", 1, "a.Backfire"},
        --{"Drivetype", "drivetype", 1, "a.Drivetype"},
        {"Bodykit", "bodykit", 7, "a.Bodykit"},
        --{"Facelift", "facelift", 0},
        --{"Paintjob", "pj", 0},
        --{"Wheel wideness", "ww", 0},
    },
}

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)


--** MARKER RENDER

local logoMaterial = dxCreateTexture("files/img/logo.png", "argb")

function onMarkerRender()
    if getElementDimension(localPlayer) == 3 then
        for k, v in ipairs(tuningMarkerPositions) do
            dxDrawCircle3D(v[1], v[2], v[3] + 0.5, 2, 100, tocolor(240, 100, 100, 255), 2)
            dxDrawCircle3D(v[1], v[2], v[3] + 0.6, 2, 100, tocolor(240, 100, 100, 255), 1)
            dxDrawCircle3D(v[1], v[2], v[3] + 0.7, 2, 100, tocolor(240, 100, 100, 255), 1)
        end
    end
end
--addEventHandler("onClientRender", root, onMarkerRender)

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

--** HIT TRIGGER
function onHit(element, dim)
    if getElementData(source, "a.Tuningmarker") == true and isPedInVehicle(element) then
        if getPedOccupiedVehicleSeat(element) == 0 then
            if not (element == localPlayer) then
                return
            end

            if getElementData(source, "a.TuningMarkerInUse") == true then
                return
            end


            addEventHandler("onClientRender", root, onRender)
            addEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientClick", root, onClick)

            triggerServerEvent("changeDataSync", source, "a.TuningMarkerInUse", true)
            triggerServerEvent("changeDataSync", element, "a.HUDshowed", false)
            triggerServerEvent("changeDataSync", element, "a.TuningProgress", true)
            showChat(false)
            tuningRender = true

            local vehicle = getPedOccupiedVehicle(element)
            setElementFrozen(vehicle, true)
            toggleControl("accelerate", false)
            toggleControl("brake_reverse", false)

            local id = getElementData(source, "a.TuningmarkerID")
            setElementPosition(vehicle, tuningMarkerPositions[id][1], tuningMarkerPositions[id][2], tuningMarkerPositions[id][3])

            local x, y, z, lx, ly, lz = getCameraMatrix()
            local lookX, lookY, lookZ = getElementPosition(vehicle)

            --setCameraMatrix(tuningMarkerPositions[id][1] + 5, tuningMarkerPositions[id][2] + 5, tuningMarkerPositions[id][3] + 2, lookX, lookY, lookZ)

            setElementAlpha(source, 0)
            triggeredMarker = source
            currentSaved = false
            pressed = false
            panelState = ""
            panelType = 0
            scrollingValue = 0
            currentSelectedColor = 0
            maxSubmenuItemsShowed = 2
            r, g, b, r2, g2, b2 = getVehicleColor(getPedOccupiedVehicle(localPlayer), true)

            --triggerServerEvent("requestTuningInformations", localPlayer, localPlayer, vehicle)
            for k, v in ipairs(subMenuThings[1]) do
                currentValue[k] = 1
            end

            for k, v in ipairs(subMenuThings[2]) do
                if v[4] == "a.Bodykit" then
                    currentValue[k] = tonumber(getElementData(vehicle, "a.Bodykit"))
                else
                    if getElementData(vehicle, v[4]) == true then
                        currentValue[k] = 1
                    else
                        currentValue[k] = 0
                    end
                end
            end

            openTick = getTickCount()
        end
    end
end
addEventHandler("onClientMarkerHit", root, onHit)

--** FONTS

local robotoBold13 = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 13, false, "cleartype")
local robotoBold10 = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 10, false, "cleartype")
local robotoBold15 = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 15, false, "cleartype")
local robotoRegular13 = dxCreateFont("files/fonts/Roboto-Condensed.ttf", 13, false, "antialiased")
local robotoThin15 = dxCreateFont("files/fonts/Roboto-Thin.ttf", 15, false, "antialiased")

--** RENDER
function onRender()
    if not tuningRender then
        return
    end

    local nowTick = getTickCount()
    local elapsedTime = nowTick - openTick
    local duration = elapsedTime / 2000
    a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

    dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2, a / 3))

    if panelState == "expanding" then
        local duration = (nowTick - changeTick) / 1500
        w = interpolateBetween(tuningPanel[1], 0, 0, tuningPanel[1]*2, 0, 0, duration, "InQuad")
        startX = interpolateBetween(sX, 0, 0, sX - tuningPanel[1], 0, 0, duration, "InQuad")
        a2 = interpolateBetween(0, 0, 0, 220, 0, 0, duration / 2, "Linear")
    elseif panelState == "narrowing" then
        local duration = (nowTick - changeTick) / 1500
        w = interpolateBetween(w, 0, 0, tuningPanel[1], 0, 0, duration, "Linear")
        startX = interpolateBetween(startX, 0, 0, sX, 0, 0, duration, "InQuad")
        a2 = interpolateBetween(a2, 0, 0, 0, 0, 0, duration / 2, "Linear")
    else
        startX = sX
        w = tuningPanel[1]
    end

    exports.a_core:dxDrawRoundedRectangle(startX - tuningPanel[1] - 10, sY - tuningPanel[2] - 30, w, tuningPanel[2], tocolor(65, 65, 65, a), 5)
    exports.a_core:dxDrawRoundedRectangle(startX - tuningPanel[1] - 8, sY - tuningPanel[2] - 30 + 2, w - 4, tuningPanel[2] - 4, tocolor(35, 35, 35, a), 5)
    exports.a_core:dxDrawRoundedRectangle(startX - tuningPanel[1] - 10, sY - tuningPanel[2] - 30, w, 30, tocolor(65, 65, 65, a), 5)

    if panelState == "expanding" then
        if isMouseInPosition(startX + w / 2 - 35, sY - tuningPanel[2] - 25, 20, 20) then
            dxDrawImage(startX + w / 2 - 35, sY - tuningPanel[2] - 25, 20, 20, "files/img/arrow.png", 180, 0, 0, tocolor(200, 200, 200, a2))
        else
            dxDrawImage(startX + w / 2 - 35, sY - tuningPanel[2] - 25, 20, 20, "files/img/arrow.png", 180, 0, 0, tocolor(150, 150, 150, a2))
        end
        if panelType == 1 then
            for k, v in ipairs(subMenuThings[1]) do
                if k <= maxSubmenuItemsShowed and (k > scrollingValue) then
                    exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 15, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55), tuningPanel[1] - 45, 50, tocolor(45, 45, 45, a2), 10)
                    dxDrawText(v[1], startX -tuningPanel[1] + w/2 + 25, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 25, _, _, tocolor(200, 200, 200, a2), 1, robotoThin15, "left", "center", false, false, false, true)
                    if isMouseInPosition(startX -tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 + 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32) then
                        dxDrawImage(startX - tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 + 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32, "files/img/arrow.png", 0, 0, 0, tocolor(100, 100, 100, a2))
                    else
                        dxDrawImage(startX - tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 + 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32, "files/img/arrow.png", 0, 0, 0, tocolor(75, 75, 75, a2))
                    end

                    if isMouseInPosition(startX -tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 - 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32) then
                        dxDrawImage(startX - tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 - 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32, "files/img/arrow.png", 180, 0, 0, tocolor(100, 100, 100, a2))
                    else
                        dxDrawImage(startX - tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 - 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32, "files/img/arrow.png", 180, 0, 0, tocolor(75, 75, 75, a2))
                    end

                    dxDrawText(currentValue[k], startX -tuningPanel[1] + w/2 + tuningPanel[1] - 60, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 25, _, _, tocolor(200, 200, 200, a2), 1, robotoRegular13, "center", "center", false, false, false, true)
                end
            end
        --[[elseif panelType == 2 then
            if isElement(colorPicker) then
                cr, cg, cb, alpha = exports.a_dgs:dgsColorPickerGetColor(colorPicker)
                dxDrawText("#E48F8FR: " .. cr .. " \n#9BE48FG: " .. cg .. " \n#8FC3E4B: " .. cb .. " \n#c8c8c8A: " .. alpha, startX -tuningPanel[1] + w/2 + 175, sY - tuningPanel[2] + 85, _, _, tocolor(200, 200, 200, a2), 1, robotoBold15, "left", "center", false, false, false, true)
            end
            if currentSelectedColor == 1 then
                setVehicleColor(getPedOccupiedVehicle(localPlayer), cr, cg, cb, r2, g2, b2)
            elseif currentSelectedColor == 2 then
                setVehicleColor(getPedOccupiedVehicle(localPlayer), r, g, b, cr, cg, cb)
            else
                setVehicleColor(getPedOccupiedVehicle(localPlayer), r, g, b, r2, g2, b2)
            end

            exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 30, 75, 25, tocolor(65, 65, 65, a2), 5)
            if isMouseInPosition(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 30, 75, 25) or currentSelectedColor == 1 then
                exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250 + 2, sY - tuningPanel[2] + 30 + 2, 75 - 4, 25 - 4, tocolor(65, 65, 65, a2), 5)
            else
                exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250 + 2, sY - tuningPanel[2] + 30 + 2, 75 - 4, 25 - 4, tocolor(35, 35, 35, a2), 5)
            end
            dxDrawText("COLOR 1", startX -tuningPanel[1] + w/2 + 250 + 75/4 - 4, sY - tuningPanel[2] + 30 + 25/4 -2, _, _, tocolor(200, 200, 200, a2), 1, robotoBold10)
            
            exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 65, 75, 25, tocolor(65, 65, 65, a2), 5)
            if isMouseInPosition(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 65, 75, 25) or currentSelectedColor == 2 then
                exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250 + 2, sY - tuningPanel[2] + 65 + 2, 75 - 4, 25 - 4, tocolor(65, 65, 65, a2), 5)
            else
                exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250 + 2, sY - tuningPanel[2] + 65 + 2, 75 - 4, 25 - 4, tocolor(35, 35, 35, a2), 5)
            end
            dxDrawText("COLOR 2", startX -tuningPanel[1] + w/2 + 250 + 75/4 - 4, sY - tuningPanel[2] + 65 + 25/4 - 2, _, _, tocolor(200, 200, 200, a2), 1, robotoBold10)

            exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 120, 75, 25, tocolor(155/2, 230/2, 140/2, a2), 5)
            if isMouseInPosition(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 120, 75, 25) then
                exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250 + 2, sY - tuningPanel[2] + 120 + 2, 75 - 4, 25 - 4, tocolor(65, 65, 65, a2), 5)
            else
                exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 250 + 2, sY - tuningPanel[2] + 120 + 2, 75 - 4, 25 - 4, tocolor(35, 35, 35, a2), 5)
            end
            dxDrawText("SAVE", startX -tuningPanel[1] + w/2 + 250 + 75/4 + 3, sY - tuningPanel[2] + 120 + 25/4 - 2, _, _, tocolor(200, 200, 200, a2), 1, robotoBold10)]]--
        elseif panelType == 2 then
            for k, v in ipairs(subMenuThings[2]) do
                if k <= maxSubmenuItemsShowed and (k > scrollingValue) then
                    exports.a_core:dxDrawRoundedRectangle(startX -tuningPanel[1] + w/2 + 15, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55), tuningPanel[1] - 45, 50, tocolor(45, 45, 45, a2), 10)
                    dxDrawText(v[1], startX -tuningPanel[1] + w/2 + 25, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 25, _, _, tocolor(200, 200, 200, a2), 1, robotoThin15, "left", "center", false, false, false, true)
                    
                    if v[3] == 1 then
                        if currentValue[k] == 1 then
                            dxDrawText("#E48F8Fremove", startX -tuningPanel[1] + w/2 + tuningPanel[1] - 90, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 25, _, _, tocolor(200, 200, 200, a2), 1, robotoRegular13, "left", "center", false, false, false, true)
                        elseif currentValue[k] == 0 then
                            dxDrawText("#9BE48Fequip",startX -tuningPanel[1] + w/2 + tuningPanel[1] - 90, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 25, _, _, tocolor(200, 200, 200, a2), 1, robotoRegular13, "left", "center", false, false, false, true)
                        end
                    else
                        dxDrawText(currentValue[k], startX -tuningPanel[1] + w/2 + tuningPanel[1] - 60, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 25, _, _, tocolor(200, 200, 200, a2), 1, robotoRegular13, "left", "center", false, false, false, true)
                    end
                    
                    if isMouseInPosition(startX -tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 + 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32) then
                        dxDrawImage(startX - tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 + 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32, "files/img/arrow.png", 0, 0, 0, tocolor(100, 100, 100, a2))
                    else
                        dxDrawImage(startX - tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 + 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32, "files/img/arrow.png", 0, 0, 0, tocolor(75, 75, 75, a2))
                    end

                    if isMouseInPosition(startX -tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 - 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32) then
                        dxDrawImage(startX - tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 - 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32, "files/img/arrow.png", 180, 0, 0, tocolor(100, 100, 100, a2))
                    else
                        dxDrawImage(startX - tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 - 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32, "files/img/arrow.png", 180, 0, 0, tocolor(75, 75, 75, a2))
                    end
                end
            end
        end
    end

    dxDrawImage(startX - tuningPanel[1] - 5, sY - tuningPanel[2] - 32 + (30/4), 20, 20, "files/img/logo.png", 0, 0, 0, tocolor(200, 200, 200, a))
    dxDrawText("#D19D6Balpha#c8c8c8Games - Tuning", startX - tuningPanel[1] + 20, sY - tuningPanel[2] - 15, _, _, tocolor(200, 200, 200, a), 1, robotoBold13, "left", "center", false, false, false, true)

    if isMouseInPosition(startX - 70, sY - tuningPanel[2] - 30 + 5, 50, 20) then
        exports.a_core:dxDrawRoundedRectangle(startX - 70, sY - tuningPanel[2] - 30 + 5, 50, 20, tocolor(230, 140, 140, a/2), 5)
    else
        exports.a_core:dxDrawRoundedRectangle(startX - 70, sY - tuningPanel[2] - 30 + 5, 50, 20, tocolor(115, 70, 70, a/2), 5)
    end
    dxDrawText("SAVE", startX - 70 + 25, sY - tuningPanel[2] - 30 + 5 + 10, _, _, tocolor(200, 200, 200, a), 1, robotoBold10, "center", "center", false, false, false, true)

    for k, v in pairs(menuThings) do
        exports.a_core:dxDrawRoundedRectangle(startX - tuningPanel[1] + 5, sY - tuningPanel[2] + 15 + ((k-1) * 55), tuningPanel[1] - 30, 50, tocolor(65, 65, 65, a), 10)
        if isMouseInPosition(startX - tuningPanel[1] + 5, sY - tuningPanel[2] + 15 + ((k-1) * 55), tuningPanel[1] - 30, 50) or panelType == k then
            local hoverColor = {65, 65, 65}
            exports.a_core:dxDrawRoundedRectangle(startX - tuningPanel[1] + 5 + 2, sY - tuningPanel[2] + 15 + ((k-1) * 55) + 2, tuningPanel[1] - 30 - 4, 50 - 4, tocolor(hoverColor[1], hoverColor[2], hoverColor[3], a), 10)
            dxDrawText(v[1], startX - tuningPanel[1] + 5 + (tuningPanel[1] - 30)/2, sY - tuningPanel[2] + 15 + ((k-1) * 55) + 25, _, _, tocolor(200, 200, 200, a), 1, robotoBold15, "center", "center", false, false, false, true)
        else
            local hoverColor = {35, 35, 35}
            exports.a_core:dxDrawRoundedRectangle(startX - tuningPanel[1] + 5 + 2, sY - tuningPanel[2] + 15 + ((k-1) * 55) + 2, tuningPanel[1] - 30 - 4, 50 - 4, tocolor(hoverColor[1], hoverColor[2], hoverColor[3], a), 10)
            dxDrawText(v[1], startX - tuningPanel[1] + 5 + (tuningPanel[1] - 30)/2, sY - tuningPanel[2] + 15 + ((k-1) * 55) + 25, _, _, tocolor(200, 200, 200, a), 1, robotoBold15, "center", "center", false, false, false, true)
        end
    end
end

--** CLICK TRIGGER

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if not tuningRender then
        return
    end

    if button == "left" and state == "down" then
        if isMouseInPosition(startX - 70, sY - tuningPanel[2] - 30 + 5, 50, 20) then
            exports.a_interface:makeNotification(1, "You have successfully saved this preset on your vehicle.")
            currentSaved = true
            --r, g, b, a = exports.a_dgs:dgsColorPickerGetColor(colorPicker) or 200, 200, 200
            --triggerServerEvent("serverResponse", localPlayer, localPlayer, "repaint", r, g, b)
            if currentSelectedColor > 0 then
                currentSelectedColor = 0
                local r, g, b, r2, g2, b2 = getVehicleColor(getPedOccupiedVehicle(localPlayer), true)
                setVehicleColor(getPedOccupiedVehicle(localPlayer), r, g, b, r2, g2, b2)
            end
            triggerServerEvent("saveTuningPreset", localPlayer, localPlayer)
        end
        for k, v in ipairs(menuThings) do
            if isMouseInPosition(startX - tuningPanel[1] + 5, sY - tuningPanel[2] + 15 + ((k-1) * 55), tuningPanel[1] - 30, 50) then
                if not (panelType == k) then
                    panelState = "expanding"
                    changeTick = getTickCount()
                    panelType = k
                    scrollingValue = 0
                    --[[if isElement(colorPicker) then
                        destroyElement(colorPicker)
                    end
                    if panelType == 2 then
                        setTimer(function()
                            if not (panelType == 2 ) then
                                return
                            end
                            if isElement(colorPicker) then
                                destroyElement(colorPicker)
                            end
                            colorPicker = exports.a_dgs:dgsCreateColorPicker("HSLSquare", startX -tuningPanel[1] + w/2 + 15, sY - tuningPanel[2] + 20, 150, 150, false)
                        end, 1500, 1)
                    end]]--
                else
                    panelState = "narrowing"
                    maxSubmenuItemsShowed = 3
                    scrollingValue = 0
                    changeTick = getTickCount()
                    panelType = 0
                    if isElement(colorPicker) then
                        destroyElement(colorPicker)
                    end
                end
            end
        end

        if panelState == "expanding" and panelType == 1 then
            for k, v in ipairs(subMenuThings[1]) do
                if k <= maxSubmenuItemsShowed and (k > scrollingValue) then
                    if isMouseInPosition(startX -tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 + 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32) then
                        local veh = getPedOccupiedVehicle(localPlayer)
                        local maxNumber = getVehicleCompatibleUpgrades(veh, v[2])
                        a = 0
                        for i, v in ipairs(maxNumber) do
                            a = a + 1
                        end

                        if a == 0 then
                            currentValue[k] = currentValue[k]
                        else
                            if currentValue[k] + 1 > a then
                                currentValue[k] = a
                            else
                                currentValue[k] = currentValue[k] + 1
                            end
                        end

                        num = currentValue[k]
                        local upgradeTable = getVehicleCompatibleUpgrades(veh, v[2])
                        if (upgradeTable[num]) then
                            triggerServerEvent("serverResponse", localPlayer, localPlayer, "saveOpticalTuning", num, v[2])
                        end
                    end

                    if isMouseInPosition(startX -tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 - 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32) then
                        if currentValue[k] - 1 < 0 then
                            currentValue[k] = 0
                        else
                            currentValue[k] = currentValue[k] - 1
                        end

                        num = currentValue[k]
                        local veh = getPedOccupiedVehicle(localPlayer)
                        local upgradeTable = getVehicleCompatibleUpgrades(veh, v[2])
                        if (upgradeTable[num]) or (upgradeTable[num+1]) then
                            if num == 0 then
                                triggerServerEvent("serverResponse", localPlayer, localPlayer, "saveOpticalTuning", num, v[2])
                            else
                                triggerServerEvent("serverResponse", localPlayer, localPlayer, "saveOpticalTuning", num, v[2])
                            end
                        end
                    end
                end
            end
        end

        --[[if panelState == "expanding" and panelType == 2 then
            if isMouseInPosition(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 30, 75, 25) then
                currentSelectedColor = 1
            elseif isMouseInPosition(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 65, 75, 25) then
                currentSelectedColor = 2
            elseif isMouseInPosition(startX -tuningPanel[1] + w/2 + 250, sY - tuningPanel[2] + 120, 75, 25) and currentSelectedColor > 0 then
                print(cr .. " " .. cg .. " " .. cb)
                triggerServerEvent("serverResponse", localPlayer, localPlayer, "repaint", currentSelectedColor, cr, cg, cb)
                currentSelectedColor = 0
            end
        end]]--

        if panelState == "expanding" and panelType == 2 then
            for k, v in ipairs(subMenuThings[2]) do
                if k <= maxSubmenuItemsShowed and (k > scrollingValue) then
                    if isMouseInPosition(startX -tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 + 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32) then
                        if currentValue[k] + 1 > v[3] then
                            currentValue[k] = 1
                            triggerServerEvent("serverResponse", localPlayer, localPlayer, v[2], currentValue[k])
                        else
                            currentValue[k] = currentValue[k] + 1
                            triggerServerEvent("serverResponse", localPlayer, localPlayer, v[2], currentValue[k])
                        end
                    end

                    if isMouseInPosition(startX -tuningPanel[1] + w/2 + 15 + (tuningPanel[1] - 45)/2 - 16, sY - tuningPanel[2] + 15 + ((k-1 - scrollingValue) * 55) + 50/4 - 3, 32, 32) then
                        if currentValue[k] - 1 < 0 then
                            currentValue[k] = 0
                            triggerServerEvent("serverResponse", localPlayer, localPlayer, v[2], currentValue[k])
                        else
                            currentValue[k] = currentValue[k] - 1
                            triggerServerEvent("serverResponse", localPlayer, localPlayer, v[2], currentValue[k])
                        end
                    end
                end
            end
        end

        if panelState == "expanding" and isMouseInPosition(startX + w / 2 - 35, sY - tuningPanel[2] - 25, 20, 20) then
            panelState = "narrowing"
            changeTick = getTickCount()
            panelType = 0
            maxSubmenuItemsShowed = 3
            scrollingValue = 0
            if isElement(colorPicker) then
                destroyElement(colorPicker)
            end
        end
    end
end

--** KEY TRIGGERS

function onKey(key, press)
    if not tuningRender then
        return
    end

    if key == "backspace" and press == true then
        if not currentSaved and not pressed then
            exports.a_interface:makeNotification(2, "You haven't saved your preset yet, press 'BACKSPACE' again to quit without saving.")
            pressed = true
            return
        end
        removeEventHandler("onClientRender", root, onRender)
        removeEventHandler("onClientKey", root, onKey)
        removeEventHandler("onClientClick", root, onClick)

        triggerServerEvent("changeDataSync", localPlayer, "a.HUDshowed", true)
        triggerServerEvent("changeDataSync", localPlayer, "a.TuningProgress", false)
        showChat(true)
        tuningRender = false
        setElementAlpha(triggeredMarker, 30)
        triggerServerEvent("changeDataSync", triggeredMarker, "a.TuningMarkerInUse", false)

        setCameraTarget(localPlayer)

        local vehicle = getPedOccupiedVehicle(localPlayer)
        setElementFrozen(vehicle, false)

        toggleControl("accelerate", true)
        toggleControl("brake_reverse", true)

        if isElement(colorPicker) then
            destroyElement(colorPicker)
        end
    end

    if panelType == 1 then
        if key == "mouse_wheel_up" then
            if scrollingValue > 0  then
                scrollingValue = scrollingValue - 1
                maxSubmenuItemsShowed = maxSubmenuItemsShowed - 1
            end
        elseif key == "mouse_wheel_down" then
            if maxSubmenuItemsShowed < (#subMenuThings[1]) then
                scrollingValue = scrollingValue + 1
                maxSubmenuItemsShowed = maxSubmenuItemsShowed + 1
            end
        end
    elseif panelType == 2 then
        if key == "mouse_wheel_up" then
            if scrollingValue > 0  then
                scrollingValue = scrollingValue - 1
                maxSubmenuItemsShowed = maxSubmenuItemsShowed - 1
            end
        elseif key == "mouse_wheel_down" then
            if maxSubmenuItemsShowed < (#subMenuThings[2]) then
                scrollingValue = scrollingValue + 1
                maxSubmenuItemsShowed = maxSubmenuItemsShowed + 1
            end
        end
    end
end

--** OTHER STUFF

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x + width, y + height, z + tonumber( rotation or 0 ), material, height, color or 0xFFFFFFFF, ... )
end

function testCommand(c)
    if getElementData(localPlayer, "adminLevel") >= 3 then
        local veh = getPedOccupiedVehicle(localPlayer)
        if (veh) then
            local upgradeTable = getVehicleCompatibleUpgrades(veh, 12)
            for index, value in ipairs(upgradeTable) do
                outputChatBox(value, 255, 255, 255, true)
            end
        end
    end
end
addCommandHandler("tuningtest", testCommand)

--[[function setTrayOnMinimize( )
    setTimer(function()
        createTrayNotification( "alphaGames - AFK status: on", "info", true )
        setWindowFlashing(true, 5)
    end, 2000, 1)
end
addEventHandler( "onClientMinimize", getRootElement( ), setTrayOnMinimize )]]--

--** NITRO

function onChange(key, oVal, nVal)
    if key == "a.Nitro" then
        if nVal == true then
            setVehicleNitroLevel(source, 1.0)
        else
            setVehicleNitroLevel(source, 0)
        end
    end
end
addEventHandler("onClientElementDataChange", root, onChange)

function toggleNitro(key, state)
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh and getElementData(veh, "a.Nitro") then
        if state == "up" then
            removeVehicleUpgrade(veh, 1010)
        else
            addVehicleUpgrade(veh, 1010)
        end
    end
end

bindKey("lctrl", "both", toggleNitro)

local renderData = {}
renderData.colorSwitches = {}
renderData.lastColorSwitches = {}
renderData.startColorSwitch = {}
renderData.lastColorConcat = {}

function processColorSwitchEffect(key, color, duration, type)
	if not renderData.colorSwitches[key] then
		if not color[4] then
			color[4] = 255
		end

		renderData.colorSwitches[key] = color
		renderData.lastColorSwitches[key] = color

		renderData.lastColorConcat[key] = table.concat(color)
	end

	duration = duration or 500
	type = type or "Linear"

	if renderData.lastColorConcat[key] ~= table.concat(color) then
		renderData.lastColorConcat[key] = table.concat(color)
		renderData.lastColorSwitches[key] = color
		renderData.startColorSwitch[key] = getTickCount()
	end

	if renderData.startColorSwitch[key] then
		local progress = (getTickCount() - renderData.startColorSwitch[key]) / duration

		local r, g, b = interpolateBetween(
			renderData.colorSwitches[key][1], renderData.colorSwitches[key][2], renderData.colorSwitches[key][3],
			color[1], color[2], color[3],
			progress, type
		)

		local a = interpolateBetween(renderData.colorSwitches[key][4], 0, 0, color[4], 0, 0, progress, type)

		renderData.colorSwitches[key][1] = r
		renderData.colorSwitches[key][2] = g
		renderData.colorSwitches[key][3] = b
		renderData.colorSwitches[key][4] = a

		if progress >= 1 then
			renderData.startColorSwitch[key] = false
		end
	end

	return renderData.colorSwitches[key][1], renderData.colorSwitches[key][2], renderData.colorSwitches[key][3], renderData.colorSwitches[key][4]
end