local font = dxCreateFont("files/fonts/Roboto.otf", 15, false, "cleartype")
local fontAwesome = dxCreateFont("files/fonts/FontAwesome.ttf", 11, false, "cleartype")
local fontAwesomeBig = dxCreateFont("files/fonts/FontAwesome.ttf", 25, false, "cleartype")
local syntax = ""
local togsyntax = false;
local playerCache = {}

function renderNick()
	if not (getElementData(localPlayer, "a.NameShowing")) then
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
									local name = getElementData(v, "a.PlayerName")
									local id = " (" .. getElementData(v, "playerid") .. ")"
									syntax = exports.aAdmin:getAdminSyntax(aLevel, true)

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
									end
									local width = dxGetTextWidth(removeHex(syntax .. name .. "#e18c88" .. id), 1, font)
									
									if getElementData(v, "afk") then
										dxDrawText("", worldX + width / 2 + 6, worldY - 1, _, _, tocolor(2, 2, 2, 200), 1, fontAwesome, "left", "center", false, false, false, true)
										dxDrawText("", worldX + width / 2 + 5, worldY - 2, _, _, tocolor(255, 255, 255, 200), 1, fontAwesome, "left", "center", false, false, false, true)

									elseif getElementData(v, "typing") then
										dxDrawText("", worldX + width / 2 + 6, worldY - 1, _, _, tocolor(2, 2, 2, 200), 1, fontAwesome, "left", "center", false, false, false, true)
										dxDrawText("", worldX + width / 2 + 5, worldY - 2, _, _, tocolor(255, 255, 255, 200), 1, fontAwesome, "left", "center", false, false, false, true)
									elseif getElementData(v, "console") then
										dxDrawText("", worldX + width / 2 + 6, worldY - 1, _, _, tocolor(2, 2, 2, 200), 1, fontAwesome, "left", "center", false, false, false, true)
										dxDrawText("", worldX + width / 2 + 5, worldY - 2, _, _, tocolor(255, 255, 255, 200), 1, fontAwesome, "left", "center", false, false, false, true)
									end

									if getElementData(v, "adminVanish") == false then
										dxDrawText(removeHex(syntax .. name .. "#e18c88" .. id, 6), worldX + 2, worldY + 2, worldX, worldY, tocolor(2, 2, 2, 230), 1, font, "center", "center", false, false, false, false)
										dxDrawText(syntax .. name .. "#e18c88" .. id, worldX, worldY, worldX, worldY, tocolor(200, 200, 200, 230), 1, font, "center", "center", false, false, false, true)
									end
								end
							end
						end
					end
				end
			end
		end
	else
		for k, v in ipairs(getElementsByType("player")) do
			--if v ~= localPlayer then
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
									local name = getElementData(v, "a.PlayerName")
									local id = " (" .. getElementData(v, "playerid") .. ")"
									syntax = exports.aAdmin:getAdminSyntax(aLevel, true) .. " "


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
									end
									local width = dxGetTextWidth(removeHex(syntax .. name .. "#e18c88" .. id), 1, font)
									
									if getElementData(v, "afk") then
										dxDrawText("", worldX + width / 2 + 6, worldY - 1, _, _, tocolor(2, 2, 2, 200), 1, fontAwesome, "left", "center", false, false, false, true)
										dxDrawText("", worldX + width / 2 + 5, worldY - 2, _, _, tocolor(255, 255, 255, 200), 1, fontAwesome, "left", "center", false, false, false, true)

									elseif getElementData(v, "typing") then
										dxDrawText("", worldX + width / 2 + 6, worldY - 1, _, _, tocolor(2, 2, 2, 200), 1, fontAwesome, "left", "center", false, false, false, true)
										dxDrawText("", worldX + width / 2 + 5, worldY - 2, _, _, tocolor(255, 255, 255, 200), 1, fontAwesome, "left", "center", false, false, false, true)
									elseif getElementData(v, "console") then
										dxDrawText("", worldX + width / 2 + 6, worldY - 1, _, _, tocolor(2, 2, 2, 200), 1, fontAwesome, "left", "center", false, false, false, true)
										dxDrawText("", worldX + width / 2 + 5, worldY - 2, _, _, tocolor(255, 255, 255, 200), 1, fontAwesome, "left", "center", false, false, false, true)
									end

									if getElementData(v, "adminVanish") == false then
										dxDrawText(removeHex(syntax .. name .. "#e18c88" .. id, 6), worldX + 2, worldY + 2, worldX, worldY, tocolor(2, 2, 2, 230), 1, font, "center", "center", false, false, false, false)
										dxDrawText(syntax .. name .. "#e18c88" .. id, worldX, worldY, worldX, worldY, tocolor(200, 200, 200, 230), 1, font, "center", "center", false, false, false, true)
									end
								end
							end
						end
					end
				end
			--end
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
								dxDrawText(removeHex("#8FC3E4[PED] " .. name), worldX + 2, worldY + 2, worldX, worldY, tocolor(2, 2, 2, 255), 1, font, "center", "center", false, false, false, true)
								dxDrawText("#8FC3E4[PED]#FFFFFF " .. name, worldX, worldY, worldX, worldY, tocolor(255, 255, 255, 255), 1, font, "center", "center", false, false, false, true)
							end
						end
					end
				--end
			end
		end
	end
end
--addEventHandler("onClientPreRender", root, renderNick)
setTimer(renderNick, 5, 0)

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

addEventHandler ("onClientRender", root,
	function ()
		local cTick = getTickCount ()
		if cTick-lastClick >= 300000 then
			if not getElementData(localPlayer, "afk") then
				setElementData(localPlayer, "afk", true)
			end
		end
	end
)

addEventHandler( "onClientRestore", localPlayer,
	function ()
		lastClick = getTickCount ()
		setElementData (localPlayer,"afk",false)

	end
)

addEventHandler( "onClientMinimize", getRootElement(),
	function ()
		setElementData (localPlayer,"afk",true)
	end
)

addEventHandler( "onClientCursorMove", getRootElement( ),
    function ( x, y )
		lastClick = getTickCount ()
		if getElementData(localPlayer,"afk") == true then
			setElementData (localPlayer,"afk",false)
		end
    end
)

addEventHandler("onClientKey", getRootElement(), 
	function ()
		lastClick = getTickCount ()
		if getElementData(localPlayer,"afk") == true then
			setElementData (localPlayer,"afk",false)
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

function onStart()
	for i, v in ipairs(getElementsByType("player")) do
		if v == localPlayer then
			if getElementData(localPlayer, "a.NameShowing") then
				table.insert(playerCache, v)
			end
		else
			table.insert(playerCache, v)
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onJoin()
	table.insert(playerCache, source)
end
addEventHandler("onClientPlayerJoin", root, onJoin)

function onLeave()
	for i, v in ipairs(playerCache) do
		if v == source then
			table.remove(playerCache, i)
		end
	end
end
addEventHandler("onClientPlayerQuit", root, onLeave)

function onChange(key, oVal, nVal)
	if key == "a.NameShowing" then
		if nVal == true then
			table.insert(playerCache, source)
		elseif nVal == false then
			for i, v in ipairs(playerCache) do
				if v == source then
					table.remove(playerCache, i)
				end
			end
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

function showMyName(commandName)
	setElementData(localPlayer, "a.NameShowing", not (getElementData(localPlayer, "a.NameShowing")))
end
addCommandHandler("showmyname", showMyName)