local shootingRangeEnter = {}
local shootingRangeExit = {}

function onStart()
    for k, v in ipairs(liftPositions) do
        shootingRangeEnter[k] = createMarker(v[1], v[2], v[3], "corona", 0.5 , 0, 0, 0, 0)
        setElementInterior(shootingRangeEnter[k], 4)
        setElementData(shootingRangeEnter[k], "shootingRange.Entry", true)

        shootingRangeExit[k] = createMarker(v[4], v[5], v[6], "corona", 0.5, 0, 0, 0, 0)
        setElementInterior(shootingRangeExit[k], 4)
        setElementData(shootingRangeExit[k], "shootingRange.Exit", true)
    end
end
addEventHandler("onResourceStart", resourceRoot, onStart)

function onHit(hitElement)
    if getElementData(source, "shootingRange.Entry") == true then
        for k, v in ipairs(liftPositions) do
            setElementPosition(hitElement, v[4] - 2, v[5], v[6])            
        end
    elseif getElementData(source, "shootingRange.Exit") == true then
        for k, v in ipairs(liftPositions) do
            setElementPosition(hitElement, v[1] - 2, v[2], v[3])
        end
    end
end
addEventHandler("onMarkerHit", root, onHit)

function goToShootingRange(executerElement, commandName)
    setElementInterior(executerElement, 4)
    setElementPosition(executerElement, interiorPosition[1], interiorPosition[2], interiorPosition[3])
end
addCommandHandler("shoot", goToShootingRange)