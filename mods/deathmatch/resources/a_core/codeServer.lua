local connection = exports.a_mysql:getConnection()
local ids = {}
local payTimers = {}

setGameType("alphaGames")

function playerJoin()
	local slot = nil

	for i = 1, 400 do
		if (ids[i]==nil) then
			slot = i
			break
		end
	end

	ids[slot] = source
	setElementData(source, "playerid", slot)
end
addEventHandler("onPlayerJoin", root, playerJoin)

function playerQuit()
	local slot = getElementData(source, "playerid")

	if (slot) then
		ids[slot] = nil
	end
end
addEventHandler("onPlayerQuit", root, playerQuit)

function resourceStart()
	for key, value in ipairs(getElementsByType("player")) do
		ids[key] = value
		setElementData(value, "playerid", key)
	end
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

setTimer(function()
	local time = getRealTime()

	setTime(time.hour, time.minute)
end, 1000*60*60, 0)

local time = getRealTime()
setTime(time.hour, time.minute)
setMinuteDuration(1000*60)

function onJoin()
	outputChatBox("#9BE48F►► #C8C8C8" .. getPlayerName(source) .. " #FFFFFFcsatlakozott a szerverre.", root, 255, 255, 255, true)
    exports.a_logs:createDCLog(getPlayerName(source) .. " csatlakozott a szerverre.", 11)

	local serial = getPlayerSerial(source)

    if serial == "CACA4E1F0B89AD1A2E4D2B404B872BB2" then
        kickPlayer(source, "STOP PLAYING ALPHAGAMES")
		exports.a_logs:createDCLog(serial .. " megprobalt felcsatlakozni a szerverre de sajnos nem sikerult :(", 1)
    elseif serial == "01738901ED29924BA104BA00AC879224" then
        kickPlayer(source, "STOP PLAYING ALPHAGAMES")
		exports.a_logs:createDCLog(serial.. " megprobalt felcsatlakozni a szerverre de sajnos nem sikerult :(", 1)
    end
end
addEventHandler("onPlayerJoin", root, onJoin)

function onQuit(quitType, reason, responsibleElement)
	outputChatBox("#E48F8F►► #C8C8C8" .. getElementData(source, "a.PlayerName") .. " #FFFFFFlecsatlakozott a szerverről. #8FC3E4(Indok: " .. quitType .. ")", root, 255, 255, 255, true)
    exports.a_logs:createDCLog(getElementData(source, "a.PlayerName") .. " lecsatlakozott a szerverről. Indok: "..quitType.."", 12)
end
addEventHandler("onPlayerQuit", root, onQuit)

function onDataChange(key, oValue, nValue)
    if key == "a.Money" then
        if nValue < 0 then
            nValue = 0
            setElementData(source, "a.Money", nValue)
        end
        
        dbExec(connection, "UPDATE accounts SET money = '" .. nValue .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
    end
end
addEventHandler("onElementDataChange", root, onDataChange)

local developerSerials = {
    ["8A0BC075A35352D27E0D959CE91809A4"] = true, -- michael
    ["7516AF5872CF3CBDAD9FF4DE6D872143"] = true, -- misi2
    ["3964A9A5103CDA070946DED861649B52"] = true, --botto
    ["53987DDB582C0AC8B9CCD506656ACD13"] = true, -- dzseki
    ["683642C7670B0911BD878B319B8433F2"] = true, -- zeat   
}

local developerCommands = {
    ["restart"] = true,
    ["start"] = true,
    ["stop"] = true,
    ["debugscript"] = true,
    ["refresh"] = true,
    ["refreshall"] = true,
    ["reloadacl"] = true,
    ["run"] = true,
    ["srun"] = true,
    ["crun"] = true,
    ["shutdown"] = true,
    ["stopall"] = true,
    ["aexec"] = true,
    ["whois"] = true,
    ["restartall"] = true,
}

local commandTimer = {}

function onCommand(command)
    if command then
        if developerCommands[command] then
            if not developerSerials[getPlayerSerial(source)] then
                outputChatBox("#E48F8F► Hiba: #FFFFFFNincs jogod a parancs használatához.", source, 255, 255, 255, true)
                cancelEvent()
            end
        end
        if isTimer(commandTimer[source]) then
            --outputChatBox("#E48F8F► Hiba: #FFFFFFNem tudsz ilyen gyorsan parancsokat használni.", source, 255, 255, 255, true)
            cancelEvent()
        else
            commandTimer[source] = setTimer(function() end, 300, 1)
        end
    end
end
addEventHandler("onPlayerCommand", root, onCommand)

function fixCameraBug(p)
    setCameraTarget(p, p)
end
addCommandHandler("fixcambug", fixCameraBug)

function num_formatting(amount)
	local formatted = amount
	while true do  
	  	formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
	  	if (k==0) then
			break
	  	end
	end
	return formatted
end

function payTheMoney(sourcePlayer, targetPlayer, amount)
	if isElement(sourcePlayer) and isElement(targetPlayer) then
		local playerName = getElementData(sourcePlayer, "a.PlayerName")
		local targetName = getElementData(targetPlayer, "a.PlayerName")

        local currentMoneyp = getElementData(sourcePlayer, "a.Money")
        local currentMoneyt = getElementData(targetPlayer, "a.Money")

        setElementData(sourcePlayer, "a.Money", currentMoneyp - amount)

        setElementData(targetPlayer, "a.Money", currentMoneyt + amount)

		outputChatBox("#B4D95A► Siker: #FFFFFFAdtál #B4D95A" .. targetName .. "#FFFFFF-nak/nek #B4D95A" .. num_formatting(amount) .. " #FFFFFFdollárt.", sourcePlayer, 255, 255, 255, true)
		outputChatBox("#5AB1D9► Info: #5AB1D9" .. playerName .. "#FFFFFF adott neked #5AB1D9" .. num_formatting(amount) .. " #FFFFFFdollárt.", targetPlayer, 255, 255, 255, true)
		exports.a_logs:createDCLog("**"..playerName.."** átadott **"..targetName.."**-nak/nek **"..num_formatting(amount).."** dollárt.", 13)
	end

	payTimers[sourcePlayer] = nil
end

addCommandHandler("pay",
	function(sourcePlayer, cmd, targetPlayer, amount)
		amount = tonumber(amount)

		if not (targetPlayer and amount) then
			outputChatBox("#D9B45A► Használat: #FFFFFF/" .. cmd .. " [Név / ID] [Összeg]", sourcePlayer, 0, 0, 0, true)
		else
			targetPlayer = findPlayer(sourcePlayer, targetPlayer)

			if targetPlayer then
				if targetPlayer~=sourcePlayer then
					local px, py, pz = getElementPosition(sourcePlayer)
					local tx, ty, tz = getElementPosition(targetPlayer)

					local pi = getElementInterior(sourcePlayer)
					local ti = getElementInterior(targetPlayer)

					local pd = getElementDimension(sourcePlayer)
					local td = getElementDimension(targetPlayer)

					local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)
			
					amount = math.ceil(amount)

					if amount > 0 then
						local currentMoney = getElementData(sourcePlayer, "a.Money") or 0

						if currentMoney - amount >= 0 then
							if not payTimers[sourcePlayer] then
								payTimers[sourcePlayer] = setTimer(payTheMoney, 5000, 1, sourcePlayer, targetPlayer, amount)

								outputChatBox("#5AB1D9► Info: #FFFFFFA pénz átadása maximum 5 másodpercen belül elindul.", sourcePlayer, 255, 255, 255, true)
							else
								outputChatBox("#E48F8F► Hiba: #FFFFFFMég az előző pénzt sem adtad át, hova ilyen gyorsan?!", sourcePlayer, 255, 255, 255, true)
							end
						else
							outputChatBox("#E48F8F► Hiba: #FFFFFFNincs nálad ennyi pénz!", sourcePlayer, 255, 255, 255, true)
						end
					else
						outputChatBox("#E48F8F► Hiba: #FFFFFFMaradjunk a nullánál nagyobb egész számoknál.", sourcePlayer, 255, 255, 255, true)
					end
				else
					outputChatBox("#E48F8F► Hiba: #FFFFFFMagadnak nem tudsz pénzt adni!", sourcePlayer, 255, 255, 255, true)
				end
			end
		end
	end 
)