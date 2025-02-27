local maintenanceMode = false;

function createMaintenance(executerElement, commandName, state)
    if isElement(executerElement) and getElementData(executerElement, "adminLevel") >= 4 then
        if not state then
            outputChatBox("#8FC3E4[Használat]: #FFFFFF/" .. commandName .. " [on/off]", executerElement, 255, 255, 255, true)
            return
        end
        if state == "off" then
            changeMaintenanceState("off")
            return
        elseif state == "on" then
            changeMaintenanceState("on")
            return
        end
    end
end
addCommandHandler("devmode", createMaintenance)

function changeMaintenanceState(state)
    if state == "on" then
        clearChatBox()
         outputChatBox("#E48F8F[FIGYELEM]: A szerver fél percen belül karbantartás üzemmódba lép.\nEzen rövid idő alatt nem leszel képes mozogni, és fekete lesz a kép. \nSzíves türelmedet kérjük, nem tart sokáig.", root, 255, 255, 255, true)        
        x = 5
        setTimer(function()
            x = x - 1
            if x == 0 then
                outputChatBox("#E48F8F[FIGYELEM]: A szerver karbantartás üzemmódba lépett.", root, 255, 255, 255, true)  
                maintenanceMode = true
                triggerClientEvent("changeMaintenanceStatus", root, root, "on")
            else
                outputChatBox("#E48F8F[FIGYELEM]: A szerver " .. x .. " másodpercen belül karbantartás üzemmódba lép.", root, 255, 255, 255, true)  
            end      
        end, 1000, 5)
    else
        triggerClientEvent("changeMaintenanceStatus", root, root, "off")
    end
end