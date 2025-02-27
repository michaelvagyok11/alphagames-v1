function invitePlayerToDuel(sourcePlayer, commandName, targetElement, betAmount, rounds)
    if targetElement and betAmount and rounds then
        local targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetElement)
        if (targetPlayer) then
            outputChatBox("#E18C88[Duel]: #8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFkihívott egy párbajra. Elfogadáshoz: #9BE48F/acceptduel #FFFFFF- elutasításhoz: #E48F8F/declineduel", targetPlayer, 255, 255, 255, true)
            outputChatBox("#E18C88[Duel]: #FFFFFFSikeresen kihívtad egy párbajra #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékost. #8FC3E4(" .. betAmount .. "$ - " .. rounds .. " kör)", 255, 255, 255, true)
            setElementData(targetPlayer, "a.DuelOffered", true)
        end
    else
        outputChatBox("#8FC3E4[Használat]: #FFFFFF/" .. commandName .. " [Játékos] [Fogadás összege] [Körök száma]", sourcePlayer, 255, 255, 255, true)
    end
end
addCommandHandler("duel", invitePlayerToDuel)

function onCommand(command)
    if command then
        if not (getElementData(source, "a.DuelOffered")) then
            return
        end
        if command == "acceptduel" then
        
        elseif command == "declineduel" then

        end
    end
end
addEventHandler("onPlayerCommand", root, onCommand)