txd = engineLoadTXD("dust2.txd")
engineImportTXD(txd, 7344)

col = engineLoadCOL("dust2.col")
engineReplaceCOL(col, 7344)

dff = engineLoadDFF("dust2.dff")
engineReplaceModel(dff, 7344)
engineSetModelLODDistance(7344, 2000)