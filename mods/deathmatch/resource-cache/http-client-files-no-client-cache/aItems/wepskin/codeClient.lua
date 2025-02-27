local vehiclesWithPaintjob = {}
local objectsWithSticker = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
	for k, v in ipairs(getElementsByType("player")) do
		local weaponShaderName = getElementData(v, "weaponshadername") or 0
		local weaponShaderID = getElementData(v, "weaponshaderid") or 0

		if weaponShaderName ~= 0 and weaponShaderID ~= 0 then
			setWeaponStickerC(v, weaponShaderName, weaponShaderID)
		end
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "player" then
		local weaponShaderName = getElementData(localPlayer, "weaponshadername") or 0
		local weaponShaderID = getElementData(localPlayer, "weaponshaderid") or 0

		if weaponShaderName ~= 0 and weaponShaderID ~= 0 then
			setWeaponStickerC(source, isVehicleHavePaintjob)
		end
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) == "player" then
		local weaponShaderName = getElementData(localPlayer, "weaponshadername") or 0
		local weaponShaderID = getElementData(localPlayer, "weaponshaderid") or 0

		if weaponShaderName ~= 0 and weaponShaderID ~= 0 then
			removeWeaponStickerC(source)
		end
	end
end)



addEventHandler("onClientElementDestroy", root, function()
	if getElementType(source) == "player" then
		local weaponShaderName = getElementData(localPlayer, "weaponshadername") or 0
		local weaponShaderID = getElementData(localPlayer, "weaponshaderid") or 0

		if weaponShaderName ~= 0 and weaponShaderID ~= 0 then
			removeWeaponStickerC(source)
		end
	end
end)



function setWeaponStickerC(localPlayer, shaderName, shaderID, weapon)
	if shaderName and shaderID then
		removeWeaponStickerC(localPlayer)
		vehiclesWithPaintjob[localPlayer] = {}
		vehiclesWithPaintjob[localPlayer][1] = dxCreateShader("wepskin/texturechanger.fx", 0, 100, false, "ped")
		vehiclesWithPaintjob[localPlayer][2] = dxCreateTexture("wepskin/skins/" .. weapon .."/".. shaderID .. ".png")

		if vehiclesWithPaintjob[localPlayer][1] and vehiclesWithPaintjob[localPlayer][2] then
			dxSetShaderValue(vehiclesWithPaintjob[localPlayer][1], "TEXTURE", vehiclesWithPaintjob[localPlayer][2])
			engineApplyShaderToWorldTexture(vehiclesWithPaintjob[localPlayer][1], "*" .. shaderName .. "*", localPlayer)
		else
			outputDebugString("[weaponskins]: shader error", 3)
		end
	end
end
addEvent("setWeaponStickerC",true)
addEventHandler("setWeaponStickerC", getRootElement(), setWeaponStickerC)

function setObjectPaintjobC(objectElement, shaderName, shaderID, eleres)
	if shaderName and shaderID then
		if not eleres then
			eleres = shaderName
		end
		objectsWithSticker[objectElement] = {}
		objectsWithSticker[objectElement][1] = dxCreateShader("wepskin/texturechanger.fx", 0, 100, false, "object")
		objectsWithSticker[objectElement][2] = dxCreateTexture("wepskin/skins/".. eleres .."/".. shaderID .. ".png")
		if objectsWithSticker[objectElement][1] and objectsWithSticker[objectElement][2] then
			dxSetShaderValue(objectsWithSticker[objectElement][1], "TEXTURE", objectsWithSticker[objectElement][2])
			engineApplyShaderToWorldTexture(objectsWithSticker[objectElement][1], "*" .. shaderName .. "*", objectElement)
		end
	end
end
addEvent("setObjectPaintjobC",true)
addEventHandler("setObjectPaintjobC", getRootElement(), setObjectPaintjobC)

function removeStickerFromObjectC(object)
	if object then
		if objectsWithSticker[object] then
			destroyElement(objectsWithSticker[object][1])
			destroyElement(objectsWithSticker[object][2])
			objectsWithSticker[object] = nil
		end
	end
end
addEvent("removeStickerFromObjectC",true)
addEventHandler("removeStickerFromObjectC", getRootElement(), removeStickerFromObjectC)

function removeWeaponStickerC(element)
	if element then
		if vehiclesWithPaintjob[element] then
			destroyElement(vehiclesWithPaintjob[element][1])
			destroyElement(vehiclesWithPaintjob[element][2])
			vehiclesWithPaintjob[element] = nil
		end
	end
end
addEvent("removeWeaponStickerC",true)
addEventHandler("removeWeaponStickerC", getRootElement(), removeWeaponStickerC)