addEvent("showTeamselectorPanel", true)

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

function getResponsiveMultipler()
	return responsiveMultipler
end

local selectorX, selectorY = respc(300), respc(105)
local poppinsBoldSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(10), false, "cleartype")
local poppinsRegularSmall = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(11), false, "cleartype")

function startRound()
    teamOneCount = 0
    teamTwoCount = 0
end
addEvent("startRound", true)
addEventHandler("startRound", root, startRound)

function showTeamselectorPanel(element)
    if element == localPlayer then
        addEventHandler("onClientRender", root, onRender)
        addEventHandler("onClientClick", root, onClick)
        openTick = getTickCount()
    end
end
addEventHandler("showTeamselectorPanel", root, showTeamselectorPanel)

function onRender()
    local startX, startY = sX / 2 - selectorX / 2, sY / 2 - selectorY / 2
    local nowTick = getTickCount()
    local elapsedTime = nowTick - openTick
    local duration = elapsedTime / 500
    a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

    dxDrawRectangle(startX, startY, selectorX, selectorY, tocolor(65, 65, 65, a))
    dxDrawRectangle(startX + 1, startY + 1, selectorX - 2, selectorY - 2, tocolor(35, 35, 35, a))
    dxDrawRectangle(startX, startY, selectorX, respc(20), tocolor(65, 65, 65, a))
    dxDrawText("#E18C88alpha#c8c8c8Games - Csapatválasztó", startX + 5, startY + (respc(20))/2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldSmall, "left", "center", false, false, false, true)

    if isMouseInPosition(startX + selectorX - 10, startY, respc(5), respc(15)) then
        dxDrawText("X", startX + selectorX - 5, startY + (respc(20))/2, _, _, tocolor(230, 140, 140, a), 1, poppinsBoldSmall, "right", "center", false, false, false, true)
    else
        dxDrawText("X", startX + selectorX - 5, startY + (respc(20))/2, _, _, tocolor(150, 150, 150, a), 1, poppinsBoldSmall, "right", "center", false, false, false, true)
    end

    local count_CT = 0
    for i, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 1 and getElementData(v, "a.DMTeam") == "Terrorists" then
            count_CT = count_CT + 1
        end
    end

    local count_T = 0
    for i, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 1 and getElementData(v, "a.DMTeam") == "Counter-Terrorists" then
            count_T = count_T + 1
        end
    end

    dxDrawRectangle(startX + respc(10), startY + respc(20) + respc(10), selectorX - respc(20), respc(30), tocolor(215/2, 180/2, 115/2, a))
    if isMouseInPosition(startX + respc(10), startY + respc(20) + respc(10), selectorX - respc(20), respc(30)) then
        dxDrawRectangle(startX + respc(10) + 1, startY + respc(20) + respc(10) + 1, selectorX - respc(20) - 2, respc(30) - 2, tocolor(215/2, 180/2, 115/2, a))
        dxDrawImage(startX + respc(10) + respc(6), startY + respc(30) + respc(6), respc(16), respc(16), "files/img/t.png", 0, 0, 0, tocolor(215, 180, 115, a))
    else    
        dxDrawRectangle(startX + respc(10) + 1, startY + respc(20) + respc(10) + 1, selectorX - respc(20) - 2, respc(30) - 2, tocolor(35, 35, 35, a))
        dxDrawImage(startX + respc(10) + respc(6), startY + respc(30) + respc(6), respc(16), respc(16), "files/img/t.png", 0, 0, 0, tocolor(215/2, 180/2, 115/2, a))
    end
    dxDrawText("Terroristák", startX + respc(10) + respc(30), startY + respc(30) + (respc(32) / 2), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldSmall, "left", "center", false, false, false, true)
    dxDrawText(count_CT .. " játékos", startX + selectorX - respc(15), startY + respc(30) + (respc(32) / 2), _, _, tocolor(120, 120, 120, a), 1, poppinsRegularSmall, "right", "center", false, false, false, true)

    dxDrawRectangle(startX + respc(10), startY + respc(30) + respc(30) + respc(5), selectorX - respc(20), respc(30), tocolor(115/2, 170/2, 205/2, a))
    if isMouseInPosition(startX + respc(10), startY + respc(30) + respc(30) + respc(5), selectorX - respc(20), respc(30)) then
        dxDrawRectangle(startX + respc(10) + 1, startY + respc(30) + respc(30) + respc(5) + 1, selectorX - respc(20) - 2, respc(30) - 2, tocolor(115/2, 170/2, 205/2, a))
        dxDrawImage(startX + respc(10) + respc(6), startY + respc(65) + respc(6), respc(16), respc(16), "files/img/ct.png", 0, 0, 0, tocolor(115, 170, 205, a))
    else
        dxDrawRectangle(startX + respc(10) + 1, startY + respc(30) + respc(30) + respc(5) + 1, selectorX - respc(20) - 2, respc(30) - 2, tocolor(35, 35, 35, a))
        dxDrawImage(startX + respc(10) + respc(6), startY + respc(65) + respc(6), respc(16), respc(16), "files/img/ct.png", 0, 0, 0, tocolor(115/2, 170/2, 205/2, a))
    end
    dxDrawText("Terrorelhárítók", startX + respc(10) + respc(30), startY + respc(65) + (respc(32) / 2), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldSmall, "left", "center", false, false, false, true)
    dxDrawText(count_T .. " játékos", startX + selectorX - respc(15), startY + respc(65) + (respc(32) / 2), _, _, tocolor(120, 120, 120, a), 1, poppinsRegularSmall, "right", "center", false, false, false, true)
end

function onClick(button, state)
    if button == "left" and state == "down" then
        local startX, startY = sX / 2 - selectorX / 2, sY / 2 - selectorY / 2
        if isMouseInPosition(startX + respc(10), startY + respc(20) + respc(10), selectorX - respc(20), respc(30)) then
            triggerServerEvent("attemptToJoinTeam", localPlayer, localPlayer, 1)
        end

        if isMouseInPosition(startX + respc(10), startY + respc(30) + respc(30) + respc(5), selectorX - respc(20), respc(30)) then
            triggerServerEvent("attemptToJoinTeam", localPlayer, localPlayer, 2)
        end

        if isMouseInPosition(startX + selectorX - 10, startY, respc(15), respc(15)) then
            setElementData(localPlayer, "a.Gamemode", nil)
            setElementDimension(localPlayer, 0)
            setElementPosition(localPlayer, 260.6982421875, 1816.28125, 4.7031307220459)
            setElementModel(localPlayer, getElementData(e, "a.Skin"))
            setElementData(localPlayer, "isInLobby", true)
            removeEventHandler("onClientRender", root, onRender)
            removeEventHandler("onClientClick", root, onClick)
        end
    end
end

function joinResponse(element, response)
    if element and isElement(element) and response and element == localPlayer then
        if response == "return" then
            exports.aInfobox:makeNotification(2, "Nem tudsz csatlakozni ebbe a csapatba az arányok miatt.")
        elseif response == "success" then
            exports.aInfobox:makeNotification(1, "Sikeresen csatlakoztál a kiválasztott csapathoz.")
            exports.a_loader:createLoadingScreen(5, "Deathmatch", 0, 0)
            addEventHandler("onClientRender", root, renderScore)
            removeEventHandler("onClientRender", root, onRender)
            removeEventHandler("onClientClick", root, onClick)
        end
    end
end
addEvent("joinResponse", true)
addEventHandler("joinResponse", root, joinResponse)

local poppinsBold = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(12), false, "cleartype")
local poppinsBold2 = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(16), false, "cleartype")
local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(25), false, "cleartype")

function removeCounterFromScreen(element)
    if element == localPlayer then
        removeEventHandler("onClientRender", root, renderScore)
    end
end
addEvent("removeCounterFromScreen", true)
addEventHandler("removeCounterFromScreen", root, removeCounterFromScreen)

function renderScore()
    local startX, startY = sX / 2, respc(25)

    dxDrawText(secondsToTime(seconds), startX + 1, startY + respc(25) + 1, _, _, tocolor(2, 2, 2, 200), 1, poppinsBold2, "center", "center")
    dxDrawText(secondsToTime(seconds), startX, startY + respc(25), _, _, tocolor(200, 200, 200, 200), 1, poppinsBold2, "center", "center")

    dxDrawImage(startX - respc(35) - respc(100), startY, respc(100), respc(50), "files/img/header.png", 180, 0, 0, tocolor(215/2, 180/2, 115/2, 150))
    dxDrawText("Terroristák", startX - respc(44), startY - respc(14), _, _, tocolor(2, 2, 2, 200), 1, poppinsBold, "right", "top", false, false, false, true)
    dxDrawText("Terroristák", startX - respc(45), startY - respc(15), _, _, tocolor(200, 200, 200, 200), 1, poppinsBold, "right", "top", false, false, false, true)
    dxDrawText(teamOneCount, startX - respc(55), startY + respc(25), _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldBig, "right", "center", false, false, false, true)

    dxDrawImage(startX + respc(35), startY, respc(100), respc(50), "files/img/header.png", 0, 0, 0, tocolor(115/2, 170/2, 205/2, 150))
    dxDrawText("Terrorelhárítók", startX + respc(46), startY - respc(14), _, _, tocolor(2, 2, 2, 200), 1, poppinsBold, "left", "top", false, false, false, true)
    dxDrawText("Terrorelhárítók", startX + respc(45), startY - respc(15), _, _, tocolor(200, 200, 200, 200), 1, poppinsBold, "left", "top", false, false, false, true)
    dxDrawText(teamTwoCount, startX + respc(55), startY + respc(25), _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldBig, "left", "center", false, false, false, true)
end

function givePointToTeam(team)
    if team == 1 then
        teamOneCount = teamOneCount + 1
    elseif team == 2 then
        teamTwoCount = teamTwoCount + 1
    end
end
addEvent("givePointToTeam", true)
addEventHandler("givePointToTeam", root, givePointToTeam)

function sendSeconds(sec)
    seconds = sec
end
addEvent("sendSeconds", true)
addEventHandler("sendSeconds", root, sendSeconds)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function secondsToTime(seconds)
	local seconds = tonumber(seconds)
    if not tonumber(seconds) then return "00:00" end
  	if seconds <= 0 then
		return "00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return mins..":"..secs
    end
end