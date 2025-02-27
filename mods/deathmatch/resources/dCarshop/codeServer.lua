local connection = exports.dMysql:getConnection()
local testVehicles = {}

function createTestDrive(element, model)
    if element and isElement(element) and model then
        testVehicles[element] = createVehicle(model, testX, testY, testZ)
        setElementDimension(element, getElementData(element, "a.accID"))
        setElementDimension(testVehicles[element], getElementData(element, "a.accID"))
        warpPedIntoVehicle(element, testVehicles[element])
    end
end
addEvent("createTestDrive", true)
addEventHandler("createTestDrive", root, createTestDrive)

function destroyTestVehicle(element)
    if element and isElement(element) then
        removePedFromVehicle(element, testVehicles[element])
        destroyElement(testVehicles[element])
        setElementDimension(element, 0)
        setElementPosition(element, markerX + 3, markerY + 3, markerZ)
        triggerClientEvent("testVehicleDeleted", element, element)
    end
end
addEvent("destroyTestVehicle", true)
addEventHandler("destroyTestVehicle", root, destroyTestVehicle)

function buyVehicle(element, index, type)
    if element and isElement(element) and index and type then
        if type == "$" then
            local modelID, price = vehiclesForSale[index][1], vehiclesForSale[index][3]
            setElementData(element, "a.Money", getElementData(element, "a.Money") - price)
            
            dbExec(connection, "INSERT INTO vehicles SET owner = ?, model = ?", getElementData(element, "a.accID"), tonumber(modelID))
            triggerClientEvent("boughtVehicle", element, element)
        elseif type == "pp" then
            local modelID, price = vehiclesForSale[index][1], vehiclesForSale[index][4]
            setElementData(element, "a.Premiumpont", getElementData(element, "a.Premiumpont") - price)

            dbExec(connection, "INSERT INTO vehicles SET owner = ?, model = ?", getElementData(element, "a.accID"), tonumber(modelID))
            triggerClientEvent("boughtVehicle", element, element)
        end
    end
end
addEvent("buyVehicle", true)
addEventHandler("buyVehicle", root, buyVehicle)