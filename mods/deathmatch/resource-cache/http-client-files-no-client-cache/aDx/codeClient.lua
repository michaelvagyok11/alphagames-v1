local sX, sY = guiGetScreenSize();
local editBoxes = {}
local hoverActive = {}
local robotoRegular = dxCreateFont("files/Poppins-Regular.ttf", 12, false, "cleartype")

function dxCreateEdit(name, inboxText, hoverText, x, y, w, h, color, maxChar, type)
    if name and x and y and w and h then
        table.insert(editBoxes, {name, inboxText or "", hoverText or "", x, y, w, h, color or {200, 200, 200}, maxChar or 32, type or 1, 255, getTickCount()})
        backSpaceTick = getTickCount()
    end
end

function dxDestroyEdit(name)
    for k, v in ipairs(editBoxes) do
        if v[1] == name then
            table.remove(editBoxes, k)
        end
    end
end

function setEditBoxAlpha(name, a)
    for k, v in ipairs(editBoxes) do
        if v[1] == name then
            v[11] = a
        end
    end
end

function dxEditSetText(name, text)
    for k, v in ipairs(editBoxes) do 
        if v[1] == name then
            v[2] = text
        end
    end
end

function dxGetEditText(name)
    for k, v in ipairs(editBoxes) do 
        if v[1] == name then
            return tostring(v[2])
        end
    end
end

function dxGetActiveEdit()
    for k, v in ipairs(editBoxes) do
        if hoverActive[k] then
            return k
        end
    end
end

function renderEditBoxes()
    for k, v in ipairs(editBoxes) do
        name, inboxtext, hovertext, x, y, w, h, color, maxchar, type, alpha = v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11]
        local nowTick = getTickCount()
        if hoverActive[k] then
            dxDrawRectangle(x - 1, y - 1, w + 2, h + 2, tocolor(color[1], color[2], color[3], alpha/2), true)
        else
            if isMouseInPosition(x, y, w, h) then
                dxDrawRectangle(x - 1, y - 1, w + 2, h + 2, tocolor(color[1], color[2], color[3], alpha/2), true)
            else
                dxDrawRectangle(x - 1, y - 1, w + 2, h + 2, tocolor(55, 55, 55, alpha), true)
            end
        end
        dxDrawRectangle(x, y, w, h, tocolor(45, 45, 45, alpha), true)
        
        
        if (string.len(inboxtext) == 0) and not hoverActive[k] then
            dxDrawText(hovertext, x + 10, y, x + w - 20, y + h, tocolor(200, 200, 200, alpha/2), 1, robotoRegular, "left", "center", true, false, true)
        else
            if type == 2 then
                local text = string.rep("*", #inboxtext)
                
                dxDrawText(text, x + 10, y, x + w - 20, y + h, tocolor(200, 200, 200, alpha/1.5), 1, robotoRegular, "left", "center", true, false, true)
            else
                dxDrawText(inboxtext, x + 10, y, x + w - 20, y + h, tocolor(200, 200, 200, alpha/1.5), 1, robotoRegular, "left", "center", true, false, true)
            end
        end
        if hoverActive[k] then
            a = interpolateBetween(0, 0, 0, 50, 0, 0, getTickCount()/1500, "SineCurve")
            local textWidth = dxGetTextWidth(v[2], 1, robotoRegular)
            dxDrawRectangle(x + textWidth + 13, y + 5, 2, h - 10, tocolor(200, 200, 200, a), true)

            if getKeyState("backspace") and (nowTick - backSpaceTick) > 125 then
                v[2] = string.sub(v[2], 1, #v[2] - 1)
                backSpaceTick = getTickCount()
            end
        end
    end
end
addEventHandler("onClientRender", root, renderEditBoxes)

function clickEditBoxes(key, state)
    for k, v in ipairs(editBoxes) do
        if isMouseInPosition(v[4], v[5], v[6], v[7]) and v[12] + 500 < getTickCount() then
            hoverActive[k] = true
        else
            hoverActive[k] = false
        end
    end
end
addEventHandler("onClientClick", root, clickEditBoxes)

function onKey(key, state)
    if key == "tab" and state then
        for k, v in ipairs(editBoxes) do
            if hoverActive[k] then
                hoverActive[k] = false
                hoverActive[k + 1] = true
                return
            end
        end
    end

    for k,v in pairs(editBoxes) do 
        if hoverActive[k] then
            cancelEvent()
        end
    end
end
addEventHandler("onClientKey", root, onKey)

function onCharacter(char)
    if isCursorShowing() then
        for k, v in ipairs(editBoxes) do
            if hoverActive[k] then
                if v[9] > string.len(v[2]) then
                    v[2] = v[2] .. char
                else
                    --exports.a_interface:makeNotification(2, "You can't write more letters to this input.")
                end
            end
        end
    end
end
addEventHandler("onClientCharacter", root, onCharacter)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

local corner = dxCreateTexture("files/corner.png", "argb", true, "clamp")

--[[function dxDrawRoundedRectangle(x, y, w, h, color, radius, postGUI, subPixelPositioning)
	radius = radius or 5
	color = color or tocolor(0, 0, 0, 200)
	
	dxDrawImage(x, y, radius, radius, corner, 0, 0, 0, color, postGUI)
	dxDrawImage(x, y + h - radius, radius, radius, corner, 270, 0, 0, color, postGUI)
	dxDrawImage(x + w - radius, y, radius, radius, corner, 90, 0, 0, color, postGUI)
	dxDrawImage(x + w - radius, y + h - radius, radius, radius, corner, 180, 0, 0, color, postGUI)
	
	dxDrawRectangle(x, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
	dxDrawRectangle(x + radius, y, w - radius * 2, h, color, postGUI, subPixelPositioning)
	dxDrawRectangle(x + w - radius, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
end]]--