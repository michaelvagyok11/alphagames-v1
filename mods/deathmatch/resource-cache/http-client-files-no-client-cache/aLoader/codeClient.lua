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

local barlowRegular15 = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(15), false, "cleartype")

function createLoader(element, time)
	if element and isElement(element) and time then
		if not (localPlayer == element) then
			return
		end
		addEventHandler("onClientRender", root, onRender)
		startTick = getTickCount()

		loadingTime = tonumber(time)

		showChat(false)
		setElementData(localPlayer, "a.HUDshowed", false)

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
	local duration = elapsedTime / 500
	
	if startTick + (loadingTime * 1000) < nowTick then
		a = interpolateBetween(a, 0, 0, 0, 0, 0, (nowTick - changeTick) / 1500, "Linear")
	else
		a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")
	end

	if (startTick + (loadingTime * 1000) + 500) < nowTick then
		removeEventHandler("onClientRender", root, onRender)
		showChat(true)
		setElementData(localPlayer, "a.HUDshowed", true)
	end

	line = interpolateBetween(0, 0, 0, lineW, 0, 0, elapsedTime / (loadingTime * 1000), "Linear")	
	progress = interpolateBetween(0, 0, 0, 100, 0, 0, elapsedTime / (loadingTime * 1000), "Linear")	

	dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2, a))
	
	dxDrawImage(sX / 2 - respc(72), sY / 2, respc(290)/2, respc(128)/2, "files/img/sign.png", 0, 0, 0, tocolor(255, 255, 255, a))

	dxDrawImage(sX / 2 - respc(64), sY / 2 - respc(128), respc(128), respc(128), "files/img/logo.png", 0, 0, 0, tocolor(200, 200, 200, a))
	dxDrawText("Betöltés folyamatban... " .. math.floor(progress) .. "%", sX / 2, sY - respc(50), _, _, tocolor(200, 200, 200, a), 1, barlowRegular15, "center", "center")
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
			createLoader(3)
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

setTimer(function()
	createLoader(localPlayer, 5)
end, 500, 1)