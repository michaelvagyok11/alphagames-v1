--[[function onFaltoro()
    kickPlayer(client)
    exports.a_logs:createDCLog("valaki megpróbált szórakozni", 11)
end

addEvent("onFaltoro", true)
addEventHandler("onFaltoro", getRootElement(), onFaltoro)


function onFaltoroAdmin()
    if getElementData(client, "adminLevel") <= 0 then
        kickPlayer(client)
        exports.a_logs:createDCLog("valaki megpróbált szórakozni adminnal", 11)
    end
end

addEvent("onAdminEvent", true)
addEventHandler("onAdminEvent", getRootElement(), onFaltoroAdmin)--]]