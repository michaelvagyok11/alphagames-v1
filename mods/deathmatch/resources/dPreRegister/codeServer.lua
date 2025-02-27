local dbname = "s8878_tdma";
local host = "mysql.srkhost.eu";
local username = "u8878_cJiNzAC4Qi";
local password = "BKlxN1SAMOkk";

local con;
local connectionAttempts = 1;

function connectMysql()
	con = dbConnect( "mysql", "dbname="..dbname..";host="..host..";charset=utf8", username, password, "share=0" );

	if (con) then
		outputDebugString("A dPreRegister sikeresen kapcsolódott az adatbázishoz.", 0, 0, 255, 0);
		outputServerLog("A dPreRegister sikeresen kapcsolódott az adatbázishoz.")
	else
		outputDebugString("A dPreRegister nem tudott kapcsolódni az adatbázishoz. (ERROR: #MYSQLCONNECTION)", 0, 255, 0, 0);
		outputServerLog("A dPreRegister nem tudott kapcsolódni az adatbázishoz. (ERROR: #MYSQLCONNECTION)")
	end
end

connectMysql();

function getConnection()
	if (con) then
		return con;
	end
end

function checkSerial(element)
    -- ** AC
    if not element or not isElement(element) or not getElementType(element) == "player" then
        return
    end
    local clientPlayer = client

    if not clientPlayer and not client == source then
        return
    end
    -- ** AC VÉGE

    local serialQuery = dbQuery(con, "SELECT * FROM accounts WHERE serial = ?", getPlayerSerial(element))
    local serialQueryResult = dbPoll(serialQuery, -1)
    if (#serialQueryResult > 0) then
        triggerClientEvent("registerServerResponse", element, element, "serialCheckResult>>Exists", serialQueryResult[1]["playerName"])
    else
        triggerClientEvent("registerServerResponse", element, element, "serialCheckResult>>Available")
    end
end
addEvent("checkSerial", true)
addEventHandler("checkSerial", root, checkSerial)

function checkRegisterAttempt(element, registerData)
    -- ** AC
    if not element or not isElement(element) or not getElementType(element) == "player" then
        return
    end
    local clientPlayer = client

    if not clientPlayer and not client == source then
        return
    end
    -- ** AC VÉGE
    
    if registerData then
        local username, password, email, playerName, dataSave = registerData[1], registerData[2], registerData[3], registerData[4], registerData[5]
        if dataSave == true then
            dataSave = 1
        else
            dataSave = 0
        end

        local serialQuery = dbQuery(con, "SELECT * FROM accounts WHERE serial = ?", getPlayerSerial(element))
        local serialQueryResult = dbPoll(serialQuery, -1)
        if (#serialQueryResult > 0) then
            triggerClientEvent("registerServerResponse", element, element, "serialExists")
        else
            local usernameQuery = dbQuery(con, "SELECT * FROM accounts WHERE username = ?", username)
            local usernameQueryResult = dbPoll(usernameQuery, -1)
            if (#usernameQueryResult > 0) then
                triggerClientEvent("registerServerResponse", element, element, "usernameExists")
            else
                local emailQuery = dbQuery(con, "SELECT * FROM accounts WHERE email = ?", email)
                local emailQueryResult = dbPoll(emailQuery, -1)
                if (#emailQueryResult > 0) then
                    triggerClientEvent("registerServerResponse", element, element, "emailExists")
                else
                    local playerNameQuery = dbQuery(con, "SELECT * FROM accounts WHERE playerName = ?", playerName)
                    local playerNameQueryResult = dbPoll(playerNameQuery, -1)
                    if (#playerNameQueryResult > 0) then
                        triggerClientEvent("registerServerResponse", element, element, "playerNameExists")
                    else
                        local accountCreation = dbExec(con, "INSERT INTO accounts SET username = ?, password = ?, email = ?, playerName = ?, serial = ?, ip=?, registrationDate=NOW(), dataSave=?", username, base64Encode(password), email, playerName, getPlayerSerial(element), getPlayerIP(element), tonumber(dataSave))
                        --local accountCreation = false
                        if (accountCreation) then
                            triggerClientEvent("registerServerResponse", element, element, "successfulRegistration")
                        else
                            triggerClientEvent("registerServerResponse", element, element, "databaseError")
                        end
                    end
                end
            end
        end
    end
end
addEvent("checkRegisterAttempt", true)
addEventHandler("checkRegisterAttempt", root, checkRegisterAttempt)