-- ** CARSHOP MARKER POSITIONS
markerX, markerY, markerZ = 1544.3252, -1346.626, 329.46359; 

-- ** VEHICLE PREVIEW POSITIONS
vehicleX, vehicleY, vehicleZ = 1556.8066, -1356.502, 329.46094;

-- ** TESTDRIVE SPAWN POSITIONS
testX, testY, testZ = 1919.7637, -2272.7051, 13.546875;

-- ** VEHICLE TABLE
vehiclesForSale = {
    -- ** MODEL ID, NAME, $ PRICE, PP PRICE

    {580, "Mercedes-Benz Maybach", 40000, 2000},
    {602, "BMW M3 E46", 32000, 1500},
    {507, "BMW M5 E60", 5000, 350},
    {411, "BMW M4 E92", 15000, 650},
    {400, "Range Rover", 35000, 1200},
    {547, "BMW 750 iL", 18000, 750},
    {405, "Audi S8", 15000, 650},
    {560, "Mercedes-Benz S63 Brabus", 50000, 3000},
    {494, "Ferrari Italia", 25000, 2000},
    {506, "Audi RS5", 20000, 1500},
    {480, "Porsche 911 Carrera", 40000, 2500},
}

function getVehicleNameFromID(model)
    if tonumber(model) then
        for k, v in ipairs(vehiclesForSale) do
            if v[1] == model then
                return tostring(v[2])
            end
        end
    end
end