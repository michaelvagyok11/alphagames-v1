local databaseConnection = exports.a_mysql:getConnection()

--[[function createAdminLogToDatabase(executerElement, command, target, level)
	if executerElement and command then
		if not target then
			target = "Not definied"
		end

		if not level then
			level = "Not definied"
		end

		local time = getRealTime()
		local seconds = time.second
		local minutes = time.minute
		local hours = time.hour
		local days = time.monthday
		local month = time.month
		local date = "[" .. month .. ", " .. days .. "] - (" .. hours .. ":" .. minutes .. ":" .. seconds .. ")"
		local command = tostring(command)

		local name = getElementData(executerElement, "adminNick") or "Unknown"
		local target = getPlayerName(target)

		dbExec(databaseConnection, "INSERT INTO adminlogs SET name=?, command = ?, target = ?, level = ?, time = ?", name, command, target, level, date)
	end
end
]]--
function toggleFly(executerElement, commandName)
	if (getElementData(executerElement, "adminLevel")) >= 2 then 
		triggerClientEvent(executerElement, "onClientFlyToggle", executerElement)
	end
end
--addCommandHandler("fly", toggleFly, false, false)

function setPlayerAdministratorLevel(executerElement, commandName, targetElement, targetAdminLevel)
    if exports.a_core:isPlayerDeveloper(getPlayerSerial(executerElement)) or getElementData(executerElement, "adminLevel") >= 3 then
        if (targetAdminLevel) then
			if (targetElement) then
				local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
				local targetPlayerName = getPlayerName(targetPlayer)
				local executerPlayerName = getPlayerName(executerElement)
				local alevel = tonumber(targetAdminLevel)
				local anick = getElementData(executerElement, "adminNick") or "Unknown"


				setElementData(targetPlayer, "adminLevel", alevel)

				outputChatBox(successSyntax .. "Sikeresen megváltoztattad " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " adminszintjét. " .. info2HexColor .. "(" .. alevel .. ")", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. getAdminSyntax(tonumber(getElementData(executerElement, "adminLevel"))) .. info3HexColor .. "" .. executerPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " megváltoztatta az adminszintedet." .. info2HexColor .. " (" .. alevel .. ")", targetPlayer, 255, 255, 255, true)
				outputAdminMessage(getAdminSyntax(tonumber(getElementData(executerElement, "adminLevel"))) .. info3HexColor .. anick .. "" .. whiteHexColor .. " megváltoztatta " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " adminszintjét." .. info2HexColor .. " (" .. alevel .. ")")
				dbExec(databaseConnection, "UPDATE accounts SET alevel = '" .. alevel .. "' WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
			end
		else
            outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement] [targetAdminLevel]", executerElement, 255, 255, 255, true)
        end
    end
end
addCommandHandler("setalevel", setPlayerAdministratorLevel)

function setPlayerAdministratorName(executerElement, commandName, targetElement, targetAdminNick)
    if exports.a_core:isPlayerDeveloper(getPlayerSerial(executerElement)) or getElementData(executerElement, "adminLevel") >= 3 then
		local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
        if (targetAdminNick) then
			if (targetPlayer) then
				local targetPlayerName = getPlayerName(targetPlayer)
				local executerPlayerName = getPlayerName(executerElement)
				local anick = targetAdminNick or getElementData(executerPlayerName, "adminNick") or "Unknown"

				setElementData(targetPlayer, "adminNick", anick)
				outputChatBox(successSyntax .. "Successfully changed " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. "'s adminnick. " .. info2HexColor .. "(" .. anick .. ")", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. executerPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " changed your adminnick." .. info2HexColor .. " (" .. anick .. ")", targetPlayer, 255, 255, 255, true)
				outputAdminMessage(info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " changed " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. "'s adminnick." .. info2HexColor .. " (" .. anick .. ")")
				dbExec(databaseConnection, "UPDATE accounts SET anick = '" .. anick .. "' WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
			end
		else
            outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement] [targetAdminNick]", executerElement, 255, 255, 255, true)
        end
    end
end
addCommandHandler("setanick", setPlayerAdministratorName, false, false)

function toggleVanish(executerElement, commandName)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if getElementData(executerElement, "adminVanish") == true then
			setElementData(executerElement, "adminVanish", false)
			setElementAlpha(executerElement, 255)
			outputChatBox(infoSyntax .. "You are visible.", executerElement, 255, 255, 255, true)
		else
			setElementData(executerElement, "adminVanish", true)
			setElementAlpha(executerElement, 0)
			outputChatBox(infoSyntax .. "You are invisible.", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("vanish", toggleVanish, false, false)

function sayToAll(executerElement, commandName, ...)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (...) then
			local text = table.concat({...}, " ")
			for k, v in ipairs(getElementsByType("player")) do
				local anick = getElementData(executerElement, "adminNick") or "Unknown"
				outputChatBox(info2HexColor .. "[ASAY] " .. info3HexColor .. "" .. anick .. ": " .. whiteHexColor .. "" .. text, v, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [Text]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("asay", sayToAll, false, false)

function goToPlayer(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local targetPosX, targetPosY, targetPosZ = getElementPosition(targetPlayer)
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(executerElement, "adminNick") or "Unknown"

				if isPedInVehicle(executerElement) then
					local veh = getPedOccupiedVehicle(executerElement)
					setElementPosition(veh, targetPosX+2, targetPosY+2, targetPosZ)
					setElementDimension(veh, getElementDimension(targetPlayer))
				else
					setElementPosition(executerElement, targetPosX+2, targetPosY+2, targetPosZ)
					setElementDimension(executerElement, getElementDimension(targetPlayer))
				end
				outputChatBox(successSyntax .. "Successfully teleported to " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. ".", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " teleported to you.", targetPlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("goto", goToPlayer, false, false)

function getHerePlayer(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local adminPosX, adminPosY, adminPosZ = getElementPosition(executerElement)
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(executerElement, "adminNick") or "Unknown"

				if isPedInVehicle(targetPlayer) then
					local veh = getPedOccupiedVehicle(targetPlayer)
					setElementPosition(veh, adminPosX+2, adminPosY+2, adminPosZ)
					setElementDimension(veh, getElementDimension(executerElement))
				else
					setElementPosition(targetPlayer, adminPosX+2, adminPosY+2, adminPosZ)
					setElementDimension(targetPlayer, getElementDimension(executerElement))
				end
				outputChatBox(successSyntax .. "Successfully teleported " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " to yourself.", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " teleported to you.", targetPlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("gethere", getHerePlayer, false, false)

function privateMessageToPlayer(executerElement, commandName, targetElement, ...)
	if isElement(executerElement) then
		if (...) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local text = table.concat({...}, " ")
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"

				if string.find(text, "@everyone") then 
					outputChatBox("#E48F8F[Ban]: #9BE48F Rendszer#FFFFFF banned#9BE48F " .. getPlayerName(executerElement) .. " #FFFFFFfrom server. #8FC3E4(Reason: @everyone dc webhookon - permanent)", root, 255, 255, 255, true)
					return banPlayer(executerElement, true, true, true, "Console", "@everyone spam")
				end

				outputChatBox("#E9CB6F[PM-FROM]: #FFFFFF" .. getPlayerName(executerElement) .. " -> #C0C0C0" .. text, targetPlayer, 255, 255, 255, true)
				outputChatBox("#E9CB6F[PM-TO]: #FFFFFF" .. getPlayerName(targetPlayer) .. " -> #C0C0C0" .. text, executerElement, 255, 255, 255, true)
				exports.a_logs:createDCLog(getPlayerName(executerElement) .. " -> " .. targetPlayerName .. ": " .. text, 4)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id] [txt]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("pm", privateMessageToPlayer, false, false)

function replyToPlayer(executerElement, commandName, targetElement, ...)
	if isElement(executerElement) then
		if (...) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local text = table.concat({...}, " ")
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"

				outputChatBox("#E9CB6F[RE-FROM]: #FFFFFF" .. getPlayerName(executerElement) .. " -> #C0C0C0" .. text, targetPlayer, 255, 255, 255, true)
				outputChatBox("#E9CB6F[RE-TO]: #FFFFFF" .. getPlayerName(targetPlayer) .. " -> #C0C0C0" .. text, executerElement, 255, 255, 255, true)
				exports.a_logs:createDCLog(getPlayerName(executerElement) .. " -> " .. targetPlayerName .. ": " .. text .. " *(reply)*", 4)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id] [txt]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("re", replyToPlayer, false, false)

function freezePlayer(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"
					
				setElementFrozen(targetPlayer, true)
				outputChatBox(successSyntax .. "Successfully freezed " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. ".", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " freezed you.", targetPlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("freeze", freezePlayer, false, false)

function unFreezePlayer(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"
					
				setElementFrozen(targetPlayer, false)
				outputChatBox(successSyntax .. "Successfully melted " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. ".", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " melted you.", targetPlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("unfreeze", unFreezePlayer, false, false)

function setPlayerHealth(executerElement, commandName, targetElement, amount)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (amount) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"
				local lvl = tonumber(amount)
				if not lvl then return end	

				setElementHealth(targetPlayer, lvl)
				outputChatBox(successSyntax .. "Successfully changed " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. "'s HP. " .. info2HexColor .. "(" .. lvl .. ")", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " changed your HP. " .. info2HexColor .. "(" .. lvl .. ")", targetPlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id] [lvl]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("sethp", setPlayerHealth, false, false)

function setPlayerArmorFunc(executerElement, commandName, targetElement, amount)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (amount) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"
				local lvl = tonumber(amount)
				if not lvl then return end	

				setPedArmor(targetPlayer, lvl)
				outputChatBox(successSyntax .. "Successfully changed " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. "'s armor level. " .. info2HexColor .. "(" .. lvl .. ")", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " changed your armor level. " .. info2HexColor .. "(" .. lvl .. ")", targetPlayer, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id] [lvl]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("setarmor", setPlayerArmorFunc, false, false)


function setElementSkin(executerElement, commandName, targetElement, skin)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (skin) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local targetPlayerName = getPlayerName(targetPlayer)
				local anick = getElementData(targetPlayer, "adminNick") or "Unknown"
				local skinid = tonumber(skin)
				if not skinid then return end	

				setElementModel(targetPlayer, skinid)
				outputChatBox(successSyntax .. "Successfully changed " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. "'s skin. " .. info2HexColor .. "(" .. skinid .. ")", executerElement, 255, 255, 255, true)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " changed your skin. " .. info2HexColor .. "(" .. skinid .. ")", targetPlayer, 255, 255, 255, true)
				dbExec(databaseConnection, "UPDATE accounts SET skin = '" .. skinid .. "' WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetname/id] [lvl]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("setskin", setElementSkin, false, false)

--[[function gotopos(executerElement, commandname, x, y, z)
	setElementPosition(executerElement, x, y, z)
end
addCommandHandler("gotopos", gotopos)]]--


function getElementCurrentPosition(executerElement, commandname)
	local x, y, z = getElementPosition(executerElement)
	local rx, ry, rz = getElementRotation(executerElement)
	local dim = getElementDimension(executerElement)
	local int = getElementInterior(executerElement)
	outputChatBox("#E4C78F[Position]: #FFFFFF" .. x .. ", " .. y .. ", " .. z, executerElement, 255, 255, 255, true)
	outputChatBox("#E4C78F[Rotation]: #FFFFFF" .. rx .. ", " .. ry .. ", " .. math.floor(rz), executerElement, 255, 255, 255, true)
	outputChatBox("#E4C78F[Other]: #FFFFFFInterior: " .. int .. ", Dimension: " .. dim, executerElement, 255, 255, 255, true)
end
addCommandHandler("getpos", getElementCurrentPosition)

function setPlayerGroup(executerElement, commandName, targetElement, targetGroupNumber)
	if exports.a_core:isPlayerDeveloper(getPlayerSerial(executerElement)) or getElementData(executerElement, "adminLevel") >= 2 then
        if (targetGroupNumber) then
			if (targetElement) then
				if exports.a_dashboard:doesGroupExist(targetGroupNumber) and tonumber(targetGroupNumber) > 0 then
					local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
					local targetPlayerName = getPlayerName(targetPlayer)
					local executerPlayerName = getPlayerName(executerElement)
					local groupNumber = tonumber(targetGroupNumber)
					local anick = getElementData(executerElement, "adminNick") or "Unknown"


					setElementData(targetPlayer, "a.PlayerGroup", groupNumber)
					outputChatBox(successSyntax .. "Successfully changed " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. "'s group. " .. info2HexColor .. "(" .. groupNumber .. ")", executerElement, 255, 255, 255, true)
					outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. executerPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " changed your group." .. info2HexColor .. " (" .. groupNumber .. ")", targetPlayer, 255, 255, 255, true)
					outputAdminMessage(info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " changed " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. "'s group." .. info2HexColor .. " (" .. groupNumber .. ")")
					dbExec(databaseConnection, "UPDATE accounts SET playerGroup = '" .. groupNumber .. "' WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
				else
					outputChatBox(errorSyntax .. "This number of groups doesn't exist!", executerElement, 255, 255, 255, true)
				end
			end
		else
            outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement] [targetGroupNumber]", executerElement, 255, 255, 255, true)
        end
    end
end

addCommandHandler("setgroup", setPlayerGroup)

function createGroup(executerElement, commandName, targetGroupName)
	if exports.a_core:isPlayerDeveloper(getPlayerSerial(executerElement)) or getElementData(executerElement, "adminLevel") >= 3 then
        if (targetGroupName) then
			if exports.a_dashboard:checkForSameGroupName(targetGroupName) == false then
				local executerPlayerName = getPlayerName(executerElement)
				local anick = getElementData(executerElement, "adminNick") or "Unknown"

				dbExec(databaseConnection, "INSERT INTO groups SET groupName=?", targetGroupName)
				local lastGroupID= exports.a_dashboard:getLastGroupID()
				outputChatBox(successSyntax .. "Successfully created a new (" .. info3HexColor .. "" .. targetGroupName .. "" .. whiteHexColor .. ") group. ", executerElement, 255, 255, 255, true)
				outputAdminMessage(info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " created a new (" .. info3HexColor .. "" .. targetGroupName .. "" .. whiteHexColor .. ") group."  .. info2HexColor .. " (" .. lastGroupID .. ")")
			else
				outputChatBox(errorSyntax .. "A group with that name already exists!", executerElement, 255, 255, 255, true)
			end
		else
            outputChatBox(usageSyntax .. "/" .. commandName .. " [groupName]", executerElement, 255, 255, 255, true)
        end
	end
end

addCommandHandler("creategroup", createGroup)

function setPlayerGroupLeader(executerElement, commandName, targetElement, targetGroupNumber)
	if exports.a_core:isPlayerDeveloper(getPlayerSerial(executerElement)) or getElementData(executerElement, "adminLevel") >= 2 then
        if (targetGroupNumber) then
			if (targetElement) then
				if exports.a_dashboard:doesGroupExist(targetGroupNumber) and tonumber(targetGroupNumber) > 0 then
					local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
					local targetPlayerName = getPlayerName(targetPlayer)
					local executerPlayerName = getPlayerName(executerElement)
					local groupNumber = tonumber(targetGroupNumber)
					local anick = getElementData(executerElement, "adminNick") or "Unknown"
					local accID = getElementData(targetPlayer, "a.accID")
					if exports.a_dashboard:isPlayerInGroup(targetPlayer, targetGroupNumber) then

						outputChatBox(successSyntax .. "Successfully set " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " as group leader. " .. info2HexColor .. "(" .. groupNumber .. ")", executerElement, 255, 255, 255, true)
						outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. executerPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " set you as group leader." .. info2HexColor .. " (" .. groupNumber .. ")", targetPlayer, 255, 255, 255, true)
						outputAdminMessage(info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " set " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " as group leader." .. info2HexColor .. " (" .. groupNumber .. ")")
						dbExec(databaseConnection, "UPDATE groups SET groupMainLeader=? WHERE id= '" .. targetGroupNumber .. "'" , accID)
						dbExec(databaseConnection, "UPDATE accounts SET playerLeaderInGroup=? WHERE id= '" .. accID .. "'", 1)
					else
						outputChatBox(errorSyntax .. "The selected player is not in the group!", executerElement, 255, 255, 255, true)
					end
				else
					outputChatBox(errorSyntax .. "This number of groups doesn't exist!", executerElement, 255, 255, 255, true)
				end
			end
		else
            outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement] [targetGroupNumber]", executerElement, 255, 255, 255, true)
        end
    end
end

addCommandHandler("setgroupleader", setPlayerGroupLeader)

function removePlayerFromGroup(executerElement, commandName, targetElement)
	if exports.a_core:isPlayerDeveloper(getPlayerSerial(executerElement)) or getElementData(executerElement, "adminLevel") >= 2 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			local targetPlayerName = getPlayerName(targetPlayer)
			local executerPlayerName = getPlayerName(executerElement)
			local groupNumber = tonumber(targetGroupNumber)
			local anick = getElementData(executerElement, "adminNick") or "Unknown"
			local oldPlayerGroup = getElementData(targetPlayer, "a.PlayerGroup")

			if tonumber(getElementData(targetPlayer, "a.PlayerGroup")) > 0 then
				outputChatBox(successSyntax .. "Successfully kicked " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " from group. ", executerElement, 255, 255, 255, true)
				setElementData(targetPlayer, "a.PlayerGroup", 0)
				outputChatBox(infoSyntax .. "" .. info3HexColor .. "" .. executerPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. " kicked you from group.", targetPlayer, 255, 255, 255, true)
				outputAdminMessage(info3HexColor .. "" .. anick .. "" .. whiteHexColor .. " kicked " .. info3HexColor .. "" .. targetPlayerName:gsub("_", " ") .. "" .. whiteHexColor .. "  from group." .. info2HexColor .. " (" .. oldPlayerGroup .. ")")
				dbExec(databaseConnection, "UPDATE accounts SET playerGroup = ? WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'", 0)
			else
				outputChatBox(errorSyntax .. "The player is not in any group!", executerElement, 255, 255, 255, true)
			end
		else
            outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement]", executerElement, 255, 255, 255, true)
        end
	end
end

addCommandHandler("removegroup", removePlayerFromGroup)

function adminChat(executerElement, commandName, ...)
	if getElementData(executerElement, "adminLevel") >= 1 then
		if (...) then
			for k, v in ipairs(getElementsByType("player")) do
				if getElementData(v, "loggedIn") then
					if getElementData(v, "adminLevel") >= 1 then
						local executerAdminName = getPlayerName(executerElement)
						local executerAdminLevel = getElementData(executerElement, "adminLevel")
						if executerAdminLevel == 1 then
							syntax = "#dfacdeP. Moderátor"
						elseif executerAdminLevel == 2 then
							syntax = "#62a7e1Adminisztrátor"
						elseif executerAdminLevel == 3 then
							syntax = "#89DC3CFőAdmin"
						elseif executerAdminLevel == 4 then
							syntax = "#00aeefFejlesztő"
						else
							syntax = "#e18c88Tulajdonos"
						end
						outputChatBox("#E48F8F[achat]: " .. syntax .. " #C8C8C8" .. executerAdminName .. ": #FFFFFF" .. table.concat({...}, " "), v, 255, 255, 255, true)
					end
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [message]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("a", adminChat, false, false)
addCommandHandler("adminChat", adminChat)

function kickElement(executerElement, commandName, targetElement, ...)
	if getElementData(executerElement, "adminLevel") >= 1 then
		if targetElement and (...) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			local reason = table.concat({...}, " ")
			if targetPlayer and reason then
				
				local targetSerial = getPlayerSerial(targetPlayer);
				if devSerials[targetSerial] then
					return
				end

				local targetAdminLevel = getElementData(targetPlayer, "adminLevel")
				local playerAdminLevel = getElementData(executerElement, "adminLevel")
				if targetAdminLevel > playerAdminLevel and playerAdminLevel < 3 then
					outputChatBox("#E48F8F[error]: #FFFFFFA kickelni kívánt játékosnak nagyobb az adminszintje mint a tiéd, így nem tudod kickelni.", executerElement, 255, 255, 255, true)
					return
				end
				outputChatBox("#E48F8F[Kick]: #9BE48F" .. getPlayerName(executerElement) .. "#FFFFFF kicked #9BE48F" .. getPlayerName(targetPlayer) .. " #FFFFFFfrom server. #8FC3E4(Reason: " .. table.concat({...}, " ") .. ")", root, 255, 255, 255, true)
				kickPlayer(targetPlayer, executerElement, table.concat({...}, " "))
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement] [reason]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("kick", kickElement)

addCommandHandler("getserial",
	function ()

	end
)

function banElement(executerElement, commandName, targetElement, time, ...)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if targetElement and ... and time then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			local reason = table.concat({...}, " ")
			if targetPlayer and reason and time then
				
				local targetSerial = getPlayerSerial(targetPlayer);
				if devSerials[targetSerial] then
					return
				end

				local time = tonumber(time)
				if time > 2 then
					duration = time .. " óra"
					seconds = time*60*60
					db = dbExec(databaseConnection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL "..tonumber(time).." HOUR), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"),reason)
				elseif time == 1 then
					duration = "1 month"
					seconds = 30*24*60*60
					db = dbExec(databaseConnection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 1 MONTH), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"),reason)
				elseif time == 2 then
					duration = "1 year"
					seconds = 365*24*60*60
					db = dbExec(databaseConnection,"INSERT INTO `bans` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 1 YEAR), `serial` = ?, `admin` = ?, `reason` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"),reason)
				end
				outputChatBox("#E48F8F[Ban]: #9BE48F" .. getPlayerName(executerElement) .. "#FFFFFF banned#9BE48F " .. getPlayerName(targetPlayer) .. " #FFFFFFfrom server. #8FC3E4(Reason: " .. reason .. " - " .. duration .. ")", root, 255, 255, 255, true)
				if (db) then
					banPlayer(targetPlayer, true, true, true, executerElement, reason, seconds)
					--print("siker")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement] [time] [reason]", executerElement, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Time: #9BE48FBigger then 1#FFFFFF - [time] hours; #9BE48F1#FFFFFF - 1 month; #9BE48F2#FFFFFF - 1 year", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("ban", banElement)

function setElementVIP(executerElement, commandName, targetElement, time)
	if getElementData(executerElement, "adminLevel") >= 5 then
		if targetElement and time then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if targetPlayer and time then
				local query = dbQuery(databaseConnection, "SELECT * FROM vips WHERE serial='" .. getPlayerSerial(targetPlayer) .. "'")
				local result, num = dbPoll(query, -1)
				if (num) > 0 then
					outputChatBox(errorSyntax .. "This player already has #C3BE66VIP #FFFFFFpermission.", executerElement, 255, 255, 255, true)
					return
				end

				local time = tonumber(time)
				if time > 1 then
					duration = time .. " hour"
					dbExec(databaseConnection,"UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 1)
					db = dbExec(databaseConnection,"INSERT INTO `vips` SET `accid` = ?, `date` =  NOW() + INTERVAL "..tonumber(time).." HOUR, `serial` = ?, `admin` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"))
				elseif time == 0 then
					duration = "Permament"
					dbExec(databaseConnection,"UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 1)
					db = dbExec(databaseConnection,"INSERT INTO `vips` SET `accid` = ?, `date` = DATE_ADD(CURRENT_TIMESTAMP() , INTERVAL 10 YEAR), `serial` = ?, `admin` = ?",getElementData(targetPlayer, "a.accID"),getPlayerSerial(targetPlayer),getElementData(executerElement, "adminNick"))
				end
				--outputChatBox("#E48F8F[Ban]: #9BE48F" .. getPlayerName(executerElement) .. "#FFFFFF kitiltotta a szerverről#9BE48F " .. getPlayerName(targetPlayer) .. " #FFFFFFjátékost. #8FC3E4(Indok: " .. reason .. " - " .. duration .. ")", root, 255, 255, 255, true)
				if (db) then
					setElementData(targetPlayer, "a.VIP", true)
					outputChatBox(infoSyntax .. "#C8C8C8" .. getPlayerName(executerElement) .. " #FFFFFFgave #C3BE66VIP #FFFFFFpermissions to you.", targetPlayer, 255, 255, 255, true) 
					outputAdminMessage(info3HexColor .. "#8FC3E4" .. getPlayerName(executerElement) .. " #FFFFFFgave for #8FC3E4" .. getPlayerName(targetPlayer) .. " #C3BE66VIP #FFFFFFpermissions. #9BE48F(" .. duration .. ")")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement] [time]", executerElement, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Time: #9BE48F0#FFFFFF - Permament; #9BE48Fbigger then 1#FFFFFF - x hours", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("setvip", setElementVIP)

function deleteVIP(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 5 then
		if targetElement then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if targetPlayer then
				local query = dbQuery(databaseConnection, "SELECT * FROM vips WHERE serial='" .. getPlayerSerial(targetPlayer) .. "'")
				local result, num = dbPoll(query, -1)
				if (num) == 0 then
					outputChatBox(errorSyntax .. "This player doesn't have #C3BE66VIP #FFFFFFpermission.", executerElement, 255, 255, 255, true)
					return
				end
				dbExec(databaseConnection, "UPDATE accounts SET vip = ? WHERE id = " .. getElementData(targetPlayer, "a.accID") .. "", 0)
				db = dbExec(databaseConnection, "DELETE FROM vips WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
				if (db) then
					setElementData(targetPlayer, "a.VIP", false)
					outputChatBox(infoSyntax .. "#C8C8C8" .. getPlayerName(executerElement) .. " #FFFFFFtook your #C3BE66VIP #FFFFFFpermissions.", targetPlayer, 255, 255, 255, true)
					outputAdminMessage(info3HexColor .. "#8FC3E4" .. getPlayerName(executerElement) .. " #FFFFFFtook #8FC3E4" .. getPlayerName(targetPlayer) .. "#ffffff's #C3BE66VIP #FFFFFFpermissions.")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [targetElement]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("delvip", deleteVIP)

function createIdgVehicle(executerElement, commandName, modelID)
	if getElementData(executerElement, "adminLevel") >= 3 then
		if tonumber(modelID) then
			local x, y, z = getElementPosition(executerElement)
			local dim = getElementDimension(executerElement)
			local int = getElementInterior(executerElement)

			local veh = createVehicle(tonumber(modelID), x + 3, y + 3, z + 2)
			warpPedIntoVehicle(executerElement, veh)
			setElementDimension(veh, dim)
			setElementInterior(veh, int)
			outputChatBox("created vehicle. modelid: " .. tonumber(modelID), executerElement, 255, 255, 255, true)
		else
			outputChatBox("[use]: /" .. commandName .. " [modelid]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("veh", createIdgVehicle)

function changePlayerMoney(executerElement, commandName, target, arg, amount)
	if getElementData(executerElement, "adminLevel") >= 3 then
		if tonumber(amount) and (target) and tonumber(arg) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, target)
			if (targetPlayer) then
				if  tonumber(arg) == 1 then
					setElementData(targetPlayer, "a.Money",tonumber(amount))
					outputAdminMessage(getPlayerName(executerElement) .. " set " .. getPlayerName(targetPlayer) .. "'s money to " .. tonumber(amount) .. "$.")
				elseif  tonumber(arg) == 2 then
					setElementData(targetPlayer, "a.Money", getElementData(targetPlayer, "a.Money") + tonumber(amount))
					outputAdminMessage(getPlayerName(executerElement) .. " gave " .. getPlayerName(targetPlayer) .. " " .. tonumber(amount) .. "$.")
				elseif  tonumber(arg) == 3 then
					setElementData(targetPlayer, "a.Money", getElementData(targetPlayer, "a.Money") - tonumber(amount))
					outputAdminMessage(getPlayerName(executerElement) .. " took " .. tonumber(amount) .. "$ from " .. getPlayerName(targetPlayer) .. ".")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [target] [type: 1-set, 2-give, 3-take] [amount]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("setmoney", changePlayerMoney)

function changePlayerPP(executerElement, commandName, target, arg, amount)
	if getElementData(executerElement, "adminLevel") >= 3 then
		if tonumber(amount) and (target) and tonumber(arg) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, target)
			if (targetPlayer) then
				if  tonumber(arg) == 1 then
					setElementData(targetPlayer, "a.Premiumpont",tonumber(amount))
					outputAdminMessage(getPlayerName(executerElement) .. " set " .. getPlayerName(targetPlayer) .. "'s pp to " .. tonumber(amount) .. "PP.")
				elseif  tonumber(arg) == 2 then
					setElementData(targetPlayer, "a.Premiumpont", getElementData(targetPlayer, "a.Premiumpont") + tonumber(amount))
					outputAdminMessage(getPlayerName(executerElement) .. " gave " .. getPlayerName(targetPlayer) .. " " .. tonumber(amount) .. "PP.")
				elseif  tonumber(arg) == 3 then
					setElementData(targetPlayer, "a.Premiumpont", getElementData(targetPlayer, "a.Premiumpont") - tonumber(amount))
					outputAdminMessage(getPlayerName(executerElement) .. " took " .. tonumber(amount) .. "PP from " .. getPlayerName(targetPlayer) .. ".")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [target] [type: 1-set, 2-give, 3-take] [amount]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("setpp", changePlayerPP)

function getNearbyVehicles(executerElement, commandName)
	if getElementData(executerElement, "adminLevel") >= 2 then
		local pX, pY, pZ = getElementPosition(executerElement)
		for k, v in ipairs(getElementsByType("vehicle")) do
			local vX, vY, vZ = getElementPosition(v);
			if getDistanceBetweenPoints3D(vX, vY, vZ, pX, pY, pZ) < 5 then
				local vehModelID = getElementModel(v);
				local vehModelName = getVehicleNameFromModel(vehModelID);
				local distance = getDistanceBetweenPoints3D(vX, vY, vZ, pX, pY, pZ);
				local vehicleID = getElementData(v, "a.VehID");
				local owner = getElementData(v, "a.Owner");
				local ownerName = getPlayerName(owner);

				outputChatBox("#9BE48F[nearbyvehs]: #E48F8F" .. vehModelName .. " #c8c8c8(" .. vehModelID .. ") #c8c8c8- id: #E48F8F" .. vehicleID .. " #c8c8c8- owner: #E48F8F" .. ownerName, executerElement, 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("nearbyvehicles", getNearbyVehicles)

function mutePlayer(executerElement, commandName, targetElement, timeToMute, ...)
	if getElementData(executerElement, "adminLevel") >= 1 then
		if tonumber(timeToMute) and (...) and (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local targetPlayerName = getPlayerName(targetPlayer)
				time = tonumber(timeToMute)
				reason = table.concat({...}, " ")

				db = dbExec(databaseConnection,"INSERT INTO `mutes` SET `accid` = ?, `date` =  NOW() + INTERVAL "..tonumber(time).." MINUTE, `reason` = ?, `admin` = ?", getElementData(targetPlayer, "a.accID"), tostring(reason), getElementData(executerElement, "adminNick"))
				db2 = dbExec(databaseConnection, "UPDATE accounts SET muted = '1', mutetime = '" .. time .. "' WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")

				if (db) and (db2) then
					setElementData(targetPlayer, "a.Muted", true)
					setElementData(targetPlayer, "a.Mutetime", time)
					setElementData(targetPlayer, "a.Mutereason", reason)
					outputChatBox("#E48F8F[MUTE]:#ffffff You have been muted by #8FC3E4" .. getPlayerName(executerElement) .. " #fffffffor #8FC3E4" .. time .. " #ffffffminutes. #E48F8F(" .. reason .. ")", targetPlayer, 255, 255, 255, true)
					outputAdminMessage("#8FC3E4" .. getPlayerName(executerElement) .. " #ffffffmuted #8FC3E4".. targetPlayerName .. " #fffffffor #8FC3E4" .. time .. " #ffffffminutes. #E48F8F(" .. reason .. ")")
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [target] [time (minutes)] [reason]", executerElement, 255, 255, 255, true)
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
					dbExec(databaseConnection, "UPDATE accounts SET mutetime = ? WHERE serial = ?", getElementData(v, "a.Mutetime"), getPlayerSerial(v))
				end
				
				local timeRemaining = getElementData(v, "a.Mutetime")

				if timeRemaining == 0 then
					local db = dbExec(databaseConnection, "DELETE FROM mutes WHERE accid = '" .. getElementData(v, "a.accID") .. "'")
					local db2 = dbExec(databaseConnection, "UPDATE accounts SET muted = '0', mutetime = '0' WHERE serial = '" .. getPlayerSerial(v) .. "'")
					if (db) and (db2) then
						setElementData(v, "a.Muted", false)
						setElementData(v, "a.Mutetime", 0)
					end
				end
			end
		end
	end
end, 1000*60, 0)


function unMutePlayer(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 1 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local isMuted = getElementData(targetPlayer, "a.Muted")
				if (isMuted) then
					local db = dbExec(databaseConnection, "DELETE FROM mutes WHERE accid = '" .. getElementData(targetPlayer, "a.accID") .. "'")
					local db2 = dbExec(databaseConnection, "UPDATE accounts SET muted = '0', mutetime = '0' WHERE serial = '" .. getPlayerSerial(targetPlayer) .. "'")
					if (db) and (db2) then
						setElementData(targetPlayer, "a.Muted", false)
						outputChatBox("#9BE48F[MUTE]: #8FC3E4" .. getPlayerName(executerElement) .. " #FFFFFFunmuted you.", targetPlayer, 255, 255, 255, true)
						outputAdminMessage("#8FC3E4" .. getPlayerName(executerElement) .. " #FFFFFFunmuted #8FC3E4" .. getPlayerName(targetPlayer) .. "#FFFFFF.")
					end
				else
					outputChatBox("#E48F8F[error]: #ffffffThe target isn't muted.", executerElement, 255, 255, 255, true)
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [target]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("unmute", unMutePlayer)

--**VEHICLE EXPLODING

function onExplode()
	veh = source
	if isElement(veh) then
		setTimer(function()
			destroyElement(veh)
		end, 5000, 1)
	end
end
addEventHandler("onVehicleExplode", root, onExplode)

function statPlayer(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				local accountID = getElementData(targetPlayer, "a.accID")
				local name = getPlayerName(targetPlayer)
				local money = getElementData(targetPlayer, "a.Money")
				local pp = getElementData(targetPlayer, "a.Premiumpont")
				local experience = getElementData(targetPlayer, "a.Experience")
				local mutetime = getElementData(targetPlayer, "a.Mutetime")
				if not mutetime then
					mutetime = 0
				end

				outputChatBox("#9BE48F[STAT]: #FFFFFF" .. name .. " #8FC3E4(id: " .. getElementData(targetPlayer, "playerid") .. ")", executerElement, 255, 255, 255, true)
				outputChatBox("AccountID: #8FC3E4" .. accountID .. " #FFFFFF// Money: #8FC3E4" .. money .. "$#FFFFFF // Premiumpont: #8FC3E4" .. pp .. "pp #FFFFFF// Experience: #8FC3E4" .. experience .. "#FFFFFFxp // Mutetime: #8FC3E4" .. mutetime, executerElement, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [target]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("stats", statPlayer)

function onChange(key, oVal, nVal)
	if key == "a.Premiumpont" then
		dbExec(databaseConnection, "UPDATE accounts SET pp = '" .. tonumber(nVal) .. "' WHERE serial = '" .. getPlayerSerial(source) .. "'")
	end
end
addEventHandler("onElementDataChange", root, onChange)

function fixVeh(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 3 then
		if (targetElement) then
			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				if isPedInVehicle(targetPlayer) then
					fixVehicle(getPedOccupiedVehicle(targetPlayer))
					outputChatBox(successSyntax .. " You have successfully fixed #9BE48F" .. getPlayerName(targetPlayer) .. "#FFFFFF's vehicle.", executerElement, 255, 255, 255, true)
					outputChatBox(successSyntax .. "#9BE48F" .. getPlayerName(executerElement) .. " #FFFFFFfixed your vehicle.", targetPlayer, 255, 255, 255, true)
				else
					outputChatBox(errorSyntax .. "The player is not in a vehicle.", executerElement, 255, 255, 255, true)
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [target]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("fixveh", fixVeh)

function unBanPlayer(executerElement, commandName, serial)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (serial) then
			reloadBans()
			local banList = getBans()
			for k, v in ipairs(banList) do
				local banSerial2 = getBanSerial(v)
				if banSerial2 == serial then
					outputChatBox(successSyntax .. "You have successfully removed #9BE48F" .. getBanNick(v) .. "#FFFFFF's ban.", executerElement, 255, 255, 255, true)
					removeBan(v, executerElement)
				end
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [serial]", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("unban", unBanPlayer)

function offlineBanS(executerElement, commandName, serial, time, ...)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (serial) and (...) and (time) then
			reloadBans()
			if tonumber(time) > 1 then
				addBan(nil, nil, serial, executerElement, table.concat({...}, " "), time*60*60)
				outputChatBox(successSyntax .. "You have successfully banned #9BE48F" .. serial .. "#FFFFFF for " .. table.concat({...}, " ") .. ". (" .. time .. " hours)", executerElement, 255, 255, 255, true)
			elseif tonumber(time) == 1 then
				addBan(nil, nil, serial, executerElement, table.concat({...}, " "), 30*24*60*60)
				outputChatBox(successSyntax .. "You have successfully banned #9BE48F" .. serial .. "#FFFFFF for " .. table.concat({...}, " ") .. ". (" .. time .. " month)", executerElement, 255, 255, 255, true)
			elseif tonumber(time) == 0 then
				addBan(nil, nil, serial, executerElement, table.concat({...}, " "), 365*24*60*60)
				outputChatBox(successSyntax .. "You have successfully banned #9BE48F" .. serial .. "#FFFFFF for " .. table.concat({...}, " ") .. ". (Forever)", executerElement, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [serial] [time] [reason]", executerElement, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Time: 1 < hours; 1 = 1month; 0 = 1 year", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("offbanserial", offlineBanS)
addCommandHandler("offban", offlineBanS)

--[[function offlineBanN(executerElement, commandName, nick, time, ...)
	if getElementData(executerElement, "adminLevel") >= 2 then
		if (nick) and (...) and (time) then
			reloadBans()
			if tonumber(time) > 1 then
				addBan(nil, nick, nil, executerElement, table.concat({...}, " "), time*60*60)
				outputChatBox(successSyntax .. "You have successfully banned #9BE48F" .. nick .. "#FFFFFF for " .. table.concat({...}, " ") .. ". (" .. time .. " hours)", executerElement, 255, 255, 255, true)
			elseif tonumber(time) == 1 then
				addBan(nil, nick, nil, executerElement, table.concat({...}, " "), 30*24*60*60)
				outputChatBox(successSyntax .. "You have successfully banned #9BE48F" .. nick .. "#FFFFFF for " .. table.concat({...}, " ") .. ". (" .. time .. " month)", executerElement, 255, 255, 255, true)
			elseif tonumber(time) == nil then
				addBan(nil, nick, serial, executerElement, table.concat({...}, " "), 365*24*60*60)
				outputChatBox(successSyntax .. "You have successfully banned #9BE48F" .. nick .. "#FFFFFF for " .. table.concat({...}, " ") .. ". (Forever)", executerElement, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [nick] [time] [reason]", executerElement, 255, 255, 255, true)
			outputChatBox(usageSyntax .. "Time: 1 < hours; 1 = 1month; 0 = 1 year", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("offban", offlineBanN)]]--

function outputMuteTime(executerElement, commandName)
	if isElement(executerElement) then
		local mutetime = getElementData(executerElement, "a.Mutetime")
		if not mutetime or mutetime == 0 then
			outputChatBox("#E48F8F[mute]: #FFFFFFYou aren't muted.", executerElement, 255, 255, 255, true)
		else
			outputChatBox("#9BE48F[mute]: #FFFFFFYou have #E48F8F" .. mutetime .. " #FFFFFFminutes left.", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("mutetime", outputMuteTime)

function spectatePlayer(executerElement, commandName, targetElement)
	if getElementData(executerElement, "adminLevel") >= 1 then
		if (targetElement) then
			if tostring(targetElement) == "off" then
				setCameraTarget(executerElement, executerElement)
				outputChatBox("#9BE48F[SPEC]: #FFFFFFSikeresen kikapcsoltad a megfigyelést.", executerElement, 255, 255, 255, true)
				return
			end

			local targetPlayer = exports.a_core:findPlayer(executerElement, targetElement)
			if (targetPlayer) then
				if (targetPlayer == executerElement) then
					outputChatBox("#E48F8F[Hiba]: #FFFFFFMagadat nem tudod megfigyelni.", executerElement, 255, 255, 255, true)
					return
				end
				setCameraTarget(executerElement, targetPlayer)
				outputChatBox("#9BE48F[SPEC]: #FFFFFFSikeresen elkezdted #8FC3E4" .. getPlayerName(targetPlayer) .. " #FFFFFFmegfigyelését. Kikapcsoláshoz: #E48F8F/spec off", executerElement, 255, 255, 255, true)
			else
				outputChatBox("#E48F8F[Hiba]: #FFFFFFNincs találat.", executerElement, 255, 255, 255, true)
			end
		else
			outputChatBox(usageSyntax .. "/" .. commandName .. " [target / 'off']", executerElement, 255, 255, 255, true)
		end
	end
end
addCommandHandler("spec", spectatePlayer)