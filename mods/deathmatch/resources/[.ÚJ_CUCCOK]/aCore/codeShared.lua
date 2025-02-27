function findPlayer(executerElement, targetElement)
	if not (executerElement) or not (isElement(executerElement)) or not (targetElement) or not (isElement(targetElement)) then
		return false
	end

	if tostring(targetElement) == nil then
		for i, v in ipairs(getElementsByType("player")) do
			local currentPlayerName = tonumber(getElementData(v, "a.PlayerID"))
			if currentPlayerName == tonumber(targetElement) then
				return v
			end
		end
	elseif (tostring(targetElement)) then
		if tostring(targetElement) == "*" then
			return executerElement
		end
	
		for i, v in ipairs(getElementsByType("player")) do
			local currentPlayerName = string.lower(getPlayerName(v))
			if string.find(currentPlayerName, tostring(targetElement)) then
				return v
			end
		end
	end
end