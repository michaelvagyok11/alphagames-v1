local sX, sY = guiGetScreenSize()
local width, height = 200, 20
local font = dxCreateFont("files/fonts/font.otf", 12)

--[[function onResStart(startedRes)
	if isPlayerDead(localPlayer) then
		local x, y, z = getElementPosition(localPlayer)
		local skin = getElementModel(localPlayer)
		triggerServerEvent("respawnPlayer", localPlayer, localPlayer, x, y, z, skin)
		setCameraTarget(localPlayer)
	end
end
addEventHandler("onClientResourceStart", root, onResStart)]]--

function renderDeath()
	local nowTick = getTickCount()
	local elapsedTime = nowTick - changeTick
	local duration = elapsedTime / 1000
	width = interpolateBetween(40*seconds, 0, 0, 40*seconds-40, 0, 0, duration, "Linear")
	dxDrawRectangle(sX / 2 - 200 / 2, sY / 2 - height / 2, 200, 20, tocolor(30, 30, 30))
	dxDrawRectangle(sX / 2 - 200 / 2 + 2, sY / 2 - height / 2 + 2, width - 4, 20 - 4, tocolor(200, 100, 100))
	dxDrawText(secondsToTime(seconds), sX / 2, sY / 2, _, _, tocolor(200, 200, 200), 1, font, "center", "center", false, false, false, true)
end

function onWasted()
	if source == localPlayer then
		if getElementData(localPlayer, "a.Gamemode") == 4 then
			local waitingPosition = {1775.2926025391, -1302.4283447266, 120.26425170898}
			local skin = getElementModel(localPlayer)
			toggleControl("fire", false)
			toggleControl("action", false)
			fadeCamera(true, 2)
			local dim = 4
			setElementData(localPlayer, "a.IsInInterior", false)
			setElementInterior(localPlayer, 0)
			setElementDimension(localPlayer, 4)
			triggerServerEvent("respawnPlayer", localPlayer, localPlayer, waitingPosition[1], waitingPosition[2], waitingPosition[3], skin, dim)
		else
			addEventHandler("onClientRender", root, renderDeath)
			changeTick = getTickCount()
			seconds = 5
			deathTime = seconds * 1000
			exports.a_blur:createBlur("death", 6)
			showChat(false)
			setElementData(localPlayer, "a.HUDshowed", false)
			dim = getElementDimension(localPlayer)
			setElementData(localPlayer, "a.isPlayerInLobbyColShape", true)
			setTimer(function()
				removeEventHandler("onClientRender", root, renderDeath)
				local respawnPos = getElementData(localPlayer, "a.RespawnPosition") or {2103.6416015625, -103.4091796875, 2.2497849464417}
				local skin = getElementModel(localPlayer)
				triggerServerEvent("respawnPlayer", localPlayer, localPlayer, respawnPos[1], respawnPos[2], respawnPos[3], skin, dim)
				setCameraTarget(localPlayer)
				exports.a_blur:removeBlur("death")
				setElementAlpha(localPlayer, 100)
				--setElementCollisionsEnabled(localPlayer, false)
				createDelay()
				showChat(true)
				setElementData(localPlayer, "a.HUDshowed", true)
			end, deathTime, 1)
			setTimer(function()
				if seconds > 0 then
					seconds = seconds - 1
					changeTick = getTickCount()
				end
			end, 1000, seconds + 1)
		end
	end
end
addEventHandler("onClientPlayerWasted", root, onWasted)

function createDelay()
	setTimer(function()
		setElementAlpha(localPlayer, 255)
		setElementData(localPlayer, "a.isPlayerInLobbyColShape", false)
		--setElementCollisionsEnabled(localPlayer, true)
	end, 3000, 1)
end

function killMyself()
	if getElementData(localPlayer, "loggedIn") == true then
		setElementHealth(localPlayer, 0)
		setElementData(localPlayer, "a.HPTeam", nil)
	end
end
addCommandHandler("kill", killMyself)

fadeCamera(true)

function secondsToTime(seconds)
	local seconds = tonumber(seconds)
  	if seconds <= 0 then
		return "00:00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return hours..":"..mins..":"..secs
	end
end