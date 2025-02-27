itemLIST = {
	{
		itemid = 1,
		name = 'AK-47',
		usable = false,
		weaponID = 30,
	},
	{
		itemid = 2,
		name = 'Desert Eagle',
		usable = false,
		weaponID = 24,
	},
	{
		itemid = 3,
		name = 'Colt-45',
		usable = false,
		weaponID = 22,
	},
	{
		itemid = 4,
		name = 'Gumibot',
		usable = false,
		weaponID = 3,
	},
	{
		itemid = 5,
		name = 'Kés',
		usable = false,
		weaponID = 4,
	},
	{
		itemid = 6,
		name = 'M4',
		usable = false,
		weaponID = 31,
	},
	{
		itemid = 7,
		name = 'Shotgun',
		usable = false,
		weaponID = 25,
	},
	{
		itemid = 8,
		name = 'Silenced Colt-45',
		usable = false,
		weaponID = 23,
	},
	{
		itemid = 9,
		name = 'Winter-Camo AK-47',
		usable = false,
		weaponID = 30,
	},
	{
		itemid = 10,
		name = 'Camo AK-47',
		usable = false,
		weaponID = 30,
	},
	{
		itemid = 11,
		name = 'P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 12,
		name = 'UZI',
		usable = false,
		weaponID = 28,
	},	
	{
		itemid = 13,
		name = 'TEC-9',
		usable = false,
		weaponID = 32,
	},
	{
		itemid = 14,
		name = "Bronze Chest",
		usable = true,
	},
	{
		itemid = 15,
		name = "Silver Chest",
		usable = true,
	},
	{
		itemid = 16,
		name = "Golden Chest",
		usable = true,
	},
	{
		itemid = 17,
		name = "Emerald Chest",
		usable = true,
	},
	{
		itemid = 18,
		name = "Diamond Chest",
		usable = true,
	},
	{
		itemid = 19,
		name = 'Camo 3 AK-47',
		usable = false,
		weaponID = 30,
	},
	{
		itemid = 20,
		name = 'Golden AK-47',
		usable = false,
		weaponID = 30,
	},
	{
		itemid = 21,
		name = 'Special Golden AK-47',
		usable = false,
		weaponID = 30,
	},
	{
		itemid = 22,
		name = 'Hello-Kitty AK-47',
		usable = false,
		weaponID = 30,
	},
	{
		itemid = 23,
		name = 'Silver AK-47',
		usable = false,
		weaponID = 30,
	},
	{
		itemid = 24,
		name = 'Camo Desert Eagle',
		usable = false,
		weaponID = 24,
	},
	{
		itemid = 25,
		name = 'Golden Desert Eagle',
		usable = false,
		weaponID = 24,
	},
	{
		itemid = 26,
		name = 'Camo P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 27,
		name = 'Winter P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 28,
		name = 'Black P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 29,
		name = 'Gold Flow P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 30,
		name = 'No Limit P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 31,
		name = 'Oni P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 32,
		name = 'Carbon P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 33,
		name = 'Wooden P90',
		usable = false,
		weaponID = 29,
	},	
	{
		itemid = 34,
		name = 'Halloween P90',
		usable = false,
		weaponID = 29,
	},
	{
		itemid = 35,
		name = 'Spas 12',
		usable = false,
		weaponID = 27,
	},
	{
		itemid = 36,
		name = 'Camo M4',
		usable = false,
		weaponID = 31,
	},
	{
		itemid = 37,
		name = 'Golden M4',
		usable = false,
		weaponID = 31,
	},
	{
		itemid = 38,
		name = 'Hello-Kitty M4',
		usable = false,
		weaponID = 31,
	},
	{
		itemid = 39,
		name = 'Painted M4',
		usable = false,
		weaponID = 31,
	},
	{
		itemid = 40,
		name = 'Winter M4',
		usable = false,
		weaponID = 31,
	},
	{
		itemid = 41,
		name = "50%-os Nitró palack",
		usable = true,
	},
	{
		itemid = 42,
		name = "100%-os Nitró palack",
		usable = true,
	},
}

function getItemName(id)
	return tostring(itemLIST[tonumber(id)].name)
end

function getItemDesc(id)
	return itemLIST[id].desc
end