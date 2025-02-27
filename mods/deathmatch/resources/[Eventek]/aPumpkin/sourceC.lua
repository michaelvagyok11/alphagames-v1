function reMap(inValue, inMin, inMax, outMin, outMax)

	return (inValue - inMin) * (outMax - outMin) / (inMax - inMin) + outMin

end



local screenWidth, screenHeight = guiGetScreenSize()

local responsiveMultipler = reMap(screenWidth, 1024, 1920, 0.75, 1)



function resp(v)

	return v * responsiveMultipler

end



function respc(v)

	return math.ceil(v * responsiveMultipler)

end



---------------------------------------------------------------------------------------------



local frameTime = getTickCount()



local gameState = false

local gameTimer = false

local gameOpacity = 0

local gameMainFont = false



local TextureElements = {}

local TexturesToBeLoaded = {

	["bg"]          = true,

	["body"]        = true,

	["head"]        = true,

	["ear"]         = true,

	["eyebg"]       = true,

	["eyeshut"]     = true,

	["eye"]         = true,

	["mouth"]       = true,

	["mouth2"]      = true,

--	["shadow_body"] = true,

--	["shadow_head"] = true,

--	["shadow_ear"]  = true,

--	["zzz"]         = true,

	["win"]         = true,

	["itemHover"]   = true,

	["ibg"]         = true,

	["1"]           = true,

	["2"]           = true,

	["3"]           = true,

	["4"]           = true,

}

local FileKeys = {
}


local basePosnX = screenWidth / 2

local basePosnY = 0



local bunnySizeX = respc(320)

local bunnySizeY = respc(320)

local bg2SizeX = respc(1280)

local bg2SizeY = respc(620)

local bunnyPosnX = basePosnX - bunnySizeX / 2

local bunnyPosnY = basePosnY + respc(69)



local logoSizeX = respc(700)

local logoSizeY = respc(250)

local logoPosnX = basePosnX - logoSizeX / 2

local logoPosnY = basePosnY + respc(265)



local eyeSizeX = respc(64)

local eyeSizeY = respc(64)

local eyeSpriteSizeX = respc(30)

local eyeSpriteSizeY = respc(34)

local eyeRadius = respc(20)

local eyesState = false

local eyesViewAngle = 0

local eyesLastBlink = 0

local eyesNextBlink = math.random(1500, 3000)

local eyesBlinkTwice = false



local headInterpolation = {getTickCount(), true}

local headRotation = 0

local headRotationCenterX = -respc(75)

local headRotationCenterY = 0



local earsInterpolation = {getTickCount(), true}

local earsRotation = 360

local earSizeX = respc(125)

local earSizeY = respc(125)



local snoreOriginX = bunnyPosnX + respc(283)

local snoreOriginY = bunnyPosnY + respc(138)

local snoreTimer = 0

local snoreSound = false

local snoreState = false



local symbolSizeX = respc(36)

local symbolSizeY = respc(36)

local symbolTable = {}



local bgPreMusic = false

local bgWinMusic = false



local carouselItemsNum = 11

local carouselItemSpacing = 1 / (carouselItemsNum - 1)

local carouselItems = {}

local carouselFocusItem = false

local carouselFirstVisibleItem = 1

local carouselItemSensor = 0



local carouselTrackedItem = false

local carouselTrackedItemPosition = {0, 0}



local carouselStartTimer = false

local carouselFinishTimer = false



local carouselDistance = 0

local carouselDestination = 0

local carouselEasing = false



local itemsLineSizeX = respc(650)

local itemsLineSizeY = respc(50)

local itemsLinePosnX = logoPosnX + (logoSizeX - itemsLineSizeX) / 2

local itemsLinePosnY = logoPosnY + respc(174)



local confettiCanvasSizeX = respc(780)

local confettiCanvasSizeY = itemsLinePosnY + itemsLineSizeY + respc(40)

local confettiCanvasPosnX = (screenWidth - confettiCanvasSizeX) / 2

local confettiCanvasPosnY = 0

local confettiParticles = {}



-- *** DEBUG ***



--bindKey("f1", "down",
--	function ()
--		--if getElementData(localPlayer, "acc.adminLevel") > 0 then
--			tryToStartSummerOpening()
--		--end
--	end
--)



---------------------------------------------------------------------------------------------

--function TeaDecodeBinary(Data, Key)
--    return base64Decode(teaDecode(Data, Key))
--end
--
--function UnlockFile(Path, Key)
--	local File = fileOpen(Path)
--	local Size = fileGetSize(File)
--
--	local EncodedData = fileRead(File, Size)
--	fileClose(File)
--
--	local Data = TeaDecodeBinary(EncodedData, Key)
--
--	return Data
--end


addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		for TextureName, ShouldBeLoaded in pairs(TexturesToBeLoaded) do
			if ShouldBeLoaded then
				--local FilePath = loadLockedFiles("files/" .. TextureName .. ".delypeter", lockCode)
				local FilePath = "files/" .. TextureName .. ".png"

				if fileExists("files/" .. TextureName .. ".png") then
					local TextureElement = dxCreateTexture(FilePath, "argb", false, "clamp")

					if isElement(TextureElement) then
						TextureElements[TextureName] = TextureElement
					end

				else
					outputDebugString("File (" .. FilePath .. ") not exists.", 2)
				end
			end
		end
	end
)




---------------------------------------------------------------------------------------------



function tryToStartSummerOpening(itemId)

	if gameState then

		return false

	end



	frameTime = getTickCount()



	gameState = "fadeIn"

	gameTimer = frameTime

	gameOpacity = 0

	gameMainFont = dxCreateFont("files/BebasNeueRegular.otf", respc(28), false, "antialiased")

	--snoreSound = playSound("files/snore.mp3")

	snoreTimer = frameTime

	snoreState = false



	eyesState = "sleep"

	eyesViewAngle = 0



	addEventHandler("onClientPreRender", root, preRenderBunnyOpen)

	addEventHandler("onClientRender", root, renderBunnyOpen)


	startBunnyOpening()

	if itemId then
		triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", itemId, 1, "octansSeeMTA")
		print(itemId)
	end



	return true

end



function startBunnyOpening()

	local numberOfConfettis = 40

	local confettiTypeCycle = 1



	for i = 1, numberOfConfettis do

		confettiParticles[i] = createConfetti(confettiTypeCycle)

		confettiTypeCycle = confettiTypeCycle % 4 + 1

	end



	table.sort(confettiParticles,

		function (a, b)

			return a.depthFactor < b.depthFactor

		end

	)



	carouselItems = {}

	carouselFocusItem = false

	carouselFirstVisibleItem = 1

	carouselTrackedItem = false



	carouselStartTimer = frameTime + 3866 * math.random(2, 3)

	carouselFinishTimer = false



	carouselDistance = 0

	carouselDestination = math.random(100, 200)

	carouselItemSensor = 0



	for i = 1, carouselItemsNum + 1 do

		carouselItems[i] = chooseRandomItem()

	end



	-- exports.see_chat:localActionC(localPlayer, "kinyit egy tojást.")

end



function closeBunnyOpening()

	if not gameState then

		return

	end



	removeEventHandler("onClientPreRender", root, preRenderBunnyOpen)

	removeEventHandler("onClientRender", root, renderBunnyOpen)



	if gameMainFont then

		if isElement(gameMainFont) then

			destroyElement(gameMainFont)

		end

		gameMainFont = nil

	end



	carouselItems = {}

	symbolTable = {}

	confettiParticles = {}



	if bgPreMusic then

		if isElement(bgPreMusic) then

			destroyElement(bgPreMusic)

		end

		bgPreMusic = nil

	end



	if bgWinMusic then

		if isElement(bgWinMusic) then

			destroyElement(bgWinMusic)

		end

		bgWinMusic = nil

	end



	gameState = false

end



---------------------------------------------------------------------------------------------



function preRenderBunnyOpen(deltaTime)

	deltaTime = deltaTime / 1000



	if carouselStartTimer then

		local elapsedTime = frameTime - carouselStartTimer



		if elapsedTime > 0 then

			local elapsedFraction = elapsedTime / 24000



			if not carouselEasing then

				carouselEasing = createBezierEasing(0.2, 0, 0.2, 1)

			end



			carouselDistance = carouselDestination * carouselEasing(elapsedFraction)



			if elapsedFraction >= 1 then

				carouselDistance = carouselDestination

				carouselStartTimer = false

				carouselFinishTimer = frameTime

			end



			if eyesState == "sleep" then

				eyesLastBlink = frameTime

				eyesNextBlink = frameTime + math.random(1500, 3000)

				eyesState = "open"

			end



			if snoreTimer then

				snoreTimer = false

				snoreState = false



				if snoreSound then

					if isElement(snoreSound) then

						destroyElement(snoreSound)

					end



					snoreSound = nil

				end

			end



			if gameState == "fadedIn" then

				gameState = "startMusic"



				bgPreMusic = playSound("files/music.mp3", true)

				bgWinMusic = playSound("files/music2.mp3", true)



				if isElement(bgPreMusic) then

					setSoundVolume(bgPreMusic, 0)

				end



				if isElement(bgWinMusic) then

					setSoundVolume(bgWinMusic, 0)

				end

			elseif gameState == "startMusic" then

				if isElement(bgPreMusic) then

					if elapsedTime < 500 then

						setSoundVolume(bgPreMusic, elapsedTime / 500)

					else

						setSoundVolume(bgPreMusic, 1)

					end

				end

			end

		end

	end



	if carouselTrackedItemPosition then

		local eyeContainerX = bunnyPosnX + bunnySizeX / 2

		local eyeContainerY = bunnyPosnY + bunnySizeY / 2



		local targetViewAngle = math.atan2(

			carouselTrackedItemPosition[2] - eyeContainerY,

			carouselTrackedItemPosition[1] - eyeContainerX

		)



		if gameState == "giveReward" then

			targetViewAngle = math.atan2(basePosnY - eyeContainerY, basePosnX - eyeContainerX)

		end



		local currentAngle = eyesViewAngle



		if targetViewAngle - currentAngle > math.pi then

			targetViewAngle = targetViewAngle - 2 * math.pi

		elseif currentAngle - targetViewAngle > math.pi then

			currentAngle = currentAngle - 2 * math.pi

		end



		eyesViewAngle = currentAngle + (targetViewAngle - currentAngle) * deltaTime * 4

	end



	updateConfettis(deltaTime)

end



function renderBunnyOpen()

	frameTime = getTickCount()



	if gameTimer then

		local elapsedTime = frameTime - gameTimer



		if elapsedTime > 0 then

			if gameState == "fadeIn" then

				local elapsedFraction = elapsedTime / 500



				gameOpacity = getEasingValue(elapsedFraction, "InOutQuad")



				if isElement(bgPreMusic) then

					setSoundVolume(bgPreMusic, gameOpacity)

				end



				if elapsedFraction >= 1 then

					gameOpacity = 1

					gameTimer = false

					gameState = "fadedIn"

				end

			elseif gameState == "fadeOut" then

				local elapsedFraction = elapsedTime / 500



				gameOpacity = 1 - getEasingValue(elapsedFraction, "InOutQuad")



				if isElement(bgWinMusic) then

					setSoundVolume(bgWinMusic, gameOpacity)

				end



				if elapsedFraction >= 1 then

					closeBunnyOpening()

					return

				end

			end

		end

	end



	renderConfettis()

	renderTheBunny()

	renderMinigame()

end



function createConfetti(confettiType)

	local self = {}



	self.textureName = tostring(confettiType)

	self.depthFactor = math.random(0, 100) / 100



	self.sizeX = respc(32) * (1 - self.depthFactor) + respc(80) * self.depthFactor

	self.sizeY = self.sizeX



	self.positionX = math.random(confettiCanvasPosnX + self.sizeX, confettiCanvasPosnX + confettiCanvasSizeX) - self.sizeX / 2

	self.positionY = math.random(confettiCanvasPosnY, confettiCanvasPosnY + confettiCanvasSizeY) - self.sizeY / 2



	self.strafeSpeed = 5 * (1 - self.depthFactor) + 20 * self.depthFactor

	self.strafeChangeRate = math.random(35, 75) / 100

	self.strafeAmount = self.strafeChangeRate



	self.rotationDeg = 0

	self.opacityFactor = 0.4 * (1 - self.depthFactor) + 1 * self.depthFactor



	self.windForce = math.random(20, 100) / 100

	self.windDirection = math.random() < 0.5 and -1 or 1



	self.distanceFactor = 0



	return self

end



function updateConfettis(deltaTime)

	for i = #confettiParticles, 1, -1 do

		local v = confettiParticles[i]



		if v then

			local strafeX = math.cos(v.strafeAmount)

			local strafeY = math.sin(math.pi / 2)



			v.windForce = v.windForce + 0.1 * v.windDirection * deltaTime



			if v.windForce > 1.2 then

				v.windForce = 1.2

				v.windDirection = -1

			elseif v.windForce < 0.2 then

				v.windForce = 0.2

				v.windDirection = 1

			end



			strafeX = strafeX * (1 - v.windForce)

			strafeY = strafeY * v.windForce



			v.rotationDeg = 60 * strafeX * math.rad(v.sizeX)

			v.strafeAmount = v.strafeAmount + v.strafeChangeRate * deltaTime



			strafeX = strafeX * v.strafeSpeed

			strafeY = strafeY * v.strafeSpeed



			if debugMode then

				dxDrawLine(v.positionX, v.positionY, v.positionX + strafeX, v.positionY + strafeY, 0xFFFF0000, 6)

			end



			v.positionX = v.positionX + strafeX * deltaTime

			v.positionY = v.positionY + strafeY * deltaTime



			v.distanceFactor = (v.positionY - confettiCanvasPosnY + v.sizeY) / (confettiCanvasSizeY + v.sizeY / 2)



			if v.distanceFactor >= 1 then

				v.positionX = math.random(confettiCanvasPosnX + v.sizeX, confettiCanvasPosnX + confettiCanvasSizeX) - v.sizeX / 2

				v.positionY = confettiCanvasPosnY - v.sizeY / 2

			end

		end

	end

end



function renderConfettis()

	if debugMode then

		dxDrawRectangle(confettiCanvasPosnX, confettiCanvasPosnY, confettiCanvasSizeX, confettiCanvasSizeY, tocolor(255, 255, 255, 50 * gameOpacity))

	end



	for i = 1, #confettiParticles do

		local v = confettiParticles[i]



		if v then

			local opacityFactor = 0



			if v.distanceFactor < 0.1 then

				opacityFactor = v.distanceFactor / 0.1

			elseif v.distanceFactor > 0.95 then

				opacityFactor = 1 - (v.distanceFactor - 0.95) / (1 - 0.95)

			else

				opacityFactor = 1

			end



		--	dxDrawImage(v.positionX - v.sizeX / 2, v.positionY - v.sizeY / 2, v.sizeX, v.sizeY, TextureElements[v.textureName], v.rotationDeg, 0, 0, tocolor(255, 255, 255, 255 * v.opacityFactor * opacityFactor * gameOpacity))

		end

	end

end



function renderTheBunny()

	local derivedColor = tocolor(255, 255, 255, 255 * gameOpacity)

	local shadowOffset = 4



	-- Base Shadows

--	dxDrawImage(bunnyPosnX - shadowOffset, bunnyPosnY, bunnySizeX, bunnySizeY, TextureElements["shadow_body"], -headRotation / 6, 0, 0, derivedColor)

--	dxDrawImage(bunnyPosnX - shadowOffset, bunnyPosnY + shadowOffset, bunnySizeX, bunnySizeY, TextureElements["shadow_head"], headRotation, headRotationCenterX, headRotationCenterY, derivedColor)



	-- Body
	dxDrawImage(bunnyPosnX-respc(500), bunnyPosnY-respc(100), bg2SizeX, bg2SizeY, TextureElements["4"], -headRotation / 4, 0, 0, derivedColor)
	dxDrawImage(bunnyPosnX-respc(500), bunnyPosnY-respc(100), bg2SizeX, bg2SizeY, TextureElements["body"], -headRotation / 4, 0, 0, derivedColor)



	-- Ears

	local bunnyCenterX = bunnyPosnX + bunnySizeX / 2

	local bunnyCenterY = bunnyPosnY + bunnySizeY / 2



	if earsInterpolation then

		if earsInterpolation[2] then

			local elapsedFraction = (frameTime - earsInterpolation[1]) / 20000



			earsRotation = interpolateBetween(1, 20, 300, 4000, 500000, 60000000, elapsedFraction, "Linear")



			if elapsedFraction >= 1 then

				earsInterpolation[2] = false

				earsInterpolation[1] = frameTime

			end

		else

			local elapsedFraction = (frameTime - earsInterpolation[1]) / 2000



			earsRotation = interpolateBetween(7, 8, 9, 10, 11, 12, elapsedFraction, "Linear")



			if elapsedFraction >= 1 then

				earsInterpolation[2] = true

				earsInterpolation[1] = frameTime

			end

		end

	end



	local leftEarX, leftEarY = rotatePoint(headRotation, bunnyPosnX + respc(198), bunnyPosnY + respc(73), bunnyCenterX + headRotationCenterX, bunnyCenterY + headRotationCenterY)



	leftEarX = leftEarX - earSizeX - respc(24)

	leftEarY = leftEarY - earSizeY / 2 + respc(50)



	--dxDrawImage(bunnyPosnX, bunnyPosnY, bunnySizeX, bunnySizeY, TextureElements["ear"], headRotation + earsRotation, 0, 0, derivedColor)



	local rightEarX, rightEarY = rotatePoint(headRotation, bunnyPosnX + respc(311), bunnyPosnY + respc(90), bunnyCenterX + headRotationCenterX, bunnyCenterY + headRotationCenterY)



	rightEarX = rightEarX - earSizeX - respc(40)

	rightEarY = rightEarY - earSizeY / 2 + respc(30)


	-- Eyes

	if eyesState ~= "sleep" then

		if frameTime > eyesNextBlink then

			eyesState = "closed"

			eyesLastBlink = frameTime

			eyesNextBlink = frameTime + math.random(2500, 7500)

			eyesBlinkTwice = math.random() <= 0.4

		end



		local elapsedTimeFromLastBlink = frameTime - eyesLastBlink



		if eyesBlinkTwice then

			if elapsedTimeFromLastBlink > 150 then

				eyesState = "open"

			elseif elapsedTimeFromLastBlink > 100 then

				eyesState = "closed"

			elseif elapsedTimeFromLastBlink > 50 then

				eyesState = "open"

			end

		elseif elapsedTimeFromLastBlink > 50 then

			eyesState = "open"

		end

	end



	if eyesState ~= "open" then

		dxDrawImage(bunnyPosnX, bunnyPosnY, bunnySizeX, bunnySizeY, TextureElements["eye"], headRotation, headRotationCenterX, headRotationCenterY, derivedColor)
		dxDrawImage(bunnyPosnX, bunnyPosnY, bunnySizeX, bunnySizeY, TextureElements["eyeshut"], headRotation, headRotationCenterX, headRotationCenterY, derivedColor)
		dxDrawImage(leftEarX, leftEarY, earSizeX, earSizeY, TextureElements["mouth"], headRotation + earsRotation, 0, 0, derivedColor)
		dxDrawImage(rightEarX, rightEarY, earSizeX, earSizeY, TextureElements["mouth"], headRotation + earsRotation, 0, 0, derivedColor)


	else

		local viewDirectionX = math.cos(eyesViewAngle)

		local viewDirectionY = math.sin(eyesViewAngle)



		dxDrawImage(bunnyPosnX, bunnyPosnY, bunnySizeX, bunnySizeY, TextureElements["eyebg"], headRotation, headRotationCenterX, headRotationCenterY, derivedColor)
		dxDrawImage(rightEarX, rightEarY, earSizeX, earSizeY, TextureElements["ear"], headRotation, 0, 0, derivedColor)
		dxDrawImage(leftEarX, leftEarY, earSizeX, earSizeY, TextureElements["ear"], headRotation, 0, 0, derivedColor)


		-- Left

		local leftEyeX, leftEyeY = rotatePoint(headRotation, bunnyPosnX + respc(231), bunnyPosnY + respc(84), bunnyCenterX + headRotationCenterX, bunnyCenterY + headRotationCenterY)



		if debugMode then

			dxDrawCircle(leftEyeX, leftEyeY, eyeRadius, 0, 360)

		end



		leftEyeX = leftEyeX - eyeSizeX / 2 + viewDirectionX * (eyeRadius - eyeSpriteSizeX / 2)

		leftEyeY = leftEyeY - eyeSizeY / 2 + viewDirectionY * (eyeRadius - eyeSpriteSizeY / 2)



	--	dxDrawImage(leftEyeX, leftEyeY, eyeSizeX, eyeSizeY, TextureElements["eye"], headRotation, 0, 0, derivedColor)



		-- Right

		local rightEyeX, rightEyeY = rotatePoint(headRotation, bunnyPosnX + respc(298), bunnyPosnY + respc(99), bunnyCenterX + headRotationCenterX, bunnyCenterY + headRotationCenterY)



		if debugMode then

			dxDrawCircle(rightEyeX, rightEyeY, eyeRadius, 0, 360)

		end



		rightEyeX = rightEyeX - eyeSizeX / 2 + viewDirectionX * (eyeRadius - eyeSpriteSizeX / 2)

		rightEyeY = rightEyeY - eyeSizeY / 2 + viewDirectionY * (eyeRadius - eyeSpriteSizeY / 2)



		--dxDrawImage(rightEyeX, rightEyeY, eyeSizeX, eyeSizeY, TextureElements["eye"], headRotation, 0, 0, derivedColor)

	end



	-- Head

	if headInterpolation then

		if headInterpolation[2] then

			local elapsedFraction = (frameTime - headInterpolation[1]) / 1500



			headRotation = interpolateBetween(0, 0, 0, 0, 0, 0, elapsedFraction, "InOutQuad")



			if elapsedFraction >= 1 then

				headInterpolation[2] = false

				headInterpolation[1] = frameTime

			end

		else

			local elapsedFraction = (frameTime - headInterpolation[1]) / 1500



			headRotation = interpolateBetween(0, 0, 0, 0, 0, 0, elapsedFraction, "InOutQuad")



			if elapsedFraction >= 1 then

				headInterpolation[2] = true

				headInterpolation[1] = frameTime

			end

		end

	end



	dxDrawImage(bunnyPosnX, bunnyPosnY, bunnySizeX, bunnySizeY, TextureElements["head"], headRotation, headRotationCenterX, headRotationCenterY, derivedColor)



	-- Mouth

	if snoreTimer then

		if frameTime > snoreTimer then

			local elapsedTime = frameTime - snoreTimer



			if elapsedTime >= 3866 then

				snoreState = false



				if eyesState == "sleep" then

					snoreTimer = frameTime

					--snoreSound = playSound("files/snore.mp3")

				end

			elseif elapsedTime > 2408 then

				if eyesState == "sleep" then

					if not snoreState then

						--table.insert(symbolTable, {startTime = frameTime, textureName = "zzz"})

						snoreState = true

					end

				end

			end

		end

	end



	local mouthRotatedX, mouthRotatedY = rotatePoint(headRotation, snoreOriginX, snoreOriginY, bunnyCenterX + headRotationCenterX, bunnyCenterY + headRotationCenterY)



	mouthRotatedX = mouthRotatedX - symbolSizeX / 2

	mouthRotatedY = mouthRotatedY - symbolSizeY / 2



	if snoreTimer then

		if snoreState then

			--dxDrawImage(bunnyPosnX, bunnyPosnY, bunnySizeX, bunnySizeY, TextureElements["mouth2"], headRotation, headRotationCenterX, headRotationCenterY, derivedColor)

		else

			--dxDrawImage(bunnyPosnX, bunnyPosnY, bunnySizeX, bunnySizeY, TextureElements["mouth"], headRotation, headRotationCenterX, headRotationCenterY, derivedColor)

		end

	end



	for i = #symbolTable, 1, -1 do

		local v = symbolTable[i]



		if v then

			local elapsedTime = frameTime - v.startTime



			if elapsedTime > 0 then

				local elapsedFraction = elapsedTime / 1750

				local opacityFraction = 0



				if elapsedTime > 1000 then

					opacityFraction = 1 - (elapsedTime - 1000) / 500



					if opacityFraction < 0 then

						opacityFraction = 0

					end

				else

					opacityFraction = elapsedTime / 500



					if opacityFraction > 1 then

						opacityFraction = 1

					end

				end



				local movementAngle = math.pi - math.pi/3 * elapsedFraction



				local symbolPosnX = mouthRotatedX - elapsedFraction * math.cos(movementAngle) * respc(250)

				local symbolPosnY = mouthRotatedY - elapsedFraction * math.sin(movementAngle) * respc(350)



				dxDrawImage(symbolPosnX, symbolPosnY, symbolSizeX, symbolSizeY, TextureElements[v.textureName], 0, 0, 0, tocolor(255, 255, 255, 255 * opacityFraction * gameOpacity))



				if elapsedFraction >= 1 then

					table.remove(symbolTable, i)

				end

			end

		end

	end

end



function renderMinigame()

	local derivedAlpha = 255 * gameOpacity



	dxDrawImage(logoPosnX, logoPosnY, logoSizeX, logoSizeY, TextureElements["bg"], 0, 0, 0, tocolor(255, 255, 255, derivedAlpha))



	for i = carouselFirstVisibleItem, carouselItemsNum + carouselFirstVisibleItem do

		local ItemId = carouselItems[i]



		if ItemId then

			local relativePosition = 1 - (i - 1) * carouselItemSpacing



			if carouselDistance > 0 then

				relativePosition = relativePosition + carouselDistance * carouselItemSpacing

			end



			local scaleFactor = 1.0 - math.abs(0.5 - relativePosition) * 2

			local alphaFactor = 1.1 - math.abs(0.5 - relativePosition) * 2 + 0.1



			if scaleFactor < 0 then

				scaleFactor = 0

			elseif scaleFactor > 1 then

				scaleFactor = 1

			end



			if alphaFactor < 0 then

				alphaFactor = 0

			elseif alphaFactor > 1 then

				alphaFactor = 1

			end



			if carouselFinishTimer then

				local elapsedTime = frameTime - carouselFinishTimer



				if carouselFocusItem ~= i then

					local targetAlpha = alphaFactor * 0.5



					if elapsedTime < 500 then

						alphaFactor = alphaFactor - targetAlpha * elapsedTime / 500

					else

						alphaFactor = targetAlpha

					end

				else

					local targetScale = scaleFactor * 1.4 --> 40x40



					if elapsedTime < 500 then

						scaleFactor = scaleFactor + (targetScale - scaleFactor) * elapsedTime / 500

					else

						scaleFactor = targetScale

					end

				end

			end



			local itemSizeX = respc(36) * scaleFactor + respc(26) * (1 - scaleFactor)

			local itemSizeY = respc(36) * scaleFactor + respc(26) * (1 - scaleFactor)



			local hoverSizeX = respc(66) * itemSizeX / respc(36)

			local hoverSizeY = respc(66) * itemSizeY / respc(36)



			local centerPosnX = itemsLinePosnX + itemsLineSizeX * relativePosition

			local centerPosnY = itemsLinePosnY + itemsLineSizeY / 2



			local itemPosnX = centerPosnX - itemSizeX / 2

			local itemPosnY = centerPosnY - itemSizeY / 2



			dxDrawImage(itemPosnX, itemPosnY, itemSizeX, itemSizeY, ":a_inventory/files/items/" .. ItemId - 1 .. ".png", 0, 0, 0, tocolor(255, 255, 255, derivedAlpha * alphaFactor))



			if goldItems[ItemId] then

				dxDrawImage(itemPosnX + (itemSizeX - hoverSizeX) / 2, itemPosnY + (itemSizeY - hoverSizeY) / 2, hoverSizeX, hoverSizeY, TextureElements["itemHover"], 0, 0, 0, tocolor(goldColor[1], goldColor[2], goldColor[3], derivedAlpha * alphaFactor))

			end



			local sensorMinX = itemsLinePosnX + (itemsLineSizeX - itemSizeX) / 2 - itemSizeX / 2

			local sensorMaxX = itemsLinePosnX + (itemsLineSizeX + itemSizeX) / 2 + itemSizeX / 2



			if debugMode then

				dxDrawLine(sensorMinX, itemsLinePosnY, sensorMinX, itemsLinePosnY + itemsLineSizeY, 0xFF00FF00, 1, true)

				dxDrawLine(sensorMaxX, itemsLinePosnY, sensorMaxX, itemsLinePosnY + itemsLineSizeY, 0xFFFF0000, 1, true)

			end



			if centerPosnX >= sensorMinX and centerPosnX <= sensorMaxX then

				carouselItemSensor = (centerPosnX - sensorMinX) / (sensorMaxX - sensorMinX)



				if carouselFocusItem then

					if carouselFocusItem < i then

						carouselFocusItem = i

						playSound("files/spin.mp3")

					end

				else

					carouselFocusItem = i

				end

			elseif carouselFocusItem == i then

				carouselItemSensor = 0

			end



			if not carouselTrackedItem then

				carouselTrackedItem = carouselFocusItem

			end



			if carouselTrackedItem == i then

				carouselTrackedItemPosition = {itemPosnX + itemSizeX / 2, itemPosnY + itemSizeY / 2}

			end



			if relativePosition >= 1.1 then

				carouselFirstVisibleItem = carouselFirstVisibleItem + 1



				carouselItems[#carouselItems + 1] = chooseRandomItem()

				carouselItems[i] = false



				if carouselTrackedItem == i then

					carouselTrackedItem = #carouselItems

				end

			end

		end

	end



	local carouselTextOpacity = 0



	if not carouselFinishTimer then

		if frameTime > carouselStartTimer - 500 then

			carouselTextOpacity = (frameTime - carouselStartTimer + 500) / 500



			if carouselTextOpacity > 1 then

				carouselTextOpacity = 1

			end

		end

	else

		carouselTextOpacity = 1

	end



	if carouselTextOpacity > 0 then

		local winOpacity = 0



		if carouselFinishTimer then

			local elapsedTime = frameTime - carouselFinishTimer



			if elapsedTime < 500 then

				winOpacity = elapsedTime / 500

			else

				winOpacity = 1

			end

		end



		dxDrawImage(

			itemsLinePosnX + (itemsLineSizeX - respc(48)) / 2,

			itemsLinePosnY,

			respc(48),

			respc(48),

			TextureElements["ibg"],

			0, 0, 0,

			tocolor(255, 255, 255, 255 * (1 - winOpacity) * carouselTextOpacity * gameOpacity)

		)



		local ItemId = carouselItems[carouselFocusItem]



		if ItemId then

			local itemAlpha = 1 - math.abs(0.5 - carouselItemSensor) * 2

			local itemColor = {255, 255, 255}

			local fontScale = 0.5 * (1 - winOpacity) + 0.625 * winOpacity



			if goldItems[ItemId] then

				itemColor[1] = goldColor[1]

				itemColor[2] = goldColor[2]

				itemColor[3] = goldColor[3]

			end



			-- Shine effect

			if winOpacity > 0 then

				local shineSizeX = respc(400) * winOpacity

				local shineSizeY = respc(400) * winOpacity



				local shinePosnX = itemsLinePosnX + (itemsLineSizeX - shineSizeX) / 2

				local shinePosnY = itemsLinePosnY + (itemsLineSizeY - shineSizeY) / 2



				dxDrawImage(

					shinePosnX,

					shinePosnY,

					shineSizeX,

					shineSizeY,

					TextureElements["win"],

					frameTime / 50, 0, 0,

					tocolor(itemColor[1], itemColor[2], itemColor[3], 255 * winOpacity * gameOpacity)

				)

			end



			-- Item name shadow

			dxDrawText(

				exports.a_inventory:getItemName(ItemId),

				itemsLinePosnX + 1,

				itemsLinePosnY + itemsLineSizeY + 1,

				itemsLinePosnX + itemsLineSizeX + 1,

				1,

				tocolor(0, 0, 0, 200 * itemAlpha * carouselTextOpacity * gameOpacity),

				fontScale,

				gameMainFont,

				"center",

				"top"

			)



			-- Item name

			dxDrawText(

				exports.a_inventory:getItemName(ItemId),

				itemsLinePosnX,

				itemsLinePosnY + itemsLineSizeY,

				itemsLinePosnX + itemsLineSizeX,

				0,

				tocolor(itemColor[1], itemColor[2], itemColor[3], 255 * itemAlpha * carouselTextOpacity * gameOpacity),

				fontScale,

				gameMainFont,

				"center",

				"top"

			)

		end

	end



	if carouselFinishTimer then

		local elapsedTime = frameTime - carouselFinishTimer



		if elapsedTime > 12500 then

			if gameState ~= "fadeOut" then

				gameTimer = frameTime

				gameState = "fadeOut"

			end

		elseif elapsedTime > 0 then

			carouselTrackedItem = carouselFocusItem



			if gameState ~= "giveReward" then

				local ItemId = carouselItems[carouselFocusItem]



				if ItemId then

					triggerServerEvent("$$$$$$$$$$$$$$$", localPlayer, localPlayer, ItemId, 1, false, false, false, false, "alphagames.net")

					if goldItems[ItemId] then

						outputChatBox("#e48f8f[alphaGames]:#ffffff Nyereményed: #e8c55a" .. exports.a_inventory:getItemName(ItemId), 255, 255, 255, true)

					else

						outputChatBox("#e48f8f[alphaGames]:#ffffff Nyereményed: #6cb3c9" .. exports.a_inventory:getItemName(ItemId), 255, 255, 255, true)

					end

				end



				gameState = "giveReward"

			end



			local fadeFactor = elapsedTime / 250



			if fadeFactor < 1 then

				if isElement(bgPreMusic) then

					setSoundVolume(bgPreMusic, 1 - fadeFactor)

				end



				if isElement(bgWinMusic) then

					setSoundVolume(bgWinMusic, fadeFactor)

				end

			else

				if isElement(bgPreMusic) then

					if not isSoundPaused(bgPreMusic) then

						setSoundPaused(bgPreMusic, true)

					end

				end



				if isElement(bgWinMusic) then

					setSoundVolume(bgWinMusic, 1)

				end

			end

		end

	end

end



---------------------------------------------------------------------------------------------



function rotatePoint(angle, pointX, pointY, centerX, centerY)

	angle = math.rad(angle)



	local cosAngle = math.cos(angle)

	local sinAngle = math.sin(angle)



	-- translate point back to origin

	pointX = pointX - centerX

	pointY = pointY - centerY



	-- rotate point

	local rotatedX = pointX * cosAngle - pointY * sinAngle

	local rotatedY = pointX * sinAngle + pointY * cosAngle



	-- translate point back

	pointX = rotatedX + centerX

	pointY = rotatedY + centerY



	return pointX, pointY

end



local function getBezierValue(t, a, b)

	return (((1 - 3 * b + 3 * a) * t + (3 * b - 6 * a)) * t + (3 * a)) * t

end



local function getBezierSlope(t, a, b)

	return 3 * (1 - 3 * b + 3 * a) * t * t + 2 * (3 * b - 6 * a) * t + (3 * a)

end



function createBezierEasing(x1, y1, x2, y2)

	local newtonIterations = 4

	local newtonMinimumSlope = 0.001



	local subdivisionPrecision = 0.0000001

	local subdivisionMaxIterations = 11



	local sampleTableSize = 11

	local sampleStepSize = 1 / (sampleTableSize - 1)



	local sampleValues = {}



	if x1 ~= y1 or x2 ~= y2 then

		for i = 1, sampleTableSize do

			sampleValues[i] = getBezierValue(sampleStepSize * (i - 1), x1, x2)

		end

	end



	local function findNewFractionOfTime(timeFraction)

		local intervalStart = 0

		local currentSample = 1



		while currentSample ~= sampleTableSize and sampleValues[currentSample] <= timeFraction do

			intervalStart = intervalStart + sampleStepSize

			currentSample = currentSample + 1

		end



		currentSample = currentSample - 1



		local currSampleValue = sampleValues[currentSample]

		local nextSampleValue = sampleValues[currentSample + 1]



		local distanceFactor = (timeFraction - currSampleValue) / (nextSampleValue - currSampleValue)

		local guessForTime = intervalStart + distanceFactor * sampleStepSize

		local initialSlope = getBezierSlope(guessForTime, x1, x2)



		if initialSlope == 0 then

			return guessForTime

		-- Newton Raphson Iteration

		elseif initialSlope >= newtonMinimumSlope then

			for i = 1, newtonIterations do

				local currentSlope = getBezierSlope(guessForTime, x1, x2)



				if currentSlope == 0 then

					return guessForTime

				end



				local currentTime = getBezierValue(guessForTime, x1, x2) - timeFraction



				if currentTime ~= 0 then

					guessForTime = guessForTime - currentTime / currentSlope

				end

			end

			return guessForTime

		-- Binary Subdivide

		else

			local intervalEnd = intervalStart + sampleStepSize

			local currentValue = 0

			local currentTime = 0

			local iteratorIndex = 1



			while math.abs(currentValue) > subdivisionPrecision and iteratorIndex < subdivisionMaxIterations do

				iteratorIndex = iteratorIndex + 1



				currentTime = intervalStart + (intervalEnd - intervalStart) * 0.5

				currentValue = getBezierValue(currentTime, x1, x2) - timeFraction



				if currentValue > 0 then

					intervalEnd = currentTime

				else

					intervalStart = currentTime

				end

			end



			return currentTime

		end

	end



	return function (timeFraction)

		if x1 == y1 and x2 == y2 then

			return timeFraction

		end



		if timeFraction == 0 then

			return 0

		elseif timeFraction == 1 then

			return 1

		end



		return getBezierValue(findNewFractionOfTime(timeFraction), y1, y2)

	end

end

