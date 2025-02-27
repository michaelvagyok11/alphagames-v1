local connection = exports.a_mysql:getConnection()
local currentMap = math.random(1, 10)

--[[function onKillSomebody(ammo, killer, weapon, bodypart, stealth)
    print("asd")
    if ammo and killer and weapon then
        if killer == source then
            return
        end

        local randomChance1 = math.random(1, 60)
        local chance = #summerEventItemsTable / (#summerEventItemsTable + randomChance1) * 100

        local secondTable = {}

        chance = (100-chance)

        for k, v in ipairs(summerEventItemsTable) do
            if math.floor(chance) <= v[3] then
                table.insert(secondTable, v)
            end
        end

        local randomChance2 = math.random(1, #secondTable)
        local winnedItem = nil

        for k, v in ipairs(secondTable) do
            if k == randomChance2 then
                winnedItem = v
            end
        end

        print(chance)

        local winnedItemName = getItemName(winnedItem[1])
        outputChatBox("#D9B45A[alphaGames]: #ffffffKaptál egy #5AB1D9strandlabdát.", source, 255, 255, 255, true)
        giveItem(source, winnedItem[1], 1, false, false, false, false, "faszhuszar.net", false)
    end
end
addEventHandler("onPlayerWasted", root, onKillSomebody)]]

function onKillSomebody(ammo, killer, weapon, bodypart, stealth)
    if ammo and killer and weapon then
        if killer == source then return end
        if bodypart == 9 then
            bonus = math.random(75, 125)
        else
            bonus = math.random(25, 75)
        end

        local isPlayerVIP = getElementData(killer, "a.VIP")

        bonus = bonus * 2 --**EVENT


        -- ** Summer event ** --
        local randomChance1 = math.random(1, 60)
        local chance = #summerEventItemsTable / (#summerEventItemsTable + randomChance1) * 100

        local secondTable = {}

        chance = (100-chance)

        for k, v in ipairs(summerEventItemsTable) do
            if math.floor(chance) <= v[3] then
                table.insert(secondTable, v)
            end
        end

        local randomChance2 = math.random(1, #secondTable)
        local winnedItem = nil

        for k, v in ipairs(secondTable) do
            if k == randomChance2 then
                winnedItem = v
            end
        end

        print(chance)

        local winnedItemName = getItemName(winnedItem[1])
        outputChatBox("#D9B45A[alphaGames]: #ffffffKaptál egy #5AB1D9strandlabdát.", source, 255, 255, 255, true)
        giveItem(source, winnedItem[1], 1, false, false, false, false, "faszhuszar.net", false)
        
        -- ** Summer event vége ** --

        if (isPlayerVIP) then
            bonus = bonus * 3
            outputChatBox("#E48F8F[Ölés]: #FFFFFFMegölted #8FC3E4" .. getPlayerName(source) .. "#ffffff játékost. #9BE48F(" .. bonus .. "#FFFFFF$ - #C4CD5D3x#9BE48F)", killer, 255, 255, 255, true)
        else
            outputChatBox("#E48F8F[Ölés]: #FFFFFFMegölted #8FC3E4" .. getPlayerName(source) .. "#ffffff játékost. #9BE48F(" .. bonus .. "#FFFFFF$)", killer, 255, 255, 255, true)
        end

        local clanID = getElementData(killer, "a.PlayerGroup")
        if clanID and clanID > 0 then
            bonus = bonus * 1.5
            outputChatBox("#E48F8F[Ölés]: #FFFFFFKlán szorzó: 1.5x.", killer, 255, 255, 255, true)
        end

        setElementData(killer, "a.Kills", getElementData(killer, "a.Kills")+1)
        setElementData(source, "a.Deaths", getElementData(source, "a.Deaths")+1)
        --outputChatBox("#E48F8F[Death]: #FFFFFFYou have killed #8FC3E4" .. getPlayerName(source) .. "#ffffff. You got #9BE48F" .. bonus .. "#FFFFFF$.", killer, 255, 255, 255, true)
        exports.a_interface:giveExperience(killer, source)
        setElementData(killer, "a.Money", getElementData(killer, "a.Money") + bonus)

        currmap = currentMap or map
        exports.a_logs:createDCLog(getPlayerName(killer) .. " killed " .. getPlayerName(source) .. " - (wep: " .. getWeaponNameFromID(weapon) .. " | bodypart: " .. bodypart .. ")", 5)
        if getElementData(killer, "a.DMTeam") == tostring(teamMaps[currmap]["mapTeamNames"][1]) then
            teamTwoKills = teamTwoKills + 1
            triggerClientEvent(root, "sendKillInformationToClient", root, 2, teamTwoKills)
        elseif getElementData(killer, "a.DMTeam") == tostring(teamMaps[currmap]["mapTeamNames"][2]) then
            teamOneKills = teamOneKills + 1
            triggerClientEvent(root, "sendKillInformationToClient", root, 1, teamOneKills)
        end

        makeProtection(source, 10)
    end
end
addEventHandler("onPlayerWasted", root, onKillSomebody)

function onDataChange(key, oValue, nValue)
    if key == "a.Kills" then
        dbExec(connection, "UPDATE accounts SET kills = '" .. nValue .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end
    if key == "a.Deaths" then
        dbExec(connection, "UPDATE accounts SET deaths = '" .. nValue .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end
end
addEventHandler("onElementDataChange", root, onDataChange)

local methodTimer = {};
local delayTimer = {};
second = 300

function calculateTime()
    if second > 0 then 
        second = second - 1
        triggerClientEvent(getRootElement(), "giveCounter", getRootElement(), second)
    elseif second <= 0 then
        currentMap = math.random(1, 10)
        triggerClientEvent(root, "sendTimeoutToClient", root, currentMap)

        for k, v in ipairs(getElementsByType("player")) do
            if getElementData(v, "a.Gamemode") == 1 then
                methodTimer[v] = setTimer(function()
                    local method = sortPlayerIntoTeam(v)
                    if method == 1 then
                        setElementData(v, "a.DMTeam", teamMaps[currentMap]["mapTeamNames"][1])
                        setElementData(v, "a.DMRespawnpos", {teamMaps[currentMap]["mapRespawnPosition"][1], teamMaps[currentMap]["mapRespawnPosition"][2], teamMaps[currentMap]["mapRespawnPosition"][3]})
                        outputChatBox("#D19D6B[TDMA]: #FFFFFFA rendszer kiválasztotta neked a #D19D6B" .. teamMaps[currentMap]["mapTeamNames"][1] .. " #FFFFFFcsapatot. Jelenlegi pálya: #8FC3E4" .. teamMaps[currentMap]["mapName"], v, 255, 255, 255, true)
                        setElementPosition(v, teamMaps[currentMap]["mapRespawnPosition"][1], teamMaps[currentMap]["mapRespawnPosition"][2], teamMaps[currentMap]["mapRespawnPosition"][3])
                    else
                        outputChatBox("#D19D6B[TDMA]: #FFFFFFA rendszer kiválasztotta neked a #7DAFDC" .. teamMaps[currentMap]["mapTeamNames"][2] .. " #FFFFFFcsapatot. Jelenlegi pálya: #8FC3E4" .. teamMaps[currentMap]["mapName"], v, 255, 255, 255, true)
                        setElementData(v, "a.DMTeam", teamMaps[currentMap]["mapTeamNames"][2])
                        setElementData(v, "a.DMRespawnpos", {teamMaps[currentMap]["mapRespawnPosition"][4], teamMaps[currentMap]["mapRespawnPosition"][5], teamMaps[currentMap]["mapRespawnPosition"][6]})
                        setElementPosition(v, teamMaps[currentMap]["mapRespawnPosition"][4], teamMaps[currentMap]["mapRespawnPosition"][5], teamMaps[currentMap]["mapRespawnPosition"][6])
                    end
                    makeProtection(v, 20)
                    --print("besorolt " .. tonumber(getTickCount()))
                end, 100*getElementData(v, "playerid"), 1)
            end
        end

        setTimer(checkDistribution, 5000, 1)
        checkTick = getTickCount();
        second = 300
        teamOneKills = 0
        teamTwoKills = 0
        setTimer(calculateTime, 1000, second + 1)
    end
end

setTimer(calculateTime, 1000, second + 1)

function checkDistribution()
    local teamOnePlayers = 0;
    local teamTwoPlayers = 0;
    local morePlayers = 0;
    local teamOne = {};
    local teamTwo = {};

    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.DMTeam") == teamMaps[currentMap]["mapTeamNames"][1] then
            teamOnePlayers = teamOnePlayers + 1;
            table.insert(teamOne, v)
        elseif getElementData(v, "a.DMTeam") == teamMaps[currentMap]["mapTeamNames"][2] then
            teamTwoPlayers = teamTwoPlayers + 1;
            table.insert(teamTwo, v)
        end
    end
    setTimer(function()
        if (teamOnePlayers - teamTwoPlayers) == 2 then
            morePlayers = 1;
            randint = math.random(1, #teamOne)
            for k, v in ipairs(teamOne) do
                if k == randint then
                    outputChatBox("#D19D6B[TDMA]: #FFFFFFA rendszer kiválasztotta neked a #7DAFDC" .. teamMaps[currentMap]["mapTeamNames"][2] .. " #FFFFFFcsapatot. Jelenlegi pálya: #8FC3E4" .. teamMaps[currentMap]["mapName"], v, 255, 255, 255, true)
                    setElementData(v, "a.DMTeam", teamMaps[currentMap]["mapTeamNames"][2])
                    setElementData(v, "a.DMRespawnpos", {teamMaps[currentMap]["mapRespawnPosition"][4], teamMaps[currentMap]["mapRespawnPosition"][5], teamMaps[currentMap]["mapRespawnPosition"][6]})
                    setElementPosition(v, teamMaps[currentMap]["mapRespawnPosition"][4], teamMaps[currentMap]["mapRespawnPosition"][5], teamMaps[currentMap]["mapRespawnPosition"][6])
                end
            end
        end

        if (teamTwoPlayers - teamOnePlayers) == 2 then
            morePlayers = 2;
            randint = math.random(1, #teamTwo)
            for k, v in ipairs(teamTwo) do
                if k == randint then
                    setElementData(v, "a.DMTeam", teamMaps[currentMap]["mapTeamNames"][1])
                    setElementData(v, "a.DMRespawnpos", {teamMaps[currentMap]["mapRespawnPosition"][1], teamMaps[currentMap]["mapRespawnPosition"][2], teamMaps[currentMap]["mapRespawnPosition"][3]})
                    outputChatBox("#D19D6B[TDMA]: #FFFFFFA rendszer kiválasztotta neked a #D19D6B" .. teamMaps[currentMap]["mapTeamNames"][1] .. " #FFFFFFcsapatot. Jelenlegi pálya: #8FC3E4" .. teamMaps[currentMap]["mapName"], v, 255, 255, 255, true)
                    setElementPosition(v, teamMaps[currentMap]["mapRespawnPosition"][1], teamMaps[currentMap]["mapRespawnPosition"][2], teamMaps[currentMap]["mapRespawnPosition"][3])
                end
            end
        end
    end, 1000, 1)
end

function onResStart()
    currentMap = math.random(1, 10)
    teamOneKills = 0
    teamTwoKills = 0
    triggerClientEvent(getRootElement(), "sendTimeoutToClient", getRootElement(), currentMap)
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 1 then
            methodTimer[v] = setTimer(function()
                local method = sortPlayerIntoTeam(v)
                if method == 1 then
                    setElementData(v, "a.DMTeam", teamMaps[currentMap]["mapTeamNames"][1])
                    setElementData(v, "a.DMRespawnpos", {teamMaps[currentMap]["mapRespawnPosition"][1], teamMaps[currentMap]["mapRespawnPosition"][2], teamMaps[currentMap]["mapRespawnPosition"][3]})
                    setElementPosition(v, teamMaps[currentMap]["mapRespawnPosition"][1], teamMaps[currentMap]["mapRespawnPosition"][2], teamMaps[currentMap]["mapRespawnPosition"][3])
                    outputChatBox("#D19D6B[TDMA]: #FFFFFFA rendszer kiválasztotta neked a #D19D6B" .. teamMaps[currentMap]["mapTeamNames"][1] .. " #FFFFFFcsapatot. Jelenlegi pálya: #8FC3E4" .. teamMaps[currentMap]["mapName"], v, 255, 255, 255, true)
                else
                    outputChatBox("#D19D6B[TDMA]: #FFFFFFA rendszer kiválasztotta neked a #7DAFDC" .. teamMaps[currentMap]["mapTeamNames"][2] .. " #FFFFFFcsapatot. Jelenlegi pálya: #8FC3E4" .. teamMaps[currentMap]["mapName"], v, 255, 255, 255, true)
                    setElementData(v, "a.DMTeam", teamMaps[currentMap]["mapTeamNames"][2])
                    setElementData(v, "a.DMRespawnpos", {teamMaps[currentMap]["mapRespawnPosition"][4], teamMaps[currentMap]["mapRespawnPosition"][5], teamMaps[currentMap]["mapRespawnPosition"][6]})
                    setElementPosition(v, teamMaps[currentMap]["mapRespawnPosition"][4], teamMaps[currentMap]["mapRespawnPosition"][5], teamMaps[currentMap]["mapRespawnPosition"][6])
                end
                makeProtection(v, 20)
            end, 100*getElementData(v, "playerid"), 1)
        end
    end
end
setTimer(onResStart, 500, 1)

function sortPlayerIntoTeam(source)
    teamOneCount = 0
    teamTwoCount = 0
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.DMTeam") == tostring(teamMaps[currentMap]["mapTeamNames"][1]) then
            teamOneCount = teamOneCount + 1
        end
        if getElementData(v, "a.DMTeam") == tostring(teamMaps[currentMap]["mapTeamNames"][2]) then
            teamTwoCount = teamTwoCount + 1
        end
    end
    if teamOneCount == teamTwoCount then
        sortedTeam = math.random(1, 2)
        return sortedTeam
    elseif teamOneCount > teamTwoCount then
        return 2
    elseif teamOneCount < teamTwoCount then
        return 1
    end
end

function onDataChange(key, oValue, nValue)
    if key == "a.Gamemode" and nValue == 1 then
        if source then
        --for k, v in ipairs(getElementsByType("player")) do
            local method = sortPlayerIntoTeam(source)
            if method == 1 then
                outputChatBox("#D19D6B[TDMA]: #FFFFFFA rendszer kiválasztotta neked a #DCAF7D" .. teamMaps[currentMap]["mapTeamNames"][1] .. " #FFFFFFcsapatot. Jelenlegi pálya: #8FC3E4" .. teamMaps[currentMap]["mapName"], source, 255, 255, 255, true)
                setElementData(source, "a.DMTeam", teamMaps[currentMap]["mapTeamNames"][1])
                setElementData(source, "a.DMRespawnpos", {teamMaps[currentMap]["mapRespawnPosition"][1], teamMaps[currentMap]["mapRespawnPosition"][2], teamMaps[currentMap]["mapRespawnPosition"][3]})
                setElementPosition(source, teamMaps[currentMap]["mapRespawnPosition"][1], teamMaps[currentMap]["mapRespawnPosition"][2], teamMaps[currentMap]["mapRespawnPosition"][3])
            else
                outputChatBox("#D19D6B[TDMA]: #FFFFFFA rendszer kiválasztotta neked a #7DAFDC" .. teamMaps[currentMap]["mapTeamNames"][2] .. " #FFFFFFcsapatot. Jelenlegi pálya: #8FC3E4" .. teamMaps[currentMap]["mapName"], source, 255, 255, 255, true)
                setElementData(source, "a.DMTeam", teamMaps[currentMap]["mapTeamNames"][2])
                setElementData(source, "a.DMRespawnpos", {teamMaps[currentMap]["mapRespawnPosition"][4], teamMaps[currentMap]["mapRespawnPosition"][5], teamMaps[currentMap]["mapRespawnPosition"][6]})
                setElementPosition(source, teamMaps[currentMap]["mapRespawnPosition"][4], teamMaps[currentMap]["mapRespawnPosition"][5], teamMaps[currentMap]["mapRespawnPosition"][6])
            end
            makeProtection(source, 20)
       -- end
        end
    end
    if key == "a.Gamemode" and oValue == 1 and nValue == nil then
        setElementData(source, "a.DMTeam", nil)
        setElementData(source, "a.DMRespawnpos", nil)
    end
end
addEventHandler("onElementDataChange", root, onDataChange)

function makeProtection(element, time)
    setElementData(element, "a.Protected", true)
    delayTimer[element] = setTimer(function()
        setElementData(element, "a.Protected", false)
    end, time*1000, 1)
end

function onFire()
    if getElementData(source, "a.Protected") then
        setElementData(source, "a.Protected", false)
        if isTimer(delayTimer[source]) then
            killTimer(delayTimer[source]) 
        end
    end
end
addEventHandler("onPlayerWeaponFire", root, onFire)