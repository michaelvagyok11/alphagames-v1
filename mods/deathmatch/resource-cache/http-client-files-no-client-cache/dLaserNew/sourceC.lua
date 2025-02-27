local lecer = false
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        setElementData(localPlayer, "enabledLaser", true)
        lecer = dxCreateTexture("lecer.dds")
        local txd = engineLoadTXD("laser-attachment.txd")
        if txd then
            engineImportTXD(txd, 7613)
            local dff = engineLoadDFF("laser-attachment.dff")
            if dff then
                engineReplaceModel(dff, 7613)
            end
        end
    end
)

local laserPositions = {
    [29] = {0.35, -0.015, 0.12, 5, -13, -8},
    [31] = {0.57, -0.02, 0.05, 5, 0, 0},
    [32] = {0.32, -0.03, 0.12, -90, 0, 0},
    [34] = {0.26, 0.02, 0.26, 180, 0, 0},
    [33] = {0.8, -0.06, 0.15, -5, -5, -6},
    [30] = {0.62, -0.03, 0.095, 0, 0, -8},
    [23] = {0.32, 0.04, 0.1, 0, -10, 5},
    [24] = {0.27, 0.01, 0.04, 0, -3, 0},
    [25] = {0.8, -0.058, 0.135, 0, -10, -5},
    [26] = {0.45, 0.012, 0.075, 0, -10, 0},
    [27] = {0.62, -0.03, 0.125, 0, -10, 0},
    [28] = {0.2, 0.005, 0.165, 180, 7, 0},
}

local laserAttachments = {}
addEvent("createLaserAttachment", true)
addEventHandler("createLaserAttachment", resourceRoot,
    function(client)
        laserAttachments[client] = createObject(7613, 0, 0, 0)
        setElementCollisionsEnabled(laserAttachments[client], false)
        exports.dAttach:attach(laserAttachments[client], client, 24, unpack(laserPositions[getPedWeapon(client)]))
    end
)

function destroyLaserAttachment(player)
    if isElement(laserAttachments[player]) then
        exports.dAttach:detach(laserAttachments[player])
        setElementCollisionsEnabled(laserAttachments[player], false)
        destroyElement(laserAttachments[player])
    end
    laserAttachments[player] = nil
end
addEvent("destroyLaserAttachment", true)
addEventHandler("destroyLaserAttachment", resourceRoot, destroyLaserAttachment)

addEventHandler("onClientPlayerWeaponSwitch", localPlayer,
    function(_, newWeaponSlot)
        if newWeaponSlot == 0 and laserAttachments[source] then
            destroyLaserAttachment(localPlayer)
            triggerServerEvent("destroyLaserAttachment", resourceRoot)
        end
    end
)


addEventHandler("onClientPreRender", getRootElement(),
    function()
        for k, v in pairs(laserAttachments) do
            if getElementData(k, "enabledLaser") then
                local muzzleX, muzzleY, muzzleZ = getElementPosition(v)
                local targetX, targetY, targetZ = getPedTargetEnd(k)
                if not getPedControlState(k, "aim_weapon") then
                    targetX, targetY, targetZ = getPositionFromElementOffset(v, 30, 0, 0)
                end
                local hit, processX, processY, processZ = processLineOfSight(muzzleX, muzzleY, muzzleZ, targetX, targetY, targetZ)
                if hit then
                    targetX, targetY, targetZ = processX, processY, processZ
                end
                dxDrawMaterialSectionLine3D(
                    muzzleX, muzzleY, muzzleZ, targetX, targetY, targetZ,
                    22 * (getElementData(k, "laserMode") or 0), 0, 22, 1, false, lecer, 0.04
                )
            end
        end
    end
)

function getPositionFromElementOffset(element, x, y, z)
    if element then
        m = getElementMatrix(element)
        return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1], x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2], x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
    end
end

addEventHandler("onClientKey", getRootElement(),
    function(key, press)
        if press and isElement(laserAttachments[localPlayer]) then
            if key == "l" then
                setElementData(localPlayer, "enabledLaser", not getElementData(localPlayer, "enabledLaser"))
            end
        end 
    end
)