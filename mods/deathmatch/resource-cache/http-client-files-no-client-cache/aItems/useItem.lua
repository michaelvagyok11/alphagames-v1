function useItem(itemID, itemSlot)
    if itemList[itemID] then
        if itemList[itemID][2] == "weapon" then
            triggerServerEvent("giveWeaponToPlayer", localPlayer, localPlayer, itemList[itemID][3], itemID)
        end
    else
        error("Nem tudta a rendszer lekérni az itemhez tartozó adatokat. (" .. itemID .. ")")
        return false
    end
end