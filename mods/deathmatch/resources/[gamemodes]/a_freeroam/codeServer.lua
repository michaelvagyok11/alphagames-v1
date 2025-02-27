local spawnPosition = {1877.861328125, -1367.0380859375, 14.640625};

function onChange(key, oVal, nVal)
    if key == "a.Gamemode" then
        if nVal == 2 then
            setElementDimension(source, 2)
            setElementPosition(source, spawnPosition[1], spawnPosition[2], spawnPosition[3])
            setElementData(source, "a.DMRespawnpos", spawnPosition)
            toggleControl(source, "fire", false)
            toggleControl(source, "action", false)
        end
    end
end
addEventHandler("onElementDataChange", root, onChange)