usageSyntax = "#D9B45A► Használat: #FFFFFF"
errorSyntax = "#E48F8F► Hiba: #FFFFFF"
successSyntax = "#B4D95A► Siker: #FFFFFF"
infoSyntax = "#5AB1D9► Info: #FFFFFF"
adminSyntax = "#F1919E►  Admin: #FFFFFF"

adminLevels = {
    [0] = "Játékos",
    [1] = "Admin 1",
    [2] = "Admin 2",
    [3] = "Admin 3",
    [4] = "Admin 4",
    [5] = "Admin 5",
    [6] = "FőAdmin",
    [7] = "SzuperAdmin",
    [8] = "Menedzser", 
    [9] = "Tulajdonos"
}

adminLevelColors = {
    [0] = "#FFFFFF",
    [1] = "#62a7e1",
    [2] = "#62a7e1",
    [3] = "#62a7e1",
    [4] = "#62a7e1",
    [5] = "#62a7e1",
    [6] = "#89DC3C",
    [7] = "#E03D42",
    [8] = "#dce188",
    [9] = "#e18c88"
}

function getAdminSyntax(level, colored)
    if colored and level then
        return tostring(adminLevelColors[level] .. " [" .. adminLevels[level] .. "]")
    end
end

adminCommands = {}

function outputAdminMessage(message)
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "adminLevel") >= 1 then
            outputChatBox(adminSyntax .. message, v, 255, 255, 255, true)
        end
    end
end

function getAdminLevelColor(adminLevel)
    if tonumber(adminLevel) then
        return adminLevelColors[adminLevel] .. ""
    else
        error("Bad argument @ 'getAdminLevelColor' [Expected number at argument 1, got " .. adminLevel .. "]")
    end
end

function addAdminCommand(commandName, commandDescription, requiredLevel)
    adminCommands[commandName] = {commandDescription, requiredLevel}
end

function isPlayerHavePermission(thePlayer, commandName)
    if getElementData(thePlayer, "adminLevel") >= adminCommands[commandName][2] then
        return true
    else
        return false
    end
end
