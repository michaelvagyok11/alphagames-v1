local webhooks = {
    {"https://discord.com/api/webhooks/1143350313852616875/m8Ah-dy2bjkiM2BXjQ_vq2VWLhm9-DE0OA-1VnP86d8Edvw3xlGG0F3Q6Kr9WnVf7_VD"},
    {"https://discord.com/api/webhooks/1143350352305979554/LhOzkZVhTP5iIllV4os4B1LP363H8vV_zdDfFgJCAGaHjGV4nflnT3eILb_0t1MXWxfK"},
    {"https://discord.com/api/webhooks/1143350356034728016/FqPDWZqKHKzoxRxZiE2n7BryixONJZjA7hBH9ux6Un51N9zu1ZNi0GAl_baf58JS66ng"},
    {"https://discord.com/api/webhooks/1143350359692161034/PU6DvIRG-1kl70I66BzJ-zUEdETKKxR7UZUMybNXlTyWVWGaVXyg-X4Kchqpunj9xEmT"},
    {"https://discord.com/api/webhooks/1143350363227947158/uaRvDn_8kchJUqHOeS6Ff2XdS9L1pyDKlfrzH6dV4wlJk_rw939OJU9pfjUgEup1mien"},
    {"https://discord.com/api/webhooks/1143350367107682365/HxKnU5-0-FmEQjFLyM_50gQ1qoIWCflqu-DhJV57TWcIkiG-iK4sbQikJwTT-hKiToqW"},
    {"https://discord.com/api/webhooks/1143350370475704486/_tW4ZrJXYfw81QwjCqHN5ONBgSYtQXFakV_FsqPBeG1Rpe3MohTEzU9KdJT5tDRru8c-"},
    {"https://discord.com/api/webhooks/1143350373965365269/QXluiAfs4pz5YAgrUJ6yGjD6NfHQZFtkaJbZpp-j5hiYGD9ZrE2ZqvIShyxbbNsdMt-7"},
    {"https://discord.com/api/webhooks/1143350377811558500/Kx4QvRcRM6crRayel1jv6QOhxpexZkPil4SMEMeGNbfQLQkjSQMNqZWI7jYK_Cqf4z41"},
    {"https://discord.com/api/webhooks/1143350381036961872/O0jGnrCivJ_pvQYxvilyrF2rqO-uw3Q_WQBjilcBKxmFMpZtfhs2zn-bx33wZPeiS_E2"},
    {"https://discord.com/api/webhooks/1159590295063773306/GKmMSANQquD9EIrG7XS02I3fK_Qv8gmAYKJsHmaqZSC5gPnhe8nRz4plXxFpmNkHIB4J"},
    {"https://discord.com/api/webhooks/1159590354115375156/RL8pVZecM6Bmg-Xadd-RJAxxviJdoF9On_5xj9z2QOwckuFZJ1tGx8cOEvv602ppCbcG"},
    {"https://discord.com/api/webhooks/1167874848844959844/WE8p4N1bZHjdSNV1D9J41L9PjaVStcd1cvUb6KnNu1diqPpJ8QKinPoi4Hces-Lubggs"},
}
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

function onChange(key, oValue, nValue)
    if key and oValue and nValue then
        createDCLog(getElementData(source, "a.PlayerName") .. " | " .. key .. " | " .. oValue .. " -> " .. nValue, 6)
    end
end
addEventHandler("onElementDataChange", root, onChange)