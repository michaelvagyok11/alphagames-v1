local panelState = "panelClosed";
local sX, sY = guiGetScreenSize();
local sizeX, sizeY = 750, 400;
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2

local robotoBold = dxCreateFont("files/fonts/Roboto-BoldCondensed.otf", 12)
local robotoRegular = dxCreateFont("files/fonts/Roboto-Condensed.otf", 12)

local maxItemsShowed = 4
local scrollingValue = 0

function openPanel()
    if panelState == "panelClosed" then
        panelState = "panelOpened"
        openTick = getTickCount()
        addEventHandler("onClientRender", root, onRender)
    else
        panelState = "panelClosed"
        removeEventHandler("onClientRender", root, onRender)
    end
end

function onRender()
    if panelState == "panelOpened" then
        local nowTick = getTickCount()
        local elapsedTime = nowTick - openTick
        local duration = elapsedTime / 500
        a = interpolateBetween(0, 0, 0, 240, 0, 0, duration, "Linear")

        roundedRectangle(startX, startY, sizeX, sizeY, tocolor(60, 60, 60, a))
        roundedRectangle(startX + 2, startY + 2, sizeX - 4, sizeY - 4, tocolor(45, 45, 45, a))
        roundedRectangle(startX + 4, startY + 4, sizeX - 8, 25, tocolor(60, 60, 60, a))
        dxDrawText("#D19D6BAlpha#c8c8c8Games - Chests", startX + sizeX / 2, startY + 16.5, _, _, tocolor(255, 255, 255, a), 1, robotoBold, "center", "center", false, false, false, true)

        if isCursorInBox(startX + 8, startY + 8, 16, 16) then
            dxDrawImage(startX + 8, startY + 8, 16, 16, "files/img/arrow.png", 180, 0, 0, tocolor(200, 200, 200, a))
        else
            dxDrawImage(startX + 8, startY + 8, 16, 16, "files/img/arrow.png", 180, 0, 0, tocolor(150, 150, 150, a))
        end

        if isCursorInBox(startX + sizeX - 24, startY + 8, 16, 16) then
            dxDrawImage(startX + sizeX - 24, startY + 8, 16, 16, "files/img/arrow.png", 0, 0, 0, tocolor(200, 200, 200, a))
        else
            dxDrawImage(startX + sizeX - 24, startY + 8, 16, 16, "files/img/arrow.png", 0, 0, 0, tocolor(150, 150, 150, a))
        end

        for k, v in ipairs(chests) do 
            if k <= maxItemsShowed and (k > scrollingValue) then
                roundedRectangle(startX + 10 + (k - scrollingValue - 1)*(700 / 4 + 10), startY + 40, 700 / 4, sizeY - 50, tocolor(50, 50, 50, a))
                dxDrawText(v["color"][4] .. v["visibleName"] .. " #c8c8c8chest", startX + 700/6 - 20 + (k - scrollingValue - 1)*185, startY + 170, _, _, tocolor(200, 200, 200, a), 1, robotoBold, "center", "center", false, false, false, true)
                dxDrawImage(startX + 45 + (k - scrollingValue - 1)*(700 / 4 + 10), startY + 50, 100, 100, "files/img/chest1.png", 0, 0, 0, tocolor(255, 255, 255, a))
                dxDrawImage(startX + 45 + (k - scrollingValue - 1)*(700 / 4 + 10), startY + 50, 100, 100, "files/img/chest2.png", 0, 0, 0, tocolor(v["color"][1], v["color"][2], v["color"][3], a))
                dxDrawText(v["description"][1], startX + 700/6 - 20 + (k - scrollingValue - 1)*185, startY + sizeY / 2, _, _, tocolor(200, 200, 200, a), 1, robotoRegular, "center", "top", false, false, false, true)
            

                if isCursorInBox(startX + 10 + (k - scrollingValue - 1)*(700 / 4 + 10) + 10, startY + sizeY - 50, 700 / 4 - 20, 30) then
                    roundedRectangle(startX + 10 + (k - scrollingValue - 1)*(700 / 4 + 10) + 10, startY + sizeY - 50, 700 / 4 - 20, 30, tocolor(55, 55, 55, a))
                    dxDrawText("Vásárlás", startX + (700 / 8) + (k - scrollingValue - 1)*(700 / 4 + 10) + 10, startY + sizeY - 35, _, _,  tocolor(200, 200, 200, a), 1, robotoBold, "center", "center", false, false, false, true)
                else
                    roundedRectangle(startX + 10 + (k - scrollingValue - 1)*(700 / 4 + 10) + 10, startY + sizeY - 50, 700 / 4 - 20, 30, tocolor(65, 65, 65, a))
                    if tostring(v["currency"]) == "PP" then
                        dxDrawText("#8FC3E4" .. v["price"] .. "#c8c8c8" .. v["currency"], startX + (700 / 8) + (k - scrollingValue - 1)*(700 / 4 + 10) + 10, startY + sizeY - 35, _, _,  tocolor(200, 200, 200, a), 1, robotoBold, "center", "center", false, false, false, true)
                    else
                        dxDrawText("#9BE48F" .. v["price"] .. "#c8c8c8" .. v["currency"], startX + (700 / 8) + (k - scrollingValue - 1)*(700 / 4 + 10) + 10, startY + sizeY - 35, _, _,  tocolor(200, 200, 200, a), 1, robotoBold, "center", "center", false, false, false, true)
                    end
                end
            end
        end
    end
end

function onKey(key, state)
    if state and panelState == "panelOpened" then
        if isCursorInBox(startX, startY, sizeX, sizeY) then
			if key == "mouse_wheel_up" then
				if scrollingValue > 0  then
					scrollingValue = scrollingValue - 1
					maxItemsShowed = maxItemsShowed - 1
				end
			elseif key == "mouse_wheel_down" then
				if maxItemsShowed < #chests then
					scrollingValue = scrollingValue + 1
					maxItemsShowed = maxItemsShowed + 1
				end
			end
		end
    end
    if key == "F2" and state and getElementData(localPlayer, "loggedIn") == true then
        openPanel()
    elseif key == "mouse1" and state then
        if isCursorInBox(startX + sizeX - 24, startY + 8, 16, 16) then
            if maxItemsShowed < #chests then
                scrollingValue = scrollingValue + 1
                maxItemsShowed = maxItemsShowed + 1
            end
        end
        if isCursorInBox(startX + 8, startY + 8, 16, 16) then
            if scrollingValue > 0  then
                scrollingValue = scrollingValue - 1
                maxItemsShowed = maxItemsShowed - 1
            end
        end
    end
end
addEventHandler("onClientKey", root, onKey)

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if panelState == "panelOpened" and button == "left" and state == "down" then
        for k, v in ipairs(chests) do 
            if k <= maxItemsShowed and (k > scrollingValue) then
                if isCursorInBox(startX + 10 + (k - scrollingValue - 1)*(700 / 4 + 10) + 10, startY + sizeY - 50, 700 / 4 - 20, 30) then
                    if v["currency"] == "$" then
                        triggerServerEvent("attemptToBuy", localPlayer, localPlayer, {v["currency"], v["price"], v["itemid"]})
                        
                        --[[currentPlayerMoney = getElementData(localPlayer, "a.Money")
                        if currentPlayerMoney >= v["price"] then
                            hexcolor = v["color"][4]
                            setElementData(localPlayer, "a.Money", currentPlayerMoney - v["price"])
                            exports.a_interface:makeNotification(1, "You have successfully bought a/an " .. hexcolor .. v["visibleName"] .. " chest#c8c8c8 for #9BE48F" .. v["price"] .. "$#c8c8c8.")
                            exports.a_inventory:givePlayerItem(v["itemid"], false, 1, 1, 100, false)
                        else
                            exports.a_interface:makeNotification(2, "You dont have enough money.")
                        end]]--
                    else
                        currentPlayerPP = getElementData(localPlayer, "a.Premiumpont")
                        if currentPlayerPP >= v["price"] then
                            hexcolor = v["color"][4]
                            setElementData(localPlayer, "a.Premiumpont", currentPlayerPP - v["price"])
                            exports.a_interface:makeNotification(1, "You have successfully bought a/an " .. hexcolor .. v["visibleName"] .. " chest#c8c8c8 for #8FC3E4" .. v["price"] .. "PP#c8c8c8.")
                            exports.a_inventory:givePlayerItem(v["itemid"], false, 1, 1, 100, false)
                        else
                            exports.a_interface:makeNotification(2, "You dont have enough PP.")
                        end
                    end
                end
            end
        end
    end
end
addEventHandler("onClientClick", root, onClick)

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end	

		if (not bgColor) then
			bgColor = borderColor;
		end

		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
end

function isCursorInBox ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end