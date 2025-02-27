itemsInShop = { -- ** MEGNEVEZÉS, $ ÁR, PP ÁR, KATEGÓRIA
	[1] = {
		{"Életerő feltöltés 100%-ra", 500, 20, "others", false, "hp100"},
		{"Páncél feltöltés 50%-ra", 750, 50, "others", false, "armor50"},
		{"Páncél feltöltés 100%-ra", 1000, 75, "others", false, "armor100"},
		{"1000$", "-", 250, "others", false, "dollar1000"},
		{"2500$", "-", 500, "others", false, "dollar2500"},
		{"5000$", "-", 750, "others", false, "dollar5000"},
	},
	-- az utolso ertek modell id
	[2] = {
		{"Colt-45", 750, 150, "weapons", true, 3},
		{"Silenced Colt-45", 1000, 250, "weapons", true, 8},
		{"Desert Eagle", 1100, 1200, "weapons", true, 2},
		{"Camo Desert Eagle", "-", 1200, "weapons2", true, 24,},
		{"Golden Desert Eagle", "-", 1200, "weapons2", true, 25},
		{"P90", 2200, 250, "weapons", true, 11},
		{"Camo P90", "-", 1400, "weapons2", true, 26},
		{"Winter P90", "-", 1400, "weapons2", true, 27},
		{"Black P90", "-", 1400, "weapons2", true, 28},
		{"Gold Flow P90", "-", 1400, "weapons2", true, 29},
		{"No Limit P90", "-", 1400, "weapons2", true, 30},
		{"Oni P90", "-", 1400, "weapons2", true, 31},
		{"Carbon P90", "-", 1400, "weapons2", true, 32},
		{"Wooden P90", "-", 1400, "weapons2", true, 33},
		{"Halloween P90", "-", 1400, "weapons2", true, 34},
		{"M4", 2500, 300, "weapons", true, 6},
		{"Camo M4", "-", 1800, "weapons2", true, 36},
		{"Golden M4", "-", 1800, "weapons2", true, 37},
		{"Hello-Kitty M4", "-", 1800, "weapons2", true, 38},
		{"Painted M4", "-", 1800, "weapons2", true, 39},
		{"Winter M4", "-", 1800, "weapons2", true, 40},
		{"AK-47", 2000, 250, "weapons", true, 1},
		{"Camo AK-47", "-", 1500, "weapons2", true, 10},
		{"Golden AK-47", "-", 1500, "weapons2", true, 20},
		{"Special Golden AK-47", "-", 1500, "weapons2", true, 21},
		{"Hello-Kitty AK-47", "-", 1500, "weapons2", true, 22},
		{"Silver AK-47", "-", 1500, "weapons2", true, 23},
		{"Spas 12", 250000, 1850, "weapons", true, 35},
		{"UZI", 1500, 100, "weapons", true, 12},
		{"TEC-9", 1750, 120, "weapons", true, 13},

	},
}

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function isCursorOverText(posX, posY, sizeX, sizeY)
	if ( not isCursorShowing( ) ) then
		return false
	end
	local cX, cY = getCursorPosition()
	local screenWidth, screenHeight = guiGetScreenSize()
	local cX, cY = (cX*screenWidth), (cY*screenHeight)

	return ( (cX >= posX and cX <= posX+(sizeX - posX)) and (cY >= posY and cY <= posY+(sizeY - posY)) )
end