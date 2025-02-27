screenX, screenY = guiGetScreenSize()
local openTick = 0

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

local skinShopPed = createPed(177, 2149.7451171875, -85.8837890625, 2.7438673973083, 90)
setPedAnimation(skinShopPed, "police", "coptraf_come")
setElementData(skinShopPed, "a.Pedname", "Ruhabolt")
setElementData(skinShopPed, "invulnerable", true)
setElementInterior(skinShopPed, 0)
setElementDimension(skinShopPed, 0)
setElementFrozen(skinShopPed, true)


local sizeX, sizeY = respc(900), respc(500);
local startX, startY = screenX / 2 - sizeX / 2, screenY / 2 - sizeY / 2;

function pedProbalnaPofazni()
    cancelEvent()
end
addEventHandler("onClientPedVoice", skinShopPed, pedProbalnaPofazni)

local panelW, panelH = respc(360), respc(150)
local panelX, panelY = screenX / 2 - panelW / 2, screenY / 2 + panelH * 2

local genderpanelW, genderpanelH = respc(360), respc(150)
local genderpanelX, genderpanelY = screenX / 2 - panelW / 2, screenY / 2 - panelH / 2

local headerHeight = respc(30)

local barlowBoldSmall = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(13), false, "cleartype")
local barlowRegularSmall = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(13), false, "cleartype")
local barlowRegularSmallest = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(11), false, "cleartype")

local buttonW, buttonH = respc(160), respc(30)
local buttonX, buttonY = panelX, panelY

local genderbuttonW, genderbuttonH = respc(130), respc(30)
local genderbuttonX, genderbuttonY = genderpanelX, genderpanelY

local panelState = false
local genderPanelState = false

function clickToElement(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" and state == "down" or button == "right" and state == "down" then

        if isElement(clickedElement) and clickedElement == skinShopPed then 
			
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
			local sourceX, sourceY, sourceZ = getElementPosition(clickedElement)
			
			if getDistanceBetweenPoints3D(playerX, playerY, playerZ, sourceX, sourceY, sourceZ) <= 3 and not getElementData(localPlayer, "inSkinShop") then 
				genderPanelState = true
                playSound("files/open.wav")
                showChat(false)
                setElementData(localPlayer, "a.HUDshowed", false)
                setElementData(localPlayer, "inSkinShop", true)
                openTick = getTickCount()
			end
		end


        local currentY = startY2

        if panelState then
        for i = 1 + scrollOffset, math.min(#skins[selectedGender], maxVisibleItems + scrollOffset) do

            local currentY = startY2 + itemHeight * (i - 1 - scrollOffset)

            local skin = skins[selectedGender][i]
            local skinId = skin[1]
            local price = skin[2]

            local totalItems = #skins[selectedGender]
            local textHeight = itemHeight * (i - scrollOffset)

            if totalItems <= maxVisibleItems then
                if isMouseInPosition(startX + respc(5), panelStartY + currentY, sizeX / 2.89 + respc(3), respc(40)) then
                    selectedSkin = i
                    setElementModel(skinPed, skinId)
                end
            elseif isMouseInPosition(startX + respc(5), panelStartY + currentY, sizeX / 3, respc(40)) then
                selectedSkin = i
                setElementModel(skinPed, skinId)
            end
        end
    end


        if activeButtons == "closePanel" then
            genderPanelState = false
            removeEventHandler("renderGenderSelect", getRootElement(), renderGenderSelect)
        elseif activeButton == "closePanel" then
            panelState = false
            showChat(true)
            setElementData(localPlayer, "a.HUDshowed", true)
            setElementData(localPlayer, "inSkinShop", false)
            destroyElement(skinPed)
            removeEventHandler("renderThePanel", getRootElement(), renderThePanel)
        elseif activeButton == "male" then
            genderPanelState = false
            openTick = getTickCount()
            selectedGender = "male"
            panelState = true
            toggleAllControls(false)
            playSound("files/open.wav")
            createSkinObjectPreviewInPanel()
            selectedSkin = 1
        elseif activeButton == "female" then
            genderPanelState = false
            openTick = getTickCount()
            selectedGender = "female"
            panelState = true
            toggleAllControls(false)
            playSound("files/open.wav")
            createSkinObjectPreviewInPanel()
            selectedSkin = 1
        elseif activeButton == "premium" then
            genderPanelState = false
            openTick = getTickCount()
            selectedGender = "premium"
            panelState = true
            toggleAllControls(false)
            playSound("files/open.wav")
            createSkinObjectPreviewInPanel()
            selectedSkin = 1
        elseif activeButton == "buy" then
            tryToBuy()
        end
	end
end
addEventHandler("onClientClick", getRootElement(), clickToElement)


scrollOffset = 0
maxVisibleItems = 11
itemHeight = respc(45)
startY2 = respc(10)


scrollBarX = startX + respc(310)
scrollBarY = respc(10)
scrollBarWidth = respc(10)
scrollBarHeight = respc(190)
scrollBarMaxHeight = respc(490)


lastScrollBarPosition = 0  
scrollBarSpeed = 0.1  

function calculateScrollBar()
    local totalItems = #skins[selectedGender]

    if totalItems <= maxVisibleItems then
        return 0, 0 
    end

    local totalHeight = totalItems * itemHeight
    local visibleHeight = maxVisibleItems * itemHeight
    local scrollBarLength = math.min((visibleHeight / totalHeight) * scrollBarMaxHeight, scrollBarMaxHeight)
    local scrollBarPosition = (scrollOffset / (totalItems - maxVisibleItems)) * (scrollBarMaxHeight - scrollBarLength)

    return scrollBarPosition, scrollBarLength
end

function onScroll(key, press)
    if panelState and isMouseInPosition(startX + respc(2), panelStartY + respc(2), sizeX / 2.8, sizeY - respc(5)) then
        if key == "mouse_wheel_up" then
            scrollOffset = math.max(scrollOffset - 1, 0)
        elseif key == "mouse_wheel_down" then
            local totalItems = #skins[selectedGender]
            scrollOffset = math.min(scrollOffset + 1, math.max(totalItems - maxVisibleItems, 0))
        end
    end
end
addEventHandler("onClientKey", root, onScroll)

function smoothScrollBarMovement(currentPosition, targetPosition)
    return interpolateBetween(currentPosition, 0, 0, targetPosition, 0, 0, scrollBarSpeed, "Linear")
end

function renderThePanel()
	buttons = {}
    local nowTick = getTickCount()
    local elapsedTime = nowTick - openTick
    local duration = elapsedTime / 500
    a, panelStartY = interpolateBetween(0, startY + respc(50), 0, 255, startY, 0, duration, "Linear")
    if panelState then
        dxDrawRectangle(0, 0, screenX, screenY, tocolor(20, 20, 20, 150))

        dxDrawText("alpha", startX + respc(2), panelStartY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldSmall, "left", "center")
		dxDrawText("SKINSHOP", startX + respc(3.5) + dxGetTextWidth("alpha", 1, barlowBoldSmall), panelStartY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowRegularSmall, "left", "center")

        dxDrawRoundedRectangle(startX, panelStartY, sizeX, sizeY, 3, tocolor(35, 35, 35, a)) 
		dxDrawFadeRectangle(startX, panelStartY, sizeX, sizeY, {20, 20, 20, a})

        dxDrawRoundedRectangle(startX + respc(2), panelStartY + respc(2), sizeX / 2.8, sizeY - respc(5), 3, tocolor(35, 35, 35, a)) 

        dxDrawText("Skin Id: " .. skins[selectedGender][selectedSkin][1], startX + (sizeX / 4) * 2.5 + respc(70), panelStartY + respc(20), _, _, tocolor(200, 200, 200, a), 1, barlowRegularSmallest, "center", "center")

        dxDrawText("Kilépéshez használd a(z) <BACKSPACE> gombot.", screenX / 2 + respc(25), panelStartY + sizeY + respc(40), _, _, tocolor(200, 200, 200, a), 0.65, barlowRegularSmall, "center", "center")

        dxDrawText("Navigáláshoz használhatod a kurzorod, vagy a fel/le nyilakat.", screenX / 2 + respc(25), panelStartY + sizeY + respc(15), _, _, tocolor(200, 200, 200, a), 0.65, barlowRegularSmall, "center", "center")

        dxDrawImage(startX + sizeX / 2 - respc(60), panelStartY + startY / 3 - respc(100), sizeX / 2 + respc(30), sizeY - respc(55) + respc(30), ":dAccount/files/img/logo.png", 0, 0, 0, tocolor(255, 255, 255, 10))


        createButton("buy", "Vásárlás", screenX / 2 + respc(90), panelStartY + sizeY - respc(50), buttonW, buttonH, {124, 197, 118})

        local currentY = startY2

        for i = 1 + scrollOffset, math.min(#skins[selectedGender], maxVisibleItems + scrollOffset) do
            local skin = skins[selectedGender][i]
            local skinId = skin[1]
            local price = skin[2]


            local totalItems = #skins[selectedGender]
            local isSelected = (selectedSkin == i)

            if totalItems <= maxVisibleItems then
                if isMouseInPosition(startX + respc(5), panelStartY - respc(5) + currentY, sizeX / 2.89 + respc(3), respc(40)) then
                    dxDrawRoundedRectangle(startX + respc(5), panelStartY - respc(5) + currentY, sizeX / 2.89 + respc(3), respc(40), 3, tocolor(40, 40, 40, a))
                elseif isSelected then
                    dxDrawRoundedRectangle(startX + respc(5), panelStartY - respc(5) + currentY, sizeX / 2.89 + respc(3), respc(40), 3, tocolor(40, 40, 40, a))
                else
                    dxDrawRoundedRectangle(startX + respc(5), panelStartY - respc(5) + currentY, sizeX / 2.89 + respc(3), respc(40), 3, tocolor(50, 50, 50, a))
                end
            else
                if isMouseInPosition(startX + respc(5), panelStartY - respc(5) + currentY, sizeX / 3, respc(40)) then
                    dxDrawRoundedRectangle(startX + respc(5), panelStartY - respc(5) + currentY, sizeX / 3, respc(40), 3, tocolor(40, 40, 40, a))
                elseif isSelected then
                    dxDrawRoundedRectangle(startX + respc(5), panelStartY - respc(5) + currentY, sizeX / 3, respc(40), 3, tocolor(40, 40, 40, a))
                else
                    dxDrawRoundedRectangle(startX + respc(5), panelStartY - respc(5) + currentY, sizeX / 3, respc(40), 3, tocolor(50, 50, 50, a))
                end
            end

            dxDrawText("Skin ID: " .. skinId, startX + respc(10), panelStartY + respc(5) + currentY, _, _, tocolor(255, 255, 255, a), 0.85, barlowRegularSmall, "left", "center")
            if selectedGender == "premium" then
                dxDrawText("Ár: ".. num_formatting(price) .. " PP", startX + respc(10), panelStartY + respc(5) + currentY + respc(20), _, _, tocolor(200, 200, 200, a), 0.85, barlowRegularSmall, "left", "center")
            else
                dxDrawText("Ár: ".. num_formatting(price) .. "$", startX + respc(10), panelStartY + respc(5) + currentY + respc(20), _, _, tocolor(200, 200, 200, a), 0.85, barlowRegularSmall, "left", "center")
            end

            currentY = currentY + itemHeight
        end

        local scrollBarPosition, scrollBarLength = calculateScrollBar()

        lastScrollBarPosition = smoothScrollBarMovement(lastScrollBarPosition, scrollBarPosition)

        dxDrawRectangle(scrollBarX, panelStartY + scrollBarY + lastScrollBarPosition - respc(5), scrollBarWidth, scrollBarLength, tocolor(70, 70, 70, a))
    end
    
    if panelState then 
        buttons.buy = {buttonX + respc(7) + buttonW + respc(110), panelStartY + startY * 1.55, buttonW, buttonH}
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
    local nowTick = getTickCount()
    local elapsedTime = nowTick - openTick
    local duration = elapsedTime / 500
    a, genderpanelStartY = interpolateBetween(0, genderpanelY + respc(50), 0, 255, genderpanelY, 0, duration, "Linear")


    if genderPanelState then
        dxDrawFadeRectangle(genderpanelX, genderpanelStartY, genderpanelW, genderpanelH, {20, 20, 20, a})

        dxDrawRectangle(0, 0, screenX, screenY, tocolor(20, 20, 20, 150))

        dxDrawText("alpha", genderpanelX + respc(2), genderpanelStartY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldSmall, "left", "center")
        dxDrawText("SKINSHOP", genderpanelX + respc(3.5) + dxGetTextWidth("alpha", 1, barlowBoldSmall), genderpanelStartY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowRegularSmall, "left", "center")

        dxDrawText("Válassz kategóriát!", genderpanelX + respc(100), genderpanelStartY + headerHeight - respc(15), genderpanelX + genderpanelW, genderpanelY + genderpanelH - headerHeight, tocolor(200, 200, 200, a), 1, barlowRegularSmall)
        dxDrawText("Kilépéshez használd a(z) <BACKSPACE> gombot.", genderpanelX + respc(42), genderpanelStartY + respc(125), genderpanelX + genderpanelW, genderpanelY + genderpanelH - headerHeight, tocolor(200, 200, 200, a), 0.65, barlowRegularSmall)


        createButton("male", "  Férfi skinek", genderbuttonX + respc(7) + genderbuttonW - respc(92), genderpanelStartY + genderpanelH - genderbuttonH - respc(70), genderbuttonW, genderbuttonH, {153, 184, 152, a})
        createButton("female", "  Női skinek", genderbuttonX + respc(7) + genderbuttonW + respc(48), genderpanelStartY + genderpanelH - genderbuttonH - respc(70), genderbuttonW, genderbuttonH, {232, 74, 95, a})
        createButton("premium", "  Prémium skinek", genderbuttonX + respc(7) + genderbuttonW - respc(23), genderpanelStartY + genderpanelH - genderbuttonH - respc(32), genderbuttonW, genderbuttonH, {240, 220, 120, a})

        buttons.male = {genderbuttonX + respc(7) + genderbuttonW + respc(-92), genderbuttonY + genderpanelH - genderbuttonH - respc(45), genderbuttonW, genderbuttonH}
        buttons.female = {genderbuttonX + respc(7) + genderbuttonW + respc(48), genderbuttonY + genderpanelH - genderbuttonH - respc(45), genderbuttonW, genderbuttonH}
        buttons.premium = {genderbuttonX + respc(7) + genderbuttonW + respc(-23), genderbuttonY + genderpanelH - genderbuttonH - respc(7), genderbuttonW, genderbuttonH}
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
        if getPlayerSkin(localPlayer) == skins[selectedGender][selectedSkin][1] then
            exports.dInfobox:makeNotification(2, "Jelenleg ez a skin van rajtad!")
            return
        end
		if selectedGender == "premium" then
			if getElementData(localPlayer, "a.Premiumpont") >= skins[selectedGender][selectedSkin][2] then
				setElementData(localPlayer, "a.Premiumpont", getElementData(localPlayer, "a.Premiumpont")-skins[selectedGender][selectedSkin][2])
				
                exports.dInfobox:makeNotification(1, "Sikeresen megvásároltad a kiválasztott skin-t!")

				triggerServerEvent("changePlayerSkin", localPlayer, localPlayer, skins[selectedGender][selectedSkin][1])

				destroyElement(skinPed)
                toggleAllControls(true)
                setElementData(localPlayer, "a.HUDshowed", true)
                setElementData(localPlayer, "inSkinShop", false)
                playSound("files/open.wav")
				panelState = false
				showChat(true)
			else
                exports.dInfobox:makeNotification(2, "Nincs elég PP-d!")
			end
		else
			if getElementData(localPlayer, "a.Money") >= skins[selectedGender][selectedSkin][2] then
				setElementData(localPlayer, "a.Money", getElementData(localPlayer, "a.Money")-skins[selectedGender][selectedSkin][2])
				
                exports.dInfobox:makeNotification(1, "Sikeresen megvásároltad a kiválasztott skin-t!")

				triggerServerEvent("changePlayerSkin", localPlayer, localPlayer, skins[selectedGender][selectedSkin][1])
				
				destroyElement(skinPed)
                toggleAllControls(true)
                setElementData(localPlayer, "a.HUDshowed", true)
                setElementData(localPlayer, "inSkinShop", false)
                playSound("files/open.wav")
				panelState = false
				showChat(true)
			else
                exports.dInfobox:makeNotification(2, "Nincs elég pénzed!")
			end
		end
	end
end

bindKey("arrow_u", "down", function()
	if panelState then
		if selectedSkin > 1 then
			selectedSkin = selectedSkin-1
			setPedNewSkin()
		end
	end
end)

bindKey("arrow_d", "down", function()
	if panelState then
		if selectedSkin < #skins[selectedGender] then
			selectedSkin = selectedSkin+1
			setPedNewSkin()
		end
	end
end)

bindKey("backspace", "down", function()
	if panelState then
        destroySkinObjectPreviewInPanel()
        panelState = false
        toggleAllControls(true)
        genderPanelState = true
        playSound("files/open.wav")
    elseif genderPanelState then
        genderPanelState = false
        showChat(true)
        setElementData(localPlayer, "a.HUDshowed", true)
        setElementData(localPlayer, "inSkinShop", false)
        playSound("files/open.wav")
    end
end)

function setPedNewSkin()
	setElementModel(skinPed, skins[selectedGender][selectedSkin][1])
end

function createSkinObjectPreviewInPanel()
	if isElement(skinPed) then
		return
	end

    local poses = {"clo_pose_hat", "clo_pose_legs", "clo_pose_shoes", "clo_pose_torso", "clo_pose_watch"}

    local randomIndex = math.random(1, #poses)

    local randomPose = poses[randomIndex]

    selectedSkin = 1

	skinPed = createPed(skins[selectedGender][selectedSkin][1], 0, 0, 0)
	exports.d3dview:createObjectPreview(skinPed, 0, 0, 90, sizeX / 2 + startX - respc(50), startY - respc(25), sizeX / 2, sizeY - respc(20), false, true)
	setPedAnimation(skinPed, "clothes", randomPose)
end

function destroySkinObjectPreviewInPanel()
	if not isElement(skinPed) then
		return
	end

	exports.d3dview:destroyObjectPreview(skinPed)
	destroyElement(skinPed)
end

function num_formatting(amount)
	local formatted = amount
	while true do  
	  	formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
	  	if (k==0) then
			break
	  	end
	end
	return formatted
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

local topTexture = dxCreateTexture("files/img/featherTop.dds", "dxt5", true, "clamp")
local sideTexture = dxCreateTexture("files/img/feather.dds", "dxt5", true, "clamp")
local cornerTexture = dxCreateTexture("files/img/corner.dds", "dxt5", true, "clamp")

function dxDrawFadeRectangle(x, y, w, h, color)
    x = x - 5
    y = y - 5
    w = w + 10
    h = h + 10
    if color[4] < 10 then
        return
    end
    
    dxDrawRectangle(x + 10, y + 10, w - 20, h - 20, tocolor(color[1], color[2], color[3], color[4] - 15))
    color = tocolor(color[1], color[2], color[3], color[4])
    dxDrawImage(x, y, 10, 10, cornerTexture, 270, 0, 0, color)
    dxDrawImage(x + w - 10, y, 10, 10, cornerTexture, 0, 0, 0, color)
    dxDrawImage(x, y + h - 10, 10, 10, cornerTexture, 180, 0, 0, color)
    dxDrawImage(x + w - 10, y + h - 10, 10, 10, cornerTexture, 90, 0, 0, color)

    dxDrawImage(x + 10, y + 10, w - 20, -10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + h - 10, w - 20, 10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + 10, -10, h - 20, sideTexture, 0, 0, 0, color)
    dxDrawImage(x + w - 10, y + 10, 10, h - 20, sideTexture, 0, 0, 0, color)
end

local thisResource = getThisResource()
local resRoot = getResourceRootElement(thisResource)

addEventHandler( "onClientResourceStop", resRoot,
    function ()
        setElementData(localPlayer, "inSkinShop", false)
        showChat(true)
        setElementData(localPlayer, "a.HUDshowed", true)
        toggleAllControls(true)
    end
);