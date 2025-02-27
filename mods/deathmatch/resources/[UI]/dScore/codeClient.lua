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

local scoreX, scoreY = respc(700), respc(400);
local startX, startY = sX / 2 - scoreX / 2, sY / 2 - scoreY / 2

local robotoBoldSmall = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(9), false, "cleartype")
local robotoBoldSmall2 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(7), false, "cleartype")
local barlowLightSmall = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(9), false, "cleartype")
local robotoThinSmall = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(9), false, "cleartype")

local barlowBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(13), false, "cleartype")
local barlowLightBig = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(13), false, "cleartype")

local playerCache = {}
local maxPlayersShowed = 12;
local scrollingValue = 0;
local teamCache = {["Defender"] = "#9BE48FDM - Védő", ["Attacker"] = "#E48F8FDM - Támadó"}

function onKey(key, state)
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end

	if key == "tab" then
		if state and not getElementData(localPlayer, "inDashboard") then
			playSound("files/open.wav")
			openTick = getTickCount()
			addEventHandler("onClientRender", root, renderScoreboard)
			addEventHandler("onClientKey", root, scrollScoreboard)
		else
			--playSound("files/open.wav")
			removeEventHandler("onClientRender", root, renderScoreboard)
			removeEventHandler("onClientKey", root, scrollScoreboard)
		end
	end
end
addEventHandler("onClientKey", root, onKey)

function renderScoreboard()
	local players = #playerCache
	if players > 12 then
		players = 12
	else
		players = players
	end
	
	scoreY = respc(25) + players * respc(30)
	--startY = sY / 2 - scoreY / 2

	local nowTick = getTickCount()
	local elapsedTime = (nowTick - openTick)
	local duration = elapsedTime / 250

	a, startY = interpolateBetween(0, sY / 2 - scoreY / 2 + respc(30), 0, 255, sY / 2 - scoreY / 2, 0, duration/2, "Linear")

	dxDrawRoundedRectangle(startX, startY, scoreX, scoreY, 3, tocolor(35, 35, 35, a))
	dxDrawFadeRectangle(startX, startY, scoreX, scoreY, {20, 20, 20, a})

	r, g, b = interpolateBetween(200, 200, 200, 225, 140, 135, nowTick / 5000, "SineCurve")
	--dxDrawImage(startX + scoreX / 2 - respc(20), startY - respc(50), respc(40), respc(40), ":aAccount/files/img/logo.png", 0, 0, 0, tocolor(r, g, b, a))
    
	dxDrawText("alpha", startX + respc(2), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldBig, "left", "center")
    dxDrawText("GAMES", startX + respc(3.5) + dxGetTextWidth("alpha", 1, barlowBoldBig), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowLightBig, "left", "center")

	dxDrawImage(startX + scoreX / 2 - respc(20), startY - respc(45), respc(40), respc(40), "files/v2logo.png", 0, 0, 0, tocolor(255, 255, 255, a))
	dxDrawText("Online: " .. #getElementsByType("player") .. "/128", startX + scoreX - respc(10), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 0.85, barlowLightBig, "right", "center", false, false, false, true)

	dxDrawText("ID", startX + respc(20), startY + respc(12.5), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "center", "center")
	dxDrawText("NÉV", startX + respc(250), startY + respc(12.5), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "center", "center")
	dxDrawText("JÁTÉKMÓD", startX + respc(480), startY + respc(12.5), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "center", "center")
	dxDrawText("SZINT", startX + respc(575), startY + respc(12.5), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "center", "center")
	dxDrawText("PING", startX + respc(650), startY + respc(12.5), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall2, "center", "center")
	
	table.sort(playerCache, 
		function(arg1, arg2)
			if arg1 ~= localPlayer and arg2 ~= localPlayer and getElementData(arg1, "d/PlayerID") and getElementData(arg2, "d/PlayerID") then
				return tonumber(getElementData(arg1, "d/PlayerID") or 0) < tonumber(getElementData(arg2, "d/PlayerID") or 0)
			end
		end
	)

	for k, v in ipairs(playerCache) do
		if k <= maxPlayersShowed and (k > scrollingValue) then
			if getElementData(v, "loggedIn") then
				local playerID = getElementData(v, "d/PlayerID") or "-";
				local name = getElementData(v, "a.PlayerName") or "-";
				local gamemode = getElementData(v, "a.Gamemode") or "LOBBY";
				if gamemode == 1 then
					local currentSessionId = getElementData(v, "a.Current<DM>Session")
					local currentTeam = getElementData(v, "a.Team<DM>")
					gamemode = teamCache[currentTeam] .. " (ID: "..currentSessionId..")"
				elseif gamemode == 2 then
					gamemode = "#8FC3E4PURSUIT"
				elseif gamemode == 3 then
					gamemode = "#F1C176DRIFT"
				end
				local level = getElementData(v, "a.Level") or "-";

				local vip = getElementData(v, "a.VIP")

				local alevel = getElementData(v, "adminLevel")
				if alevel > 0 then
					syntax = exports.dAdmin:getAdminSyntax(alevel, true)
				else
					syntax = ""
				end

				if vip == true then
					name = "#C4CD5D ".. name .. ""
				end

				local clanID = getElementData(v, "a.PlayerGroup")
				if clanID and clanID > 0 then
					local hex, syntax = getElementData(v, "a.ClanHex"), getElementData(v, "a.ClanSyntax")
					name = "" .. hex .. "(" .. syntax .. ") #AFAFAF" .. name
				end

				local playerPing = getPlayerPing(v)


				dxDrawRoundedRectangle(startX + respc(5), startY + ((k - scrollingValue - 1) * respc(30)) + respc(25), scoreX - respc(10), respc(25), 3, tocolor(45, 45, 45, a))

				dxDrawText(playerID, startX + respc(20), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(175, 175, 175, a), 1, robotoThinSmall, "center", "center")
				if alevel > 0 then
					local nameW = dxGetTextWidth(name, 1, robotoBoldSmall)
					dxDrawText(name, startX + respc(249), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(175, 175, 175, a), 1, robotoBoldSmall, "right", "center", false, false, false, true)
					dxDrawText(" -" .. syntax, startX + respc(251), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(175, 175, 175, a), 1, robotoThinSmall, "left", "center", false, false, false, true)
				else
					dxDrawText(name .. syntax, startX + respc(250), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(175, 175, 175, a), 1, robotoBoldSmall, "center", "center", false, false, false, true)
				end
				dxDrawText(gamemode, startX + respc(480), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(120, 120, 120, a), 1, robotoThinSmall, "center", "center", false, false, false, true)
				dxDrawText("LVL " .. math.floor(level), startX + respc(575), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(120, 120, 120, a), 1, robotoThinSmall, "center", "center")
				dxDrawText(playerPing .. " ms", startX + respc(650), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(120, 120, 120, a), 1, robotoThinSmall, "center", "center")
			else
				local playerID = getElementData(v, "d/PlayerID") or "-";
				local name = getPlayerName(v) or "-";

				dxDrawRoundedRectangle(startX + respc(5), startY + ((k - scrollingValue - 1) * respc(30)) + respc(25), scoreX - respc(10), respc(25), 3, tocolor(30, 30, 30, a))
				dxDrawText(playerID, startX + respc(20), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText(name, startX + respc(175), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + respc(480), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + respc(575), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				if getPlayerPing(v) then
					dxDrawText(getPlayerPing(v) .. " ms", startX + respc(650), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				else
					dxDrawText("n/a", startX + respc(650), startY + respc(25) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				end
			end
		end
	end
	if #playerCache > 12 then
		local listHeight = 12 * respc(30) - respc(5)
		local visibleItems = (#playerCache - 12) + 1

		scrollbarHeight = (listHeight / visibleItems)

		if scrollTick then
			scrollbarY = interpolateBetween(scrollbarY, 0, 0, startY + respc(25) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 500, "Linear")
		else
			scrollbarY = startY + respc(30) + (scrollingValue * scrollbarHeight)
		end
		dxDrawRectangle(startX + scoreX - respc(3), startY + respc(25), respc(2), listHeight, tocolor(65, 65, 65, 200))
		dxDrawRectangle(startX + scoreX - respc(3) + 1, scrollbarY + 1, respc(1), scrollbarHeight - 2, tocolor(140, 195, 230, 200))
	end
end

function scrollScoreboard(button, press)
	if press then
		--if isMouseInPosition(startX, startY, scoreX, scoreY) then
			if button == "mouse_wheel_up" then
				scrollTick = getTickCount()
				if scrollingValue > 0  then
					scrollingValue = scrollingValue -1
					maxPlayersShowed = maxPlayersShowed -1
				end
			elseif button == "mouse_wheel_down" then
				scrollTick = getTickCount()
				if maxPlayersShowed < #playerCache then
					scrollingValue = scrollingValue +1
					maxPlayersShowed = maxPlayersShowed +1
				end
			end
		--end
	end
end

function getPlayerKD(player, k, d)
	if k ~= 0 and d ~= 0 then 
		mult = 10^(2)
		num = k/d;
		return math.floor(num * mult + 0.5) / mult
	elseif k~=0 then
		return k;
	else
		return 0;
  	end
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

function onStart()
	playerCache = getElementsByType("player")
	--[[for i=0, 15 do
		for k, v in ipairs(getElementsByType("player")) do
			--if getPlayerName(v) == "!michael." then
				table.insert(playerCache, v)
			--end
		end
	end]]--
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onJoin()
	table.insert(playerCache, source)
end
addEventHandler("onClientPlayerJoin", root, onJoin)
  
function onQuit()
	for k, v in ipairs(playerCache) do
		if v == source then
			table.remove(playerCache, k)
		end
	end
end
addEventHandler("onClientPlayerQuit", root, onQuit)

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

local topTexture = dxCreateTexture("files/images/featherTop.dds", "dxt5", true, "clamp")
local sideTexture = dxCreateTexture("files/images/feather.dds", "dxt5", true, "clamp")
local cornerTexture = dxCreateTexture("files/images/corner.dds", "dxt5", true, "clamp")

function dxDrawFadeRectangle(x, y, w, h, color)

    x = x - 5
    y = y - 5
    w = w + 10
    h = h + 10
    if color[4] < 10 then
        return
    end
    
    dxDrawRectangle(x + 10, y + 10, w - 20, h - 20, tocolor(color[1], color[2], color[3], color[4] - 15))
    color = tocolor(color[1], color[2], color[3], color[4])
    dxDrawImage(x, y, 10, 10, cornerTexture, 270, 0, 0, color)
    dxDrawImage(x + w - 10, y, 10, 10, cornerTexture, 0, 0, 0, color)
    dxDrawImage(x, y + h - 10, 10, 10, cornerTexture, 180, 0, 0, color)
    dxDrawImage(x + w - 10, y + h - 10, 10, 10, cornerTexture, 90, 0, 0, color)

    dxDrawImage(x + 10, y + 10, w - 20, -10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + h - 10, w - 20, 10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + 10, -10, h - 20, sideTexture, 0, 0, 0, color)
    dxDrawImage(x + w - 10, y + 10, 10, h - 20, sideTexture, 0, 0, 0, color)
end