local connection = exports.a_mysql:getConnection()

function onKillSomebody(ammo, killer, weapon, bodypart, stealth)
    if ammo and killer and weapon then
        if killer == source then return end
        tdmaEventKills = getElementData(killer, "a.eventKills") or 0
        setElementData(killer, "a.eventKills", tonumber(getElementData(killer, "a.eventKills") or 0) +1)
    end
end
addEventHandler("onPlayerWasted", root, onKillSomebody)

function onDataChange(key, oValue, nValue)
    if key == "a.eventKills" then
        dbExec(connection, "UPDATE accounts SET eventKills = '" .. nValue .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end
end
addEventHandler("onElementDataChange", root, onDataChange)

addCommandHandler("cleareventkills",
    function (source)
        if getElementData(source, "adminLevel") >= 4 then
            for k, v in pairs(getElementsByType("player")) do
                setElementData(v, "a.eventKills", 0)
            end
        end
    end
)

function getEventKills(executerElement, commandName, targetElement)
	if (targetElement) then
		local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
		if (targetPlayer) then

            local name = getPlayerName(targetPlayer)
			local eventKills = getElementData(targetPlayer, "a.eventKills")

			outputChatBox("#E18C88[alphaGames - Event Killek]: #7cc576".. name .." #ffffffevent ölései: #8FC3E4".. eventKills, executerElement, 255, 255, 255, true)
			--outputChatBox("Event ölések száma: #8FC3E4" .. eventKills, executerElement, 255, 255, 255, true)
            iprint("player: "..name.." kills: "..eventKills)
		end
	else
		outputChatBox("#E18C88[alphaGames - Event]: #ffffff/" .. commandName .. " [target]", executerElement, 255, 255, 255, true)
	end
end
addCommandHandler("geteventkills", getEventKills)

function requestData(element)
    if isElement(element) then
        dbQuery(function(handler)
            local result = dbPoll(handler, 0)
            local killStats = {}
            for k, v in pairs(result) do
                if k <= 10 then
                    table.insert(killStats, {v["playerName"], v["eventKills"]})
                    if k == 10 then
                        triggerClientEvent("sendInformations", element, element, "eventKills", killStats)
                    end
                else
                    break
                end
            end
        end, connection, "SELECT * FROM accounts ORDER BY eventKills DESC")
    end
end
addEvent("requestData", true)
addEventHandler("requestData", root, requestData)