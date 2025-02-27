if fileExists("codeClient.lua") then
	fileDelete("codeClient.lua")
end


localPlayer:setData('useingWeapon > item', false)
sx, sy = guiGetScreenSize()
--sx, sy = 1280, 720
local alpha = 0
local useData = {}
local tick = getTickCount()
local items = {}
local itemMoveStorage = {}
local Inventory = {
    show = false,
    size = Vector2(340, 175),
    movable = true,
    invSlot = 32,
    itemicons = 4,
    itemIconPNG = {
    	'files/bag.png',
    	'files/keys.png',
    	'files/wallet.png',
    	'files/craft.png'
    },
    itemIconPadding = 35,
    activePage = 1
}
setmetatable({}, {__index = Inventory})

local handlers = {
    {
        name = 'onClientRender',
        func = function(...)
            return Inventory:Render(...)
        end
    },
    {
        name = 'onClientRender',
        func = function(...)
            return Inventory:RenderSlot()
        end
    },
    {
    	name = 'onClientClick',
    	func = function(...)
    		return Inventory:MoveItem(...)
    	end
    },
    {
    	name = 'onClientClick',
    	func = function(...)
    		return Inventory:UsePlayerItem(...)
    	end
    },
    {
    	name = 'onClientClick',
    	func = function(...)
    		return Inventory:SelectPage(...)
    	end
    }
}

function Inventory:Open(element)
    for _, event in pairs(handlers) do
        removeEventHandler(event.name, event.arg or root, event.func)
        addEventHandler(event.name, event.arg or root, event.func)
    end
    self.show = element
    self.activePage = 1
    self.hovered = false
    self.selectedSlot = false
    tick = getTickCount()
end

function getInventorySize()
	return Vector2(Inventory.size.x, Inventory.size.y)
end
getInventorySize()

function Inventory:Close()
    for _, event in pairs(handlers) do
        removeEventHandler(event.name, event.arg or root, event.func)
    end
    self.show = false
    self.hovered = false
    self.selectedSlot = false
    self.activePage = false
    tick = getTickCount()
end

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

local sx, sy = guiGetScreenSize()
local panelSize = {330, 165}
local startX, startY = sx - panelSize[1] - 200, sy - panelSize[2] - 300
local font = dxCreateFont("files/Roboto-Condensed.otf", 10)
local fontSmall = dxCreateFont("files/Roboto-Condensed.otf", 8)
local font2 = dxCreateFont("files/Roboto-Condensed.otf", 12)

function Inventory:Render()
	--if not exports.ml_interface:isWidgetShowing('inventory') then return end
	local invX, invY = sx - 500, sy - 500
	alphaAnimation = interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount() - tick) / 600, 'Linear')
	width = interpolateBetween(0, 0, 0, panelSize[1]/2, 0, 0, (getTickCount() - tick) / 600, "InQuad")
	Inventory.pos = Vector2(invX, invY)
    self.hovered = false
    self.selectedSlot = false
	if inventoryMoving == true then
		local cx, cy = getCursorPosition()
		startX = cx * sx - panelSize[1] + 10
		startY = cy * sy
	end
	roundedRectangle(startX+5, startY-10, panelSize[1], panelSize[2] + 20, tocolor(60, 60, 60, alphaAnimation))
    roundedRectangle(startX+7, startY-8, panelSize[1] -4, panelSize[2] + 16, tocolor(45, 45, 45, alphaAnimation))
	dxDrawImage(startX+5, startY-8, 16, 16, "files/logo.png", 0, 0, 0, tocolor(200, 200, 200, alphaAnimation))
	dxDrawImage(startX+5+panelSize[1]-20, startY-8, 16, 16, "files/move.png", 0, 0, 0, tocolor(100, 100, 100, alphaAnimation))
	dxDrawRectangle(startX + 5 + panelSize[1]/2, startY+panelSize[2]+7, width, 2, tocolor(115, 100, 70, alphaAnimation))
	dxDrawRectangle(startX + 5 + panelSize[1]/2, startY+panelSize[2]+7, -width, 2, tocolor(115, 100, 70, alphaAnimation))
	dxDrawText("Inventory", startX + 50, startY + 2, _, _, tocolor(200, 200, 200, alphaAnimation), 1, font, "center", "center")
end


local SlothoverColor = 255
local slotColor = {}

local imageColor = {}

function Inventory:RenderSlot()
    local slotCount = 0
    local x = 0
    local y = 0

    for i = 1, self.invSlot do 

        local slotHovered = isCursorOnBox(12 + startX + x, 10 + startY +y, 35, 35)
		x = x
		y = y
        slotColor = slotHovered and {50, 50, 50, alphaAnimation} or {30, 30, 30, alphaAnimation}

        --dxDrawRectangle(self.pos + Vector2(12 + x, 10 + y), Vector2(35, 35), tocolor(unpack(slotColor)))
        dxDrawRectangle(12 + startX + x, 10 + startY +y, 35, 35, tocolor(unpack(slotColor)), false)

        if #items > 0 then
	    	for slot, item in pairs(items) do

        		if isCursorOnBox(12 + startX + x, 10 + startY +y, 35, 35) then
        			self.hovered = 'slot'
        			self.selectedSlot = i
        		end

	    		if items[slot].slot == i then
	    			if itemMoveStorage[2] and itemMoveStorage[1] == items[slot].slot then
	    				if not isCursorShowing() then itemMoveStorage = {} return end
	    				local cursorX, cursorY = getCursorPosition()
	        			dxDrawImage(12 + cursorX * sx - 10, 10 + cursorY * sy - 20, 35, 35, getItemImagePath(items[slot].item), 0, 0, 0, tocolor(255, 255, 255, alphaAnimation), true)
    					dxDrawText(items[slot].count, 15 + cursorX * sx, 18 + cursorY * sy, _, _, tocolor(255, 255, 255, alphaAnimation), 1, fontSmall, 'center', 'center', false, false, true)
	    			else
						if isCursorOnBox(12 + startX + x, 10 + startY + y, 35, 35) then
							local cursorX, cursorY = getCursorPosition()
							dxDrawImage(12 + startX + x, 10 + startY + y, 35, 35, getItemImagePath(items[slot].item), 0, 0, 0, tocolor(255, 255, 255, alphaAnimation), false)
							dxDrawText(items[slot].count, 18 + startX + x, 20 + startY + y + 18, _, _, tocolor(255, 255, 255, alphaAnimation), 1, fontSmall, 'center', 'center', false, false, false)
							createTooltip(getItemName(items[slot].item))
						else
							dxDrawImage(12 + startX + x, 10 + startY + y, 35, 35, getItemImagePath(items[slot].item), 0, 0, 0, tocolor(255, 255, 255, alphaAnimation), false)
							dxDrawText(items[slot].count, 18 + startX + x, 20 + startY + y + 18, _, _, tocolor(255, 255, 255, alphaAnimation), 1, fontSmall, 'center', 'center', false, false, false)
							--dxDrawText(getItemName(items[slot].item), 15 + startX + x, 25 + startY + y, _, _, tocolor(255, 255, 255), 1, 'default-bold', 'center', 'center', false, false, true)
						end
	        		end
	        	end
	        end
        end
        slotCount = slotCount + 1
        x = x + 40
        if slotCount == 8 then
            x = 0
            slotCount = 0
            y = y + 40
        end
    end
end

function createTooltip(text)
	--[[local width, height = dxGetTextWidth(text, 1, font), 20

	dxDrawRectangle(x/1920*sx, (y - 25)/1080*sy, (width + 10)/1920*sx, height/1080*sy, tocolor(55, 55, 55), true)
	dxDrawText(text, (x + 5)/1920*sx, (y - 15)/1080*sy, _, _, tocolor(255, 255, 255), 1, font, "left", "center", false, false, true, true)]]--
	local x, y = getCursorPosition();
	local x, y = x * sx, y * sy;
	local x, y = x + 10, y + 10

	text = tostring(text)
	
	local width = dxGetTextWidth(text, 1, font) + 10
	local height = 20

	x = math.max(10, math.min(x, sx - width - 10 ))
	y = math.max(10, math.min(y, sy - height - 10 ))
	
	dxDrawRectangle(x, y, width, height, tocolor(55, 55, 55), true)
	dxDrawText(text, x, y, x + width, y + height, tocolor(200, 200, 200), 1, font, "center", "center", false, false, true, true)
end

function onClick(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
	if button == "left" then
			if state == "down" then
				if isInBox2(startX+5+panelSize[1]-22, startY-10, 16, 16, absoluteX, absoluteY) then
					inventoryMoving = true
				end
				--print("move")
			elseif state == "up" then
				inventoryMoving = false
			end
		--end
	end
end
addEventHandler("onClientClick", root, onClick)

function isInBox2(dX, dY, dSZ, dM, eX, eY)
	if(eX >= dX and eX <= dX+dSZ and eY >= dY and eY <= dY+dM) then
		return true
	else
		return false
	end
end

bindKey('i', 'down', function()
	if not getElementData(localPlayer, 'loggedIn') then return end
    if Inventory.show then
        Inventory:Close()
        itemMoveStorage = {}
    else
		tick = getTickCount()
        Inventory:Open(true) 
    end
end)
local inventorySlot = 1
local factionItemCache = false
function givePlayerItem(itemid, slot, count, page, percentage, factionItem, actionslot, dbid)
	if #items >= 32 then return end
	if itemid and count and page and percentage then
		if slot then
			inventorySlot = 1
			inventorySlot = slot
		else
			inventorySlot = 1
			-- DUAL CHECK
			for w = 1, #items do
				if inventorySlot == items[w].slot then
					inventorySlot = inventorySlot + 1
				end
			end
			for key, value in pairs(items) do
				if items[key].slot == inventorySlot then
					inventorySlot = inventorySlot + 1
				end
			end
			-- 
		end
		if dbid then
			dbid = dbid
		end
		if factionItem then
			factionItemCache = factionItem
		else
			factionItemCache = false
		end
		if not count then
			count = 1
		end
		-- local itemheight = itemLIST[itemid].height
		table.insert(items, {
			item = itemid,
			slot = inventorySlot,
			count = tonumber(count),
			percentage = page,
			factionItem = factionItemCache,
            actionSlot = actionslot or 0,
            usable = itemLIST[itemid].usable,
			wepID = tonumber(itemLIST[itemid].weaponID) or 0,
			id = tonumber(dbid)
		})
		--if not factionItemCache then
			triggerServerEvent('uploadSqlItems > ml', localPlayer, localPlayer, itemid, inventorySlot, count, page, percentage, id)
		--end
	end
end
--function givePlayerItem(itemid, slot, count, page, percentage, factionItem, actionslot)
function setPlayerItemsInInventoryLoad()
	items = {}
	triggerServerEvent('serverResourceStart > ml', localPlayer, localPlayer)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
	if localPlayer:getData('loggedIn') then
		items = {}
		setPlayerItemsInInventoryLoad()
	end
end)

addEventHandler('onClientElementDataChange', localPlayer, function(data, oldValue, newValue)
	if data == 'loggedIn' then
		if newValue then
			setPlayerItemsInInventoryLoad()
		end
	end
end)


addEvent('giveItemAcceptedServer > ml', true)
addEventHandler('giveItemAcceptedServer > ml', root, function(itemid, slot, count, page, percentage, actionslot, dbid)
	givePlayerItem(itemid, slot, count, page, percentage, false, actionslot, dbid)
end)

function getItemImagePath(image)
	return 'files/items/' .. image .. '.png'
end

function isInSlot(position, size) 
    if isCursorShowing() then 
        cPosX, cPosY = getCursorPosition()
        cPosX, cPosY = cPosX * sx, cPosY * sy
        if ( (cPosX > position.x) and (cPosY > position.y) and (cPosX < position.x + size.x) and (cPosY < position.y + size.y) ) then 
            return true 
        else
            return false
        end
    end
end
function isCursorOnBox(xS,yS,wS,hS)
	if(isCursorShowing()) then
		XY = {guiGetScreenSize()}
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX*XY[1], cursorY*XY[2]
		if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
			return true
		else
			return false
		end
	end	
end
--ITEM MOZGATÁS

function Inventory:MoveItem(button, state)
	if button == 'left' then
    	for slot, item in pairs(items) do
			if state == 'down' then
				if self.selectedSlot and self.selectedSlot == items[slot].slot and self.hovered == 'slot' then
					itemMoveStorage = {items[slot].slot, items[slot].item, items[slot].count, self.selectedSlot, items[slot].factionItem, items[slot]}
					return
				end
			elseif state == 'up' then
				self.selectedSlot = self.selectedSlot
				--self.selectedSlot = 1
				if self.selectedSlot then
					if items[slot].slot == itemMoveStorage[1] then
						for w = 1, #items do
							if items[w].slot == self.selectedSlot then
								itemMoveStorage = {}
								return
							end
						end
						items[slot].slot = self.selectedSlot
						triggerServerEvent('updateItemSlot > ml', localPlayer, localPlayer, itemMoveStorage[4], self.selectedSlot, 1, items[slot].id)
						itemMoveStorage = {}
					end
				else
					itemMoveStorage = {}
				end
			end
		end
	end
end
  
function takePlayerItem(slot, page)
	if slot then
		table.remove(items, slot)
	end
end

function split(str)

	if not str or type(str) ~= "string" then return false end
 
	local splitStr = {}
	for i=1,string.len(str) do
	   local char = str:sub( i, i )
	   table.insert( splitStr , char )
	end
 
	return splitStr 
end

function insert(self, str1, str2, pos)
    if (self) then
        return self:sub(1,str2)..str1..self:sub(str2+1)
    else
        return str1:sub(1,pos)..str2..str1:sub(pos+1)
    end
end

function round(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end

function useItem(i)
	if i then
		for key, value in pairs(items) do
			if items[key].slot == i then
				local itemID = tonumber(items[key].item)
				local itemName = tostring(itemLIST[itemID].name)
				local usable = items[key].usable
				local count = tonumber(items[key].count)

				if usable then
					if count > 1 then
						count = count - 1
						triggerServerEvent('updateitemCount > ml', localPlayer, localPlayer, i, count)
					else
						takePlayerItem(key, 1)
						triggerServerEvent('deleteItemWhereSlot > ml', localPlayer, localPlayer, i, 1)
					end

					if itemID >= 14 and itemID <= 17 then
						local prizes = {"pp", "$", "xp", "armor"}
						local randint = math.random(1, #prizes)
						local prize = tostring(prizes[randint])
	
						local int1 = math.random(1, 9)
						local int2 = math.random(1, 9)
						local count = int1 .. int2 .. "0"
						count = tonumber(count)

						if randint == 1 then
							count = count / 3
							count = round(count, 0)
							setElementData(localPlayer, "a.Premiumpont", getElementData(localPlayer, "a.Premiumpont") + count)
						elseif randint == 2 then
							setElementData(localPlayer, "a.Money", getElementData(localPlayer, "a.Money") + count)
						elseif randint == 3 then
							count = count / 1.5
							count = round(count, 0)
							setElementData(localPlayer, "a.Experience", getElementData(localPlayer, "a.Experience") + count)
						elseif randint == 4 then
							count = 100
							setPedArmor(localPlayer, count)
						end

						
						outputChatBox("#9BE48F[Success]: #ffffffYou have successfully opened a " .. itemName .. ". You get: " .. count .."".. prize .. ".", 255, 255, 255, true)
					elseif itemID == 41 then
						if not isPlayerInVehicle(localPlayer) then
							outputChatBox("#d75959[Nitro]: #ffffffNem vagy járműben!", 255, 255, 255, true)
							givePlayerItem(41, false, count, 1, 100)
						end
						if isPlayerInVehicle(localPlayer) then
							local vehicle = getPedOccupiedVehicle(localPlayer)
							setElementData(vehicle, "a.Nitro", 50)
							outputChatBox("#9BE48F[Nitro]: #ffffffSikeresen beszereltél egy " .. itemName .. ". tárgyat a járművedbe.", 255, 255, 255, true)
						end
					elseif itemID == 42 then
						if not isPlayerInVehicle(localPlayer) then
							outputChatBox("#d75959[Nitro]: #ffffffNem vagy járműben!", 255, 255, 255, true)
							givePlayerItem(42, false, count, 1, 100)
						end 
						if isPlayerInVehicle(localPlayer) then
							local vehicle = getPedOccupiedVehicle(localPlayer)
							setElementData(vehicle, "a.Nitro", 50)
							outputChatBox("#9BE48F[Nitro]: #ffffffSikeresen beszereltél egy " .. itemName .. ". tárgyat a járművedbe.", 255, 255, 255, true)
						end
					elseif itemID == 18 then
						local prizes = {"pp", "money", "xp", "customwep"}
						local randint = math.random(1, #prizes)
						local prize = tostring(prizes[randint])
	
						local int1 = math.random(1, 9)
						local int2 = math.random(1, 9)
						local count = int1 .. int2 .. "0"
						count = tonumber(count)

						if randint == 1 then
							setElementData(localPlayer, "a.Premiumpont", getElementData(localPlayer, "a.Premiumpont") + count)
						elseif randint == 2 then
							setElementData(localPlayer, "a.Money", getElementData(localPlayer, "a.Money") + count)
						elseif randint == 3 then
							setElementData(localPlayer, "a.Experience", getElementData(localPlayer, "a.Experience") + count)
						else
							count = 1
							local x = math.random(19, 34)
							givePlayerItem(x, false, 1, 1, 100, false)
						end

						
						outputChatBox("#9BE48F[Success]: #ffffffYou have successfully opened a " .. itemName .. ". You get: " .. count .." ".. prize .. ".", 255, 255, 255, true)
					end
				end
				if items[key].wepID > 0 then
					triggerServerEvent('takeOrGiveWeapon > item', localPlayer, localPlayer, tonumber(items[key].wepID), '-', tonumber(items[key].item))
				end
			end
		end
	end
end


function isSlotFree(slot)
	if slot then
		for i = 1, 32 do
			if items[i].slot ~= slot then
				return true
			else
				return false
			end
		end
	end
end

function findIndex(tbl)
	for i = 1, 32 do
		if tbl[i] then
			return true
		else 
			return false
		end
	end
end

function Inventory:UsePlayerItem(button, state)
	if self.hovered == 'slot' and self.selectedSlot then
		if button == 'right' and state == 'down' then
			-- outputChatBox('?')
			useItem(self.selectedSlot)
			-- triggerServerEvent('deleteItemWhereSlot > ml', localPlayer, localPlayer, self.selectedSlot, self.activePage)
		end
	end
end

function Inventory:SelectPage(button, state)
	if self.hovered == 'image' and self.selectedSlot then
		if button == 'left' and state == 'down' then
			self.activePage = self.selectedSlot
			--outputChatBox(self.activePage)
		end
	end	
end

--UTILS

function isValueInTable(theTable, value, columnID)
    assert(theTable, "Bad argument 1 @ isValueInTable (table expected, got " .. type(theTable) .. ")")
    local checkIsTable = type(theTable)
    assert(checkIsTable == "table", "Invalid value type @ isValueInTable (table expected, got " .. checkIsTable .. ")")
    assert(value, "Bad argument 2 @ isValueInTable (value expected, got " .. type(value) .. ")")
    assert(columnID, "Bad argument 3 @ isValueInTable (number expected, got " .. type(columnID) .. ")")
    local checkIsID = type(columnID)
    assert(checkIsID == "number", "Invalid value type @ isValueInTable (number expected, got " ..checkIsID .. ")")
    for i,v in ipairs (theTable) do
        if v[columnID] == value then
            return true,i
        end
    end
    return false
end

addEvent('giveTargetItem > ml', true)
addEventHandler('giveTargetItem > ml', root, function(itemid, count)
	-- items = {}
	inventorySlot = 1
	givePlayerItem(tonumber(itemid), false, count, 1, 100)
end)

function drawItemImage(position, size, img)
	return dxDrawImage(position, size, getItemImagePath(img))
end


-- tárgy átadása
-- még nem volt kivel tesztelni ezért ez még vár reggeligxddxű
-- itemMoveStorage = {items[slot].slot, items[slot].item, items[slot].count, items[slot].page, self.selectedSlot}
function givePlayerItemInMoveItem(button, state, x, y, wx, wy, wz, element)
	if button == 'left' and state == 'up' and itemMoveStorage[2] and itemMoveStorage[3] then
		if element and element.type == 'player' then
			if element == localPlayer then return end
			if itemMoveStorage[5] then return outputChatBox('#7098CF' .. '[ITEM]:' .. '#FFFFFF' .. 'Frakció itemet nem tudsz átadni!', 255, 255, 255, true) end
			local distance = getDistanceBetweenPoints3D(localPlayer.position, element.position)
			if distance > 5 then return end
			triggerServerEvent('giveTriggerElementItem > ml', localPlayer, localPlayer, element, itemMoveStorage[2], itemMoveStorage[3])
			triggerServerEvent('deleteItemWhereSlot > ml', localPlayer, localPlayer, itemMoveStorage[1], 1)
			--print("igen")
			for k, v in pairs(items) do
				if items[k].slot == itemMoveStorage[1] and items[k].item == itemMoveStorage[2] then
					table.remove(items, k)
					itemMoveStorage = {}
				end
			end
		end
	end
end
addEventHandler('onClientClick', root, givePlayerItemInMoveItem)

function getAllDutyItem()
    local temp = {} 
    for i, v in ipairs(items) do 
        if not isElement(items[i]) then 
        	if items[i].factionItem then
           	 table.insert(temp, i)
           	end
        end 
    end 
    for i, v in ipairs(temp) do 
        table.remove(items, v-(i-1)) 
    end 
    temp = {} 
end

function table.removeValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            table.remove(tab, index)
            return index
        end
    end
    return false
end
--ACTIONBAR    
local actionBarHovered = false
function Inventory_ActionBarRender()
    actionBarHovered = false
	 if not getElementData(localPlayer, 'a.HUDshowed') then return end
	 if not getElementData(localPlayer, 'loggedIn') then return end
	--if not exports.ml_interface:isWidgetShowing('actionbar') then return end
	local actionbarX, actionbarY = sx/2-195/2, sy-50
	dxDrawRectangle(actionbarX, actionbarY - 2, 195, 40 + 3, tocolor(60, 60, 60))
	dxDrawRectangle(actionbarX + 2, actionbarY - 1.5, 191, 40 + 1, tocolor(45, 45, 45))

	for i = 1, 5 do
		-- dxDrawRectangle(Vector2(sx / 2 - 32 + i * 76 / 2 - 76, sy - 80 / 2), Vector2(35, 35), tocolor(30, 30, 30))
		if isInSlot(Vector2(actionbarX + (i * 38) - 34.4, actionbarY + 2), Vector2(35, 35)) then
			dxDrawRectangle(Vector2(actionbarX + (i * 38) - 34.4, actionbarY + 2), Vector2(35, 35), tocolor(45, 45, 45))
		else
			dxDrawRectangle(Vector2(actionbarX + (i * 38) - 34.4, actionbarY + 2), Vector2(35, 35), tocolor(30, 30, 30))
		end
        if isInSlot(Vector2(actionbarX + (i * 38) - 34.4, actionbarY + 2), Vector2(35, 35)) then
            actionBarHovered = i 
        end
        for k, v in pairs(items) do
            if items[k].actionSlot == i then
                dxDrawImage(Vector2(actionbarX + (i * 38) - 34.4, actionbarY + 2), Vector2(35, 35), getItemImagePath(items[k].item))
                dxDrawText(v.count, actionbarX + (i * 38) - 28, actionbarY + 10 + 18, _, _, tocolor(255, 255, 255), 1, font, 'center', 'center')
            end
        end
	end
end
addEventHandler('onClientRender', root, Inventory_ActionBarRender)

addEventHandler('onClientClick', root, function(button, state)
    if itemMoveStorage[1] and itemMoveStorage[2] then
        if button == 'left' and state == 'up' then
            if actionBarHovered then
            	for k, v in pairs(items) do
            		if items[k].actionSlot == actionBarHovered then
            			--exports.ml_notification:addNotification('A sloton már van egy item!', 'warning')
            			itemMoveStorage = {}
            			return
            		end
            	end
                itemMoveStorage[6].actionSlot = actionBarHovered
--                outputChatBox(itemMoveStorage[7].actionSlot)
                triggerServerEvent('updateActionSlot > item', localPlayer, localPlayer, actionBarHovered, itemMoveStorage[1])
                itemMoveStorage = {}
            end
        end
    end
end)

addEventHandler('onClientKey', root, function(button, state)
    for index = 1, 5 do
        if button == tostring(index) and state then
            for k, v in pairs(items) do 
                if v.actionSlot == index then
                    useItem(items[k].slot)
                end
            end
        end
    end
end)

addEventHandler('onClientClick', root, function(button, state)
    if button == 'left' and state == 'down' and actionBarHovered then
        for k, v in pairs(items) do
            if v.actionSlot == actionBarHovered then
                --outputChatBox(v.slot)
                v.actionSlot = 0
                triggerServerEvent('updateActionSlot > item', localPlayer, localPlayer, v.actionSlot, v.slot)
            end
        end
    end
end)

function hasPlayerItem(itemid)
	for i = 1, #items do
		if items[i].item == tonumber(itemid) then
			return true
		end
	end
end
--ACTIONBAR VÉGE

local weaponPosition = {
	-- AK
    [355] = {
        position = Vector3(-0.1, -0.18, 0.2),
        rotation = Vector3(8, 95, 0)
    }
    -- 
}
-- WEAPON

-- FEGYVER GÖRGŐZÉS
-- FIXED
addEventHandler('onClientPlayerWeaponSwitch', localPlayer, function(oldslot, newslot)
	toggleControl('next_weapon ', false)
	toggleControl('previous_weapon ', false)
end)

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

local sX, sY = guiGetScreenSize()
local panelSize = {450, 350}
local itemListShowed = false;
local fontBold = dxCreateFont("files/Roboto-BoldCondensed.otf", 20)
local fontBoldSmaller = dxCreateFont("files/Roboto-BoldCondensed.otf", 15)
local scrollingValue = 0
local maxItemsOnScreen = 9


function createItemList(commandName)
	if getElementData(localPlayer, "adminLevel") >= 3 then
		if itemListShowed == true then
			itemListShowed = false
			removeEventHandler("onClientRender", root, onItemListRender)
			outputChatBox("#E48F8F[Item]: #FFFFFFSikeresen #E48F8Feltűntetted #FFFFFFaz itemlistát.", 255, 255, 255, true)
		else
			alphaTick = getTickCount()
			itemListShowed = true
			addEventHandler("onClientRender", root, onItemListRender)
			outputChatBox("#E48F8F[Item]: #FFFFFFSikeresen #9BE48Felőhoztad #FFFFFFaz itemlistát.", 255, 255, 255, true)
		end
	end
end
addCommandHandler("itemlist", createItemList)

-- Kirajzolás

function onItemListRender()
	if not itemListShowed then
		return
	end

	local nowTick = getTickCount()
	local elapsedTime = nowTick - alphaTick
	local duration = elapsedTime / 500
	a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")
	roundedRectangle(sX / 2 - panelSize[1] / 2, sY / 2 - panelSize[2] / 2, panelSize[1], panelSize[2] + 10, tocolor(65, 65, 65, a))
	roundedRectangle(sX / 2 - panelSize[1] / 2 + 2, sY / 2 - panelSize[2] / 2 + 2, panelSize[1] - 4, panelSize[2] + 6, tocolor(30, 30, 30, a))
	dxDrawText("Itemlista", sX / 2, sY / 2 - panelSize[2] / 2 + 20, _, _, tocolor(200, 200, 200, a), 1, fontBold, "center", "center", false)

	for k, v in ipairs(itemLIST) do
		if k <= maxItemsOnScreen and (k > scrollingValue) then
			roundedRectangle(sX / 2 - panelSize[1] / 2 + 20, sY / 2 - panelSize[2] / 2 + 40 + (k - scrollingValue - 1)*35, panelSize[1] - 40, 30, tocolor(45, 45, 45, a))
			dxDrawText(v.itemid, sX / 2 - panelSize[1]/2 + 35, sY / 2 - panelSize[2] / 2 + 55 + (k - scrollingValue - 1)*35, _, _, tocolor(210, 160, 110, a), 1, fontBoldSmaller, "left", "center")
			dxDrawRectangle(sX / 2 - panelSize[1]/2 + 73, sY / 2 - panelSize[2] / 2 + 41 + (k - scrollingValue - 1)*35, 29, 29, tocolor(20, 20, 20, a))
			dxDrawImage(sX / 2 - panelSize[1]/2 + 75, sY / 2 - panelSize[2] / 2 + 43 + (k - scrollingValue - 1)*35, 25, 25, "files/items/" .. tonumber(v.itemid) .. ".png", 0, 0, 0, tocolor(200, 200, 200, a))
			dxDrawText(v.name, sX / 2 - panelSize[1]/2 + 125, sY / 2 - panelSize[2] / 2 + 55 + (k - scrollingValue - 1)*35, _, _, tocolor(200, 200, 200, a), 1, fontBoldSmaller, "left", "center")
		end
	end
end

-- Görgetés

addEventHandler("onClientKey", getRootElement(), function(button, press)
	if press and itemListShowed == true then
		if button == "mouse_wheel_up" then
		  	if scrollingValue > 0  then
				scrollingValue = scrollingValue - 1
				maxItemsOnScreen = maxItemsOnScreen - 1
		  	end
		elseif button == "mouse_wheel_down" then
		  	if maxItemsOnScreen < #itemLIST then
				scrollingValue = scrollingValue + 1
				maxItemsOnScreen = maxItemsOnScreen + 1
		 	end
		end
		if button == "mouse3" and isCursorInBox(sX / 2 - panelSize[1] / 2, sY / 2 - panelSize[2] / 2, panelSize[1], panelSize[2] + 10) then
			for k, v in ipairs(itemLIST) do
				if k <= maxItemsOnScreen and (k > scrollingValue) then
					if isCursorInBox(sX / 2 - panelSize[1] / 2 + 20, sY / 2 - panelSize[2] / 2 + 40 + (k - scrollingValue - 1)*35, panelSize[1] - 40, 30) then
						--triggerEvent("giveTargetItem > ml", localPlayer, localPlayer, tonumber(v.itemid), 1)
						givePlayerItem(tonumber(v.itemid), false, 1, 1, 100, false, 0)
						outputChatBox("#9BE48F[Give]: #FFFFFFSikeresen adtál magadnak #8FC3E41 #FFFFFFdarab #8FC3E4" .. getItemName(tonumber(v.itemid)) .. "#FFFFFF-et/t.", 255, 255, 255, true)
					end
				end
			end
		end
	end
end)

function isCursorInBox ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end