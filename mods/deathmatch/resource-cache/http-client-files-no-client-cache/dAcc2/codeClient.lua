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

local sizeX, sizeY = respc(300), respc(200)
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2

local bebasLight15 = dxCreateFont("files/fonts/BebasNeue-Light.ttf", respc(25), false, "cleartype")
local bebasBold15 = dxCreateFont("files/fonts/BebasNeue-Bold.ttf", respc(25), false, "cleartype")
local bebasRegular15 = dxCreateFont("files/fonts/BebasNeue-Regular.ttf", respc(25), false, "cleartype")

function renderLogin()
    local serverNameSignWidth = dxGetTextWidth("RATHER", 1 , bebasBold15)
    dxDrawText("RATHER", startX + sizeX / 2, startY + respc(30), _, _, tocolor(200, 200, 200, 255), 1, bebasBold15, "right", "center")
    dxDrawText("MTA", startX + sizeX / 2, startY + respc(30), _, _, tocolor(200, 200, 200, 255), 1, bebasLight15, "left", "center")
    dxDrawText("RATHERMTA", startX + sizeX / 2, startY + respc(75), _, _, tocolor(200, 200, 200, 255), 1, bebasRegular15, "center", "center")
end
--addEventHandler("onClientRender", root, renderLogin)