local sX, sY = guiGetScreenSize();

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

local font = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(8), false, "cleartype")
local interLightSmall = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(8), false, "cleartype")

local fontAwesome = dxCreateFont(":dFonts/fonts/FontAwesome.ttf", respc(11), false, "cleartype")
local fontAwesomeBig = dxCreateFont(":dFonts/fonts/FontAwesome.ttf", respc(25), false, "cleartype")
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
									local id = " (" .. getElementData(v, "d/PlayerID") .. ")"
									if aLevel > 0 then
										syntax = exports.dAdmin:getAdminSyntax(aLevel, true) .. " - "
									else
										syntax = ""
									end

									local isVip = getElementData(v, "a.VIP")

									if isVip == true then
										name = "#F1DB76 ".. name .. ""
									else
										name = "#FFFFFF " .. name .. ""
									end
									
									if getElementData(v, "a.Team<DM>") == "Attacker" then
										name = "#C89E62" .. name
									elseif getElementData(v, "a.Team<DM>") == "Defender" then
										name = "#6299C8" .. name
									else
										name = "#FFFFFF" .. name
									end

									-- local vipLevel = getElementData(v, "a.VIP")
									-- if vipLevel and aLevel == 0 then
									-- 	if vipLevel == 1 then
									-- 		syntax = "#F1DB76VIP - #FFFFFF"
									-- 	elseif vipLevel == 2 then
									-- 		syntax = "#BBEE6AsuperVIP - #FFFFFF"
									-- 	end
									-- end

									local width = dxGetTextWidth(removeHex(syntax .. name .. "#8FC3E4" .. id), 1, font)

									local maxDist = 25
									if anamesState then
										maxDist = 100
									end
									if distance > maxDist then
										return
									end
									local scale = 1 - distance / (maxDist * 2)

									if aLevel > 0 then
										if (not getElementData(v, "afk")) and (not getElementData(v, "typing")) and (not getElementData(v, "console")) then
											local sizeX, sizeY = respc(40) * scale, respc(40) * scale
											dxDrawImage(worldX - sizeX / 2, worldY - sizeY - respc(10), sizeX, sizeY, "files/icons/logo.png", 0, 0, 0, tocolor(255, 255, 255, 200 * scale))
											local r, g, b = hex2rgb(exports.dAdmin:getAdminLevelColor(aLevel))
											dxDrawImage(worldX - sizeX / 2, worldY - sizeY - respc(10), sizeX, sizeY, "files/icons/logo2.png", 0, 0, 0, tocolor(r, g, b, 255 * scale))
										else
											local sizeX, sizeY = respc(40) * scale, respc(40) * scale
											dxDrawImage(worldX - sizeX / 2, worldY - sizeY - respc(17.5), sizeX, sizeY, "files/icons/logo.png", 0, 0, 0, tocolor(255, 255, 255, 200 * scale))
											local r, g, b = hex2rgb(exports.dAdmin:getAdminLevelColor(aLevel))
											dxDrawImage(worldX - sizeX / 2, worldY - sizeY - respc(17.5), sizeX, sizeY, "files/icons/logo2.png", 0, 0, 0, tocolor(r, g, b, 255 * scale))
										end
									end

									if getElementData(v, "afk") then
										dxDrawText(">> AFK <<", worldX, worldY - respc(15), _, _, tocolor(255, 255, 255, 200), 0.85 * scale, interLightSmall, "center", "center", false, false, false, true)
									elseif getElementData(v, "typing") then
										dxDrawText(">> TYPING <<", worldX, worldY - respc(15), _, _, tocolor(255, 255, 255, 200), 0.85 * scale, interLightSmall, "center", "center", false, false, false, true)
									elseif getElementData(v, "console") then
										dxDrawText(">> CONSOLE <<", worldX, worldY - respc(15), _, _, tocolor(255, 255, 255, 200), 0.85 * scale, interLightSmall, "center", "center", false, false, false, true)
									end

									if getElementData(v, "adminVanish") == false then
										dxDrawText(removeHex(syntax .. name .. "#e18c88" .. id, 6), worldX + 2, worldY + 2, worldX, worldY, tocolor(2, 2, 2, 255 * scale), 1 * scale, font, "center", "center", false, false, false, false)
										dxDrawText(syntax .. name .. "#e18c88" .. id, worldX, worldY, worldX, worldY, tocolor(200, 200, 200, 255 * scale), 1 * scale, font, "center", "center", false, false, false, true)
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
									local id = " (" .. getElementData(v, "d/PlayerID") .. ")"
									
									if aLevel > 0 then
										syntax = exports.dAdmin:getAdminSyntax(aLevel, true) .. " - "
									else
										syntax = ""
									end

									local isVip = getElementData(v, "a.VIP")

									if isVip == true then
										name = "#F1DB76 ".. name .. ""
									else
										name = "#FFFFFF " .. name .. ""
									end

									if getElementData(v, "a.Team<DM>") == "Attacker" then
										name = "#C89E62" .. name
									elseif getElementData(v, "a.Team<DM>") == "Defender" then
										name = "#6299C8" .. name
									else
										name = "#FFFFFF" .. name
									end

									-- local vipLevel = getElementData(v, "a.VIP")
									-- if vipLevel and aLevel == 0 then
									-- 	if vipLevel == 1 then
									-- 		syntax = "#F1DB76VIP - #FFFFFF"
									-- 	elseif vipLevel == 2 then
									-- 		syntax = "#BBEE6AsuperVIP - #FFFFFF"
									-- 	end
									-- end

									local width = dxGetTextWidth(removeHex(syntax .. name .. "#e18c88" .. id), 1, font)
									
									local maxDist = 25
									if anamesState then
										maxDist = 100
									end
									if distance > maxDist then
										return
									end
									
									local scale = 1 - distance / (maxDist * 2)

									if aLevel > 0 then
										if (not getElementData(v, "afk")) and (not getElementData(v, "typing")) and (not getElementData(v, "console")) then
											local sizeX, sizeY = respc(40) * scale, respc(40) * scale
											dxDrawImage(worldX - sizeX / 2, worldY - sizeY - respc(10), sizeX, sizeY, "files/icons/logo.png", 0, 0, 0, tocolor(255, 255, 255, 200 * scale))
											local r, g, b = hex2rgb(exports.dAdmin:getAdminLevelColor(aLevel))
											dxDrawImage(worldX - sizeX / 2, worldY - sizeY - respc(10), sizeX, sizeY, "files/icons/logo2.png", 0, 0, 0, tocolor(r, g, b, 255 * scale))
										else
											local sizeX, sizeY = respc(40) * scale, respc(40) * scale
											dxDrawImage(worldX - sizeX / 2, worldY - sizeY - respc(17.5), sizeX, sizeY, "files/icons/logo.png", 0, 0, 0, tocolor(255, 255, 255, 200 * scale))
											local r, g, b = hex2rgb(exports.dAdmin:getAdminLevelColor(aLevel))
											dxDrawImage(worldX - sizeX / 2, worldY - sizeY - respc(17.5), sizeX, sizeY, "files/icons/logo2.png", 0, 0, 0, tocolor(r, g, b, 255 * scale))
										end
									end

									if getElementData(v, "afk") then
										dxDrawText(">> AFK <<", worldX, worldY - respc(15), _, _, tocolor(255, 255, 255, 200), 0.85 * scale, interLightSmall, "center", "center", false, false, false, true)
									elseif getElementData(v, "typing") then
										dxDrawText(">> TYPING <<", worldX, worldY - respc(15), _, _, tocolor(255, 255, 255, 200), 0.85 * scale, interLightSmall, "center", "center", false, false, false, true)
									elseif getElementData(v, "console") then
										dxDrawText(">> CONSOLE <<", worldX, worldY - respc(15), _, _, tocolor(255, 255, 255, 200), 0.85 * scale, interLightSmall, "center", "center", false, false, false, true)
									end

									if getElementData(v, "adminVanish") == false then
										dxDrawText(removeHex(syntax .. name .. "#e18c88" .. id, 6), worldX + 2, worldY + 2, worldX, worldY, tocolor(2, 2, 2, 255 * scale), 1 * scale, font, "center", "center", false, false, false, false)
										dxDrawText(syntax .. name .. "#e18c88" .. id, worldX, worldY, worldX, worldY, tocolor(200, 200, 200, 255 * scale), 1 * scale, font, "center", "center", false, false, false, true)
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

								local maxDist = 15
								if distance > maxDist then
									return
								end
								local scale = 1 - distance / (maxDist * 2)

								dxDrawText(removeHex("#8FC3E4PED - " .. name), worldX + 2, worldY + 2, worldX, worldY, tocolor(2, 2, 2, 255*scale), 1*scale, font, "center", "center", false, false, false, true)
								dxDrawText("#8FC3E4PED -#FFFFFF " .. name, worldX, worldY, worldX, worldY, tocolor(255, 255, 255, 255*scale), 1*scale, font, "center", "center", false, false, false, true)
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

function hex2rgb(hex) 
	hex = hex:gsub("#","") 
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)) 
  end 

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

local topTexture = dxCreateTexture("files/icons/featherTop.dds", "dxt5", true, "clamp")
local sideTexture = dxCreateTexture("files/icons/feather.dds", "dxt5", true, "clamp")
local cornerTexture = dxCreateTexture("files/icons/corner.dds", "dxt5", true, "clamp")

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