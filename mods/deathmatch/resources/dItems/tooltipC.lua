local screenX, screenY = guiGetScreenSize()

myriadpro = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", 20, false, "cleartype")

function showTooltip2(x, y, text, subText, showItem, KeyChain)
	text = tostring(text)
	subText = subText and tostring(subText)

	if text == subText then
		subText = nil
	end

	local sx = dxGetTextWidth(text, 1, "clear", true) + 10
	
	if subText then
		sx = math.max(sx, dxGetTextWidth(subText, 1, "clear", true) + 10)
		text = "#8FC3E4" .. text .. "\n#ffffff" .. subText
	end

	local sy = 20

	if subText then
		local _, lines = string.gsub(subText, "\n", "")
		
		sy = sy + 12 * (lines + 1)
	end

	local drawnOnTop = true

	if showItem then
		x = math.floor(x - sx / 2)
		drawnOnTop = false
	else
		x = math.max(0, math.min(screenX - sx, x))
		y = math.max(0, math.min(screenY - sy, y))
	end


	dxDrawRectangle(x, y, sx, sy, tocolor(65, 65, 65, 255), drawnOnTop)
	dxDrawRectangle(x + 1, y + 1, sx - 2, sy - 2, tocolor(35, 35, 35, 255), drawnOnTop)
	dxDrawText(text, x, y, x + sx, y + sy, tocolor(255, 255, 255, 255), 0.5, myriadpro, "center", "center", false, false, drawnOnTop, true)
end

function showTooltip(x, y, text, subText, showItem, KeyChain)
	text = tostring(text)
	subText = subText and tostring(subText)

	if text == subText then
		subText = nil
	end

	local sx = dxGetTextWidth(text, 1, "clear", true) + 10
	
	if subText then
		sx = math.max(sx, dxGetTextWidth(subText, 1, "clear", true) + 10)
		text = "#FFFFFF" .. text .. "\n#ffffff" .. subText
	end

	local sy = 20

	if subText then
		local _, lines = string.gsub(subText, "\n", "")
		
		sy = sy + 12 * (lines + 1)
	end

	local drawnOnTop = true

	if showItem then
		x = math.floor(x - sx / 2)
		drawnOnTop = false
	else
		x = math.max(0, math.min(screenX - sx, x))
		y = math.max(0, math.min(screenY - sy, y))
	end


	dxDrawRectangle(x + 5, y + 5, sx, sy, tocolor(35, 35, 35, 255 * alphaProgress), drawnOnTop)
	dxDrawText(text, x + 5, y + 5, x + 5 + sx, y + 5 + sy, tocolor(255, 255, 255, 255 * alphaProgress), 0.5, myriadpro, "center", "center", false, false, drawnOnTop, true)
end