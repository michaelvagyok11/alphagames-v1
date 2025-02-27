local dbConnection = exports.a_mysql:getConnection();

function onStart()
    easterEventPed = createPed(pedSkinID, pedX, pedY, pedZ)

    setElementData(easterEventPed, "a.EasterEventPed", true)
    setElementData(easterEventPed, "a.Pedname", "Patrícia #F27503(Halloween event)")

    setElementFrozen(easterEventPed, true)
    setElementRotation(easterEventPed, 0, 0, -90)
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function checkEasterEventTimer(source)
    if isElement(source) and client and client == source then
        dbExec(dbConnection, "UPDATE accounts SET eventLastUseDate = ? WHERE eventLastUseDate < NOW()", tostring(""))

        local query = dbQuery(dbConnection, "SELECT * FROM accounts WHERE id = ?", getElementData(source, "a.accID"))
        local results = dbPoll(query, -1)
        if (#results > 0) then
            for _, v in ipairs(results) do
                if not (v["eventLastUseDate"] == "") then
                    triggerClientEvent("sendDataToClient", source, source, "declined")
                else
                    triggerClientEvent("sendDataToClient", source, source, "success")
                end
            end
        end
    end
end
addEvent("YwmfZJeKGlhBea6P1zXS$$$$$$", true)
addEventHandler("YwmfZJeKGlhBea6P1zXS$$$$$$", root, checkEasterEventTimer)

function giveGiftToPlayer(source)
    if isElement(source) and client and client == source then
        dbExec(dbConnection, "UPDATE accounts SET eventLastUseDate = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 12 HOUR)  WHERE id = ?", getElementData(source, "a.accID"))

        randomGift = math.random(1, 100)
        if randomGift > 1 and randomGift < 50 then
            -- ** item
            exports.a_inventory:giveItem(source, 62, 1, false, false, false, false, "alphagames.net", false)
            outputChatBox("#F27503[alphaGames - Halloween Event]: #FFFFFFAz ajándékod egy #F27503Tök#ffffff! Megtalálod az inventorydban.", source, 255, 255, 255, true)
        elseif randomGift >= 50 and randomGift <= 75 then
            -- ** XP
            giftAmount = math.random(250, 500)
            setElementData(source, "a.Experience", getElementData(source, "a.Experience") + giftAmount)
            outputChatBox("#F27503[alphaGames - Halloween Event]: #FFFFFFAz ajándékod #F27503" .. giftAmount .. " tapasztalatpont.", source, 255, 255, 255, true)
        elseif randomGift > 75 and randomGift <= 85 then
            -- ** PP
            giftAmount = math.random(100, 150)
            setElementData(source, "a.Premiumpont", getElementData(source, "a.Premiumpont") + giftAmount)
            outputChatBox("#F27503[alphaGames - Halloween Event]: #FFFFFFAz ajándékod #8FC3E4" .. giftAmount .. " prémiumpont.", source, 255, 255, 255, true)
        else
            outputChatBox("#F27503[alphaGames - Halloween Event]: #FFFFFFAz ajándékodat #F27503Patrícia #FFFFFFinkább felajánlotta jótékony célokra. Gyere vissza később, hátha szerencsével jársz!", source, 255, 255, 255, true)
        end
    end
end
addEvent("SuwyG68DruYPD93B84YE$$$$$$", true)
addEventHandler("SuwyG68DruYPD93B84YE$$$$$$", root, giveGiftToPlayer)