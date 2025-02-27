addEventHandler("onResourceStart", getResourceRootElement(), 
    function()
        for k, v in ipairs(interiorList) do

            local interiorEnterCollision = createColSphere(v.enterPosition[1], v.enterPosition[2], v.enterPosition[3], 0.5)
            setElementDimension(interiorEnterCollision, v.enterDimension)
            setElementInterior(interiorEnterCollision, v.enterInterior)
            setElementData(interiorEnterCollision, "interiorEnterCollision", true)
            setElementData(interiorEnterCollision, "interiorTable", v)

            local interiorExitCollision = createColSphere(v.exitPosition[1], v.exitPosition[2], v.exitPosition[3], 0.5)
            setElementDimension(interiorExitCollision, v.exitDimension)
            setElementInterior(interiorExitCollision, v.exitInterior)
            setElementData(interiorExitCollision, "interiorExitCollision", true)
            setElementData(interiorExitCollision, "interiorTable", v)
        end
    end
)

addEvent("enterInterior", true)
addEventHandler("enterInterior", getRootElement(),
    function(activeInterior)
        local interiorTable = getElementData(activeInterior, "interiorTable")
        
        if interiorTable then
            if getElementData(source, "a.HPTeam") == 2 then
                for i, v in ipairs(getElementsByType("player")) do 
                    if getElementData(v, "a.HPTeam") == 1 then
                        outputChatBox("#E48F8F[FIGYELEM]: #FFFFFFEgy Ismeretlen személy belépett egy épületbe. #E48F8F(" .. interiorTable.name .. ")", v, 255, 255, 255, true)
                    end
                end
            end
            
            setElementPosition(source, interiorTable.exitPosition[1], interiorTable.exitPosition[2], interiorTable.exitPosition[3])
            setElementDimension(source, interiorTable.exitDimension)
            setElementInterior(source, interiorTable.exitInterior)
        end
    end
)

addEvent("exitInterior", true)
addEventHandler("exitInterior", getRootElement(),
    function(activeInterior)
        local interiorTable = getElementData(activeInterior, "interiorTable")
        
        if interiorTable then
            if getElementData(source, "a.HPTeam") == 2 then
                for i, v in ipairs(getElementsByType("player")) do 
                    if getElementData(v, "a.HPTeam") == 1 then
                        outputChatBox("#E48F8F[FIGYELEM]: #FFFFFFEgy Ismeretlen személy elhagyott egy épületet. #E48F8F(" .. interiorTable.name .. ")", v, 255, 255, 255, true)
                    end
                end
            end

            setElementPosition(source, interiorTable.enterPosition[1], interiorTable.enterPosition[2], interiorTable.enterPosition[3])
            setElementDimension(source, interiorTable.enterDimension)
            setElementInterior(source, interiorTable.enterInterior)
        end
    end
)

addEvent("setPlayerAlpha", true)
addEventHandler("setPlayerAlpha", getRootElement(),
    function(alpha)
        setElementAlpha(source, alpha)
    end
)