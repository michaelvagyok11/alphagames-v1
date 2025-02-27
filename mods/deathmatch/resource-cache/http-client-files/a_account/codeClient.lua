local sX, sY = guiGetScreenSize()
local myX, myY = 1920, 1080
local isPanelShowing = true
local startingNow = getTickCount()
local startingNow2 = getTickCount()
local panelPage = "login"
function start()
	startingNow2 = getTickCount()
end
setTimer(start, 1000, 0)
local x = 760
local wx3 = 0
local wx4 = 0
local font1 = dxCreateFont("files/fonts/font.ttf", 18)
local font2 = dxCreateFont("files/fonts/font.ttf", 13)
local font3 = dxCreateFont("files/fonts/font2.ttf", 13)

if fileExists("codeClient.lua") then
	fileDelete("codeClient.lua")
end

function calculating()
	if isCursorOnBox(780/myX * sX, 600/myY * sY, 360/myX * sX, 40/myY * sY) or isCursorOnBox(780/myX * sX, 650/myY * sY, 360/myX * sX, 40/myY * sY) then
		calculatedNow = getTickCount()
	else
		calculatedNow = getTickCount()
	end
end
addEventHandler("onClientRender", root, calculating)


function renderAccountSystem()
	if panelPage == "login" then

		renderNow = getTickCount()
		elapsedTime = renderNow - startingNow
		progress = elapsedTime / 1000

		roundedRectangle(760/myX * sX, 400/myY * sY, 400/myX * sX, 300/myY * sY, tocolor(20, 20, 20, textA))
		roundedRectangle(760/myX * sX + 2, 400/myY * sY + 2, 400/myX * sX - 4, 300/myY * sY - 4, tocolor(30, 30, 30, textA))
		roundedRectangle(760/myX * sX, 400/myY * sY, 400/myX * sX, 30, tocolor(35, 35, 35, textA))

		--dxDrawRectangle(780/myX * sX, 460/myY * sY, 360/myX * sX, 30/myY * sY, tocolor(30, 30, 30, textA))
		dxDrawImage(782/myX * sX, 462/myY * sY, 24/myX * sX, 24/myY * sY, "files/username.png", 0, 0, 0, tocolor(200, 200, 200, textA))

		--dxDrawRectangle(780/myX * sX, 500/myY * sY, 360/myX * sX, 30/myY * sY, tocolor(30, 30, 30, textA))
		dxDrawImage(782/myX * sX, 502/myY * sY, 24/myX * sX, 24/myY * sY, "files/password.png", 0, 0, 0, tocolor(200, 200, 200, textA))

		dxDrawRectangle(780/myX * sX, 550/myY * sY, 30/myX * sX, 30/myY * sY, tocolor(20, 20, 20, textA))
		
		elapsedTime2 = calculatedNow - startingNow2
		progress2 = elapsedTime2 / 5000

		if isCursorOnBox(780/myX * sX, 550/myY * sY, 30/myX * sX, 30/myY * sY) or rememberData then
			cR, cG, cB = 100, 200, 100
			dxDrawImage(782/myX * sX, 552/myY * sY, 24/myX * sX, 24/myY * sY, "files/correct.png", 0, 0, 0, tocolor(cR, cG, cB, textA))
		end

		roundedRectangle(780/myX * sX, 600/myY * sY, 360/myX * sX, 40/myY * sY, tocolor(50, 50, 50, textA))
		roundedRectangle(780/myX * sX, 650/myY * sY, 360/myX * sX, 40/myY * sY, tocolor(50, 50, 50, textA))


		if isCursorOnBox(780/myX * sX, 600/myY * sY, 360/myX * sX, 40/myY * sY) then
			wx3 = interpolateBetween(wx3, 0, 0, 360, 0, 0, progress2 / 2, "OutQuad")
			roundedRectangle(780/myX * sX, 600/myY * sY, wx3/myX * sX, 40/myY * sY, tocolor(80, 80, 80, 200))
		else
			wx3 = interpolateBetween(wx3, 0, 0, 0, 0, 0, progress2 / 2, "OutQuad")
			--roundedRectangle(780/myX * sX, 600/myY * sY, wx3/myX * sX, 40/myY * sY, tocolor(80, 80, 80, textA))
		end

		if isCursorOnBox(780/myX * sX, 650/myY * sY, 360/myX * sX, 40/myY * sY) then
			wx4 = interpolateBetween(wx4, 0, 0, 360, 0, 0, progress2 / 2, "OutQuad")
			roundedRectangle(780/myX * sX, 650/myY * sY, wx4/myX * sX, 40/myY * sY, tocolor(80, 80, 80, 200))
		else
			wx4 = interpolateBetween(wx4, 0, 0, 0, 0, 0, progress2 / 2, "OutQuad")
			--roundedRectangle(780/myX * sX, 650/myY * sY, wx4/myX * sX, 40/myY * sY, tocolor(80, 80, 80, textA))
		end

		lineA = interpolateBetween(50, 0, 0, 100, 0, 0, renderNow / 5000, "SineCurve")

		--[[wx1 = interpolateBetween(0, 0, 0, 400, 0, 0, progress, "Linear")
		dxDrawRectangle(x, 400/myY * sY, wx1/myX * sX, 2/myY * sY, tocolor(230, 200, 140, lineA))

		wy1 = interpolateBetween(0, 0, 0, 300, 0, 0, progress, "Linear")
		dxDrawRectangle((x + 400)/myX * sX, 400/myY * sY, 2/myX * sX, wy1/myY * sY, tocolor(230, 200, 140, lineA))

		wx2 = interpolateBetween(0, 0, 0, 400, 0, 0, progress, "Linear")
		dxDrawRectangle((x + 400)/myX * sX, 700/myY * sY, -wx2/myX * sX, 2/myY * sY, tocolor(230, 200, 140, lineA))

		wy2 = interpolateBetween(0, 0, 0, 300, 0, 0, progress, "Linear")
		dxDrawRectangle(x/myX * sX, 700/myY * sY, 2/myX * sX, -wy2/myY * sY, tocolor(230, 200, 140, lineA))]]--

		textA = interpolateBetween(0, 0, 0, 240, 0, 0, progress, "Linear")
		dxDrawText("#D19D6BAlpha#c8c8c8Games - Loginpanel", 955/myX * sX, 415/myY * sY, _, _, tocolor(200, 200, 200, textA), 1, font3, "center", "center", false, false, false, true)

		--dxDrawText("Username", 950/myX * sX, 475/myY * sY, _, _, tocolor(200, 200, 200, textA), 1, font2, "center", "center")
		--dxDrawText("Password", 950/myX * sX, 515/myY * sY, _, _, tocolor(200, 200, 200, textA), 1, font2, "center", "center")
		dxDrawText("Remember me", 890/myX * sX, 568/myY * sY, _, _, tocolor(200, 200, 200, textA), 1, font2, "center", "center")

		dxDrawText("Login", 950/myX * sX, 620/myY * sY, _, _, tocolor(200, 200, 200, textA), 1, font1, "center", "center")
		dxDrawText("Register", 950/myX * sX, 670/myY * sY, _, _, tocolor(200, 200, 200, textA), 1, font1, "center", "center")
	elseif panelPage == "register" then
		renderNow = getTickCount()
		elapsedTime = renderNow - startingNow
		progress = elapsedTime / 1500
		textA = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "Linear")
		roundedRectangle(760/myX * sX, 400/myY * sY, 400/myX * sX, 300/myY * sY, tocolor(30, 30, 30, textA))
		dxDrawText("Regisztráció", 955/myX * sX, 430/myY * sY, _, _, tocolor(200, 200, 200, textA), 1, font3, "center", "center")

		dxDrawRectangle(780/myX * sX, 460/myY * sY, 360/myX * sX, 30/myY * sY, tocolor(30, 30, 30, textA))
		dxDrawImage(782/myX * sX, 462/myY * sY, 24/myX * sX, 24/myY * sY, "files/username.png", 0, 0, 0, tocolor(200, 200, 200, textA))

		dxDrawRectangle(780/myX * sX, 500/myY * sY, 360/myX * sX, 30/myY * sY, tocolor(30, 30, 30, textA))
		dxDrawImage(782/myX * sX, 502/myY * sY, 24/myX * sX, 24/myY * sY, "files/password.png", 0, 0, 0, tocolor(200, 200, 200, textA))

		dxDrawRectangle(780/myX * sX, 540/myY * sY, 360/myX * sX, 30/myY * sY, tocolor(30, 30, 30, textA))
		dxDrawImage(782/myX * sX, 542/myY * sY, 24/myX * sX, 24/myY * sY, "files/email.png", 0, 0, 0, tocolor(200, 200, 200, textA))

		dxDrawRectangle(780/myX * sX, 580/myY * sY, 360/myX * sX, 30/myY * sY, tocolor(30, 30, 30, textA))
		dxDrawImage(782/myX * sX, 582/myY * sY, 24/myX * sX, 24/myY * sY, "files/email.png", 0, 0, 0, tocolor(200, 200, 200, textA))

		elapsedTime2 = calculatedNow - startingNow2
		progress2 = elapsedTime2 / 5000

		roundedRectangle(780/myX * sX, 630/myY * sY, 360/myX * sX, 40/myY * sY, tocolor(50, 50, 50, textA))
		if isCursorOnBox(780/myX * sX, 630/myY * sY, 360/myX * sX, 40/myY * sY) then
			wx3 = interpolateBetween(wx3, 0, 0, 360, 0, 0, progress2 / 2, "OutQuad")
			if wx3 > 0 then
				roundedRectangle(780/myX * sX, 630/myY * sY, wx3/myX * sX, 40/myY * sY, tocolor(80, 80, 80, 200))
			end
		else
			wx3 = interpolateBetween(wx3, 0, 0, 0, 0, 0, progress2 / 2, "OutQuad")
			--dxDrawRectangle(780/myX * sX, 630/myY * sY, wx3/myX * sX, 40/myY * sY, tocolor(80, 80, 80, textA))
		end
		dxDrawText("Create", 950/myX * sX, 650/myY * sY, _, _, tocolor(200, 200, 200, textA), 1, font1, "center", "center")

		if not isCursorOnBox(780/myX * sX, 675/myY * sY, 100, 20) then
			dxDrawText("<- Login", 820/myX * sX, 685/myY * sY, _, _, tocolor(150, 150, 150, textA), 1, font2, "center", "center")
		else
			dxDrawText("<- Login", 820/myX * sX, 685/myY * sY, _, _, tocolor(150, 50, 50, textA), 1, font2, "center", "center")
		end
	end
end

addEventHandler("onClientClick", root, function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" and state == "down" then
		if not isPanelShowing then return end
		if panelPage == "login" then
			if isInBox(780/myX * sX, 600/myY * sY, 360/myX * sX, 40/myY * sY, absoluteX, absoluteY) then
				local id = exports.a_dx:dxGetEdit("username")
				local id2 = exports.a_dx:dxGetEdit("password")
				local un = exports.a_dx:dxGetEditText(id)
				local pw = exports.a_dx:dxGetEditText(id2)
				triggerServerEvent("executeLogin", getLocalPlayer(), getLocalPlayer(), un, pw)
			end
			if isInBox(782/myX * sX, 552/myY * sY, 24/myX * sX, 24/myY * sY, absoluteX, absoluteY) then
				rememberData = not rememberData
			end
			if isInBox(780/myX * sX, 640/myY * sY, 360/myX * sX, 40/myY * sY, absoluteX, absoluteY) then
				panelPage = "register"
				local id = exports.a_dx:dxGetEdit("username")
				local id2 = exports.a_dx:dxGetEdit("password")
				exports.a_dx:dxDestroyEdit(id2)
				exports.a_dx:dxDestroyEdit(id)
				exports.a_dx:dxCreateEdit("username2", "", "username", 810/myX * sX, 460/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30)
				exports.a_dx:dxCreateEdit("password2", "", "password", 810/myX * sX, 500/myY * sY, 320/myX * sX, 30/myY * sY, 2, 30)
				exports.a_dx:dxCreateEdit("email", "", "email", 810/myX * sX, 540/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30)
				exports.a_dx:dxCreateEdit("emaill", "", "email 2x", 810/myX * sX, 580/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30)
			end
		elseif panelPage == "register" then
			if isInBox(780/myX * sX, 675/myY * sY, 100, 20, absoluteX, absoluteY) then
				panelPage = "login"
				local id = exports.a_dx:dxGetEdit("username2")
				local id2 = exports.a_dx:dxGetEdit("password2")
				local id3 = exports.a_dx:dxGetEdit("email")
				local id4 = exports.a_dx:dxGetEdit("emaill")
				exports.a_dx:dxDestroyEdit(id4)
				exports.a_dx:dxDestroyEdit(id3)
				exports.a_dx:dxDestroyEdit(id2)
				exports.a_dx:dxDestroyEdit(id)
				--triggerServerEvent("restartEditBox", getLocalPlayer())
				exports.a_dx:dxCreateEdit("username", "", "", 810/myX * sX, 460/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30)
				exports.a_dx:dxCreateEdit("password", "", "", 810/myX * sX, 500/myY * sY, 320/myX * sX, 30/myY * sY, 2, 30)
			end

			if isInBox(780/myX * sX, 630/myY * sY, 360/myX * sX, 40/myY * sY, absoluteX, absoluteY) then
				local id = exports.a_dx:dxGetEdit("username2")
				local id2 = exports.a_dx:dxGetEdit("password2")
				local id3 = exports.a_dx:dxGetEdit("email")
				local id4 = exports.a_dx:dxGetEdit("emaill")
				local username = exports.a_dx:dxGetEditText(id)
				local password = exports.a_dx:dxGetEditText(id2)
				local email = exports.a_dx:dxGetEditText(id3)
				local emaill = exports.a_dx:dxGetEditText(id4)

				if (username) and string.len(username) > 3 then 
					if (password) and string.len(password) > 5 then
						if (email) and utf8.find(email, "@") then
							if (emaill == email) then
								triggerServerEvent("executeRegister", localPlayer, localPlayer, username, password, tostring(email))
							else		
								-- infobox noti email nem egyezik
								exports.a_interface:makeNotification(2, "Two email address arent matching.")
								--print("1")
							end
						else
							-- infobox noti nem valid email
							exports.a_interface:makeNotification(2, "Please enter a valid email address.")
							--print("2")
						end
					else
						--infobox noti rovid password
						exports.a_interface:makeNotification(2, "Your password is too short. (Min: 5 characters)")
						--print("3")
					end
				else
					-- infobox noti rovid username
					exports.a_interface:makeNotification(2, "Your username is too short. (Min: 3 characters)")
					--print("4")
				end
			end
		end
	end
end)

function saveLoginFiles(username, password, remember)
	if fileExists("@aLogindata.xml") then
		fileDelete("@aLogindata.xml")
	end
	
	local loginRememberFile = xmlCreateFile("@aLogindata.xml", "logindata")
	
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "username"), username)
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "password"), password)
	xmlNodeSetValue(xmlCreateChild(loginRememberFile, "remember"), remember)
	
	xmlSaveFile(loginRememberFile)
	xmlUnloadFile(loginRememberFile)
end

function loadLoginFiles()
	local loginRememberFile = xmlLoadFile("@aLogindata.xml")
	
	if loginRememberFile then
		rememberedUsername = xmlNodeGetValue(xmlFindChild(loginRememberFile, "username", 0))
		rememberedPassword = xmlNodeGetValue(xmlFindChild(loginRememberFile, "password", 0))
		
		local id = exports.a_dx:dxGetEdit("username")
		local id2 = exports.a_dx:dxGetEdit("password")
		exports.a_dx:dxEditSetText(id, rememberedUsername)
		exports.a_dx:dxEditSetText(id2, rememberedPassword)
		local rememberValue = xmlNodeGetValue(xmlFindChild(loginRememberFile, "remember", 0))
		if tonumber(rememberValue) and tonumber(rememberValue) == 1 then
			rememberData = true
		else
			rememberData = false
		end
		
		xmlUnloadFile(loginRememberFile)
	end
end

addEventHandler("onClientResourceStart", getRootElement(), function(startedRes)
	if startedRes == getThisResource() then
		if getElementData(localPlayer, "loggedIn") == false then
			setPlayerHudComponentVisible("all", false)
			setPlayerHudComponentVisible("crosshair", true)
			showCursor(true)
			showChat(false)
			setCameraMatrix(2249.4482421875, 8.2763671875, 33.484375, 2250.98046875, 34.029296875, 27.78438949585)
			addEventHandler("onClientRender", root, renderAccountSystem)
			isPanelShowing = true
			if panelPage == "login" then
				exports.a_dx:dxCreateEdit("username", "", "", 810/myX * sX, 460/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30)
				exports.a_dx:dxCreateEdit("password", "", "", 810/myX * sX, 500/myY * sY, 320/myX * sX, 30/myY * sY, 2, 30)
				loadLoginFiles()
				fadeCamera(true)
			elseif panelPage == "register" then
				exports.a_dx:dxCreateEdit("username2", "", "Username", 810/myX * sX, 460/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30, 30)
				exports.a_dx:dxCreateEdit("password2", "", "Password", 810/myX * sX, 500/myY * sY, 320/myX * sX, 30/myY * sY, 2, 30, 30)
				exports.a_dx:dxCreateEdit("email", "", "Email", 810/myX * sX, 540/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30, 30)
				exports.a_dx:dxCreateEdit("emaill", "", "Email again", 810/myX * sX, 580/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30, 30)
			end
		end
	end
end)

addEventHandler("onClientResourceStop", getRootElement(), function(stoppedRes)
	if stoppedRes == getThisResource() then
		removeEventHandler("onClientRender", root, renderAccountSystem)
		setCameraTarget(getLocalPlayer())
		showChat(true)
		showCursor(false)
		isPanelShowing = false
		if panelPage == "login" then
			local id = exports.a_dx:dxGetEdit("username")
			local id2 = exports.a_dx:dxGetEdit("password")
			exports.a_dx:dxDestroyEdit(id)
			exports.a_dx:dxDestroyEdit(id2)
		elseif panelPage == "register" then
			local id = exports.a_dx:dxGetEdit("username2")
			local id2 = exports.a_dx:dxGetEdit("password2")
			local id3 = exports.a_dx:dxGetEdit("email")
			local id4 = exports.a_dx:dxGetEdit("emaill")
			exports.a_dx:dxDestroyEdit(id)
			exports.a_dx:dxDestroyEdit(id2)
			exports.a_dx:dxDestroyEdit(id3)
			exports.a_dx:dxDestroyEdit(id4)
		end
	end
end)

function isCursorOnBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end	
end

-- Smooth camera movement functions -- DO NOT CHANGE IT!

local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
 
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
	else
		removeEventHandler("onClientPreRender",root,camRender)
	end
end

 
function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then return false end
	sm.object1 = createObject(1337,x1,y1,z1)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
        setElementCollisionsEnabled (sm.object1,false) 
	setElementCollisionsEnabled (sm.object2,false) 
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
	sm.moov = 1
	setTimer(removeCamHandler,time,1)
	setTimer(destroyElement,time,1,sm.object1)
	setTimer(destroyElement,time,1,sm.object2)
	addEventHandler("onClientPreRender",root,camRender)
	return true
end

addCommandHandler("getcam", function ()
	local x, y, z, lx, ly, lz = getCameraMatrix(getLocalPlayer())
	outputChatBox(x .. ", " .. y .. ", " .. z .. ", " .. lx .. ", " .. ly .. ", " .. lz, 255, 255, 255, true)
end)

bindKey("m", "down", function()
	showCursor(not isCursorShowing())
end)

function isInBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end	

		if (not bgColor) then
			bgColor = borderColor;
		end

		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
end

local delayTimer = {}

function serverSideResponse(type)
	if type == "successfulLogin" then
		removeEventHandler("onClientRender", root, renderAccountSystem)
		delayTimer[localPlayer] = setTimer(function()
			showChat(true)
			showCursor(false)
			setPlayerHudComponentVisible("all", false)
			setPlayerHudComponentVisible("crosshair", true)
		end, 5000, 1)
		local id = exports.a_dx:dxGetEdit("username")
		local id2 = exports.a_dx:dxGetEdit("password")
		local un = exports.a_dx:dxGetEditText(id)
		local pw = exports.a_dx:dxGetEditText(id2)
		if rememberData then
			saveLoginFiles(un, pw, 1)
		else
			saveLoginFiles("", "", 0)
		end

		local id = exports.a_dx:dxGetEdit("username")
		local idd = exports.a_dx:dxGetEdit("password")
		exports.a_dx:dxDestroyEdit(2)
		exports.a_dx:dxDestroyEdit(1)
		--print(dxGetActiveEditBox())
		panelPage = "login"
		isPanelShowing = false
		setCameraTarget(localPlayer)
		exports.a_interface:makeNotification( 1, "Sikeresen beléptél!")
		
		--print("successfulLogin")
	elseif type == "serialError" then
		--print("serialError")
		exports.a_interface:makeNotification(2, "Ez a fiók nem a Te gépedhez van kötve!")
		-- infobox
	elseif type == "dataError" then
		-- infobox
		exports.a_interface:makeNotification(2, "Hibás felhasználói név/jelszó.")
		--print("dataError")
	elseif type == "successfulRegister" then
		exports.a_interface:makeNotification(1, "Sikeresen regisztráltál!")
		local id = exports.a_dx:dxGetEdit("username2")
		local idd = exports.a_dx:dxGetEdit("password2")
		exports.a_dx:dxDestroyEdit(4)
		exports.a_dx:dxDestroyEdit(3)
		exports.a_dx:dxDestroyEdit(2)
		exports.a_dx:dxDestroyEdit(1)
		panelPage = "login"
		exports.a_dx:dxCreateEdit("username", "", "username", 810/myX * sX, 460/myY * sY, 320/myX * sX, 30/myY * sY, 1, 30)
		exports.a_dx:dxCreateEdit("password", "", "password", 810/myX * sX, 500/myY * sY, 320/myX * sX, 30/myY * sY, 2, 30)
		--removeEventHandler("onClientRender", root, renderAccountSystem)
		--[[delayTimer[localPlayer] = setTimer(function()
			showChat(true)
			showCursor(false)
			setPlayerHudComponentVisible("all", false)
			setPlayerHudComponentVisible("crosshair", true)
		end, 5000, 1)


		isPanelShowing = false
		--print(dxGetActiveEditBox())
		exports.a_interface:makeNotification(1, "Successfully created your account.")
		--print("successfulRegister")]]--
	end
end
addEvent("serverSideResponse", true)
addEventHandler("serverSideResponse", root, serverSideResponse)