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

local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(17), false, "cleartype")
local poppinsBold = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(14), false, "cleartype")
local poppinsRegular = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(14), false, "cleartype")

-- ** MARKER FUNCTIONS -- START

function onStart()
	enterMarker = createColCuboid(markerX - 1, markerY - 1, markerZ - 1, 2, 2, 3)
	addEventHandler("onClientRender", root, markerRender)
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onHit()
	if source == enterMarker then
		openTick = getTickCount()
		addEventHandler("onClientRender", root, onRender)
		addEventHandler("onClientClick", root, onClick)
		addEventHandler("onClientKey", root, onKey)

		setElementFrozen(localPlayer, true)
		showChat(false)
		setElementData(localPlayer, "a.HUDshowed", false)
		setCameraMatrix(vehicleX - 8, vehicleY, vehicleZ + 2, vehicleX, vehicleY, vehicleZ)

		paymentInProgress = false

		currentVehicleIndex = 1
		rotation = math.random(0, 360)
		currentVehicle = createVehicle(vehiclesForSale[currentVehicleIndex][1], vehicleX, vehicleY, vehicleZ)
	end
end
addEventHandler("onClientColShapeHit", root, onHit)

function onLeave()
	if source == enterMarker then
		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientClick", root, onClick)
		removeEventHandler("onClientKey", root, onKey)
		setCameraTarget(localPlayer)
		setElementFrozen(localPlayer, false)
	end
end
--addEventHandler("onClientColShapeLeave", root, onLeave)


function markerRender()
	if not (getElementDimension(localPlayer) == 0) then
        return
    end


    local pX, pY, pZ = getElementPosition(localPlayer)
    local mX, mY, mZ = markerX, markerY, markerZ
    local distanceFromMarker = getDistanceBetweenPoints3D(pX, pY, pZ, mX, mY, mZ)
    if distanceFromMarker < 10 then
        local x, y = getScreenFromWorldPosition(markerX, markerY,  markerZ, 0.06)
        if x and y then
			radius, z = interpolateBetween(0.3, 0.5, 0, 0.5, 0.8, 0, getTickCount()/7500, "SineCurve")

			dxDrawOctagon3D(markerX, markerY, markerZ - z, radius, 1, tocolor(240, 195, 120, 255))
			dxDrawOctagon3D(markerX, markerY, markerZ - z - 0.1, radius + 0.1, 1, tocolor(240, 195, 120, 255))
			dxDrawOctagon3D(markerX, markerY, markerZ - z - 0.2, radius + 0.2, 1, tocolor(240, 195, 120, 255))
           	dxDrawText("Járműbolt", x + 1, y - 1 - respc(74) + (z * 100), _, _, tocolor(20, 20, 20), 1, poppinsBoldBig, "center", "center")
           	dxDrawText("Járműbolt", x, y - respc(75) + (z * 100), _, _, tocolor(255, 255, 255), 1, poppinsBoldBig, "center", "center")
        end
    end
end

-- ** MARKER FUNCTIONS -- END

-- ** CARSHOP FUNCTIONS -- START

function onRender()
	if currentVehicle then
		rotation = rotation + 0.075
		setElementRotation(currentVehicle, 0, 0, rotation)
	else
		return
	end
	local nowTick = getTickCount();
	local elapsedTime = nowTick - openTick;
	local duration = elapsedTime / 500
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	sizeX, sizeY = respc(400), respc(100)
	startX = sX / 2 - sizeX / 2
	if paymentInProgress then
		startY = interpolateBetween(sY - sizeY - respc(10), 0, 0, sY - sizeY - respc(45), 0, 0, (nowTick - clickTick) / 500, "InQuad")
	else
		if clickTick then
			startY = interpolateBetween(startY, 0, 0, sY - sizeY - respc(10), 0, 0, (nowTick - clickTick) / 500, "InQuad")
		else
			startY = sY - sizeY - respc(10)
		end
	end

	dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2, a*0.5))

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))

	if isMouseInPosition(startX + sizeX - respc(30), startY + (sizeY - respc(20)) / 2 - respc(20), respc(20), respc(20)) then
		dxDrawImage(startX + sizeX - respc(30), startY + (sizeY - respc(20)) / 2 - respc(20), respc(20), respc(20), "files/img/arrow.png", 0, 0, 0, tocolor(200, 200, 200, a))
	else
		dxDrawImage(startX + sizeX - respc(30), startY + (sizeY - respc(20)) / 2 - respc(20), respc(20), respc(20), "files/img/arrow.png", 0, 0, 0, tocolor(150, 150, 150, a))
	end

	if isMouseInPosition(startX + respc(10), startY + (sizeY - respc(20)) / 2 - respc(20), respc(20), respc(20)) then
		dxDrawImage(startX + respc(10), startY + (sizeY - respc(20)) / 2 - respc(20), respc(20), respc(20), "files/img/arrow.png", 180, 0, 0, tocolor(200, 200, 200, a))
	else
		dxDrawImage(startX + respc(10), startY + (sizeY - respc(20)) / 2 - respc(20), respc(20), respc(20), "files/img/arrow.png", 180, 0, 0, tocolor(150, 150, 150, a))
	end

	local vehicleName, vehicleDollarPrice, vehiclePremiumPrice = vehiclesForSale[currentVehicleIndex][2], vehiclesForSale[currentVehicleIndex][3], vehiclesForSale[currentVehicleIndex][4]
	dxDrawText(vehicleName, startX + sizeX / 2, startY + respc(20), _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "center", "center")
	dxDrawText(vehicleDollarPrice .. " #9BE48F$ #969696| ".. vehiclePremiumPrice .. " #8FC3E4PP", startX + sizeX / 2, startY + respc(40), _, _, tocolor(150, 150, 150, a), 1, poppinsRegular, "center", "center", false, false, false, true)

	buttonW, buttonH = (sizeX - respc(70)) / 2, respc(30)

	dxDrawRectangle(startX + respc(30), startY + sizeY - buttonH - respc(10), buttonW, buttonH, tocolor(65, 65, 65, a))
	if isMouseInPosition(startX + respc(30), startY + sizeY - buttonH - respc(10), buttonW, buttonH) then
		dxDrawRectangle(startX + respc(30) + 1, startY + sizeY - buttonH - respc(10) + 1, buttonW - 2, buttonH - 2, tocolor(65, 65, 65, a))
		dxDrawImage(startX + respc(30) + buttonW / 2 - respc(10), startY + sizeY - buttonH - respc(10) + respc(5), respc(20), respc(20), "files/img/buy.png", 0, 0, 0, tocolor(200, 200, 200, a))
	else
		dxDrawRectangle(startX + respc(30) + 1, startY + sizeY - buttonH - respc(10) + 1, buttonW -2 , buttonH - 2, tocolor(35, 35, 35, a))
		dxDrawText("Vásárlás", startX + respc(30) + buttonW / 2, startY + sizeY - respc(10) - buttonH / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "center", "center")
	end
	
	dxDrawRectangle(startX + respc(30) + buttonW + respc(10), startY + sizeY - buttonH - respc(10), buttonW, buttonH, tocolor(65, 65, 65, a))
	if isMouseInPosition(startX + respc(30) + buttonW + respc(10), startY + sizeY - buttonH - respc(10), buttonW, buttonH) then
		dxDrawRectangle(startX + respc(30) + buttonW + respc(10) + 1, startY + sizeY - buttonH - respc(10) + 1, buttonW - 2, buttonH - 2, tocolor(65, 65, 65, a))
		dxDrawImage(startX + respc(40) + buttonW + buttonW / 2 - respc(10), startY + sizeY - buttonH - respc(10) + respc(5), respc(20), respc(20), "files/img/drive.png", 0, 0, 0, tocolor(200, 200, 200, a))
	else
		dxDrawRectangle(startX + respc(30) + buttonW + respc(10) + 1, startY + sizeY - buttonH - respc(10) + 1, buttonW -2 , buttonH - 2, tocolor(35, 35, 35, a))
		dxDrawText("Tesztvezetés", startX + respc(30) + buttonW + respc(10) + buttonW / 2, startY + sizeY - respc(10) - buttonH / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "center", "center")
	end

	if paymentInProgress then
		local startY = startY + respc(50)
		a2 = interpolateBetween(0, 0, 0, 255, 0, 0, (nowTick - clickTick) / 500, "Linear")
		dxDrawRectangle(startX, startY + sizeY - respc(5), sizeX, respc(35), tocolor(65, 65, 65, a2))
		dxDrawRectangle(startX + 1, startY + sizeY - respc(5) + 1, sizeX - 2, respc(35) - 2, tocolor(35, 35, 35, a2))

		dxDrawRectangle(startX + respc(30), startY + sizeY - buttonH - respc(10), buttonW, buttonH, tocolor(65, 65, 65, a2))
		if isMouseInPosition(startX + respc(30), startY + sizeY - buttonH - respc(10), buttonW, buttonH) then
			dxDrawRectangle(startX + respc(30) + 1, startY + sizeY - buttonH - respc(10) + 1, buttonW - 2, buttonH - 2, tocolor(65, 65, 65, a2))
			dxDrawImage(startX + respc(30) + buttonW / 2 - respc(10), startY + sizeY - buttonH - respc(10) + respc(5), respc(20), respc(20), "files/img/buy.png", 0, 0, 0, tocolor(200, 200, 200, a2))
		else
			dxDrawRectangle(startX + respc(30) + 1, startY + sizeY - buttonH - respc(10) + 1, buttonW -2 , buttonH - 2, tocolor(35, 35, 35, a2))
			dxDrawText(vehiclesForSale[currentVehicleIndex][3] .. " #9BE48F$", startX + respc(30) + buttonW / 2, startY + sizeY - respc(10) - buttonH / 2 + 1, _, _, tocolor(200, 200, 200, a2), 1, poppinsBold, "center", "center", false, false, false, true)
		end
		
		dxDrawRectangle(startX + respc(30) + buttonW + respc(10), startY + sizeY - buttonH - respc(10), buttonW, buttonH, tocolor(65, 65, 65, a))
		if isMouseInPosition(startX + respc(30) + buttonW + respc(10), startY + sizeY - buttonH - respc(10), buttonW, buttonH) then
			dxDrawRectangle(startX + respc(30) + buttonW + respc(10) + 1, startY + sizeY - buttonH - respc(10) + 1, buttonW - 2, buttonH - 2, tocolor(65, 65, 65, a))
			dxDrawImage(startX + respc(40) + buttonW + buttonW / 2 - respc(10), startY + sizeY - buttonH - respc(10) + respc(5), respc(20), respc(20), "files/img/buy.png", 0, 0, 0, tocolor(200, 200, 200, a))
		else
			dxDrawRectangle(startX + respc(30) + buttonW + respc(10) + 1, startY + sizeY - buttonH - respc(10) + 1, buttonW -2 , buttonH - 2, tocolor(35, 35, 35, a))
			dxDrawText(vehiclesForSale[currentVehicleIndex][4] .. " #8FC3E4PP", startX + respc(30) + buttonW + respc(10) + buttonW / 2, startY + sizeY - respc(10) - buttonH / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "center", "center", false, false, false, true)
		end
	end
end

function onClick(button, state)
	if currentVehicle then
		if openTick + 1000 > getTickCount() then
			return
		end
		if button == "left" and state == "down" then
			-- ** NEXT VEH
			if isMouseInPosition(startX + sizeX - respc(30), startY + (sizeY - respc(20)) / 2 - respc(20), respc(20), respc(20)) then
				if currentVehicleIndex + 1 > #vehiclesForSale then
					currentVehicleIndex = 1
					changeTheCurrentVehicle(currentVehicleIndex)
				else
					currentVehicleIndex = currentVehicleIndex + 1
					changeTheCurrentVehicle(currentVehicleIndex)
				end
			end

			-- ** PREV VEH
			if isMouseInPosition(startX + respc(10), startY + (sizeY - respc(20)) / 2 - respc(20), respc(20), respc(20)) then
				if currentVehicleIndex - 1 < 1 then
					currentVehicleIndex = #vehiclesForSale
					changeTheCurrentVehicle(currentVehicleIndex)
				else
					currentVehicleIndex = currentVehicleIndex - 1
					changeTheCurrentVehicle(currentVehicleIndex)
				end
			end

			-- ** VÁSÁRLÁS
			if isMouseInPosition(startX + respc(30), startY + sizeY - buttonH - respc(10), buttonW, buttonH) then
				clickTick = getTickCount()
				paymentInProgress = not paymentInProgress
			end

			if paymentInProgress and (clickTick + 200) < getTickCount() then
				-- ** $
				local startY = startY + respc(50)
				local sizeY = respc(100)
				if isMouseInPosition(startX + respc(30), startY + sizeY - buttonH - respc(10), buttonW, buttonH) then
					local currentPlayerMoney = getElementData(localPlayer, "a.Money")
					if currentPlayerMoney >= vehiclesForSale[currentVehicleIndex][3] then
						triggerServerEvent("buyVehicle", localPlayer, localPlayer, currentVehicleIndex, "$")
					else
						exports.aInfobox:makeNotification(2, "Nincs elég pénzed a művelet végrehajtásához.")
					end
				end

				-- ** PP
				if isMouseInPosition(startX + respc(30) + buttonW + respc(10), startY + sizeY - buttonH - respc(10), buttonW, buttonH) then
					local currentPlayerPP = getElementData(localPlayer, "a.Premiumpont")
					if currentPlayerPP >= vehiclesForSale[currentVehicleIndex][4] then
						triggerServerEvent("buyVehicle", localPlayer, localPlayer, currentVehicleIndex, "pp")
					else
						exports.aInfobox:makeNotification(2, "Nincs elég prémiumpontod a művelet végrehajtásához.")
					end
				end
			end

			-- ** TESZTVEZETÉS
			if isMouseInPosition(startX + respc(30) + buttonW + respc(10), startY + sizeY - buttonH - respc(10), buttonW, buttonH) then
				testDriveStartTick = getTickCount()

				removeEventHandler("onClientRender", root, onRender)
				removeEventHandler("onClientClick", root, onClick)
				removeEventHandler("onClientKey", root, onKey)
				setCameraTarget(localPlayer)
				destroyElement(currentVehicle)
				setElementFrozen(localPlayer, false)

				triggerServerEvent("createTestDrive", localPlayer, localPlayer, vehiclesForSale[currentVehicleIndex][1])
				addEventHandler("onClientRender", root, renderDrivePanel)
				addEventHandler("onClientClick", root, clickDrivePanel)
				changeTick = getTickCount()
			end
		end
	end
end

function onKey(key, state)
	if currentVehicle then
		if state then
			if key == "backspace" then
				removeEventHandler("onClientRender", root, onRender)
				removeEventHandler("onClientClick", root, onClick)
				removeEventHandler("onClientKey", root, onKey)

				setCameraTarget(localPlayer)
				showChat(true)
				setElementData(localPlayer, "a.HUDshowed", true)
				destroyElement(currentVehicle)
				setElementFrozen(localPlayer, false)
			elseif key == "arrow_r" then
				if currentVehicleIndex + 1 > #vehiclesForSale then
					currentVehicleIndex = 1
					changeTheCurrentVehicle(currentVehicleIndex)
				else
					currentVehicleIndex = currentVehicleIndex + 1
					changeTheCurrentVehicle(currentVehicleIndex)
				end
			elseif key == "arrow_l" then
				if currentVehicleIndex - 1 < 1 then
					currentVehicleIndex = #vehiclesForSale
					changeTheCurrentVehicle(currentVehicleIndex)
				else
					currentVehicleIndex = currentVehicleIndex - 1
					changeTheCurrentVehicle(currentVehicleIndex)
				end
			end
		end
	end
end

function changeTheCurrentVehicle(index)
	if index and currentVehicle then
		clickTick = getTickCount()
		paymentInProgress = false
		local modelID = vehiclesForSale[index][1]
		destroyElement(currentVehicle)
		currentVehicle = createVehicle(modelID, vehicleX, vehicleY, vehicleZ)
	end
end

function boughtVehicle(element)
	if element and isElement(element) then
		if element == localPlayer then
			exports.aInfobox:makeNotification(1, "Sikeresen megvásároltad a kiválasztott járművet. (" .. vehiclesForSale[currentVehicleIndex][2] .. ")")
			removeEventHandler("onClientRender", root, onRender)
			removeEventHandler("onClientClick", root, onClick)
			removeEventHandler("onClientKey", root, onKey)

			setCameraTarget(localPlayer)
			showChat(true)
			setElementData(localPlayer, "a.HUDshowed", true)
			destroyElement(currentVehicle)
			setElementFrozen(localPlayer, false)
		end
	end
end
addEvent("boughtVehicle", true)
addEventHandler("boughtVehicle", root, boughtVehicle)

-- ** CARSHOP FUNCTIONS -- END

-- ** TESTDRIVE FUNCTIONS -- START

function renderDrivePanel()
	local nowTick = getTickCount();
	local elapsedTime = nowTick - changeTick;
	local duration = elapsedTime / 2000
	local a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	sizeX, sizeY = respc(400), respc(100)
	startX, startY = sX / 2 - sizeX / 2, sY - sizeY - respc(10)

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))
	--dxDrawText(vehiclesForSale[currentVehicleIndex][2], startX + respc(10), startY + respc(15), _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "left", "center")
	dxDrawText("Vezetési módok", startX + sizeX / 2, startY + respc(15), _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "center", "center")

	bW, bH = (sizeX - respc(25)) / 2, respc(30)

	dxDrawRectangle(startX + respc(10), startY + sizeY - respc(75), bW, bH, tocolor(65, 65, 65, a))
	if isMouseInPosition(startX + respc(10), startY + sizeY - respc(75), bW, bH) then
		dxDrawRectangle(startX + respc(10) + 1, startY + sizeY - respc(75) + 1, bW -2 , bH - 2, tocolor(65, 65, 65, a))
	else
		dxDrawRectangle(startX + respc(10) + 1, startY + sizeY - respc(75) + 1, bW - 2, bH - 2, tocolor(35, 35, 35, a))
	end
	dxDrawText("Normál", startX + respc(10) + bW / 2, startY + sizeY - respc(75) + bH / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsRegular, "center", "center")

	dxDrawRectangle(startX + respc(10) + bW + respc(5), startY + sizeY - respc(75), bW, bH, tocolor(65, 65, 65, a))
	if isMouseInPosition(startX + respc(10) + bW + respc(5), startY + sizeY - respc(76), bW, bH) then
		dxDrawRectangle(startX + respc(10) + bW + respc(5) + 1, startY + sizeY - respc(75) + 1, bW - 2, bH - 2, tocolor(65, 65, 65, a))
	else
		dxDrawRectangle(startX + respc(10) + bW + respc(5) + 1, startY + sizeY - respc(75) + 1, bW - 2, bH - 2, tocolor(35, 35, 35, a))	
	end
	dxDrawText("Drift", startX + respc(10) + bW + respc(5) + bW / 2, startY + sizeY - respc(75) + bH / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsRegular, "center", "center")

	dxDrawRectangle(startX + respc(10), startY + sizeY - respc(40), sizeX - respc(20), bH, tocolor(65, 65, 65, a))
	if isMouseInPosition(startX + respc(10), startY + sizeY - respc(40), sizeX - respc(20), bH) then
		dxDrawRectangle(startX + respc(10) + 1, startY + sizeY - respc(40) + 1, sizeX - respc(20) - 2, bH - 2, tocolor(65, 65, 65, a))	
		dxDrawText("Kilépés a tesztvezetésből", startX + respc(10) + (sizeX - respc(20)) / 2, startY + sizeY - respc(40) + bH / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsBold, "center", "center")
	else
		dxDrawRectangle(startX + respc(10) + 1, startY + sizeY - respc(40) + 1, sizeX - respc(20) - 2, bH - 2, tocolor(35, 35, 35, a))
		dxDrawText("Kilépés a tesztvezetésből", startX + respc(10) + (sizeX - respc(20)) / 2, startY + sizeY - respc(40) + bH / 2 + 1, _, _, tocolor(230/2, 140/2, 140/2, a), 1, poppinsBold, "center", "center")
	end
end

function clickDrivePanel(button, state)
	if button == "left" and state == "down" then
		sizeX, sizeY = respc(400), respc(100)
		startX, startY = sX / 2 - sizeX / 2, sY - sizeY - respc(10)
		bW, bH = (sizeX - respc(25)) / 2, respc(30)
		if isMouseInPosition(startX + respc(10), startY + sizeY - respc(40), sizeX - respc(20), bH) then
			triggerServerEvent("destroyTestVehicle", localPlayer, localPlayer)
		end
	end
end

function testVehicleDeleted(element)
	if element == localPlayer then
		removeEventHandler("onClientRender", root, renderDrivePanel)
		openTick = getTickCount()
		addEventHandler("onClientRender", root, onRender)
		addEventHandler("onClientClick", root, onClick)
		addEventHandler("onClientKey", root, onKey)

		setElementFrozen(localPlayer, true)
		setCameraMatrix(vehicleX - 8, vehicleY, vehicleZ + 2, vehicleX, vehicleY, vehicleZ)

		
		rotation = math.random(0, 360)
		currentVehicle = createVehicle(vehiclesForSale[currentVehicleIndex][1], vehicleX, vehicleY, vehicleZ)
		removeEventHandler("onClientClick", root, clickDrivePanel)
	end
end
addEvent("testVehicleDeleted", true)
addEventHandler("testVehicleDeleted", root, testVehicleDeleted)

-- ** TESTDRIVE FUNCTIONS -- END

function dxDrawOctagon3D(x, y, z, radius, width, color)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
		return false
	end

	local radius = radius or 1
	local radius2 = radius/math.sqrt(2)
	local width = width or 1
	local color = color or tocolor(255,255,255,150)

	point = {}

		for i=1,8 do
			point[i] = {}
		end

		point[1].x = x
		point[1].y = y-radius
		point[2].x = x+radius2
		point[2].y = y-radius2
		point[3].x = x+radius
		point[3].y = y
		point[4].x = x+radius2
		point[4].y = y+radius2
		point[5].x = x
		point[5].y = y+radius
		point[6].x = x-radius2
		point[6].y = y+radius2
		point[7].x = x-radius
		point[7].y = y
		point[8].x = x-radius2
		point[8].y = y-radius2
		
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2, color, width)
	end
	return true
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