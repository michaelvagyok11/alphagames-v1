local sX, sY = guiGetScreenSize();

function changeMaintenanceStatus(state)
    if state == "on" then
        addEventHandler("onClientRender", root, onRender)
        changeTick = getTickCount()
    elseif state == "off" then
        removeEventHandler("onClientRender", root, onRender)
    end
end
addEvent("changeMaintenanceStatus", true)
addEventHandler("changeMaintenanceStatus", root, changeMaintenanceStatus)

function onRender()
    if getElementData(localPlayer, "adminLevel") >= 3 and not getPlayerName(localPlayer) == "jacketoffcl" then
        return
    end

    local nowTick = getTickCount();
    local elapsedTime = nowTick - changeTick;
    local duration = elapsedTime / 1500;
    a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

    dxDrawRectangle(0, 0, sX, sY, tocolor(20, 20, 20, a), true)
end