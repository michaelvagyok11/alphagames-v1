colors = {
    ["server"] = {"#D19D6B", 210, 160, 110},
    ["red"] = {"#E48F8F", 230, 140, 140},
    ["blue"] = {"#8FC3E4", 140, 195, 230},
    ["green"] = {"#9BE48F", 155, 230, 140},
    ["grey"] = {"#C8C8C8", 200, 200, 200},
}

function getColor(color, type)
    if color and type then
        if type == "hex" then
            return colors[color][1]
        elseif type == "rgb" then
            return {colors[color][1], colors[color][2], colors[color][3], 255}
        end
    end
end

developers = {
    ["8A0BC075A35352D27E0D959CE91809A4"] = true, -- michael
}

function isPlayerDeveloper(serial)
    if serial then
       	if developers[serial] then
			return true
	   	else
			return false
        end
    end
end

function findPlayer(thePlayer, nick, msg, tipus)
	if not tipus then tipus = 1 end
	local byID = false
	if not nick and not isElement(thePlayer) and type( thePlayer ) == "string" then
		--outputChatBox( "#E48F8F[Hiba]: #FFFFFFHibás paraméterek lettek megadva.", thePlayer, 255, 255, 255, true)
		return
	end

	if tonumber(nick) ~= nil then
		byID = true
	else
		byID = false
	end

	if nick == "*" then return thePlayer end

	local tempTable = {}
	if not byID then
		nick = string.gsub(nick, " ", "_")
		nick = string.lower(nick)
		for key, value in ipairs(getElementsByType("player")) do
			local playerName = string.lower(getElementData(value, "a.PlayerName"))
			local playerName2 = getElementData(value, "a.PlayerName")
			if string.find(playerName, tostring(nick)) then
				local stringStart, stringEnd = string.find(playerName, tostring(nick))
				if tonumber(stringStart) > 0 and tonumber(stringEnd) > 0 then
					tempTable[#tempTable + 1] = {value, playerName2}
				end
			end
		end
	else
		nick = tonumber(nick) or 0
		for key, value in ipairs(getElementsByType("player")) do
			local playerID = tonumber(getElementData(value, "playerid")) or 0
			local playerName2 = getElementData(value, "a.PlayerName")
			if playerID == nick then
				tempTable[#tempTable + 1] = {value, playerName2}
			end
		end
	end
	
	if #tempTable == 1 then
		return tempTable[#tempTable][1], tempTable[#tempTable][2]
	elseif #tempTable == 0 then
		if not msg then
			if tipus == 1 then
				--outputChatBox("#E48F8F[Hiba]: #FFFFFFNem található játékos ilyen névvel.", thePlayer, 255, 255, 255, true)
			else
				--outputChatBox("#E48F8F[Hiba]: #FFFFFFNem található játékos ilyen névvel.", thePlayer, 255, 255, 255, true)
			end
		end
		return false
	else
		if tipus == 1 then
			for k,v in ipairs(tempTable) do
				local vid = tonumber(getElementData(v[1], "playerid")) or 0
				--outputChatBox(v[2] .. " - [" .. vid .. "]", thePlayer, 255, 0, 0)
			end
		else
			--outputChatBox("#E48F8F[Hiba]: #FFFFFFTöbb játékos is található ezzel a névrészlettel.", 255, 255, 255, true)
			for k,v in ipairs(tempTable) do
				local vid = tonumber(getElementData(v[1], "playerid")) or 0
				--outputChatBox(v[2] .. " - [" .. vid .. "]", 255, 255, 255, true)
			end
		end
		return false
	end
	return false
end