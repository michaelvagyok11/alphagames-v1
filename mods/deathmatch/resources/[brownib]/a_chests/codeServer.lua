function attemptToBuy(element, ...)
    if isElement(element) and getElementData(element, "loggedIn") then
        if ... then
            args = {...}
            args = args[1]
            if args[1] == "$" then
                local playerMoney = getElementData(element, "a.Money");
                if tonumber(playerMoney) >= args[2] then
                    exports.a_inventory:givePlayerItem(element, args[3], 1)
                    outputChatBox("#9BE48F[Láda]: #FFFFFFSikeresen megvásároltad a kiválasztott ládát.", element, 255, 255, 255, true)
                else
                    outputChatBox("#E48F8F[Hiba]: #FFFFFFNincs elég pénzed a vásárláshoz.", element, 255, 255, 255, true)
                    return
                end
            elseif args[2] == "pp" then
            
            else
                return
            end
        end
    end
end
addEvent("attemptToBuy", true)
addEventHandler("attemptToBuy", root, attemptToBuy)