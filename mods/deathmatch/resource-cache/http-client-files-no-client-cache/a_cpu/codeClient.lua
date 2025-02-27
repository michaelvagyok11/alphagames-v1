local sx,sy = guiGetScreenSize()
local resStat = false
local clientRows = {}, {}
local serverRows = {}, {}

local MED_CLIENT_CPU = 5 -- 5%
local MAX_CLIENT_CPU = 10 -- 5%

local MED_SERVER_CPU = 5 -- 5%
local MAX_SERVER_CPU = 10 -- 5%

local font = dxCreateFont("Roboto-Condensed.otf", 11)

function dxDrawBorder(x, y, w, h, size, color, postGUI)
	size = size or 2

	dxDrawRectangle(x - size, y, size, h, color or tocolor(0, 0, 0, 200), postGUI)
	dxDrawRectangle(x + w, y, size, h, color or tocolor(0, 0, 0, 200), postGUI)
	dxDrawRectangle(x - size, y - size, w + (size * 2), size, color or tocolor(0, 0, 0, 200), postGUI)
	dxDrawRectangle(x - size, y + h, w + (size * 2), size, color or tocolor(0, 0, 0, 200), postGUI)
end


addCommandHandler("stat", function()
	if getElementData(localPlayer, "adminLevel") >= 3 then
		resStat = not resStat
		if resStat then
			_, clientRows = getPerformanceStats("Lua timing")
			outputChatBox("#8FC3E4[cpu]: #FFFFFFCPU load detection switched on.", 0, 255, 0, true)
			addEventHandler("onClientRender", root, resStatRender)
		else
			outputChatBox("#8FC3E4[cpu]: #FFFFFFCPU load detection switched off.", 255, 0, 0, true)
			removeEventHandler("onClientRender", root, resStatRender)
			serverRows = {}, {}
			clientRows = {}, {}
			triggerServerEvent("destroyServerStat", localPlayer)
		end
	end
end)

function toFloor(num)
	return tonumber(string.sub(tostring(num), 0, -2)) or 0
end


triggerServerEvent("getServerStat", localPlayer)

addEvent("receiveServerStat", true)
addEventHandler("receiveServerStat", root, function(stat1,stat2)
	_, clientRows = getPerformanceStats("Lua timing")
	_, serverRows = stat1,stat2

	table.sort(clientRows, function(a, b)
		return toFloor(a[2]) > toFloor(b[2])
	end)

	table.sort(serverRows, function(a, b)
		return toFloor(a[2]) > toFloor(b[2])
	end)
end)

local gColorCR, gColorCG, gColorCB = 120, 70, 50
local gColorSR, gColorSG, gColorSB = 120, 70, 50

setTimer(
    function()
        local allCPU, count = 0, 0
        for k,v in pairs(clientRows) do
            local usedCPU = toFloor(v[2])
            allCPU = allCPU + usedCPU
            count = count + 1
        end
        
        local average = allCPU / count
        --outputChatBox("KLIENS ÁTLAG: "..average.. " ("..allCPU.."/"..count..")")
        
        gColorCR, gColorCG, gColorCB = 120, 70, 50
        if average >= MAX_CLIENT_CPU then
            gColorCR, gColorCG, gColorCB = 210,49,49
        elseif average >= MED_CLIENT_CPU then
            gColorCR, gColorCG, gColorCB = 208, 153, 36
        end
        
        local allCPU, count = 0, 0
        for k,v in pairs(serverRows) do
            local usedCPU = toFloor(v[2])
            allCPU = allCPU + usedCPU
            count = count + 1
        end
        
        local average = allCPU / count
        --outputChatBox("SERVER ÁTLAG: "..average.. " ("..allCPU.."/"..count..")")
        
        gColorSR, gColorSG, gColorSB = 120, 70, 50
        if average >= MAX_SERVER_CPU then
            gColorSR, gColorSG, gColorSB = 210,49,49
        elseif average >= MED_SERVER_CPU then
            gColorSR, gColorSG, gColorSB = 208, 153, 36
        end
    end, 250, 0
)

local disabledResources = {}
function resStatRender()
	local x = sx-310
	if #serverRows == 0 then
		x = sx-150
	end
	if #clientRows ~= 0 then
		local height = (15*#clientRows)
		local y = sy/2-(height + 30)/2
		dxDrawRectangle(x-47,y,185,height + 30,tocolor(0,0,0,100))
		dxDrawBorder(x-47,y,185,height + 30,1,tocolor(gColorCR, gColorCG, gColorCB,255))
		if #serverRows == 0 then
			dxDrawText("Clientside",x-47,y,x-47+185,y-18,tocolor(255,255,255,255),1,font,"center")
		else
			dxDrawText("Clientside",x-47,y,x-47+185,y-17,tocolor(0,0,0,255),1,font,"center")
			dxDrawText("Clientside",x-47-1,y,x-47-1+185,y-20,tocolor(255,255,255,255),1,font,"center")
		end
		y = y + 5
		for i, row in ipairs(clientRows) do
			if not disabledResources[row[1]] then
				local usedCPU = toFloor(row[2])
				local r,g,b,a = 200, 200, 200, 255
				if usedCPU >= MAX_CLIENT_CPU then
					r,g,b = 200,200,200
				elseif usedCPU >= MED_CLIENT_CPU then
					r,g,b = 208, 153, 36
				end
                --if usedCPU > 0.1 then                    
                local text = row[1]:sub(0,16)..": "..usedCPU.."%"
                dxDrawText(text,x-42,y+16,150,15,tocolor(0,0,0,a),1,font)
                dxDrawText(text,x-41,y+15,150,15,tocolor(r,g,b,a),1,font)
                y = y + 15
                --end
			end
		end
	end

	if #serverRows ~= 0 then
		local x = sx-150
		local height = (15*#serverRows)
		local y = sy/2-(height + 30)/2
		dxDrawRectangle(x-10,y,150,height+30,tocolor(0,0,0,100))
		dxDrawBorder(x-10,y,150,height+30,1,tocolor(gColorSR, gColorSG, gColorSB, 255))
		dxDrawText("Serverside",sx-86,y,sx-86,y,tocolor(0,0,0,255),1,font,"center")
		dxDrawText("Serverside",sx-85,y,sx-85,y,tocolor(255,255,255,255),1,font,"center")
		y = y + 5
		for i, row in ipairs(serverRows) do
			if not disabledResources[row[1]] then
				local usedCPU = toFloor(row[2])
				local r,g,b,a = 200, 200, 200, 255
				if usedCPU >= MAX_SERVER_CPU then
					r,g,b = 200,200,200
				elseif usedCPU >= MED_SERVER_CPU then
					r,g,b = 208, 153, 36
				end
                --if usedCPU > 0.1 then
				local text = row[1]:sub(0,15)..": "..usedCPU.."%"
				dxDrawText(text,x-1,y+16,150,15,tocolor(0,0,0,a),1,font)
				dxDrawText(text,x,y+15,150,15,tocolor(r,g,b,a),1,font)
				y = y + 15
                --end
			end
		end
	end
end
