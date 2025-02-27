id = 3674

print(id)

txd = engineLoadTXD("alphagames.txd")
engineImportTXD(txd, id)

dff = engineLoadDFF("alphagames.dff")
engineReplaceModel(dff, id)

if dff then
    print(dff)
end