ID = 304

TXD = engineLoadTXD("1.txd")
engineImportTXD(TXD, ID)

DFF = engineLoadDFF("1.dff")
engineReplaceModel(DFF, ID)