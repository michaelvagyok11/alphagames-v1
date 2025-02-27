local sX, sY = guiGetScreenSize();
local robotoBold = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 15)
local delayTimer = {}


function onChange(key, oVal, nVal)
    if key == "a.Gamemode" then
        if nVal == nil or nVal == 2 or nVal == 3 or nVal == 4 then
            if source == localPlayer then
                createLoadingScreen(5, tostring(exports.a_lobby:getGamemodeNameById(getElementData(getLocalPlayer(), "a.Gamemode"))))
            end
        end
    end
end
addEventHandler("onClientElementDataChange", getRootElement(), onChange)

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)

function createLoadingScreen(time, whereTo, arg, iftrue)
    if time and whereTo then
        argument = arg
        iftruearg = iftrue
        if not (argument == iftruearg) then
            return
        end
        addEventHandler("onClientRender", getRootElement(), onLoaderRender2)
        duration = tonumber(time)
        createTick = getTickCount();
        setElementAlpha(localPlayer, 0)
        setElementFrozen(localPlayer, true)
        showChat(false)
        triggerServerEvent("changeDataSync", localPlayer, "a.Hudshowed", false)
        destination = tostring(whereTo)

        --waitingSound = playSound("files/sound/music.mp3", true)
        --setSoundVolume(waitingSound, 0.5)
        delayTimer[localPlayer] = setTimer(function()
            if not (argument == iftruearg) then
                return
            end
            removeEventHandler("onClientRender", getRootElement(), onLoaderRender2)
            
            setElementAlpha(localPlayer, 255)
            setElementFrozen(localPlayer, false)
            showChat(true)
            triggerServerEvent("changeDataSync", localPlayer, "a.Hudshowed", true)
            setElementInterior(localPlayer, 0)

            if isTimer(tipTimer) then
                killTimer(tipTimer)
            end
        end, tonumber(duration*1000), 1)

        local tipTable = exports.a_extras:getTipTable();
        currentTip = tostring(tipTable[math.random(1, #tipTable)][1])
        tipTimer = setTimer(function()
            currentTip = tostring(tipTable[math.random(1, #tipTable)][1])
            changeTick = getTickCount();
        end, 5000, 0)
    end
end

function onLoaderRender2()
    local nowTick = getTickCount();
    local elapsedTime = nowTick - createTick;
    local dur = elapsedTime / (duration*1000);
    progress = interpolateBetween(0, 0, 0, 100, 0, 0, dur, "Linear")
    a = 255
    
    dxDrawRectangle(0, 0, sX, sY, tocolor(30, 30, 30, a))

	dxDrawCircle(sX / 2, sY / 2, 100, -90, 360, tocolor(65, 65, 65, a), tocolor(35, 35, 35, 200), 1024)
	dxDrawCircle(sX / 2, sY / 2, 100, -90, -90 + 360/100*progress, tocolor(155, 230, 140, a), tocolor(155/2, 230/2, 140/2), 1024)
	dxDrawCircle(sX / 2, sY / 2, 99, -90, 360, tocolor(35, 35, 35, 255), tocolor(2, 2, 2, 255), 1024)

    dxDrawText("Betöltés ide: #9BE48F" .. destination, sX / 2, sY / 2, _, _, tocolor(200, 200, 200, a), 1, robotoBold, "center", "center", false, false, false, true)
    dxDrawText(tonumber(math.floor(progress)) .. "%", sX / 2, sY / 2 + 20, _, _, tocolor(150, 150, 150, a), 1, robotoBold, "center", "center", false, false, false, true)

    a2 = interpolateBetween(0, 0, 0, 255, 0, 0, elapsedTime/5000, "SineCurve")
    local width = dxGetTextWidth(currentTip, 1, robotoBold, true)
    exports.a_core:dxDrawRoundedRectangle(sX / 2 - width / 2 - 15, sY - 55, width + 30, 50, tocolor(25, 25, 25, a2), 15)
    dxDrawText(currentTip, sX / 2, sY - 30, _, _, tocolor(200, 200, 200, a2), 1, robotoBold, "center", "center", false, false, false, true);

end