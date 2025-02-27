local sizeY = 25;
local currentInfoboxes = {}
local poppinsRegular12 = dxCreateFont("files/fonts/Roboto-Thin.ttf", 13, false, "cleartype")
local sX, sY = guiGetScreenSize();
function createInfobox(type, message)
	if type and message then
		table.insert(currentInfoboxes, {type, message, getTickCount()})
	end
end

function renderInfoboxes()
	for i, v in ipairs(currentInfoboxes) do
		local type, message, tick = v[1], v[2], v[3]
		local messageWidth = dxGetTextWidth(message, 1, poppinsRegular12)
		local startX, startY, sizeX, sizeY = sX / 2 - messageWidth / 2 - 10, 10 + ((i - 1) * 35), messageWidth + 20, sizeY
		dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65))
		dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35))
		dxDrawText(message, sX / 2, startY + sizeY / 2, _, _, tocolor(200, 200, 200), 1, poppinsRegular12, "center", "center", false, false, false, true)
	end
end
addEventHandler("onClientRender", root, renderInfoboxes)

createInfobox(2, "Ez amit látsz, egy tesztelésre szánt hosszú infobox szövege.")