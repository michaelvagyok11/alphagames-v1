function szirenak()
	sound = playSound("tomo.mp3")
    setSoundVolume(sound, 100)
end

addEvent("SzirenaLejatszasa", true)
addEventHandler("SzirenaLejatszasa", root, szirenak)