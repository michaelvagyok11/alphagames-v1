function onStart()
    playersToRender = getElementsByType("player")
    fontAwesome = dxCreateFont("files/fonts/FontAwesome.ttf", 10, false, "cleartype")
    fontAwesomeBig = dxCreateFont("files/fonts/FontAwesome.ttf", 12, false, "cleartype")
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onJoin()
    table.insert(playersToRender, source)
end
addEventHandler("onClientPlayerJoin", root, onJoin)

function onQuit()
    for k, v in ipairs(getElementsByType("player")) do
        if v == source then
            table.remove(playersToRender, k)
        end
    end
end
addEventHandler("onClientPlayerQuit", root, onQuit)

function onRender()
    for i, v in ipairs(playersToRender) do
        if isElementOnScreen(v) then
            local cameraX, cameraY, cameraZ = getCameraMatrix()
            local playerX, playerY, playerZ = getElementPosition(v)
            if isLineOfSightClear(cameraX, cameraY, cameraZ, playerX, playerY, playerZ, true, false, false, true, false, false, false, localPlayer) then
                local boneX, boneY, boneZ = getPedBonePosition(v, 5)
                local worldX, worldY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.28)
                if worldX and worldY then
                    local aLevel = getElementData(v, "adminLevel");
                    if aLevel == 1 and not togsyntax then
                        syntax = "#dfacde[P. Moderátor] #FFFFFF"
                        r, g, b = 87, 67, 87
                    elseif aLevel == 2 and not togsyntax then
                        syntax = "#62a7e1[Adminisztrátor] #FFFFFF"
                        r, g, b = 38, 65, 88
                    elseif aLevel == 3 and not togsyntax then
                        syntax = "#cfad80[Fejlesztő] #FFFFFF"
                        r, g, b = 81, 68, 50
                    elseif aLevel == 4 and not togsyntax then
                        syntax = "#dce188[Menedzser] #FFFFFF"
                        r, g, b = 86, 88, 53
                    elseif aLevel == 5 and not togsyntax then
                        syntax = "#e18c88[Tulajdonos] #FFFFFF"
                        r, g, b = 88, 55, 53
                    elseif aLevel == 0 or togsyntax then
                        syntax = ""
                    end

                    dxDrawText(removeHex(syntax, 6), worldX - (dxGetTextWidth(getPlayerName(v), 1, fontAwesomeBig, true)/2) - 25 + 1, worldY + 1, _, _, tocolor(20, 20, 20), 1, fontAwesome, "left", "center", false, false, false, false)
                    dxDrawText(getPlayerName(v), worldX + 1, worldY + 1, _, _, tocolor(20, 20, 20), 1, fontAwesomeBig, "left", "center", false, false, false, true)

                    dxDrawText(syntax, worldX - (dxGetTextWidth(getPlayerName(v), 1, fontAwesomeBig, true)/2) - 25, worldY, _, _, tocolor(150, 150, 150), 1, fontAwesome, "left", "center", false, false, false, true)
                    dxDrawText(getPlayerName(v), worldX, worldY, _, _, tocolor(200, 200, 200), 1, fontAwesomeBig, "left", "center", false, false, false, true)

                    if getElementData(v, "typing") then 
                        dxDrawText("", worldX + (dxGetTextWidth(getPlayerName(v), 1, fontAwesomeBig, true)/2) + 5 + 1, worldY + 1, _, _, tocolor(20, 20, 20), 1, fontAwesome, "left", "center", false, false, false, true)
                        dxDrawText("", worldX + (dxGetTextWidth(getPlayerName(v), 1, fontAwesomeBig, true)/2) + 5, worldY, _, _, tocolor(150, 150, 150), 1, fontAwesome, "left", "center", false, false, false, true)
                    elseif getElementData(v, "console") then
                        dxDrawText("", worldX + (dxGetTextWidth(getPlayerName(v), 1, fontAwesomeBig, true)/2) + 5 + 1, worldY + 1, _, _, tocolor(20, 20, 20), 1, fontAwesome, "left", "center", false, false, false, true)
                        dxDrawText("", worldX + (dxGetTextWidth(getPlayerName(v), 1, fontAwesomeBig, true)/2) + 5, worldY, _, _, tocolor(150, 150, 150), 1, fontAwesome, "left", "center", false, false, false, true)
                    elseif getElementData(v, "afk") then
                        dxDrawText("", worldX + (dxGetTextWidth(getPlayerName(v), 1, fontAwesomeBig, true)/2) + 5 + 1, worldY + 1, _, _, tocolor(20, 20, 20), 1, fontAwesome, "left", "center", false, false, false, true)
                        dxDrawText("", worldX + (dxGetTextWidth(getPlayerName(v), 1, fontAwesomeBig, true)/2) + 5, worldY, _, _, tocolor(150, 150, 150), 1, fontAwesome, "left", "center", false, false, false, true)
                    end
                end
            end
        end
    end

    for i, v in ipairs(getElementsByType("ped")) do
        if isElementOnScreen(v) then
            local cameraX, cameraY, cameraZ = getCameraMatrix()
            local playerX, playerY, playerZ = getElementPosition(v)
            if isLineOfSightClear(cameraX, cameraY, cameraZ, playerX, playerY, playerZ, true, false, false, true, false, false, false, localPlayer) then
                local boneX, boneY, boneZ = getPedBonePosition(v, 5)
                local worldX, worldY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.28)
                if worldX and worldY then
                    local dist = getDistanceBetweenPoints3D(Vector3(getElementPosition(v)), Vector3(getElementPosition(localPlayer)))
                    if dist < 10 then
                         dxDrawText(getElementData(v, "a.Pedname") .. " #B1C7AA", worldX, worldY, _, _, tocolor(200, 200, 200), 1, fontAwesome, "center", "center", false, false, false, true)
                    end
                end
            end
        end
    end
end
setTimer(onRender, 5, 0)

function anamesEnable(commandName)
    if (commandName) then
        if getElementData(localPlayer, "a.AnamesState") then
            setElementData(localPlayer, "a.AnamesState", false)
            exports.a_interface:makeNotification(1, "You have successfully disabled the admin names.")
        else
            setElementData(localPlayer, "a.AnamesState", true)
            exports.a_interface:makeNotification(1, "You have successfully enabled the admin names.")
        end
    end
end
addCommandHandler("anames", anamesEnable)

-- AFK CHECK

local lastClick = getTickCount()

addEventHandler ("onClientRender",getRootElement(),
	function ()
		local cTick = getTickCount ()
		if cTick-lastClick >= 300000 then
			if getElementData(getLocalPlayer(),"afk") == false then
				local hp = getElementHealth (getLocalPlayer())
				if hp > 0 then
					setElementData (getLocalPlayer(),"afk",true)
					if isTimer (startTimer) then 
						killTimer(startTimer)
					end

					startTimer = setTimer(Timer,1000,0)
					if isTimer (timer) then 
						killTimer(timer)
					end
				end
			end
		end
	end
)

addEventHandler( "onClientRestore", getLocalPlayer(),
	function ()
		lastClick = getTickCount ()
		setElementData (getLocalPlayer(),"afk",false)
		second = 0
		if isTimer (startTimer) then 
			killTimer(startTimer)
		end
	end
)

function Timer()
	second = second + 1
	--setElementData(getLocalPlayer(),"Timer", second)
end

addEventHandler( "onClientMinimize", getRootElement(),
	function ()
		setElementData (getLocalPlayer(),"afk",true)
		second = 0
		if isTimer (startTimer) then 
			killTimer(startTimer)
		end
		startTimer = setTimer(Timer,1000,0)
		if isTimer (timer) then 
			killTimer(timer)
		end
	end
)

addEventHandler( "onClientCursorMove", getRootElement( ),
    function ( x, y )
		lastClick = getTickCount ()
		if getElementData(getLocalPlayer(),"afk") == true then
			setElementData (getLocalPlayer(),"afk",false)
			if isTimer (startTimer) then 
				killTimer(startTimer)
			end
		end
    end
)

addEventHandler("onClientKey", getRootElement(), 
	function ()
		lastClick = getTickCount ()
		if getElementData(getLocalPlayer(),"afk") == true then
			setElementData (getLocalPlayer(),"afk",false)
			second = 0
			if isTimer (startTimer) then 
				killTimer(startTimer)
			end
		end
	end
)

-- TYPING CHECK

function checkForChat()
	if isChatBoxInputActive() then
		setElementData(getLocalPlayer(), "typing", true)	
	elseif not isChatBoxInputActive() then
		setElementData(getLocalPlayer(), "typing", false)
	end
end
setTimer ( checkForChat, 100, 0 )

function checkForConsole()
	if isConsoleActive() then
		setElementData(getLocalPlayer(), "console", true)	
	elseif not isConsoleActive() then
		setElementData(getLocalPlayer(), "console", false)
	end
end
setTimer ( checkForConsole, 100, 0 )

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end