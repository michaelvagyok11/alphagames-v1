ColorSwitches = {}
LastColorSwitches = {}
StartColorSwitch = {}
LastColorConcat = {}
activeButton = false
b = false

local barlowBoldSmall = dxCreateFont(":dFonts/fonts/Barlow-Bold.ttf", respc(13), false, "cleartype")
local barlowRegularSmall = dxCreateFont(":dFonts/fonts/Barlow-Regular.ttf", respc(13), false, "cleartype")

function createButton(Name, Text, PosX, PosY, SizeX, SizeY, Color)
	if Name and Text and PosX and PosY and SizeX and SizeY and Color then
		Buttons = {}

		Buttons[Name] = {PosX, PosY, SizeX, SizeY}
		
		local CursorX, CursorY = getCursorPosition()

		if tonumber(CursorX) then
			CursorX = CursorX * screenX
			CursorY = CursorY * screenY
		end

		if isCursorShowing() then
			for Key, Value in pairs(Buttons) do
				if CursorX >= Value[1] and CursorX <= Value[1] + Value[3] and CursorY >= Value[2] and CursorY <= Value[2] + Value[4] then
					activeButton = Key
					break
				end
			end
		end

		if activeButton == Name then
			ButtonData = {ProcessColorSwitchEffect(Name, {Color[1], Color[2], Color[3], 240, 4})}
		else
			ButtonData = {ProcessColorSwitchEffect(Name, {Color[1], Color[2], Color[3], 190, 0})}
		end

		PosX, PosY, SizeX, SizeY = PosX - ButtonData[5] / 2, PosY - ButtonData[5] / 2, SizeX + ButtonData[5], SizeY + ButtonData[5]
		dxDrawRectangle(PosX, PosY, SizeX, SizeY, tocolor(ButtonData[1], ButtonData[2], ButtonData[3], ButtonData[4]))
		dxDrawText(Text, PosX + SizeX / 2, PosY + SizeY / 2, nil, nil, tocolor(200, 200, 200, 240), 0.8, barlowRegularSmall, "center", "center")

		if activeButton then 
			b = true
		else
			b = false 
		end
	end
end

function ProcessColorSwitchEffect(Key, Color)
	if not ColorSwitches[Key] then
		if not Color[4] then
			Color[4] = 255
		end
		
		ColorSwitches[Key] = Color
		LastColorSwitches[Key] = Color
		
		LastColorConcat[Key] = table.concat(Color)
	end
		
	if LastColorConcat[Key] ~= table.concat(Color) then
		LastColorConcat[Key] = table.concat(Color)
		LastColorSwitches[Key] = Color
		StartColorSwitch[Key] = getTickCount()
	end
		
	if StartColorSwitch[Key] then
		local Progress = (getTickCount() - StartColorSwitch[Key]) / 300
		
		local Red, Green, Blue = interpolateBetween(
			ColorSwitches[Key][1], ColorSwitches[Key][2], ColorSwitches[Key][3],
			Color[1], Color[2], Color[3],
			Progress, "Linear"
		)
		
		Alpha, Size = interpolateBetween(ColorSwitches[Key][4], ColorSwitches[Key][5], 0, Color[4], Color[5], 0, Progress, "Linear")
		
		ColorSwitches[Key][1] = Red
		ColorSwitches[Key][2] = Green
		ColorSwitches[Key][3] = Blue
		ColorSwitches[Key][4] = Alpha
		ColorSwitches[Key][5] = Size
		
		if Progress >= 1 then
			StartColorSwitch[Key] = false
		end
	end
		
	return ColorSwitches[Key][1], ColorSwitches[Key][2], ColorSwitches[Key][3], ColorSwitches[Key][4], ColorSwitches[Key][5]
end