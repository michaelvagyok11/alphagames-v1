local menuIsOpen = false;
local sX, sY = guiGetScreenSize();
local panelSize = {200, 215};
local maxVehsShowed = 5;
local scrollingValue2 = 0;
local robotoBold = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 12)
local isBought = {}

function pressedButton(button, pressed)
	if (getElementData(localPlayer, "loggedIn")) then
		if (pressed) then
			if (button == "F1") then
                if (getElementData(localPlayer, "a.Gamemode") == 2) or (getElementData(localPlayer, "a.Gamemode") == 3) then
				    showPanel()
                    buttonTick = getTickCount()
					currentColor = ""
					panelState = ""
					panelType = ""
					scrollingValue2 = 0
					maxVehsShowed = 5

					local vehicleTable = getElementData(localPlayer, "a.BoughtVehs")
					for k, v in ipairs(vehicleTable) do
						if isValueInTable(accessibleVehs, v, 1) then
							isBought[v] = true
						else
							isBought[v] = false
						end
					end
                elseif (getElementData(localPlayer, "a.Gamemode") == nil) then
                    outputChatBox("#E48F8F► Hiba: #FFFFFFEz a panel csak Drift és Freeroam játékmódokban elérhető.", 255, 255, 255, true)
                else
                    outputChatBox("#E48F8F► Hiba: #FFFFFFEz a panel csak Drift és Freeroam játékmódokban elérhető.", 255, 255, 255, true)
                end
            end
        end
    end
end
addEventHandler("onClientKey", root, pressedButton)

function isValueInTable(theTable,value,columnID)
    assert(theTable, "Bad argument 1 @ isValueInTable (table expected, got " .. type(theTable) .. ")")
    local checkIsTable = type(theTable)
    assert(checkIsTable == "table", "Invalid value type @ isValueInTable (table expected, got " .. checkIsTable .. ")")
    assert(value, "Bad argument 2 @ isValueInTable (value expected, got " .. type(value) .. ")")
    assert(columnID, "Bad argument 3 @ isValueInTable (number expected, got " .. type(columnID) .. ")")
    local checkIsID = type(columnID)
    assert(checkIsID == "number", "Invalid value type @ isValueInTable (number expected, got " ..checkIsID .. ")")
    for i,v in ipairs (theTable) do
        if v[columnID] == value then
            return true,i
        end
    end
    return false
end

function onChange(key, oVal, nVal)
	if key == "a.Gamemode" and nVal == nil or nVal == 1 and menuIsOpen then
		if source == localPlayer then
			menuIsOpen = false
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

function showPanel()
	if (menuIsOpen == false) then
		menuIsOpen = true
    else
        menuIsOpen = false
		if isElement(colorPicker) then
			destroyElement(colorPicker)
		end
    end
end

function panelAnimation()
    if (menuIsOpen) then
        local nowTick = getTickCount()
        local elapsedTime = nowTick - buttonTick
        local duration = elapsedTime / 500
        a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")
    end
end
addEventHandler("onClientRender", root, panelAnimation)

function mainPanel()
	if (menuIsOpen) then
		startX = 10
		nowTick = getTickCount();

		if panelState == "expand" then
			h = interpolateBetween(panelSize[1], 0, 0, panelSize[1]*2, 0, 0, (nowTick - stateTick)/500, "Linear")
			a2 = interpolateBetween(0, 0, 0, 220, 0, 0, (nowTick - stateTick)/1000, "Linear")
		elseif panelState == "narrow" then
			h = interpolateBetween(h, 0, 0, panelSize[1], 0, 0, (nowTick - stateTick)/1000, "Linear")
			a2 = interpolateBetween(a2, 0, 0, 0, 0, 0, (nowTick - stateTick)/1000, "Linear")
		else
			h = panelSize[1]
			a2 = 0
		end

        dxDrawRectangle(startX, sY/2 - panelSize[2]/2, h, panelSize[2], tocolor(65, 65, 65, a)) -- alap panel
		dxDrawRectangle(startX + 2, sY/2 - panelSize[2]/2 + 2, h - 4, panelSize[2] - 4, tocolor(30, 30, 30, a)) -- alap panel
		dxDrawRectangle(startX, sY/2 - panelSize[2]/2, h, 25, tocolor(65, 65, 65, a)) -- alap panel
		dxDrawText("#E48F8Falpha#c8c8c8Games - Interakció", startX + 5, sY/2 - panelSize[2]/2 + 25/2 + 2.5, _, _, tocolor(200, 200, 200, a), 1, robotoBold, "left", "center", false, false, false, true)

		createButtonDx("Járműlista", startX + 15, sY/2 - panelSize[2]/2 + 35, panelSize[1] - 30, 30, "vehicle", a, "center");
		createButtonDx("Javítás", startX + 15, sY/2 - panelSize[2]/2 + 70, panelSize[1] - 30, 30, "repair", a, "center");
		createButtonDx("Visszafordítás", startX + 15, sY/2 - panelSize[2]/2 + 105, panelSize[1] - 30, 30, "unflip", a, "center");
		createButtonDx("Festés", startX + 15, sY/2 - panelSize[2]/2 + 140, panelSize[1] - 30, 30, "repaint", a, "center");
		
		if getElementData(localPlayer, "a.Driftmode") == "on" then
			syntax = "#9BE48F"
		else
			syntax = "#E48F8F"
		end
		
		createButtonDx(syntax .. "Driftmode", startX + 15, sY/2 - panelSize[2]/2 + 175, panelSize[1] - 30, 30, "drift", a, "center");
		
		if isMouseInPosition(startX + h - 25, sY/2 - panelSize[2]/2 + 25/4, 16, 16) then
			dxDrawImage(startX + h - 25, sY/2 - panelSize[2]/2 + 25/4, 16, 16, "files/img/arrow.png", 180, 0, 0, tocolor(200, 200, 200, a2))
		else
			dxDrawImage(startX + h - 25, sY/2 - panelSize[2]/2 + 25/4, 16, 16, "files/img/arrow.png", 180, 0, 0, tocolor(150, 150, 150, a2))
		end

		if panelType == "vehicle" then
			--** VEHICLE SPAWN

			for k, v in ipairs(accessibleVehs) do
				if k <= maxVehsShowed and (k > scrollingValue2) then
					if isBought[v[1]] then
						v[3] = "bought"
						syntax = ""
					else
						v[3] = v[3]
						syntax = "$"
					end

					createButtonDx(v[2] .. " #D19D6B(" .. v[3] .. syntax .. ")", startX + h/2 + 10, sY/2 - panelSize[2]/2 + 35 + ((k - scrollingValue2 - 1) * 35), h/3 + 50, 30, false, a2, "left")
				end
			end	

		elseif panelType == "repaint" and isPedInVehicle(localPlayer) then
			if isElement(colorPicker) then
				r, g, b, alpha = exports.a_dgs:dgsColorPickerGetColor(colorPicker)
			else
				r, g, b, alpha = getVehicleColor(getPedOccupiedVehicle(localPlayer), true)
			end
			dxDrawText("#E48F8FR: " .. r .. " \n#9BE48FG: " .. g .. " \n#8FC3E4B: " .. b .. " \n#c8c8c8A: " .. alpha, startX + panelSize[1] + 10, sY/2 + 60, _, _, tocolor(200, 200, 200, a2), 1, robotoBold, "left", "center", false, false, false, true)
			local r1, g1, b1, r2, g2, b2, _, _, _, _, _, _ = getVehicleColor(getPedOccupiedVehicle(localPlayer), true)
			if currentColor == "first" then
				setVehicleColor(getPedOccupiedVehicle(localPlayer), r, g, b, r2, g2, b2)
			elseif currentColor == "second" then
				setVehicleColor(getPedOccupiedVehicle(localPlayer), r1, g1, b1, r, g, b)
			elseif currentColor == "lights" then
				setVehicleHeadLightColor(getPedOccupiedVehicle(localPlayer), r, g, b)
			end
			createButtonDx("Color 1", startX + h - 65, sY/2 - panelSize[2]/2 + 40, 50, 30, false, a2, "center")
			createButtonDx("Color 2", startX + h - 65, sY/2 - panelSize[2]/2 + 75, 50, 30, false, a2, "center")
			createButtonDx("Lights", startX + h - 65, sY/2 - panelSize[2]/2 + 110, 50, 30, false, a2, "center")

			createButtonDx("Set", startX + h/2 + 85, sY/2 + panelSize[2]/2 - 45, h/4, 30, false, a2, "center")
		end
    end
end
addEventHandler("onClientRender", root, mainPanel)

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if not menuIsOpen then
		return
	end
	if button == "left" and state == "down" then
		--**CAR SPAWN
		if isMouseInPosition(startX + 15, sY/2 - panelSize[2]/2 + 35, panelSize[1] - 30, 30) then
			panelState = "expand";
			panelType = "vehicle";
			stateTick = getTickCount();
			if isElement(colorPicker) then
				destroyElement(colorPicker)
			end
		end

		if panelType == "vehicle" and not (isPedInVehicle(localPlayer)) and stateTick + 750 < nowTick then
			for k, v in ipairs(accessibleVehs) do
				if isMouseInPosition(startX + h/2 + 10, sY/2 - panelSize[2]/2 + 35 + ((k - scrollingValue2 - 1) * 35), h/3 + 50, 30) then
					local currentPlayerMoney = getElementData(localPlayer, "a.Money")
					if not (isBought[v[1]]) then
						if currentPlayerMoney >= tonumber(v[3]) then
							triggerServerEvent("requestServerResponse", localPlayer, localPlayer, "buyveh", v[1], v[3])
							isBought[v[1]] = true
						else
							exports.a_interface:makeNotification(2, "Nincs elég pénzed, hogy megvedd ezt a járművet.")
						end
					else
						if isTimer(spamTimer) then
							return
						end
						spamTimer = setTimer(function()

						end, 5000, 1)
						triggerServerEvent("requestServerResponse", localPlayer, localPlayer, "requestveh", v[1], tonumber(v[3]))
					end
				end
			end
		end

		--**FIX
		if isMouseInPosition(startX + 15, sY/2 - panelSize[2]/2 + 70, panelSize[1] - 30, 30) then
			if not isPedInVehicle(localPlayer) then
                outputChatBox("#E48F8F► Hiba: #FFFFFFEz a funkció csak járműben ülve elérhető.", 255, 255, 255, true)
				return
			end
			triggerServerEvent("requestServerResponse", localPlayer, localPlayer, "fixveh")
		end
		
		--**UNFLIP
		if isMouseInPosition(startX + 15, sY/2 - panelSize[2]/2 + 105, panelSize[1] - 30, 30) then
			if not isPedInVehicle(localPlayer) then
                outputChatBox("#E48F8F► Hiba: #FFFFFFEz a funkció csak járműben ülve elérhető.", 255, 255, 255, true)
				return
			end
			triggerServerEvent("requestServerResponse", localPlayer, localPlayer, "unflip")
		end

		--**REPAINT
		if isMouseInPosition(startX + 15, sY/2 - panelSize[2]/2 + 140, panelSize[1] - 30, 30) then
			if not isPedInVehicle(localPlayer) then
                outputChatBox("#E48F8F► Hiba: #FFFFFFEz a funkció csak járműben ülve elérhető.", 255, 255, 255, true)
				return
			end
			panelState = "expand";
			panelType = "repaint";
			stateTick = getTickCount();
			setTimer(function()
				colorPicker = exports.a_dgs:dgsCreateColorPicker("HSVRing", startX + panelSize[1] + 10, sY/2 - panelSize[2]/2 + 30, 100, 100, false)
			end, 500, 1)
		end

		if panelType == "repaint" then
			if isMouseInPosition(startX + panelSize[1] + h/2 - 65, sY/2 - panelSize[2]/2 + 40, 50, 30) then
				currentColor = "first"
			elseif isMouseInPosition(startX + panelSize[1] + h/2 - 65, sY/2 - panelSize[2]/2 + 75, 50, 30) then
				currentColor = "second"
			elseif isMouseInPosition(startX + panelSize[1] + h/2 - 65, sY/2 - panelSize[2]/2 + 110, 50, 30) then
				currentColor = "lights"
			end

			if isMouseInPosition(startX + h/2 + 85, sY/2 + panelSize[2]/2 - 45, h/4, 30) then
				triggerServerEvent("requestServerResponse", localPlayer, localPlayer, "repaint", currentColor, r, g, b)
				currentColor = ""
			end
		end

		--**DRIFTMODE
		if isMouseInPosition(startX + 15, sY/2 - panelSize[2]/2 + 175, panelSize[1] - 30, 30) then
			if not isPedInVehicle(localPlayer) then
                outputChatBox("#E48F8F► Hiba: #FFFFFFEz a funkció csak járműben ülve elérhető.", 255, 255, 255, true)
				return
			end
			if not (getElementData(localPlayer, "a.Gamemode") == 3) then
                outputChatBox("#E48F8F► Hiba: #FFFFFFEz a funkció csak a Drift játékmódban elérhető.", 255, 255, 255, true)
				return 
			end
			if getElementData(localPlayer, "a.Driftmode") == "on" then
				triggerServerEvent("requestServerResponse", localPlayer, localPlayer, "driftmode", "off")
			else
				triggerServerEvent("requestServerResponse", localPlayer, localPlayer, "driftmode", "on")
			end
		end

		--**NARROW
		if panelState == "expand" and isMouseInPosition(startX + h - 25, sY/2 - panelSize[2]/2 + 25/4, 16, 16) then
			panelState = "narrow"
			stateTick = getTickCount();
			if panelType == "repaint" then
				destroyElement(colorPicker)
				currentColor = ""
			end
			panelType = ""
		end
	end
end
addEventHandler("onClientClick", root, onClick)

function onKey(key, state)
	if not menuIsOpen then
		return
	end

	if state and panelType == "vehicle" then
		if isMouseInPosition(startX + h / 2, sY/2 - panelSize[2]/2, h/2, panelSize[2]) then
			if key == "mouse_wheel_up" then
				if scrollingValue2 > 0  then
					scrollingValue2 = scrollingValue2 - 1
					maxVehsShowed = maxVehsShowed - 1
				end
			elseif key == "mouse_wheel_down" then
				if maxVehsShowed < #accessibleVehs then
					scrollingValue2 = scrollingValue2 + 1
					maxVehsShowed = maxVehsShowed +1
				end
			end
		end
	end
end
addEventHandler("onClientKey", root, onKey)

function createButtonDx(text, x, y, w, h, img, a, align)
	dxDrawRectangle(x, y, w, h, tocolor(65, 65, 65, a))
	if isMouseInPosition(x, y, w, h) or panelType == img then
		dxDrawRectangle(x + 1, y + 1, w - 2, h - 2, tocolor(65, 65, 65, a))
		if not (img == false) then
			dxDrawImage(x + 10, y + h / 4, 16, 16, "files/img/" .. img .. ".png", 0, 0, 0, tocolor(200, 200, 200, a))
		end
	else
		dxDrawRectangle(x + 1, y + 1, w - 2, h - 2, tocolor(30, 30, 30, a))
		if not (img == false) then
			dxDrawImage(x + 10, y + h / 4, 16, 16, "files/img/" .. img .. ".png", 0, 0, 0, tocolor(150, 150, 150, a))
		end
	end

	if align == "left" then
		dxDrawText(text, x + 10, y + h / 2, _, _, tocolor(200, 200, 200, a), 1, robotoBold, align, "center", false, false, false, true)
	else
		dxDrawText(text, x + w / 2, y + h / 2, _, _, tocolor(200, 200, 200, a), 1, robotoBold, align, "center", false, false, false, true)
	end
end

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

function isMouseInPosition ( x, y, width, height )
	if (not isCursorShowing()) then
		return false
	end
	local sx, sy = guiGetScreenSize()
	local cx, cy = getCursorPosition()
	local cx, cy = (cx * sx), (cy * sy)
	
	return ((cx >= x and cx <= x + width) and (cy >= y and cy <= y + height))
end

function testDim(cmd)
    outputChatBox("client:" .. getElementDimension(localPlayer), 200, 255, 200, true)
end
addCommandHandler("testdim", testDim)

function offDriftIfNotInVehicle()
	if not (isPedInVehicle(localPlayer)) then
		triggerServerEvent("changeDataSync", localPlayer, "a.Driftmode", "off")
	end
end

addEventHandler("onClientRender", root, offDriftIfNotInVehicle)