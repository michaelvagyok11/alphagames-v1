local sX, sY = guiGetScreenSize();
local sizeX, sizeY = 600, 175;
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 12, false, "cleartype")
local poppinsSmall2 = dxCreateFont("files/fonts/Poppins-Regular.ttf", 20, false, "cleartype")
local poppinsSmall3 = dxCreateFont("files/fonts/Poppins-Regular.ttf", 14, false, "cleartype")

function onRender()
	local nowTick = getTickCount();
	local elapsedTime = nowTick - changeTick
	local duration = elapsedTime / 1500
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY + 25, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY  + 25 - 2, tocolor(35, 35, 35, a))
	dxDrawRectangle(startX, startY, sizeX, 25, tocolor(65, 65, 65, a))
	dxDrawText("#E18C88alpha#c8c8c8Games - Névválasztó", startX + 5, startY + 25 / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "left", "center", false, false, false, true)
	
	dxDrawText("Szia #9BE48F" .. getPlayerName(localPlayer) .. "#c8c8c8!", startX + sizeX / 2, startY + 25 + 20, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall2, "center", "center", false, false, false, true)
	dxDrawText("Kérlek válassz egy nevet magadnak, amivel látható leszel a többi játékos számára.\nEzt később csak #8FC3E4Discord#c8c8c8on tudod kérelemmel megváltoztatni.", startX + sizeX / 2, startY + 25 + 60, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall3, "center", "center", false, false, false, true)

	dxDrawRectangle(startX + 200, startY + sizeY - 10, sizeX - 400, 25, tocolor(65, 65, 65, a))
	if isMouseInPosition(startX + 200, startY + sizeY - 10, sizeX - 400, 25) then
		dxDrawRectangle(startX + 200 + 1, startY + sizeY - 10 + 1, sizeX - 400 - 2, 25 - 2, tocolor(65, 65, 65, a))
	else
		dxDrawRectangle(startX + 200 + 1, startY + sizeY - 10 + 1, sizeX - 400 - 2, 25 - 2, tocolor(35, 35, 35, a))
	end	
	dxDrawText("Megerősítés", startX + 200 + (sizeX - 400) / 2, startY + sizeY - 10 + 25 / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "center", "center", false, false, false, true)
end

function onClick(button, state)
	if button == "left" and state == "down" then
		if isMouseInPosition(startX + 200, startY + sizeY - 10, sizeX - 400, 25) then
			local inputText = exports.aDx:dxGetEditText("a.NameInput")
			if (inputText) then
				if string.len(inputText) <= 3 then
					exports.aInfobox:makeNotification(2, "Minimum 4 karakterből álljon a neved.")
				else
					inputText = inputText:gsub("%p", "")
					triggerServerEvent("changePlayerName", localPlayer, localPlayer, tostring(inputText))
					exports.aInfobox:makeNotification(1, "Sikeresen beállítottad a nevedet. #9BE48F(" .. inputText .. ")")
					removeEventHandler("onClientRender", root, onRender)
					removeEventHandler("onClientClick", root, onClick)
					exports.aDx:dxDestroyEdit("a.NameInput")
					setElementFrozen(localPlayer, false)
					setElementAlpha(localPlayer, 255)
				end
			else
				exports.aInfobox:makeNotification(2, "Mielőtt továbblépsz, add meg a nevedet.")
			end
		end
	end
end


function showNamePanel(element)
	if (element == localPlayer) then
		changeTick = getTickCount()
		exports.aDx:dxCreateEdit("a.NameInput", "", "Megjelenített neved", startX + 50, startY + 125, sizeX - 100, 30, {125, 125, 125}, 12, 1)
		addEventHandler("onClientRender", root, onRender)
		addEventHandler("onClientClick", root, onClick)
		setElementFrozen(localPlayer, true)
		setElementAlpha(localPlayer, 30)
	end
end
addEvent("showNamePanel", true)
addEventHandler("showNamePanel", root, showNamePanel)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end