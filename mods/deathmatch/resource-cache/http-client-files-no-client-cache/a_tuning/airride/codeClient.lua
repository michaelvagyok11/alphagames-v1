local sX, sY = guiGetScreenSize();
local airrideSize = {200, 95};
local isPanelOpen = false
local airrideHeader10 = dxCreateFont("files/fonts/Roboto-Condensed.ttf", 10, false, "antialiased")
local startX, startY = sX - airrideSize[1] - 15, sY/2 - airrideSize[2] / 2

local airrides = {
	{0.1},
	{0.05},
	{0},
	{-0.05},
	{-0.15},
}

function onAirrideRender()
	if not isPedInVehicle(localPlayer) then
		removeEventHandler("onClientRender", root, onAirrideRender)
		return
	end
	if isPanelMoving then
		local cX, cY = getCursorPosition();
		startX, startY = cX * sX - airrideSize[1] + 20, cY * sY -8
	else
		startX, startY = startX, startY
	end
	
	local nowTick = getTickCount();
	local elapsedTime = nowTick - openAirrideTick;
	local duration = elapsedTime / 500
	a3 = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	exports.a_core:dxDrawRoundedRectangle(startX, startY, airrideSize[1], airrideSize[2], tocolor(65, 65, 65, a3), 5)
	exports.a_core:dxDrawRoundedRectangle(startX + 2, startY + 2, airrideSize[1] - 4, airrideSize[2] - 4, tocolor(35, 35, 35, a3), 5)
	exports.a_core:dxDrawRoundedRectangle(startX, startY, airrideSize[1], 25, tocolor(65, 65, 65, a3), 5)
	dxDrawImage(startX + airrideSize[1] - 20, startY + 25/4 - 2, 16, 16, "files/img/move.png", 0, 0, 0, tocolor(100, 100, 100, a3))

	if isMouseInPosition(startX + airrideSize[1]/4 - 16, startY + 25, 32, 32) then
		dxDrawImage(startX + airrideSize[1]/4 - 16, startY + 25, 32, 32, "files/img/arrow.png", -90, 0, 0, tocolor(150, 150, 150, a3))
	else
		dxDrawImage(startX + airrideSize[1]/4 - 16, startY + 25, 32, 32, "files/img/arrow.png", -90, 0, 0, tocolor(75, 75, 75, a3))
	end
	
	if isMouseInPosition(startX + airrideSize[1]/4 - 16, startY + 60, 32, 32) then
		dxDrawImage(startX + airrideSize[1]/4 - 16, startY + 60, 32, 32, "files/img/arrow.png", 90, 0, 0, tocolor(150, 150, 150, a3))
	else
		dxDrawImage(startX + airrideSize[1]/4 - 16, startY + 60, 32, 32, "files/img/arrow.png", 90, 0, 0, tocolor(75, 75, 75, a3))
	end
	
	exports.a_core:dxDrawRoundedRectangle(startX + airrideSize[1]/2 + 5, startY + 30, 90, 55, tocolor(25, 25, 25, a3), 5)

	for i = 1, 5 do
		local veh = getPedOccupiedVehicle(localPlayer)
		airrideLevel = getElementData(veh, "a.AirrideLevel") or currentAirrideLevel
		if i <= airrideLevel then
			r, g, b = 155, 230, 140
		else
			r, g, b = 65, 65, 65
		end
		dxDrawRectangle(startX + airrideSize[1]/2 + 10, startY + 75 - ((i-1)*10), airrideSize[1] / 2 - 20, 5, tocolor(r, g, b, a3/2))
	end

	dxDrawText("#D19D6Balpha#c8c8c8Games - Airride", startX + 5, startY + 25/2, _, _, tocolor(200, 200, 200, a3), 1, airrideHeader10, "left", "center", false, false, false, true)
end

function onOpen()
	if isPanelOpen then
		isPanelOpen = false
		removeEventHandler("onClientRender", root, onAirrideRender)
		removeEventHandler("onClientClick", root, onAirrideClick)
	else
		if not isPedInVehicle(localPlayer) then
			return
		end

		local veh = getPedOccupiedVehicle(localPlayer)
		if getElementData(veh, "a.Airride") == false then
			return
		end

		isPanelOpen = true
		isPanelMoving = false
		changeAirride = false
		openAirrideTick = getTickCount()
		currentAirrideLevel = getElementData(getPedOccupiedVehicle(localPlayer), "a.AirrideLevel") or 1
		addEventHandler("onClientRender", root, onAirrideRender)
		addEventHandler("onClientClick", root, onAirrideClick)
	end
end
addCommandHandler("airride", onOpen)

function onAirrideClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" then
		if state == "down" then
			if isMouseInPosition(startX + airrideSize[1] - 20, startY + 25/4 - 2, 16, 16) then
				isPanelMoving = true
			end
		elseif state == "up" then
			isPanelMoving = false
		end
		if state == "down" then
			if isMouseInPosition(startX + airrideSize[1]/4 - 16, startY + 60, 32, 32) then
				if isTimer(spamTimer) then
					outputChatBox("#E48F8F[error]: #FFFFFFYou have to wait a sec.", 255, 255, 255, true)
					return
				end

				if currentAirrideLevel - 1 < 1 then
					currentAirrideLevel = 1
				else
					currentAirrideLevel = currentAirrideLevel - 1
				end

				target = airrides[currentAirrideLevel][1]
				triggerServerEvent("changeAirride", localPlayer, localPlayer, target)

				spamTimer = setTimer(function()
				end, 2500, 1)
			end
			if isMouseInPosition(startX + airrideSize[1]/4 - 16, startY + 25, 32, 32) then
				if isTimer(spamTimer) then
					outputChatBox("#E48F8F[error]: #FFFFFFYou have to wait a sec.", 255, 255, 255, true)
					return
				end

				if currentAirrideLevel + 1 > 5 then
					currentAirrideLevel = 5
				else
					currentAirrideLevel = currentAirrideLevel + 1
				end

				target = airrides[currentAirrideLevel][1]
				triggerServerEvent("changeAirride", localPlayer, localPlayer, target)
				

				spamTimer = setTimer(function()
				end, 2500, 1)
			end
		end
	end
end