-- szia misi, ugy tudsz hozzaadni kocsi hogy behuzod a server/models mappaba a dff majd beirod szeron /lockveh "dff neve" peldakent: huntley.dff a fajl neve de te csak ezt irod be: /lockveh huntley
-- miutan ez megvan megfogod bemesz mods mappa oda behuzod a txd-t, FONTOS! legyen ugyan az a neve mint a dff-nek.
-- harmadik step: bemesz metaba beirod a nevet pl: <file src="mods/huntley.alphaGames" /> és <file src="mods/huntley.txd" />
-- negyedik step: restart es bent van a kocsi, errort meg ignorald kosz

availableModels = {
    -- ** Újabb kocsi modok ** --
    [579] = {path = "huntley"}, -- G63
    [547] = {path = "primo"}, -- GT63S
    [549] = {path = "tampa"}, -- BMW M8
    [426] = {path = "premier"}, -- Demon
    [466] = {path = "glendale"}, -- Giulia

    [604] = {path = "604"}, -- audi a8
    [496] = {path = "blistac"}, -- vw 7
    [401] = {path = "bravura"}, -- ford focus rs
    [541] = {path = "bullet"}, -- zl1
    [507] = {path = "elegant"}, -- w220
    [587] = {path = "euros"}, -- nissan gtr
    [505] = {path = "audiq7"}, -- audi q7
    [479] = {path = "regina"}, -- uj merci evolution fasz
    [580] = {path = "stafford"}, -- e65
    [451] = {path = "turismo"}, -- huracan
    [550] = {path = "sunrise"}, -- Mercedes-Benz S-Class W223
    [551] = {path = "m5f90"},

    -- egyedi
    [426] = {path = "ervin-egyedi"}, -- Dodge Demon egyedi

    -- ** Régebbi kocsi modok ** --
    [602] = {path = "alpha"},
    [445] = {path = "admiral"},
    [411] = {path = "infernus"},
    [559] = {path = "jester"},
    [540] = {path = "vincent"},
    [562] = {path = "elegy"},
    [480] = {path = "comet"},
    [542] = {path = "clover"},
    [477] = {path = "zr350"},
    [421] = {path = "washington"},
    [565] = {path = "flash"},
    [596] = {path = "copcarvg"},
    [597] = {path = "copcarla"},
    [598] = {path = "copcarsf"},
    [599] = {path = "copcarru"},
    [529] = {path = "willard"}, -- csere
    [589] = {path = "club"}, -- csere
    [474] = {path = "hermes"}, -- csere
    [502] = {path = "502"}, -- csere
    [405] = {path = "sentinel"},
    [566] = {path = "tahoma"},
    [400] = {path = "fbirancher"},
}

function getVehicleDatasById(customId)
    if availableModels[customId] then
        local vehicleData = availableModels[customId]
        vehicleData.customId = customId
        return vehicleData
    end
    return false
end

tablecounts = {}
function getTableCount(t)
    local count = 0
    if tablecounts[t] then
        count = tablecounts[t]
    else
        for _ in pairs(t) do
            count = count + 1
        end
    end
    tablecounts[t] = count
    return count
end