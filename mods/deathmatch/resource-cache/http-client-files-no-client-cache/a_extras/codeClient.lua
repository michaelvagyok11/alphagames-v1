local sX, sY = guiGetScreenSize()
--local sX, sY = 1280, 720
local boxSize = {300, 120}
local fontBold = dxCreateFont("files/fonts/Roboto-BoldCondensed.otf", 15, false, "cleartype")
local fontBold2 = dxCreateFont("files/fonts/Roboto-BoldCondensed.otf", 13, false, "cleartype")
local fontSmall = dxCreateFont("files/fonts/Roboto-Condensed.otf", 13, false, "cleartype")
local QnAshowed = false
local lastQ = {}

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)

function createQnA()
	if QnAshowed == true then
		boxState = "close"
		stateTick = getTickCount()
		QnAshowed = false
	else
		removeEventHandler("onClientRender", root, renderQnA)
		boxState = "open"
		QnAshowed = true
		stateTick = getTickCount()
		amount = math.random(50, 150)
		currentQuestion = math.random(1, #questions)
		if currentQuestion == lastQ[localPlayer] then
			currentQuestion2 = math.random(1, #questions)
			lastQ[localPlayer] = currentQuestion2
		else
			lastQ[localPlayer] = currentQuestion
		end
		currentSelected = nil
		sound = playSound("files/sounds/alert.mp3")
		setSoundVolume(sound, 15)
		addEventHandler("onClientRender", root, renderQnA)
		setTimer(function()
			if currentSelected == nil then
				boxState = "close"
				stateTick = getTickCount()
				QnAshowed = false
			end
		end, 1000*60, 1)
	end
end

function renderQnA()
	if not getElementData(localPlayer, "loggedIn") then return end
	if boxState == "open" then
		local nowTick = getTickCount()
		local elapsedTime = nowTick - stateTick
		local duration = elapsedTime / 1000
		a = interpolateBetween(0, 0, 0, 255, 0, 0, duration/2, "Linear")
		x = interpolateBetween(-boxSize[1] - 10, 0, 0, 10, 0, 0, duration, "Linear")
		rot = interpolateBetween(-20, 0, 0, 20, 0, 0, getTickCount()/3000, "SineCurve")
		w = interpolateBetween(boxSize[1], 0, 0, 0, 0, 0, elapsedTime/(60*1000), "Linear")
	elseif boxState == "close" then
		local nowTick = getTickCount()
		local elapsedTime = nowTick - stateTick
		local duration = elapsedTime / 1000
		a = interpolateBetween(a, 0, 0, 0, 0, 0, duration, "Linear")
		x = interpolateBetween(x, 0, 0, -boxSize[1]-10, 0, 0, duration/2, "OutBack")
	end
	dxDrawRectangle(x, sY/2 - boxSize[2]/2, boxSize[1], boxSize[2] + 80, tocolor(65, 65, 65, a))
	dxDrawRectangle(x + 1, sY/2 - boxSize[2]/2 + 1 + 25, boxSize[1] - 2, boxSize[2] + 80 - 2 - 25, tocolor(35, 35, 35, a))
	dxDrawRectangle(x, sY/2 - boxSize[2]/2 + boxSize[2] + 79, w, 1, tocolor(155, 230, 140, a/2))
	
	dxDrawImage(x + 4, sY/2 - boxSize[2]/2 + 4, 16, 16, "files/icons/mark.png", rot, 0, 0, tocolor(155, 230, 140, a/1.5))
	dxDrawText("Q&A", x + boxSize[1]/2, sY/2 - boxSize[2]/2 + 15, _, _, tocolor(150, 150, 150), 1, fontBold, "center", "center")
	
	dxDrawText(amount .. "$", x + boxSize[1] - 10, sY/2 - boxSize[2]/2 + 15, _, _, tocolor(140, 180, 120), 1, fontSmall, "right", "center")
	dxDrawText(questions[currentQuestion][1], x + boxSize[1]/2, sY/2 - boxSize[2]/2 + 40, _, _, tocolor(255, 255, 255, a), 1, fontBold2, "center", "center")

	for k = 1, 4 do
		dxDrawRectangle(x + 17, sY/2 - 5+ (k-1)*35, boxSize[1] - 34, 30, tocolor(65, 65, 65, a))
		if isCursorInBox(x + 17, sY/2 - 5+ (k-1)*35, boxSize[1] - 34, 30) or currentSelected == k then
			dxDrawRectangle(x + 17 + 1, sY/2 - 5+ (k-1)*35 + 1, boxSize[1] - 34 - 2, 30 - 2, tocolor(65, 65, 65, a))
			dxDrawText(questions[currentQuestion][k + 1], x + boxSize[1]/2, sY/2 + 10 + (k-1)*35, _, _, tocolor(220, 220, 220), 1, fontSmall, "center", "center")
		else
			dxDrawRectangle(x + 17 + 1, sY/2 - 5+ (k-1)*35 + 1, boxSize[1] - 34 - 2, 30 - 2, tocolor(35, 35, 35, a))
			dxDrawText(questions[currentQuestion][k + 1], x + boxSize[1]/2, sY/2 + 10 + (k-1)*35, _, _, tocolor(150, 150, 150), 1, fontSmall, "center", "center")
		end
	end
end

setTimer(createQnA, (1000*60)*tonumber(math.random(10,20)), 0)

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if boxState == "open" and button == "left" and state == "down" then
		for k = 1, 4 do
			if isCursorInBox(x + 17, sY/2 - 5+ (k-1)*35, boxSize[1] - 34, 30) then
				currentSelected = k
				boxState = "close"
				stateTick = getTickCount()
				QnAshowed = false
				if questions[currentQuestion][6] == k then
					triggerServerEvent("changeDataSync", localPlayer, "a.Money", getElementData(localPlayer, "a.Money") + amount)
					outputChatBox("#E18C88► Kérdés: #FFFFFFA válaszod helyes volt, nyereményed: #9BE48F" .. amount .. "$#FFFFFF.", 255, 255, 255, true)
				else
					outputChatBox("#E18C88► Kérdés: #FFFFFFA válaszod helytelen volt#FFFFFF.", 255, 255, 255, true)
				end
			end
		end
	end
end
addEventHandler("onClientClick", root, onClick)

function makeCoinFlip(commandName, amountToFlip, multipler)
	if amountToFlip and multipler then
		if inProgress then
			outputChatBox("#E48F8F► Hiba: #FFFFFFEgy coinflip már folyamatban van.", 255, 255, 255, true)
			return
		end

		if isTimer(spamTimer) then
			outputChatBox("#E48F8F► Hiba: #FFFFFFCsak 2 percenként használhatod a funkciót.", 255, 255, 255, true)
			return
		end

		local currentPlayerMoney = getElementData(localPlayer, "a.Money")
		if currentPlayerMoney < tonumber(amountToFlip) then
			outputChatBox("#E48F8F► Hiba: #FFFFFFNincs elég pénzed a funkció végbeviteléhez.", 255, 255, 255, true)
			return
		end

		flipAmount = tonumber(amountToFlip)
		multipler = tonumber(multipler)

		if flipAmount > 1500 then
			outputChatBox("#E48F8F► Hiba: #FFFFFFA legmagasabb összeg 1500$, amit felrakhatsz.", 255, 255, 255, true)
			inProgress = false
			return
		end

		if multipler > 3 or multipler < 2 then
			outputChatBox("#E48F8F► Hiba: #FFFFFFA legnagyobb szorzó 3.", 255, 255, 255, true)
			inProgress = false
			return
		end
		
		triggerServerEvent("changeDataSync", localPlayer, "a.Money", getElementData(localPlayer, "a.Money") - tonumber(flipAmount))
		addEventHandler("onClientRender", root, renderCoinFlip)
		inProgress = true

		setTimer(function()
			if a1 < (255/2) then
				outputChatBox("#5AB1D9► Coinflip: #FFFFFFElvesztetted a játékot. Veszteség: #E48F8F" .. flipAmount .. "$.", 255, 255, 255, true)
				removeEventHandler("onClientRender", root, renderCoinFlip)
				inProgress = false
			else
				outputChatBox("#5AB1D9► Coinflip: #FFFFFFSikeresen megnyerted a játékot. Nyereményed: #9BE48F" .. flipAmount*multipler .. "$.", 255, 255, 255, true)
				triggerServerEvent("changeDataSync", localPlayer, "a.Money", getElementData(localPlayer, "a.Money") + tonumber(flipAmount*multipler))
				removeEventHandler("onClientRender", root, renderCoinFlip)
				inProgress = false
			end
		end, 5000, 1)
		spamTimer = setTimer(function() end, 1000*60*2, 1)
	else
		outputChatBox("#D9B45A► Használat: #FFFFFF/" .. commandName .. " [mennyiség] [szorzó]", 255, 255, 255, true)
	end
end
addCommandHandler("coinflip", makeCoinFlip)

function renderCoinFlip()
	a1 = interpolateBetween(0, 0, 0, 255, 0, 0, getTickCount()/2000, "SineCurve")
	a2 = interpolateBetween(255, 0, 0, 0, 0, 0, getTickCount()/2000, "SineCurve")

	dxDrawImage(sX/2 - 128, 20, 256, 256, "files/icons/coins/zelenskycoin.png", 0, 0, 200, tocolor(220, 220, 220, a1))
	dxDrawImage(sX/2 - 128, 20, 256, 256, "files/icons/coins/putincoin.png", 0, 0, 200, tocolor(220, 220, 220, a2))
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

function isCursorInBox ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end



function hiText()
    outputChatBox("#E18C88[alphaGames] #ffffffHi!", 255, 255, 255, true)
end
addCommandHandler("hello", hiText)
addCommandHandler("hi", hiText)

--** CAMERA MOVEMENT

function setCamPos(cmd, arg)
	if getElementData(localPlayer, "adminLevel") >= 3 then
		if not (arg) then
			outputChatBox("[use]: /" .. cmd .. " [start/end]", 255, 255, 255, true)
		else
			arg = tostring(arg)
			if arg == "start" then
				camStartX, camStartY, camStartZ, camStartOX, camStartOY, camStartOZ = getCameraMatrix(localPlayer);
				outputChatBox("camera movement start pos set.", 255, 255, 255, true)
			elseif arg == "end" then
				camStopX, camStopY, camStopZ, camStopOX, camStopOY, camStopOZ = getCameraMatrix(localPlayer);
				outputChatBox("camera movement end pos set.", 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("setcampos", setCamPos)

function moveCamera(cmd, time)
	if camStartX and camStartY and camStartZ and camStartOX and camStartOY and camStartOZ and camStopX and camStopY and camStopZ and camStopOX and camStopOY and camStopOZ and tonumber(time) then
		smoothMoveCamera(camStartX, camStartY, camStartZ, camStartOX, camStartOY, camStartOZ, camStopX, camStopY, camStopZ, camStopOX, camStopOY, camStopOZ, (tonumber(time)*1000))
	else
		outputChatBox("[use]: /" .. cmd .. " [time in seconds]", 255, 255, 255, true)
	end
end
addCommandHandler("movecam", moveCamera)

function stopCamera()
	removeCamHandler()
	setCameraTarget(localPlayer)
	--fadeCamera(true)
end
addCommandHandler("stopcam", stopCamera)

local sm = {}
sm.moov = 0

function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end

local start
local animTime
local tempPos = {{},{}}
local tempPos2 = {{},{}}

local function camRender()
	local now = getTickCount()
	if (sm.moov == 1) then
		local x1, y1, z1 = interpolateBetween(tempPos[1][1], tempPos[1][2], tempPos[1][3], tempPos2[1][1], tempPos2[1][2], tempPos2[1][3], (now-start)/animTime, "OutBack")
		local x2,y2,z2 = interpolateBetween(tempPos[2][1], tempPos[2][2], tempPos[2][3], tempPos2[2][1], tempPos2[2][2], tempPos2[2][3], (now-start)/animTime, "OutBack")
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	else
		removeEventHandler("onClientRender",root,camRender)
		fadeCamera(true)
	end
end

function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1) then
		killTimer(timer1)
		killTimer(timer2)
		removeEventHandler("onClientRender",root,camRender)
		fadeCamera(true)
	end
	fadeCamera(true)
	sm.moov = 1
	timer1 = setTimer(removeCamHandler,time,1)
	timer2 = setTimer(fadeCamera, time-1000, 1, false) -- 
	start = getTickCount()
	animTime = time
	tempPos[1] = {x1,y1,z1}
	tempPos[2] = {x1t,y1t,z1t}
	tempPos2[1] = {x2,y2,z2}
	tempPos2[2] = {x2t,y2t,z2t}
	addEventHandler("onClientRender",root,camRender)
	return true
end

function createMisi()
	if isMisi then
		--isMisi = false
		--removeEventHandler("onClientRender", root, onMisi)
	else
		--isMisi = true
		--addEventHandler("onClientRender", root, onMisi)
	end
	outputChatBox("ne használd ezt a parancsot.", 255, 2, 2, true)
end
addCommandHandler("misi", createMisi)

function onMisi()
	dxDrawImage(sX - 515, sY - 515, 512, 512, "files/icons/misi.png", 0, 0, 0, tocolor(200, 200, 200, 200))
end

function changeTimeClient(command, time)
	if tonumber(time) then
		change = setTime(time, 0)
		if (change) then
			outputChatBox("#9BE48F[Beállítás]: #FFFFFFSikeresen beállítottad a saját játékmeneted idejét #9BE48F" .. time .. "#FFFFFF órára.", 255, 255, 255, true)
		end
	else
		outputChatBox("#8FC3E4[Használat]: #FFFFFF/" .. command .. " [óra]", 255, 255, 255, true)
	end
end
addCommandHandler( "settime", changeTimeClient)

function changeWeatherClient(command, weather)
	if tonumber(weather) then
		change = setWeather(weather)
		if (change) then
			outputChatBox("#9BE48F[Beállítás]: #FFFFFFSikeresen beállítottad a saját játékmeneted időjárását #9BE48F" .. weather .. "#FFFFFF weatherID-ra.", 255, 255, 255, true)
		end
	else
		outputChatBox("#8FC3E4[Használat]: #FFFFFF/" .. command .. " [ID]", 255, 255, 255, true)
		outputChatBox("#8FC3E4[Segédlet]: #FFFFFFhttps://wiki.multitheftauto.com/wiki/Weather", 255, 255, 255, true)
	end
end
addCommandHandler("setweather", changeWeatherClient)

