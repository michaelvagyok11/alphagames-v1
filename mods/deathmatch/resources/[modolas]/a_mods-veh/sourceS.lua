local lockKey = "a!e5I$@92GtCEpFG"

function lockVehicle(path)
    local ivFile = false
    if fileExists("server/iv/" .. path) then
        ivFile = fileOpen("server/iv/" .. path)
    else
        ivFile = fileCreate("server/iv/" .. path)
    end

    if ivFile then
        if fileExists("server/models/" .. path .. ".dff") then
            local unlockedDFF = fileOpen("server/models/" .. path .. ".dff")
            if unlockedDFF then
                local encodedDFF, iv = encodeString("aes128", fileRead(unlockedDFF, fileGetSize(unlockedDFF)), {key = lockKey})

                local ivTable = fileRead(ivFile, fileGetSize(ivFile))
                fileWrite(ivFile, iv)

                local encodedFile = fileCreate("mods/" .. path .. ".alphaGames")
                fileWrite(encodedFile, encodedDFF)

                fileClose(encodedFile)
                fileClose(unlockedDFF)
                fileClose(ivFile)
                return "success"
            end
        end
        fileClose(ivFile)
        return "no_unlockedDFF"
    end
    return "error"
end

addCommandHandler("lockveh",
    function(sourcePlayer, commandName, ...)
        if getElementData(sourcePlayer, "adminLevel") >= 6 then
            local args = {...}
            if #args >= 1 then
                for k, v in pairs(args) do
                    local lockedVehicle = lockVehicle(v)
                    if lockedVehicle == "success" then
                        outputChatBox("#B4D95A[alphagames]: #ffffffSikeresen levédted: #5AB1D9" .. v .. "#ffffff!", sourcePlayer, 215, 89, 69, true)
                    elseif lockedVehicle == "error" then
                        outputChatBox("[alphagames]: #ffffffHiba, nem sikerült levédeni: #5AB1D9" .. v .. "#ffffff!", sourcePlayer, 215, 89, 69, true)
                    elseif lockedVehicle == "no_unlockedDFF" then
                        outputChatBox("[alphagames]: #ffffffHiba, nincs ilyen fájl: #5AB1D9" .. v .. "#ffffff!", sourcePlayer, 215, 89, 69, true)
                    end
                end
            end
        end
    end
)

addEvent("requestKeys", true)
addEventHandler("requestKeys", resourceRoot,
    function()
        local ivKeys = {}
        for k, v in pairs(availableModels) do
            local ivFile = fileOpen("server/iv/" .. v.path)
            ivKeys[v.path] = fileRead(ivFile, fileGetSize(ivFile))
            fileClose(ivFile)
        end
        triggerClientEvent(client, "requestKeys", resourceRoot, {iv = ivKeys, key = lockKey})
    end
)

--[[addCommandHandler("replacevehmodel",
    function(sourcePlayer, commandName, customId)
        if getElementData(sourcePlayer, "adminLevel") >= 6 then
            if customId then
                local veh = getPedOccupiedVehicle(sourcePlayer)
                customId = string.lower(customId)

                if isElement(veh) then
                    if availableModels[customId] or customId == "0" then
                        setElementData(veh, "vehicle.customId", customId)
                        setElementData(veh, "appliedHandling", false)
                        outputChatBox("#2682c9[NorthMTA]: #ffffffAz autó modelljét sikeresen megváltoztattad!", sourcePlayer, 215, 89, 69, true)
                    else
                        outputChatBox("[NorthMTA]: #ffffffNem létezik ilyen modell!", sourcePlayer, 215, 89, 69, true)
                    end
                else
                    outputChatBox("[NorthMTA]: #ffffffNem ülsz autóban!", sourcePlayer, 215, 89, 69, true)
                end
            else
                outputChatBox("[Használat]: #ffffff/" .. commandName .. " [CustomID (/infinitevehiclelist, 0 = levétel)]", sourcePlayer, 215, 89, 69, true)
            end
        end
    end
)]]