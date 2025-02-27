local leaveTimer = {}
local lobbyPed = {}

function onResStart(startedRes)
	--if startedRes == getThisResource() then
		lobbyColShape = createColSphere(lobbyColPositions[1], lobbyColPositions[2], lobbyColPositions[3], lobbyColPositions[4])
        gmSelectorColShape = createColCuboid(gmSelectorPoint[1] - 2, gmSelectorPoint[2] - 2, gmSelectorPoint[3] - 1, 2, 2, 3)
        setElementData(gmSelectorColShape, "a.GMselector", true)
        setElementData(lobbyColShape, "a.Lobbycol", true)

        --[[for k, v in ipairs(lobbyPeds) do
            lobbyPed[k] = createPed(v[1], v[3], v[4], v[5], v[6])
            setElementData(lobbyPed[k], "a.Pedname", v[2])
            setElementFrozen(lobbyPed[k], true)
        end]]--
    
	--end
end
addEventHandler("onResourceStart", resourceRoot, onResStart)

function onColHit(element, dim)
    if source == lobbyColShape then
        if not (getElementData(element, "a.Gamemode") == false) then
            return
        end
        toggleControl(element, "fire", false)
        toggleControl(element, "action", false)
        setElementData(element, "a.isPlayerInLobbyColShape", true)
    end
end
addEventHandler("onColShapeHit", root, onColHit)

function onColLeave(element, dim)
    if source == lobbyColShape then
        if getElementData(element, "a.Gamemode") == false then
            if getElementData(element, "a.Maintenance") then
                return
            end
        else
            toggleControl(element, "fire", false)
            toggleControl(element, "action", false)
            setElementData(element, "a.isPlayerInLobbyColShape", false)
        end
    end
end
addEventHandler("onColShapeLeave", root, onColLeave)

function getBackToLobby(e, cmd)
    if isPedInVehicle(e) then
        removePedFromVehicle(e)
        --destroyElement(getPedOccupiedVehicle(e))
    end

    outputChatBox("#9BE48Falphav2 ► Siker: #FFFFFFVisszatértél a lobbyba.", e, 255, 255, 255, true)
    setElementData(e, "a.Gamemode", false)
    setElementData(e, "a.inSession", false)
    -- setElementData(element, "a.isPlayerInLobbyColShape", true)
    setElementDimension(e, 0)
    setElementPosition(e, 2103.662109375, -103.2578125, 2.2428879737854)
    setElementModel(e, getElementData(e, "a.Skin"))

    setElementData(e, "a.Current<DM>Session", false)
end
addCommandHandler("lobby", getBackToLobby)

local pedPositions = {
    {51, 1459.2890625, -1148.0693359375, 24.367082595825, 160, "dzseki"},
    {44, 1457.998046875, -1147.9287109375, 24.363229751587, 260, "toni"},
    {122, 1458.826171875, -1147.484375, 24.368915557861, 155, "dzsordzs"},
    {213, 2282.857421875, 20.736328125, 26.484375, 180, "boti"},
    {200, 2259.9892578125, 31.1875, 26.40930557251, 290, "zolko"},
}
local peds = {}

local anims = {
    {"GANGS", "prtial_gngtlkB"},
    {"GANGS", "prtial_gngtlkC"},
    {"GANGS", "prtial_gngtlkA"},
    {"bd_fire", "wash_up"},
    {"camera", "camcrch_idleloop"},
}

function createPeds()
    for k, v in ipairs(pedPositions) do
        peds[k] = createPed(v[1], v[2], v[3], v[4], v[5])
        setElementDimension(peds[k], 0)
        setPedAnimation(peds[k], anims[k][1], anims[k][2], true, false, false)
        setElementData(peds[k], "a.Pedname", v[6])
        setElementFrozen(peds[k], true)
    end
end

setTimer(function()
    createPeds();
end, 500, 1)

setTimer(function()
    for k, v in ipairs(peds) do
        setPedAnimation(v, anims[k][1], anims[k][2], true, false, false)
        setElementFrozen(v, true)
    end
end, 1000*30, 0)