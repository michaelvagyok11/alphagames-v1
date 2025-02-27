function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

local screenX, screenY = guiGetScreenSize()
responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local slotLimit = 6

local panelState = false

local panelWidth = (defaultSettings.slotBoxWidth + 5) * slotLimit + 5
local panelHeight = defaultSettings.slotBoxHeight + 5 * 2

local panelPosX = screenX  / 2 - panelWidth / 2
local panelPosY = screenY - panelHeight - 5

actionBarItems = {}
local actionBarSlots = {}
local slotPositions = false

local loggedIn = false
local editHud = false
local bigRadarState = false

local moveDifferenceX = 0
local moveDifferenceY = 0

local movedSlotId = false
local lastHoverSlotId = false
local hoverSpecialItem = false

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "loggedIn") then
			loadActionBarItems()

			loggedIn = true
			panelState = true

			triggerEvent("requestChangeItemStartPos", localPlayer)
			triggerEvent("movedItemInInv", localPlayer, true)
		end
	end)

function loadActionBarItems()
	setTimer(
		function ()

			local items = getElementData(localPlayer, "actionBarItems") or {}

			--outputConsole(inspect(items))
			triggerEvent("movedItemInInv", localPlayer, true)

			actionBarSlots = {}

			for i = 1, 6 do
				if items[i] then
					--outputChatBox(items[i])
					actionBarSlots[i - 1] = items[i]
				end
			end
		end, 2000, 1
	)
end

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName, oldValue)
		if dataName == "loggedIn" then
			if getElementData(localPlayer, "loggedIn") then
				loadActionBarItems()

				loggedIn = true
				panelState = true	
			end
		elseif dataName == "actionBarItems" then
			triggerEvent("movedItemInInv", localPlayer)
		elseif dataName == "bigRadarState" then
			bigRadarState = getElementData(source, "bigRadarState")
		end
	end)

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY)
		if loggedIn and not editHud and not bigRadarState then
			if button == "left" then
				if state == "down" then
					local hoverSlotId, slotPosX, slotPosY = findActionBarSlot(absX, absY)

					if hoverSlotId and actionBarSlots[hoverSlotId] then
						movedSlotId = hoverSlotId

						moveDifferenceX = absX - slotPosX
						moveDifferenceY = absY - slotPosY

						playSound("files/sounds/select.mp3")
					end
				elseif state == "up" then
					if movedSlotId then
						local items = getElementData(localPlayer, "actionBarItems") or {}
						local hoverSlotId = findActionBarSlot(absX, absY)

						if hoverSlotId then
							if not actionBarSlots[hoverSlotId] then
								actionBarSlots[hoverSlotId] = actionBarSlots[movedSlotId]
								items[hoverSlotId+1] = actionBarSlots[movedSlotId]

								for i = 1, 6 do
									if items[i] then
										if movedSlotId == i - 1 then
											items[i] = nil
										end
									end
								end

								setElementData(localPlayer, "actionBarItems", items)
								actionBarSlots[movedSlotId] = nil
							end
						else
							for i = 1, 6 do
								if items[i] then
									if movedSlotId == i - 1 then
										items[i] = nil
									end
								end
							end
								
							actionBarSlots[movedSlotId] = nil
							setElementData(localPlayer, "actionBarItems", items)
						end

						playSound("files/sounds/select.mp3")

						movedSlotId = false
					elseif hoverSpecialItem then
						if currentItemInUse then
							itemsTable.player[currentItemInUse.slot].inUse = false
							triggerServerEvent("detachObject", localPlayer)
							currentItemInUse = false
							currentItemRemainUses = false
						end
					end
				end
			elseif button == "right" then
				if state == "up" then
					if hoverSpecialItem and currentItemInUse then
						useSpecialItem()
					end
				end
			end
		end
	end)

function putOnActionBar(slot, item)
	if slot then
		if not actionBarSlots[slot] then
			local items = getElementData(localPlayer, "actionBarItems") or {}

			actionBarSlots[slot] = item.dbID
			items[slot + 1] = item.dbID

			setElementData(localPlayer, "actionBarItems", items)

			return true
		else
			return false
		end
	else
		return false
	end
end

function findActionBarSlot(x, y)
	if panelState then
		local slot = false
		local slotPosX, slotPosY = false, false

		for i = 0, slotLimit - 1 do
			if not slotPositions or not slotPositions[i] then
				return
			end

			local x2 = slotPositions[i][1]
			local y2 = slotPositions[i][2]

			if x >= x2 and x <= x2 + defaultSettings.slotBoxWidth and y >= y2 and y <= y2 + defaultSettings.slotBoxHeight then
				slot = tonumber(i)
				slotPosX, slotPosY = x2, y2
				break
			end
		end

		if slot then
			return slot, slotPosX, slotPosY
		else
			return false
		end
	else
		return false
	end
end

for i = 1, slotLimit do
	bindKey(tostring(i), "down",
		function ()
			if not editHud and not bigRadarState and loggedIn then
				useActionSlot(i)
			end
		end
	)
end

function useActionSlot(slot)
	if not haveMoving and slot then
		slot = tonumber(slot - 1)

		if not guiGetInputEnabled() then
			local item = tonumber(actionBarSlots[slot])

			if item then
				useItem(item)
			end
		end
	end
end

addEvent("updateItemID", true)
addEventHandler("updateItemID", getRootElement(),
	function (ownerType, itemId, newId)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			newId = tonumber(newId)
			
			if itemId and newId then
				for i = 0, slotLimit - 1 do
					if tonumber(actionBarSlots[i]) == itemId then
						actionBarItems[i].itemId = newId
					end
				end
			end
		end
	end)

addEvent("updateData1", true)
addEventHandler("updateData1", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			
			if itemId and newData then
				for i = 0, slotLimit - 1 do
					if tonumber(actionBarSlots[i]) == itemId then
						actionBarItems[i].data1 = newData
					end
				end
			end
		end
	end)

addEvent("updateData2", true)
addEventHandler("updateData2", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			
			if itemId and newData then
				for i = 0, slotLimit - 1 do
					if tonumber(actionBarSlots[i]) == itemId then
						actionBarItems[i].data2 = newData
					end
				end
			end
		end
	end)

addEvent("updateData3", true)
addEventHandler("updateData3", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			
			if itemId and newData then
				for i = 0, slotLimit - 1 do
					if tonumber(actionBarSlots[i]) == itemId then
						actionBarItems[i].data3 = newData
					end
				end
			end
		end
	end)

function isPointOnActionBar(x, y)
	if panelState then
		if x >= panelPosX and x <= panelPosX + panelWidth and y >= panelPosY and y <= panelPosY + panelHeight then
			return true
		else
			return false
		end
	else
		return false
	end
end

function changeItemStartPos(x, y)
	panelPosX = x
	panelPosY = y
end

slotPositions = {}

for i = 0, slotLimit - 1 do
	slotPositions[i] = {math.floor(panelPosX + 5 + (defaultSettings.slotBoxWidth + 5) * i), panelPosY + 5}
end

function processActionBarShowHide(state)
	panelState = state
end

local lastActionBarX = 9999
local lastActionBarY = 9999
local actionBarState = true

render = {}

lastActionBarX, lastActionBarY = screenX / 2 - 125.5, screenY - 46 - resp(5)

panelState = true

function hideActionBar(state)
	state = not state
	panelState = state
end

render.actionbar = function (x, y)
	if not panelState and not getElementData(localPlayer, "loggedIn") then 
		return
	end

	if getElementData(localPlayer, "loggedIn") then 
		local sx, sy = 251, 46

		--x, y = x - 5, y - 5

		bordercolor = bordercolor or tocolor(0, 0, 0, 200)

		dxDrawRectangle(panelPosX, panelPosY, sx, 2, bordercolor)
		dxDrawRectangle(panelPosX, panelPosY + sy - 2, sx, 2, bordercolor)
		dxDrawRectangle(panelPosX, panelPosY + 2, 2, sy - 4, bordercolor)
		dxDrawRectangle(panelPosX + sx-2, panelPosY + 2, 2, sy - 4, bordercolor)

		--x, y = x + 5, y + 5

		dxDrawRectangle(panelPosX, panelPosY, sx, sy, tocolor(25, 25, 25, 255))

		--if lastActionBarX ~= x or lastActionBarY ~= y then
		--	lastActionBarX = x
		--	lastActionBarY = y
		--	changeItemStartPos(x, y)
		--end

		return true
	end
end
addEventHandler("onClientRender", root, render.actionbar)

addEvent("requestChangeItemStartPos", true)
addEventHandler("requestChangeItemStartPos", localPlayer,
	function()
		lastActionBarX, lastActionBarY = 9999, 9999
	end
)

addEventHandler("onClientRender", getRootElement(),
	function ()
		if slotPositions and panelState and getElementData(localPlayer, "loggedIn") then
			if isCursorShowing() then
				editHud = getKeyState("lctrl")
			elseif editHud then
				editHud = false
			end

			local cx, cy = getCursorPosition()

			if cx and cy then
				cx = cx * screenX
				cy = cy * screenY
			else
				cx, cy = -1, -1
			end

			for i = 0, slotLimit - 1 do
				if slotPositions[i] then
					renderActionBarItem(i, slotPositions[i][1], slotPositions[i][2], cx, cy)
				end
			end

			if movedSlotId then
				local x = cx - moveDifferenceX
				local y = cy - moveDifferenceY
				local item = false

				for k, v in pairs(itemsTable.player) do
					if actionBarSlots[movedSlotId] == v.dbID then
						item = v
						break
					end
				end

				if item and tonumber(item.itemId) and tonumber(item.amount) then
					drawActionbarImage(item, x, y)
					dxDrawText(item.amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.5, myriadpro, "right")
				else
					dxDrawImage(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, "files/noitem.png")
				end
			end

			hoverSpecialItem = false
		end
	end, true, "low")

function renderActionBarItem(slot, x, y, cx, cy)
	if actionBarItems[slot] and actionBarSlots[slot] and slot ~= movedSlotId then
		local item = actionBarItems[slot].slot
		local slotColor = tocolor(50, 50, 50, 200)
		local inUse = false

		if item and itemsTable.player[item] and itemsTable.player[item].inUse then
			slotColor = tocolor(61, 122, 188, 200)
			inUse = true
		end

		if (getKeyState(slot + 1) or cx >= x and cx <= x + defaultSettings.slotBoxWidth and cy >= y and cy <= y + defaultSettings.slotBoxHeight) and not editHud then
			if not inUse then
				slotColor = tocolor(209, 157, 107, 200)
			end
			
			if lastHoverSlotId ~= slot then
				lastHoverSlotId = slot

				if not movedSlotId then
					playSound("files/sounds/hover.wav")
				end
			end
		elseif lastHoverSlotId == slot then
			lastHoverSlotId = false
		end

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, slotColor, false)

		if actionBarItems[slot].itemId and actionBarItems[slot].amount then
			drawActionbarImage(actionBarItems[slot], x, y)
			dxDrawText(actionBarItems[slot].amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.5, myriadpro, "right")
		else
			dxDrawImage(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, "files/noitem.png")
		end

		if inUse then
			dxDrawImage(x - 3, y - 3, 42, 42, "files/used.png", 0, 0, 0, tocolor(255, 255, 255, 150))
		end
	else
		local slotColor = tocolor(50, 50, 50, 200)

		if getKeyState(slot + 1) or cx >= x and cx <= x + defaultSettings.slotBoxWidth and cy >= y and cy <= y + defaultSettings.slotBoxHeight then
			if not editHud then
				slotColor = tocolor(209, 157, 107, 200)
			end
		end

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, slotColor, false)
	end
end

local sideWeapons = {
	--[[[1] = 355,
	[2] = 348,
	[3] = 346,
	[4] = 334,
	[5] = 335,
	[6] = 356,
	[7] = 349,
	[8] = 347,
	[9] = 355,
	[10] = 355,
	[11] = 353,
	[12] = 352,
	[13] = 372,
	[19] = 355,
	[20] = 355,
	[21] = 355,
	[22] = 355,
	[23] = 355,
	[24] = 348,
	[25] = 348,
	[26] = 353,
	[27] = 353,
	[28] = 353,
	[29] = 353,
	[30] = 353,
	[31] = 353,
	[32] = 353,
	[33] = 353,
	[34] = 353,
	[35] = 351,
	[36] = 356,
	[37] = 356,
	[38] = 356,
	[39] = 356,
	[40] = 356,]]
}

addEvent("movedItemInInv", true)
addEventHandler("movedItemInInv", getRootElement(),
	function (simpleUpdate)
		
		for i = 0, slotLimit - 1 do
			actionBarItems[i] = {}

			for k, v in pairs(itemsTable.player) do
				if actionBarSlots[i] == v.dbID then
					actionBarItems[i].slot = tonumber(v.slot)
					actionBarItems[i].itemId = tonumber(v.itemId)
					actionBarItems[i].amount = tonumber(v.amount)
					actionBarItems[i].data1 = tonumber(v.data1)
					actionBarItems[i].data2 = tonumber(v.data2)
					actionBarItems[i].data3 = tonumber(v.data3)
					break
				end
			end
		end

		if not simpleUpdate then
			local added = {}
			local datas = {}

			for i = 0, defaultSettings.slotLimit - 1 do
				if itemsTable.player[i] then
					local item = itemsTable.player[i]

					if sideWeapons[item.itemId] then
						local k = item.itemId .. "," .. (weaponSkins[item.itemId] or 0)

						if not added[k] then
							added[k] = true

							if item.inUse then
								table.insert(datas, {item.itemId, "inuse", weaponSkins[item.itemId] or 0})
							else
								table.insert(datas, {item.itemId, true, weaponSkins[item.itemId] or 0})
							end
						end
					end
				end
			end

			local currentdatas = getElementData(localPlayer, "playerSideWeapons") or {}
			local updatedata = false

			if currentdatas then
				local old = {}
				local new = {}

				for k, v in ipairs(currentdatas) do
					old[tostring(v[1]) .. "," .. tostring(v[2]) .. "," .. tostring(v[3])] = true
				end
				
				for k, v in ipairs(datas) do
					new[tostring(v[1]) .. "," .. tostring(v[2]) .. "," .. tostring(v[3])] = true
				end
				
				for k, v in pairs(old) do
					if not new[k] then
						updatedata = true
						break
					end
				end
				
				for k, v in pairs(new) do
					if not old[k] then
						updatedata = true
						break
					end
				end
			end

			if updatedata then
				setElementData(localPlayer, "playerSideWeapons", datas)
			end
		end
	end)

function isActionBarVisible()
	return panelState
end