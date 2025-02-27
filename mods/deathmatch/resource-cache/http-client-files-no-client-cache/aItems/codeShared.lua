itemList = {
	{"AK-47", "weapon", 30},
	{"Desert-Eagle", "weapon", 24},
	{"Colt-45", "weapon", 22},
	{"Gumibot", "weapon", 3},
	{"Kés", "weapon", 4},
	{"M4", "weapon", 31},
	{"Shotgun", "weapon", 25},
	{"Silenced Colt-45", "weapon", 23},
	{"Winter-Camo AK-47", "weapon", 30},
	{"Camo AK-47", "weapon", 30},
	{"P90", "weapon", 29},
	{"UZI", "weapon", 28},
	{"TEC-9", "weapon", 32},
	--
	{"Bronz Láda", "chest"},
	{"Ezüst Láda", "chest"},
	{"Arany Láda", "chest"},
	{"Smaragd Láda", "chest"},
	{"Gyémánt Láda", "chest"},
	--
	{"Camo-Styled AK-47", "weapon", 30},
	{"Golden AK-47", "weapon", 30},
	{"Golden-Styled AK-47", "weapon", 30},
	{"Hello-Kitty AK-47", "weapon", 30},
	{"Silver AK-47", "weapon", 30},
	{"Camo Desert Eagle", "weapon", 24},
	{"Golden Desert Eagle", "weapon", 24},
	{"Camo P90", "weapon", 29},
	{"Winter P90", "weapon", 29},
	{"Black P90", "weapon", 29},
	{"Gold Flow P90", "weapon", 29},
	{"No Limit P90", "weapon", 29},
	{"Oni P90", "weapon", 29},
	{"Carbon P90", "weapon", 29},
	{"Wooden P90", "weapon", 29},
	{"Halloween P90", "weapon", 29},
	{"Spas 12", "weapon", 27},
	{"Camo M4", "weapon", 31},
	{"Golden M4", "weapon", 31},
	{"Hello-Kitty M4", "weapon", 31},
	{"Painted M4", "weapon", 31},
	{"Winter M4", "weapon", 31},
}

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
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

function isValueInTable(theTable,value,columnID)
    assert(theTable, "Bad argument 1 @ isValueInTable (table expected, got " .. type(theTable) .. ")")
    local checkIsTable = type(theTable)
    assert(checkIsTable == "table", "Invalid value type @ isValueInTable (table expected, got " .. checkIsTable .. ")")
    assert(value, "Bad argument 2 @ isValueInTable (value expected, got " .. type(value) .. ")")
    assert(columnID, "Bad argument 3 @ isValueInTable (number expected, got " .. type(columnID) .. ")")
    local checkIsID = type(columnID)
    assert(checkIsID == "number", "Invalid value type @ isValueInTable (number expected, got " ..checkIsID .. ")")
    for i,v in ipairs (theTable) do
        if v[columnID] == value then
            return true,i
        end
    end
    return false
end