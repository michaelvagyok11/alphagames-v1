setPlayerHudComponentVisible("all", false)
setPlayerHudComponentVisible("crosshair", true)

addEventHandler("onClientElementStreamIn", getRootElement( ),
function ()
	if getElementType(source) == "player" or getElementType(source) == "ped" then
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

		outputChatBox(colorRed .. "alphav2 ► Hiba: #FFFFFFMagasabb a pinged mint 150, ezért a kattintás, mint funkció le lett tiltva.", 255, 255, 255, true)
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


function findInterior()
	local interiorId = 3
	local x, y, z = 207.3560, -138.0029, 1003.3130

	setElementInterior(localPlayer, interiorId)
	setElementPosition(localPlayer, x, y, z)
end
addCommandHandler("intitest", findInterior)

function findInterior()
	setElementInterior(localPlayer, 0)
end
addCommandHandler("visacard", findInterior)



--[[function getAllDataFromTheClickedObj ( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	if ( clickedElement ) then
		
		local data = getAllElementData ( clickedElement )     
		for k, v in pairs ( data ) do                    
			print ( k .. ": " .. tostring ( v ) )             
		end
	end
end
addEventHandler ( "onClientClick", root, getAllDataFromTheClickedObj )]]