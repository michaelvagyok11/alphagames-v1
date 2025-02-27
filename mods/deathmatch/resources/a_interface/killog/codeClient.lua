local sx, sy = guiGetScreenSize()
local boxSize = {300, 30}
local currentKillog = {}
local font = dxCreateFont("files/Roboto-Condensed.otf", 15)

function addKillog(source, target, weapon, bodypart)
    createKillog(source, target, weapon, bodypart)
end
addEvent("addKillog", true)
addEventHandler("addKillog", root, addKillog)

function createKillog(element, target, wep, bodyp)
    data = {element, target, wep, bodyp, getTickCount()}
    table.insert(currentKillog, data)
end

function removeHex (text, digits)
    assert (type (text) == "string", "Bad argument 1 @ removeHex [String expected, got "..tostring(text).."]")
    assert (digits == nil or (type (digits) == "number" and digits > 0), "Bad argument 2 @ removeHex [Number greater than zero expected, got "..tostring (digits).."]")
 return string.gsub (text, "#"..(digits and string.rep("%x", digits) or "%x+"), "")
end

function onRender()
    if not getElementData(localPlayer, "loggedIn") then return end
    if not (getElementData(localPlayer, "a.Gamemode") == 1) then return end
    for k, v in ipairs(currentKillog) do
        local killerName = getPlayerName(v[1])
        local wastedName = getPlayerName(v[2])
        
        if getElementData(v[1], "a.DMTeam") == "Terrorists" then
            prefix = "#D19D6B[T]"
        elseif getElementData(v[1], "a.DMTeam") == "Counter-Terrorists" then
            prefix = "#7DAFDC[CT]"
        else
            prefix = ""
        end

        
        if getElementData(v[2], "a.DMTeam") == "Terrorists" then
            prefix2 = "#D19D6B[T]"
        elseif getElementData(v[2], "a.DMTeam") == "Counter-Terrorists" then
            prefix2 = "#7DAFDC[CT]"
        else
            prefix2 = ""
        end

        local w = dxGetTextWidth(removeHex(killerName) .. "[" .. removeHex(prefix) .. "]", 1, font)
        local w2 = dxGetTextWidth(removeHex(wastedName) .. "[" .. removeHex(prefix2) .. "]", 1, font)

        if v[4] == 9 then
            width = 5 + w + 10 + 52 + w2 + 5
        else
            width = 5 + w + 52 + w2 + 5
        end

        local nowTick = getTickCount()
        local elapsedTime = nowTick - v[5]
        local duration = elapsedTime / 500

        x = interpolateBetween(sx + boxSize[1], 0, 0, sx - boxSize[1] - 15, 0, 0, duration, "OutBack")
        r, g, b = interpolateBetween(150, 150, 150, 45, 45, 45, duration/5, "Linear")



        --roundedRectangle(x - 2, sy - (boxSize[2] * k) - 20, boxSize[1] + 4, boxSize[2] + 4, tocolor(r, g, b))
        roundedRectangle(x, sy - ((boxSize[2] + 5) * k) - 18, boxSize[1], boxSize[2], tocolor(30, 30, 30))

        dxDrawText(killerName .. prefix, x + 5, sy - ((boxSize[2] + 5) * k) - 3, _, _, tocolor(200, 100, 100), 1, font, "left", "center", false, false, false, true)

        if v[4] == 9 then
            dxDrawImage(x + boxSize[1]/4 + 20, sy - ((boxSize[2] + 5) * k) - 15, 64, 25, "files/weapons/" .. v[3] .. ".png")
            dxDrawImage(x + boxSize[1]/2 + 15, sy - ((boxSize[2] + 5) * k) - 13, 20, 20, "files/icons/head.png", 0, 0, 0, tocolor(150, 150, 150))
        else
            dxDrawImage(x + boxSize[1]/4 + 20, sy - ((boxSize[2] + 5) * k) - 15, 64, 25, "files/weapons/" .. v[3] .. ".png")
        end

        dxDrawText(wastedName .. prefix2, x + boxSize[1] - 5, sy - ((boxSize[2] + 5) * k) - 3, _, _, tocolor(100, 100, 100), 1, font, "right", "center", false, false, false, true)

        if v[5] + 3500 < getTickCount() then
			table.remove(currentKillog, k)
		end
    end
end
addEventHandler("onClientRender", root, onRender)
--setTimer(onRender, 5, 0)