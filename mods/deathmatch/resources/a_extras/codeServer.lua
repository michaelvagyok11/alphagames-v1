local lastTip = {}
local numberGuessable = false
local textWritable = false

function createTip()
    for k, v in ipairs(getElementsByType("player")) do
        if getElementData(v, "loggedIn") then
            currentTip = math.random(1, #tips)
            if lastTip[v] == currentTip then
                currentTip = math.random(1, #tips)
                outputChatBox("#8FC3E4► Tipp: #FFFFFF" .. tips[currentTip][1], v, 255, 255, 255, true)
            else
                lastTip[v] = currentTip
                outputChatBox("#8FC3E4► Tipp: #FFFFFF" .. tips[currentTip][1], v, 255, 255, 255, true)
            end
        end
    end
end
setTimer(createTip, (1000*60)*10, 0)

function createNumberExercise()
    currentNumber1 = math.random(10, 120)
    currentNumber2 = math.random(10, 50)
    currentNumber3 = math.random(10, 75)
    numberAmount = math.random(50, 150)
    numberGuessable = true
    outputChatBox("#E48F8F► Matekpélda: #FFFFFFSzámold ki: #9BE48F" .. currentNumber1 .. " #FFFFFF+ #9BE48F" .. currentNumber2 .. " #FFFFFF- #9BE48F" .. currentNumber3 .. "#FFFFFF, majd írd be a helyes választ a chatre. #8FC3E4(" .. numberAmount .. "$)", root, 255, 255, 255, true)
end
setTimer(createNumberExercise, (1000*60)*math.random(5, 10), 0)

function createTextExercise()
    currentText = generateString(10)
    textAmount = math.random(20, 120)
    textWritable = true
    outputChatBox("#E48F8F► Karakterlánc: #FFFFFFÍrd be te a leggyorsabban a chatre: '#9BE48F" .. currentText .. "#FFFFFF' #8FC3E4(" .. textAmount .. "$)", root, 255, 255, 255, true)
end
setTimer(createTextExercise, (1000*60)*math.random(2, 8), 1)

function onMessage(message)
    if message then
        if getElementData(source, "loggedIn") then
            if numberGuessable == true then
                calculateNumber = tostring(currentNumber1 + currentNumber2 - currentNumber3)
                if message == calculateNumber then
                    numberGuessable = false
                    outputChatBox("#E48F8F► Matekpélda: #8FC3E4" .. getElementData(source, "a.PlayerName") .. " #FFFFFFeltalálta a számot.", root, 255, 255, 255, true)
                    outputChatBox("#9BE48F► Matekpélda: #FFFFFFSikeresen eltaláltad a számot. Nyereményed: #8FC3E4" .. numberAmount .. "$", source, 255, 255, 255, true)
                    setElementData(source, "a.Money", getElementData(source, "a.Money") + numberAmount)
                end
            end
            if textWritable == true then
                if message == tostring(currentText) then
                    textWritable = false
                    outputChatBox("#E48F8F► Karakterlánc: #8FC3E4" .. getElementData(source, "a.PlayerName") .. " #FFFFFFírta be leghamarabb a karakterláncot.", root, 255, 255, 255, true)
                    outputChatBox("#9BE48F► Karakterlánc: #FFFFFFSikeresen beírtad a karakterláncot. Nyereményed: #8FC3E4" .. textAmount .. "$", source, 255, 255, 255, true)
                    setElementData(source, "a.Money", getElementData(source, "a.Money") + textAmount)
                end
            end
        end
    end
end
addEventHandler("onPlayerChat", root, onMessage)

local allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } } -- numbers/lowercase chars/uppercase chars

function generateString ( len )
    
    if tonumber ( len ) then
        math.randomseed ( getTickCount () )

        local str = ""
        for i = 1, len do
            local charlist = allowed[math.random ( 1, 3 )]
            str = str .. string.char ( math.random ( charlist[1], charlist[2] ) )
        end

        return str
    end
    
    return false
    
end

local pedPositions = {
    {60, 219.4716796875, 1865.7333984375, 13.140625},
    {61, 218.4716796875, 1865.7333984375, 13.140625},
    {60, 217.4716796875, 1865.7333984375, 13.140625},
    {61, 216.4716796875, 1864.7333984375, 13.140625},
    {60, 219.4716796875, 1864.7333984375, 13.140625},
    {61, 218.4716796875, 1864.7333984375, 13.140625},
    {60, 217.4716796875, 1864.7333984375, 13.140625},
    --{61, 216.4716796875, 1864.7333984375, 13.140625},
    --{60, 219.4716796875, 1863.7333984375, 13.140625},
    --{61, 218.4716796875, 1863.7333984375, 13.140625},
    --{60, 217.4716796875, 1863.7333984375, 13.140625},
    {61, 216.4716796875, 1865.7333984375, 13.140625},
    {60, 219.4716796875, 1864.7333984375, 13.140625},
    {61, 219.4716796875, 1863.7333984375, 13.140625},
}
local peds = {}

function createPeds()
    for k, v in ipairs(pedPositions) do
        peds[k] = createPed(v[1], v[2], v[3], v[4])
        setElementDimension(peds[k], 2)
        giveWeapon(peds[k], 31)
    end
end

function nickChange(oldNick, newNick, changedBy)
    if getElementData(source, "loggedIn") then
        outputChatBox("#E48F8F[Hiba]: #ffffffNem tudod változtatni a becenevedet miközben be vagy jelentkezve.", source, 255, 255, 255, true)
        cancelEvent()
        return
    else
        if tonumber(string.len(newNick)) > 15 then
            outputChatBox("#E48F8F[Hiba]: #ffffffNem tudod 15 karakternél hosszabb névre változtatni a nevedet.", source, 255, 255, 255, true)
            cancelEvent()
            return
        else
            outputChatBox("#8FC3E4[Becenév]: #ffffffSikeresen megváltoztattad a becenevedet. #8FC3E4(" .. tostring(oldNick) .. " -> " .. tostring(newNick) .. ")", source, 255, 255, 255, true)
        end
    end
end
addEventHandler("onPlayerChangeNick", root, nickChange)

local connection = exports.a_mysql:getConnection()

--[[addCommandHandler("itemtabletest",
    function(element)
        local itemsTable = {9, 10, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40}
        local winnedItem = itemsTable[math.random(#itemsTable)]
        local winnedItemName = exports.a_inventory:getItemName(winnedItem)
        print(winnedItem)
        print(winnedItemName)
        if winnedItem == 9 then
            --print("9-es lett teso")
        end
    end
)]]

function onCoupon(element, command, code)
    if isElement(element) and getElementData(element, "loggedIn") then
        if (code) and tostring(code) then
            local query = dbQuery(connection, "SELECT * FROM coupons WHERE code = ?", tostring(code))
            local result = dbPoll(query, 500)
            if (#result > 0) then
                for _, v in ipairs(result) do
                    if v["expired"] == 0 then
                        --outputChatBox("#9BE48F► Kupon: #FFFFFFGratulálok, sikeresen aktiváltad a kuponkódot. #8FC3E4(" .. tostring(code) .. ")", element, 255, 255, 255, true)
                        exports.a_logs:createDCLog(getElementData(element, "a.PlayerName") .. " aktivált egy kupont: "..tostring(code), 8)
                        local db = dbExec(connection, "UPDATE coupons SET expired = '1' WHERE code = ?", tostring(code))
                        chances = math.random(1, 100)
                        --[[if chances < 10 then
                            local vipHours = math.random(1, 3)
                            db1 = dbExec(connection, "UPDATE accounts SET vip = ? WHERE id = " .. getElementData(element, "a.accID") .. "", 1)
                            db2 = dbExec(connection, "INSERT INTO `vips` SET `accid` = ?, `date` =  NOW() + INTERVAL " .. tonumber(vipHours) .. " HOUR, `serial` = ?, `admin` = ?",getElementData(element, "a.accID"), getPlayerSerial(element), tostring("coupon code (" .. tostring(code) .. ")"))
                            if db1 and db2 then
                                setElementData(element, "a.VIP", true)
                            end
                            outputChatBox("#9BE48F► Kupon: #FFFFFFNyereményed #8FC3E4" .. vipHours .. " #FFFFFFóra #C4CD5DVIP rang#FFFFFF.", element, 255, 255, 255, true)
                            outputChatBox("#9BE48F► Kupon: #8FC3E4"..getElementData(element, "a.PlayerName").." #FFFFFFbeaktivált egy kupont. Nyereménye: #8FC3E4" .. vipHours .. " #FFFFFFóra #C4CD5DVIP rang#FFFFFF. #E48F8F("..tostring(code)..")", root, 255, 255, 255, true)
                            exports.a_logs:createDCLog(getElementData(element, "a.PlayerName") .. " nyereménye: "..vipHours.." óra VIP rang.", 8)]]
                        if chances >= 10 and chances <= 40 then
                            local amount = math.random(50, 150)
                            setElementData(element, "a.Premiumpont", getElementData(element, "a.Premiumpont") + amount)
                            outputChatBox("#9BE48F► Kupon: #FFFFFFNyereményed #8FC3E4" .. amount .. "PP.", element, 255, 255, 255, true)
                            outputChatBox("#9BE48F► Kupon: #8FC3E4"..getElementData(element, "a.PlayerName").." #FFFFFFbeaktivált egy kupont. Nyereménye: #8FC3E4" .. amount .. "PP. #E48F8F("..tostring(code)..")", root, 255, 255, 255, true)
                            exports.a_logs:createDCLog(getElementData(element, "a.PlayerName") .. " nyereménye: "..amount.." PP.", 8)
                        else
                            local amount = math.random(1000, 2000)
                            setElementData(element, "a.Money", getElementData(element, "a.Money") + amount)
                            outputChatBox("#9BE48F► Kupon: #FFFFFFNyereményed #9BE48F" .. amount .. "$.", element, 255, 255, 255, true)
                            outputChatBox("#9BE48F► Kupon: #8FC3E4"..getElementData(element, "a.PlayerName").." #FFFFFFbeaktivált egy kupont. Nyereménye: #9BE48F" .. amount .. "$. #E48F8F("..tostring(code)..")", root, 255, 255, 255, true)
                            exports.a_logs:createDCLog(getElementData(element, "a.PlayerName") .. " nyereménye: "..amount.." $.", 8)
                        end
                        break
                    else
                        outputChatBox("#E48F8F► Hiba: #FFFFFFEz a kuponkód lejárt, vagy már valaki felhasználta.", element, 255, 255, 255, true)
                        return
                    end
                end
            else
                outputChatBox("#E48F8F► Hiba: #FFFFFFEz a kuponkód érvénytelen.", element, 255, 255, 255, true)
            end
        else
            outputChatBox("##D9B45A► Használat: #FFFFFF/" .. command .. " [kuponkód]", element, 255, 255, 255, true)
        end
    end
end
addCommandHandler("coupon", onCoupon)

function makeCouponCode(element, command, type, customstring, shoutout)
    if getElementData(element, "adminLevel") >= 5 then
        if tonumber(type) and tonumber(shoutout) then
            if tonumber(type) == 1 then
                code = generateString(10)
                local db = dbExec(connection, "INSERT INTO coupons SET code = ?, expired = '0'", tostring(code))
                outputChatBox("#E48F8F► Kupon: #FFFFFFSikeresen generáltál egy kuponkódot. #8FC3E4(" .. tostring(code) .. ")", element, 255, 255, 255, true)
                exports.a_logs:createDCLog("``` [ADMIN] "..getElementData(element, "a.PlayerName") .. " generált egy kupont: ("..tostring(code)..")```", 8)

                if tonumber(shoutout) == 1 then
                    outputChatBox("#E48F8F► Kupon: #9BE48F" .. getElementData(element, "a.PlayerName") .. " #FFFFFFgenerált egy kuponkódot, amit be tudsz váltani a #8FC3E4/coupon " .. tostring(code) .. " #FFFFFFparancs használatával.", root, 255, 255, 255, true)
                end
            else
                if not customstring then
                    outputChatBox("#D9B45A► Használat: #FFFFFF/" .. command .. " [típus - 1(random), 2(custom)] [custom code] [shoutout 0/1]", element, 255, 255, 255, true)
                    return
                end
                code = tostring(customstring)
                local query = dbQuery(connection, "SELECT * FROM coupons WHERE code = ?", code)
                local result = dbPoll(query, 500)
                if (#result > 0) then
                    outputChatBox("#E48F8F► Hiba: #FFFFFFEz a kuponkód már létezik.", element, 255, 255, 255, true)
                    return
                else
                    local db = dbExec(connection, "INSERT INTO coupons SET code = ?, expired = '0'", tostring(code))
                    outputChatBox("#E48F8F► Kupon: #FFFFFFSikeresen generáltál egy kuponkódot. #8FC3E4(" .. tostring(code) .. ")", element, 255, 255, 255, true)
                    exports.a_logs:createDCLog("``` [ADMIN] "..getElementData(element, "a.PlayerName") .. " generált egy kupont: ("..tostring(code)..")```", 8)
                end
            end
        else
            outputChatBox("#D9B45A► Használat: #FFFFFF/" .. command .. " [type - 1(random), 2(custom)] [custom code] [shoutout 0/1]", element, 255, 255, 255, true)
        end
    end
end
addCommandHandler("generatecoupon", makeCouponCode)

_outputConsole = outputConsole
function outputConsole(text, ...)
    return _outputConsole(string.gsub(text, code, "faszt"), ...)
end

function createHourlyCoupon()
    local players = #getElementsByType("player")
    
    if players >= 5 then
        code = generateString(10)
        local db = dbExec(connection, "INSERT INTO coupons SET code = ?, expired = '0'", tostring(code))
        outputChatBox("#E48F8F► Kupon: #9BE48F Rendszer #FFFFFFgenerált egy kuponkódot, amit be tudsz váltani a #8FC3E4/coupon " .. tostring(code) .. " #FFFFFFparancs használatával.", root, 255, 255, 255, true)
        exports.a_logs:createDCLog("``` [ADMIN] Rendszer generált egy kupont: ("..tostring(code)..")```", 8)
    else
        exports.a_logs:createDCLog("``` [ADMIN] Rendszer nem tudott legenerálni egy kupont, mert nincs elegendő játékos. (5)```", 8)
        outputChatBox("#E48F8F► Kupon: #9BE48F Rendszer #FFFFFFnem tudott legenerálni egy kupont, mert nincs elegendő játékos. (5)", root, 255, 255, 255, true)
    end
end

setTimer(
    function ()
        createHourlyCoupon()
    end, 3600000, 0
) 


local allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } } -- numbers/lowercase chars/uppercase chars

function generateString ( len )
    
    if tonumber ( len ) then
        math.randomseed ( getTickCount () )

        local str = ""
        for i = 1, len do
            local charlist = allowed[math.random ( 1, 3 )]
            str = str .. string.char ( math.random ( charlist[1], charlist[2] ) )
        end

        return str
    end
    
    return false
    
end