local sX, sY = guiGetScreenSize();

function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(sX, 720, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

function getResponsiveMultipler()
	return responsiveMultipler
end

local sizeX, sizeY = respc(400), respc(75); -- ** MANIPULÁLT MÉRETEK AZ ALSÓ CSÍK MIATT!
local startX, startY = sX - sizeX - respc(10), respc(10);

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(11), false, "cleartype")
local poppinsSmall2 = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(10), false, "cleartype")

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
	if not (getElementData(localPlayer, "loggedIn")) or not getElementData(localPlayer, "a.HUDshowed") then
		return
	end
	--dxDrawRectangle(startX, startY, sizeX, sizeY + respc(25), tocolor(65, 65, 65, 50))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY + respc(25) - 2, tocolor(35, 35, 35, 200))
	
	local playerHealth = getElementHealth(localPlayer);

	dxDrawImage(startX + respc(22), startY + respc(12), respc(42), respc(42), textures["heart"], 0, 0, 0, tocolor(55, 55, 55, 200))
    dxDrawImageSection(startX + respc(22), startY + respc(12), respc(42), respc(42) * (playerHealth / 100), 0, 0, 512, 512 * (playerHealth / 100), textures["heart"], 0, 0, 0, tocolor(230/1.3, 140/1.3, 140/1.3))
	dxDrawText(math.floor(playerHealth) .. "%", startX + respc(22) + respc(50)/2, startY + respc(16) + respc(42) + respc(7.5), _, _, tocolor(200, 200, 200, 200), 1, poppinsSmall, "center", "center")

	local playerArmor = getPedArmor(localPlayer);

	dxDrawImage(startX + respc(22) + respc(42) + respc(22), startY + respc(12), respc(42), respc(42), textures["armor"], 0, 0, 0, tocolor(55, 55, 55, 200))
    dxDrawImageSection(startX + respc(22) + respc(42) + respc(22), startY + respc(12), respc(42), respc(42) * (playerArmor / 100), 0, 0, 512, 512 * (playerArmor / 100), textures["armor"], 0, 0, 0, tocolor(140/1.3, 195/1.3, 230/1.3))
	dxDrawText(math.floor(playerArmor) .. "%", startX + respc(44) + respc(42) + respc(50)/2, startY + respc(16) + respc(42) + respc(7.5), _, _, tocolor(200, 200, 200, 200), 1, poppinsSmall, "center", "center")
	
	local playerMoney = getElementData(localPlayer, "a.Money");
	playerMoney = num_formatting(tonumber(playerMoney))

	dxDrawRectangle(startX + respc(150), startY + respc(25)/3, respc(110), respc(25), tocolor(65, 65, 65))
	dxDrawRectangle(startX + respc(150) + 1, startY + respc(25)/3 + 1, respc(110) - 2, respc(25) - 2, tocolor(35, 35, 35))
	dxDrawImage(startX + respc(150) + respc(8), startY + respc(25)/3 + respc(4), respc(16), respc(16), textures["money"], 0, 0, 0, tocolor(200, 200, 90))
	dxDrawText(playerMoney .. "#C4CD5D $", startX + respc(150) + respc(110) - respc(10), startY + respc(25)/3 + respc(25) / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local playerPremium = getElementData(localPlayer, "a.Premiumpont");
	playerPremium = num_formatting(tonumber(playerPremium))

	dxDrawRectangle(startX + respc(150), startY + (respc(25)/3) * 2 + respc(25), respc(110), respc(25), tocolor(65, 65, 65))
	dxDrawRectangle(startX + respc(150) + 1, startY + (respc(25)/3) * 2 + respc(25) + 1, respc(108), respc(23), tocolor(35, 35, 35))
	dxDrawImage(startX + respc(150) + respc(8), startY + (respc(25)/3) * 2 + respc(25) + respc(4), respc(16), respc(16), textures["pp"], 0, 0, 0, tocolor(140, 195, 230))
	dxDrawText(playerPremium .. "#8FC3E4 PP", startX + respc(150) + respc(110) - respc(10), startY +(respc(25)/3) * 2 + respc(25) + respc(25) / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local playerExperience = getElementData(localPlayer, "a.Experience");
	playerExperience = num_formatting(tonumber(playerExperience))

	dxDrawRectangle(startX + respc(150) + respc(110) + respc(20), startY + respc(25)/3, respc(110), respc(25), tocolor(65, 65, 65))
	dxDrawRectangle(startX + respc(150) + respc(110) + respc(20) + 1, startY + respc(25)/3 + 1, respc(108), respc(23), tocolor(35, 35, 35))
	dxDrawImage(startX + respc(280) + respc(8), startY + respc(25)/3 + respc(4), respc(16), respc(16), textures["xp"], 0, 0, 0, tocolor(230, 140, 140))
	dxDrawText(playerExperience .. "#E48F8F XP", startX + respc(150) + respc(110) + respc(20) + respc(110) - respc(10), startY + respc(25)/3 + respc(25) / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)
	
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

	dxDrawRectangle(startX + respc(150) + respc(110) + respc(20), startY + (respc(25)/3) * 2 + respc(25), respc(110), respc(25), tocolor(65, 65, 65))
	dxDrawRectangle(startX + respc(150) + respc(110) + respc(20) + 1, startY + (respc(25)/3) * 2 + respc(25) + 1, respc(110) - 2, respc(25) - 2, tocolor(35, 35, 35))
	dxDrawImage(startX + respc(288), startY + (respc(25)/3) * 2 + respc(29), respc(16), respc(16), textures["clock"], 0, 0, 0, tocolor(155, 230, 140))
	dxDrawText(currentTime["hour"] .. "#9BE48F:#c8c8c8" .. currentTime["minute"] .. "#9BE48F:#c8c8c8" .. currentTime["second"], startX + respc(380), startY + (respc(25)/3) * 2 + respc(25) + respc(25) / 2, _, _, tocolor(200, 200, 200), 1, poppinsSmall, "right", "center", false, false, false, true)

	local footerText = "alphaGames v2.0 - " .. (currentTime["year"] + 1900) .. "." .. currentTime["month"] .. "." .. currentTime["monthday"] .. " - " .. getCurrentFPS() .. " FPS - " .. getPlayerPing(localPlayer) .. " ms";
	local footerWidth = dxGetTextWidth(footerText, 1, poppinsSmall2, false)

	dxDrawText(footerText, startX + sizeX / 2, startY + sizeY + respc(15), _, _, tocolor(150, 150, 150), 1, poppinsSmall2, "center", "center", false, false, false, true)
	dxDrawRectangle(startX + respc(50), startY + sizeY + respc(3), sizeX - respc(100), 2, tocolor(65, 65, 65))

end
addEventHandler("onClientRender", root, onRender)
--setTimer(onRender, 5, 0)

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
	setElementData(localPlayer, "a.HUDshowed", not (getElementData(localPlayer, "a.HUDshowed")))
end
addCommandHandler("toghud", onToggleHUD)