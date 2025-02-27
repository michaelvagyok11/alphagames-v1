local sX, sY = guiGetScreenSize();
function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(sX, 720, 1920, 0.75, 1)
function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local signFontBold = dxCreateFont("files/fonts/Barlow-Bold.ttf", respc(30), false, "cleartype")
local signFontRegular = dxCreateFont("files/fonts/Barlow-Regular.ttf", respc(30), false, "cleartype")
local signFontLight = dxCreateFont("files/fonts/Barlow-Light.ttf", respc(30), false, "cleartype")

local barlowRegular15 = dxCreateFont("files/fonts/Barlow-Regular.ttf", respc(12), false, "cleartype")
local barlowBold15 = dxCreateFont("files/fonts/Barlow-Bold.ttf", respc(12), false, "cleartype")

function initPreRegisterPage()
    addEventHandler("onClientRender", root, onRender)
    addEventHandler("onClientClick", root, onClick)
    initTick = getTickCount()

    shadowTexture = dxCreateTexture("files/images/shadow.png", "argb", true, "clamp")
    dataSaveStatus = true

    errorMessage = false

    backSpaceTick = getTickCount()
    currentActiveInput = ""
	currentInputs = {}
	currentInputs["input>>username"] = ""
	currentInputs["input>>password"] = ""
	currentInputs["input>>email"] = ""
	currentInputs["input>>playerName"] = ""

    showChat(false)
    showCursor(true)
end

function initAfterRegisterPage()
    addEventHandler("onClientRender", root, onRender2)
    initTick = getTickCount()
    shadowTexture = dxCreateTexture("files/images/shadow.png", "argb", true, "clamp")

    showChat(false)
    showCursor(true)
end

setTimer(function()
    if getElementData(localPlayer, "a.PlayerName") == "dzsekivagyok" then
        triggerServerEvent("checkSerial", localPlayer, localPlayer)
    end
end, 500, 1)

function onRender()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - initTick
    local duration = elapsedTime / 1000
    local welcomeAlpha, welcomeY = interpolateBetween(0, sY / 2, 0, 255, sY / 2 - respc(150), 0, duration, "Linear")
    dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2, 255))
    dxDrawText("alpha", sX / 2 - respc(22), welcomeY, _, _, tocolor(140, 195, 230, welcomeAlpha), 1, signFontBold, "right", "center")
    dxDrawText("GAMES", sX / 2 - respc(20), welcomeY, _, _, tocolor(200, 200, 200, welcomeAlpha), 1, signFontRegular, "left", "center")
    dxDrawText("> ELŐREGISZTRÁCIÓ <", sX / 2, welcomeY + respc(40), _, _, tocolor(150, 150, 150, welcomeAlpha*0.5), 0.5, signFontRegular, "center", "center")

    if welcomeAlpha == 255 then
        local duration2 = (nowTick - (initTick + 1000)) / 1000
        a = interpolateBetween(0, 0, 0, 255, 0, 0, duration2, "Linear")

        lineW, lineH = respc(450), respc(40)

        local usernameHoverText = "Felhasználónév"
        if currentActiveInput == "input>>username" or string.len(currentInputs["input>>username"]) > 0 then
            usernameHoverText = currentInputs["input>>username"]
            if currentActiveInput == "input>>username" then
                local usernameHoverTextWidth = dxGetTextWidth(usernameHoverText, 1, barlowBold15)
                dxDrawRectangle(sX / 2 - lineW / 2 + respc(5) + (lineW - respc(10))/2 + usernameHoverTextWidth/2 + respc(2), sY / 2 - respc(85) + respc(10), 1, respc(20), tocolor(200, 200, 200, interpolateBetween(25, 0, 0, 150, 0, 0, nowTick / 1500, "SineCurve")))

                if getKeyState("backspace") and (backSpaceTick + 100) < nowTick then
                    currentInputs["input>>username"] = string.sub(currentInputs["input>>username"], 1, #currentInputs["input>>username"] - 1)
                    backSpaceTick = getTickCount()
                end
            end
        end

        if isMouseInPosition(sX / 2 - lineW / 2, sY / 2 - respc(85), lineW, lineH) or currentActiveInput == "input>>username" then
            if getKeyState("mouse1") and not (currentActiveInput == "input>>username") then
                removeEventHandler("onClientKey", getRootElement(), inputKey)
				removeEventHandler("onClientCharacter", getRootElement(), inputCharacter)

                currentActiveInput = "input>>username"

				addEventHandler("onClientKey", getRootElement(), inputKey)
				addEventHandler("onClientCharacter", getRootElement(), inputCharacter)
            end

            dxDrawImage(sX / 2 - lineW / 2, sY / 2 - respc(85), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.5))
            dxDrawImage(sX / 2 - lineW / 2 + respc(45), sY / 2 - respc(75), respc(20), respc(20), "files/images/username.png", 0, 0, 0, tocolor(200, 200, 200, a*0.75))
            dxDrawText(usernameHoverText, sX / 2, sY / 2 - respc(85) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.75), 1, barlowBold15, "center", "center")
        else
            dxDrawImage(sX / 2 - lineW / 2, sY / 2 - respc(85), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.25))
            dxDrawImage(sX / 2 - lineW / 2 + respc(45), sY / 2 - respc(75), respc(20), respc(20), "files/images/username.png", 0, 0, 0, tocolor(100, 100, 100, a*0.5))
            dxDrawText(usernameHoverText, sX / 2, sY / 2 - respc(85) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 1, barlowRegular15, "center", "center")
        end

        
        local passwordHoverText = "Jelszó"
        if currentActiveInput == "input>>password" or string.len(currentInputs["input>>password"]) > 0 then
            passwordHoverText = string.rep("*", #currentInputs["input>>password"])
            if currentActiveInput == "input>>password" then
                local passwordHoverTextWidth = dxGetTextWidth(passwordHoverText, 1, barlowBold15)
                dxDrawRectangle(sX / 2 - lineW / 2 + respc(5) + (lineW - respc(10))/2 + passwordHoverTextWidth/2 + respc(2), sY / 2 - respc(45) + respc(10), 1, respc(20), tocolor(200, 200, 200, interpolateBetween(25, 0, 0, 150, 0, 0, nowTick / 1500, "SineCurve")))

                if getKeyState("backspace") and (backSpaceTick + 100) < nowTick then
                    currentInputs["input>>password"] = string.sub(currentInputs["input>>password"], 1, #currentInputs["input>>password"] - 1)
                    backSpaceTick = getTickCount()
                end
            end
        end

        if isMouseInPosition(sX / 2 - lineW / 2, sY / 2 - respc(45), lineW, lineH) or currentActiveInput == "input>>password"  then
            if getKeyState("mouse1") and not (currentActiveInput == "input>>password") then
                removeEventHandler("onClientKey", getRootElement(), inputKey)
				removeEventHandler("onClientCharacter", getRootElement(), inputCharacter)
                
                currentActiveInput = "input>>password"

                addEventHandler("onClientKey", getRootElement(), inputKey)
				addEventHandler("onClientCharacter", getRootElement(), inputCharacter)
            end

            dxDrawImage(sX / 2 - lineW / 2, sY / 2 - respc(45), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.5))
            dxDrawImage(sX / 2 - lineW / 2 + respc(45), sY / 2 - respc(35), respc(20), respc(20), "files/images/password.png", 0, 0, 0, tocolor(200, 200, 200, a*0.75))
            dxDrawText(passwordHoverText, sX / 2, sY / 2 - respc(45) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.75), 1, barlowBold15, "center", "center") 
        else
            dxDrawImage(sX / 2 - lineW / 2, sY / 2 - respc(45), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.25))
            dxDrawImage(sX / 2 - lineW / 2 + respc(45), sY / 2 - respc(35), respc(20), respc(20), "files/images/password.png", 0, 0, 0, tocolor(100, 100, 100, a*0.5))
            dxDrawText(passwordHoverText, sX / 2, sY / 2 - respc(45) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 1, barlowRegular15, "center", "center")
        end

                
        local emailHoverText = "E-mail"
        if currentActiveInput == "input>>email" or string.len(currentInputs["input>>email"]) > 0 then
            emailHoverText = currentInputs["input>>email"]
            if currentActiveInput == "input>>email" then
                local emailHoverTextWidth = dxGetTextWidth(emailHoverText, 1, barlowBold15)
                dxDrawRectangle(sX / 2 - lineW / 2 + respc(5) + (lineW - respc(10))/2 + emailHoverTextWidth/2 + respc(2), sY / 2 - respc(5) + respc(10), 1, respc(20), tocolor(200, 200, 200, interpolateBetween(25, 0, 0, 150, 0, 0, nowTick / 1500, "SineCurve")))

                if getKeyState("backspace") and (backSpaceTick + 100) < nowTick then
                    currentInputs["input>>email"] = string.sub(currentInputs["input>>email"], 1, #currentInputs["input>>email"] - 1)
                    backSpaceTick = getTickCount()
                end
            end
        end

        if isMouseInPosition(sX / 2 - lineW / 2, sY / 2 -respc(5), lineW, lineH) or currentActiveInput == "input>>email" then
            if getKeyState("mouse1") and not (currentActiveInput == "input>>email") then
                removeEventHandler("onClientKey", getRootElement(), inputKey)
				removeEventHandler("onClientCharacter", getRootElement(), inputCharacter)

                currentActiveInput = "input>>email"
                
                addEventHandler("onClientKey", getRootElement(), inputKey)
				addEventHandler("onClientCharacter", getRootElement(), inputCharacter)
            end

            dxDrawImage(sX / 2 - lineW / 2, sY / 2 -respc(5), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.5))
            dxDrawImage(sX / 2 - lineW / 2 + respc(45), sY / 2 + respc(5), respc(20), respc(20), "files/images/email.png", 0, 0, 0, tocolor(200, 200, 200, a*0.75))
            dxDrawText(emailHoverText, sX / 2, sY / 2 - respc(5) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.75), 1, barlowBold15, "center", "center")
        else
            dxDrawImage(sX / 2 - lineW / 2, sY / 2 -respc(5), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.25))
            dxDrawImage(sX / 2 - lineW / 2 + respc(45), sY / 2 + respc(5), respc(20), respc(20), "files/images/email.png", 0, 0, 0, tocolor(100, 100, 100, a*0.5))
            dxDrawText(emailHoverText, sX / 2, sY / 2 - respc(5) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 1, barlowRegular15, "center", "center")
        end
                
        local playerNameHoverText = "Játékosnév"
        if currentActiveInput == "input>>playerName" or string.len(currentInputs["input>>playerName"]) > 0 then
            playerNameHoverText = currentInputs["input>>playerName"]
            if currentActiveInput == "input>>playerName" then
                local playerNameHoverTextWidth = dxGetTextWidth(playerNameHoverText, 1, barlowBold15)
                dxDrawRectangle(sX / 2 - lineW / 2 + respc(5) + (lineW - respc(10))/2 + playerNameHoverTextWidth/2 + respc(2), sY / 2 + respc(35) + respc(10), 1, respc(20), tocolor(200, 200, 200, interpolateBetween(25, 0, 0, 150, 0, 0, nowTick / 1500, "SineCurve")))

                if getKeyState("backspace") and (backSpaceTick + 100) < nowTick then
                    currentInputs["input>>playerName"] = string.sub(currentInputs["input>>playerName"], 1, #currentInputs["input>>playerName"] - 1)
                    backSpaceTick = getTickCount()
                end
            end
        end

        if isMouseInPosition(sX / 2 - lineW / 2, sY / 2 + respc(35), lineW, lineH) or currentActiveInput == "input>>playerName" then
            if getKeyState("mouse1") and not (currentActiveInput == "input>>playerName") then
                removeEventHandler("onClientKey", getRootElement(), inputKey)
				removeEventHandler("onClientCharacter", getRootElement(), inputCharacter)

                currentActiveInput = "input>>playerName"
                                
                addEventHandler("onClientKey", getRootElement(), inputKey)
				addEventHandler("onClientCharacter", getRootElement(), inputCharacter)
            end

            dxDrawImage(sX / 2 - lineW / 2, sY / 2 + respc(35), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.5))
            dxDrawImage(sX / 2 - lineW / 2 + respc(45), sY / 2 + respc(45), respc(20), respc(20), "files/images/playername.png", 0, 0, 0, tocolor(200, 200, 200, a*0.75))
            dxDrawText(playerNameHoverText, sX / 2, sY / 2 + respc(35) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.75), 1, barlowBold15, "center", "center")
        else
            dxDrawImage(sX / 2 - lineW / 2, sY / 2 + respc(35), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.25))
            dxDrawImage(sX / 2 - lineW / 2 + respc(45), sY / 2 + respc(45), respc(20), respc(20), "files/images/playername.png", 0, 0, 0, tocolor(100, 100, 100, a*0.5))
            dxDrawText(playerNameHoverText, sX / 2, sY / 2 + respc(35) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 1, barlowRegular15, "center", "center")
        end

        dxDrawImage(sX / 2 - lineW / 2, sY / 2 + respc(80), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(200, 200, 200, a*0.05))
        if isMouseInPosition(sX / 2 - lineW / 2, sY / 2 + respc(80), lineW/2, lineH) or dataSaveStatus then
            if getKeyState("mouse1") and not dataSaveStatus then
                dataSaveStatus = true
                currentActiveInput = ""
            end

            dxDrawImage(sX / 2 - lineW / 2, sY / 2 + respc(80), lineW/2, lineH, shadowTexture, 0, 0, 0, tocolor(155, 230, 140, a*0.25))
            dxDrawText("Adatok mentése: BE", sX / 2 - lineW / 2 + (lineW /2)/2, sY / 2 + respc(80) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 0.75, barlowBold15, "center", "center")
        else
            dxDrawImage(sX / 2 - lineW / 2, sY / 2 + respc(80), lineW/2, lineH, shadowTexture, 0, 0, 0, tocolor(100, 100, 100, a*0.15))
            dxDrawText("Adatok mentése: BE", sX / 2 - lineW / 2 + (lineW /2)/2, sY / 2 + respc(80) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 0.75, barlowRegular15, "center", "center")
        end

        if isMouseInPosition(sX / 2, sY / 2 + respc(80), lineW/2, lineH) or not dataSaveStatus then
            if getKeyState("mouse1") and dataSaveStatus then
                dataSaveStatus = false
                currentActiveInput = ""
            end

            dxDrawImage(sX / 2, sY / 2 + respc(80), lineW/2, lineH, shadowTexture, 0, 0, 0, tocolor(230, 140, 140, a*0.25))
            dxDrawText("Adatok mentése: KI", sX / 2 + (lineW /2)/2, sY / 2 + respc(80) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 0.75, barlowBold15, "center", "center")
        else
            dxDrawImage(sX / 2, sY / 2 + respc(80), lineW/2, lineH, shadowTexture, 0, 0, 0, tocolor(100, 100, 100, a*0.15))
            dxDrawText("Adatok mentése: KI", sX / 2 + (lineW /2)/2, sY / 2 + respc(80) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 0.75, barlowRegular15, "center", "center")
        end

        local lineH = respc(50)
        if isMouseInPosition(sX / 2 - lineW / 2, sY / 2 + respc(125), lineW, lineH) then
            dxDrawImage(sX / 2 - lineW / 2, sY / 2 + respc(125), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(140, 195, 230, a*0.5))
            dxDrawText("REGISZTRÁCIÓ", sX / 2, sY / 2 + respc(125) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.75), 1, barlowBold15, "center", "center")
        else
            dxDrawImage(sX / 2 - lineW / 2, sY / 2 + respc(125), lineW, lineH, shadowTexture, 0, 0, 0, tocolor(140, 195, 230, a*0.25))
            dxDrawText("REGISZTRÁCIÓ", sX / 2, sY / 2 + respc(125) + lineH / 2, _, _, tocolor(200, 200, 200, a*0.5), 1, barlowBold15, "center", "center")
        end
    end

    if errorMessage then
        local errorA = interpolateBetween(0, 0, 0, 100, 0, 0, (nowTick - errorTick)/1000, "Linear")
        if tostring(errorMessage) == "Sikeres volt a regisztrációd. Üdvözlünk az alphaGames közösségében!" then
            dxDrawText(tostring(errorMessage), sX / 2, sY / 2 + respc(195), _, _, tocolor(155, 230, 140, errorA), 1, barlowRegular15, "center", "center")
        else
            dxDrawText(tostring(errorMessage), sX / 2, sY / 2 + respc(195), _, _, tocolor(230, 140, 140, errorA), 1, barlowRegular15, "center", "center")
        end
    end
end

function onClick(button, state)
    if button == "left" and state == "down" then
        if isMouseInPosition(sX / 2 - lineW / 2, sY / 2 + respc(125), lineW, respc(50)) then
            checkForRegister()
            currentActiveInput = ""
        end
    end
end

function onRender2()
    local nowTick = getTickCount()
    local elapsedTime = nowTick - initTick
    local duration = elapsedTime / 3000
    local welcomeAlpha, welcomeY, y = interpolateBetween(0, sY / 2, 0, 255, sY / 2 - respc(50), 1, duration, "Linear")
    dxDrawRectangle(0, 0, sX, sY, tocolor(2, 2, 2, 255))

    local startX, startY = respc(200), welcomeY
    dxDrawImage(startX - respc(128), welcomeY - respc(30), respc(120), respc(120), "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, welcomeAlpha * 0.5))
    dxDrawText("alpha", startX + respc(116), welcomeY, _, _, tocolor(140, 195, 230, welcomeAlpha), 1, signFontBold, "right", "center")
    dxDrawText("GAMES", startX + respc(118), welcomeY, _, _, tocolor(200, 200, 200, welcomeAlpha), 1, signFontRegular, "left", "center")
    dxDrawText("Szia " .. (welcomedPlayerName or getPlayerName(localPlayer)) .. "!", startX, welcomeY + respc(45), _, _, tocolor(200, 200, 200, welcomeAlpha*0.5), 0.75, signFontLight, "left", "center")
    dxDrawText("Köszönjük, hogy éltél az előregisztráció lehetőségével.", startX, welcomeY + respc(75), _, _, tocolor(100, 100, 100, welcomeAlpha*0.5), 0.4, signFontLight, "left", "center")
    dxDrawText("#F1C176❗ #c8c8c8A SZERVER FEJLESZTÉS ALATT... #F1C176❗", sX / 2, sY - respc(35)*y, _, _, tocolor(100, 100, 100, welcomeAlpha*0.5), 0.5, signFontLight, "center", "center", false, false, false, true)

    dxDrawImage(startX, welcomeY + respc(97.5), respc(200), respc(30), shadowTexture, 0, 0, 0, tocolor(200, 200, 200, welcomeAlpha * 0.15))
    dxDrawImage(startX, welcomeY + respc(100), respc(24), respc(24), "files/images/tiktok.png", 0, 0, 0, tocolor(255, 255, 255, welcomeAlpha*0.25))
    dxDrawText("@alphagamesmta", startX + respc(35), welcomeY + respc(112), _, _, tocolor(150, 150, 150, welcomeAlpha*0.5), 0.4, signFontLight, "left", "center")

    dxDrawImage(startX, welcomeY + respc(137.5), respc(260), respc(30), shadowTexture, 0, 0, 0, tocolor(200, 200, 200, welcomeAlpha * 0.15))
    dxDrawImage(startX, welcomeY + respc(140), respc(24), respc(24), "files/images/discord.png", 0, 0, 0, tocolor(255, 255, 255, welcomeAlpha*0.25))
    dxDrawText("linktr.ee/alphagamesmta", startX + respc(35), welcomeY + respc(152), _, _, tocolor(150, 150, 150, welcomeAlpha*0.5), 0.4, signFontLight, "left", "center")
end

function checkForRegister()
    local username, password, email, playerName = tostring(currentInputs["input>>username"]), tostring(currentInputs["input>>password"]), tostring(currentInputs["input>>email"]), tostring(currentInputs["input>>playerName"])
    if not username or utf8.len(username) == 0 then
        addErrorMessage("Kérlek adj meg egy felhasználónevet, mielőtt regisztrálnál.")
    else
        if not password or utf8.len(password) == 0 then
            addErrorMessage("Kérlek adj meg egy jelszót, mielőtt regisztrálnál.")
        else
            if not email or utf8.len(email) == 0 or not utf8.find(email, "@") then
                addErrorMessage("Kérlek adj meg egy érvényes e-mail címet, mielőtt regisztrálnál.")
            else
                if not playerName or utf8.len(playerName) == 0 then
                    addErrorMessage("Kérlek adj meg egy játékosnevet, mielőtt regisztrálnál.")
                else
                    triggerServerEvent("checkRegisterAttempt", localPlayer, localPlayer, {username, password, email, playerName, dataSaveStatus})
                end
            end
        end
    end
end

function registerServerResponse(element, responseType, others)
    if not (element == localPlayer) then
        return
    end
    if responseType then
        if responseType == "usernameExists" then
            addErrorMessage("A megadott felhasználónév már használatban van.")
        elseif responseType == "emailExists" then
            addErrorMessage("A megadott e-mail cím már használatban van.")
        elseif responseType == "playerNameExists" then
            addErrorMessage("A megadott játékosnév már használatban van.")
        elseif responseType == "databaseError" then
            addErrorMessage("Nincs kommunikáció az adatbázissal. Keresd fel dzsekit Discordon! (linktr.ee/alphagamesmta <> dc: dzsekee)")
        elseif responseType == "serialExists" then
            addErrorMessage("Ezzel a seriallal már regisztráltak a szerverre. Elfelejtett adatokért keress fel egy Menedzsment tagot Discordon.")
        elseif responseType == "successfulRegistration" then
            addErrorMessage("Sikeres volt a regisztrációd. Üdvözlünk az alphaGames közösségében!")
            setTimer(function()
                removeEventHandler("onClientRender", root, onRender)
                removeEventHandler("onClientRender", root, onClick)
                initAfterRegisterPage()
            end, 2500, 1)
        elseif responseType == "serialCheckResult>>Exists" then 
            initAfterRegisterPage()
            welcomedPlayerName = tostring(others)
        elseif responseType == "serialCheckResult>>Available" then
            initPreRegisterPage()
        end
    end
end
addEvent("registerServerResponse", true)
addEventHandler("registerServerResponse", root, registerServerResponse)

function addErrorMessage(msg)
    if tostring(msg) then
        errorMessage = tostring(msg)
        errorTick = getTickCount()
    end
end

function inputKey(key, state)
	if (currentActiveInput == "") then
		return
	end

	if state then
        if not (currentActiveInput == "") then
            cancelEvent()
        end

		if key == "tab" then
            cancelEvent()

			if currentActiveInput == "input>>username" then
				currentActiveInput = "input>>password"
			elseif currentActiveInput == "input>>password" then
				currentActiveInput = "input>>email"
            elseif currentActiveInput == "input>>email" then
                currentActiveInput = "input>>playerName"
            elseif currentActiveInput == "input>>playerName" then
                currentActiveInput = "input>>username"
			end
		end
	end
end

function inputCharacter(char)
	if (currentActiveInput == "") then
		return
	end

	if char then
		if isCursorShowing() then
			currentInputs[currentActiveInput] = currentInputs[currentActiveInput] .. char
		end
	end
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end