addCommandHandler("testprop2",
    function(sourcePlayer)
        setElementAlpha(sourcePlayer, 0)
        local x, y, z = getElementPosition(sourcePlayer)
        local object = createObject(2912, x, y, z)
        setObjectScale(object, 0.5)
        attachElements(object, sourcePlayer)
        setElementAlpha(sourcePlayer, 150)
    end
)

--[[function setPlayerVisible(sourcePlayer)
    --if getElementData(sourcePlayer, "isPlayerObject") then
        setElementAlpha(sourcePlayer, 255)
    --end
end
addEventHandler("onResourceStop", , setPlayerVisible)]]

addEvent("setPlayerAlpha", true)
addEventHandler("setPlayerAlpha", getRootElement(),
    function(alpha)
        setElementAlpha(source, alpha)
    end
)

addEventHandler("onResourceStop", getResourceRootElement(),
    function ()
        setElementAlpha(source, 255)
    end
)