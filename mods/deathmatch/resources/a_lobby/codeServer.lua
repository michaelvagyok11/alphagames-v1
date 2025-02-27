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
        if not (getElementData(element, "a.Gamemode") == nil) then
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
        if getElementData(element, "a.Gamemode") == nil then
            if getElementData(element, "a.Maintenance") then
                return
            end
            setElementPosition(element, 260.6982421875, 1816.28125, 4.7031307220459)
            setElementAlpha(element, 100)
            outputChatBox("#E48F8F► Hiba: #FFFFFFNem hagyhatod el a lobby területét amíg nem választottál játékmódot.", element, 255, 255, 255, true)
            --outputChatBox("#E48F8F[Lobby]: #8FC3E4Ideiglenesen kikapcsolva a visszateleportálás.", element, 255, 255, 255, true)
            setElementRotation(element, 0, 0, 300)

            leaveTimer[element] = setTimer(function() 
                setElementAlpha(element, 255)
            end, 5000, 1)
        else
            toggleControl(element, "fire", true)
            toggleControl(element, "action", true)
            setElementData(element, "a.isPlayerInLobbyColShape", false)
        end
    end
end
addEventHandler("onColShapeLeave", root, onColLeave)

function getBackToLobby(e, cmd)
    if getElementData(e, "loggedIn") == true then
        if isPedInVehicle(e) then
            removePlayerFromVehicle(e)
        end

        outputChatBox("#5AB1D9► Info: #FFFFFFSikeresen visszatértél a lobbyba.", e, 255, 255, 255, true)
        setElementData(e, "a.Gamemode", nil)
        setElementDimension(e, 0)
        setElementInterior(e, 0)
        setElementPosition(e, 260.6982421875, 1816.28125, 4.7031307220459)
        setElementModel(e, getElementData(e, "a.Skin"))
        setElementData(e, "isInLobby", true)
        toggleControl(e, "fire", false)
        toggleControl(e, "action", false)
    end
end
addCommandHandler("lobby", getBackToLobby)

function togAction()
    if getElementData(sourcePlayer, "isInLobby") == false then
        toggleControl(sourcePlayer, "fire", true)
        toggleControl(sourcePlayer, "action", true)
    else
        toggleControl(sourcePlayer, "fire", false)
        toggleControl(sourcePlayer, "action", false)
    end
end

local pedPositions = {
    {114, 239.814453125, 1808.75390625, 4.7109375, -90, "michael", 0},
    {24, 239.814453125, 1807.6, 4.7109375, -90, "boti", 0},
    {7, 261.2041015625, 1826.646484375, 4.7109375, 150, "crudo", 31},
    {86, 262.3857421875, 1825.74609375, 4.7109375, 150, "bazsi", 32},
    {301, 240.119140625, 1828.1533203125, 4.7109375, 195, "kfc kosar", 0},
    {300, 240.3505859375, 1826.9228515625, 4.7109375, 15, "Nxmrod", 31},
    {7, 246.5966796875, 1822.658203125, 4.7109375, 180, "Ruhaboltos", 0},
    {291, 241.1435546875, 1809.00390625, 4.7109375, 291, "pontJack", 0},
    {105, 217.806640625, 1822.8115234375, 6.4140625, 265, "crimeter", 0},
    {115, 254.08984375, 1808.6796875, 5.209228515625, 41, "misi 2", 0},
    {230, 252.9521484375, 1809.630859375, 5.209228515625, 225, "crudo 2", 0},
    {291, 248.81034851074, 1821.4459228516, 5.7103633880615, 271, "Gyuris Bence", 0},
}
local peds = {}

local anims = {
    {"misc", "seat_talk_01"},
    {"misc", "seat_talk_01"},
    {"camera", "camcrch_idleloop"},
    {"camera", "camcrch_idleloop"},
    {"SHOP", "SHP_Rob_React"},
    {"SHOP", "SHP_Gun_Aim"},
    {"COP_AMBIENT", "Coplook_think"},
    {"GANGS", "smkcig_prtl"},
    {"COP_AMBIENT", "Coplook_think"},
    {"gymnasium", "gymshadowbox"},
    {"gymnasium", "gymshadowbox"},
    {"crib", "ped_console_loop"},
    {"COP_AMBIENT", "Coplook_think"},
    {"COP_AMBIENT", "Coplook_think"},
    {"COP_AMBIENT", "Coplook_think"},
    {"COP_AMBIENT", "Coplook_think"},
}

function createPeds()
    for k, v in ipairs(pedPositions) do
        peds[k] = createPed(v[1], v[2], v[3], v[4], v[5])
        setElementDimension(peds[k], 0)
        setPedAnimation(peds[k], anims[k][1], anims[k][2], true, false, false)
        setElementData(peds[k], "a.Pedname", v[6])
        setElementData(peds[k], "currentWeaponPaintjob", {weaponSkins[32], 31})
        setElementFrozen(peds[k], true)
        giveWeapon(peds[k], v[7], 1, true)
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