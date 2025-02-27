local sX, sY = guiGetScreenSize();
local scoreX, scoreY = 600, 400;
local startX, startY = sX / 2 - scoreX / 2, sY / 2 - scoreY / 2

local robotoBoldSmall = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 13, false, "cleartype")
local robotoThinSmall = dxCreateFont("files/fonts/Roboto-Condensed.ttf", 12, false, "cleartype")
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
	scoreY = 20 + 30 + players*30
	startY = sY / 2 - scoreY / 2

	local nowTick = getTickCount()
	local elapsedTime = (nowTick - openTick)
	local duration = elapsedTime / 500
	a = interpolateBetween(0, 0, 0, 235, 0, 0, duration, "Linear")

	dxDrawRectangle(startX - 1, startY - 1, scoreX + 2, scoreY + 2, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX, startY, scoreX, scoreY, tocolor(35, 35, 35, a))
	
	dxDrawText("Online: " .. #getElementsByType("player") .. "/128", startX + scoreX / 2, startY + scoreY + 15, _, _, tocolor(150, 150, 150, a), 1, robotoBoldSmall, "center", "center", false, false, false, true)
	dxDrawRectangle(startX + 15, startY + 10, scoreX - 30, 25, tocolor(45, 45, 45, a))
	
	dxDrawText("ID", startX + 35, startY + 10 + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("NÉV", startX + 145, startY + 10 + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("JÁTÉKMÓD", startX + 285, startY + 10 + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("SZINT", startX + 380, startY + 10 + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("K/D", startX + 450, startY + 10 + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoBoldSmall, "center", "center")
	dxDrawText("TOP DRIFT", startX + 530, startY + 10 + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoBoldSmall, "center", "center")
	
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
				local name = getPlayerName(v) or "-";
				local gamemode = getElementData(v, "a.Gamemode") or "LOBBY";
				if gamemode == 1 then
					gamemode = "#B14C4CTDMA"
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
				if alevel > 0 then
                    if alevel == 1 then
                        syntax = "#dfacde (P. Moderátor)"
                    elseif alevel ==  2 then
                        syntax = "#62a7e1 (Adminisztrátor)"
                    elseif alevel == 3 then
                        syntax = "#cfad80 (Fejlesztő)"
                    elseif alevel == 4 then
                        syntax = "#dce188 (Menedzser)"
                    elseif alevel == 5 then
                        syntax = "#e18c88 (Tulajdonos)"
					end
				else
					syntax = ""
				end

				if vip == true and alevel == 0 then
					syntax = " #C4CD5D[VIP]"
				end

				local clanID = getElementData(v, "a.PlayerGroup")
				if clanID and clanID > 0 then
					local hex, syntax = getElementData(v, "a.ClanHex"), getElementData(v, "a.ClanSyntax")
					name = "#" .. hex .. "(" .. syntax .. ") #c8c8c8" .. name
				end

				dxDrawRectangle(startX + 15, startY + ((k-scrollingValue-1)*30 ) + 45, scoreX - 30, 25, tocolor(50, 50, 50, a))
				--dxDrawRectangle(startX + 15 + 1, startY + ((k-scrollingValue-1)*30 ) + 45 + 1, scoreX - 30 - 2, 25 - 2, tocolor(40, 40, 40, a))
				dxDrawText(playerID, startX + 35, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(175, 175, 175, a), 1, robotoBoldSmall, "center", "center")
				dxDrawText(name .. syntax, startX + 145, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(175, 175, 175, a), 1, robotoThinSmall, "center", "center", false, false, false, true)
				dxDrawText(gamemode, startX + 285, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(120, 120, 120, a), 1, robotoBoldSmall, "center", "center", false, false, false, true)
				dxDrawText("LVL " .. math.floor(level), startX + 380, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(120, 120, 120, a), 1, robotoBoldSmall, "center", "center")
				dxDrawText(kd, startX + 450, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(120, 120, 120, a), 1, robotoBoldSmall, "center", "center")
				dxDrawText(drift, startX + 530, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(120, 120, 120, a), 1, robotoBoldSmall, "center", "center")
			else
				local name = getPlayerName(v) or "-";

				exports.a_core:dxDrawRoundedRectangle(startX + 15, startY + ((k-scrollingValue-1)*30 ) + 45, scoreX - 30, 25, tocolor(42, 42, 42, a), 5)
				dxDrawText("-", startX + 35, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText(name, startX + 145, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + 285, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + 380, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + 450, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
				dxDrawText("-", startX + 530, startY + 45 + ((k-scrollingValue-1)*30 ) + 25/2, _, _, tocolor(85, 85, 85, a), 1, robotoThinSmall, "center", "center")
			end
		end
	end
end

function scrollScoreboard(button, press)
	if press then
		--if isMouseInPosition(startX, startY, scoreX, scoreY) then
			if button == "mouse_wheel_up" then
				if scrollingValue > 0  then
					scrollingValue = scrollingValue -1
					maxPlayersShowed = maxPlayersShowed -1
				end
			elseif button == "mouse_wheel_down" then
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