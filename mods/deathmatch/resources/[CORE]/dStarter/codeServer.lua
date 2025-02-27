local exceptionResources = {"dDerby", "dDrift", "dPursuit", "dMods-veh", "dCarshop", "dDuel", "dHandlings", "dInteriors", "dSiren", "dVehicles"}
local highPrioResources = {"dMysql", "dFonts", "dCore", "dDx"}

function startAllResources()

    for i, name in ipairs(highPrioResources) do
        for k, v in ipairs(getResources()) do
            local resName = getResourceName(v)
            if resName == name then
                startResource(v)
                outputDebugString("alphav2 ► " .. resName .. " >> elindult. (#HIGHPRIORITY)", 0, 140, 195, 230)   
            end
        end
    end

	for k, v in ipairs(getResources()) do
        local resName = getResourceName(v)
        local startTick = getTickCount()
        if getResourceState(v) == "running" then
        elseif getResourceState(v) == "loaded" then
            local successTick = getTickCount()
            for i, name in ipairs(exceptionResources) do
                if resName == tostring(name) then
                    outputDebugString("alphav2 ► " .. resName .. " >> nem indult el, mivel exceptionResource.", 0, 140, 195, 230)   
                    break
                else    
                    if i == #exceptionResources then
                        startResource(v)
                        outputDebugString("alphav2 ► " .. resName .. " elindult. (Betöltés ideje: " .. tonumber(successTick - startTick) .. " ms)", 0, 140, 195, 230)
                    end
                end
            end
        elseif getResourceState(v) == "failed to load" then
            outputDebugString("alphav2 ► " .. resName .. " >> nem indult el.", 0, 140, 195, 230)
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, startAllResources)