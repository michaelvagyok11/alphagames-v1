local screenX, screenY = guiGetScreenSize()

function reMap(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
    return num * responsiveMultipler
end

function respc(num)
    return math.ceil(num * responsiveMultipler)
end

function getResponsiveMultipler()
    return responsiveMultipler
end

local panelW, panelH = respc(300), respc(60)
local panelX, panelY = (screenX - panelW) / 2, (screenY - panelH) - respc(70)

local interiorTexture = false
local activeInterior = false

local startTick = getTickCount()

RobotoCondensed = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", respc(12))

addEventHandler("onClientResourceStart", getResourceRootElement(),
    function()
        interiorTexture = dxCreateTexture("files/img/exit.png", "argb")
        setTimer(renderInteriors, 5, 0)
    end
)

addEventHandler("onClientColShapeHit", getResourceRootElement(),
    function(hitElement, matchingDimension)
        if localPlayer == hitElement then
            if getElementType(hitElement) == "player" then
                if matchingDimension then
                    if getElementData(source, "interiorEnterCollision") then
                        activeInterior = source
                        startTick = getTickCount()
                        addEventHandler("onClientKey", getRootElement(), enterInteriorHandler)
                        addEventHandler("onClientRender", getRootElement(), renderInteriorsPanel)
                    elseif getElementData(source, "interiorExitCollision") then
                        activeInterior = source
                        startTick = getTickCount()
                        addEventHandler("onClientKey", getRootElement(), exitInteriorHandler)
                        addEventHandler("onClientRender", getRootElement(), renderInteriorsPanel)
                    end
                end
            end
        end
    end
)

addEventHandler("onClientColShapeLeave", getResourceRootElement(),
    function(leaveElement, matchingDimension)
        if not (leaveElement == localPlayer) then
            return
        end

        if getElementType(leaveElement) == "player" then
            if matchingDimension then
                if getElementData(source, "interiorEnterCollision") then
                    activeInterior = false
                    removeEventHandler("onClientKey", getRootElement(), enterInteriorHandler)
                    removeEventHandler("onClientRender", getRootElement(), renderInteriorsPanel)
                elseif getElementData(source, "interiorExitCollision") then
                    activeInterior = false
                    removeEventHandler("onClientKey", getRootElement(), exitInteriorHandler)
                    removeEventHandler("onClientRender", getRootElement(), renderInteriorsPanel)
                end
            end
        end
    end
)

function protectPlayer()
    for k, v in ipairs(getElementsByType("player")) do
        setElementCollidableWith(v, localPlayer, false)
    end

    for k, v in ipairs(getElementsByType("vehicle")) do
        setElementCollidableWith(v, localPlayer, false)
    end

    triggerServerEvent("setPlayerAlpha", localPlayer, 230)

    setTimer(
        function()
            for k, v in ipairs(getElementsByType("player")) do
                setElementCollidableWith(v, localPlayer, true)
            end
        
            for k, v in ipairs(getElementsByType("vehicle")) do
                setElementCollidableWith(v, localPlayer, true)
            end
        
            triggerServerEvent("setPlayerAlpha", localPlayer, 255)
        end,
    2000, 1)
end

function enterInteriorHandler(key, down)
    if down then
        if key == "e" then
            triggerServerEvent("enterInterior", localPlayer, activeInterior)
            protectPlayer()
        end
    end
end

function exitInteriorHandler(key, down)
    if down then
        if key == "e" then
            triggerServerEvent("exitInterior", localPlayer, activeInterior)
            protectPlayer()
        end
    end
end

function renderInteriorsPanel()
    local panelInformation = getElementData(activeInterior, "interiorTable")
    local panelProgress = (getTickCount() - startTick) / 500
    local panelAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, panelProgress, "Linear")

    -- ** Background
    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(65, 65, 65, panelAlpha))
    dxDrawRectangle(panelX + 1, panelY + 1, panelW - 2, panelH - 2, tocolor(35, 35, 35, panelAlpha))
    
    -- ** Title 
    dxDrawText(panelInformation.name, panelX, panelY + respc(10), panelW + panelX, panelH + panelY, tocolor(225, 140, 135, panelAlpha), 1, RobotoCondensed, "center", "top")

    -- ** innerOuterColShape:)
    dxDrawText("Belépéshez/kilépéshez használd az E betűt.", panelX, panelY, panelW + panelX, panelH + panelY - respc(10), tocolor(200, 200, 200, panelAlpha), 1, RobotoCondensed, "center", "bottom")
end

function renderInteriors()
    for k, v in ipairs(getElementsByType("colshape")) do 
        if getElementData(v, "interiorEnterCollision") then
            local collisionPosition = {getElementPosition(v)}
            local x, y, z = getScreenFromWorldPosition(collisionPosition[1], collisionPosition[2], collisionPosition[3])

            if x and y and z then
                radius2 = interpolateBetween(0.3, 0, 0, 0.5, 0, 0, getTickCount()/5000, "SineCurve")
                dxDrawCircle3D(collisionPosition[1], collisionPosition[2], collisionPosition[3] - 0.95, radius2, 52, tocolor(110, 224, 88), 2)
                dxDrawCircle3D(collisionPosition[1], collisionPosition[2], collisionPosition[3] - 0.95, radius2 + 0.1, 52, tocolor(110, 224, 88), 2)
                dxDrawCircle3D(collisionPosition[1], collisionPosition[2], collisionPosition[3] - 0.95, radius2 + 0.2, 52, tocolor(110, 224, 88), 2)
        
                        
                local pX, pY, pZ = getElementPosition(localPlayer)

                if getDistanceBetweenPoints3D(pX, pY, pZ, collisionPosition[1], collisionPosition[2], collisionPosition[3]) < 100 then
                    dxDrawImage3D(collisionPosition[1], collisionPosition[2], collisionPosition[3] - 0.25, 0.3, 0.3, interiorTexture, tocolor(155, 230, 140))
                end
            end
        elseif getElementData(v, "interiorExitCollision") then
            local collisionPosition = {getElementPosition(v)}
            local x, y, z = getScreenFromWorldPosition(collisionPosition[1], collisionPosition[2], collisionPosition[3])

            if x and y and z then
                radius2 = interpolateBetween(0.3, 0, 0, 0.5, 0, 0, getTickCount()/5000, "SineCurve")
                dxDrawCircle3D(collisionPosition[1], collisionPosition[2], collisionPosition[3] - 0.95, radius2, 52, tocolor(235, 70, 70), 2)
                dxDrawCircle3D(collisionPosition[1], collisionPosition[2], collisionPosition[3] - 0.95, radius2 + 0.1, 52, tocolor(235, 70, 70), 2)
                dxDrawCircle3D(collisionPosition[1], collisionPosition[2], collisionPosition[3] - 0.95, radius2 + 0.2, 52, tocolor(235, 70, 70), 2)
        
                        
                local pX, pY, pZ = getElementPosition(localPlayer)
                
                if getDistanceBetweenPoints3D(pX, pY, pZ, collisionPosition[1], collisionPosition[2], collisionPosition[3]) < 100 then
                    dxDrawImage3D(collisionPosition[1], collisionPosition[2], collisionPosition[3] - 0.25, 0.3, 0.3, interiorTexture, tocolor(230, 108, 108))
                end
            end
        end
    end
end

function dxDrawCircle3D( x, y, z, radius, segments, color, width ) 
    segments = segments or 16; 
    color = color or tocolor( 255, 255, 0 ); 
    width = width or 1; 
    local segAngle = 360 / segments; 
    local fX, fY, tX, tY; 
    for i = 1, segments do 
        fX = x + math.cos( math.rad( segAngle * i ) ) * radius; 
        fY = y + math.sin( math.rad( segAngle * i ) ) * radius; 
        tX = x + math.cos( math.rad( segAngle * (i+1) ) ) * radius; 
        tY = y + math.sin( math.rad( segAngle * (i+1) ) ) * radius; 
        dxDrawLine3D( fX, fY, z, tX, tY, z, color, width ); 
    end 
end 

function dxDrawImage3D( x, y, z, width, height, material, color, rotation, ... )
    return dxDrawMaterialLine3D( x, y, z, x, y, z - width, material, height, color or 0xFFFFFFFF, ... )
end

function dxDrawRoundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
    if (x) and (y) and (w) and (h) then
        borderColor = borderColor or tocolor(0, 0, 0, 200)
        bgColor = bgColor or borderColor
    
        --> Background
        dxDrawRectangle(x, y, w, h, bgColor, postGUI);
        
        --> Border
        dxDrawRectangle(x - 1, y + 1, 1, h - 2, borderColor, postGUI)-- left
        dxDrawRectangle(x + w, y + 1, 1, h - 2, borderColor, postGUI)-- right
        dxDrawRectangle(x + 1, y - 1, w - 2, 1, borderColor, postGUI)-- top
        dxDrawRectangle(x + 1, y + h, w - 2, 1, borderColor, postGUI)-- bottom
        dxDrawRectangle(x, y, 1, 1, borderColor, postGUI)
        dxDrawRectangle(x + w - 1, y, 1, 1, borderColor, postGUI)
        dxDrawRectangle(x, y + h - 1, 1, 1, borderColor, postGUI)
        dxDrawRectangle(x + w - 1, y + h - 1, 1, 1, borderColor, postGUI)
    end
end