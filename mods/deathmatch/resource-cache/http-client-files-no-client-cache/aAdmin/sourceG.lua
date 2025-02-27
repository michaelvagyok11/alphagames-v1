usageSyntax = "#D9B45A[Használat]: #FFFFFF"
errorSyntax = "#D95A5A[Hiba]: #FFFFFF"
successSyntax = "#5AB1D9[Siker]: #FFFFFF"
infoSyntax = "#B4D95A[Info]: #FFFFFF"
adminSyntax = "#8CA4FF[Admin]: #FFFFFF"

adminLevels = {
    [0] = "Player",
    [1] = "P. Moderátor",
    [2] = "Moderátor",
    [3] = "Admin",
    [4] = "FőAdmin",
    [5] = "Menedzser", 
    [6] = "Tulajdonos" 
}

adminLevelColors = {
    [0] = "#FFFFFF",
    [1] = "#dfacde",
    [2] = "#cfad80",
    [3] = "#62a7e1",
    [4] = "#89DC3C",
    [5] = "#dce188",
    [6] = "#e18c88"
}

function getAdminSyntax(level, colored)
    if colored and level then
        return tostring(adminLevelColors[level] .. " (" .. adminLevels[level] .. ")")
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
        return adminLevelColors[adminLevel]
    else
        error("Bad argument @ 'getAdminLevelColor' [Expected number at argument 1, got " .. adminLevel .. "]")
    end
end

function addAdminCommand(commandName, commandDescription, requiredLevel)
    --table.insert(adminCommands, {commandName, commandDescription, requiredLevel})
    adminCommands[commandName] = {commandDescription, requiredLevel}
end

function isPlayerHavePermission(thePlayer, commandName)
    if getElementData(thePlayer, "adminLevel") >= adminCommands[commandName][2] then
        return true
    else
        return false
    end
end
