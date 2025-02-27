setPlayerHudComponentVisible("all", false)
setPlayerHudComponentVisible("crosshair", true)

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
		local colorRed = getColor("red", "hex")

		outputChatBox(colorRed .. "● Hiba: #FFFFFFMagasabb a pinged mint 150, ezért a kattintás, mint funkció le lett tiltva.", 255, 255, 255, true)
		cancelEvent()
	end
end
addEventHandler("onClientClick", root, onClick)

bindKey("m", "down", function()
	showCursor(not (isCursorShowing()))
end)

function setClipBoardPosition(element, ...)
	if element and isElement(element) and ... then
		position = {...}
		setClipboard(position[1][1] .. ", " .. position[1][2] .. ", " .. position[1][3])
	end
end
addEvent("setClipBoardPosition", true)
addEventHandler("setClipBoardPosition", root, setClipBoardPosition)