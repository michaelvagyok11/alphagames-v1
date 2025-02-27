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

local sizeY = respc(30);
local infoboxCache = {}

local poppinsRegular = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(10), false, "cleartype")

local colors = {
    [1] = {155, 230, 140},
    [2] = {230, 140, 140},
}

local sounds = {
    [1] = "files/sounds/success.mp3",
    [2] = "files/sounds/error.mp3",
}

function makeNotification(type, text)
    if type and text then
        table.insert(infoboxCache, {type, text, getTickCount()})
        playSound(sounds[type], false)
    end
end
addEvent("makeNotification", true)
addEventHandler("makeNotification", root, makeNotification)

function onRender()
    for i, v in ipairs(infoboxCache) do
        local type, text, createTick = v[1], v[2], v[3]

        local nowTick = getTickCount();
        local elapsedTime = nowTick - createTick;
        local duration = elapsedTime / 500;
        a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

        local textWidth = dxGetTextWidth(text, 1, poppinsRegular, true)
        local startX, startY, sizeX, sizeY = sX / 2 - textWidth / 2, respc(10) + ((i - 1) * respc(32)), respc(50) + textWidth + respc(10), sizeY
    
        startY = interpolateBetween(-40, 0, 0, startY, 0, 0, duration * 2, "Linear")

        line = interpolateBetween(0, 0, 0, sizeX - respc(3), 0, 0, elapsedTime / 5000, "Linear")

        --dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a), true)
        dxDrawRoundedRectangle(startX, startY, sizeX, sizeY, 3, tocolor(35, 35, 35, a), true)
        
        dxDrawRectangle(startX + sizeX / 2, startY + sizeY - 1, line / 2, 2, tocolor(colors[type][1], colors[type][2], colors[type][3], a), true)
        dxDrawRectangle(startX + sizeX / 2, startY + sizeY - 1, -(line / 2), 2, tocolor(colors[type][1], colors[type][2], colors[type][3], a), true)

        dxDrawImage(startX + respc(15), startY + respc(6), respc(18), respc(18), "files/img/" .. type .. ".png", 0, 0, 0, tocolor(colors[type][1], colors[type][2], colors[type][3], a), true)

        dxDrawText(text, startX + sizeX / 2 + respc(20), startY + sizeY / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsRegular, "center", "center", false, false, true, true)

        if createTick + 5000 < nowTick then
            table.remove(infoboxCache, i)
        end
    end
end
addEventHandler("onClientRender", root, onRender)

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