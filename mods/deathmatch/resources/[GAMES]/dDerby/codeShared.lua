mapCache = {
    [1] = {
        ["mapName"] = "Los Santos Reptér",
        ["mapSpawnPositions"] = {
            {1919.7637, -2272.7051, 13.546875},
            {1919.7637, -2278.7051, 13.546875},
            {1919.7637, -2275.7051, 13.546875},
        },
    },
}

allowedVehicles = {445, 580, 558}

local lastMap = nil;

function getRandomMap()
    if lastMap then
        local randomNumber = math.random(1, #mapCache)
        if randomNumber == lastMap then
            local randomNumber = math.random(1, #mapCache)
            lastMap = randomNumber
            return randomNumber
        else
            lastMap = randomNumber
            return randomNumber
        end
    else
        local randomNumber = math.random(1, #mapCache)
        lastMap = randomNumber
        return tonumber(randomNumber)
    end
end