screenX, screenY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local skinShopPed = createPed(69, 2149.7451171875, -85.8837890625, 2.7438673973083, 90)
setElementData(skinShopPed, "a.Pedname", "Ruhabolt")
setElementData(skinShopPed, "invulnerable", true)
setElementInterior(skinShopPed, 0)
setElementDimension(skinShopPed, 0)
setElementFrozen(skinShopPed, true)

function pedProbalnaPofazni()
    cancelEvent()
end
addEventHandler("onClientPedVoice", skinShopPed, pedProbalnaPofazni)

local panelW, panelH = respc(360), respc(150)
local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 + panelH * 2

local genderpanelW, genderpanelH = respc(360), respc(150)
local genderpanelX, genderpanelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

local headerHeight = respc(30)

local panelColors = {
	background = tocolor(25, 25, 25, 255),
	header = tocolor(0, 0, 0, 255),
	input = tocolor(0, 0, 0, 120)
}

local panelTexts = {
	main = "VisionMTA - Skin shop",
    xtext = "Bezárás"
}

local fontColors = {
	main = tocolor(200, 200, 200, 255),
    xtext = tocolor(215, 89, 89, 255)
}

panelFont = dxCreateFont("files/BebasNeueLight.otf", respc(16), false, "antialiased")


local inputW, inputH = respc(330), respc(30)
local inputX, inputY = panelX + respc(5), panelY + headerHeight + respc(5)
local buttonW, buttonH = respc(160), respc(30)
local buttonX, buttonY = panelX, panelY

local genderinputW, genderinputH = respc(330), respc(30)
local genderinputX, genderinputY = genderpanelX + respc(5), genderpanelY + headerHeight + respc(5)
local genderbuttonW, genderbuttonH = respc(130), respc(30)
local genderbuttonX, genderbuttonY = genderpanelX, genderpanelY

local panelState = false
local genderPanelState = false

function clickToElement(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" and state == "down" then

        if isElement(clickedElement) and clickedElement == skinShopPed then 
			
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local sourceX, sourceY, sourceZ = getElementPosition(clickedElement)
			
			if getDistanceBetweenPoints3D(playerX, playerY, playerZ, sourceX, sourceY, sourceZ) <= 3 then 
				genderPanelState = true
                --outputChatBox("ez meg nem jo, hiaba nezed", 255, 255, 255, true)
			end
		end

		--print(activeButton)


        if activeButtons == "closePanel" then
            genderPanelState = false
            removeEventHandler("renderGenderSelect", getRootElement(), renderGenderSelect)
        elseif activeButton == "closePanel" then
            panelState = false
            destroyElement(skinPed)
		    setCameraTarget(localPlayer)
            removeEventHandler("renderThePanel", getRootElement(), renderThePanel)
        elseif activeButton == "male" then
            genderPanelState = false
            selectedGender = "male"
            createTryingPed()
        elseif activeButton == "female" then
            genderPanelState = false
            selectedGender = "female"
            createTryingPed()
        elseif activeButton == "premium" then
            genderPanelState = false
            selectedGender = "premium"
            createTryingPed()
        elseif activeButton == "buy" then
            destroyElement(skinPed)
		    setCameraTarget(localPlayer)
            tryToBuy()
            panelState = false
        end
	end
end
addEventHandler("onClientClick", getRootElement(), clickToElement)

function createTryingPed()
	panelState = true
    genderPanelState = false

	setCameraMatrix(2102.6416015625, -100.1630859375, 2.2737467288971, 2102.6416015625, -104.1630859375, 2.2737467288971)

	selectedSkin = 1

	rotationX = 0
	skinPed = createPed(skins[selectedGender][selectedSkin][1], 2102.6416015625, -104.1630859375, 2.2737467288971, rotationX)
    setElementInterior(skinPed, 0)
    setElementDimension(skinPed, 0)
end

function renderThePanel()
	buttons = {}
    if panelState then

        dxDrawText("alpha", panelX + respc(2), panelY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, panelFont, "left", "center")
        dxDrawText("SKINSHOP", panelX + respc(3.5) + dxGetTextWidth("alpha", 1, panelFont), panelY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, panelFont, "left", "center")

	    dxDrawRoundedRectangle(panelX, panelY, panelW, panelH, 3, tocolor(35, 35, 35, a))

        -- dxDrawRectangle(panelX, panelY, panelW, panelH, panelColors.background)
        -- dxDrawRectangle(panelX, panelY, panelW, headerHeight, panelColors.header)
        -- ** text
        dxDrawText(panelTexts.main, panelX + respc(5), panelY, panelX + panelW, panelY + panelH - headerHeight, fontColors.main, 1, panelFont)
        dxDrawText(panelTexts.xtext, panelX + respc(300), panelY, panelX + panelW, panelY + panelH - headerHeight, gombColor, 1, panelFont)
        dxDrawText("Választott Skin ID: "..skins[selectedGender][selectedSkin][1].."", panelX + respc(105), panelY + headerHeight + respc(5), panelX + panelW, panelY + panelH - headerHeight, fontColors.main, 1, panelFont)
        if selectedGender == "premium" then
            dxDrawText("Ár: "..skins[selectedGender][selectedSkin][2].." PP", panelX + respc(145), panelY + headerHeight + respc(30), panelX + panelW, panelY + panelH - headerHeight, fontColors.main, 1, panelFont)
        else
            dxDrawText("Ár: "..skins[selectedGender][selectedSkin][2].."$", panelX + respc(145), panelY + headerHeight + respc(30), panelX + panelW, panelY + panelH - headerHeight, fontColors.main, 1, panelFont)
        end


        createButton("buy", "Vásárlás", buttonX + respc(7) + buttonW + respc(-67), buttonY + panelH - buttonH - respc(7), buttonW, buttonH, {124, 197, 118})
    end
    
    if panelState then 
        if activeButton == "closePanel" then
            gombColor = tocolor(215, 89, 89, 255)
        else
            gombColor = tocolor(200, 200, 200, 255)
        end
    
    if panelState then 
        if activeButton == "closePanel" then
            gombColor = tocolor(215, 89, 89, 255)
        else
            gombColor = tocolor(200, 200, 200, 255)
        end
        
        buttons.closePanel = {panelX + respc(300), panelY, respc(60), headerHeight} 
        buttons.buy = {buttonX + respc(7) + buttonW + respc(-23), buttonY + panelH - buttonH - respc(7), buttonW, buttonH}
        --dxDrawRectangle(buttonX + respc(-152) + buttonW, buttonY + panelH - buttonH - respc(85), respc(70), buttonH, tocolor(200, 200, 200, 200))
    end
end

    local relX, relY = getCursorPosition()

    activeButton = false

    if relX and relY then
        relX = relX * screenX
        relY = relY * screenY

        for k, v in pairs(buttons) do
            if relX >= v[1] and relY >= v[2] and relX <= v[1] + v[3] and relY <= v[2] + v[4] then
                activeButton = k
                break
            end
        end
    end
end
addEventHandler("onClientRender", getRootElement(), renderThePanel)

function renderGenderSelect()
	buttons = {}
    if genderPanelState then

        dxDrawText("alpha", genderpanelX + respc(2), genderpanelY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, panelFont, "left", "center")
        dxDrawText("SKINSHOP", genderpanelX + respc(3.5) + dxGetTextWidth("alpha", 1, panelFont), genderpanelY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, panelFont, "left", "center")

	    dxDrawRoundedRectangle(genderpanelX, genderpanelY, genderpanelW, genderpanelH, 3, tocolor(35, 35, 35, a))
        dxDrawText("Válassz kategóriát!", genderpanelX + respc(113), genderpanelY + headerHeight - respc(15), genderpanelX + genderpanelW, genderpanelY + genderpanelH - headerHeight, fontColors.main, 1, panelFont)


        createButton("male", "  Férfi skinek", genderbuttonX + respc(7) + genderbuttonW + respc(-92), genderbuttonY + genderpanelH - genderbuttonH - respc(45), genderbuttonW, genderbuttonH, {124, 197, 118})
        createButton("female", "  Női skinek", genderbuttonX + respc(7) + genderbuttonW + respc(48), genderbuttonY + genderpanelH - genderbuttonH - respc(45), genderbuttonW, genderbuttonH, {124, 197, 118})
        createButton("premium", "  Prémium skinek", genderbuttonX + respc(7) + genderbuttonW + respc(-23), genderbuttonY + genderpanelH - genderbuttonH - respc(7), genderbuttonW, genderbuttonH, {73, 154, 242})
    end
    
    if genderPanelState then 
        if activeButtons == "closePanel" then
            bezarColor = tocolor(215, 89, 89, 255)
        else
            bezarColor = tocolor(200, 200, 200, 255)
        end

    if genderPanelState then 
        if activeButtons == "kurva" then
            gombColor = tocolor(215, 89, 89, 255)
        else
            gombColor = tocolor(200, 200, 200, 255)
        end

        -- buttons.closePanel = {genderpanelX + respc(300), genderpanelY, respc(60), headerHeight}
        buttons.kurva = {genderpanelX + respc(3000), genderpanelY, respc(60), headerHeight}
        buttons.male = {genderbuttonX + respc(7) + genderbuttonW + respc(-92), genderbuttonY + genderpanelH - genderbuttonH - respc(45), genderbuttonW, genderbuttonH}
        buttons.female = {genderbuttonX + respc(7) + genderbuttonW + respc(48), genderbuttonY + genderpanelH - genderbuttonH - respc(45), genderbuttonW, genderbuttonH}
        buttons.premium = {genderbuttonX + respc(7) + genderbuttonW + respc(-23), genderbuttonY + genderpanelH - genderbuttonH - respc(7), genderbuttonW, genderbuttonH}
        --dxDrawRectangle(genderpanelX + respc(300), genderpanelY, respc(60), headerHeight, tocolor(200, 200, 200, 200))
    end
end

    local relX, relY = getCursorPosition()

    activeButtons = false

    if relX and relY then
        relX = relX * screenX
        relY = relY * screenY

        for k, v in pairs(buttons) do
            if relX >= v[1] and relY >= v[2] and relX <= v[1] + v[3] and relY <= v[2] + v[4] then
                activeButtons = k
                break
            end
        end
    end
end
addEventHandler("onClientRender", getRootElement(), renderGenderSelect)

function tryToBuy()
	if panelState then
		if selectedGender == "premium" then
			if getElementData(localPlayer, "acc.pp") >= skins[selectedGender][selectedSkin][2] then
				setElementData(localPlayer, "acc.pp", getElementData(localPlayer, "acc.pp")-skins[selectedGender][selectedSkin][2])
				
				outputChatBox("#7CC576[VisionMTA - Siker]: #FFFFFFSikeresen megvásároltad a kiválasztott kinézetet a #7CC576"..selectedGender.."#FFFFFF kategóriában! ID: #7CC576"..skins[selectedGender][selectedSkin][1].." ("..skins[selectedGender][selectedSkin][2].." PP)", 0, 0, 0, true)
				
				setElementData(localPlayer, "acc.Skin", skins[selectedGender][selectedSkin][1])
				triggerServerEvent("changePlayerSkin", localPlayer, localPlayer, skins[selectedGender][selectedSkin][1])
				
				panelState = false
				showChat(true)
			else
				outputChatBox("#D75959[VisionMTA - Hiba]: #FFFFFFNincs elég PP-d. #D75959(" .. skins[selectedGender][selectedSkin][2] .. ")", 0, 0, 0, true)
			end
		else
			if getElementData(localPlayer, "acc.Money") >= skins[selectedGender][selectedSkin][2] then
				setElementData(localPlayer, "acc.Money", getElementData(localPlayer, "acc.Money")-skins[selectedGender][selectedSkin][2])
				
				outputChatBox("#7CC576[VisionMTA - Siker]: #FFFFFFSikeresen megvásároltad a kiválasztott kinézetet a #7CC576"..selectedGender.."#FFFFFF kategóriában! ID: #7CC576"..skins[selectedGender][selectedSkin][1].." ("..skins[selectedGender][selectedSkin][2].."$)", 0, 0, 0, true)
				
				setElementData(localPlayer, "acc.Skin", skins[selectedGender][selectedSkin][1])
				triggerServerEvent("changePlayerSkin", localPlayer, localPlayer, skins[selectedGender][selectedSkin][1])
				
				panelState = false
				showChat(true)
			else
				outputChatBox("#D75959[VisionMTA - Hiba]: #FFFFFFNincs elég pénzed #D75959(" .. skins[selectedGender][selectedSkin][2] .. "$)", 0, 0, 0, true)
			end
		end
	end
end

bindKey("arrow_l", "down", function()
	if panelState then
		if selectedSkin > 1 then
			selectedSkin = selectedSkin-1
			setPedNewSkin()
		end
	end
end)

bindKey("arrow_r", "down", function()
	if panelState then
		if selectedSkin < #skins[selectedGender] then
			selectedSkin = selectedSkin+1
			setPedNewSkin()
		end
	end
end)

bindKey("backspace", "down", function()
	if panelState then
        panelState = false
        destroyElement(skinPed)
		setCameraTarget(localPlayer)
    elseif genderPanelState then
        genderPanelState = false
    end
end)

function setPedNewSkin()
	setElementModel(skinPed, skins[selectedGender][selectedSkin][1])
end

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end