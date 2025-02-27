local sX, sY = guiGetScreenSize()
local myX, myY = 1920, 1080;
local panelSize = {800, 400}
local dashboardIsOpen = false
local currentPage = 4
local currentGroupPage = 1
local currentlyCreatingGroup = false
local headerFont = dxCreateFont("files/fonts/font.otf", 15, false, "cleartype")
local normalFont = dxCreateFont("files/fonts/font.otf", 15, false, "cleartype")
local robotoThin = dxCreateFont("files/fonts/Roboto-Condensed.otf", 12, false, "cleartype")
local buttons = {"Információk", "Klán", "Adminok", "Beállítások"}
local admins = {"Admin 1", "Admin 2", "Admin 3", "Admin 4", "Admin 5", "FőAdmin", "SzuperAdmin", "Menedzser", "Tulajdonos"}
local skinPreview = {}
local topKillers = {}
local maxMembersShowing = 6
local scrollingValue = 0

function pressedButton(button, pressed)
	if getElementData(localPlayer, "loggedIn") then
		if pressed then
			if button == "home" then
				currentPage = 1
				showPanel()
				maxMembersShowing = 6
				scrollingValue = 0
				cancelEvent()
				buttonTick = getTickCount()
				--createObjectPreviewInPanel()
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
				maxMembersShowing = 6
				scrollingValue = 0
				showPanel()
				buttonTick = getTickCount()
			end
			if button == "mouse_wheel_up" and dashboardIsOpen and currentPage == 2 and currentGroupPage == 1 then
				if scrollingValue > 0  then
				  	scrollingValue = scrollingValue - 1
				  	maxMembersShowing = maxMembersShowing - 1
				end
			  elseif button == "mouse_wheel_down" then
				if maxMembersShowing < #playerGroupMembers then
				  	scrollingValue = scrollingValue + 1
				  	maxMembersShowing = maxMembersShowing + 1
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
			exports.a_3dview:processSkinPreview(getElementModel(localPlayer), sX / 2 - panelSize[1]/2 + 20, sY / 2, 300, 500)
		end
		--currentCrosshair = getElementData(localPlayer, "a.Crosshair") or 1
		triggerServerEvent("callServerInformations", localPlayer, localPlayer)
	else
		exports.a_3dview:processSkinPreview()
		dashboardIsOpen = false
		local id = exports.a_dx:dxGetEdit("clanName")
		local id2 = exports.a_dx:dxGetEdit("clanSyntax")
		local id3 = exports.a_dx:dxGetEdit("clanHEX")
		local id4 = exports.a_dx:dxGetEdit("addPlayer")
		if id4 then
			exports.a_dx:dxDestroyEdit(id4)
		end
		if (id) and (id2) and (id3) then
			exports.a_dx:dxDestroyEdit(id3)
			exports.a_dx:dxDestroyEdit(id2)
			exports.a_dx:dxDestroyEdit(id)
		end
	end
end

function mainPanel()
	if (dashboardIsOpen == true) then
		if currentPage == 1 then
			local nowTick = getTickCount()
			local elapsedTime = nowTick - buttonTick
			local duration = elapsedTime / 1000
			a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

			local name = getElementData(localPlayer, "a.PlayerName") or "-"
			local id = getElementData(localPlayer, "playerid") or "-"
			local accid = getElementData(localPlayer, "a.accID") or "-"
			local adminlvl = getElementData(localPlayer, "adminLevel") or "0"
			local adminsyntax = admins[adminlvl] or ""
			local adminnick = getElementData(localPlayer, "adminNick") or "-"
			local vip = getElementData(localPlayer, "a.VIP") or false
			if vip == true then
				vip = "#C4CD5DIgen"
			else
				vip = "Nem"
			end
			local money = getElementData(localPlayer, "a.Money") or "0"
			local pp = getElementData(localPlayer, "a.Premiumpont") or "0"
			local kills = getElementData(localPlayer, "a.Kills") or "0"
			local deaths = getElementData(localPlayer, "a.Deaths") or "0"
			local kd = getPlayerKD(localPlayer, kills, deaths)
			local bestdrift = getElementData(localPlayer, "a.bestDrift") or "0"

			-- OBJECT PREVIEW

			-- DEFAULT PANEL DRAW
			dxDrawRectangle(sX/2 - panelSize[1]/2, sY/2 - panelSize[2]/2, panelSize[1], panelSize[2], tocolor(65, 65, 65, a)) -- alap panel
			dxDrawRectangle(sX/2 - panelSize[1]/2 + 2, sY/2 - panelSize[2]/2 + 2, panelSize[1] - 4, panelSize[2] - 4, tocolor(30, 30, 30, a)) -- alap panel
			for k, v in ipairs(buttons) do
				if k == currentPage then
					dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(45, 45, 45, a))
					dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(255, 255, 255, a), 1, headerFont, "center", "center")
				else
					if isMouseInPosition(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25) then
						dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(50, 50, 50, a))
						dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(255, 255, 255, a), 1, headerFont, "center", "center")
					else
						dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(20, 20, 20, a))
						dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(200, 200, 200, a), 1, headerFont, "center", "center")
					end
				end
			end
			exports.a_3dview:setSkinProjection(sX/2 - panelSize[1]/2 - 25, sY/2 - panelSize[2] + 175, 350, 450, a)

			dxDrawRectangle(sX/2 - 45, sY/2 - panelSize[2]/2 + 45, panelSize[1]/2, panelSize[2] - 70, tocolor(25, 25, 25, a))		
			dxDrawImage(sX/2 - 40, sY/2 - panelSize[2]/2 + 50, 20, 23, "files/icons/user.png", 0, 0, 0, tocolor(200, 200, 200, a))
			dxDrawText(name .. " #D19D6B(" .. id .. ") #FFFFFF- Információk", sX/2 - 45 + panelSize[1]/4, sY/2 - panelSize[2]/2 + 60, _, _, tocolor(255, 255, 255, a), 1, headerFont, "center", "center", false, false, false, true)

			dxDrawText("Név: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 90, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText(name, sX/2 + 7, sY/2 - panelSize[2]/2 + 90, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)

			dxDrawText("Account ID: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 120, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText(accid, sX/2 + 62, sY/2 - panelSize[2]/2 + 120, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)

			dxDrawText("Adminszint: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 150, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText(adminlvl .. " - " .. adminsyntax, sX/2 + 65, sY/2 - panelSize[2]/2 + 150, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)
			
			dxDrawText("Adminnév: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 180, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText(adminnick, sX/2 + 60, sY/2 - panelSize[2]/2 + 180, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)
						
			dxDrawText("VIP: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 210, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText(vip, sX/2 + 3, sY/2 - panelSize[2]/2 + 210, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)
									
			dxDrawText("Pénz: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 240, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText("#9BE48F" .. money .. "$", sX/2 + 14, sY/2 - panelSize[2]/2 + 240, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)
									
			dxDrawText("PP: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 270, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText("#8FC3E4" .. pp .. " PP", sX/2, sY/2 - panelSize[2]/2 + 270, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)
												
			dxDrawText("K/D: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 300, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText(kd .. " (#9BE48F" .. kills .. "#c8c8c8/#E48F8F" .. deaths .. "#c8c8c8)", sX/2 + 8, sY/2 - panelSize[2]/2 + 300, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)
												
			dxDrawText("Legjobb drift: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 330, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			dxDrawText(bestdrift, sX/2 + 74, sY/2 - panelSize[2]/2 + 330, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)
												
			--dxDrawText("K/D: ", sX/2 - 30, sY/2 - panelSize[2]/2 + 360, _, _, tocolor(150, 150, 150, a), 1, headerFont, "left", "center", false, false, false, true)
			--dxDrawText(kd, sX/2 + 10, sY/2 - panelSize[2]/2 + 360, _, _, tocolor(200, 200, 200, a), 1, normalFont, "left", "center", false, false, false, true)
		elseif currentPage == 2 then
			-- DEFAULT PANEL DRAW
			dxDrawRectangle(sX/2 - panelSize[1]/2, sY/2 - panelSize[2]/2, panelSize[1], panelSize[2], tocolor(65, 65, 65)) -- alap panel
			dxDrawRectangle(sX/2 - panelSize[1]/2 + 2, sY/2 - panelSize[2]/2 + 2, panelSize[1] - 4, panelSize[2] - 4, tocolor(30, 30, 30)) -- alap panel
			for k, v in ipairs(buttons) do
				if k == currentPage then
					dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(45, 45, 45))
					dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(255, 255, 255), 1, headerFont, "center", "center")
				else
					if isMouseInPosition(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25) then
						dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(50, 50, 50))
						dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(255, 255, 255), 1, headerFont, "center", "center")
					else
						dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(20, 20, 20))
						dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center")
					end
				end
			end

			if getElementData(localPlayer, "a.PlayerGroup") == 0 and currentlyCreatingGroup == false then -- ha nincs csoportban és nem csinál jelenleg csoportot
				dxDrawText("Nem vagy klántag.", sX/2, sY/2 - 20, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center")
				dxDrawRectangle(sX / 2 - 100, sY / 2, 200, 30, tocolor(65, 65, 65))
				if isMouseInPosition(sX / 2 - 100, sY / 2, 200, 30) then
					dxDrawRectangle(sX / 2 - 98, sY / 2 + 2, 196, 26, tocolor(65, 65, 65))
					dxDrawText("100.000$",sX / 2, sY / 2 + 15, _, _, tocolor(140, 240, 140), 1, headerFont, "center", "center")		
				else
					dxDrawRectangle(sX / 2 - 98, sY / 2 + 2, 196, 26, tocolor(40, 40, 40))
					dxDrawText("Létrehozás",sX / 2, sY / 2 + 15, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center")		
				end
			elseif currentlyCreatingGroup == true then
				dxDrawRectangle(sX/2 - panelSize[1]/4, sY/2 - panelSize[2]/4, panelSize[1]/2, panelSize[2]/2, tocolor(20, 20, 20, 200))
				dxDrawRectangle(sX/2 - panelSize[1]/4, sY/2 - panelSize[2]/4, panelSize[1]/2, 30, tocolor(45, 45, 45, 200))
				dxDrawText("#D19D6Balpha#c8c8c8Games - Klán létrehozás", sX/2 - panelSize[1]/4 + 5, sY/2 - panelSize[2]/4 + 15, _, _, tocolor(200, 200, 200, 200), 1, headerFont, "left", "center", false, false, false, true)
				dxDrawRectangle(sX/2 - panelSize[1]/4 + 30 - 2, sY/2 - panelSize[2]/4 + panelSize[2]/2 - 40 - 2, panelSize[1]/2 - 60 + 4, 30 + 4, tocolor(65, 65, 65, 200))
				if isMouseInPosition(sX/2 - panelSize[1]/4 + 30, sY/2 - panelSize[2]/4 + panelSize[2]/2 - 40, panelSize[1]/2 - 60, 30) then
					dxDrawRectangle(sX/2 - panelSize[1]/4 + 30, sY/2 - panelSize[2]/4 + panelSize[2]/2 - 40, panelSize[1]/2 - 60, 30, tocolor(65, 65, 65, 200))
				else
					dxDrawRectangle(sX/2 - panelSize[1]/4 + 30, sY/2 - panelSize[2]/4 + panelSize[2]/2 - 40, panelSize[1]/2 - 60, 30, tocolor(30, 30, 30, 200))
				end
				dxDrawText("Létrehozás", sX/2 - panelSize[1]/4 + 30 + (panelSize[1]/2 - 60)/2, sY/2 - panelSize[2]/4 + panelSize[2]/2 - 40 + 15, _, _, tocolor(200, 200, 200, 200), 1, headerFont, "center", "center", false, false, false, true)
			else -- ha csoportbanvan
				if currentGroupPage == 1 then
					dxDrawRectangle(sX/2 - panelSize[1]/2 + 15, sY/2 - panelSize[2]/2 + 50, panelSize[1] - 35, panelSize[2]-80, tocolor(35, 35, 35))
					dxDrawRectangle(sX/2 - panelSize[1]/2 + 15, sY/2 - panelSize[2]/2 + 50, panelSize[1] - 35, 30, tocolor(65, 65, 65))
					dxDrawText("#D19D6B" .. playerGroupName .. " (ID: "..getElementData(localPlayer, "a.PlayerGroup")..")", sX/2 - panelSize[1]/2 + 20, sY/2 - panelSize[2]/2 + 65, _, _, tocolor(200, 200, 200), 1, headerFont, "left", "center", false, false, false, true)
					dxDrawText("Név", sX/2 - panelSize[1]/2 + (panelSize[1]/2 - 100)/4 - 32, sY/2 - panelSize[2]/2 + 100, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center", false, false, false, true)
					dxDrawText("Ölések", sX/2 - panelSize[1]/2 + 50 + (panelSize[1]/2 - 100)/2, sY/2 - panelSize[2]/2 + 100, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center", false, false, false, true)
					dxDrawText("Halálok", sX/2 - panelSize[1]/2 + (panelSize[1]/2 - 100) - 20, sY/2 - panelSize[2]/2 + 100, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center", false, false, false, true)
					dxDrawText("Leader: #D19D6B" .. playerGroupLeaderName, sX/2 - panelSize[1]/2 + 15 + panelSize[1] - 40, sY/2 - panelSize[2]/2 + 65, _, _, tocolor(200, 200, 200), 1, headerFont, "right", "center", false, false, false, true)
				
					for k,v in ipairs(playerGroupMembers) do
						if k <= maxMembersShowing and (k > scrollingValue) then
							if isMouseInPosition(sX/2 - panelSize[1]/2 + 20, sY/2 - panelSize[2]/2 + 80 + (k - scrollingValue)*40, panelSize[1]/2 - 100, 35) or selectedMember == k then
								dxDrawRectangle(sX/2 - panelSize[1]/2 + 20, sY/2 - panelSize[2]/2 + 80 + (k - scrollingValue)*40, panelSize[1]/2 - 100, 35, tocolor(45, 45, 45))
							else
								dxDrawRectangle(sX/2 - panelSize[1]/2 + 20, sY/2 - panelSize[2]/2 + 80 + (k - scrollingValue)*40, panelSize[1]/2 - 100, 35, tocolor(25, 25, 25))
							end
							dxDrawText(v[1], sX/2 - panelSize[1]/2 + 25, sY/2 - panelSize[2]/2 + 80 + (k - scrollingValue)*40 + 35/2, _, _, tocolor(200, 200, 200), 1, normalFont, "left", "center", false, false, false, true)
							dxDrawText(v[3], sX/2 - panelSize[1]/2 + 50 + (panelSize[1]/2 - 100)/2, sY/2 - panelSize[2]/2 + 80 + (k - scrollingValue)*40 + 35/2, _, _, tocolor(200, 200, 200), 1, normalFont, "center", "center", false, false, false, true)
							dxDrawText(v[4], sX/2 - panelSize[1]/2 + (panelSize[1]/2 - 100) - 20, sY/2 - panelSize[2]/2 + 80 + (k - scrollingValue)*40 + 35/2, _, _, tocolor(200, 200, 200), 1, normalFont, "center", "center", false, false, false, true)
						end
					end

					dxDrawText("Klán név: #D19D6B" .. playerGroupName, sX/2 - 35, sY/2 - panelSize[2]/2 + 120, _, _, tocolor(200, 200, 200), 1, headerFont, "left", "center", false, false, false, true)
					dxDrawText("Klán syntax: #D19D6B" .. playerGroupSyntax, sX/2 - 35, sY/2 - panelSize[2]/2 + 150, _, _, tocolor(200, 200, 200), 1, headerFont, "left", "center", false, false, false, true)
					dxDrawText("Klán szín: " .. playerGroupHex .. "szín", sX/2 - 35, sY/2 - panelSize[2]/2 + 180, _, _, tocolor(200, 200, 200), 1, headerFont, "left", "center", false, false, false, true)
					dxDrawText("Klán létrehozva: #D19D6B" .. playerGroupCreatingDate, sX/2 - 35, sY/2 - panelSize[2]/2 + 210, _, _, tocolor(200, 200, 200), 1, headerFont, "left", "center", false, false, false, true)

					if getElementData(localPlayer, "a.PlayerGroupLeader") == currentGroupID then
						if isMouseInPosition(sX/2 - 40, sY / 2 + panelSize[2]/2 - 100, 200, 50) then
							dxDrawRectangle(sX/2 - 40, sY / 2 + panelSize[2]/2 - 100, 200, 50, tocolor(65, 65, 65))
						else
							dxDrawRectangle(sX/2 - 40, sY / 2 + panelSize[2]/2 - 100, 200, 50, tocolor(45, 45, 45))
						end
						dxDrawText("Kirúgás", sX/2 - 40 + 100, sY / 2 + panelSize[2]/2 - 100 + 25, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center", false, false, false, true)

						if isMouseInPosition(sX/2 - 40 + 210, sY / 2 + panelSize[2]/2 - 100, 200, 50) then
							dxDrawRectangle(sX/2 - 40 + 210, sY / 2 + panelSize[2]/2 - 100, 200, 50, tocolor(65, 65, 65))
						else
							dxDrawRectangle(sX/2 - 40 + 210, sY / 2 + panelSize[2]/2 - 100, 200, 50, tocolor(45, 45, 45))
						end
						dxDrawText("Tag hozzáadása", sX/2 - 40 + 210 + 100, sY / 2 + panelSize[2]/2 - 100 + 25, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center", false, false, false, true)

						local id = exports.a_dx:dxGetEdit("addPlayer")
						if (id) then
							local name = exports.a_dx:dxGetEditText(id)
							local targetPlayer = exports.a_core:findPlayer(localPlayer, name)
							dxDrawText(getElementData(targetPlayer, "a.PlayerName") or "No target", sX/2 - 40 + 210 + 100, sY / 2 + panelSize[2]/2 - 160, _, _, tocolor(200, 200, 200), 1, normalFont, "center", "center", false, false, false, true)
						end
					end
				end
			end
		elseif currentPage == 3 then
			-- DEFAULT PANEL DRAW
			dxDrawRectangle(sX/2 - panelSize[1]/2, sY/2 - panelSize[2]/2, panelSize[1], panelSize[2], tocolor(65, 65, 65)) -- alap panel
			dxDrawRectangle(sX/2 - panelSize[1]/2 + 2, sY/2 - panelSize[2]/2 + 2, panelSize[1] - 4, panelSize[2] - 4, tocolor(30, 30, 30)) -- alap panel
			for k, v in ipairs(buttons) do
				if k == currentPage then
					dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(45, 45, 45))
					dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(255, 255, 255), 1, headerFont, "center", "center")
				else
					if isMouseInPosition(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25) then
						dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(50, 50, 50))
						dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(255, 255, 255), 1, headerFont, "center", "center")
					else
						dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(20, 20, 20))
						dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center")
					end
				end
			end

			dxDrawRectangle(sX/2 - panelSize[1]/2 + 25, sY/2 - panelSize[2]/2 + 50, panelSize[1]/2 - 50, panelSize[2] - 80, tocolor(20, 20, 20))
			dxDrawText("Elérhető adminok:", sX/2 - panelSize[1]/2 + 35, sY/2 - panelSize[2]/2 + 65, _, _, tocolor(220, 220, 220), 1, headerFont, "left", "center")

			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "adminLevel") > 0 then
					dxDrawText("#D19D6B(" .. getElementData(v, "playerid") .. ") #c8c8c8" .. getElementData(v, "a.PlayerName") .. " #8FC3E4[" .. admins[getElementData(v, "adminLevel")] .. "]", sX/2 - panelSize[1]/2 + 35, sY/2 - panelSize[2]/2 + 100 + (k-1)*25, _, _, tocolor(200, 200, 200), 1, normalFont, "left", "center", false, false, false, true)
				end
			end
		elseif currentPage == 4 then
			dxDrawRectangle(sX/2 - panelSize[1]/2, sY/2 - panelSize[2]/2, panelSize[1], panelSize[2], tocolor(65, 65, 65)) -- alap panel
			dxDrawRectangle(sX/2 - panelSize[1]/2 + 2, sY/2 - panelSize[2]/2 + 2, panelSize[1] - 4, panelSize[2] - 4, tocolor(30, 30, 30)) -- alap panel
			for k, v in ipairs(buttons) do
				if k == currentPage then
					dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(45, 45, 45))
					dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(255, 255, 255), 1, headerFont, "center", "center")
				else
					if isMouseInPosition(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25) then
						dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(50, 50, 50))
						dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(255, 255, 255), 1, headerFont, "center", "center")
					else
						dxDrawRectangle(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25, tocolor(20, 20, 20))
						dxDrawText(v, sX/2 - panelSize[1]/2 + (193/2) + 5 + (k-1)*198, sY/2 - panelSize[2]/2 + (25/2) + 5, _, _, tocolor(200, 200, 200), 1, headerFont, "center", "center")
					end
				end
			end	

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
	else
		currentPage = 0
    end
  end

addEventHandler("onClientRender", root, mainPanel)

local allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } } -- numbers/lowercase chars/uppercase chars

function generateString ( len )
    
    if tonumber ( len ) then
        math.randomseed ( getTickCount () )

        local str = ""
        for i = 1, len do
            local charlist = allowed[math.random ( 1, 3 )]
            str = str .. string.char ( math.random ( charlist[1], charlist[2] ) )
        end

        return str
    end
    
    return false
    
end

function onClick(button, state)
	if dashboardIsOpen then
		for k, v in ipairs(buttons) do
			if isMouseInPosition(sX/2 - panelSize[1]/2 + 8 + (k-1)*198, sY/2 - panelSize[2]/2 + 5, 193, 25) then
				if k == 1 then
					exports.a_3dview:processSkinPreview(getElementModel(localPlayer), sX / 2 - panelSize[1]/2 + 20, sY / 2, 300, 500)
					local id = exports.a_dx:dxGetEdit("clanName")
					local id2 = exports.a_dx:dxGetEdit("clanSyntax")
					local id3 = exports.a_dx:dxGetEdit("clanHEX")
					local id4 = exports.a_dx:dxGetEdit("addPlayer")
					if id4 then
						exports.a_dx:dxDestroyEdit(id4)
					end
					if (id) and (id2) and (id3) then
						exports.a_dx:dxDestroyEdit(id4)
						exports.a_dx:dxDestroyEdit(id3)
						exports.a_dx:dxDestroyEdit(id2)
						exports.a_dx:dxDestroyEdit(id)
					end
				else
					local id = exports.a_dx:dxGetEdit("clanName")
					local id2 = exports.a_dx:dxGetEdit("clanSyntax")
					local id3 = exports.a_dx:dxGetEdit("clanHEX")
					local id4 = exports.a_dx:dxGetEdit("addPlayer")
					if id4 then
						exports.a_dx:dxDestroyEdit(id4)
					end
					if (id) and (id2) and (id3) then
						exports.a_dx:dxDestroyEdit(id4)
						exports.a_dx:dxDestroyEdit(id3)
						exports.a_dx:dxDestroyEdit(id2)
						exports.a_dx:dxDestroyEdit(id)
					end
					exports.a_3dview:processSkinPreview()
				end
				currentPage = k
			end
		end
		if currentPage == 2 and button == "left" and state == "down" then
			if isMouseInPosition(sX / 2 - 100, sY / 2, 200, 30) and not currentlyCreatingGroup and getElementData(localPlayer, "a.PlayerGroup") == 0 then
				currentlyCreatingGroup = true
				exports.a_dx:dxCreateEdit("clanName", "", "Klán név", sX/2 - panelSize[1]/4 + 15, sY/2 - panelSize[2]/4 + 40, 370/myX * sX, 30/myY * sY, 1, 30, 30)
				exports.a_dx:dxCreateEdit("clanSyntax", "", "Klán syntax", sX/2 - panelSize[1]/4 + 15, sY/2 - panelSize[2]/4 + 75, 370/myX * sX, 30/myY * sY, 1, 30, 30)
				exports.a_dx:dxCreateEdit("clanHEX", "", "Klán HEX színkód", sX/2 - panelSize[1]/4 + 15, sY/2 - panelSize[2]/4 + 110, 370/myX * sX, 30/myY * sY, 1, 30, 30)
			end

			if isMouseInPosition(sX/2 - panelSize[1]/4 + 30, sY/2 - panelSize[2]/4 + panelSize[2]/2 - 40, panelSize[1]/2 - 60, 30) and currentlyCreatingGroup then
				local currentPlayerMoney = getElementData(localPlayer, "a.Money")
				if currentPlayerMoney < 100000 then
					exports.a_interface:makeNotification(2, "Nincs elég pénzed a klán létrehozásához")
					return
				end
				local id = exports.a_dx:dxGetEdit("clanName")
				local id2 = exports.a_dx:dxGetEdit("clanSyntax")
				local id3 = exports.a_dx:dxGetEdit("clanHEX")
				local name = exports.a_dx:dxGetEditText(id)
				local syntax = exports.a_dx:dxGetEditText(id2)
				local hex = exports.a_dx:dxGetEditText(id3)

				if tostring(name) and string.len(name) >= 3 and string.len(name) <= 10 then
					if tostring(syntax) and string.len(syntax) >= 2 and string.len(syntax) <= 5 then
						if tostring(hex) and string.len(hex) == 6 then
							triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "createclan", tostring(name), tostring(syntax), tostring(hex))
							exports.a_interface:makeNotification(1, "Sikeresen létrehoztad a klánodat.")
							showPanel()
						else
							exports.a_interface:makeNotification(2, "HEX színkód hibás. Példa: c8c8c8")
							-- hex code rovid vagy nincs benne #
						end
					else
						exports.a_interface:makeNotification(2, "Klán syntax rövid! (min. 2, max. 5 karakter)")
						-- tul rovid syntax
					end
				else
					exports.a_interface:makeNotification(2, "Klán neve rövid!. (min. 3, max. 10 karakter)")
					--tul rovid name
				end
			end
		end
		if currentPage == 2 and button == "left" and state == "down" then
			if getElementData(localPlayer, "a.PlayerGroupLeader") == currentGroupID then
				for k,v in ipairs(playerGroupMembers) do
					if k <= maxMembersShowing and (k > scrollingValue) then
						if isMouseInPosition(sX/2 - panelSize[1]/2 + 20, sY/2 - panelSize[2]/2 + 80 + (k - scrollingValue)*40, panelSize[1]/2 - 100, 35) then
							selectedMember = k
						end
					end
				end
				if isMouseInPosition(sX/2 - 40, sY / 2 + panelSize[2]/2 - 100, 200, 50) then
					if not selectedMember then
						exports.a_interface:makeNotification(2, "Nem választottál ki tagot!")
					else
						if playerGroupMembers[selectedMember][2] == getElementData(localPlayer, "a.accID") then
							exports.a_interface:makeNotification(2, "Nem tudod kirúgni magadat. (Ha törölni akarod a klánt, vedd fel a kapcsolatot a tulajdonossal)")
							return
						end
						exports.a_interface:makeNotification(1, "Sikeresen kirúgtad " .. playerGroupMembers[selectedMember][1] .. "-t a klánból.")
						triggerServerEvent("kickPlayerFromGroup", localPlayer, localPlayer, playerGroupMembers[selectedMember][2], playerGroupMembers[selectedMember][1])
						table.removeValue(playerGroupMembers, playerGroupMembers[selectedMember])
					end
				end

				if isMouseInPosition(sX/2 - 40 + 210, sY / 2 + panelSize[2]/2 - 100, 200, 50) then
					if not choosingMember then
						choosingMember = true
						exports.a_dx:dxCreateEdit("addPlayer", "", "Név", sX/2 + 175, sY / 2 + panelSize[2]/2 - 140, 190/myX * sX, 30/myY * sY, 1, 30, 30)
					else
						choosingMember = false
						local id = exports.a_dx:dxGetEdit("addPlayer")
						if (id) then
							local name = exports.a_dx:dxGetEditText(id)
							local targetPlayer = exports.a_core:findPlayer(localPlayer, name)
							if targetPlayer then
								triggerServerEvent("addPlayerToGroup", localPlayer, localPlayer, targetPlayer)
							else
								exports.a_interface:makeNotification(2, "Nincs ilyen játékos.")
							end
						end
					end
				end
			end
		end
		if currentPage == 4 and button == "left" and state == "down" then
			if isMouseInPosition(sX/2 - panelSize[1]/2 + 30, sY/2 - panelSize[2]/2 + 50, 200, 35) then
				exports.a_interface:makeNotification(1, "Sikeresen resetelted a statjaid.")
				triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "resetstat")
			end
			if isMouseInPosition(sX/2 - panelSize[1]/2 + 205, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20) then
				local currentCrosshair = getElementData(localPlayer, "a.Crosshair")
				if currentCrosshair + 1 > 11 then
					triggerServerEvent("changeDataSync", localPlayer, "a.Crosshair", 11)
					--applyShader("siteM16", "files/icons/chs/" .. getElementData(localPlayer, "a.Crosshair") .. ".png")
					triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "crosshair", getElementData(localPlayer, "a.Crosshair"))
				else
					triggerServerEvent("changeDataSync", localPlayer, "a.Crosshair", getElementData(localPlayer, "a.Crosshair") + 1)
					--applyShader("siteM16", "files/icons/chs/" .. getElementData(localPlayer, "a.Crosshair") .. ".png")
					triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "crosshair", getElementData(localPlayer, "a.Crosshair"))
				end
			end
			if isMouseInPosition(sX/2 - panelSize[1]/2 + 185, sY/2 - panelSize[2]/2 + 102 + 5, 20, 20) then
				local currentCrosshair = getElementData(localPlayer, "a.Crosshair")
				if currentCrosshair - 1 < 1 then
					triggerServerEvent("changeDataSync", localPlayer, "a.Crosshair", 1)
					applyShader("siteM16", "files/icons/chs/" .. getElementData(localPlayer, "a.Crosshair") .. ".png")
					triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "crosshair", getElementData(localPlayer, "a.Crosshair"))
				else
					triggerServerEvent("changeDataSync", localPlayer, "a.Crosshair", getElementData(localPlayer, "a.Crosshair") - 1)
					--applyShader("siteM16", "files/icons/chs/" .. getElementData(localPlayer, "a.Crosshair") .. ".png")
					triggerServerEvent("requestServersideSave", localPlayer, localPlayer, "crosshair", getElementData(localPlayer, "a.Crosshair"))
				end
			end
		end
	end
end
addEventHandler("onClientClick", root, onClick)

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
		playerGroupHex = "#" .. playerGroupHex
		currentGroupID = tonumber(arguments[6])
		playerGroupMembers = table
		randomString = generateString(6)
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
		preview = exports.a_op:createObjectPreview(temp,0,0,180,sX/2 + 20, sY/2 - panelSize[2]/2 + 50, 800, 800, false,true);
		exports.a_op:setPositionOffsets(preview,2,2,0);
		skinPreview[1] = temp;
		skinPreview[2] = preview;
	end, 200, 1)
end

function destroyObjectPreviewInPanel()
	if skinPreview and skinPreview[1] and isElement(skinPreview[1]) then
		exports.a_op:destroyObjectPreview(skinPreview[2])
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