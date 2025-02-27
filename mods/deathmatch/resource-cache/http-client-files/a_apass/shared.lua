itemsInBpass = { -- ** MEGNEVEZÉS, $ ÁR, PP ÁR, KATEGÓRIA
	{"Életerő feltöltés 100%-ra", 500, 20, "others", false, "hp100"},
	{"Páncél feltöltés 50%-ra", 750, 50, "others", false, "armor50"},
	{"Páncél feltöltés 100%-ra", 1000, 75, "others", false, "armor100"},
	{"Colt-45", 750, 150, "weapons", true, 3},
	{"Silenced Colt-45", 1000, 250, "weapons", true, 8},
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