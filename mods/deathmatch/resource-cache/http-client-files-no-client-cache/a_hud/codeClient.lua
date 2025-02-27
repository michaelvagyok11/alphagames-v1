local renderData = {}
renderData.pos = {}

renderData.pos.sX, renderData.pos.sY = guiGetScreenSize();
renderData.pos.sizeX, renderData.pos.sizeY = 400, 75; -- ** MANIPULÁLT MÉRETEK AZ ALSÓ CSÍK MIATT!
renderData.pos.startX, renderData.pos.startY = renderData.pos.sX - renderData.pos.sizeX - 10, 10;

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 12, false, "cleartype")
local poppinsSmall2 = dxCreateFont("files/fonts/Poppins-Regular.ttf", 11, false, "cleartype")

local movingOffsetX, movingOffsetY = 0, 0;
local isMoving = false;

local textures = {}
local fxResources = {
	["heart"] = {"files/img/heart.png"},
	["armor"] = {"files/img/armor.png"},
	["money"] = {"files/img/money.png"},
	["pp"] = {"files/img/premium.png"},
	["xp"] = {"files/img/experience.png"},
	["clock"] = {"files/img/clock.png"},
}

function onStart()
	for i, v in pairs(fxResources) do
		textures[i] = dxCreateTexture(v[1], "argb", true, "clamp")
	end
	loadHUD()
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop()
	saveHUD()
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)

function resetHUD()
	renderData.pos.sX, renderData.pos.sY = guiGetScreenSize();
	renderData.pos.sizeX, renderData.pos.sizeY = 400, 75; -- ** MANIPULÁLT MÉRETEK AZ ALSÓ CSÍK MIATT!
	renderData.pos.startX, renderData.pos.startY = renderData.pos.sX - renderData.pos.sizeX - 10, 10;
end

function resetHUDCMD()
	resetHUD()
	exports.a_interface:makeNotification(1, "Sikeresen visszaállítottad a HUD pozícióját!")
end
addCommandHandler("resethud", resetHUDCMD)

render = {}

function onRender()
	if not getElementData(localPlayer, "a.HUDshowed") then return end
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end

	if (isCursorShowing() and isMoving) then
		local cursorX, cursorY = getCursorPosition();

		cursorX = cursorX * renderData.pos.sX;
		cursorY = cursorY * renderData.pos.sY;
		
		renderData.pos.startX = cursorX - movingOffsetX;
		renderData.pos.startY = cursorY - movingOffsetY;
	end

	dxDrawRectangle(renderData.pos.startX, renderData.pos.startY, renderData.pos.sizeX, renderData.pos.sizeY + 25, tocolor(65, 65, 65))
	dxDrawRectangle(renderData.pos.startX + 1, renderData.pos.startY + 1, renderData.pos.sizeX - 2, renderData.pos.sizeY  + 25 - 2, tocolor(35, 35, 35))
	
	local playerHealth = getElementHealth(localPlayer);

	dxDrawCircle(renderData.pos.startX + 40, renderData.pos.startY + renderData.pos.sizeY / 2, 25, -90, 360, tocolor(65, 65, 65, 200), tocolor(35, 35, 35, 200), 1000)
	dxDrawCircle(renderData.pos.startX + 40, renderData.pos.startY + renderData.pos.sizeY / 2, 25, -90, -90 + 360/100*playerHealth, tocolor(230, 140, 140), tocolor(230/2, 140/2, 140/2), 1000)
	dxDrawCircle(renderData.pos.startX + 40, renderData.pos.startY + renderData.pos.sizeY / 2, 24, -90, 360, tocolor(35, 35, 35, 200), tocolor(2, 2, 2, 200), 1000)
	dxDrawImage(renderData.pos.startX + 40 - 10, renderData.pos.startY + renderData.pos.sizeY / 2 - 10, 20, 20, textures["heart"], 0, 0, 0, tocolor(230, 140, 140, 200))

	local playerArmor = getPedArmor(localPlayer);

	dxDrawCircle(renderData.pos.startX + 110, renderData.pos.startY + renderData.pos.sizeY / 2, 25, -90, 360, tocolor(65, 65, 65, 200), tocolor(35, 35, 35, 200), 1000)
	dxDrawCircle(renderData.pos.startX + 110, renderData.pos.startY + renderData.pos.sizeY / 2, 25, -90, -90 + 360/100*playerArmor, tocolor(140, 195, 230), tocolor(140/2, 195/2, 230/2), 1000)
	dxDrawCircle(renderData.pos.startX + 110, renderData.pos.startY + renderData.pos.sizeY / 2, 24, -90, 360, tocolor(35, 35, 35, 200), tocolor(2, 2, 2, 200), 1000)
	dxDrawImage(renderData.pos.startX + 110 - 10, renderData.pos.startY + renderData.pos.sizeY / 2 - 10, 20, 20, textures["armor"], 0, 0, 0, tocolor(140, 195, 230, 200))

	local playerMoney = getElementData(localPlayer, "a.Money");
	playerMoney = num_formatting(tonumber(playerMoney))

	dxDrawRectangle(renderData.pos.startX + 150, renderData.pos.startY + 25/3, 110, 25, tocolor(65, 65, 65))
	dxDrawRectangle(renderData.pos.startX + 150 + 1, renderData.pos.startY + 25/3 + 1, 110 - 2, 25 - 2, tocolor(35, 35, 35))
	dxDrawImage(renderData.pos.startX + 150 + 8, renderData.pos.startY + 25/3 + 4, 16, 16, textures["money"], 0, 0, 0, tocolor(200, 200, 90))
	dxDrawText(playerMoney .. "#C4CD5D $", renderData.pos.startX + 150 + 110 - 10, renderData.pos.startY + 25/3 + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local playerPremium = getElementData(localPlayer, "a.Premiumpont");
	playerPremium = num_formatting(tonumber(playerPremium))

	dxDrawRectangle(renderData.pos.startX + 150, renderData.pos.startY + (25/3) * 2 + 25, 110, 25, tocolor(65, 65, 65))
	dxDrawRectangle(renderData.pos.startX + 150 + 1, renderData.pos.startY + (25/3) * 2 + 25 + 1, 110 - 2, 25 - 2, tocolor(35, 35, 35))
	dxDrawImage(renderData.pos.startX + 150 + 8, renderData.pos.startY + (25/3) * 2 + 25 + 4, 16, 16, textures["pp"], 0, 0, 0, tocolor(140, 195, 230))
	dxDrawText(playerPremium .. "#8FC3E4 PP", renderData.pos.startX + 150 + 110 - 10, renderData.pos.startY +(25/3) * 2 + 25 + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local playerExperience = getElementData(localPlayer, "a.Experience");
	playerExperience = num_formatting(tonumber(playerExperience))

	dxDrawRectangle(renderData.pos.startX + 150 + 110 + 20, renderData.pos.startY + 25/3, 110, 25, tocolor(65, 65, 65))
	dxDrawRectangle(renderData.pos.startX + 150 + 110 + 20 + 1, renderData.pos.startY + 25/3 + 1, 110 - 2, 25 - 2, tocolor(35, 35, 35))
	dxDrawImage(renderData.pos.startX + 280 + 8, renderData.pos.startY + 25/3 + 4, 16, 16, textures["xp"], 0, 0, 0, tocolor(230, 140, 140))
	dxDrawText(playerExperience .. "#E48F8F XP", renderData.pos.startX + 150 + 110 + 20 + 110 - 10, renderData.pos.startY + 25/3 + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local currentTime = getRealTime();

	if currentTime.minute < 10 then 
		currentTime.minute = "0"..currentTime.minute
	end 
	 
	if currentTime.hour < 10 then 
		currentTime.hour = "0"..currentTime.hour
	end
	 
	if currentTime.second < 10 then 
		currentTime.second = "0"..currentTime.second
	end

	dxDrawRectangle(renderData.pos.startX + 150 + 110 + 20, renderData.pos.startY + (25/3) * 2 + 25, 110, 25, tocolor(65, 65, 65))
	dxDrawRectangle(renderData.pos.startX + 150 + 110 + 20 + 1, renderData.pos.startY + (25/3) * 2 + 25 + 1, 110 - 2, 25 - 2, tocolor(35, 35, 35))
	dxDrawImage(renderData.pos.startX + 280 + 8, renderData.pos.startY + (25/3) * 2 + 25 + 4, 16, 16, textures["clock"], 0, 0, 0, tocolor(155, 230, 140))
	dxDrawText(currentTime["hour"] .. "#9BE48F:#c8c8c8" .. currentTime["minute"] .. "#9BE48F:#c8c8c8" .. currentTime["second"], renderData.pos.startX + 150 + 110 + 20 + 110 - 10, renderData.pos.startY + (25/3) * 2 + 25 + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local footerText = "alphaGames v1.9 - " .. string.format("%04d.%02d.%02d", currentTime.year + 1900, currentTime.month + 1, currentTime.monthday) .. " - " .. getCurrentFPS() .. " FPS - " .. getPlayerPing(localPlayer) .. " ms";
	local footerWidth = dxGetTextWidth(footerText, 1, poppinsSmall2, false)

	dxDrawText(footerText, renderData.pos.startX + renderData.pos.sizeX / 2, renderData.pos.startY + renderData.pos.sizeY + 15, _, _, tocolor(150, 150, 150), 1, poppinsSmall2, "center", "center", false, false, false, true)
	dxDrawRectangle(renderData.pos.startX + 50, renderData.pos.startY + renderData.pos.sizeY, renderData.pos.sizeX - 100, 2, tocolor(65, 65, 65))

end
setTimer(onRender, 5, 0)

function num_formatting(amount)
	local formatted = amount
	while true do  
	  	formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
	  	if (k==0) then
			break
	  	end
	end
	return formatted
end

local fps = 0
local nextTick = 0
function getCurrentFPS() 
    return math.floor(fps)
end

local function updateFPS(msSinceLastFrame)
    local now = getTickCount()
    if (now >= nextTick) then
        fps = (1 / msSinceLastFrame) * 1000
        nextTick = now + 1000
    end
end
addEventHandler("onClientPreRender", root, updateFPS)

function onDamage()

end
addEventHandler("onClientPlayerDamage", root, onDamage)

function onToggleHUD()
	triggerServerEvent("changeDataSync", localPlayer, "a.HUDshowed", not (getElementData(localPlayer, "a.HUDshowed")))
end
addCommandHandler("toghud", onToggleHUD)

function loadHUD()
	if fileExists("hud.data") then
		local savefile = fileOpen("hud.data")

		if savefile then
			local savedata = fileRead(savefile, fileGetSize(savefile))

			if savedata then
				savedata = fromJSON(decodeString("tea", savedata, {key = "__DATAFILE__"}))
			end

			fileClose(savefile)

			if savedata then
				resetHUD()

				for k, v in pairs(savedata.pos) do
					renderData.pos[k] = tonumber(v)
				end
			end
		end
	end
end

function saveHUD()
	if getElementData(localPlayer, "loggedIn") then
		if fileExists("hud.data") then
		end

		local savedata = {
			pos = {},
		}

		for k, v in pairs(renderData.pos) do
			savedata.pos[k] = v
		end

		local savefile = fileCreate("hud.data")
		fileWrite(savefile, encodeString("tea", toJSON(savedata, true), {key = "__DATAFILE__"}))
		fileClose(savefile)
	end
end

addEventHandler('onClientClick', getRootElement(),
	function(button, state, cursorX, cursorY)
		if getElementData(localPlayer, "a.HUDshowed") then
			if (button == 'left' and state == 'down') then
				if (cursorX >= renderData.pos.startX and cursorX <= renderData.pos.startX + renderData.pos.sizeX and cursorY >= renderData.pos.startY and cursorY <= renderData.pos.startY + renderData.pos.sizeY) then
					isMoving = true;
					movingOffsetX = cursorX - renderData.pos.startX;
					movingOffsetY = cursorY - renderData.pos.startY;
				end
			else
				isMoving = false;
			end
		end
	end
)