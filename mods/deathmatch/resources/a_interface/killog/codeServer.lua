function onWasted(ammo, attacker, weapon, bodypart)
    if attacker and weapon and bodypart then
        data = {source, attacker, weapon, bodypart}
        triggerClientEvent(root, "addKillog", root, attacker, source, weapon, bodypart)
        table.insert(currentKillog, {attacker, source, weapon, bodypart, getTickCount()})
    end
end
addEventHandler("onPlayerWasted", root, onWasted)