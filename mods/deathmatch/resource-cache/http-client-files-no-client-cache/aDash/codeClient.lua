local sX, sY = guiGetScreenSize();
--local sX, sY = 1280, 720
local sizeX, sizeY = sX / 2, sY / 2; 
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;

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

--local startX, startY, sizeX, sizeY = respc(startX), respc(startY), respc(sizeX), respc(sizeY)

local poppinsSmall = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", resp(10), false, "cleartype")
local poppinsBold15 = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", resp(15), false, "cleartype")
local poppinsBold20 = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", resp(20), false, "cleartype")
local poppinsSmall2 = dxCreateFont("files/fonts/Poppins-Regular.ttf", resp(12), false, "cleartype")

local tabs = {"Információk", "Klánok", "Járművek", "Adminisztrátorok", "Beállítások"}
local tabIcons = {"info", "clan", "vehicle", "admin", "settings"}

function onOpen()
	if isDashboardOpened then
		isDashboardOpened = false
		removeEventHandler("onClientRender", root, onRender)
		removeEventHandler("onClientClick", root, onClick)
		removeEventHandler("onClientKey", root, onKey2)
	else
		isDashboardOpened = true

		playerData = {}
		triggerServerEvent("requestDashboardInformation", localPlayer, localPlayer)
		
		privateMode = false
		privateModeChanging = ""
		clanCreating = false

		currentDashboardPage = 1
		pageTick = getTickCount()
		openTick = getTickCount()
		scrollTick = getTickCount()

		scrollingValue = 0
		maxItemsOnScreen = 9

		addEventHandler("onClientRender", root, onRender)
		addEventHandler("onClientClick", root, onClick)
		addEventHandler("onClientKey", root, onKey2)
	end
end
--addEventHandler("onClientResourceStart", resourceRoot, onOpen)

function sendDashboardInformation(element, table, str)
	if element and isElement(element) then
		if str == "vehicle" then
			vehicleData = table
			local listHeight = 9 * respc(40) - respc(5)
			local visibleItems = (#vehicleData - 9) + 1
	
			scrollbarHeight = (listHeight / visibleItems)
			scrollbarY = startY + respc(85) + (scrollingValue * scrollbarHeight)
	
		else
			playerData = table
		end
	end
end
addEvent("sendDashboardInformation", true)
addEventHandler("sendDashboardInformation", root, sendDashboardInformation)

function onKey(key, state)
	if key == "home" and state then
		onOpen()
		cancelEvent()
	end
end
addEventHandler("onClientKey", root, onKey)


function onRender()
	if not (getElementData(localPlayer, "loggedIn")) or not isDashboardOpened then
		return
	end
	--dxDrawRectangle(0, 0, sX, sY, tocolor(255, 0, 0, 150))

	local nowTick = getTickCount();
	local elapsedTime = nowTick - openTick;
	local duration = elapsedTime / 500;
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

	dxDrawRectangle(startX, startY, sizeX, sizeY, tocolor(65, 65, 65, a))
	dxDrawRectangle(startX + 1, startY + 1, sizeX - 2, sizeY - 2, tocolor(35, 35, 35, a))

	for i, v in ipairs(tabs) do
		tabW, tabH = ((sizeX - respc(20)) / #tabs), respc(30); 
		tabX, tabY = startX + respc(10) + (tabW * (i - 1)) + respc(5), startY + respc(10)

		dxDrawRectangle(tabX, tabY, tabW - respc(10), tabH, tocolor(65, 65, 65, a))
		if isMouseInPosition(tabX, tabY, tabW - respc(10), tabH) or currentDashboardPage == i then
			dxDrawRectangle(tabX + 1, tabY + 1, tabW - respc(10) - 2, tabH - 2, tocolor(65, 65, 65, a))
		else
			dxDrawRectangle(tabX + 1, tabY + 1, tabW - respc(10) - 2, tabH - 2, tocolor(35, 35, 35, a))
		end

		dxDrawImage(tabX + (tabW - respc(10)) / 2 - (dxGetTextWidth(v, 1, poppinsSmall))/2 - respc(23), tabY + respc(7), respc(16), respc(16), "files/img/navicons/" .. tabIcons[i] .. ".png", 0, 0, 0, tocolor(200, 200, 200, a))
		dxDrawText(v, tabX + (tabW - respc(10)) / 2, tabY + tabH / 2 + respc(1), _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "center", "center")
	end

	if currentDashboardPage == 1 then
		if pageTick + 500 > nowTick then
			rotation = interpolateBetween(0, 0, 0, 360, 0, 0, (nowTick - (pageTick)) / 2000, "InOutQuad")
			dxDrawImage(startX + sizeX / 2 - respc(16), startY + sizeY / 2 - respc(16), respc(32), respc(32), "files/img/loading.png", rotation, 0, 0, tocolor(150, 150, 150, a))
		else
			dxDrawRectangle(startX + respc(15), startY + respc(50), (sizeX - respc(10)) / 3, sizeY - respc(60), tocolor(45, 45, 45, a))
			dxDrawText("skin preview", startX + respc(15) + ((sizeX - respc(10)) / 3) / 2, startY + respc(50) + (sizeY - respc(60)) / 2, _, _, tocolor(100, 100, 100, a), 1, poppinsSmall2, "center", "center")
			
			local lineX, lineY, lineW, lineH = startX + respc(15) + (sizeX - respc(10)) / 3 + respc(10), startY + respc(50), ((sizeX - respc(10)) / 1.5 - respc(30)), (sizeY - respc(60)) / 3 - respc(10);

			dxDrawRectangle(lineX, lineY, lineW, lineH, tocolor(45, 45, 45, a))
			dxDrawRectangle(lineX, lineY + lineH + respc(10), lineW, lineH, tocolor(45, 45, 45, a))
			dxDrawRectangle(lineX, lineY + lineH * 2 + respc(20), lineW, lineH, tocolor(45, 45, 45, a))
			
			-- ** ACCOUNT INFORMÁCIÓK TAB
			if privateModeChanging == "on" then
				local nowTick = getTickCount();
				local elapsedTime = nowTick - changeTick;
				x, y, size = interpolateBetween(lineX + lineW - respc(24), lineY + respc(4), respc(16), lineX + (lineW / 2) - respc(18), lineY + (lineH / 2) - respc(18), respc(36), elapsedTime / 500, "Linear")
			elseif privateModeChanging == "off" then
				local nowTick = getTickCount();
				local elapsedTime = nowTick - changeTick;
				x, y, size = interpolateBetween(x, y, size, lineX + lineW - respc(24), lineY + respc(4), respc(16), elapsedTime / 500, "Linear")
			else
				x, y, size = lineX + lineW - respc(24), lineY + respc(4), respc(16)
			end

			dxDrawImage(x, y, size, size, "files/img/hide.png", 0, 0, 0, tocolor(125, 125, 125, a))
			if privateMode == false then
				if isMouseInPosition(lineX + lineW - respc(24), lineY + respc(4), respc(16), respc(16)) then
					local cX, cY = getCursorPosition();
					local cX, cY = cX * sX, cY * sY

					dxDrawRectangle(cX + 8, cY + 10, dxGetTextWidth("Privát mód", 1, poppinsSmall) + 4, 20, tocolor(30, 30, 30, a), true)
					dxDrawText("Privát mód", cX + 10, cY + 10, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "left", "top", false, false, true)
				end

				dxDrawText("Account információk", lineX + lineW / 2, lineY + respc(5), _, _, tocolor(100, 100, 100, a), 1, poppinsSmall2, "center", "top")
				dxDrawText("Account ID:#c8c8c8 " .. getElementData(localPlayer, "a.accID"), lineX + respc(10), lineY + respc(10), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
				dxDrawText("Felhasználónév:#c8c8c8 " .. playerData[1]["username"], lineX + respc(10), lineY + respc(30), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
				dxDrawText("Jelszó:#c8c8c8 " .. playerData[1]["password"], lineX + respc(10), lineY + respc(50), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
				dxDrawText("Serial:#c8c8c8 53987DDB582C0AC8B9CCD506656ACD13", lineX + respc(10), lineY + respc(70), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
				dxDrawText("E-mail:#c8c8c8 dzsekivagyok@alphagames.com", lineX + respc(10), lineY + respc(90), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
				if lineY + respc(110) > (lineY + lineH) then
					dxDrawText("Adminszint:#c8c8c8 5 - #E48F8FTulajdonos", lineX + lineW - respc(10), lineY + respc(30), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "right", "top", false, false, false, true)
				else
					dxDrawText("Adminszint:#c8c8c8 5 - #E48F8FTulajdonos", lineX + respc(10), lineY + respc(110), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
				end
			else
				if isMouseInPosition(lineX + (lineW / 2) - respc(18), lineY + (lineH / 2) - respc(18), respc(36), respc(36)) then
					local cX, cY = getCursorPosition();
					local cX, cY = cX * sX, cY * sY

					dxDrawRectangle(cX + respc(8), cY + respc(10), dxGetTextWidth("Privát mód kikapcsolása", 1, poppinsSmall) + 4, 20, tocolor(30, 30, 30, a), true)
					dxDrawText("Privát mód kikapcsolása", cX + respc(10), cY + respc(10), _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "left", "top", false, false, true)
				end
			end

			-- ** KARAKTER INFO TAB
			dxDrawText("Karakter információk" , lineX + respc(10) + lineW / 2, lineY + lineH + respc(15), _, _, tocolor(100, 100, 100, a), 1, poppinsSmall2, "center", "top")
			dxDrawText("Játszott percek:#c8c8c8 12 perc", lineX + respc(10), lineY + lineH + respc(20), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
			dxDrawText("Pénz:#c8c8c8 23.144 $", lineX + respc(10), lineY + lineH + respc(40), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
			dxDrawText("Prémiumpont:#c8c8c8 1.144 pp", lineX + respc(10), lineY + lineH + respc(60), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
			dxDrawText("Tapasztalat:#c8c8c8 51.144 xp", lineX + respc(10), lineY + lineH + respc(80), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
			dxDrawText("Szint:#c8c8c8 LVL 51", lineX + respc(10), lineY + lineH + respc(100), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
			
			if lineY + lineH + respc(120) > (lineY + lineH) + respc(10) + lineH then
				dxDrawText("VIP:#c8c8c8 Igen (Lejárat: 2023. 03. 15.)", lineX + respc(10) + lineW - respc(20), lineY + lineH + respc(20), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "right", "top", false, false, false, true)
			else
				dxDrawText("VIP:#c8c8c8 Igen (Lejárat: 2023. 03. 15.)", lineX + respc(10), lineY + lineH + respc(120), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
			end

			-- ** TDMA STATS
			dxDrawText("Statisztika" , lineX + respc(10) + lineW / 2, lineY + lineH*2 + respc(25), _, _, tocolor(100, 100, 100, a), 1, poppinsSmall2, "center", "top", false, false, false, true)
			dxDrawText("Ölések:#c8c8c8 32", lineX + respc(10), lineY + lineH*2 + respc(30), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
			dxDrawText("Halálok:#c8c8c8 65", lineX + respc(10), lineY + lineH*2 + respc(50), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
			dxDrawText("K/D:#c8c8c8 0.49", lineX + respc(10), lineY + lineH*2 + respc(70), _, _, tocolor(150, 150, 150, a), 1, poppinsSmall, "left", "top", false, false, false, true)
		end
	elseif currentDashboardPage == 2 then
		if pageTick + 1000 > nowTick then
			rotation = interpolateBetween(0, 0, 0, 360, 0, 0, (nowTick - (pageTick)) / 2000, "InOutQuad")
			dxDrawImage(startX + sizeX / 2 - respc(16), startY + sizeY / 2 - respc(16), respc(32), respc(32), "files/img/loading.png", rotation, 0, 0, tocolor(150, 150, 150, a))
		else
			if playerData[2]["groupID"] == "no" then
				if not clanCreating then
					dxDrawText("Jelenleg nem vagy klán tagja.", startX + sizeX / 2, startY + sizeY / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBold15, "center", "center")
					dxDrawRectangle(startX + sizeX / 2 - respc(75), startY + sizeY / 2 + respc(15), respc(150), respc(30), tocolor(65, 65, 65, a))
					if isMouseInPosition(startX + sizeX / 2 - respc(75), startY + sizeY / 2 + respc(15), respc(150), respc(30)) then
						dxDrawRectangle(startX + sizeX / 2 - respc(75) + 1, startY + sizeY / 2 + respc(15) + 1, respc(150) - 2, respc(30) - 2, tocolor(65, 65, 65, a))				
					else
						dxDrawRectangle(startX + sizeX / 2 - respc(75) + 1, startY + sizeY / 2 + respc(15) + 1, respc(150) - 2, respc(30) - 2, tocolor(35, 35, 35, a))				
					end
					dxDrawText("Klán vásárlása (500.000$)", startX + sizeX / 2 - respc(75) + respc(150)/2, startY + sizeY / 2 + respc(15) + respc(31) / 2, _, _, tocolor(125, 125, 125, a), 1, poppinsSmall, "center", "center")
				else
					dxDrawText("Klán létrehozás", startX + sizeX / 2, startY + sizeY / 2 - respc(75), _, _, tocolor(200, 200, 200, a), 1, poppinsBold15, "center", "center")
					
					if isMouseInPosition(startX + sizeX / 2 - respc(150), startY + sizeY / 2 - respc(75) - respc(8), respc(16), respc(16)) then
						dxDrawImage(startX + sizeX / 2 - respc(150), startY + sizeY / 2 - respc(75) - respc(8), respc(16), respc(16), "files/img/arrow.png", 180, 0, 0, tocolor(160, 160, 160, a))
					else
						dxDrawImage(startX + sizeX / 2 - respc(150), startY + sizeY / 2 - respc(75) - respc(8), respc(16), respc(16), "files/img/arrow.png", 180, 0, 0, tocolor(120, 120, 120, a))
					end

					dxDrawRectangle(startX + sizeX / 2 - respc(75), startY + sizeY / 2 + respc(70), respc(150), respc(25), tocolor(65, 65, 65, a))
					if isMouseInPosition(startX + sizeX / 2 - respc(75), startY + sizeY / 2 + respc(70), respc(150), respc(25)) then
						dxDrawRectangle(startX + sizeX / 2 - respc(75) + 1, startY + sizeY / 2 + respc(70) + 1, respc(150) - 2, respc(25) - 2, tocolor(65, 65, 65, a))
					else
						dxDrawRectangle(startX + sizeX / 2 - respc(75) + 1, startY + sizeY / 2 + respc(70) + 1, respc(150) - 2, respc(25) - 2, tocolor(35, 35, 35, a))
					end
					dxDrawText("Létrehozás", startX + sizeX / 2, startY + sizeY / 2 + respc(70) + respc(26) / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "center", "center")
				end
			else
				local clanID, clanName, clanSyntax, clanHex, clanCreate = playerData[2]["groupID"], playerData[2]["groupName"], playerData[2]["groupSyntax"], playerData[2]["groupHex"], playerData[2]["groupCreateDate"]
				dxDrawRectangle(startX + respc(25), startY + respc(65), respc(2), respc(100), tocolor(hexColorToRGB(clanHex)))
				dxDrawText("Név: #c8c8c8" .. clanName, startX + respc(40), startY + respc(80), _, _, tocolor(150, 150, 150, a), 1, poppinsBold20, "left", "center", false, false, false, true)
				dxDrawText("ID: #c8c8c8" .. clanID, startX + respc(40), startY + respc(110), _, _, tocolor(150, 150, 150, a), 1, poppinsBold15, "left", "center", false, false, false, true)
				dxDrawText("Syntax: #c8c8c8" .. clanSyntax, startX + respc(40), startY + respc(130), _, _, tocolor(150, 150, 150, a), 1, poppinsBold15, "left", "center", false, false, false, true)
				dxDrawText("Színkód: #c8c8c8" .. tostring(clanHex:gsub("#", " ")), startX + respc(40), startY + respc(150), _, _, tocolor(150, 150, 150, a), 1, poppinsBold15, "left", "center", false, false, false, true)
			end
		end
	elseif currentDashboardPage == 3 then
		if pageTick + 750 > nowTick then
			rotation = interpolateBetween(0, 0, 0, 360, 0, 0, (nowTick - (pageTick)) / 2000, "InOutQuad")
			dxDrawImage(startX + sizeX / 2 - respc(16), startY + sizeY / 2 - respc(16), respc(32), respc(32), "files/img/loading.png", rotation, 0, 0, tocolor(150, 150, 150, a))
		else
			dxDrawRectangle(startX + respc(15), startY + respc(50), sizeX - respc(30), sizeY - respc(65), tocolor(30, 30, 30, a))
			dxDrawText("ID", startX + respc(55), startY + respc(70), _, _, tocolor(100, 100, 100, a), 1, poppinsSmall, "left", "center")
			dxDrawText("Jármű neve", startX + respc(100), startY + respc(70), _, _, tocolor(100, 100, 100, a), 1, poppinsSmall, "left", "center")

			if vehicleData ~= nil then
				for k, v in ipairs(vehicleData) do
					if (k <= maxItemsOnScreen) and (k > scrollingValue) then
						k = k - scrollingValue
						if isMouseInPosition(startX + respc(35), startY + respc(85) + ((k - 1) * respc(40)), sizeX - respc(70), respc(35)) then
							dxDrawRectangle(startX + respc(35), startY + respc(85) + ((k - 1) * respc(40)), sizeX - respc(70), respc(35), tocolor(55, 55, 55, a))
						else
							dxDrawRectangle(startX + respc(35), startY + respc(85) + ((k - 1) * respc(40)), sizeX - respc(70), respc(35), tocolor(45, 45, 45, a))
						end

						dxDrawText(v[1], startX + respc(55), startY + respc(85) + ((k - 1) * respc(40)) + respc(35)/2 + 1, _, _, tocolor(150, 150, 150, a), 1, poppinsBold15, "left", "center")
						if (exports.aCarshop:getVehicleNameFromID(v[2])) then
							dxDrawText(exports.aCarshop:getVehicleNameFromID(v[2]), startX + respc(100), startY + respc(85) + ((k - 1) * respc(40)) + respc(35)/2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsBold15, "left", "center")
						else
							dxDrawText("N/A", startX + respc(85), startY + respc(100) + ((k - 1) * respc(40)) + respc(35)/2 + 1, _, _, tocolor(200, 200, 200, a), 1, poppinsBold15, "left", "center")
						end

						if isMouseInPosition(startX + respc(35) + sizeX - respc(95), startY + respc(85) + ((k - 1) * respc(40)) + respc(9.5), respc(16), respc(16)) then
							dxDrawImage(startX + respc(35) + sizeX - respc(95), startY + respc(85) + ((k - 1) * respc(40)) + respc(9.5), respc(16), respc(16), "files/img/spawn.png", 0, 0, 0, tocolor(200, 200, 200, a))
							local cX, cY = getCursorPosition();
							local cX, cY = cX * sX, cY * sY;
		
							dxDrawRectangle(cX + respc(8), cY + respc(10), dxGetTextWidth("Jármű lehívása", 1, poppinsSmall) + 4, 20, tocolor(30, 30, 30, a), true)
							dxDrawText("Jármű lehívása", cX + respc(10), cY + respc(10), _, _, tocolor(200, 200, 200, a), 1, poppinsSmall, "left", "top", false, false, true)
						else
							dxDrawImage(startX + respc(35) + sizeX - respc(95), startY + respc(85) + ((k - 1) * respc(40)) + respc(9.5), respc(16), respc(16), "files/img/spawn.png", 0, 0, 0, tocolor(150, 150, 150, a))
						end
					end
				end
				if #vehicleData > 9 then
					local listHeight = 9 * respc(40) - respc(5)
					local visibleItems = (#vehicleData - 9) + 1

					scrollbarHeight = (listHeight / visibleItems)

					if scrollTick then
						scrollbarY = interpolateBetween(scrollbarY, 0, 0, startY + respc(85) + (scrollingValue * scrollbarHeight), 0, 0, (nowTick - scrollTick) / 500, "Linear")
					else
						scrollbarY = startY + respc(85) + (scrollingValue * scrollbarHeight)
					end
					dxDrawRectangle(startX + sizeX - respc(30), startY + respc(85), respc(10), listHeight, tocolor(65, 65, 65, 200))
					dxDrawRectangle(startX + sizeX - respc(30) + 1, scrollbarY + 1, respc(8), scrollbarHeight - 2, tocolor(120, 120, 120, 200))
				end
			else
				dxDrawText("Jelenleg nem rendelkezel járművekkel.", startX + sizeX / 2, startY + sizeY / 2, _, _, tocolor(200, 200, 200, a), 1, poppinsBold15, "center", "center")
			end
		end
	end
end

function hexColorToRGB(hex)
    hex = (type(hex) == 'number') and '0x'..('%x'):format(hex):gsub('%l', string.upper) or hex
    if hex:match('^0x%x%x%x%x%x%x%x%x$') then
        local a = tonumber('0x'..hex:sub(3,4))
        local r = tonumber('0x'..hex:sub(5,6))
        local g = tonumber('0x'..hex:sub(7,8))
        local b = tonumber('0x'..hex:sub(9,10))
        return r,g,b,a
    elseif hex:match('^#%x%x%x$') then
        local r = tonumber('0x'..hex:sub(2,2)..hex:sub(2,2))
        local g = tonumber('0x'..hex:sub(3,3)..hex:sub(3,3))
        local b = tonumber('0x'..hex:sub(4,4)..hex:sub(4,4))
        return r,g,b,a
    elseif hex:match('^#%x%x%x%x%x%x$') then
        local r = tonumber('0x'..hex:sub(2,3))
        local g = tonumber('0x'..hex:sub(4,5))
        local b = tonumber('0x'..hex:sub(6,7))
        return r,g,b,a
    else return false,false,false,false end
end

function onKey2(key, state)
	if currentDashboardPage == 3 then
		scrollTick = getTickCount()
		if key == "mouse_wheel_up" then
			if scrollingValue > 0  then
				scrollingValue = scrollingValue - 1
				maxItemsOnScreen = maxItemsOnScreen - 1
			end
		elseif key == "mouse_wheel_down" then
			if maxItemsOnScreen < #vehicleData then
				scrollingValue = scrollingValue + 1
				maxItemsOnScreen = maxItemsOnScreen + 1
			end
		end
	end
end

function onClick(button, state)
	if not (getElementData(localPlayer, "loggedIn")) or not isDashboardOpened then
		return
	end
	if button == "left" and state == "down" then
		for i, v in ipairs(tabs) do
			tabW, tabH = ((sizeX - respc(20)) / #tabs), respc(30); 
			tabX, tabY = startX + respc(10) + (tabW * (i - 1)) + respc(5), startY + respc(7.5)
			if isMouseInPosition(tabX, tabY, tabW - 10, tabH) then
				currentDashboardPage = i
				pageTick = getTickCount()
			end
		end

		if currentDashboardPage == 1 then
			local lineX, lineY, lineW, lineH = startX + respc(15) + (sizeX - respc(10)) / 3 + respc(10), startY + respc(50), ((sizeX - respc(10)) / 1.5 - respc(30)), (sizeY - respc(60)) / 3 - respc(10);
			if privateMode == false then
				if isMouseInPosition(lineX + lineW - respc(24), lineY + respc(4), respc(16), respc(16)) then
					privateMode = true
					privateModeChanging = "on"
					changeTick = getTickCount()
				end
			else
				if isMouseInPosition(lineX + (lineW / 2) - respc(18), lineY + (lineH / 2) - respc(18), respc(36), respc(36)) then
					privateMode = false
					privateModeChanging = "off"
					changeTick = getTickCount()
				end
			end
		elseif currentDashboardPage == 2 then
			if playerData[2]["groupID"] == "no" then
				if not clanCreating then
					if isMouseInPosition(startX + sizeX / 2 - respc(75), startY + sizeY / 2 + respc(15), respc(150), respc(30)) then
						local playerMoney = getElementData(localPlayer, "a.Money")
						if playerMoney >= 500000 then
							clanCreating = true
							exports.aDx:dxCreateEdit("a.ClanName", "", "Klán neve", startX + sizeX / 2 - respc(150), startY + sizeY / 2 - respc(55), respc(300), respc(30), {125, 125, 125}, 20, 1)
							exports.aDx:dxCreateEdit("a.ClanSyntax", "", "Klán előtag (syntax)", startX + sizeX / 2 - respc(150), startY + sizeY / 2 - respc(15), respc(300), respc(30), {125, 125, 125}, 20, 1)
							exports.aDx:dxCreateEdit("a.ClanColor", "", "Klán szín (HEX code, pl: #00DEFF)", startX + sizeX / 2 - respc(150), startY + sizeY / 2 + respc(25), respc(300), respc(30), {125, 125, 125}, 20, 1)
					
						else
							exports.aInfobox:makeNotification(2, "Nincs elég pénzed a művelet végrehajtásához.")
						end
					end
				else
					if isMouseInPosition(startX + sizeX / 2 - respc(150), startY + sizeY / 2 - respc(70) - respc(8), respc(16), respc(16)) then
						clanCreating = false
						exports.aDx:dxDestroyEdit("a.ClanName")
						exports.aDx:dxDestroyEdit("a.ClanSyntax")
						exports.aDx:dxDestroyEdit("a.ClanColor")
					end
					if isMouseInPosition(startX + sizeX / 2 - respc(75), startY + sizeY / 2 + respc(70), respc(150), respc(25)) then						
						local name, syntax, color = exports.aDx:dxGetEditText("a.ClanName"), exports.aDx:dxGetEditText("a.ClanSyntax"), exports.aDx:dxGetEditText("a.ClanColor")
						if not name or not syntax or not color then
							exports.aInfobox:makeNotification(2, "A létrehozáshoz minden mezőt ki kell töltened.")
							return
						end

						if string.len(name) < 5 then
							exports.aInfobox:makeNotification(2, "A megadott klán név túl rövid. (Min. 5 karakter)")
							return
						end

						if string.len(syntax) < 3 or string.len(syntax) > 5 then
							exports.aInfobox:makeNotification(2, "A megadott syntax túl rövid/túl hosszú. (Min. 3, max. 5 karakter)")
							return
						end

						if string.len(color) ~= 7 or not utf8.find(color, "#") then
							exports.aInfobox:makeNotification(2, "A megadott szín nem megfelelő. (pl: #XXXXXX)")
							return
						end

						triggerServerEvent("createClan", localPlayer, localPlayer, {name, syntax, color})
					end
				end
			else
				
			end
		elseif currentDashboardPage == 3 then
			if vehicleData ~= nil then
				for k, v in ipairs(vehicleData) do
					if (k <= maxItemsOnScreen) and (k > scrollingValue) then
						k = k - scrollingValue
						if isMouseInPosition(startX + respc(35) + sizeX - respc(95), startY + respc(85) + ((k - 1) * respc(40)) + respc(9.5), respc(16), respc(16)) then
							if getElementData(localPlayer, "a.Gamemode") ~= 3 then
								exports.aInfobox:makeNotification(2, "A járművet csak a DRIFT játékmódban tudod lehívni.")
							else
								-- ** jármű lehívás
								triggerServerEvent("spawnVehicle", localPlayer, localPlayer, v[2])
							end
						end
					end
				end
			end
		end
	end
end

function receiveAnswerFromServer(element, type, ...)
	if not element == localPlayer then
		return
	end

	if type == "a.GroupNameExists" then
		exports.aInfobox:makeNotification(2, "A megadott név már létezik.")
	elseif type == "a.GroupSyntaxExists" then
		exports.aInfobox:makeNotification(2, "A megadott syntax már létezik.")
	elseif type == "a.GroupCreatingSuccess" then
		exports.aInfobox:makeNotification(1, "Sikeresen létrehoztad a saját klánodat.")
		clanCreating = false
		exports.aDx:dxDestroyEdit("a.ClanName")
		exports.aDx:dxDestroyEdit("a.ClanSyntax")
		exports.aDx:dxDestroyEdit("a.ClanColor")
		pageTick = getTickCount()
		args = {...}
		playerData[2]["groupID"] = args[1]
		playerData[2]["groupName"] = args[2]
		playerData[2]["groupSyntax"] = args[3]
		playerData[2]["groupHex"] = args[4]
		playerData[2]["groupCreateDate"] = args[5]
	end
end
addEvent("receiveAnswerFromServer", true)
addEventHandler("receiveAnswerFromServer", root, receiveAnswerFromServer)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end