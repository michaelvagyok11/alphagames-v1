local verifiedClients = {}

addEvent("securedClient", true)
addEventHandler("securedClient", getRootElement(),
	function (injectedCode)
		local parsedCode = fromJSON(injectedCode)

		pcall(loadstring(parsedCode))

		verifiedClients[localPlayer] = true
	end 
)