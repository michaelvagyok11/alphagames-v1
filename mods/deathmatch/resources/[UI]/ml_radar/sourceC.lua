--Script by LENNON (112, 152, 207) #7098CF
local sX, sY = guiGetScreenSize()
local width, height = 0,0
local posX,posY = 5, sY-height-15
local waterColor = tocolor(129, 166, 208, 200)
local bSize = 30

local showBigMap = false
local minimapTarget = dxCreateRenderTarget(300,400,true)
local arrowTexture = dxCreateTexture("files/arrow.png","dxt3",true)

local font = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", 12, false, "cleartype")

local texture = dxCreateTexture( "files/radar.png", "dxt5", true, "clamp")
dxSetTextureEdge(texture, 'border', waterColor)
local imageWidth, imageHeight = dxGetMaterialSize(texture)
local blipTextures = {}
local playerBlips = {}

local mapRatio = 6000 / imageWidth

local framesPerSecond = 0
local framesDeltaTime = 0
local lastRenderTick = false
local fpsCount = 60
local stat = dxGetStatus()
local bit = stat["setting32BitColor"] and 32 or 16

local playerX,playerY,playerZ = getElementPosition(localPlayer)
local mapUnit = imageWidth / 6000
local currentZoom = 1
local minZoom, maxZoom = 1, 5

local mapOffsetX, mapOffsetY = 0,0
local mapMoved = false
local changeTick = 0

addEventHandler("onClientResourceStart",getRootElement(),function(res)
	for i=0,64 do 
		if fileExists("blips/"..i..".png") then 
			blipTextures[i] = dxCreateTexture("blips/"..i..".png","dxt3",true)
		end
	end
end)

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle)
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist
    return x+dx, y+dy
end

function findRotation(x1,y1,x2,y2)
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end
	return t
end

function getMapFromWorldPosition(worldX, worldY)
	local centerX, centerY = (posX + (width / 2)), (posY + (height / 2))
	local mapLeftFrame = centerX - ((playerX - worldX) / currentZoom * mapUnit)
	local mapRightFrame = centerX + ((worldX - playerX) / currentZoom * mapUnit)
	local mapTopFrame = centerY - ((worldY - playerY) / currentZoom * mapUnit)
	local mapBottomFrame = centerY + ((playerY - worldY) / currentZoom * mapUnit)

	centerX = math.max(mapLeftFrame, math.min(mapRightFrame, centerX))
	centerY = math.max(mapTopFrame, math.min(mapBottomFrame, centerY))

	return centerX, centerY
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function getWorldFromMapPosition(mapX, mapY)
	return playerX + ((mapX * ((width * currentZoom) * 2)) - (width * currentZoom)), playerY + ((mapY * ((height * currentZoom) * 2)) - (height * currentZoom)) * -1
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

addEventHandler("onClientPreRender",root,function()		
	if not (getElementData(localPlayer, "loggedIn")) or not (getElementData(localPlayer,"loggedIn")) then
		return
	end

	--if exports.ml_interface:isWidgetShowing("radar") then
		if showBigMap then return end
		if getElementDimension(localPlayer) == 0 then
			width, height = 400, 250 
			posX,posY = 5, sY - height - 5
			local px,py, pz = getElementPosition(localPlayer)
			local _, _, camZ = getElementRotation(getCamera())	
			local mW, mH = dxGetMaterialSize(minimapTarget)
			if mW ~= width or mH ~= height then 
				destroyElement(minimapTarget)
				minimapTarget = dxCreateRenderTarget(width, height,false)
			end

			dxSetRenderTarget(minimapTarget, true)
			local mW, mH = dxGetMaterialSize(minimapTarget)
			local ex,ey = mW/2 -px/(6000/imageWidth), mH/2 + py/(6000/imageHeight)
			dxDrawRectangle(0,0,mW,mH, waterColor)
			dxDrawImage(ex - imageWidth/2, (ey - imageHeight/2), imageWidth, imageHeight, texture, camZ, (px/(6000/imageWidth)), -(py/(6000/imageHeight)), tocolor(255, 255, 255, 200))
			dxSetRenderTarget()

			dxDrawRoundedRectangle(posX, posY, width-1, height, 3, tocolor(35,35,35,200))
			dxDrawImage(posX+4.2,posY+3,width-8.4,height-6,minimapTarget,0,0,0,tocolor(255,255,255,200))
			dxDrawRoundedRectangle(posX, posY + height - 30, width-1, 30, 3, tocolor(35,35,35,200))

			--dxDrawImage(posX + 5, posY+400 - 425 + 5, 16, 16, "files/gps.png", 0, 0, 0, tocolor(75,75,75,255))
	        local zoneName = getZoneName(px, py, pz)
	        local koorX, koorY, koorZ = getElementPosition(localPlayer)
	        dxDrawText("XYZ: #737373"..math.round(koorX)..", "..math.round(koorY)..", "..math.round(koorZ).."", posX + width - 5, posY + height - 15, _, _, tocolor(255, 255, 255, 255), 1, font, "right", "center")
		
		    for k, v in ipairs(getElementsByType("blip")) do
				local bx, by = getElementPosition(v)
				local actualDist = getDistanceBetweenPoints2D(px,py, bx, by)
				local bIcon = getBlipIcon(v)
				local bSize = getElementData(v,"blip > size") or 22
				if actualDist <= 200 or (getElementData(v, "blip > maxVisible")) then
					local dist = actualDist/(6000/((imageWidth+imageHeight)/2))
					local rot = findRotation(bx, by, px, py)-camZ
					local blipX, blipY = getPointFromDistanceRotation( (posX+width+posX)/2, (posY+posY+height)/2, math.min(dist, math.sqrt((posY+posY+height)/2-posY^2 + posX+width-(posX+width+posX)/2^2)), rot )
						
					local blipX = math.max(posX+17, math.min(posX+width-15, blipX))
					local blipY = math.max(posY+15, math.min(posY+height, blipY))

					local r,g,b = unpack(getElementData(v,"blip > color") or {255,255,255})
					dxDrawImage(blipX - bSize/2, blipY - bSize/2, bSize, bSize, blipTextures[bIcon] or "blips/0.png", 0, 0, 0, tocolor(r,g,b),true)
				end
			end
	        dxDrawImage(posX + width/2 - 17/2, posY + height/2 -17/2, 16, 16, arrowTexture, camZ-getPedRotation(localPlayer), 0, 0, tocolor(255,255,255, 255), true)
		else
    		dxDrawRectangle(posX, posY, width-1, height, tocolor(20,20,20,255))
    		centerText("A kapcsolat megszakadt...", posX, posY, width-1, height, tocolor(100,100,100,255), 1, font)
        end
    --end
end)

function centerText(text, x, y, w, h, color, fontS, font)
    dxDrawText(text, x+w/2, y+h/2, x+w/2, y+h/2, color, fontS, font, "center", "center", false, false, false, true)
end 


function drawBigMap()
	if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return end
	--local width, height = 500,500
	--local posX, posY = sX/2 - width/2, sY/2 - height/2
	posX, posY, width, height = 25, 25, sX - 50, sY - 50

	if(isCursorShowing()) and mapMoved then
		local cursorX, cursorY = getCursorPosition()
		local mapX, mapY = getWorldFromMapPosition(cursorX, cursorY)

		local absoluteX = cursorX * sX
		local absoluteY = cursorY * sY

		if getKeyState("mouse1") and exports.ml_core:isInSlot(posX, posY, width, height) then
			playerX = -(absoluteX * currentZoom - mapOffsetX)
			playerY = absoluteY * currentZoom - mapOffsetY
	
			playerX = math.max(-3000, math.min(3000, playerX))
			playerY = math.max(-3000, math.min(3000, playerY))
		end
	else 
		if (not mapMoved) then
			playerX, playerY, playerZ = getElementPosition(localPlayer)
		end
	end
	local _, _, playerRotation = getElementRotation(localPlayer);
	local mapX = (((3000 + playerX) * mapUnit) - (width / 2) * currentZoom)
	local mapY = (((3000 - playerY) * mapUnit) - (height / 2) * currentZoom)
	local mapWidth, mapHeight = width * currentZoom, height * currentZoom
	local localX, localY, localZ = getElementPosition(localPlayer)
	local koorX, koorY, koorZ = getElementPosition(localPlayer)

	dxDrawRectangle(posX - 5, posY - 5, width + 10, height + 10,tocolor(35,35,35,255))
	dxDrawImageSection(posY, posX, width, height, mapX, mapY, mapWidth, mapHeight, texture, 0, 0, 0, tocolor(255, 255, 255, 255), false)
   -- dxDrawImage(sX/2 - 140/2, sY/2 - 140/2 - 350, 140, 140, "files/small_logo.png", 0, 0, 0, tocolor(255,255,255,50))
	

	for _, blip in pairs(getElementsByType("blip")) do
		local blipX, blipY, blipZ = getElementPosition(blip)
		local icon = getBlipIcon(blip)
		local size = (getElementData(blip,"blip > size") or 25)
		local color = getElementData(blip,"blip > color") or {255,255,255}

		local blipDistance = getDistanceBetweenPoints2D(blipX, blipY, playerX, playerY)
		if (blipDistance <= (1000*(currentZoom*3))) then 
			local centerX, centerY = (posX + (width / 2)), (posY + (height / 2))
			local leftFrame = (centerX - width / 2) + (30/2)
			local rightFrame = (centerX + width / 2) - (30/2)
			local topFrame = (centerY - height / 2) + (30/2)
			local bottomFrame = (centerY + height / 2) - 40
			local blipX, blipY = getMapFromWorldPosition(blipX, blipY)
			centerX = math.max(leftFrame, math.min(rightFrame, blipX))
			centerY = math.max(topFrame, math.min(bottomFrame, blipY))

			dxDrawImage(centerX - (size / 2), centerY - (size / 2), size, size, blipTextures[icon], 0, 0, 0, tocolor(color[1], color[2], color[3], a))

			if exports.ml_core:isInSlot(centerX - (size / 2), centerY - (size / 2), size, size) then 
				local blipName = getElementData(blip, "blip > name") or blipNames[icon] or "Ismeretlen"
				local textWidth = dxGetTextWidth("Blip: "..blipName,1,font,true)
				local cursorX, cursorY = getCursorPosition()
				cursorX, cursorY = cursorX*sX + 10, cursorY*sY + 10
				dxDrawRectangle(cursorX,cursorY,textWidth + 10, 40,tocolor(65,65,65,255));
				dxDrawText("Blip: #ffffff"..blipName.."\n"..math.floor(blipDistance).."m",cursorX,cursorY + 20,cursorX + textWidth + 10,cursorY+20,tocolor(112, 152, 207),1,font,"center","center",false,false,false,true)
			end
		end
	end
	local blipX, blipY = getMapFromWorldPosition(localX, localY);
	if (blipX >= posX and blipX <= posX + width) then
		if (blipY >= posY and blipY <= posY + height) then
			dxDrawImage(blipX - 7, blipY - 7, 15, 15, arrowTexture, 360 - playerRotation, 0, 0, tocolor(255, 255, 255, a), false)
		end
	end
end

addEventHandler("onClientKey",root,function(button,state)
	if button == "F11" and state then 
		cancelEvent()
		if not showBigMap then 
			removeEventHandler("onClientRender",root,drawBigMap)
			addEventHandler("onClientRender",root,drawBigMap)
			showBigMap = true
			mapMoved = false
			setElementData(localPlayer,"char > toghud",false)
			showChat(false)
		else 
			removeEventHandler("onClientRender",root,drawBigMap)
			showBigMap = false
			setElementData(localPlayer,"char > toghud",true)
			showChat(true)
		end
	end
	if showBigMap then 
		if button == "space" and state then 
			mapMoved = false
		end

		if button == "mouse_wheel_up" and state then 
			currentZoom = math.max(currentZoom - 0.05, minZoom)
		end

		if button == "mouse_wheel_down" and state then 
			currentZoom = math.min(currentZoom + 0.05, maxZoom)
		end
	end
end)

addEventHandler("onClientClick",root,function(button,state,x,y)
	if showBigMap then 
		if button == "left" then 
			if state == "down" then 
				if exports.ml_core:isInSlot(posX,posY,width,height-30) then 
					mapOffsetX = x * currentZoom + playerX
					mapOffsetY = y * currentZoom - playerY
					mapMoved = true
				end
			end
		end
	end
end)

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY,a,b,c,d,rot)
	if not a then a = false end;
	if not b then b = false end;
	if not c then c = false end;
    if not d then d = true end;
    if not rot then rot = 0 end;
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, a,b,c,d,false,rot) 
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, a,b,c,d,false,rot)
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, a,b,c,d,false,rot) 
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, a,b,c,d,false,rot) 
    dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, a,b,c,d,false,rot)
end

blipNames = { --Tipus szám, név
	[5] = "Városháza",
	[6] = "Rendőrség",
	[23] = "Szerelőtelep",
	[4] = "Határ",
	[7] = "Benzinkút",
	[19] = "Gumi javító műhely",
	[11] = "Jármű bolt",
	[9] = "Festőműhely",

 }	

addEventHandler("onClientResourceStart", getResourceRootElement(), function()

	--Pozició X Y Z, Tipus szám
	createBlip(2359.9375, 2378.2182617188, 10.8203125,5) --Városháza
	createBlip(2237.1084, 2453.4351, 10.6832,6) -- Rendőrség
	createBlip(1067.9875, 1367.251, 10.8242,23) --Szerelő telep

	--carshop
	createBlip(1941.1427, 2068.3179, 10.8203, 11)

	--Határok
	createBlip(-564.1422, 622.6813, 16.8171, 4)
	createBlip(-477.2693, 1053.6278, 11.0312, 4)
	createBlip(-1031.2638, 2708.1194, 45.8672, 4)
	createBlip(-708.3982, 2062.8582, 60.3828, 4)

	--Benzinkutak
	createBlip(2137.6025, 2748.5471, 10.8203,7)
	createBlip(2118.4297, 935.274, 10.8203, 7)

	--hankook
	createBlip(1648.262, 2189.3579, 10.8203, 19)

	--festő
	createBlip(1954.8484, 2162.396, 10.8203, 9)

end)