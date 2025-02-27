function loadModels()
	for k, v in ipairs(vehicleMods) do
		local modeltxd = engineLoadTXD("mods/" .. v[2] .. ".txd")
		local modeldff = engineLoadDFF("mods/" .. v[2] .. ".dff")
		if modeltxd and modeldff then
			engineImportTXD(modeltxd, v[1])
			engineReplaceModel(modeldff, v[1])
			sleep(200)
		end
	end
end

function onChange(key, oVal, nVal)
	if key == "a.Gamemode" then
		if nVal == 2 or nVal == 3 or nVal == 4 then
			if source == localPlayer then
				callFunctionWithSleeps(loadModels)
				outputChatBox("#9BE48F[MODS]: #FFFFFFVehicle mods successfully loaded.", 255, 255, 255, true)
			end
		end
	end
	if key == "a.Gamemode" then
		if nVal == nil and not (getElementData(source, "loggedIn")) then
			if source == localPlayer then
				callFunctionWithSleeps(loadModels)
				outputChatBox("#9BE48F[MODS]: #FFFFFFVehicle mods successfully loaded.", 255, 255, 255, true)
			end
		end
	end
end
--addEventHandler("onClientElementDataChange", root, onChange)

function callFunctionWithSleeps(calledFunction, ...) 
    local co = coroutine.create(calledFunction) --we create a thread 
    coroutine.resume(co, ...) --and start its execution 
end 
  
function sleep(time) 
    local co = coroutine.running() 
    local function resumeThisCoroutine() --since setTimer copies the argument values and coroutines cannot be copied, co cannot be passed as an argument, so we use a nested function with co as an upvalue instead 
        coroutine.resume(co) 
    end 
    setTimer(resumeThisCoroutine, time, 1) --we set a timer to resume the current thread later 
    coroutine.yield() --we pause the execution, it will be continued when the timer calls the resume function 
end 

function onStart()
	callFunctionWithSleeps(loadModels)
end

setTimer(onStart, 250, 1)

--**DOWNLOAD MODE (UNFIXED)
--[[function onChange(key, oVal, nVal)
	if key == "a.Gamemode" then
		if nVal == 2 or nVal == 3 then
			if source == localPlayer then
				setTimer(function()
					for k, v in ipairs(vehicleMods) do
						--if v[3] == 0 or v[3] == nVal then
							downloadFile("mods/" .. v[2] .. ".dff")
							downloadFile("mods/" .. v[2] .. ".txd")
						--end
					end
				end, 2500, 1)
			end
		end
	end
end
addEventHandler("onClientElementDataChange", root, onChange)

function onLoadComplete(file, success)
	if file == "mods/" .. vehicleMods[#vehicleMods][2] .. ".txd" then
		setTimer(function()
			loadModels()
		end, 1000, 1)
	end
end
addEventHandler("onClientFileDownloadComplete", root, onLoadComplete)]]--