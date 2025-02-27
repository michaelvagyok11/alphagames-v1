function createLogo()
    for i, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "isInLobby") == true then
            local object = createObject(3674, 1879.1201171875, -1384.41796875, 13.573223114014)
            setElementInterior(object, 0)
            setElementDimension(object, 2)
            end
        end
    end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), createLogo)