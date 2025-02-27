--[[local sX, sY = guiGetScreenSize()
local panelSize = {400, 100}
local respx, respy = 1920*sX, 1080*sY
local font = dxCreateFont("files/Roboto-Condensed.otf", 14)
local font2 = dxCreateFont("files/Roboto-Condensed.otf", 12)
local startX, startY = sX - panelSize[1], 7 + panelSize[2]/2
local HUDrendered = true
local changeTick = getTickCount()
setElementData(localPlayer, "a.HUDshowed", true)

function renderHUD()
    if not HUDrendered then return end
    if getElementData(localPlayer, "loggedIn") == false then return end
    if not getElementData(localPlayer, "a.HUDshowed") then return end
    local hp = getElementHealth(getLocalPlayer())
    local armor = getPedArmor(getLocalPlayer())
    local xp = getElementData(getLocalPlayer(), "a.Experience") or 0
    local level = getElementData(getLocalPlayer(), "a.Level") or 1
    local money = getElementData(getLocalPlayer(), "a.Money") or 0
    local time = getRealTime();
    
    local nowTick = getTickCount()
    local elapsedTime = nowTick - changeTick
    local duration = elapsedTime / 1000

    hp = interpolateBetween(0, 0, 0, hp, 0, 0, duration, "InQuad")
    armor = interpolateBetween(0, 0, 0, armor, 0, 0, duration, "InQuad")
    xp = interpolateBetween(0, 0, 0, xp, 0, 0, duration, "InQuad")
    leveltxt = interpolateBetween(0, 0, 0, tonumber(level), 0, 0, duration, "InQuad")
    money = interpolateBetween(0, 0, 0, tonumber(money), 0, 0, duration, "InQuad")

    if time.minute < 10 then 
       time.minute = "0"..time.minute
    end 
    
    if time.hour < 10 then 
       time.hour = "0"..time.hour
    end
    
    --[[ LEVEL RESZ
    roundedRectangle(startX - 10, startY + panelSize[2]/2 - 10, panelSize[1]/2 - 5, panelSize[2]-60, tocolor(65, 65, 65, 255))
    roundedRectangle(startX - 8, startY + panelSize[2]/2 - 8, panelSize[1]/2 - 9, panelSize[2]-64, tocolor(30, 30, 30, 255))


    dxDrawCircle(startX + 10, startY + panelSize[2]/2 + 10, 15, 0, 360, tocolor(20, 20, 20, 150), tocolor(45, 45, 45, 150), 1000)
    dxDrawCircle(startX + 10, startY + panelSize[2]/2 + 10, 15, 0, 360/(level*100)*xp, tocolor(150, 150, 50, 200), tocolor(200, 200, 100, 255), 1000)
    dxDrawImage(startX + 2, startY + panelSize[2]/2, 18, 18, "files/icons/xp.png", 0, 0, 0, tocolor(200, 200, 100, 255))

    dxDrawText("#969632" .. math.floor(xp) .. " #C8C8C8XP #9BE48F(LVL " .. math.floor(leveltxt) .."#9BE48F)", startX + 105, startY + panelSize[2]/2 + 10, _, _, tocolor(200, 200, 200), 1, font2, "center", "center", false, false, false, true)

    roundedRectangle(startX - 10, startY - panelSize[2]/2 + 5, panelSize[1], panelSize[2]-25, tocolor(65, 65, 65, 255))
    roundedRectangle(startX - 8, startY - panelSize[2]/2 + 7, panelSize[1]-4, panelSize[2]-29, tocolor(30, 30, 30, 255))
    dxDrawImage(startX + panelSize[1] - 35, startY - panelSize[2]/2 + 7, 20, 20, "files/icons/logo.png", 0, 0, 0, tocolor(200, 200, 200, 200))

    --[[ WEAPON RESZ
    local gunID = getPedWeapon(localPlayer)
	local ammo = getPedAmmoInClip (localPlayer)
	local totalAmmo = getPedTotalAmmo (localPlayer)
    roundedRectangle(startX - 10 + panelSize[1]/2 + 10, startY + panelSize[2]/2 - 10, panelSize[1]/2 - 10, panelSize[2]-60, tocolor(65, 65, 65, 255))
    roundedRectangle(startX - 10 + panelSize[1]/2 + 12, startY + panelSize[2]/2 - 8, panelSize[1]/2 - 14, panelSize[2]-64, tocolor(30, 30, 30, 255))

    dxDrawImage(startX - 10 + panelSize[1]/2 + 95, startY + panelSize[2]/2 - 12.5, 100, 40, "files/weapons/" .. gunID .. ".png")
    if gunID >= 1 then
        dxDrawText(ammo .. " / " .. totalAmmo, startX - 10 + panelSize[1]/2 + 65, startY + panelSize[2]/2 + 10, _, _, tocolor(200, 200, 200), 1, font, "center", "center")
    end


    -- HP
    dxDrawCircle(startX + 40, startY - 10, 30, 0, 360, tocolor(20, 20, 20, 150))
    dxDrawCircle(startX + 40, startY - 10, 30, 0, 360/100*hp, tocolor(200, 100, 100, 150), tocolor(200, 100, 100, 255), 1000)
    dxDrawCircle(startX + 40, startY - 10, 25, 0, 360, tocolor(30, 30, 30, 255))

    if isCursorOnBox(startX + 25, startY - 25, 30, 30) then
        dxDrawText(math.floor(hp), startX + 40, startY - 12, _, _, tocolor(255, 255, 255), 1, font, "center", "center")
    else
        dxDrawImage(startX + 28, startY - 22, 24, 24, "files/icons/health.png", 0, 0, 0, tocolor(255, 150, 150, 255))
    end

    -- ARMOR
    dxDrawCircle(startX + 120, startY - 10, 30, 0, 360, tocolor(20, 20, 20, 150))
    dxDrawCircle(startX + 120, startY - 10, 30, 0, 360/100*armor, tocolor(100, 100, 200, 150), tocolor(100, 100, 200, 255), 1000)    

    
    if isCursorOnBox(startX + 105, startY - 25, 30, 30) then
        dxDrawText(math.floor(armor), startX + 120, startY - 12, _, _, tocolor(255, 255, 255), 1, font, "center", "center")
    else
        dxDrawImage(startX + 108, startY - 22, 24, 24, "files/icons/shield.png", 0, 0, 0, tocolor(150, 150, 255, 255))
    end

    local ping = getPlayerPing(localPlayer)
    if ping < 20 then
        pingHex = "#9BE48F"
    elseif ping < 100 and ping > 20 then
        pingHex = "#E4C78F"
    elseif ping < 150 and ping > 100 then
        pingHex = "#E48F8F"
    else
        pingHex = "#9BE48F"
    end

    roundedRectangle(startX + 185, startY - 43, 70, 30, tocolor(20, 20, 20))
    dxDrawText(pingHex .. getPlayerPing(localPlayer) .. "#C8C8C8 ms",startX + 220, startY - 27.5, _, _, tocolor(200, 200, 200, 200), 1, font, "center", "center", false, false, false, true)  

    roundedRectangle(startX + 185, startY - 5, 70, 30, tocolor(20, 20, 20))
    dxDrawText(time.hour .. ":" .. time.minute,startX + 220, startY + 10, _, _, tocolor(200, 200, 200, 200), 1, font, "center", "center", false, false, false, true) 

    local fps = getCurrentFPS()
    if fps < 20 then
        fpsHex = "#E48F8F"
    elseif fps > 20 and fps < 50 then
        fpsHex = "#E4C78F"
    elseif fps > 50 and fps < 61 then
        fpsHex = "#9BE48F"
    else
        fpsHex = "#9BE48F"
    end

    roundedRectangle(startX + 285, startY - 43, 70, 30, tocolor(20, 20, 20))
    dxDrawText(fpsHex .. math.floor(getCurrentFPS()) .. " #C8C8C8FPS",startX + 320, startY - 27.5, _, _, tocolor(200, 200, 200, 200), 1, font, "center", "center", false, false, false, true) 

    roundedRectangle(startX + 285, startY - 5, 100, 30, tocolor(20, 20, 20))  
    dxDrawText("#E4C78F" .. math.floor(money) .. " #C8C8C8$",startX + 335, startY + 10, _, _, tocolor(200, 200, 200, 200), 1, font, "center", "center", false, false, false, true)   
end
--addEventHandler("onClientRender", root, renderHUD)
setTimer(renderHUD, 5, 0)

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

local fps = 0
local nextTick = 0
function getCurrentFPS() 
    return fps
end

local function updateFPS(msSinceLastFrame)
    local now = getTickCount()
    if (now >= nextTick) then
        fps = (1 / msSinceLastFrame) * 1000
        nextTick = now + 1000
    end
end
addEventHandler("onClientPreRender", root, updateFPS)

function isInBox(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

function isCursorOnBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end	
end

function onChange(key, oValue, nValue)
    if key == "loggedIn" and nValue == true then
        if source == localPlayer then
            changeTick = getTickCount()
        end
    end
end
addEventHandler("onClientElementDataChange", root, onChange)]]--

function showHUD()
    if getElementData(localPlayer, "a.HUDshowed") == true then
        setElementData(localPlayer, "a.HUDshowed", false)
    else
        setElementData(localPlayer, "a.HUDshowed", true)
    end
end
--addCommandHandler("toghud", showHUD)