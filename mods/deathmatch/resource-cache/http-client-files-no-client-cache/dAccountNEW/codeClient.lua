local sX, sY = guiGetScreenSize()

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

local sizeX, sizeY = respc(400), respc(400)
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

local barlowLight10 = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(10), false, "cleartype")
local barlowRegular10 = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(10), false, "cleartype")

function onLoad()
    if not getElementData(localPlayer, "d/LoggedIn") then
        startTick = getTickCount()
        addEventHandler("onClientRender", root, onRender)
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onLoad)

function onRender()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - startTick
    local duration = elapsedTime / 2000
    local a = interpolateBetween(0, 0, 0, 225, 0, 0, duration, "Linear")

    --dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(35, 35, 35, a))

    if isMouseInPosition(startX + respc(10), startY + respc(15), sizeX - respc(20), respc(40)) then
        dxDrawText("FELHASZNÁLÓNÉV", startX + respc(15), startY + respc(5), _, _, tocolor(200, 200, 200, a), 1, barlowRegular10, "left", "center", false, false, false, true)
        dxDrawRoundedRectangle(startX + respc(10), startY + respc(15), sizeX - respc(20), respc(40), 3, tocolor(45, 45, 45, a))
    else
        dxDrawText("FELHASZNÁLÓNÉV", startX + respc(15), startY + respc(5), _, _, tocolor(220, 220, 220, a), 1, barlowLight10, "left", "center", false, false, false, true)
        dxDrawRoundedRectangle(startX + respc(10), startY + respc(15), sizeX - respc(20), respc(40), 3, tocolor(35, 35, 35, a))
    end

    if isMouseInPosition(startX + respc(10), startY + respc(85), sizeX - respc(20), respc(40)) then
        dxDrawText("JELSZÓ", startX + respc(15), startY + respc(75), _, _, tocolor(200, 200, 200, a), 1, barlowRegular10, "left", "center", false, false, false, true)
        dxDrawRoundedRectangle(startX + respc(10), startY + respc(85), sizeX - respc(20), respc(40), 3, tocolor(45, 45, 45, a))
    else
        dxDrawText("JELSZÓ", startX + respc(15), startY + respc(75), _, _, tocolor(220, 220, 220, a), 1, barlowLight10, "left", "center", false, false, false, true)
        dxDrawRoundedRectangle(startX + respc(10), startY + respc(85), sizeX - respc(20), respc(40), 3, tocolor(35, 35, 35, a))
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

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end