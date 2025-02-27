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

local sX, sY = guiGetScreenSize()
local panelSize = {300, 300}
local panelState = "closed"

local scrollingValue = 0
local maxRadiosShowed = 5

local robotoRegular11 = dxCreateFont("files/fonts/Roboto-Condensed.ttf", 11, false, "antialiased")
local robotoThin11 = dxCreateFont("files/fonts/Roboto-Thin.ttf", 11, false, "antialiased")

function openPanel()
    if panelState == "opened" then
        panelState = "closed"
        openTick = getTickCount()
        removeEventHandler("onClientRender", root, onRender)
        removeEventHandler("onClientKey", root, onKey)
        removeEventHandler("onClientClick", root, onClick)
    else
        panelState = "opened"
        --panelMoving = false
        openTick = getTickCount()
        soundChangeTick = getTickCount()
        addEventHandler("onClientRender", root, onRender)
        addEventHandler("onClientKey", root, onKey)
        addEventHandler("onClientClick", root, onClick)
        currentPlayingRadio = 1
        if not startX and not startY then
            startX, startY = sX - panelSize[1] - 15, sY - panelSize[2] - 15
        end
    end
end
addCommandHandler("setmusicvol", openPanel)
addCommandHandler("music", openPanel)


local sx2, sy2 = guiGetScreenSize();
local bx, by = panelSize[1] - 20, panelSize[2] - 130
local boxes = 200;
local startColor, endColor = {75, 115, 70}, {230, 140, 140}

function onRender()
    if panelState == "opened" then
        local nowTick = getTickCount()
        local elapsedTime = nowTick - openTick
        local duration = elapsedTime / 1000


        if panelMoving == true then
            local cx, cy = getCursorPosition()
            startX = cx * sX - panelSize[1] + 10
            startY = cy * sY
        end
        a = interpolateBetween(0, 0, 0, 220, 0, 0, duration, "Linear")

        exports.a_core:dxDrawRoundedRectangle(startX, startY, panelSize[1], panelSize[2] - 30, tocolor(65, 65, 65, a), 5)
        exports.a_core:dxDrawRoundedRectangle(startX + 2, startY + 2, panelSize[1] - 4, panelSize[2] - 34, tocolor(35, 35, 35, a), 5)
        exports.a_core:dxDrawRoundedRectangle(startX, startY, panelSize[1], 25, tocolor(65, 65, 65, a), 5)
        dxDrawImage(startX + panelSize[1] - 20, startY + 5, 16, 16, "files/img/move.png", 0, 0, 0, tocolor(100, 100, 100, a))
        dxDrawText("#D19D6Balpha#c8c8c8Games - Radio", startX + 5, startY + 25/2, _, _, tocolor(200, 200, 200, a), 1, robotoRegular11, "left", "center", false, false, false, true)

        exports.a_core:dxDrawRoundedRectangle(startX + 10, startY + 30, panelSize[1] - 20, panelSize[2] - 155, tocolor(50, 50, 50, a), 5)
        exports.a_core:dxDrawRoundedRectangle(startX + 100, startY + panelSize[2] - 95, panelSize[1] - 200, 30, tocolor(80, 80, 80, a), 10)
         
        dxDrawRectangle(startX + 20, startY + panelSize[2] - 60, panelSize[1] - 40, 10, tocolor(25, 25, 25, a))
        if isElement(currentRadio) then
            local size = getSoundVolume(currentRadio)
            local sound = getSoundVolume(currentRadio)
            if soundChangeTick then
                width = interpolateBetween(width or 0, 0, 0, (panelSize[1] - 42)*size, 0, 0, (nowTick - soundChangeTick)/250, "InQuad")
                sound = interpolateBetween(soundOldValue or 0, 0, 0, sound, 0, 0, (nowTick - soundChangeTick)/250, "InQuad")
            else
                width = (panelSize[1] - 42)*size                
            end
            dxDrawRectangle(startX + 20 + 1, startY + panelSize[2] - 60 + 1, width, 10 - 2, tocolor(155, 230, 140, a))
            dxDrawText(tostring(math.floor(sound*100)) .. "%", startX + 20 + 1, startY + panelSize[2] - 80 + 1, _, _, tocolor(155, 230, 140, a), 1, robotoRegular11)

            if isMouseInPosition(startX + 100 + (panelSize[1] - 200)/2 - 8, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16) then
                dxDrawImage(startX + 100 + (panelSize[1] - 200)/2 - 8, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16, "files/img/pause.png", 0, 0, 0, tocolor(200, 200, 200, a))
            else
                dxDrawImage(startX + 100 + (panelSize[1] - 200)/2 - 8, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16, "files/img/pause.png", 0, 0, 0, tocolor(120, 120, 120, a))
            end
        else
            if isMouseInPosition(startX + 100 + (panelSize[1] - 200)/2 - 8, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16) then
                dxDrawImage(startX + 100 + (panelSize[1] - 200)/2 - 8, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16, "files/img/start.png", 0, 0, 0, tocolor(200, 200, 200, a))
            else
                dxDrawImage(startX + 100 + (panelSize[1] - 200)/2 - 8, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16, "files/img/start.png", 0, 0, 0, tocolor(120, 120, 120, a))
            end
        end

        for k, v in ipairs(radioLinks) do
            if k <= maxRadiosShowed and (k > scrollingValue) then
                exports.a_core:dxDrawRoundedRectangle(startX + 15, startY + 35 + (k-1-scrollingValue)*27, panelSize[1] - 30, 25, tocolor(20, 20, 20, a), 5)

                if currentPlayingRadio == k then
                    exports.a_core:dxDrawRoundedRectangle(startX + 15, startY + 35 + (k-1-scrollingValue)*27, panelSize[1] - 30, 25, tocolor(105, 80, 55, a), 5)
                end
                dxDrawText("#D19D6B(" .. k .. ") #c8c8c8" .. v[1], startX + 22, startY + 35 + (k-1-scrollingValue)*27 + 25/2, _, _, tocolor(200, 200, 200, a), 1, robotoRegular11, "left", "center", false, false, false, true)
            end
        end
    

        if isMouseInPosition(startX + 100 + panelSize[2] - 220, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16) then
            dxDrawImage(startX + 100 + panelSize[2] - 220, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16, "files/img/arrow.png", 0, 0, 0, tocolor(200, 200, 200, a))
        else
            dxDrawImage(startX + 100 + panelSize[2] - 220, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16, "files/img/arrow.png", 0, 0, 0, tocolor(120, 120, 120, a))
        end
            
        if isMouseInPosition(startX + 105, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16) then
            dxDrawImage(startX + 105, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16, "files/img/arrow.png", 180, 0, 0, tocolor(200, 200, 200, a))
        else
            dxDrawImage(startX + 105, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16, "files/img/arrow.png", 180, 0, 0, tocolor(120, 120, 120, a))
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
            dxDrawText(musicName, startX + panelSize[1]/2, startY + panelSize[2] - 105, _, _, tocolor(200,200, 200, a), 1, robotoRegular11, "center", "center")
        else
            musicName = "-"
            dxDrawText(musicName, startX + panelSize[1]/2, startY + panelSize[2] - 105, _, _, tocolor(200,200, 200, a), 1, robotoRegular11, "center", "center")
        end
        --[[if isElement(currentRadio) and not isSoundPaused(currentRadio) then
			local soundFFT = getSoundFFTData(currentRadio, 16384, 256) or {};
			if (soundFFT) then
				local l = sX/2 - bx/2
				local t = sY/2 + by/2
				local w = bx/boxes
	
				local soundVolume = getSoundVolume(currentRadio);
				local multipler = 5 * (soundVolume)
				for i = 0, boxes do
					if (soundFFT) ~= nil then
						local numb = soundFFT[i] or 0
						sr = (numb * multipler) or 0
	
						if sr > 0 then
							r, g, b = interpolateBetween(startColor[1], startColor[2], startColor[3], endColor[1], endColor[2], endColor[3], sr, "Linear")
							dxDrawRectangle(startX + 5 + i * w, startY + panelSize[2] - 5, 2, -(sr * 50), tocolor(r, g, b, a))
						end	
					end
				end
				--if r and g and b and sr then
                    if currentRadio then
                        local details = getSoundMetaTags(currentRadio)
                        local musicName = details["title"]
                        if not musicName then
                            musicName = details["stream_title"]
                            if not musicName then
                                musicName = "Ismeretlen zene cím"
                            end
                        end
                        dxDrawText(musicName, startX + panelSize[1]/2, startY + panelSize[2] - 105, _, _, tocolor(200,200, 200, a), 1, robotoRegular11, "center", "center")
                    else
                        musicName = "-"
                        dxDrawText(musicName, startX + panelSize[1]/2, startY + panelSize[2] - 105, _, _, tocolor(200,200, 200, a), 1, robotoRegular11, "center", "center")
                    end
				--end
			end
		end]]--
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
        if state == "down" and isMouseInPosition(startX + 5 + panelSize[1] - 22, startY + 5, 24, 24) then
            panelMoving = true
        end
            
        if state == "up" then
            panelMoving = false
        end
    end
    if button == "left" and state == "down" then
        if isMouseInPosition(startX + 100 + panelSize[2] - 220, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16) then
            if currentPlayingRadio + 1 > #radioLinks then
                currentPlayingRadio = #radioLinks
                changePlayersRadio(radioLinks[currentPlayingRadio][2])
            else
                currentPlayingRadio = currentPlayingRadio + 1
                changePlayersRadio(radioLinks[currentPlayingRadio][2])
            end
        end

        if isMouseInPosition(startX + 20 + 1, startY + panelSize[2] - 60 + 1, (panelSize[1] - 42), 10 - 2) then
            local cx, cy = getCursorPosition()
            local cx, cy = cx*sX, cy*sY
            soundOldValue = getSoundVolume(currentRadio)
            local newSound = math.floor(getDistanceBetweenPoints2D((startX + 20 + 1)/1920*sX, (startY + panelSize[2] - 60 + 1)/1080*sY, cx, cy) * 1) / ((panelSize[1] - 42)/1920*sX)
            
            if newSound <= 100 then
                soundChangeTick = getTickCount()
                soundVolume = newSound
                setSoundVolume(currentRadio, newSound)
            end
        end

        if isMouseInPosition(startX + 100 + (panelSize[1] - 200)/2 - 8, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16) then
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

        if isMouseInPosition(startX + 105, startY + panelSize[2] - 95 + 30/4 - 2, 16, 16) then
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
                if isMouseInPosition(startX + 15, startY + 35 + (k-1-scrollingValue)*27, panelSize[1] - 30, 25) then
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