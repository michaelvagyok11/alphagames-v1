local sX, sY = guiGetScreenSize();
local sizeX, sizeY = 800, 400; 
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 12, false, "cleartype")
local poppinsSmall2 = dxCreateFont("files/fonts/Poppins-Regular.ttf", 14, false, "cleartype")

local helpdeskResources = {
	["Alapvető információk"] = {
		"> Hivatalos Discord szerver: dc.alphatdma.com \n\n> Hivatalos weboldal: alphatdma.com \n\n> Miért válassz minket? \nAz alphaGames szerverén elérhető minden, ami a szórakozáshoz és a kikapcsolódáshoz kell."
	},

	["Gamemode leírás (TDMA)"] = {
		"asdasdasd"
	},

	["Gamemode leírás (DRIFT)"] = {
		"asdasdasdasdas"
	},

	["Gamemode leírás (PURSUIT)"] = {
		"asdddddddddddddd"
	},

	["Prémiumpont"] = {
		"asdddddddddddddd"
	},

	["VIP"] = {
		"asdddddddddddddd"
	},
}

local currentSelected = "Alapvető információk"

function onRender()
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end
	dxDrawRectangle(startX, startY, sizeX, sizeY + 25, tocolor(65, 65, 65))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY  + 25 - 2, tocolor(35, 35, 35))
	dxDrawRectangle(startX, startY, sizeX, 25, tocolor(65, 65, 65))
	dxDrawText("#E18C88alpha#c8c8c8Games - Helpdesk", startX + 5, startY + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "left", "center", false, false, false, true)

	-- ** NAVBAR

	dxDrawRectangle(startX + 10, startY + 35, sizeX / 4, sizeY - 20, tocolor(40, 40, 40))

	loopNum = 0
	for i, v in pairs(helpdeskResources) do 
		dxDrawRectangle(startX + 15, startY + 37 + (loopNum * 40), sizeX / 4 - 10, 35, tocolor(65, 65, 65))
		if isMouseInPosition(startX + 15, startY + 37 + (loopNum * 40), sizeX / 4 - 10, 35) or currentSelected == i then
			dxDrawRectangle(startX + 15 + 1, startY + 37 + (loopNum * 40) + 1, sizeX / 4 - 10 - 2, 35 - 2, tocolor(65, 65, 65))
			dxDrawText(i, startX + 20, startY + 37 + (loopNum * 40) + 35 / 2, _, _, tocolor(150, 150, 150), 1, poppinsSmall, "left", "center", false, false, false, true)
		else
			dxDrawRectangle(startX + 15 + 1, startY + 37 + (loopNum * 40) + 1, sizeX / 4 - 10 - 2, 35 - 2, tocolor(35, 35, 35))
			dxDrawText(i, startX + 20, startY + 37 + (loopNum * 40) + 35 / 2, _, _, tocolor(100, 100, 100), 1, poppinsSmall, "left", "center", false, false, false, true)
		end
		loopNum = loopNum + 1
	end

	-- ** TEXT
	dxDrawRectangle(startX + 10 + sizeX / 4 + 10, startY + 35, sizeX - sizeX / 4 - 30, sizeY - 20, tocolor(50, 50, 50))

	dxDrawText(helpdeskResources[currentSelected][1], startX + sizeX / 4 + 30, startY + 45, startX + sizeX / 4 + 30 + sizeX - sizeX / 4 - 30, startY + 45 + sizeY - 20, tocolor(200, 200, 200), 1, poppinsSmall2, "left", "top", false, true)
end
addEventHandler("onClientRender", root, onRender)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end