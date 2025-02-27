function onJoin()
    local joinedPlayer = source
    local joinedPlayer_name = getPlayerName(joinedPlayer)

    outputChatBox("#8FC3E4►#FFFFFF Szia #E48F8F" .. joinedPlayer_name .. "#FFFFFF! Üdvözöllek az #E48F8FalphaGames #FFFFFFhivatalos szerverén.", joinedPlayer, 255, 255, 255, true)
    outputChatBox("#8FC3E4►#FFFFFF Csatlakozz #B2A7ECDiscord #FFFFFFközösségünkbe, ahol már közel 600-an vagyunk.", joinedPlayer, 255, 255, 255, true)
    outputChatBox("#8FC3E4►#FFFFFF Link: #9BE48Fhttps://bit.ly/alphagamesmta", joinedPlayer, 255, 255, 255, true)
end
addEventHandler("onPlayerJoin", root, onJoin)