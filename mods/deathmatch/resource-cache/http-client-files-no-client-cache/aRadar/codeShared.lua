blipNames = {
	[1] = {"Cigány pénisz"},
}

blipPositions = {
	-- ** X, Y, Z, BLIP ID, NÉV
	{1882.7336425781, -1301.1793212891, 120.26425170898, 1, "Teszt 0"},
	{1782.7336425781, -1381.1793212891, 120.26425170898, 1, "Teszt 1"},
	{1682.7336425781, -1461.1793212891, 120.26425170898, 1, "Teszt 2"},
	{1582.7336425781, -1541.1793212891, 120.26425170898, 1, "Teszt 3"},
	{1482.7336425781, -1621.1793212891, 120.26425170898, 1, "Teszt 4"},
	{1382.7336425781, -1701.1793212891, 120.26425170898, 1, "Teszt 5"},
	{1282.7336425781, -1781.1793212891, 120.26425170898, 1, "Teszt 6"},
}

local blipsCreated = {}

function onStart()
	for i, v in ipairs(blipPositions) do
		blipsCreated[i] = createBlip(v[1], v[2], v[3], v[4])
		setElementData(blipsCreated[i], "a.BlipName", v[5])
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)