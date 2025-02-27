local connection = exports.a_mysql:getConnection()

function setPlayerAdminLevel(thePlayer, adminLevel)
    if isElement(thePlayer) and tonumber(adminLevel) then
        setElementData(thePlayer, "adminLevel", tonumber(adminLevel))
        dbExec(connection, "UPDATE accounts SET alevel = ? WHERE serial = ?", tonumber(adminLevel), getPlayerSerial(thePlayer))
    end
end

function setPlayerAdminNick(thePlayer, adminNick)
    if isElement(thePlayer) and tostring(adminNick) then
        setElementData(thePlayer, "adminNick", tostring(adminNick))
        dbExec(connection, "UPDATE accounts SET anick = ? WHERE serial = ?", tostring(adminNick), getPlayerSerial(thePlayer))
    end
end

function setPlayerSkin(thePlayer, modelID)
    if isElement(thePlayer) and tonumber(modelID) then
        setElementModel(thePlayer, tonumber(modelID))
        setElementData(thePlayer, "a.Skin", tonumber(modelID))
        dbExec(connection, "UPDATE accounts SET skin = ? WHERE serial = ?", tonumber(modelID), getPlayerSerial(thePlayer))
    end
end

function setPlayerMoney(thePlayer, moneyAmount)
    if isElement(thePlayer) and tonumber(moneyAmount) then
        setElementData(thePlayer, "a.Money", tonumber(moneyAmount))
        dbExec(connection, "UPDATE accounts SET money = ? WHERE serial = ?", tonumber(moneyAmmount), getPlayerSerial(thePlayer))
    end
end

function setPlayerPremiumPoints(thePlayer, ppAmount)
    if isElement(thePlayer) and tonumber(ppAmount) then
        setElementData(thePlayer, "a.Premiumpont", tonumber(ppAmount))
        dbExec(connection, "UPDATE accounts SET pp = ? WHERE serial = ?", tonumber(ppAmount), getPlayerSerial(thePlayer))
    end
end

-- ** Adminisztrátori jogosultság, név állítására alkalmas parancsok.

addAdminCommand("setadminlevel", "Adminisztrátori szint állítása.", 6)
addCommandHandler("setadminlevel", 
    function(sourcePlayer, commandName, targetPlayer, adminLevel)
        if isPlayerHavePermission(sourcePlayer, commandName) or exports.a_core:isPlayerDeveloper(getPlayerSerial(sourcePlayer)) then
            if not (targetPlayer and adminLevel) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Szint]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

				if getElementData(sourcePlayer, "adminLevel") <= 5 and targetPlayer == sourcePlayer then
					return outputChatBox("na hat ez majdnem osszejott baratom :D", sourcePlayer, 255, 255, 255, true)
				end

                if targetPlayer then
                    setPlayerAdminLevel(targetPlayer, adminLevel)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFadminisztrátori szintjét. Új szint: #8FC3E4" .. adminLevel .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta adminisztrátori szinted. Új szint: #8FC3E4" .. adminLevel .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFadminisztrátori szintjét. Új szint: #8FC3E4" .. adminLevel .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setadminnick", "Adminisztrátori becenév állítása.", 6)
addCommandHandler("setadminnick", 
    function(sourcePlayer, commandName, targetPlayer, adminNick)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and adminNick) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Név]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerAdminNick(targetPlayer, adminNick)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFadminisztrátori nevét. Új név: #8FC3E4" .. adminNick .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta adminisztrátori neved. Új név: #8FC3E4" .. adminNick .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFadminisztrátori nevét. Új név: #8FC3E4" .. adminNick .. "#FFFFFF.")
                end
            end
        end
    end
)

-- ** Alap parancsok.

addAdminCommand("goto", "Teleportálás egy játékoshoz.", 1)
addCommandHandler("goto", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    local x, y, z = getElementPosition(targetPlayer)
                    local rx, ry, rz = getElementRotation(targetPlayer)
                    local dim, int = getElementDimension(targetPlayer), getElementInterior(targetPlayer)

					if isPedInVehicle(sourcePlayer) then
						local pedVehicle = getPedOccupiedVehicle(sourcePlayer)

						setElementPosition(pedVehicle, math.floor(x), math.floor(y), z, true)
                    	setElementRotation(pedVehicle, rx, ry, rz)
                    	setElementDimension(pedVehicle, dim)
                    	setElementInterior(pedVehicle, int)
					else
						setElementPosition(sourcePlayer, math.floor(x), math.floor(y), z, true)
                    	setElementRotation(sourcePlayer, rx, ry, rz)
                    	setElementDimension(sourcePlayer, dim)
                    	setElementInterior(sourcePlayer, int)
					end

                    outputChatBox(successSyntax .. "Sikeresen hozzá teleportáltál #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékoshoz.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFhozzád teleportált.", targetPlayer, 255, 255, 255, true)
                end
            end
        end
    end
)

addAdminCommand("gotopos", "Teleportálás egy koordinátára.", 6)
function gotoxyz(sourcePlayer, commandName, posX, posY, posZ)
	if getElementData(sourcePlayer, "adminLevel") >= 6 then 
		setElementPosition(sourcePlayer, posX, posY, posZ)
	end
end
addCommandHandler("gotopos", gotoxyz)

addAdminCommand("gethere", "Egy játékos magadhoz teleportálása.", 1)
addCommandHandler("gethere", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    local x, y, z = getElementPosition(sourcePlayer)
                    local rx, ry, rz = getElementRotation(sourcePlayer)
                    local dim, int = getElementDimension(sourcePlayer), getElementInterior(sourcePlayer)

                    if isPedInVehicle(targetPlayer) then
						local pedVehicle = getPedOccupiedVehicle(targetPlayer)
					
						setElementPosition(pedVehicle, math.floor(x), math.floor(y), z, true)
						setElementRotation(pedVehicle, rx, ry, rz)
						setElementDimension(pedVehicle, dim)
						setElementInterior(pedVehicle, int)
					else
						setElementPosition(targetPlayer, math.floor(x), math.floor(y), z, true)
						setElementRotation(targetPlayer, rx, ry, rz)
						setElementDimension(targetPlayer, dim)
						setElementInterior(targetPlayer, int)
					end
					outputChatBox(successSyntax .. "Sikeresen magadhoz teleportáltad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékost.", sourcePlayer, 255, 255, 255, true)
					outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmagához teleportált.", targetPlayer, 255, 255, 255, true)
				end
            end
        end
    end
)

addAdminCommand("freeze", "Egy játékos lefagyasztása.", 1)
addCommandHandler("freeze", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setElementFrozen(targetPlayer, true)
                    toggleAllControls(targetPlayer, false, false, true)

                    outputChatBox(successSyntax .. "Sikeresen lefagyasztottad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékost.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFlefagyasztott téged.", targetPlayer, 255, 255, 255, true)
                end
            end
        end
    end
)

addAdminCommand("unfreeze", "Egy játékos lefagyasztásának feloldása.", 1)
addCommandHandler("unfreeze", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setElementFrozen(targetPlayer, false)
                    toggleAllControls(targetPlayer, true, true, true)

                    outputChatBox(successSyntax .. "Sikeresen feloldottad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjátékos lefagyasztását.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFfeloldotta a lefagyasztásod.", targetPlayer, 255, 255, 255, true)
                end
            end
        end
    end
)

addAdminCommand("vanish", "Magad láthatatlanná tétele.", 1)
addCommandHandler("vanish",
    function(sourcePlayer, commandName)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            local invisible = getElementData(sourcePlayer, "invisible")

            if invisible then
                setElementAlpha(sourcePlayer, 255)
            else
                setElementAlpha(sourcePlayer, 0)
            end

            setElementData(sourcePlayer, "invisible", not invisible)
        end
    end
)

addAdminCommand("sethp", "Egy játékos életerejének beállítása.", 1)
addCommandHandler("sethp", 
    function(sourcePlayer, commandName, targetPlayer, healthLevel)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and healthLevel) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Szint]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setElementHealth(targetPlayer, healthLevel)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFéleterejét. Új szint: #8FC3E4" .. healthLevel .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta életerőd. Új szint: #8FC3E4" .. healthLevel .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFéleterejét. Új szint: #8FC3E4" .. healthLevel .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setarmor", "Egy játékos páncéljának beállítása.", 1)
addCommandHandler("setarmor", 
    function(sourcePlayer, commandName, targetPlayer, armorLevel)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and armorLevel) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Szint]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPedArmor(targetPlayer, armorLevel)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFpáncélját. Új szint: #8FC3E4" .. armorLevel .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta páncélod. Új szint: #8FC3E4" .. armorLevel .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFpáncélját. Új szint: #8FC3E4" .. armorLevel .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setskin", "Egy játékos kinézetének beállítása.", 1)
addCommandHandler("setskin", 
    function(sourcePlayer, commandName, targetPlayer, skinID)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and skinID) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerSkin(targetPlayer, skinID)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFkinézetét. Új skin: #8FC3E4" .. skinID .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta kinézeted. Új skin: #8FC3E4" .. skinID .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    --outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFkinézetét. Új skin: #8FC3E4" .. skinID .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setmoney", "Egy játékos pénzének beállítása.", 6)
addCommandHandler("setmoney", 
    function(sourcePlayer, commandName, targetPlayer, moneyAmount)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and moneyAmount) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Összeg]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerMoney(targetPlayer, moneyAmount)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFpénzét. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta pénzed. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFpénzét. Új összeg: #8FC3E4" .. moneyAmount .. "#FFFFFF.")
                end
            end
        end
    end
)

addAdminCommand("setpp", "Egy játékos prémiumpontjának beállítása.", 6)
addCommandHandler("setpp", 
    function(sourcePlayer, commandName, targetPlayer, ppAmount)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and ppAmount) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Összeg]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    setPlayerPremiumPoints(targetPlayer, ppAmount)

                    outputChatBox(successSyntax .. "Sikeresen megváltoztattad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFPP egyenlegét. Új összeg: #8FC3E4" .. ppAmount .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta PP egyenleged. Új összeg: #8FC3E4" .. ppAmount .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFPP egyenlegét. Új összeg: #8FC3E4" .. ppAmount .. "#FFFFFF.")
					exports.a_logs:createDCLog(getElementData(sourcePlayer, "a.PlayerName").. " megváltoztatta ".. getElementData(targetPlayer, "a.PlayerName") .." PP egyenlegét. Új összeg: **".. ppAmount .." PP**.", 1)
                end
            end
        end
    end
)

addAdminCommand("givepp", "Prémiumpont egyenleg növelése.", 6)
addCommandHandler("givepp", 
    function(sourcePlayer, commandName, targetPlayer, ppAmount)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer and ppAmount) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Összeg]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
					local currentPP = getElementData(targetPlayer, "a.Premiumpont") or 0
					local newPP = currentPP

					newPP = currentPP + ppAmount

					setElementData(targetPlayer, "a.Premiumpont", newPP)
					dbExec(connection, "UPDATE accounts SET pp = ? WHERE serial = ?", tonumber(newPP), getPlayerSerial(targetPlayer))

                    outputChatBox(successSyntax .. "Sikeresen megnövelted #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFPP egyenlegét. Új egyenleg: #8FC3E4" .. newPP .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                    outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegnövelte PP egyenleged #8FC3E4"..ppAmount.." PP-vel.#ffffff Új egyenleg: #8FC3E4" .. newPP .. "#FFFFFF.", targetPlayer, 255, 255, 255, true)
                    outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegnövelte #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFPP egyenlegét #8FC3E4" .. ppAmount .. " PP-vel.#ffffff Új egyenleg: #8FC3E4" .. newPP .. "#FFFFFF.")
					exports.a_logs:createDCLog("**" ..getElementData(sourcePlayer, "a.PlayerName").. "** megnövelte **".. getElementData(targetPlayer, "a.PlayerName") .."** PP egyenlegét **" .. ppAmount .. " PP-vel**. Régi egyenleg: **"..currentPP.." PP** | Új egyenleg: **".. newPP .." PP**.", 1)
                end
            end
        end
    end
)

addAdminCommand("stats", "Játékos statisztikáinak lekérése.", 1)
function statPlayer(sourcePlayer, commandName, targetElement)
	if getElementData(sourcePlayer, "adminLevel") >= 1 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			if (targetPlayer) then
				local accountID = getElementData(targetPlayer, "a.accID")
				local name = getElementData(targetPlayer, "a.PlayerName")
				local money = getElementData(targetPlayer, "a.Money")
				local pp = getElementData(targetPlayer, "a.Premiumpont")
				local experience = getElementData(targetPlayer, "a.Experience")
				local mutetime = getElementData(targetPlayer, "a.Mutetime")
				local muteindok = getElementData(targetPlayer, "a.Mutereason") or "#DB7D7DNincs lenémítva"
				local skinid = getElementData(targetPlayer, "a.Skin")
				local vip = getElementData(targetPlayer, "a.VIP") or false
				if vip == true then
					vip = "#C4CD5DIgen"
				else
					vip = "#DB7D7DNem"
				end
				if not mutetime then
					mutetime = "#DB7D7DNincs lenémítva"
				else
					mutetime = num_formatting(tonumber(mutetime)) .. " perc"
				end

				outputChatBox(adminSyntax .. "" .. name .. " #8FC3E4(ID: " .. getElementData(targetPlayer, "playerid") .. ")", sourcePlayer, 255, 255, 255, true)
				outputChatBox("AccountID: #8FC3E4" .. accountID .. " #FFFFFF// Pénz: #8FC3E4" .. num_formatting(tonumber(money)) .. "$#FFFFFF // PP: #8FC3E4" .. num_formatting(tonumber(pp)) .. " PP #FFFFFF// XP: #8FC3E4" .. num_formatting(tonumber(experience)) .. " XP#FFFFFF\nMute idő: #8FC3E4" .. mutetime .. "#FFFFFF // Mute indok: #8FC3E4" .. muteindok .. "#ffffff // Skin ID: #8FC3E4".. skinid .. "#ffffff // VIP: ".. vip .. "", sourcePlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("stats", statPlayer)

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

addAdminCommand("changename", "Játékos nevének átírása", 1)
function changeName(sourcePlayer, commandName, targetElement, newName)
	if getElementData(sourcePlayer, "adminLevel") >= 1 then
		if not (targetElement and newName) then
			outputChatBox(usageSyntax .. "/changename [Név/ID] [Új név]", sourcePlayer, 255, 255, 255, true)
		end
		if targetElement and newName then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)

			if targetPlayer and newName == getElementData(targetPlayer, "a.PlayerName") then
				outputChatBox(errorSyntax .. "Már ez a neve!", sourcePlayer, 255, 255, 255, true)
				return
			elseif targetPlayer and newName then
				local oldName = getElementData(targetPlayer, "a.PlayerName")

				outputChatBox(successSyntax .. "Sikeresen átírtad #8FC3E4"..oldName.." #ffffffnevét a következőre: #8FC3E4"..newName.."#ffffff.", sourcePlayer, 255, 255, 255, true)

				for k, v in ipairs(getElementsByType("player")) do
					if getElementData(v, "adminLevel") >= 1 then
						outputChatBox(adminSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta #8FC3E4" .. oldName .. " #FFFFFFnevét. Új név: #8FC3E4" .. newName .. "#FFFFFF.", v, 255, 255, 255, true)
					end
				end
				
				exports.a_logs:createDCLog("**" .. getElementData(sourcePlayer, "a.PlayerName") .. "** megváltoztatta **"..oldName.."** nevét a következőre: **"..newName.."**.", 1)

				setElementData(targetPlayer, "a.PlayerName", newName)
				dbExec(connection, "UPDATE accounts SET playerName = ? WHERE serial = ?", newName, getPlayerSerial(targetPlayer))

				outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegváltoztatta a nevedet a következőre: #8FC3E4"..newName.."#FFFFFF.", targetPlayer, 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("changename", changeName)

addAdminCommand("kick", "Játékos kirúgása a szerverről", 1)
function kickElement(sourcePlayer, commandName, targetElement, ...)
	if getElementData(sourcePlayer, "adminLevel") >= 1 then
		if targetElement and (...) then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			local reason = table.concat({...}, " ")
			if targetPlayer and reason then
				
				local targetSerial = getPlayerSerial(targetPlayer);

				local targetAdminLevel = getElementData(targetPlayer, "adminLevel")
				local playerAdminLevel = getElementData(sourcePlayer, "adminLevel")
				if targetAdminLevel > playerAdminLevel and playerAdminLevel < 3 then
					outputChatBox(errorSyntax .. "A kickelni kívánt játékosnak nagyobb az adminszintje mint a tiéd, így nem tudod kickelni.", sourcePlayer, 255, 255, 255, true)
					return
				end
				outputChatBox("#E48F8F[Kick]: #9BE48F" .. getElementData(sourcePlayer, "a.PlayerName") .. "#FFFFFF kirúgta #9BE48F" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFF játékost a szerverről. #8FC3E4(Indok: " .. table.concat({...}, " ") .. ")", root, 255, 255, 255, true)
				kickPlayer(targetPlayer, sourcePlayer, table.concat({...}, " "))
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Indok]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("kick", kickElement)

addAdminCommand("pm", "PM írása.", 0)
function privateMessageToPlayer(sourcePlayer, commandName, targetElement, ...)
	if isElement(sourcePlayer) then
		if (...) then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			if (targetPlayer) then
				local text = table.concat({...}, " ")
				local targetPlayerName = getElementData(targetPlayer, "a.PlayerName")
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"

				if string.find(text, "@everyone") then 
					outputChatBox("#E48F8F[Ban]: #9BE48F Rendszer#FFFFFF banned#9BE48F " .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFfrom server. #8FC3E4(Reason: @everyone dc webhookon - permanent)", root, 255, 255, 255, true)
					return banPlayer(sourcePlayer, true, true, true, "Console", "@everyone spam")
				end

				outputChatBox("#E9CB6F[Üzenet]: #FFFFFF" .. getElementData(sourcePlayer, "a.PlayerName") .. " ("..getElementData(sourcePlayer, "playerid")..") --> #C0C0C0" .. text, targetPlayer, 255, 255, 255, true)
				outputChatBox("#E9CB6F[Üzenet]: #FFFFFF" .. getElementData(targetPlayer, "a.PlayerName") .. " ("..getElementData(targetPlayer, "playerid")..") --> #C0C0C0" .. text, sourcePlayer, 255, 255, 255, true)
				exports.a_logs:createDCLog(getElementData(sourcePlayer, "a.PlayerName") .. " -> " .. targetPlayerName .. ": " .. text, 4)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [üzenet]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("pm", privateMessageToPlayer, false, false)

addAdminCommand("vá", "VÁ írása.", 0)
function replyToPlayer(sourcePlayer, commandName, targetElement, ...)
	if isElement(sourcePlayer) then
		if (...) then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			if (targetPlayer) then
				local text = table.concat({...}, " ")
				local targetPlayerName = getElementData(targetPlayer, "a.PlayerName")
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"

				outputChatBox("#E9CB6F[Segítség]: #FFFFFF" .. getElementData(sourcePlayer, "a.PlayerName") .. " ("..getElementData(sourcePlayer, "playerid")..") --> #C0C0C0" .. text, targetPlayer, 255, 255, 255, true)
				outputChatBox("#E9CB6F[Válasz]: #FFFFFF" .. getElementData(targetPlayer, "a.PlayerName") .. " ("..getElementData(targetPlayer, "playerid")..") --> #C0C0C0" .. text, sourcePlayer, 255, 255, 255, true)
				exports.a_logs:createDCLog(getElementData(sourcePlayer, "a.PlayerName") .. " -> " .. targetPlayerName .. ": " .. text .. " *(reply)*", 4)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [üzenet]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("vá", replyToPlayer, false, false)

function getPlayerNameBySerial(sourcePlayer, command, serial)
	local db = exports.a_mysql:getConnection()
	
	if not serial then
		outputChatBox(usageSyntax .. "/"..command.." [serial]", sourcePlayer, 255, 255, 255, true)
	end

	if serial then
		if db then
			local query = dbQuery(db, "SELECT playerName FROM accounts WHERE serial=?", serial)
			local result, num_affected_rows = dbPoll(query, -1)
			if num_affected_rows > 0 then
				local playerName = result[1]["playerName"]
				outputChatBox(successSyntax .."Ehhez a serialhoz tartozó játékos neve: #E48F8F" .. playerName, sourcePlayer, 255, 255, 255, true)
			else
				outputChatBox(errorSyntax .. "Nincs találat a megadott serial alapján.", sourcePlayer, 255, 255, 255, true)
			end
			dbFree(query)
			dbFree(db)
		else
			outputChatBox(errorSyntax .. "Nem sikerült kapcsolódni az adatbázishoz.", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("getname", getPlayerNameBySerial)

addAdminCommand("unban", "Egy játékos unbanolása.", 3)
function unBanPlayer(sourcePlayer, commandName, serial)
	if getElementData(sourcePlayer, "adminLevel") >= 3 then
		if (serial) then
			reloadBans()
			local banList = getBans()
			for k, v in ipairs(banList) do
				local banSerial2 = getBanSerial(v)
				local playerName = getElementData(sourcePlayer, "a.PlayerName")
				if banSerial2 == serial then
					outputChatBox(successSyntax .. "Sikeresen unbanoltad #9BE48F" .. getBanSerial(v) .. "#FFFFFF-t.", sourcePlayer, 255, 255, 255, true)
					removeBan(v, sourcePlayer)
					exports.a_logs:createDCLog(playerName.. " feloldotta " .. banSerial2.. " kitiltását", 1)
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Serial]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("unban", unBanPlayer)

function banElement(sourcePlayer, commandName, targetElement, time, ...)
	if getElementData(sourcePlayer, "adminLevel") >= 3 then
		if targetElement and ... and time then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			local reason = table.concat({...}, " ")
			if targetPlayer and reason and time then
				
				local targetSerial = getPlayerSerial(targetPlayer);

				local time = tonumber(time)
				if time > 1 then
					duration = time .. " óra"
					seconds = time*60*60
					db = dbExec(connection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL "..tonumber(time).." HOUR), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(sourcePlayer, "adminNick"),reason)
				elseif time == 1 then
					duration = "1 hónap"
					seconds = 30*24*60*60
					db = dbExec(connection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 1 MONTH), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(sourcePlayer, "adminNick"),reason)
				elseif time == 0 then
					duration = "1 év"
					seconds = 365*24*60*60
					db = dbExec(connection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 1 YEAR), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(sourcePlayer, "adminNick"),reason)
				end
				outputChatBox("#E48F8F► Ban: #9BE48F" .. getElementData(sourcePlayer, "a.PlayerName") .. "#FFFFFF kibannolta#9BE48F " .. getElementData(targetPlayer, "a.PlayerName") .. "#FFFFFF-t a szerverről. #8FC3E4(Indok: " .. reason .. " - " .. duration .. ")", root, 255, 255, 255, true)
				exports.a_logs:createDCLog("**" .. getElementData(sourcePlayer, "a.PlayerName") .. "** kibannolta a szerverről **" .. getElementData(targetPlayer, "a.PlayerName") .. "**-t. Indok: **"..reason.."** | Időtartam: **"..duration.."**", 1)
				if (db) then
					banPlayer(targetPlayer, true, true, true, sourcePlayer, reason, seconds)
					--print("siker")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Idő] [Indok]", sourcePlayer, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Idő: #9BE48FNagyobb mint 1#FFFFFF - x óra; #9BE48F1#FFFFFF - 1 hónap; #9BE48F0#FFFFFF - 1 év", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("ban", banElement)

addAdminCommand("offban", "Egy játékos banolása ha offline.", 4)
function offlineBanS(sourcePlayer, commandName, serial, time, ...)
	if getElementData(sourcePlayer, "adminLevel") >= 4 then
		if (serial) and (...) and (time) then
			reloadBans()
			if tonumber(time) > 1 then
				addBan(nil, nil, serial, sourcePlayer, table.concat({...}, " "), time*60*60)
				outputChatBox(successSyntax .. "Sikeresen banoltad #9BE48F" .. serial .. "#FFFFFF-t #9BE48F" .. table.concat({...}, " ") .. "#ffffff indokkal. (" .. time .. " óra)", sourcePlayer, 255, 255, 255, true)
			elseif tonumber(time) == 1 then
				addBan(nil, nil, serial, sourcePlayer, table.concat({...}, " "), 30*24*60*60)
				outputChatBox(successSyntax .. "Sikeresen banoltad #9BE48F" .. serial .. "#FFFFFF-t #9BE48F" .. table.concat({...}, " ") .. "#ffffff indokkal. (" .. time .. " hónap)", sourcePlayer, 255, 255, 255, true)
			elseif tonumber(time) == 0 then
				addBan(nil, nil, serial, sourcePlayer, table.concat({...}, " "), 365*24*60*60)
				outputChatBox(successSyntax .. "Sikeresen banoltad #9BE48F" .. serial .. "#FFFFFF-t #9BE48F" .. table.concat({...}, " ") .. "#ffffff indokkal. (Örökre)", sourcePlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Serial] [Idő] [Indok]", sourcePlayer, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Idő: Nagyobb mint 1 = [x] óra; 1 = 1 hónap; 0 = 1 év", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("offbanserial", offlineBanS)
addCommandHandler("offban", offlineBanS)

addAdminCommand("setvip", "VIP adása játékosnak.", 6)
function setElementVIP(sourcePlayer, commandName, targetElement, time)
	if getElementData(sourcePlayer, "adminLevel") >= 6 then
		if targetElement and time then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			if targetPlayer and time then
				local query = dbQuery(connection, "SELECT * FROM vips WHERE serial='" .. getPlayerSerial(targetPlayer) .. "'")
				local result, num = dbPoll(query, -1)
				if (num) > 0 then
					outputChatBox(errorSyntax .. "Ennek a játékosnak már van #C3BE66VIP #FFFFFFjogosultsága.", sourcePlayer, 255, 255, 255, true)
					return
				end

				local time = tonumber(time)
				if time > 1 then
					duration = time .. " óra"
					dbExec(connection,"UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 1)
					db = dbExec(connection,"INSERT INTO `vips` SET `accid` = ?, `date` =  NOW() + INTERVAL "..tonumber(time).." HOUR, `serial` = ?, `admin` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(sourcePlayer, "a.PlayerName"))
				elseif time == 0 then
					duration = "Örök"
					dbExec(connection,"UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 1)
					db = dbExec(connection,"INSERT INTO `vips` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 10 YEAR), `serial` = ?, `admin` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(sourcePlayer, "a.PlayerName"))
				end
				if (db) then
					setElementData(targetPlayer, "a.VIP", true)
					outputChatBox(infoSyntax .. "#C8C8C8" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFadott neked #C3BE66VIP #FFFFFFjogosultságot.", targetPlayer, 255, 255, 255, true) 
					outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFadott #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. "-nak/nek #C3BE66VIP #FFFFFFjogosultságot. #9BE48F(" .. duration .. ")")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Idő]", sourcePlayer, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Idő: #9BE48F0#FFFFFF - Örök; #9BE48Fnagyobb min 1#FFFFFF - [x] óra", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("setvip", setElementVIP)

addAdminCommand("delvip", "VIP elvétele játékostól.", 6)
function deleteVIP(sourcePlayer, commandName, targetElement)
	if getElementData(sourcePlayer, "adminLevel") >= 6 then
		if targetElement then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			if targetPlayer then
				local query = dbQuery(connection, "SELECT * FROM vips WHERE serial='" .. getPlayerSerial(targetPlayer) .. "'")
				local result, num = dbPoll(query, -1)
				if (num) == 0 then
					outputChatBox(errorSyntax .. "Ennek a játékosnak nincs még #C3BE66VIP #FFFFFFjogosultsága.", sourcePlayer, 255, 255, 255, true)
					return
				end
				dbExec(connection, "UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 0)
				db = dbExec(connection, "DELETE FROM vips WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
				if (db) then
					setElementData(targetPlayer, "a.VIP", false)
					outputChatBox(infoSyntax .. "#C8C8C8" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFelvette a #C3BE66VIP #FFFFFFjogosultságodat.", targetPlayer, 255, 255, 255, true)
					outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFelvette #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. "#ffffff #C3BE66VIP #FFFFFFjogosultságát.")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("delvip", deleteVIP)

addAdminCommand("getserial", "Játékos seriáljának lekérése.", 1)
addCommandHandler("getserial", 
	function(sourcePlayer, commandName, name)
		if getElementData(sourcePlayer, "adminLevel") >= 1 then
			if not name then
				outputChatBox(usageSyntax .. "/" .. commandName .." [Név]", sourcePlayer, 255, 255, 255, true)
			else
				dbQuery(
					function(qh, sourcePlayer)
						local result = dbPoll(qh, 0)[1]
						
						if not result then
							outputChatBox(errorSyntax .. "Nincs ilyen nevű játékos!", sourcePlayer, 255, 255, 255, true)
						else
							outputChatBox(successSyntax .."#5AB1D9"..name.."#ffffff serialja: #5AB1D9"..result.serial, sourcePlayer, 255, 255, 255, true)					
						end
					
					end, {sourcePlayer}, connection, "SELECT serial from accounts WHERE playerName = ?", name)
			end
		end
	end
)

addAdminCommand("a", "Adminchat", 1)
function adminChat(sourcePlayer, commandName, ...)
	if getElementData(sourcePlayer, "adminLevel") >= 1 then
		if (...) then
			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "loggedIn") then
					if getElementData(v, "adminLevel") >= 1 then
						local executerAdminName = getElementData(sourcePlayer, "a.PlayerName")
						local executerAdminLevel = getElementData(sourcePlayer, "adminLevel")
						if executerAdminLevel == 1 then
							syntax = "#62a7e1Admin 1"
						elseif executerAdminLevel == 2 then
							syntax = "#62a7e1Admin 2"
						elseif executerAdminLevel == 3 then
							syntax = "#62a7e1Admin 3"
						elseif executerAdminLevel == 4 then
							syntax = "#62a7e1Admin 4"
						elseif executerAdminLevel == 5 then
							syntax = "#62a7e1Admin 5"
						elseif executerAdminLevel == 6 then
							syntax = "#89DC3CFőAdmin"
						elseif executerAdminLevel == 7 then
							syntax = "#E03D42SzuperAdmin"
                        elseif executerAdminLevel == 8 then
                            syntax = "#dce188Menedzser"
                        else
							syntax = "#e18c88Tulajdonos"
						end
						outputChatBox("#E48F8F[adminchat]: " .. syntax .. " #C8C8C8" .. executerAdminName .. ": #FFFFFF" .. table.concat({...}, " "), v, 255, 255, 255, true)
					end
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [üzenet]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("a", adminChat, false, false)
addCommandHandler("adminChat", adminChat)

addAdminCommand("mutetime", "Maradék mute idő lekérése.", 0)
function outputMuteTime(sourcePlayer, commandName)
	if isElement(sourcePlayer) then
		local mutetime = getElementData(sourcePlayer, "a.Mutetime")
		if not mutetime or mutetime == 0 then
			outputChatBox("#E48F8F[mute]: #FFFFFFNem vagy lenémítva.", sourcePlayer, 255, 255, 255, true)
		else
			outputChatBox("#9BE48F[mute]: #FFFFFFMaradt még #E48F8F" .. mutetime .. " #FFFFFFperced.", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("mutetime", outputMuteTime)

addAdminCommand("mute", "Játékos némítása", 1)
function mutePlayer(sourcePlayer, commandName, targetElement, timeToMute, ...)
	if getElementData(sourcePlayer, "adminLevel") >= 1 then
		if tonumber(timeToMute) and (...) and (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			if (targetPlayer) then
				local targetPlayerName = getElementData(targetPlayer, "a.PlayerName")
				time = tonumber(timeToMute)
				reason = table.concat({...}, " ")

				db = dbExec(connection,"INSERT INTO `mutes` SET `accid` = ?, `date` =  NOW() + INTERVAL "..tonumber(time).." MINUTE, `reason` = ?, `admin` = ?", getElementData(targetPlayer, "a.accID"), tostring(reason), getElementData(sourcePlayer, "adminNick"))
				db2 = dbExec(connection, "UPDATE accounts SET muted = '1', mutetime = '" .. time .. "' WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")

				if (db) and (db2) then
					setElementData(targetPlayer, "a.Muted", true)
					setElementData(targetPlayer, "a.Mutetime", time)
					setElementData(targetPlayer, "a.Mutereason", reason)
					outputChatBox(infoSyntax .. " Le lettél némítva #8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #ffffff által #8FC3E4" .. time .. " #ffffffpercre. #E48F8F(" .. reason .. ")", targetPlayer, 255, 255, 255, true)
					outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #fffffflenémította #8FC3E4".. targetPlayerName .. "#ffffff-t #8FC3E4" .. time .. " #ffffffpercre. #E48F8F(" .. reason .. ")")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID] [Idő (perc)] [Indok]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("tempmute", mutePlayer)
addCommandHandler("mute", mutePlayer)

setTimer(function()
	for k, v in ipairs(getElementsByType("player")) do
		if getElementData(v, "loggedIn") then
			if getElementData(v, "a.Muted") == true then
				local timeRemaining = getElementData(v, "a.Mutetime")
				if not (timeRemaining) then
					return
				end
				if timeRemaining - 1 < 0 then
					setElementData(v, "a.Mutetime", 0)
				else
					setElementData(v, "a.Mutetime", timeRemaining - 1)
					dbExec(connection, "UPDATE accounts SET mutetime = ? WHERE serial = ?", getElementData(v, "a.Mutetime"), getPlayerSerial(v))
				end
				
				local timeRemaining = getElementData(v, "a.Mutetime")

				if timeRemaining == 0 then
					local db = dbExec(connection, "DELETE FROM mutes WHERE accid = '" .. getElementData(v, "a.accID") .. "'")
					local db2 = dbExec(connection, "UPDATE accounts SET muted = '0', mutetime = '0' WHERE serial = '" .. getPlayerSerial(v) .. "'")
					if (db) and (db2) then
						setElementData(v, "a.Muted", false)
						setElementData(v, "a.Mutetime", 0)
					end
				end
			end
		end
	end
end, 1000*60, 0)

addAdminCommand("unmute", "Mute levétele a játékosról.", 1)
function unMutePlayer(sourcePlayer, commandName, targetElement)
	if getElementData(sourcePlayer, "adminLevel") >= 1 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			if (targetPlayer) then
				local isMuted = getElementData(targetPlayer, "a.Muted")
				if (isMuted) then
					local db = dbExec(connection, "DELETE FROM mutes WHERE accid = '" .. getElementData(targetPlayer, "a.accID") .. "'")
					local db2 = dbExec(connection, "UPDATE accounts SET muted = '0', mutetime = '0' WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
					if (db) and (db2) then
						setElementData(targetPlayer, "a.Muted", false)
						setElementData(targetPlayer, "a.Mutereason", nil)
						setElementData(targetPlayer, "a.Mutetime", nil)
						outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFlevette rólad a némítást.", targetPlayer, 255, 255, 255, true)
						outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFlevette a némítást #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. "#FFFFFF-ról/ről.")
					end
				else
					outputChatBox(errorSyntax .. "#ffffffA játékos nincs még lenémítva.", sourcePlayer, 255, 255, 255, true)
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("unmute", unMutePlayer)

function spectatePlayer(sourcePlayer, commandName, targetElement)
	if getElementData(sourcePlayer, "adminLevel") >= 1 then
		if (targetElement) then
			if tostring(targetElement) == "off" then
				setCameraTarget(sourcePlayer, sourcePlayer)
				outputChatBox(infoSyntax .. "#FFFFFFSikeresen kikapcsoltad a megfigyelést.", sourcePlayer, 255, 255, 255, true)
				return
			end

			local targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetElement)
			if (targetPlayer) then
				if (targetPlayer == sourcePlayer) then
					outputChatBox(errorSyntax .. "#FFFFFFMagadat nem tudod megfigyelni.", sourcePlayer, 255, 255, 255, true)
					return
				end
				setCameraTarget(sourcePlayer, targetPlayer)
				outputChatBox(infoSyntax .. "#FFFFFFSikeresen elkezdted #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFmegfigyelését. Kikapcsoláshoz: #E48F8F/spec off", sourcePlayer, 255, 255, 255, true)
			else
				outputChatBox(errorSyntax .. "#FFFFFFNincs találat.", sourcePlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID / 'off']", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("spec", spectatePlayer)

-- ** Járművekkel kapcsolatos parancsok.

addAdminCommand("makeveh", "Egy ideiglenes jármű létrehozása", 6)
addCommandHandler("makeveh", 
    function(sourcePlayer, commandName, vehicleID)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (vehicleID) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Jármű ID]", sourcePlayer, 255, 255, 255, true)
            else
                local x, y, z = getElementPosition(sourcePlayer)
                local rx, ry, rz = getElementRotation(sourcePlayer)
                local dim, int = getElementDimension(sourcePlayer), getElementInterior(sourcePlayer)

                local vehicle = createVehicle(vehicleID, x, y, z, rx, ry, rz, getElementData(sourcePlayer, "a.PlayerName"))

                setElementDimension(vehicle, dim)
                setElementInterior(vehicle, int)

                warpPedIntoVehicle(sourcePlayer, vehicle)

                outputChatBox(successSyntax .. "Sikeresen létrehoztál egy ideiglenes járművet. ID: #8FC3E4" .. vehicleID .. "#FFFFFF.", sourcePlayer, 255, 255, 255, true)
                outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFlétrehozott egy ideiglenes járművet. Típus: #8FC3E4" .. vehicleID .. "#FFFFFF.")
            end
        end
    end
)

addAdminCommand("fixveh", "Egy játékos járművének megjavítása.", 1)
addCommandHandler("fixveh", 
    function(sourcePlayer, commandName, targetPlayer)
        if isPlayerHavePermission(sourcePlayer, commandName) then
            if not (targetPlayer) then
                outputChatBox(usageSyntax .. "/" .. commandName .. " [Név/ID]", sourcePlayer, 255, 255, 255, true)
            else
                targetPlayer = exports.a_core:findPlayer(sourcePlayer, targetPlayer)

                if targetPlayer then
                    if isPedInVehicle(targetPlayer) then
                        fixVehicle(getPedOccupiedVehicle(targetPlayer))

                        outputChatBox(successSyntax .. "Sikeresen megjavítottad #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjárművét.", sourcePlayer, 255, 255, 255, true)
                        outputChatBox(infoSyntax .. "#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegjavította járműved.", targetPlayer, 255, 255, 255, true)
                        outputAdminMessage("#8FC3E4" .. getElementData(sourcePlayer, "a.PlayerName") .. " #FFFFFFmegjavította #8FC3E4" .. getElementData(targetPlayer, "a.PlayerName") .. " #FFFFFFjárművét.")
                    else
                        outputChatBox(errorSyntax .. "A kiválasztott játékos nem ül járműben.", sourcePlayer, 255, 255, 255, true)
                    end
                end
            end
        end
    end
)

function sayToAll(sourcePlayer, commandName, ...)
	if getElementData(sourcePlayer, "adminLevel") >= 1 then
		if (...) then
			local text = table.concat({...}, " ")
			for k, v in ipairs(getElementsByType("player")) do
				local anick = getElementData(sourcePlayer, "a.PlayerName") or "-"
                local alevel = getElementData(sourcePlayer, "adminLevel")
                local adminlevel = exports.aAdmin:getAdminSyntax(alevel, true)
				outputChatBox(adminlevel .." " .. anick .. ": ".. text, v, 215, 89, 89, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Szöveg]", sourcePlayer, 255, 255, 255, true)
		end
	end
end
addCommandHandler("asay", sayToAll, false, false)

-- ** DEV FUNCTIONS

function getElementCurrentPosition(sourcePlayer, commandname)
	local x, y, z = getElementPosition(sourcePlayer)
	local rx, ry, rz = getElementRotation(sourcePlayer)
	local dim = getElementDimension(sourcePlayer)
	local int = getElementInterior(sourcePlayer)
	outputChatBox("#E4C78F[Position]: #FFFFFF" .. x .. ", " .. y .. ", " .. z, sourcePlayer, 255, 255, 255, true)
	outputChatBox("#E4C78F[Rotation]: #FFFFFF" .. rx .. ", " .. ry .. ", " .. math.floor(rz), sourcePlayer, 255, 255, 255, true)
	outputChatBox("#E4C78F[Other]: #FFFFFFInterior: " .. int .. ", Dimension: " .. dim, sourcePlayer, 255, 255, 255, true)
end
addCommandHandler("getpos", getElementCurrentPosition)