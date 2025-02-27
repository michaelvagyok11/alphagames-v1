local connection = exports.dMysql:getConnection()
local ids = {}

setGameType("alphaGames v2.0")

function playerJoin()
	local slot = nil

	for i = 1, 400 do
		if (ids[i]==nil) then
			slot = i
			break
		end
	end

	ids[slot] = source
	setElementData(source, "d/PlayerID", slot)
end
addEventHandler("onPlayerJoin", root, playerJoin)

function playerQuit()
	local slot = getElementData(source, "d/PlayerID")

	if (slot) then
		ids[slot] = nil
	end
end
addEventHandler("onPlayerQuit", root, playerQuit)

function resourceStart()
	for key, value in ipairs(getElementsByType("player")) do
		ids[key] = value
		setElementData(value, "d/PlayerID", key)
	end
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

setTimer(function()
	local time = getRealTime()

	setTime(time.hour, time.minute)
end, 1000*60*60, 0)

local time = getRealTime()
setTime(time.hour, time.minute)
setMinuteDuration(1000*60)

function onJoin()
    local colorGreen = getColor("green", "hex")
    local colorGray = getColor("gray", "hex")

	outputChatBox(colorGreen .. "∙ JOIN: " .. colorGray .. getPlayerName(source) .. " #FFFFFFcsatlakozott a szerverre.", root, 255, 255, 255, true)
end
addEventHandler("onPlayerJoin", root, onJoin)

function onQuit(quitType, reason, responsibleElement)
    local colorRed = getColor("red", "hex")
    local colorBlue = getColor("blue", "hex")
    local colorGray = getColor("gray", "hex")

	outputChatBox(colorRed .. "∙ QUIT: " .. colorGray .. getPlayerName(source) .. " #FFFFFFlecsatlakozott a szerverről. " .. colorBlue .. "(" .. quitType .. ")", root, 255, 255, 255, true)
end
addEventHandler("onPlayerQuit", root, onQuit)

local acName = "System"
local adminElementData = "adminLevel"

local acCodes = {
    --Kikapcsolható AC kódok (disableac)
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
   
	--SD AC kódok (enablesd)
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

local disallowedACCodes = {
    [22] = "Incorrectly downloaded file",
    [11] = "Trainer / DLL Injector",
    [23] = "Incorrectly downloaded file.",
    [33] = "Use of Netlimiter or similar software.",
}

function handleOnPlayerACInfo(detectedACList, d3d9Size, d3d9MD5, d3d9SHA256)
    for _,ac in pairs(detectedACList) do
        if (getAdminCount() > 1) then
            notifyAdmins("#E48F8F[admin]: #C8C8C8" .. getPlayerName(source).." #FFFFFFtriggered anticheat. #9BE48F("..acCodes[tostring(ac)].." - "..tostring(ac)..")")
        elseif disallowedACCodes[ac] then
            kickPlayer(source,acName, disallowedACCodes[ac])
        end
    end
end
addEventHandler("onPlayerACInfo", root, handleOnPlayerACInfo)

function getACInfoOnRestart()
    for _,plr in ipairs(getElementsByType("player")) do
        resendPlayerACInfo(plr)
    end
end
addEventHandler("onResourceStart", resourceRoot, getACInfoOnRestart)

function getACInfoOnDemand(player,cmd)
    if (getElementData(player, adminElementData) and (getElementData(player, adminElementData) >= 3)) then
        for _,plr in ipairs(getElementsByType("player")) do
            resendPlayerACInfo(plr)
        end
        outputChatBox("#E48F8F[anticheat]: #FFFFFFYou have successfully retrieved the anticheat information again.",player,0,255,0,true)
    end
end
addCommandHandler("anticheat", getACInfoOnDemand)

function notifyAdmins(message)
    local players = getElementsByType("player")
    for k, player in ipairs(players) do
        if (getElementData(player, adminElementData) and (getElementData(player, adminElementData) >= 3)) then
            outputChatBox(tostring(message), player, 255, 255, 255, true)
        end
    end
end

function getAdminCount()
    local admincount = 0
    local players = getElementsByType("player")
    for k, player in ipairs(players) do
        if (getElementData(player, adminElementData) and (getElementData(player, adminElementData) >= 3)) then
            admincount = admincount + 1
        end
    end
    return admincount
end

function onDataChange(key, oValue, nValue)
    if key == "a.Money" then
        if nValue < 0 then
            nValue = 0
            setElementData(source, "a.Money", nValue)
        end
        
        dbExec(connection, "UPDATE accounts SET money = '" .. nValue .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end
end
addEventHandler("onElementDataChange", root, onDataChange)

local developerSerials = {
    ["53987DDB582C0AC8B9CCD506656ACD13"] = true, -- dzseki
    ["7D452DDE356827F83087CC96273BFC71"] = true, -- toni
    ["CD7416B6E424CF8FBB1D20C9ADE8B702"] = true, -- george
    ["2A4DA2DCA79AFF12BB2F0970274D4603"] = true, -- akos(miliomos)
    ["8A0BC075A35352D27E0D959CE91809A4"] = true,
}

local developerCommands = {
    ["restart"] = true,
    ["start"] = true,
    ["stop"] = true,
    ["debugscript"] = true,
    ["refresh"] = true,
    ["refreshall"] = true,
    ["reloadacl"] = true,
    ["run"] = true,
    ["srun"] = true,
    ["crun"] = true,
    ["shutdown"] = true,
    ["stopall"] = true,
    ["aexec"] = true,
    ["whois"] = true,
    ["restartall"] = true,
}

local commandTimer = {}

function onCommand(command)
    if command then
        if developerCommands[command] then
            if not developerSerials[getPlayerSerial(source)] then
                outputChatBox("#E48F8F[Hiba]: #FFFFFFNincs jogod a parancs használatához.", source, 255, 255, 255, true)
                cancelEvent()
            end
        end
        if isTimer(commandTimer[source]) then
            --outputChatBox("#E48F8F[Hiba]: #FFFFFFYou can't use commands that fast.", source, 255, 255, 255, true)
            cancelEvent()
        else
            commandTimer[source] = setTimer(function() end, 300, 1)
        end
    end
end
addEventHandler("onPlayerCommand", root, onCommand)

function fixCameraBug(p)
    setCameraTarget(p, p)
end
addCommandHandler("fixcambug", fixCameraBug)

function getPlayerPosition(sourcePlayer)
    if (sourcePlayer) and isElement(sourcePlayer) then
        local x, y, z = getElementPosition(sourcePlayer)
        local rotX, rotY, rotZ = getElementRotation(sourcePlayer)
        local dim, int = getElementDimension(sourcePlayer), getElementInterior(sourcePlayer)
        outputChatBox("#9BE48F[POSITION]: #FFFFFF" .. x .. ", " .. y .. ", " .. z, sourcePlayer, 255, 255, 255, true)
        outputChatBox("#9BE48F[ROTATION]: #FFFFFF" .. rotX .. ", " .. rotY .. ", " .. rotZ, sourcePlayer, 255, 255, 255, true)
        outputChatBox("#9BE48F[INT, DIM]: #FFFFFFInterior: " .. int .. ", Dimension: " .. dim, sourcePlayer, 255, 255, 255, true)
        triggerClientEvent("setClipBoardPosition", sourcePlayer, sourcePlayer, {x, y, z})
    end
end
addCommandHandler("getpos", getPlayerPosition)

setTimer(function()
    for i, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "loggedIn") and not getElementData(v, "afk") then
            local playedMinutes = getElementData(v, "a.PlayedMinutes") or 0
            setElementData(v, "a.PlayedMinutes", playedMinutes + 1)
            dbExec(connection, "UPDATE accounts SET playedMinutes = ? WHERE id = ?", getElementData(v, "a.PlayedMinutes"), getElementData(v, "a.accID"))
        end
    end
end, 1000*60, 0)

local notAllowedCommandsTable = {["misi"] = true, ["tonifly"] = true, ["toniwater"] = true}
function notAllowedCommands(cmd)
    if notAllowedCommandsTable[cmd] then
        kickPlayer(source, "Anticheat", "CODE: AG-#62")
    end
end
addEventHandler("onPlayerCommand", root, notAllowedCommands)