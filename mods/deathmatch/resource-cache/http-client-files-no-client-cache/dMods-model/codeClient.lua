function onStart()
    for i, v in ipairs(modelsToLoad) do
        if (v[2]) then
            local dffFile = engineLoadDFF(v[2])
            engineReplaceModel(dffFile, v[1])
            if (v[3]) then
                local colFile = engineLoadCOL(v[3])
                engineReplaceCOL(v[1], colFile)
                if (v[4]) then
                    local txdFile = engineLoadTXD(v[4])
                    engineReplaceTXD(v[1], txdFile)
                end
            end
        end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)