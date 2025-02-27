function startSpectate(element)
	if element and isElement(element) and getElementType(element) == "player" then
		setElementData(element, "a.HUDShowed", false)
		showCursor(element, true)

		for _, v in ipairs(getElementsByType("player")) do
			if getElementData(v, "a.Gamemode") == 4 then
				if getElementData(v, "a.HPTeam") ~= nil and not (getElementData(v, "a.HPTeam") == 1) then
					setCameraTarget(element, v)
					triggerClientEvent("spectateStarted", element, element)
					break
				end
			end
		end
	end
end
addEvent("startSpectate", true)
addEventHandler("startSpectate", root, startSpectate)