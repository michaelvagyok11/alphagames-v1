mapCache = {
    [1] = {
        ["mapName"] = "Fallen Tree",
        ["mapRespawnPosition"] = {-592.05859375, -475.9658203125, 25.517845153809, -502.58203125, -518.2734375, 25.5234375},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [2] = {
        ["mapName"] = "Los Santos Gyár",
        ["mapRespawnPosition"] = {2772.7890625, -1621.3955078125, 10.921875, 2797.0498046875, -1545.4423828125, 10.921875},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [3] = {
        ["mapName"] = "Los Santos Trains",
        ["mapRespawnPosition"] = {2212.0517578125, -2199.5439453125, 13.554685592651, 2159.2412109375, -2323.9189453125, 13.554685592651},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [4] = {
        ["mapName"] = "Willowfield",
        ["mapRespawnPosition"] = {2533.5537109375, -1973.3271484375, 13.539093017578, 2434.267578125, -2042.251953125, 13.550000190735},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [5] = {
        ["mapName"] = "Las Venturas Factory",
        ["mapRespawnPosition"] = {969.1220703125, 2096.4833984375, 10.8203125, 993.5966796875, 2173.6845703125, 10.8203125},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [6] = {
        ["mapName"] = "Las Venturas Docks",
        ["mapRespawnPosition"] = {2374.3310546875, 560.71484375, 7.78125, 2255.2861328125, 596.8876953125, 7.7802124023438},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [7] = {
        ["mapName"] = "LSPD",
        ["mapRespawnPosition"] = {1529.3408203125, -1700.4345703125, 13.3828125, 1582.611328125, -1707.67578125, 5.890625},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [8] = {
        ["mapName"] = "San Fierro Lakótelep",
        ["mapRespawnPosition"] = {-2176.59765625, 964.828125, 80, -2219.4384765625, 1043.015625, 80.0078125},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [9] = {
        ["mapName"] = "Las Venturas Underground",
        ["mapRespawnPosition"] = {1917.4091796875, 1755.6171875, 12.714403152466, 2011.9609375, 1752.9833984375, 12.743692398071},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [10] = {
        ["mapName"] = "Las Venturas Lakótelep",
        ["mapRespawnPosition"] = {1123.33923, 2075.04028, 10.82031, 1106.74548, 1935.98999, 10.82031},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    },
    [11] = {
        ["mapName"] = "AWP India",
        ["mapRespawnPosition"] = {-2337.08203125, 2237.482421875, 272.935546875, -2336.9658203125, 2291.1455078125, 272.935546875},
        ["mapTeamNames"] = {"Terroristák", "Terrorelhárítók"},
    }
}

usageSyntax = "#D9B45A► Használat: #FFFFFF"
errorSyntax = "#E48F8F► Hiba: #FFFFFF"
successSyntax = "#B4D95A► Siker: #FFFFFF"
infoSyntax = "#5AB1D9► Info: #FFFFFF"
adminSyntax = "#F1919E►  Admin: #FFFFFF"

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

function outputAdminMessage(message)
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "adminLevel") >= 1 then
            outputChatBox(adminSyntax .. message, v, 255, 255, 255, true)
        end
    end
end

--[[function setTargetMap(targetMapID)
    if lastMap then
        targetMapID = #mapCache[1]
    end
end]]