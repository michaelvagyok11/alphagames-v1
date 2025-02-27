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

local selectorX, selectorY = respc(500), respc(145)
local barlowBoldSmall = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(13), false, "cleartype")
local barlowRegularSmall = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(13), false, "cleartype")
local barlowRegularSmall2 = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(11), false, "cleartype")
local robotoBoldSmall2 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(7), false, "cleartype")

function startRound()
    teamOneCount = 0
    teamTwoCount = 0
end
addEvent("startRound", true)
addEventHandler("startRound", root, startRound)

function showTeamselectorPanel(element)
    if element == localPlayer then
        triggerServerEvent("a_RequestSessions", element, element)
    end
end
addEventHandler("showTeamselectorPanel", root, showTeamselectorPanel)

function a_SendRequestedSessions(receiverElement, tableOfSessions)
    createdSessions = {}
    if receiverElement and tableOfSessions and receiverElement == localPlayer then
        createdSessions = tableOfSessions
        
        addEventHandler("onClientRender", root, onRender)
        addEventHandler("onClientClick", root, onClick)
        addEventHandler("onClientKey", root, onKey)
        maxSessionsShowed = 8
        scrollingValue = 0
        currentSelectedSession = false

        openTick = getTickCount()

        showChat(false)
        setElementData(localPlayer, "a.HUDshowed", false)

        sessionX, sessionY = respc(700), respc(400)
        sStartX, sStartY = sX / 2 - sessionX / 2, sY / 2 - sessionY / 2
        playSound("files/sounds/open.wav")

        selectedSession = false
    else
        print("error #1")
        --error("#1")
    end
end
addEvent("a_SendRequestedSessions", true)
addEventHandler("a_SendRequestedSessions", root, a_SendRequestedSessions)

function syncSessionTable(table)
    if createdSessions then
        createdSessions = table
    else
        createdSessions = {}
        createdSessions = table
    end
end
addEvent("syncSessionTable", true)
addEventHandler("syncSessionTable", root, syncSessionTable)

function onRender()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - openTick
    local duration = elapsedTime / 500
    a, sStartY = interpolateBetween(0, sY / 2 - sessionY / 2 + respc(30), 0, 255, sY / 2 - sessionY / 2, 0, duration, "Linear")

    if not selectedSession then
        if getKeyState("esc") or getKeyState("backspace") then
            if getElementData(localPlayer, "a.inSession") == true then
                --setElementDimension(localPlayer, 0)
                setElementPosition(localPlayer, 2103.662109375, -103.2578125, 2.2428879737854)

                playSound("files/sounds/open.wav")

                setElementData(localPlayer, "a.inSession", false)
                setElementData(localPlayer, "a.Current<DM>Session", false)

                --setElementFrozen(localPlayer, false)
                toggleAllControls(true)
                removeEventHandler("onClientRender", root, onRender)
                removeEventHandler("onClientClick", root, onClick)
                removeEventHandler("onClientKey", root, onKey)
                showChat(true)
                setElementData(localPlayer, "a.HUDshowed", true)
                setElementData(localPlayer, "a.Gamemode", false)
                return
            else
                playSound("files/sounds/open.wav")

                --setElementFrozen(localPlayer, false)
                toggleAllControls(true)
                removeEventHandler("onClientRender", root, onRender)
                removeEventHandler("onClientClick", root, onClick)
                removeEventHandler("onClientKey", root, onKey)
                showChat(true)
                setElementData(localPlayer, "a.HUDshowed", true)
                setElementData(localPlayer, "a.Gamemode", false)
                return
            end
        end

        dxDrawRectangle(0, 0, sX, sY, tocolor(20, 20, 20, 150))
        dxDrawFadeRectangle(sStartX, sStartY, sessionX, sessionY, {20, 20, 20, a})
        dxDrawRectangle(sStartX, sStartY, sessionX, sessionY, tocolor(35, 35, 35, a))

        dxDrawText("alpha", sStartX, sStartY - respc(15), _, _, tocolor(200, 200, 200, a), 1, barlowBoldSmall, "left", "center")
        dxDrawText("SESSIONS-DM", sStartX + dxGetTextWidth("alpha", 1, barlowBoldSmall) + respc(1), sStartY - respc(15), _, _, tocolor(200, 200, 200, a), 1, barlowRegularSmall, "left", "center")

        dxDrawText("ID", sStartX + respc(20), sStartY + respc(25)/2, _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "left", "center")
        dxDrawText("FANTÁZIANÉV", sStartX + respc(75), sStartY + respc(25)/2, _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "left", "center")
        dxDrawText("JUTALOM", sStartX + respc(225), sStartY + respc(25)/2, _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "left", "center")
        dxDrawText("HOSSZ", sStartX + respc(320), sStartY + respc(25)/2, _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "left", "center")
        dxDrawText("PÁLYA", sStartX + respc(420), sStartY + respc(25)/2, _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "left", "center")
        dxDrawText("TELÍTETTSÉG", sStartX + respc(610), sStartY + respc(25)/2, _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "left", "center")

        for index, map in ipairs(createdSessions) do
            if (index <= maxSessionsShowed) and (index > scrollingValue) then
                local index = index - scrollingValue
                if isMouseInPosition(sStartX + respc(5), sStartY + respc(25) + (index - 1) * respc(37.5), sessionX - respc(14), respc(35)) or currentSelectedSession == index + scrollingValue then
                    dxDrawRectangle(sStartX + respc(5), sStartY + respc(25) + (index - 1) * respc(37.5), sessionX - respc(14), respc(35), tocolor(45, 45, 45, a))
                else
                    dxDrawRectangle(sStartX + respc(5), sStartY + respc(25) + (index - 1) * respc(37.5), sessionX - respc(14), respc(35), tocolor(25, 25, 25, a))
                end

                local lineWidth = (sessionX - respc(14)) / 600 * map[2]
                dxDrawRectangle(sStartX + respc(5), sStartY + respc(25) + (index - 1) * respc(37.5) + respc(33), lineWidth, respc(1), tocolor(100, 100, 100, 75))

                dxDrawText("#" .. index + scrollingValue, sStartX + respc(20), sStartY + respc(25) + (index - 1) * respc(37.5) + respc(35)/2, _, _, tocolor(150, 150, 150,  a), 0.75, barlowRegularSmall, "left", "center")
                dxDrawText(teamNames[map[3]], sStartX + respc(75), sStartY + respc(25) + (index - 1) * respc(37.5) + respc(35)/2, _, _, tocolor(200, 200, 200,  a), 0.85, barlowRegularSmall, "left", "center")

                local currentMapMoney = map[5]
                if currentMapMoney <= 1250 then
                    currentMapMoney = "#EE8F8F".. currentMapMoney
                elseif currentMapMoney > 1250 and currentMapMoney <= 1500 then
                    currentMapMoney = "#E4BB8E".. currentMapMoney
                elseif currentMapMoney > 1500 and currentMapMoney <= 1750 then
                    currentMapMoney = "#D7E48E".. currentMapMoney
                else
                    currentMapMoney = "#B9E48E".. currentMapMoney            
                end
                dxDrawText(currentMapMoney .. "$", sStartX + respc(225), sStartY + respc(25) + (index - 1) * respc(37.5) + respc(35)/2, _, _, tocolor(200, 200, 200,  a), 0.85, barlowRegularSmall, "left", "center", false, false, false, true)

                local currentMapSeconds = map[2]
                if currentMapSeconds <= 180 then
                    currentMapSeconds = "#EE8F8F".. secondsToTime2(currentMapSeconds)
                elseif currentMapSeconds > 180 and currentMapSeconds <= 360 then
                    currentMapSeconds = "#E4BB8E".. secondsToTime2(currentMapSeconds)
                else
                    currentMapSeconds = "#B9E48E".. secondsToTime2(currentMapSeconds)       
                end

                local playerCount = map[4]

                -- iprint(playerCount)

                dxDrawText(currentMapSeconds .. "", sStartX + respc(320), sStartY + respc(25) + (index - 1) * respc(37.5) + respc(35)/2, _, _, tocolor(150, 150, 150,  a), 0.75, barlowRegularSmall, "left", "center", false, false, false, true)
                dxDrawText(mapCache[map[1]]["mapName"], sStartX + respc(420), sStartY + respc(25) + (index - 1) * respc(37.5) + respc(35)/2, _, _, tocolor(150, 150, 150,  a), 0.75, barlowRegularSmall, "left", "center")
                dxDrawText(playerCount .. "/10", sStartX + respc(640), sStartY + respc(25) + (index - 1) * respc(37.5) + respc(35)/2, _, _, tocolor(150, 150, 150,  a), 0.75, barlowRegularSmall, "left", "center")
                --dxDrawText("-", sStartX + respc(640), sStartY + respc(25) + (index - 1) * respc(37.5) + respc(35)/2, _, _, tocolor(150, 150, 150,  a), 0.75, barlowRegularSmall, "left", "center")
            end
        end

        -- ** ALSÓ CSATLAKOZÁS GOMB
        if not currentSelectedSession then
            dxDrawText("Válassz ki egy sessiont, ahova csatlakozni szeretnél.", sStartX + sessionX / 2, sStartY + sessionY - respc(40), _, _, tocolor(120, 120, 120, a), 1, barlowRegularSmall, "center", "center")
            dxDrawText("Kilépéshez használd a(z) <BACKSPACE> gombot.", sStartX + sessionX / 2, sStartY + sessionY - respc(17.5), _, _, tocolor(100, 100, 100, a), 0.65, barlowRegularSmall, "center", "center")
        else
            if isMouseInPosition(sStartX + sessionX / 2 - respc(150), sStartY + sessionY - respc(60), respc(300), respc(50)) then
                dxDrawRectangle(sStartX + sessionX / 2 - respc(150), sStartY + sessionY - respc(60), respc(300), respc(50), tocolor(50, 50, 50, a))
                dxDrawText("CSATLAKOZÁS", sStartX + sessionX / 2, sStartY + sessionY - respc(60) + respc(25), _, _, tocolor(200, 200, 200, a), 1, barlowBoldSmall, "center", "center")
            else
                dxDrawRectangle(sStartX + sessionX / 2 - respc(150), sStartY + sessionY - respc(60), respc(300), respc(50), tocolor(40, 40, 40, a))
                dxDrawText("CSATLAKOZÁS", sStartX + sessionX / 2, sStartY + sessionY - respc(60) + respc(25), _, _, tocolor(175, 175, 175, a), 1, barlowRegularSmall, "center", "center")
            end
        end

        -- ** SCROLLBAR
        if #createdSessions > 8 then
            local listHeight = 8 * respc(37.5) - respc(5)
            local visibleItems = (#createdSessions - 8) + 1
    
            scrollbarHeight = (listHeight / visibleItems)
    
            if scrollTick then
                scrollbarY = interpolateBetween(scrollbarY, 0, 0, sStartY + respc(25) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 200, "Linear")
            else
                scrollbarY = sStartY + respc(30) + (scrollingValue * scrollbarHeight)
            end
            dxDrawRectangle(sStartX + sessionX - respc(6), sStartY + respc(25), respc(2), listHeight, tocolor(65, 65, 65, 200))
            dxDrawRectangle(sStartX + sessionX - respc(6) + 1, scrollbarY + 1, respc(1), scrollbarHeight - 2, tocolor(140, 195, 230, 200))
        end
    else
        --[[dxDrawImage(sX / 2 - respc(32), sY / 2 - respc(140), respc(64), respc(64), ":dAccount/files/img/logo.png")
        dxDrawRoundedRectangle(startX, startY, selectorX, selectorY, 3, tocolor(35, 35, 35, a))

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

        if isMouseInPosition(startX + respc(5), startY + respc(5), selectorX - respc(10), respc(40)) then
            dxDrawRoundedRectangle(startX + respc(5), startY + respc(5), selectorX - respc(10), respc(40), 3, tocolor(140, 195, 230, a*0.5))
            dxDrawText("TERRORELHÁRÍTÓK", startX + selectorX / 2, startY + respc(5) + respc(20), _, _, tocolor(140, 195, 230, a), 1, barlowBoldSmall, "center", "center")
            dxDrawText(count_CT .. " játékos", startX + selectorX - respc(20), startY + respc(5) + respc(20), _, _, tocolor(175, 175, 175, a), 1, barlowRegularSmall2, "right", "center")
            dxDrawImage(startX + respc(20), startY + respc(14), respc(22), respc(22), "files/img/ct.png", 0, 0, 0, tocolor(140, 195, 230, a))
        else
            dxDrawRoundedRectangle(startX + respc(5), startY + respc(5), selectorX - respc(10), respc(40), 3, tocolor(45, 45, 45, a))
            dxDrawText("TERRORELHÁRÍTÓK", startX + selectorX / 2, startY + respc(5) + respc(20), _, _, tocolor(200, 200, 200, a), 1, barlowRegularSmall, "center", "center")
            dxDrawText(count_CT .. " játékos", startX + selectorX - respc(20), startY + respc(5) + respc(20), _, _, tocolor(150, 150, 150, a), 1, barlowRegularSmall2, "right", "center")
            dxDrawImage(startX + respc(20), startY + respc(14), respc(22), respc(22), "files/img/ct.png", 0, 0, 0, tocolor(200, 200, 200, a))
        end
        
        if isMouseInPosition(startX + respc(5), startY + respc(50), selectorX - respc(10), respc(40)) then
            dxDrawRoundedRectangle(startX + respc(5), startY + respc(50), selectorX - respc(10), respc(40), 3, tocolor(210, 160, 110, a*0.5))
            dxDrawText("TERRORISTÁK", startX + selectorX / 2, startY + respc(50) + respc(20), _, _, tocolor(210, 160, 110, a), 1, barlowBoldSmall, "center", "center")
            dxDrawText(count_T .. " játékos", startX + selectorX - respc(20), startY + respc(50) + respc(20), _, _, tocolor(175, 175, 175, a), 1, barlowRegularSmall2, "right", "center")
            dxDrawImage(startX + respc(20), startY + respc(14) + respc(45), respc(22), respc(22), "files/img/t.png", 0, 0, 0, tocolor(210, 160, 110, a))
        else
            dxDrawRoundedRectangle(startX + respc(5), startY + respc(50), selectorX - respc(10), respc(40), 3, tocolor(45, 45, 45, a))
            dxDrawText("TERRORISTÁK", startX + selectorX / 2, startY + respc(50) + respc(20), _, _, tocolor(200, 200, 200, a), 1, barlowRegularSmall, "center", "center")
            dxDrawText(count_T .. " játékos", startX + selectorX - respc(20), startY + respc(50) + respc(20), _, _, tocolor(150, 150, 150, a), 1, barlowRegularSmall2, "right", "center")
            dxDrawImage(startX + respc(20), startY + respc(14) + respc(45), respc(22), respc(22), "files/img/t.png", 0, 0, 0, tocolor(200, 200, 200, a))
        end

        if isMouseInPosition(startX + respc(50), startY + respc(100), selectorX - respc(100), respc(40)) then
            dxDrawRoundedRectangle(startX + respc(50), startY + respc(100), selectorX - respc(100), respc(40), 3, tocolor(230, 140, 140, a*0.75))
            dxDrawText("KILÉPÉS A JÁTÉKMÓDBÓL", startX + selectorX / 2, startY + respc(100) + respc(20), _, _, tocolor(255, 255, 255, a), 1, barlowBoldSmall, "center", "center")
        else
            dxDrawRoundedRectangle(startX + respc(50), startY + respc(100), selectorX - respc(100), respc(40), 3, tocolor(230, 140, 140, a*0.5))
            dxDrawText("KILÉPÉS A JÁTÉKMÓDBÓL", startX + selectorX / 2, startY + respc(100) + respc(20), _, _, tocolor(200, 200, 200, a), 1, barlowRegularSmall, "center", "center")
        end]]
    end
end
--addCommandHandler("misinek", onRender)

function onClick(button, state)
    if button == "left" and state == "down" then

        -- ** SESSION KIVÁLASZTÁS LISTÁBÓL
        for index, map in ipairs(createdSessions) do
            if (index <= maxSessionsShowed) and (index > scrollingValue) then
                local index = index - scrollingValue
                if isMouseInPosition(sStartX + respc(5), sStartY + respc(25) + (index - 1) * respc(37.5), sessionX - respc(14), respc(35)) then
                    currentSelectedSession = index + scrollingValue
                end
            end
        end

        -- ** SESSION CSATLAKOZÁS
        if isMouseInPosition(sStartX + sessionX / 2 - respc(150), sStartY + sessionY - respc(60), respc(300), respc(50)) then
            triggerServerEvent("attemptToJoinSession", localPlayer, localPlayer, currentSelectedSession)
        end
    end
end

function onKey(key, state)
    if not state then
        return
    end
    if key == "mouse_wheel_up" then
        scrollTick = getTickCount()
        if scrollingValue > 0  then
            scrollingValue = scrollingValue - 1
            maxSessionsShowed = maxSessionsShowed - 1
        end
    elseif key == "mouse_wheel_down" then
        scrollTick = getTickCount()
        if maxSessionsShowed < #createdSessions then
            scrollingValue = scrollingValue + 1
            maxSessionsShowed = maxSessionsShowed + 1
        end
    end
end

function joinSuccess(element)
    if element and isElement(element) and element == localPlayer then
        playSound("files/sounds/open.wav")

        removeEventHandler("onClientRender", root, onRender)
        removeEventHandler("onClientClick", root, onClick)
        removeEventHandler("onClientKey", root, onKey)
        showChat(true)
        setElementData(localPlayer, "a.HUDshowed", true)
        
        exports.dInfobox:makeNotification(1, "Sikeresen csatlakoztál a játékmenethez. Kilépni a /lobby paranccsal tudsz.")
        toggleControl("fire", true)
        toggleControl("action", true)
        exports.dLoader:createLoader(element, 2)
        setTimer(function()
            if not (getElementData(element, "a.Gamemode") == 1) then
                return
            end

            addEventHandler("onClientRender", root, renderScore)
        end, 2000, 1)

        local currentPlayerSession = getElementData(localPlayer, "a.Current<DM>Session")
        if not currentPlayerSession then
            return
        end

        createdSessions[currentPlayerSession][4] = createdSessions[currentPlayerSession][4] + 1
    end
end
addEvent("joinSuccess", true)
addEventHandler("joinSuccess", root, joinSuccess)

local poppinsBold = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(12), false, "cleartype")
local poppinsBold2 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(20), false, "cleartype")
local poppinsBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(25), false, "cleartype")

function removeCounterFromScreen(element)
    if element == localPlayer then
        removeEventHandler("onClientRender", root, renderScore)
    end
end
addEvent("removeCounterFromScreen", true)
addEventHandler("removeCounterFromScreen", root, removeCounterFromScreen)

function renderScore()
    if not (getElementData(localPlayer, "a.HUDshowed")) then
        return
    end
    
    local startX, startY = sX / 2, sY - respc(100)

    local currentPlayerSession = getElementData(localPlayer, "a.Current<DM>Session")
    if not currentPlayerSession then
        return
    end
    local currentSessionSeconds = tonumber(createdSessions[currentPlayerSession][2])

    local teamOneCount = tonumber(createdSessions[currentPlayerSession][6])
    local teamTwoCount = tonumber(createdSessions[currentPlayerSession][7])

    dxDrawText(secondsToTime(currentSessionSeconds), startX + 1, startY + respc(25) + 1, _, _, tocolor(2, 2, 2, 200), 1, poppinsBold2, "center", "center")
    dxDrawText(secondsToTime(currentSessionSeconds), startX, startY + respc(25), _, _, tocolor(240, 220, 120, 255*0.8), 1, poppinsBold2, "center", "center")

    dxDrawImage(startX - respc(50) - respc(100), startY, respc(100), respc(50), "files/img/header.png", 180, 0, 0, tocolor(210, 160, 110, 255*0.75))
    dxDrawText(teamOneCount, startX - respc(65) + 1, startY + respc(22.5) + 1, _, _, tocolor(20, 20, 20, 200), 1, poppinsBoldBig, "right", "center", false, false, false, true)
    dxDrawText(teamOneCount, startX - respc(65), startY + respc(22.5), _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldBig, "right", "center", false, false, false, true)

    dxDrawImage(startX + respc(50), startY, respc(100), respc(50), "files/img/header.png", 0, 0, 0, tocolor(140, 195, 230, 255*0.75))
    dxDrawText(teamTwoCount, startX + respc(65) + 1, startY + respc(22.5) + 1, _, _, tocolor(20, 20, 20, 200), 1, poppinsBoldBig, "left", "center", false, false, false, true)
    dxDrawText(teamTwoCount, startX + respc(65), startY + respc(22.5), _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldBig, "left", "center", false, false, false, true)
end

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

function secondsToTime2(seconds)
	local seconds = tonumber(seconds)
    if not tonumber(seconds) then return "00:00" end
  	if seconds <= 0 then
		return "00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = math.floor(seconds/60 - (hours*60))
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return mins.."p "..secs.. "mp"
    end
end

function addToKillFeed(killer, killed, weapon)
    if getElementData(localPlayer, "a.Gamemode") == 1 then
        local killerTeam = getElementData(killer, "a.Team<DM>")
        local deadTeam = getElementData(killed, "a.Team<DM>")
        local weaponId = getElementData(killer, "currentWeaponID")

        local hexColors = {
            ["Attacker"] = "#D6B370",
            ["Defender"] = "#72ABCC",
        }
    
        triggerEvent("sendToEventLogger", localPlayer, hexColors[killerTeam] .. getElementData(killer, "a.PlayerName") .. "#FFFFFF megölte " .. hexColors[deadTeam] .. getElementData(killed, "a.PlayerName") .. "#FFFFFF-t (fegyver: " .. exports.dItems:getItemName(weaponId) .. ")")
    end
end
addEvent("addToKillFeed", true)
addEventHandler("addToKillFeed", getRootElement(), addToKillFeed)

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

local topTexture = dxCreateTexture("files/img/featherTop.dds", "dxt5", true, "clamp")
local sideTexture = dxCreateTexture("files/img/feather.dds", "dxt5", true, "clamp")
local cornerTexture = dxCreateTexture("files/img/corner.dds", "dxt5", true, "clamp")

function dxDrawFadeRectangle(x, y, w, h, color)

    x = x - 5
    y = y - 5
    w = w + 10
    h = h + 10
    if color[4] < 10 then
        return
    end
    
    dxDrawRectangle(x + 10, y + 10, w - 20, h - 20, tocolor(color[1], color[2], color[3], color[4] - 15))
    color = tocolor(color[1], color[2], color[3], color[4])
    dxDrawImage(x, y, 10, 10, cornerTexture, 270, 0, 0, color)
    dxDrawImage(x + w - 10, y, 10, 10, cornerTexture, 0, 0, 0, color)
    dxDrawImage(x, y + h - 10, 10, 10, cornerTexture, 180, 0, 0, color)
    dxDrawImage(x + w - 10, y + h - 10, 10, 10, cornerTexture, 90, 0, 0, color)

    dxDrawImage(x + 10, y + 10, w - 20, -10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + h - 10, w - 20, 10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + 10, -10, h - 20, sideTexture, 0, 0, 0, color)
    dxDrawImage(x + w - 10, y + 10, 10, h - 20, sideTexture, 0, 0, 0, color)
end