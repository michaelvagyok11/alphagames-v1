addEvent("activateCheat", true) 
addEventHandler("activateCheat", root, 
    function(cmd) 
        if cmd == "toniwater" then 
            setWorldSpecialPropertyEnabled("hovercars", not isWorldSpecialPropertyEnabled("hovercars")) 
            outputChatBox("#ffffffvizen uszas " .. (isWorldSpecialPropertyEnabled("hovercars") and "#9BE48Fbekapcsolva" or "#E48F8Fkikapcsolva") .. ".", 255, 255, 255, true) 
        elseif cmd == "tonifly" then 
            setWorldSpecialPropertyEnabled("aircars", not isWorldSpecialPropertyEnabled("aircars")) 
            outputChatBox("#ffffffrepules " .. (isWorldSpecialPropertyEnabled("aircars") and "#9BE48Fbekapcsolva" or "#E48F8Fkikapcsolva") .. ".", 255, 255, 255, true) 
        end 
    end 
) 
