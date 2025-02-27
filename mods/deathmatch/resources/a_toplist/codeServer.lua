local connection = exports.a_mysql:getConnection()

function requestData(element)
    if isElement(element) then
        dbQuery(function(handler)
            local result = dbPoll(handler, 0)
            local killStats = {}
            for k, v in pairs(result) do
                if k <= 10 then
                    table.insert(killStats, {v["playerName"], v["kills"]})
                    --table.insert(killStats[2], v["kills"])
                    if k == 10 then
                        triggerClientEvent("sendInformations", element, element, "kills", killStats)
                    end
                else
                    break
                end
            end
        end, connection, "SELECT * FROM accounts ORDER BY kills DESC")

        dbQuery(function(handler)
            local result = dbPoll(handler, 0)
            local deathStats = {}
            for k, v in pairs(result) do
                if k <= 10 then
                    table.insert(deathStats, {v["playerName"], v["deaths"]})
                    --table.insert(killStats[2], v["kills"])
                    if k == 10 then
                        triggerClientEvent("sendInformations", element, element, "deaths", deathStats)
                    end
                else
                    break
                end
            end
        end, connection, "SELECT * FROM accounts ORDER BY deaths DESC")

        dbQuery(function(handler)
            local result = dbPoll(handler, 0)
            local driftStats = {}
            for k, v in pairs(result) do
                if k <= 10 then
                    table.insert(driftStats, {v["playerName"], v["bestDrift"]})
                    --table.insert(killStats[2], v["kills"])
                    if k == 10 then
                        triggerClientEvent("sendInformations", element, element, "drifts", driftStats)
                    end
                else
                    break
                end
            end
        end, connection, "SELECT * FROM accounts ORDER BY bestDrift DESC")

        dbQuery(function(handler)
            local result = dbPoll(handler, 0)
            local xpStats = {}
            for k, v in pairs(result) do
                if k <= 10 then
                    table.insert(xpStats, {v["playerName"], v["xp"]})
                    --table.insert(killStats[2], v["kills"])
                    if k == 10 then
                        triggerClientEvent("sendInformations", element, element, "xp", xpStats)
                    end
                else
                    break
                end
            end
        end, connection, "SELECT * FROM accounts ORDER BY xp DESC")
    end
end
addEvent("requestData", true)
addEventHandler("requestData", root, requestData)