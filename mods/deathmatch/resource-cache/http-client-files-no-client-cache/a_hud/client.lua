local sX, sY = guiGetScreenSize();
local sizeX, sizeY = 400, 75; -- ** MANIPULÁLT MÉRETEK AZ ALSÓ CSÍK MIATT!
local startX, startY = sX - sizeX - 10, 10;

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 12, false, "cleartype")
local poppinsSmall2 = dxCreateFont("files/fonts/Poppins-Regular.ttf", 11, false, "cleartype")

local circleScale, circleStroke = 50, 3
local circleLeft, circleTop = circleScale + 30, sY - circleScale - 20
local iconScale = 15

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
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onRender()
	if not getElementData(localPlayer, "a.HUDshowed") then return end
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end
	dxDrawRectangle(startX, startY, sizeX, sizeY + 25, tocolor(65, 65, 65))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY  + 25 - 2, tocolor(35, 35, 35))

	createCircle("bgHealth", circleScale, circleScale)
	createCircle("bgArmor", circleScale, circleScale)
	createCircleStroke("health", circleScale, circleScale, circleStroke)
	createCircleStroke("armor", circleScale, circleScale, circleStroke)

	local playerMoney = getElementData(localPlayer, "a.Money");
	playerMoney = num_formatting(tonumber(playerMoney))

	dxDrawRectangle(startX + 150, startY + 25/3, 110, 25, tocolor(65, 65, 65))
	dxDrawRectangle(startX + 150 + 1, startY + 25/3 + 1, 110 - 2, 25 - 2, tocolor(35, 35, 35))
	dxDrawImage(startX + 150 + 8, startY + 25/3 + 4, 16, 16, textures["money"], 0, 0, 0, tocolor(200, 200, 90))
	dxDrawText(playerMoney .. "#C4CD5D $", startX + 150 + 110 - 10, startY + 25/3 + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local playerPremium = getElementData(localPlayer, "a.Premiumpont");
	playerPremium = num_formatting(tonumber(playerPremium))

	dxDrawRectangle(startX + 150, startY + (25/3) * 2 + 25, 110, 25, tocolor(65, 65, 65))
	dxDrawRectangle(startX + 150 + 1, startY + (25/3) * 2 + 25 + 1, 110 - 2, 25 - 2, tocolor(35, 35, 35))
	dxDrawImage(startX + 150 + 8, startY + (25/3) * 2 + 25 + 4, 16, 16, textures["pp"], 0, 0, 0, tocolor(140, 195, 230))
	dxDrawText(playerPremium .. "#8FC3E4 PP", startX + 150 + 110 - 10, startY +(25/3) * 2 + 25 + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local playerExperience = getElementData(localPlayer, "a.Experience");
	playerExperience = num_formatting(tonumber(playerExperience))

	dxDrawRectangle(startX + 150 + 110 + 20, startY + 25/3, 110, 25, tocolor(65, 65, 65))
	dxDrawRectangle(startX + 150 + 110 + 20 + 1, startY + 25/3 + 1, 110 - 2, 25 - 2, tocolor(35, 35, 35))
	dxDrawImage(startX + 280 + 8, startY + 25/3 + 4, 16, 16, textures["xp"], 0, 0, 0, tocolor(230, 140, 140))
	dxDrawText(playerExperience .. "#E48F8F XP", startX + 150 + 110 + 20 + 110 - 10, startY + 25/3 + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

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

	if currentTime.month < 10 then
		currentTime.month = "0" .. (currentTime.month) + 1
	end
	if currentTime.monthday < 10 then
		currentTime.monthday = "0" .. (currentTime.monthday)
	end

	dxDrawRectangle(startX + 150 + 110 + 20, startY + (25/3) * 2 + 25, 110, 25, tocolor(65, 65, 65))
	dxDrawRectangle(startX + 150 + 110 + 20 + 1, startY + (25/3) * 2 + 25 + 1, 110 - 2, 25 - 2, tocolor(35, 35, 35))
	dxDrawImage(startX + 280 + 8, startY + (25/3) * 2 + 25 + 4, 16, 16, textures["clock"], 0, 0, 0, tocolor(155, 230, 140))
	dxDrawText(currentTime["hour"] .. "#9BE48F:#c8c8c8" .. currentTime["minute"] .. "#9BE48F:#c8c8c8" .. currentTime["second"], startX + 150 + 110 + 20 + 110 - 10, startY + (25/3) * 2 + 25 + 25 / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local footerText = "alphaGames v1.9 - " .. (currentTime["year"] + 1900) .. "." .. currentTime["month"] .. "." .. currentTime["monthday"] .. " - " .. getCurrentFPS() .. " FPS - " .. getPlayerPing(localPlayer) .. " ms";
	local footerWidth = dxGetTextWidth(footerText, 1, poppinsSmall2, false)

	dxDrawText(footerText, startX + sizeX / 2, startY + sizeY + 15, _, _, tocolor(150, 150, 150), 1, poppinsSmall2, "center", "center", false, false, false, true)
	dxDrawRectangle(startX + 50, startY + sizeY, sizeX - 100, 2, tocolor(65, 65, 65))

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

addEventHandler("onClientRender", root, function()
	drawItem("bgHealth", circleLeft, circleTop, tocolor(28, 28, 28, 170))
	drawItem("bgArmor", circleLeft + circleScale + 10, circleTop, tocolor(28, 28, 28, 170))

	drawItem("health", circleLeft, circleTop, tocolor(255, 255, 255))
	dxDrawImage(circleLeft + ((circleLeft/2) - (iconScale/2)), circleTop + ((circleScale/2) - (iconScale/2)), iconScale, iconScale, textures["heart"])
	drawItem("armor", circleLeft + circleScale + 10, circleTop, tocolor(255, 255, 255))
	dxDrawImage((circleLeft + circleScale + 10) + ((circleScale/2) - (iconScale/2)), circleTop + ((circleScale/2) - (iconScale/2)), iconScale, iconScale, textures["armor"])

	setSVGOffset("health", getElementHealth(localPlayer))
	setSVGOffset("armor", getPedArmor(localPlayer))
end)

function onToggleHUD()
	setElementData(localPlayer, "a.HUDshowed", not (getElementData(localPlayer, "a.HUDshowed")))
end
addCommandHandler("toghud", onToggleHUD)