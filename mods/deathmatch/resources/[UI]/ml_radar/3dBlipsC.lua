--Script by LENNON (112, 152, 207) #7098CF

local font = dxCreateFont( ":dFonts/fonts/Barlow-Bold.ttf", 10 )

addEventHandler("onClientResourceStart",resourceRoot,function()
    loadState()
    if getElementData(localPlayer,"3Dblips") then 
        addEventHandler("onClientRender",getRootElement(),blipsRender)
    end
end)

addEventHandler("onClientElementDataChange",localPlayer,function(dataName,oldValue,newValue)
    if dataName == "3Dblips" then 
        if newValue then 
            removeEventHandler("onClientRender",getRootElement(),blipsRender)
            addEventHandler("onClientRender",getRootElement(),blipsRender)
        else 
            removeEventHandler("onClientRender",getRootElement(),blipsRender)
        end
    end
end)

function blipsRender()
    local px,py,pz = getElementPosition(localPlayer)
    if getElementDimension(localPlayer) == 0 and getElementData(localPlayer, "char > loggedin") then 
        for k,v in pairs(getElementsByType("blip")) do 
            local x,y = getScreenFromWorldPosition(getElementPosition(v))
            local bx,by,bz = getElementPosition(v)
            local distance = getDistanceBetweenPoints3D(px,py,pz,bx,by,bz)
            if x and y then 
                if (distance < 200 or (getElementData(v,"blip > maxVisible") or false)) then 
                    local icon = getBlipIcon(v)
                    if icon ~= 2 and icon ~= 15 then 
                        local name = "Ismeretlen Blip"
                        if (getElementData(v, "blip > name") or false) then
                            name = getElementData(v, "blip > name")
                        elseif blipNames[icon] then
                            name = blipNames[icon]
                        end 
                        local r,g,b = unpack(getElementData(v,"blip > color") or {255,255,255})
                        dxDrawImage(x,y-20,25,25,"blips/"..icon..".png",0,0,0,tocolor(r,g,b,220))
                        dxDrawText(name.."\n Távolság: #7098CF"..math.floor(distance).." m",x,y+10,x+30,0,tocolor(255,255,255),1,font,"center","top", false, false, false, true)
                    end
                end
            end
        end
    end
end

function loadState()
    if fileExists("3dstate.save666666") then 
        local file = fileOpen("3dstate.save666666")
        local cache = fileRead(file,1000)
        if cache == "true" then 
            cache = true
        else 
            cache = false
        end
        setElementData(localPlayer,"3Dblips",cache)
        fileClose(file)
        outputDebugString("3D blipek betöltve!",0,100,100,100,200)
    end
end

function saveState()
    if fileExists("3dstate.save666666") then 
        fileDelete("3dstate.save666666")
    end
    local file = fileCreate("3dstate.save666666")
    fileWrite(file,tostring(getElementData(localPlayer,"3Dblips")))
    fileClose(file);
    outputDebugString("3D blipek lementve!",0,100,100,100,200)
end
addEventHandler("onClientResourceStop",resourceRoot,saveState)

function shadowedText(text,x,y,w,h,color,fontsize,font,aligX,alignY,a,b,c,d,rot)
    if not a then a = false end;
    if not b then b = false end;
    if not c then c = false end;
    if not d then d = true end;
    if not rot then rot = 0 end;
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x,y+1,w,h+1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, a,b,c,d,false,rot) 
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x,y-1,w,h-1,tocolor(0,0,0,255),fontsize,font,aligX,alignY, a,b,c,d,false,rot)
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x-1,y,w-1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, a,b,c,d,false,rot) 
    dxDrawText(text:gsub("#%x%x%x%x%x%x",""),x+1,y,w+1,h,tocolor(0,0,0,255),fontsize,font,aligX,alignY, a,b,c,d,false,rot) 
    dxDrawText(text,x,y,w,h,color,fontsize,font,aligX,alignY, a,b,c,d,false,rot)
end

addCommandHandler("3dblips", function()
    if getElementData(localPlayer, "3Dblips") then
        setElementData(localPlayer, "3Dblips", false)
        outputChatBox("[3D Blips] #ffffffBlipek megjelenítése kikapcsolva!",112, 152, 207,true)
    else
        setElementData(localPlayer, "3Dblips", true)
        outputChatBox("[3D Blips] #ffffffBlipek megjelenítése bekapcsolva!",112, 152, 207,true)
    end
end)