maps = {
    [1] = {
        ["mapName"] = "Los Santos",
        ["mapRespawnPositions"] = {2386.3359375, -1931.1845703125, 13.546875, 2371.013671875, -1886.0517578125, 13.546875}
    },
    [2] = {
        ["mapName"] = "San Fierro",
        ["mapRespawnPositions"] = {-2263.27734375, 716.119140625, 49.290794372559, -2270.3056640625, 643.6474609375, 49.296875},
    },
    [3] = {
        ["mapName"] = "Las Venturas",
        ["mapRespawnPositions"] = {2039.1728515625, 1000.947265625, 10.671875, 2038.9736328125, 1069.765625, 10.671875},
    },
}

function getMapName(id)
    if id then
        return tostring(maps[id]["mapName"])
    end
end