local dbname = "s33503_alphames_items";
local host = "maria.srkhost.eu";
local username = "u33503_jUthbUmnKf";
local password = "+yn9wpMqgP0H92iqm=5ip1W+";

local con;
local connectionAttempts = 1;

function connectMysql()
	con = dbConnect( "mysql", "dbname="..dbname..";host="..host..";charset=utf8", username, password, "share=0" );

	if (con) then
		outputDebugString("MySQL connection was succesful.", 0, 255, 255, 0);
		outputServerLog("MySQL connection succesful.")
		connectionAttempts = 1;
	else
		outputDebugString("MySQL connection failed. Trying it again.", 0, 255, 255, 0);
		outputServerLog("MySQL connection failed. Trying again.")
		if (connectionAttempts < 3) then
			connectionAttempts = connectionAttempts + 1;
			setTimer(connectMysql, 10000, 1);
		else
			outputDebugString("MySQL connection failed. Server is going to stop in 30 seconds.", 0, 255, 255, 0);
			outputServerLog("MySQL connection failed. Server is going to stop in 30 seconds.")
			setTimer(function()
				shutdown("MySQL connection failed.");
			end, 30000, 1);
		end
	end
end

connectMysql();

function getConnection()
	if (con) then
		return con;
	end
end

itemsTable = {}
inventoryInUse = {}

local wallNotes = {}
local playerItemObjects = {}

local lastWeaponSerial = 0
local lastTicketSerial = 0

local trackingTimer = {}

addEventHandler("}Đää{äđÄ&}}Ä&ÄĐ~", getRootElement(),
	function (db)
		connection = db
	end)

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		connection = getConnection()
	end)

addEventHandler("onResourceStop", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("player")) do
			takeAllWeapons(v)
			removeElementData(v, "canisterInHand")
		end

		if fileExists("saves.json") then
			fileDelete("saves.json")
		end

		local jsonFile = fileCreate("saves.json")
		if jsonFile then
			local jsonData = {}

			jsonData.lastWeaponSerial = tonumber(lastWeaponSerial or 0)
			jsonData.lastTicketSerial = tonumber(lastTicketSerial or 0)

			fileWrite(jsonFile, toJSON(jsonData, true, "tabs"))
			fileClose(jsonFile)
		end
	end
)

--[[addEventHandler("onPlayerDamage", root, 
	function(attacker, weapon) 
    	if weapon == 8 then  
        	killPed(source,attacker,weapon) 
			setElementData(source, "a.Protected", false)
    	end 
	end
)]]

addEventHandler("onElementDestroy", getRootElement(),
	function ()
		if itemsTable[source] then
			itemsTable[source] = nil
		end

		if inventoryInUse[source] then
			inventoryInUse[source] = nil
		end
	end)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "loggedIn" then
			if getElementData(source, dataName) then
				setTimer(triggerEvent, 1000, 1, "Ä\€Äđ&ä&&Ä", source)
			end
		end

		if dataName == "canisterInHand" then
			if getElementData(source, "canisterInHand") then
				playerItemObjects[source] = createObject(363, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					exports.a_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0, 0.025, -0.025, 0, 270, 180)
				end
			else
				if playerItemObjects[source] then
					exports.a_boneattach:detachElementFromBone(playerItemObjects[source])

					if isElement(playerItemObjects[source]) then
						destroyElement(playerItemObjects[source])
					end

					playerItemObjects[source] = nil
				end
			end
		elseif dataName == "usingGrinder" then
			if getElementData(source, "usingGrinder") then
				playerItemObjects[source] = createObject(1636, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					setElementInterior(playerItemObjects[source], getElementInterior(source))
					setElementDimension(playerItemObjects[source], getElementDimension(source))

					exports.a_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0, 0.05, 0.025, 0, 270, 90)
				end
			else
				if playerItemObjects[source] then
					exports.a_boneattach:detachElementFromBone(playerItemObjects[source])

					if isElement(playerItemObjects[source]) then
						destroyElement(playerItemObjects[source])
					end

					playerItemObjects[source] = nil
				end
			end
		elseif dataName == "fishingRodInHand" then
			if getElementData(source, "fishingRodInHand") then
				playerItemObjects[source] = createObject(2993, 0, 0, 0)

				if isElement(playerItemObjects[source]) then
					setElementInterior(playerItemObjects[source], getElementInterior(source))
					setElementDimension(playerItemObjects[source], getElementDimension(source))
					exports.a_boneattach:attachElementToBone(playerItemObjects[source], source, 12, 0.05, 0.05, 0.05, 0, -90, 0)
					setElementData(source, "attachedObject", playerItemObjects[source])
				end
			else
				if playerItemObjects[source] then
					if isElement(playerItemObjects[source]) then
						if getElementModel(playerItemObjects[source]) == 2993 then
							exports.a_boneattach:detachElementFromBone(playerItemObjects[source])
							destroyElement(playerItemObjects[source])
							playerItemObjects[source] = nil
							setElementData(source, "attachedObject", false)
						end
					end
				end
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if playerItemObjects[source] then
			exports.a_boneattach:detachElementFromBone(playerItemObjects[source])

			if isElement(playerItemObjects[source]) then
				destroyElement(playerItemObjects[source])
			end

			playerItemObjects[source] = nil
		end

		if trackingTimer[source] then
			if isTimer(trackingTimer[source]) then
				killTimer(trackingTimer[source])
			end

			trackingTimer[source] = nil
		end

		if itemsTable[source] then
			for k, v in pairs(itemsTable[source]) do
				if v.itemId == 361 then
					takeItem(source, "dbID", v.dbID, 1, "octansSeeMTA")
				end
			end
		end
	end)

addEvent("ä}€[[€ÄŁ", true)
addEventHandler("ä}€[[€ÄŁ", getRootElement(),
	function (casetteMoney)
		if isElement(source) and client and client == source then
			--if hasItem(source, 362) and hasItem(source, 34) and casetteMoney > 0 or casetteMoney < 200000 then
				--print(casetteMoney)
				local currentMoney = getElementData(source, "char.Money") or 0
				currentMoney = currentMoney + casetteMoney

				setElementData(source, "char.Money", currentMoney)
				setPedAnimation(source, false)
			--elseif casetteMoney < 0 or casetteMoney > 200000 then
				--print("cancel money")
			--else

				--exports.a_hud:showInfobox(source, "error", "Nincs nálad a pénzkazetta kinyitásához megfelelő tárgy!")
			--end
		end
	end
)

addCommandHandler("seeinv", 
    function(localPlayer, cmd, target)
        if getElementData(localPlayer, "adminLevel") >= 1 then
            if not (target) then
                outputChatBox("#3d7abc► alphaGames: #ffffff/" .. cmd .. " [ID/Név]", localPlayer, 0, 0, 0, true)
                return
            else
                target = exports.a_core:findPlayer(localPlayer, target)
                
                if target then
                    local playerName = getElementData(target, "a.PlayerName")
                    local charMoney = getElementData(target, "a.Money") or 0
                    triggerClientEvent(localPlayer, "bodySearchGetDatas", localPlayer, itemsTable[target] or {}, playerName, charMoney)
                 end
            end
        end
    end
)

local lastHealTick = 0
local spamTick = {}

function useItem(item, additional, additional2)
	if not source then
		source = client
	end

	if not isElement(source) then
		return
	end

	if not item or not item.dbID then
		return
	end

	local itemId = item.itemId

	if not hasItem(source, itemId) then 
		return --print(source, itemId)
	end

	if isElement(source) and client and client == source then 

		-- ** Nitró palack
		if itemId == 41 then
			if not isPlayerInVehicle(source) then
				return outputChatBox("#00aeef[Nitró]: #ffffffNem ülsz járműben!", source, 255, 255, 255, true)
			end

			if isPlayerInVehicle(source) then
				local vehicle = getPedOccupiedVehicle(source)
				setElementData(vehicle, "a.Nitro", 1)
				takeItem(source, "dbID", item.dbID, 1, "octansSeeMTA")
			end

			local vehicle = getPedOccupiedVehicle(source)

			if getElementData(vehicle, "a.Nitro") then
				return outputChatBox("#00aeef[Nitró]: #ffffffMár van nitró a járművedben!", source, 255, 255, 255, true)
			end
		elseif itemId == 42 then
			if spamTick[source] and getTickCount() - spamTick[source] < 3000 then 
				return outputChatBox("#D9B45A► alphaGames: #ffffffCsak 3 másodpercenként használhatod.", source, 255, 255, 255, true)
			end
				
			local random1 = math.random(1, 60)
			local chance = #mysteriousItemsTable/(#mysteriousItemsTable+random1) * 100
						
			local secondTable = {}

			chance = (100-chance)
			for i, v in ipairs(mysteriousItemsTable) do
				if math.floor(chance) <= v[3] then
					table.insert(secondTable, v)
				end
			end
						
			local random2 = math.random(1, #secondTable)
			local winnedItem = nil
			for i, v in ipairs(secondTable) do
				if i == random2 then
					winnedItem = v
				end
			end
				

			local winnedItemName = getItemName(winnedItem[1])			
				
			if getElementData(source, "adminLevel") <= 5 then
				if specialItemsTable[winnedItem[1]] then
					--print(specialItemsTable[winnedItem[1]])
					outputChatBox("#D9B45A► alphaGames: #5AB1D9".. getElementData(source, "a.PlayerName") .."#ffffff nyitott egy #D9B45A"..winnedItemName.."#ffffff tárgyat.", root, 255, 255, 255, true)
				else
					outputChatBox("#D9B45A► alphaGames: #5AB1D9".. getElementData(source, "a.PlayerName") .."#ffffff nyitott egy #5AB1D9"..winnedItemName.."#ffffff tárgyat.", root, 255, 255, 255, true)
				end
			end

			takeItem(source, "dbID", item.dbID, 1, "octansSeeMTA")
			giveItem(source, winnedItem[1], 1, false, false, false, false, "alphagames.net", false)
			spamTick[source] = getTickCount()
		end
	end
	triggerClientEvent(source, "movedItemInInv", source, true)
end
addEvent("|ÄÍÄŁäđĐŁ$Ł$~", true)
addEventHandler("|ÄÍÄŁäđĐŁ$Ł$~", getRootElement(), useItem)

function giveHealth(element, health)
	health = tonumber(health)

	if health then
		setElementHealth(element, math.min(100, getElementHealth(element) + health))
	end
end

addEvent("€đÄđÄ&ÍäŁÍÄ#113", true)
addEventHandler("€đÄđÄ&ÍäŁÍÄ#113", getRootElement(),
	function (currentItemInUse, currentItemUses)
		if isElement(source) and client and client == source then 
			if currentItemInUse then
				local itemId = currentItemInUse.itemId
				local specialItem = specialItems[itemId]

				if specialItem then
					if specialItem[1] == "pizza" or specialItem[1] == "kebab" or specialItem[1] == "hamburger" then
						triggerEvent("playAnimation", client, "food")
					elseif specialItem[1] == "beer" or specialItem[1] == "wine" or specialItem[1] == "drink" then
						triggerEvent("playAnimation", client, "drink")
					elseif specialItem[1] == "cigarette" then
						triggerEvent("playAnimation", client, "smoke")
					end

					local slotId = getItemSlotID(source, currentItemInUse.dbID)
					local amount = math.random(7, 20)

					if slotId then
						itemsTable[source][slotId].data1 = currentItemUses

					

						if specialItem[1] == "pizza" or specialItem[1] == "kebab" or specialItem[1] == "hamburger" then
							local currentHunger = getElementData(source, "char.Hunger") or 100

							if currentHunger + amount > 100 then
								setElementData(source, "char.Hunger", 100)
							else
								setElementData(source, "char.Hunger", currentHunger + amount)
							end
						elseif specialItem[1] == "beer" or specialItem[1] == "wine" or specialItem[1] == "drink" then
							local currentThirst = getElementData(source, "char.Thirst") or 100

							if currentThirst + amount > 100 then
								setElementData(source, "char.Thirst", 100)
							else
								setElementData(source, "char.Thirst", currentThirst + amount)
							end
						end

						dbExec(connection, "UPDATE items SET data1 = ? WHERE dbID = ?", currentItemUses, itemsTable[source][slotId].dbID)
					end
				end
			end
		end
	end)

addEvent("detachObject", true)
addEventHandler("detachObject", getRootElement(),
	function ()
		if isElement(source) and client and client == source then 
			if playerItemObjects[source] then
				exports.a_boneattach:detachElementFromBone(playerItemObjects[source])

				if isElement(playerItemObjects[source]) then
					destroyElement(playerItemObjects[source])
				end

				playerItemObjects[source] = nil
			end
		end
	end)

addEvent("playAnimation", true)
addEventHandler("playAnimation", getRootElement(),
	function (typ)
		if isElement(source) and client and client == source then 
			if typ then
				if typ == "food" then
					setPedAnimation(source, "FOOD", "eat_pizza", 4000, false, true, true, false)
				elseif typ == "drink" then
					setPedAnimation(source, "VENDING", "vend_drink2_p", 1200, false, true, true, false)
				elseif typ == "smoke" then
					setPedAnimation(source, "SMOKING", "M_smkstnd_loop", 4000, false, true, true, false)
				end
			end
		end
	end)

function bodySearchFunction(sourcePlayer, commandName, targetPlayer)
	if getElementData(sourcePlayer, "loggedIn") then
		if not targetPlayer then
			outputChatBox("#ff9900[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID]", sourcePlayer, 255, 255, 255, true)
		else
			targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				local px, py, pz = getElementPosition(sourcePlayer)
				local pint = getElementInterior(sourcePlayer)
				local pdim = getElementDimension(sourcePlayer)

				local tx, ty, tz = getElementPosition(targetPlayer)
				local tint = getElementInterior(targetPlayer)
				local tdim = getElementDimension(targetPlayer)
				local targetName = getElementData(targetPlayer, "a.PlayerName")

				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) <= 3 and pint == tint and pdim == tdim then
					triggerClientEvent(sourcePlayer, "bodySearchGetDatas",
						sourcePlayer,
						itemsTable[targetPlayer] or {},
						targetName:gsub("_", " "),
						getElementData(targetPlayer, "a.Money") or 0
					)
				else
					outputChatBox("#dc143c► alphaGames: #ffffffA kiválasztott játékos túl messze van tőled!", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end
end
addCommandHandler("frisk", bodySearchFunction)
addCommandHandler("motozas", bodySearchFunction)
--addCommandHandler("motozás", bodySearchFunction)

addEvent("ĐÄŁÄÄ&ä¸|äŁŁ}ĐÄ", true)
addEventHandler("ĐÄŁÄÄ&ä¸|äŁŁ}ĐÄ", getRootElement(),
	function (id)
		if isElement(source) and client and client == source then
			wallNotes[id] = nil
			triggerLatentClientEvent(getElementsByType("player"), "ĐÄŁÄÄ&ä¸|äŁŁ}ĐÄ", source, id)
		end
	end)

addEvent("|€|}|Đ|Ä|}|#äđĐäđ|ä#Ł#Ł#|", true)
addEventHandler("|€|}|Đ|Ä|}|#äđĐäđ|ä#Ł#Ł#|", getRootElement(),
	function (pixels, x, y, z, int, dim, nx, ny, itemId, title)
		if isElement(source) and client and client == source then
			if pixels and itemId then
				local characterId = getElementData(source, "a.accID")
				local placednotes = 0

				for k, v in pairs(wallNotes) do
					if v[2] == characterId then
						placednotes = placednotes + 1
					end
				end

				if placednotes >= 3 then
					exports.a_hud:showInfobox(source, "e", "Maximum 3 jegyzetet tűzhetsz ki egyszerre!")
				else
					local slot = getItemSlotID(source, itemId)

					if slot then
						local time = getRealTime().timestamp
						local id = 1

						for i = 1, #wallNotes + 1 do
							if not wallNotes[i] then
								id = i
								break
							end
						end

						wallNotes[id] = {pixels, characterId, false, x, y, z, int, dim, time + 60 * 60 * 3, nx, ny, title}

						triggerClientEvent(source, "deleteItem", source, "player", {itemsTable[source][slot].dbID})
						triggerClientEvent(source, "movedItemInInv", source, true)

						dbExec(connection, "DELETE FROM items WHERE dbID = ?", itemsTable[source][slot].dbID)

						itemsTable[source][slot] = nil

						triggerLatentClientEvent(getElementsByType("player"), "addWallNote", source, id, wallNotes[id])

						exports.a_hud:showInfobox(source, "s", "Sikeresen kitűzted! Várj egy kicsit, és megjelenik!")
					end
				end
			else
				exports.a_hud:showInfobox(source, "e", "A jegyzet kitűzése meghiúsult!")
			end
		end
	end)

addEvent("|ÄÍÄŁäđĐŁ$Ł$~$ä$Ł", true)
addEventHandler("|ÄÍÄŁäđĐŁ$Ł$~$ä$Ł", getRootElement(),
	function (item, nearby, nameTag)
		if isElement(source) and client and client == source then
			if type(item) == "table" and type(nearby) == "table" then
				triggerLatentClientEvent(nearby, "|ÄÍÄŁäđĐŁ$Ł$~$ä$Ł", source, item)
			end
		end
	end)

addEvent("@Đää]ÄÄ}}ä", true)
addEventHandler("@Đää]ÄÄ}}ä", getRootElement(),
	function (itemId, damage)
		if isElement(source) and client and client == source then
			itemId = tonumber(itemId)
			damage = tonumber(damage)

			if itemId and damage then
				local slot = getItemSlotID(source, itemId)

				if slot then
					itemsTable[source][slot].data1 = damage

					dbExec(connection, "UPDATE items SET data1 = ? WHERE dbID = ?", damage, itemsTable[source][slot].dbID)

					triggerClientEvent(source, "updateData1", source, "player", itemsTable[source][slot].dbID, damage)
				end
			end
		end
	end
)

addEvent("UpdateKeyItemData1", true)
addEventHandler("UpdateKeyItemData1", getRootElement(),
	function (itemId, Table)
		if isElement(source) and client and client == source then
			itemId = tonumber(itemId)

			if getElementData(source, "keyResponse") then 
				if itemId and Table then
					local slot = getItemSlotID(source, itemId)

					if slot then
						itemsTable[source][slot].data1 = toJSON(Table)

						setElementData(source, "keyResponse", false)

						dbExec(connection, "UPDATE items SET data1 = ? WHERE dbID = ?", toJSON(Table), itemsTable[source][slot].dbID)

						triggerClientEvent(source, "updateData1", source, "player", itemsTable[source][slot].dbID, toJSON(Table))
					end
				end
			end
		end
	end
)

addEvent("tryToRenameItem", true)
addEventHandler("tryToRenameItem", getRootElement(),
	function (text, renameItemId, nameTagItemId)
		if isElement(source) and client and client == source and text and renameItemId and nameTagItemId then
			local renameSlot = getItemSlotID(source, renameItemId)
			local nametagSlot = getItemSlotID(source, nameTagItemId)
			local success = 0

			if renameSlot then
				itemsTable[source][renameSlot].nameTag = text
				success = success + 1
			end

			if nametagSlot then
				itemsTable[source][nametagSlot] = nil
				success = success + 1
			end

			if success == 2 then
				dbExec(connection, "UPDATE items SET nameTag = ? WHERE dbID = ?", text, renameItemId)
				dbExec(connection, "DELETE FROM items WHERE dbID = ?", nameTagItemId)

				triggerClientEvent(source, "updateNameTag", source, renameItemId, text)
				triggerClientEvent(source, "deleteItem", source, "player", {nameTagItemId})
			else
				exports.a_hud:showInfobox(source, "e", "Az item átnevezése meghiúsult.")
			end
		end
	end)

addEvent("requestCrafting", true)
addEventHandler("requestCrafting", getRootElement(),
	function (selectedRecipe, takeItems, nearbyPlayers)
		if isElement(source) and source == client and client == source and selectedRecipe then
			if availableRecipes[selectedRecipe] and itemsTable[source] then
				local recipe = availableRecipes[selectedRecipe]
				local deletedItems = {}

				for i = 1, #takeItems do
					local id = takeItems[i]

					if not craftDoNotTakeItems[id] then
						for k, v in pairs(itemsTable[source]) do
							if v.itemId == id then
								table.insert(deletedItems, v.dbID)
								itemsTable[source][v.slot] = nil
								break
							end
						end
					end
				end

				if #deletedItems > 0 then
					triggerClientEvent(source, "deleteItem", source, "player", deletedItems)
					triggerClientEvent(source, "movedItemInInv", source, true)
					dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deletedItems, ",") .. ")")
				end

				triggerLatentClientEvent(source, "requestCrafting", source, selectedRecipe, true)

				if recipe.finalItem[3] and recipe.finalItem[4] then -- fegyverek craftolása random állapottal
					giveItem(source, recipe.finalItem[1], recipe.finalItem[2], false, math.random(recipe.finalItem[3], recipe.finalItem[4]), false, false, "alphagames.net")
					triggerLatentClientEvent(nearbyPlayers, "crafting3dSound", source, "hammer")
				else
					giveItem(source, recipe.finalItem[1], recipe.finalItem[2], false, false, false, false, "alphagames.net")
					--giveItem(source, recipe.finalItem[1], recipe.finalItem[2], 1, "alphagames.net")
					triggerLatentClientEvent(nearbyPlayers, "crafting3dSound", source, "crafting")
				end

				setElementFrozen(source, true)
				setPedAnimation(source, "GANGS", "prtial_gngtlkE", 10000, true, false, false, false)
				setTimer(
					function (sourcePlayer)
						if isElement(sourcePlayer) then
							setElementFrozen(sourcePlayer, false)
							setPedAnimation(sourcePlayer, false)
						end
					end,
				10000, 1, source)
			end
		end
	end)

addEvent("|Ää}|ÄÄä$$", true)
addEventHandler("|Ää}|ÄÄä$$", getRootElement(),
	function (nearby, itemId)
		if isElement(source) and client and client == source and itemId then
			itemId = tonumber(itemId)

			if itemId then
				local slot = getItemSlotID(source, itemId)
				local damage = math.random(5)

				if slot then
					local newAmount = (tonumber(itemsTable[source][slot].data1) or 0) + damage

					if newAmount >= 100 then
						takeAllWeapons(source)

						itemsTable[source][slot] = nil

						dbExec(connection, "DELETE FROM items WHERE dbID = ?", itemsTable[source][slot].dbID)

						triggerClientEvent(source, "unuseAmmo", source)
						triggerClientEvent(source, "deleteItem", source, "player", {itemsTable[source][slot].dbID})
						triggerClientEvent(source, "movedItemInInv", source)
					else
						itemsTable[source][slot].data1 = newAmount

						dbExec(connection, "UPDATE items SET data1 = ? WHERE dbID = ?", newAmount, itemsTable[source][slot].dbID)

						triggerClientEvent(source, "updateData1", source, "player", itemsTable[source][slot].dbID, newAmount)
					end
				end

				triggerLatentClientEvent(nearby, "weaponOverheatSound", source)
			end
		end
	end
)

addEvent("reloadPlayerWeapon", true)
addEventHandler("reloadPlayerWeapon", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			reloadPedWeapon(source)
		end
	end)

addEvent("takeWeapon", true)
addEventHandler("takeWeapon", getRootElement(),
	function ()
		if isElement(source) and client and client == source then
			takeAllWeapons(source)
			setElementData(source, "currentWeaponPaintjob", {})
		end
	end)

addEvent("]Í@Ä|Ää}}}", true)
addEventHandler("]Í@Ä|Ää}}}", getRootElement(),
	function (itemId, weaponId, ammo)
		if isElement(source) and client and client == source then
			
			takeAllWeapons(source)

			local ammo = 9999

			giveWeapon(source, weaponId, ammo, true)
			--reloadPedWeapon(source)
			--setPedAnimation(source, "COLT45", "sawnoff_reload", 500, false, false, false, false)
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
	end
)

addEvent("updateData2", true)
addEventHandler("updateData2", getRootElement(),
	function (element, itemId, newData)
		if itemsTable[element] then
			itemId = tonumber(itemId)

			if itemId and newData then
				local slot = getItemSlotID(element, itemId)

				if slot then
					itemsTable[element][slot].data2 = newData
					dbExec(connection, "UPDATE items SET data2 = ? WHERE dbID = ?", newData, itemsTable[element][slot].dbID)
				end
			end
		end
	end)

addEvent("updateData3", true)
addEventHandler("updateData3", getRootElement(),
	function (element, itemId, newData)
		if itemsTable[element] then
			itemId = tonumber(itemId)

			if itemId and newData then
				local slot = getItemSlotID(element, itemId)

				if slot then
					itemsTable[element][slot].data3 = newData
					dbExec(connection, "UPDATE items SET data3 = ? WHERE dbID = ?", newData, itemsTable[element][slot].dbID)
				end
			end
		end
	end)

--addEvent("ticketPerishableEvent", true)
--addEventHandler("ticketPerishableEvent", getRootElement(),
	--function (itemId)
		--if itemsTable[source] then
		--	itemId = tonumber(itemId)

		--	if itemId then
		--		outputDebugString("ticketPerishableEvent")
		--		-- #d75959► alphaGames: #ffffffMivel nem fizetted be a csekket, ezért automatikusan le lett vonva a büntetés 110%-a. (x$)
		--	end
		--end
	--end)

addEvent("[ÍđÄÍđä{ŁÄ@@", true)
addEventHandler("[ÍđÄÍđä{ŁÄ@@", getRootElement(),
	function (itemId)
		if isElement(source) and client and client == source then 
			if itemsTable[source] then
				itemId = tonumber(itemId)

				if itemId then
					local ownerType = getElementType(source)
					local slot = getItemSlotID(source, itemId)

					if slot then
						itemsTable[source][slot].itemId = 219

						dbExec(connection, "UPDATE items SET itemId = 219 WHERE dbID = ?", itemsTable[source][slot].dbID)

						if ownerType == "player" then
							triggerClientEvent(source, "updateItemID", source, "player", itemsTable[source][slot].dbID, 219)
							triggerClientEvent(source, "movedItemInInv", source, true)
						end
					end
				end
			end
		end
	end
)

function processPerishableItems()
	for element in pairs(itemsTable) do
		if isElement(element) then
			local elementType = getElementType(element)

			if elementType == "vehicle" or elementType == "object" then
				for k, v in pairs(itemsTable[element]) do
					local itemId = v.itemId

					if perishableItems[itemId] then
						local value = (tonumber(v.data3) or 0) + 1

						if value - 1 > perishableItems[itemId] then
							triggerEvent("updateData3", element, element, v.dbID, perishableItems[itemId])
						end

						if value <= perishableItems[itemId] then
							triggerEvent("updateData3", element, element, v.dbID, value)
						elseif perishableEvent[itemId] then
							triggerEvent(perishableEvent[itemId], element, v.dbID)
						end
					end
				end
			end
		else
			itemsTable[element] = nil
		end
	end

	-- for k, v in pairs(worldItems) do
	-- 	local itemId = v.itemId

	-- 	if perishableItems[v.itemId] then
	-- 		local value = (tonumber(v.data3) or 0) + 1

	-- 		if value - 1 > perishableItems[itemId] then
	-- 			v.data3 = perishableItems[itemId]
	-- 			dbExec(connection, "UPDATE items SET data3 = ? WHERE dbID = ?", v.data3, v.dbID)
	-- 		end

	-- 		if value <= perishableItems[itemId] then
	-- 			v.data3 = value
	-- 			dbExec(connection, "UPDATE items SET data3 = ? WHERE dbID = ?", v.data3, v.dbID)
	-- 		end
	-- 	end
	-- end
end

addCommandHandler("giveitem",
	function (sourcePlayer, commandName, targetPlayer, itemId, amount, data1, data2, data3)
		if getElementData(sourcePlayer, "adminLevel") >= 6 then
			itemId = tonumber(itemId)
			amount = tonumber(amount) or 1

			--[[if getElementData(sourcePlayer, "adminLevel") <= 7 and itemId == 42 or itemId == 41 then
				return outputChatBox("#DC143C► alphaGames: #ffffffEzt az itemet nem kérheted le!", sourcePlayer, 255, 255, 255, true)
			end]]

			if not targetPlayer or not itemId or not amount then
				outputChatBox("[Használat]: #ffffff/" .. commandName .. " [Játékos Név / ID] [Item ID] [Mennyiség] [ < Data 1 | Data 2 | Data 3 > ]", sourcePlayer, 255, 150, 0, true)
			else
				targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

				if targetPlayer then
					local state = giveItem(targetPlayer, itemId, amount, false, data1, data2, data3, "alphagames.net", false)

					--print(state)
					local playerName = getElementData(sourcePlayer, "a.PlayerName")
					local targetName = getElementData(targetPlayer, "a.PlayerName")

					if state then
						outputChatBox("#DC143C► alphaGames: #ffffffA kiválasztott tárgy sikeresen odaadásra került.", sourcePlayer, 0, 0, 0, true)
						exports.a_logs:createDCLog("**"..playerName.. "** addolt egy tárgyat **"..targetName.."**-nak/nek Item: " ..getItemName(itemId).." ("..itemId..") | Darab: **"..amount.."**", 1)
					else
						outputChatBox("#DC143C► alphaGames: #ffffffA kiválasztott tárgy odaadása meghiúsult.", sourcePlayer, 0, 0, 0, true)
					end
				end
			end
		end
	end)

local blackjackRewards = {
	-- esély, nyeremény
	{100, 5},
	{85, 10},
	{75, 15},
	{65, 25},
	{55, 50},
	{45, 75},
	{25, 100000},
	{5, 200000},
	{1, 1000000}
}

function generateBlackjack(serial)
	local winnerNumber = math.random(1, 21)
	local numberChance = math.random(1, 100) / 100

	if numberChance < 0.1 then
		numberChance = 0.1
	end

	local numsKeyed = {}
	local numbers = {}

	for i = 1, 4 do
		local num = math.ceil(math.random(1, 21) * numberChance)
		numsKeyed[num] = i
		numbers[i] = num
	end

	local rewardChance = 100 - math.ceil(math.random(0, 100) * (winnerNumber / 21))
	local availableRewards = {}

	for i = 1, #blackjackRewards do
		local rewardDetails = blackjackRewards[i]

		if rewardDetails[1] >= rewardChance then
			table.insert(availableRewards, rewardDetails)
		end
	end

	table.sort(availableRewards,
		function (a, b)
			return a[1] < b[1]
		end
	)

	local prize = availableRewards[math.ceil(math.random(1, #availableRewards) * 0.375)]

	if not prize then
		prize = blackjackRewards[1]
	end

	local win = false

	for i = 1, 4 do
		if numbers[i] > winnerNumber then
			win = true
			break
		end
	end

	return toJSON({win, winnerNumber, numbers[1], numbers[2], numbers[3], numbers[4], prize[2], serial}, true)
end

local moneyManiaRewards = {
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	10, 10, 10, 10, 10, 10, 10,
	15, 15, 15, 15, 15, 15,
	25, 25, 25, 25, 25,
	50, 50, 50, 50,
	1000, 1000, 1000,
	5000, 5000,
	10000
}

function generateMoneyMania(serial)
	local availableSymbols = {"bank", "card", "dollar"}
	local symbols = {}

	for column = 1, 3 do
		symbols[column] = {}

		for row = 1, 3 do
			symbols[column][row] = availableSymbols[math.random(1, #availableSymbols)]
		end
	end

	local prizes = {}
	local winnerColumns = {}

	for column = 1, 3 do
		prizes[column] = moneyManiaRewards[math.ceil(math.random(1, #moneyManiaRewards) * math.random())]

		if symbols[column][1] == symbols[column][2] and symbols[column][2] == symbols[column][3] then
			winnerColumns[column] = true
		end
	end

	return toJSON({symbols, prizes, winnerColumns, serial}, true)
end

local piggyRewards = {
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	10, 10, 10, 10, 10, 10, 10,
	15, 15, 15, 15, 15, 15,
	25, 25, 25, 25, 25,
	50, 50, 50, 50,
	1000, 1000, 1000,
	5000, 5000,
	10000
}

function generateFortunePiggy(serial)
	local prizes = {}
	local counter = {}

	for column = 1, 2 do
		prizes[column] = {}

		for row = 1, 3 do
			local prize = piggyRewards[math.ceil(math.random(1, #piggyRewards) * math.random())]

			prizes[column][row] = prize

			if not counter[prize] then
				counter[prize] = 0
			end

			counter[prize] = counter[prize] + 1
		end
	end

	local reward = 0
	local highest = 0
	local luck = false

	for prize, count in pairs(counter) do
		if count >= 3 and count > highest then
			highest = count
			reward = prize
		end
	end

	if math.random() < 0.25 then
		luck = math.random(1, 3)
	end

	return toJSON({prizes, reward, luck, serial}, true)
end

local moneyLiftRewards = {
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	10, 10, 10, 10, 10, 10, 10,
	15, 15, 15, 15, 15, 15,
	25, 25, 25, 25, 25,
	50, 50, 50, 50,
	1000, 1000, 1000,
	5000, 5000,
	10000
}

function generateMoneyLift(serial)
	local symbols = {}
	local prizes = {}

	for x = 1, 6 do
		symbols[x] = {}
		prizes[x] = moneyLiftRewards[math.ceil(math.random(1, #moneyLiftRewards) * math.random())]

		for y = 1, 5 do
			symbols[x][y] = "arrow"
		end

		if math.random() < 0.85 then
			symbols[x][math.random(1, 5)] = "stop"
		end
	end

	local counter = {}
	local reward = 0

	for x = 1, 6 do
		counter[x] = 0

		for y = 1, 5 do
			if symbols[x][y] == "arrow" then
				counter[x] = counter[x] + 1
			end
		end

		if counter[x] == 5 then
			reward = reward + prizes[x]
		end
	end

	return toJSON({symbols, prizes, reward, serial}, true)
end

function giveItem(element, itemId, amount, slotId, data1, data2, data3, code, nameTag)
	iprint(element, itemId, amount, slotId, data1, data2, data3, code)
	if code ~= "alphagames.net" and client then 
		return print("hibas kod")
	end
	if isElement(element) then
		--iprint(element)
		local ownerType = getElementType(element)
		local ownerId = false 
		if ownerType == "player" then
			ownerId = getElementData(element, defaultSettings.characterId)
		elseif ownerType == "vehicle" then
			ownerId = getElementData(element, defaultSettings.vehicleId)
		elseif ownerType == "object" then
			ownerId = getElementData(element, defaultSettings.objectId)
		end


		if ownerId then
			if not itemsTable[element] then
				itemsTable[element] = {}
			end

			if not nameTag then
				nameTag = nil
			end

			if not slotId then
				slotId = findEmptySlot(element, ownerType, itemId)
			elseif tonumber(slotId) then
				if itemsTable[element][slotId] then
					slotId = findEmptySlot(element, ownerType, itemId)
				end
			end

			if tonumber(slotId) then
				local serial = false

				if serialItems[itemId] then
					serial = lastWeaponSerial + 1
					lastWeaponSerial = serial
				end

				if itemId == 361 then -- Pénzkazetta
					if isElement(sourceResource) and getResourceName(sourceResource) == "a_bank" then
						if ownerType == "player" then
							local moneyCasettes = getElementData(resourceRoot, "moneyCasettes") or {}

							moneyCasettes[element] = true

							if isTimer(trackingTimer[element]) then
								killTimer(trackingTimer[element])
							end

							trackingTimer[element] = setTimer(
								function (sourcePlayer)
									local moneyCasettes = getElementData(resourceRoot, "moneyCasettes") or {}

									if moneyCasettes[sourcePlayer] then
										moneyCasettes[sourcePlayer] = nil

										setElementData(resourceRoot, "moneyCasettes", moneyCasettes)
									end

									trackingTimer[sourcePlayer] = nil
								end,
							1000 * 60 * 8, 1, element)

							setElementData(resourceRoot, "moneyCasettes", moneyCasettes)
						end
					end
				end

				itemsTable[element][slotId] = {}
				itemsTable[element][slotId].locked = true

				dbQuery(
					function (query)
						local result, rows, dbID = dbPoll(query, 0)

						if itemsTable[element][slotId] and itemsTable[element][slotId].locked then
							itemsTable[element][slotId] = nil
						end

						if result and dbID then
							addItem(element, dbID, slotId, itemId, amount, data1, data2, data3, nameTag, serial)

							if ownerType == "player" then
								triggerClientEvent(element, "$$$$$$$$$$$$$$$", element, ownerType, itemsTable[element][slotId])
								triggerClientEvent(element, "movedItemInInv", element)
							end
						end
					end,
				connection, "INSERT INTO items (itemId, slot, amount, data1, data2, data3, serial, ownerType, ownerId, nameTag) VALUES (?,?,?,?,?,?,?,?,?,?)", itemId, slotId, amount, data1, data2, data3, serial, ownerType, ownerId, nameTag)

				return true
			end
		end
	end

	return false
end
addEvent("$$$$$$$$$$$$$$$", true)
addEventHandler("$$$$$$$$$$$$$$$", getRootElement(), giveItem)


function takeItem(element, dataType, dataValue, amount, code)
	--iprint(element, dataType, dataValue, amount, code)
	if code ~= "octansSeeMTA" and client then 
		return iprint(element)
	end
	if not isElement(element) then
		return false
	end

	if not itemsTable[element] then
		return false
	end

	local ownerType = getElementType(element)
	local ownerId = false

	if ownerType == "player" then
		ownerId = getElementData(element, defaultSettings.characterId)
	elseif ownerType == "vehicle" then
		ownerId = getElementData(element, defaultSettings.vehicleId)
	elseif ownerType == "object" then
		ownerId = getElementData(element, defaultSettings.objectId)
	end

	if not ownerId then
		return false
	end

	local deleted = {}

	for k, v in pairs(itemsTable[element]) do
		if v[dataType] and v[dataType] == dataValue then
			-- item mennyiség módosítás
			if amount and v.amount - amount > 0 then
				v.amount = v.amount - amount

				if ownerType == "player" then
					triggerClientEvent(element, "updateAmount", element, ownerType, v.dbID, v.amount)
				end

				dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", v.amount, v.dbID)
			-- item törlés
			else
				table.insert(deleted, v.dbID)
				itemsTable[element][v.slot] = nil
			end
		end
	end

	if #deleted > 0 then
		if ownerType == "player" then
			triggerClientEvent(element, "deleteItem", element, ownerType, deleted)
			triggerClientEvent(element, "movedItemInInv", element)
		end

		dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deleted, ",") .. ")")
	end
end
addEvent("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", true)
addEventHandler("äłÄÍÄ<đ\|Ä\|ÄäđĐ$äđĐ", getRootElement(), takeItem)

function clearItems(element)
	if isElement(element) then
		local ownerType = getElementType(element)
		local ownerId = false

		if ownerType == "player" then
			ownerId = tonumber(getElementData(element, defaultSettings.characterId))
		elseif ownerType == "vehicle" then
			ownerId = tonumber(getElementData(element, defaultSettings.vehicleId))
		elseif ownerType == "object" then
			ownerId = tonumber(getElementData(element, defaultSettings.objectId))
		end

		itemsTable[element] = nil

		if isElement(inventoryInUse[element]) then
			triggerClientEvent(inventoryInUse[element], "loadItems", inventoryInUse[element], {}, ownerType, element, true)
		end

		dbExec(connection, "DELETE FROM items WHERE ownerType = ? AND ownerId = ?", ownerType, ownerId)
	end
end

function takeItemWithData(element, itemId, dataValue, dataType)
	if isElement(element) then
		if itemsTable[element] then
			itemId = tonumber(itemId)
			dataType = dataType or "data1"

			if itemId and dataValue and dataType then
				local ownerType = getElementType(element)
				local ownerId = false

				if ownerType == "player" then
					ownerId = tonumber(getElementData(element, defaultSettings.characterId))
				elseif ownerType == "vehicle" then
					ownerId = tonumber(getElementData(element, defaultSettings.vehicleId))
				elseif ownerType == "object" then
					ownerId = tonumber(getElementData(element, defaultSettings.objectId))
				end

				if ownerId then
					local deleted = {}

					for k, v in pairs(itemsTable[element]) do
						if v[dataType] and v[dataType] == dataValue then
							table.insert(deleted, v.dbID)
							itemsTable[element][v.slot] = nil
						end
					end

					if #deleted > 0 then
						if ownerType == "player" then
							triggerClientEvent(element, "deleteItem", element, ownerType, deleted)
							triggerClientEvent(element, "movedItemInInv", element)
						end

						dbExec(connection, "DELETE FROM items WHERE dbID IN (" .. table.concat(deleted, ",") .. ")")
					end
				end
			end
		end
	end
end

function getElementItems(element)
	if isElement(element) then
		if itemsTable[element] then
			return itemsTable[element]
		end
	end

	return {}
end

addEvent("äÄłÄÍÄäÍ€}[;~ˇ^", true)
addEventHandler("äÄłÄÍÄäÍ€}[;~ˇ^", getRootElement(),
	function (itemId, amount)
		if isElement(source) and itemsTable[source] then
			local ownerType = getElementType(source)
			local ownerId = false

			if ownerType == "player" then
				ownerId = getElementData(source, defaultSettings.characterId)
			elseif ownerType == "vehicle" then
				ownerId = getElementData(source, defaultSettings.vehicleId)
			elseif ownerType == "object" then
				ownerId = getElementData(source, defaultSettings.objectId)
			end

			if ownerId then
				local slot = getItemSlotID(source, itemId)

				if slot then
					local newAmount = itemsTable[source][slot].amount - amount

					itemsTable[source][slot].amount = newAmount

					dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", newAmount, itemsTable[source][slot].dbID)
				end
			end
		end
	end)

function addItem(element, dbID, slotId, itemId, amount, data1, data2, data3, nameTag, serial)
	if dbID and slotId and itemId and amount then
		itemsTable[element][slotId] = {}
		itemsTable[element][slotId].dbID = dbID
		itemsTable[element][slotId].slot = slotId
		itemsTable[element][slotId].itemId = itemId
		itemsTable[element][slotId].amount = amount
		itemsTable[element][slotId].data1 = data1
		itemsTable[element][slotId].data2 = data2
		itemsTable[element][slotId].data3 = data3
		itemsTable[element][slotId].inUse = false
		itemsTable[element][slotId].locked = false
		itemsTable[element][slotId].nameTag = nameTag
		itemsTable[element][slotId].serial = serial
	end
end

--***Updated For keychain***--
function hasItemWithData(element, itemId, data, dataType)
	if itemsTable[element] then
		data = tonumber(data) or data
		dataType = dataType or "data1"

		for k, v in pairs(itemsTable[element]) do
			if v.itemId == 318 then
				if v and v.data1 and fromJSON(v.data1) then
					for Key, Value in pairs(fromJSON(v.data1)) do
						if Value and Value.itemId == itemId and (tonumber(Value[dataType]) or Value[dataType]) == data then
							return Value
						end
					end
				end
			elseif v.itemId == itemId and (tonumber(v[dataType]) or v[dataType]) == data then
				return v
			end
		end
	end

	return false
end
--***Updated For keychain***--

function hasItem(element, itemId, amount)
	if itemsTable[element] then
		for k, v in pairs(itemsTable[element]) do
			if v.itemId == itemId and (not amount or v.amount == amount) then
				return v
			end
		end
	end

	return false
end

function getItemSlotID(element, itemDbID)
	if itemsTable[element] then
		for k, v in pairs(itemsTable[element]) do
			if v.dbID == itemDbID then
				return v.slot
			end
		end
	end

	return false
end

function getItemsCount(element)
	local items = 0

	if itemsTable[element] then
		for k, v in pairs(itemsTable[element]) do
			items = items + 1
		end
	end

	return items
end

function getCurrentWeight(element)
	local weight = 0

	if itemsTable[element] then
		for k, v in pairs(itemsTable[element]) do
			weight = weight + getItemWeight(v.itemId) * v.amount
		end
	end

	return weight
end

function getFreeSlotCount(element, itemId)
	if itemsTable[element] then
		local elementType = getElementType(element)
		local emptyslot = 0

		if elementType == "player" and itemId then
			if isKeyItem(itemId) then
				for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
					if not itemsTable[element][i] then
						emptyslot = emptyslot + 1
					end
				end
			elseif isPaperItem(itemId) then
				for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
					if not itemsTable[element][i] then
						emptyslot = emptyslot + 1
					end
				end
			else
				for i = 0, defaultSettings.slotLimit - 1 do
					if not itemsTable[element][i] then
						emptyslot = emptyslot + 1
					end
				end
			end
		else
			for i = 0, defaultSettings.slotLimit - 1 do
				if not itemsTable[element][i] then
					emptyslot = emptyslot + 1
				end
			end
		end

		return emptyslot
	end

	return 0
end

addEvent("receiveTrade", true)
addEventHandler("receiveTrade", getRootElement(),
	function (dbID, itemId)
		if isElement(client) and client and client == source then
			if itemId then
				local itemPrice = itemsTablePrice[itemId]
				--if itemPrice then
					triggerClientEvent(source, "createDeal", resourceRoot, dbID, itemId, itemPrice or 0)
				--end
			else
				return
			end
		end
	end 
)

addEvent("acceptTrade", true)
addEventHandler("acceptTrade", getRootElement(),
	function (dbID, itemId)
		if isElement(source) and client and client == source then
			if dbID and itemId then
				if hasItem(source, itemId) then
					takeItem(source, "dbID", dbID, 1, "octansSeeMTA")

					local money = (getElementData(source, "a.Money") or 0)

					--iprint(itemsTablePrice[itemId])
					playerName = getElementData(source, "a.PlayerName")
					playerSerial = getPlayerSerial(source)
					playerAccId = getElementData(source, "a.accID")
					playerIp = getPlayerIP(source)

					if not itemsTablePrice[itemId] then 
						outputChatBox("#E18C88► alphaGames: #ffffffEnnek az itemnek nem volt értéke, ezért nem kaptál érte pénzt.", source, 255, 255, 255, true)
						exports.a_logs:createDCLog("\n**"..playerName.. "** eladott egy tárgyat. \nItem: " .. getItemName(itemId).. "\nItem ID: "..itemId.."\nItem dbID: ("..dbID..")\nSerial: "..playerSerial.."\nAccount ID: "..playerAccId, 10)
					else
						setElementData(source, "a.Money", money + itemsTablePrice[itemId] or 0)
						outputChatBox("#E18C88► alphaGames: #ffffffSikeresen eladtál egy #7cc576"..getItemName(itemId).."#ffffff-t. Kaptál érte: #7cc576"..itemsTablePrice[itemId].."$#ffffff-t.", source, 255, 255, 255, true)
						exports.a_logs:createDCLog("\n**"..playerName.. "** eladott egy tárgyat. \nItem: " .. getItemName(itemId).. "\nItem ID: "..itemId.."\nItem dbID: ("..dbID..")\nSerial: "..playerSerial.."\nAccount ID: "..playerAccId, 10)
					end
				else 
					return
					-- ** GERINCTELENSÉG. kikommentelve dzseki által ekkor: 2023. 08. 23. - 22:06


					--[[playerName = getElementData(source, "a.PlayerName")
					playerSerial = getPlayerSerial(source)
					playerAccId = getElementData(source, "a.accID")
					playerIp = getPlayerIP(source)]]--

					--outputChatBox("halo hat ez nem jot osze pajti :)))) mivel nics " .. getItemName(itemId).. " ("..itemId..") itemed!", source)
					--exports.a_logs:createDCLog("\n@everyone\n"..playerName.. " megpróbált bugoltatni. \nItem: " .. getItemName(itemId).. " ("..itemId..")\nSerial: "..playerSerial.."\nAccount ID: "..playerAccId.."\nIP Address: "..playerIp, 10)
				end
			end
		end
	end
)

addEvent("@ÄÍÄđđäŁđĐŁ|", true)
addEventHandler("@ÄÍÄđđäŁđĐŁ|", getRootElement(),
	function (dbID, itemId, movedSlotId, hoverSlotId, stackAmount, ownerElement, targetElement)
		print(itemId)

		if not isElement(source) or not isElement(ownerElement) or not isElement(targetElement) then
			return
		end

		dbID = tonumber(dbID)

		if not dbID then
			return
		end

		local ownerType = getElementType(ownerElement)
		local ownerId = false

		if ownerType == "player" then
			ownerId = getElementData(ownerElement, defaultSettings.characterId)
		elseif ownerType == "vehicle" then
			ownerId = getElementData(ownerElement, defaultSettings.vehicleId)
		elseif ownerType == "object" then
			ownerId = getElementData(ownerElement, defaultSettings.objectId)
		end

		if ownerElement == targetElement then
			local movedItem = itemsTable[ownerElement][movedSlotId]

			if not movedItem or dbID ~= movedItem.dbID then
				return
			end

			if itemsTable[ownerElement][hoverSlotId] then
				if itemsTable[ownerElement][hoverSlotId].locked then
					outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFEz a slot zárolva van! Kérlek várj egy kicsit.", source, 255, 255, 255, true)
				else
					outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFA kiválasztott slot foglalt.", source, 255, 255, 255, true)
				end

				triggerClientEvent(source, "failedToMoveItem", source, movedSlotId, hoverSlotId, stackAmount)
				return
			end

			-- mozgatás
			if stackAmount >= movedItem.amount or stackAmount <= 0 then
				if ownerElement == source and targetElement == source then
					triggerClientEvent(source, "movedItemInInv", source, true)
				end

				itemsTable[ownerElement][hoverSlotId] = itemsTable[ownerElement][movedSlotId]
				itemsTable[ownerElement][hoverSlotId].slot = hoverSlotId
				itemsTable[ownerElement][movedSlotId] = nil

				dbExec(connection, "UPDATE items SET ownerType = ?, ownerId = ?, slot = ? WHERE dbID = ?", ownerType, ownerId, hoverSlotId, dbID)
			-- stackelés
			elseif stackAmount > 0 then
				movedItem.amount = movedItem.amount - stackAmount

				giveItem(ownerElement, itemId, stackAmount, hoverSlotId, movedItem.data1, movedItem.data2, movedItem.data3, "alphagames.net")

				dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", movedItem.amount, dbID)
				src = source
				setTimer(function()
					triggerClientEvent(src, "loadItems", src, itemsTable[ownerElement], "vehicle", ownerElement, false)
				end, 150, 1)
			end

			return
		end

		-- átmozgatás egy másik inventoryba
		local targetType = getElementType(targetElement)
		local targetId = false

		if targetType == "player" then
			targetId = getElementData(targetElement, defaultSettings.characterId)
		elseif targetType == "vehicle" then
			targetId = getElementData(targetElement, defaultSettings.vehicleId)
		elseif targetType == "object" then
			targetId = getElementData(targetElement, defaultSettings.objectId)
		end

		if targetType == "vehicle" then
			if isVehicleLocked(targetElement) then
				outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFA kiválasztott jármű csomagtartója zárva van.", source, 255, 255, 255, true)
				triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
				return
			end
		end

		local movedItem = itemsTable[ownerElement][movedSlotId]

		if not movedItem or dbID ~= movedItem.dbID then
			triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
			return
		end

		if isElement(inventoryInUse[targetElement]) then
			outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFNem rakhatsz tárgyat az inventoryba amíg azt valaki más használja!", source, 255, 255, 255, true)
			triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
			return
		end

		if targetType == "object" then
			if storedSafes[targetId] then
				if storedSafes[targetId].ownerGroup > 0 then
					if not exports.a_groups:isPlayerInGroup(source, storedSafes[targetId].ownerGroup) then
						outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFA kiválasztott széfhez nincs kulcsod.", source, 255, 255, 255, true)
						triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
						return
					end
				elseif not hasItemWithData(source, 154, targetId) then
					outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFA kiválasztott széfhez nincs kulcsod.", source, 255, 255, 255, true)
					triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
					return
				end
			end
		end

		if targetType ~= "player" then
			if itemId == 361 then -- Pénzkazetta
				outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFEzt az itemet csak más játékosnak adhatod át!", source, 255, 255, 255, true)
				triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
				return
			end
		end

		if not itemsTable[targetElement] then
			itemsTable[targetElement] = {}
		end

		hoverSlotId = findEmptySlot(targetElement, targetType, itemId)

		if not hoverSlotId then
			outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFNincs szabad slot a kiválasztott inventoryban!", source, 255, 255, 255, true)
			triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
			return
		end

		local statement = false

		if stackAmount >= movedItem.amount or stackAmount <= 0 then
			statement = "move"
			stackAmount = movedItem.amount
		elseif stackAmount > 0 then
			statement = "stack"
		end

		--if getCurrentWeight(targetElement) + getItemWeight(itemId) * stackAmount > getWeightLimit(targetType, targetElement) then
		----	outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFA kiválasztott inventory nem bírja el ezt a tárgyat!", source, 255, 255, 255, true)
		--	triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)
		--	return false
		--end

		if statement == "move" then
			itemsTable[targetElement][hoverSlotId] = itemsTable[ownerElement][movedSlotId]
			itemsTable[targetElement][hoverSlotId].slot = hoverSlotId
			itemsTable[ownerElement][movedSlotId] = nil

			triggerItemEvent(targetElement, "$$$$$$$$$$$$$$$", targetType, itemsTable[targetElement][hoverSlotId])
			triggerItemEvent(ownerElement, "deleteItem", ownerType, {dbID})

			dbExec(connection, "UPDATE items SET ownerType = ?, ownerId = ?, slot = ? WHERE dbID = ?", targetType, targetId, hoverSlotId, dbID)
		end

		if statement == "stack" then
			movedItem.amount = movedItem.amount - stackAmount

			giveItem(targetElement, itemId, stackAmount, hoverSlotId, movedItem.data1, movedItem.data2, movedItem.data3, "alphagames.net")
			triggerItemEvent(ownerElement, "updateAmount", ownerType, dbID, movedItem.amount)

			dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", movedItem.amount, dbID)
		end

		triggerClientEvent(source, "unLockItem", source, ownerType, movedSlotId)

		--exports.a_logs:logCommand(source, eventName, {dbID, itemId, stackAmount, ownerType, ownerId, targetType, targetId})

		local itemName = ""

		if availableItems[itemId] then
			itemName = getItemName(itemId)
			if itemsTable[targetElement] and itemsTable[targetElement][hoverSlotId] then
				if itemsTable[targetElement][hoverSlotId].nameTag then
					itemName = " (" .. itemName .. " (" .. itemsTable[targetElement][hoverSlotId].nameTag .. "))"
				else
					itemName = " (" .. itemName .. ")"
				end
			end
		end

		if ownerType == "player" and targetType == "player" then
			--exports.a_chat:localAction(ownerElement, "átadott egy tárgyat " .. getElementData(targetElement, "visibleName"):gsub("_", " ") .. "-nak/nek." .. itemName)
			local targetName = getElementData(targetElement, "a.PlayerName")
			local ownerName = getElementData(ownerElement, "a.PlayerName")
			outputChatBox("#00aeef[Inventory]: #ffffffAdtál "..stackAmount.."db#d75959"..itemName.."#ffffff tárgyat #d75959"..targetName.."#ffffff játékosnak.", ownerElement, 255, 255, 255, true)
			outputChatBox("#00aeef[Inventory]: #ffffffKaptál "..stackAmount.."db#d75959"..itemName.."#ffffff tárgyat #d75959"..ownerName.."#ffffff játékostól.", targetElement, 255, 255, 255, true)

			exports.a_logs:createDCLog("**"..ownerName.."** átadott **"..stackAmount.."db"..itemName.."** ItemID: **("..itemId..")** Item dbID: **("..dbID..")** tárgyat **"..targetName.."** játékosnak.", 9)

			setPedAnimation(ownerElement, "DEALER", "DEALER_DEAL", -1, false, false, false, false)
			setPedAnimation(targetElement, "DEALER", "DEALER_DEAL", -1, false, false, false, false)
			return
		end
		setElementData(source, "movedItemID", false)
	end
)

addEvent("đä&łÍ€Äđ", true)
addEventHandler("đä&łÍ€Äđ", getRootElement(),
	function (ownerElement, movedItemId, hoverItemId, stackAmount)
		if isElement(source) then
			if itemsTable[ownerElement] then
				local ownerType = getElementType(ownerElement)

				for k, v in pairs(itemsTable[ownerElement]) do
					if v.dbID == hoverItemId then
						v.amount = v.amount + stackAmount

						triggerItemEvent(source, "updateAmount", ownerType, v.dbID, v.amount)

						dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", v.amount, v.dbID)
					end

					if v.dbID == movedItemId then
						if v.amount - stackAmount > 0 then
							v.amount = v.amount - stackAmount

							triggerItemEvent(source, "updateAmount", ownerType, v.dbID, v.amount)

							dbExec(connection, "UPDATE items SET amount = ? WHERE dbID = ?", v.amount, v.dbID)
						else
							triggerItemEvent(source, "deleteItem", ownerType, {v.dbID})

							dbExec(connection, "DELETE FROM items WHERE dbID = ?", v.dbID)

							itemsTable[ownerElement][v.slot] = nil
						end
					end
				end
			end
		end
	end)

function triggerItemEvent(element, event, ...)
	local sourcePlayer = element

	if getElementType(element) == "player" then
		triggerClientEvent(element, event, element, ...)
	else
		if isElement(inventoryInUse[element]) then
			triggerClientEvent(inventoryInUse[element], event, inventoryInUse[element], ...)
			sourcePlayer = inventoryInUse[element]
		end
	end

	if event == "$$$$$$$$$$$$$$$" or event == "deleteItem" or event == "updateAmount" then
		if isElement(sourcePlayer) and getElementType(element) == "player" then
			triggerClientEvent(sourcePlayer, "movedItemInInv", sourcePlayer, event == "updateAmount")
		end
	end
end

function hasSpaceForItem(element, itemId, amount)
	if itemsTable[element] then
		local elementType = getElementType(element)
		local emptyslot = 0

		amount = amount or 1

		if elementType == "player" and isKeyItem(itemId) then
			for i = defaultSettings.slotLimit, defaultSettings.slotLimit * 2 - 1 do
				if not itemsTable[element][i] then
					emptyslot = emptyslot + 1
				end
			end
		elseif elementType == "player" and isPaperItem(itemId) then
			for i = defaultSettings.slotLimit * 2, defaultSettings.slotLimit * 3 - 1 do
				if not itemsTable[element][i] then
					emptyslot = emptyslot + 1
				end
			end
		else
			for i = 0, defaultSettings.slotLimit - 1 do
				if not itemsTable[element][i] then
					emptyslot = emptyslot + 1
				end
			end
		end

		if emptyslot >= 1 then
			if getCurrentWeight(element) + getItemWeight(itemId) * amount <= getWeightLimit(elementType, element) then
				return true
			end

			return false, "weight"
		end

		return false, "slot"
	end

	return false
end

function findEmptySlot(element, ownerType, itemId)
	if itemsTable[element] then
		if ownerType == "player" then
			if isKeyItem(itemId) then
				return findEmptySlotOfKeys(element)
			elseif isPaperItem(itemId) then
				return findEmptySlotOfPapers(element)
			end
		end

		local slotId = false

		for i = 0, defaultSettings.slotLimit - 1 do
			if not itemsTable[element][i] then
				slotId = tonumber(i)
				break
			end
		end

		if slotId then
			if slotId <= defaultSettings.slotLimit then
				return tonumber(slotId)
			end
		end

		return false
	end

	return false
end

addEvent("&ŁđÄÍ}{Ä>ßß÷÷÷|", true)
addEventHandler("&ŁđÄÍ}{Ä>ßß÷÷÷|", getRootElement(),
	function (element, nearby)
		if isElement(element) then
			inventoryInUse[element] = nil

			if getElementType(element) == "vehicle" and getVehicleType(element) == "Automobile" then
				setVehicleDoorOpenRatio(element, 1, 0, 250)
				setTimer(triggerLatentClientEvent, 250, 1, nearby, "toggleVehicleTrunk", source, "close", element)
			end
		end
	end)

addEvent("rÄđÍÄđ,s||", true)
addEventHandler("rÄđÍÄđ,s||", getRootElement(),
	function (element, ownerId, ownerType, nearbyPlayers)
		if isElement(element) then
			if ownerId and ownerType then
				local canOpenInv = true

				if ownerType == "vehicle" then
					if isVehicleLocked(element) then
						canOpenInv = false
					end
				elseif ownerType == "object" then
					if storedSafes[ownerId] then
						if getElementData(source, "adminLevel") >= 4 then 
							canOpenInv = true 
						end
						if storedSafes[ownerId].ownerGroup > 0 then
							if not exports.a_groups:isPlayerInGroup(source, storedSafes[ownerId].ownerGroup) then
								canOpenInv = false
							end
						elseif not hasItemWithData(source, 154, ownerId) then
							canOpenInv = false
						end
					end
				end

				if not canOpenInv then
					outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFA kiválasztott inventory zárva van, esetleg nincs kulcsod hozzá.", source, 255, 255, 255, true)
					return
				end

				if isElement(inventoryInUse[element]) then
					outputChatBox("#DC143C[alphaGames - Inventory]: #FFFFFFA kiválasztott inventory már használatban van!", source, 255, 255, 255, true)
					return
				end

				inventoryInUse[element] = source
				loadItems(element)

				if ownerType == "vehicle" then
					exports.a_chat:localAction(source, "belenézett a csomagtartóba.")

					if getVehicleType(element) == "Automobile" then
						setVehicleDoorOpenRatio(element, 1, 1, 500)
						triggerLatentClientEvent(nearbyPlayers, "toggleVehicleTrunk", source, "open", element)
					end
				elseif ownerType == "object" then
					exports.a_chat:localAction(source, "belenézett a széfbe.")
				end
			end
		end
	end)

addEvent("Ä\€Äđ&ä&&Ä", true)
addEventHandler("Ä\€Äđ&ä&&Ä", getRootElement(),
	function ()
		if isElement(source) then
			local characterId = getElementData(source, defaultSettings.characterId)

			if characterId then
				loadItems(source)
			end
		end
	end
)

function loadItems(element)
	if isElement(element) then
		local ownerType = getElementType(element)
		local ownerId = false

		ownerId = tonumber(getElementData(element, defaultSettings.characterId))

		if ownerId then
			itemsTable[element] = {}

			return dbQuery(
				function (query)
					local result = dbPoll(query, 0)

					if result then
						local lost, restored = 0, 0

						for k, v in pairs(result) do
							local slotId = false

							if itemsTable[element][v.slot] then
								slotId = findEmptySlot(element, ownerType, v.itemId)

								if slotId then
									dbExec(connection, "UPDATE items SET slot = ? WHERE dbID = ?", slotId, v.dbID)
									restored = restored + 1
								end

								lost = lost + 1
							else
								slotId = v.slot
							end

							addItem(element, v.dbID, slotId, v.itemId, v.amount, v.data1, v.data2, v.data3, v.nameTag, v.serial)
						end

						if lost > 0 and ownerType == "player" then
							outputChatBox("#dc143c[alphaGames - Inventory]: #4aabd0" .. lost .. " #ffffffdarab elveszett tárggyal rendelkezel.", element, 255, 255, 255, true)

							if restored > 0 then
								outputChatBox("#dc143c[alphaGames - Inventory]: #ffffffEbből #4aabd0" .. restored .. " #ffffffdarab lett visszaállítva.", element, 255, 255, 255, true)
							end

							if lost - restored > 0 then
								outputChatBox("#dc143c[alphaGames - Inventory]: #ffffffNem sikerült visszaállítani #4aabd0" .. lost - restored .. " #ffffffdarab tárgyad, mert nincs szabad slot az inventorydban.", element, 255, 255, 255, true)
								outputChatBox("#dc143c[alphaGames - Inventory]: #ffffffkövetkező bejelentkezésedkor ismét megpróbáljuk.", element, 255, 255, 255, true)
							end

							if lost == restored then
								outputChatBox("#dc143c[alphaGames - Inventory]: #ffffffAz összes hibás tárgyadat sikeresen visszaállítottuk. Kellemes játékot kívánunk! :).", element, 255, 255, 255, true)
							end
						end
					end

					if ownerType == "player" then
						triggerClientEvent(element, "loadItems", element, itemsTable[element], "player")
					else
						if isElement(inventoryInUse[element]) then
							triggerClientEvent(inventoryInUse[element], "loadItems", inventoryInUse[element], itemsTable[element], ownerType, element, true)
						end
					end
				end,
			connection, "SELECT * FROM items WHERE ownerType = ? AND ownerId = ?", ownerType, ownerId)
		end

		return false
	end

	return false
end