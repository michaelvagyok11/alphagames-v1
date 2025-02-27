lobbyColPositions = {246.1142578125, 1824.9150390625, 4.7109375, 60}

gmSelectorPoint = {259.9140625, 1823.994140625, 4.7025456428528}

gameModes = {
    {"Deathmatch", "DM"},
    {"Freeroam", "FROAM"},
    {"Drift", "DRIFT"},
    {"Hot Pursuit", "HP"},
}

weaponSkins = {
	--** AK-47
	[9] = 1,
	[10] = 2,
	[19] = 3,
	[20] = 4,
	[21] = 5,
	[22] = 7,
	[23] = 6,
	[49] = 9,
	[50] = 8,
	
	--** Dezi
	[24] = 1,
	[25] = 2,
	[51] = 4,
	[52] = 3,

	--** P90
	[26] = 1,
	[27] = 2,
	[28] = 3,
	[29] = 4,
	[30] = 5,
	[31] = 6,
	[32] = 7,
	[33] = 8,
	[34] = 9,

	--** M4
	[36] = 1,
	[37] = 2,
	[38] = 3,
	[39] = 4,
	[40] = 5,
	[46] = 6,
	[47] = 7,
	[48] = 8,
	[59] = 9,

	--** Silenced
	[53] = 1,
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