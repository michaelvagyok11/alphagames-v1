local sX, sY = guiGetScreenSize();
function reMap(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(sX, 720, 1920, 0.75, 1)

function resp(num)
    return num * responsiveMultipler
end

function respc(num)
    return math.ceil(num * responsiveMultipler)
end
local editBoxes = {}
local hoverActive = {}
local robotoRegular = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(12), false, "cleartype")

function dxCreateEdit(name, inboxText, hoverText, x, y, w, h, color, maxChar, type, a)
    if name and x and y and w and h then
        table.insert(editBoxes, {name, inboxText or "", hoverText or "", x, y, w, h, color or {200, 200, 200}, maxChar or 32, type or 1, a or 255, getTickCount()})
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
            dxDrawImage(x, y, w, h, "files/shadow.png", 0, 0, 0, tocolor(65, 65, 65, alpha), true)
            --dxDrawRectangle(x, y, w, h, tocolor(65, 65, 65, alpha), true)
        else
            if isMouseInPosition(x, y, w, h) then
                dxDrawImage(x, y, w, h, "files/shadow.png", 0, 0, 0, tocolor(65, 65, 65, alpha), true)
                --dxDrawRoundedRectangle(x, y, w, h, 3, tocolor(65, 65, 65, alpha), true)
            else
                dxDrawImage(x, y, w, h, "files/shadow.png", 0, 0, 0, tocolor(45, 45, 45, alpha), true)
                --dxDrawRoundedRectangle(x, y, w, h, 3, tocolor(45, 45, 45, alpha), true)
            end
        end
        --dxDrawRoundedRectangle(x, y, w, h, 3, tocolor(45, 45, 45, alpha), true)
        
        
        if (string.len(inboxtext) == 0) and not hoverActive[k] then
            dxDrawText(hovertext, x, y, x + w, y + h, tocolor(200, 200, 200, alpha/2), 1, robotoRegular, "center", "center", true, false, true)
        else
            if type == 2 then
                local text = string.rep("*", #inboxtext)
                
                dxDrawText(text, x, y, x + w, y + h, tocolor(200, 200, 200, alpha/1.5), 1, robotoRegular, "center", "center", true, false, true)
            else
                dxDrawText(inboxtext, x, y, x + w, y + h, tocolor(200, 200, 200, alpha/1.5), 1, robotoRegular, "center", "center", true, false, true)
            end
        end
        if hoverActive[k] then
            a = interpolateBetween(0, 0, 0, 50, 0, 0, getTickCount()/1500, "SineCurve")
            local textWidth = dxGetTextWidth(v[2], 1, robotoRegular)
            dxDrawRectangle(x + w / 2 + textWidth / 2 + respc(3), y + respc(10), 2, h - respc(20), tocolor(200, 200, 200, a), true)

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
                    --exports.d_interface:makeNotification(2, "You can't write more letters to this input.")
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

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end