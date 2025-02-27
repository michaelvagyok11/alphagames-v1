local sX, sY = guiGetScreenSize();
local sizeX, sizeY = 600, 405;
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

local scrollingValue = 0;
local maxItemsShowed = 10;
local panelState = "closed";

local poppinsBoldSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 12, false, "cleartype")
local poppinsThinSmall = dxCreateFont("files/fonts/Poppins-Regular.ttf", 12, false, "cleartype")

function changeShopState(state)
	if state == "close" then
		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientClick", root, onClick)
		removeEventHandler("onClientKey", root, onKey)
		panelState = "closed"
		paymentDetails = {}
	else
		addEventHandler("onClientRender", root, onRender)
		addEventHandler("onClientClick", root, onClick)
		addEventHandler("onClientKey", root, onKey)
		panelState = "opened"
		paymentIsInProgress = false
		paymentDetails = {}
		openTick = getTickCount()
	end
end

function onRender()
	if not panelState == "opened" then
		return
	end

	local nowTick = getTickCount()
	local elapsedTime = nowTick - openTick
	local duration = elapsedTime / 500
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
	dxDrawRectangle(startX, startY, sizeX, 25, tocolor(65, 65, 65, a))
	dxDrawText("#E18C88alpha#c8c8c8Games - Shop", startX + 5, startY + 25 / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldSmall, "left", "center", false, false, false, true)
	dxDrawImage(startX + sizeX - 20, startY + 6, 12, 12, "files/img/close.png", 0, 0, 0, tocolor(230, 140, 140, a/2))
	
	dxDrawText("Megnevezés", startX + 45, startY + 25 + 12.5, _, _, tocolor(150, 150, 150, a), 1, poppinsThinSmall, "left", "center", false, false, false, true)
	dxDrawText("Ár #9BE48F($)", startX + 275, startY + 25 + 12.5, _, _, tocolor(150, 150, 150, a), 1, poppinsThinSmall, "left", "center", false, false, false, true)
	dxDrawText("Ár #8FC3E4(PP)", startX + 370, startY + 25 + 12.5, _, _, tocolor(150, 150, 150, a), 1, poppinsThinSmall, "center", "center", false, false, false, true)
	dxDrawText("Itemkép", startX + 458, startY + 25 + 12.5, _, _, tocolor(150, 150, 150, a), 1, poppinsThinSmall, "center", "center", false, false, false, true)

	for i, v in ipairs(itemsInShop) do
		if i <= maxItemsShowed and (i > scrollingValue) then
			dxDrawRectangle(startX + 10, startY + 45 + (35 * (i - scrollingValue - 1)) + 5, sizeX - 120, 30, tocolor(65, 65, 65, a))
			dxDrawImage(startX + 20, startY + 45 + (35 * (i - scrollingValue - 1)) + 3 + 16/2, 16, 16, "files/img/" .. v[4] .. ".png", 0, 0, 0, tocolor(200, 200, 200, a))
			dxDrawText(v[1], startX + 45, startY + 45 + (35 * (i - scrollingValue - 1)) + 5 + 15, _, _, tocolor(200, 200, 200, a), 1, poppinsBoldSmall, "left", "center", false, false, false, true)
			
			if v[2] == "-" then
				dxDrawText(v[2], startX + 290, startY + 45 + (35 * (i - scrollingValue - 1)) + 5 + 15, _, _, tocolor(175, 175, 175, a), 1, poppinsBoldSmall, "center", "center", false, false, false, true)
			else
				dxDrawText(v[2] .. "#9BE48F$", startX + 290, startY + 45 + (35 * (i - scrollingValue - 1)) + 5 + 15, _, _, tocolor(175, 175, 175, a), 1, poppinsBoldSmall, "center", "center", false, false, false, true)
			end

			dxDrawText(v[3] .. "#8FC3E4PP", startX + 370, startY + 45 + (35 * (i - scrollingValue - 1)) + 5 + 15, _, _, tocolor(175, 175, 175, a), 1, poppinsBoldSmall, "center", "center", false, false, false, true)

			if v[5] == true then
				dxDrawImage(startX + 445, startY + 45 + (35 * (i - scrollingValue - 1)) + 3 + 4, 24, 24, ":aItems/files/items/" .. v[6] .. ".png", 0, 0, 0, tocolor(150, 150, 150, a))
			else			
				dxDrawImage(startX + 450, startY + 45 + (35 * (i - scrollingValue - 1)) + 3 + 16/2, 16, 16, "files/img/nopreview.png", 0, 0, 0, tocolor(120, 120, 120, a))
			end

			if isMouseInPosition(startX + sizeX - 105, startY + 45 + (35 * (i - scrollingValue - 1)) + 5, 95, 30) then
				dxDrawRectangle(startX + sizeX - 105, startY + 45 + (35 * (i - scrollingValue - 1)) + 5, 100, 30, tocolor(155, 230, 140, a/2))
			else
				dxDrawRectangle(startX + sizeX - 105, startY + 45 + (35 * (i - scrollingValue - 1)) + 5, 100, 30, tocolor(50, 50, 50, a/2))

			end
			dxDrawText("Vásárlás", startX + sizeX - 105 + 50, startY + 45 + (35 * (i - scrollingValue - 1)) + 5 + 15, _, _, tocolor(175, 175, 175, a), 1, poppinsBoldSmall, "center", "center", false, false, false, true)
		end
	end

	if paymentIsInProgress then
		local sizeX, sizeY = 350, 75
		local startX, startY = sX / 2 - sizeX / 2, sY / 2 + 405 / 2 + 5
		dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, 200))
		dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, 200))
		dxDrawImage(startX + sizeX - 20, startY + 6, 12, 12, "files/img/close.png", 0, 0, 0, tocolor(230, 140, 140, a/2))

		dxDrawText("Meg akarod vásárolni a kiválasztott tárgyat?", startX + sizeX / 2, startY + 15, _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldSmall, "center", "center")
		dxDrawText(paymentDetails[1], startX + sizeX / 2, startY + 35, _, _, tocolor(125, 125, 125, 200), 1, poppinsBoldSmall, "center", "center")

		if isMouseInPosition(startX + 5, startY + sizeY - 30, (sizeX - 10) / 2 - 5, 25) then
			dxDrawRectangle(startX + 5, startY + sizeY - 30, (sizeX - 10) / 2 - 5, 25, tocolor(155, 230, 140, 200))
			dxDrawText("Vásárlás", startX + 5 + ((sizeX - 10) / 2 - 5) / 2, startY + sizeY - 30 + 25 / 2, _, _, tocolor(20, 20, 20, 200), 1, poppinsBoldSmall, "center", "center", false, false, false, true)
		else
			dxDrawRectangle(startX + 5, startY + sizeY - 30, (sizeX - 10) / 2 - 5, 25, tocolor(50, 50, 50, 200))
			dxDrawText(paymentDetails[2] .. "#9BE48F$", startX + 5 + ((sizeX - 10) / 2 - 5) / 2, startY + sizeY - 30 + 25 / 2, _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldSmall, "center", "center", false, false, false, true)
		end

		if isMouseInPosition(startX + 5 + (sizeX - 10) / 2, startY + sizeY - 30, (sizeX - 10) / 2, 25) then
			dxDrawRectangle(startX + 5 + (sizeX - 10) / 2, startY + sizeY - 30, (sizeX - 10) / 2, 25, tocolor(145, 195, 230, 200))
			dxDrawText("Vásárlás", startX + 5 + (sizeX - 10) / 2 + ((sizeX - 10) / 2 - 5) / 2, startY + sizeY - 30 + 25 / 2, _, _, tocolor(20, 20, 20, 200), 1, poppinsBoldSmall, "center", "center", false, false, false, true)
		else
			dxDrawRectangle(startX + 5 + (sizeX - 10) / 2, startY + sizeY - 30, (sizeX - 10) / 2, 25, tocolor(50, 50, 50, 200))
			dxDrawText(paymentDetails[3] .. "#8FC3E4PP", startX + 5 + (sizeX - 10) / 2 + ((sizeX - 10) / 2 - 5) / 2, startY + sizeY - 30 + 25 / 2, _, _, tocolor(200, 200, 200, 200), 1, poppinsBoldSmall, "center", "center", false, false, false, true)
		end
	end
end

function onClick(button, state)
	if not panelState == "opened" then
		return
	end

	if button == "left" and state == "down" then
		for i, v in ipairs(itemsInShop) do
			if i <= maxItemsShowed and (i > scrollingValue) then
				if isMouseInPosition(startX + sizeX - 105, startY + 45 + (35 * (i - scrollingValue - 1)) + 5, 95, 30) then
					-- ** NÉV, $, PP, ITEMID
					paymentDetails = {v[1], v[2], v[3], v[6]}
					paymentIsInProgress = true
				end
			end
		end
		if isMouseInPosition(startX + sizeX - 20, startY + 6, 12, 12) then
			changeShopState("close")
		end
		if paymentIsInProgress then
			local sizeX, sizeY = 350, 75
			local startX, startY = sX / 2 - sizeX / 2, sY / 2 + 405 / 2 + 5
			if isMouseInPosition(startX + sizeX - 20, startY + 6, 12, 12) then
				paymentIsInProgress = false
				paymentDetails = {}
			end

			-- ** $-AL VÁSÁRLÁS
			if isMouseInPosition(startX + 5, startY + sizeY - 30, (sizeX - 10) / 2 - 5, 25) then
				if paymentDetails[2] == "-" then
					exports.a_interface:makeNotification(2, "A kiválasztott tárgyat nem tudod megvásárolni ezzel a fizetőeszközzel.")
					return
				end
				triggerServerEvent("tryToPurchase", localPlayer, localPlayer, "$", paymentDetails[4], paymentDetails[2])
			end

			-- ** PP-VEL VÁSÁRLÁS
			if isMouseInPosition(startX + 5 + (sizeX - 10) / 2, startY + sizeY - 30, (sizeX - 10) / 2, 25) then
				triggerServerEvent("tryToPurchase", localPlayer, localPlayer, "pp", paymentDetails[4], paymentDetails[3])
			end
		end
	end
end

function onKey(key, state)
	if key == "mouse_wheel_up" then
		if scrollingValue > 0  then
			scrollingValue = scrollingValue -1
			maxItemsShowed = maxItemsShowed -1
		end
	elseif key == "mouse_wheel_down" then
		if maxItemsShowed < #itemsInShop then
			scrollingValue = scrollingValue +1
			maxItemsShowed = maxItemsShowed +1
		end
	end
end

function openClose(key, state)
	if key == "F4" and state then
		if panelState == "opened" then
			changeShopState("close")
		else
			changeShopState("open")
		end
	end
end
addEventHandler("onClientKey", root, openClose)

function purchaseResponse(element, type)
	if not (element == localPlayer) then
		return
	end
	if type == "failed.notEnoughMoney" then
		paymentDetails = {}
		paymentIsInProgress = false
		exports.a_interface:makeNotification(2, "Nincs elég pénzed a művelet végrehajtásához.")
	elseif type == "failed.notEnoughPP" then
		paymentDetails = {}
		paymentIsInProgress = false
		exports.a_interface:makeNotification(2, "Nincs elég prémiumpontod a művelet végrehajtásához.")
	elseif type == "success" then
		exports.a_interface:makeNotification(1, "Sikeresen vettél egy " .. paymentDetails[1] .. "-t/et.")
		paymentDetails = {}
		paymentIsInProgress = false
	end
end
addEvent("purchaseResponse", true)
addEventHandler("purchaseResponse", root, purchaseResponse)