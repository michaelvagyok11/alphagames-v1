usageSyntax = "#D9B45A► Használat: #FFFFFF"
errorSyntax = "#E48F8F► Hiba: #FFFFFF"
successSyntax = "#B4D95A► Siker: #FFFFFF"
infoSyntax = "#5AB1D9► Info: #FFFFFF"
adminSyntax = "#F1919E►  Admin: #FFFFFF"

function invitePlayerToDuel(sourcePlayer, commandName, targetElement, map, round)
    if not (sourcePlayer) or not (isElement(sourcePlayer)) then
        return
    end

    if not targetElement or not map or not round then
        outputChatBox(usageSyntax .. "#FFFFFF/" .. commandName .. " [Név/ID] [Map] [Kör]", sourcePlayer, 255, 255, 255, true)
        return
    end

    local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
    if not (targetPlayer) then
        outputChatBox(errorSyntax .. "#FFFFFFNem található a target.", sourcePlayer, 255, 255, 255, true)
    else
        outputChatBox("#8FC3E4[Párbaj]: #8FC3E4" .. getPlayerName(sourcePlayer) .. " #FFFFFFkihívott téged egy párbajra. Elfogadáshoz használd az #9BE48F/elfogad#FFFFFF, elutasításhoz a #E48F8F/elutasit #FFFFFFparancsot.", targetPlayer, 255, 255, 255, true)
        outputChatBox("#8FC3E4[Párbaj]: #FFFFFFSikeresen kihívtad #8FC3E4" .. getPlayerName(targetPlayer) .. " #FFFFFFjátékost egy párbajra.", sourcePlayer, 255, 255, 255, true)

        setElementData(targetPlayer, "a.DuelOffered", true)
        setElementData(sourcePlayer, "a.DuelHosted", true)
    end
end
addCommandHandler("duel", invitePlayerToDuel)

function responseToInvite(command)
    if not (getElementData(source, "a.DuelOffered")) then
        return
    end
    if command == "elfogad" then
        setElementData(source, "a.DuelOffered", false)
    elseif command == "elutasit" then
        setElementData(source, "a.DuelOffered", false)
    end
end
addEventHandler("onPlayerCommand", root, responseToInvite)