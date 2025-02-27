local sX, sY = guiGetScreenSize()
local font = dxCreateFont("files/Roboto-Condensed.otf", 15)
local seconds = 300
local started = 0
local teamOneCount = 0
local teamTwoCount = 0

function sendKillInformationToClient(type, number)
    if type == 1 then
        teamOneKills = number
    elseif type == 2 then
        teamTwoKills = number
    end
end
addEvent("sendKillInformationToClient", true)
addEventHandler("sendKillInformationToClient", root, sendKillInformationToClient)

function sendTimeoutToClient(map)
    currentMap = map
    teamOneKills = 0
    teamTwoKills = 0

    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "a.Gamemode") == 1 then
            exports.a_loader:createLoadingScreen(5, "Next map", getElementData(localPlayer, "a.Gamemode"), 1)
        end
    end
end
addEvent("sendTimeoutToClient", true)
addEventHandler("sendTimeoutToClient", root, sendTimeoutToClient)

function giveCounter(second)
	if second > 0 then 
        serverClocking = second
	elseif second <= 0 then 
        serverClocking = false
	end
end
addEvent("giveCounter", true)
addEventHandler("giveCounter", getRootElement(), giveCounter)

function drawTime()
    if not (getElementData(localPlayer, "a.Gamemode") == 1) then 
        return 
    end
    
    local text = secondsToTime(serverClocking)
    local width = dxGetTextWidth(text, 1, font)
    roundedRectangle(sX / 2 - 100, 5, 200, 30, tocolor(30, 30, 30))
    dxDrawRectangle(sX / 2 - 95, 10, 35, 20, tocolor(220, 175, 125))
    dxDrawRectangle(sX / 2 + 60, 10, 35, 20, tocolor(125, 175, 220))

    dxDrawBorderedText(1, text, sX/2, 20, _, _, tocolor(255, 255, 255), 1, font, "center", "center")
    dxDrawBorderedText(1, teamOneKills or 0, sX / 2 + 77.5, 20, _, _, tocolor(255, 255, 255), 1, font, "center", "center")
    dxDrawBorderedText(1, teamTwoKills or 0, sX / 2 - 77.5, 20, _, _, tocolor(255, 255, 255), 1, font, "center", "center")
end
addEventHandler("onClientRender", root, drawTime)

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 200);
		end	

		if (not bgColor) then
			bgColor = borderColor;
		end

		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI); -- top
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI); -- bottom
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI); -- left
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI); -- right
	end
end

function secondsToTime(seconds)
	local seconds = tonumber(seconds)
    if not tonumber(seconds) then return "00:00" end
  	if seconds <= 0 then
		return "00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return mins..":"..secs
    end
end

function dxDrawBorderedText (outline, text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    for oX = (outline * -1), outline do
        for oY = (outline * -1), outline do
            dxDrawText (text, left + oX, top + oY, _, _, tocolor(0, 0, 0, 255), scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
        end
    end
    dxDrawText (text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end