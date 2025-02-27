addEvent("infinityNitro",true) 
addEventHandler("infinityNitro",root, 
function () 
  
if isElement(source) then 
setVehicleNitroActivated ( source, true ) 
setVehicleNitroCount (source,101 ) 
end 
  
end) 