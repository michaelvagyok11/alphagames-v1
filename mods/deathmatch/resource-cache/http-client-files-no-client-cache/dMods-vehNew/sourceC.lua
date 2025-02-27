local lockKeys = false
addEvent("requestKeys", true)
addEventHandler("requestKeys", resourceRoot,
    function(_lockKeys)
        lockKeys = _lockKeys
    end
)

local infinity = {
	loadedModels = {}
}

local dynamic = {
	nearbyVehicles = {}
}

local loadedVehicleModels = {}
function getPathFromModelId(modelId)
	if modelId >= 400 and modelId <= 611 then
		if availableModels[modelId] then
			return availableModels[modelId].path
		end
		return false
	else
		for k, v in pairs(infinity.loadedModels) do
			if v.modelId == modelId then
				return availableModels[k].path
			end
		end
		return false
	end
	return false
end

local currentlyLoading = {}
function loadVehicleModel(modelId, vehicleElement)
	if vehicleElement then
		if not isElementStreamedIn(vehicleElement) then
			return
		end
	end
	
	local modelName = getPathFromModelId(modelId)
	if not loadedVehicleModels[modelId] then
		if modelName then
			currentlyLoading[modelId] = true
			local file = fileOpen("mods/" .. modelName .. ".bossGames")
			local input = fileRead(file, fileGetSize(file))
			fileClose(file)
			local decoded = decodeString("aes128", input, {key = lockKeys.key, iv = lockKeys.iv[modelName]})
			engineReplaceModel(engineLoadDFF(decoded), modelId)
			decoded = false
			input = false
			loadedVehicleModels[modelId] = getTickCount()
			currentlyLoading[modelId] = false
		end
	end
end

function unloadVehicleModel(modelId)
	if loadedVehicleModels[modelId] and (getTickCount() - loadedVehicleModels[modelId]) >= 1000 then
		engineRestoreModel(modelId)
		loadedVehicleModels[modelId] = false
	end
end

addEventHandler("onClientRender", root,
	function()
		--dxDrawText(inspect(dynamic.nearbyVehicles), 600, 600)
		--dxDrawText(inspect(infinity), 800, 600)
	end
)

--[[local panelState = false
function toggleModPanel(state)
	panelState = state
end
toggleModPanel()

local modPanelState = "overview"
local panelGrab = false
local panelW, panelH = respc(420), respc(230)
local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2
addEventHandler("onClientRender", getRootElement(),
	function()
		if modPanelState then
			if panelGrab then
				if getKeyState("mouse1") then
					local cursorX, cursorY = getCursorPosition()
					cursorX, cursorY = cursorX * screenX, cursorY * screenY
					panelX = cursorX + panelGrab[1]
					panelY = cursorY + panelGrab[2]
				else
					panelGrab = false
				end
			end
			if modPanelState == "overview" then
				panelW, panelH = respc(520), respc(230)
				dxDrawRectangle(panelX - 2, panelY - 2, panelW + 4, panelH + 4, tocolor(30, 30, 40))
				dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(20, 20, 30))
				dxDrawRectangle(panelX, panelY, panelW, respc(30), tocolor(30, 30, 40))
				dxDrawText("NorthMTA - Modpanel", panelX + respc(5), panelY, panelX + panelW, panelY + respc(30), tocolor(255, 255, 255), 1, Rubik12, "left", "center")

				local panelY = panelY + respc(30)
				local count = 0
				for k, v in pairs(availableModels) do

				end
			end
		end
	end
)]]

addEventHandler("onClientClick", getRootElement(),	
	function(key, state, x, y)
		if modPanelState then
			if key == "left" then
				if state == "down" then
					if x >= panelX and x <= panelX + panelW and y >= panelY and y <= panelY + respc(30) then
						panelGrab = {panelX - x, panelY - y}
					end
				elseif state == "up" then
					if panelGrab then
						panelGrab = false
					end
				end
			end
		end
	end
)

addCommandHandler("modpanel",
	function()
		toggleModPanel(not modPanelState)
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        triggerServerEvent("requestKeys", resourceRoot)

		local count = 0
		for k, v in pairs(availableModels) do
			if type(k) == "string" then
				count = count + 1
				infinity.loadedModels[k] = {}
				infinity.loadedModels[k].modelId = engineRequestModel("vehicle", v.defaultId)
				local veh = createVehicle(v.defaultId, 1466.3303222656 + count * 3, -2174.5495605469, 13.546875)
				setVehicleOverrideLights(veh, 2)
				setElementData(veh, "vehicle.customId", k)
				setVehiclePlateText(veh, k)
			end
		end

		for k, v in pairs(availableModels) do
			if type(k) == "number" and k <= 611 and k >= 400 then
				engineImportTXD(engineLoadTXD("mods/" .. v.path .. ".txd"), k)
			elseif type(k) == "string" then
				engineImportTXD(engineLoadTXD("mods/" .. v.path .. ".txd"), infinity.loadedModels[k].modelId)
			end
		end
		--[[setTimer(
			function()
				for k, v in pairs(availableModels) do
					if type(k) == "number" and k <= 611 and k >= 400 then
						engineImportTXD(engineLoadTXD("mods/" .. v.path .. ".txd"), k)
					elseif type(k) == "string" then
						if 
						engineImportTXD(engineLoadTXD("mods/" .. v.path .. ".txd"), infinity.loadedModels[k].modelId)
					end
				end
			end, 3000, 1
		)
		]]
		--[[for k, v in pairs(availableModels) do
			setTimer(
				function(k, v)
					outputChatBox(inspect(k) .. ", " .. toJSON(v))
					if type(k) == "number" and k <= 611 and k >= 400 then
						engineImportTXD(engineLoadTXD("mods/" .. v.path .. ".txd"), k)
						if infinity.loadedModels["bmw_5_e60"].modelId == k then
							print(k)
						end
					elseif type(k) == "string" then
						if infinity.loadedModels["bmw_5_e60"].modelId == infinity.loadedModels[k].modelId then
							print(k, infinity.loadedModels[k].modelId)
						end
						engineImportTXD(engineLoadTXD("mods/" .. v.path .. ".txd"), infinity.loadedModels[k].modelId)
					end
				end, 500 * count, 1, k, v
			)
			count = count + 1
		end]]
    end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function()
		if getElementType(source) == "vehicle" then
			if getVehicleController(source) and getElementData(getVehicleController(source), "activeTuningMarker") then
				return
			end
            local customID = getElementData(source, "vehicle.customId")
            if customID and infinity.loadedModels[customID] and getElementModel(source) ~= infinity.loadedModels[customID].modelId then
                setElementModel(source, infinity.loadedModels[customID].modelId)
				return
            end
			dynamic.nearbyVehicles[getElementModel(source)] = dynamic.nearbyVehicles[getElementModel(source)] or 0
			if dynamic.nearbyVehicles[getElementModel(source)] < 0 then
				dynamic.nearbyVehicles[getElementModel(source)] = 0
			end
			dynamic.nearbyVehicles[getElementModel(source)] = dynamic.nearbyVehicles[getElementModel(source)] + 1
			if dynamic.nearbyVehicles[getElementModel(source)] >= 1 then
				if getTableCount(currentlyLoading) > 0 then
					setTimer(loadVehicleModel, 1000 * getTableCount(currentlyLoading), 1, getElementModel(source), source)
				elseif getTableCount(currentlyLoading) == 0 then
					loadVehicleModel(getElementModel(source))
				end
				currentlyLoading[getElementModel(source)] = true
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),	
	function()
		if getElementType(source) == "vehicle" then
			dynamic.nearbyVehicles[getElementModel(source)] = (dynamic.nearbyVehicles[getElementModel(source)] or 1) - 1
			if dynamic.nearbyVehicles[getElementModel(source)] <= 0 then
				unloadVehicleModel(getElementModel(source))
			end
			if dynamic.nearbyVehicles[getElementModel(source)] < 0 then
				dynamic.nearbyVehicles[getElementModel(source)] = 0
			end
            local customID = getElementData(source, "vehicle.customId")
            if customID and infinity.loadedModels[customID] and loadedVehicleModels[getElementModel(source)] then
                --setElementModel(source, availableModels[customID].defaultId)
			elseif customID and infinity.loadedModels[customID] then
                --setElementModel(source, availableModels[customID].defaultId)
            end
		end
	end
)

addEventHandler("onClientElementDestroy", getRootElement(),	
function()
	if getElementType(source) == "vehicle" then
		dynamic.nearbyVehicles[getElementModel(source)] = (dynamic.nearbyVehicles[getElementModel(source)] or 1) - 1
		if dynamic.nearbyVehicles[getElementModel(source)] <= 0 then
			unloadVehicleModel(getElementModel(source))
		end
		if dynamic.nearbyVehicles[getElementModel(source)] < 0 then
			dynamic.nearbyVehicles[getElementModel(source)] = 0
		end
	end
end
)

addEventHandler("onClientElementDataChange", getRootElement(),
    function(dataName, oldValue, newValue)
        if dataName == "vehicle.customId" then
            if getElementType(source) == "vehicle" then
                if infinity.loadedModels[newValue] then
                    setElementModel(source, infinity.loadedModels[newValue].modelId)
                elseif not newValue or newValue == "0" then
                    setElementModel(source, getElementData(source, "vehicle.modelId"))
                end
            end
        end
    end
)

--[[addCommandHandler("infinitevehiclelist",
    function()
        outputChatBox("#2682c9[NorthMTA]: #ffffffAutók listája:", 255, 255, 255, true)
        for k, v in pairs(availableModels) do
			if v.defaultId and type(k) == "string" then
            	outputChatBox("    #2682c9- [" .. k .. "]: #ffffffMintázott handling: #2682c9" .. v.defaultId, 255, 255, 255, true)
			end
        end
    end
)]]

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        for k, v in pairs(getElementsByType("vehicle")) do
			if getElementData(v, "vehicle.modelId") then
            	setElementModel(v, getElementData(v, "vehicle.modelId"))
			end
        end
        for k, v in pairs(infinity.loadedModels) do
            engineFreeModel(v.modelId)
        end
    end
)

function getCustomIdByModel(modelId)
    for k, v in pairs(infinity.loadedModels) do
        if v.modelId == modelId then
            return k
        end
    end
    return "not found"
end

local hideComponents = {
	[426] = "Widebody_car",
	[541] = "display",
	[587] = "display",
}

local streamedVehicles = {}
addEventHandler("onClientPreRender", getRootElement(),
	function ()
		local streamedVehicles = getElementsByType("vehicle", getRootElement(), true)
		for i = 1, #streamedVehicles do
			if isElement(streamedVehicles[i]) then
				if streamedVehicles[i] then
					vehicleid = getElementModel(streamedVehicles[i])
					if not (vehicleid >= 400 and vehicleid <= 611) then
						vehicleid = getElementData(streamedVehicles[i], "vehicle.customId")
					end
					for j, k in pairs(hideComponents) do
						if vehicleid == j then
							setVehicleComponentVisible(streamedVehicles[i], k, false)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		local streamedVehicles = getElementsByType("vehicle", getRootElement(), true)
		for i = 1, #streamedVehicles do
			if isElement(streamedVehicles[i]) then
				if streamedVehicles[i] then
					setVehicleComponentVisible(streamedVehicles[i], "indicator_l", false)
					setVehicleComponentVisible(streamedVehicles[i], "indicator_r", false)
					vehicleid = getElementModel(streamedVehicles[i])
					if not (vehicleid >= 400 and vehicleid <= 611) then
						vehicleid = getElementData(streamedVehicles[i], "vehicle.customId")
					end
					for j, k in pairs(hideComponents) do
						if vehicleid == j then
							setVehicleComponentVisible(streamedVehicles[i], k, false)
						end
					end
				end
			end
		end
	end
)