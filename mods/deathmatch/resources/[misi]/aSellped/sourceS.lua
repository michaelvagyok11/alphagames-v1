local ped = createPed(230, 256.3583984375, 1819.3466796875, 4.7109375)
setElementRotation(ped, 0, 0, 180)
setElementData(ped, "invulnerable", true)
setElementData(ped, "a.Pedname", "Fegyver felvásárló (Kuka)")
setElementData(ped, "isSellPed", true)

setElementFrozen(ped, true)

--[[function startLobbyMusic()
    setTimer(
        function ()
            triggerClientEvent(root, "lobbyMusicPlay", root)
        end,
    1000, 1)
end
addEventHandler("onResourceStart", getResourceRootElement(), startLobbyMusic)]]

function getMyData ( thePlayer, command )
    local data = getAllElementData ( thePlayer )     -- get all the element data of the player who entered the command
    for k, v in pairs ( data ) do                    -- loop through the table that was returned
        outputConsole ( k .. ": " .. tostring ( v ) )             -- print the name (k) and value (v) of each element data, we need to make the value a string, since it can be of any data type
    end
end
addCommandHandler ( "teszt", getMyData )