radioLinks = {
    {"Danubius Radio", "https://stream.danubiusradio.hu:443/danubius_192k"},
    {"Klubradio", "https://stream.klubradio.hu:8443/bpstream"},
    {"Mercy Radio", "http://stream.mercyradio.eu:80/mercyradio.mp3"},
    {"Mulatos Radio", "https://stream.lazaradio.com/mulatos.mp3?time=1659552564495"},
    {"Radio 88", "http://www.radio88.hu/stream/radio88.pls"},
    {"Retro Radio", "https://icast.connectmedia.hu/5001/live.mp3"},
    {"Radio 1", "https://icast.connectmedia.hu/5201/live.mp3"},
    {"Slager FM", "http://92.61.114.159:7812/slagerfm256.mp3"},
    {"KroneHit", "http://relay.181.fm:8068"},
    {"Old School", "http://relay.181.fm:8068"},
    {"Radio HiT", "http://asculta.radiohitfm.ro:8340/listen.pls"},
    {"Hard Techno", "http://tunein.t4e.dj/hard/dsl/mp3"},
    {"Hip Hop", "http://sverigesradio.se/topsy/direkt/2576-hi-aac.pls"},
    {"Uzic - Techo/Minimal", "http://stream.uzic.ch:9010/listen.pls"},
    {"idobi Howl", "http://69.46.88.26:80/listen.pls"},
    {"HOT 108 Jamz", "http://108.61.30.179:4010/listen.pls"},
	{"Balaton Radio", "http://wssgd.gdsinfo.com:8200/listen.pls"},
	{"Sunshine FM", "http://195.56.193.129:8100/listen.pls"},
	{"90's dance", "http://listen.181fm.com/181-90sdance_128k.mp3"},
	{"Awesome 80's", "http://www.181.fm/winamp.pls?station=181-awesome80s&file=181-awesome80s.pls"},
	{"Star 90's", "http://www.181.fm/winamp.pls?station=181-star90s&file=181-star90s.pls"},
	{"PopTron", "http://somafm.com/wma128/poptron.asx"},
	{"UK top 40", "http://www.181.fm/winamp.pls?station=181-uktop40&file=181-uktop40.pls"},
	{"The Mix", "http://www.181.fm/winamp.pls?station=181-themix&file=181-themix.pls"},
	{"The Vibe of Vegas", "http://www.181.fm/winamp.pls?station=181-vibe&file=181-vibe.pls"},
	{"BlackBeats FM", "http://blackbeats.fm/listen.m3u"},
	{"Classic RAP Radio", "http://listen.radionomy.com/classic-rap.m3u"},
	{"Old School Hip Hop", "http://www.181.fm/winamp.pls?station=181-oldschool&file=181-oldschool.pls"},
	{"Ibiza Global Radio", "http://ibizaglobalradio.streaming-pro.com:8024/listen.pls"},
	{"Bassjunkees", "http://space.ducks.invasion.started.at.bassjunkees.com:8442/listen.pls"},
	{"fnoobtechno", "http://play.fnoobtechno.com:2199/tunein/fnoobtechno320.pls"},
}

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

function getResponsiveMultipler()
	return responsiveMultipler
end

local sizeX, sizeY = respc(500), respc(275)
local startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
local panelState = "closed"

local scrollingValue = 0
local maxRadiosShowed = 6

local robotoRegular11 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(11), false, "cleartype")

local barlowBold12 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(12), false, "cleartype")
local barlowRegular12 = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(12), false, "cleartype")

local robotoThin11 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(11), false, "cleartype")

function openPanel()
    if panelState == "opened" then
        panelState = "closed"
        openTick = getTickCount()
        removeEventHandler("onClientRender", root, onRender)
        removeEventHandler("onClientKey", root, onKey)
        removeEventHandler("onClientClick", root, onClick)
    else
        if getElementData(localPlayer, "loggedIn") == true then
            panelState = "opened"
            --panelMoving = false
            openTick = getTickCount()
            soundChangeTick = getTickCount()
            addEventHandler("onClientRender", root, onRender)
            addEventHandler("onClientKey", root, onKey)
            addEventHandler("onClientClick", root, onClick)
            currentPlayingRadio = 1
            if not startX and not startY then
                startX, startY = sX / 2 - sizeX / 2, sY / 2 - sizeY / 2;
            end
        end
    end
end
addCommandHandler("setmusicvol", openPanel)
addCommandHandler("music", openPanel)

--setTimer(openPanel, 500, 1)




local sx2, sy2 = guiGetScreenSize();
local bx, by = sizeX, sizeY
local boxes = 30;
local startColor, endColor = {35, 35, 35}, {230, 140, 140}

function onRender()
    if panelState == "opened" then
        local nowTick = getTickCount()
        local elapsedTime = nowTick - openTick
        local duration = elapsedTime / 500


        if panelMoving == true then
            local cx, cy = getCursorPosition()
            startX = cx * sX - sizeX + 10
            startY = cy * sY
        end
        a = interpolateBetween(0, 0, 0, 255, 0, 0, duration, "Linear")

        dxDrawRoundedRectangle(startX, startY, sizeX, sizeY, 3, tocolor(35, 35, 35, a))

        dxDrawRoundedRectangle(startX + respc(5), startY + respc(5), sizeX - respc(10), sizeY - respc(75), 3, tocolor(50, 50, 50, a))
        if isElement(currentRadio) and not isSoundPaused(currentRadio) then
			local soundFFT = getSoundFFTData(currentRadio, 16384, 256) or {};
			if (soundFFT) then
				local l = sX/2 - bx/2
				local t = sY/2 + by/2
				local w = bx/boxes
	
				local soundVolume = getSoundVolume(currentRadio);
				local multipler = 10 * (soundVolume)
				for i = 0, boxes do
					if (soundFFT) ~= nil then
						local numb = soundFFT[i] or 0
						sr = (numb * multipler) or 0
	
						if sr > 0 then
							r, g, b = interpolateBetween(startColor[1], startColor[2], startColor[3], endColor[1], endColor[2], endColor[3], sr, "Linear")
							dxDrawRectangle(startX + i * (w -1), startY + sizeY - 2, w - 2, -(sr * 100), tocolor(r, g, b, a*0.3))
						end	
					end
				end
			end
		end
        --dxDrawRoundedRectangle(startX + 100, startY + sizeY - 95, sizeX - 200, 30, 3, tocolor(80, 80, 80, a))
        --dxDrawRectangle(startX + 20, startY + sizeY - 60, sizeX - 40, 10, tocolor(25, 25, 25, a))

        if isElement(currentRadio) then
            local size = getSoundVolume(currentRadio)
            local sound = getSoundVolume(currentRadio)
            if soundChangeTick then
                width = interpolateBetween(width or 0, 0, 0, (sizeX - 42)*size, 0, 0, (nowTick - soundChangeTick)/250, "InQuad")
                sound = interpolateBetween(soundOldValue or 0, 0, 0, sound, 0, 0, (nowTick - soundChangeTick)/250, "InQuad")
            else
                width = (sizeX - 42)*size                
            end
            --dxDrawRectangle(startX + 20 + 1, startY + sizeY - 60 + 1, width, 10 - 2, tocolor(155, 230, 140, a))
            --dxDrawText(tostring(math.floor(sound*100)) .. "%", startX + 20 + 1, startY + sizeY - 80 + 1, _, _, tocolor(155, 230, 140, a), 1, robotoRegular11)

            if isMouseInPosition(startX + sizeX / 2 - respc(15), startY + sizeY - respc(35), respc(30), respc(30)) then
                dxDrawImage(startX + sizeX / 2 - respc(15), startY + sizeY - respc(35), respc(30), respc(30), "files/img/pause.png", 0, 0, 0, tocolor(150, 150, 150, a))
            else
                dxDrawImage(startX + sizeX / 2 - respc(15), startY + sizeY - respc(35), respc(30), respc(30), "files/img/pause.png", 0, 0, 0, tocolor(100, 100, 100, a))
            end
        else
            if isMouseInPosition(startX + sizeX / 2 - respc(15), startY + sizeY - respc(35), respc(30), respc(30)) then
                dxDrawImage(startX + sizeX / 2 - respc(15), startY + sizeY - respc(35), respc(30), respc(30), "files/img/start.png", 0, 0, 0, tocolor(150, 150, 150, a))
            else
                dxDrawImage(startX + sizeX / 2 - respc(15), startY + sizeY - respc(35), respc(30), respc(30), "files/img/start.png", 0, 0, 0, tocolor(100, 100, 100, a))
            end
        end

        for k, v in ipairs(radioLinks) do
            if k <= maxRadiosShowed and (k > scrollingValue) then
                if isMouseInPosition(startX + respc(10), startY + respc(10) + (k-1-scrollingValue)*respc(31.5), sizeX - respc(20), respc(30)) or currentPlayingRadio == k then
                    dxDrawRoundedRectangle(startX + respc(10), startY + respc(10) + (k-1-scrollingValue)*respc(31.5), sizeX - respc(20), respc(30), 3, tocolor(230, 140, 140, a*0.5))
                    dxDrawText("#E48F8F(" .. k .. ") #c8c8c8" .. v[1], startX + respc(10) + respc(10), startY + respc(10) + (k-1-scrollingValue)*respc(31.5) + respc(15), _, _, tocolor(200, 200, 200, a), 1, barlowBold12, "left", "center", false, false, false, true)
                else
                    dxDrawRoundedRectangle(startX + respc(10), startY + respc(10) + (k-1-scrollingValue)*respc(31.5), sizeX - respc(20), respc(30), 3, tocolor(25, 25, 25, a))
                    dxDrawText("#E48F8F(" .. k .. ") #c8c8c8" .. v[1], startX + respc(10) + respc(10), startY + respc(10) + (k-1-scrollingValue)*respc(31.5) + respc(15), _, _, tocolor(200, 200, 200, a), 1, barlowRegular12, "left", "center", false, false, false, true)
                end
            end
        end
    

        if isMouseInPosition(startX + sizeX / 2 + respc(15), startY + sizeY - respc(27.5), respc(16), respc(16)) then
            dxDrawImage(startX + sizeX / 2 + respc(15), startY + sizeY - respc(27.5), respc(16), respc(16), "files/img/arrow.png", 0, 0, 0, tocolor(150, 150, 150, a))
        else
            dxDrawImage(startX + sizeX / 2 + respc(15), startY + sizeY - respc(27.5), respc(16), respc(16), "files/img/arrow.png", 0, 0, 0, tocolor(100, 100, 100, a))
        end
            
        if isMouseInPosition(startX + sizeX / 2 - respc(35), startY + sizeY - respc(27.5), respc(16), respc(16)) then
            dxDrawImage(startX + sizeX / 2 - respc(35), startY + sizeY - respc(27.5), respc(16), respc(16), "files/img/arrow.png", 180, 0, 0, tocolor(150, 150, 150, a))
        else
            dxDrawImage(startX + sizeX / 2 - respc(35), startY + sizeY - respc(27.5), respc(16), respc(16), "files/img/arrow.png", 180, 0, 0, tocolor(100, 100, 100, a))
        end

        if isElement(currentRadio) then
            local details = getSoundMetaTags(currentRadio)
            local musicName = details["title"]
            if not musicName then
                musicName = details["stream_title"]
                if not musicName then
                    musicName = "Ismeretlen zene cím"
                end
            end
            dxDrawText(musicName, startX + sizeX/2, startY + sizeY - respc(50), _, _, tocolor(200,200, 200, a), 1, barlowRegular12, "center", "center")
        else
            musicName = "-"
            dxDrawText(musicName, startX + sizeX/2, startY + sizeY - respc(50), _, _, tocolor(200,200, 200, a), 1, barlowRegular12, "center", "center")
        end
    end
end

function onKey(key, press)
    if not (panelState == "opened") then
        return
    end

    if key == "mouse_wheel_up" then
        if scrollingValue > 0  then
            scrollingValue = scrollingValue - 1
            maxRadiosShowed = maxRadiosShowed - 1
        end
    elseif key == "mouse_wheel_down" then
        if maxRadiosShowed < (#radioLinks) then
            scrollingValue = scrollingValue + 1
            maxRadiosShowed = maxRadiosShowed + 1
        end
    end
end

function onClick(button, state)
    if button == "left" then
        if state == "down" and isMouseInPosition(startX + 5 + sizeX - 22, startY + 5, 24, 24) then
            panelMoving = true
        end
            
        if state == "up" then
            panelMoving = false
        end
    end
    if button == "left" and state == "down" then
        if isMouseInPosition(startX + sizeX / 2 + respc(15), startY + sizeY - respc(27.5), respc(16), respc(16)) then
            if currentPlayingRadio + 1 > #radioLinks then
                currentPlayingRadio = #radioLinks
                changePlayersRadio(radioLinks[currentPlayingRadio][2])
            else
                currentPlayingRadio = currentPlayingRadio + 1
                changePlayersRadio(radioLinks[currentPlayingRadio][2])
            end
        end

        if isMouseInPosition(startX + 20 + 1, startY + sizeY - 60 + 1, (sizeX - 42), 10 - 2) then
            local cx, cy = getCursorPosition()
            local cx, cy = cx*sX, cy*sY
            soundOldValue = getSoundVolume(currentRadio)
            local newSound = math.floor(getDistanceBetweenPoints2D((startX + 20 + 1)/1920*sX, (startY + sizeY - 60 + 1)/1080*sY, cx, cy) * 1) / ((sizeX - 42)/1920*sX)
            
            if newSound <= 100 then
                soundChangeTick = getTickCount()
                soundVolume = newSound
                setSoundVolume(currentRadio, newSound)
            end
        end

        if isMouseInPosition(startX + sizeX / 2 - respc(15), startY + sizeY - respc(35), respc(30), respc(30)) then
            if soundState == "started" then
                stopSound(currentRadio)
                currentPlayingRadio = 1
                soundState = "stopped"
            else
                changePlayersRadio(radioLinks[1][2])
                currentPlayingRadio = 1
                soundState = "started"
            end
        end

        if isMouseInPosition(startX + sizeX / 2 - respc(35), startY + sizeY - respc(27.5), respc(16), respc(16)) then
            if currentPlayingRadio - 1 < 1 then
                currentPlayingRadio = 1
                changePlayersRadio(radioLinks[currentPlayingRadio][2])
            else
                currentPlayingRadio = currentPlayingRadio - 1
                changePlayersRadio(radioLinks[currentPlayingRadio][2])
            end
        end
        for k, v in ipairs(radioLinks) do
            if k <= maxRadiosShowed and (k > scrollingValue) then
                if isMouseInPosition(startX + 15, startY + 35 + (k-1-scrollingValue)*27, sizeX - 30, 25) then
                    currentPlayingRadio = k
                    changePlayersRadio(v[2])
                end
            end
        end
    end
end

function changePlayersRadio(link)
    if link then
        if isElement(currentRadio) then
            stopSound(currentRadio)
        end
        currentRadio = playSound(link)
        soundState = "started"
        if soundVolume then
            setSoundVolume(currentRadio, soundVolume)
        else
            setSoundVolume(currentRadio, 0.5)
        end
    end
end

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