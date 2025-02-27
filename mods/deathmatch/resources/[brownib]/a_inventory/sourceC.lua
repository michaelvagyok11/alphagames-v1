local screenX, screenY = guiGetScreenSize()

local panelState = false

local KeySizeX = (defaultSettings.slotBoxWidth + 10)

local panelWidth = (defaultSettings.slotBoxWidth + 3) * defaultSettings.width + 7
local panelHeight = (defaultSettings.slotBoxHeight + 3) * math.floor(defaultSettings.slotLimit / defaultSettings.width) + 7 + 25

local panelPosX = screenX / 2 + 200
local panelPosY = screenY / 2 + 50

local stackGUI = false
local stackAmount = 0

local moveDifferenceX = 0
local moveDifferenceY = 0
local panelIsMoving = false

local KeyItemActivatedIn = nil

local Roboto = dxCreateFont("files/fonts/Roboto.ttf", 22, false, "antialiased")

itemsTableState = "player"
itemsTable = {}
itemsTable.player = {}
itemsTable.vehicle = {}
itemsTable.object = {}
currentInventoryElement = localPlayer

haveMoving = false
local movedSlotId = false
local lastHoverSlotId = false

--***Updated For keychain***--
local LastHoverSlotKeyId = false
local KeysOnItem = {}
local KeyItemActivated = false
--***Updated For keychain***--

local currentTab = "main"
local hoverTab = false

local itemPictures = {}
local perishableTimer = false
local grayItemPictures = {}

setTimer(
	function ()
		toggleControl("next_weapon", false)
		toggleControl("previous_weapon", false)
	end,
1000, 0)

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)

function deepcopy(t)
	local copy
	if type(t) == "table" then
		copy = {}
		for k, v in next, t, nil do
			copy[deepcopy(k)] = deepcopy(v)
		end
		setmetatable(copy, deepcopy(getmetatable(t)))
	else
		copy = t
	end
	return copy
end

function rotateAround(angle, x1, y1, x2, y2)
	angle = math.rad(angle)

	local rotatedX = x1 * math.cos(angle) - y1 * math.sin(angle)
	local rotatedY = x1 * math.sin(angle) + y1 * math.cos(angle)

	return rotatedX + (x2 or 0), rotatedY + (y2 or 0)
end

local renameProcess = false
local renameDetails = false

local myCharacterId = getElementData(localPlayer, "a.accID")
local myAdminLevel = getElementData(localPlayer, "adminLevel")

addEvent("loadItems", true)
addEventHandler("loadItems", getRootElement(),
	function (items, ownerType, element, reopen)
		if items and type(items) == "table" then
			itemsTable[ownerType] = {}

			for k, v in pairs(items) do
				addItem(tostring(ownerType), v.dbID, v.slot, v.itemId, v.amount, v.data1, v.data2, v.data3, v.nameTag, v.serial)
			end

			if reopen then
				toggleInventory(false)
				currentInventoryElement = element
				itemsTableState = ownerType
				toggleInventory(true)
			end

			triggerEvent("movedItemInInv", localPlayer)
		end
	end)

addEvent("$$$$$$$$$$$$$$$", true)
addEventHandler("$$$$$$$$$$$$$$$", getRootElement(),
	function (ownerType, item)
		if itemsTable[ownerType] and item and type(item) == "table" then
			addItem(ownerType, item.dbID, item.slot, item.itemId, item.amount, item.data1, item.data2, item.data3, item.nameTag, item.serial)
		end
	end)

addEvent("deleteItem", true)
addEventHandler("deleteItem", getRootElement(),
	function (ownerType, items)
		if itemsTable[ownerType] and items and type(items) == "table" then
			for k, v in pairs(items) do
				for i = 0, defaultSettings.slotLimit * 3 - 1 do
					if itemsTable[ownerType][i] and itemsTable[ownerType][i].dbID == v then
						itemsTable[ownerType][i] = nil

						if movedSlotId == i then
							movedSlotId = false
						end
					end
				end
			end
		end
	end)

addEvent("updateAmount", true)
addEventHandler("updateAmount", getRootElement(),
	function (ownerType, itemId, newAmount)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			newAmount = tonumber(newAmount)

			if itemId and newAmount then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].amount = newAmount
					end
				end
			end
		end
	end)

addEvent("updateItemID", true)
addEventHandler("updateItemID", getRootElement(),
	function (ownerType, itemId, newId)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)
			newId = tonumber(newId)

			if itemId and newId then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].itemId = newId
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
			newData = tonumber(newData) or newData

			if itemId and newData then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].data1 = newData
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
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].data2 = newData
						triggerServerEvent("updateData2", localPlayer, localPlayer, itemId, newData)
					end
				end
			end
		end
	end)

addEvent("updateData2Ex", true)
addEventHandler("updateData2Ex", getRootElement(),
	function (ownerType, itemId, newData)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)

			if itemId and newData then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].data2 = newData
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
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].data3 = newData
						triggerServerEvent("updateData3", localPlayer, localPlayer, itemId, newData)
					end
				end
			end
		end
	end)

addEvent("updateNameTag", true)
addEventHandler("updateNameTag", getRootElement(),
	function (itemId, text)
		if itemsTable.player then
			itemId = tonumber(itemId)

			if itemId and text then
				for k, v in pairs(itemsTable.player) do
					if v.dbID == itemId then
						itemsTable.player[v.slot].nameTag = text
					end
				end
			end
		end
	end)

addEvent("updateInUse", true)
addEventHandler("updateInUse", getRootElement(),
	function (ownerType, itemId, inuse)
		if itemsTable[ownerType] then
			itemId = tonumber(itemId)

			if itemId then
				for k, v in pairs(itemsTable[ownerType]) do
					if v.dbID == itemId then
						itemsTable[ownerType][v.slot].inUse = inuse
					end
				end
			end
		end
	end)

addEvent("unLockItem", true)
addEventHandler("unLockItem", getRootElement(),
	function (ownerType, slot)
		if itemsTable[ownerType] and itemsTable[ownerType][slot] and itemsTable[ownerType][slot].locked then
			itemsTable[ownerType][slot].locked = false
		end
	end)

addEventHandler("onClientElementDataChange", localPlayer,
	function (dataName)
		if dataName == "loggedIn" then
			if getElementData(source, dataName) then
			end
		end

		if dataName == "a.accID" then
			myCharacterId = getElementData(localPlayer, "a.accID")
		end

		if dataName == "adminLevel" then
			myAdminLevel = getElementData(localPlayer, "adminLevel")
		end
	end)

function addItem(ownerType, dbID, slot, itemId, amount, data1, data2, data3, nameTag, serial)
	if dbID and slot and itemId and amount and not itemsTable[ownerType][slot] then
		itemsTable[ownerType][slot] = {}
		itemsTable[ownerType][slot].dbID = dbID
		itemsTable[ownerType][slot].slot = slot
		itemsTable[ownerType][slot].itemId = itemId
		itemsTable[ownerType][slot].amount = amount
		itemsTable[ownerType][slot].data1 = data1
		itemsTable[ownerType][slot].data2 = data2
		itemsTable[ownerType][slot].data3 = data3
		itemsTable[ownerType][slot].inUse = false
		itemsTable[ownerType][slot].locked = false
		itemsTable[ownerType][slot].nameTag = nameTag
		itemsTable[ownerType][slot].serial = serial
	end
end

function findEmptySlot(ownerType)
	local emptySlot = false

	for i = 0, defaultSettings.slotLimit - 1 do
		if not itemsTable[ownerType][i] then
			emptySlot = i
			break
		end
	end

	return emptySlot
end

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		if getElementData(localPlayer, "loggedIn") then
			setTimer(triggerServerEvent, 5000, 1, "Ä\€Äđ&ä&&Ä", localPlayer)
		end

		for k, v in pairs(availableItems) do
			if fileExists("files/items/" .. k - 1 .. ".png") then
				itemPictures[k] = dxCreateTexture("files/items/" .. k - 1 .. ".png")
			else
				itemPictures[k] = dxCreateTexture("files/items/nopic.png")
			end
		end
	end
)

local lastOpenTick = 0

bindKey("i", "down",
	function ()
		if getElementData(localPlayer, "loggedIn") then
			toggleInventory(not panelState)

			itemsTableState = "player"
			currentInventoryElement = localPlayer

			panelIsMoving = false

			if renameProcess then
				itemsTable.player[renameProcess].inUse = false
				renameProcess = false
				renameDetails = false
				setCursorAlpha(255)
			end
		end
	end)

function toggleInventory(state)
	if panelState ~= state then
		if state then
			checkRecipeHaveItem()

			if isElement(stackGUI) then
				destroyElement(stackGUI)
			end

			stackAmount = 0
			stackGUI = guiCreateEdit(panelPosX + panelWidth - 50 - 10, panelPosY, 50, 20, "", false)

			guiSetAlpha(stackGUI, 0)
			guiEditSetMaxLength(stackGUI, 4)

			if not iTaste then 
				addEventHandler("onClientRender", getRootElement(), onRender, true, "low-999")
			end

			iTaste = true

			lastOpenTick = getTickCount()

			addEventHandler("onClientRender", getRootElement(), function ()
				local currentTick = getTickCount()

				alphaProg = (currentTick - lastOpenTick) / 300
				alphaProgress = interpolateBetween(0, 0, 0, 1, 0, 0, alphaProg, "Linear")

				--print("aaa")
			end)

			panelState = true
		else
			if itemsTableState == "vehicle" or itemsTableState == "object" then
				triggerServerEvent("&ŁđÄÍ}{Ä>ßß÷÷÷|", localPlayer, currentInventoryElement, getElementsByType("player", getRootElement(), true))
			end

			lastOpenTick = getTickCount()

			addEventHandler("onClientRender", getRootElement(), function ()
				local currentTick = getTickCount()

				alphaProg = (currentTick - lastOpenTick) / 300
				alphaProgress = interpolateBetween(1, 0, 0, 0, 0, 0, alphaProg, "Linear")

				--guiSetAlpha(stackGUI, 0)
			end)

			panelState = false

			movedSlotId, movedItem = false, false

			--if isElement(stackGUI) then
			--	destroyElement(stackGUI)
			--end

			--stackGUI = nil
			stackAmount = 0
		end
	end
end

function applyRecipe(items)
	appliedRecipeItems = items
	requiredRecipeItems = {}

	if items then
		checkRecipeHaveItem()
	end
end

function checkRecipeHaveItem()
	if currentTab == "crafting" and appliedRecipeItems then
		local items = {}

		for k, v in pairs(itemsTable.player) do
			items[v.itemId] = true
		end

		for y = 1, 3 do
			requiredRecipeItems[y] = {}

			if appliedRecipeItems[y] then
				for x = 1, 3 do
					if appliedRecipeItems[y][x] then
						requiredRecipeItems[y][x] = {appliedRecipeItems[y][x], items[appliedRecipeItems[y][x]]}
					end
				end
			end
		end
	end
end

addEvent("requestCrafting", true)
addEventHandler("requestCrafting", getRootElement(),
	function (recipe, state)
		if recipe and availableRecipes[recipe] then
			if state then
				craftStartTime = getTickCount()
				setTimer(craftDone, 10000, 1, availableRecipes[recipe].finalItem)
			end

			craftingProcess = false
		end
	end)

function craftDone(item)
	if item[1] and item[2] then
		outputChatBox("#d19d6b► alphaGames: #FFFFFFSikeresen elkészítetted a kiválasztott receptet! #32b3ef(" .. getItemName(item[1]) .. ")", 255, 255, 255, true)
		exports.stdma_hud:showInfobox("success", "Sikeresen elkészítetted a kiválasztott receptet! (" .. getItemName(item[1]) .. ")")
	end
end

local craftingSounds = {}

addEvent("crafting3dSound", true)
addEventHandler("crafting3dSound", getRootElement(),
	function (typ)
		if isElement(craftingSounds[source]) then
			destroyElement(craftingSounds[source])
		end

		if typ then
			craftingSounds[source] = playSound3D("files/sounds/" .. typ .. ".mp3", getElementPosition(source))
			setElementInterior(craftingSounds[source], getElementInterior(source))
			setElementDimension(craftingSounds[source], getElementDimension(source))
			attachElements(craftingSounds[source], source)
			setTimer(
				function (sourceElement)
					craftingSounds[sourceElement] = nil
				end,
			10000, 1, source)
		end
	end)

addEvent("toggleVehicleTrunk", true)
addEventHandler("toggleVehicleTrunk", getRootElement(),
	function (state, vehicle)
		if isElement(vehicle) then
			local soundPath = false

			if state == "open" then
				soundPath = exports.stdma_vehiclepanel:getDoorOpenSound(getElementModel(vehicle))
			elseif state == "close" then
				soundPath = exports.stdma_vehiclepanel:getDoorCloseSound(getElementModel(vehicle))
			end

			if soundPath then
				local x, y, z = getElementPosition(vehicle)
				local int = getElementInterior(vehicle)
				local dim = getElementDimension(vehicle)
				local sound = playSound3D(soundPath, x, y, z)

				if isElement(sound) then
					setElementInterior(sound, int)
					setElementDimension(sound, dim)
				end
			end
		end
	end)

addEventHandler("onClientGUIChanged", getRootElement(),
	function ()
		if isElement(stackGUI) and source == stackGUI and not searchState then
			local stack = tonumber(guiGetText(stackGUI))

			if stack then
				if stack >= 0 then
					stackAmount = tonumber(string.format("%.0f", stack))
				else
					stackAmount = 0
				end
			else
				stackAmount = 0
			end

			if string.find(guiGetText(stackGUI), "i") then
				toggleInventory(false)
			end
		end
	end)

function processNotepadText()
	local chunks = {}

	noteText = {}

	for chunk in utf8.gmatch(notepadText .. "\n", "([^\n]*)\n") do
		table.insert(chunks, chunk)
	end

	for i = 1, #chunks do
		local t2 = {}

		for word in utf8.gmatch(chunks[i], "([^ ]*)") do
			table.insert(t2, word .. " ")
		end

		local str = ""

		for j = 1, #t2 do
			str = str .. t2[j]
			t2[j] = utf8.gsub(t2[j], "\n", "")

			if dxGetTextWidth(str, 1, notepadFont) + 70 > 395 then
				table.insert(noteText, "")
				str = str .. " "
			end
		end

		table.insert(noteText, str)
	end
end

function processNotepadTextEx(text, font)
	local chunks = {}
	local textlines = {}

	for chunk in utf8.gmatch(text .. "\n", "([^\n]*)\n") do
		table.insert(chunks, chunk)
	end

	for i = 1, #chunks do
		local t2 = {}

		for word in utf8.gmatch(chunks[i], "([^ ]*)") do
			table.insert(t2, word .. " ")
		end

		local str = ""

		for j = 1, #t2 do
			str = str .. t2[j]
			t2[j] = utf8.gsub(t2[j], "\n", "")

			if dxGetTextWidth(str, 1, font) + 70 > 395 then
				table.insert(textlines, "")
				str = str .. " "
			end
		end

		table.insert(textlines, str)
	end

	return textlines
end

function canWriteToNotepad()
	if #noteText >= 22 then
		return dxGetTextWidth(noteText[#noteText], 1, notepadFont) < 320
	elseif not utf8.find(noteText[#noteText], " ") then
		return dxGetTextWidth(noteText[#noteText], 1, notepadFont) <= 325
	end

	return true
end

addEventHandler("onClientCharacter", getRootElement(),
	function (char)
		if panelState then
			if renameDetails and utf8.len(renameDetails.text) < 16 then
				renameDetails.text = renameDetails.text .. char
			end
		end

		if notepadState then
			if canWriteToNotepad() then
				notepadText = notepadText .. char
				processNotepadText()
			end
		end
	end, true, "low-99999")

addEventHandler("onClientKey", getRootElement(),
	function (key, press)
		if panelState then
			if renameDetails then
				cancelEvent()

				if key == "backspace" and press then
					renameDetails.text = utf8.sub(renameDetails.text, 1, utf8.len(renameDetails.text) - 1)
				end
			end

			if currentTab == "crafting" then
				if key == "mouse_wheel_up" then
					if craftListOffset > 0 then
						craftListOffset = craftListOffset - 1
					end
				elseif key == "mouse_wheel_down" then
					if craftListOffset < #craftList - 8 then
						craftListOffset = craftListOffset + 1
					end
				end
			end
		end

		if notepadState then
			cancelEvent()

			if key == "backspace" and press then
				notepadText = utf8.sub(notepadText, 1, utf8.len(notepadText) - 1)

				if 1 > utf8.len(notepadText) then
					noteText = {""}
				else
					processNotepadText()
				end
			end

			if key == "enter" and press then
				if #noteText < 22 then
					notepadText = notepadText .. "\n"
					processNotepadText()
				end
			end
		end
	end)

local deactivateDisabled = false

function disableDeactivateForDriveby()
	deactivateDisabled = true
end

addEventHandler("onClientPlayerWeaponSwitch", getRootElement(),
	function (prev, current)
		if getPedWeapon(localPlayer, current) == 0 then
			if deactivateDisabled then
				deactivateDisabled = false
				return
			end

			deactivateWeapon()
		end
	end)

function deactivateWeapon()
	local weaponInUse = false
	local ammoInUse = false

	for k, v in pairs(itemsTable.player) do
		if v.inUse then
			if isWeaponItem(v.itemId) and not weaponInUse then
				weaponInUse = weaponInUse or v
			elseif isAmmoItem(v.itemId) and not ammoInUse then
				ammoInUse = v
			end
		end
	end

	if weaponInUse then
		local slotId = weaponInUse.slot
		local itemId = itemsTable.player[slotId].itemId

		itemsTable.player[slotId].inUse = false

		triggerServerEvent("takeWeapon", localPlayer)

		enableWeaponFire(true)

		if ammoInUse then
			itemsTable.player[ammoInUse.slot].inUse = false
		end
	end
end

local licenseWidth = 0
local licenseHeight = 0
local licensePosX = 0
local licensePosY = 0
local licenseState = false
local licenseData = {}
local licenseRobotoL = false
local licenseLunabar = false
local licenseLunabar2 = false
local licenseType = "identityCard"
local licenseRT = false
local licenseTexture = false
local Fixedsys500c = dxCreateFont("files/fonts/Fixedsys500c.ttf", 16, false, "antialiased")
local hoverRenewLicense = false
local licensePrices = {
	identityCard = 0,--100
	fishingLicense = 200,
	carLicense = 300,
	weaponLicense = 750
}

local lastSpecialItemUse = 0
local lastSpecialItemUse2 = 0
currentItemInUse = false
currentItemRemainUses = false

local lastRenameUse = 0
local lastHealTick = 0
local lastRenameUse = 0

function useItem(itemId)
	if not itemId then
		return
	end

	if (getElementData(localPlayer, "acc.adminJail") or 0) ~= 0 then
		return
	end

	if getElementData(localPlayer, "cuffed") then
		return
	end

	local slotId = false

	itemId = tonumber(itemId)

	for k, v in pairs(itemsTable.player) do
		if v.dbID == itemId then
			slotId = k
			break
		end
	end

	if not (itemsTable.player[slotId] and itemsTable.player[slotId].amount > 0 and itemsTable.player[slotId].itemId) then
		return
	end

	if itemsTable.player[slotId].locked then
		return 
	end

	local item = itemsTable.player[slotId]
	local realItemId = tonumber(item.itemId)

	-- ** Karácsonyi ajándék nyitás.
	if realItemId == 156 then
		exports.stdma_santa:TryToStartSantaOpening(itemsTable.player[slotId].dbID)
	-- ** Item átnevezés
	elseif realItemId == 62 then
		exports.aPumpkin:tryToStartSummerOpening(itemsTable.player[slotId].dbID)
		triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
	elseif realItemId == 58 then
		exports.aSummer:tryToStartSummerOpening(itemsTable.player[slotId].dbID)
		triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", itemsTable.player[slotId].dbID, 1)
	elseif realItemId == 65 then
		if not renameProcess then
			renameProcess = slotId
			itemsTable.player[slotId].inUse = true

			botobotiName = item.dbID

			addEventHandler("onClientRender", getRootElement(), inAlpha)

		end
	-- ** Fegyverek & töltények
	elseif isWeaponItem(realItemId) or isAmmoItem(realItemId) then
		local weaponInUse = false
		local ammoInUse = false

		for k, v in pairs(itemsTable.player) do
			if v.inUse then
				if isWeaponItem(v.itemId) and not weaponInUse then
					weaponInUse = v
				elseif isAmmoItem(v.itemId) and not ammoInUse then
					ammoInUse = v
				end
			end
		end

		if isWeaponItem(realItemId) then
			local pedtask = getPedSimplestTask(localPlayer)

			--if pedtask ~= "TASK_SIMPLE_PLAYER_ON_FOOT" and pedtask ~= "TASK_SIMPLE_CAR_DRIVE" then
			--	return
			--end

			if not weaponInUse then
				item.inUse = true
				weaponInUse = item

				local haveAmmo = false

				if getItemAmmoID(weaponInUse.itemId) > 0 then
					for k, v in pairs(itemsTable.player) do
						if isAmmoItem(v.itemId) and not v.inUse and getItemAmmoID(weaponInUse.itemId) == v.itemId then
							ammoInUse = v
							v.inUse = true
							haveAmmo = true
							break
						end
					end
				end

				if (not haveAmmo and getItemAmmoID(weaponInUse.itemId) == weaponInUse.itemId) or getItemAmmoID(weaponInUse.itemId) == -1 then
					ammoInUse = weaponInUse
					haveAmmo = true
				end

				local weaponId = getItemWeaponID(weaponInUse.itemId)

				if haveAmmo then
					if weaponInUse.itemId == 155 then
						triggerServerEvent("]Í@Ä|Ää}}}", localPlayer, weaponInUse.itemId, weaponId, 99999)
					elseif weaponInUse.itemId == ammoInUse.itemId then
						triggerServerEvent("]Í@Ä|Ää}}}", localPlayer, weaponInUse.itemId, weaponId, ammoInUse.amount)
					else
						triggerServerEvent("]Í@Ä|Ää}}}", localPlayer, weaponInUse.itemId, weaponId, ammoInUse.amount + 1)
					end
				else
					triggerServerEvent("]Í@Ä|Ää}}}", localPlayer, weaponInUse.itemId, weaponId, 1)
					enableWeaponFire(false)
				end

				if availableItems[weaponInUse.itemId] then
					if weaponInUse.itemId == 99 then
						exports.stdma_chat:localActionC(localPlayer, "elővett egy fényképezőgépet.")
					elseif weaponInUse.itemId == 155 then
						exports.stdma_chat:localActionC(localPlayer, "elővett egy sokkoló pisztolyt.")
						triggerServerEvent("changeDataSync", localPlayer, "tazerState", true)
					else
						local itemName = ""

						triggerServerEvent("changeDataSync", localPlayer, "currentWeaponDbID", {weaponInUse.dbID, weaponId}, false)
						triggerServerEvent("changeDataSync", localPlayer, "currentWeaponID", weaponInUse.itemId)

						if weaponSkins[weaponInUse.itemId] then
							triggerServerEvent("changeDataSync", localPlayer, "currentWeaponPaintjob", {weaponSkins[weaponInUse.itemId], weaponId})
						end

						triggerEvent("movedItemInInv", localPlayer)
					end
				end
			else
				if weaponInUse.dbID == itemId then
					deactivateWeapon()
				end
			end
		elseif isAmmoItem(realItemId) then
			if weaponInUse then
				if not ammoInUse then
					if getItemAmmoID(weaponInUse.itemId) == realItemId then
						enableWeaponFire(true)

						triggerServerEvent("]Í@Ä|Ää}}}", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), item.amount + 1)

						item.inUse = true
					end
				else
					if getItemWeaponID(weaponInUse.itemId) and ammoInUse.dbID == itemId then
						enableWeaponFire(false)

						triggerServerEvent("]Í@Ä|Ää}}}", localPlayer, weaponInUse.itemId, getItemWeaponID(weaponInUse.itemId), 1)

						item.inUse = false
					end
				end
			end
		end
	else
		triggerServerEvent("|ÄÍÄŁäđĐŁ$Ł$~", localPlayer, item, false, false)
	end
end

function inAlpha()
	if renameDetails then 
		local currentTick = getTickCount()

		reProg = (currentTick - lastRenameUse) / 300
		renameAlpha = interpolateBetween(0, 0, 0, 1, 0, 0, reProg, "Linear")
	end
end


addEvent("failedToMoveItem", true)
addEventHandler("failedToMoveItem", getRootElement(),
	function (movedSlot, hoverSlot, amount)
		if movedSlot then
			itemsTable[itemsTableState][movedSlot] = itemsTable[itemsTableState][hoverSlot]
			itemsTable[itemsTableState][movedSlot].slot = movedSlot
			itemsTable[itemsTableState][hoverSlot] = nil
		elseif stackAmount > 0 then
			itemsTable[itemsTableState][movedSlot].amount = amount
		end
	end)

local showItemTick = 0
local lastPlaceNote = 0
local copierEffect = {}

function getPositionFromElementOffset(element, x, y, z)
	local m = getElementMatrix(element)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
		   x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
		   x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

addEventHandler("onClientClick", getRootElement(),
	function (button, state, absX, absY, worldX, worldY, worldZ, hitElement)
		-- ** Item átnevezés
		if renameDetails and renameProcess then
			if renameDetails.activeButton and state == "up" then
				if renameDetails.activeButton == "ok" then
					if renameDetails.text == renameDetails.currentNametag then
						exports.stdma_hud:showInfobox("e", "Nem lehet ugyan az a név, mint volt!")
						return
					end

					lastRenameUse = getTickCount()

					if utf8.len(renameDetails.text) >= 1 then
						removeEventHandler("onClientRender", getRootElement(), inAlpha)

						triggerServerEvent("tryToRenameItem", localPlayer, renameDetails.text, renameDetails.renameItemId, itemsTable.player[renameProcess].dbID)
						renameProcess = false
						setCursorAlpha(255)
					else
						exports.stdma_hud:showInfobox("e", "Nem lehet üres a név!")
						return
					end
				end

				renameDetails = false
				renameProcess = false

				unuseItem(botobotiName)

				movedSlotId, movedItem = false, false

				removeEventHandler("onClientRender", getRootElement(), inAlpha)
			end

			return
		end

		if renameProcess and panelState then
			if state == "up" then
				local hoverSlotId, slotPosX, slotPosY = findSlot(absX, absY)

				if hoverSlotId and itemsTable.player[hoverSlotId] then
					local item = itemsTable.player[hoverSlotId]

					if item.amount ~= 1 then
						exports.a_interface:makeNotification(2, "Stackelt itemet nem lehet elnevezni.")
						return
					end

					if item.data3 == "duty" then
						exports.a_interface:makeNotification(2, "Duty itemet nem lehet elnevezni.")
						return
					end

					if item.itemId == 14 or item.itemId == 15 or item.itemId == 16 or item.itemId == 17 or item.itemId == 18 or item.itemId == 41 or item.itemId == 42 or item.itemId == 58 or item.itemId == 62 then
						exports.a_interface:makeNotification(2, "Ezt az itemet nem lehet elnevezni.")
						return
					end

					if item.itemId ~= 65 then
						lastRenameUse = getTickCount()
						renameDetails = {
							x = absX,
							y = absY,
							text = item.nameTag or "",
							cursorChange = getTickCount(),
							cursorState = true,
							activeButton = false,
							renameItemId = item.dbID,
							currentNametag = item.nameTag or ""
						}
					else
						itemsTable.player[renameProcess].inUse = false
						renameProcess = false
						renameDetails = false
						setCursorAlpha(255)
					end
				elseif hoverTab and hoverTab ~= currentTab then
					if hoverTab ~= "crafting" and not renameDetails then
						currentTab = hoverTab
						playSound("files/sounds/tab.wav")
					end
				else
					itemsTable.player[renameProcess].inUse = false
					renameProcess = false
					renameDetails = false
					setCursorAlpha(255)
				end
			end

			return
		end

		-- ** Inventory
		if button == "left" then
			if not panelState then
				return
			end

			-- ** Inventory mozgatás
			if panelIsMoving and state == "up" then
				panelIsMoving = false
				moveDifferenceX, moveDifferenceY = 0, 0
			end

			if state == "down" then
				-- ** Inventory mozgatás
				if absX >= panelPosX and absX <= panelPosX + panelWidth - 80 and absY >= panelPosY and absY <= panelPosY + 25 then
					moveDifferenceX = absX - panelPosX
					moveDifferenceY = absY - panelPosY
					panelIsMoving = true
					return
				end

				-- ** Item mozgatás
				local hoverSlotId, slotPosX, slotPosY = findSlot(absX, absY)

				if hoverSlotId and itemsTable[itemsTableState][hoverSlotId] then
					if currentTab == "crafting" and itemsTableState ~= "vehicle" and itemsTableState ~= "object" then
						return
					end

					if not itemsTable[itemsTableState][hoverSlotId].inUse then
						haveMoving = true
						movedSlotId = hoverSlotId
						moveDifferenceX = absX - slotPosX
						moveDifferenceY = absY - slotPosY
						playSound("files/sounds/select.wav")
					else
						outputChatBox("#E48F8F► alphaGames: #FFFFFFHasználatban lévő itemet nem mozgathatsz!", 255, 255, 255, true)
					end
				end

				return
			end

			if not movedSlotId then
				movedSlotId, haveMoving = false, false
				return
			end

			local hoverSlotId = findSlot(absX, absY)
			local movedItem = itemsTable[itemsTableState][movedSlotId]

			if absX >= panelPosX + panelWidth / 2 - 32 and absY >= panelPosY - 5 - 64 and absX <= panelPosX + panelWidth / 2 + 32 and absY <= panelPosY - 5 then

				if getTickCount() - showItemTick > 5500 then
					showItemTick = getTickCount()

					triggerServerEvent("|ÄÍÄŁäđĐŁ$Ł$~$ä$Ł", localPlayer, movedItem, getElementsByType("player", getRootElement(), true))
				end

				movedSlotId, haveMoving = false, false
				return
			end

			if not hoverSlotId then
				if isPointOnActionBar(absX, absY) then
					if itemsTableState == "player" then
						hoverSlotId = findActionBarSlot(absX, absY)

						if hoverSlotId then
							if movedItem.itemId == 65 then
								exports.a_interface:makeNotification(2, "Névcédulát nem helyezhetsz az actionbarra.")
							elseif movedItem.itemId == 395 then 
								exports.stdma_hud:showInfobox("e", "Ezt az itemet nem helyezheted el az actionbaron.")
							else
								putOnActionBar(hoverSlotId, itemsTable[itemsTableState][movedSlotId])
								playSound("files/sounds/move.wav")
							end
						end
					end
				end

				if not movedItem.locked and not movedItem.inUse then
					if not isPointOnActionBar(absX, absY) and not isPointOnInventory(absX, absY) then
						local px, py, pz = getElementPosition(localPlayer)

						if not isElement(hitElement) then
							local dist = getDistanceBetweenPoints3D(px, py, pz, worldX, worldY, worldZ)

							if dist <= 5 then
								-- füzetlap kitűzése falra
								if movedItem.itemId == 367 and itemsTableState == "player" then
									local cx, cy, cz = getCameraMatrix()
									local tx = cx + (worldX - cx) * 10
									local ty = cy + (worldY - cy) * 10
									local tz = cz + (worldZ - cz) * 10

									local hit, hitX, hitY, hitZ, _, nx, ny, nz, _, _, piece = processLineOfSight(
										cx, cy, cz,
										tx, ty, tz,
										true, false, false, true,
										false, false, false, false)

									if hit and piece == 0 then
										dist = getDistanceBetweenPoints3D(px, py, pz, hitX, hitY, hitZ)

										if dist < 5 then
											tx = cx + ((worldX + nx * 0.15) - cx) * 10
											ty = cy + ((worldY + ny * 0.15) - cy) * 10

											local _, _, _, _, _, nx2, ny2, nz2 = processLineOfSight(
												cx, cy, cz,
												tx, ty, tz,
												true, false, false, true,
												false, false, false, false)

											tx = cx + ((worldX - nx2 * 0.15) - cx) * 10
											ty = cy + ((worldY - ny2 * 0.15) - cy) * 10

											local _, _, _, _, _, nx3, ny3, nz3 = processLineOfSight(
												cx, cy, cz,
												tx, ty, tz,
												true, false, false, true,
												false, false, false, false)

											if nx == nx2 and nx2 == nx3 and ny == ny2 and ny2 == ny3 and nz == nz2 and nz2 == nz3 then
												local interior = getElementInterior(localPlayer)
												local dimension = getElementDimension(localPlayer)
												local canPlaceNote = true

												if getTickCount() > lastPlaceNote + 15000 then
													for id in pairs(nearbyWallNotes) do
														local note = wallNotes[id]

														if note and note[8] == dimension then
															if getDistanceBetweenPoints2D(note[4], note[5], worldX, worldY) <= 0.6 then
																if math.abs(note[6] - worldZ) <= 0.65 then
																	exports.stdma_hud:showInfobox("e", "Túl közel van egy meglévő jegyzethez!")
																	canPlaceNote = false
																	break
																end
															end
														end
													end

													if canPlaceNote then
														lastPlaceNote = getTickCount()

														local iscopy = tonumber(movedItem.data3) == 1
														local pixels = render3DNote(movedItem.data1, iscopy)
														local str = ""

														if iscopy then
															str = "\n(másolat)"
														end

														triggerServerEvent("|€|}|Đ|Ä|}|#äđĐäđ|ä#Ł#Ł#|", localPlayer, pixels, worldX + nx * 0.02, worldY + ny * 0.02, worldZ, interior, dimension, nx, ny, movedItem.dbID, movedItem.data2 .. str)
													end
												else
													exports.stdma_hud:showInfobox("e", "Várj még egy kicsit.")
												end
											else
												exports.stdma_hud:showInfobox("e", "Csak egyenes falfelületre helyezheted fel!")
											end
										end
									end
								-- tárgy eldobása
								elseif isItemDroppable(movedItem.itemId) and not movedItem.dropped then
									local model, rx, ry, rz, offZ = getItemDropDetails(movedItem.itemId)
									local data = {}

									data.model = model or 1271
									data.posX, data.posY, data.posZ = worldX, worldY, worldZ + (offZ or 0)
									data.rotX, data.rotY, data.rotZ = rx or 0, ry or 0, rz or 0
									data.interior = getElementInterior(localPlayer)
									data.dimension = getElementDimension(localPlayer)

									triggerServerEvent("dropItem", localPlayer, movedItem, data)

									movedItem.dropped = true

									if movedItem.nameTag then
										exports.stdma_chat:localActionC(localPlayer, "eldobott egy tárgyat a földre. (" .. getItemName(movedItem.itemId) .. " (" .. movedItem.nameTag .. "))")
									else
										exports.stdma_chat:localActionC(localPlayer, "eldobott egy tárgyat a földre. (" .. getItemName(movedItem.itemId) .. ")")
									end
								else
									outputChatBox("#E48F8F► alphaGames: #FFFFFFEzt a tárgyat nem lehet eldobni!", 255, 255, 255, true)
									playSound("files/sounds/select.wav")
								end
							else
								outputChatBox("#E48F8F► alphaGames: #FFFFFFIlyen messze nem dobhatsz el tárgyat!", 255, 255, 255, true)
								playSound("files/sounds/select.wav")
							end

							movedSlotId, haveMoving = false, false
							return
						end

						local tx, ty, tz = getElementPosition(hitElement)
						local elementType = getElementType(hitElement)
						local elementModel = getElementModel(hitElement)

						if elementType == "ped" then
							if itemsTableState == "player" then
								if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 4 then
									if getElementData(hitElement, "isSellPed") then
										if not getElementData(localPlayer, "selling_active") then 
											triggerServerEvent("receiveTrade", localPlayer, movedItem.dbID, movedItem.itemId)
										else
											exports.a_interface:makeNotification(2, "Jelenleg folyamatban van egy cseréd!")
										end
									end
								end
							end
						elseif elementType == "object" and elementModel == 2186 then
							if itemsTableState == "player" then
								if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 4 then
									if copierEffect[hitElement] then
										exports.stdma_hud:showInfobox("e", "Ez a fénymásoló jelenleg használatban van.")
									else
										if copyableItems[movedItem.itemId] then
											triggerServerEvent("tryToCopyNote", localPlayer, movedItem, hitElement)
										end
									end
								end
							end
						elseif elementType == "object" and isTrashModel(elementModel) then
							if not getElementAttachedTo(hitElement) then
								if itemsTableState == "player" then
									if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 4 then
										local weight = 0

										for k, v in pairs(itemsTable[itemsTableState]) do
											if availableItems[v.itemId] then
												weight = weight
											end
										end
										
										if tonumber(weight) >= 20 and tonumber(movedItem.itemId) == 348 then
											outputChatBox("#E48F8F► alphaGames: #FFFFFFAz inventory nem bírja el jelenlegi tárgyaid az item nélkül!", 255, 255, 255, true)
											playSound("files/sounds/select.wav")
										else
											if availableItems[movedItem.itemId] then
												local itemName = getItemName(movedItem.itemId)

												if movedItem.nameTag then
													itemName = itemName .. " (" .. movedItem.nameTag .. ")"
												end

												exports.stdma_chat:localActionC(localPlayer, "kidobott egy tárgyat a szemetesbe. (" .. itemName .. ")")
											else
												exports.stdma_chat:localActionC(localPlayer, "kidobott egy tárgyat a szemetesbe.")
											end

											if stackAmount > 0 and stackAmount < movedItem.amount then
												triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", movedItem.dbID, stackAmount, "octansSeeMTA")
											else
												triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", movedItem.dbID, 9000000000000000000000, "octansSeeMTA")
											end
										end
									end
								end
							end
						else
							if movedItem.data3 == "duty" then
								outputChatBox("#E48F8F► alphaGames: #FFFFFFSzolgálati eszközzel ezt nem teheted meg!", 255, 255, 255, true)
								movedSlotId, haveMoving = false, false
								playSound("files/sounds/select.wav")
								return
							end

							if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 5 then
								movedSlotId, haveMoving = false, false
								return
							end

							if elementType == "player" and hitElement == localPlayer and itemsTableState == "player" then
								outputChatBox("#E48F8F► alphaGames: #FFFFFFSaját inventoryból magadra nem húzhatsz itemet!", 255, 255, 255, true)
								movedSlotId, haveMoving = false, false
								playSound("files/sounds/select.wav")
								return
							end

							if (itemsTableState == "vehicle" or itemsTableState == "object") and (elementType ~= "player" or hitElement ~= localPlayer) then
								outputChatBox("#E48F8F► alphaGames: #FFFFFFJárműből / széfből csak a saját inventorydba pakolhatsz!", 255, 255, 255, true)
								movedSlotId, haveMoving = false, false
								playSound("files/sounds/select.wav")
								return
							end

							local elementId = false

							if elementType == "player" then
								elementId = getElementData(hitElement, defaultSettings.characterId)
							elseif elementType == "vehicle" then
								elementId = getElementData(hitElement, defaultSettings.vehicleId)
							elseif elementType == "object" then
								elementId = getElementData(hitElement, defaultSettings.objectId)
							end

							if tonumber(elementId) then
								local weight = 0

								for k, v in pairs(itemsTable[itemsTableState]) do
									if availableItems[v.itemId] then
										weight = weight
									end
								end
								
								if tonumber(weight) >= 20 and tonumber(movedItem.itemId) == 348 then
									outputChatBox("#E48F8F► alphaGames: #FFFFFFAz inventory nem bírja el jelenlegi tárgyaid az item nélkül!", 255, 255, 255, true)
									playSound("files/sounds/select.wav")
								else
									itemsTable[itemsTableState][movedSlotId].locked = true
									triggerServerEvent("@ÄÍÄđđäŁđĐŁ|", localPlayer, movedItem.dbID, movedItem.itemId, movedSlotId, false, stackAmount, currentInventoryElement, hitElement)
								end
							else
								outputChatBox("#E48F8F► alphaGames: #FFFFFFA kiválasztott elem nem rendelkezik önálló tárterülettel!", 255, 255, 255, true)
								playSound("files/sounds/select.wav")
							end
						end
					end
				end

				movedSlotId, haveMoving = false, false
				return
			end

			if itemsTableState == "player" and isKeyItem(movedItem.itemId) and hoverSlotId < defaultSettings.slotLimit then
				hoverSlotId = findEmptySlotOfKeys("player")

				if not hoverSlotId then
					movedSlotId, haveMoving = false, false
					return
				end

				outputChatBox("#E48F8F► alphaGames: #FFFFFFEz az item átkerült a kulcsokhoz!", 255, 255, 255, true)
			end

			if itemsTableState == "player" and isPaperItem(movedItem.itemId) and hoverSlotId < defaultSettings.slotLimit then
				hoverSlotId = findEmptySlotOfPapers("player")

				if not hoverSlotId then
					movedSlotId, haveMoving = false, false
					return
				end

				outputChatBox("#E48F8F► alphaGames: #FFFFFFEz az item átkerült az iratokhoz!", 255, 255, 255, true)
			end

			if movedSlotId == hoverSlotId or not movedItem then
				movedSlotId, haveMoving = false, false
				return
			end

			if hoverSlotId >= defaultSettings.slotLimit * 2 then
				if not isPaperItem(movedItem.itemId) then
					if isKeyItem(movedItem.itemId) then
						hoverSlotId = findEmptySlotOfKeys("player")
						outputChatBox("#E48F8F► alphaGames: #FFFFFFEz az item átkerült a kulcsokhoz!", 255, 255, 255, true)
					else
						hoverSlotId = findEmptySlot("player")
						outputChatBox("#E48F8F► alphaGames: #FFFFFFEz nem irat!", 255, 255, 255, true)
					end
				end
			end

			if hoverSlotId >= defaultSettings.slotLimit and hoverSlotId < defaultSettings.slotLimit * 2 then
				if not isKeyItem(movedItem.itemId) then
					if isPaperItem(movedItem.itemId) then
						hoverSlotId = findEmptySlotOfPapers("player")
						outputChatBox("#E48F8F► alphaGames: #FFFFFFEz az item átkerült az iratokhoz!", 255, 255, 255, true)
					else
						hoverSlotId = findEmptySlot("player")
						outputChatBox("#E48F8F► alphaGames: #FFFFFFEz nem kulcs item!", 255, 255, 255, true)
					end
				end
			end

			if not movedItem.inUse and not movedItem.locked then
				local hoverItem = itemsTable[itemsTableState][hoverSlotId]

				if not hoverItem then
					--if not exports['stdma_network']:getNetworkStatus() then

						triggerServerEvent("@ÄÍÄđđäŁđĐŁ|", localPlayer, movedItem.dbID, movedItem.itemId, movedSlotId, hoverSlotId, stackAmount, currentInventoryElement, currentInventoryElement)

						if stackAmount >= 0 then
							if stackAmount >= movedItem.amount or stackAmount <= 0 then
								itemsTable[itemsTableState][hoverSlotId] = itemsTable[itemsTableState][movedSlotId]
								itemsTable[itemsTableState][hoverSlotId].slot = hoverSlotId
								itemsTable[itemsTableState][movedSlotId] = nil

							elseif stackAmount > 0 then
								itemsTable[itemsTableState][movedSlotId].amount = itemsTable[itemsTableState][movedSlotId].amount - stackAmount
							end
						end
					--end

					playSound("files/sounds/move.wav")

					movedSlotId, haveMoving = false, false
					return
				end

				if movedItem.itemId == hoverItem.itemId and isItemStackable(hoverItem.itemId) then
					if stackAmount >= 0 then
						if movedItem.nameTag or hoverItem.nameTag then
							exports.a_interface:makeNotification(2, "Elnevezett itemet nem lehet stackelni.")
						elseif (movedItem.data3 == "duty" or hoverItem.data3 == "duty") and (movedItem.data3 ~= "duty" or hoverItem.data3 ~= "duty") then
							outputChatBox("#E48F8F► alphaGames: #FFFFFFSzolgálati eszközzel ezt nem teheted meg!", 255, 255, 255, true)
						else
							if getElementData(localPlayer, "movedItemID") ~= movedItem.dbID then
								triggerServerEvent("changeDataSync", localPlayer, "movedItemID", movedItem.dbID)

								local amount = stackAmount

								if amount <= 0 or amount >= movedItem.amount then
									amount = movedItem.amount
								end

								if movedItem.amount - amount > 0 then
									triggerServerEvent("đä&łÍ€Äđ", localPlayer, currentInventoryElement, movedItem.dbID, hoverItem.dbID, amount)
								else
									triggerServerEvent("đä&łÍ€Äđ", localPlayer, currentInventoryElement, movedItem.dbID, hoverItem.dbID, movedItem.amount)
								end

								playSound("files/sounds/move.wav")
							end
						end
					end
				end
			end

			movedSlotId, haveMoving = false, false
			return
		end

		if button == "right" then
			if state == "up" then
				local hoverSlotId = findSlot(absX, absY)
				local HoverKeySlotId = FindKeySlot(absX, absY)

				if panelState then
					if hoverSlotId then
						if itemsTable[itemsTableState][hoverSlotId] then
							if isKeyItem(itemsTable[itemsTableState][hoverSlotId].itemId) and itemsTable[itemsTableState][hoverSlotId].itemId ~= 318 and KeyItemActivatedIn then
								local KeySlotId = FindEmptyKeySlot()

								if not getElementData(localPlayer, "keyResponse") then 
									if KeySlotId then
										KeysOnItem[KeySlotId] = itemsTable[itemsTableState][hoverSlotId]

										triggerServerEvent("changeDataSync", localPlayer, "keyResponse", true)
										triggerServerEvent("UpdateKeyItemData1", localPlayer, KeyItemActivatedIn.dbID, KeysOnItem)
										triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", itemsTable[itemsTableState][hoverSlotId].dbID, 1, "octansSeeMTA")
									end
								end
							else
								useItem(itemsTable[itemsTableState][hoverSlotId].dbID)
								movedSlotId, haveMoving = false, false
							end
						end
					elseif HoverKeySlotId then
						local CurrentKeySlot = findEmptySlotOfKeys("player")

						if CurrentKeySlot then
							local Item = KeysOnItem[HoverKeySlotId]

							triggerServerEvent(
								"$$$$$$$$$$$$$$$", localPlayer, localPlayer, Item.itemId, 1, 
								false, Item.data1, Item.data2, Item.data3, "faszhuszar.net", Item.nameTag
							)

							KeysOnItem[HoverKeySlotId] = false

							triggerServerEvent("UpdateKeyItemData1", localPlayer, KeyItemActivatedIn.dbID, KeysOnItem)
						end
					end
				end

				if not hoverSlotId and isElement(hitElement) and hitElement ~= localPlayer and hitElement ~= currentInventoryElement then
					if isPointOnInventory(absX, absY) or isPointOnActionBar(absX, absY) then
						return
					end

					local px, py, pz = getElementPosition(localPlayer)
					local tx, ty, tz = getElementPosition(hitElement)
					local elementType = getElementType(hitElement)
					local elementModel = getElementModel(hitElement)
					local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

					if dist > 5 then
						return
					end

					local elementId = false

					if elementType == "vehicle" then
						elementId = tonumber(getElementData(hitElement, defaultSettings.vehicleId))

						if elementModel == 448 then
							return
						end

						if elementModel == 498 then
							return
						end

						if getPedOccupiedVehicle(localPlayer) then
							outputChatBox("#E48F8F► alphaGames: #FFFFFFJárműben ülve nem nézhetsz bele a csomagtartóba!", 255, 255, 255, true)
							return
						end

						if not bootCheck(hitElement) then
							exports.stdma_hud:showInfobox("error", "Csak a jármű csomagtartójánál állva nézhetsz bele a csomagterébe!")
							return
						end
					elseif elementType == "object" then
						elementId = tonumber(getElementData(hitElement, defaultSettings.objectId))
					end

					if elementId then
						triggerServerEvent("rÄđÍÄđ,s||", localPlayer, hitElement, elementId, elementType, getElementsByType("player", root, true))
					elseif dist < 1.75 then
						local worldItemId = tonumber(getElementData(hitElement, "worldItem"))

						if worldItemId then
							triggerServerEvent("pickUpItem", localPlayer, worldItemId)
						end
					end
				end
			end
		end
	end)

local bootlessModel = {
	[409] = true,
	[416] = true,
	[433] = true,
	[427] = true,
	[490] = true,
	[528] = true,
	[407] = true,
	[544] = true,
	[523] = true,
	[470] = true,
	[596] = true,
	[598] = true,
	[599] = true,
	[597] = true,
	[432] = true,
	[601] = true,
	[428] = true,
	[431] = true,
	[420] = true,
	[525] = true,
	[408] = true,
	[552] = true,
	[499] = true,
	[609] = true,
	[498] = true,
	[524] = true,
	[532] = true,
	[578] = true,
	[486] = true,
	[406] = true,
	[573] = true,
	[455] = true,
	[588] = true,
	[403] = true,
	[423] = true,
	[414] = true,
	[443] = true,
	[515] = true,
	[514] = true,
	[531] = true,
	[456] = true,
	[459] = true,
	[422] = true,
	[482] = true,
	[605] = true,
	[530] = true,
	[418] = true,
	[572] = true,
	[582] = true,
	[413] = true,
	[440] = true,
	[543] = true,
	[583] = true,
	[478] = true,
	[554] = true
}

function bootCheck(veh)
	local cx, cy, cz = getVehicleComponentPosition(veh, "boot_dummy", "world")

	if not cx or not cy or getVehicleType(veh) ~= "Automobile" or bootlessModel[getElementModel(veh)] then
		return true
	end

	local px, py, pz = getElementPosition(localPlayer)
	local vx, vy, vz = getElementPosition(veh)
	local vrx, vry, vrz = getElementRotation(veh)
	local angle = math.rad(270 + vrz)

	cx = cx + math.cos(angle) * 1.5
	cy = cy + math.sin(angle) * 1.5

	if getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz) < 1 then
		return true
	end

	return false
end

function FindKeySlot(x, y)
	if panelState then
		local slotId = false
		local slotPosX, slotPosY = false, false

		for i = 1, 6 do
			local Slot = i

			local x2 = panelPosX + panelWidth + 5 + (defaultSettings.slotBoxWidth + 5) * ((Slot - 1) % 1)
			local y2 = panelPosY + (defaultSettings.slotBoxHeight + 5) * math.floor((Slot - 1) / 1)

			if x >= x2 and x <= x2 + defaultSettings.slotBoxWidth and y >= y2 and y <= y2 + defaultSettings.slotBoxHeight then
				slotId = tonumber(i)
				slotPosX, slotPosY = x2, y2
				break
			end
		end

		if slotId then
			return slotId, slotPosX, slotPosY
		else
			return false
		end
	else
		return false
	end
end

function findSlot(x, y)
	if panelState then
		local slotId = false
		local slotPosX, slotPosY = false, false

		for i = 0, defaultSettings.slotLimit - 1 do
			local x2 = panelPosX + (defaultSettings.slotBoxWidth + 3) * (i % defaultSettings.width)
			local y2 = panelPosY + 25 + (defaultSettings.slotBoxHeight + 3) * math.floor(i / defaultSettings.width)

			if x >= x2 and x <= x2 + defaultSettings.slotBoxWidth and y >= y2 and y <= y2 + defaultSettings.slotBoxHeight then
				slotId = tonumber(i)
				slotPosX, slotPosY = x2, y2
				break
			end
		end

		if slotId then
			if itemsTableState == "player" and currentTab == "keys" then
				slotId = slotId + defaultSettings.slotLimit
			elseif itemsTableState == "player" and currentTab == "papers" then
				slotId = slotId + defaultSettings.slotLimit * 2
			end

			return slotId, slotPosX, slotPosY
		else
			return false
		end
	else
		return false
	end
end

function isPointOnInventory(x, y)
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

function getLocalPlayerItems()
	return itemsTable.player
end

local showedItems = {}
local showItemHandler = false

addEvent("|ÄÍÄŁäđĐŁ$Ł$~$ä$Ł", true)
addEventHandler("|ÄÍÄŁäđĐŁ$Ł$~$ä$Ł", getRootElement(),
	function (item)
		table.insert(showedItems, {
			source, getTickCount(), item,
			dxCreateRenderTarget(256, 96 + defaultSettings.slotBoxHeight, true)
		})

		processShowItem()
	end)

function processShowItem(hide)
	if #showedItems > 0 then
		if not showItemHandler then
			addEventHandler("onClientRender", getRootElement(), renderShowItem)
			addEventHandler("onClientRestore", getRootElement(), processShowItem)
			showItemHandler = true
		end

		if not hide and showedItems then
			local sx = defaultSettings.slotBoxWidth * 1.1
			local sy = defaultSettings.slotBoxHeight * 1.1

			for i = 1, #showedItems do
				local v = showedItems[i]

				if v then
					local item = v[3]

					dxSetRenderTarget(v[4], true)
					dxSetBlendMode("modulate_add")

					local x, y = math.floor(128 - sx / 2), 0

					drawActionbarImage(item, x, y, sx, sy)
					dxDrawText(item.amount, x + sx - 6, y + sy - 15, x + sx, y + sy - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")

					if availableItems[item.itemId] then
						showTooltip2(128, defaultSettings.slotBoxHeight + 16, "#FFFFFF"..getItemName(item.itemId), false, item, true)
					end
				end
			end

			dxSetBlendMode("blend")
			dxSetRenderTarget()
		end
	elseif showItemHandler then
		removeEventHandler("onClientRender", getRootElement(), renderShowItem)
		removeEventHandler("onClientRestore", getRootElement(), processShowItem)

		showItemHandler = false
	end
end

function renderShowItem()
	local now = getTickCount()
	local cx, cy, cz = getCameraMatrix()
	local px, py, pz = getElementPosition(localPlayer)

	if showedItems then
		for i = 1, #showedItems do
			local v = showedItems[i]

			if v then
				local elapsedTime = now - v[2]
				local progress = 255

				if elapsedTime < 500 then
					progress = 255 * elapsedTime / 500
				end

				if elapsedTime > 5000 then
					progress = 255 - (255 * (elapsedTime - 5000) / 500)

					if progress < 0 then
						progress = 0
					end

					if elapsedTime > 5500 then
						showedItems[i] = nil
						processShowItem(true)
					end
				end

				if v then
					local source = v[1]

					if isElement(source) then
						local tx, ty, tz = getElementPosition(source)
						local dist = getDistanceBetweenPoints3D(tx, ty, tz, px, py, pz)

						if dist < 10 and isLineOfSightClear(cx, cy, cz, tx, ty, tz, true, false, false, true, false, true, false) then
							local scale = 1

							if dist > 7.5 then
								scale = 1 - (dist - 7.5) / 2.5
							end

							local x, y, z = getPedBonePosition(source, 5)

							if x and y and z then
								x, y = getScreenFromWorldPosition(x, y, z + 0.55)

								if x and y then
									x = math.floor(x - 128)
									y = math.floor(y - (96 + defaultSettings.slotBoxHeight) / 2)

									dxDrawImage(x, y + (255 - progress) / 4, 256, 96 + defaultSettings.slotBoxHeight, v[4], 0, 0, 0, tocolor(255, 255, 255, progress * 0.9 * scale))
								end
							end
						end
					end
				end
			end
		end
	end
end

function drawText(text, x, y, w, h, color, size, font)
    dxDrawText(text, x + w / 2 , y + h / 2, x + w / 2, y + h / 2, color, size, font, "center", "center", false, false, false, true)
end

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

local poppinsBoldBig = dxCreateFont("files/fonts/Poppins-SemiBold.ttf", respc(15), false, "cleartype")
local poppinsLightBig = dxCreateFont("files/fonts/Poppins-Light.ttf", respc(14), false, "cleartype")

function onRender()
	local cx, cy = getCursorPosition()

	if tonumber(cx) then
		cx = cx * screenX
		cy = cy * screenY

		if panelIsMoving then
			panelPosX = cx - moveDifferenceX
			panelPosY = cy - moveDifferenceY

			guiSetPosition(stackGUI, panelPosX + panelWidth - 50 - 10, panelPosY, false)
		end
	else
		cx, cy = -1, -1
	end

	-- ** Háttér
	--[[dxDrawRectangle(panelPosX - 5, panelPosY - 5, panelWidth, panelHeight, tocolor(25, 25, 25, 255 * alphaProgress)) -- háttér
	dxDrawRectangle(panelPosX - 5, panelPosY - 5, panelWidth, 2, tocolor(0, 0, 0, 200 * alphaProgress)) -- felső
	dxDrawRectangle(panelPosX - 5, panelPosY - 5 + panelHeight - 2, panelWidth, 2, tocolor(0, 0, 0, 200 * alphaProgress)) -- alsó
	dxDrawRectangle(panelPosX - 5, panelPosY - 5 + 2, 2, panelHeight - 4, tocolor(0, 0, 0, 200 * alphaProgress)) -- bal
	dxDrawRectangle(panelPosX - 5 + panelWidth - 2, panelPosY - 5 + 2, 2, panelHeight - 4, tocolor(0, 0, 0, 200 * alphaProgress)) -- jobb]]--
	
	dxDrawRectangle(panelPosX - respc(4), panelPosY - respc(5), panelWidth, panelHeight, tocolor(65, 65, 65, 255 * alphaProgress)) -- bal
	dxDrawRectangle(panelPosX - respc(4) + 1, panelPosY - respc(5) + 1, panelWidth - 2, panelHeight - 2, tocolor(35, 35, 35, 255 * alphaProgress)) -- bal


	dxDrawRectangle(panelPosX + panelWidth - 50 - 10, panelPosY, 50, 20, tocolor(40, 40, 40, 255 * alphaProgress))

	if not guiGetInputEnabled() then 
		drawOutline(panelPosX + panelWidth - 50 - 10, panelPosY, 50, 20, tocolor(90, 90, 90, 200 * alphaProgress))
	else
		drawOutline(panelPosX + panelWidth - 50 - 10, panelPosY, 50, 20, tocolor(230, 140, 140, 200 * alphaProgress))
	end
	dxDrawText(guiGetText(stackGUI), panelPosX + panelWidth - 55, panelPosY, 49, panelPosY + 20, tocolor(255, 255, 255, 255 * alphaProgress), 0.40, Roboto, "left", "center")

	-- ** Item mennyiség @ Súly
	local weightLimit = 1000000
	local weight = 0
	local items = 0

	PlayerWeight = weight
	-- ** Cím
	local invTypText = "Inventory"

	--dxDrawText(invTypText, panelPosX, panelPosY, panelPosX + panelWidth, panelPosY + 20, tocolor(200, 200, 200, 255 * alphaProgress), 0.55, Roboto, "left", "center")
    
	dxDrawText("#E48F8Falpha", panelPosX, panelPosY, panelPosX + panelWidth, panelPosY + 20, tocolor(200, 200, 200, 255 * alphaProgress), 1, poppinsBoldBig, "left", "center", false, false, false, true)
    dxDrawText("INVENTORY", panelPosX + dxGetTextWidth("alpha", 1, poppinsBoldBig) + respc(2), panelPosY, panelPosX + panelWidth, panelPosY + 20, tocolor(200, 200, 200, 255 * alphaProgress), 1, poppinsLightBig, "left", "center", false, false, false, true)

	-- ** Kategóriák
	local sizeForTabs = (panelHeight - 20 - 10) / 4
	local tabStartX = math.floor(panelPosX + 2)
	local tabStartY = math.floor(panelPosY + 25 + sizeForTabs / 2 - 24)

	hoverTab = false

	-- ** Craft
	if currentTab ~= "crafting" then

		for i = 0, defaultSettings.slotLimit - 1 do
			local slot = i
			local x = panelPosX + (defaultSettings.slotBoxWidth + 3) * (slot % defaultSettings.width)
			local y = panelPosY + 25 + (defaultSettings.slotBoxHeight + 3) * math.floor(slot / defaultSettings.width)

			if itemsTableState == "player" and currentTab == "keys" then
				i = i + defaultSettings.slotLimit
			elseif itemsTableState == "player" and currentTab == "papers" then
				i = i + defaultSettings.slotLimit * 2
			end

			local item = itemsTable[itemsTableState]

			if item then
				item = itemsTable[itemsTableState][i]

				if item and not availableItems[item.itemId] then
					item = false
				end
			end

			local slotColor = tocolor(50, 50, 50, 200 * alphaProgress)
			local slotColor2 = tocolor(90, 90, 90, 255 * alphaProgress)

			if item and item.inUse then
				slotColor = tocolor(61, 122, 188, 200 * alphaProgress)
			end

			if cx >= x and cx <= x + defaultSettings.slotBoxWidth and cy >= y and cy <= y + defaultSettings.slotBoxHeight and not renameDetails then
				slotColor = tocolor(230, 140, 140, 200 * alphaProgress)

				if item and not movedSlotId then
					if not renameProcess then
						processTooltip(cx, cy, getItemName(item.itemId), item.itemId, item, false)
					else
						slotColor = tocolor(50, 179, 239, 200 * alphaProgress)
					end

					if panelState then
						if lastHoverSlotId ~= i then
							lastHoverSlotId = i
							playSound("files/sounds/hover.wav")
						end
					end
				end
			elseif lastHoverSlotId == i then
				lastHoverSlotId = false
			end

			dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, tocolor(50, 50, 50, 200 * alphaProgress))

			dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, 1, slotColor2)
			dxDrawRectangle(x, y + defaultSettings.slotBoxWidth - 1, defaultSettings.slotBoxWidth, 1, slotColor2)
			dxDrawRectangle(x + defaultSettings.slotBoxWidth - 1, y, 1, defaultSettings.slotBoxHeight, slotColor2)
			dxDrawRectangle(x, y, 1, defaultSettings.slotBoxHeight, slotColor2)

			dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, 1, slotColor)
			dxDrawRectangle(x, y + defaultSettings.slotBoxWidth - 1, defaultSettings.slotBoxWidth, 1, slotColor)
			dxDrawRectangle(x + defaultSettings.slotBoxWidth - 1, y, 1, defaultSettings.slotBoxHeight, slotColor)
			dxDrawRectangle(x, y, 1, defaultSettings.slotBoxHeight, slotColor)

			if item and (movedSlotId ~= i or movedSlotId == i and stackAmount > 0 and stackAmount < item.amount) then
				drawItemPicture(item, x, y)
				dxDrawText(item.amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255, 255 * alphaProgress), 0.375, Roboto, "right")
			end
		end

		-- ** Mozgatott item
		if movedSlotId then
			dxDrawImage(panelPosX + panelWidth / 2 - 32, panelPosY - 5 - 64, 64, 64, "files/eye.png", 0, 0, 0, tocolor(255, 255, 255, 125 * alphaProgress))

			if cx >= panelPosX + panelWidth / 2 - 32 and cy >= panelPosY - 5 - 64 and cx <= panelPosX + panelWidth / 2 + 32 and cy <= panelPosY - 5 then
				if getTickCount() - showItemTick > 5500 then
					dxDrawImage(panelPosX + panelWidth / 2 - 32, panelPosY - 5 - 64, 64, 64, "files/eye.png", 0, 0, 0, tocolor(255, 255, 255, 200 * alphaProgress))
				end
			end

			local x = cx - moveDifferenceX
			local y = cy - moveDifferenceY

			drawItemPicture(itemsTable[itemsTableState][movedSlotId], x, y)

			if stackAmount < itemsTable[itemsTableState][movedSlotId].amount then
				if stackAmount > 0 then
					dxDrawText(stackAmount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255, 255 * alphaProgress), 0.375, Roboto, "right")
				else
					dxDrawText(itemsTable[itemsTableState][movedSlotId].amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255, 255 * alphaProgress), 0.375, Roboto, "right")
				end
			else
				dxDrawText(itemsTable[itemsTableState][movedSlotId].amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255, 255 * alphaProgress), 0.375, Roboto, "right")
			end
		end

		-- ** Item átnevezés
		if not renameDetails then
			if isCursorShowing() then
				if renameProcess then
					dxDrawImage(cx, cy, 32, 32, "files/nametag.png")
					setCursorAlpha(0)
				end
			elseif renameProcess then
				renameProcess = false
				setCursorAlpha(255)
			end
		elseif isCursorShowing() then
			setCursorAlpha(255)
		end

		if renameDetails then
			if getTickCount() - renameDetails.cursorChange >= 750 then
				renameDetails.cursorChange = getTickCount()
				renameDetails.cursorState = not renameDetails.cursorState
			end

			renameDetails.activeButton = false

			-- Háttér
			dxDrawRectangle(renameDetails.x, renameDetails.y, 200, 24, tocolor(0, 0, 0, 200))

			-- Mégsem
			local closeAlpha = 225

			if cx >= renameDetails.x + 200 - 32 and cy >= renameDetails.y + 3 and cx <= renameDetails.x + 200 - 32 + 28 and cy <= renameDetails.y + 3 + 18 then
				renameDetails.activeButton = "close"
				closeAlpha = 255
			end

			dxDrawRectangle(renameDetails.x + 200 - 32 + 1, renameDetails.y + 3, 28, 18, tocolor(215, 89, 89, closeAlpha * renameAlpha))
			dxDrawText("X", renameDetails.x + 200 - 32, renameDetails.y + 3, renameDetails.x + 200 - 32 + 28, renameDetails.y + 3 + 18, tocolor(0, 0, 0, 255 * renameAlpha), 0.5, Roboto, "center", "center")

			-- Alkalmaz
			local okayAlpha = 225

			if cx >= renameDetails.x + 200 - 64 and cy >= renameDetails.y + 3 and cx <= renameDetails.x + 200 - 64 + 28 and cy <= renameDetails.y + 3 + 18 then
				renameDetails.activeButton = "ok"
				okayAlpha = 255
			end

			dxDrawRectangle(renameDetails.x + 200 - 64, renameDetails.y + 3, 28, 18, tocolor(61, 122, 188, okayAlpha * renameAlpha))
			dxDrawText("Ok", renameDetails.x + 200 - 64, renameDetails.y + 3, renameDetails.x + 200 - 64 + 28, renameDetails.y + 3 + 18, tocolor(0, 0, 0, 255 * renameAlpha), 0.5, Roboto, "center", "center")

			-- Szöveg
			if renameDetails.cursorState then
				dxDrawText(renameDetails.text .. "|", renameDetails.x + 2, renameDetails.y, 0, renameDetails.y + 24, tocolor(255, 255, 255, 255 * renameAlpha), 0.5, Roboto, "left", "center")
			else
				dxDrawText(renameDetails.text, renameDetails.x + 2, renameDetails.y, 0, renameDetails.y + 24, tocolor(255, 255, 255, 255 * renameAlpha), 0.5, Roboto, "left", "center")
			end
		end
	end
end

function drawOutline(x, y, w, h, color)
	if x and y and w and h then 
		dxDrawRectangle(x, y, w, 1, color)
		dxDrawRectangle(x, y + h - 1, w, 1, color)
		dxDrawRectangle(x + w - 1, y, 1, h, color)
		dxDrawRectangle(x, y, 1, h, color)
	end
end

local searchState = false
local searchWidth = (defaultSettings.slotBoxWidth + 5) * defaultSettings.width + 5
local searchHeight = (defaultSettings.slotBoxHeight + 5) * math.floor(defaultSettings.slotLimit / defaultSettings.width) + 5 + 90
local searchPosX = screenX / 2
local searchPosY = screenY / 2
local searchDragging = false
local currentSearchTab = "main"
local hoverSearchTab = false
local bodyItems = {}
local bodyMoney = 0
local bodyName = ""
local gtaFont = false

addEvent("bodySearchGetDatas", true)
addEventHandler("bodySearchGetDatas", getRootElement(),
	function (items, name, cash)
		bodyItems = {}

		for k, v in pairs(items) do
			bodyItems[v.slot] = {
				itemId = v.itemId,
				amount = v.amount,
				data1 = v.data1,
				data2 = v.data2,
				data3 = v.data3,
				nameTag = v.nameTag,
				serial = v.serial
			}
		end

		bodyName = name
		bodyMoney = cash

		if not searchState then
			searchState = true
			gtaFont = dxCreateFont("files/fonts/gtaFont.ttf", 30, false, "antialiased")
			addEventHandler("onClientRender", getRootElement(), bodySearchRender)
			addEventHandler("onClientClick", getRootElement(), bodySearchClick)
		end
	end)

function bodySearchClick(button, state, cx, cy)
	if button == "left" and state == "up" then
		if hoverSearchTab then
			if hoverSearchTab and hoverSearchTab ~= currentSearchTab then
				currentSearchTab = hoverSearchTab
				playSound("files/sounds/tab.wav")
			end
		elseif cx >= searchPosX + searchWidth - 35 and cx <= searchPosX + searchWidth - 5 and cy >= searchPosY and cy <= searchPosY + 30 then
			removeEventHandler("onClientRender", getRootElement(), bodySearchRender)
			removeEventHandler("onClientClick", getRootElement(), bodySearchClick)

			bodyItems = {}
			searchState = false

			if isElement(gtaFont) then
				destroyElement(gtaFont)
			end

			gtaFont = nil
		end
	end
end

function bodySearchRender()
	local cx, cy = getCursorPosition()

	if isCursorShowing() then
		cx = cx * screenX
		cy = cy * screenY

		if not searchDragging then
			if getKeyState("mouse1") and cx >= searchPosX and cx <= searchPosX + searchWidth - 30 and cy >= searchPosY and cy <= searchPosY + 30 then
				searchDragging = {cx, cy, searchPosX, searchPosY}
			end
		elseif getKeyState("mouse1") then
			searchPosX = cx - searchDragging[1] + searchDragging[3]
			searchPosY = cy - searchDragging[2] + searchDragging[4]
		else
			searchDragging = false
		end
	else
		cx, cy = -1, -1
	end

	-- ** Háttér
	local panelHeight = panelHeight + 10
	dxDrawRectangle(searchPosX - 5, searchPosY - 5, panelWidth, panelHeight, tocolor(25, 25, 25, 255)) -- háttér
	dxDrawRectangle(searchPosX - 5, searchPosY - 5, panelWidth, 2, tocolor(0, 0, 0, 200)) -- felső
	dxDrawRectangle(searchPosX - 5, searchPosY - 5 + panelHeight - 2, panelWidth, 2, tocolor(0, 0, 0, 200)) -- alsó
	dxDrawRectangle(searchPosX - 5, searchPosY - 5 + 2, 2, panelHeight - 4, tocolor(0, 0, 0, 200)) -- bal
	dxDrawRectangle(searchPosX - 5 + panelWidth - 2, searchPosY - 5 + 2, 2, panelHeight - 4, tocolor(0, 0, 0, 200)) -- jobb

	-- ** Cím
	dxDrawText(bodyName, searchPosX + 5, searchPosY - 5, 0, searchPosY + 18, tocolor(230, 140, 140, 255), 0.5, Roboto, "left", "center", false, false, false, true)

	local currentMoney = bodyMoney
	local moneyForDraw = ""
	local moneyTextWidth = 0

	if tonumber(bodyMoney) < 0 then
		moneyTextWidth = dxGetTextWidth("- " .. bodyMoney .. " $", 0.5, gtaFont)
	else
		moneyTextWidth = dxGetTextWidth(bodyMoney .. " $", 0.5, gtaFont)
	end

	for i = 1, 15 - utfLen(currentMoney) do
		moneyForDraw = moneyForDraw .. "0"
	end

	if tonumber(currentMoney) < 0 then
		currentMoney = "#d75959" .. math.abs(currentMoney)
	elseif tonumber(currentMoney) > 0 then
		currentMoney = "#d19d6b" .. math.abs(currentMoney)
	else
		currentMoney = 0
	end

	moneyForDraw = currentMoney

	if tonumber(bodyMoney) < 0 then
		moneyForDraw = "- " .. moneyForDraw
	end

	dxDrawText(moneyForDraw .. " #eaeaea$", searchPosX + 5, searchPosY + 7, 0, searchPosY + 20 + 18, tocolor(255, 255, 255), 0.5, gtaFont, "left", "center", false, false, false, true)

	-- Bezárás
	if cx >= searchPosX + panelWidth - 35 and cx <= searchPosX + panelWidth - 5 and cy >= searchPosY and cy <= searchPosY + 30 then
		dxDrawText("X", searchPosX + panelWidth - 35, searchPosY, searchPosX + panelWidth - 5, searchPosY + 30, tocolor(215, 89, 89), 0.6, Roboto, "center", "center")
	else
		dxDrawText("X", searchPosX + panelWidth - 35, searchPosY, searchPosX + panelWidth - 5, searchPosY + 30, tocolor(255, 255, 255), 0.6, Roboto, "center", "center")
	end

	-- ** Itemek
	for i = 0, defaultSettings.slotLimit - 1 do
		local slot = i
		local x = searchPosX + (defaultSettings.slotBoxWidth + 3) * (slot % defaultSettings.width)
		local y = searchPosY + 25 + (defaultSettings.slotBoxHeight + 3) * math.floor(slot / defaultSettings.width) + 10

		if currentSearchTab == "keys" then
			i = i + defaultSettings.slotLimit
		elseif currentSearchTab == "papers" then
			i = i + defaultSettings.slotLimit * 2
		end

		local item = bodyItems[i]

		if cx >= x and cx <= x + defaultSettings.slotBoxWidth and cy >= y and cy <= y + defaultSettings.slotBoxHeight then
			if item then
				showTooltip2(cx, cy, "#FFFFFF" .. getItemName(item.itemId), false)
				slotColor2 = tocolor(61, 122, 188, 200)
			end
		end

		local slotColor = tocolor(50, 50, 50, 200)
		local slotColor2 = tocolor(90, 90, 90, 255)

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, defaultSettings.slotBoxHeight, tocolor(50, 50, 50, 200))

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, 1, slotColor2)
		dxDrawRectangle(x, y + defaultSettings.slotBoxWidth - 1, defaultSettings.slotBoxWidth, 1, slotColor2)
		dxDrawRectangle(x + defaultSettings.slotBoxWidth - 1, y, 1, defaultSettings.slotBoxHeight, slotColor2)
		dxDrawRectangle(x, y, 1, defaultSettings.slotBoxHeight, slotColor2)

		dxDrawRectangle(x, y, defaultSettings.slotBoxWidth, 1, slotColor)
		dxDrawRectangle(x, y + defaultSettings.slotBoxWidth - 1, defaultSettings.slotBoxWidth, 1, slotColor)
		dxDrawRectangle(x + defaultSettings.slotBoxWidth - 1, y, 1, defaultSettings.slotBoxHeight, slotColor)
		dxDrawRectangle(x, y, 1, defaultSettings.slotBoxHeight, slotColor)

		if item then
			drawActionbarImage(item, x, y)
			dxDrawText(item.amount, x + defaultSettings.slotBoxWidth - 6, y + defaultSettings.slotBoxHeight - 15, x + defaultSettings.slotBoxWidth, y + defaultSettings.slotBoxHeight - 15 + 5, tocolor(255, 255, 255), 0.375, Roboto, "right")
		end
	end
end

function isTheItemCopy(item)
	if item.itemId == 309 or item.itemId == 367 then
		return tonumber(item.data3) == 1
	end

	if item.itemId == 264 then
		return item.data3 and utf8.len(item.data3) > 0
	end

	if item.itemId == 207 or item.itemId == 208 or item.itemId == 308 or item.itemId == 310 then
		return utf8.find(item.data1, "iscopy")
	end

	--if item.itemId == 289 then
		--return utf8.find(item.data3, "iscopy")
	--end

	return false
end

function processTooltip(x, y, text, itemId, item, showItem)
	if tonumber(item.serial) and item.serial > 0 then
		text = text
	end

	if item.nameTag then
		text = text .. " #d75959(" .. item.nameTag .. ")"
	end

	showTooltip(x, y, "#FFFFFF" .. text, showItem)
end

function drawActionbarImage(item, x, y, sx, sy)
	sx = sx or defaultSettings.slotBoxWidth
	sy = sy or defaultSettings.slotBoxHeight

	if not item then
		dxDrawImage(x, y, sx, sy, "files/noitem.png")
	else
		local itemId = item.itemId
		local itemPictureId = itemId - 1
		local itemPicture = false
		local pictureAlpha = 255

		if itemPictures[itemId] then
			itemPicture = itemPictures[itemId]
		else
			itemPicture = "files/items/" .. itemPictureId .. ".png"
		end

		if pictureAlpha > 0 then
			dxDrawImage(x, y, sx, sy, itemPicture, 0, 0, 0, tocolor(255, 255, 255))
		end
	end
end

function drawItemPicture(item, x, y, sx, sy)
	sx = sx or defaultSettings.slotBoxWidth
	sy = sy or defaultSettings.slotBoxHeight

	if not item then
		dxDrawImage(x, y, sx, sy, "files/noitem.png")
	else
		local itemId = item.itemId
		local itemPictureId = itemId - 1
		local itemPicture = false
		local pictureAlpha = 255

		if itemPictures[itemId] then
			itemPicture = itemPictures[itemId]
		else
			itemPicture = "files/items/" .. itemPictureId .. ".png"
		end

		if pictureAlpha > 0 then
			dxDrawImage(x, y, sx, sy, itemPicture, 0, 0, 0, tocolor(255, 255, 255, pictureAlpha * alphaProgress))
		end
	end
end

function getCurrentWeight()
	local weight = 0

	for k, v in pairs(itemsTable.player) do
		if availableItems[v.itemId] then
			weight = weight
		end
	end

	return weight
end

function isHavePen()
	for k, v in pairs(itemsTable.player) do
		if v.itemId == 312 then
			return true
		end
	end

	return false
end

function playerHasItem(itemId)
	for k, v in pairs(itemsTable.player) do
		if v.itemId == itemId then
			return v
		end
	end

	return false
end

function hasItem(player, itemId)
	return playerHasItem(itemId)
end

function playerHasItemWithData(itemId, data, dataType)
	data = tonumber(data) or data
	dataType = dataType or "data1"

	for k, v in pairs(itemsTable.player) do
		if v.itemId == itemId and (tonumber(v[dataType]) or v[dataType]) == data then
			return v
		end
	end

	return false
end

function penSetData()
	for k, v in pairs(itemsTable.player) do
		if v.itemId == 312 then
			local damage = tonumber(v.data1 or 0) + 1

			if damage >= 100 then
				triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", v.dbID)
				exports.stdma_accounts:showInfo("e", "Kifogyott a tollad, ezért eldobtad.")
				break
			end

			triggerServerEvent("@Đää]ÄÄ}}ä", localPlayer, v.dbID, damage)
			break
		end
	end

	return false
end

function notepadSetData()
	for k, v in pairs(itemsTable.player) do
		if v.itemId == 366 then
			local usedpages = tonumber(v.data1 or 0) + 1

			if usedpages >= 20 then
				triggerServerEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", localPlayer, localPlayer, "dbID", v.dbID)
				exports.stdma_accounts:showInfo("e", "Kifogyott a jegyzetfüzetedből a lap, ezért eldobtad.")
				break
			end

			triggerServerEvent("@Đää]ÄÄ}}ä", localPlayer, v.dbID, usedpages) -- ugyan azt csinálja, ezért ugyan az az event név
			break
		end
	end

	return false
end

function unuseItem(dbID)
	if dbID then
		dbID = tonumber(dbID)

		for k, v in pairs(itemsTable.player) do
			if v.dbID == dbID then
				itemsTable.player[v.slot].inUse = false
				break
			end
		end
	end
end

function enableWeaponFire(state)
	if state then
		if playerNoAmmo then
			exports.stdma_controls:toggleControl({"fire", "vehicle_fire", "action"}, true)
			playerNoAmmo = false
		end
	else
		if not playerNoAmmo then
			exports.stdma_controls:toggleControl({"fire", "vehicle_fire", "action"}, false)
			playerNoAmmo = true
		end
	end
end

local itemlistState = false
local itemlistWidth = 800
local itemlistHeight = 600
local itemlistPosX = screenX / 2 - itemlistWidth / 2
local itemlistPosY = screenY / 2 - itemlistHeight / 2
local itemlistDragging = false
local itemlistTable = false
local itemlistOffset = 0
local itemlistText = ""

addCommandHandler("itemlist",
	function ()
		if getElementData(localPlayer, "adminLevel") >= 4 then
			itemlistState = not itemlistState

			if itemlistState then
				if not itemlistTable then
					itemlistTable = {}

					for i = 1, #availableItems do
						table.insert(itemlistTable, i)
					end
				end

				addEventHandler("onClientRender", getRootElement(), itemlistRender, true, "low-1000")
				addEventHandler("onClientCharacter", getRootElement(), itemlistCharacter)
				addEventHandler("onClientKey", getRootElement(), itemlistKey)
				showCursor(true)
			else
				removeEventHandler("onClientRender", getRootElement(), itemlistRender)
				removeEventHandler("onClientCharacter", getRootElement(), itemlistCharacter)
				removeEventHandler("onClientKey", getRootElement(), itemlistKey)
				showCursor(false)
			end
		end
	end)

function itemlistKey(key, press)
	if isCursorShowing() then
		cancelEvent()

		if key == "mouse_wheel_up" then
			if itemlistOffset > 0 then
				itemlistOffset = itemlistOffset - 1
			end
		end

		if key == "mouse_wheel_down" then
			if itemlistOffset < #itemlistTable - 14 then
				itemlistOffset = itemlistOffset + 1
			end
		end

		if press and key == "backspace" then
			itemlistText = utf8.sub(itemlistText, 1, utf8.len(itemlistText) - 1)
			searchItems()
		end
	end
end

function itemlistCharacter(character)
	if isCursorShowing() then
		itemlistText = itemlistText .. character
		searchItems()
	end
end

function searchItems()
	itemlistTable = {}

	if utf8.len(itemlistText) < 1 then
		for i = 1, #availableItems do
			table.insert(itemlistTable, i)
		end
	elseif tonumber(itemlistText) then
		local id = tonumber(itemlistText)

		if availableItems[id] then
			table.insert(itemlistTable, id)
		end
	else
		for i = 1, #availableItems do
			if utf8.find(utf8.lower(availableItems[i][1]), utf8.lower(itemlistText)) then
				table.insert(itemlistTable, i)
			end
		end
	end

	itemlistOffset = 0
end

function itemlistRender()
	local exitButtonAlpha = 200

	if isCursorShowing() then
		local cx, cy = getCursorPosition()

		cx = cx * screenX
		cy = cy * screenY

		if cx >= itemlistPosX + itemlistWidth - 100 and cx <= itemlistPosX + itemlistWidth - 10 and cy >= itemlistPosY + itemlistHeight - 30 and cy <= itemlistPosY + itemlistHeight - 10 then
			exitButtonAlpha = 255

			if getKeyState("mouse1") then
				itemlistState = false
				removeEventHandler("onClientRender", getRootElement(), itemlistRender)
				removeEventHandler("onClientCharacter", getRootElement(), itemlistCharacter)
				removeEventHandler("onClientKey", getRootElement(), itemlistKey)
				showCursor(false)
				return
			end
		end

		if not itemlistDragging then
			if getKeyState("mouse1") and cx >= itemlistPosX and cx <= itemlistPosX + itemlistWidth and cy >= itemlistPosY and cy <= itemlistPosY + itemlistHeight then
				itemlistDragging = {cx, cy, itemlistPosX, itemlistPosY}
			end
		elseif getKeyState("mouse1") then
			itemlistPosX = cx - itemlistDragging[1] + itemlistDragging[3]
			itemlistPosY = cy - itemlistDragging[2] + itemlistDragging[4]
		else
			itemlistDragging = false
		end
	end

	dxDrawRectangle(itemlistPosX, itemlistPosY, itemlistWidth, itemlistHeight, tocolor(0, 0, 0, 150))
	dxDrawRectangle(itemlistPosX + 8, itemlistPosY + 8, itemlistWidth - 16, 30, tocolor(0, 0, 0, 100))
	dxDrawText(itemlistText, itemlistPosX + 16, itemlistPosY + 8, 0, itemlistPosY + 38, tocolor(255, 255, 255), 0.6, Roboto, "left", "center")

	local oneSize = defaultSettings.slotBoxHeight / 0.915

	for i = 1, 14 do
		local y = itemlistPosY + 46 + (i - 1) * oneSize

		if i % 2 == 0 then
			dxDrawRectangle(itemlistPosX, y, itemlistWidth, oneSize, tocolor(0, 0, 0, 75))
		else
			dxDrawRectangle(itemlistPosX, y, itemlistWidth, oneSize, tocolor(0, 0, 0, 100))
		end

		local item = itemlistTable[i + itemlistOffset]

		if item then
			if fileExists("files/items/" .. item - 1 .. ".png") then
				dxDrawImage(itemlistPosX + 4, y + 4, oneSize - 8, oneSize - 8, "files/items/" .. item - 1 .. ".png")
			else
				dxDrawImage(itemlistPosX + 4, y + 4, oneSize - 8, oneSize - 8, "files/items/nopic.png")
			end

			dxDrawText("[" .. item .. "] " .. availableItems[item][1], itemlistPosX + oneSize, y, 0, y + oneSize / 2 + 3, tocolor(255, 255, 255), 0.5, Roboto, "left", "center")
			dxDrawText(availableItems[item][2], itemlistPosX + oneSize, y + oneSize / 2 - 3, 0, y + oneSize, tocolor(200, 200, 200), 0.45, Roboto, "left", "center")
		end
	end

	if #itemlistTable > 14 then
		dxDrawRectangle(itemlistPosX + itemlistWidth - 5, itemlistPosY + 46, 5, 504, tocolor(0, 0, 0, 100))
		dxDrawRectangle(itemlistPosX + itemlistWidth - 5, itemlistPosY + 46 + (504 / #itemlistTable) * itemlistOffset, 5, (504 / #itemlistTable) * 14, tocolor(61, 122, 188, 150))
	end

	dxDrawRectangle(itemlistPosX + itemlistWidth - 100, itemlistPosY + itemlistHeight - 30, 90, 20, tocolor(215, 89, 89, exitButtonAlpha))
	dxDrawText("Bezárás", itemlistPosX + itemlistWidth - 100, itemlistPosY + itemlistHeight - 30, itemlistPosX + itemlistWidth - 10, itemlistPosY + itemlistHeight - 10, tocolor(0, 0, 0), 0.45, Roboto, "center", "center")
end