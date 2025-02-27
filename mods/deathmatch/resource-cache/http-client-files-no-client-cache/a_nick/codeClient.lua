local font = dxCreateFont("files/fonts/Roboto.otf", 13, false, "cleartype")
local syntax = ""
local togsyntax = false;
local playerTable = {}

function renderNick()
    for k, v in ipairs(getElementsByType("player")) do
        if v ~= localPlayer then
            if isElementOnScreen(v) then
                if getElementAlpha(v, 255) then
                    local cameraX, cameraY, cameraZ = getCameraMatrix()
                    local playerX, playerY, playerZ = getElementPosition(v)
                    if isLineOfSightClear(cameraX, cameraY, cameraZ, playerX, playerY, playerZ, true, false, false, true, false, false, false, localPlayer) then
                        local distance = getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), playerX, playerY, playerZ)
                        if distance < 25 then
                            local boneX, boneY, boneZ = getPedBonePosition(v, 5)
                            local worldX, worldY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.28)
                            if worldX and worldY then
                                local aLevel = getElementData(v, "adminLevel")
                                local name = getPlayerName(v)
								local id = " (" .. getElementData(v, "playerid") .. ")"
                                if aLevel == 1 and not togsyntax then
                                    syntax = "#f49ac1[HELPER] #FFFFFF"
									r, g, b = 245, 155, 195
                                elseif aLevel == 2 and not togsyntax then
                                    syntax = "#36a93c[STAFF] #FFFFFF"
									r, g, b = 55, 170, 60
                                elseif aLevel == 3 and not togsyntax then
                                    syntax = "#89dc3c[MAIN STAFF] #FFFFFF"
									r, g, b = 140, 220, 60
                                elseif aLevel == 0 or togsyntax then
                                    syntax = ""
                                end

                                if getElementData(v, "afk") then
                                    name = name .. " #C8C8C8(AFK)"
                                    dxDrawImage(worldX - 35, worldY - 75, 75, 75, "files/icons/afk.png", 0, 0, 0, tocolor(200, 200, 200, 200))
                                elseif getElementData(v, "typing") then
                                    name = name .. " #C8C8C8(Typing...)"
                                    dxDrawImage(worldX - 35, worldY - 85, 75, 75, "files/icons/typing.png", 0, 0, 0, tocolor(200, 200, 200, 200))
								elseif getElementData(v, "console") then
									name = name .. " #C8C8C8(Console)"
                                end

								if getElementData(v, "a.DMTeam") == "Terrorists" then
									name = "#C89E62" .. name
								elseif getElementData(v, "a.DMTeam") == "Counter-Terrorists" then
									name = "#6299C8" .. name
								else
									name = "#FFFFFF" .. name
								end

								local vip = getElementData(v, "a.VIP")
								if vip == true and aLevel == 0 then
									syntax = "#C4CD5D[VIP] #FFFFFF"
									if aLevel == 0 then
									end
								end
								local width = dxGetTextWidth(removeHex(syntax .. name .. "#D19D6B" .. id), 1, font)

                                dxDrawBorderedText(1, syntax .. name .. "#D19D6B" .. id, worldX, worldY, worldX, worldY, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)
								if aLevel >= 1 then
									dxDrawImage(worldX - width/2 - 29, worldY - 13, 24, 24, "files/icons/logo.png", 0, 0, 0, tocolor(20, 20, 20, 255))
									dxDrawImage(worldX - width/2 - 28, worldY - 12, 22, 22, "files/icons/logo.png", 0, 0, 0, tocolor(r, g, b, 255))
								end
								if vip == true and aLevel == 0 then
									dxDrawImage(worldX - width/2 - 29, worldY - 13, 24, 24, "files/icons/logo.png", 0, 0, 0, tocolor(20, 20, 20, 255))
									dxDrawImage(worldX - width/2 - 28, worldY - 12, 22, 22, "files/icons/logo.png", 0, 0, 0, tocolor(220, 220, 120, 255))
								end
								--dxDrawImage(worldX, worldY, 128, 128, "files/icons/logo2.png", 0, 0, 0, tocolor(140, 220, 60, 255))
                            end
                        end
                    end
                end
            end
        end
    end
	for k, v in ipairs(getElementsByType("ped")) do
		if getElementData(v, "a.Pedname") then
			if isElementOnScreen(v) then
					local cameraX, cameraY, cameraZ = getCameraMatrix()
                    local playerX, playerY, playerZ = getElementPosition(v)
                    if isLineOfSightClear(cameraX, cameraY, cameraZ, playerX, playerY, playerZ, true, false, false, true, false, false, false, localPlayer) then
                        local distance = getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), playerX, playerY, playerZ)
                        if distance < 15 then
                            local boneX, boneY, boneZ = getPedBonePosition(v, 5)
                            local worldX, worldY = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.28)
                            if worldX and worldY then
								local name = getElementData(v, "a.Pedname")
								dxDrawBorderedText(1, name .. " #8FC3E4(PED)", worldX, worldY, worldX, worldY, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)
							end
						end
					end
				--end
			end
		end
	end
end
addEventHandler("onClientRender", root, renderNick)

function togSyntax()
	if getElementData(localPlayer, "adminLevel") >= 1 then
		togsyntax = not togsyntax
	end
end
addCommandHandler("togsyntax", togSyntax)

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end

function dxDrawBorderedText (outline, text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    for oX = (outline * -1), outline do
        for oY = (outline * -1), outline do
            dxDrawText (removeHex(text, 6), left + oX, top + oY, right + oX, bottom + oY, tocolor(0, 0, 0, 255), scale, font, alignX, alignY, clip, wordBreak, false, false, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
        end
    end
    dxDrawText (text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, false, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end

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