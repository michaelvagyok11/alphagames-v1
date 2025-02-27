addCommandHandler( "commands", 
   function(player)
    if not (getElementData(player, "adminLevel" or 0) > 2) then 
        return 
    end
      local commandsList = {} --table to store commands
        
      --store/sort commands in the table where key is resource and value is table with commands
      for _, subtable in pairs( getCommandHandlers() ) do
     local commandName = subtable[1]
     local theResource = subtable[2]
            
         if not commandsList[theResource] then
        commandsList[theResource] = {}
     end
            
     table.insert( commandsList[theResource], commandName )
      end
        
      --output sorted information in the chat
      for theResource, commands in pairs( commandsList ) do
      local resourceName = getResourceInfo( theResource, "name" ) or getResourceName( theResource ) --try to get full name, if no full name - use short name
      outputChatBox( "== "..resourceName.. " ==", player, 0, 255, 0 )
            
      --output list of commands
      for _, command in pairs( commands ) do
         outputChatBox( "/"..command, player, 255, 255, 255 )
      end
      end
  end
)

local connection = exports.a_mysql:getConnection()

function onJoin()
    dbExec(connection, "DELETE FROM bans WHERE date<NOW()")
    dbExec(connection, "DELETE FROM vips WHERE date<NOW()")
end
addEventHandler("onResourceStart", getRootElement(), onJoin)

function executeLogin(element, username, password)
    if isElement(element) and username and password then
        dbQuery(function(queryHandler)
            local result = dbPoll(queryHandler, 0)
            if #result > 0 then
                for k, v in pairs(result) do 
                    if v.serial ~= getPlayerSerial(element) and serial ~= "0" then   
                        triggerClientEvent(element, "serverSideResponse", element, "serialError")
                        return
                    end
                end
                loginPlayer(element)
                dbExec(connection, "UPDATE accounts SET ip= '" .. getPlayerIP(element) .. "' WHERE serial = '" .. getPlayerSerial(element) .. "'")
                triggerClientEvent(element, "serverSideResponse", element, "successfulLogin")
            else
                triggerClientEvent(element, "serverSideResponse", element, "dataError")
                -- felh hiba
            end
        end, connection, "SELECT * FROM accounts WHERE username=? AND password=?", username, base64Encode(password))
    end
end
addEvent("executeLogin", true)
addEventHandler("executeLogin", root, executeLogin)

function executeRegister(element, username, password, email)
    if isElement(element) then
        if (connection) then
            dbQuery(function(queryHandler)
                local result, rows, insertid = dbPoll(queryHandler, 0)
                if #result > 0 then
                    triggerClientEvent(element, "serverSideResponse", element, "dataError")
                else
                    local savePlayer = dbExec(connection, "INSERT INTO accounts SET username=?, password=?, serial=?, ip=?, email=?", username, base64Encode(password), getPlayerSerial(element), getPlayerIP(element), tostring(email))
                    if (savePlayer) then
                        setElementData(element, "accID", insertid)
                        triggerClientEvent(element, "serverSideResponse", element, "successfulRegister")
                    else
                    
                    end
                end
            end, connection, "SELECT * FROM accounts WHERE username=?", username)
        end
    end
end
addEvent("executeRegister", true)
addEventHandler("executeRegister", root, executeRegister)

local delayTimer = {}

function loginPlayer(player)
    local spawnQuery = dbPoll(dbQuery(connection, "SELECT * FROM accounts WHERE serial = ?", getPlayerSerial(player)), -1)
    if #spawnQuery > 0 then
        for _, v in ipairs(spawnQuery) do
            --local respawnPosition = getElementData(player, "a.Respawnpos") or {0, 0, 5}
            spawnPlayer(player, 1159.271484375, -1366.287109375, 494.880859375)
            for _, stat in ipairs({ 24, 69, 70, 71, 72, 73, 74, 76, 77, 78, 79 }) do
                setPedStat(player, stat, 1000)
            end
            setElementFrozen(player, true)
            setElementRotation(player, 0, 0, 300)
            setElementAlpha(player, 100)
            delayTimer[player] = setTimer(function() 
                setElementAlpha(player, 255)
                setCameraTarget(player, player)
                setElementData(player, "loggedIn", true)
                setElementFrozen(player, false)
            end, 5001, 1)
            setPedWalkingStyle(player, 118)
            setElementData(player, "adminLevel", v["alevel"])
            setElementData(player, "a.PlayerName", getPlayerName(player))
            setElementData(player, "adminNick", v["anick"])
            setElementModel(player, v["skin"])
            setElementData(player, "a.Skin", v["skin"])
            setElementData(player, "a.HUDshowed", true)
            setElementData(player, "a.NameShowing", false)
            setPlayerBlurLevel(player, 0)
            setElementData(player, "a.Warns", 0)

            setElementData(player, "a.Kills", v["kills"])
            setElementData(player, "a.Deaths", v["deaths"])
            setElementData(player, "a.PlayerGroup", v["playerGroup"])
            setElementData(player, "a.accID", v["id"])           
            setElementData(player, "a.Experience", v["xp"])
            setElementData(player, "a.Level", v["level"])
            setElementData(player, "a.Money", v["money"])
            setElementData(player, "a.Gamemode", nil)

            if tonumber(v["vip"]) == 1 then
                setElementData(player, "a.VIP", true)
            else
                setElementData(player, "a.VIP", false)
            end

            setElementData(player, "a.Premiumpont", v["pp"])
            setElementData(player, "a.Dueloffered", false)
            setElementData(player, "a.Crosshair", v["crosshair"])
            setElementData(player, "a.totalDrift", v["totalDrift"])
            setElementData(player, "a.lastDrift", 0)
            setElementData(player, "a.bestDrift", v["bestDrift"])
            if tonumber(v["muted"]) == 1 then
                setElementData(player, "a.Muted", true)
                setElementData(player, "a.Mutetime", v["mutetime"])
            else
                setElementData(player, "a.Muted", false)
            end

            local vehTable = fromJSON(v["unlockedVehs"]) or {}
            setElementData(player, "a.BoughtVehs", vehTable)


            dbQuery(function(handler)
                local result = dbPoll(handler, 0)
                if #result == 0 then
                    setElementData(player, "a.VIP", false)
                end
            end, connection, "SELECT * FROM vips WHERE accid = '" .. getElementData(player, "a.accID") .. "'")

            local hpVehTable = fromJSON(v["hpVeh"]) or {596, 445}
            setElementData(player, "a.HPVehicle", hpVehTable)

            local hpSkinTable = fromJSON(v["hpSkin"]) or {51, 55}
            setElementData(player, "a.HPSkin", hpSkinTable)

            local hpBoughtVehs = fromJSON(v["hpBoughtVehs"]) or {596, 445}
            setElementData(player, "a.HPBoughtVehs", hpBoughtVehs)

            setElementData(player, "a.GuardLevel", v["guardLevel"])
        end
    end
end