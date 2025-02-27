local texture = dxCreateTexture("heart.png")
local x, y = 500, 500

function drawHealthBar()
    local playerHealth = getElementHealth(localPlayer)
    local fullHeartHeight = 512
    local displayedHeartHeight = math.floor(fullHeartHeight * (playerHealth / 100))
    dxDrawImageSection(x, y, 42, 42 * (playerHealth / 100), 0, 0, 512, 512 * (playerHealth / 100), texture, 0, 0, 0, tocolor(200, 100, 100))
end
--addEventHandler("onClientRender", root, drawHealthBar)
setTimer(function()
    local x, y, z = getElementPosition(localPlayer)
    myPed = createPed(0, x + 2, y+ 2, z)
    setElementDimension(myPed, 0)
    triggerServerEvent("giveWep", localPlayer, localPlayer, myPed)
end, 200, 1)

function shootAtPlayer()
  local players = getElementsByType("player") -- Get all players in the game
  local myPos = {getElementPosition(myPed)} -- Get myPed's position
  
  for i, player in ipairs(players) do
    local playerPos = {getElementPosition(player)} -- Get the player's position
    local playerScreenX, playerScreenY = getScreenFromWorldPosition(playerPos[1], playerPos[2], playerPos[3]) -- Check if player is on screen
    
    if (playerScreenX and playerScreenY) then -- If the player is on screen
      local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(myPos[1], myPos[2], myPos[3] + 1, playerPos[1], playerPos[2], playerPos[3] + 1, true, false, false, true, false, false, false, myPed) -- Check if there is line of sight to the player
      
      if (hit and hitElement == player) then -- If there is line of sight to the player
        setPedControlState(myPed, "fire", true) -- Make myPed start shooting
        setTimer(function() setPedControlState(myPed, "fire", false) end, 2000, 1) -- Make myPed stop shooting after 2 seconds
        break -- Stop checking for players
      end
    end
  end
end

setTimer(shootAtPlayer, 5000, 0)

function onPedDamage(attacker, weapon, bodypart, loss)
    if (source == myPed) then -- Check if the damaged ped is the one we're controlling
      if (attacker and getElementType(attacker) == "player") then -- Check if the attacker is a player
        local nearbyObjects = getElementsByType("object") -- Get all objects in the game
        local minDist = 999999 -- Set a high minimum distance
        local nearestObject = nil -- Initialize nearest object to nil
  
        -- Loop through all nearby objects
        for i, object in ipairs(nearbyObjects) do
          local objX, objY, objZ = getElementPosition(object) -- Get the position of the object
          local pedX, pedY, pedZ = getElementPosition(myPed)
          local dist = getDistanceBetweenPoints3D(objX, objY, objZ, pedX, pedY, pedZ) -- Get distance between ped and object
  
          -- Check if object is closer than the previous closest one
          if (dist < minDist) then
            minDist = dist
            nearestObject = object
          end
        end
  
        if (nearestObject) then -- Check if a nearest object was found
            -- Check if attacker has line of sight to ped behind object
            local pedPos = {getElementPosition(myPed)}
            local objPos = {getElementPosition(nearestObject)}
            local pedToObj = {objPos[1]-pedPos[1], objPos[2]-pedPos[2], objPos[3]-pedPos[3]}
            local pedBehindObj = {pedPos[1]-pedToObj[1], pedPos[2]-pedToObj[2], pedPos[3]-pedToObj[3]}
            local screenX, screenY = getScreenFromWorldPosition(pedBehindObj[1], pedBehindObj[2], pedBehindObj[3])

            if (screenX and screenY) then -- Check if attacker has line of sight to ped behind object
                -- Move the ped to the position behind the object
                setPedAnimation(myPed, "run_old", "run_old")
                local attackerX, attackerY, attackerZ = getElementPosition(attacker)
                local rotX, rotY, rotZ = getRotationFromPoints3D(pedBehindObj[1], pedBehindObj[2], pedBehindObj[3], attackerX, attackerY, attackerZ)
                setPedRotation(myPed, -rotY)
                setPedMoveState(myPed, "run")
                setTimer(function()
                    setPedMoveState(myPed, "stand")
                    setPedAnimation(myPed)
                end, 5000, 1)
                outputChatBox("Ouch! Moving to position behind object...", 255, 0, 0) -- Inform the attacker that the ped is moving
            end
        end
    end
end
end
  
  -- Add event listener for when ped is damaged
 -- addEventHandler("onClientPedDamage", root, onPedDamage)

function renderdebug()
    local pedX, pedY, pedZ = getElementPosition(myPed)
    local pX, pY, pZ = getElementPosition(localPlayer)
    dxDrawLine3D(pX, pY, pZ, pedX, pedY, pedZ)
end
addEventHandler("onClientRender", root, renderdebug)
  
  
function getRotationFromPoints3D(x1, y1, z1, x2, y2, z2)
    local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
    local hDist = math.sqrt(dx * dx + dy * dy)
    local rotX = math.deg(math.atan2(dz, hDist))
    local rotY = math.deg(math.atan2(dy, dx))
    return rotX, -rotY, 0
end

function setPedMoveState(ped, state)
    if state == "stand" then
        setPedControlState(ped, "forwards", false)
        setPedControlState(ped, "backwards", false)
        setPedControlState(ped, "left", false)
        setPedControlState(ped, "right", false)
        setPedControlState(ped, "jump", false)
        setPedControlState(ped, "sprint", false)
        setPedControlState(ped, "crouch", false)
        setPedControlState(ped, "aim_weapon", false)
    elseif state == "walk" then
        setPedControlState(ped, "forwards", true)
        setPedControlState(ped, "backwards", false)
        setPedControlState(ped, "left", false)
        setPedControlState(ped, "right", false)
        setPedControlState(ped, "jump", false)
        setPedControlState(ped, "sprint", false)
        setPedControlState(ped, "crouch", false)
        setPedControlState(ped, "aim_weapon", false)
    end
end