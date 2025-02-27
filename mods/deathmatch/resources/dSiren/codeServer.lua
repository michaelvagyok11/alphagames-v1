local sirens = {};

addEventHandler("onResourceStop", resourceRoot, function()
	for key, value in pairs(sirens) do
		removeVehicleSirens(key);
	end
end);

addEvent("flasher->ChangeState", true);
addEventHandler("flasher->ChangeState", root, function(player, array)
	if client and client == player then
		if isElement(sirens[player.vehicle]) then
			removeVehicleSirens(player.vehicle);

			detachElements(sirens[player.vehicle], player.vehicle);
			destroyElement(sirens[player.vehicle]);

			setElementData(player.vehicle, "sirens->State", false);
			setElementData(player.vehicle, "sirens->Flasher", false);
		else
			sirens[player.vehicle] = Object(903, player.vehicle.position);
			attachElements(sirens[player.vehicle], player.vehicle, array[1], array[2], array[3]);

			removeVehicleSirens(player.vehicle);
			addVehicleSirens(player.vehicle, 1, 2, true, false, true, true);
			setElementData(player.vehicle,"sirenObject",siren)
			setElementData(player.vehicle,"isVehicleInObject",true)
			setVehicleSirens(player.vehicle, 1, array[1], array[2], array[3] + 0.05, 20, 50, 230, 255, 255);

			setElementData(player.vehicle, "sirens->State", true);
			setElementData(player.vehicle, "sirens->Flasher", true);
		end
	end
end);

addEventHandler("onElementDestroy", root, function()
	if sirens[source] then
		destroyElement(sirens[source]);
	end
end);
