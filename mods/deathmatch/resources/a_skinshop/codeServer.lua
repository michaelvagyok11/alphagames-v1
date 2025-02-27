local connection = exports.a_mysql:getConnection();

function onResStart(startedRes)
    skinShopCol = createColCuboid(skinShopMarker[1] - 2, skinShopMarker[2] - 2, skinShopMarker[3] - 1, 2, 2, 3)
    setElementData(skinShopCol, "a.SkinshopCol", true)
end
addEventHandler("onResourceStart", resourceRoot, onResStart)

function changePlayerSkin(element, skinid)
    if element and skinid then
        skinChangeProcess = setElementModel(element, skinid)
        if (skinChangeProcess) then
            dbExec(connection, "UPDATE accounts SET skin='" .. skinid .. "' WHERE id='" .. getElementData(element, "a.accID") .. "'")
        end
    end
end
addEvent("changePlayerSkin", true)
addEventHandler("changePlayerSkin", root, changePlayerSkin)