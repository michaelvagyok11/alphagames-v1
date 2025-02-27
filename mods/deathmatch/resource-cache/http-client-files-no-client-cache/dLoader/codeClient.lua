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

local barlowLight15 = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(25), false, "cleartype")
local barlowRegular15 = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(12), false, "cleartype")
local barlowBold20 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(25), false, "cleartype")

function createLoader(element, time)
	if element and isElement(element) and time then
		if not getPlayerSerial(localPlayer) == "53987DDB582C0AC8B9CCD506656ACD13" then
			return
		end
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
	local duration = elapsedTime / 100
	
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

	local lineWidth = sX / 4
	line = interpolateBetween(0, 0, 0, lineWidth, 0, 0, elapsedTime / (loadingTime * 1000), "Linear")	
	progress = interpolateBetween(0, 0, 0, 100, 0, 0, elapsedTime / (loadingTime * 1000), "Linear")	


	dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2, 255))
	dxDrawRectangle(sX / 2 - lineWidth / 2, sY / 2 + respc(90), lineWidth, respc(30), tocolor(20, 20, 20, a*0.75))	
	dxDrawRectangle(sX / 2 - lineWidth / 2, sY / 2 + respc(90), line, respc(30), tocolor(35, 35, 35, a*0.75))	

	--dxDrawImage(sX / 2 - respc(72), sY / 2, respc(290)/2, respc(128)/2, "files/img/sign.png", 0, 0, 0, tocolor(255, 255, 255, a))
	dxDrawText("alpha", sX / 2 - respc(8), sY / 2 + respc(15), _, _, tocolor(255, 255, 255, a), 1, barlowBold20, "right", "center", false, false, false, true)
	dxDrawText("GAMES", sX / 2 - respc(6), sY / 2 + respc(15), _, _, tocolor(255, 255, 255, a), 1, barlowLight15, "left", "center", false, false, false, true)

	dxDrawImage(sX / 2 - respc(64), sY / 2 - respc(128), respc(128), respc(128), "files/img/logo.png", 0, 0, 0, tocolor(255, 255, 255, a))

	dxDrawText("Betöltés folyamatban...", sX / 2, sY / 2 + respc(75), _, _, tocolor(200, 200, 200, a), 1, barlowRegular15, "center", "center")
	dxDrawText(math.floor(progress) .. "%", sX / 2, sY / 2 + respc(90) + respc(30)/2, _, _, tocolor(150, 150, 150, a), 1, barlowRegular15, "center", "center")
end

function onChange(key, oVal, nVal)
	if source ~= localPlayer then
		return
	end
	if key == "loggedIn" then
		if nVal == true then
			createLoader(source, 5)
		end
	end

	if key == "a.Gamemode" then
		if nVal == nil or nVal == 2 or nVal == 3 then
			createLoader(source, 3)
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

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