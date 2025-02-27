local connection = exports.a_mysql:getConnection()

function giveExperience(source, target)
    if source and target then
        local isPlayerVIP = getElementData(source, "a.VIP")

        if (isPlayerVIP) then
            setElementData(source, "a.Experience", (getElementData(source, "a.Experience") or 0) + tonumber(math.random(10, 15)))
        else
            setElementData(source, "a.Experience", (getElementData(source, "a.Experience") or 0) + tonumber(math.random(5, 10)))
        end

        local clanID = getElementData(source, "a.PlayerGroup")
        if clanID and clanID > 0 then
            setElementData(source, "a.Experience", (getElementData(source, "a.Experience") or 0) + tonumber(math.random(7, 10)))
        end

        xp = getElementData(source, "a.Experience")
        lvl = getElementData(source, "a.Level") or 0
        if (lvl*100) > (xp) then
            if (lvl*100)-50 > xp then 
                level = (math.floor(round(xp, -2)/100)) + 1
            else
                level = math.floor(round(xp, -2)/100)
            end
            if level == 0 then level = 1 end
        else
            level = math.floor(round(xp, -2)/100) +1
        end
        setElementData(source, "a.Level", tonumber(level/10))

        dbExec(connection, "UPDATE accounts SET xp = '" .. xp .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
        dbExec(connection, "UPDATE accounts SET level = '" .. level/10 .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end
end
addEvent("giveExperience", true)
addEventHandler("giveExperience", getRootElement(), giveExperience)

function onChange(key, oVal, nVal)
    if key == "a.Experience" then
        xp = getElementData(source, "a.Experience")
        lvl = getElementData(source, "a.Level") or 0
        if (lvl*100) > (xp) then
            if (lvl*100)-50 > xp then 
                level = (math.floor(round(xp, -2)/100)) + 1
            else
                level = math.floor(round(xp, -2)/100)
            end
            if level == 0 then level = 1 end
        else
            level = math.floor(round(xp, -2)/100) +1
        end
        setElementData(source, "a.Level", math.floor(level/10))

        dbExec(connection, "UPDATE accounts SET xp = '" .. xp .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
        dbExec(connection, "UPDATE accounts SET level = '" .. math.floor(level/10) .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end

    --[[if key == "a.Level" and oVal > 0 and not (getElementData(source, "a.Gamemode") == nil) then
        --outputChatBox("#E48F8F[LVLUP]: #FFFFFFCongratulations, you have reached the level #9BE48F" .. nVal .. "#FFFFFF.", source, 255, 255, 255, true)
        if (nVal % 5) == 0 then
            --outputChatBox("#E48F8F[LVLUP]: #FFFFFFYou got #8FC3E4250PP#FFFFFF.", source, 255, 255, 255, true)
            --setElementData(source, "a.Premiumpont", getElementData(source, "a.Premiumpont") + 250)
        else
            --outputChatBox("#E48F8F[LVLUP]: #FFFFFFYou got #9BE48F500$#FFFFFF.", source, 255, 255, 255, true)
           -- setElementData(source, "a.Money", getElementData(source, "a.Money") + 500)
        end
    end]]--
end
addEventHandler("onElementDataChange", root, onChange)

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function round2(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end