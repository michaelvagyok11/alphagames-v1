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

local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(15), false, "cleartype")
local poppinsBoldBig2 = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(12), false, "cleartype")
local poppinsLightBig = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(14), false, "cleartype")
local poppinsRegular = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(13), false, "cleartype")

local sizeX, sizeY = respc(600), respc(320)
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2

function onChange(key, oVal, nVal)
	if key == "loggedIn" then
		if nVal == true then
			triggerServerEvent("checkForPlayerName", localPlayer, localPlayer)
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

function playerNameResponse(element, responseType)
	if element and isElement(element) and element == localPlayer then
		if not (responseType) then
			setTimer(function()
				openTick = getTickCount()
				addEventHandler("onClientRender", root, onRender_WelcomePanel)
				addEventHandler("onClientClick", root, onClick_WelcomePanel)		
				
				setElementFrozen(localPlayer, true)
				setElementData(localPlayer, "a.HUDshowed", false)
				showChat(false)
				showCursor(true)
				rememberData = false
		
				exports.aDx:dxDestroyEdit("a.NewPassword")
				exports.aDx:dxDestroyEdit("a.PlayerName")
				exports.aDx:dxCreateEdit("a.NewPassword", "", "Új jelszó", startX + respc(50), startY + sizeY / 2 - respc(5), sizeX - respc(100), respc(30), {255, 255, 255}, 20, 2)
				exports.aDx:dxCreateEdit("a.PlayerName", "", "Megjelenített név", startX + respc(50), startY + sizeY / 2 + respc(75), sizeX - respc(100), respc(30), {255, 255, 255}, 20, 1)
			end, 5000, 1)
		end
	end
end
addEvent("playerNameResponse", true)
addEventHandler("playerNameResponse", root, playerNameResponse)

function saveResponse(element)
	if element and isElement(element) and element == localPlayer then
		exports.aInfobox:makeNotification(2, "A név már használatban van, amit megadtál.")
	end
end
addEvent("saveResponse", true)
addEventHandler("saveResponse", root, saveResponse)

function onRender_WelcomePanel()
	local nowTick = getTickCount();
	local elapsedTime = nowTick - openTick;
	a = interpolateBetween(0, 0, 0, 255, 0, 0, elapsedTime / 500, "Linear")

	dxDrawRectangle(0, 0, sX, sY, tocolor(20, 20, 20, a*0.75))

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(25, 25, 25, a))

	dxDrawText("#E48F8Falpha", startX + respc(2), startY - respc(8.5), _, _, tocolor(255, 255, 255, a), 1, poppinsBoldBig, "left", "center", false, false, false, true)
    dxDrawText("THE NEW BEGINNING", startX + respc(4) + dxGetTextWidth("alpha", 1, poppinsBoldBig), startY - respc(7.5), _, _, tocolor(255, 255, 255, a), 1, poppinsLightBig, "left", "center", false, false, false, true)
	
	--dxDrawText("#E48F8Falpha", startX + sizeX / 2 - respc(1), startY - respc(8.5), _, _, tocolor(255, 255, 255, a), 1, poppinsBoldBig, "right", "center", false, false, false, true)
    --dxDrawText("THE NEW BEGINNING", startX + sizeX / 2, startY - respc(8.5), _, _, tocolor(255, 255, 255, a), 1, poppinsLightBig, "center", "center", false, false, false, true)

	dxDrawText("Szia #8FC3E4" .. getPlayerName(localPlayer) .. "#c8c8c8!", startX + sizeX / 2, startY + respc(20), _, _, tocolor(255, 255, 255, a), 1, poppinsLightBig, "center", "center", false, false, false, true)
	dxDrawText(
		"Szeretnénk megerősíteni az adatbázisunkat, mivel a közelmúltban több olyan dolog is történt, amit nem szerettünk volna hogy megtörténjen.\nEzért kérnénk, hogy írj be egy új jelszót, valamint egy nevet, amit ezentúl szeretnél használni a szerveren.",
		 startX + respc(10), startY + respc(45), startX + respc(10) + sizeX - respc(20), startY + respc(45) + sizeY - respc(90), tocolor(255, 255, 255, a), 1, poppinsRegular, "center", "top", false, true, false)

	dxDrawText("Jegyezze meg az account rendszer?", startX + respc(50), startY + sizeY / 2 + respc(45), _, _, tocolor(255, 255, 255, a), 1, poppinsLightBig, "left", "center", false, false, false, true)
	
	if isMouseInPosition(startX + respc(50) + sizeX - respc(120), startY + sizeY / 2 + respc(35), respc(20), respc(20)) then
		dxDrawRectangle(startX + respc(50) + sizeX - respc(120), startY + sizeY / 2 + respc(35), respc(20), respc(20), tocolor(255, 255, 255, a*0.5))
		dxDrawRectangle(startX + respc(50) + sizeX - respc(120) + 1, startY + sizeY / 2 + respc(35) + 1, respc(20) - 2, respc(20) - 2, tocolor(45, 45, 45, a))
		if not rememberData then
			dxDrawImage(startX + respc(50) + sizeX - respc(120) + 3, startY + sizeY / 2 + respc(35) + 3, respc(20) - 6, respc(20) - 6, "files/img/tick.png", 0, 0, 0, tocolor(150, 150, 150, a))
		end
	else
		dxDrawRectangle(startX + respc(50) + sizeX - respc(120), startY + sizeY / 2 + respc(35), respc(20), respc(20), tocolor(45, 45, 45, a))
	end

	if rememberData then
		dxDrawImage(startX + respc(50) + sizeX - respc(120) + 3, startY + sizeY / 2 + respc(35) + 3, respc(20) - 6, respc(20) - 6, "files/img/tick.png", 0, 0, 0, tocolor(55*1.5, 85*1.5, 55*1.5, a))
	end

	dxDrawText("Köszönjük szépen a közreműködést és további jó játékot kívánunk!", startX + sizeX / 2, startY + sizeY - respc(30), _, _, tocolor(255, 255, 255, a), 1, poppinsRegular, "center", "center", false, false, false, true)
	dxDrawText("alpha - Vezetőség", startX + sizeX  - respc(10), startY + sizeY - respc(10), _, _, tocolor(255, 255, 255, a*0.5), 1, poppinsBoldBig2, "right", "center", false, false, false, true)

	if isMouseInPosition(startX + sizeX / 2 - respc(100), startY + sizeY + respc(10), respc(200), respc(30)) then
		dxDrawRectangle(startX + sizeX / 2 - respc(100), startY + sizeY + respc(10), respc(200), respc(30), tocolor(55*1.5, 85*1.5, 55*1.5, a))
	else
		dxDrawRectangle(startX + sizeX / 2 - respc(100), startY + sizeY + respc(10), respc(200), respc(30), tocolor(55, 85, 55, a))
	end
	dxDrawText("Megvan, játszok!", startX + sizeX / 2, startY + sizeY + respc(10) + respc(15) + 1, _, _, tocolor(255, 255, 255, a), 1, poppinsBoldBig, "center", "center", false, false, false, true)
end

function onClick_WelcomePanel(button, state)
	if button == "left" and state == "down" then
		if isMouseInPosition(startX + respc(50) + sizeX - respc(120), startY + sizeY / 2 + respc(35), respc(20), respc(20)) then
			rememberData = not rememberData
		end
		if isMouseInPosition(startX + sizeX / 2 - respc(100), startY + sizeY + respc(10), respc(200), respc(30)) then
			local newPassword = exports.aDx:dxGetEditText("a.NewPassword")
			local playerName = exports.aDx:dxGetEditText("a.PlayerName")
			if not (tostring(newPassword) ~= "") or not (tostring(playerName) ~= "") then
				exports.aInfobox:makeNotification(2, "Nem tudsz továbblépni, amíg nem töltöd ki a kért adatokat.")
				return
			else
				if string.len(newPassword) < 6 then
					exports.aInfobox:makeNotification(2, "A megadott jelszó túl rövid. (Min. 5 karakter)")
					return
				end
				if string.len(playerName) < 4 then
					exports.aInfobox:makeNotification(2, "A megadott név túl rövid. (Min. 3 karakter)")
					return
				end
				
				triggerServerEvent("requestDatabaseSave", localPlayer, localPlayer, {newPassword, playerName})
				exports.aInfobox:makeNotification(1, "Köszönjük, hogy hozzájárultál a szerver biztonságához.")
			end
		end
	end
end

function sendAccountDataToSave(element, data)
	if element and isElement(element) and element == localPlayer and data then
		local username, password, remember= data[1], base64Decode(data[2]), 1
		if fileExists("@alphaGLoginData.xml") then
			fileDelete("@alphaGLoginData.xml")
		end
		
		local loginRememberFile = xmlCreateFile("@alphaGLoginData.xml", "logindata")
		
		xmlNodeSetValue(xmlCreateChild(loginRememberFile, "username"), username)
		xmlNodeSetValue(xmlCreateChild(loginRememberFile, "password"), password)
		xmlNodeSetValue(xmlCreateChild(loginRememberFile, "remember"), remember)
		
		xmlSaveFile(loginRememberFile)
		xmlUnloadFile(loginRememberFile)

		setElementFrozen(localPlayer, false)
		exports.aDx:dxDestroyEdit("a.NewPassword")
		exports.aDx:dxDestroyEdit("a.PlayerName")
		removeEventHandler("onClientRender", root, onRender_WelcomePanel)
		removeEventHandler("onClientClick", root, onClick_WelcomePanel)
		setElementData(localPlayer, "a.HUDshowed", true)
		showChat(true)
	end
end
addEvent("sendAccountDataToSave", true)
addEventHandler("sendAccountDataToSave", root, sendAccountDataToSave)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end