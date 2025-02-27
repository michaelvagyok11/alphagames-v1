function Reload(plr) 
    reloadPedWeapon(plr) 
end 
addEventHandler('onResourceStart', resourceRoot, Reload ) 
  
addEventHandler ( "onPlayerJoin", root, 
    function ( ) 
        bindKey ( source, "r", "down", Reload ) 
    end 
) 

function Reload ( plr ) 
    local player = plr or source 
    reloadPedWeapon ( player ) 
end 
  
addEventHandler ( "onPlayerJoin", root, 
    function ( ) 
        bindKey ( source, "r", "down", Reload ) 
    end 
) 
  
addEventHandler ( "onResourceStart", resourceRoot,  
    function ( ) 
        for _, plr in ipairs ( getElementsByType ( "player" ) ) do 
            bindKey ( plr, "r", "down", Reload ) 
        end 
    end 
) 