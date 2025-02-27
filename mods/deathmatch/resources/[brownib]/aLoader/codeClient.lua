local sX, sY = guiGetScreenSize();
local lineW, lineH = sX / 4, 10;

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 20, false, "cleartype")
local poppinsSmall2 = dxCreateFont("files/fonts/Poppins-Regular.ttf", 14, false, "cleartype")

function createLoader(element, time)
	if element and isElement(element) and time then
		if not (localPlayer == element) then
			return
		end
		addEventHandler("onClientRender", root, onRender)
		startTick = getTickCount()

		loadingTime = tonumber(time)

		showChat(false)

		setTimer(function()
			changeTick = getTickCount()
		end, loadingTime*1000, 1)
	end
end
addEvent("createLoader", true)
addEventHandler("createLoader", root, createLoader)

function onRender()
	local nowTick = getTickCount();
	local elapsedTime = nowTick - startTick;
	local duration = elapsedTime / 100
	
	if startTick + (loadingTime * 1000) < nowTick then
		a = interpolateBetween(a, 0, 0, 0, 0, 0, (nowTick - changeTick) / 1500, "Linear")
	else
		a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")
	end

	if (startTick + (loadingTime * 1000) + 500) < nowTick then
		removeEventHandler("onClientRender", root, onRender)
		showChat(true)
	end

	line = interpolateBetween(0, 0, 0, lineW, 0, 0, elapsedTime / (loadingTime * 1000), "Linear")	
	progress = interpolateBetween(0, 0, 0, 100, 0, 0, elapsedTime / (loadingTime * 1000), "Linear")	

	dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2, a))
	
	dxDrawImage(0, 0, sX, sY, ":aAccount/files/img/bg.jpg", 0, 0, 0, tocolor(255, 255, 255, a))

	dxDrawImage(sX / 2 - 64, sY / 2 - 64, 128, 128, "files/img/logo.png", 0, 0, 0, tocolor(150, 150, 150, a))

	dxDrawText("Betöltés, kérlek várj!", sX / 2, sY / 2 + 75, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "center", "center", false, false)

	dxDrawRectangle(sX / 2 - lineW / 2, sY / 2 + 100, lineW, lineH, tocolor(65, 65, 65, a))
	dxDrawRectangle(sX / 2 - lineW / 2 + 1, sY / 2 + 100 + 1, line - 2, lineH - 2, tocolor(225, 140, 135, a/2))
	dxDrawText(math.floor(progress) .. "%", sX / 2, sY / 2 + 125, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall2, "center", "center", false, false)
end

function onChange(key, oVal, nVal)
	if source ~= localPlayer then
		return
	end
	if key == "loggedIn" then
		if nVal == true then
			--createLoader(5)
		end
	end

	if key == "a.Gamemode" then
		if nVal == nil or nVal == 2 or nVal == 3 then
			createLoader(localPlayer, 3)
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

setTimer(function()
	createLoader(localPlayer, 5)
end, 500, 1)