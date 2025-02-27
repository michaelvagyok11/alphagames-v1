local sX, sY = guiGetScreenSize();

local components = {
    {"hud", sX - 400 - 10, 20, 400, 70},
}

local robotoThin = dxCreateFont("files/fonts/Roboto-Condensed.ttf", 12, false, "antialiased")
local robotoThinSmall = dxCreateFont("files/fonts/Roboto-Condensed.ttf", 11, false, "cleartype")
local robotoBold = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 12, false, "cleartype")
local heartTexture, armorTexture = dxCreateTexture("files/img/heart.png", "argb", false), dxCreateTexture("files/img/armor.png")
local a = 0
local weaponShowed = false
local weaponTick = getTickCount()

function renderComponents()
    for i, v in ipairs(components) do
        componentName = v[1]
        startX, startY, sizeX, sizeY = v[2], v[3], v[4], v[5]
        if componentName == "hud" then
            dxDrawRoundedRectangle(startX + 10, startY, sizeX - 5, sizeY, tocolor(65, 65, 65, 240), tocolor(35, 35, 35, 240))

            local barX, barY = 175, 25;

            local playerHealth = getElementHealth(localPlayer);

            dxDrawRoundedRectangle(startX + 20, startY + 8, barX, barY, tocolor(25, 25, 25, 240), tocolor(25, 25, 25, 240), true)
            dxDrawRoundedRectangle(startX + 20 + 1, startY + 8 + 1, (barX - 2)*(playerHealth/100), barY - 2, tocolor(120, 75, 75, 240), tocolor(120, 75, 75, 240), true)
            --dxDrawImage((startX + 20 + 1) + barX / 2 - 8, startY + barY / 2 + 1, 16, 16, heartTexture, 0, 0, 0, tocolor(120, 75, 75, 240), true)
            --dxDrawImage((startX + 20 + 1) + barX / 2 - 6, startY + barY / 2 + 3, 12, 12, heartTexture, 0, 0, 0, tocolor(20, 20, 20, 240), true)
            dxDrawText(math.floor(playerHealth) .. "%", (startX + 20 + 1) + barX / 2, startY + 8 + 1 + barY / 2, _, _, tocolor(185, 185, 185, 220), 1, robotoBold, "center", "center", false, false, true, true)
            
            dxDrawRoundedRectangle(startX + 20, startY + 7.5 + barY + 5, barX, barY, tocolor(25, 25, 25, 240), tocolor(25, 25, 25, 240), true)
            dxDrawRoundedRectangle(startX + 20 + 1, startY + 7.5 + barY + 5 + 1, (barX - 2)*(getPedArmor(localPlayer)/100), barY - 2, tocolor(75, 95, 120, 240), tocolor(75, 95, 120, 240), true)
           -- dxDrawImage((startX + 20 + 1) + barX / 2 - 8, startY + barY + 5 + barY / 2, 16, 16, armorTexture, 0, 0, 0, tocolor(75, 95, 120, 240), true)
            --dxDrawImage((startX + 20 + 1) + barX / 2 - 6, startY + barY + 5 + barY / 2 + 2, 12, 12, armorTexture, 0, 0, 0, tocolor(20, 20, 20, 240), true)
            dxDrawText(getPedArmor(localPlayer) .. "%", (startX + 20 + 1) + barX / 2, startY + 7.5 +  barY + 6 + (barY-2)/ 2, _, _, tocolor(185, 185, 185, 220), 1, robotoBold, "center", "center", false, false, true, true)

            -- ** TIME
            local time = getRealTime();

            if time["hour"] < 10 then
                time["hour"] = "0" .. time["hour"]
            else
                time["hour"] = time["hour"]
            end

            if time["minute"] < 10 then
                time["minute"] = "0" .. time["minute"]
            else
                time["minute"] = time["minute"]
            end

            if time["second"] < 10 then
                time["second"] = "0" .. time["second"]
            else
                time["second"] = time["second"]
            end
            
            dxDrawText("alphaGames v0.3  |  " .. time["hour"] .. ":" .. time["minute"] .. ":" .. time["second"] .. "  |  " .. getPlayerPing(localPlayer) .. " ms  |  " .. math.floor(getCurrentFPS()) .. " FPS", sX - 10, 10, _, _, tocolor(185, 185, 185, 220), 1, robotoThinSmall, "right", "center", false, false, true, true)
        
            local bubbleSizeX = 95
            dxDrawRoundedRectangle(startX + 20 + barX + 5, startY + 8, bubbleSizeX, barY, tocolor(25, 25, 25, 240), tocolor(25, 25, 25, 240), true)
            dxDrawText(getElementData(localPlayer, "a.Money") or 0 .. "#8CCB65$", startX + barX + 25 + bubbleSizeX / 2, startY + 8 + barY / 2, _, _, tocolor(200, 200, 200, 240), 1, robotoBold, "center", "center", false, false, true, true)

            dxDrawRoundedRectangle(startX + 20 + barX + 5 + bubbleSizeX + 5, startY + 8, bubbleSizeX, barY, tocolor(25, 25, 25, 240), tocolor(25, 25, 25, 240), true)
            dxDrawText(getElementData(localPlayer, "a.Experience") or 0 .. "#ECBC85XP", startX + barX + 25 + bubbleSizeX + bubbleSizeX / 2, startY + 8 + barY / 2, _, _, tocolor(200, 200, 200, 240), 1, robotoBold, "center", "center", false, false, true, true)

            dxDrawRoundedRectangle(startX + 20 + barX + 5, startY + 8 + barY + 5, bubbleSizeX, barY, tocolor(25, 25, 25, 240), tocolor(25, 25, 25, 240), true)
            dxDrawText(math.floor(getElementData(localPlayer, "a.Level") or 0) .. "#9B7070LVL", startX + barX + 25 + bubbleSizeX / 2, startY + 8 + barY + 5 + barY / 2, _, _, tocolor(200, 200, 200, 240), 1, robotoBold, "center", "center", false, false, true, true)

            dxDrawRoundedRectangle(startX + 20 + barX + 5 + bubbleSizeX + 5, startY + 8 + barY + 5, bubbleSizeX, barY, tocolor(25, 25, 25, 240), tocolor(25, 25, 25, 240), true)
            dxDrawText(math.floor(getElementData(localPlayer, "a.Premiumpont") or 0) .. "#70A9B6PP", startX + barX + 25 + bubbleSizeX / 2 + bubbleSizeX + 5, startY + 8 + barY + 5 + barY / 2, _, _, tocolor(200, 200, 200, 240), 1, robotoBold, "center", "center", false, false, true, true)
        
            local nowTick = getTickCount()
            if weaponShowed then
                local elapsedTime = nowTick - weaponTick
                local duration = elapsedTime / 1000
                a = interpolateBetween(0, 0, 0, 240, 0, 0, duration, "Linear")
            else
                local elapsedTime = nowTick - weaponTick
                local duration = elapsedTime / 1000
                a = interpolateBetween(a, 0, 0, 0, 0, 0, duration, "Linear")
            end
            dxDrawRoundedRectangle(startX + sizeX / 2, startY + sizeY + 5, sizeX / 2, sizeY / 2, tocolor(65, 65, 65, a), tocolor(35, 35, 35, a), true)
            
            local wep = getPedWeapon(localPlayer)
            if wep and weaponShowed and not (wep == 0) then
                local ammo = getPedAmmoInClip (localPlayer)
                local totalAmmo = getPedTotalAmmo (localPlayer)
                dxDrawText(getWeaponNameFromID(wep), startX + sizeX / 2 + 5, startY + sizeY + 5 + sizeY / 4, _, _, tocolor(200, 200, 200, a), 1, robotoThinSmall, "left", "center", false, false, true, true)
                dxDrawText(ammo .. "/" .. totalAmmo, startX + sizeX - 10, startY + sizeY + 5 + sizeY / 4, _, _, tocolor(200, 200, 200, a), 1, robotoBold, "right", "center", false, false, true, true)
            end
        end
    end
end
setTimer(renderComponents, 5, 0)

-- ** ASSETS ** --

function dxDrawRoundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x) and (y) and (w) and (h) then
		borderColor = borderColor or tocolor(0, 0, 0, 200)
		bgColor = bgColor or borderColor
        if (w == 0) or (h == 0) then
            return
        end
		--> Background
		dxDrawRectangle(x, y, w, h, borderColor, postGUI);
		
		--> Border
		dxDrawRectangle(x + 1, y + 1, w - 2, h - 2, bgColor, postGUI)-- left
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

function wepSwitch(prevWep, currWep)
    if getPedWeapon(localPlayer, prevWep) == 0 then
        weaponShowed = true
        weaponTick = getTickCount()
    end
    if getPedWeapon(localPlayer, currWep) == 0 then
        weaponShowed = false
        weaponTick = getTickCount()
    end
end
addEventHandler("onClientPlayerWeaponSwitch", root, wepSwitch)

function wepFire()
    fireTick = getTickCount()
end
addEventHandler("onClientPlayerWeaponFire", root, wepFire)