
defaultSettings = {
	characterId = "a.accID",
	slotLimit = 50,
	width = 10,
	weightLimit = {
		player = 20,
		vehicle = 100,
		object = 60
	},
	slotBoxWidth = 36,
	slotBoxHeight = 36
}

function getElementDatabaseId(element)
    if isElement(element) then
        local elementType = getElementType(element)

        if elementType == "player" then
            return getElementData(element, "a.accID")
        else
            return false
        end
    else
        return false
    end
end

availableItems = { -- [ItemID] = {Név, Leírás, Súly, Stackelhető, Fegyver ID, Töltény item ID, Eldobható, Model, RotX, RotY, RotZ, Z offset}
	[1] = {"AK-47", "", 0, false, 30, -1},
	[2] = {"Desert Eagle", "", 0, false, 24, -1},
	[3] = {"Glock 18", "", 0, false, 22, -1}, -- UJ ITEMKEP KELL NEKI AZ LV-S AZ JO LESZ :) -------------------------------------------------------------------------
	[4] = {"Gumibot", "", 0, false, 3, -1},
	[5] = {"Kés", "", 0, false, 4, -1},
	[6] = {"M4", "", 0, false, 31, -1},
	[7] = {"Shotgun", "", 0, false, 25, -1},
	[8] = {"Silenced Colt-45", "", 0, false, 23, -1},
	[9] = {"Winter AK-47", "", 0, false, 30, -1},
	[10] = {"Camo AK-47", "", 0, false, 30, -1},
	[11] = {"P90", "", 0, false, 29, -1},
	[12] = {"UZI", "", 0, false, 28, -1},
	[13] = {"TEC-9", "", 0, false, 32, -1},
	[14] = {"Bronze Chest", "", 0, true, -1, -1},
	[15] = {"Silver Chest", "", 0, true, -1, -1},
	[16] = {"Gold Chest", "", 0, true, -1, -1},
	[17] = {"Emerald Chest", "", 0, true, -1, -1},
	[18] = {"Diamond Chest", "", 0, true, -1, -1},
	[19] = {"Digit AK-47", "", 0, false, 30, -1},
	[20] = {"Gold AK-47", "", 0, false, 30, -1},
	[21] = {"Special Gold AK-47", "", 0, false, 30, -1},
	[22] = {"Hello Kitty AK-47", "", 0, false, 30, -1},
	[23] = {"Silver AK-47", "", 0, false, 30, -1},
	[24] = {"Camo Desert Eagle", "", 0, false, 24, -1},
	[25] = {"Gold Desert Eagle", "", 0, false, 24, -1},
	[26] = {"Camo P90", "", 0, false, 29, -1},
	[27] = {"Winter P90", "", 0, false, 29, -1},
	[28] = {"Black P90", "", 0, false, 29, -1},
	[29] = {"Gold Flow P90", "", 0, false, 29, -1},
	[30] = {"No Limit P90", "", 0, false, 29, -1},
	[31] = {"Oni P90", "", 0, false, 29, -1},
	[32] = {"Carbon P90", "", 0, false, 29, -1},
	[33] = {"Wooden P90", "", 0, false, 29, -1},
	[34] = {"Halloween P90", "", 0, false, 29, -1},
	[35] = {"SPAZ-12", "", 0, false, 27, -1},
	[36] = {"Camo M4", "", 0, false, 31, -1},
	[37] = {"Gold M4", "", 0, false, 31, -1},
	[38] = {"Hello Kitty M4", "", 0, false, 31, -1},
	[39] = {"Paint M4", "", 0, false, 31, -1},
	[40] = {"Winter M4", "", 0, false, 31, -1},
	[41] = {"Nitró palack", "", 0, true, -1, -1},
	[42] = {"Titokzatos láda", "", 0, true, -1, -1},
	[43] = {"Katana", "", 0, false, 8, -1},
	[44] = {"Sawed-Off Shotgun", "", 0, false, 26, -1},
	[45] = {"Sniper", "", 0, false, 34, -1},
	[46] = {"Dragon King M4", "", 0, false, 31, -1},
	[47] = {"Howl M4", "", 0, false, 31, -1},
	[48] = {"Hello Kitty 2 M4", "", 0, false, 31, -1},
	[49] = {"Fade AK-47", "", 0, false, 30, -1},
	[50] = {"Summer AK-47 [LIMITÁLT]", "", 0, false, 30, -1},
	[51] = {"Fade Deagle", "", 0, false, 24, -1},
	[52] = {"Hello Kitty Deagle", "", 0, false, 24, -1},
	[53] = {"Hello Kitty USP", "", 0, false, 23, -1},
	[54] = {"Dragon Spaz-12 [LIMITÁLT]", "", 0, false, 27, -1},
	[55] = {"Printstream Spaz-12 [LIMITÁLT]", "", 0, false, 27, -1},
	[56] = {"Abstract Spaz-12", "", 0, false, 27, -1},
	[57] = {"Scratched Spaz-12", "", 0, false, 27, -1},
	[58] = {"Strandlabda", "", false, -1, -1},
	[59] = {"Thunder M4", "", 0, false, 31, -1},
	[60] = {"Stratched M4", "", 0, false, 31, -1},
	[61] = {"Special Gold M4", "", 0, false, 31, -1},
	[62] = {"Tök", "Halloween-i tök", false, -1, -1},
}

mysteriousItemsTable = {
	-- [ID] = {itemId, "Item név", Esély}
	[1] = {1, "AK-47", 90},
	[2] = {2, "Desert Eagle", 85},
	[3] = {3, "Colt-45", 90},
	[4] = {4, "Gumibot", 85},
	[5] = {5, "Kés", 85},
	[6] = {6, "M4", 85},
	[7] = {7, "Shotgun", 20},
	[8] = {8, "Silenced Colt-45", 75},
	[9] = {9, "Winter AK-47", 5},
	[10] = {10, "Camo AK-47", 5},
	[11] = {11, "P90", 75},
	[12] = {12, "UZI", 75},
	[13] = {13, "TEC-9", 75},
	[14] = {19, "Digit AK-47", 5},
	[15] = {20, "Gold AK-47", 5},
	[16] = {21, "Special Gold AK-47", 3},
	[17] = {22, "Hello Kitty AK-47", 3},
	[18] = {23, "Silver AK-47", 5},
	[19] = {24, "Camo Desert Eagle", 5},
	[20] = {25, "Gold Desert Eagle", 3},
	[21] = {26, "Camo P90", 5},
	[22] = {27, "Winter P90", 5},
	[23] = {28, "Black P90", 5},
	[24] = {29, "Gold Flow P90", 5},
	[25] = {30, "No Limit P90", 5},
	[26] = {31, "Oni P90", 5},
	[27] = {32, "Carbon P90", 5},
	[28] = {33, "Wooden P90", 5},
	[29] = {34, "Halloween P90", 0.5},
	[30] = {35, "SPAZ-12", 0.5},
	[31] = {36, "Camo M4", 3},
	[32] = {37, "Gold M4", 3},
	[33] = {38, "Hello Kitty M4", 1},
	[34] = {39, "Paint M4", 5},
	[35] = {40, "Winter M4", 5},
	[36] = {41, "Nitró palack", 40},
	[37] = {42, "Titokzatos láda", 80},
	[38] = {43, "Katana", 0.5},
	[39] = {44, "Sawed-Off Shotgun", 0.5},
	[40] = {45, "Sniper", 0.5},
	[41] = {46, "Dragon King M4", 0.3},
	[42] = {47, "Howl M4", 0.3},
	[43] = {48, "Hello Kitty 2 M4", 0.3},
	[44] = {49, "Fade AK-47", 0.3},
	[45] = {50, "Summer AK-47", 0.3},
	[46] = {51, "Fade Deagle", 0.3},
	[47] = {52, "Hello Kitty Deagle", 0.3},
	[48] = {53, "Hello Kitty USP", 0.3},
	[49] = {54, "Dragon Spaz-12 [LIMITÁLT]", 0.3},
}

specialItemsTable = {
	[9] = true,
	[10] = true,
	[19] = true,
	[20] = true,
	[21] = true,
	[22] = true,
	[23] = true,
	[24] = true,
	[25] = true,
	[26] = true,
	[27] = true,
	[28] = true,
	[29] = true,
	[30] = true,
	[31] = true,
	[32] = true,
	[33] = true,
	[34] = true,
	[35] = true,
	[36] = true,
	[37] = true,
	[38] = true,
	[39] = true,
	[40] = true,
	[42] = true,
	[43] = true,
	[44] = true,
	[45] = true,
	[46] = true,
	[47] = true,
	[48] = true,
	[49] = true,
	[50] = true,
	[51] = true,
	[52] = true,
	[53] = true,
	[54] = true,
	[55] = true,
	[56] = true,
	[57] = true,
}

weaponSkins = {
	--** AK-47
	[9] = 1,
	[10] = 2,
	[19] = 3,
	[20] = 4,
	[21] = 5,
	[22] = 7,
	[23] = 6,
	[49] = 9,
	[50] = 8,
	
	--** Dezi
	[24] = 1,
	[25] = 2,
	[51] = 4,
	[52] = 3,

	--** P90
	[26] = 1,
	[27] = 2,
	[28] = 3,
	[29] = 4,
	[30] = 5,
	[31] = 6,
	[32] = 7,
	[33] = 8,
	[34] = 9,

	--** M4
	[36] = 1,
	[37] = 2,
	[38] = 3,
	[39] = 4,
	[40] = 5,
	[46] = 6,
	[47] = 7,
	[48] = 8,
	[59] = 9,
	[60] = 10,
	[61] = 11,

	--** Silenced
	[53] = 1,
	
	--** Spaz-12
	[54] = 1,
	[55] = 2,
	[56] = 3,
	[57] = 4,
}

itemsTablePrice = { -- [Item ID] = price,
    [1] = 1000,
	[2] = 1000,
    [35] = 100000,
	[11] = 1000,
	[12] = 1000,
	[13] = 1000,
	[3] = 500,
	[4] = 1000,
	[5] = 1000,
	[6] = 1000,
	[7] = 1000,
	[8] = 750,
	[19] = 20000,
	[20] = 20000,
	[21] = 20000,
	[22] = 20000,
	[23] = 20000,
	[24] = 20000,
	[25] = 20000,
	[26] = 20000,
	[27] = 20000,
	[28] = 20000,
	[29] = 20000,
	[30] = 20000,
	[31] = 20000,
	[32] = 20000,
	[33] = 20000,
	[34] = 20000,
	[37] = 20000,
	[38] = 20000,
	[39] = 20000,
	[40] = 20000,
	[45] = 30000,
	[43] = 20000,
	[44] = 20000,

	[46] = 50000,
	[47] = 50000,
	[48] = 50000,
	[49] = 50000,
	[50] = 50000,
	[9] = 20000,
	[10] = 20000,
	[51] = 40000,
	[52] = 40000,
	[36] = 20000,
	[53] = 50000,
	[61] = 30000,

}
function getWeaponNameFromIDNew(id)
	if id == 22 then
		return "Colt-45"
	elseif id == 29 then
		return "P90"
	elseif id == 34 then
		return "Remington 700"
	elseif id == 33 then
		return "Vadászpuska"
	else
		return getWeaponNameFromID(id)
	end
end

function getItemPerishable(itemId)
	if availableItems[itemId] then
		if perishableItems[itemId] then
			return perishableItems[itemId]
		end
	end
	return false
end

function getWeaponSkin(itemId)
	return weaponSkins[itemId]
end

function isKeyItem(itemId)
	return false
end

function isPaperItem(itemId)
	return false
end

function getItemInfoForShop(itemId)
	return getItemName(itemId), getItemDescription(itemId), getItemWeight(itemId)
end

function getItemNameList()
	local nameList = {}

	for i = 1, #availableItems do
		nameList[i] = getItemName(i)
	end

	return nameList
end

function getItemDescriptionList()
	local descriptionList = {}

	for i = 1, #availableItems do
		descriptionList[i] = getItemDescription(i)
	end

	return descriptionList
end

function getItemName(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][1]
	end
	return false
end

function getItemDescription(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][2]
	end
	return false
end

function getItemWeight(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][3]
	end
	return 0
end

function isItemStackable(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][4]
	end
	return false
end

function getItemWeaponID(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][5] or 0
	end
	return false
end

function getItemAmmoID(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][6]
	end
	return false
end

function isItemDroppable(itemId)
	if availableItems[itemId] then
		return availableItems[itemId][7]
	end
	return false
end

function getItemDropDetails(itemId)
	if availableItems[itemId] and availableItems[itemId][8] then
		return availableItems[itemId][8], availableItems[itemId][9], availableItems[itemId][10], availableItems[itemId][11], availableItems[itemId][12]
	end
	return false
end

function isWeaponItem(itemId)
	if availableItems[itemId] and getItemWeaponID(itemId) > 0 then
		return true
	end
	return false
end

function isAmmoItem(itemId)
	if itemId >= 109 and itemId <= 114 or itemId == 151 then
		return true
	end
	return false
end

serialItems = {}

local weaponTypes = {
	[22] = "P",
	[23] = "P",
	[24] = "P",
	[25] = "S",
	[26] = "S",
	[27] = "S",
	[28] = "SM",
	[29] = "SM",
	[32] = "SM",
	[30] = "AR",
	[31] = "AR",
	[33] = "R",
	[34] = "R",
	[12] = "K",
	[8] = "K",
	[4] = "K"
}

for i = 1, #availableItems do
	if isWeaponItem(i) then
		local weaponId = getItemWeaponID(i)

		if weaponId >= 22 and weaponId <= 39 or weaponId == 12 or weaponId == 8 or weaponId == 4 or weaponId == 1 then
			availableItems[i][4] = false

			if i == 155 then
				serialItems[i] = "T"
			else
				serialItems[i] = weaponTypes[weaponId] or "O"
			end
		end
	end
end

local nonStackableItems = {}

for i = 1, #availableItems do
	if not isItemStackable(i) then
		table.insert(nonStackableItems, i)
	end
end

function getNonStackableItems()
	return nonStackableItems
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