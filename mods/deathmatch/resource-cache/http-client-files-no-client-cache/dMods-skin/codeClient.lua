function loadSkin(id, filepath)
	if id then
		local txd = engineLoadTXD("mods/" .. filepath .. ".txd")
		engineImportTXD(txd, id)

		local dff = engineLoadDFF("mods/" .. filepath .. ".dff")
		engineReplaceModel(dff, id)
	end
end

function onResourceStart(startedRes)
	for k, v in ipairs(skinModels) do
		loadSkin(v[1], v[2])
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)