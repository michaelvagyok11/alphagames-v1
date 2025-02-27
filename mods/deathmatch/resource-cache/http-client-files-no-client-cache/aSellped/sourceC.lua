screenX, screenY = guiGetScreenSize()
sX, sY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local panelColors = {
	background = tocolor(30, 30, 30),
	fontColor = tocolor(200, 200, 200),
	header = tocolor(15, 15, 15)

}

local poppinsBoldVeryBig = dxCreateFont("files/Poppins-SemiBold.ttf", respc(20), false, "cleartype")
local poppinsBold = dxCreateFont("files/Poppins-SemiBold.ttf", respc(15), false, "cleartype")
local poppinsRegularVeryBig = dxCreateFont("files/Poppins-Regular.ttf", respc(15), false, "cleartype")

local poppinsBoldBig = dxCreateFont("files/Poppins-SemiBold.ttf", respc(15), false, "cleartype")
local poppinsLightBig = dxCreateFont("files/Poppins-Light.ttf", respc(14), false, "cleartype")

local itemName = ""

local panelState = false

local panelSizeX, panelSizeY = respc(300) + dxGetTextWidth(itemName), respc(110)

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)

function createDeal(dbID, itemId, itePrice)
	if panelState and getElementData(localPlayer, "selling_active") then 
		return
	end

	itemPrice = itePrice

	databaseID = dbID
	id = itemId
	triggerServerEvent("changeDataSync", localPlayer, "faszomitemid", id)
	itemName = exports.a_inventory:getItemName(itemId)

	panelSizeX = panelSizeX + dxGetTextWidth(itemName)
	panelState = true

	addEventHandler("onClientRender", getRootElement(), renderTradePanel)
	addEventHandler("onClientClick", getRootElement(), handleClicks)

	triggerServerEvent("changeDataSync", localPlayer, "selling_active", true)
end
addEvent("createDeal", true)
addEventHandler("createDeal", getRootElement(), createDeal)

local sizeX, sizeY = respc(400), respc(200);
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

function renderTradePanel()
	if not panelState and not getElementData(localPlayer, "selling_active") then 
		return
	end

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, 150))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, 150))
	dxDrawText("#E48F8Falpha", startX + respc(2), startY - respc(8.5), _, _, tocolor(200, 200, 200), 1, poppinsBoldBig, "left", "center", false, false, false, true)
    dxDrawText("SELLPED", startX + respc(4) + dxGetTextWidth("alpha", 1, poppinsBoldBig), startY - respc(8.5), _, _, tocolor(200, 200, 200), 1, poppinsLightBig, "left", "center", false, false, false, true)
	dxDrawText("Szeretnéd eladni a(z) #E48F8F" .. itemName .. " #c8c8c8tárgyadat?\nEzért a tárgyért ennyit kapsz: #7cc576" .. itemPrice .. "$", startX + sizeX / 2, startY + respc(60) + respc(5), nil, nil, panelColors.fontColor, 1, poppinsBoldBig, "center", "center", false, false, false, true)

	dxDrawImage(startX + sizeX / 2.18, startY + respc(100), 35, 35, ":a_inventory/files/items/" .. getElementData(localPlayer, "faszomitemid") - 1 .. ".png", 0, 0, 0, tocolor(255, 255, 255))

	dxDrawRectangle(startX + respc(20), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35), tocolor(75, 75, 75, 150))
	if isMouseInPosition(startX + respc(20), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
		dxDrawRectangle(startX + respc(20) + 1, startY + respc(150) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(75, 75, 75, 150))
	else
		dxDrawRectangle(startX + respc(20) + 1, startY + respc(150) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(35, 35, 35, 150))
	end
	dxDrawText("Elfogadás", startX + respc(20) + ((sizeX - respc(40)) / 2 - respc(10)) / 2, startY + respc(150) + respc(35)/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsBold, "center", "center", false, false, false, true)

	dxDrawRectangle(startX + sizeX / 2 + respc(10), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35), tocolor(75, 75, 75, 150))
	if isMouseInPosition(startX + sizeX / 2 + respc(10), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
		dxDrawRectangle(startX + sizeX / 2 + respc(10) + 1, startY + respc(150) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(75, 75, 75, 150))
	else
		dxDrawRectangle(startX + sizeX / 2 + respc(10) + 1, startY + respc(150) + 1, (sizeX - respc(40)) / 2 - respc(10) - 2, respc(35) - 2, tocolor(35, 35, 35, 150))
	end
	dxDrawText("Elutasítás", startX + sizeX / 2 + respc(10) + ((sizeX - respc(40)) / 2 - respc(10)) / 2, startY + respc(150) + respc(35)/2, _, _, tocolor(200, 200, 200, 150), 1, poppinsBold, "center", "center", false, false, false, true)
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

function handleClicks(key, state)
	if not panelState then 
		return
	end
	if key == "left" and state == "down" then 
		if isMouseInPosition(startX + respc(20), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
			triggerServerEvent("acceptTrade", localPlayer, databaseID, id)
			removeEventHandler("onClientRender", getRootElement(), renderTradePanel)
			removeEventHandler("onClientClick", getRootElement(), handleClicks)
			panelSizeX = respc(300)
			panelState = false
			triggerServerEvent("changeDataSync", localPlayer, "selling_active", false)
		elseif isMouseInPosition(startX + sizeX / 2 + respc(10), startY + respc(150), (sizeX - respc(40)) / 2 - respc(10), respc(35)) then
			removeEventHandler("onClientRender", getRootElement(), renderTradePanel)
			removeEventHandler("onClientClick", getRootElement(), handleClicks)
			panelSizeX = respc(300)
			panelState = false
			triggerServerEvent("changeDataSync", localPlayer, "selling_active", false)
			outputChatBox("#E18C88[alphaGames]: #ffffffSikeresen #d75959elutasítottad.", 255, 255, 255, true)
		end
	end
end