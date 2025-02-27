local textures = {}
local shaders = {}

addEvent("requestCustomPJ", true)
addEventHandler("requestCustomPJ", resourceRoot, 
    function(veh, pixels)
        if isElement(veh) and isElementStreamedIn(veh) then
            shaders[veh] = dxCreateShader("files/texturechanger.fx")
            if shaders[veh] then
                textures[veh] = dxCreateTexture(pixels)
                dxSetShaderValue(shaders[veh], "gTexture", textures[veh])
                engineApplyShaderToWorldTexture(shaders[veh], remapContainer[getElementModel(veh)], veh)
                local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4 = getVehicleColor(veh, true)
                setVehicleColor(veh, 255, 255, 255, r2, g2, b2, r3, g3, b3, r4, g4, b4)
            end
        end
    end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
    function()
        if getElementType(source) == "vehicle" then
            if getElementData(source, "vehicle.tuning.Paintjob") and getElementData(source, "vehicle.tuning.Paintjob") < 0 then
                triggerServerEvent("requestCustomPJ", resourceRoot, source)
            end
        end
    end
)

addEventHandler("onClientElementDataChange", getRootElement(),
    function(dataName, oldValue, newValue)
        if dataName == "vehicle.tuning.Paintjob" and newValue == -1 and isElementStreamedIn(source) then
            triggerServerEvent("requestCustomPJ", resourceRoot, source)
        elseif dataName == "vehicle.tuning.Paintjob" and newValue == 0 and shaders[source] then
            if isElement(textures[source]) then
                destroyElement(textures[source])
            end
            textures[source] = nil
            if isElement(shaders[source]) then
                destroyElement(shaders[source])
            end
            shaders[source] = nil
        end
    end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
    function()
        if shaders[source] then
            if isElement(textures[source]) then
                destroyElement(textures[source])
            end
            textures[source] = nil
            if isElement(shaders[source]) then
                destroyElement(shaders[source])
            end
            shaders[source] = nil
        end
    end
)

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        for k, v in pairs(getElementsByType("vehicle", getRootElement(), true)) do
            if getElementData(v, "vehicle.tuning.Paintjob") == -1 then
                triggerServerEvent("requestCustomPJ", resourceRoot, v)
            end
        end
    end
)