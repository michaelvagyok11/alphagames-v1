addEvent("createLaserAttachment", true)
addEventHandler("createLaserAttachment", resourceRoot,
    function()
        triggerClientEvent("createLaserAttachment", resourceRoot, client)
    end
)

function createLaser(player)
    setElementData(player, "enabledLaser", not getElementData(player, "enabledLaser"))

    if getElementData(player, "enabledLaser") then
        triggerClientEvent("createLaserAttachment", resourceRoot, player)
        --outputChatBox("bekapcs")
    else
        triggerClientEvent("destroyLaserAttachment", resourceRoot, player)
        --outputChatBox("kikapcs")
    end
end
addCommandHandler("toglaser", createLaser)

addEvent("destroyLaserAttachment", true)
addEventHandler("destroyLaserAttachment", resourceRoot,
    function()
        triggerClientEvent("destroyLaserAttachment", resourceRoot, client)
    end
)