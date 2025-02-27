addCommandHandler("backon",
    function(player,cmd)
        if getElementData(player, "adminLevel") > 2 then  
            setElementData(getPedOccupiedVehicle(player),"vehicle.backfire",1)
            outputChatBox("backfire berakva", player, 255, 255, 255, true)
        end
    end
)
addCommandHandler("backof",
    function(player,cmd)
        if getElementData(player, "adminLevel") > 2 then 
            setElementData(getPedOccupiedVehicle(player),"vehicle.backfire",0)
            outputChatBox("backfire kiszedve", player, 255, 255, 255, true)
        end
    end
)

addEvent("onBackFire",true)
addEventHandler("onBackFire",getRootElement(),
    function(player)
        if client and getPedOccupiedVehicle(client) then
            if isElement(source) and getElementType(source) == "vehicle" and getPedOccupiedVehicle(client) == source then
                triggerClientEvent(player, "onBackFire", source)
            end
        end
    end
)
