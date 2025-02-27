local devSerials = {
	[""] = true
}

addEventHandler("onClientPlayerDamage", localPlayer,
	function (attacker, weapon, bodypart, loss)
		if getElementData(source, "invulnerable") or getElementData(source, "a.DMTeam") == getElementData(localPlayer, "a.DMTeam") then
			cancelEvent()
			return
		end
		if bodypart == 9 then
			triggerServerEvent("processHeadShot", localPlayer, attacker, weapon)
			cancelEvent()
		end

		if localPlayer then 
			if devSerials[getPlayerSerial(localPlayer)] then 
				outputChatBox(attacker .. ":" .. weapon .. ":" .. bodypart .. ":"..loss)
			end
		end
	end
)

addEventHandler("onClientPedDamage", getRootElement(),
	function ()
		if getElementData(source, "invulnerable") then
			cancelEvent()
		end
	end
)

addEventHandler("onClientPlayerStealthKill", getRootElement(),
	function (targetPlayer)
		cancelEvent()
	end
)