-- ** ---------------------------- COMMAND ENABLE ---------------------------- ** --

function onCommand(cmd)
    if not (enabledCommands[cmd]) then
        cancelEvent()
        return
        exports.a_logs:createDCLog("Executed unknown command: **/" .. cmd .. "** - (Name: **" .. getPlayerName(source) .. "** | accID: **" .. getElementData(source, "a.accID") .. "** | Serial: **" .. getPlayerSerial(source) .. "** | IP: **" .. getPlayerIP(source) .. "**)", 11)
    end
end
addEventHandler("onPlayerCommand", root, onCommand)

local susAmount = 250000;

function onChange(key, oVal, nVal)
    if key == "a.Money" then
        if (nVal - oVal) > susAmount then
            setElementData(source, "a.Money", oVal)
            outputChatBox("nem sikerult pajti", source, 255, 255, 255, true)
            exports.a_logs:createDCLog("Nagy pénzmozgás történt. DIFFERENCE: " .. (nVal - oVal) .. "$ (@everyone) - (Name: **" .. getPlayerName(source) .. "** | accID: **" .. getElementData(source, "a.accID") .. "** | Serial: **" .. getPlayerSerial(source) .. "** | IP: **" .. getPlayerIP(source) .. "**)", 11)
            cancelEvent()
        end
    end

    if key == "a.Premiumpont" then
        if (nVal - oVal) > 5000 then
            setElementData(source, "a.Premiumpont", oVal)
            outputChatBox("nem sikerult pajti", source, 255, 255, 255, true)
            exports.a_logs:createDCLog("Nagy PP mozgás történt. DIFFERENCE: " .. (nVal - oVal) .. "PP (@everyone) - (Name: **" .. getPlayerName(source) .. "** | accID: **" .. getElementData(source, "a.accID") .. "** | Serial: **" .. getPlayerSerial(source) .. "** | IP: **" .. getPlayerIP(source) .. "**)", 11)
            cancelEvent()
        end
    end

    if key == "a.Experience" then
        if (nVal - oVal) > 5000 then
            setElementData(source, "a.Experience", oVal)
            outputChatBox("nem sikerult pajti", source, 255, 255, 255, true)
            exports.a_logs:createDCLog("Nagy XP mozgás történt. DIFFERENCE: " .. (nVal - oVal) .. "XP (@everyone) - (Name: **" .. getPlayerName(source) .. "** | accID: **" .. getElementData(source, "a.accID") .. "** | Serial: **" .. getPlayerSerial(source) .. "** | IP: **" .. getPlayerIP(source) .. "**)", 11)
            cancelEvent()
        end
    end
end
addEventHandler("onElementDataChange", root, onChange)