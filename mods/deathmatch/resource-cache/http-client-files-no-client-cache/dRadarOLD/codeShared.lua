blipNames = {
	[1] = {"Cigány pénisz"},
}

blipPositions = {
	-- ** X, Y, Z, BLIP ID
	{1782.7336425781, -1301.1793212891, 120.26425170898, 1}
}

function onStart()
	for i, v in ipairs(blipPositions) do
		createBlip(v[1], v[2], v[3], v[4])
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)