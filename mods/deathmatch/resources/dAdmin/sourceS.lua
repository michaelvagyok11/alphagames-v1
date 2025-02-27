local connection = exports.dMysql:getConnection()

function setPlayerAdminLevel(thePlayer, adminLevel)
    if isElement(thePlayer) and tonumber(adminLevel) then
        setElementData(thePlayer, "adminLevel", tonumber(adminLevel))
        dbExec(connection, "UPDATE accounts SET alevel = ? WHERE serial = ?", tonumber(adminLevel), getPlayerSerial(thePlayer))
    end
end

function setPlayerAdminNick(thePlayer, adminNick)
    if isElement(thePlayer) and tostring(adminNick) then
        setElementData(thePlayer, "adminNick", tostring(adminNick))
        dbExec(connection, "UPDATE accounts SET anick = ? WHERE serial = ?", tostring(adminNick), getPlayerSerial(thePlayer))
    end
end

function setPlayerSkin(thePlayer, modelID)
    if isElement(thePlayer) and tonumber(modelID) then
        setElementModel(thePlayer, tonumber(modelID))
        setElementData(thePlayer, "a.Skin", tonumber(modelID))
        dbExec(connection, "UPDATE accounts SET skin = ? WHERE serial = ?", tonumber(modelID), getPlayerSerial(thePlayer))
    end
end

function setPlayerMoney(thePlayer, moneyAmount)
    if isElement(thePlayer) and tonumber(moneyAmount) then
        setElementData(thePlayer, "a.Money", tonumber(moneyAmount))
        --dbExec(connection, "UPDATE accounts SET money = ? WHERE serial = ?", tonumber(moneyAmmount), getPlayerSerial(thePlayer))
    end
end

function setPlayerPP(thePlayer, ppAmount)
    if isElement(thePlayer) and tonumber(ppAmount) then
        setElementData(thePlayer, "a.Premiumpont", tonumber(ppAmount))
        dbExec(connection, "UPDATE accounts SET pp = ? WHERE serial = ?", tonumber(ppAmount), getPlayerSerial(thePlayer))
    end
end

-- ** Adminisztrátori jogosultság, név állítására alkalmas parancsok.

addAdminCommand("setadminlevel", "Adminisztrátori szint állítása.", 3)
addCommandHandler("setadminlevel", 
    function(sourcePlayer, commandName, targetPlayer, adminLevel)
        if isPlayerHavePermission(sourcePlayer, commandName) or exports.dCore:isPlayerDeveloper(getPlayerSerial(sourcePlayer)) then
            if not (targetPlayer and adminLevel) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Szint]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerAdminLevel(targetPlayer, adminLevel)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFadminisztrátori szintjét. Új szint: #8FC3E4" .. adminLevel .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta adminisztrátori szinted. Új szint: #8FC3E4" .. adminLevel .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFadminisztrátori szintjét. Új szint: #8FC3E4" .. adminLevel .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setadminnick", "Adminisztrátori becenév állítása.", 3)
addCommandHandler("setadminnick", 
    function(sourcePlayer, commandName, targetPlayer, adminNick)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and adminNick) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Név]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerAdminNick(targetPlayer, adminNick)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFadminisztrátori nevét. Új név: #8FC3E4" .. adminNick .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta adminisztrátori neved. Új név: #8FC3E4" .. adminNick .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFadminisztrátori nevét. Új név: #8FC3E4" .. adminNick .. "#FFFFFF.")
                end
            end
        end
    end
)

-- ** Alap parancsok.

addAdminCommand("goto", "Teleportálás egy játékoshoz.", 2)
addCommandHandler("goto", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    local x, y, z = getElementPosition(targetPlayer)
                    local rx, ry, rz = getElementRotation(targetPlayer)
                    local dim, int = getElementDimension(targetPlayer), getElementInterior(targetPlayer)

                    setElementPosition(sourcePlayer, math.floor(x), math.floor(y), z, true)
                    setElementRotation(sourcePlayer, rx, ry, rz)
                    setElementDimension(sourcePlayer, dim)
                    setElementInterior(sourcePlayer, int)

                    outputChatBox(successSyntax .. "Sikeresen hozzá teleportáltál #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékoshoz.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFhozzád teleportált.", targetPlayer, 255, 255, 255, true)
                end
            end
        end
    end
)

addAdminCommand("gethere", "Egy játékos magadhoz teleportálása.", 2)
addCommandHandler("gethere", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    local x, y, z = getElementPosition(sourcePlayer)
                    local rx, ry, rz = getElementRotation(sourcePlayer)
                    local dim, int = getElementDimension(sourcePlayer), getElementInterior(sourcePlayer)

                    setElementPosition(targetPlayer, math.floor(x), math.floor(y), z, true)
                    setElementRotation(targetPlayer, rx, ry, rz)
                    setElementDimension(targetPlayer, dim)
                    setElementInterior(targetPlayer, int)

                    outputChatBox(successSyntax .. "Sikeresen magadhoz teleportáltad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékost.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmagához teleportált.", targetPlayer, 255, 255, 255, true)
                end
            end
        end
    end
)

addAdminCommand("freeze", "Egy játékos lefagyasztása.", 2)
addCommandHandler("freeze", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setElementFrozen(targetPlayer, true)
                    toggleAllControls(targetPlayer, false, false, true)

                    outputChatBox(successSyntax .. "Sikeresen lefagyasztottad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékost.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFlefagyasztott téged.", targetPlayer, 255, 255, 255, true)
                end
            end
        end
    end
)

addAdminCommand("unfreeze", "Egy játékos lefagyasztásának feloldása.", 2)
addCommandHandler("unfreeze", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setElementFrozen(targetPlayer, false)
                    toggleAllControls(targetPlayer, true, true, true)

                    outputChatBox(successSyntax .. "Sikeresen feloldottad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékos lefagyasztását.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFfeloldotta a lefagyasztásod.", targetPlayer, 255, 255, 255, true)
                end
            end
        end
    end
)

addAdminCommand("vanish", "Magad láthatatlanná tétele.", 2)
addCommandHandler("vanish",
    function(sourcePlayer, commandName)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            local invisible = getElementData(sourcePlayer, "invisible")

            if invisible then
                setElementAlpha(sourcePlayer, 255)
            else
                setElementAlpha(sourcePlayer, 0)
            end

            setElementData(sourcePlayer, "invisible", not invisible)
        end
    end
)

addAdminCommand("sethp", "Egy játékos életerejének beállítása.", 2)
addCommandHandler("sethp", 
    function(sourcePlayer, commandName, targetPlayer, healthLevel)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and healthLevel) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Szint]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setElementHealth(targetPlayer, healthLevel)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFéleterejét. Új szint: #8FC3E4" .. healthLevel .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta életerőd. Új szint: #8FC3E4" .. healthLevel .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFéleterejét. Új szint: #8FC3E4" .. healthLevel .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setarmor", "Egy játékos páncéljának beállítása.", 2)
addCommandHandler("setarmor", 
    function(sourcePlayer, commandName, targetPlayer, armorLevel)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and armorLevel) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Szint]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPedArmor(targetPlayer, armorLevel)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFpáncélját. Új szint: #8FC3E4" .. armorLevel .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta páncélod. Új szint: #8FC3E4" .. armorLevel .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFpáncélját. Új szint: #8FC3E4" .. armorLevel .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setskin", "Egy játékos kinézetének beállítása.", 2)
addCommandHandler("setskin", 
    function(sourcePlayer, commandName, targetPlayer, skinID)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and skinID) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerSkin(targetPlayer, skinID)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFkinézetét. Új skin: #8FC3E4" .. skinID .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta kinézeted. Új skin: #8FC3E4" .. skinID .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFkinézetét. Új skin: #8FC3E4" .. skinID .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setmoney", "Egy játékos pénzének beállítása.", 2)
addCommandHandler("setmoney", 
    function(sourcePlayer, commandName, targetPlayer, moneyAmount)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and moneyAmount) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [$]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerMoney(targetPlayer, moneyAmount)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFpénzét. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta pénzed. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFpénzét. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setpp", "Egy játékos pénzének beállítása.", 2)
addCommandHandler("setpp", 
    function(sourcePlayer, commandName, targetPlayer, moneyAmount)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and moneyAmount) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [PP]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerPP(targetPlayer, moneyAmount)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFprémiumpont egyenlegét. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta prémiumpont egyenleged. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFprémiumpont egyenlegét. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.")
                end
            end
        end
    end
)

-- ** Járművekkel kapcsolatos parancsok.

addAdminCommand("makeveh", "Egy ideiglenes jármű létrehozása", 3)
addCommandHandler("makeveh", 
    function(sourcePlayer, commandName, vehicleID)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (vehicleID) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Jármű ID]", sourcePlayer, 255, 255, 255, true)
            else
                local x, y, z = getElementPosition(sourcePlayer)
                local rx, ry, rz = getElementRotation(sourcePlayer)
                local dim, int = getElementDimension(sourcePlayer), getElementInterior(sourcePlayer)

                local vehicle = exports.dVehicles:makeVehicle(sourcePlayer, tonumber(vehicleID))

                setElementDimension(vehicle, dim)
                setElementInterior(vehicle, int)

                warpPedIntoVehicle(sourcePlayer, vehicle)

                outputChatBox(successSyntax .. "Sikeresen létrehoztál egy ideiglenes járművet. ID: #8FC3E4" .. vehicleID .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFlétrehozott egy ideiglenes járművet. Típus: #8FC3E4" .. vehicleID .. "#FFFFFF.")
            end
        end
    end
)

addAdminCommand("fixveh", "Egy játékos járművének megjavítása.", 2)
addCommandHandler("fixveh", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.dCore:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    if isPedInVehicle(targetPlayer) then
                        fixVehicle(getPedOccupiedVehicle(targetPlayer))

                        outputChatBox(successSyntax .. "Sikeresen megjavítottad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjárművét.", sourcePlayer, 255, 255, 255, true)
                        outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegjavította járműved.", targetPlayer, 255, 255, 255, true)
                        outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegjavította #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjárművét.")
                    else
                        outputChatBox(errorSyntax .. "A kiválasztott játékos nem ül járműben.", sourcePlayer, 255, 255, 255, true)
                    end
                end
            end
        end
    end
)

addAdminCommand("gotoveh", "Adott járműhöz való teleportálás", 2)
addCommandHandler("gotoveh", 
    function(sourcePlayer, commandName, targetVehicleID)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetVehicleID) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Kocsi ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetVehicleID = tonumber(targetVehicleID)

                if targetVehicleID then
                    for i, v in ipairs(getElementsByType("vehicle")) do
                        if getElementData(v, "a.VehID") == targetVehicleID then
                            local x, y, z = getElementPosition(v)
                            setElementPosition(sourcePlayer, x + 2, y + 2, z)
                            setElementInterior(sourcePlayer, getElementInterior(v))
                            setElementDimension(sourcePlayer, getElementDimension(v))
                            outputChatBox("#72ABCCalphav2 ► Jármű: #FFFFFFSikeresen odateleportáltál a járműhöz. #F1C176(ID: " .. targetVehicleID .. ")", sourcePlayer, 255, 255, 255, true)
                        end
                    end
                end
            end
        end
    end
)

addAdminCommand("getveh", "Adott jármű hozzádteleportálása", 2)
addCommandHandler("getveh", 
    function(sourcePlayer, commandName, targetVehicleID)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetVehicleID) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Kocsi ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetVehicleID = tonumber(targetVehicleID)

                if targetVehicleID then
                    for i, v in ipairs(getElementsByType("vehicle")) do
                        if getElementData(v, "a.VehID") == targetVehicleID then
                            local x, y, z = getElementPosition(sourcePlayer)
                            setElementPosition(v, x + 2, y + 2, z)
                            setElementInterior(v, getElementInterior(sourcePlayer))
                            setElementDimension(v, getElementDimension(sourcePlayer))
                            outputChatBox("#72ABCCalphav2 ► Jármű: #FFFFFFSikeresen magadhoz teleportáltad a járművet. #F1C176(ID: " .. targetVehicleID .. ")", sourcePlayer, 255, 255, 255, true)
                        end
                    end
                end
            end
        end
    end
)

addAdminCommand("delveh", "Adott jármű kitörlése", 2)
addCommandHandler("delveh", 
    function(sourcePlayer, commandName, targetVehicleID)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetVehicleID) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Kocsi ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetVehicleID = tonumber(targetVehicleID)

                if targetVehicleID then
                    for i, v in ipairs(getElementsByType("vehicle")) do
                        if getElementData(v, "a.VehID") == targetVehicleID then
                            local vehOwner = getElementData(v, "a.Owner")
                            outputChatBox("#72ABCCalphav2 ► Jármű: #9BE48F" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFkitörölte az ideiglenes járművedet. #F1C176(ID: " .. targetVehicleID .. ")", vehOwner, 255, 255, 255, true)
                            destroyElement(v)
                            outputChatBox("#72ABCCalphav2 ► Jármű: #FFFFFFSikeresen kitörölted a járművet. #F1C176(ID: " .. targetVehicleID .. ")", sourcePlayer, 255, 255, 255, true)
                        end
                    end
                end
            end
        end
    end
)

addAdminCommand("nearbyvehicles", "Közelben lévő járművek.", 2)
addCommandHandler("nearbyvehicles", 
    function(sourcePlayer, commandName)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            local pX, pY, pZ = getElementPosition(sourcePlayer)
            outputChatBox("#72ABCCalphav2 ► Jármű: #FFFFFFKözelben lévő járművek:", sourcePlayer, 255, 255, 255, true)
            for i, v in ipairs(getElementsByType("vehicle")) do
                if getElementData(v, "a.TempVehicle") then
                    local x, y, z = getElementPosition(v)
                    if getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ) < 10 then
                        local vehOwner = getElementData(v, "a.Owner")
                        local vehOwnerName = getElementData(vehOwner, "a.PlayerName")
                        local vehOwnerID = getElementData(vehOwner, "d/PlayerID")
                        outputChatBox("#F1C176[ID: " .. getElementData(v, "a.VehID") .. "] #FFFFFF- #9BE48FModel: #FFFFFF" .. getElementModel(v) .. " (" .. getVehicleNameFromModel(getElementModel(v)).. ") - #9BE48FTulajdonos: #FFFFFF" .. vehOwnerName .. " (" .. vehOwnerID .. ")", sourcePlayer, 255, 255, 255, true)
                    end
                end
            end
        end
    end
)

addAdminCommand("setvehcolor", "Adott jármű festése", 2)
addCommandHandler("setvehcolor", 
    function(sourcePlayer, commandName, r1, g1, b1, r2, g2, b2)
        local vehicle = getPedOccupiedVehicle(sourcePlayer)

        if not vehicle then
            return
        end

        -- Ellenőrizd, hogy mind a 6 színérték meg lett-e adva
        if not (r1 and g1 and b1 and r2 and g2 and b2) then
            return
        end

        -- Konvertáljuk a szöveges bemenetet számokká
        r1, g1, b1, r2, g2, b2 = tonumber(r1), tonumber(g1), tonumber(b1), tonumber(r2), tonumber(g2), tonumber(b2)

        -- Ellenőrizd, hogy az értékek érvényesek-e (0-255 között)
        if not (r1 and g1 and b1 and r2 and g2 and b2) or 
           r1 < 0 or r1 > 255 or g1 < 0 or g1 > 255 or b1 < 0 or b1 > 255 or
           r2 < 0 or r2 > 255 or g2 < 0 or g2 > 255 or b2 < 0 or b2 > 255 then
            --outputChatBox("Minden színértéknek 0 és 255 között kell lennie!", player, 255, 0, 0)
            return
        end

        -- Állítsuk be a jármű színét
        setVehicleColor(vehicle, r1, g1, b1, r2, g2, b2)
        --outputChatBox("A jármű színe sikeresen megváltozott!", player, 0, 255, 0)
    end
)

-- ** DEV FUNCTIONS

function onResStart(resourceElement)
    for _, v in ipairs(getElementsByType("player")) do
        if exports.dCore:isPlayerDeveloper(getPlayerSerial(v)) then
            local resName = getResourceName(resourceElement)
            outputChatBox("#9BE48Falphav2 ► DEV: #FFFFFFElindult egy resource. #9BE48F(" .. resName .. ")", v, 255, 255, 255, true)
        end
    end
end
addEventHandler("onResourceStart", root, onResStart)

function onResStop(resourceElement, wasDeleted)
    for _, v in ipairs(getElementsByType("player")) do
        if exports.dCore:isPlayerDeveloper(getPlayerSerial(v)) then
            local resName = getResourceName(resourceElement)
            outputChatBox("#E48F8Falphav2 ► DEV: #FFFFFFLeállt egy resource. #E48F8F(" .. resName .. ")", v, 255, 255, 255, true)
            if wasDeleted then
                outputChatBox("#F1C176alphav2 ► ALERT: #FFFFFFA #F1C176" .. resName .. " #FFFFFFresource törölve/módosítva lett.", v, 255, 255, 255, true)
            end
        end
    end
end
addEventHandler("onResourceStop", root, onResStop)

function privateMessageToPlayer(executerElement, commandName, targetElement, ...)
	if isElement(executerElement) then
		if (...) then
			local targetPlayer = exports.dCore:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local text = table.concat({...}, " ")

				outputChatBox("#EBAD5C[PM-Tőle: #FFFFFF" .. getElementData(executerElement, "a.PlayerName") .. "(" .. getElementData(executerElement, "d/PlayerID") .. ")" .. "#EBAD5C]: #EBAD5C" .. text, targetPlayer, 255, 255, 255, true)
				outputChatBox("#D5EE9F[PM-Neki: #FFFFFF" .. getElementData(targetPlayer, "a.PlayerName") .. "(" .. getElementData(targetPlayer, "d/PlayerID") .. ")" .. "#D5EE9F]: #D5EE9F" .. text, executerElement, 255, 255, 255, true)
				--exports.a_logs:createDCLog(getPlayerName(executerElement) .. " -> " .. targetPlayerName .. ": " .. text, 4)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Szöveg]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("pm", privateMessageToPlayer, false, false)

function adminChat(executerElement, commandName, ...)
	if getElementData(executerElement, "adminLevel") >= 1 then
		if (...) then
			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "loggedIn") then
					if getElementData(v, "adminLevel") >= 1 then
						local executerAdminName = getElementData(executerElement, "a.PlayerName")
						local executerAdminLevel = getElementData(executerElement, "adminLevel")
                        local executerAdminSyntax = exports.dAdmin:getAdminSyntax(executerAdminLevel, true)

						outputChatBox("#E48F8F[ADMINCHAT]:" .. executerAdminSyntax .. " - " .. executerAdminName .. ": #FFFFFF" .. table.concat({...}, " "), v, 255, 255, 255, true)
					end
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Üzenet]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("a", adminChat, false, false)
addCommandHandler("ac", adminChat, false, false)

function kickElement(executerElement, commandName, targetElement, ...)
	if getElementData(executerElement, "adminLevel") >= 2 or exports.dCore:isPlayerDeveloper(getPlayerSerial(executerElement)) then
		if targetElement and (...) then
			local targetPlayer = exports.dCore:findPlayer(executerElement, targetElement)
			local reason = table.concat({...}, " ")
			if targetPlayer and reason then
				if exports.dCore:isPlayerDeveloper(getPlayerSerial(targetPlayer)) then
					return
				end

				local targetAdminLevel = getElementData(targetPlayer, "adminLevel")
				local playerAdminLevel = getElementData(executerElement, "adminLevel")
                local executerAdminSyntax = exports.dAdmin:getAdminSyntax(playerAdminLevel, true)
				if (targetAdminLevel > playerAdminLevel and playerAdminLevel < 3) and not exports.dCore:isPlayerDeveloper(getPlayerSerial(executerElement)) then
					outputChatBox(errorSyntax.."A kickelni kívánt játékosnak nagyobb az adminszintje mint a tiéd, így nem tudod kickelni.", executerElement, 255, 255, 255, true)
					return
				end
				outputChatBox("#F1DB76alphav2 ► Kirúgás:#E48F8F".. executerAdminSyntax .. " - " .. getElementData(executerElement, "a.PlayerName") .. "#FFFFFF kirúgta #E48F8F" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékost. #E48F8F(Indoklás: " .. table.concat({...}, " ") .. ")", root, 255, 255, 255, true)
				kickPlayer(targetPlayer, executerElement, table.concat({...}, " "))
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Indoklás]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("kick", kickElement)

function banElement(executerElement, commandName, targetElement, time, ...)
	if getElementData(executerElement, "adminLevel") >= 2 or exports.dCore:isPlayerDeveloper(getPlayerSerial(executerElement)) then
		if targetElement and ... and time then
			local targetPlayer = exports.dCore:findPlayer(executerElement, targetElement)
			local reason = table.concat({...}, " ")
			if targetPlayer and reason and time then
				if exports.dCore:isPlayerDeveloper(getPlayerSerial(targetPlayer)) then
					return
				end
                local playerAdminLevel = getElementData(executerElement, "adminLevel")
                local executerAdminSyntax = exports.dAdmin:getAdminSyntax(playerAdminLevel, true)
                
                local targetAdminLevel = getElementData(targetPlayer, "adminLevel")
				local playerAdminLevel = getElementData(executerElement, "adminLevel")
                local executerAdminSyntax = exports.dAdmin:getAdminSyntax(playerAdminLevel, true)
				if (targetAdminLevel > playerAdminLevel and playerAdminLevel < 3) and not exports.dCore:isPlayerDeveloper(getPlayerSerial(executerElement)) then
					outputChatBox(errorSyntax.."A kickelni kívánt játékosnak nagyobb az adminszintje mint a tiéd, így nem tudod kickelni.", executerElement, 255, 255, 255, true)
					return
				end

				local time = tonumber(time)
				if time > 1 then
					duration = time .. " óra"
					seconds = time*60*60
					--db = dbExec(databaseConnection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL "..tonumber(time).." HOUR), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"),reason)
				elseif time == 1 then
					duration = "1 hónap"
					seconds = 30*24*60*60
					--db = dbExec(databaseConnection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 1 MONTH), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"),reason)
				elseif time == 0 then
					duration = "Örök"
					seconds = 365*24*60*60
					--db = dbExec(databaseConnection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 1 YEAR), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"),reason)
				end
                outputChatBox("#F1DB76alphav2 ► Kitiltás:#E48F8F".. executerAdminSyntax .. " - " .. getElementData(executerElement, "a.PlayerName") .. "#FFFFFF kitiltotta #E48F8F" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékost. #E48F8F(Indoklás: " .. table.concat({...}, " ") .. " - Időtartam: " .. duration .. ")", root, 255, 255, 255, true)
                if (db) then
					banPlayer(targetPlayer, true, true, true, executerElement, reason, seconds)
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Időtartam] [Indoklás]", executerElement, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Időtartam: #9BE48F>1#FFFFFF - x óra; #9BE48F1#FFFFFF - 1 hónap; #9BE48F0#FFFFFF - Örök", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("ban", banElement)

function setElementVIP(executerElement, commandName, targetElement, time)
	if getElementData(executerElement, "adminLevel") >= 5 then
		if targetElement and time then
			local targetPlayer = exports.dCore:findPlayer(executerElement, targetElement)
			if targetPlayer and time then
				local query = dbQuery(connection, "SELECT * FROM vips WHERE serial='" .. getPlayerSerial(targetPlayer) .. "'")
				local result, num = dbPoll(query, -1)
				if (num) > 0 then
					outputChatBox(errorSyntax .. "A játékosnak már van #C3BE66VIP #FFFFFFjogosultsága.", executerElement, 255, 255, 255, true)
					return
				end

				local time = tonumber(time)
				if time > 0 then
					duration = time .. " perc"
					dbExec(connection,"UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 1)
					db = dbExec(connection,"INSERT INTO `vips` SET `accid` = ?, `date` =  NOW() + INTERVAL "..tonumber(time).." MINUTE, `serial` = ?, `admin` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"))
				elseif time == 0 then
					duration = "Örök"
					dbExec(connection,"UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 1)
					db = dbExec(connection,"INSERT INTO `vips` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 10 YEAR), `serial` = ?, `admin` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"))
				end
				--outputChatBox("#E48F8F[Ban]: #9BE48F" .. getPlayerName(executerElement) .. "#FFFFFF kitiltotta a szerverről#9BE48F " .. getPlayerName(targetPlayer) .. " #FFFFFFjátékost. #8FC3E4(Indok: " .. reason .. " - " .. duration .. ")", root, 255, 255, 255, true)
				if (db) then
					setElementData(targetPlayer, "a.VIP", true)
					outputChatBox(infoSyntax .. "#C8C8C8" .. getPlayerName(executerElement) .. " #C3BE66VIP #FFFFFFjogot adott neked ("..duration..").", targetPlayer, 255, 255, 255, true) 
					outputAdminMessage("#8FC3E4" .. getPlayerName(executerElement) .. " #C3BE66VIP ##FFFFFFjogot adott. #8FC3E4" .. getPlayerName(targetPlayer) .. " ##FFFFFFJátékosnak   #9BE48F(" .. duration .. ")")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Idő]", executerElement, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Idő: #9BE48F0#FFFFFF - Örök; #9BE48Fnagyobb mint 0#FFFFFF - x perc", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("setvip", setElementVIP)

function deleteVIP(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 5 then
		if targetElement then
			local targetPlayer = exports.dCore:findPlayer(executerElement, targetElement)
			if targetPlayer then
				local query = dbQuery(connection, "SELECT * FROM vips WHERE serial='" .. getPlayerSerial(targetPlayer) .. "'")
				local result, num = dbPoll(query, -1)
				if (num) == 0 then
					outputChatBox(errorSyntax .. "Ennek a játékosnak nincs #C3BE66VIP #FFFFFFjogosultsága.", executerElement, 255, 255, 255, true)
					return
				end
				dbExec(connection, "UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 0)
				db = dbExec(connection, "DELETE FROM vips WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
				if (db) then
					setElementData(targetPlayer, "a.VIP", false)
					outputChatBox(infoSyntax .. "#C8C8C8" .. getPlayerName(executerElement) .. " #FFFFFFelvette a #C3BE66VIP #FFFFFFjogosultságodat.", targetPlayer, 255, 255, 255, true)
					outputAdminMessage("#8FC3E4" .. getPlayerName(executerElement) .. " #FFFFFFelvette #8FC3E4" .. getPlayerName(targetPlayer) .. "#ffffff #C3BE66VIP #FFFFFFjogosultságát.")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("delvip", deleteVIP)

function checkVIPStatus()
    if connection then
        local query = dbQuery(connection, "SELECT * FROM vips WHERE date <= NOW()")
        local result = dbPoll(query, -1)

        if result then
            --print("van result hulye cigany")
            for _, row in ipairs(result) do
                local playerSerial = row.serial
                local player = getPlayerFromSerial(playerSerial)

                if player and getElementData(player, "loggedIn") then
                    setElementData(player, "a.VIP", false)

                    triggerClientEvent("makeVipNoti", player)
                    outputChatBox(infoSyntax .. "#E48F8FLejárt #FFFFFFa #C3BE66VIP #FFFFFFtagságod. Ha szeretnél VIP tagságot venni, akkor nyiss ticketet discord szerverünkön!", player, 255, 255, 255, true)

                    dbExec(connection, "DELETE FROM vips WHERE serial = ?", playerSerial)
                end
            end
        end
    else
        outputDebugString("Nem sikerült csatlakozni az adatbázishoz!", 2)
    end
end
setTimer(checkVIPStatus, 300000, 0)
    
function getPlayerFromSerial ( serial )
    assert ( type ( serial ) == "string" and #serial == 32, "getPlayerFromSerial - invalid serial" )
    for index, player in ipairs ( getElementsByType ( "player" ) ) do
        if ( getPlayerSerial ( player ) == serial ) then
            return player
        end
    end
    return false
end