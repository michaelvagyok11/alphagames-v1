local dbConnection = exports.a_mysql:getConnection();

function onStart()
    easterEventPed = createPed(pedSkinID, pedX, pedY, pedZ)

    setElementData(easterEventPed, "a.EasterEventPed", true)
    setElementData(easterEventPed, "a.Pedname", "Patrícia #E18C88(Húsvét)")

    setElementFrozen(easterEventPed, true)
    setElementRotation(easterEventPed, 0, 0, 195)
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function checkEasterEventTimer(element)
    if element and isElement(element) then
        dbExec(dbConnection, "UPDATE accounts SET eventLastUseDate = ? WHERE eventLastUseDate < NOW()", tostring(""))

        local query = dbQuery(dbConnection, "SELECT * FROM accounts WHERE id = ?", getElementData(element, "a.accID"))
        local results = dbPoll(query, -1)
        if (#results > 0) then
            for _, v in ipairs(results) do
                if not (v["eventLastUseDate"] == "") then
                    triggerClientEvent("sendDataToClient", element, element, "declined")
                else
                    triggerClientEvent("sendDataToClient", element, element, "success")
                end
            end
        end
    end
end
addEvent("checkEasterEventTimer", true)
addEventHandler("checkEasterEventTimer", root, checkEasterEventTimer)

function giveGiftToPlayer(element)
    if element and isElement(element) then
        dbExec(dbConnection, "UPDATE accounts SET eventLastUseDate = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 5 HOUR)  WHERE id = ?", getElementData(element, "a.accID"))

        randomGift = math.random(1, 100)
        if randomGift > 1 and randomGift < 50 then
            -- ** MONEY
            giftAmount = math.random(500, 1000)
            setElementData(element, "a.Money", getElementData(element, "a.Money") + giftAmount)
            outputChatBox("#E48F8F[Easter]: #FFFFFFAz ajándékod #9BE48F" .. giftAmount .. "$.", element, 255, 255, 255, true)
        elseif randomGift >= 50 and randomGift <= 75 then
            -- ** XP
            giftAmount = math.random(250, 500)
            setElementData(element, "a.Experience", getElementData(element, "a.Experience") + giftAmount)
            outputChatBox("#E48F8F[Easter]: #FFFFFFAz ajándékod #F1C176" .. giftAmount .. " tapasztalatpont.", element, 255, 255, 255, true)
        elseif randomGift > 75 and randomGift <= 85 then
            -- ** PP
            giftAmount = math.random(100, 150)
            setElementData(element, "a.Premiumpont", getElementData(element, "a.Premiumpont") + giftAmount)
            outputChatBox("#E48F8F[Easter]: #FFFFFFAz ajándékod #8FC3E4" .. giftAmount .. " prémiumpont.", element, 255, 255, 255, true)
        else
            outputChatBox("#E48F8F[Easter]: #FFFFFFAz ajándékodat #F1C176Patrícia #FFFFFFinkább felajánlotta jótékony célokra. Gyere vissza később, hátha szerencsével jársz!", element, 255, 255, 255, true)
        end
    end
end
addEvent("giveGiftToPlayer", true)
addEventHandler("giveGiftToPlayer", root, giveGiftToPlayer)