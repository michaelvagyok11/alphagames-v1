local webhooks = {
    {"https://discord.com/api/webhooks/1244355151762948319/mY0-SKELr9P6wuOkMLsPXVKQ0faWOENaFUdhC8hGTYDk9t74aFUHf9icR49IPJZCdJ6X"}, -- adminlog
    {"https://discord.com/api/webhooks/1244354599364726875/bEmuL8HSpg79VpsMX_a7pkNVKGGQ4Ls0uYcCw5ClnC3gbFGZzwfnYuPYV4xttbhGiCZl"}, -- DEBUGSCRIPT
    {"https://discord.com/api/webhooks/1244354599364726875/bEmuL8HSpg79VpsMX_a7pkNVKGGQ4Ls0uYcCw5ClnC3gbFGZzwfnYuPYV4xttbhGiCZl"}, -- DEBUGSCRIPT
    {"https://discord.com/api/webhooks/1244354599364726875/bEmuL8HSpg79VpsMX_a7pkNVKGGQ4Ls0uYcCw5ClnC3gbFGZzwfnYuPYV4xttbhGiCZl"}, -- DEBUGSCRIPT
    {"https://discord.com/api/webhooks/1244354599364726875/bEmuL8HSpg79VpsMX_a7pkNVKGGQ4Ls0uYcCw5ClnC3gbFGZzwfnYuPYV4xttbhGiCZl"}, -- DEBUGSCRIPT
    {"https://discord.com/api/webhooks/1244355614386163732/aEWcWGu76Vs-nBoYpnFQZs2f9FUvBPzGxtutsLVDvkWHvz2abMnest2jEj9I7PGkRdy1"}, -- EDATACHANGE
}
local types = {"adminlog", "debug", "chat", "pm", "killog", "datachange"}

function createDCLog(message, type)
    local time = getRealTime()
	local year, month, day = time.year+1900, time.month+1, time.monthday
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second
    if (month < 10) then
		month = "0"..month
	end
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
            content = "**[" .. year .. "." .. month .. "." .. day .. " - " .. hours .. ":" .. minutes .. ":" .. seconds .. "]:** " .. message .. ""
        },
    }
    fetchRemote(webhooks[type][1], sendOptions, WebhookCallback)
end
addEvent("createDCLog", true)
addEventHandler("createDCLog", root, createDCLog)

function WebhookCallback(responseData) 
    --outputChatBox("dzsekit megbasszak visszajelzes")
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

local ignoreDataKey = {["a.PlayedMinutes"] = true, ["afk"] = true, ["typing"] = true, ["console"] = true}
function onChange(key, oValue, nValue)
    if key and oValue and nValue then
        if not ignoreDataKey[key] then
            if not oValue or not nValue then
                return
            end
            createDCLog("\nSource element: **" .. getElementData(source, "a.PlayerName") .. "** (" .. getPlayerSerial(source) .. ")\n>>  eData: **" .. key .. "**\n>> oldValue: **" .. oValue .. "** -> newValue: **" .. nValue .. "**", 6)
        end
    end
end
addEventHandler("onElementDataChange", root, onChange)