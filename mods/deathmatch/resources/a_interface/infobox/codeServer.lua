function makeNotificationS(player, type, text)
	triggerClientEvent(player, "makeNotification", root, type, text)
end
addEvent("makeNotification", true)
addEventHandler("makeNotification", root, makeNotificationS)