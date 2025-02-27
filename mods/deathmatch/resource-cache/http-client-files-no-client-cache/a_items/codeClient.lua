local sX, sY = guiGetScreenSize();
local sizeX, sizeY = 400, 275;
local startX, startY = sX - sizeX - 50, sY / 2 - sizeY / 2;

local rows, coloumns = 0, 0;
local boxSize = 35;
local endColoumn = 10;

function changeInventoryState(state)
	if state == "open" then
		addEventHandler("onClientRender", root, onRender)
		openTick = getTickCount();
	elseif state == "close" then
		removeEventHandler("onClientRender", root, onRender)
	end
end

function onRender()
	local nowTick = getTickCount();
	local elapsedTime = nowTick - openTick;
	local duration = elapsedTime / 500;
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
	dxDrawRectangle(startX, startY, sizeX, 20, tocolor(65, 65, 65, a))

end

setTimer(changeInventoryState, 500, 1, "open")