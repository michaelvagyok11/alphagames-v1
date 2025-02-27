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

local sizeX, sizeY = respc(800), respc(400); 
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(10), false, "cleartype")
local poppinsSmall2 = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(12), false, "cleartype")

local helpdeskResources = {
	["Alapvető információk"] = {
		"> Hivatalos Discord szerver: dc.alphatdma.com \n\n> Hivatalos weboldal: alphatdma.com \n\n> Miért válassz minket? \nAz alphaGames szerverén elérhető minden, ami a szórakozáshoz és a kikapcsolódáshoz kell."
	},

	["Gamemode leírás (TDMA)"] = {
		"asdasdasd"
	},

	["Gamemode leírás (DRIFT)"] = {
		"asdasdasdasdas"
	},

	["Gamemode leírás (PURSUIT)"] = {
		"asdddddddddddddd"
	},
}

local currentSelected = "Alapvető információk"
local panelOpened = false

function onKey(key, state)
	if key == "F1" and state then
		if not getElementData(localPlayer, "loggedIn") then
			return
		end
		if panelOpened then
			removeEventHandler("onClientRender", root, onRender)
			removeEventHandler("onClientClick", root, onClick)
			panelOpened = false
		else
			openTick = getTickCount()
			addEventHandler("onClientRender", root, onRender)
			addEventHandler("onClientClick", root, onClick)
			panelOpened = true
		end
	end
end
addEventHandler("onClientKey", root, onKey)


function onRender()
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end
	
	local nowTick = getTickCount();
	local elapsedTime = nowTick - openTick
	local duration = elapsedTime / 750
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY + respc(25), tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY + respc(25) - 2, tocolor(35, 35, 35, a))
	dxDrawRectangle(startX, startY, sizeX, respc(25), tocolor(65, 65, 65, a))
	dxDrawText("#E18C88alpha#c8c8c8Games - Helpdesk", startX + respc(5), startY + respc(26) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "left", "center", false, false, false, true)

	if isMouseInPosition(startX + sizeX - respc(15), startY, respc(15), respc(25)) then
		dxDrawText("#E18C88X", startX + sizeX - respc(5), startY + respc(26) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "right", "center", false, false, false, true)
	else
		dxDrawText("#c8c8c8X", startX + sizeX - respc(5), startY + respc(26) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "right", "center", false, false, false, true)
	end
	
	-- ** NAVBAR

	dxDrawRectangle(startX + respc(10), startY + respc(35), sizeX / 4, sizeY - respc(20), tocolor(40, 40, 40, a))

	loopNum = 0
	for i, v in pairs(helpdeskResources) do 
		dxDrawRectangle(startX + respc(15), startY + respc(37) + (loopNum * respc(35)), sizeX / 4 - respc(10), respc(30), tocolor(65, 65, 65, a))
		if isMouseInPosition(startX + respc(15), startY + respc(37) + (loopNum * respc(35)), sizeX / 4 - respc(10), respc(30)) or currentSelected == i then
			dxDrawRectangle(startX + respc(15) + 1, startY + respc(37) + (loopNum * respc(35)) + 1, sizeX / 4 - respc(10) - 2, respc(30) - 2, tocolor(65, 65, 65, a))
			dxDrawText(i, startX + respc(20), startY + respc(37) + (loopNum * respc(35)) + 36 / 2, _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "center", false, false, false, true)
		else
			dxDrawRectangle(startX + respc(15) + 1, startY + respc(37) + (loopNum * respc(35)) + 1, sizeX / 4 - respc(10) - 2, respc(30) - 2, tocolor(35, 35, 35, a))
			dxDrawText(i, startX + respc(20), startY + respc(37) + (loopNum * respc(35)) + respc(31) / 2, _, _, tocolor(100, 100, 100, a), 1, poppinsSmall, "left", "center", false, false, false, true)
		end
		loopNum = loopNum + 1
	end

	-- ** TEXT
	dxDrawRectangle(startX + respc(10) + sizeX / 4 + respc(10), startY + respc(35), sizeX - sizeX / 4 - respc(30), sizeY - respc(20), tocolor(50, 50, 50, a))

	dxDrawText(helpdeskResources[currentSelected][1], startX + sizeX / 4 + respc(30), startY + respc(45), startX + sizeX / 4 + respc(30) + sizeX - sizeX / 4 - respc(30), startY + respc(45) + sizeY - respc(20), tocolor(200, 200, 200, a), 1, poppinsSmall2, "left", "top", false, true)
end

function onClick(button, state)
	if button == "left" and state == "down" then
		if isMouseInPosition(startX + sizeX - respc(15), startY, respc(15), respc(25)) then
			removeEventHandler("onClientRender", root, onRender)
			removeEventHandler("onClientClick", root, onClick)
		end
		loopNum = 0
		for i, v in pairs(helpdeskResources) do 
			if isMouseInPosition(startX + respc(15), startY + respc(37) + (loopNum * respc(35)), sizeX / 4 - respc(10), respc(30)) then
				currentSelected = i
			end
			loopNum = loopNum + 1
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