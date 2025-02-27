function onStart()
	sX, sY = guiGetScreenSize()
	sizeX, sizeY = 350, 220
	startX, startY = 10, sY - sizeY - 10
	
	-- ** RENDERTARGETS
	minimapTarget = dxCreateRenderTarget(sizeX, sizeY, true)
	f11Target = dxCreateRenderTarget(sX / 1.1, sY / 1.1, true)
	
	-- ** FONTS
	robotoBold = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 14, false, "cleartype")
	
	-- ** VARIABLES
	renderF11 = false
	renderMinimap = true
	zoomState = 1
	blipSize = 16
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onRender()
	if not (getElementData(localPlayer, "loggedIn")) then
		return
	end
	if renderMinimap then
		if not getElementData(localPlayer, "a.HUDshowed") then
			return
		end
		local camX, camY, camZ = getElementRotation(getCamera())
		local playerX, playerY, playerZ = getElementPosition(localPlayer);
		local sizeX, sizeY = dxGetMaterialSize(minimapTarget)
		local x, y = sizeX / 2 - (playerX / (6000 / 1600)), sizeY / 2 + (playerY / (6000 / 1600))
		local rx, ry, rz = getElementRotation(localPlayer)

		dxDrawRectangle(startX - 2, startY - 2 - 30, sizeX + 4, sizeY + 4 + 30, tocolor(65, 65, 65, 255))
		dxDrawRectangle(startX - 1, startY - 1 - 30, sizeX + 2, sizeY + 2 + 30, tocolor(35, 35, 35, 255))
		dxDrawImage(startX + 5, startY + sizeY - 22.5, 15, 15, "files/img/location.png", 0, 0, 0, tocolor(200, 200, 200, 255))
		dxDrawText(getZoneName(Vector3(getElementPosition(localPlayer))), startX + 30, startY + sizeY - 15, _, _, tocolor(200, 200, 200, 255), 1, robotoBold, "left", "center")

		dxSetRenderTarget(minimapTarget, true)
		dxSetBlendMode("modulate_add")
			dxDrawRectangle(0, 0, sizeX, sizeY, tocolor(110, 158, 206))
			dxDrawImage(x - 800, y - 800, 1600, 1600, "files/img/map.png", 0, (playerX / (6000 / 1600)), -(playerY / (6000 / 1600)), tocolor(255, 255, 255, 255))
			dxDrawImage(0, 0, sizeX, sizeY, "files/img/vignette.png", 0, 0, 0, tocolor(200, 200, 200, 255))

			for k, v in ipairs(getElementsByType("blip")) do
				local x2, y2 = getElementPosition(v)
				local sizeX, sizeY = dxGetMaterialSize(minimapTarget)

				local blipX = 0 + sizeX / 2 + (remapTheFirstWay(playerX) - remapTheFirstWay(x2))
				local blipY = 0 + sizeY / 2 - (remapTheFirstWay(playerY) - remapTheFirstWay(y2))

				dxDrawImage(blipX - 8, blipY - 8, 16, 16, "files/img/blips/1.png", 0, (playerX / (6000 / 16)), -(playerY / (6000 / 16)), tocolor(255, 255, 255, 255))
			end
			
		dxSetBlendMode("blend")
		dxSetRenderTarget()

		dxDrawImage(startX + sizeX / 2 - 8, startY + sizeY / 2 - 8 - 30, 16, 16, "files/img/arrow.png", -getPedRotation(localPlayer), 0, 0, tocolor(200, 200, 200, 255), true)

		dxDrawImage(startX, startY - 30, sizeX, sizeY, minimapTarget)
	end

	if renderF11 then
		local sizeX, sizeY = sX / 1.1, sY / 1.1
		local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2

		local nowTick = getTickCount()
		local elapsedTime = nowTick - openTick;
		local duration = elapsedTime / 50;
		a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

		-- ** BORDER
		--dxDrawRectangle(startX - 2, startY - 2, sizeX + 4, sizeY + 4, tocolor(65, 65, 65, a))
		--dxDrawRectangle(startX - 1, startY - 1, sizeX + 2, sizeY + 2, tocolor(35, 35, 35, a))

		local camX, camY, camZ = getElementRotation(getCamera())
		local playerX, playerY, playerZ = getElementPosition(localPlayer);
		local x, y = sizeX / 2 - (playerX / (6000 / (1600 * zoomState))), sizeY / 2 + (playerY / (6000 / (1600 * zoomState)))
		local rx, ry, rz = getElementRotation(localPlayer)

		-- ** RENDERTARGET
		dxSetRenderTarget(f11Target, true)
			dxDrawRectangle(0, 0, sizeX, sizeY, tocolor(110, 158, 206, a))
			dxDrawImage(x - (1600 * zoomState)/2, y - (1600 * zoomState)/2, 1600 * zoomState, 1600 * zoomState, "files/img/map.png", 0, (playerX / (6000 / 1600 * zoomState)), -(playerY / (6000 / 1600 * zoomState)), tocolor(255, 255, 255, a))
			dxDrawImage(0, 0, sizeX, sizeY, "files/img/vignette.png", 0, 0, 0, tocolor(200, 200, 200, a))

			for k, v in ipairs(getElementsByType("blip")) do
				local x,y = getElementPosition(v)

				local blipX = 0 + sizeX / 2 + (remapTheFirstWay(playerX) - remapTheFirstWay(x)) * zoomState
				local blipY = 0 + sizeY / 2 - (remapTheFirstWay(playerY) - remapTheFirstWay(y)) * zoomState
				
				local blipName = getElementData(v, "a.BlipName")
				if not blipName then
					blipName = "Ismeretlen"
				end

				if blipX > sizeX then
					blipX = sizeX
				elseif blipX < 0 then
					blipX = 0
				end
		
				if blipY > sizeY then
					blipY = sizeY
				elseif blipY < 0 then
					blipY = 0
				end

				local textWidth = dxGetTextWidth(blipName, 1, robotoBold)

				dxDrawRectangle(blipX - textWidth / 2 - 5, blipY - 30, textWidth + 10, 20, tocolor(35, 35, 35, a))
				dxDrawRectangle(blipX - 2.5, blipY, 5, -10, tocolor(35, 35, 35, a))
				dxDrawImage(blipX - 8, blipY - 8, 16, 16, "files/img/blips/1.png", 0, 0, 0, tocolor(255, 255, 255, a))
				dxDrawText(blipName, blipX, blipY - 16, _, _, tocolor(255, 255, 255, a), 1, robotoBold, "center", "center", false, false, false, true)
			end
		dxSetRenderTarget()

		-- ** FOOTER
		dxDrawRectangle(startX, startY + sizeY - 30, sizeX, 30, tocolor(25, 25, 25, a), true)
		dxDrawImage(startX + 5, startY + sizeY - 23, 15, 15, "files/img/location.png", 0, 0, 0, tocolor(200, 200, 200, a), true)
		dxDrawText(getZoneName(Vector3(getElementPosition(localPlayer))), startX + 30, startY + sizeY - 15, _, _, tocolor(200, 200, 200, a), 1, robotoBold, "left", "center", false, false, true)

		-- ** PLAYER ARROW
		dxDrawImage(startX + sizeX / 2 - 8, startY + sizeY / 2 - 8, 16, 16, "files/img/arrow.png", -getPedRotation(localPlayer), 0, 0, tocolor(200, 200, 200, a), true)

		-- **DRAW RENDERTARGET
		dxDrawImage(startX, startY, sizeX, sizeY, f11Target)
	end
end
addEventHandler("onClientRender", root, onRender)

--[[function start()
	blip = createBlip(Vector3(getElementPosition(localPlayer)), 1)
	setElementData(blip, "a.BlipName", getPlayerName(localPlayer))
	attachElements(blip, localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, start)]]--

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

local mapScaleFactor = 6000 / 1600

function remapTheFirstWay(x)
	return (-x + 3000) / mapScaleFactor
end

function remapTheSecondWay(x)
	return (x + 3000) / mapScaleFactor
end

function onKey(key, state)
	if key == "F11" and state then
		--[[if not (getElementData(localPlayer, "loggedIn")) or getElementData(localPlayer, "a.Gamemode") == nil then
			cancelEvent()
			return
		end]]--
		if renderF11 then
			renderF11 = false
			renderMinimap = true
			showChat(true)
			triggerServerEvent("changeDataSync", localPlayer, "a.HUDshowed", true)
		else
			openTick = getTickCount()
			renderF11 = true
			zooming = false
			renderMinimap = false
			showChat(false)
			triggerServerEvent("changeDataSync", localPlayer, "a.HUDshowed", false)
		end
		cancelEvent()
	elseif key == "mouse_wheel_down" and state and renderF11 then
		if zoomState - 0.05 < 0.5 then
			zoomState = 0.5
		else
			zoomState = zoomState - 0.05
		end
	elseif key == "mouse_wheel_up" and state and renderF11 then
		if zoomState + 0.05 > 1.5 then
			zoomState = 1.5
		else
			zoomState = zoomState + 0.05
		end
	end
end
addEventHandler("onClientKey", root, onKey)

function getMapFromWorldPosition(worldX, worldY)
	local playerX, playerY = getElementPosition(localPlayer)
	local centerX, centerY = (startX + (sizeX / 2)), (startY + (sizeY / 2));
	local mapLeftFrame = centerX - ((playerX - worldX) / zoomState);
	local mapRightFrame = centerX + ((worldX - playerX) / zoomState);
	local mapTopFrame = centerY - ((worldY - playerY) / zoomState);
	local mapBottomFrame = centerY + ((playerY - worldY) / zoomState);

	centerX = math.max(mapLeftFrame, math.min(mapRightFrame, centerX));
	centerY = math.max(mapTopFrame, math.min(mapBottomFrame, centerY));
	
	return centerX, centerY;
end
function findRotation(x1,y1,x2,y2)
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end;
	return t;
  end
  
  function dxCreateBorder(x,y,w,h,color)
	  dxDrawRectangle(x-2,y-2,w+4,2,color) -- Fent
	  dxDrawRectangle(x-2,y,2,h,color) -- Bal Oldal
	  dxDrawRectangle(x-2,y+h,w+4,2,color) -- Lent Oldal
	  dxDrawRectangle(x+w,y-2,2,h+2,color) -- Jobb Oldal
  end
  
  function getPointFromDistanceRotation(x, y, dist, angle)
	  local a = math.rad(90 - angle);
	  local dx = math.cos(a) * dist;
	  local dy = math.sin(a) * dist;
	  return x+dx, y+dy;
  end