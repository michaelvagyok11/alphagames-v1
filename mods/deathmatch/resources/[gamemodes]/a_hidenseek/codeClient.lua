addCommandHandler("testprop",
    function ()
        triggerServerEvent("setPlayerAlpha", localPlayer, 150)
        local x, y, z = getElementPosition(localPlayer)
        local object = createObject(964, x, y, z)
        setObjectScale(object, 0.2)
        setElementCollisionsEnabled(object, false)
        attachElements(object, localPlayer, 0, 0, -1)
    end
)

addEvent("setPlayerAlpha", true)
addEventHandler("setPlayerAlpha", getRootElement(),
    function(alpha)
        setElementAlpha(source, alpha)
    end
)