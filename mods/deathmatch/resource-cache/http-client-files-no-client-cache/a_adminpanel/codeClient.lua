local sX, sY = guiGetScreenSize();
local panelX, panelY = 800, 425;
local startX, startY = sX / 2 - panelX / 2, sY / 2 - panelY / 2;

local robotoBoldSmall = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 12, false, "cleartype")
local robotoRegular = dxCreateFont("files/fonts/Roboto-Condensed.ttf", 13, false, "cleartype")
local robotoRegularBig = dxCreateFont("files/fonts/Roboto-Condensed.ttf", 16, false, "cleartype")

accountInformations = {}

function openStatsPanel(commandName)
	if commandName and getElementData(localPlayer, "adminLevel") >= 2 then
		if not isPanelVisible then
			isPanelVisible = true
			openTick = getTickCount()
			addEventHandler("onClientRender", root, renderPanel)
			addEventHandler("onClientKey", root, onKey)
			addEventHandler("onClientClick", root, onClick)
			triggerServerEvent("requestAccountData", localPlayer, localPlayer)
			maxPlayersShowing = 10
			scrollingValue = 0
			currentSelectedPlayer = 0

			--exports.a_dxNEW:dxCreateEdit("a.Searchbar", "", "Search player", startX + 10, startY + 35, 200, 25, {70, 120, 70}, 20, 1)
			exports.a_dx:dxCreateEdit("a.Searchbar", "", "Search player", startX + 10, startY + 35, 200, 25, 1, 20)
		else
			isPanelVisible = false
			--exports.a_dxNEW:dxDestroyEdit("a.Searchbar")
			local id = exports.a_dx:dxGetEdit("a.Searchbar")
			if (id) then
				exports.a_dx:dxDestroyEdit(id)
			end

			removeEventHandler("onClientRender", root, renderPanel)
			removeEventHandler("onClientKey", root, onKey)
			removeEventHandler("onClientClick", root, onClick)
		end
	end
end
addCommandHandler("adminpanel", openStatsPanel)

function renderPanel()
	local nowTick = getTickCount()
	local elapsedTime = nowTick - openTick
	local duration = elapsedTime / 1000
	a = interpolateBetween(0, 0, 0, 200, 0, 0, duration, "Linear")
	--exports.a_dxNEW:setEditBoxAlpha("a.Searchbar", a)

	exports.a_core:dxDrawRoundedRectangle(startX, startY, panelX, panelY, tocolor(65, 65, 65, a), 5)
	exports.a_core:dxDrawRoundedRectangle(startX + 1, startY + 1, panelX - 2, panelY - 2, tocolor(35, 35, 35, a), 5)
	exports.a_core:dxDrawRoundedRectangle(startX, startY, panelX, 25, tocolor(65, 65, 65, a), 5)
	dxDrawText("#D19D6Balpha#c8c8c8Games - #E48F8Fadmin#c8c8c8panel", startX + 5, startY + 25/2, _, _, tocolor(200, 200, 200, a), 1, robotoBoldSmall, "left", "center", false, false, false, true)

	if nowTick - openTick > 500 then
		for k, v in ipairs(accountInformations) do
			--local searchInput = exports.a_dxNEW:dxGetEditText("a.Searchbar")
			local id = exports.a_dx:dxGetEdit("a.Searchbar")
			if (id) then
				local searchInput = exports.a_dx:dxGetEditText(id)
				if (searchInput) and not (searchInput == "") and string.len(searchInput) > 2 then
					if string.find(string.lower(string.gsub(v[15], "#%x%x%x%x%x%x", "")), searchInput) then
						exports.a_core:dxDrawRoundedRectangle(startX + 10, startY + 70 + (k - scrollingValue - 1) * 35, 300, 30, tocolor(60, 120, 60, a), 10)
						currentSelectedPlayer = k
					end
				end
			end
			if k <= maxPlayersShowing and (k > scrollingValue) then
				if isMouseInPosition(startX + 10, startY + 70 + (k - scrollingValue - 1) * 35, 300, 30) then
					exports.a_core:dxDrawRoundedRectangle(startX + 10, startY + 70 + (k - scrollingValue - 1) * 35, 300, 30, tocolor(60, 60, 60, a), 10)
				else
					exports.a_core:dxDrawRoundedRectangle(startX + 10, startY + 70 + (k - scrollingValue - 1) * 35, 300, 30, tocolor(50, 50, 50, a), 10)
				end

				dxDrawText(v[1], startX + 20, startY + 70 + (k - scrollingValue - 1)*35 + 30/2, _, _, tocolor(100, 100, 100, a), 1, robotoBoldSmall, "left", "center", false, false, false, true)
				dxDrawText(v[15], startX + 55, startY + 70 + (k - scrollingValue - 1)*35 + 30/2, _, _, tocolor(150, 150, 150, a), 1, robotoRegular, "left", "center", false, false, false, true)
			end
			if currentSelectedPlayer == k then
				exports.a_core:dxDrawRoundedRectangle(startX + panelX / 2 - 10, startY + 35, panelX / 2 - 5, panelY - 45, tocolor(35, 35, 35, a), 5)
				exports.a_core:dxDrawRoundedRectangle(startX + panelX / 2 - 10, startY + 35, panelX / 2 - 5, 35, tocolor(45, 45, 45, a), 5)
				dxDrawText(v[15], startX + panelX / 2 + 10 + (panelX / 2 - 20)/2, startY + 35 + 35/2, _, _, tocolor(200, 200, 200, a), 1, robotoRegularBig, "center", "center", false, false, false, true)
				
				dxDrawText("Account ID: #8FC3E4" .. v[1], startX + panelX / 2 + 5, startY + 35 + 50, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("Username: #8FC3E4" .. v[2], startX + panelX / 2 + 5, startY + 35 + 75, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("Serial: #8FC3E4" .. v[3], startX + panelX / 2 + 5, startY + 35 + 100, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				
				if isMouseInPosition(startX + panelX /2 + 5 + dxGetTextWidth("Serial: " .. v[3], 1, robotoRegular) + 10, startY + 35 + 92.5, 16, 16) then
					dxDrawImage(startX + panelX /2 + 5 + dxGetTextWidth("Serial: " .. v[3], 1, robotoRegular) + 10, startY + 35 + 92.5, 16, 16, "files/img/copy.png", 0, 0, 0, tocolor(120, 120, 120, a))
				else
					dxDrawImage(startX + panelX /2 + 5 + dxGetTextWidth("Serial: " .. v[3], 1, robotoRegular) + 10, startY + 35 + 92.5, 16, 16, "files/img/copy.png", 0, 0, 0, tocolor(80, 80, 80, a))
				end
				
				dxDrawText("Adminlevel: #8FC3E4" .. (v[4] or 0), startX + panelX / 2 + 5, startY + 35 + 125, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("Adminnick: #8FC3E4" .. (v[5] or "admin"), startX + panelX / 2 + 5, startY + 35 + 150, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("Skin: #8FC3E4" .. v[6], startX + panelX / 2 + 5, startY + 35 + 175, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("K/D: #8FC3E4" .. v[7] .. "/" .. v[8], startX + panelX / 2 + 5, startY + 35 + 200, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("Clan: #8FC3E4" .. v[9], startX + panelX / 2 + 5, startY + 35 + 225, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("XP: #8FC3E4" .. v[10], startX + panelX / 2 + 5, startY + 35 + 250, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("Money: #8FC3E4" .. v[11], startX + panelX / 2 + 5, startY + 35 + 275, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("VIP: #8FC3E4" .. v[12], startX + panelX / 2 + 5, startY + 35 + 300, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("PP: #8FC3E4" .. v[13], startX + panelX / 2 + 5, startY + 35 + 325, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
				dxDrawText("Mutetime: #8FC3E4" .. v[14], startX + panelX / 2 + 5, startY + 35 + 350, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "left", "center", false, false, false, true)
			end
		end
	end
end
function string.split(str)

	if not str or type(str) ~= "string" then return false end
 
	local splitStr = {}
	for i=1,string.len(str) do
	   local char = str:sub( i, i )
	   table.insert( splitStr , char )
	end
 
	return splitStr 
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

function onKey(key, state)
	if key == "mouse_wheel_up" then
		if scrollingValue > 0  then
			scrollingValue = scrollingValue - 1
			maxPlayersShowing = maxPlayersShowing - 1
		end
	elseif key == "mouse_wheel_down" then
		if maxPlayersShowing < (#accountInformations) then
			scrollingValue = scrollingValue + 1
			maxPlayersShowing = maxPlayersShowing + 1
		end
	end
end

function onClick(key, state)
	if key == "left" and state == "down" then
		for k, v in ipairs(accountInformations) do
			if k <= maxPlayersShowing and (k > scrollingValue) then
				if isMouseInPosition(startX + 10, startY + 70 + (k - scrollingValue - 1) * 35, 300, 30) then
					currentSelectedPlayer = k
				end
				if isMouseInPosition(startX + panelX /2 + 5 + dxGetTextWidth("Serial: " .. v[3], 1, robotoRegular) + 10, startY + 35 + 92.5, 16, 16) and currentSelectedPlayer == k then
					exports.a_interface:makeNotification(1, "You have successfully copied #E48F8F" .. v[2] .. "#c8c8c8's serial.")
					setClipboard(tostring(v[3]))
				end
			end
		end
		
	end
end

function sendAccountData(e, table)
	accountInformations = table
end
addEvent("sendAccountData", true)
addEventHandler("sendAccountData", root, sendAccountData)

function onStop()
	local id = exports.a_dx:dxGetEdit("a.Searchbar")
	if (id) then
		exports.a_dx:dxDestroyEdit(id)
	end
	--exports.a_dxNEW:dxDestroyEdit("a.Searchbar")
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)