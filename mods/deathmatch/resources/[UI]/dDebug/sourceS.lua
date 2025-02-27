local developers = {}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		for k, v in pairs(getElementsByType("player")) do
			local adminLevel = getElementData(v, "adminLevel") or 0
			if adminLevel >= 3 then
				table.insert(developers, v)
			end
		end
	end)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		if (getElementData(source, "adminLevel") or 0) >= 3 then
			local temp = {}

			for i = 1, #developers do
				if developers[i] ~= source then
					table.insert(temp, developers[i])
				end
			end

			developers = temp
		end
	end)

addEventHandler("onElementDataChange", getRootElement(),
	function (dataName, oldValue)
		if dataName == "adminLevel" then
			local adminLevel = getElementData(source, "adminLevel") or 0
			if adminLevel >= 3 then
				table.insert(developers, source)
			else
				local temp = {}

				for i = 1, #developers do
					if developers[i] ~= source then
						table.insert(temp, developers[i])
					end
				end

				developers = temp
			end
		end
	end)

addEventHandler("onDebugMessage", getRootElement(),
	function (message, level, file, line, r, g, b)
		local color = false

		if level == 1 then
			level = "[ERROR] "
			color = tocolor(215, 89, 89)
		elseif level == 2 then
			level = "[WARNING] "
			color = tocolor(255, 150, 0)
		elseif level == 3 then
			level = "[INFO] "
			color = tocolor(124, 197, 118)
		else
			level = "[INFO] "
			color = tocolor(r, g, b)
		end

		if file and line then
			triggerLatentClientEvent(developers, "addDebugLine", resourceRoot, level .. file .. ":" .. line .. ", " .. message, color)
		else
			triggerLatentClientEvent(developers, "addDebugLine", resourceRoot, level .. message, color)
		end
	end)