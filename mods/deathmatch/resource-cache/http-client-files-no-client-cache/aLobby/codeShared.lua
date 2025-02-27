lobbyColPositions = {1544.2266, -1350.4395, 329.472085, 40}

gmSelectorPoint = {1544.5, -1353.8887, 329.47333}

gameModes = {
    {"Deathmatch", "DM"},
    {"Derby", "DERBY"},
    {"Drift", "DRIFT"},
    {"Hot Pursuit", "HP"},
}

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