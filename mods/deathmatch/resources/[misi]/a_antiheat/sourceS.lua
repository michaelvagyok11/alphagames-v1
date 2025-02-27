addEvent("requestBan", true)
addEventHandler("requestBan", getRootElement(),
	function (dataName) 
		return banPlayer(client, true, true, true, "anticheat", "client-side elementdata change", 0)
	end 
)

addEvent("changeDataSync", true)
addEventHandler("changeDataSync", getRootElement(),
  function (dataName, newVal, oldVal)
    --iprint(dataName, oldVal, newVal)

    if not newVal then 
      setElementData(source, dataName, false)
    elseif newVal == true then
      setElementData(source, dataName, true)
    elseif newVal == nil then 
      setElementData(source, dataName, nil)
    else
      setElementData(source, dataName, newVal)
    end
  end
)

local whitelistedKeys = {
    ["afk"] = true
}

addEventHandler("onElementDataChange", getRootElement(),
    function(theKey, oldValue, newValue)
        if client then
            if not whitelistedKeys[theKey] then
                setElementData(source, theKey, oldValue)
                kickPlayer(client, "ALPHAGAMES - ILLEGAL EDATA CHANGE")
                iprint(source, theKey, oldValue)
            end
        end
    end
)

addEvent("secureClient", true)
addEventHandler("secureClient", getRootElement(),
	function (injectedClient, injectedCode)
		triggerClientEvent(injectedClient, "securedClient", source, injectedCode)
	end 
)