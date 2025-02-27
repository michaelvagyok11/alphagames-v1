sX, sY = guiGetScreenSize();

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

local sizeX, sizeY = respc(842.5), (350);
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
local panelSize = {sizeX, sizeY} 

local scrollingValue = 0;
local maxItemsShowed = 10;
local panelState = "closed";
local currentPage = 1;
local closeTick = getTickCount()

local barlowBoldSmall = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(12), false, "cleartype")
local barlowThinSmall = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(12), false, "cleartype")

local barlowBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(15), false, "cleartype")
local barlowLightBig = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(15), false, "cleartype")
local barlowRegularBig = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(13), false, "cleartype")

local barlowBoldVeryBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(14), false, "cleartype")
local barlowRegularVeryBig = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(14), false, "cleartype")

local shopCategories = {"Játékmenet", "Fegyverek"}

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
		shoppingTick = getTickCount()
		currentShopping = false

		currentSelectedCategory = 1
		maxItemsShowed = 4
		scrollingValue = 0
	end
end

--setTimer(changeShopState, 500, 1, "opened")

local genderpanelW, genderpanelH = respc(360), respc(150)
local genderpanelX, genderpanelY = sX / 2 - respc(360) / 2, sY / 2 - respc(150) / 2

function renderCurrentShopping()
	buttons = {}

    if currentShopping then
		if not currentShopping then return end
        dxDrawFadeRectangle(genderpanelX, genderpanelY, genderpanelW, genderpanelH, {20, 20, 20, a})

        --dxDrawText("alpha", genderpanelX + respc(2), genderpanelY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldSmall, "left", "center")
        --dxDrawText("SHOP", genderpanelX + respc(3.5) + dxGetTextWidth("alpha", 1, barlowBoldSmall), genderpanelY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowRegularSmall, "left", "center")


        dxDrawText("Biztosan megszeretnéd vásárolni a kiválasztott tárgyat?", genderpanelX + respc(100), genderpanelY + respc(30) - respc(15), genderpanelX + genderpanelW, genderpanelY + genderpanelH - respc(30), tocolor(200, 200, 200, a), 1, barlowLightBig)
        dxDrawText("Kilépéshez használd a(z) <BACKSPACE> gombot.", genderpanelX + respc(42), genderpanelY + respc(125), genderpanelX + genderpanelW, genderpanelY + genderpanelH - respc(30), tocolor(200, 200, 200, a), 0.65, barlowLightBig)


        createButton("male", "  Férfi skinek", genderpanelX + respc(7) + respc(130) - respc(92), genderpanelY + genderpanelH - respc(30) - respc(70), respc(130), respc(30), {153, 184, 152, a})
        createButton("female", "  Női skinek", genderpanelX + respc(7) + respc(130) + respc(48), genderpanelY + genderpanelH - respc(30) - respc(70), respc(130), respc(30), {232, 74, 95, a})
        createButton("premium", "  Prémium skinek", genderpanelX + respc(7) + respc(130) - respc(23), genderpanelY + genderpanelH - respc(30) - respc(32), respc(130), respc(30), {240, 220, 120, a})

        buttons.male = {genderpanelX + respc(7) + respc(130) + respc(-92), genderpanelY + genderpanelH - respc(30) - respc(45), respc(130), respc(30)}
        buttons.female = {genderpanelX + respc(7) + respc(130) + respc(48), genderpanelY + genderpanelH - respc(30) - respc(45), respc(130), respc(30)}
        buttons.premium = {genderpanelX + respc(7) + respc(130) + respc(-23), genderpanelY + genderpanelH - respc(30) - respc(7), respc(130), respc(30)}
    end   

    local relX, relY = getCursorPosition()

    activeButtons = false

    if relX and relY then
        relX = relX * sX
        relY = relY * sY

        for k, v in pairs(buttons) do
            if relX >= v[1] and relY >= v[2] and relX <= v[1] + v[3] and relY <= v[2] + v[4] then
                activeButtons = k
                break
            end
        end
    end
end
addEventHandler("onClientRender", getRootElement(), renderCurrentShopping)

function onRender()
	buttons = {}

	if not panelState == "opened" then
		return
	end

	local nowTick = getTickCount()
	local elapsedTime = nowTick - openTick
	local duration = elapsedTime / 300
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	if not currentShopping then
		dxDrawText("alpha", startX + respc(2), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldBig, "left", "center")
    	dxDrawText("SHOP", startX + respc(3.5) + dxGetTextWidth("alpha", 1, barlowBoldBig), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowLightBig, "left", "center")
		dxDrawRoundedRectangle(startX, startY, sizeX, sizeY, 3, tocolor(35, 35, 35, a))
	else
		--dxDrawText("alpha", startX + respc(102), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldBig, "left", "center")
    	--dxDrawText("SHOP", startX + respc(103.5) + dxGetTextWidth("alpha", 1, barlowBoldBig), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowLightBig, "left", "center")
		--dxDrawRoundedRectangle(startX + respc(100), startY, sizeX - respc(200), sizeY, 3, tocolor(35, 35, 35, a))
	end
	
	for i, v in ipairs(shopCategories) do
		catW, catH = (sizeX - (respc(5) * (#shopCategories + 1) )) / #shopCategories, respc(35)
		catX, catY = startX + (catW + respc(5))*(i - 1) + respc(5), startY + respc(5)

		if isMouseInPosition(catX, catY, catW, catH) or currentSelectedCategory == i then
			if not currentShopping then
				dxDrawRoundedRectangle(catX, catY, catW, catH, 3, tocolor(55, 55, 55, a))
				dxDrawText(v, catX + catW / 2, catY + catH / 2 - 2, _, _, tocolor(200, 200, 200, a), 1, barlowBoldSmall, "center", "center")
			end
		else
			if not currentShopping then
				dxDrawRoundedRectangle(catX, catY, catW, catH, 3, tocolor(45, 45, 45, a))
				dxDrawText(v, catX + catW / 2, catY + catH / 2 - 2, _, _, tocolor(150, 150, 150, a), 1, barlowThinSmall, "center", "center")
			end
		end
	end

	if currentSelectedCategory == 1 then
		if currentShopping then
			a2 = interpolateBetween(255, 0, 0, 0, 0, 0, (nowTick - shoppingTick) / 250, "Linear")
			a3 = interpolateBetween(0, 0, 0, 255, 0, 0, (nowTick - shoppingTick) / 750, "Linear")
		else
			a3 = interpolateBetween(255, 0, 0, 0, 0, 0, (nowTick - shoppingTick) / 250, "Linear")
			a2 = interpolateBetween(0, 0, 0, 255, 0, 0, (nowTick - shoppingTick) / 750, "Linear")
		end

		if not currentShopping then
			dxDrawRoundedRectangle(startX + respc(5), startY + respc(45), sizeX - respc(12), sizeY - respc(50), 3, tocolor(45, 45, 45, a))
		elseif currentShopping then
			--dxDrawRoundedRectangle(startX + respc(5), startY + respc(5), sizeX - respc(10), sizeY - respc(10), 3, tocolor(45, 45, 45, a))
		end

		for i, v in ipairs(itemsInShop[currentSelectedCategory]) do 
			itemW, itemH = respc(200), sizeY - respc(65)
			itemX, itemY = startX + respc(10) + ((itemW + respc(5)) * (i - scrollingValue - 1)), startY + respc(50) 

			if (i <= maxItemsShowed) and (i > scrollingValue) then
				if isMouseInPosition(itemX, itemY, itemW, itemH) then
					dxDrawRoundedRectangle(itemX, itemY, itemW, itemH, 3, tocolor(30, 30, 30, a2))
				
					dxDrawImage(itemX + itemW / 2 - respc(25), itemY + respc(25), respc(50), respc(50), "files/img/nopreview.png", 0, 0, 0, tocolor(255, 255, 255, a2/0.5))
					dxDrawText("#" .. i, itemX + respc(5), itemY, _, _, tocolor(100, 100, 100, a2), 1, barlowThinSmall, "left", "top")
					dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(255, 255, 255, a2), 1, barlowBoldBig, "center", "center", false, true)
					
					if v[2] == "-" and getElementData(localPlayer, "a.VIP") == false then
						dxDrawText("#8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(255, 255, 255, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
					elseif getElementData(localPlayer, "a.VIP") == false then
						dxDrawText("#9BE48F" .. v[2] .. "$ #c8c8c8/ #8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(255, 255, 255, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
					end

					if v[2] == "-" and getElementData(localPlayer, "a.VIP") == true then
						--print("benne van a reszben a kurzor es a vip ertek true")
						dxDrawText("#8FC3E4" .. v[3] * 0.80 .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(255, 255, 255, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
					elseif getElementData(localPlayer, "a.VIP") == true then
						dxDrawText("#9BE48F" .. v[2] * 0.80 .. "$ #c8c8c8/ #8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(255, 255, 255, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
					end

					dxDrawImage(itemX, itemY, itemW, itemH, "files/img/bg.png", 0, 0, 0, tocolor(140, 195, 230, a2*0.5))
					dxDrawText("VÁSÁRLÁS", itemX + itemW /2, itemY + itemH - respc(25), _, _, tocolor(255, 255, 255, a2), 1, barlowBoldBig, "center", "center")
				else
					dxDrawRoundedRectangle(itemX, itemY, itemW, itemH, 3, tocolor(25, 25, 25, a2))
					dxDrawImage(itemX + itemW / 2 - respc(25), itemY + respc(25), respc(50), respc(50), "files/img/nopreview.png", 0, 0, 0, tocolor(255, 255, 255, a2/0.5))
					dxDrawText("#" .. i, itemX + respc(5), itemY, _, _, tocolor(100, 100, 100, a2), 1, barlowThinSmall, "left", "top")


					if v[2] == "-" and getElementData(localPlayer, "a.VIP") == false then
						dxDrawText("#8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(200, 200, 200, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
						dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(240, 220, 120, a2), 1, barlowBoldBig, "center", "center", false, true)
						dxDrawImage(itemX, itemY, itemW, itemH, "files/img/bg.png", 0, 0, 0, tocolor(240, 220, 120, a2*0.3), true)
					elseif getElementData(localPlayer, "a.VIP") == false then
						dxDrawText("#9BE48F" .. v[2] .. "$ #c8c8c8/ #8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(200, 200, 200, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
						dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(200, 200, 200, a2), 1, barlowBoldBig, "center", "center", false, true)
					end

					if v[2] == "-" and getElementData(localPlayer, "a.VIP") == true then
						dxDrawText("#8FC3E4" .. v[3] * 0.80 .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(200, 200, 200, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
						dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(240, 220, 120, a2), 1, barlowBoldBig, "center", "center", false, true)
						dxDrawImage(itemX, itemY, itemW, itemH, "files/img/bg.png", 0, 0, 0, tocolor(240, 220, 120, a2*0.3), true)
					elseif getElementData(localPlayer, "a.VIP") == true then
						dxDrawText("#9BE48F" .. v[2] * 0.80 .. "$ #c8c8c8/ #8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(200, 200, 200, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
						dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(200, 200, 200, a2), 1, barlowBoldBig, "center", "center", false, true)
					end
	
					dxDrawText("VÁSÁRLÁS", itemX + itemW /2, itemY + itemH - respc(25), _, _, tocolor(200, 200, 200, a2), 1, barlowLightBig, "center", "center")
				end
			end
		end

		
		if currentShopping then
			--dxDrawRoundedRectangle(startX + respc(10), startY + respc(50), respc(400), sizeY - respc(60), 3, tocolor(30, 30, 30, a3))
			--dxDrawText("TÁRGY", startX + sizeX / 2 + respc(10), startY + respc(75), _, _, tocolor(150, 150, 150, a3), 1, barlowRegularVeryBig, "left", "center", false, false, false, true)
			--dxDrawText(itemsInShop[currentSelectedCategory][currentSelectedItem][1], startX + sizeX / 2 + respc(10), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 0.75, barlowBoldVeryBig, "left", "center", false, false, false, true)

			if getElementData(localPlayer, "a.VIP") == false then
				dxDrawText("ÁR ($)", startX + sizeX / 2 + respc(225), startY + respc(75), _, _, tocolor(150, 150, 150, a3), 1, barlowRegularVeryBig, "left", "center", false, false, false, true)
				dxDrawText("#9BE48F" .. itemsInShop[currentSelectedCategory][currentSelectedItem][2] .. "$", startX + sizeX / 2 + respc(225), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "left", "center", false, false, false, true)

				dxDrawText("ÁR (PP)", startX + sizeX / 2 + respc(325), startY + respc(75), _, _, tocolor(150, 150, 150, a3), 1, barlowRegularVeryBig, "left", "center", false, false, false, true)
				dxDrawText("#8FC3E4" .. itemsInShop[currentSelectedCategory][currentSelectedItem][3] .. "PP", startX + sizeX / 2 + respc(325), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "left", "center", false, false, false, true)
			else
				dxDrawText("ÁR ($)", startX + sizeX / 2 + respc(225), startY + respc(75), _, _, tocolor(150, 150, 150, a3), 1, barlowRegularVeryBig, "left", "center", false, false, false, true)
				if itemsInShop[currentSelectedCategory][currentSelectedItem][2] == "-" then
					dxDrawText("#9BE48F" .. itemsInShop[currentSelectedCategory][currentSelectedItem][2] .. "$", startX + sizeX / 2 + respc(225), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "left", "center", false, false, false, true)
				else
					dxDrawText("#9BE48F" .. itemsInShop[currentSelectedCategory][currentSelectedItem][2] * 0.80 .. "$", startX + sizeX / 2 + respc(225), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "left", "center", false, false, false, true)
				end
				dxDrawText("ÁR (PP)", startX + sizeX / 2 + respc(325), startY + respc(75), _, _, tocolor(150, 150, 150, a3), 1, barlowRegularVeryBig, "left", "center", false, false, false, true)
				dxDrawText("#8FC3E4" .. itemsInShop[currentSelectedCategory][currentSelectedItem][3] .. "PP", startX + sizeX / 2 + respc(325), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "left", "center", false, false, false, true)
			end

			--[[if isMouseInPosition(startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45)) then
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45), 3, tocolor(155, 230, 140, a3*0.5))
				--dxDrawText("VÁSÁRLÁS ($)", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(45)/2, _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "center", "center")
			else
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45), 3, tocolor(65, 65, 65, a3))
				dxDrawText("VÁSÁRLÁS ($)", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(45)/2, _, _, tocolor(200, 200, 200, a3), 1, barlowRegularVeryBig, "center", "center")
			end

			if isMouseInPosition(startX + sizeX / 2 + respc(5), startY + genderpanelY + respc(50), sizeX / 2 - respc(30), respc(45)) then
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(5), startY + genderpanelY + respc(50), sizeX / 2 - respc(30), respc(45), 3, tocolor(140, 195, 230, a3*0.5))
				--dxDrawText("VÁSÁRLÁS (PP)", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(50) + respc(45)/2, _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "center", "center")
			else
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(5), startY + genderpanelY + respc(50), sizeX / 2 - respc(30), respc(45), 3, tocolor(65, 65, 65, a3))
				dxDrawText("VÁSÁRLÁS (PP)", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(50) + respc(45)/2, _, _, tocolor(200, 200, 200, a3), 1, barlowRegularVeryBig, "center", "center")
			end]]

			--[[createButton("buy", "Vásárlás ($)", startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45),  {124, 197, 118})

			buttons.buy = {startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45)}

			local relX, relY = getCursorPosition()

    		activeButton = false

    		if relX and relY then
        		relX = relX * sX
        		relY = relY * sY

        		for k, v in pairs(buttons) do
            		if relX >= v[1] and relY >= v[2] and relX <= v[1] + v[3] and relY <= v[2] + v[4] then
                		activeButton = k
                		break
            		end
        		end
    		end]]

			--renderCurrentShopping()

			if isMouseInPosition(startX + sizeX / 2 + respc(25), startY + genderpanelY + respc(100), sizeX / 2 - respc(70), respc(45)) then
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(25), startY + genderpanelY + respc(100), sizeX / 2 - respc(70), respc(45), 3, tocolor(230, 140, 140, a3*0.5))
				dxDrawText("VISSZALÉPÉS", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(100) + respc(45)/2, _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "center", "center")
			else
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(25), startY + genderpanelY + respc(100), sizeX / 2 - respc(70), respc(45), 3, tocolor(230, 140, 140, a3*0.25))
				dxDrawText("VISSZALÉPÉS", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(100) + respc(45)/2, _, _, tocolor(200, 200, 200, a3), 1, barlowRegularVeryBig, "center", "center")
			end
		end

		local maxVariable = 4
		if #itemsInShop[currentSelectedCategory] > maxVariable then
			local listHeight = maxVariable * respc(205) - respc(5)
			local visibleItems = (#itemsInShop[currentSelectedCategory] - maxVariable) + 1
	
			local scrollbarHeight = (listHeight / visibleItems)
	
			if scrollTick then
				scrollbarX = interpolateBetween(scrollbarX, 0, 0, startX + respc(10) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 200, "Linear")
				--scrollbarY = interpolateBetween(scrollbarY, 0, 0, startY + respc(52.5) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 200, "Linear")
			else
				scrollbarX = startX + respc(10) + (scrollingValue * scrollbarHeight)
				--scrollbarY = startY + respc(52.5) + (scrollingValue * scrollbarHeight)
			end
			if not currentShopping then
				dxDrawRectangle(startX + respc(10) - 1, startY + sizeY - respc(12), listHeight + 2, respc(3), tocolor(65, 65, 65, a))
				dxDrawRectangle(scrollbarX + 1, startY + sizeY - respc(10) - 1, scrollbarHeight, 2, tocolor(240, 195, 120, a*0.5))
			end
		end
		
	elseif currentSelectedCategory == 2 then
		if currentShopping then
			a2 = interpolateBetween(255, 0, 0, 0, 0, 0, (nowTick - shoppingTick) / 250, "Linear")
			a3 = interpolateBetween(0, 0, 0, 255, 0, 0, (nowTick - shoppingTick) / 750, "Linear")
		else
			a3 = interpolateBetween(255, 0, 0, 0, 0, 0, (nowTick - shoppingTick) / 250, "Linear")
			a2 = interpolateBetween(0, 0, 0, 255, 0, 0, (nowTick - shoppingTick) / 750, "Linear")
		end

		dxDrawRoundedRectangle(startX + respc(5), startY + respc(45), sizeX - respc(12), sizeY - respc(50), 3, tocolor(45, 45, 45, a))

		for i, v in ipairs(itemsInShop[currentSelectedCategory]) do 
			itemW, itemH = respc(200), sizeY - respc(65)
			itemX, itemY = startX + respc(10) + ((itemW + respc(5)) * (i - scrollingValue - 1)), startY + respc(50) 

			if (i <= maxItemsShowed) and (i > scrollingValue) then
				if isMouseInPosition(itemX, itemY, itemW, itemH) then
					dxDrawRoundedRectangle(itemX, itemY, itemW, itemH, 3, tocolor(30, 30, 30, a2))
				
					dxDrawImage(itemX + itemW / 2 - respc(25), itemY + respc(25), respc(50), respc(50), ":dItems/files/items/" .. (v[6] - 1) .. ".png", 0, 0, 0, tocolor(255, 255, 255, a2))
					dxDrawText("#" .. i, itemX + respc(5), itemY, _, _, tocolor(100, 100, 100, a2), 1, barlowThinSmall, "left", "top")
					dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(255, 255, 255, a2), 1, barlowBoldBig, "center", "center", false, true)
					if v[2] == "-" and getElementData(localPlayer, "a.VIP") == false then
						dxDrawText("#8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(255, 255, 255, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
					elseif getElementData(localPlayer, "a.VIP") == false then
						dxDrawText("#9BE48F" .. v[2] .. "$ #c8c8c8/ #8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(255, 255, 255, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
					end

					if v[2] == "-" and getElementData(localPlayer, "a.VIP") == true then
						dxDrawText("#8FC3E4" .. v[3] * 0.80 .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(255, 255, 255, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
					elseif getElementData(localPlayer, "a.VIP") == true then
						dxDrawText("#9BE48F" .. v[2] * 0.80 .. "$ #c8c8c8/ #8FC3E4" .. v[3] * 0.80 .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(255, 255, 255, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
					end

					dxDrawImage(itemX, itemY, itemW, itemH, "files/img/bg.png", 0, 0, 0, tocolor(140, 195, 230, a2*0.5))
					dxDrawText("VÁSÁRLÁS", itemX + itemW /2, itemY + itemH - respc(25), _, _, tocolor(255, 255, 255, a2), 1, barlowBoldBig, "center", "center")
				else
					dxDrawRoundedRectangle(itemX, itemY, itemW, itemH, 3, tocolor(25, 25, 25, a2))
					dxDrawImage(itemX + itemW / 2 - respc(25), itemY + respc(25), respc(50), respc(50), ":dItems/files/items/" .. (v[6] - 1) .. ".png", 0, 0, 0, tocolor(255, 255, 255, a2/0.5))
					dxDrawText("#" .. i, itemX + respc(5), itemY, _, _, tocolor(100, 100, 100, a2), 1, barlowThinSmall, "left", "top")


					if v[2] == "-" and getElementData(localPlayer, "a.VIP") == false then
						dxDrawText("#8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(200, 200, 200, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
						dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(240, 220, 120, a2), 1, barlowBoldBig, "center", "center", false, true)
						dxDrawImage(itemX, itemY, itemW, itemH, "files/img/bg.png", 0, 0, 0, tocolor(240, 220, 120, a2*0.3), true)
					elseif getElementData(localPlayer, "a.VIP") == false then
						dxDrawText("#9BE48F" .. v[2] .. "$ #c8c8c8/ #8FC3E4" .. v[3] .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(200, 200, 200, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
						dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(200, 200, 200, a2), 1, barlowBoldBig, "center", "center", false, true)
					end

					if v[2] == "-" and getElementData(localPlayer, "a.VIP") == true then
						dxDrawText("#8FC3E4" .. v[3] * 0.80 .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(200, 200, 200, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
						dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(240, 220, 120, a2), 1, barlowBoldBig, "center", "center", false, true)
						dxDrawImage(itemX, itemY, itemW, itemH, "files/img/bg.png", 0, 0, 0, tocolor(240, 220, 120, a2*0.3), true)
					elseif getElementData(localPlayer, "a.VIP") == true then
						dxDrawText("#9BE48F" .. v[2] * 0.80 .. "$ #c8c8c8/ #8FC3E4" .. v[3] * 0.80 .. "PP", itemX + itemW / 2, itemY + itemH / 2 + respc(30), _, _, tocolor(200, 200, 200, a2), 1, barlowRegularBig, "center", "center", false, false, false, true)
						dxDrawText(v[1], itemX + respc(10), itemY, itemX + itemW - respc(10), itemY + itemH - respc(35), tocolor(200, 200, 200, a2), 1, barlowBoldBig, "center", "center", false, true)
					end
	
					dxDrawText("VÁSÁRLÁS", itemX + itemW /2, itemY + itemH - respc(25), _, _, tocolor(200, 200, 200, a2), 1, barlowLightBig, "center", "center")
				end
			end
		end
		
		if currentShopping then
			--dxDrawRoundedRectangle(startX + respc(10), startY + respc(50), respc(400), sizeY - respc(60), 3, tocolor(30, 30, 30, a3))
			dxDrawText("TÁRGY", startX + sizeX / 2 + respc(10), startY + respc(75), _, _, tocolor(150, 150, 150, a3), 1, barlowRegularVeryBig, "left", "center", false, false, false, true)
			dxDrawText(itemsInShop[currentSelectedCategory][currentSelectedItem][1], startX + sizeX / 2 + respc(10), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "left", "center", false, false, false, true)

			dxDrawText("ÁR ($)", startX + sizeX / 2 + respc(225), startY + respc(75), _, _, tocolor(150, 150, 150, a3), 1, barlowRegularVeryBig, "left", "center", false, false, false, true)
			dxDrawText("#9BE48F" .. itemsInShop[currentSelectedCategory][currentSelectedItem][2] .. "$", startX + sizeX / 2 + respc(225), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "left", "center", false, false, false, true)

			dxDrawText("ÁR (PP)", startX + sizeX / 2 + respc(325), startY + respc(75), _, _, tocolor(150, 150, 150, a3), 1, barlowRegularVeryBig, "left", "center", false, false, false, true)
			dxDrawText("#8FC3E4" .. itemsInShop[currentSelectedCategory][currentSelectedItem][3] .. "PP", startX + sizeX / 2 + respc(325), startY + respc(100), _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "left", "center", false, false, false, true)

			if isMouseInPosition(startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45)) then
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45), 3, tocolor(155, 230, 140, a3*0.5))
				dxDrawText("VÁSÁRLÁS ($)", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(45)/2, _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "center", "center")
			else
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45), 3, tocolor(65, 65, 65, a3))
				dxDrawText("VÁSÁRLÁS ($)", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(45)/2, _, _, tocolor(200, 200, 200, a3), 1, barlowRegularVeryBig, "center", "center")
			end

			if isMouseInPosition(startX + sizeX / 2 + respc(5), startY + genderpanelY + respc(50), sizeX / 2 - respc(30), respc(45)) then
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(5), startY + genderpanelY + respc(50), sizeX / 2 - respc(30), respc(45), 3, tocolor(140, 195, 230, a3*0.5))
				dxDrawText("VÁSÁRLÁS (PP)", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(50) + respc(45)/2, _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "center", "center")
			else
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(5), startY + genderpanelY + respc(50), sizeX / 2 - respc(30), respc(45), 3, tocolor(65, 65, 65, a3))
				dxDrawText("VÁSÁRLÁS (PP)", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(50) + respc(45)/2, _, _, tocolor(200, 200, 200, a3), 1, barlowRegularVeryBig, "center", "center")
			end

			if isMouseInPosition(startX + sizeX / 2 + respc(25), startY + genderpanelY + respc(100), sizeX / 2 - respc(70), respc(45)) then
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(25), startY + genderpanelY + respc(100), sizeX / 2 - respc(70), respc(45), 3, tocolor(230, 140, 140, a3*0.5))
				dxDrawText("VISSZALÉPÉS", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(100) + respc(45)/2, _, _, tocolor(255, 255, 255, a3), 1, barlowBoldVeryBig, "center", "center")
			else
				dxDrawRoundedRectangle(startX + sizeX / 2 + respc(25), startY + genderpanelY + respc(100), sizeX / 2 - respc(70), respc(45), 3, tocolor(230, 140, 140, a3*0.25))
				dxDrawText("VISSZALÉPÉS", startX + sizeX / 2 + respc(5) + (sizeX / 2 - respc(30))/2, startY + genderpanelY + respc(100) + respc(45)/2, _, _, tocolor(200, 200, 200, a3), 1, barlowRegularVeryBig, "center", "center")
			end
		end

		local maxVariable = 4
		if #itemsInShop[currentSelectedCategory] > maxVariable then
			local listHeight = maxVariable * respc(205) - respc(5)
			local visibleItems = (#itemsInShop[currentSelectedCategory] - maxVariable) + 1
	
			local scrollbarHeight = (listHeight / visibleItems)
	
			if scrollTick then
				scrollbarX = interpolateBetween(scrollbarX, 0, 0, startX + respc(10) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 200, "Linear")
			else
				scrollbarX = startX + respc(10) + (scrollingValue * scrollbarHeight)
			end
			if not currentShopping then
				dxDrawRectangle(startX + respc(10) - 1, startY + sizeY - respc(12), listHeight + 2, respc(3), tocolor(65, 65, 65, a))
				dxDrawRectangle(scrollbarX + 1, startY + sizeY - respc(10) - 1, scrollbarHeight, 2, tocolor(240, 195, 120, a*0.5))
			end
		end
	end
end

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

function onClick(button, state)
	if not panelState == "opened" then
		return
	end

	if button == "left" and state == "down" then
		for i, v in ipairs(shopCategories) do
			catW, catH = (sizeX - (respc(5) * (#shopCategories + 1) )) / #shopCategories, respc(35)
			catX, catY = startX + (catW + respc(5))*(i - 1) + respc(5), startY + respc(5)
	
			if isMouseInPosition(catX, catY, catW, catH) and not currentShopping then
				currentSelectedCategory = i 
			end
		end

		if currentShopping then
			-- **DOLÁR:)
			--if isMouseInPosition(startX + sizeX / 2 + respc(5), startY + genderpanelY, sizeX / 2 - respc(30), respc(45)) and shoppingTick + 100 < getTickCount() then
			if activeButton == "buy" then
				print("vetel")
				triggerServerEvent("tryToPurchase", localPlayer, localPlayer, "$", itemsInShop[currentSelectedCategory][currentSelectedItem])
			end

			--** PP
			if isMouseInPosition(startX + sizeX / 2 + respc(5), startY + genderpanelY + respc(50), sizeX / 2 - respc(30), respc(45)) and shoppingTick + 100 < getTickCount() then
				triggerServerEvent("tryToPurchase", localPlayer, localPlayer, "pp", itemsInShop[currentSelectedCategory][currentSelectedItem])
			end

			-- ** VISSZALÉPÉS
			if isMouseInPosition(startX + sizeX / 2 + respc(25), startY + genderpanelY + respc(100), sizeX / 2 - respc(70), respc(45)) and shoppingTick + 100 < getTickCount() then
				currentSelectedItem = nil
				closeTick = getTickCount()
				shoppingTick = getTickCount()
				currentShopping = false
			end
		end

		for i, v in ipairs(itemsInShop[currentSelectedCategory]) do 
			itemW, itemH = respc(200), sizeY - respc(65)
			itemX, itemY = startX + respc(10) + ((itemW + respc(5)) * (i - scrollingValue - 1)), startY + respc(50) 

			if (i <= maxItemsShowed) and (i > scrollingValue) then
				if isMouseInPosition(itemX, itemY, itemW, itemH) and not currentShopping then
					if closeTick + 100 > getTickCount() then
						return
					end
					currentShopping = true
					currentSelectedItem = i
					shoppingTick = getTickCount()
				end
			end
		end
	end
end

function onKey(key, state)
	if currentSelectedCategory then
		if key == "mouse_wheel_up" then
			if not currentShopping then
				if scrollingValue > 0 then
					scrollTick = getTickCount()
					scrollingValue = scrollingValue -1
					maxItemsShowed = maxItemsShowed -1
				end
			end
		elseif key == "mouse_wheel_down" then
			if not currentShopping then
				if maxItemsShowed <( #(itemsInShop[currentSelectedCategory])) then
					scrollTick = getTickCount()
					scrollingValue = scrollingValue +1
					maxItemsShowed = maxItemsShowed +1
				end
			end
		end
	end
end

function openClose(key, state)
	if key == "F4" and state then
		if panelState == "opened" then
			changeShopState("close")
			showCursor(false)
		else
			changeShopState("open")
			showCursor(true)
		end
	end
	if key == "backspace" and state then
		if panelState == "opened" then
			changeShopState("close")
			showCursor(false)
		end
	end
end
addEventHandler("onClientKey", root, openClose)

function purchaseResponse(element, type)
	if not (element == localPlayer) then
		return
	end
	if type == "failed.notEnoughMoney" then
		exports.dInfobox:makeNotification(2, "Nincs elég pénzed a művelet végrehajtásához.")
	elseif type == "failed.notEnoughPP" then
		exports.dInfobox:makeNotification(2, "Nincs elég prémiumpontod a művelet végrehajtásához.")
	elseif type == "success" then
		exports.dInfobox:makeNotification(1, "Sikeresen megvásároltad a kiválasztott tárgyat.")
	elseif type == "failed.canNotPayWithCash" then
		exports.dInfobox:makeNotification(2, "Ezt az itemet csak PP-vel lehet megvásárolni.")
	elseif type == "failed.hpPurchase" then
		exports.dInfobox:makeNotification(2, "Már maxon van a HP-d.")
	elseif type == "failed.armor50" then
		exports.dInfobox:makeNotification(2, "Jelenlegi páncél szinted meghaladja az 50%-ot.")
	elseif type == "failed.armor100" then
		exports.dInfobox:makeNotification(2, "Már 100%-on van a páncélod.")
	end
end
addEvent("purchaseResponse", true)
addEventHandler("purchaseResponse", root, purchaseResponse)


local topTexture = dxCreateTexture("files/img/featherTop.dds", "dxt5", true, "clamp")
local sideTexture = dxCreateTexture("files/img/feather.dds", "dxt5", true, "clamp")
local cornerTexture = dxCreateTexture("files/img/corner.dds", "dxt5", true, "clamp")

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
