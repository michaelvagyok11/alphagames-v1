local sX, sY = guiGetScreenSize();
--local sX, sY = 1280, 720

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

local sizeX, sizeY = respc(358), respc(202);
local startX, startY = sX - sizeX - respc(50), sY / 2 - sizeY / 2;

local rows, coloumns = 5, 10;
local boxSize = respc(30);
local padding = respc(5);
local breakColumn = 10;
local inventoryOpened = false

local poppinsBold = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(10), false, "cleartype")
local poppinsRegular = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(9), false, "cleartype")

local actionbarSlots = 6;

function onStart()
	triggerServerEvent("requestPlayerItems", localPlayer, localPlayer, true)
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function changeInventoryState(state)
	if state == "open" then
		triggerServerEvent("requestPlayerItems", localPlayer, localPlayer, false)
	elseif state == "close" then
		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientClick", root, onClick)
	end
end

function onKey(key, state)
	if key == "i" and state then
		if isChatBoxInputActive() or isConsoleActive() then
            return
        end
		if inventoryOpened then
			inventoryOpened = false
			changeInventoryState("close")
		else
			inventoryOpened = true
			changeInventoryState("open")
		end
	end
end
addEventHandler("onClientKey", root, onKey)

function receivePlayerItems(element, itemTable, type)
	if element ~= localPlayer then
		return
	end
	if element and isElement(element) and itemTable then
		playerItems = itemTable
		if not isEventHandlerAdded("onClientRender", root, renderActionbar) then
			addEventHandler("onClientRender", root, renderActionbar)
			addEventHandler("onClientKey", root, actionKeys)
		end

		if type and type == 1 then
			addEventHandler("onClientRender", root, onRender)
			addEventHandler("onClientClick", root, onClick)
			openTick = getTickCount();

			movingItem = false
		end
	end
end
addEvent("receivePlayerItems", true)
addEventHandler("receivePlayerItems", root, receivePlayerItems)

function onRender()
	if not getElementData(localPlayer, "loggedIn") then
		return
	end

	local nowTick = getTickCount();
	local elapsedTime = nowTick - openTick;
	local duration = elapsedTime / 500;
	local a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
	dxDrawRectangle(startX, startY, sizeX, respc(20), tocolor(65, 65, 65, a))
	dxDrawText("#E18C88alpha#c8c8c8Games - Items", startX + respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "left", "center", false, false, false, true)
	
	if isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
		dxDrawText("X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(230, 140, 140, a), 1, poppinsBold, "right", "center")
	else
		dxDrawText("X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "right", "center")
	end

	local bX, bY = startX + padding, startY + respc(20) + padding
	local row, coloumn = 0, 0
	for i = 1, rows*coloumns do 
		if isMouseInPosition(bX, bY, boxSize, boxSize) then
			dxDrawRectangle(bX, bY, boxSize, boxSize, tocolor(65, 65, 65, a))
		else
			dxDrawRectangle(bX, bY, boxSize, boxSize, tocolor(45, 45, 45, a))
		end

		for k, v in ipairs(playerItems) do
			local itemSlot, itemID, itemCount, actionSlot = v[1], v[2], v[3], v[4]
			if itemSlot == i then
				if movingItem == itemSlot then
					local cX, cY = getCursorPosition()
					local cX, cY = sX*cX, sY*cY
					dxDrawImage(cX, cY, boxSize, boxSize, "files/items/" .. itemID .. ".png", 0, 0, 0, tocolor(255, 255, 255, a), true)
				else
					if isMouseInPosition(bX, bY, boxSize, boxSize) then
						drawTooltip(itemID)
						dxDrawImage(bX, bY, boxSize, boxSize, "files/items/" .. itemID .. ".png", 0, 0, 0, tocolor(255, 255, 255, a), false)
						dxDrawText(itemCount, bX + boxSize - respc(3), bY + boxSize + respc(3), _, _, tocolor(255, 255, 255, a), 1, poppinsBold, "right", "bottom", false, false, false)
					else
						dxDrawImage(bX, bY, boxSize, boxSize, "files/items/" .. itemID .. ".png", 0, 0, 0, tocolor(200, 200, 200, a), false)
						dxDrawText(itemCount, bX + boxSize - respc(3), bY + boxSize + respc(3), _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "right", "bottom", false, false, false)
					end
				end
			end
		end
		
		coloumn = coloumn + 1
		if coloumn == breakColumn then
			row = row + 1
			coloumn = 0
			bX = startX + padding
			bY = startY + respc(20) + padding + (boxSize + padding) * row
		else
			bX = bX + boxSize + padding
		end
	end
end

function renderActionbar()
	-- ** ACTIONBAR
	if not getElementData(localPlayer, "loggedIn") or not getElementData(localPlayer, "a.HUDshowed") then
		return
	end

	a_sizeX, a_sizeY = (actionbarSlots * respc(35)) + respc(5), respc(40)
	a_startX, a_startY = sX / 2 - a_sizeX / 2, sY - a_sizeY - respc(5)

	dxDrawRectangle(a_startX, a_startY, a_sizeX, a_sizeY, tocolor(65, 65, 65))
	dxDrawRectangle(a_startX + 1, a_startY + 1, a_sizeX - 2, a_sizeY - 2, tocolor(35, 35, 35))

	for i = 0, 5 do
		if isMouseInPosition(a_startX + respc(5) + i * respc(35), a_startY + respc(5), boxSize, boxSize) then
			dxDrawRectangle(a_startX + respc(5) + i * respc(35), a_startY + respc(5), boxSize, boxSize, tocolor(65, 65, 65))
		else
			dxDrawRectangle(a_startX + respc(5) + i * respc(35), a_startY + respc(5), boxSize, boxSize, tocolor(45, 45, 45))
		end

		for k, v in ipairs(playerItems) do
			if v[4] == (i+1) then
				dxDrawImage(a_startX + respc(5) + i * respc(35), a_startY + respc(5), boxSize, boxSize, "files/items/" .. v[2] .. ".png", 0, 0, 0, tocolor(200, 200, 200))
			end
		end
	end
end

local lastTick = getTickCount()

function actionKeys(key, state)
	for i = 1, 6 do
		if key == tostring(i) and state then
			for k, v in ipairs(playerItems) do
				if v[4] == (i) then
					if lastTick and lastTick + 250 < getTickCount() then
						useItem(v[2], v[1])
						lastTick = getTickCount()
					end
				end
			end
		end
	end
end

--setTimer(changeInventoryState, 500, 1, "open")

function drawTooltip(itemid)
	local cX, cY = getCursorPosition();
	local cX, cY = cX * sX, cY * sY;
	local itemName = itemList[itemid][1]
	local itemNameWidth = dxGetTextWidth(itemName, 1, poppinsRegular)

	local startX, startY, sizeX, sizeY = cX + respc(10), cY - respc(15), respc(3) + itemNameWidth + respc(3), respc(20)
	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65), true)
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35), true)
	dxDrawText(itemName, startX + (respc(7) + itemNameWidth)/2, startY + respc(21)/2, _, _, tocolor(200, 200, 200), 1, poppinsRegular, "center", "center", false, false, true)
end

function onClick(button, state)
	if button == "left" and state == "down" and inventoryOpened then
		if isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
			inventoryOpened = false
			changeInventoryState("close")
		end
	end
	if button == "right" and state == "down" then
		if isMouseInPosition(a_startX, a_startY, a_sizeX, a_sizeY) then
			for x = 0, 5 do
				if isMouseInPosition(a_startX + respc(5) + x * respc(35), a_startY + respc(5), boxSize, boxSize) then
					for k, v in ipairs(playerItems) do
						if v[4] == x+1 then
							triggerServerEvent("updateActionSlot", localPlayer, localPlayer, tonumber(0), v[1])
							v[4] = 0
						end
					end
				end
			end
		end
	end
	if button == "left" and state == "up" then
		if movingItem then
			if isMouseInPosition(startX, startY, sizeX, sizeY) then
				local bX, bY = startX + padding, startY + respc(20) + padding
				local row, coloumn = 0, 0
				for i = 1, rows*coloumns do 
					if isMouseInPosition(bX, bY, boxSize, boxSize) then
						for k, v in ipairs(playerItems) do
							if v[1] == movingItem then
								if not isValueInTable(playerItems, i, 1) then
									triggerServerEvent("updateItemSlot", localPlayer, localPlayer, v[1], i)
									v[1] = i
									movingItem = false
								else
									movingItem = false
								end
							end
						end
					else
						--movingItem = false
						--break
					end

					coloumn = coloumn + 1
					if coloumn == breakColumn then
						row = row + 1
						coloumn = 0
						bX = startX + padding
						bY = startY + respc(20) + padding + (boxSize + padding) * row
					else
						bX = bX + boxSize + padding
					end
				end
			elseif isMouseInPosition(a_startX, a_startY, a_sizeX, a_sizeY) then
				for x = 0, 5 do
					if isMouseInPosition(a_startX + respc(5) + x * respc(35), a_startY + respc(5), boxSize, boxSize) then
						print(tonumber(x + 1))
						triggerServerEvent("updateActionSlot", localPlayer, localPlayer, tonumber(x + 1), movingItem)
						for k, v in ipairs(playerItems) do
							if v[1] == movingItem then
								v[4] = tonumber(x + 1)
							end
						end
						movingItem = false
					end
				end
			else
				movingItem = false
			end
		end
	end
	
	local bX, bY = startX + padding, startY + respc(20) + padding
	local row, coloumn = 0, 0
	for i = 1, rows*coloumns do 
		for k, v in ipairs(playerItems) do
			local itemSlot, itemID, itemCount, actionSlot = v[1], v[2], v[3], v[4]
			if itemSlot == i then
				if isMouseInPosition(bX, bY, boxSize, boxSize) then
					if button == "left" then
						if state == "down" then
							movingItem = tonumber(itemSlot)
							return
						end
					elseif button == "right" and state == "down" then
						useItem(itemID, itemSlot)
					end
				end
			end
		end
		coloumn = coloumn + 1
		if coloumn == breakColumn then
			row = row + 1
			coloumn = 0
			bX = startX + padding
			bY = startY + respc(20) + padding + (boxSize + padding) * row
		else
			bX = bX + boxSize + padding
		end
	end
end

local itemListOpened = false

function openItemlist()
	if itemListOpened then
		itemListOpened = false
		removeEventHandler("onClientRender", root, renderItemList)
		removeEventHandler("onClientKey", root, keyItemList)
	else
		itemListOpened = true
		openTick = getTickCount()
		addEventHandler("onClientRender", root, renderItemList)
		addEventHandler("onClientKey", root, keyItemList)

		scrollingValue = 0
		maxBoxesInPanel = 7
	end
end
addCommandHandler("itemlist", openItemlist)

function renderItemList()
	local sizeX, sizeY = respc(300), respc(235)
	local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

	local nowTick = getTickCount()
	local elapsedTime = nowTick - openTick
	local duration = elapsedTime / 500
	local a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
	dxDrawRectangle(startX, startY, sizeX, respc(20), tocolor(65, 65, 65, a))
	dxDrawText("#E18C88alpha#c8c8c8Games - Itemlist", startX + respc(5), startY + respc(21)/2, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "left", "center", false, false, false, true)
	
	if isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
		dxDrawText("X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(230, 140, 140, a), 1, poppinsBold, "right", "center")
	else
		dxDrawText("X", startX + sizeX - respc(5), startY + respc(21) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "right", "center")
	end

	for i, v in ipairs(itemList) do
		if (i <= maxBoxesInPanel) and (i > scrollingValue) then
			local bX, bY, bW, bH = startX + respc(5), startY + respc(25) + (respc(30) * (i - scrollingValue - 1)), sizeX - respc(30), respc(25)
			
			if isMouseInPosition(bX, bY, bW, bH) then
				dxDrawRectangle(bX, bY, bW, bH, tocolor(65, 65, 65, a))
				dxDrawText(i, bX + respc(10), bY + bH / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsRegular, "left", "center")
				dxDrawImage(bX + respc(30), bY + respc(2.5), respc(20), respc(20), "files/items/" .. i .. ".png", 0, 0, 0, tocolor(200, 200, 200, a))
				dxDrawText(v[1], bX + respc(60), bY + bH / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsRegular, "left", "center")
			else
				dxDrawRectangle(bX, bY, bW, bH, tocolor(45, 45, 45, a))
				dxDrawText(i, bX + respc(10), bY + bH / 2 + 1, _, _, tocolor(150, 150, 150, a), 1, poppinsRegular, "left", "center")
				dxDrawImage(bX + respc(30), bY + respc(2.5), respc(20), respc(20), "files/items/" .. i .. ".png", 0, 0, 0, tocolor(150, 150, 150, a))
				dxDrawText(v[1], bX + respc(60), bY + bH / 2 + 1, _, _, tocolor(150, 150, 150, a), 1, poppinsRegular, "left", "center")
			end
		end
	end

	local maxVariable = 7
	if #itemList > maxVariable then
		local listHeight = maxVariable * respc(30) - respc(5)
		local visibleItems = (#itemList - maxVariable) + 1

		scrollbarHeight = (listHeight / visibleItems)

		if scrollTick then
			scrollbarY = interpolateBetween(scrollbarY, 0, 0, startY + respc(25) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 500, "Linear")
		else
			scrollbarY = startY + respc(25) + (scrollingValue * scrollbarHeight)
		end
		dxDrawRectangle(startX + sizeX - respc(17.5), startY + respc(25), respc(10), listHeight, tocolor(65, 65, 65, 200))
		dxDrawRectangle(startX + sizeX - respc(17.5) + 1, scrollbarY + 1, respc(8), scrollbarHeight - 2, tocolor(120, 120, 120, 200))
	end
end

function keyItemList(key, state)
	local sizeX, sizeY = respc(300), respc(235)
	local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
	if state and isMouseInPosition(startX, startY, sizeX, sizeY) then
		if key == "mouse_wheel_up" then
			scrollTick = getTickCount()
			if scrollingValue > 0  then
			  	scrollingValue = scrollingValue - 1
			  	maxBoxesInPanel = maxBoxesInPanel - 1
			end
		elseif key == "mouse_wheel_down" then
			scrollTick = getTickCount()
			if maxBoxesInPanel < #itemList then
				scrollingValue = scrollingValue + 1
				maxBoxesInPanel = maxBoxesInPanel + 1
			end
		elseif key == "mouse1" and isMouseInPosition(startX + sizeX - respc(10), startY, respc(10), respc(20)) then
			itemListOpened = false
			removeEventHandler("onClientRender", root, renderItemList)
			removeEventHandler("onClientKey", root, keyItemList)
		elseif key == "mouse3" then
			for i, v in ipairs(itemList) do
				if (i <= maxBoxesInPanel) and (i > scrollingValue) then
					local bX, bY, bW, bH = startX + respc(5), startY + respc(25) + (respc(30) * (i - scrollingValue - 1)), sizeX - respc(10), respc(25)
					if isMouseInPosition(bX, bY, bW, bH) then
						triggerServerEvent("givePlayerItem", localPlayer, localPlayer, i)
						exports.dInfobox:makeNotification(1, "Sikeresen adtál magadnak egy #F1C176" .. v[1] .. " #c8c8c8tárgyat.")
					end
				end
			end
		end
	end
end