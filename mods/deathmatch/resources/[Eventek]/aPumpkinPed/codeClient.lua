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

function getResponsiveMultipler()
	return responsiveMultipler
end

local sizeX, sizeY = respc(400), respc(150); 
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
local panelOpened = false;

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(10), false, "cleartype")
local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(15), false, "cleartype")
local poppinsLightBig = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(15), false, "cleartype")
local poppinsLighSmall = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(11), false, "cleartype")

local eventPedLastUse = 0

function togglePanel()
	if panelOpened then
		panelOpened = false
		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientClick", root, onClick)
	else
		panelOpened = true
		openTick = getTickCount()
		addEventHandler("onClientRender", root, onRender)
		addEventHandler("onClientClick", root, onClick)
	end
end
--addEventHandler("onClientResourceStart", resourceRoot, togglePanel)

function onRender()
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end

	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	if getDistanceBetweenPoints3D(playerX, playerY, playerZ, pedX, pedY, pedZ) > 5 then
		removeEventHandler("onClientRender", root, onRender)
		panelOpened = false
		return
	end

	local nowTick = getTickCount();
	local elapsedTime = nowTick - openTick;
	local duration = elapsedTime / 500;
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
	--dxDrawRectangle(startX, startY, sizeX, respc(20), tocolor(65, 65, 65, a))
	if isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
		dxDrawText("#E18C88X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "right", "center", false, false, false, true)
	else
		dxDrawText("#c8c8c8X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "right", "center", false, false, false, true)
	end

	rotation = interpolateBetween(-5, 0, 0, 5, 0, 0, nowTick / 5000, "SineCurve")

	dxDrawImage(startX + sizeX / 2 - respc(32), startY - respc(0) + respc(12), respc(64), respc(64), "files/img/pumpkin.png", rotation, 0, 0, tocolor(255, 255, 255, a))
	dxDrawText("alpha", startX + sizeX / 2 - respc(42), startY - respc(0) + respc(32), _, _, tocolor(242, 117, 3, a), 1, poppinsBoldBig, "right", "center")
	dxDrawText("Games", startX + sizeX / 2 - respc(42), startY - respc(0) + respc(46), _, _, tocolor(200, 200, 200, a), 1, poppinsLightBig, "right", "center")

	dxDrawText("Halloween", startX + sizeX / 2 + respc(42), startY - respc(0) + respc(32), _, _, tocolor(242, 117, 3, a), 1, poppinsBoldBig, "left", "center")
	dxDrawText("Event", startX + sizeX / 2 + respc(42), startY - respc(0) + respc(46), _, _, tocolor(200, 200, 200, a), 1, poppinsLightBig, "left", "center")

	if isMouseInPosition(startX + respc(50), startY + sizeY - respc(65), sizeX - respc(100), respc(25)) then
		dxDrawRectangle(startX + respc(50), startY + sizeY - respc(65), sizeX - respc(100), respc(25), tocolor(242, 117, 3, a * 0.75))
	else
		dxDrawRectangle(startX + respc(50), startY + sizeY - respc(65), sizeX - respc(100), respc(25), tocolor(242, 117, 3, a * 0.5))
	end
	dxDrawText("Jutalom begyűjtése", startX + respc(50) + (sizeX - respc(100))/2, startY + sizeY - respc(65) + respc(26)/2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "center", "center")

	dxDrawText("Kellemes Halloweent kíván az alphaGames csapata!", startX + sizeX / 2, startY + sizeY - respc(15), _, _, tocolor(150, 150, 150, a), 1, poppinsLighSmall, "center", "center")
end

function onClick(button, state, x, y, x2, y2, z2, clickedElement)
	if button == "left" and state == "down" then
		if panelOpened then
			if isMouseInPosition(startX + respc(50), startY + sizeY - respc(65), sizeX - respc(100), respc(25)) then
				triggerServerEvent("YwmfZJeKGlhBea6P1zXS$$$$$$", localPlayer, localPlayer)
				panelOpened = false
				removeEventHandler("onClientRender", root, onRender)
			end

			if isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
				removeEventHandler("onClientRender", root, onRender)
				panelOpened = false
			end
		end
	end

	if button == "right" and state == "down" and not panelOpened then
		if getElementType(clickedElement) == "ped" and getElementData(clickedElement, "a.EasterEventPed") then
			panelOpened = true
			openTick = getTickCount()
			addEventHandler("onClientRender", root, onRender)
		end
	end
end
addEventHandler("onClientClick", root, onClick)

function sendDataToClient(source, type)
	if source and isElement(source) and source == localPlayer and type then
		if type == "success" then
			exports.a_interface:makeNotification(1, "Sikeresen begyűjtötted a halloween-i ajándékodat. Leghamarabb 12 óra múlva tudsz újra ajándékot kérni.")
			removeEventHandler("onClientRender", root, onRender)
			panelOpened = false
			triggerServerEvent("SuwyG68DruYPD93B84YE$$$$$$", localPlayer, localPlayer)
		elseif type == "declined" then
			exports.a_interface:makeNotification(2, "Gyűjtöttél már be ajándékot az elmúlt 12 órában, gyere vissza később.")
		end
	end
end
addEvent("sendDataToClient", true)
addEventHandler("sendDataToClient", root, sendDataToClient)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end