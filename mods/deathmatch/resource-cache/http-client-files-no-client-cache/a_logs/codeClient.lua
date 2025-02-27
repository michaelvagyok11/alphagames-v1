function createDCLog(message, type)
	if (message) and (type) then
		triggerServerEvent("createDCLog", resourceRoot, message, type)
	end
end

