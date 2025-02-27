local connection = exports.dMysql:getConnection();

function changePlayerSkin(element, skinid)
    if element and skinid then
        skinChangeProcess = setElementModel(element, skinid)

        if (skinChangeProcess) then
            setElementData(element, "a.Skin", skinid)
            setElementModel(element, skinid)
            dbExec(connection, "UPDATE accounts SET skin = ? WHERE serial = ?", tonumber(skinid), getPlayerSerial(element))
        end
    end
end
addEvent("changePlayerSkin", true)
addEventHandler("changePlayerSkin", root, changePlayerSkin)