local sX, sY = guiGetScreenSize()
local height = 35
local types = {
	{1, "success", "files/icons/infobox/success.png", 155, 230, 140},
	{2, "error", "files/icons/infobox/error.png", 200, 100, 100},
	{3, "info", "files/icons/infobox/info.png", 100, 180, 220},
	{4, "warning", "files/icons/infobox/warning.png", 220, 170, 100},
}
local currentInfoBoxes = {}
local font = dxCreateFont("files/Roboto-Condensed.otf", 11)
local currentShowedInfoboxes = 0

function createInfobox(type, text)
	if type and text then
		data = {type, text, getTickCount(), types[type][3], types[type][4], types[type][5], types[type][6]}
		table.insert(currentInfoBoxes, data)
		currentShowedInfoboxes = currentShowedInfoboxes + 1
	end
end

function makeNotification(type, text)
	if type and text then
		createInfobox(type, text)
		--playSound("files/sounds/" .. types[type][2] .. ".mp3")
		playSound("files/sounds/" .. types[type][2] .. ".mp3")
		outputConsole("[" .. types[type][2] .. "]: " .. removeHex(text, 6))
	end
end
addEvent("makeNotification", true)
addEventHandler("makeNotification", root, makeNotification)

function renderInfobox()
	for k, v in ipairs(currentInfoBoxes) do
		text = v[2]
		local nowTick = getTickCount()
		local elapsedTime = nowTick - v[3]
		local duration = elapsedTime / 1000
		a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "InQuad")
		width = dxGetTextWidth(removeHex(text, 6), 1, font)
		width = width + 20
		startY = (5 + height) * (k) - height
		startY = interpolateBetween(0 - startY, 0, 0, startY, 0, 0, duration, "InQuad")
		linewidth = interpolateBetween(width + 25, 0, 0, 0, 0, 0, elapsedTime/5000, "Linear")

		if linewidth > 20 then
			dxDrawRectangle(sX/2 - width / 2 - 25, startY, linewidth, height, tocolor(v[5]/2, v[6]/2, v[7]/2, a))
		end
		dxDrawRectangle(sX/2 - width / 2 - 24, startY + 1, width - 2 + 25, height - 2, tocolor(45, 45, 45, a))
		dxDrawImage(sX/2 - width / 2 - 15, startY + 2 + height / 4 - 2, 18, 18, v[4], 0, 0, 0, tocolor(v[5], v[6], v[7], a), true)

		dxDrawText(text, sX/2 - width / 2 + width / 2, startY + height / 2, _, _, tocolor(200, 200, 200, a), 1, font, "center", "center", false, false, true, true)
		if v[3] + 5000 < getTickCount() then
			currentShowedInfoboxes = currentShowedInfoboxes - 1
			table.remove(currentInfoBoxes, k)
		end
	end
end
addEventHandler("onClientRender", root, renderInfobox)

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
    return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end