local availablePaintjobs = {
	[30] = {
		[1] = dxCreateTexture("files/ak/camo.png", "dxt1"), -- Winter
		[2] = dxCreateTexture("files/ak/camo2.png", "dxt1"), -- Camo
		[3] = dxCreateTexture("files/ak/camo3.png", "dxt1"), -- Digit
		[4] = dxCreateTexture("files/ak/gold.png", "dxt1"), -- Gold
		[5] = dxCreateTexture("files/ak/gold2.png", "dxt1"), -- Special Gold
		[6] = dxCreateTexture("files/ak/silver.png", "dxt1"), -- Silver
		[7] = dxCreateTexture("files/ak/kitty.png", "dxt1"), -- Hello Kitty
		[8] = dxCreateTexture("files/ak/summerak.png", "dxt1"), -- Summer
		[9] = dxCreateTexture("files/ak/fadeak.png", "dxt1"), -- Fade

	},
	--[[[34] = {
		[1] = dxCreateTexture("files/sniper/camo.png", "dxt1"),
		[2] = dxCreateTexture("files/sniper/camo2.png", "dxt1"),
	},]]
	[23] = {
		[1] = dxCreateTexture("files/silenced/hkitty.png", "dxt1"), -- Hello Kitty

	},
	[24] = {
		[1] = dxCreateTexture("files/deagle/camo.png", "dxt1"), -- Camo
		[2] = dxCreateTexture("files/deagle/gold.png", "dxt1"), -- Gold
		[3] = dxCreateTexture("files/deagle/hkitty.png", "dxt1"), -- Hello Kitty
		[4] = dxCreateTexture("files/deagle/fade.png", "dxt1"), -- Fade
	},
	[29] = {
		[1] = dxCreateTexture("files/p90/1.png", "dxt1"), -- Camo
		[2] = dxCreateTexture("files/p90/2.png", "dxt1"), -- Winter
		[3] = dxCreateTexture("files/p90/3.png", "dxt1"), -- Black
		[4] = dxCreateTexture("files/p90/4.png", "dxt1"), -- Gold Flow
		[5] = dxCreateTexture("files/p90/5.png", "dxt1"), -- No Limit
		[6] = dxCreateTexture("files/p90/6.png", "dxt1"), -- Oni
		[7] = dxCreateTexture("files/p90/7.png", "dxt1"), -- Carbon
		[8] = dxCreateTexture("files/p90/8.png", "dxt1"), -- Wooden
		[9] = dxCreateTexture("files/p90/9.png", "dxt1"), -- Halloween
	},
	[31] = {
		[1] = dxCreateTexture("files/m4/1.png", "dxt1"), -- Camo
		[2] = dxCreateTexture("files/m4/2.png", "dxt1"), -- Gold
		[3] = dxCreateTexture("files/m4/3.png", "dxt1"), -- Hello Kitty
		[4] = dxCreateTexture("files/m4/4.png", "dxt1"), -- Painted
		[5] = dxCreateTexture("files/m4/5.png", "dxt1"), -- Winter
		[6] = dxCreateTexture("files/m4/6.png", "dxt1"), -- Dragon King
		[7] = dxCreateTexture("files/m4/7.png", "dxt1"), -- Howl
		[8] = dxCreateTexture("files/m4/8.png", "dxt1"), -- Hello Kitty 2
	},
	[27] = { -- Spaz
		[1] = dxCreateTexture("files/spaz/dragon.png", "dxt1"),
		[2] = dxCreateTexture("files/spaz/printstream.png", "dxt1"),
		[3] = dxCreateTexture("files/spaz/abstract.png", "dxt1"),
		[4] = dxCreateTexture("files/spaz/stratched.png", "dxt1"),
	},
	--[[[4] = {
		[1] = dxCreateTexture("files/knife/knife1.png", "dxt1"),
		[2] = dxCreateTexture("files/knife/knife2.png", "dxt1"),
		[3] = dxCreateTexture("files/knife/knife3.png", "dxt1"),
		[4] = dxCreateTexture("files/knife/summerknife.png", "dxt1"),
	},
	[28] = {
		[1] = dxCreateTexture("files/uzi/uzi1.png", "dxt1"),
		[2] = dxCreateTexture("files/uzi/uzi2.png", "dxt1"),
		[3] = dxCreateTexture("files/uzi/uzi3.png", "dxt1"),
		[4] = dxCreateTexture("files/uzi/uzi4.png", "dxt1"),
	},
	[25] = {
		[1] = dxCreateTexture("files/shotgun/1.png", "dxt1"),
		[2] = dxCreateTexture("files/shotgun/2.png", "dxt1"),
		[3] = dxCreateTexture("files/shotgun/3.png", "dxt1"),
		[4] = dxCreateTexture("files/shotgun/4.png", "dxt1"),
	},]]
}

local weaponTextureNames = {
	[30] = "ak",
	[31] = "1stpersonassualtcarbine",
	[34] = "tekstura",
	[23] = "1911",
	[24] = "deagle",
	[29] = "p90TEX",
	[4] = "kabar",
	[28] = "9MM_C",
	[25] = "m870t",
	[27] = "spaz",
}

local playerWeaponShaders = {}
local sideWeaponObjects = {}
local sideWeaponShaders = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("player")) do
			if getElementData(v, "loggedIn") then
				local currentWeaponPaintjob = getElementData(v, "currentWeaponPaintjob")

				if currentWeaponPaintjob then
					local paintjobId = currentWeaponPaintjob[1]
					local weaponId = currentWeaponPaintjob[2]

					if paintjobId then
						if paintjobId > 0 then
							playerWeaponShaders[v] = dxCreateShader("files/texturechanger.fx", 0, 0, false, "ped")

							if isElement(playerWeaponShaders[v]) then
								dxSetShaderValue(playerWeaponShaders[v], "gTexture", availablePaintjobs[weaponId][paintjobId])
								engineApplyShaderToWorldTexture(playerWeaponShaders[v], weaponTextureNames[weaponId], v)
								--print("vetel")
							end
						end
					end
				end

				if getElementData(v, "playerSideWeapons") then
					if isElementStreamedIn(v) then
						--processSideWeapons(v)
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementDataChange", getRootElement(),
	function (dataName)
		if dataName == "currentWeaponPaintjob" then
			local newValue = getElementData(source, "currentWeaponPaintjob")

			if isElement(playerWeaponShaders[source]) then
				destroyElement(playerWeaponShaders[source])
			end

			if newValue then
				local paintjobId = newValue[1]
				local weaponId = newValue[2]

				if paintjobId then
					if paintjobId > 0 then
						playerWeaponShaders[source] = dxCreateShader("files/texturechanger.fx", 0, 0, false, "ped")

						if isElement(playerWeaponShaders[source]) then
							dxSetShaderValue(playerWeaponShaders[source], "gTexture", availablePaintjobs[weaponId][paintjobId])
							engineApplyShaderToWorldTexture(playerWeaponShaders[source], weaponTextureNames[weaponId], source)
							--print("asdasd")
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientElementModelChange", getRootElement(),
	function ()
		if getElementType(source) == "player" then
			if getElementData(source, "playerSideWeapons") then
				processSideWeapons(source)
			end
		end
	end
)

addEventHandler("onClientElementStreamIn", getRootElement(),
	function ()
		if getElementType(source) == "player" then
			if getElementData(source, "playerSideWeapons") then
				processSideWeapons(source)
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", getRootElement(),
	function ()
		if sideWeaponObjects[source] then
			for i = 1, #sideWeaponObjects[source] do
				if isElement(sideWeaponObjects[source][i]) then
					destroyElement(sideWeaponObjects[source][i])
					print("toroltem 242")
				end
			end

			sideWeaponObjects[source] = nil
		end

		if sideWeaponShaders[source] then
			for i = 1, #sideWeaponShaders[source] do
				if isElement(sideWeaponShaders[source][i]) then
					destroyElement(sideWeaponShaders[source][i])
					print("toroltem 253")
				end
			end

			sideWeaponShaders[source] = nil
		end
	end
)

addEventHandler("onClientPlayerQuit", getRootElement(),
	function ()
		if sideWeaponObjects[source] then
			for i = 1, #sideWeaponObjects[source] do
				if isElement(sideWeaponObjects[source][i]) then
					destroyElement(sideWeaponObjects[source][i])
					print("toroltem 268")
				end
			end

			sideWeaponObjects[source] = nil
		end

		if sideWeaponShaders[source] then
			for i = 1, #sideWeaponShaders[source] do
				if isElement(sideWeaponShaders[source][i]) then
					destroyElement(sideWeaponShaders[source][i])
					print("toroltem 278")
				end
			end

			sideWeaponShaders[source] = nil
		end
	end
)

function attachToBoneEX(sizeName, sideId, objectElement, pedElement, boneId, posX, posY, posZ, rotX, rotY, rotZ)
	local skinId = getElementModel(pedElement)
	local multiplier = (positionMultipliers[skinId] or 1) * 2.55

	if sizeName == "small" then
		if primaryMultipliers[skinId] then
			multiplier = primaryMultipliers[skinId] * 2.55
		end

		if sideId == 2 then
			if secondaryMultipliers[skinId] then
				multiplier = secondaryMultipliers[skinId] * 2.55
			end
		end

		if skinRotationOffsets[skinId] then
			rotX = rotX + skinRotationOffsets[skinId][1]
			rotY = rotY + skinRotationOffsets[skinId][2]
			rotZ = rotZ + skinRotationOffsets[skinId][3]
		end

		if skinPositionOffsets[skinId] then
			posX = posX + skinPositionOffsets[skinId][1]
			posY = posY + skinPositionOffsets[skinId][2]
			posZ = posZ + skinPositionOffsets[skinId][3]
		end
	end

	exports.dAttach:attachElementToBone(objectElement, pedElement, boneId, posX * multiplier, posY * multiplier, posZ * multiplier, rotX, rotY, rotZ)
end

function processSideWeapons(pedElement)
	local visibleObjects = {}

	if sideWeaponShaders[pedElement] then
		if #sideWeaponShaders[pedElement] > 0 then
			for i = 1, #sideWeaponShaders[pedElement] do
				if isElement(sideWeaponShaders[pedElement][i]) then
					destroyElement(sideWeaponShaders[pedElement][i])
					print("toroltem 327")
				end
			end
		end
	end

	sideWeaponShaders[pedElement] = {}

	if isElementStreamedIn(pedElement) then
		if getElementData(pedElement, "adminDuty") ~= 1 then
			local playerSideWeapons = getElementData(pedElement, "playerSideWeapons") or {}
			local sideWeaponCount = 0
			local backWeaponCount = 0

			for i = 1, #playerSideWeapons do
				local weaponData = playerSideWeapons[i]
				local itemId = weaponData[1]
				local modelId = itemWeaponModel[itemId]
				local hideTheWeapon = false

				if not hideTheWeapon then
					if weaponData[2] == "inuse" then
						if backWeapons[itemId] then
							backWeaponCount = backWeaponCount + 1

							if backWeaponCount > #backOffsets then
								backWeaponCount = 1
							end
						else
							sideWeaponCount = sideWeaponCount + 1

							if sideWeaponCount > #sideOffsets then
								sideWeaponCount = 1
							end
						end
					elseif weaponData[2] then
						if modelId then
							local pedX, pedY, pedZ = getElementPosition(pedElement)
							local objectElement = createObject(modelId, pedX, pedY, pedZ)

							setElementDimension(objectElement, getElementDimension(pedElement))
							setElementInterior(objectElement, getElementInterior(pedElement))
							setElementCollisionsEnabled(objectElement, false)

							local itemOffset = itemOffsets[itemId]

							if backWeapons[itemId] then
								backWeaponCount = backWeaponCount + 1

								if backWeaponCount > #backOffsets then
									backWeaponCount = 1
								end

								local mainOffset = backOffsets[backWeaponCount]
								local extraOffset = false

								if itemOffset then
									extraOffset = itemOffset[backWeaponCount]
								end

								if extraOffset then
									attachToBoneEX("big", backWeaponCount, objectElement, pedElement, 3, mainOffset[1] + extraOffset[1], mainOffset[2] + extraOffset[2], mainOffset[3] + extraOffset[3], mainOffset[4] + extraOffset[4], mainOffset[5] + extraOffset[5], mainOffset[6] + extraOffset[6])
								else
									attachToBoneEX("big", backWeaponCount, objectElement, pedElement, 3, unpack(mainOffset))
								end
							elseif itemOffset then
								sideWeaponCount = sideWeaponCount + 1

								if sideWeaponCount > #sideOffsets then
									sideWeaponCount = 1
								end

								local mainOffset = sideOffsets[sideWeaponCount]
								local extraOffset = itemOffset[sideWeaponCount]

								attachToBoneEX("small", sideWeaponCount, objectElement, pedElement, 4, mainOffset[1] + extraOffset[1], mainOffset[2] + extraOffset[2], mainOffset[3] + extraOffset[3], mainOffset[4] + extraOffset[4], mainOffset[5] + extraOffset[5], mainOffset[6] + extraOffset[6])
							else
								sideWeaponCount = sideWeaponCount + 1

								if sideWeaponCount > #sideOffsets then
									sideWeaponCount = 1
								end

								attachToBoneEX("small", sideWeaponCount, objectElement, pedElement, 4, unpack(sideOffsets[sideWeaponCount]))
							end

							local paintjobId = tonumber(weaponData[3])

							if paintjobId then
								if paintjobId > 0 then
									local weaponId = itemWeaponId[itemId]

									if weaponId then
										if weaponTextureNames[weaponId] then
											if availablePaintjobs[weaponId][paintjobId] then
												local shaderIndex = #sideWeaponShaders[pedElement] + 1

												sideWeaponShaders[pedElement][shaderIndex] = dxCreateShader("files/texturechanger.fx", 0, 0, false, "object")

												if isElement(sideWeaponShaders[pedElement][shaderIndex]) then
													dxSetShaderValue(sideWeaponShaders[pedElement][shaderIndex], "gTexture", availablePaintjobs[weaponId][paintjobId])
													engineApplyShaderToWorldTexture(sideWeaponShaders[pedElement][shaderIndex], weaponTextureNames[weaponId], objectElement)
												end
											end
										end
									end
								end
							end

							table.insert(visibleObjects, objectElement)
						end
					end
				end
			end
		end
	end

	if sideWeaponObjects[pedElement] then
		for i = 1, #sideWeaponObjects[pedElement] do
			if isElement(sideWeaponObjects[pedElement][i]) then
				destroyElement(sideWeaponObjects[pedElement][i])
				print("toroltem 448")
			end
		end
	end

	if visibleObjects then
		sideWeaponObjects[pedElement] = visibleObjects
	end
end
