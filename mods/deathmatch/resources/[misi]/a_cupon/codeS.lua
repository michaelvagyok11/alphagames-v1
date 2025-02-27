local connection = false
local cupons = {}

addEventHandler("onDatabaseConnected", getRootElement(),
    function(db)
        if client then
            banPlayer(client, true, false, true, "Anticheat", "AC #1")
            return
        end
        connection = db
    end
)

addEventHandler("onResourceStart", root,
    function()
        connection = exports.a_mysql:getConnection()

        dbQuery(loadCupons, connection, "SELECT * FROM cupons")
    end
)

function loadCupons(qh)
    local result = dbPoll(qh, 0)

    if result then
        for k, v in pairs(result) do
            table.insert(cupons, {cuponID = v.dbID, cuponCode = v.code, cuponAmount = tonumber(v.amount), cuponType = v.type, cuponTypeAmount = tonumber(v.typeAmount), cuponActivatedBy = fromJSON(v.activatedBy) or {}})
        end
    end
end


local enabledSerials = {
    ["8A0BC075A35352D27E0D959CE91809A4"] = true, -- michael
    ["7516AF5872CF3CBDAD9FF4DE6D872143"] = true, -- michael 2
}

addCommandHandler("kupon",
    function(sourcePlayer, commandName, cuponCode)
        if not getElementData(sourcePlayer, "loggedIn") then
            return
        end
        local foundCupon = false
        for k, v in pairs(cupons) do
            if v.cuponCode == cuponCode then
                foundCupon = v
            end
        end
        if cuponCode then
            v = foundCupon
            local alreadyUsed = false
            if not foundCupon then
                outputChatBox("#d75959[Kupon]: #ffffffNincs ilyen kód!", sourcePlayer, 255, 255, 255, true)
                return
            end
            for k, v in pairs(v.cuponActivatedBy) do
                if tonumber(v) == getElementData(sourcePlayer, "a.accID") then
                    alreadyUsed = true
                    break
                end
            end
            if alreadyUsed then
                outputChatBox("#d75959[Kupon]: #ffffffTe már felhasználtad ezt a kódot!", sourcePlayer, 255, 255, 255, true)
                return
            end
            
            if v.cuponAmount > 0 then
                --local cuponReward = v.cuponTypeAmount
                if v.cuponType == 1 then
                    cuponReward = v.cuponTypeAmount.." PP"
                    setElementData(sourcePlayer, "a.Premiumpont", getElementData(sourcePlayer, "a.Premiumpont") + v.cuponTypeAmount)
                    local newPP, accID = getElementData(sourcePlayer, "a.Premiumpont"), getElementData(sourcePlayer, "a.accID")
                    print("asd")
                    dbExec(connection, "UPDATE accounts SET pp = ? WHERE id = ?", newPP, getElementData(sourcePlayer, "a.accID"))
                elseif v.cuponType == 2 then
                    cuponReward = exports.see_items:getItemName(v.cuponTypeAmount)
                    exports.see_items:giveItem(sourcePlayer, v.cuponTypeAmount, 1)
                end
                table.insert(v.cuponActivatedBy, getElementData(sourcePlayer, "a.accID"))
                v.cuponAmount = v.cuponAmount - 1
                dbExec(connection, "UPDATE cupons SET amount = ?, activatedBy = ? WHERE dbID = ?", v.cuponAmount, toJSON(v.cuponActivatedBy), v.cuponID)
                exports.a_logs:createDCLog("**"..getElementData(sourcePlayer, "a.PlayerName").."** felhasznált egy kupont! **("..cuponReward..")** ("..cuponCode..")", 1)
                messageToAdmins("#E48F8F[alphaGames] #E48F8F"..getElementData(sourcePlayer, "a.PlayerName").." #fffffffelhasznált egy kupont! #E48F8F("..cuponCode..")")
                outputChatBox("#E48F8F[Kupon]: #ffffffSikeresen felhasználtad a kódot! #E48F8F("..cuponReward..")", sourcePlayer, 255, 255, 255, true)
            else
                outputChatBox("#d75959[Kupon]: #ffffffElfogyott!", sourcePlayer, 255, 255, 255, true)
            end
        else
            outputChatBox("#d75959[Használat]: #ffffff/"..commandName.." [Kód]", sourcePlayer, 255, 255, 255, true)
        end
    end
)

addCommandHandler("createkupon",
    function(sourcePlayer, commandName, code, amount, type, typeAmount)
        if enabledSerials[getPlayerSerial(sourcePlayer)] and getElementData(sourcePlayer, "loggedIn") then
            if typeAmount then
                if tonumber(amount) and tonumber(type) and tonumber(typeAmount) and tonumber(type) <= 2 then
                    for k, v in pairs(cupons) do
                        if v.cuponCode == code then
                            outputChatBox("#d75959[Kupon]: #ffffffIlyen azonosítóval már létezik kupon!", sourcePlayer, 255, 255, 255, true)
                            return
                        end
                    end
                    if code == "0" then
                        code = sha256((math.random(1, 100000)/1000)*getTickCount()/1002)
                        code = utfSub(code, 1, 8)
                    end
                    dbExec(connection, "INSERT INTO cupons (code, amount, type, typeAmount, activatedBy) VALUES (?,?,?,?,?)", code, amount, type, typeAmount, toJSON({}))
                    messageToAdmins("#E48F8F[alphaGames] #ffffff"..getElementData(sourcePlayer, "a.PlayerName").." létrehozott egy kupont! #E48F8F("..code..", "..amount..", "..type..", "..typeAmount..")")
                    exports.a_logs:createDCLog("**"..getElementData(sourcePlayer, "a.PlayerName").."** létrehozott egy kupont! **("..code..", "..amount..", "..type..", "..typeAmount..")**", 1)
                    outputChatBox("#E48F8F[Kupon]: #ffffffSikeresen létrehoztad a kupont! #E48F8F("..code..")", sourcePlayer, 255, 255, 255, true)
                    dbQuery(loadCupons, connection, "SELECT * FROM cupons")
                end
            else
                outputChatBox("#d75959[Használat]: #ffffff/"..commandName.." [Kód (0 = random)] [Mennyiség] [Típus (1 = PP, 2 = Item)] [Mennyiség (PP mennyiség, ItemID)]", sourcePlayer, 255, 255, 255, true)
            end
        end
    end
)

function messageToAdmins(msg)
    for i,v in ipairs(getElementsByType("player")) do 
        if getElementData(v, "loggedIn") then 
            if getElementData(v, "adminLevel")>=6 then
                 
                outputChatBox(msg, v, 255, 255, 255, true)
            end
        end
    end
end