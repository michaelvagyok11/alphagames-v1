function ChangeObjectModel (filename,id)
	if id and filename then
		if fileExists(filename..".txd") then
			txd = engineLoadTXD(filename..".txd")
			engineImportTXD(txd, id)
		end

		if fileExists(filename..".dff") then
			dff = engineLoadDFF(filename..".dff", 0)
			engineReplaceModel(dff, id)
		end

		if fileExists(filename..".col") then
			col = engineLoadCOL(filename..".col")
			engineReplaceCOL(col, id)
		end

		engineSetModelLODDistance(id, 300)
	end
end

ChangeObjectModel("files/siren", 903)


local flasherPos = { -- Jobbra -balra / Előre - hátra / Le - Fel
	[400] = {-0.35, 0.1, 0.7},  -- x5
	[541] = {-0.38, -0.11, 0.760}, 	-- zl1
    [445] = {-0.35, -0.14, 0.78},  -- m5
	[558] = {-0.32, -0.13, 0.9}, -- m3
	[489] = {-0.38, -0.11, 1.2},  -- g65
	[507] = {-0.39, 0.3, 0.82}, 	-- chrysler
	[580] = {-0.39, 0.1, 0.92}, 	-- RS4
	[401] = {-0.39, 0.1, 0.85}, 	-- Golf V
	[585] = {-0.39, 0.1, 0.85}, 	-- A6
	[550] = {-0.39, 0.1, 0.85}, 	-- E34
	[458] = {-0.39, 0.1, 0.95}, 	-- E34
	[426] = {-0.39, 0.1, 0.83}, 	-- E34
	[547] = {-0.39, 0.1, 0.82}, 	-- E34
};

local sirens = {};

function createSiren()
	if not isPedInVehicle(localPlayer) then 
		return false
	end

	local playerVehicleModel = getElementModel(getPedOccupiedVehicle(localPlayer))

	if flasherPos[playerVehicleModel] then
		triggerServerEvent("flasher->ChangeState", localPlayer, localPlayer, flasherPos[playerVehicleModel]);
		setElementData(getPedOccupiedVehicle(localPlayer), "sirens->Flasher", true)
	else
		return false
	end
end
addCommandHandler("felrakvillogo", createSiren)

function villogas()
	if localPlayer.vehicleSeat <= 1 then
		setElementData(localPlayer.vehicle, "sirens->Flasher", not getElementData(localPlayer.vehicle, "sirens->Flasher"));
	end
end
bindKey ( "h", "down", villogas )


addEventHandler("onClientElementDataChange", root, function(data)
	if data == "sirens->Flasher" then
		if getElementData(source, data) then
			sirens[source] = true;
			source.sirensOn = true;
		else
			if sirens[source] then
				sirens[source] = nil;
			end
			source.sirensOn = false;
		end
	end
end);

setTimer(function()
	for vehicle, value in pairs(sirens) do
		if not isElement(vehicle) then
			sirens[vehicle] = nil;
		end

		if value and isElement(vehicle) then
			local state = getVehicleLightState(vehicle, 0);

		else
			sirens[vehicle] = nil
		end
	end
end, 150, 0);
