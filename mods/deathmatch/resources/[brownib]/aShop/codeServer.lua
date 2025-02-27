function tryToPurchase(element, type, itemid, price)
    if isElement(element) and type and price then
        if type == "$" then
            local playerMoney = getElementData(element, "a.Money")
            local price = tonumber(price)
            if price > playerMoney then
                triggerClientEvent("purchaseResponse", element, element, "failed.notEnoughMoney")
                return false
            else
                -- ** SIKERES VÁSÁRLÁS
                setElementData(element, "a.Money", playerMoney - price)
                triggerClientEvent("purchaseResponse", element, element, "success")
                if tonumber(itemid) then
                    exports.a_inventory:giveItem(element, itemid, 1)
                else
                    if tostring(itemid) == "hp100" then
                        setElementHealth(element, 100)
                    elseif tostring(itemid) == "hp50" then
                        setElementHealth(element, 50)
                    elseif tostring(itemid) == "armor50" then
                        setPedArmor(element, 50)
                    elseif tostring(itemid) == "armor100" then
                        setPedArmor(element, 100)
                    end
                end
            end
        elseif type == "pp" then
            local playerPP = getElementData(element, "a.Premiumpont")
            local price = tonumber(price)
            if price > playerPP then
                triggerClientEvent("purchaseResponse", element, element, "failed.notEnoughPP")
                return false
            else
                setElementData(element, "a.Premiumpont", playerPP - price)
                triggerClientEvent("purchaseResponse", element, element, "success")
                if tonumber(itemid) then
                    exports.a_inventory:giveItem(element, itemid, 1)
                else
                    if tostring(itemid) == "hp100" then
                        setElementHealth(element, 100)
                    elseif tostring(itemid) == "armor50" then
                        setPedArmor(element, 50)
                    elseif tostring(itemid) == "armor100" then
                        setPedArmor(element, 100)
                    end
                end
            end
        end
    end
end
addEvent("tryToPurchase", true)
addEventHandler("tryToPurchase", root, tryToPurchase)