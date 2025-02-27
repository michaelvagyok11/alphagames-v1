addEvent("processHeadShot", true)
addEventHandler("processHeadShot", getRootElement(),
	function (attacker, weapon)
		if isElement(attacker) and weapon then
			killPed(source, attacker, weapon, 9)
			setPedHeadless(source, true)
		end
	end
)

addEventHandler("onPlayerSpawn", getRootElement(),
	function ()
		setPedHeadless(source, false)
	end
)
