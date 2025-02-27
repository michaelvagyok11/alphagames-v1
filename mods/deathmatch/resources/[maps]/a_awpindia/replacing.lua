function importTextures2()
	txd = engineLoadTXD ( "awp_india.txd" )
		engineImportTXD ( txd, 9215 )
	col = engineLoadCOL ( "awp_india.col" )
	dff = engineLoadDFF ( "awp_india.dff", 0 )
	engineReplaceCOL ( col, 9215 )
	engineReplaceModel ( dff, 9215 )
	engineSetModelLODDistance(9215, 2000)
end

setTimer ( importTextures2, 100, 1)
--addCommandHandler("replace",importTextures2)

addEventHandler("onClientResourceStop", getResourceRootElement(getThisResource()),
	function()
		engineRestoreCOL(9215)
		engineRestoreModel(9215)
		destroyElement(dff)
		destroyElement(col)
		destroyElement(txd)
	end
)