addEventHandler("onClientElementStreamIn", getRootElement( ),
function ()
	if getElementType(source) == "player" then
		setPedVoice(source, "PED_TYPE_DISABLED")
	end
end)

addEventHandler("onClientResourceStart", getResourceRootElement(),
function (startedRes)
	for k, v in ipairs(getElementsByType("player")) do
		setPedVoice(v, "PED_TYPE_DISABLED")
	end
end)

setTimer(function()
	setPedControlState("walk", true)
end, 500, 0)

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if getPlayerPing(localPlayer) > 150 then
		exports.aInfobox:makeNotification(2, "Túl nagy a pinged, így a rendszer letiltotta a kattintás funkcióját.")
		cancelEvent()
	end
end
addEventHandler("onClientClick", root, onClick)

local corner = dxCreateTexture("assets/img/corner.png", "argb", true, "clamp")

function dxDrawRoundedRectangle(x, y, w, h, color, radius, postGUI, subPixelPositioning)
	radius = radius or 5
	color = color or tocolor(0, 0, 0, 200)
	
	dxDrawImage(x, y, radius, radius, corner, 0, 0, 0, color, postGUI)
	dxDrawImage(x, y + h - radius, radius, radius, corner, 270, 0, 0, color, postGUI)
	dxDrawImage(x + w - radius, y, radius, radius, corner, 90, 0, 0, color, postGUI)
	dxDrawImage(x + w - radius, y + h - radius, radius, radius, corner, 180, 0, 0, color, postGUI)
	
	dxDrawRectangle(x, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
	dxDrawRectangle(x + radius, y, w - radius * 2, h, color, postGUI, subPixelPositioning)
	dxDrawRectangle(x + w - radius, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
end

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)