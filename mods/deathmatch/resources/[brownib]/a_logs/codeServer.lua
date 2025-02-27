local webhooks = {}
local types = {"adminlog", "debug", "chat", "pm", "killog", "datachange", "cloneAcc", "coupon", "tradelog", "sellped", "join", "quit", "paylog"}

function createDCLog(message, type)
    local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second
    if (hours < 10) then
		hours = "0"..hours
	end
	if (minutes < 10) then
		minutes = "0"..minutes
	end
	if (seconds < 10) then
		seconds = "0"..seconds
	end
    sendOptions = {
        formFields = {
            content = "**[" .. hours .. ":" .. minutes .. ":" .. seconds .. "]:** " .. message .. ""
        },
    }
    fetchRemote(webhooks[type][1], sendOptions, WebhookCallback)
end
addEvent("createDCLog", true)
addEventHandler("createDCLog", root, createDCLog)

function WebhookCallback(responseData)
end

function debugLOG(message, level, file, line)
    if message and level and file and line then
        if level == 1 then
            header = "ERROR"
        elseif level == 2 then
            header = "WARNING"
        elseif level == 3 then
            header = "INFO"
        elseif level == 0 then
            header = "DEBUG"
        end
        createDCLog("(" .. header .. ") " .. message .. ". (" .. file .. " | " .. line .. " sor)", 2)
    end
end
addEventHandler("onDebugMessage", root, debugLOG)

function onChange(key, oValue, nValue)
    if key and oValue and nValue then
        createDCLog(getElementData(source, "a.PlayerName") .. " | " .. key .. " | " .. oValue .. " -> " .. nValue, 6)
    end
end
addEventHandler("onElementDataChange", root, onChange)