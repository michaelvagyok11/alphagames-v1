local playerTimers = {}
function sendStats(player)
	if isElement(player) then
		local columns, rows = getPerformanceStats("Lua timing")
		triggerClientEvent(player, "receiveServerStat", player, columns, rows)
		playerTimers[player] = setTimer(sendStats, 750, 1, player)
	end
end

addEvent("getServerStat", true)
addEventHandler("getServerStat", root, function()
	sendStats(client)
end)

addEvent("destroyServerStat", true)
addEventHandler("destroyServerStat", root, function()
	if isTimer(playerTimers[client]) then
		killTimer(playerTimers[client])
		playerTimers[client] = nil
	end
end)

local devSerials = {
	["3964A9A5103CDA070946DED861649B52"] = true
}
--[[
function toggleControls(source, state)
	toggleControl(source, "fire", state)
	toggleControl(source, "action", state)
end

function handleDataChange(dataName, oldValue, newValue)
	if devSerials[getPlayerSerial(source)] then 
		if dataName == "a.HPTeam" then 
			if newValue == nil then 
				outputChatBox("toggleControl nil", source)
				toggleControls(source, false)
			elseif newValue == 1 or newValue == 2 then 
				outputChatBox("toggleControl true", source)
				toggleControls(source, true)
			end
		end
	end
end
addEventHandler("onElementDataChange", getRootElement(), handleDataChange)]]