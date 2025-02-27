--**---------------------------- ANTICHEAT ----------------------------**--

local anticheatCodes = {
    ["1"] = "Classic health/armour hack",
    ["2"] = "Corrupted dll files",
    ["4"] = "Presence of Trainer",
    ["5"] = "Use of Trainer",
    ["6"] = "Use of Trainer (player movement, health/damage, weapons, money, gamespeed, game cheats, aimbot)",
    ["7"] = "Use of Trainer (2)",
    ["8"] = "Unauthorized mods",
    ["11"] = "Trainer / DLL Injector",
    ["13"] = "Data files issue",
    ["17"] = "Speed / Wallhack",
    ["18"] = "Modified game files",
    ["21"] = "Trainer / Custom gta_sa.exe",
    ["26"] = "AntiCheat component blocked",
   
    ["12"] = "Custom D3D9.DLL (ENB, Other graphics mods)",
    ["14"] = "Virtual machine",
    ["15"] = "Disabled driver signing (Windows Insider or some cheats for other games)",
    ["16"] = "Disabled AntiCheat components (Wants to cheat, or has a virus)",
    ["20"] = "Non-standard gta3.img or gta_int.img",
    ["22"] = "Corrupted LUA file download",
    ["23"] = "Corrupted non-LUA file download",
    ["28"] = "Linux Wine user",
    ["31"] = "Injected keyboard inputs (Macro, On-screen keyboard, AHK)",
    ["32"] = "Injected mouse inputs (Macro, AHK, or ambigious aim hacks)",
    ["33"] = "Netlimiter or similar software",
    ["34"] = "Internet café user",
    ["35"] = "FPS Locking software",
    ["36"] = "AutoHotKey user",
}

local kickACCodes = {
    [1] = "Classic health/armour hack",
    [2] = "Corrupted dll files",
    [4] = "Presence of Trainer",
    [11] = "Trainer / DLL Injector",
    [16] = "Disabled AntiCheat components",
    [20] = "Non-standard gta3.img or gta_int.img",
    [22] = "Incorrectly downloaded file",
    [23] = "Incorrectly downloaded file",
    [26] = "Disabled AntiCheat components",
    [33] = "Use of Netlimiter or similar software.",
}

function onAnticheatInformation(detectedACList, d3d9Size, d3d9MD5, d3d9SHA256)
    for _, anticheatCode in pairs(detectedACList) do
        if kickACCodes[anticheatCode] then
            for k, v in ipairs(getElementsByType("player")) do
              if (getElementData(v, "adminLevel")) and getElementData(v, "adminLevel") >= 3 then
                outputChatBox("#E48F8F[ANTICHEAT]: #FFFFFFThe system kicked #8FC3E4" .. getPlayerName(source) .. " #FFFFFFfor triggering the anticheat. #8FC3E4(" .. tostring(kickACCodes[anticheatCode]) .. ")", v, 255, 255, 255, true)
              end
            end
            kickPlayer(source, "System", kickACCodes[anticheatCode])
        end
    end
end
addEventHandler("onPlayerACInfo", root, onAnticheatInformation)

function onStart()
    for k, v in ipairs(getElementsByType("player")) do
        resendPlayerACInfo(v)
    end
end
addEventHandler("onResourceStart", resourceRoot, onStart)

-- ** ---------------------------- ELEMENTDATA CHECK ---------------------------- ** --
--[[
local triggerableValues = {
    ["a.Money"] = true,
    ["a.Premiumpont"] = true,
    ["a.Experience"] = true,
    ["a.Kills"] = true,
    ["a.Deaths"] = true,
}

local valueToTrigger = {
    ["a.Money"] = 10000,
    ["a.Premiumpont"] = 1000,
    ["a.Experience"] = 1500,
    ["a.Kills"] = 10,
    ["a.Deaths"] = 10,
}

local dataToGiveBack = {}

function onDataChange(key, oVal, nVal)
    if triggerableValues[key] then
        if tonumber(nVal - oVal) > tonumber(valueToTrigger[key]) then
            exports.a_logs:createDCLog(key .. " - from **" .. oVal .. "** to **" .. nVal .. "**. (Name: **" .. getPlayerName(source) .. "** | accID: **" .. getElementData(source, "a.accID") .. "** | Serial: **" .. getPlayerSerial(source) .. "** | IP: **" .. getPlayerIP(source) .. "**)", 7)
            table.insert(dataToGiveBack, {source, key, oVal})
        end
    end
end
addEventHandler("onElementDataChange", root, onDataChange)

function giveBackData()
    for key, value in ipairs(dataToGiveBack) do
        setElementData(dataToGiveBack[key][1], dataToGiveBack[key][2], dataToGiveBack[key][3])
        table.remove(dataToGiveBack, key)
    end
end

setTimer(giveBackData, 1000, 0)

-- ** ---------------------------- COMMAND ENABLE ---------------------------- ** --

function onCommand(cmd)
    if not (enabledCommands[cmd]) then
        exports.a_logs:createDCLog("Executed unknown command: **/" .. cmd .. "** - (Name: **" .. getPlayerName(source) .. "** | accID: **" .. getElementData(source, "a.accID") .. "** | Serial: **" .. getPlayerSerial(source) .. "** | IP: **" .. getPlayerIP(source) .. "**)", 8)
    end
end
addEventHandler("onPlayerCommand", root, onCommand)]]--