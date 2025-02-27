local sX, sY = guiGetScreenSize()

function reMap(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(sX, 720, 1920, 0.75, 1)

function resp(num)
    return num * responsiveMultipler
end

function respc(num)
    return math.ceil(num * responsiveMultipler)
end

--
-- Meghatározzuk a komponensek alap pozícióját, eltároljuk egy táblában, amit az indexek alapján tudjuk majd bejárni.
-- Ez esetben az főindexek a "hpBar", "armorBar", ... - az alindexek pedig a "startX", "startY", ...
--

local defaultHudPositions = {
	["hpBar"] = {
		["startX"] = sX - respc(350) - respc(7.5),
		["startY"] = respc(5),
		["sizeX"] = respc(350),
		["sizeY"] = respc(30),
	},
	["armorBar"] = {
		["startX"] = sX - respc(350) - respc(7.5),
		["startY"] = respc(15) + respc(30),
		["sizeX"] = respc(350),
		["sizeY"] = respc(30),
	},
	["money"] = {
		["startX"] = sX - respc(350) - respc(7.5) + respc(10),
		["startY"] = respc(20) + respc(65),
		["sizeX"] = respc(150),
		["sizeY"] = respc(30),
	},
	["clock"] = {
		["startX"] = sX - respc(350)/2 - respc(7.5) + respc(60),
		["startY"] = respc(20) + respc(65),
		["sizeX"] = respc(150),
		["sizeY"] = respc(30),
	},
}

function resetHUD()
	defaultHudPositions = {
		["hpBar"] = {
			["startX"] = sX - respc(350) - respc(7.5),
			["startY"] = respc(5),
			["sizeX"] = respc(350),
			["sizeY"] = respc(30),
		},
		["armorBar"] = {
			["startX"] = sX - respc(350) - respc(7.5),
			["startY"] = respc(15) + respc(30),
			["sizeX"] = respc(350),
			["sizeY"] = respc(30),
		},
		["money"] = {
			["startX"] = sX - respc(350) - respc(7.5) + respc(10),
			["startY"] = respc(20) + respc(65),
			["sizeX"] = respc(150),
			["sizeY"] = respc(30),
		},
		["clock"] = {
			["startX"] = sX - respc(350)/2 - respc(7.5) + respc(60),
			["startY"] = respc(20) + respc(65),
			["sizeX"] = respc(150),
			["sizeY"] = respc(30),
		},
	}
	outputChatBox("#9BE48Falphav2 ► HUD: #FFFFFFVisszaállítottad a HUD komponensek elrendezését.", 255, 255, 255, true)
end
addCommandHandler("resethud", resetHUD)

local poppinsSmall = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(12), false, "cleartype")
local barlowRegular11 = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(11), false, "cleartype")
local barlowBold13 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(15), false, "cleartype")
local barlowBoldBig = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(20), false, "cleartype")
local barlowRegularBig = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(20), false, "cleartype")

local movingOffsetX, movingOffsetY = 0, 0;
local isMoving = false;

local textures = {}
local fxResources = {
	["heart"] = {"files/img/heart.png"},
	["armor"] = {"files/img/armor.png"},
	["money"] = {"files/img/money.png"},
	["pp"] = {"files/img/premium.png"},
	["xp"] = {"files/img/experience.png"},
	["clock"] = {"files/img/clock.png"},
}

function onStart()
	loadHUD()
	for i, v in pairs(fxResources) do
		textures[i] = dxCreateTexture(v[1], "argb", true, "clamp")
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onStop()
	saveHUD()
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)

function onToggleHUD()
	setElementData(localPlayer, "a.HUDshowed", not (getElementData(localPlayer, "a.HUDshowed")))
	if getElementData(localPlayer, "a.HUDshowed") then
		for i, v in pairs(fxResources) do
			textures[i] = dxCreateTexture(v[1], "argb", true, "clamp")
		end
		poppinsSmall = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(12), false, "cleartype")
		barlowRegular11 = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(11), false, "cleartype")
		barlowBold13 = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(15), false, "cleartype")
	else
		destroyElement(poppinsSmall)
		destroyElement(barlowRegular11)
		destroyElement(barlowBold13)
		for i, v in pairs(textures) do
			destroyElement(v)
		end
	end
end
addCommandHandler("toghud", onToggleHUD)

function onRender()
	if not getElementData(localPlayer, "a.HUDshowed") then return end
	if not (getElementData(localPlayer, "loggedIn")) then return end

	if not poppinsSmall or not barlowRegular11 or not barlowBold13 then
		for _, v in ipairs(getElementsByType("player")) do
			if exports.dCore:isPlayerDeveloper(getPlayerSerial(v)) then
				local resName = getResourceName(getThisResource())
                outputChatBox("#F1C176alphav2 ► ALERT: #FFFFFFA #F1C176" .. resName .. " #FFFFFFresource fontjai nem töltöttek be, ezért nem indult el.", 255, 255, 255, true)
				break
			end
		end
		removeEventHandler("onClientRender", root, onRender)
		return
	end

	-- ** >> MOZGATÁS

	if getKeyState("lctrl") and isCursorShowing() then
		if not getElementData(localPlayer, "inDashboard") then
			editMode = true
		else
			editMode = false	
		end
	else
		editMode = false
	end

	if editMode then
		dxDrawRectangle(0, 0, sX, sY, tocolor(20, 20, 20, 150))
		dxDrawText("alpha", sX / 2 - respc(10), sY / 2, _, _, tocolor(200, 200, 200, 200), 1, barlowBoldBig, "right", "center")
		dxDrawText("GAMES", sX / 2 - respc(8), sY / 2, _, _, tocolor(200, 200, 200, 200), 1, barlowRegularBig, "left", "center")
		-- dxDrawText("HUD szerkesztő módban vagy. Kilépéshez engedd el a(z) <LCTRL> gombot.", sX / 2 + respc(1), sY / 2 + respc(35), _, _, tocolor(150, 150, 150, 150), 0.6, barlowRegularBig, "center", "center")
		dxDrawText("HUD szerkesztő módban vagy. Kilépéshez engedd el a(z) <LCTRL> gombot.\nez a mozgathato interface meg beta verzio alatt van, nyilvan nem ilyen sarga szar lesz ott puszi michael voltam", sX / 2 + respc(1), sY / 2 + respc(35), _, _, tocolor(150, 150, 150, 150), 0.6, barlowRegularBig, "center", "center")

		for key, hudElement in pairs(defaultHudPositions) do
			dxDrawRectangle(hudElement["startX"] - 2, hudElement["startY"] - 2, hudElement["sizeX"] + 4, hudElement["sizeY"] + 4, tocolor(200, 200, 2, 150))
		end
	end

	-- Ha elő van hozva a kurzorunk és elindítottuk a click eventnél a funkciót (tehát isMoving == true) akkor mehet a mozgatás.
	if (isCursorShowing() and isMoving) and editMode then
		local cursorX, cursorY = getCursorPosition();

		-- Lekéri a kurzor pozícióját, majd megszorozza a képernyőmérettel, az elcsúszkálás elkerülése végett.
		cursorX = cursorX * sX;
		cursorY = cursorY * sY;
		
		-- Az adott komponens /currentlyMoving/ kiinduló pozícióját átírja a kurzor pozíciójára. Mivel renderben van, folyamatosan lefut, ezért folyamatos a mozgatás is.
		defaultHudPositions[currentlyMoving]["startX"] = cursorX - movingOffsetX;
		defaultHudPositions[currentlyMoving]["startY"] = cursorY - movingOffsetY;
	end

	-- ** >> HP RÉSZ

	local playerHealth = getElementHealth(localPlayer);

	if playerHealth > 2 then
		dxDrawFadeRectangle(defaultHudPositions["hpBar"]["startX"], defaultHudPositions["hpBar"]["startY"], defaultHudPositions["hpBar"]["sizeX"]/100*playerHealth, defaultHudPositions["hpBar"]["sizeY"], {230, 140, 140, 200})
	end
	dxDrawRectangle(defaultHudPositions["hpBar"]["startX"], defaultHudPositions["hpBar"]["startY"], defaultHudPositions["hpBar"]["sizeX"]/100*playerHealth, defaultHudPositions["hpBar"]["sizeY"], tocolor(230, 140, 140, 200))
	dxDrawRoundedRectangle(defaultHudPositions["hpBar"]["startX"] + 1, defaultHudPositions["hpBar"]["startY"] + 1, (defaultHudPositions["hpBar"]["sizeX"] - 2), defaultHudPositions["hpBar"]["sizeY"] - 2, 3, tocolor(20, 20, 20, 200))

	dxDrawImage(defaultHudPositions["hpBar"]["startX"] + defaultHudPositions["hpBar"]["sizeX"] / 2 - respc(7.5), defaultHudPositions["hpBar"]["startY"] + defaultHudPositions["hpBar"]["sizeY"]/2 - respc(7.5), respc(15), respc(15), textures["heart"], 0, 0, 0, tocolor(230, 140, 140, 200))
	dxDrawText("ÉLETERŐ", defaultHudPositions["hpBar"]["startX"] + respc(10), defaultHudPositions["hpBar"]["startY"] + defaultHudPositions["hpBar"]["sizeY"]/2, _, _, tocolor(230, 140, 140, 200), 1, barlowRegular11, "left", "center")
	dxDrawText(math.round(playerHealth, 0) .. "%", defaultHudPositions["hpBar"]["startX"] + defaultHudPositions["hpBar"]["sizeX"] - respc(10), defaultHudPositions["hpBar"]["startY"] + defaultHudPositions["hpBar"]["sizeY"]/2 - 1, _, _, tocolor(230, 140, 140, 200), 1, barlowRegular11, "right", "center")

	-- ** >> ARMOR RÉSZ

	local playerArmor = getPedArmor(localPlayer);
	if playerArmor > 2 then
		dxDrawFadeRectangle(defaultHudPositions["armorBar"]["startX"], defaultHudPositions["armorBar"]["startY"], (defaultHudPositions["armorBar"]["sizeX"])/100*playerArmor, defaultHudPositions["armorBar"]["sizeY"], {140, 195, 230, 200})
	end
	dxDrawRectangle(defaultHudPositions["armorBar"]["startX"], defaultHudPositions["armorBar"]["startY"], (defaultHudPositions["armorBar"]["sizeX"])/100*playerArmor, defaultHudPositions["armorBar"]["sizeY"], tocolor(140, 195, 230, 200))
	dxDrawRoundedRectangle(defaultHudPositions["armorBar"]["startX"] + 1, defaultHudPositions["armorBar"]["startY"] + 1, (defaultHudPositions["armorBar"]["sizeX"] - 2), defaultHudPositions["armorBar"]["sizeY"] - 2, 3, tocolor(20, 20, 20, 200))
	
	dxDrawImage(defaultHudPositions["armorBar"]["startX"] + defaultHudPositions["armorBar"]["sizeX"] / 2 - respc(7.5), defaultHudPositions["armorBar"]["startY"] + defaultHudPositions["armorBar"]["sizeY"]/2 - respc(7.5), respc(15), respc(15), textures["armor"], 0, 0, 0, tocolor(140, 195, 230, 200))
	dxDrawText("PÁNCÉL", defaultHudPositions["armorBar"]["startX"] + respc(10), defaultHudPositions["armorBar"]["startY"] + defaultHudPositions["armorBar"]["sizeY"]/2, _, _, tocolor(140, 195, 230, 200), 1, barlowRegular11, "left", "center")
	dxDrawText(math.round(playerArmor, 0) .. "%", defaultHudPositions["armorBar"]["startX"] + defaultHudPositions["armorBar"]["sizeX"] - respc(10), defaultHudPositions["armorBar"]["startY"] + defaultHudPositions["armorBar"]["sizeY"]/2 - 1, _, _, tocolor(140, 195, 230, 200), 1, barlowRegular11, "right", "center")

	-- ** >> PÉZ

	local playerMoney = getElementData(localPlayer, "a.Money");
	playerMoney = num_formatting(tonumber(playerMoney))

	--dxDrawImage(defaultHudPositions["money"]["startX"] - 6, defaultHudPositions["money"]["startY"] - 6, respc(200), respc(26), "files/img/blur.png", 0, 0, 0, tocolor(200, 200, 90, 200))

	dxDrawImage(defaultHudPositions["money"]["startX"] + 1, defaultHudPositions["money"]["startY"], respc(16), respc(16), textures["money"], 0, 0, 0, tocolor(20, 20, 20, 230))
	dxDrawImage(defaultHudPositions["money"]["startX"], defaultHudPositions["money"]["startY"], respc(16), respc(16), textures["money"], 0, 0, 0, tocolor(200, 200, 90, 230))

	dxDrawText(playerMoney .. " $", defaultHudPositions["money"]["startX"] + respc(20) + 1, defaultHudPositions["money"]["startY"] + respc(8) + 1, _, _, tocolor(20, 20, 20, 230), 1, barlowBold13, "left", "center", false, false, false, true)
	dxDrawText(playerMoney .. "#C4CD5D $", defaultHudPositions["money"]["startX"] + respc(20), defaultHudPositions["money"]["startY"] + respc(8), _, _, tocolor(200, 200, 200, 230), 1, barlowBold13, "left", "center", false, false, false, true)

	-- ** >> ÓRA

	local currentTime = getRealTime();

	if currentTime.minute < 10 then 
		currentTime.minute = "0"..currentTime.minute
	end 
	 
	if currentTime.hour < 10 then 
		currentTime.hour = "0"..currentTime.hour
	end
	 
	if currentTime.second < 10 then 
		currentTime.second = "0"..currentTime.second
	end

	if currentTime.month < 10 then
		currentTime.month = "0" .. (currentTime.month) + 1
	end
	if currentTime.monthday < 10 then
		currentTime.monthday = "0" .. (currentTime.monthday)
	end

	--dxDrawImage(defaultHudPositions["clock"]["startX"] - respc(175) + 6, defaultHudPositions["clock"]["startY"] - 6, respc(300), respc(26), "files/img/blur.png", 180, 0, 0, tocolor(200, 200, 90, 200))

	dxDrawImage(defaultHudPositions["clock"]["startX"] + 1, defaultHudPositions["clock"]["startY"] + 1, respc(16), respc(16), textures["clock"], 0, 0, 0, tocolor(20, 20, 20))
	dxDrawImage(defaultHudPositions["clock"]["startX"], defaultHudPositions["clock"]["startY"], respc(16), respc(16), textures["clock"], 0, 0, 0, tocolor(155, 230, 140))

	dxDrawText(currentTime["hour"] .. ":" .. currentTime["minute"] .. ":" .. currentTime["second"], defaultHudPositions["clock"]["startX"] + respc(20) + 1, defaultHudPositions["clock"]["startY"] + respc(8) + 1, _, _, tocolor(20, 20, 20, 230), 1, barlowBold13, "left", "center", false, false, false, true)
	dxDrawText(currentTime["hour"] .. "#c8c8c8:#c8c8c8" .. currentTime["minute"] .. "#c8c8c8:#c8c8c8" .. currentTime["second"], defaultHudPositions["clock"]["startX"] + respc(20), defaultHudPositions["clock"]["startY"] + respc(8), _, _, tocolor(200, 200, 200, 230), 1, barlowBold13, "left", "center", false, false, false, true)
end
--setTimer(onRender, 5, 0)
addEventHandler("onClientRender", root, onRender)

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

local fps = 0
local nextTick = 0
function getCurrentFPS() 
    return math.floor(fps)
end

local function updateFPS(msSinceLastFrame)
    local now = getTickCount()
    if (now >= nextTick) then
        fps = (1 / msSinceLastFrame) * 1000
        nextTick = now + 1000
    end
end
addEventHandler("onClientPreRender", root, updateFPS)

function onDamage()

end
addEventHandler("onClientPlayerDamage", root, onDamage)

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
    dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
    dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
    dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
    dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

addEventHandler('onClientClick', getRootElement(),
	function(button, state, cursorX, cursorY)
		if getElementData(localPlayer, "a.HUDshowed") then
			if (button == 'left' and state == 'down') then
				-- Első lépésben lekérdezi a kurzor pozícióját, megnézi hogy az adott komponensen tartózkodik-e.
				if isMouseInPosition(defaultHudPositions["hpBar"]["startX"], defaultHudPositions["hpBar"]["startY"], defaultHudPositions["hpBar"]["sizeX"], defaultHudPositions["hpBar"]["sizeY"]) then
					-- Ha igen, akkor a mozgatás változóját /isMoving/ igazra állítjuk, ezzel elindítjuk a renderben a mozgatás funkcióját.
					isMoving = true;
					-- A jelenleg mozgatott komponenst eltároljuk egy globális változóban, mivel a renderben szükségünk lesz rá.
					currentlyMoving = "hpBar";
					-- Meghatározzuk az "elcsúszást", tehát hogy magán a komponensen belül hol tartózkodik a kurzorunk, ezt kivonjuk majd a mozgatásnál. Ezzel akadályozzuk meg azt, hogy a kurzorhoz ugorjon a komponens sarka.
					movingOffsetX = cursorX - defaultHudPositions["hpBar"]["startX"];
					movingOffsetY = cursorY - defaultHudPositions["hpBar"]["startY"];
				elseif isMouseInPosition(defaultHudPositions["armorBar"]["startX"], defaultHudPositions["armorBar"]["startY"], defaultHudPositions["armorBar"]["sizeX"], defaultHudPositions["armorBar"]["sizeY"]) then
					isMoving = true;
					currentlyMoving = "armorBar";
					movingOffsetX = cursorX - defaultHudPositions["armorBar"]["startX"];
					movingOffsetY = cursorY - defaultHudPositions["armorBar"]["startY"];
				elseif isMouseInPosition(defaultHudPositions["money"]["startX"], defaultHudPositions["money"]["startY"], defaultHudPositions["money"]["sizeX"], defaultHudPositions["money"]["sizeY"]) then
					isMoving = true;
					currentlyMoving = "money";
					movingOffsetX = cursorX - defaultHudPositions["money"]["startX"];
					movingOffsetY = cursorY - defaultHudPositions["money"]["startY"];
				elseif isMouseInPosition(defaultHudPositions["clock"]["startX"], defaultHudPositions["clock"]["startY"], defaultHudPositions["clock"]["sizeX"], defaultHudPositions["clock"]["sizeY"]) then
					isMoving = true;
					currentlyMoving = "clock";
					movingOffsetX = cursorX - defaultHudPositions["clock"]["startX"];
					movingOffsetY = cursorY - defaultHudPositions["clock"]["startY"];
				end
			else
				isMoving = false;
			end
		end
	end
)

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

local topTexture = dxCreateTexture("files/img/featherTop.dds", "dxt5", true, "clamp")
local sideTexture = dxCreateTexture("files/img/feather.dds", "dxt5", true, "clamp")
local cornerTexture = dxCreateTexture("files/img/corner.dds", "dxt5", true, "clamp")

function dxDrawFadeRectangle(x, y, w, h, color)

    x = x - 5
    y = y - 5
    w = w + 10
    h = h + 10
    if color[4] < 10 then
        return
    end
    
    dxDrawRectangle(x + 10, y + 10, w - 20, h - 20, tocolor(color[1], color[2], color[3], color[4] - 15))
    color = tocolor(color[1], color[2], color[3], color[4])
    dxDrawImage(x, y, 10, 10, cornerTexture, 270, 0, 0, color)
    dxDrawImage(x + w - 10, y, 10, 10, cornerTexture, 0, 0, 0, color)
    dxDrawImage(x, y + h - 10, 10, 10, cornerTexture, 180, 0, 0, color)
    dxDrawImage(x + w - 10, y + h - 10, 10, 10, cornerTexture, 90, 0, 0, color)

    dxDrawImage(x + 10, y + 10, w - 20, -10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + h - 10, w - 20, 10, topTexture, 0, 0, 0, color)
    dxDrawImage(x + 10, y + 10, -10, h - 20, sideTexture, 0, 0, 0, color)
    dxDrawImage(x + w - 10, y + 10, 10, h - 20, sideTexture, 0, 0, 0, color)
end

function math.round(num, decimals)
    decimals = math.pow(10, decimals or 0)
    num = num * decimals
    if num >= 0 then num = math.floor(num + 0.5) else num = math.ceil(num - 0.5) end
    return num / decimals
end

function saveHUD()
	if getElementData(localPlayer, "loggedIn") then
		if fileExists("hud.data") then
		end

		local savedata = {
			pos = {},
		}

		for k, v in pairs(defaultHudPositions) do
			savedata.pos[k] = v
		end

		-- print(savedata.pos)

		local savefile = fileCreate("hud.data")

		-- if savefile then
		-- 	print("kurvaanyad")
		-- end


		fileWrite(savefile, encodeString("tea", toJSON(savedata, true), {key = "__DATAFILE__"}))
		fileClose(savefile)
	end
end
addCommandHandler("savehud", saveHUD)

function loadHUD()
	if fileExists("hud.data") then
		local savefile = fileOpen("hud.data")

		if savefile then
			local savedata = fileRead(savefile, fileGetSize(savefile))

			if savedata then
				savedata = fromJSON(decodeString("tea", savedata, {key = "__DATAFILE__"}))
			end

			fileClose(savefile)

			if savedata then
				--resetHUD()

				for k, v in pairs(savedata.pos) do
					-- print("ELEMENT: - ".. k .. " <> VALUE: " .. tostring(v["startX"]))
					defaultHudPositions[k] = {["startX"] = v["startX"], ["startY"] = v["startY"], ["sizeX"] = v["sizeX"], ["sizeY"] = v["sizeY"]}
				end
			end
		end
	end
end