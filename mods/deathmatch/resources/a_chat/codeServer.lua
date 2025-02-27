local connection = exports.a_mysql:getConnection()

local swearWords = {
    "kurva",
    "anyád",
    "fasz",
    "cigány",
    "geci",
    "picsa",
    "buzi",
    "basz",
    "baszás",
    "bazdmeg",
    "baszódj",
    "picsába",
    "takony",
    "idióta",
    "idiota",
    "nyomorek",
    "nyomorék",
    "rákos",
    "rakos",
}

function onChat(message, messageType)
    cancelEvent()

    local isMuted = getElementData(source, "a.Muted")
    if (isMuted) then
        local muteTime = getElementData(source, "a.Mutetime")
        local muteReason = getElementData(source, "a.Mutereason")
        outputChatBox("#E48F8F► Hiba: #FFFFFFNémítva vagy jelenleg, így nem tudod használni a chatet. #8FC3E4(Indok: " .. muteReason .. " - Hátralévő idő: " .. muteTime .. " perc)", source, 255, 255, 255, true)
        cancelEvent()
        return
    end

    if message and messageType then
        if string.find(message:lower(), "@everyone") or string.find(message:lower(), "@here") or string.find(message:lower(), "https://") then
            return outputChatBox("#E48F8F► Hiba: #FFFFFFEz nem engedélyezett a chaten!", source, 255, 255, 255, true)
        end
        if messageType == 1 then
            return
        end
        for k, v in ipairs(swearWords) do
            if getElementData(source, "adminLevel") == 0 then
                if string.find(message:lower(), v) then
                    message = string.gsub(message:lower(), v, string.rep("*", string.len(v)))
                    warnPlayer(source)
                    local warns = getElementData(source, "a.Warns") or 0
                    outputChatBox("#E48F8F► Hiba: #FFFFFFHa tovább káromkodsz, a rendszer kirúg a szerverről! #d75959("..warns.."/3)", source, 255, 255, 255, true)
                end
            end
        end
        for k, v in ipairs(getElementsByType("player")) do
            if messageType == 0 then
                if getElementData(v, "loggedIn") then
                    name = getElementData(source, "a.PlayerName")
                    local clanID = getElementData(source, "a.PlayerGroup")

                    local adminLevel = getElementData(source, "adminLevel")
                    if adminLevel > 0 then
                        syntax = exports.aAdmin:getAdminSyntax(adminLevel, true) .. " "
                    else
                        syntax = ""
                    end

                    if clanID > 0 then
                        syntax = syntax .. "#" .. getElementData(source, "a.ClanHex") .. "[" .. getElementData(source, "a.ClanSyntax") .. "] "
                    end

                    local isPlayerVIP = getElementData(source, "a.VIP")
                    if isPlayerVIP == true and adminLevel == 0 and clanID > 0 then
                        syntax = "#C4CD5D[VIP] #"..getElementData(source, "a.ClanHex").."["..getElementData(source, "a.ClanSyntax").."] #C4E094"
                    elseif isPlayerVIP == true and adminLevel == 0 and clanID == 0 then
                        syntax = "#C4CD5D[VIP] #C4E094"
                    end

                    outputChatBox("#C4E094»» " .. syntax .. name .. "#FFFFFF: ".. message, v, 255, 255, 255, true)
                end
            end
        end
        exports.a_logs:createDCLog("(GLOBAL) **" .. removeHex(name, 6) .. "** - " .. message, 3)
    end
end
addEventHandler("onPlayerChat", root, onChat)

addEventHandler("onPlayerPrivateMessage", getRootElement(),
    function ()
        cancelEvent()
        outputChatBox("#E48F8F► Hiba: #FFFFFFEz a funckió letiltásra került!", source, 255, 255, 255, true)
    end
)


-- ** warn system (figyelmeztetés.. brownib)
function warnPlayer(source)
    local warns = getElementData(source, "a.Warns") or 0
    local playerName = getElementData(source, "a.PlayerName")

    setElementData(source, "a.Warns", warns + 1)

    if getElementData(source, "a.Warns") >= 3 then
        time = 30
		reason = "Túl sokat káromkodtál a chaten."

		db = dbExec(connection,"INSERT INTO `mutes` SET `accid` = ?, `date` =  NOW() + INTERVAL "..tonumber(time).." MINUTE, `reason` = ?, `admin` = ?", getElementData(source, "a.accID"), reason, "Rendszer")
		db2 = dbExec(connection, "UPDATE accounts SET muted = '1', mutetime = '" .. time .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")

		if (db) and (db2) then
			setElementData(source, "a.Muted", true)
			setElementData(source, "a.Mutetime", time)
			setElementData(source, "a.Mutereason", reason)
			outputChatBox("#E48F8F[Warn]: #ffffffLe lettél némítva a #8FC3E4Rendszer#ffffff által #8FC3E4" .. time .. " #ffffffpercre. #E48F8F(" .. reason .. ")", source, 255, 255, 255, true)
        end
        --kickPlayer(source, "Figyelmeztetés", "Túl sokat káromkodtál a chaten.")
        setElementData(source, "a.Warns", 0)
        outputChatBox("#E48F8F[Kick]: #9BE48FRendszer#FFFFFF lenémította #9BE48F" .. playerName .. " #FFFFFFjátékost. #8FC3E4(Indok: Figyelmeztetés 3/3.)", root, 255, 255, 255, true)
        --outputChatBox("#E48F8F[Kick]: #9BE48FRendszer#FFFFFF kirúgta #9BE48F" .. playerName .. " #FFFFFFjátékost a szerverről. #8FC3E4(Indok: Figyelmeztetés 3/3.)", root, 255, 255, 255, true)
    end
end

addCommandHandler("warn",
    function(source, cmd, target, ...)
        if getElementData(source, "adminLevel") >= 1 then
            if target and (...) then
                local target = exports.a_core:findPlayer(source, target)
                local reason = table.concat({...}, " ")

                if target and reason then
                    local warns = getElementData(target, "a.Warns") or 0
                    local targetName = getElementData(target, "a.PlayerName")
                    local sourceName = getElementData(source, "a.PlayerName")

                    outputChatBox("#E48F8F[Warn]: #9BE48F" .. sourceName .. "#FFFFFF figyelmeztette #9BE48F" .. targetName .. " #FFFFFFjátékost. #8FC3E4(Indok: " .. table.concat({...}, " ") .. ")", root, 255, 255, 255, true)
                    outputChatBox("#E48F8F[Warn]: #9BE48F" .. sourceName .. "#FFFFFF figyelmeztett téged! #d75959(".. warns ..")", target, 255, 255, 255, true)
                    
                    warnPlayer(target)
                end
            else
                outputChatBox("#D19D6B[Warn]:#ffffff /".. cmd .." [Név/ID] [Indok]", source, 255, 255, 255, true)
            end
        end
    end
)

addCommandHandler("delwarn",
    function(source, cmd, target, ...)
        if getElementData(source, "adminLevel") >= 1 then
            if target and (...) then
                local target = exports.a_core:findPlayer(source, target)
                local reason = table.concat({...}, " ")

                if target and reason then
                    local warns = getElementData(target, "a.Warns") or 0
                    local targetName = getElementData(target, "a.PlayerName")
                    local sourceName = getElementData(source, "a.PlayerName")

                    outputChatBox("#E48F8F[Warn]: #9BE48F" .. sourceName .. "#FFFFFF törölte #9BE48F" .. targetName .. " #FFFFFFjátékos figyelmeztetéseit. #8FC3E4(Indok: " .. table.concat({...}, " ") .. ")", root, 255, 255, 255, true)
                    outputChatBox("#E48F8F[Warn]: #9BE48F" .. sourceName .. "#FFFFFF törölte a figyelmeztetéseid! #d75959(".. warns ..")", target, 255, 255, 255, true)
                    
                    setElementData(target, "a.Warns", 0)
                end
            else
                outputChatBox("#D19D6B[Warn]:#ffffff /".. cmd .." [Név/ID] [Indok]", source, 255, 255, 255, true)
            end
        end
    end
)

addCommandHandler("checkwarn",
    function(source, cmd, target, ...)
        if getElementData(source, "adminLevel") >= 1 then
            if target then
                local target = exports.a_core:findPlayer(source, target)

                if target then
                    local warns = getElementData(target, "a.Warns") or 0
                    local targetName = getElementData(target, "a.PlayerName")


                    outputChatBox("#E48F8F[Warn]: #9BE48F" .. targetName .. "#FFFFFF figyelmeztetései: #d75959(".. warns .."/3)", source, 255, 255, 255, true)
                end
            else
                outputChatBox("#D19D6B[Warn]:#ffffff /".. cmd .." [Név/ID]", source, 255, 255, 255, true)
            end
        end
    end
)

--[[addCommandHandler("delallwarn",
    function(source, cmd, target, ...)
        if getElementData(source, "adminLevel") >= 1 then
            if target and (...) then
                local target = exports.a_core:findPlayer(source, target)
                local reason = table.concat({...}, " ")

                if target and reason then
                    for k, v in pairs(getElementsByType("player")) do
                        local warns = getElementData(v, "a.Warns") or 0
                        local targetName = getPlayerName(v)
                        local sourceName = getPlayerName(source)
    
                        outputChatBox("#E48F8F[Warn]: #9BE48F" .. sourceName .. "#FFFFFF törölte #9BE48Faz összes#FFFFFFjátékos figyelmeztetéseit. #8FC3E4(Indok: " .. table.concat({...}, " ") .. ")", root, 255, 255, 255, true)
                        outputChatBox("#E48F8F[Warn]: #9BE48F" .. sourceName .. "#FFFFFF törölte a figyelmeztetéseid! #d75959(".. warns ..")", v, 255, 255, 255)
                        
                        setElementData(v, "a.Warns", 0)
                    end
                end
            else
                outputChatBox("#D19D6B[Warn]:#ffffff /".. cmd .." [target] [reason]", source, 255, 255, 255, true)
            end
        end
    end
)]]

addCommandHandler("delallwarn",
    function(source)
        if getElementData(source, "adminLevel") >= 5 then
            for k, v in pairs(getElementsByType("player")) do
                local sourceName = getElementData(source, "a.PlayerName")
                outputChatBox("#E48F8F[Warn]: #9BE48F" .. sourceName .. "#FFFFFF törölte a figyelmeztetéseid!", v, 255, 255, 255, true)
                setElementData(v, "a.Warns", 0)
            end
            local sourceName = getElementData(source, "a.PlayerName")
            outputChatBox("#E48F8F[Warn]: #9BE48F" .. sourceName .. "#FFFFFF törölte#9BE48F az összes játékos #FFFFFFfigyelmeztetéseit.", root, 255, 255, 255, true)
        end
    end
)


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
            local muteReason = getElementData(source, "a.Mutereason")
            outputChatBox("#E48F8F► Hiba: #FFFFFFNémítva vagy jelenleg, így nem tudod használni a chatet. #8FC3E4(Indok: " .. muteReason .. " - Hátralévő idő: " .. muteTime .. " perc)", source, 255, 255, 255, true)
            cancelEvent()
            return
        end

        if getElementData(executerElement, "a.Gamemode") == nil then
            outputChatBox("#E48F8F► Hiba: #FFFFFFA csapat társalgást nem tudod használni a várakozóban.", source, 255, 255, 255, true)
            return
        end

        if getElementData(executerElement, "a.Gamemode") == 1 then
            local currentTeamName = getElementData(executerElement, "a.DMTeam")
            local currentPlayerName = getElementData(executerElement, "a.PlayerName")
            for k, v in ipairs(getElementsByType("player")) do
                if getElementData(v, "a.DMTeam") == currentTeamName then
                    outputChatBox("#9BE48F[Csapat]#C8C8C8 " .. currentPlayerName .. ": #FFFFFF" .. table.concat({...}, " "), v, 255, 255, 255, true)
                end
            end
        else 
            local currentGamemode = getElementData(executerElement, "a.Gamemode")
            local currentPlayerName = getElementData(executerElement, "a.PlayerName")
            for k, v in ipairs(getElementsByType("player")) do
                if getElementData(v, "a.Gamemode") == currentGamemode then
                    outputChatBox("#8FC3E4[" .. exports.a_lobby:getGamemodeNameById(getElementData(executerElement, "a.Gamemode")) .. "]: #c8c8c8" .. currentPlayerName .. ": #ffffff" .. table.concat({...}, " "), v, 255, 255, 255, true)
                end
            end
            exports.a_logs:createDCLog("(teamsay) **" .. currentPlayerName .. "** - " .. table.concat({...}, " "), 3)
        end
    end
end
addCommandHandler("Teamsay", teamSay)

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end