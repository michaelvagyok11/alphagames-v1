local Charset = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890"

addCommandHandler("compileresfiles", 
	function(Player, Command, ResourceName)
		if ResourceName then
			local Resource = getResourceFromName(ResourceName)
			local TempTable = "local FileKeys = {\n"

			if Resource then
				local Files = getFilesInResourceFolder("files/spaz/", Resource)

				if Files then
					for Key, Value in pairs(Files) do
						local FilePath = ":" .. ResourceName .. "/" .. Value

						local File = fileOpen(FilePath)
						local Size = fileGetSize(File)

						local Data = fileRead(File, Size)

						local LockString = RandomString(8)
						local EncodedData = TeaEncodeBinary(Data, LockString)

						local NewPath = utf8.gsub(Value, ".png", ".alphaGames")

						if fileExists(":" .. ResourceName .. "/" .. NewPath) then
							fileDelete(":" .. ResourceName .. "/" .. NewPath)
						end

						local EncodedFile = fileCreate(":" .. ResourceName .. "/" .. NewPath)
						fileWrite(EncodedFile, EncodedData)
						fileClose(EncodedFile)

						--print(":" .. ResourceName .. "/" .. NewPath .. " Done")

						local FileName = utf8.gsub(NewPath, "files/spaz/", "")
						local FileName = utf8.gsub(FileName, ".alphaGames", "")

						TempTable = TempTable .. '	["' .. tostring(FileName) .. '"] = "' .. tostring(LockString) .. '",\n'
					end

					TempTable = TempTable .. "\n}"

					if fileExists(ResourceName .. ".lua") then
						fileDelete(ResourceName .. ".lua")
					end

					local LuaFile = fileCreate(ResourceName .. ".lua")
					fileWrite(LuaFile, TempTable)
					fileClose(LuaFile)
				end
			end
		end
	end
)

function TeaEncodeBinary(Data, Key)
    return teaEncode(base64Encode(Data), Key)
end

function RandomString(Length)
	local Ret = {}
	local r
	for i = 1, Length do
		r = math.random(1, #Charset)
		table.insert(Ret, Charset:sub(r, r))
	end
	return table.concat(Ret)
end

function getFilesInResourceFolder(path, res)
	if (triggerServerEvent) then error('The @getFilesInResourceFolder function should only be used on server-side', 2) end
	
	if not (type(path) == 'string') then
		error("@getFilesInResourceFolder argument #1. Expected a 'string', got '"..type(path).."'", 2)
	end
	
	if not (tostring(path):find('/$')) then
		error("@getFilesInResourceFolder argument #1. The path must contain '/' at the end to make sure it is a directory.", 2)
	end
	
	res = (res == nil) and getThisResource() or res
	if not (type(res) == 'userdata' and getUserdataType(res) == 'resource-data') then  
		error("@getFilesInResourceFolder argument #2. Expected a 'resource-data', got '"..(type(res) == 'userdata' and getUserdataType(res) or tostring(res)).."' (type: "..type(res)..")", 2)
	end
	
	local files = {}
	local files_onlyname = {}
	local thisResource = res == getThisResource() and res or false
	local charsTypes = '%.%_%w%d%|%\%<%>%:%(%)%&%;%#%?%*'
	local resourceName = getResourceName(res)
	local Meta = xmlLoadFile(':'..resourceName ..'/meta.xml')
	if not Meta then error("(@getFilesInResourceFolder) Could not get the 'meta.xml' for the resource '"..resourceName.."'", 2) end
	for _, nod in ipairs(xmlNodeGetChildren(Meta)) do
		local srcAttribute = xmlNodeGetAttribute(nod, 'src')
		if (srcAttribute) then
			local onlyFileName = tostring(srcAttribute:match('/(['..charsTypes..']+%.['..charsTypes..']+)') or srcAttribute)
			local theFile = fileOpen(thisResource and srcAttribute or ':'..resourceName..'/'..srcAttribute)
			if theFile then
				if (path == '/') then
					table.insert(files, srcAttribute)
					table.insert(files_onlyname, onlyFileName)
				else
					local filePath = fileGetPath(theFile)
					filePath = filePath:gsub('/['..charsTypes..']+%.['..charsTypes..']+', '/'):gsub(':'..resourceName..'/', '')
					if (filePath == tostring(path)) then
						table.insert(files, srcAttribute)
						table.insert(files_onlyname, onlyFileName)
					end
				end
				fileClose(theFile)
			else
				outputDebugString("(@getFilesInResourceFolder) Could not check file '"..onlyFileName.."' from resource '"..nomeResource.."'", 2)
			end
		end
	end
	xmlUnloadFile(Meta)
	return #files > 0 and files or false, #files_onlyname > 0 and files_onlyname or false
end