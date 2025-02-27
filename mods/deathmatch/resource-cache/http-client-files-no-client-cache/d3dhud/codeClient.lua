local sX, sY = guiGetScreenSize()

function reMap(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local responsiveMultipler = reMap(sX, 720, 1920, 0.75, 1)

function resp(num)
    return num * responsiveMultipler
end

function respc(num)
    return math.ceil(num * responsiveMultipler)
end

local sizeX, sizeY = respc(100), respc(200)

local bebasLight15 = dxCreateFont("files/fonts/BebasNeue-Light.ttf", respc(25), false, "cleartype")
local bebasBold15 = dxCreateFont("files/fonts/BebasNeue-Bold.ttf", respc(25), false, "cleartype")
local bebasRegular15 = dxCreateFont("files/fonts/BebasNeue-Regular.ttf", respc(25), false, "cleartype")

hudRenderTarget = dxCreateRenderTarget(sizeX, sizeY, true)

function renderLogin()
    dxSetRenderTarget(hudRenderTarget, true)
        local x, y, z = getElementPosition(localPlayer)
        if x and y and z then
            dxDrawRectangle(0, 0, sizeX, sizeY, tocolor(255, 255, 255, 255 * 0.8))
            dxDrawText("X", 0, 0)
            dxDrawText("X", 0 + sizeX, 0)
            dxDrawText("X", 0 + sizeX, 0 + sizeY)
        end
    dxSetRenderTarget()

    if hudRenderTarget then
        x, y, z, ox, oy, oz, x2, y2, z2 = getPositionFromElementOffset(1.3, -0.4, -1.5, -10)
        dxDrawMaterialLine3D(x2, y2, z2, x, y, z, hudRenderTarget, 1, tocolor(255, 255, 255, 255), ox, oy, oz)
    end
end
--addEventHandler("onClientRender", root, renderLogin)

function getPositionFromElementOffset(offX,offY,offX2,offY2)
	local offZ = -0.5
	local m = getElementMatrix ( localPlayer )  -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	
	local x2 = offX2 * m[1][1] + offY2 * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y2 = offX2 * m[1][2] + offY2 * m[2][2] + offZ * m[3][2] + m[4][2]
	local z2 = offX2 * m[1][3] + offY2 * m[2][3] + offZ * m[3][3] + m[4][3]
	
	offZ = 0.5
	local x3 = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y3 = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z3 = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	
	return x, y, z, x2, y2, z2, x3, y3, z3                            -- Return the transformed point
end