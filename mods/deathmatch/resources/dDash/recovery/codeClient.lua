local sX, sY = guiGetScreenSize();

function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(sX, 720, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

function getResponsiveMultipler()
	return responsiveMultipler
end

local sizeX, sizeY = respc(900), respc(500);
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
local panelSize = {sizeX, sizeY}

local dashboardIsOpen = false
local currentPage = 1
local currentGroupPage = 1
local currentlyCreatingGroup = false

local headerFont = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(13), false, "cleartype")
local normalFont = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(13), false, "cleartype")
local robotoThin = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(10), false, "cleartype")

local barlowBold13 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(11), false, "cleartype")
local barlowBold11 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(9), false, "cleartype")
local barlowBold15 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(13), false, "cleartype")
local barlowRegular13 = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(11), false, "cleartype")
local barlowRegular11 = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(9), false, "cleartype")

local barlowBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(13), false, "cleartype")
local barlowLightBig = dxCreateFont(":dFonts/fonts/Barlow-Light.ttf", respc(13), false, "cleartype")

local dashTabs = {"ÁTTEKINTÉS", "KLÁN", "TOPLISTA", "BEÁLLÍTÁSOK"}
local skinPreview = {}
local topKillers = {}
local maxMembersShowing = 9
local scrollingValue = 0

if fileExists("codeClient.lua") then
	fileDelete("codeClient.lua")
end

function pressedButton(button, pressed)
	if getElementData(localPlayer, "loggedIn") then
		if pressed then
			if button == "home" then
				currentPage = 1
				maxMembersShowing = 9
				scrollingValue = 0
				showPanel()
				buttonTick = getTickCount()
				rotation = 0
				cancelEvent()
			end
		end
	end
end
addEventHandler("onClientKey", root, pressedButton)

function pressedGroupButton(button, pressed) --redirect group
	if getElementData(localPlayer, "loggedIn") then
		if pressed then
			if button == "F3" then
				currentPage = 2
				maxMembersShowing = 9
				scrollingValue = 0
				showPanel()
				buttonTick = getTickCount()
			end
			if dashboardIsOpen and currentPage == 2 and currentGroupPage == 1 and isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2, startY + respc(95), (sizeX - respc(15))/2, sizeY - respc(145)) then			
				if button == "mouse_wheel_up" then
					scrollTick = getTickCount()
					if scrollingValue > 0  then
						scrollingValue = scrollingValue - 1
						maxMembersShowing = maxMembersShowing - 1
					end
				elseif button == "mouse_wheel_down" then
					scrollTick = getTickCount()
					if maxMembersShowing < #playerGroupMembers then
						scrollingValue = scrollingValue + 1
						maxMembersShowing = maxMembersShowing + 1
					end
				end
			end
		end
	end
end
addEventHandler("onClientKey", root, pressedGroupButton)

function showPanel()
	if (dashboardIsOpen == false) then
		dashboardIsOpen = true
		currentlyCreatingGroup = false
		if currentPage == 1 then
			createSkinObjectPreviewInPanel()
		elseif currentPage == 2 then
			exports.dDx:dxCreateEdit("clanPlayerToAdd", "", "Játékos név/ID", startX + respc(5), startY + sizeY - respc(90), (sizeX - respc(15))/2, respc(40), false, 25, 1, a)
		end

		triggerServerEvent("callServerInformations", localPlayer, localPlayer)
	else
		destroySkinObjectPreviewInPanel()
		if currentPage == 2 then
			exports.dDx:dxDestroyEdit("clanPlayerToAdd")
		end

		dashboardIsOpen = false
	end
end

setTimer(function()
	if not getPlayerSerial(localPlayer) == "53987DDB582C0AC8B9CCD506656ACD13" then
        return
	else
		return
    end
	currentPage = 1
	maxMembersShowing = 9
	scrollingValue = 0
	showPanel()
	buttonTick = getTickCount()
	rotation = 0

	createSkinObjectPreviewInPanel()
end, 500, 1)

function createSkinObjectPreviewInPanel()
	if isElement(skinPed) then
		return
	end

	skinPed = createPed(getElementModel(localPlayer), 0, 0, 0)
	exports.d3dview:createObjectPreview(skinPed, 0, 0, 180, startX + sizeX / 2, startY + respc(50), sizeX / 2, sizeY - respc(55), false, true)
	setPedAnimation(skinPed, "CASINO", "Roulette_loop")
	givePedWeapon(skinPed, math.random(0, 38), 999, true)

	--setElementData(getPedWeapon(skinPed), "currentWeaponPaintjob", {1, 31})
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

function mainPanel()
	if (dashboardIsOpen == true) then
		local nowTick = getTickCount()
		local elapsedTime = nowTick - buttonTick
		local duration = elapsedTime / 500
		a, startY = interpolateBetween(0, sY / 2 - sizeY / 2 + respc(30), 0, 255, sY / 2 - sizeY / 2, 0, duration, "Linear")

		dxDrawRoundedRectangle(startX, startY, sizeX, sizeY, 3, tocolor(35, 35, 35, a)) -- alap panel
		dxDrawFadeRectangle(startX, startY, sizeX, sizeY, {20, 20, 20, a})

		dxDrawText("alpha", startX + respc(2), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowBoldBig, "left", "center")
		dxDrawText("DASHBOARD", startX + respc(3.5) + dxGetTextWidth("alpha", 1, barlowBoldBig), startY - respc(12.5), _, _, tocolor(200, 200, 200, a), 1, barlowLightBig, "left", "center")

		for i, v in ipairs(dashTabs) do
			i = i - 1
			local tabW = (sizeX - (respc(5) * (#dashTabs + 1) )) / #dashTabs
			if isMouseInPosition(startX + (tabW + respc(5))*i + respc(5), startY + respc(5), tabW, respc(35)) or currentPage == (i + 1) then
				dxDrawRoundedRectangle(startX + (tabW + respc(5))*i + respc(5), startY + respc(5), tabW, respc(35), 3, tocolor(140, 195, 230, a*0.5))
				dxDrawText(v, startX + (tabW + respc(5))*i + respc(5) + tabW / 2, startY + respc(5) + (respc(35))/2 - 1, _, _, tocolor(200, 200, 200, a), 1, barlowBold13, "center", "center", false, false, false, true)
			else
				dxDrawRoundedRectangle(startX + (tabW + respc(5))*i + respc(5), startY + respc(5), tabW, respc(35), 3, tocolor(45, 45, 45, a))
				dxDrawText(v, startX + (tabW + respc(5))*i + respc(5) + tabW / 2, startY + respc(5) + (respc(35))/2 - 1, _, _, tocolor(175, 175, 175, a), 1, barlowRegular13, "center", "center", false, false, false, true)
			end
		end

		if currentPage == 1 then

			local playerName = getElementData(localPlayer, "a.PlayerName") or "-";

			local playerData = {
				{"Játékosnév: ", (getElementData(localPlayer, "a.PlayerName") or "-")},
				{"Account ID: ", (getElementData(localPlayer, "a.accID") or "-")},
				--{"Pénz: ", num_formatting(getElementData(localPlayer, "a.Money") .. " $" or "0")},
				{"Prémiumpont: ", num_formatting(getElementData(localPlayer, "a.Premiumpont") .. " PP" or "0")},
				{"Játszott percek: ", getElementData(localPlayer, "a.PlayedMinutes") .. " perc = ~" .. math.floor(getElementData(localPlayer, "a.PlayedMinutes")/60) .. " óra" or "0"},
				--{"Adminszint: ", (getElementData(localPlayer, "adminLevel") or "Játékos")},
				-- {"VIP: ", tostring(getElementData(localPlayer, "a.VIP")) .. " - (".. getElementData(localPlayer, "d/VipDuration") .. ")"},
				{"VIP: ", tostring(getElementData(localPlayer, "a.VIP"))},
				{"Némítás: ", tostring(getElementData(localPlayer, "a.Muted"))},
			}

			if (getElementData(localPlayer, "a.Muted")) then
				playerData[6][2] = "Igen"
			else
				playerData[6][2] = "Nem"
			end

			-- if (getElementData(localPlayer, "a.VIP")) then
			-- 	playerData[5][2] = "Igen - (".. getElementData(localPlayer, "d/VipDuration") .. ")"                        JAVÍTÁSRA SZORUL // misi
			-- else
			-- 	playerData[5][2] = "Nem"
			-- end

			if (getElementData(localPlayer, "a.VIP")) then
				playerData[5][2] = "Igen"
			else
				playerData[5][2] = "Nem"
			end
			
			dxDrawImage(startX + sizeX / 2 - respc(15), startY + respc(20), sizeX / 2 + respc(30), sizeY - respc(55) + respc(30), ":dAccount/files/img/logo.png", 0, 0, 0, tocolor(255, 255, 255, 10))
			dxDrawText("Skin ID: " .. getElementModel(localPlayer), startX + (sizeX / 4) * 3, startY + respc(65), _, _, tocolor(200, 200, 200, a), 1, barlowRegular13, "center", "center")

			local bestdrift = getElementData(localPlayer, "a.bestDrift") or "0"
			-- ** INFO RÉSZ START

			halfTabSize = (sizeX - respc(10))/2
			dxDrawRoundedRectangle(startX + respc(5), startY + respc(45), halfTabSize, sizeY - respc(247.5), 3, tocolor(25, 25, 25, a))		
			dxDrawText("> #F1DB76INFORMÁCIÓK #c8c8c8<", startX + respc(5) + halfTabSize/2, startY + respc(45) + respc(17.5), _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "center", "center", false, false, false, true)

			for i, v in ipairs(playerData) do
				i = i - 1
				dxDrawRectangle(startX + respc(10), startY + respc(45) + respc(40) + (i * respc(35)), halfTabSize - respc(10), respc(30), tocolor(40, 40, 40, a))
				dxDrawText(v[1] .. "#8FC3E4" .. v[2], startX + respc(5) + halfTabSize/2, startY + respc(45) + respc(40) + respc(30)/2 + (i * respc(35)), _, _, tocolor(200, 200, 200, a), 1, barlowRegular13, "center", "center", false, false, false, true)	
			end									
		
			-- ** INFO RÉSZ END

			-- ** STAT RÉSZ START
			local playerKills = getElementData(localPlayer, "a.Kills") or 0;
			local playerDeaths = getElementData(localPlayer, "a.Deaths") or 0;

			dxDrawRoundedRectangle(startX + respc(5), startY + respc(302.5), halfTabSize, respc(192.5), 3, tocolor(25, 25, 25, a))		
			dxDrawText("> #F1DB76K/D STATISZTIKA #c8c8c8<", startX + respc(5) + halfTabSize/2, startY + respc(320), _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "center", "center", false, false, false, true)

			killPercentage = 360 * (playerKills / (playerDeaths + playerKills))
			deathPercentage = 360 * (playerDeaths / (playerDeaths + playerKills))

			if (playerKills == 0) and (playerDeaths == 0) then
				dxDrawCircle(startX + respc(100), startY + respc(400), respc(60), 0, 360, tocolor(50, 50, 50, a), tocolor(150, 150, 150, a), 64, 1)
				dxDrawText("0", startX + respc(100), startY + respc(400), _, _, tocolor(255, 255, 255, a), 1, barlowBold13, "center", "center")
			else
				dxDrawCircle(startX + respc(100), startY + respc(400), respc(60), 0, deathPercentage, tocolor(50, 50, 50, a), tocolor(150, 150, 150, a), 64, 1)
				dxDrawCircle(startX + respc(100), startY + respc(400), respc(60), deathPercentage, killPercentage + deathPercentage, tocolor(50, 50, 50, a), tocolor(230, 140, 140, a), 64, 1)
				dxDrawText(getPlayerKD(localPlayer, playerKills, playerDeaths), startX + respc(100), startY + respc(400), _, _, tocolor(255, 255, 255, a), 1, barlowBold13, "center", "center")
			end

			dxDrawText("Ölés-halál eloszlás", startX + respc(100), startY + respc(475), _, _, tocolor(200, 200, 200, a), 1, barlowBold11, "center", "center")

			
			dxDrawCircle(startX + respc(185), startY + respc(380), respc(10), 0, 360, tocolor(50, 50, 50, a), tocolor(150, 150, 150, a), 64, 1)
			dxDrawText("Halálok száma - " .. playerDeaths .. " db", startX + respc(200), startY + respc(380), _, _, tocolor(150, 150, 150, a), 1, barlowRegular11, "left", "center")

			dxDrawCircle(startX + respc(185), startY + respc(410), respc(10), 0, 360, tocolor(50, 50, 50, a), tocolor(230, 140, 140, a), 64, 1)
			dxDrawText("Ölések száma - " .. playerKills .. " db", startX + respc(200), startY + respc(410), _, _, tocolor(230, 140, 140, a), 1, barlowRegular11, "left", "center")

			-- ** STAT RÉSZ END
		elseif currentPage == 2 then
			if buttonTick + 200 > nowTick then
				rotation = rotation + 3
				dxDrawImage(startX + sizeX / 2 - respc(16), startY + sizeY / 2, respc(32), respc(32), "files/img/loading.png", rotation, 0, 0, tocolor(150, 150, 150, a))
			else
				if getElementData(localPlayer, "a.PlayerGroup") == false and currentlyCreatingGroup == false and not justCreatedGroup then -- ha nincs csoportban és nem csinál jelenleg csoportot
					dxDrawText("Jelenleg nem vagy klán tagja.", startX + sizeX / 2, startY + (sizeY - respc(50)) / 2, _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "center", "center")
					dxDrawText("Szeretnél létrehozni egyet? #9BE48F(250.000$)", startX + sizeX / 2, startY + (sizeY - respc(50)) / 2 + respc(25), _, _, tocolor(200, 200, 200, a), 1, barlowRegular13, "center", "center", false, false, false, true)
					
					if isMouseInPosition(startX + sizeX / 2 - respc(150), startY + (sizeY - respc(50))/2 + respc(45), respc(300), respc(35)) then
						dxDrawRoundedRectangle(startX + sizeX / 2 - respc(150), startY + (sizeY - respc(50))/2 + respc(45), respc(300), respc(35), 3, tocolor(140, 195, 230, a*0.5))
						dxDrawText("Létrehozás", startX + sizeX / 2, startY + (sizeY - respc(50))/2 + respc(45) + respc(35)/2, _, _, tocolor(200, 200, 200, a), 1, barlowBold13, "center", "center")	
					else
						dxDrawRoundedRectangle(startX + sizeX / 2 - respc(150), startY + (sizeY - respc(50))/2 + respc(45), respc(300), respc(35), 3, tocolor(65, 65, 65, a))
						dxDrawText("Létrehozás", startX + sizeX / 2, startY + (sizeY - respc(50))/2 + respc(45) + respc(35)/2, _, _, tocolor(150, 150, 150, a), 1, barlowRegular13, "center", "center")		
					end
				end
	
				if currentlyCreatingGroup == true then
					if isMouseInPosition(startX + sizeX / 2 - respc(150), startY + (sizeY - respc(50))/2 + respc(100), respc(300), respc(35)) then
						dxDrawRoundedRectangle(startX + sizeX / 2 - respc(150), startY + (sizeY - respc(50))/2 + respc(100), respc(300), respc(35), 3, tocolor(140, 195, 230, a*0.5))
						dxDrawText("Létrehozás", startX + sizeX / 2, startY + (sizeY - respc(50))/2 + respc(100) + respc(35)/2, _, _, tocolor(200, 200, 200, a), 1, barlowBold13, "center", "center")	
					else
						dxDrawRoundedRectangle(startX + sizeX / 2 - respc(150), startY + (sizeY - respc(50))/2 + respc(100), respc(300), respc(35), 3, tocolor(65, 65, 65, a))
						dxDrawText("Létrehozás", startX + sizeX / 2, startY + (sizeY - respc(50))/2 + respc(100) + respc(35)/2, _, _, tocolor(150, 150, 150, a), 1, barlowRegular13, "center", "center")		
					end
				end
	
				if getElementData(localPlayer, "a.PlayerGroup") ~= false and currentlyCreatingGroup == false then -- ha csoportbanvan
					if justCreatedGroup then
						local nowTick = getTickCount()
						if groupCreationTick + 2000 > nowTick then
							rotation = rotation + 3
							dxDrawImage(startX + sizeX / 2 - respc(16), startY + sizeY / 2, respc(32), respc(32), "files/img/loading.png", rotation, 0, 0, tocolor(150, 150, 150, a))
						end
					end
	
					if currentGroupPage == 1 then
						exports.dDx:setEditBoxAlpha("clanPlayerToAdd", a)
	
						dxDrawRectangle(startX + respc(5), startY + respc(50), sizeX - respc(10), respc(40), tocolor(45, 45, 45, a))
						dxDrawText("> #F1DB76" .. playerGroupName .. " #c8c8c8<", startX + sizeX / 2, startY + respc(50) + respc(20) - 1, _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "center", "center", false, false, false, true)
	
						dxDrawRectangle(startX + respc(10) + (sizeX - respc(15))/2, startY + respc(95), (sizeX - respc(15))/2, sizeY - respc(145), tocolor(25, 25, 25, a))
					
						for k,v in ipairs(playerGroupMembers) do
							if (k <= maxMembersShowing) and (k > scrollingValue) then
								if isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2 + respc(5), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)), (sizeX - respc(15))/2 - respc(10), respc(35)) or selectedMember == k then
									dxDrawRectangle(startX + respc(10) + (sizeX - respc(15))/2 + respc(5), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)), (sizeX - respc(15))/2 - respc(10), respc(35), tocolor(155, 230, 140, a*0.5))
									dxDrawText(v[1], startX + respc(10) + (sizeX - respc(15))/2 + respc(15), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)) + respc(35)/2, _, _, tocolor(200, 200, 200, a), 1, barlowBold13, "left", "center", false, false, false, true)
	
									dxDrawText("#E48F8FÖlés: " .. v[3], startX + respc(10) + (sizeX - respc(15))/2 + respc(255), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)) + respc(35)/2, _, _, tocolor(150, 150, 150, a), 1, barlowBold13, "left", "center", false, false, false, true)
									dxDrawText("#8FC3E4Halál: " .. v[4], startX + respc(10) + (sizeX - respc(15))/2 + respc(355), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)) + respc(35)/2, _, _, tocolor(150, 150, 150, a), 1, barlowBold13, "left", "center", false, false, false, true)
								else
									dxDrawRectangle(startX + respc(10) + (sizeX - respc(15))/2 + respc(5), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)), (sizeX - respc(15))/2 - respc(10), respc(35), tocolor(40, 40, 40, a))
									dxDrawText(v[1], startX + respc(10) + (sizeX - respc(15))/2 + respc(15), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)) + respc(35)/2, _, _, tocolor(200, 200, 200, a), 1, barlowRegular13, "left", "center", false, false, false, true)
	
									dxDrawText("#E48F8FÖlés: " .. v[3], startX + respc(10) + (sizeX - respc(15))/2 + respc(255), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)) + respc(35)/2, _, _, tocolor(150, 150, 150, a), 1, barlowRegular13, "left", "center", false, false, false, true)
									dxDrawText("#8FC3E4Halál: " .. v[4], startX + respc(10) + (sizeX - respc(15))/2 + respc(355), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)) + respc(35)/2, _, _, tocolor(150, 150, 150, a), 1, barlowRegular13, "left", "center", false, false, false, true)
								end
							end
						end
	
						local maxVariable = 9
						if #playerGroupMembers > maxVariable then
							local listHeight = maxVariable * respc(38) - respc(5)
							local visibleItems = (#playerGroupMembers - maxVariable) + 1
					
							scrollbarHeight = (listHeight / visibleItems)
					
							if scrollTick then
								scrollbarY = interpolateBetween(scrollbarY, 0, 0, startY + respc(100) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 200, "Linear")
							else
								scrollbarY = startY + respc(100) + (scrollingValue * scrollbarHeight)
							end
							dxDrawRectangle(startX + sizeX - respc(7.5), startY + respc(100), respc(3), listHeight, tocolor(65, 65, 65, a))
							dxDrawRectangle(startX + sizeX - respc(7.5) + 1, scrollbarY + 1, respc(1), scrollbarHeight - 2, tocolor(140, 195, 230, a))
						end
	
						dxDrawText("► Klán név: #8FC3E4" .. playerGroupName, startX + respc(10), startY + respc(120), _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "left", "center", false, false, false, true)
						dxDrawText("► Klán rövidítés: #8FC3E4" .. playerGroupSyntax, startX + respc(10), startY + respc(150), _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "left", "center", false, false, false, true)
						dxDrawText("► Klán szín: " .. playerGroupHex .. "SZÍN #c8c8c8 (" .. tostring(utf8.remove(playerGroupHex, 1, 1)) .. ")", startX + respc(10), startY + respc(180), _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "left", "center", false, false, false, true)
						dxDrawText("► Klán létrehozva: #8FC3E4" .. playerGroupCreatingDate, startX + respc(10), startY + respc(210), _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "left", "center", false, false, false, true)
						dxDrawText("► Klán vezető: #8FC3E4" .. playerGroupLeaderName, startX + respc(10), startY + respc(240), _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "left", "center", false, false, false, true)
						dxDrawText("► Klán ID: #8FC3E4" .. currentGroupID, startX + respc(10), startY + respc(270), _, _, tocolor(200, 200, 200, a), 1, barlowBold15, "left", "center", false, false, false, true)
	
						if getElementData(localPlayer, "a.PlayerGroupLeader") == currentGroupID then
							if isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2 + respc(5), startY + sizeY - respc(45), respc(215), respc(40)) then
								dxDrawRectangle(startX + respc(10) + (sizeX - respc(15))/2 + respc(5), startY + sizeY - respc(45), respc(215), respc(40), tocolor(230, 140, 140, a*0.5))
								dxDrawText("Tag eltávolítása", startX + respc(10) + (sizeX - respc(15))/2 + respc(5) + respc(215)/2, startY + sizeY - respc(45) + respc(20), _, _, tocolor(200, 200, 200, a), 1, barlowBold13, "center", "center", false, false, false, true)
							else
								dxDrawRectangle(startX + respc(10) + (sizeX - respc(15))/2 + respc(5), startY + sizeY - respc(45), respc(215), respc(40), tocolor(55, 55, 55, a))
								dxDrawText("Tag eltávolítása", startX + respc(10) + (sizeX - respc(15))/2 + respc(5) + respc(215)/2, startY + sizeY - respc(45) + respc(20), _, _, tocolor(200, 200, 200, a), 1, barlowRegular13, "center", "center", false, false, false, true)
							end
	
							if isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2 + respc(5) + respc(215) + respc(5), startY + sizeY - respc(45), respc(215), respc(40)) then
								dxDrawRectangle(startX + respc(10) + (sizeX - respc(15))/2 + respc(5) + respc(215) + respc(5), startY + sizeY - respc(45), respc(215), respc(40), tocolor(240, 220, 120, a*0.5))
								dxDrawText("Tag kinevezése vezetővé", startX + respc(10) + (sizeX - respc(15))/2 + respc(10) + respc(215) + respc(215)/2, startY + sizeY - respc(45) + respc(20), _, _, tocolor(200, 200, 200, a), 1, barlowBold13, "center", "center", false, false, false, true)
							else
								dxDrawRectangle(startX + respc(10) + (sizeX - respc(15))/2 + respc(5) + respc(215) + respc(5), startY + sizeY - respc(45), respc(215), respc(40), tocolor(55, 55, 55, a))
								dxDrawText("Tag kinevezése vezetővé", startX + respc(10) + (sizeX - respc(15))/2 + respc(10) + respc(215) + respc(215)/2, startY + sizeY - respc(45) + respc(20), _, _, tocolor(200, 200, 200, a), 1, barlowRegular13, "center", "center", false, false, false, true)
							end
	
							if isMouseInPosition(startX + respc(5), startY + sizeY - respc(45), (sizeX - respc(15))/2, respc(40)) then
								dxDrawRectangle(startX + respc(5), startY + sizeY - respc(45), (sizeX - respc(15))/2, respc(40), tocolor(155, 230, 140, a*0.5))
								dxDrawText("Tag hozzáadása", startX + respc(5) + ((sizeX - respc(15))/2)/2, startY + sizeY - respc(45) + respc(20), _, _, tocolor(200, 200, 200), 1, barlowBold13, "center", "center", false, false, false, true)
							else
								dxDrawRectangle(startX + respc(5), startY + sizeY - respc(45), (sizeX - respc(15))/2, respc(40), tocolor(55, 55, 55, a))
								dxDrawText("Tag hozzáadása", startX + respc(5) + ((sizeX - respc(15))/2)/2, startY + sizeY - respc(45) + respc(20), _, _, tocolor(200, 200, 200), 1, barlowRegular13, "center", "center", false, false, false, true)
							end
	
							if (exports.dDx:dxGetEditText("clanPlayerToAdd")) then
								local name = exports.dDx:dxGetEditText("clanPlayerToAdd")
								local targetPlayer = exports.dCore:findPlayer(localPlayer, name)
								if (targetPlayer) and (targetPlayer ~= localPlayer) then
									dxDrawText("#9BE48F" .. getElementData(targetPlayer, "a.PlayerName") .. "#c8c8c8?", startX + respc(5) + ((sizeX - respc(15))/2)/2, startY + sizeY - respc(105), _, _, tocolor(200, 200, 200), 1, barlowBold11, "center", "center", false, false, false, true)
								else
									dxDrawText("Nincs találat a játékosra.", startX + respc(5) + ((sizeX - respc(15))/2)/2, startY + sizeY - respc(105), _, _, tocolor(150, 150, 150), 1, barlowRegular11, "center", "center", false, false, false, true)
								end
							end
						end
					end
				end
			end
		elseif currentPage == 3 then
			dxDrawText("Toplista fejlesztés alatt.", startX + sizeX / 2, startY + sizeY / 2, _, _, tocolor(150, 150, 150, a), 1, barlowRegular11, "center", "center")
		elseif currentPage == 4 then
			dxDrawRectangle(sX/2 - panelSize[1]/2 + 30, sY/2 - panelSize[2]/2 + 50, 200, 35, tocolor(65, 65, 65))
			if isMouseInPosition(sX/2 - panelSize[1]/2 + 30, sY/2 - panelSize[2]/2 + 50, 200, 35) then
				dxDrawRectangle(sX/2 - panelSize[1]/2 + 32, sY/2 - panelSize[2]/2 + 52, 196, 31, tocolor(65, 65, 65))
			else
				dxDrawRectangle(sX/2 - panelSize[1]/2 + 32, sY/2 - panelSize[2]/2 + 52, 196, 31, tocolor(40, 40, 40))
			end
			dxDrawText("K/D reset", sX/2 - panelSize[1]/2 + 132, sY/2 - panelSize[2]/2 + 67, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center")

			dxDrawRectangle(sX/2 - panelSize[1]/2 + 30, sY/2 - panelSize[2]/2 + 100, 200, 35, tocolor(65, 65, 65))
			dxDrawRectangle(sX/2 - panelSize[1]/2 + 32, sY/2 - panelSize[2]/2 + 102, 196, 31, tocolor(40, 40, 40))
			dxDrawText("Crosshair", sX/2 - panelSize[1]/2 + 132, sY/2 - panelSize[2]/2 + 117.5, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center")
			dxDrawImage(sX/2 - panelSize[1]/2 + 35 + 25/4, sY/2 - panelSize[2]/2 + 100 + 25/4, 25, 25, "files/icons/chs/allcrosshair/" .. tonumber(getElementData(localPlayer, "a.Crosshair")) .. ".png", 0, 0, 0, tocolor(255, 255, 255))

			if isMouseInPosition(sX/2 - panelSize[1]/2 + 205, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20) then
				dxDrawImage(sX/2 - panelSize[1]/2 + 205, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20, "files/icons/arrow.png", 0, 0, 0, tocolor(200, 200, 200))
			else
				dxDrawImage(sX/2 - panelSize[1]/2 + 205, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20, "files/icons/arrow.png", 0, 0, 0, tocolor(150, 150, 150))
			end

			if isMouseInPosition(sX/2 - panelSize[1]/2 + 185, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20) then
				dxDrawImage(sX/2 - panelSize[1]/2 + 185, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20, "files/icons/arrow.png", 180, 0, 0, tocolor(200, 200, 200))
			else
				dxDrawImage(sX/2 - panelSize[1]/2 + 185, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20, "files/icons/arrow.png", 180, 0, 0, tocolor(150, 150, 150))
			end
		end
    end
  end

addEventHandler("onClientRender", root, mainPanel)

function onClick(button, state)
	if dashboardIsOpen then
		for i, v in ipairs(dashTabs) do
			i = i - 1
			local tabW = (sizeX - (respc(5) * (#dashTabs + 1) )) / #dashTabs
			if isMouseInPosition(startX + (tabW + respc(5))*i + respc(5), startY + respc(5), tabW, respc(35)) then
				if currentPage == (i + 1) then
					return
				end

				if (i + 1) == 1 then
					createSkinObjectPreviewInPanel()
				else
					destroySkinObjectPreviewInPanel()
				end

				if currentPage == 2 and (i + 1) ~= 2 then
					exports.dDx:dxDestroyEdit("clanPlayerToAdd")
				end

				if (i + 1) == 2 then
					triggerServerEvent("callServerInformations", localPlayer, localPlayer)
				end

				currentPage = (i + 1)
			end
		end
		if currentPage == 2 and button == "left" and state == "down" then
			if isMouseInPosition(startX + sizeX / 2 - respc(150), startY + (sizeY - respc(50))/2 + respc(45), respc(300), respc(35)) and not currentlyCreatingGroup and getElementData(localPlayer, "a.PlayerGroup") == false then
				local currentPlayerMoney = getElementData(localPlayer, "a.Money")
				if currentPlayerMoney < 250000 then
					exports.dInfobox:makeNotification(2, "Nincs elég pénzed klán létrehozásához. (250.000$)")
					return
				end

				currentlyCreatingGroup = true
				exports.dDx:dxCreateEdit("clanName", "", "Klán név (pl.: Loser Klán)", startX + sizeX / 2 - respc(150), startY + sizeY / 2 - respc(50), respc(300), respc(35), false, 25, 1)
				exports.dDx:dxCreateEdit("clanSyntax", "", "Klán rövidítés (pl.: LOSE)", startX + sizeX / 2 - respc(150), startY + sizeY / 2 - respc(10), respc(300), respc(35), false, 4, 1)
				exports.dDx:dxCreateEdit("clanHEX", "", "Klán színkód (pl.: #00DEFF)", startX + sizeX / 2 - respc(150), startY + sizeY / 2 + respc(30), respc(300), respc(35), false, 7, 1)
			end

			if isMouseInPosition(startX + sizeX / 2 - respc(150), startY + (sizeY - respc(50))/2 + respc(100), respc(300), respc(35)) and currentlyCreatingGroup then
				local name = exports.dDx:dxGetEditText("clanName")
				local syntax = exports.dDx:dxGetEditText("clanSyntax")
				local hex = exports.dDx:dxGetEditText("clanHEX")

				if tostring(name) and string.len(name) >= 3 and string.len(name) <= 25 then
					if tostring(syntax) and string.len(syntax) >= 2 and string.len(syntax) <= 4 then
						if tostring(hex) and string.len(hex) == 7 then
							triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "createclan", tostring(name), tostring(syntax), tostring(hex))
							--exports.dInfobox:makeNotification(1, "Sikeresen létrehoztad a klánodat. ([" .. tostring(syntax) .. "] " .. tostring(name) ..")")
							--showPanel()
						else
							exports.dInfobox:makeNotification(2, "A színkód, amit megadtál, nem megfelelő formátumban van! Példa: #c8c8c8")
							-- hex code rovid vagy nincs benne #
						end
					else
						exports.dInfobox:makeNotification(2, "A rövidítés, amit megadtál, nem megfelelő! (min. 2, max. 4 karakter)")
						-- tul rovid syntax
					end
				else
					exports.dInfobox:makeNotification(2, "A név, amit megadtál, nem megfelelő! (min. 3, max. 25 karakter)")
					--tul rovid name
				end
			end
		end
		if currentPage == 2 and button == "left" and state == "down" then
			if getElementData(localPlayer, "a.PlayerGroupLeader") == currentGroupID then
				for k,v in ipairs(playerGroupMembers) do
					if k <= maxMembersShowing and (k > scrollingValue) then
						if isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2 + respc(5), startY + respc(100) + ((k - scrollingValue - 1) * respc(38)), (sizeX - respc(15))/2 - respc(10), respc(35)) then
							selectedMember = k
						end
					end
				end

				-- ** TAG ELTÁVOLÍTÁS
				if isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2 + respc(5), startY + sizeY - respc(45), respc(215), respc(40)) then
					if not selectedMember then
						exports.dInfobox:makeNotification(2, "Nincs kiválasztva tag, így ez nem végbevihető.")
					else
						if playerGroupMembers[selectedMember][2] == getElementData(localPlayer, "a.accID") then
							exports.dInfobox:makeNotification(2, "Saját magadat nem tudod kirúgni a klánból. (Ha törölni akarod a klánt, vedd fel a kapcsolatot egy menedzsment taggal Discordon.)")
							return
						end
						exports.dInfobox:makeNotification(1, "Sikeresen eltávolítottad " .. playerGroupMembers[selectedMember][1] .. " játékost a klánból.")
						triggerServerEvent("kickPlayerFromGroup", localPlayer, localPlayer, playerGroupMembers[selectedMember][2], playerGroupMembers[selectedMember][1])
						table.removeValue(playerGroupMembers, playerGroupMembers[selectedMember])
					end
				end

				-- ** TAG LEADERRÉ TEVÉS
				if isMouseInPosition(startX + respc(10) + (sizeX - respc(15))/2 + respc(5) + respc(215) + respc(5), startY + sizeY - respc(45), respc(215), respc(40)) then
					if not selectedMember then
						exports.dInfobox:makeNotification(2, "Nincs kiválasztva tag, így ez nem végbevihető.")
					else
						if playerGroupMembers[selectedMember][2] == getElementData(localPlayer, "a.accID") then
							exports.dInfobox:makeNotification(2, "Saját magadat nem tudod kirúgni a klánból. (Ha törölni akarod a klánt, vedd fel a kapcsolatot egy menedzsment taggal Discordon.)")
							return
						end
						exports.dInfobox:makeNotification(1, "Sikeresen eltávolítottad " .. playerGroupMembers[selectedMember][1] .. " játékost a klánból.")
						triggerServerEvent("kickPlayerFromGroup", localPlayer, localPlayer, playerGroupMembers[selectedMember][2], playerGroupMembers[selectedMember][1])
						table.removeValue(playerGroupMembers, playerGroupMembers[selectedMember])
					end
				end

				-- ** TAG FELVÉTELE
				if isMouseInPosition(startX + respc(5), startY + sizeY - respc(45), (sizeX - respc(15))/2, respc(40)) then
					local name = exports.dDx:dxGetEditText("addPlayerToGroup")
					local targetPlayer = exports.dCore:findPlayer(localPlayer, name)
					if targetPlayer and (targetPlayer ~= localPlayer) then
						triggerServerEvent("addPlayerToGroup", localPlayer, localPlayer, targetPlayer)
					else
						exports.dInfobox:makeNotification(2, "Nem található ilyen játékos.")
					end
				end
			end
		end
		if currentPage == 4 and button == "left" and state == "down" then
			if isMouseInPosition(sX/2 - panelSize[1]/2 + 30, sY/2 - panelSize[2]/2 + 50, 200, 35) then
				exports.dinterface:makeNotification(1, "Sikeresen resetelted a statjaid.")
				triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "resetstat")
			end
			if isMouseInPosition(sX/2 - panelSize[1]/2 + 205, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20) then
				local currentCrosshair = getElementData(localPlayer, "a.Crosshair")
				if currentCrosshair + 1 > 11 then
					setElementData(localPlayer, "a.Crosshair", 11)
					--applyShader("siteM16", "files/icons/chs/" .. getElementData(localPlayer, "a.Crosshair") .. ".png")
					triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "crosshair", getElementData(localPlayer, "a.Crosshair"))
				else
					setElementData(localPlayer, "a.Crosshair", getElementData(localPlayer, "a.Crosshair") + 1)
					--applyShader("siteM16", "files/icons/chs/" .. getElementData(localPlayer, "a.Crosshair") .. ".png")
					triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "crosshair", getElementData(localPlayer, "a.Crosshair"))
				end
			end
			if isMouseInPosition(sX/2 - panelSize[1]/2 + 185, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20) then
				local currentCrosshair = getElementData(localPlayer, "a.Crosshair")
				if currentCrosshair - 1 < 1 then
					setElementData(localPlayer, "a.Crosshair", 1)
					applyShader("siteM16", "files/icons/chs/" .. getElementData(localPlayer, "a.Crosshair") .. ".png")
					triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "crosshair", getElementData(localPlayer, "a.Crosshair"))
				else
					setElementData(localPlayer, "a.Crosshair", getElementData(localPlayer, "a.Crosshair") - 1)
					--applyShader("siteM16", "files/icons/chs/" .. getElementData(localPlayer, "a.Crosshair") .. ".png")
					triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "crosshair", getElementData(localPlayer, "a.Crosshair"))
				end
			end
		end
	end
end
addEventHandler("onClientClick", root, onClick)

function clanCreatingResponse(element, responseType)
	if element and isElement(element) and element == localPlayer then
		if responseType == "nameAlreadyExists" then
			exports.dInfobox:makeNotification(2, "Ez a klán név már létezik.")
		elseif responseType == "syntaxAlreadyExists" then
			exports.dInfobox:makeNotification(2, "Ez a klán rövidítés már létezik.")
		elseif responseType == "success" then
			exports.dInfobox:makeNotification(1, "Sikeresen létrehoztad a klánodat.")
			currentlyCreatingGroup = false
			justCreatedGroup = true
			groupCreationTick = getTickCount()
			rotation = 0

			exports.dDx:dxDestroyEdit("clanName")
			exports.dDx:dxDestroyEdit("clanSyntax")
			exports.dDx:dxDestroyEdit("clanHEX")
			triggerServerEvent("callServerInformations", element, element)

		end
	end
end
addEvent("clanCreatingResponse", true)
addEventHandler("clanCreatingResponse", root, clanCreatingResponse)

function table.removeValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            table.remove(tab, index)
            return index
        end
    end
    return false
end

function sendInformation(type, arguments, table)
	if type == "groups" then
		playerGroupName = tostring(arguments[1])
		playerGroupLeaderName = tostring(arguments[2])
		playerGroupCreatingDate = tostring(arguments[3])
		playerGroupSyntax = tostring(arguments[4])
		playerGroupHex = tostring(arguments[5])
		playerGroupHex = playerGroupHex
		currentGroupID = tonumber(arguments[6])
		playerGroupMembers = table
	end
end
addEvent("sendInformation", true)
addEventHandler("sendInformation", root, sendInformation)

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end	

		if (not bgColor) then
			bgColor = borderColor;
		end

		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
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

function createObjectPreviewInPanel()
	setTimer(function()
		local skin = getElementModel(localPlayer) or 1
		temp = createPed(skin, 0,0,0);
		setElementInterior(temp, getElementInterior(localPlayer))
		setElementDimension(temp, getElementDimension(localPlayer))
		setElementCollisionsEnabled(temp, false);
		preview = exports.dop:createObjectPreview(temp,0,0,180,sX/2 + 20, sY/2 - panelSize[2]/2 + 50, 800, 800, false,true);
		exports.dop:setPositionOffsets(preview,2,2,0);
		skinPreview[1] = temp;
		skinPreview[2] = preview;
	end, 200, 1)
end

function destroyObjectPreviewInPanel()
	if skinPreview and skinPreview[1] and isElement(skinPreview[1]) then
		exports.dop:destroyObjectPreview(skinPreview[2])
 		destroyElement(skinPreview[1])
	end
end

function getPlayerKD(player, k, d)
	if k ~= 0 and d ~= 0 then 
		mult = 10^(2)
		num = k/d;
		return math.floor(num * mult + 0.5) / mult
	elseif k~=0 then
		return k;
	else
		return 0;
  	end
end

--**
local shaders = {}
function applyShader(texture, img)
	this = #shaders + 1
	shaders[this] = {}
	shaders[this][1] = dxCreateShader ( "files/fx/texture.fx" )
	shaders[this][2] = dxCreateTexture ( img )
	if shaders[this][1] and shaders[this][2] then
		dxSetShaderValue ( shaders[this][1], "gTexture", shaders[this][2] )
		if shaders[this][1] then
			engineApplyShaderToWorldTexture ( shaders[this][1], texture )
		end
	end
end

function onCrosshairApply(key, oval, nval)
	if key == "a.Crosshair" then
		if source == localPlayer then
			applyShader("siteM16", "files/icons/chs/" .. tonumber(nval) .. ".png")
		end
	end
end
addEventHandler("onClientElementDataChange", root, onCrosshairApply)

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