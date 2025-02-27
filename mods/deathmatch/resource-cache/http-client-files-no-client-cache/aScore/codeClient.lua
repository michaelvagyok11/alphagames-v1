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

local scoreX, scoreY = respc(600), respc(400);
local startX, startY = sX / 2 - scoreX / 2, sY / 2 - scoreY / 2

local robotoBoldSmall = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", respc(11), false, "cleartype")
local robotoThinSmall = dxCreateFont("files/fonts/Roboto-Condensed.ttf", respc(11), false, "cleartype")
local playerCache = {}
local maxPlayersShowed = 12;
local scrollingValue = 0;

function onKey(key, state)
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end

	if key == "tab" then
		if state then
			openTick = getTickCount()
			addEventHandler("onClientRender", root, renderScoreboard)
			addEventHandler("onClientKey", root, scrollScoreboard)
		else
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
	
	scoreY = respc(35) + players * respc(30)
	startY = sY / 2 - scoreY / 2

	local nowTick = getTickCount()
	local elapsedTime = (nowTick - openTick)
	local duration = elapsedTime / 500

	a = interpolateBetween(0, 0, 0, 235, 0, 0, duration/1.5, "Linear")
	lineX, lineW, lineA = interpolateBetween(startX + scoreX / 2, 0, 0, startX, scoreX, 235, duration / 2.5, "Linear")

	dxDrawRectangle(startX - 1, startY - 1, scoreX + 2, scoreY + 2, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX, startY, scoreX, scoreY, tocolor(35, 35, 35, a))

	r, g, b = interpolateBetween(200, 200, 200, 225, 140, 135, nowTick / 5000, "SineCurve")
	dxDrawImage(startX + scoreX / 2 - respc(20), startY - respc(50), respc(40), respc(40), ":aAccount/files/img/logo.png", 0, 0, 0, tocolor(r, g, b, a))

	dxDrawText("Online: " .. #getElementsByType("player") .. "/128", startX + scoreX / 2, startY + scoreY + respc(15), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall, "center", "center", false, false, false, true)
	dxDrawImage(lineX, startY - respc(1), lineW, respc(25), "files/header.png", 180, 0, 0, tocolor(200, 200, 200, lineA))

	dxDrawText("ID", startX + respc(35), startY + respc(15), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("NÉV", startX + respc(145), startY + respc(15), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("JÁTÉKMÓD", startX + respc(285), startY + respc(15), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("SZINT", startX + respc(380), startY + respc(15), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("K/D", startX + respc(450), startY + respc(15), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("TOP DRIFT", startX + respc(530), startY + respc(15), _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall, "center", "center")
	
	table.sort(playerCache, 
		function(arg1, arg2)
			if arg1 ~= localPlayer and arg2 ~= localPlayer and getElementData(arg1, "playerid") and getElementData(arg2, "playerid") then
				return tonumber(getElementData(arg1, "playerid") or 0) < tonumber(getElementData(arg2, "playerid") or 0)
			end
		end
	)

	for k, v in ipairs(playerCache) do
		if k <= maxPlayersShowed and (k > scrollingValue) then
			if getElementData(v, "loggedIn") then
				local playerID = getElementData(v, "playerid") or "-";
				local name = getElementData(v, "a.PlayerName") or "-";
				local gamemode = getElementData(v, "a.Gamemode") or "LOBBY";
				if gamemode == 1 then
					local team = getElementData(v, "a.DMTeam")
					if team == 1 then
						gamemode = "#B14C4CTDMA #D6B370(T)"
					elseif team == 2 then
						gamemode = "#B14C4CTDMA #72ABCC(CT)"
					else
						gamemode = "#B14C4CTDMA"
					end
				elseif gamemode == 2 then
					gamemode = "#4F9643FREEROAM"
				elseif gamemode == 3 then
					gamemode = "#AB6B40DRIFT"
				elseif gamemode == 4 then
					gamemode = "#407FABPURSUIT"
				end
				local level = getElementData(v, "a.Level") or "-";
				local kills = getElementData(v, "a.Kills") or 0;
				local deaths = getElementData(v, "a.Deaths") or 0;
				local kd = getPlayerKD(localPlayer, kills, deaths)
				local drift = getElementData(v, "a.bestDrift") or "-";
				local vip = getElementData(v, "a.VIP")

				local alevel = getElementData(v, "adminLevel")
				syntax = exports.aAdmin:getAdminSyntax(alevel, true)

				if vip == true and alevel == 0 then
					syntax = " #C4CD5D[VIP]"
				end

				local clanID = getElementData(v, "a.PlayerGroup")
				if clanID and clanID > 0 then
					local hex, syntax = getElementData(v, "a.ClanHex"), getElementData(v, "a.ClanSyntax")
					name = "#" .. hex .. "(" .. syntax .. ") #c8c8c8" .. name
				end


				dxDrawRectangle(startX + respc(15), startY + ((k - scrollingValue - 1) * respc(30)) + respc(30), scoreX - respc(30), respc(25), tocolor(30, 30, 30, a))

				dxDrawText(playerID, startX + respc(35), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(175, 175, 175, a), 1, robotoBoldSmall, "center", "center")
				dxDrawText(name .. syntax, startX + respc(145), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(175, 175, 175, a), 1, robotoThinSmall, "center", "center", false, false, false, true)
				dxDrawText(gamemode, startX + respc(285), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(120, 120, 120, a), 1, robotoBoldSmall, "center", "center", false, false, false, true)
				dxDrawText("LVL " .. math.floor(level), startX + respc(380), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(120, 120, 120, a), 1, robotoBoldSmall, "center", "center")
				dxDrawText(kd, startX + respc(450), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(120, 120, 120, a), 1, robotoBoldSmall, "center", "center")
				dxDrawText(drift, startX + respc(530), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(120, 120, 120, a), 1, robotoBoldSmall, "center", "center")
			else
				local name = getPlayerName(v) or "-";

				dxDrawRectangle(startX + respc(15), startY + ((k - scrollingValue - 1) * respc(30)) + respc(30), scoreX - respc(30), respc(25), tocolor(30, 30, 30, a))
				dxDrawText("-", startX + respc(35), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText(name, startX + respc(145), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + respc(285), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + respc(380), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + respc(450), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + respc(530), startY + respc(30) + ((k - scrollingValue - 1) * respc(30)) + respc(25)/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
			end
		end
	end
	if #playerCache > 12 then
		local listHeight = 12 * respc(30) - respc(5)
		local visibleItems = (#playerCache - 12) + 1

		scrollbarHeight = (listHeight / visibleItems)

		if scrollTick then
			scrollbarY = interpolateBetween(scrollbarY, 0, 0, startY + respc(30) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 500, "Linear")
		else
			scrollbarY = startY + respc(30) + (scrollingValue * scrollbarHeight)
		end
		dxDrawRectangle(startX + scoreX - respc(10), startY + respc(30), respc(6), listHeight, tocolor(65, 65, 65, 200))
		dxDrawRectangle(startX + scoreX - respc(10) + 1, scrollbarY + 1, respc(4), scrollbarHeight - 2, tocolor(120, 120, 120, 200))
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