_tocolor = tocolor
function tocolor(r, g, b, a)
    if r == 30 and g == 35 and b == 48 then
        r, g, b = 35, 35, 35
    elseif  r == 40 and g == 45 and b == 58 then
        r, g, b = 45, 45, 45  
    elseif  r == 50 and g == 55 and b == 68 then
        r, g, b = 55, 55, 55     
    elseif  r == 60 and g == 65 and b == 78 then
        r, g, b = 65, 65, 65      
    elseif  r == 94 and g == 193 and b == 230 then
        r, g, b = 108, 179, 201                        
    end
    return _tocolor(r, g, b, a)
end