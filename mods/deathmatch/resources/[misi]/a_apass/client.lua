local sX, sY = guiGetScreenSize();
local sizeX, sizeY = 600, 405;
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

local scrollingValue = 0;
local maxItemsShowed = 10;
local panelState = "closed";

local poppinsBoldSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 12, false, "cleartype")
local poppinsThinSmall = dxCreateFont("files/fonts/Poppins-Regular.ttf", 12, false, "cleartype")

function changeBpassState(state)
	if state == "close" then
		removeEventHandler("onClientRender", root, onRender)
		panelState = "closed"
		claimDetails = {}
	else
		addEventHandler("onClientRender", root, onRender)
		panelState = "opened"
		claimIsInProgress = false
		claimDetails = {}
		openTick = getTickCount()
	end
end

function onRender()
	if not panelState == "opened" then
		return
	end

	local nowTick = getTickCount()
	local elapsedTime = nowTick - openTick
	local duration = elapsedTime / 2000
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
	dxDrawRectangle(startX, startY, sizeX, 25, tocolor(65, 65, 65, a))
	dxDrawText("#E18C88alpha#c8c8c8Pass", startX + 5, startY + 25 / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldSmall, "left", "center", false, false, false, true)
	dxDrawImage(startX + sizeX - 20, startY + 6, 12, 12, "files/img/close.png", 0, 0, 0, tocolor(230, 140, 140, a/2))
	
	--dxDrawText("Megnevezés", startX + 45, startY + 25 + 12.5, _, _, tocolor(150, 150, 150, a), 1, poppinsThinSmall, "left", "center", false, false, false, true)
	--dxDrawText("Ár #9BE48F($)", startX + 275, startY + 25 + 12.5, _, _, tocolor(150, 150, 150, a), 1, poppinsThinSmall, "left", "center", false, false, false, true)
	--dxDrawText("Ár #8FC3E4(PP)", startX + 370, startY + 25 + 12.5, _, _, tocolor(150, 150, 150, a), 1, poppinsThinSmall, "center", "center", false, false, false, true)
	--dxDrawText("Itemkép", startX + 458, startY + 25 + 12.5, _, _, tocolor(150, 150, 150, a), 1, poppinsThinSmall, "center", "center", false, false, false, true)
end

function openClose(key, state)
	if key == "F2" and state then
		if panelState == "opened" then
			changeBpassState("close")
		else
			changeBpassState("open")
		end
	end
end
addEventHandler("onClientKey", root, openClose)