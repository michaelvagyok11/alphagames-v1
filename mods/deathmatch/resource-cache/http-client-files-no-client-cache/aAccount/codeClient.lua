local sX, sY = guiGetScreenSize();
local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 40, false, "cleartype")
local poppinsLightBig = dxCreateFont("files/fonts/Poppins-Light.ttf", 40, false, "cleartype")
local poppinsLightRegular = dxCreateFont("files/fonts/Poppins-Light.ttf", 25, false, "cleartype")
local poppinsRegular = dxCreateFont("files/fonts/Poppins-Regular.ttf", 15, false, "cleartype")

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
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
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
	smoothMoveCamera(2287.1855, -875.00098, 30.139843, 2287.293, -993.75586, 30.139843, 2286.0801, -1520.6875, 30.139843, 2286.1289, -1560.6875, 30.139843, 120000)
	
	showChat(false)
	showCursor(true)
	addEventHandler("onClientRender", root, onRender)
	addEventHandler("onClientClick", root, onClick)
	
	sizeX, sizeY = 400, 200;
	startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

	exports.aDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + 20, startY + 20, sizeX - 40, 30, {125, 125, 125}, 20, 1)
	exports.aDx:dxCreateEdit("a.Password", "", "Jelszó", startX + 20, startY + 70, sizeX - 40, 30, {125, 125, 125}, 20, 2)

	loadLoginFiles()
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop()
	exports.aDx:dxDestroyEdit("a.Username")
	exports.aDx:dxDestroyEdit("a.Password")
	exports.aDx:dxDestroyEdit("a.Password2")
	exports.aDx:dxDestroyEdit("a.Email")
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)

function onRender()
	--dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2), false)
	a1, a2 = interpolateBetween(0, 255, 0, 255, 0, 0, getTickCount()/10000, "SineCurve")	
	
	--dxDrawImage(0, 0, sX, sY, "files/img/bg.jpg", 0, 0, 0, tocolor(200, 200, 200, a1))
	--dxDrawImage(0, 0, sX, sY, "files/img/bg.jpg", 180, 0, 0, tocolor(200, 200, 200, a2))
	
	r, g, b = interpolateBetween(200, 200, 200, 225, 140, 135, getTickCount()/10000, "SineCurve")
	size, x = interpolateBetween(144, 180, 0, 164, 200, 0, getTickCount()/5000, "SineCurve")
	dxDrawImage(sX / 2 - 164/2, 200, 164, 164, "files/img/logo.png", 0, 0, 0, tocolor(r, g, b))

	--dxDrawText("Szia #8FC3E4" .. getPlayerName(localPlayer) .. "#c8c8c8!", sX / 2, sY / 2 - sizeY / 2 - 100, _, _, tocolor(200, 200, 200), 1, poppinsLightRegular, "center", "center", false, false, false, true)
	dxDrawText("Üdvözöl az #E18C88alpha#c8c8c8Games.", sX / 2, sY / 2 - sizeY / 2 - 50, _, _, tocolor(200, 200, 200), 1, poppinsLightBig, "center", "center", false, false, false, true)

	if currentPage == "login" then
		sizeX, sizeY = 400, 200;
		startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

		dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, 150))
		dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, 150))
		
		dxDrawRectangle(startX + 25, startY + 115, 20, 20, tocolor(100, 100, 100, 150))
		if isMouseInPosition(startX + 25, startY + 115, 20, 20) or rememberMe then
			dxDrawRectangle(startX + 25 + 1, startY + 115 + 1, 20 - 2, 20 - 2, tocolor(155, 225, 135, 75))
		end

		dxDrawText("Emlékezz rám!", startX + 55, startY + 125, _, _, tocolor(200, 200, 200, 150), 1, poppinsRegular, "left", "center", false, false, false, true)

		dxDrawRectangle(startX + 20, startY + 150, (sizeX - 40) / 2 - 10, 35, tocolor(75, 75, 75, 150))
		if isMouseInPosition(startX + 20, startY + 150, (sizeX - 40) / 2 - 10, 35) then
			dxDrawRectangle(startX + 20 + 1, startY + 150 + 1, (sizeX - 40) / 2 - 10 - 2, 35 - 2, tocolor(75, 75, 75, 150))
		else
			dxDrawRectangle(startX + 20 + 1, startY + 150 + 1, (sizeX - 40) / 2 - 10 - 2, 35 - 2, tocolor(35, 35, 35, 150))
		end
		dxDrawText("Bejelentkezés", startX + 20 + ((sizeX - 40) / 2 - 10) / 2, startY + 150 + 35/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsRegular, "center", "center", false, false, false, true)

		dxDrawRectangle(startX + sizeX / 2 + 10, startY + 150, (sizeX - 40) / 2 - 10, 35, tocolor(75, 75, 75, 150))
		if isMouseInPosition(startX + sizeX / 2 + 10, startY + 150, (sizeX - 40) / 2 - 10, 35) then
			dxDrawRectangle(startX + sizeX / 2 + 10 + 1, startY + 150 + 1, (sizeX - 40) / 2 - 10 - 2, 35 - 2, tocolor(75, 75, 75, 150))
		else
			dxDrawRectangle(startX + sizeX / 2 + 10 + 1, startY + 150 + 1, (sizeX - 40) / 2 - 10 - 2, 35 - 2, tocolor(35, 35, 35, 150))
		end
		dxDrawText("Regisztráció", startX + sizeX / 2 + 10 + ((sizeX - 40) / 2 - 10) / 2, startY + 150 + 35/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsRegular, "center", "center", false, false, false, true)
	elseif currentPage == "register" then

		dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, 150))
		dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, 150))

		
		dxDrawRectangle(startX + 20, startY + sizeY - 45, (sizeX - 40) / 2 - 10, 35, tocolor(75, 75, 75, 150))
		if isMouseInPosition(startX + 20, startY + sizeY - 45, (sizeX - 40) / 2 - 10, 35) then
			dxDrawRectangle(startX + 20 + 1, startY + sizeY - 45 + 1, (sizeX - 40) / 2 - 10 - 2, 35 - 2, tocolor(75, 75, 75, 150))
		else
			dxDrawRectangle(startX + 20 + 1, startY + sizeY - 45 + 1, (sizeX - 40) / 2 - 10 - 2, 35 - 2, tocolor(35, 35, 35, 150))
		end
		dxDrawText("Visszalépés", startX + 20 + ((sizeX - 40) / 2 - 10) / 2, startY + sizeY - 45 + 35/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsRegular, "center", "center", false, false, false, true)

		dxDrawRectangle(startX + sizeX / 2 + 10, startY + sizeY - 45, (sizeX - 40) / 2 - 10, 35, tocolor(75, 75, 75, 150))
		if isMouseInPosition(startX + sizeX / 2 + 10, startY + sizeY - 45, (sizeX - 40) / 2 - 10, 35) then
			dxDrawRectangle(startX + sizeX / 2 + 10 + 1, startY + sizeY - 45 + 1, (sizeX - 40) / 2 - 10 - 2, 35 - 2, tocolor(75, 75, 75, 150))
		else
			dxDrawRectangle(startX + sizeX / 2 + 10 + 1, startY + sizeY - 45 + 1, (sizeX - 40) / 2 - 10 - 2, 35 - 2, tocolor(35, 35, 35, 150))
		end
		dxDrawText("Továbblépés", startX + sizeX / 2 + 10 + ((sizeX - 40) / 2 - 10) / 2, startY + sizeY - 45 + 35/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsRegular, "center", "center", false, false, false, true)
	end
end

function onClick(button, state)
	if button == "left" and state == "down" then
		if currentPage == "login" then
			if isMouseInPosition(startX + sizeX / 2 + 10, startY + 150, (sizeX - 40) / 2 - 10, 35) then
				currentPage = "register"
				sizeX, sizeY = 400, 275;
				startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

				exports.aDx:dxDestroyEdit("a.Username")
				exports.aDx:dxDestroyEdit("a.Password")
				exports.aDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + 20, startY + 20, sizeX - 40, 30, {125, 125, 125}, 20, 1)
				exports.aDx:dxCreateEdit("a.Password", "", "Jelszó", startX + 20, startY + 70, sizeX - 40, 30, {125, 125, 125}, 20, 2)
				exports.aDx:dxCreateEdit("a.Password2", "", "Jelszó újra", startX + 20, startY + 120, sizeX - 40, 30, {125, 125, 125}, 20, 2)
				exports.aDx:dxCreateEdit("a.Email", "", "E-mail", startX + 20, startY + 170, sizeX - 40, 30, {125, 125, 125}, 35, 1)
			end

			if isMouseInPosition(startX + 20, startY + 150, (sizeX - 40) / 2 - 10, 35) then
				local username = exports.aDx:dxGetEditText("a.Username")
				local password = exports.aDx:dxGetEditText("a.Password")
				if not username or not password then
					-- notification here
					return
				end
				triggerServerEvent("a.RequestAction", localPlayer, localPlayer, "login", username, password)
			end

			if isMouseInPosition(startX + 25, startY + 115, 20, 20) then
				rememberMe = not rememberMe
			end
		elseif currentPage == "register" then
			if isMouseInPosition(startX + 20, startY + sizeY - 45, (sizeX - 40) / 2 - 10, 35) then
				exports.aDx:dxDestroyEdit("a.Username")
				exports.aDx:dxDestroyEdit("a.Password")
				exports.aDx:dxDestroyEdit("a.Password2")
				exports.aDx:dxDestroyEdit("a.Email")
				
				sizeX, sizeY = 400, 200;
				startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
				currentPage = "login"
				
				exports.aDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + 20, startY + 20, sizeX - 40, 30, {125, 125, 125}, 20, 1)
				exports.aDx:dxCreateEdit("a.Password", "", "Jelszó", startX + 20, startY + 70, sizeX - 40, 30, {125, 125, 125}, 20, 2)
			end

			if isMouseInPosition(startX + sizeX / 2 + 10, startY + sizeY - 45, (sizeX - 40) / 2 - 10, 35) then
				local username = exports.aDx:dxGetEditText("a.Username")
				local password = exports.aDx:dxGetEditText("a.Password")
				local password2 = exports.aDx:dxGetEditText("a.Password2")
				local email = exports.aDx:dxGetEditText("a.Email")
				if not username or not password or not password2 or not email then
					exports.aInfobox:makeNotification(2, "A regisztráció véglegesítéséhez minden adatot ki kell töltened.")
					return
				end

				if string.len(username) < 5 then
					exports.aInfobox:makeNotification(2, "A megadott felhasználónév túl rövid. (Min. 5 karakter)")
				else
					if string.len(password) < 6 then
						exports.aInfobox:makeNotification(2, "A megadott jelszó túl rövid. (Min. 5 karakter)")
					else
						if string.len(password2) < 6 then
							exports.aInfobox:makeNotification(2, "A megismételt jelszó túl rövid. (Min. 5 karakter)")
						else
							if not (tostring(password) == tostring(password2)) then
								exports.aInfobox:makeNotification(2, "A két jelszó nem egyezik.")
							else
								if not utf8.find(email, "@") then
									exports.aInfobox:makeNotification(2, "Valós e-mail címet adj meg.")
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
end

function serverResponse(element, type)
	if not (element == localPlayer) then
		return
	end
	if type == "loginError" then
		exports.aInfobox:makeNotification(2, "Hibás adatok lettek megadva.")
	elseif type == "loginSuccess" then
		exports.aLoader:createLoader(5)
		triggerServerEvent("a.LoginSuccess", localPlayer, localPlayer)

		local username, password = exports.aDx:dxGetEditText("a.Username"), exports.aDx:dxGetEditText("a.Password")

		if rememberMe then
			saveLoginFiles(username, password, 1)
		else
			saveLoginFiles("", "", 0)
		end


		showChat(true)
		showCursor(false)
		fadeCamera(true)
		setCameraTarget(localPlayer, localPlayer)
		stopSmoothMoveCamera()
		exports.aDx:dxDestroyEdit("a.Username")
		exports.aDx:dxDestroyEdit("a.Password")
		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientClick", root, onClick)
	elseif type == "registerError.usernameExists" then
		exports.aInfobox:makeNotification(2, "Ez a felhasználónév már regisztrálva van az adatbázisban.")
	elseif type == "registerError.serialExists" then
		exports.aInfobox:makeNotification(2, "Ehhez a serialhoz már van account társítva.")
	elseif type == "registerSuccess" then
		exports.aInfobox:makeNotification(1, "Sikeresen létrehoztad a felhasználódat, mostmár bejelentkezhetsz.")
		exports.aDx:dxDestroyEdit("a.Username")
		exports.aDx:dxDestroyEdit("a.Password")
		exports.aDx:dxDestroyEdit("a.Password2")
		exports.aDx:dxDestroyEdit("a.Email")
		sizeX, sizeY = 400, 200;
		startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
		currentPage = "login"
		
		exports.aDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + 20, startY + 20, sizeX - 40, 30, {125, 125, 125}, 20, 1)
		exports.aDx:dxCreateEdit("a.Password", "", "Jelszó", startX + 20, startY + 70, sizeX - 40, 30, {125, 125, 125}, 20, 2)
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
		
		exports.aDx:dxEditSetText("a.Username", rememberedUsername)
		exports.aDx:dxEditSetText("a.Password", rememberedPassword)
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