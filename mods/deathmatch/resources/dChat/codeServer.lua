local swearWords = {"kurva", "anyád", "fasz", "cigány", "geci", "picsa", "buzi", "basz", "baszás", "bazdmeg", "baszódj", "picsába"}

function onChat(message, messageType)
    cancelEvent()

    local isMuted = getElementData(source, "a.Muted")
    if (isMuted) then
        local muteTime = getElementData(source, "a.Mutetime")
        outputChatBox("#E48F8Falphav2 ► Hiba: #FFFFFFNem tudsz kommunikálni, mivel le vagy némítva még #E48F8F" .. muteTime .. " #ffffffpercig.", source, 255, 255, 255, true)
        cancelEvent()
        return
    end

    if message and messageType then
        if string.find(message:lower(), "@everyone") or string.find(message:lower(), "@here") then
            return
        end

        for k, v in ipairs(getElementsByType("player")) do
            if messageType == 0 then
                if getElementData(v, "loggedIn") then
                    local name = "#F1C692" .. getElementData(source, "a.PlayerName")
                    local clanID = getElementData(source, "a.PlayerGroup")

                    local alevel = getElementData(source, "adminLevel")
                    if alevel > 0 then
                        syntax = exports.dAdmin:getAdminSyntax(alevel, true) .. " "
                    else
                        syntax = ""
                    end
                    
                    if clanID and clanID > 0 then
                        syntax = "" .. getElementData(source, "a.ClanHex") .. "[" .. getElementData(source, "a.ClanSyntax") .. "] " .. syntax
                    end

                    local isPlayerVIP = getElementData(source, "a.VIP");
                    if isPlayerVIP == true and alevel == 0 then
                        syntax = "#C4CD5D(VIP) #FFFFFF"
                    end

                    outputChatBox("#C5D8A7>> " .. syntax .. name .. "#FFFFFF: ".. message, v, 255, 255, 255, true)
                end
            end
        end
        for k, v in ipairs(swearWords) do
            if string.find(message:lower(), v) then
                -- ** HIBAPONT RENDSZER, 5nél LEMUTEOL - EZT MÉG MEG KELL ÍRNI! - dzseki (2024/05/26)
                local currentFaultPoint = 1
                outputChatBox("#E48F8Falphav2 ► Szűrő: #FFFFFFKérlek próbáld meg mellőzni az #E48F8Fobszcén szavak #FFFFFFhasználatát a chaten. #E48F8F(Hibapontjaid: " .. currentFaultPoint .. ")", source, 255, 255, 255, true)
            end
        end
        --exports.d_logs:createDCLog("(GLOBAL) **" .. removeHex(name, 6) .. "** - " .. message, 3)
    end
end
addEventHandler("onPlayerChat", root, onChat)

function bindTeamSay()
    for k, v in ipairs(getElementsByType("player")) do
        bindKey(v, "y", "down", "chatbox", "Teamsay")
    end
end
addEventHandler("onResourceStart", root, bindTeamSay)
addEventHandler("onPlayerJoin", root, bindTeamSay)

function teamSay(executerElement, commandName, ...)
    if (...) then
        local isMuted = getElementData(executerElement, "a.Muted")
        if (isMuted) then
            local muteTime = getElementData(source, "a.Mutetime")
            outputChatBox("#E48F8Falphav2 ► Hiba: #FFFFFFNem tudsz kommunikálni, mivel le vagy némítva még #E48F8F" .. muteTime .. " #ffffffpercig.", source, 255, 255, 255, true)
            cancelEvent()
            return
        end

        if getElementData(executerElement, "a.Gamemode") == 1 then
            local currentTeamName = getElementData(executerElement, "a.DMTeam")
            local currentPlayerName = getPlayerName(executerElement)
            for k, v in ipairs(getElementsByType("player")) do
                if getElementData(v, "a.DMTeam") == currentTeamName then
                    outputChatBox("#9BE48F[CSAPAT]#C8C8C8 " .. currentPlayerName .. ": #FFFFFF" .. table.concat({...}, " "), v, 255, 255, 255, true)
                end
            end
        else 
            local currentGamemode = getElementData(executerElement, "a.Gamemode")
            local currentPlayerName = getPlayerName(executerElement)
            for k, v in ipairs(getElementsByType("player")) do
                if getElementData(v, "a.Gamemode") == currentGamemode and currentGamemode ~= nil then
                    outputChatBox("#A7D2D8[" .. exports.dLobby:getGamemodeNameById(getElementData(executerElement, "a.Gamemode")) .. "]: #c8c8c8" .. currentPlayerName .. ": #ffffff" .. table.concat({...}, " "), v, 255, 255, 255, true)
                end
            end
            --exports.d_logs:createDCLog("(teamsay) **" .. currentPlayerName .. "** - " .. table.concat({...}, " "), 3)
        end
    end
end
addCommandHandler("Teamsay", teamSay)

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end