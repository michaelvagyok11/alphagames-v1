function respawnPlayer(player, x, y, z, skin, dim)
    spawnPlayer(player, x, y, z)
	setElementHealth(player, 100)
    setElementModel(player, skin)
    setPedHeadless(player, false)
	setElementDimension(player, dim or 0)
end
addEvent("respawnPlayer", true)
addEventHandler("respawnPlayer", root, respawnPlayer)

addEventHandler("onPlayerDamage", root, function(attacker, weapon, bodypart, loss)
	if bodypart == 9 then
		setElementHealth(source, 0)
		killPed(source, attacker, weapon, bodypart)
		setPedHeadless(source, true)
	end
end)