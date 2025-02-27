function createLoader(element, time)
    if element and isElement(element) and time then
        triggerClientEvent("createLoader", element, element, time)
    end
end
addEvent("createLoader", true)
addEventHandler("createLoader", root, createLoader)