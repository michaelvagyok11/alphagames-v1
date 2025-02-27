local fontCache = {}
local resourceFonts = {}

local function getFontUsedCount(token)
    local count = 0

    for k, v in pairs(resourceFonts) do
        for k2 in pairs(v) do
            if k2 == token then
                count = count + 1
            end
        end
    end

    return count
end

function getFontsDetail()
    local fonts = {}

    for k, v in pairs(fontCache) do
        local subStrings = split(k, "/")
        table.insert(fonts, {subStrings[1], subStrings[2], subStrings[3], subStrings[4], getFontUsedCount(k)})
    end

    return fonts
end

function loadFont(fontName, size, bold, quality)
    if not fileExists("files/fonts/" .. fontName) then
        print("[RayCore - Error]: \""  .. fontName .. "\" nem található")
        return false
    end

    size = size or 14
    quality = quality or "cleartype"

    local token = fontName .. "/" .. size .. "/" .. tostring(bold) .. "/" .. quality

    if not fontCache[token] then
        fontCache[token] = dxCreateFont("files/fonts/" .. fontName, size, bold, quality)

        if not fontCache[token] then
            if bold then
                fontCache[token] = "default-bold"
            else
                fontCache[token] = "Arial"
            end

            print("[RayCore - Error]: \""  .. fontName .. "\" . Nincs elég VRAM!")
        end
    end

    if not sourceResource then
        sourceResource = getThisResource()
    end 

    if not resourceFonts[sourceResource] then
        resourceFonts[sourceResource] = {}
    end

    resourceFonts[sourceResource][token] = true

    return fontCache[token]
end

addEventHandler("onClientResourceStop", getRootElement(),
    function (stoppedResource)
        if stoppedResource == resourceRoot then
            for k,v in pairs(fontCache) do
                if isElement(v) then
                    destroyElement(v)
                end
                fontCache[k] = nil
            end

            return
        end

        if stoppedResource ~= resourceRoot and resourceFonts[stoppedResource] then
            for k, v in pairs(resourceFonts[stoppedResource]) do
                if getFontUsedCount(k) <= 1 then
                    if isElement(fontCache[k]) then
                        destroyElement(fontCache[k])
                    end
                    fontCache[k] = nil
                end
            end
            resourceFonts[stoppedResource] = nil
        end
    end
)

local screenX, screenY = guiGetScreenSize()

local defLines = 20

local pos = {screenX / 2, screenY - 30}

local font = loadFont("BebasNeueBold.otf", 14, false)

debugTable = {}

debug = false

local states = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
}

local levels = {
    [0] = "[Custom]",
    [1] = "#ad1503[Error]#ffffff",
    [2] = "#ffa500[Warning]#ffffff",
    [3] = "#009B3A[Info]#ffffff",
}

local latestRow = 1
local currentRow = 1
local maxRow = 10

function renderDebug()
    if not debug then return end
    --dxDrawRectangle(pos[1] - 425, pos[2] - 15 * maxRow - 5, 850, 15 * maxRow + 15, tocolor(44, 44, 44, 230), false)
    latestRow = currentRow+maxRow-1
    for k, v in ipairs(debugTable) do
        if k >= currentRow and k <= latestRow then
            k = k - currentRow + 1
            if v[3] > 1 and v[4] then
                dxDrawBorderText(v[1] .. " [Dup #ad1503x" .. v[3] .. "#ffffff - Client Side]", pos[1], pos[2] - 16 * (k - 1), pos[1], pos[2] - 16 * (k - 1), tocolor(200, 200, 200, 200), tocolor(0, 0, 0, 200), 0.75, font, "center", "center", _, _, true, true)
            elseif v[4] then
                dxDrawBorderText(v[1] .. " [Client Side", pos[1], pos[2] - 16 * (k - 1), pos[1], pos[2] - 16 * (k - 1), tocolor(200, 200, 200, 200), tocolor(0, 0, 0, 200), 0.75, font, "center", "center", _, _, true, true)
            elseif v[3] > 1 then
                dxDrawBorderText(v[1] .. " [Dup #ad1503x" .. v[3] .. "#ffffff]", pos[1], pos[2] - 16 * (k - 1), pos[1], pos[2] - 16 * (k - 1), tocolor(200, 200, 200, 200), tocolor(0, 0, 0, 200), 0.75, font, "center", "center", _, _, true, true)
            else
                dxDrawBorderText(v[1], pos[1], pos[2] - 16 * (k - 1), pos[1], pos[2] - 16 * (k - 1), tocolor(200, 200, 200, 200), tocolor(0, 0, 0, 200), 0.75, font, "center", "center", _, _, true, true)
            end
        end
    end
end
addEventHandler("onClientRender", getRootElement(), renderDebug)

function moveDebugRender()
    if not cdm then return end
    local cpx, cpy = getCursorPosition()
    local posx, posy = cpx * screenX   - doffsetx, cpy * screenY - doffsety
    pos[1] = posx
    pos[2] = posy
end
addEventHandler("onClientRender", getRootElement(), moveDebugRender)

function moveDebug(k, s)
    if k == "mouse1" and s then
        if isCursorInPos(pos[1] - 425, pos[2] - 15 * maxRow - 5, 850, 15 * maxRow + 15) and not cdm then
            local cpx, cpy = getCursorPosition()
            doffsetx, doffsety = cpx * screenX   - pos[1], cpy * screenY - pos[2]
            cdm = true
        end
    elseif k == "mouse1" and not s then
        cdm = false
    end
end
addEventHandler("onClientKey", getRootElement(), moveDebug)

local perm = getElementData(localPlayer, "adminLevel") >= 3

function addDebug(msg, level, file, line, client)
    if perm then
        if states[level] == false then
            return
        end
        if client == nil then
            client = false
        end
        if line == nil then
            line = 0
        end
        if file == nil then
            file = "Script"
        end

        local debugString = levels[level] .. ": " .. msg .. " [ " .. file .. " : " .. line .. " ]"
        if table.find(debugTable, debugString, 1) then
            local k = table.findIndex(debugTable, debugString, 1)
            debugTable[k][3] = debugTable[k][3] + 1
            table.sort(debugTable, function(a, b) return a[2] > b[2] end)
        else
            table.insert(debugTable, {debugString, #debugTable + 1, 1, client})
            table.sort(debugTable, function(a, b) return a[2] > b[2] end)
        end
    end
end
addEvent("addDebug", true)
addEventHandler("addDebug", getRootElement(), addDebug)

addEventHandler("onClientDebugMessage", root, 
    function(message, level, file, line)
        addDebug(message, level, file, line, true)
    end
)

function showDebug()
    if perm then
        if debug then
            debug = false
            outputChatBox("Kikapcsoltad a debugot.")
        else
            debug = true
            outputChatBox("Bekapcsoltad a debugot.")
        end
    end
end
addCommandHandler("debugon", showDebug)

function cDebug()
    debugTable = {}
end
addCommandHandler("cd", cDebug)


bindKey("pgup", "down",
    function()
        if currentRow > 1 then
            currentRow = currentRow - 1
        end
    end
)

bindKey("pgdown", "down",
    function()
        if currentRow < #debugTable - (maxRow - 1) then
            currentRow = currentRow + 1
        end 
    end
)

function table.find(t, v, n)
	for k, a in ipairs(t) do
		if a[n] == v then
			return true
		end
	end
	return false
end

function table.findIndex(t, v, n)
	for k, a in ipairs(t) do
		if a[n] == v then
			return k
		end
	end
	return false
end

function isCursorInPos(posX, posY, width, height)
	if isCursorShowing() then
		local mouseX, mouseY = getCursorPosition();
		local clientW, clientH = guiGetScreenSize();
		local mouseX, mouseY = mouseX * clientW, mouseY * clientH;
		if (mouseX > posX and mouseX < (posX+width) and mouseY > posY and mouseY < (posY+height)) then
			return true;
		end
	end
	return false;
end

function dxDrawBorderText(text, x, y, w, h, color, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
    originalText = text
    text = text:gsub("#......", "")
    dxDrawText(text, x - 1, y - 1, w - 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    dxDrawText(text, x - 1, y + 1, w - 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    dxDrawText(text, x + 1, y - 1, w + 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    dxDrawText(text, x + 1, y + 1, w + 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    dxDrawText(originalText, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end

local devState = false

addCommandHandler("devmode",
    function()
        devState = not devState

        setDevelopmentMode(devState)

        if devState then
            print("bekapcsoltad a dev modot")
        else
            print("Kikapcsoltad a dev modot")
        end
    end
)