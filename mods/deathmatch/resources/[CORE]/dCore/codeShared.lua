colors = {
    ["server"] = {"#B2CE67", 180, 205, 100},
    ["red"] = {"#E48F8F", 230, 140, 140},
    ["blue"] = {"#8FC3E4", 140, 195, 230},
    ["green"] = {"#9BE48F", 155, 230, 140},
    ["gray"] = {"#E3CFAF", 225, 210, 175},
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
    ["B21EE0915EBF4AE599D496503E1CC852"] = true, -- maybe george
    ["7D452DDE356827F83087CC96273BFC71"] = true, -- toni
    ["53987DDB582C0AC8B9CCD506656ACD13"] = true, -- dzseki
	["2A4DA2DCA79AFF12BB2F0970274D4603"] = true, -- akos(miliomos)
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

function findPlayer(executerElement, targetElement)
	if not executerElement or not targetElement then
		return false
	end

	if tostring(targetElement) == "*" then
		return executerElement
	end

	local targetElement2 = tonumber(targetElement)
	if targetElement2 then
		print("num " .. targetElement)
		for i, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "d/PlayerID") == tonumber(targetElement) then
				return v		
			end
		end
	else
		for i, v in ipairs(getElementsByType("player")) do
			if (string.find(getElementData(v, "a.PlayerName"), tostring(targetElement))) then
				return v			
			end
		end
	end
end