local discordWebhookTypes = {
  --TYPE, WEBHOOK
  cupon = {"cupon", "https://discord.com/api/webhooks/1123941333615255647/Q8ZeCGNcnESoGshDL1LxROl_eECORE9PhbM-_CRO65wRSGXaCIf8SZv2JzqXn5drpKao"},
}

function sendDiscordMessage(message, type)
sendOptions = {
    formFields = {
        content=""..message..""
    },
}
fetchRemote ( discordWebhookTypes[type][2], sendOptions, WebhookCallback )
end

function WebhookCallback(responseData) 
   -- outputDebugString("(Discord webhook callback): responseData: "..responseData)
end

--//EXPORTHOZ//--
--exports.cosmo_dclog:sendDiscordMessage("Az üzenet", "Tipus!")
--Konkrét példa : exports.cosmo_dclog:sendDiscordMessage("A fegyverhajó várhatóan x órakor érkezik meg!", "weaponship")