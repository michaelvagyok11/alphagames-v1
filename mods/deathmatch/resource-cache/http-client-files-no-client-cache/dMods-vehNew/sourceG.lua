-- szia misi, ugy tudsz hozzaadni kocsi hogy behuzod a server/models mappaba a dff majd beirod szeron /lockveh "dff neve" peldakent: huntley.dff a fajl neve de te csak ezt irod be: /lockveh huntley
-- miutan ez megvan megfogod bemesz mods mappa oda behuzod a txd-t, FONTOS! legyen ugyan az a neve mint a dff-nek.
-- harmadik step: bemesz metaba beirod a nevet pl: <file src="mods/huntley.alphaGames" /> és <file src="mods/huntley.txd" />
-- negyedik step: restart es bent van a kocsi, errort meg ignorald kosz

availableModels = {
    -- ** Újabb kocsi modok ** --
    [507] = {path = "elegant"},
    [489] = {path = "landstalker"},
}

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