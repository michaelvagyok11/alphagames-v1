local dbname = "s33503_alphagames1";
local host = "mysql.srkhost.eu";
local username = "u33503_hAbJyjb91o";
local password = "lxIen=nlI2ej7s2A^Pbe9x!z";

local con;
local connectionAttempts = 1;

function connectMysql()
	con = dbConnect( "mysql", "dbname="..dbname..";host="..host..";charset=utf8", username, password, "share=0" );

	if (con) then
		outputDebugString("MySQL connection was succesful.", 0, 255, 255, 0);
		outputServerLog("MySQL connection succesful.")
		connectionAttempts = 1;
	else
		outputDebugString("MySQL connection failed. Trying it again.", 0, 255, 255, 0);
		outputServerLog("MySQL connection failed. Trying again.")
		if (connectionAttempts < 3) then
			connectionAttempts = connectionAttempts + 1;
			setTimer(connectMysql, 10000, 1);
		else
			outputDebugString("MySQL connection failed. Server is going to stop in 30 seconds.", 0, 255, 255, 0);
			outputServerLog("MySQL connection failed. Server is going to stop in 30 seconds.")
			setTimer(function()
				shutdown("MySQL connection failed.");
			end, 30000, 1);
		end
	end
end

connectMysql();

function getConnection()
	if (con) then
		return con;
	end
end