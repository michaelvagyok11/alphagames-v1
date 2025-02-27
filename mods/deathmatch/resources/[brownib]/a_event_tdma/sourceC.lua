addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
        tdmaEventKills = getElementData(localPlayer, "a.eventKills")
		outputChatBox("#E18C88[alphaGames - Event]: #ffffffÖléseid száma: #E18C88"..tdmaEventKills..".", 255, 255, 255, true)
	end
)

addCommandHandler("eventkills",
	function ()
		playerName = getElementData(localPlayer, "a.PlayerName")
		eventKills = getElementData(localPlayer, "a.eventKills")
		outputChatBox("#E18C88[alphaGames - Event]: #ffffffÖléseid száma: #E18C88"..eventKills..".", 255, 255, 255, true)
	end
)


local sX, sY = guiGetScreenSize()
local panelSize = {230, 320}
local font = dxCreateFont(":a_toplist/files/fonts/font.otf", 15, false, "cleartype")
local font2 = dxCreateFont(":a_toplist/files/fonts/font.otf", 10, false, "cleartype")
local robotoThin = dxCreateFont(":a_toplist/files/fonts/Roboto-Condensed.otf", 12, false, "cleartype")
local width = panelSize[1] - 20
local delayTimer = {}
local clicked = {}
local r2, g2, b2 = 50, 50, 50

function openPanel()
	if panelState == "opened" then
		if isTimer(requestTimer) then
			return
		end
		panelState = "closed"
		removeEventHandler("onClientRender", root, onRender)
	else
		panelState = "opened"
		triggerServerEvent("requestData", localPlayer, localPlayer)
		outputChatBox("#C8B28F[Event toplista]: #ffffffAdatok lekérése...", 255, 255, 255, true)
		requestTimer = setTimer(function()
			openTick = getTickCount()
			addEventHandler("onClientRender", root, onRender)
		end, 1000, 1)
	end
end
addCommandHandler("eventtoplist", openPanel)

function onRender()
	if panelState == "opened" then
		local nowTick = getTickCount()
		local elapsedTime = nowTick - openTick
		local duration = elapsedTime / 1000
		a = interpolateBetween(0, 0, 0, 240, 0, 0, duration, "Linear")

		startX, startY = sX / 2 - panelSize[1] / 2, sY / 2 - panelSize[2] / 2

		dxDrawRectangle(startX, startY, panelSize[1], panelSize[2], tocolor(65, 65, 65, a))
		dxDrawRectangle(startX + 2, startY + 2, panelSize[1] - 4, panelSize[2] - 4, tocolor(35, 35, 35, a))
		dxDrawRectangle(startX, startY, panelSize[1], 25, tocolor(65, 65, 65, a))
		dxDrawText("#D19D6Balpha#c8c8c8Games - Event toplista", startX + 5, startY + 30/2, _, _, tocolor(200, 200, 200, a), 1, font, "left", "center", false, false, false, true)
		
		--** TOP KILLS
		dxDrawRectangle(startX + 5, startY + 30, panelSize[1] - 10, panelSize[2] - 35, tocolor(50, 50, 50, a))
		dxDrawRectangle(startX + 5, startY + 30, panelSize[1] - 10, 25, tocolor(65, 65, 65, a))
		dxDrawText("#D19D6BEvent killek", startX + 5 + (panelSize[1] - 10) / 2, startY + 30 + 25/2, _, _, tocolor(200, 200, 200, a), 1, font, "center", "center", false, false, false, true)

		for k, v in ipairs(killTable) do
			if string.len(v[1]) > 14 then
				scale = 1
			else
				scale = 1
			end
			
			if k == 1 then
				syntax = "#C7D26C"
			elseif k == 2 then
				syntax = "#C6C9B1"
			elseif k == 3 then
				syntax = "#C8B28F"
			else
				syntax = ""
			end

			dxDrawText(syntax .. "#" .. k .. " #c8c8c8" .. v[1] .. "#8FC3E4 (" .. v[2] .. ")", startX + 15, startY + 45 + k*26, _, _, tocolor(200, 200, 200, a), scale, font2, "left", "center", false, false, false, true)
		end
	end
end

function sendInformations(element, str, table)
	if str == "eventKills" then
		killTable = table
	elseif str == "deaths" then
		deathTable = table
	elseif str == "drifts" then
		driftTable = table
	elseif str == "xp" then
		xpTable = table
	end
end
addEvent("sendInformations", true)
addEventHandler("sendInformations", root, sendInformations)

function isCursorInBox ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end