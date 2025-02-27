function onStart()
    weaponTexture = dxCreateTexture("files/img/weapon.png", "argb")
    exitTexture = dxCreateTexture("files/img/exit.png", "argb")
end
addEventHandler("onClientResourceStart", root, onStart)

function renderMarker()
    local x, y, z = getScreenFromWorldPosition(colshapePosition[1], colshapePosition[2], colshapePosition[3])
    if x and y and z then
        radius = interpolateBetween(0.8, 0, 0, 1, 0, 0, getTickCount()/5000, "SineCurve")
        dxDrawCircle3D(colshapePosition[1], colshapePosition[2], colshapePosition[3] - 1, radius, 52, tocolor(100, 150, 210, 200), 2)
        dxDrawCircle3D(colshapePosition[1], colshapePosition[2], colshapePosition[3] - 1, radius + 0.1, 52, tocolor(100, 150, 210, 200), 2)
        dxDrawCircle3D(colshapePosition[1], colshapePosition[2], colshapePosition[3] - 1, radius + 0.2, 52, tocolor(100, 150, 210, 200), 2)
        
        local pX, pY, pZ = getElementPosition(localPlayer)
        if getDistanceBetweenPoints3D(pX, pY, pZ, colshapePosition[1], colshapePosition[2], colshapePosition[3]) < 30 then
            dxDrawImage3D(colshapePosition[1], colshapePosition[2], colshapePosition[3], 0.5, 0.5, weaponTexture, tocolor(100, 150, 210))
        end
    end

    local x, y, z = getScreenFromWorldPosition(exitPosition[1], exitPosition[2], exitPosition[3])
    if x and y and z then
        radius2 = interpolateBetween(0.3, 0, 0, 0.5, 0, 0, getTickCount()/5000, "SineCurve")
        dxDrawCircle3D(exitPosition[1], exitPosition[2], exitPosition[3] - 0.95, radius2, 52, tocolor(140, 50, 50), 2)
        dxDrawCircle3D(exitPosition[1], exitPosition[2], exitPosition[3] - 0.95, radius2 + 0.1, 52, tocolor(140, 50, 50), 2)
        dxDrawCircle3D(exitPosition[1], exitPosition[2], exitPosition[3] - 0.95, radius2 + 0.2, 52, tocolor(140, 50, 50), 2)

                
        local pX, pY, pZ = getElementPosition(localPlayer)
        if getDistanceBetweenPoints3D(pX, pY, pZ, exitPosition[1], exitPosition[2], exitPosition[3]) < 5 then
            dxDrawImage3D(exitPosition[1], exitPosition[2], exitPosition[3] - 0.25, 0.3, 0.3, exitTexture, tocolor(255, 100, 100))
        end
    end
end
setTimer(renderMarker, 5, 0)

--[[function onShoot(wep, ammo, clip, x, y, z, hitElement)
    if isElement(hitElement) and getElementType(hitElement) == "object" and getElementModel(hitElement) == 1583 or getElementModel(hitElement) == 1584 or getElementModel(hitElement) == 1585 or getElementModel(hitElement) == 1586 then
        createEffect("shootlight", x, y, z)
        triggerServerEvent("destroyObject", source, source, hitElement)
    end
end
addEventHandler("onClientPlayerWeaponFire", root, onShoot)]]

function onHit(element, dim)
    if not dim or not isElement(element) or not (element == localPlayer) then 
        return
    end
    if getElementData(source, "a.ShootingRangeCol") then
        if isTimer(spamTimer) then
            return
        end
        triggerServerEvent("changePosition", element, element, "entry")
        exports.d_loader:createLoadingScreen(5, "Shooting range")
        spamTimer = setTimer(function() end, 1500, 1)
    elseif getElementData(source, "a.ShootingRangeExit") then
        if isTimer(spamTimer) then
            return
        end
        exports.d_loader:createLoadingScreen(3, "Lobby")
        triggerServerEvent("changePosition", element, element, "exit")
    end
end
addEventHandler("onClientColShapeHit", root, onHit)