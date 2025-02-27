function farmSpawn (player)
	if ( player == "allSpawn" ) then
		for k,v in pairs(players) do
			setTimer ( setCameraTarget, 250, 1, v )
			setTimer ( fadeCamera, 1000, 1, v, true )			
			r = 10
			angle = math.random(0, 359.99) --random angle between 0 and 359.99
			centerX = 30
			centerY = -15
			spawnX = r*math.cos(angle) + centerX --circle trig math
			spawnY = r*math.sin(angle) + centerY --circle trig math
			spawnAngle = 360 - math.deg( math.atan2 ( (0 - spawnX), (0 - spawnY) ) ) --Look at 0,0 where transformers are
		end
	elseif ( player ~= "allSpawn" ) then
		setTimer ( setCameraTarget, 250, 1, player )
		setTimer ( fadeCamera, 1000, 1, player, true )
		r = 10
		angle = math.random(0, 359.99) --random angle between 0 and 359.99
		centerX = 30
		centerY = -15
		spawnX = r*math.cos(angle) + centerX --circle trig math
		spawnY = r*math.sin(angle) + centerY --circle trig math
		spawnAngle = 360 - math.deg( math.atan2 ( (0 - spawnX), (0 - spawnY) ) ) --Look at 0,0 where transformers are
	end
end

players = getElementsByType ( "player" )
farmSpawn ("allSpawn")

g_AutoBots = {}		-- { ped = {occupied = bool, model=model, color1=color1, color2=color2} }

function createAutoBot(model, x, y, z, angle, color1, color2, positions)
	local ped = createPed(167, x, y, z, angle)
	triggerClientEvent ( "client_collisionlessPed", ped )
	-- if not ped then
		-- return false
	-- end
	color1 = color1 or math.random(0, 126)
	color2 = color2 or color1
	g_AutoBots[ped] = { occupied = false, model = model, color1 = color1, color2 = color2 }
	clientCall(root, 'createAutoBot', ped, model, color1, color2, positions)
	return ped
end

function destroyAutoBot(parentPed)
	if not g_AutoBots[parentPed] then
		return false
	end
	clientCall(root, 'destroyAutoBot', parentPed)
	if not g_AutoBots[parentPed].occupied then
		destroyElement(parentPed)
	end
	g_AutoBots[parentPed] = nil
	return true
end

function warpPlayerIntoAutoBot(player, parentPed)
	local autobot = g_AutoBots[parentPed]
	if not autobot then
		return false
	end
	if autobot.occupied then
		parentPed = removePlayerFromAutoBot(parentPed)
	end
	clientCall(root, 'warpPlayerIntoAutoBot', player, parentPed)
	destroyElement(parentPed)
	g_AutoBots[parentPed] = nil
	g_AutoBots[player] = autobot
	autobot.occupied = true
	return true
end

function removePlayerFromAutoBot(player)
	local autobot = g_AutoBots[player]
	if not autobot then
		return false
	end
	local x, y, z = getElementPosition(player)
	local angle = getPedRotation(player)
	local parentPed = createPed(167, x, y, z)
	triggerClientEvent ( "client_collisionlessPed", parentPed )
	setPedRotation(parentPed, angle)
	clientCall(root, 'removePlayerFromAutoBot', player, parentPed)
	g_AutoBots[player] = nil
	g_AutoBots[parentPed] = autobot
	autobot.occupied = false
	return parentPed
end

addCommandHandler('blow',
	function(player)
		clientCall(root, 'blowAutoBot', next(g_AutoBots))
	end
)

addEventHandler('onResourceStart', getResourceRootElement(getThisResource()),
	function()
 --, 0, 126, false, { {1, 0, 3, 10}, {5, 3, 3, 82}, {-4, -3, 3, 35}, {10, 8, 3, 200}, {5, -6, 3, 352}, {-9, 2, 3, 184}, {18, -15, 3, 140}, {-20, -18, 3, 80}, {19, 8, 3, 10}, {-20, -25, 3, 250} })  
		players = getElementsByType ( "player" )
		local autoBotSpotting = -40
		local vehicleIDS = { 
		602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585, 405, 587,
		409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 488, 497, 447, 469, 487, 513, 472, 473, 493, 595, 430, 453, 452, 446, 454, 552, 431,
		438, 437, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 432, 528, 601, 407, 428, 544, 470, 598, 499, 588, 609, 403, 498, 514, 524, 423,
		532, 414, 578, 443, 486, 406, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 418, 582, 413, 440, 536, 575, 534, 567, 535, 576, 412,
		402, 542, 603, 475, 568, 557, 424, 504, 495, 539, 483, 508, 500, 444, 556, 429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 
		558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458, 584, 435, 450, 591 }

		for k=1,2 do
			if k <= 2 then --Spawn a max of 6 transformers. Increment as needed with playercount.
				createAutoBot(vehicleIDS[math.random(1,#vehicleIDS)], 5, autoBotSpotting, 3)
				autoBotSpotting = autoBotSpotting + 12	
			end
		end

		
		-- setTimer(clientCall, 5000, 1, root, 'assembleAutoBot', ped)
		-- setTimer(clientCall, 8000, 1, root, 'setPedAnimation', ped, 'dancing', 'dnce_m_a')
		-- setTimer(clientCall, 12000, 1, root, 'setPedAnimation', ped, 'dancing', 'DAN_Up_A')
		-- setTimer(clientCall, 14000, 1, root, 'setPedAnimation', ped, 'dancing', 'DAN_Right_A')
		-- setTimer(clientCall, 16000, 1, root, 'setPedAnimation', ped, 'dancing', 'DAN_Left_A')
		-- setTimer(clientCall, 18000, 1, root, 'blowAutoBot', ped)
		
		
		for i,player in ipairs(getElementsByType('player')) do
			joinHandler(player)
		end
	end
)

function joinHandler(player)
	bindKey(player, 'enter_exit', 'down', enterExitKey)
	if playerJoined then
		clientCall(player, 'setAutoBots', g_AutoBots)
	end
end
addEventHandler('onPlayerJoin', root, joinHandler)

function enterExitKey(player)
	if g_AutoBots[player] then
		-- player is in an autobot; make him get out
		removePlayerFromAutoBot(player)
	else
		-- not in an autobot. look for autobots in the vicinity
		local px, py, pz = getElementPosition(player)
		for ped,autobot in pairs(g_AutoBots) do
			if not autobot.occupied then
				if getDistanceBetweenPoints3D(px, py, pz, getElementPosition(ped)) < 10 then
					warpPlayerIntoAutoBot(player, ped)
					break
				end
			end
		end
	end
end

addEventHandler('onResourceStop', getResourceRootElement(getThisResource()),
	function()	
		setGravity ( 0.008 ) -- Normal gravity
		setGameSpeed ( 1 ) -- Normal speed
	end
)