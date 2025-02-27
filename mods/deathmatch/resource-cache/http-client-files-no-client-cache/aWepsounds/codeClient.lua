local cd;
setWorldSoundEnabled (5, false )
setWorldSoundEnabled (5, 31, true )
setWorldSoundEnabled (5, 32, true )
setWorldSoundEnabled (5, 84, true )
setWorldSoundEnabled (5, 85, true )
setWorldSoundEnabled (5, 55, true )
setWorldSoundEnabled (5, 51, true )
setWorldSoundEnabled (5, 66, true )
setWorldSoundEnabled (5, 69, true )
setWorldSoundEnabled (5, 70, true )
setWorldSoundEnabled (5, 71, true )
setWorldSoundEnabled (5, 72, true )
setWorldSoundEnabled (5, 84, true )
setWorldSoundEnabled (5, 85, true )

addEventHandler("onClientPlayerWeaponFire", getRootElement(), 
function ( weapon, ammo, ammoInClip ) 
    if gunsounds[weapon] then 
        
        local x,y,z = getElementPosition(source) 
        local sound = playSound3D(gunsounds[weapon], x,y,z) 
        if getElementDimension(localPlayer)~=64999 then
            setElementDimension(sound,getElementDimension(localPlayer))
        end
        setSoundVolume(sound,0.8) 
        setSoundMaxDistance(sound,120) 
    end 
end 
) 