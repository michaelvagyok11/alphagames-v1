local sX, sY = guiGetScreenSize();
local sizeY = 30;
local infoboxCache = {}

local poppinsRegular = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", 13, false, "cleartype")

local textToTypes = {
    [1] = "Siker",
    [2] = "Hiba",
}

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
        outputConsole("INFOBOX ► " .. textToTypes[type] .. ": " .. removeHex(text, 6))
    end
end
addEvent("makeNotification", true)
addEventHandler("makeNotification", root, makeNotification)

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end

function onRender()
    for i, v in ipairs(infoboxCache) do
        local type, text, createTick = v[1], v[2], v[3]

        local nowTick = getTickCount();
        local elapsedTime = nowTick - createTick;
        local duration = elapsedTime / 500;
        a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

        local textWidth = dxGetTextWidth(text, 1, poppinsRegular, true)
        local startX, startY, sizeX, sizeY = sX / 2 - textWidth / 2, 10 + ((i - 1) * 33), 50 + textWidth + 10, sizeY
    
        startY = interpolateBetween(-40, 0, 0, startY, 0, 0, duration * 2, "Linear")

        line = interpolateBetween(0, 0, 0, sizeX, 0, 0, elapsedTime / 5000, "Linear")

        dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a), true)
        dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a), true)
        
        dxDrawRectangle(startX + sizeX / 2, startY + sizeY - 1, line / 2, 1, tocolor(colors[type][1], colors[type][2], colors[type][3], a), true)
        dxDrawRectangle(startX + sizeX / 2, startY + sizeY - 1, -(line / 2), 1, tocolor(colors[type][1], colors[type][2], colors[type][3], a), true)

        dxDrawImage(startX + 15, startY + 6, 18, 18, "files/img/" .. type .. ".png", 0, 0, 0, tocolor(colors[type][1], colors[type][2], colors[type][3], a), true)

        dxDrawText(text, startX + sizeX / 2 + 20, startY + sizeY / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsRegular, "center", "center", false, false, true, true)

        if createTick + 5000 < nowTick then
            table.remove(infoboxCache, i)
        end
    end
end
addEventHandler("onClientRender", root, onRender)