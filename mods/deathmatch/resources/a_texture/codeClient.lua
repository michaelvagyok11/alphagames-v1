local shaders = {}
function applyShader(texture, img)
	this = #shaders + 1
	shaders[this] = {}
	shaders[this][1] = dxCreateShader ( "files/fx/texturechanger.fx" )
	shaders[this][2] = dxCreateTexture ( img )
	if shaders[this][1] and shaders[this][2] then
		dxSetShaderValue ( shaders[this][1], "gTexture", shaders[this][2] )
		if shaders[this][1] then
			engineApplyShaderToWorldTexture ( shaders[this][1], texture )
		end
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	applyShader("big_cock", "files/img/big_cock.png")
	applyShader("BINC_hooded", "files/img/BINC_hooded.png")
	applyShader("bobobillboard1", "files/bobobillboard1.png")
	applyShader("homies_1", "files/homies_1.png")
	applyShader("cokopops_2", "files/cokopops_2.png")
end)
