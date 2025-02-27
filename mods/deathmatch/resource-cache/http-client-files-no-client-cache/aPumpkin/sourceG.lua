debugMode = false

weightedItems = {
    [1] = 5,
    [2] = 5,
    [3] = 4.5,
    [6] = 4,
    [8] = 4,
    [11] = 3,
    [13] = 3,
    [58] = 3,
    [41] = 2,
    [42] = 1,
    [45] = 1,

    -- innen jonnek a premium targyak
    [9] = 0.5,
    [10] = 0.5,
    [19] = 0.5,
    [20] = 0.5,
    [21] = 0.5,
    [22] = 0.5,
    [23] = 0.5,
    [24] = 0.5,
    [25] = 0.5,
    [26] = 0.5,
    [27] = 0.5,
    [28] = 0.5,
    [34] = 1, -- halloween p90
    [35] = 0.5,
    [37] = 0.4,
    [40] = 0.4,
    [43] = 0.4,
    [46] = 0.3,
    [51] = 0.3,
    [53] = 0.3,
    [55] = 0.3,
    [61] = 0.3,
    [63] = 1, -- halloween ak
    [64] = 1, -- halloween deagle
}

goldColor = {244, 205, 70}

goldItems = {
    [9] = true, -- winter ak
    [10] = true, -- camo ak
    [19] = true, -- digit ak
    [20] = true, -- gold ak
    [21] = true, -- special gold ak
    [22] = true, -- hello kitty ak
    [23] = true, -- silver ak
    [24] = true, -- camo deagle
    [25] = true, -- gold deagle
    [26] = true, -- camo p90
    [27] = true, -- winter p90
    [28] = true, -- black p90
    [34] = true, -- halloween p90
    [35] = true, -- spaz
    [37] = true, -- gold m4
    [40] = true, -- winter m4
    [43] = true, -- katana
    [46] = true, -- dragon king m4
    [51] = true, -- fade deagle
    [53] = true, -- hello kitty usp
    [55] = true, -- printstream spaz
    [61] = true, -- special gold m4
    [63] = true, -- halloween ak
    [64] = true, -- halloween deagle
}

function chooseRandomItem()
	local weightSum = 0

	for itemId, itemWeight in pairs(weightedItems) do
		weightSum = weightSum + itemWeight
	end

	local selectedWeight = math.random(weightSum)
	local iteratedWeight = 0

	for itemId, itemWeight in pairs(weightedItems) do
		iteratedWeight = iteratedWeight + itemWeight

		if selectedWeight <= iteratedWeight then
			return itemId
		end
	end

	return false
end
