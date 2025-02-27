local screenX, screenY = guiGetScreenSize()

function reMap(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
    return num * responsiveMultipler
end

function respc(num)
    return math.ceil(num * responsiveMultipler)
end

function getResponsiveMultipler()
    return responsiveMultipler
end

local panelW, panelH = respc(800), respc(400)
local panelX, panelY = (screenX - panelW) * 0.5, (screenY - panelH) * 0.5

function dxDrawRoundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
    if (x) and (y) and (w) and (h) then
        borderColor = borderColor or tocolor(0, 0, 0, 200)
        bgColor = bgColor or borderColor
    
        --** Background
        dxDrawRectangle(x, y, w, h, bgColor, postGUI);
        
        --** Border
        dxDrawRectangle(x - 1, y + 1, 1, h - 2, borderColor, postGUI)-- left
        dxDrawRectangle(x + w, y + 1, 1, h - 2, borderColor, postGUI)-- right
        dxDrawRectangle(x + 1, y - 1, w - 2, 1, borderColor, postGUI)-- top
        dxDrawRectangle(x + 1, y + h, w - 2, 1, borderColor, postGUI)-- bottom
        dxDrawRectangle(x, y, 1, 1, borderColor, postGUI)
        dxDrawRectangle(x + w - 1, y, 1, 1, borderColor, postGUI)
        dxDrawRectangle(x, y + h - 1, 1, 1, borderColor, postGUI)
        dxDrawRectangle(x + w - 1, y + h - 1, 1, 1, borderColor, postGUI)
    end
end

-- addEvent("makeVipNoti", true)
-- addEventHandler("makeVipNoti", getRootElement(), makeVipNotin)
-- function makeVipNotin()
--     exports.dInfobox:makeNotification(2, "Lejárt a VIP tagságod!")
-- end

addEvent("makeVipNoti", true)
addEventHandler("makeVipNoti", getRootElement(),
	function ()
		exports.dInfobox:makeNotification(2, "Lejárt a VIP tagságod!")
	end)