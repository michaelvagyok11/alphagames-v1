local lockKeys = false
addEvent("requestKeys", true)
addEventHandler("requestKeys", resourceRoot,
    function(_lockKeys)
        lockKeys = _lockKeys
    end
)

addEventHandler("onClientResourceStart", getRootElement(),
	function ()
		engineImportTXD(engineLoadTXD("mods/279.txd"), 279)
        local file = fileOpen("mods/279.alphaGames")
		local input = fileRead(file, fileGetSize(file))
		fileClose(file)
		local decoded = decodeString("aes128", input, {key = lockKeys.key, iv = lockKeys.iv[modelName]})
		engineReplaceModel(engineLoadDFF(decoded), modelId)
		decoded = false
		input = false
	end
)