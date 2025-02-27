local sX, sY = guiGetScreenSize();
local sizeX, sizeY = 400, 250;
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
local panelState = "closed";
local scrollValue = 0;
local maxContainersOnScreen = 6;

local poppinsBold = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 13, false, "cleartype");
local poppinsRegular = dxCreateFont("files/fonts/Poppins-Regular.ttf", 13, false, "cleartype");

local teleportPositions = {
	{"Willowfield", 2105.3095703125, -2084.654296875, 13.546875},
	{"Glen Park", 1877.4267578125, -1377.0703125, 13.564956665039},
	{"Jefferson", 2223.9765625, -1159.255859375, 25.746496200562},
	{"Angel Pine", -2099.5947265625, -2515.8427734375, 30.580184936523},
	{"Supa Save", -2442.3349609375, 741.6953125, 35.015625},
	{"San Fierro Downtown", -1634.259765625, 1293.8232421875, 7.0390625},
	{"Fourd Dragons Casino", 2033.876953125, 1006.94140625, 10.510503768921},
	{"Las Venturas Police Department", 2288.8525390625, 2422.22265625, 10.524280548096},
	{"Las Venturas Airport", 1698.6533203125, 1608.3076171875, 10.390411376953},
	{"Las Venturas elhagyatott reptér", 391.1650390625, 2508.0849609375, 16.187789916992},
	{"Bayside", -2259.861328125, 2301.9833984375, 4.5227832794189},
}

function openPanel()
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end
	if getElementData(localPlayer, "a.Gamemode") == 2 or getElementData(localPlayer, "a.Gamemode") == 3 then
		if panelState == "opened" then
			panelState = "closed"
			removeEventHandler("onClientRender", root, onRender)
			removeEventHandler("onClientClick", root, onClick)
			removeEventHandler("onClientKey", root, onKey)
		else
			panelState = "opened"
			addEventHandler("onClientRender", root, onRender)
			addEventHandler("onClientClick", root, onClick)
			addEventHandler("onClientKey", root, onKey)

			openTick = getTickCount()
		end
	end
end
addCommandHandler("tp", openPanel)
addCommandHandler("teleport", openPanel)

function onChange(key, oVal, nVal)
	if key == "a.Gamemode" then
		if nVal == nil or nVal == 1 or nVal == 4 then
			if panelState == "opened" then
				panelState = "closed"
				removeEventHandler("onClientRender", root, onRender)
				removeEventHandler("onClientClick", root, onClick)
				removeEventHandler("onClientKey", root, onKey)
			end
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

function onRender()
	if not panelState == "opened" then
		return
	end

	local nowTick = getTickCount();
	local elapsedTime = nowTick - openTick
	local duration = elapsedTime / 1500
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
	dxDrawRectangle(startX, startY, sizeX, 25, tocolor(65, 65, 65, a))
	dxDrawText("#E18C88alpha#c8c8c8Games - Teleport", startX + 5, startY + 25 / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "left", "center", false, false, false, true)

	for x, v in pairs(teleportPositions) do 
		if x <= maxContainersOnScreen and x > scrollValue then
			dxDrawRectangle(startX + 10, startY + 35 + ((x - 1 - scrollValue) * 35), sizeX - 20, 30, tocolor(65, 65, 65, a))

			if isMouseInPosition(startX + 10, startY + 35 + ((x - 1 - scrollValue) * 35), sizeX - 20, 30) then
				dxDrawRectangle(startX + 10 + 1, startY + 35 + ((x - 1 - scrollValue) * 35) + 1, sizeX - 20 - 2, 30 - 2, tocolor(65, 65, 65, a))
				dxDrawText("500$", startX + sizeX - 20 - 10, startY + 35 + ((x - 1 - scrollValue) * 35) + 30 / 2, _, _, tocolor(140, 195, 230, a), 1, poppinsBold, "right", "center")
			else
				dxDrawRectangle(startX + 10 + 1, startY + 35 + ((x - 1 - scrollValue) * 35) + 1, sizeX - 20 - 2, 30 - 2, tocolor(35, 35, 35, a))
				dxDrawText("Teleportálás", startX + sizeX - 20 - 10, startY + 35 + ((x - 1 - scrollValue) * 35) + 30 / 2, _, _, tocolor(125, 125, 125, a), 1, poppinsBold, "right", "center")
			end

			dxDrawImage(startX + 20, startY + 35 + ((x - 1 - scrollValue) * 35) + 6, 16, 16, "files/icons/point.png", 0, 0, 0, tocolor(225, 140, 135, a/2))
			dxDrawText(v[1], startX + 45, startY + 35 + ((x - 1 - scrollValue) * 35) + 30 / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsRegular, "left", "center")
		end
	end
end

function onClick(button, state)
	if not panelState == "opened" then
		return
	end


	if button == "left" and state == "down" then	
		for x, v in pairs(teleportPositions) do 
			if x <= maxContainersOnScreen and x > scrollValue then
				if isMouseInPosition(startX + 10, startY + 35 + ((x - 1 - scrollValue) * 35), sizeX - 20, 30) then
					if isTimer(spamTimer) then
						exports.a_interface:makeNotification(2, "Ilyen gyorsan nem tudod használni a funkciót.")
						return
					end
					
					triggerServerEvent("teleportPlayer", localPlayer, localPlayer, {v[2], v[3], v[4]})
					outputChatBox("#E18C88[Teleport]: #FFFFFFSikeresen elteleportáltált a kiválasztott lokációhoz. #8FC3E4(" .. v[1] .. ")", 255, 255, 255, true)
					spamTimer = setTimer(function() end, 10000, 1)
				end
			end
		end
	end
end

function onKey(key, state)
	if key == "mouse_wheel_up" then
		if scrollValue > 0  then
			scrollValue = scrollValue - 1
			maxContainersOnScreen = maxContainersOnScreen - 1
		end
	elseif key == "mouse_wheel_down" then
		if maxContainersOnScreen < (#teleportPositions) then
			scrollValue = scrollValue + 1
			maxContainersOnScreen = maxContainersOnScreen + 1
		end
	end
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