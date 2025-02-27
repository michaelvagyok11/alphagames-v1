function tryToPurchase(element, paymentType, itemLine)
    if isElement(element) and paymentType and itemLine then
        -- ** AC
        if not element or not isElement(element) or not getElementType(element) == "player" then
            return
        end
        local clientPlayer = client

        if not clientPlayer and not client == source then
            return
        end
        -- ** AC VÉGE

        if paymentType == "$" then
            local playerMoney = getElementData(element, "a.Money")
            local currentSelectedItemPrice = itemLine[2]

            if getElementData(element, "a.VIP") == true then
                if not currentSelectedItemPrice == "-" then
                    local currentSelectedItemPrice = itemLine[2] * 0.80
                end

                if currentSelectedItemPrice == "-" then
                    triggerClientEvent("purchaseResponse", element, element, "failed.canNotPayWithCash")
                    return false
                end

                if itemLine[6] == "hp100" and getElementHealth(element) == 100 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.hpPurchase")
                    return false
                elseif itemLine[6] == "armor50" and getPedArmor(element) >= 49 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.armor50")
                    return false
                elseif itemLine[6] == "armor100" and getPedArmor(element) == 100 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.armor100")
                    return false
                end

                if currentSelectedItemPrice > playerMoney and not currentSelectedItemPrice == "-" then
                    triggerClientEvent("purchaseResponse", element, element, "failed.notEnoughMoney")
                    return false
                else
                    -- ** SIKERES VÁSÁRLÁS
                    setElementData(element, "a.Money", playerMoney - currentSelectedItemPrice)
                    triggerClientEvent("purchaseResponse", element, element, "success")

                    if itemLine[4] == "weapons" then
                        exports.dItems:giveItem(element, itemLine[6], 1, false, false, false, false, "alphagames.net", false)
                    else
                        if itemLine[6] == "hp100" then
                            setElementHealth(element, 100)
                        elseif itemLine[6] == "armor50" then
                            setPedArmor(element, 50)
                        elseif itemLine[6] == "armor100" then
                            setPedArmor(element, 100)
                        end
                    end
                end
            elseif getElementData(element, "a.VIP") == false then
                local currentSelectedItemPrice = itemLine[2]
        
                if currentSelectedItemPrice == "-" then
                    triggerClientEvent("purchaseResponse", element, element, "failed.canNotPayWithCash")
                    return false
                end
        
                if itemLine[6] == "hp100" and getElementHealth(element) == 100 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.hpPurchase")
                    return false
                elseif itemLine[6] == "armor50" and getPedArmor(element) >= 49 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.armor50")
                    return false
                elseif itemLine[6] == "armor100" and getPedArmor(element) == 100 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.armor100")
                    return false
                end
        
                if currentSelectedItemPrice > playerMoney and not currentSelectedItemPrice == "-" then
                    triggerClientEvent("purchaseResponse", element, element, "failed.notEnoughMoney")
                    return false
                else                           
                    -- ** SIKERES VÁSÁRLÁS
                    setElementData(element, "a.Money", playerMoney - currentSelectedItemPrice)
                    triggerClientEvent("purchaseResponse", element, element, "success")
        
                    if itemLine[4] == "weapons" then
                        exports.dItems:giveItem(element, itemLine[6], 1, false, false, false, false, "alphagames.net", false)
                    else
                        if itemLine[6] == "hp100" then
                            setElementHealth(element, 100)
                        elseif itemLine[6] == "armor50" then
                            setPedArmor(element, 50)
                        elseif itemLine[6] == "armor100" then
                            setPedArmor(element, 100)
                        end
                    end
                end
            end
        elseif paymentType == "pp" then
            local playerPP = getElementData(element, "a.Premiumpont")
            local currentSelectedItemPrice = tonumber(itemLine[3])

            if getElementData(element, "a.VIP") == true then
                local currentSelectedItemPrice = tonumber(itemLine[3]) * 0.80

                if itemLine[6] == "hp100" and getElementHealth(element) == 100 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.hpPurchase")
                    return false
                elseif itemLine[6] == "armor50" and getPedArmor(element) >= 49 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.armor50")
                    return false
                elseif itemLine[6] == "armor100" and getPedArmor(element) == 100 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.armor100")
                    return false
                end

                if currentSelectedItemPrice > playerPP then
                    triggerClientEvent("purchaseResponse", element, element, "failed.notEnoughPP")
                    return false
                else
                    setElementData(element, "a.Premiumpont", playerPP - currentSelectedItemPrice)
                    triggerClientEvent("purchaseResponse", element, element, "success")

                    if itemLine[4] == "weapons" or itemLine[4] == "weapons2" then
                        exports.dItems:giveItem(element, itemLine[6], 1, false, false, false, false, "alphagames.net", false)
                    else
                        if itemLine[6] == "hp100" then
                            setElementHealth(element, 100)
                        elseif itemLine[6] == "armor50" then
                            setPedArmor(element, 50)
                        elseif itemLine[6] == "armor100" then
                            setPedArmor(element, 100)
                        elseif itemLine[6] == "dollar1000" then
                            local playerMoney = getElementData(element, "a.Money")
                            setElementData(element, "a.Money", playerMoney + 1000)
                        elseif itemLine[6] == "dollar2500" then
                            local playerMoney = getElementData(element, "a.Money")
                            setElementData(element, "a.Money", playerMoney + 2500)
                        elseif itemLine[6] == "dollar5000" then
                            local playerMoney = getElementData(element, "a.Money")
                            setElementData(element, "a.Money", playerMoney + 5000)
                        end
                    end
                end
            elseif getElementData(element, "a.VIP") == false then
                local currentSelectedItemPrice = tonumber(itemLine[3])
    
                if itemLine[6] == "hp100" and getElementHealth(element) == 100 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.hpPurchase")
                    return false
                elseif itemLine[6] == "armor50" and getPedArmor(element) >= 49 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.armor50")
                    return false
                elseif itemLine[6] == "armor100" and getPedArmor(element) == 100 then
                    triggerClientEvent("purchaseResponse", element, element, "failed.armor100")
                    return false
                end
    
                if currentSelectedItemPrice > playerPP then
                    triggerClientEvent("purchaseResponse", element, element, "failed.notEnoughPP")
                    return false
                else
                    setElementData(element, "a.Premiumpont", playerPP - currentSelectedItemPrice)
                    triggerClientEvent("purchaseResponse", element, element, "success")
    
                    if itemLine[4] == "weapons" or itemLine[4] == "weapons2" then
                        exports.dItems:giveItem(element, itemLine[6], 1, false, false, false, false, "alphagames.net", false)
                    else
                        if itemLine[6] == "hp100" then
                            setElementHealth(element, 100)
                        elseif itemLine[6] == "armor50" then
                            setPedArmor(element, 50)
                        elseif itemLine[6] == "armor100" then
                            setPedArmor(element, 100)
                        elseif itemLine[6] == "dollar1000" then
                            local playerMoney = getElementData(element, "a.Money")
                            setElementData(element, "a.Money", playerMoney + 1000)
                        elseif itemLine[6] == "dollar2500" then
                            local playerMoney = getElementData(element, "a.Money")
                            setElementData(element, "a.Money", playerMoney + 2500)
                        elseif itemLine[6] == "dollar5000" then
                            local playerMoney = getElementData(element, "a.Money")
                            setElementData(element, "a.Money", playerMoney + 5000)
                        end
                    end
                end
            end
        end
    end
end
addEvent("tryToPurchase", true)
addEventHandler("tryToPurchase", root, tryToPurchase)