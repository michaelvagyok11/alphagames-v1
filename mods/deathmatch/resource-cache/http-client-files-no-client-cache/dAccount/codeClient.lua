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

local barlowBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(28), false, "cleartype")
local barlowBoldRegular = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(10), false, "cleartype")
local barlowRegularBig = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(38), false, "cleartype")
local barlowRegularRegular = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(10), false, "cleartype")

local barlowLight15 = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(25), false, "cleartype")
local barlowBold20 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(25), false, "cleartype")

local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
sm.timer1,sm.timer2,sm.timer3 = nil,nil,nil
 
local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end
 
local function camRender()
	if (sm.moov == 1) then
		local x1,y1,z1 = getElementPosition(sm.object1)
		local x2,y2,z2 = getElementPosition(sm.object2)
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	end
end
addEventHandler("onClientPreRender",root,camRender)
 
function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then return false end
	sm.object1 = createObject(1337,x1,y1,z1)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"Linear")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"Linear")
	sm.moov = 1
	sm.timer1 = setTimer(removeCamHandler,time,1)
	sm.timer2 = setTimer(destroyElement,time,1,sm.object1)
	sm.timer3 = setTimer(destroyElement,time,1,sm.object2)
	return true
end

function stopSmoothMoveCamera()
	if isTimer( sm.timer1 ) then killTimer( sm.timer1 ) end
	if isTimer( sm.timer2 ) then killTimer( sm.timer2 ) end
	if isTimer( sm.timer3 ) then killTimer( sm.timer3 ) end
	if isElement( sm.object1 ) then destroyElement( sm.object1 ) end
	if isElement( sm.object2 ) then destroyElement( sm.object2 ) end
	removeCamHandler()
end

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

function onStart()
	if getElementData(localPlayer, "loggedIn") then
		return
	end
	local components = { "weapon", "ammo", "health", "clock", "money", "breath", "armour", "wanted", "radar" }
	for _, component in ipairs( components ) do
		setPlayerHudComponentVisible( component, false )
	end

	currentPage = "login"

	fadeCamera(true)
	smoothMoveCamera(642.705078125, -611.326171875, 32.043209075928, 619.3154296875, -574.1455078125, 17.50061416626, 651.0009765625, -522.55859375, 32.043209075928, 619.3154296875, -574.1455078125, 17.50061416626, 80000)
	
	showChat(false)
	showCursor(true)
	addEventHandler("onClientRender", root, onRender)
	addEventHandler("onClientClick", root, onClick)
	startTick = getTickCount()

	--loginMusic = playSound("files/sounds/loginmusic.mp3")
	--setSoundVolume(loginmusic, 0.5)

	sizeX, sizeY = respc(400), respc(200);
	startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

	exports.dDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + respc(10), startY + respc(15), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 1)
	exports.dDx:dxCreateEdit("a.Password", "", "Jelszó", startX + respc(10), startY + respc(55), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 2)

	loadLoginFiles()
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop()
	exports.dDx:dxDestroyEdit("a.Username")
	exports.dDx:dxDestroyEdit("a.Password")
	exports.dDx:dxDestroyEdit("a.Password2")
	exports.dDx:dxDestroyEdit("a.PlayerName")
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)

local sx2, sy2 = guiGetScreenSize();
local bx, by = sX, sY
local boxes = 200;
local startColor, endColor = {20, 20, 20}, {140, 195, 230}

function onRender()
	local nowTick = getTickCount()
	local elapsedTime = nowTick - startTick
	local duration = elapsedTime / 500
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")
	dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2, a*0.85))

	dxDrawImage(sX / 2 - respc(164)/2, respc(175), respc(164), respc(164), "files/img/logo.png", 0, 0, 0, tocolor(255, 255, 255, a))
	dxDrawText("alpha", sX / 2 - respc(8), sY / 2 - respc(120), _, _, tocolor(255, 255, 255, a), 1, barlowBold20, "right", "center", false, false, false, true)
	dxDrawText("GAMES", sX / 2 - respc(6), sY / 2 - respc(120), _, _, tocolor(255, 255, 255, a), 1, barlowLight15, "left", "center", false, false, false, true)

	if currentPage == "login" then
		dxDrawRoundedRectangle(startX + respc(20), startY + respc(110), respc(25), respc(25), 3, tocolor(55, 55, 55, a))
		
		if rememberMe or isMouseInPosition(startX + respc(20), startY + respc(110), respc(25), respc(25)) then
			dxDrawImage(startX + respc(20), startY + respc(110), respc(24), respc(24), "files/img/tick.png", 0, 0, 0, tocolor(155, 230, 140, a*0.5))
		end
		dxDrawText("Jegyezzen meg?", startX + respc(50), startY + respc(122.5), _, _, tocolor(200, 200, 200, a), 1, barlowRegularRegular, "left", "center")

		if isMouseInPosition(startX + respc(50), startY + respc(145), sizeX - respc(100), respc(35)) then
			dxDrawRoundedRectangle(startX + respc(50), startY + respc(145), sizeX - respc(100), respc(35), 3, tocolor(155, 230, 140, a*0.6))
			dxDrawText("BEJELENTKEZÉS", startX + respc(50) + (sizeX - respc(100))/2, startY + respc(145) + (respc(35))/2, _, _, tocolor(255, 255, 255, a), 1, barlowBoldRegular, "center", "center")	
		else
			dxDrawRoundedRectangle(startX + respc(50), startY + respc(145), sizeX - respc(100), respc(35), 3, tocolor(155, 230, 140, a*0.4))
			dxDrawText("BEJELENTKEZÉS", startX + respc(50) + (sizeX - respc(100))/2, startY + respc(145) + (respc(35))/2, _, _, tocolor(200, 200, 200, a), 1, barlowBoldRegular, "center", "center")	
		end

		if isMouseInPosition(startX + respc(50), startY + respc(185), sizeX - respc(100), respc(35)) then
			dxDrawRoundedRectangle(startX + respc(50), startY + respc(185), sizeX - respc(100), respc(35), 3, tocolor(140, 195, 230, a*0.6))
			dxDrawText("REGISZTRÁCIÓ", startX + respc(50) + (sizeX - respc(100))/2, startY + respc(185) + (respc(35))/2, _, _, tocolor(255, 255, 255, a), 1, barlowBoldRegular, "center", "center")	
		else
			dxDrawRoundedRectangle(startX + respc(50), startY + respc(185), sizeX - respc(100), respc(35), 3, tocolor(140, 195, 230, a*0.4))
			dxDrawText("REGISZTRÁCIÓ", startX + respc(50) + (sizeX - respc(100))/2, startY + respc(185) + (respc(35))/2, _, _, tocolor(200, 200, 200, a), 1, barlowBoldRegular, "center", "center")	
		end
	elseif currentPage == "register" then
		if isMouseInPosition(startX + respc(50), startY + respc(205), sizeX - respc(100), respc(35)) then
			dxDrawRoundedRectangle(startX + respc(50), startY + respc(205), sizeX - respc(100), respc(35), 3, tocolor(140, 195, 230, a*0.6))
			dxDrawText("REGISZTRÁCIÓ", startX + respc(50) + (sizeX - respc(100))/2, startY + respc(205) + (respc(35))/2, _, _, tocolor(255, 255, 255, a), 1, barlowBoldRegular, "center", "center")	
		else
			dxDrawRoundedRectangle(startX + respc(50), startY + respc(205), sizeX - respc(100), respc(35), 3, tocolor(140, 195, 230, a*0.4))
			dxDrawText("REGISZTRÁCIÓ", startX + respc(50) + (sizeX - respc(100))/2, startY + respc(205) + (respc(35))/2, _, _, tocolor(200, 200, 200, a), 1, barlowBoldRegular, "center", "center")	
		end

		if isMouseInPosition(startX + respc(50), startY + respc(245), sizeX - respc(100), respc(35)) then
			dxDrawRoundedRectangle(startX + respc(50), startY + respc(245), sizeX - respc(100), respc(35), 3, tocolor(230, 140, 140, a*0.6))
			dxDrawText("VISSZALÉPÉS", startX + respc(50) + (sizeX - respc(100))/2, startY + respc(245) + (respc(35))/2, _, _, tocolor(255, 255, 255, a), 1, barlowBoldRegular, "center", "center")	
		else
			dxDrawRoundedRectangle(startX + respc(50), startY + respc(245), sizeX - respc(100), respc(35), 3, tocolor(230, 140, 140, a*0.4))
			dxDrawText("VISSZALÉPÉS", startX + respc(50) + (sizeX - respc(100))/2, startY + respc(245) + (respc(35))/2, _, _, tocolor(200, 200, 200, a), 1, barlowBoldRegular, "center", "center")	
		end
	end
end

function onClick(button, state)
	if button == "left" and state == "down" then
		if currentPage == "login" then
			if isMouseInPosition(startX + respc(50), startY + respc(185), sizeX - respc(100), respc(35)) then
				currentPage = "register"

				exports.dDx:dxDestroyEdit("a.Username")
				exports.dDx:dxDestroyEdit("a.Password")
				exports.dDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + respc(10), startY + respc(5), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 1)
				exports.dDx:dxCreateEdit("a.Password", "", "Jelszó", startX + respc(10), startY + respc(55), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 2)
				exports.dDx:dxCreateEdit("a.Password2", "", "Jelszó újra", startX + respc(10), startY + respc(105), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 2)
				exports.dDx:dxCreateEdit("a.PlayerName", "", "Játékosnév", startX + respc(10), startY + respc(155), sizeX - respc(20), respc(40), {125, 125, 125}, 35, 1)
			end

			if isMouseInPosition(startX + respc(50), startY + respc(145), sizeX - respc(100), respc(35)) then
				local username = exports.dDx:dxGetEditText("a.Username")
				local password = exports.dDx:dxGetEditText("a.Password")
				if not username or not password then
					-- notification here
					return
				end
				triggerServerEvent("a.RequestAction", localPlayer, localPlayer, "login", username, password)
			end

			if isMouseInPosition(startX + respc(20), startY + respc(110), respc(25), respc(25)) then
				rememberMe = not rememberMe
			end
		elseif currentPage == "register" then
			if isMouseInPosition(startX + respc(50), startY + respc(245), sizeX - respc(100), respc(35)) then
				exports.dDx:dxDestroyEdit("a.Username")
				exports.dDx:dxDestroyEdit("a.Password")
				exports.dDx:dxDestroyEdit("a.Password2")
				exports.dDx:dxDestroyEdit("a.PlayerName")
				
				currentPage = "login"
				
				exports.dDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + respc(10), startY + respc(5), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 1)
				exports.dDx:dxCreateEdit("a.Password", "", "Jelszó", startX + respc(10), startY + respc(55), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 2)
			end

			if isMouseInPosition(startX + respc(50), startY + respc(205), sizeX - respc(100), respc(35)) then
				local username = exports.dDx:dxGetEditText("a.Username")
				local password = exports.dDx:dxGetEditText("a.Password")
				local password2 = exports.dDx:dxGetEditText("a.Password2")
				local email = exports.dDx:dxGetEditText("a.PlayerName")
				if not username or not password or not password2 or not email then
					exports.dInfobox:makeNotification(2, "A regisztráció véglegesítéséhez minden adatot ki kell töltened.")
					return
				end

				if string.len(username) < 5 then
					exports.dInfobox:makeNotification(2, "A megadott felhasználónév túl rövid. (Min. 5 karakter)")
				else
					if string.len(password) < 6 then
						exports.dInfobox:makeNotification(2, "A megadott jelszó túl rövid. (Min. 5 karakter)")
					else
						if string.len(password2) < 6 then
							exports.dInfobox:makeNotification(2, "A megismételt jelszó túl rövid. (Min. 5 karakter)")
						else
							if not (tostring(password) == tostring(password2)) then
								exports.dInfobox:makeNotification(2, "A két jelszó nem egyezik.")
							else
								triggerServerEvent("attemptRegister", localPlayer, localPlayer, {tostring(username), tostring(password), tostring(email)})
							end
						end
					end
				end
			end
		end
	end
end

function serverResponse(element, type)
	if not (element == localPlayer) then
		return
	end
	if type == "loginError" then
		exports.dInfobox:makeNotification(2, "Hibás adatok lettek megadva.")
	elseif type == "loginSuccess" then
		exports.dLoader:createLoader(5)
		triggerServerEvent("a.LoginSuccess", localPlayer, localPlayer)

		local username, password = exports.dDx:dxGetEditText("a.Username"), exports.dDx:dxGetEditText("a.Password")

		if rememberMe then
			saveLoginFiles(username, password, 1)
		else
			saveLoginFiles("", "", 0)
		end


		--showChat(true)
		showCursor(false)
		--fadeCamera(true)
		--setCameraTarget(localPlayer, localPlayer)
		stopSmoothMoveCamera()
		exports.dDx:dxDestroyEdit("a.Username")
		exports.dDx:dxDestroyEdit("a.Password")
		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientClick", root, onClick)
		exports.dItems:loadActionBarItems()
		--destroyElement(loginMusic)
	elseif type == "registerError.usernameExists" then
		exports.dInfobox:makeNotification(2, "Ez a felhasználónév már regisztrálva van az adatbázisban.")
	elseif type == "registerError.serialExists" then
		exports.dInfobox:makeNotification(2, "Ehhez a serialhoz már van account társítva.")
	elseif type == "registerError.playerNameExists" then
		exports.dInfobox:makeNotification(2, "Ez a játékosnév már használatban van.")
	elseif type == "registerSuccess" then
		exports.dInfobox:makeNotification(1, "Sikeresen létrehoztad a felhasználódat, mostmár bejelentkezhetsz.")
		exports.dDx:dxDestroyEdit("a.Username")
		exports.dDx:dxDestroyEdit("a.Password")
		exports.dDx:dxDestroyEdit("a.Password2")
		exports.dDx:dxDestroyEdit("a.PlayerName")

		currentPage = "login"
		
		exports.dDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + respc(10), startY + respc(5), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 1)
		exports.dDx:dxCreateEdit("a.Password", "", "Jelszó", startX + respc(10), startY + respc(55), sizeX - respc(20), respc(40), {125, 125, 125}, 20, 2)
	end
end
addEvent("a.ServerResponse", true)
addEventHandler("a.ServerResponse", root, serverResponse)


function saveLoginFiles(username, password, remember)
	if fileExists("@alphaGLoginData.xml") then
		fileDelete("@alphaGLoginData.xml")
	end
	
	local loginRememberFile = xmlCreateFile("@alphaGLoginData.xml", "logindata")
	
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "username"), username)
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "password"), password)
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "remember"), remember)
	
	xmlSaveFile(loginRememberFile)
	xmlUnloadFile(loginRememberFile)
end

function loadLoginFiles()
	local loginRememberFile = xmlLoadFile("@alphaGLoginData.xml")
	
	if loginRememberFile then
		rememberedUsername = xmlNodeGetValue(xmlFindChild(loginRememberFile, "username", 0))
		rememberedPassword = xmlNodeGetValue(xmlFindChild(loginRememberFile, "password", 0))
		
		exports.dDx:dxEditSetText("a.Username", rememberedUsername)
		exports.dDx:dxEditSetText("a.Password", rememberedPassword)
		local rememberValue = xmlNodeGetValue(xmlFindChild(loginRememberFile, "remember", 0))
		if tonumber(rememberValue) and tonumber(rememberValue) == 1 then
			rememberMe = true
		else
			rememberMe = false
		end
		
		xmlUnloadFile(loginRememberFile)
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