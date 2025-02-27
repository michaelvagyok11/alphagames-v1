local sx, sy = guiGetScreenSize()
--local ytLink = "https://www.youtube.com/embed/%s?controls=0&autoplay=1"
boardWidth, boardHeight = 851*3, 314*3

addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		myShader, tec = dxCreateShader ( "uv_scripted.fx" )
		if myShader then
			boardWidth, boardHeight = 851*2, 314*2
			boardTarget = dxCreateRenderTarget(boardWidth, boardHeight)
			engineApplyShaderToWorldTexture ( myShader, "bobo_2" )
			dxSetShaderValue(myShader, "CUSTOMTEX0", boardTarget)
			createObject ( 4729, 1372.3486328125, -18.2412109375, 36.25945892334, 0, 0, 190)
		end
	end
)

function onRender()
	dxSetRenderTarget(boardTarget, true)
		dxDrawImage(0, 0, boardWidth, boardHeight, "images/bg.jpg")
	dxSetRenderTarget()
end
addEventHandler("onClientRender", root, onRender)

--[[local signTexts = {
	{"#D19D6BGAMES"},
	{"#E48F8FTDMA"},
	{"#8FC3E4DRIFT"},
	{"#9BE48FFROAM"},
	{"#E48F8FPURSUIT"},
}

local signNum = 1;
signText = tostring(signTexts[signNum][1])
changeTick = getTickCount();
changeStatus = "out";

function changeSignText()
    if signNum == 1 then
        changeStatus = "in";
        changeTick = getTickCount();
        setTimer(function()
            signNum = signNum + 1;
            signText = tostring(signTexts[signNum][1])
            changeTick = getTickCount();
            changeStatus = "out";
        end, 400, 1)
    else
        changeStatus = "in";
        changeTick = getTickCount();
        setTimer(function()
            if signNum + 1 > #signTexts then
                signNum = 1;
                signText = tostring(signTexts[signNum][1])
            else
                signNum = signNum + 1;
                signText = tostring(signTexts[signNum][1])
            end
            signText = tostring(signTexts[signNum][1])
            changeTick = getTickCount();
            changeStatus = "out";
        end, 400, 1)
    end
end

setTimer(changeSignText, 2500, 0)

changeTick = getTickCount()
local headerFont = dxCreateFont("files/fonts/Roboto-BoldCondensed.ttf", 100, false, "antialiased")
local thinFont = dxCreateFont("files/fonts/Roboto-Thin.ttf", 100, false, "antialiased")
function render()
	if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), 1150.3505859375, -1338.263671875, 494.86477661133) < 15 then
		dxSetRenderTarget(boardTarget, true)
			local nowTick = getTickCount()
			local elapsedTime = nowTick - changeTick
			local duration = elapsedTime / 5000
			a = interpolateBetween(0, 0, 0, 255, 0, 0, nowTick/5000, "SineCurve")
			a2 = interpolateBetween(255, 0, 0, 0, 0, 0, nowTick/5000, "SineCurve")
			a4 = interpolateBetween(255, 0, 0, 0, 0, 0, nowTick/5000, "SineCurve")
			
			if changeStatus == "in" then
				a3 = interpolateBetween(255, 0, 0, 0, 0, 0, (nowTick - changeTick) / 500, "Linear")
			else
				a3 = interpolateBetween(0, 0, 0, 255, 0, 0, (nowTick - changeTick) / 500, "Linear")
			end

			dxDrawImage(0, 0, boardWidth, boardHeight, "files/bg/bg1.jpg", 0, 0, 0, tocolor(255, 255, 255, a))
			dxDrawImage(0, 0, boardWidth, boardHeight, "files/bg/bg2.jpg", 0, 0, 0, tocolor(255, 255, 255, a2))
			dxDrawImage(0, 0, boardWidth, boardHeight, "files/bg/bg3.jpg", 0, 0, 0, tocolor(255, 255, 255, a4))

			dxDrawText("alpha", 0 - dxGetTextWidth("alpha", 1, thinFont), 0, boardWidth, boardHeight, tocolor(210, 160, 110, 255), 1, thinFont, "center", "center")
			dxDrawText(signText, 0 + dxGetTextWidth(signText, 1, headerFont, true), 0, boardWidth, boardHeight, tocolor(255, 255, 255, a3), 1, headerFont, "center", "center", false, false, false, true)	
		dxSetRenderTarget()
	end
end
addEventHandler("onClientRender", root, render)]]--

--[[local webBrowser = createBrowser(boardWidth, boardHeight, false, false)
--local webBrowser = createBrowser(sx, sy, false, false)
	
function webBrowserRender()
	dxSetRenderTarget(boardTarget, true)
		dxDrawImage(0, 0, boardWidth, boardHeight, webBrowser, 0, 0, 0, tocolor(255,255,255,255), false)
	dxSetRenderTarget()
end

local url = "Snjh4rZQ3Fc"

addEventHandler("onClientBrowserCreated", webBrowser, 
	function()
		loadBrowserURL(webBrowser, "https://www.youtube.com/embed/" .. url .. "?autoplay=1")
		addEventHandler("onClientRender", root, webBrowserRender)	
	end
)]]--