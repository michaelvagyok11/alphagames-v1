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

local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(40), false, "cleartype")
local poppinsLightBig = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(40), false, "cleartype")
local poppinsLightRegular = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(25), false, "cleartype")
local poppinsRegular = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(15), false, "cleartype")
local poppinsBold = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(15), false, "cleartype")

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)

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
	setPlayerHudComponentVisible("all", false)
	setPlayerHudComponentVisible("crosshair", true)

	currentPage = "login"

	fadeCamera(true)
	smoothMoveCamera(2287.1855, -875.00098, 30.139843, 2287.293, -993.75586, 30.139843, 2286.0801, -1520.6875, 30.139843, 2286.1289, -1560.6875, 30.139843, 120000)
	
	showChat(false)
	showCursor(true)
	addEventHandler("onClientRender", root, onRender)
	addEventHandler("onClientClick", root, onClick)
	
	sizeX, sizeY = respc(400), respc(200);
	startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

	exports.aDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + respc(50), startY + respc(20), sizeX - respc(70), respc(30), {155, 230, 140}, 20, 1)
	exports.aDx:dxCreateEdit("a.Password", "", "Jelszó", startX + respc(50), startY + respc(70), sizeX - respc(70), respc(30), {140, 195, 230}, 20, 2)

	loadLoginFiles()
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop()
	exports.aDx:dxDestroyEdit("a.Username")
	exports.aDx:dxDestroyEdit("a.Password")
	exports.aDx:dxDestroyEdit("a.Password2")
	exports.aDx:dxDestroyEdit("a.VisibleName")
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)

function onRender()
	a1, a2 = interpolateBetween(0, 255, 0, 255, 0, 0, getTickCount()/10000, "SineCurve")		
	r, g, b = interpolateBetween(200, 200, 200, 225, 140, 135, getTickCount()/10000, "SineCurve")
	
	-- ** V2 logó, egyelőre kivéve.
	--dxDrawImage(sX / 2 - respc(32), sY / 2 - sizeY / 2 - respc(50) - respc(84), respc(64), respc(64), "files/img/logo.png", 0, 0, 0, tocolor(r, g, b))

	dxDrawText("Üdvözöl az #E18C88alpha#c8c8c8Games.", sX / 2, sY / 2 - sizeY / 2 - respc(50), _, _, tocolor(200, 200, 200), 1, poppinsLightBig, "center", "center", false, false, false, true)

	if currentPage == "login" then
		sizeX, sizeY = respc(400), respc(200);
		startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

		dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, 150))
		dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, 150))
		
		dxDrawImage(startX + respc(20) - respc(6), startY + respc(20) + respc(3), respc(24), respc(24), "files/img/username.png", 0, 0, 0, tocolor(155, 230, 140, 150))
		dxDrawImage(startX + respc(20) - respc(6), startY + respc(70) + respc(3), respc(24), respc(24), "files/img/password.png", 0, 0, 0, tocolor(140, 195, 230, 150))

		dxDrawRectangle(startX + respc(25), startY + respc(115), respc(20), respc(20), tocolor(100, 100, 100, 150))
		if isMouseInPosition(startX + respc(25), startY + respc(115), respc(20), respc(20)) or rememberMe then
			dxDrawRectangle(startX + respc(25) + 1, startY + respc(115) + 1, respc(20) - 2, respc(20) - 2, tocolor(155, 225, 135, 75))
		end

		dxDrawText("Emlékezz rám!", startX + respc(55), startY + respc(125), _, _, tocolor(200, 200, 200, 150), 1, poppinsRegular, "left", "center", false, false, false, true)

		dxDrawRectangle(startX + respc(20), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35), tocolor(75, 75, 75, 150))
		if isMouseInPosition(startX + respc(20), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
			dxDrawRectangle(startX + respc(20) + 1, startY + respc(150) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(75, 75, 75, 150))
		else
			dxDrawRectangle(startX + respc(20) + 1, startY + respc(150) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(35, 35, 35, 150))
		end
		dxDrawText("Bejelentkezés", startX + respc(20) + ((sizeX - respc(40)) / 2 - respc(10)) / 2, startY + respc(150) + respc(35)/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsBold, "center", "center", false, false, false, true)

		dxDrawRectangle(startX + sizeX / 2 + respc(10), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35), tocolor(75, 75, 75, 150))
		if isMouseInPosition(startX + sizeX / 2 + respc(10), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
			dxDrawRectangle(startX + sizeX / 2 + respc(10) + 1, startY + respc(150) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(75, 75, 75, 150))
		else
			dxDrawRectangle(startX + sizeX / 2 + respc(10) + 1, startY + respc(150) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(35, 35, 35, 150))
		end
		dxDrawText("Regisztráció", startX + sizeX / 2 + respc(10) + ((sizeX - respc(40)) / 2 - respc(10)) / 2, startY + respc(150) + respc(35)/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsBold, "center", "center", false, false, false, true)
	elseif currentPage == "register" then

		dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, 150))
		dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, 150))

		
		dxDrawRectangle(startX + respc(20), startY + sizeY - respc(45), (sizeX - respc(40)) / 2 - respc(10), respc(35), tocolor(75, 75, 75, 150))
		if isMouseInPosition(startX + respc(20), startY + sizeY - respc(45), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
			dxDrawRectangle(startX + respc(20) + 1, startY + sizeY - respc(45) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(75, 75, 75, 150))
		else
			dxDrawRectangle(startX + respc(20) + 1, startY + sizeY - respc(45) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(35, 35, 35, 150))
		end
		dxDrawText("Visszalépés", startX + respc(20) + ((sizeX - respc(40)) / 2 - respc(10)) / 2, startY + sizeY - respc(45) + respc(35)/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsBold, "center", "center", false, false, false, true)

		dxDrawRectangle(startX + sizeX / 2 + respc(10), startY + sizeY - respc(45), (sizeX - respc(40)) / 2 - respc(10), respc(35), tocolor(75, 75, 75, 150))
		if isMouseInPosition(startX + sizeX / 2 + respc(10), startY + sizeY - respc(45), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
			dxDrawRectangle(startX + sizeX / 2 + respc(10) + 1, startY + sizeY - respc(45) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(75, 75, 75, 150))
		else
			dxDrawRectangle(startX + sizeX / 2 + respc(10) + 1, startY + sizeY - respc(45) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(35, 35, 35, 150))
		end
		dxDrawText("Továbblépés", startX + sizeX / 2 + respc(10) + ((sizeX - respc(40)) / 2 - respc(10)) / 2, startY + sizeY - respc(45) + respc(35)/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsBold, "center", "center", false, false, false, true)
	end
end

function onClick(button, state)
	if button == "left" and state == "down" then
		if currentPage == "login" then
			if isMouseInPosition(startX + sizeX / 2 + respc(10), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
				currentPage = "register"
				sizeX, sizeY = respc(400), respc(275);
				startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

				exports.aDx:dxDestroyEdit("a.Username")
				exports.aDx:dxDestroyEdit("a.Password")
				exports.aDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + respc(20), startY + respc(20), sizeX - respc(40), respc(30), {125, 125, 125}, 20, 1)
				exports.aDx:dxCreateEdit("a.Password", "", "Jelszó", startX + respc(20), startY + respc(70), sizeX - respc(40), respc(30), {125, 125, 125}, 20, 2)
				exports.aDx:dxCreateEdit("a.Password2", "", "Jelszó újra", startX + respc(20), startY + respc(120), sizeX - respc(40), respc(30), {125, 125, 125}, 20, 2)
				exports.aDx:dxCreateEdit("a.VisibleName", "", "Megjelenített neved", startX + respc(20), startY + respc(170), sizeX - respc(40), respc(30), {125, 125, 125}, 35, 1)
			end

			if isMouseInPosition(startX + respc(20), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
				local username = exports.aDx:dxGetEditText("a.Username")
				local password = exports.aDx:dxGetEditText("a.Password")
				if not username or not password then
					exports.aInfobox:makeNotification(2, "Hibás adatokat adtál meg.")
					return
				end
				triggerServerEvent("a.RequestAction", localPlayer, localPlayer, "login", username, password)
			end

			if isMouseInPosition(startX + respc(25), startY + respc(115), respc(20), respc(20)) then
				rememberMe = not rememberMe
			end
		elseif currentPage == "register" then
			if isMouseInPosition(startX + respc(20), startY + sizeY - respc(45), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
				exports.aDx:dxDestroyEdit("a.Username")
				exports.aDx:dxDestroyEdit("a.Password")
				exports.aDx:dxDestroyEdit("a.Password2")
				exports.aDx:dxDestroyEdit("a.VisibleName")
				
				sizeX, sizeY = respc(400), respc(200);
				startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
				currentPage = "login"
				
				exports.aDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + respc(50), startY + respc(20), sizeX - respc(70), respc(30), {155, 230, 140}, 20, 1)
				exports.aDx:dxCreateEdit("a.Password", "", "Jelszó", startX + respc(50), startY + respc(70), sizeX - respc(70), respc(30), {140, 195, 230}, 20, 2)
			end

			if isMouseInPosition(startX + sizeX / 2 + respc(10), startY + sizeY - respc(45), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
				local username = exports.aDx:dxGetEditText("a.Username")
				local password = exports.aDx:dxGetEditText("a.Password")
				local password2 = exports.aDx:dxGetEditText("a.Password2")
				local visibleName = exports.aDx:dxGetEditText("a.VisibleName")
				if not username or not password or not password2 or not visibleName then
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
								if string.len(visibleName) < 3 or string.len(visibleName) > 15 then
									exports.aInfobox:makeNotification(2, "Túl hosszú/rövid a neved.")
								else
									triggerServerEvent("attemptRegister", localPlayer, localPlayer, {tostring(username), tostring(password), tostring(visibleName)})
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
		triggerServerEvent("a.LoginSuccess", localPlayer, localPlayer)
		exports.a_loader:createLoadingScreen(2, "Lobby", getElementData(localPlayer, "a.Gamemode"), 0)
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

		exports.a_inventory:processActionBarShowHide(true)
		exports.a_inventory:loadActionBarItems()

	elseif type == "registerError.usernameExists" then
		exports.aInfobox:makeNotification(2, "Ez a felhasználónév már regisztrálva van az adatbázisban.")
	elseif type == "registerError.nameExists" then
		exports.aInfobox:makeNotification(2, "Ez a név már felhasználásban van.")
	elseif type == "registerError.serialExists" then
		exports.aInfobox:makeNotification(2, "Ehhez a serialhoz már van account társítva.")
	elseif type == "registerSuccess" then
		exports.aInfobox:makeNotification(1, "Sikeresen létrehoztad a felhasználódat, mostmár bejelentkezhetsz.")
		exports.aDx:dxDestroyEdit("a.Username")
		exports.aDx:dxDestroyEdit("a.Password")
		exports.aDx:dxDestroyEdit("a.Password2")
		exports.aDx:dxDestroyEdit("a.VisibleName")
		sizeX, sizeY = respc(400), respc(200);
		startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
		currentPage = "login"
		
		exports.aDx:dxCreateEdit("a.Username", "", "Felhasználónév", startX + respc(50), startY + respc(20), sizeX - respc(70), respc(30), {155, 230, 140}, 20, 1)
		exports.aDx:dxCreateEdit("a.Password", "", "Jelszó", startX + respc(50), startY + respc(70), sizeX - respc(70), respc(30), {140, 195, 230}, 20, 2)
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

bindKey("m", "down", function()
	showCursor(not (isCursorShowing()))
end)