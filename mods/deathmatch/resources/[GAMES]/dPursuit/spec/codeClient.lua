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

local sizeX, sizeY = respc(200), respc(30)
local startX, startY = sX / 2 - sizeX / 2, sY - sizeY * 3

local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(15), false, "cleartype")
local poppinsLightBig = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(14), false, "cleartype")
local poppinsRegularBig = dxCreateFont("files/fonts/Poppins-Regular.ttf", respc(14), false, "cleartype")

function onChange(key, oVal, nVal)
	if key == "a.HPTeam" then
		if nVal == nil then
			spectateInProgress = false

			openTick = getTickCount()
			addEventHandler("onClientRender", root, renderSpectatePanel)
			addEventHandler("onClientClick", root, clickSpectatePanel)
		elseif nVal ~= nil and oVal == nil then
			spectateInProgress = false
			removeEventHandler("onClientRender", root, renderSpectatePanel)
			removeEventHandler("onClientClick", root, clickSpectatePanel)
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

function renderSpectatePanel()
	local nowTick = getTickCount()
	local elapsedTime = nowTick - openTick
	local duration = elapsedTime / 500
	local a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	if isMouseInPosition(startX, startY, sizeX, sizeY) then
		dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	else	
		dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(35, 35, 35, a))
	end
	dxDrawText("alpha", startX + respc(2), startY - respc(10), _, _, tocolor(200, 200, 200, a), 1, poppinsBoldBig, "left", "center", false, false, false, true)
	dxDrawText("SPECTATE", startX + respc(4.5) + dxGetTextWidth("alpha", 1, poppinsBoldBig), startY - respc(10), _, _, tocolor(200, 200, 200, a), 1, poppinsLightBig, "left", "center", false, false, false, true)

	if spectateInProgress then
		dxDrawImage(startX + respc(10), startY + respc(7), respc(16), respc(16), "files/img/close.png", 0, 0, 0, tocolor(230, 140, 140, a))
		dxDrawText("#E48F8FKilépés a figyelésből", startX + sizeX / 2 + respc(10), startY + sizeY / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsLightBig, "center", "center", false, false, false, true)
	else
		dxDrawImage(startX + respc(10), startY + respc(5), respc(20), respc(20), "files/img/eye.png", 0, 0, 0, tocolor(155, 230, 140, a))
		dxDrawText("#9BE48FJátékosok figyelése", startX + sizeX / 2 + respc(10), startY + sizeY / 2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsLightBig, "center", "center", false, false, false, true)
	end
end

function clickSpectatePanel(button, state)
	if button == "left" and state == "down" then
		if isMouseInPosition(startX, startY, sizeX, sizeY) then
			if spectateInProgress then
				spectateInProgress = false
				triggerServerEvent("stopSpectate", localPlayer, localPlayer)
				outputChatBox("#E48F8F► Siker: #FFFFFFSikeresen kiléptél a játékosfigyelő módból.", 255, 255, 255, true)
			else
				spectateInProgress = true
				triggerServerEvent("startSpectate", localPlayer, localPlayer)
				outputChatBox("#9BE48F► Siker: #FFFFFFSikeresen beléptél a játékosfigyelő módba. Kilépni belőle a #E48F8F/stopspec #FFFFFFparanccsal, vagy a #E48F8Fpanel újbóli megnyomásával#FFFFFF tudsz.", 255, 255, 255, true)
			end
		end
	end
end

function spectateStarted(element)
	if element and localPlayer == element and isElement(element) and getElementType(element) == "player" then
		addEventHandler("onClientRender", root, renderSpectating)
		addEventHandler("onClientClick", root, clickSpectating)
		addEventHandler("onClientKey", root, keySpectating)
	end
end
addEvent("spectateStarted", true)
addEventHandler("spectateStarted", root, spectateStarted)

function renderSpectating()

end

function clickSpectating(button, state)
end

function keySpectating(key, state)
end