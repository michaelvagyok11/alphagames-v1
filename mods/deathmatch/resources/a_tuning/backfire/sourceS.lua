function backfireOn(player,cmd,state)
    local backfireCost = 5000
    local money = getElementData(player, "a.Money")
    local state = state

    if not state then
        return outputChatBox("#D9B45A► Használat: #FFFFFF/"..cmd.." [on/off]", player, 255, 255, 255, true)
    end

    if state == "on" then
        if not isPlayerInVehicle(player) then
            return outputChatBox("#E48F8F► Hiba: #FFFFFFNem ülsz járműben!", player, 255, 255, 255, true)
        end

        if getElementData(getPedOccupiedVehicle(player), "a.Backfire") == 1 then
            outputChatBox("#E48F8F► Hiba: #FFFFFFMár van backfire a kocsidban!", player, 255, 255, 255, true)
            return
        end

        if isPlayerInVehicle(player) then
            if money >= backfireCost then
                setElementData(getPedOccupiedVehicle(player),"a.Backfire",1)
                outputChatBox("#B4D95A► Siker: #FFFFFFSikeresen bekerült a backfire a kocsidba! Ez #B4D95A5000$#FFFFFF-ba fájt neked.", player, 255, 255, 255, true)
                outputChatBox("#5AB1D9► Info: #FFFFFFKivenni a #5AB1D9/backfire off#FFFFFF paranccsal tudod.", player, 255, 255, 255, true)
                setElementData(player, "a.Money", money - backfireCost)
            else
                outputChatBox("#E48F8F► Hiba: #FFFFFFNincs elég pénzed! #E48F8F(5000$)", player, 255, 255, 255, true)
            end
        end
    elseif state == "off" then
        if not isPlayerInVehicle(player) then
            return outputChatBox("#E48F8F► Hiba: #FFFFFFNem ülsz járműben!", player, 255, 255, 255, true)
        end

        if getElementData(getPedOccupiedVehicle(player), "a.Backfire") == 0 then
            outputChatBox("#E48F8F► Hiba: #FFFFFFNincs a kocsidban backfire!", player, 255, 255, 255, true)
            return
        end

        if isPlayerInVehicle(player) then
            setElementData(getPedOccupiedVehicle(player), "a.Backfire", 0)
            outputChatBox("#B4D95A► Siker: #FFFFFFSikeresen kivetted a kocsidból a backfire-t!", player, 255, 255, 255, true)
        end
    end
end
addCommandHandler("backfire", backfireOn)

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
