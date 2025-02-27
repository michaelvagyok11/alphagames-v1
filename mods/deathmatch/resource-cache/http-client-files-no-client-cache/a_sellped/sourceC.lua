screenX, screenY = guiGetScreenSize()

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

Rubik = dxCreateFont("Rubik.ttf", respc(14), false, "proof")

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
	itemName = exports.a_inventory:getItemName(itemId)

	panelSizeX = panelSizeX + dxGetTextWidth(itemName)
	panelState = true

	addEventHandler("onClientRender", getRootElement(), renderTradePanel)
	addEventHandler("onClientClick", getRootElement(), handleClicks)

	setElementData(localPlayer, "selling_active", true)
end
addEvent("createDeal", true)
addEventHandler("createDeal", getRootElement(), createDeal)

local buttonWeight, buttonHeight = respc(135), respc(30) 
local panelX, panelY = (screenX - panelSizeX) / 2, (screenY - panelSizeY) / 2

function renderTradePanel()
	if not panelState and not getElementData(localPlayer, "selling_active") then 
		return
	end
	activeButton = false
	dxDrawRectangle(panelX, panelY, panelSizeX, panelSizeY, panelColors.background)
	dxDrawRectangle(panelX, panelY, panelSizeX, respc(20), panelColors.header)
	dxDrawText("alphaGames", panelX + panelSizeX / 2, panelY + respc(1), nil, nil, panelColors.fontColor, 0.8, Rubik, "center")
	dxDrawText("Szeretnéd eladni a(z) #3d7abc" .. itemName .. " #c8c8c8tárgyadat?\nEzért a tárgyért ennyit kapsz: #7cc576" .. itemPrice .. "$", panelX + panelSizeX / 2, panelY + respc(40) + respc(5), nil, nil, panelColors.fontColor, 0.8, Rubik, "center", "center", false, false, false, true)

	createButton("accept", "Elfogadás", panelX + respc(10), panelY + panelSizeY - buttonHeight - respc(10), buttonWeight, buttonHeight, {124, 197, 118})
	createButton("decline", "Elutasítás", panelX + panelSizeX - buttonWeight - respc(10), panelY + panelSizeY - buttonHeight - respc(10), buttonWeight, buttonHeight, {215, 89, 89})
end

function handleClicks(key, state)
	if not panelState then 
		return
	end
	if key == "left" and state == "down" then 
		if activeButton then 
			if activeButton == "accept" then
				triggerServerEvent("acceptTrade", localPlayer, databaseID, id)
				removeEventHandler("onClientRender", getRootElement(), renderTradePanel)
				removeEventHandler("onClientClick", getRootElement(), handleClicks)
				panelSizeX = respc(300)
				panelState = false
				setElementData(localPlayer, "selling_active", false)
			elseif activeButton == "decline" then 
				removeEventHandler("onClientRender", getRootElement(), renderTradePanel)
				removeEventHandler("onClientClick", getRootElement(), handleClicks)
				panelSizeX = respc(300)
				panelState = false
				setElementData(localPlayer, "selling_active", false)
				outputChatBox("#E18C88[alphaGames]: #ffffffSikeresen #d75959elutasítottad.", 255, 255, 255, true)
			end
		end
	end
end

addEvent("lobbyMusicPlay", true)
addEventHandler("lobbyMusicPlay", getRootElement(),
	function ()
		local x, y, z = 250.0498046875, 1822.3505859375, 4.7109375
		local sound = playSound3D("https://rautemusik-de-hz-fal-stream14.radiohost.de/harder?ref=mp3&amsparams=mp3", x, y, z, false)
		setSoundVolume(sound, 1.5)
		setSoundMaxDistance(sound, 100)
	end
)

addCommandHandler("nightvision",
	function ()
		local effect = (getCameraGoggleEffect() == "normal") and "thermalvision" or "normal"
		setCameraGoggleEffect(effect, false)
		local sound = playSound("nvg.wav", false)
		setSoundVolume(sound, 1.5)
	end
)