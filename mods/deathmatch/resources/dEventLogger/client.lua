local renderData = {}
renderData.pos = {}

renderData.pos.Sx, renderData.pos.Sy = guiGetScreenSize()

renderData.pos.eventlogX = renderData.pos.Sx - 300
renderData.pos.eventlogY = renderData.pos.Sy/2

local isMoving = false
local bgState = false
local movingOffsetX, movingOffsetY = 0, 0

local event_font = dxCreateFont("files/Ubuntu-Regular.ttf", 15, false, "antialiased")

local messages = {
    {"ez egy teszt, nagyjából olyan hosszú mint dzseki farka", 5, 255, 0}
}

function onStart()
	loadFeed()
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop()
	saveFeed()
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)

function dxDrawBorderText(text, x, y, w, h, color, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
    text2 = text:gsub("#......", "")
    dxDrawText(text2, x + 1, y + 1, w + 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
    dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end

addEventHandler("onClientRender", root, function()
    if not (getElementData(localPlayer, "loggedIn")) then return end

    if getElementData(localPlayer, "a.Gamemode") == 1 and bgState then
        dxDrawRectangle(renderData.pos.eventlogX, renderData.pos.eventlogY, 300, 200, tocolor(0, 0, 0, 100))
    end

    if (isCursorShowing() and isMoving) then
		local cursorX, cursorY = getCursorPosition();

		cursorX = cursorX * renderData.pos.Sx;
		cursorY = cursorY * renderData.pos.Sy;
		
		renderData.pos.eventlogX = cursorX - movingOffsetX;
		renderData.pos.eventlogY = cursorY - movingOffsetY;
	end
    
    for i=1, 10 do 
       if messages[i] == nil then return end
        if messages[i][4] > renderData.pos.eventlogY + (i * 18) - 18 then 
            messages[i][4] = messages[i][4] - 5
        else
            messages[i][4] = renderData.pos.eventlogY + (i * 18) - 18
        end
        dxDrawBorderText(messages[i][1], renderData.pos.eventlogX, messages[i][4], renderData.pos.eventlogX+295, renderData.pos.Sx, tocolor(255, 255, 255, messages[i][3]), tocolor(0, 0, 0, messages[i][3]), 1.0, event_font, "right", "top", false, false, false, true)
        --dxDrawText(messages[i][2] .. " " .. messages[i][3], eventlogX, messages[i][4], eventlogX+295, _, tocolor(255, 255, 255, messages[i][3]), 1.0, event_font, "left", "top", false, false, false, true)
        if messages[i][2] <= 0 then 
            if messages[i][3] > 0 then 
                messages[i][3] = messages[i][3] - 5
            else
                table.remove(messages, i)
            end
        end
    end
end)

setTimer(function()
    for i=1, #messages do

        messages[i][2] = messages[i][2] - 1
    end

end, 1000, 0)

function contains(string, table)
    local contains = false
    for i=1, #table do 
        if string == table[i] then 
            contains = true 
        end
    end

    return contains
end

addEvent("sendToEventLogger", true)
addEventHandler("sendToEventLogger", root, function(msg)
    if contains(msg, messages) then return end
    table.insert(messages, 1, {msg, 15, 255, 0})
end)

function editFeed(cmd, state)
    local state = state

    if not getElementData(localPlayer, "a.Gamemode") == 1 then
        exports.dInfobox:makeNotification(2, "Nem vagy a megfelelő játékmódban!")
        return
    end

    if not state then
        outputChatBox("#D9B45A► Használat: #FFFFFF/"..cmd.." [on/off]", 255, 255, 255, true)
        return
    end

    if getElementData(localPlayer, "a.Gamemode") == 1 and state == "on" and bgState == false then
        exports.dInfobox:makeNotification(1, "Beléptél a kill-feed szerkesztőbe!")
        bgState = true
    elseif getElementData(localPlayer, "a.Gamemode") == 1 and state == "on" and bgState == true then
        exports.dInfobox:makeNotification(2, "Már a kill-feed szerkesztőben vagy!")
    elseif getElementData(localPlayer, "a.Gamemode") == 1 and state == "off" and bgState == true then
        exports.dInfobox:makeNotification(1, "Kiléptél a kill-feed szerkesztőből!")
        bgState = false
    elseif getElementData(localPlayer, "a.Gamemode") == 1 and state == "off" and bgState == false then
        exports.dInfobox:makeNotification(2, "Nem vagy a kill-feed szerkesztőben!")
    end
end
addCommandHandler("editfeed", editFeed)

function resetFeed()
    renderData.pos.Sx, renderData.pos.Sy = guiGetScreenSize()
    renderData.pos.eventlogX = renderData.pos.Sx - 300
    renderData.pos.eventlogY = renderData.pos.Sy/2
end

function resetFeedCMD()
    resetFeed()
    exports.dInfobox:makeNotification(1, "Sikeresen visszaállítottad a kill-feeded!")
end
addCommandHandler("resetfeed", resetFeedCMD)

function loadFeed()
	if fileExists("feed.data") then
		local savefile = fileOpen("feed.data")

		if savefile then
			local savedata = fileRead(savefile, fileGetSize(savefile))

			if savedata then
				savedata = fromJSON(decodeString("tea", savedata, {key = "__DATAFILE__"}))
			end

			fileClose(savefile)

			if savedata then
				resetFeed()

				for k, v in pairs(savedata.pos) do
					renderData.pos[k] = tonumber(v)
				end
			end
		end
	end
end

function saveFeed()
	if getElementData(localPlayer, "loggedIn") then
		if fileExists("feed.data") then
		end

		local savedata = {
			pos = {},
		}

		for k, v in pairs(renderData.pos) do
			savedata.pos[k] = v
		end

		local savefile = fileCreate("feed.data")
		fileWrite(savefile, encodeString("tea", toJSON(savedata, true), {key = "__DATAFILE__"}))
		fileClose(savefile)
	end
end

addEventHandler('onClientClick', getRootElement(),
	function(button, state, cursorX, cursorY)
		if getElementData(localPlayer, "a.Gamemode") == 1 then
			if (button == 'left' and state == 'down') then
				if (cursorX >= renderData.pos.eventlogX and cursorX <= renderData.pos.eventlogX + renderData.pos.Sx and cursorY >= renderData.pos.eventlogY and cursorY <= renderData.pos.eventlogY + renderData.pos.Sy) then
					isMoving = true;
					movingOffsetX = cursorX - renderData.pos.eventlogX;
					movingOffsetY = cursorY - renderData.pos.eventlogY;
				end
			else
				isMoving = false;
			end
		end
	end
)