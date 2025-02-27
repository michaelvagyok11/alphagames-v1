lobbyColPositions = {2139.7607421875, -79.6025390625, 2.9461483955383, 45}

gmSelectorPoint = {2139.7607421875, -79.6025390625, 3.0461483955383}

function getGamemodeNameById(id, type)
    if tonumber(id) then
        if not type then
            type = false
        end

        if type == true then
            return (tostring(gameModes[id][2]))
        else
            return (tostring(gameModes[id][1]))
        end
    else
        return (tostring("Lobby"))
    end
end