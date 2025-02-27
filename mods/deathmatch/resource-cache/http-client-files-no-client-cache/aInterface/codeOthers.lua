function createFont(type, size)
	if type and size then
		if type == "bold" then
			return dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", size, false, "cleartype")
		elseif type == "regular" then
			return dxCreateFont("files/fonts/Roboto-Condensed.ttf", size, false, "cleartype")
		elseif type == "light" then
			return dxCreateFont("files/fonts/Roboto-Thin.ttf", size, false, "cleartype")
		end
	end
end