local screenX, screenY = guiGetScreenSize()

local shaderRaw = [[
    #include "files/mta-helper.fx"
    texture secondRTX < string renderTarget = "yes"; >; texture secondRTY < string renderTarget = "yes"; >; texture Tex0; sampler Sampler0 = sampler_state { Texture = (Tex0); }; sampler Sampler1 = sampler_state { Texture = (gTexture1); }; struct VSInput { float3 Position : POSITION0; float3 Normal : NORMAL0; float4 Diffuse : COLOR0; float2 TexCoord : TEXCOORD0; float3 TexCoord1 : TEXCOORD1; }; struct PSInput { float4 Position : POSITION0; float4 Diffuse : COLOR0; float2 TexCoord : TEXCOORD0; float3 Specular : COLOR1; float3 TexCoord1 : TEXCOORD1; }; float4 gLight1Specular < string lightState="1,Specular"; >; int gStage1ColorOp < string stageState="1,COLOROP"; >; float4 gTextureFactor < string renderState="TEXTUREFACTOR"; >; float4 CalcVehDiff( float3 WorldNormal, float4 InDiffuse ) { float4 ambient = gAmbientMaterialSource == 0 ? gMaterialAmbient : InDiffuse; float4 diffuse = gDiffuseMaterialSource == 0 ? gMaterialDiffuse : InDiffuse; float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse; float4 TotalAmbient = ambient * ( gGlobalAmbient + gLightAmbient ); float DirectionFactor = 0; DirectionFactor += max(0,dot(WorldNormal, -float3(0.5773502691896258, 0.5773502691896258, -0.5773502691896258) )); DirectionFactor += max(0,dot(WorldNormal, -float3(0.5773502691896258, -0.5773502691896258, -0.5773502691896258) )); DirectionFactor += max(0,dot(WorldNormal, -float3(-0.5773502691896258, -0.5773502691896258, -0.5773502691896258) )); DirectionFactor += max(0,dot(WorldNormal, -float3(-0.5773502691896258, 0.5773502691896258, -0.5773502691896258) )); DirectionFactor /= 4; float4 TotalDiffuse = ( diffuse * gLightDiffuse * DirectionFactor * 1.25 ); float4 OutDiffuse = saturate(TotalDiffuse + TotalAmbient + emissive); OutDiffuse.a *= diffuse.a; return OutDiffuse; } PSInput VertexShaderFunction(VSInput VS) { PSInput PS = (PSInput)0; PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection); PS.TexCoord = VS.TexCoord; float3 WorldNormal = MTACalcWorldNormal( VS.Normal ); PS.Diffuse = CalcVehDiff( WorldNormal, VS.Diffuse ); if (gStage1ColorOp == 25) { float3 ViewNormal = mul(VS.Normal, (float3x3)gWorldView); ViewNormal = normalize(ViewNormal); PS.TexCoord1 = ViewNormal.xyz; } else if (gStage1ColorOp == 14) { PS.TexCoord1 = float3(VS.TexCoord1.xy, 1); } else { PS.TexCoord1 = 0; } PS.Specular.rgb = gMaterialSpecular.rgb * MTACalculateSpecular(gCameraDirection, gLightDirection, VS.Normal, min(127, gMaterialSpecPower)) * gLight1Specular.rgb; return PS; } struct Pixel { float4 Color : COLOR0; float4 ExtraX : COLOR1; float4 ExtraY : COLOR2; }; Pixel PixelShaderFunction(PSInput PS) { Pixel output; output.Color = tex2D(Sampler0, PS.TexCoord) * PS.Diffuse; if (gStage1ColorOp == 14) { float4 envTexel = tex2D(Sampler1, PS.TexCoord1.xy); output.Color.rgb = output.Color.rgb * (1 - gTextureFactor.a) + envTexel.rgb * gTextureFactor.a; } if (gStage1ColorOp == 25) { float4 sphTexel = tex2D(Sampler1, PS.TexCoord1.xy/PS.TexCoord1.z); output.Color.rgb += sphTexel.rgb * gTextureFactor.r; } if (gMaterialSpecPower != 0) output.Color.rgb += PS.Specular.rgb; output.ExtraX = float4( min(1, PS.TexCoord[0]*3), min(1, max(0, PS.TexCoord[0]*3-1)), max(0, PS.TexCoord[0]*3-2), 1 ); output.ExtraY = float4( min(1, PS.TexCoord[1]*3), min(1, max(0, PS.TexCoord[1]*3-1)), max(0, PS.TexCoord[1]*3-2), 1 ); return output; } technique tec { pass P0 { VertexShader = compile vs_2_0 VertexShaderFunction(); PixelShader = compile ps_2_0 PixelShaderFunction(); } } ]]    

local editorState = false
local shader = false
local renderTarget = false
local renderTargetX = false
local renderTargetY = false
local uvX, uvY, uvR
local ts = 1024

local decals = {}
local colorSchemes = exports.am_gui:getColorSchemes()

local veh = false
local minX, minY, minZ, maxX, maxY, maxZ
local vehColor = {255, 255, 255}

local pih = math.pi/2

local camX, camY = 2, 0
local camZoom = 1.7
local camCursor = false

local cx, cy = false, false

local editor = false
local toolbar = false
local layerSelector = false
local layerSelectorContent = false
local layersFooter = false
local footerLabel = false

local decalsToLoad = 0
local decalLoadQueue = false
function loadDecalFinal(cat, name, colorable)
	if not decalContainer[cat] then
		decalContainer[cat] = {}
	end
	table.insert(decalContainer[cat], {name .. ".dds"})
	decals[cat .. "/" .. name] = {
		{
			"files/decals/32/" .. cat .. "/" .. name .. ".dds",
			"files/decals/64/" .. cat .. "/" .. name .. ".dds",
			"files/decals/128/" .. cat .. "/" .. name .. ".dds",
			"files/decals/256/" .. cat .. "/" .. name .. ".dds"
		},
		256,
		256,
		colorable,
		cat
	}
end
function loadDecal(cat, name)
	if not decalLoadQueue then
		decalLoadQueue = {}
		decalsToLoad = 0
	end
	colorable = true--not colorCategories[cat]
	if not decalContainer[cat .. "/" .. name] then
		table.insert(decalLoadQueue, {
			cat,
			name,
			colorable
		})
		decalsToLoad = decalsToLoad + 1
	end
end
local categoryNames = {
	["1shapes"] = "Formák",
	gradients = "Átmenetek",
	grunge = "Piszok",
	splashpaint = "Festék",
	textures = "Textúrák",
	mintazatok = "Mintázatok",
	pinstripe = "Pinstripe minták",
	tribal = "Tribal minták",
	animals = "Állatok",
	skull = "Koponya",
	flames = "Lángok",
	racing = "Motorsport",
	flags = "Zászlók",
	stickers = "Matricák",
	stickers2 = "Matricák",
	aftermarket = "Logók",
	aftermarket2 = "Logók",
	manufacturer = "Autómárkák",
	manufacturer2 = "Autómárkák"
}
function loadTheDecals()
	decalLoadQueue = {}
	decalsToLoad = 0
	loadDecal("1shapes", "0")
	loadDecal("1shapes", "1")
	loadDecal("1shapes", "2")
	loadDecal("1shapes", "2a")
	loadDecal("1shapes", "3")
	loadDecal("1shapes", "4")
	loadDecal("1shapes", "4a")
	loadDecal("1shapes", "5")
	loadDecal("1shapes", "6")
	loadDecal("1shapes", "7")
	loadDecal("1shapes", "8")
	loadDecal("1shapes", "8a")
	loadDecal("1shapes", "8b")
	loadDecal("1shapes", "9")
	loadDecal("1shapes", "9a")
	loadDecal("1shapes", "9b")
	loadDecal("1shapes", "10")
	loadDecal("1shapes", "11")
	loadDecal("1shapes", "11a")
	loadDecal("1shapes", "11a1")
	loadDecal("1shapes", "11b")
	loadDecal("1shapes", "12")
	loadDecal("1shapes", "12a")
	loadDecal("1shapes", "12b")
	loadDecal("1shapes", "12c")
	loadDecal("1shapes", "12c1")
	loadDecal("1shapes", "12c2")
	loadDecal("1shapes", "12d")
	loadDecal("1shapes", "12e")
	loadDecal("1shapes", "13")
	loadDecal("1shapes", "13a")
	loadDecal("1shapes", "14")
	loadDecal("1shapes", "14a")
	loadDecal("1shapes", "14a1")
	loadDecal("1shapes", "15")
	loadDecal("1shapes", "15a")
	loadDecal("1shapes", "15b")
	loadDecal("1shapes", "16")
	loadDecal("1shapes", "16a")
	loadDecal("1shapes", "16b")
	loadDecal("1shapes", "16c")
	loadDecal("1shapes", "17")
	loadDecal("1shapes", "17a")
	loadDecal("1shapes", "18")
	loadDecal("1shapes", "18a")
	loadDecal("1shapes", "19")
	loadDecal("1shapes", "20")
	loadDecal("1shapes", "21")
	loadDecal("1shapes", "21a")
	loadDecal("1shapes", "22")
	loadDecal("1shapes", "22a")
	loadDecal("1shapes", "22b")
	loadDecal("1shapes", "23")
	loadDecal("1shapes", "24")
	loadDecal("1shapes", "25")
	loadDecal("1shapes", "26")
	loadDecal("1shapes", "26a")
	loadDecal("1shapes", "26b")
	loadDecal("1shapes", "26c")
	loadDecal("1shapes", "26d")
	loadDecal("1shapes", "26e")
	loadDecal("1shapes", "26f")
	loadDecal("1shapes", "27")
	loadDecal("1shapes", "28")
	loadDecal("1shapes", "29")
	loadDecal("1shapes", "x4")
	loadDecal("1shapes", "x4a")
	loadDecal("1shapes", "x5")
	loadDecal("1shapes", "x6")
	loadDecal("1shapes", "x7")
	loadDecal("1shapes", "x8")
	loadDecal("1shapes", "y")
	loadDecal("1shapes", "y0")
	loadDecal("1shapes", "y0a")
	loadDecal("1shapes", "y1")
	loadDecal("1shapes", "y2")
	loadDecal("1shapes", "y2a")
	loadDecal("1shapes", "Y3")
	loadDecal("1shapes", "y4")
	loadDecal("1shapes", "y5")
	loadDecal("1shapes", "y6")
	loadDecal("1shapes", "y7")
	loadDecal("1shapes", "y8")
	loadDecal("1shapes", "y9")
	loadDecal("1shapes", "y10")
	loadDecal("aftermarket", "5zigen")
	loadDecal("aftermarket", "aem")
	loadDecal("aftermarket", "akra")
	loadDecal("aftermarket", "alpine")
	loadDecal("aftermarket", "alpinestars")
	loadDecal("aftermarket", "apex")
	loadDecal("aftermarket", "apracing")
	loadDecal("aftermarket", "bbs")
	loadDecal("aftermarket", "bf")
	loadDecal("aftermarket", "blitz")
	loadDecal("aftermarket", "borla")
	loadDecal("aftermarket", "bosch")
	loadDecal("aftermarket", "brembo")
	loadDecal("aftermarket", "brembo1")
	loadDecal("aftermarket", "bride")
	loadDecal("aftermarket", "bridgestone")
	loadDecal("aftermarket", "castr")
	loadDecal("aftermarket", "continental")
	loadDecal("aftermarket", "cwest")
	loadDecal("aftermarket", "dunlop")
	loadDecal("aftermarket", "edelb")
	loadDecal("aftermarket", "eibach")
	loadDecal("aftermarket", "endless")
	loadDecal("aftermarket", "enkei")
	loadDecal("aftermarket", "falken")
	loadDecal("aftermarket", "fifteen")
	loadDecal("aftermarket", "firestone")
	loadDecal("aftermarket", "garrett")
	loadDecal("aftermarket", "goody")
	loadDecal("aftermarket", "greddy")
	loadDecal("aftermarket", "hankook")
	loadDecal("aftermarket", "hella")
	loadDecal("aftermarket", "hks")
	loadDecal("aftermarket", "holley")
	loadDecal("aftermarket", "hoosier")
	loadDecal("aftermarket", "import")
	loadDecal("aftermarket", "kenwood")
	loadDecal("aftermarket", "kn")
	loadDecal("aftermarket", "koni")
	loadDecal("aftermarket", "konig")
	loadDecal("aftermarket", "kw")
	loadDecal("aftermarket", "magna")
	loadDecal("aftermarket", "michelin")
	loadDecal("aftermarket", "momo")
	loadDecal("aftermarket", "motec")
	loadDecal("aftermarket", "motul")
	loadDecal("aftermarket", "ngk")
	loadDecal("aftermarket", "nitto")
	loadDecal("aftermarket", "nos")
	loadDecal("aftermarket", "nx")
	loadDecal("aftermarket", "oz")
	loadDecal("aftermarket", "pirelli")
	loadDecal("aftermarket", "rays")
	loadDecal("aftermarket", "recaro")
	loadDecal("aftermarket", "recaro2")
	loadDecal("aftermarket", "remus")
	loadDecal("aftermarket", "ronal")
	loadDecal("aftermarket", "sparco")
	loadDecal("aftermarket", "sparco2")
	loadDecal("aftermarket", "speedh")
	loadDecal("aftermarket", "sultan")
	loadDecal("aftermarket", "takata")
	loadDecal("aftermarket", "tein")
	loadDecal("aftermarket", "tenzo")
	loadDecal("aftermarket", "toyo")
	loadDecal("aftermarket", "veilside")
	loadDecal("aftermarket", "wilwood")
	loadDecal("aftermarket", "work")
	loadDecal("aftermarket", "x")
	loadDecal("aftermarket", "x2")
	loadDecal("aftermarket", "yokohama")
	loadDecal("aftermarket2", "5zigen")
	loadDecal("aftermarket2", "76")
	loadDecal("aftermarket2", "advan")
	loadDecal("aftermarket2", "advan2")
	loadDecal("aftermarket2", "akra")
	loadDecal("aftermarket2", "alpines")
	loadDecal("aftermarket2", "alpines1")
	loadDecal("aftermarket2", "am")
	loadDecal("aftermarket2", "apexi")
	loadDecal("aftermarket2", "apracing")
	loadDecal("aftermarket2", "bbs")
	loadDecal("aftermarket2", "bf")
	loadDecal("aftermarket2", "borla")
	loadDecal("aftermarket2", "bosch")
	loadDecal("aftermarket2", "brembo")
	loadDecal("aftermarket2", "bridgestone")
	loadDecal("aftermarket2", "bridgestone2")
	loadDecal("aftermarket2", "castr")
	loadDecal("aftermarket2", "champion")
	loadDecal("aftermarket2", "chevron")
	loadDecal("aftermarket2", "conti")
	loadDecal("aftermarket2", "dunlop")
	loadDecal("aftermarket2", "edelb2")
	loadDecal("aftermarket2", "eibach")
	loadDecal("aftermarket2", "falken")
	loadDecal("aftermarket2", "flowmasters")
	loadDecal("aftermarket2", "goody")
	loadDecal("aftermarket2", "goodyear")
	loadDecal("aftermarket2", "greddy")
	loadDecal("aftermarket2", "greddy1")
	loadDecal("aftermarket2", "gulf")
	loadDecal("aftermarket2", "hankook")
	loadDecal("aftermarket2", "hella")
	loadDecal("aftermarket2", "hks")
	loadDecal("aftermarket2", "hks2")
	loadDecal("aftermarket2", "hks3")
	loadDecal("aftermarket2", "hks4")
	loadDecal("aftermarket2", "holley")
	loadDecal("aftermarket2", "hoo")
	loadDecal("aftermarket2", "hotw")
	loadDecal("aftermarket2", "japanracing")
	loadDecal("aftermarket2", "kenwood")
	loadDecal("aftermarket2", "kn")
	loadDecal("aftermarket2", "koni")
	loadDecal("aftermarket2", "kw")
	loadDecal("aftermarket2", "martini")
	loadDecal("aftermarket2", "martini1")
	loadDecal("aftermarket2", "martini2")
	loadDecal("aftermarket2", "michelin")
	loadDecal("aftermarket2", "momo")
	loadDecal("aftermarket2", "monster")
	loadDecal("aftermarket2", "motul")
	loadDecal("aftermarket2", "ngk")
	loadDecal("aftermarket2", "nitto")
	loadDecal("aftermarket2", "nx")
	loadDecal("aftermarket2", "oz")
	loadDecal("aftermarket2", "penzoil")
	loadDecal("aftermarket2", "redb")
	loadDecal("aftermarket2", "roush")
	loadDecal("aftermarket2", "shell")
	loadDecal("aftermarket2", "subw")
	loadDecal("aftermarket2", "texaco")
	loadDecal("aftermarket2", "valvoline")
	loadDecal("aftermarket2", "volk")
	loadDecal("aftermarket2", "wilwood")
	loadDecal("aftermarket2", "yokohama")
	loadDecal("aftermarket2", "yokohama2")
	loadDecal("animals", "animal00")
	loadDecal("animals", "animal01")
	loadDecal("animals", "animal02")
	loadDecal("animals", "animal03")
	loadDecal("animals", "animal04")
	loadDecal("animals", "animal05")
	loadDecal("animals", "animal06")
	loadDecal("animals", "animal07")
	loadDecal("animals", "animal08")
	loadDecal("animals", "animal09")
	loadDecal("animals", "animal10")
	loadDecal("animals", "animal11")
	loadDecal("animals", "animal12")
	loadDecal("animals", "animal13")
	loadDecal("animals", "animal14")
	loadDecal("animals", "animal15")
	loadDecal("animals", "animal16")
	loadDecal("animals", "animal17")
	loadDecal("animals", "animal18")
	loadDecal("animals", "animal19")
	loadDecal("animals", "animal20")
	loadDecal("animals", "animal21")
	loadDecal("flags", "australia")
	loadDecal("flags", "austria")
	loadDecal("flags", "canada")
	loadDecal("flags", "croatia")
	loadDecal("flags", "france")
	loadDecal("flags", "germany")
	loadDecal("flags", "hungary")
	loadDecal("flags", "italy")
	loadDecal("flags", "japan")
	loadDecal("flags", "mexico")
	loadDecal("flags", "netherlands")
	loadDecal("flags", "romania")
	loadDecal("flags", "russia")
	loadDecal("flags", "serbia")
	loadDecal("flags", "slovakia")
	loadDecal("flags", "slovenia")
	loadDecal("flags", "spain")
	loadDecal("flags", "uk")
	loadDecal("flags", "ukraine")
	loadDecal("flags", "usa")
	loadDecal("flames", "flame01")
	loadDecal("flames", "flame02")
	loadDecal("flames", "flame03")
	loadDecal("flames", "flame04")
	loadDecal("flames", "flame05")
	loadDecal("flames", "flame06")
	loadDecal("flames", "flame07")
	loadDecal("flames", "flame08")
	loadDecal("flames", "flame09")
	loadDecal("flames", "flame10")
	loadDecal("flames", "flame11")
	loadDecal("flames", "flame12")
	loadDecal("flames", "flame13")
	loadDecal("flames", "flame14")
	loadDecal("flames", "flame15")
	loadDecal("flames", "flame16")
	loadDecal("flames", "flame17")
	loadDecal("flames", "flame18")
	loadDecal("flames", "flame19")
	loadDecal("flames", "flame20")
	loadDecal("flames", "flame21")
	loadDecal("flames", "flame22")
	loadDecal("flames", "flame23")
	loadDecal("flames", "flame24")
	loadDecal("flames", "flame25")
	loadDecal("flames", "flame26")
	loadDecal("flames", "flame27")
	loadDecal("flames", "flame28")
	loadDecal("flames", "flame29")
	loadDecal("flames", "flame30")
	loadDecal("flames", "flame31")
	loadDecal("flames", "flame32")
	loadDecal("flames", "flame33")
	loadDecal("flames", "flame34")
	loadDecal("flames", "flame35")
	loadDecal("flames", "flame36")
	loadDecal("flames", "flame37")
	loadDecal("flames", "flame38")
	loadDecal("flames", "flame39")
	loadDecal("flames", "flame40")
	loadDecal("flames", "flame41")
	loadDecal("flames", "flame42")
	loadDecal("flames", "flame43")
	loadDecal("flames", "flame44")
	loadDecal("flames", "flame45")
	loadDecal("flames", "flame46")
	loadDecal("flames", "flame47")
	loadDecal("flames", "flame48")
	loadDecal("flames", "flame49")
	loadDecal("flames", "flame50")
	loadDecal("flames", "flame51")
	loadDecal("gradients", "1")
	loadDecal("gradients", "1a")
	loadDecal("gradients", "1b")
	loadDecal("gradients", "1c")
	loadDecal("gradients", "2")
	loadDecal("gradients", "2a")
	loadDecal("gradients", "2a1")
	loadDecal("gradients", "2b")
	loadDecal("gradients", "2c")
	loadDecal("gradients", "3")
	loadDecal("gradients", "4")
	loadDecal("gradients", "5")
	loadDecal("gradients", "6")
	loadDecal("gradients", "7")
	loadDecal("gradients", "8")
	loadDecal("gradients", "8a")
	loadDecal("gradients", "9")
	loadDecal("gradients", "9a")
	loadDecal("gradients", "9a1")
	loadDecal("gradients", "9b")
	loadDecal("gradients", "9c")
	loadDecal("gradients", "9c1")
	loadDecal("gradients", "9d")
	loadDecal("gradients", "9e")
	loadDecal("gradients", "10")
	loadDecal("gradients", "11")
	loadDecal("gradients", "11a")
	loadDecal("gradients", "11b")
	loadDecal("gradients", "11b1")
	loadDecal("gradients", "11b2")
	loadDecal("gradients", "11c")
	loadDecal("gradients", "12")
	loadDecal("gradients", "12a")
	loadDecal("gradients", "13")
	loadDecal("gradients", "14")
	loadDecal("gradients", "14a")
	loadDecal("gradients", "15")
	loadDecal("gradients", "15a")
	loadDecal("gradients", "15b")
	loadDecal("gradients", "15c")
	loadDecal("gradients", "16")
	loadDecal("gradients", "16a")
	loadDecal("gradients", "16a1")
	loadDecal("gradients", "16b")
	loadDecal("gradients", "16c")
	loadDecal("gradients", "16d")
	loadDecal("gradients", "17")
	loadDecal("gradients", "y2")
	loadDecal("gradients", "y2a1")
	loadDecal("gradients", "y2a2")
	loadDecal("grunge", "0")
	loadDecal("grunge", "0a")
	loadDecal("grunge", "0a1")
	loadDecal("grunge", "1")
	loadDecal("grunge", "2")
	loadDecal("grunge", "3")
	loadDecal("grunge", "3a")
	loadDecal("grunge", "3b")
	loadDecal("grunge", "3c")
	loadDecal("grunge", "4")
	loadDecal("grunge", "4a")
	loadDecal("grunge", "5")
	loadDecal("grunge", "6")
	loadDecal("grunge", "7")
	loadDecal("grunge", "8")
	loadDecal("grunge", "9")
	loadDecal("grunge", "10")
	loadDecal("grunge", "11")
	loadDecal("grunge", "12")
	loadDecal("grunge", "13")
	loadDecal("grunge", "14")
	loadDecal("grunge", "15")
	loadDecal("grunge", "15a")
	loadDecal("grunge", "16")
	loadDecal("grunge", "17")
	loadDecal("grunge", "17a")
	loadDecal("grunge", "17a1")
	loadDecal("grunge", "17a2")
	loadDecal("grunge", "18")
	loadDecal("grunge", "18a")
	loadDecal("grunge", "18a1")
	loadDecal("grunge", "18b")
	loadDecal("grunge", "19")
	loadDecal("grunge", "20")
	loadDecal("grunge", "21")
	loadDecal("grunge", "21a")
	loadDecal("grunge", "22")
	loadDecal("grunge", "22a")
	loadDecal("grunge", "23")
	loadDecal("grunge", "24")
	loadDecal("grunge", "25")
	loadDecal("grunge", "26")
	loadDecal("grunge", "27")
	loadDecal("grunge", "28")
	loadDecal("grunge", "29")
	loadDecal("grunge", "30")
	loadDecal("grunge", "31")
	loadDecal("grunge", "32")
	loadDecal("grunge", "33")
	loadDecal("grunge", "34")
	loadDecal("grunge", "35")
	loadDecal("grunge", "36")
	loadDecal("grunge", "37")
	loadDecal("grunge", "38")
	loadDecal("manufacturer", "a_quattro")
	loadDecal("manufacturer", "a_rs4")
	loadDecal("manufacturer", "a_rs6")
	loadDecal("manufacturer", "a_sport")
	loadDecal("manufacturer", "alpina")
	loadDecal("manufacturer", "audi")
	loadDecal("manufacturer", "audi1")
	loadDecal("manufacturer", "audi2")
	loadDecal("manufacturer", "audi3")
	loadDecal("manufacturer", "chevy")
	loadDecal("manufacturer", "chevy2")
	loadDecal("manufacturer", "chevy3")
	loadDecal("manufacturer", "chevy4")
	loadDecal("manufacturer", "chevy5")
	loadDecal("manufacturer", "dodge")
	loadDecal("manufacturer", "dodge1")
	loadDecal("manufacturer", "ferrari")
	loadDecal("manufacturer", "firebird")
	loadDecal("manufacturer", "ford")
	loadDecal("manufacturer", "fordmustanggt")
	loadDecal("manufacturer", "fordold")
	loadDecal("manufacturer", "fordraptor")
	loadDecal("manufacturer", "gti")
	loadDecal("manufacturer", "hemi")
	loadDecal("manufacturer", "honda")
	loadDecal("manufacturer", "honda1")
	loadDecal("manufacturer", "honda1mugen")
	loadDecal("manufacturer", "jeep")
	loadDecal("manufacturer", "jeep1")
	loadDecal("manufacturer", "lada")
	loadDecal("manufacturer", "lambo")
	loadDecal("manufacturer", "mercedes")
	loadDecal("manufacturer", "mercedesamg")
	loadDecal("manufacturer", "mitsu_ralliart")
	loadDecal("manufacturer", "mitsu")
	loadDecal("manufacturer", "mitsu1")
	loadDecal("manufacturer", "mopar")
	loadDecal("manufacturer", "nismo")
	loadDecal("manufacturer", "nismo2")
	loadDecal("manufacturer", "nissan")
	loadDecal("manufacturer", "nissan1")
	loadDecal("manufacturer", "nissanmines")
	loadDecal("manufacturer", "pontiac")
	loadDecal("manufacturer", "porsche")
	loadDecal("manufacturer", "porsche1")
	loadDecal("manufacturer", "raptor")
	loadDecal("manufacturer", "raptor1")
	loadDecal("manufacturer", "rt")
	loadDecal("manufacturer", "shelby")
	loadDecal("manufacturer", "shelby1")
	loadDecal("manufacturer", "silverado")
	loadDecal("manufacturer", "skoda")
	loadDecal("manufacturer", "skoda2")
	loadDecal("manufacturer", "skoda2vrs")
	loadDecal("manufacturer", "srt")
	loadDecal("manufacturer", "subaru")
	loadDecal("manufacturer", "subarusti")
	loadDecal("manufacturer", "toyo")
	loadDecal("manufacturer", "trd")
	loadDecal("manufacturer", "vw")
	loadDecal("manufacturer", "vw2")
	loadDecal("manufacturer", "vw2a")
	loadDecal("manufacturer", "vw3")
	loadDecal("manufacturer", "vw4")
	loadDecal("manufacturer2", "alfa")
	loadDecal("manufacturer2", "amc")
	loadDecal("manufacturer2", "amg")
	loadDecal("manufacturer2", "ariel")
	loadDecal("manufacturer2", "audi")
	loadDecal("manufacturer2", "audi2")
	loadDecal("manufacturer2", "audi3")
	loadDecal("manufacturer2", "bmw")
	loadDecal("manufacturer2", "bmw1")
	loadDecal("manufacturer2", "bmw2")
	loadDecal("manufacturer2", "bmw3")
	loadDecal("manufacturer2", "bmw4")
	loadDecal("manufacturer2", "bmw5")
	loadDecal("manufacturer2", "bmw6")
	loadDecal("manufacturer2", "bmw7")
	loadDecal("manufacturer2", "bmw8")
	loadDecal("manufacturer2", "bmw9")
	loadDecal("manufacturer2", "bmwm")
	loadDecal("manufacturer2", "bmwm2")
	loadDecal("manufacturer2", "bmwm3")
	loadDecal("manufacturer2", "bmwm4")
	loadDecal("manufacturer2", "bugatti")
	loadDecal("manufacturer2", "cadi")
	loadDecal("manufacturer2", "chevy")
	loadDecal("manufacturer2", "chevy0")
	loadDecal("manufacturer2", "chevy1")
	loadDecal("manufacturer2", "chevy1a")
	loadDecal("manufacturer2", "chevy2")
	loadDecal("manufacturer2", "dodge")
	loadDecal("manufacturer2", "dodge1")
	loadDecal("manufacturer2", "ducati")
	loadDecal("manufacturer2", "ferrari")
	loadDecal("manufacturer2", "ferrari1")
	loadDecal("manufacturer2", "firebird")
	loadDecal("manufacturer2", "ford")
	loadDecal("manufacturer2", "ford1")
	loadDecal("manufacturer2", "ford2")
	loadDecal("manufacturer2", "gmc")
	loadDecal("manufacturer2", "honda")
	loadDecal("manufacturer2", "hum")
	loadDecal("manufacturer2", "jeep")
	loadDecal("manufacturer2", "lada")
	loadDecal("manufacturer2", "lambo")
	loadDecal("manufacturer2", "landrover")
	loadDecal("manufacturer2", "lincoln")
	loadDecal("manufacturer2", "mazda")
	loadDecal("manufacturer2", "mb")
	loadDecal("manufacturer2", "mclaren")
	loadDecal("manufacturer2", "mitsu_ralliart")
	loadDecal("manufacturer2", "mitsu_ralliart2")
	loadDecal("manufacturer2", "mitsu")
	loadDecal("manufacturer2", "mopar")
	loadDecal("manufacturer2", "mugen")
	loadDecal("manufacturer2", "nismo")
	loadDecal("manufacturer2", "nissan")
	loadDecal("manufacturer2", "nissanmines")
	loadDecal("manufacturer2", "nissanvspec")
	loadDecal("manufacturer2", "nissanvspec2")
	loadDecal("manufacturer2", "peu")
	loadDecal("manufacturer2", "plymouth")
	loadDecal("manufacturer2", "pontiac")
	loadDecal("manufacturer2", "porsche")
	loadDecal("manufacturer2", "porsche2")
	loadDecal("manufacturer2", "raptor")
	loadDecal("manufacturer2", "raptora")
	loadDecal("manufacturer2", "raptorx")
	loadDecal("manufacturer2", "seat")
	loadDecal("manufacturer2", "silverado")
	loadDecal("manufacturer2", "skodavrs")
	loadDecal("manufacturer2", "skodavrs2")
	loadDecal("manufacturer2", "suba")
	loadDecal("manufacturer2", "suzuki")
	loadDecal("manufacturer2", "toyota")
	loadDecal("manufacturer2", "toyotadenso")
	loadDecal("manufacturer2", "toyotatrd")
	loadDecal("manufacturer2", "toyotatrd1")
	loadDecal("manufacturer2", "transam")
	loadDecal("manufacturer2", "vw")
	loadDecal("manufacturer2", "vw2")
	loadDecal("manufacturer2", "vw3")
	loadDecal("mintazatok", "0")
	loadDecal("mintazatok", "0a")
	loadDecal("mintazatok", "1")
	loadDecal("mintazatok", "1a")
	loadDecal("mintazatok", "2")
	loadDecal("mintazatok", "3")
	loadDecal("mintazatok", "4")
	loadDecal("mintazatok", "x")
	loadDecal("mintazatok", "x1")
	loadDecal("mintazatok", "x1a")
	loadDecal("mintazatok", "x2")
	loadDecal("mintazatok", "x2a")
	loadDecal("mintazatok", "x2a1")
	loadDecal("mintazatok", "x2a2")
	loadDecal("mintazatok", "x2aa")
	loadDecal("mintazatok", "x2b")
	loadDecal("mintazatok", "x2c")
	loadDecal("mintazatok", "x2d")
	loadDecal("mintazatok", "x2e")
	loadDecal("mintazatok", "x3a")
	loadDecal("mintazatok", "y0")
	loadDecal("mintazatok", "y1")
	loadDecal("mintazatok", "y2")
	loadDecal("mintazatok", "y3")
	loadDecal("mintazatok", "y4")
	loadDecal("mintazatok", "y5")
	loadDecal("mintazatok", "y6")
	loadDecal("mintazatok", "y7")
	loadDecal("pinstripe", "1")
	loadDecal("pinstripe", "2")
	loadDecal("pinstripe", "3")
	loadDecal("pinstripe", "4")
	loadDecal("pinstripe", "5")
	loadDecal("pinstripe", "6")
	loadDecal("pinstripe", "7")
	loadDecal("pinstripe", "8")
	loadDecal("pinstripe", "9")
	loadDecal("pinstripe", "10")
	loadDecal("pinstripe", "11")
	loadDecal("pinstripe", "12")
	loadDecal("pinstripe", "13")
	loadDecal("pinstripe", "14")
	loadDecal("pinstripe", "15")
	loadDecal("pinstripe", "16")
	loadDecal("pinstripe", "17")
	loadDecal("pinstripe", "18")
	loadDecal("pinstripe", "19")
	loadDecal("pinstripe", "20")
	loadDecal("pinstripe", "21")
	loadDecal("pinstripe", "22")
	loadDecal("pinstripe", "23")
	loadDecal("pinstripe", "24")
	loadDecal("pinstripe", "25")
	loadDecal("pinstripe", "26")
	loadDecal("pinstripe", "27")
	loadDecal("pinstripe", "28")
	loadDecal("pinstripe", "29")
	loadDecal("pinstripe", "30")
	loadDecal("pinstripe", "31")
	loadDecal("pinstripe", "32")
	loadDecal("pinstripe", "33")
	loadDecal("pinstripe", "34")
	loadDecal("pinstripe", "35")
	loadDecal("pinstripe", "36")
	loadDecal("pinstripe", "37")
	loadDecal("pinstripe", "38")
	loadDecal("pinstripe", "39")
	loadDecal("pinstripe", "40")
	loadDecal("pinstripe", "41")
	loadDecal("pinstripe", "42")
	loadDecal("pinstripe", "43")
	loadDecal("pinstripe", "44")
	loadDecal("racing", "1")
	loadDecal("racing", "2")
	loadDecal("racing", "3")
	loadDecal("racing", "3a")
	loadDecal("racing", "4")
	loadDecal("racing", "4a")
	loadDecal("racing", "4b")
	loadDecal("racing", "4c")
	loadDecal("racing", "4d")
	loadDecal("racing", "4e")
	loadDecal("racing", "4g")
	loadDecal("racing", "4g1")
	loadDecal("racing", "5")
	loadDecal("racing", "5a")
	loadDecal("racing", "5b")
	loadDecal("racing", "5ba")
	loadDecal("racing", "5c")
	loadDecal("racing", "6a")
	loadDecal("racing", "6b")
	loadDecal("racing", "7")
	loadDecal("racing", "8")
	loadDecal("racing", "9")
	loadDecal("racing", "10")
	loadDecal("racing", "11")
	loadDecal("racing", "12")
	loadDecal("racing", "13")
	loadDecal("racing", "14")
	loadDecal("racing", "15")
	loadDecal("racing", "hood")
	loadDecal("racing", "hood2")
	loadDecal("racing", "side")
	loadDecal("racing", "side1")
	loadDecal("racing", "side3")
	loadDecal("racing", "t1")
	loadDecal("racing", "t2")
	loadDecal("racing", "t3")
	loadDecal("racing", "t4")
	loadDecal("racing", "t4a")
	loadDecal("racing", "t5")
	loadDecal("racing", "t6")
	loadDecal("racing", "t7")
	loadDecal("skull", "sk")
	loadDecal("skull", "sk1")
	loadDecal("skull", "skull01")
	loadDecal("skull", "skull02")
	loadDecal("skull", "skull03")
	loadDecal("skull", "skull04")
	loadDecal("skull", "skull05")
	loadDecal("skull", "skull06")
	loadDecal("skull", "skull07")
	loadDecal("skull", "skull08")
	loadDecal("skull", "skull09")
	loadDecal("skull", "skull10")
	loadDecal("skull", "skull11")
	loadDecal("skull", "skull12")
	loadDecal("skull", "skull13")
	loadDecal("skull", "skull14")
	loadDecal("skull", "skull15")
	loadDecal("skull", "skull16")
	loadDecal("skull", "skull17")
	loadDecal("skull", "skull18")
	loadDecal("skull", "skull19")
	loadDecal("skull", "skull20")
	loadDecal("skull", "skull21")
	loadDecal("skull", "skull22")
	loadDecal("skull", "skull23")
	loadDecal("skull", "skull24")
	loadDecal("splashpaint", "0")
	loadDecal("splashpaint", "0a")
	loadDecal("splashpaint", "0b")
	loadDecal("splashpaint", "0c")
	loadDecal("splashpaint", "1")
	loadDecal("splashpaint", "2")
	loadDecal("splashpaint", "3")
	loadDecal("splashpaint", "4")
	loadDecal("splashpaint", "5")
	loadDecal("splashpaint", "6")
	loadDecal("splashpaint", "7")
	loadDecal("splashpaint", "8")
	loadDecal("splashpaint", "8a")
	loadDecal("splashpaint", "8a1")
	loadDecal("splashpaint", "8b")
	loadDecal("splashpaint", "8c")
	loadDecal("splashpaint", "8c1")
	loadDecal("splashpaint", "9")
	loadDecal("splashpaint", "10")
	loadDecal("splashpaint", "11")
	loadDecal("splashpaint", "12")
	loadDecal("splashpaint", "13")
	loadDecal("splashpaint", "14")
	loadDecal("splashpaint", "15")
	loadDecal("splashpaint", "16")
	loadDecal("splashpaint", "16a")
	loadDecal("splashpaint", "16b")
	loadDecal("splashpaint", "16c")
	loadDecal("splashpaint", "16d")
	loadDecal("splashpaint", "16e")
	loadDecal("splashpaint", "16e1")
	loadDecal("splashpaint", "16e1a")
	loadDecal("splashpaint", "16e2")
	loadDecal("splashpaint", "17")
	loadDecal("splashpaint", "18")
	loadDecal("splashpaint", "19")
	loadDecal("splashpaint", "20")
	loadDecal("splashpaint", "21")
	loadDecal("splashpaint", "22")
	loadDecal("splashpaint", "23")
	loadDecal("splashpaint", "x")
	loadDecal("splashpaint", "x0")
	loadDecal("splashpaint", "x0a")
	loadDecal("splashpaint", "x1")
	loadDecal("stickers", "4x4")
	loadDecal("stickers", "4x42")
	loadDecal("stickers", "battlem")
	loadDecal("stickers", "beem")
	loadDecal("stickers", "blow")
	loadDecal("stickers", "bmw")
	loadDecal("stickers", "bomb")
	loadDecal("stickers", "bomb2")
	loadDecal("stickers", "bomb3")
	loadDecal("stickers", "boo")
	loadDecal("stickers", "built")
	loadDecal("stickers", "bullet")
	loadDecal("stickers", "call")
	loadDecal("stickers", "callservice")
	loadDecal("stickers", "crown")
	loadDecal("stickers", "daily")
	loadDecal("stickers", "dapper")
	loadDecal("stickers", "dc")
	loadDecal("stickers", "dekra")
	loadDecal("stickers", "dekra2")
	loadDecal("stickers", "diamond")
	loadDecal("stickers", "diesel")
	loadDecal("stickers", "diesel2")
	loadDecal("stickers", "domo")
	loadDecal("stickers", "domo1")
	loadDecal("stickers", "dope")
	loadDecal("stickers", "dope2")
	loadDecal("stickers", "dope3")
	loadDecal("stickers", "drift")
	loadDecal("stickers", "drift2")
	loadDecal("stickers", "drift3")
	loadDecal("stickers", "drift4")
	loadDecal("stickers", "drift5")
	loadDecal("stickers", "drift6")
	loadDecal("stickers", "drift7")
	loadDecal("stickers", "drift8")
	loadDecal("stickers", "driftking")
	loadDecal("stickers", "driftking2")
	loadDecal("stickers", "dtm")
	loadDecal("stickers", "dub")
	loadDecal("stickers", "dub2")
	loadDecal("stickers", "eat")
	loadDecal("stickers", "eat2")
	loadDecal("stickers", "eye")
	loadDecal("stickers", "eyes")
	loadDecal("stickers", "f1")
	loadDecal("stickers", "face")
	loadDecal("stickers", "fatl")
	loadDecal("stickers", "formuladrift")
	loadDecal("stickers", "fox")
	loadDecal("stickers", "gasmonkey")
	loadDecal("stickers", "gasmonkey1")
	loadDecal("stickers", "ghost")
	loadDecal("stickers", "grip")
	loadDecal("stickers", "groot")
	loadDecal("stickers", "gym")
	loadDecal("stickers", "haters")
	loadDecal("stickers", "hoon")
	loadDecal("stickers", "hoon2")
	loadDecal("stickers", "hoon3")
	loadDecal("stickers", "hot")
	loadDecal("stickers", "illest")
	loadDecal("stickers", "illest2")
	loadDecal("stickers", "illest3")
	loadDecal("stickers", "init")
	loadDecal("stickers", "initiald")
	loadDecal("stickers", "insta")
	loadDecal("stickers", "jag1")
	loadDecal("stickers", "jag2")
	loadDecal("stickers", "japan")
	loadDecal("stickers", "jdm")
	loadDecal("stickers", "jdm2")
	loadDecal("stickers", "jeep")
	loadDecal("stickers", "jeep2")
	loadDecal("stickers", "kazanish")
	loadDecal("stickers", "low")
	loadDecal("stickers", "low2")
	loadDecal("stickers", "low3")
	loadDecal("stickers", "lowlife")
	loadDecal("stickers", "madein")
	loadDecal("stickers", "mario")
	loadDecal("stickers", "mario2")
	loadDecal("stickers", "mario3")
	loadDecal("stickers", "med")
	loadDecal("stickers", "med2")
	loadDecal("stickers", "med3")
	loadDecal("stickers", "mil")
	loadDecal("stickers", "mil2")
	loadDecal("stickers", "monstel")
	loadDecal("stickers", "monster")
	loadDecal("stickers", "mountain")
	loadDecal("stickers", "nfs")
	loadDecal("stickers", "nofatc")
	loadDecal("stickers", "noisebomb")
	loadDecal("stickers", "noisebomb2")
	loadDecal("stickers", "nos")
	loadDecal("stickers", "nur")
	loadDecal("stickers", "pandem")
	loadDecal("stickers", "patesz")
	loadDecal("stickers", "pig")
	loadDecal("stickers", "racing")
	loadDecal("stickers", "rocket")
	loadDecal("stickers", "rocket2")
	loadDecal("stickers", "safetyc")
	loadDecal("stickers", "safetyc2")
	loadDecal("stickers", "sedan")
	loadDecal("stickers", "stance")
	loadDecal("stickers", "stance2")
	loadDecal("stickers", "stance3")
	loadDecal("stickers", "star")
	loadDecal("stickers", "star2")
	loadDecal("stickers", "star3")
	loadDecal("stickers", "static")
	loadDecal("stickers", "sticker5hp")
	loadDecal("stickers", "sticker10hp")
	loadDecal("stickers", "suba")
	loadDecal("stickers", "tuning")
	loadDecal("stickers", "tuning1")
	loadDecal("stickers", "turbo")
	loadDecal("stickers", "turbo1")
	loadDecal("stickers", "turbo2")
	loadDecal("stickers", "turbo3")
	loadDecal("stickers", "turbo4")
	loadDecal("stickers", "twitch")
	loadDecal("stickers", "x")
	loadDecal("stickers", "x0")
	loadDecal("stickers", "x1")
	loadDecal("stickers", "xbaby")
	loadDecal("stickers", "xbaby2")
	loadDecal("stickers", "yt")
	loadDecal("stickers2", "0")
	loadDecal("stickers2", "bear")
	loadDecal("stickers2", "bear2")
	loadDecal("stickers2", "bomb")
	loadDecal("stickers2", "built")
	loadDecal("stickers2", "carhub1")
	loadDecal("stickers2", "carhub2")
	loadDecal("stickers2", "crown")
	loadDecal("stickers2", "dc")
	loadDecal("stickers2", "dofi")
	loadDecal("stickers2", "domo")
	loadDecal("stickers2", "drift")
	loadDecal("stickers2", "driftmonkey")
	loadDecal("stickers2", "face")
	loadDecal("stickers2", "fdrift")
	loadDecal("stickers2", "fuelcap")
	loadDecal("stickers2", "fuelcap2")
	loadDecal("stickers2", "grip")
	loadDecal("stickers2", "hand")
	loadDecal("stickers2", "heat")
	loadDecal("stickers2", "hk")
	loadDecal("stickers2", "hks")
	loadDecal("stickers2", "hoo")
	loadDecal("stickers2", "hoo2")
	loadDecal("stickers2", "hoodpin")
	loadDecal("stickers2", "insta")
	loadDecal("stickers2", "jdm")
	loadDecal("stickers2", "jeep")
	loadDecal("stickers2", "liq")
	loadDecal("stickers2", "lowrider")
	loadDecal("stickers2", "mouth")
	loadDecal("stickers2", "mouth2")
	loadDecal("stickers2", "nagymagyar")
	loadDecal("stickers2", "nber1")
	loadDecal("stickers2", "nber2")
	loadDecal("stickers2", "nber3")
	loadDecal("stickers2", "nber4")
	loadDecal("stickers2", "nber5")
	loadDecal("stickers2", "nber6")
	loadDecal("stickers2", "nber7")
	loadDecal("stickers2", "nber8")
	loadDecal("stickers2", "nber9")
	loadDecal("stickers2", "nber10")
	loadDecal("stickers2", "nber11")
	loadDecal("stickers2", "nber12")
	loadDecal("stickers2", "nber13")
	loadDecal("stickers2", "nur")
	loadDecal("stickers2", "p")
	loadDecal("stickers2", "pelikan")
	loadDecal("stickers2", "shine")
	loadDecal("stickers2", "shine2")
	loadDecal("stickers2", "skull2")
	loadDecal("stickers2", "smokeandcharm1")
	loadDecal("stickers2", "smokeandcharm2")
	loadDecal("stickers2", "st")
	loadDecal("stickers2", "stick")
	loadDecal("stickers2", "stones")
	loadDecal("stickers2", "sultan")
	loadDecal("stickers2", "t")
	loadDecal("stickers2", "thug")
	loadDecal("stickers2", "turbo")
	loadDecal("stickers2", "yt")
	loadDecal("textures", "0")
	loadDecal("textures", "1")
	loadDecal("textures", "alu")
	loadDecal("textures", "brushed")
	loadDecal("textures", "c1")
	loadDecal("textures", "camo0")
	loadDecal("textures", "camo00")
	loadDecal("textures", "camo000")
	loadDecal("textures", "camo00a")
	loadDecal("textures", "camo0a")
	loadDecal("textures", "camo0a1")
	loadDecal("textures", "camo1")
	loadDecal("textures", "camo2")
	loadDecal("textures", "camo2a")
	loadDecal("textures", "camo2a1")
	loadDecal("textures", "camo2a2")
	loadDecal("textures", "camo2a3")
	loadDecal("textures", "camo2a4")
	loadDecal("textures", "camo2a5")
	loadDecal("textures", "camo3")
	loadDecal("textures", "camo4")
	loadDecal("textures", "fiberglass")
	loadDecal("textures", "hks")
	loadDecal("textures", "metal")
	loadDecal("textures", "metal2")
	loadDecal("textures", "metal3")
	loadDecal("textures", "metal3a")
	loadDecal("textures", "metal4")
	loadDecal("textures", "metal4a")
	loadDecal("textures", "metal5")
	loadDecal("textures", "metal6")
	loadDecal("textures", "metal7")
	loadDecal("textures", "neon1")
	loadDecal("textures", "neon2")
	loadDecal("textures", "neon3")
	loadDecal("textures", "neon4")
	loadDecal("textures", "neon5")
	loadDecal("textures", "neon6")
	loadDecal("textures", "neon7")
	loadDecal("textures", "neon8")
	loadDecal("textures", "neonp1")
	loadDecal("textures", "neonp2")
	loadDecal("textures", "neonp3")
	loadDecal("textures", "neonp4")
	loadDecal("textures", "plastic")
	loadDecal("textures", "ps")
	loadDecal("textures", "rust")
	loadDecal("textures", "rust2")
	loadDecal("textures", "splat0")
	loadDecal("textures", "splat1")
	loadDecal("textures", "splat1a")
	loadDecal("textures", "splat2")
	loadDecal("textures", "splat3")
	loadDecal("textures", "splat4")
	loadDecal("textures", "splat5")
	loadDecal("textures", "splat11")
	loadDecal("textures", "stars")
	loadDecal("textures", "stickerbomb")
	loadDecal("textures", "stickerbomb1")
	loadDecal("textures", "w1")
	loadDecal("textures", "w2")
	loadDecal("textures", "w3")
	loadDecal("tribal", "0")
	loadDecal("tribal", "1")
	loadDecal("tribal", "2")
	loadDecal("tribal", "3")
	loadDecal("tribal", "4")
	loadDecal("tribal", "5")
	loadDecal("tribal", "6")
	loadDecal("tribal", "7")
	loadDecal("tribal", "8")
	loadDecal("tribal", "9")
	loadDecal("tribal", "10")
	loadDecal("tribal", "11")
	loadDecal("tribal", "12")
	loadDecal("tribal", "13")
	loadDecal("tribal", "14")
	loadDecal("tribal", "15")
	loadDecal("tribal", "16")
	loadDecal("tribal", "17")
	loadDecal("tribal", "18")
	loadDecal("tribal", "19")
	loadDecal("tribal", "20")
	loadDecal("tribal", "21")
	loadDecal("tribal", "22")
	loadDecal("tribal", "23")
	loadDecal("tribal", "24")
	loadDecal("tribal", "25")
	loadDecal("tribal", "26")
end

-- 1, 2, 3, 4,  5,    7,    6,    8,  9,  10, 11,     12,      13
-- x, y, w, h, rot, path, color, mh, mv, m1, m2, customtext, name
local layers = {}
local selectedLayer = false
local layerElements = {}
local layerScroll = 0

local decalSelector = false
local decalSelectorContent = false
local selectedCategory = 1
local decalScroll = 0
local decalSelectorElements = {}
local decalSelectorsb = false

local layerEditor = false
local layerPreview = false
local layerPreviewBG = false
local h = false
local s = false
local l = false
local o = false

local decalToPlace = false
local decalPlacing = false
local decalPlacingSize = 128
local decalPlaceRot = 0

local newLayerCount = 1

local movingMode = "move"

local highlight = false
local toolbarToggles = {}

local categoryElements = {}
local carBackgroundTexture = 0
local carBackgroundSize = 128 + 128/2
local carBG = 0

remapContainer = {
    [445] = "remap",
    [602] = "remap_quattro82",
    [429] = "remap_gts",
    [496] = "remap",
    [401] = "remap",
    [402] = "remap_firebird",
    [541] = "camaro_remap",
    [438] = "remap",
    [457] = "remap",
    [527] = "remap_mustang",
    [483] = "remap",
    [415] = "remap",
    [589] = "remap_body",
    [480] = "remap_porsche",
    [596] = "remap_rs_body",
    [597] = "remap_octavia",
    [598] = "remap",
    [599] = "remap",
    [562] = "remapelegybody",
    [585] = "rs2_remap",
    [419] = "remap_body",
    [587] = "remap",
    [521] = "remap",
    [533] = "remap",
    [565] = "remap_civic",
    [466] = "remap",
    [604] = "remap_body",
    [492] = "remap_f10",
    [474] = "remap",
    [434] = "remap_body",
    [494] = "remap",
    [502] = "ac_white",
    [503] = "remap_chiron",
    [579] = "remap_hse",
    [411] = "remap_pista",
    [546] = "lada_remap",
    [559] = "remap_supra92",
    [400] = "remap_x5",
    [517] = "remap_chevelle67",
    [410] = "remapelegybody128",
    [551] = "remap_750",
    [500] = "remapmesa256",
    [418] = "remap_body",
    [516] = "remap_300SEL72",
    [582] = "template",
    [522] = "remap_suzuki",
    [467] = "T_Body2",
    [470] = "remap",
    [404] = "remap_g63",
    [426] = "Paint_material",
    [547] = "remap",
    [479] = "remap_190e",
    [468] = "remap",
    [495] = "remap",
    [567] = "remap",
    [405] = "remap_a8",
    [535] = "remapslamvan92body128",
    [458] = "remap",
    [580] = "remap",
    [439] = "remap_charger70",
    [561] = "remapelegybody128",
    [409] = "remap_limo",
    [560] = "remapelegybody128",
    [550] = "remap_e420",
    [506] = "remap",
    [549] = "remap_m8comp",
    [420] = "remap_e34",
    [576] = "remap_belair57",
    [525] = "F550_body",
    [451] = "remap",
    [558] = "remap",
    [540] = "remap_impreza",
    [491] = "remap_M635CSi84",
    [421] = "remap_760",
    [586] = "remap_fatboy",
    [529] = "leon_remap",
    [554] = "remap_silverado",
    [477] = "remap",
}

local mirrorTries = 0
local mirrorSetStage = 1
local mirrorPositions = {}
local mirrorsReady = false
local mirrorsPostReady = false

local newTextInput = false
local newTextPreviewFont = false
local newTextPreviewFontId = 1
local newTextPreviewFontElements = {}
local customTextFonts = {
	{
		"aAnotherTag.ttf",
		30
	},
	{
		"americorps.ttf",
		20
	},
	{
		"americorps3d.ttf",
		20
	},
	{
		"americorpsgrad.ttf",
		20
	},
	{
		"americorpslaser.ttf",
		20
	},
	{
		"barbatrick.ttf",
		23
	},
	{
		"BebasNeueBold.otf",
		25
	},
	{
		"BebasNeueRegular.otf",
		25
	},
	{
		"BlankRiver.ttf",
		30
	},
	{"Ikarus.otf", 23},
	{
		"Butler_Regular.otf",
		25
	},
	{
		"CampusA.ttf",
		23
	},
	{
		"DDayStencil.ttf",
		25
	},
	{
		"raustila-Regular.ttf",
		30
	},
	{
		"StrangerbackintheNight.ttf",
		30
	},
	{
		"Ubuntu-B.ttf",
		23
	},
	{
		"Ubuntu-R.ttf",
		23
	},
	{
		"Xenogears.ttf",
		23
	}
}
local newDecalColorList = {}
function resetTheColorList()
	newDecalColorList = {
		{
			255,
			255,
			255,
			true
		},
		{
			50,
			50,
			50,
			true
		},
		{
			0,
			0,
			0,
			true
		},
		{
			29,
			167,
			230,
			true
		},
		{
			45,
			41,
			143,
			true
		},
		{
			217,
			23,
			29,
			true
		},
		{
			226,
			0,
			37,
			true
		},
		{
			252,
			228,
			0,
			true
		},
		{
			33,
			116,
			78,
			true
		},
		{
			214,
			39,
			39,
			true
		},
		{
			61,
			87,
			143,
			true
		},
		{
			255,
			151,
			0,
			true
		},
		{
			0,
			152,
			155,
			true
		},
		{
			7,
			17,
			66,
			true
		},
		{
			0,
			154,
			78,
			true
		},
		{
			0,
			173,
			239,
			true
		},
		{
			218,
			30,
			42,
			true
		},
		{
			37,
			49,
			92,
			true
		},
		{
			251,
			206,
			7,
			true
		}
	}
end
resetTheColorList()
local maskSource = [[

	texture MaskTexture;
	sampler implicitMaskTexture = sampler_state
	{
		Texture = <MaskTexture>;
	};


	float4 MaskTextureMain( float2 uv : TEXCOORD0 ) : COLOR0
	{

		float4 sampledTexture = float4(1, 1, 1, 0);

		float4 maskSampled = tex2D( implicitMaskTexture, uv );

		sampledTexture.a = (maskSampled.r + maskSampled.g + maskSampled.b) / 3.0f;

		return sampledTexture;
	}

	technique Technique1
	{
		pass Pass1
		{
			PixelShader = compile ps_2_0 MaskTextureMain();
		}
	}

]]
function loadCustomTextDecal(input, fontInput, size)
	local name = "customtext/" .. fontInput .. "/" .. size .. "/" .. input
	if decals[name] then
		return name
	end
	local done = false
	local text = false
	local tw = 0
	local font = dxCreateFont("files/fonts/" .. fontInput, size * 2, false, "antialiased")
	if isElement(font) then
		local tw = math.floor(dxGetTextWidth(input, 0.5, font) / 2) * 2 + 16
		local rt = dxCreateRenderTarget(tw, 64, true)
		local rt2 = dxCreateRenderTarget(tw, 64, true)
		local shader = dxCreateShader(maskSource)
		if isElement(rt) and isElement(rt2) and isElement(shader) then
			dxSetShaderValue(shader, "MaskTexture", rt2)
			dxSetRenderTarget(rt2, true)
			dxSetBlendMode("modulate_add")
			dxDrawRectangle(0, 0, tw, 64, tocolor(0, 0, 0))
			dxDrawText(input, tw, 0, 0, 64, tocolor(255, 255, 255, 255), 0.5, font, "center", "center")
			dxSetRenderTarget(rt, true)
			dxSetBlendMode("overwrite")
			dxDrawImage(0, 0, tw, 64, shader)
			dxSetBlendMode("blend")
			dxSetRenderTarget()
			local pixels = dxGetTexturePixels(rt)
			if pixels then
				text = dxCreateTexture(pixels)
				pixels = nil
				collectgarbage("collect")
				decals[name] = {
					text,
					tw,
					64,
					true,
					"Egyedi szöveg",
					fontInput,
					size,
					input
				}
				done = name
			end
		end
		if isElement(shader) then
			destroyElement(shader)
		end
		shader = nil
		if isElement(rt) then
			destroyElement(rt)
		end
		rt = nil
		if isElement(rt2) then
			destroyElement(rt2)
		end
		rt2 = nil
		destroyElement(font)
		font = nil
	end
	return done
end

local paintjobDeleterPrompt = false
local paintjobToLoad = false
local paintjobLoaderElements = {}
local paintjobLoaderData = {}
local paintjobLoaderPager = {}
local currentPaintjobLoaderPage = 1

local drawRT = false
function drawLayers(final)
    dxSetRenderTarget(renderTarget, true)
    dxSetBlendMode("modulate_add")
    local col = tocolor(vehColor[1], vehColor[2], vehColor[3])
    local cs = math.floor(carBackgroundSize + 0.5)
    
    if decalContainer.textures then
        local path = "textures/" .. decalContainer["textures"][carBG + 1][1]
        if cs <= 32 then
            path = "files/decals/32/" .. path
        elseif cs <= 64 then
            path = "files/decals/64/" .. path
        elseif cs <= 128 then
            path = "files/decals/128/" .. path
        else
            path = "files/decals/256/" .. path
        end
        for x = 0, math.ceil(1024 / cs) - 1 do
            for y = 0, math.ceil(1024 / cs) - 1 do
                dxDrawImage(x * cs, y * cs, cs, cs, dynamicImage(path), 0, 0, 0, col)
            end
        end
    end

    for i = #layers, 1, -1 do
        local layer = layers[i]
        if layer then
            local x, y, w, h, rot, path, color, mh, mv, m1, m2, customtext, name = unpack(layer)
            
            local s = math.max(w, h)
            if not customtext then
                if s <= 32 then
                    path = "files/decals/32/" .. path
                elseif s <= 64 then
                    path = "files/decals/64/" .. path
                elseif s <= 128 then
                    path = "files/decals/128/" .. path
                else
                    path = "files/decals/256/" .. path
                end
            end

            if mh then
                x = x + w
                w = -w
            end
            if mv then
                y = y + h
                h = -h
            end

            if decals[layers[i][6]] then
                if highlight then
                    if selectedLayer == i then
                        dxDrawImage(x, y, w, h, decals[layers[i][6]][1], rot, 0, 0, tocolor(color[1], color[2], color[3], color[4] or 255))
                    else
                        dxDrawImage(x, y, w, h, decals[layers[i][6]][1], rot, 0, 0, tocolor(color[1], color[2], color[3], (color[4] or 255)/5))
                    end
                else
                    dxDrawImage(x, y, w, h, decals[layers[i][6]][1], rot, 0, 0, tocolor(color[1], color[2], color[3], color[4] or 255))
                end
            else
                if highlight then
                    if selectedLayer == i then
                        dxDrawImage(x, y, w, h, dynamicImage(path), rot, 0, 0, tocolor(color[1], color[2], color[3], color[4] or 255))
                    else
                        dxDrawImage(x, y, w, h, dynamicImage(path), rot, 0, 0, tocolor(color[1], color[2], color[3], (color[4] or 255)/5))
                    end
                else
                    dxDrawImage(x, y, w, h, dynamicImage(path), rot, 0, 0, tocolor(color[1], color[2], color[3], color[4] or 255))
                end
            end

            if mirrorsReady and layer[10] then
				local x, y, sx, sy = layers[i][1], layers[i][2], layers[i][3], layers[i][4]
				local mx, my, mdx, mdy = mirrorPositions[1], mirrorPositions[2], mirrorPositions[3], mirrorPositions[4]
				local mx2, my2, mdx2, mdy2 = mirrorPositions[5], mirrorPositions[6], mirrorPositions[7], mirrorPositions[8]
				if getDistanceBetweenPoints2D(x, y, mx2, my2) < getDistanceBetweenPoints2D(x, y, mx, my) then
					mx, my, mdx, mdy = mirrorPositions[5], mirrorPositions[6], mirrorPositions[7], mirrorPositions[8]
					mx2, my2, mdx2, mdy2 = mirrorPositions[1], mirrorPositions[2], mirrorPositions[3], mirrorPositions[4]
				end
				x = x + sx / 2
				y = y + sy / 2
				x = mx2 + (x - mx) * (mdx2 * mdx)
				y = my2 + (y - my) * (mdy2 * mdy)
				local dx = (layers[i][8] and -1 or 1) * mdx2 * mdx * (layers[i][11] and -1 or 1)
				local dy = (layers[i][9] and -1 or 1) * mdy2 * mdy
				local r = layers[i][5]
				if mdx2 * mdx * mdy2 * mdy < 0 then
					r = 360 - r
				end
				x = x + sx / 2 * -dx
				y = y + sy / 2 * -dy
				sx = sx * dx
				sy = sy * dy
				if decals[layers[i][6]] and decals[layers[i][6]][1] then
					dxDrawImage(x, y, sx, sy, decals[layers[i][6]][1], r, 0, 0, tocolor(layers[i][7][1], layers[i][7][2], layers[i][7][3], a))
				else
					dxDrawImage(x, y, sx, sy, dynamicImage(path), r, 0, 0, tocolor(layers[i][7][1], layers[i][7][2], layers[i][7][3], a))
				end
			end
        end
    end

    if not final and decalPlacing then
        if uvX and uvY then
            local path = ""
            if type(decalToPlace) == "string" then
                path = decals[decalToPlace][1]
            else
                if decalPlacingSize <= 32 then
                    path = "files/decals/32/" .. decalToPlace[1] .. "/" .. decalToPlace[2] .. ".dds"
                elseif decalPlacingSize <= 64 then
                    path = "files/decals/64/" .. decalToPlace[1] .. "/" .. decalToPlace[2] .. ".dds"
                elseif decalPlacingSize <= 128 then
                    path = "files/decals/128/" .. decalToPlace[1] .. "/" .. decalToPlace[2] .. ".dds"
                else
                    path = "files/decals/256/" .. decalToPlace[1] .. "/" .. decalToPlace[2] .. ".dds"
                end
                path = dynamicImage(path)
            end

            local bx = (uvX/1024) - (calculateUV(pixelsX, cx + 0, cy + 2) or 0)
            local by = (uvY/1024) - (calculateUV(pixelsY, cx + 0, cy + 2) or 0)
            local rx = (uvX/1024) - (calculateUV(pixelsX, cx + 2, cy + 0) or 0)
            local ry = (uvY/1024) - (calculateUV(pixelsY, cx + 2, cy + 0) or 0)
            local r = false
            local ts = 1024
            if 0 < math.abs(bx) + math.abs(by) and math.abs(bx) < 2 / ts and math.abs(by) < 2 / ts then
                r = math.floor(math.atan2(by, bx) / pih) * pih + pih
            end
            if 0 < math.abs(rx) + math.abs(ry) and math.abs(rx) < 2 / ts and math.abs(ry) < 2 / ts then
                local r2 = math.floor(math.atan2(ry, rx) / pih) * pih + pih * 2
                r = r and math.max(r, r2) or r2
            end
            if r then
                uvR = math.deg(r)
            end

            dxDrawImage(uvX - decalPlacingSize/2, uvY - decalPlacingSize/2, decalPlacingSize, decalPlacingSize, path, decalPlaceRot + uvR, 0, 0, tocolor(decalPlacing[1], decalPlacing[2], decalPlacing[3], decalPlacing[4]))
        end
    end

    if not final and not decalPlacing and selectedLayer then
        local layer = layers[selectedLayer]
        local hom = hoveringLayer or movingLayer
        local hSide = false
        if movingMode == "resize" and hom then
            hSide = hoveringLayer and hoveringLayer[7] or movingLayer[7]
        end
        local white = tocolor(255, 255, 255)
        local col = hom and tocolor(108, 179, 201) or white
        local x, y = layer[1], layer[2]
        local sx, sy = layer[3], layer[4]
        local rot = layer[5]
        local r = math.rad(rot)
        local s = math.sin(r)
        local c = math.cos(r)
        local cs = math.min(math.floor(math.min(sx, sy) / 5 / 2) * 2, 16)
        local lw = cs / 4
        local lx, ly, lx2, ly2, cx, cy, cx2, cy2
        if movingMode == "resize" then
            col = hom and hSide == "s1" and tocolor(108, 179, 201) or white
            lx = x + sx / 2 + (-sx / 2 + cs * 1.5) * c - -sy / 2 * s
            ly = y + sy / 2 + (-sx / 2 + cs * 1.5) * s + -sy / 2 * c
            lx2 = x + sx / 2 + (sx / 2 - cs * 1.5) * c - -sy / 2 * s
            ly2 = y + sy / 2 + (sx / 2 - cs * 1.5) * s + -sy / 2 * c
            dxDrawLineEx(lx, ly, lx2, ly2, lw)
            dxDrawLine(lx, ly, lx2, ly2, col, lw)
            col = hom and hSide == "s2" and tocolor(108, 179, 201) or white
            lx = x + sx / 2 + (-sx / 2 + cs * 1.5) * c - sy / 2 * s
            ly = y + sy / 2 + (-sx / 2 + cs * 1.5) * s + sy / 2 * c
            lx2 = x + sx / 2 + (sx / 2 - cs * 1.5) * c - sy / 2 * s
            ly2 = y + sy / 2 + (sx / 2 - cs * 1.5) * s + sy / 2 * c
            dxDrawLineEx(lx, ly, lx2, ly2, lw)
            dxDrawLine(lx, ly, lx2, ly2, col, lw)
            col = hom and hSide == "s3" and tocolor(108, 179, 201) or white
            lx = x + sx / 2 + -sx / 2 * c - (-sy / 2 + cs * 1.5) * s
            ly = y + sy / 2 + -sx / 2 * s + (-sy / 2 + cs * 1.5) * c
            lx2 = x + sx / 2 + -sx / 2 * c - (sy / 2 - cs * 1.5) * s
            ly2 = y + sy / 2 + -sx / 2 * s + (sy / 2 - cs * 1.5) * c
            dxDrawLineEx(lx, ly, lx2, ly2, lw)
            dxDrawLine(lx, ly, lx2, ly2, col, lw)
            col = hom and hSide == "s4" and tocolor(108, 179, 201) or white
            lx = x + sx / 2 + sx / 2 * c - (-sy / 2 + cs * 1.5) * s
            ly = y + sy / 2 + sx / 2 * s + (-sy / 2 + cs * 1.5) * c
            lx2 = x + sx / 2 + sx / 2 * c - (sy / 2 - cs * 1.5) * s
            ly2 = y + sy / 2 + sx / 2 * s + (sy / 2 - cs * 1.5) * c
            dxDrawLineEx(lx, ly, lx2, ly2, lw)
            dxDrawLine(lx, ly, lx2, ly2, col, lw)
        end
        if movingMode == "resize" then
            col = hom and hSide == "c1" and tocolor(108, 179, 201) or white
        end
        cx = x + sx / 2 + (-sx / 2 - lw / 2) * c - -sy / 2 * s
        cy = y + sy / 2 + (-sx / 2 - lw / 2) * s + -sy / 2 * c
        cx2 = x + sx / 2 + -sx / 2 * c - -sy / 2 * s
        cy2 = y + sy / 2 + -sx / 2 * s + -sy / 2 * c
        lx = x + sx / 2 + (-sx / 2 + cs) * c - -sy / 2 * s
        ly = y + sy / 2 + (-sx / 2 + cs) * s + -sy / 2 * c
        lx2 = x + sx / 2 + -sx / 2 * c - (-sy / 2 + cs) * s
        ly2 = y + sy / 2 + -sx / 2 * s + (-sy / 2 + cs) * c
        dxDrawLineEx(cx, cy, lx, ly, lw)
        dxDrawLineEx(cx2, cy2, lx2, ly2, lw)
        dxDrawLine(cx, cy, lx, ly, col, lw)
        dxDrawLine(cx2, cy2, lx2, ly2, col, lw)
        if movingMode == "resize" then
            col = hom and hSide == "c3" and tocolor(108, 179, 201) or white
        end
        cx = x + sx / 2 + (sx / 2 + lw / 2) * c - -sy / 2 * s
        cy = y + sy / 2 + (sx / 2 + lw / 2) * s + -sy / 2 * c
        cx2 = x + sx / 2 + sx / 2 * c - -sy / 2 * s
        cy2 = y + sy / 2 + sx / 2 * s + -sy / 2 * c
        lx = x + sx / 2 + (sx / 2 - cs) * c - -sy / 2 * s
        ly = y + sy / 2 + (sx / 2 - cs) * s + -sy / 2 * c
        lx2 = x + sx / 2 + sx / 2 * c - (-sy / 2 + cs) * s
        ly2 = y + sy / 2 + sx / 2 * s + (-sy / 2 + cs) * c
        dxDrawLineEx(cx, cy, lx, ly, lw)
        dxDrawLineEx(cx2, cy2, lx2, ly2, lw)
        dxDrawLine(cx, cy, lx, ly, col, lw)
        dxDrawLine(cx2, cy2, lx2, ly2, col, lw)
        if movingMode == "resize" then
            col = hom and hSide == "c4" and tocolor(108, 179, 201) or white
        end
        cx = x + sx / 2 + (sx / 2 + lw / 2) * c - sy / 2 * s
        cy = y + sy / 2 + (sx / 2 + lw / 2) * s + sy / 2 * c
        cx2 = x + sx / 2 + sx / 2 * c - sy / 2 * s
        cy2 = y + sy / 2 + sx / 2 * s + sy / 2 * c
        lx = x + sx / 2 + (sx / 2 - cs) * c - sy / 2 * s
        ly = y + sy / 2 + (sx / 2 - cs) * s + sy / 2 * c
        lx2 = x + sx / 2 + sx / 2 * c - (sy / 2 - cs) * s
        ly2 = y + sy / 2 + sx / 2 * s + (sy / 2 - cs) * c
        dxDrawLineEx(cx, cy, lx, ly, lw)
        dxDrawLineEx(cx2, cy2, lx2, ly2, lw)
        dxDrawLine(cx, cy, lx, ly, col, lw)
        dxDrawLine(cx2, cy2, lx2, ly2, col, lw)
        if movingMode == "resize" then
            col = hom and hSide == "c2" and tocolor(108, 179, 201) or white
        end
        cx = x + sx / 2 + (-sx / 2 - lw / 2) * c - sy / 2 * s
        cy = y + sy / 2 + (-sx / 2 - lw / 2) * s + sy / 2 * c
        cx2 = x + sx / 2 + -sx / 2 * c - sy / 2 * s
        cy2 = y + sy / 2 + -sx / 2 * s + sy / 2 * c
        lx = x + sx / 2 + (-sx / 2 + cs) * c - sy / 2 * s
        ly = y + sy / 2 + (-sx / 2 + cs) * s + sy / 2 * c
        lx2 = x + sx / 2 + -sx / 2 * c - (sy / 2 - cs) * s
        ly2 = y + sy / 2 + -sx / 2 * s + (sy / 2 - cs) * c
        dxDrawLineEx(cx, cy, lx, ly, lw)
        dxDrawLineEx(cx2, cy2, lx2, ly2, lw)
        dxDrawLine(cx, cy, lx, ly, col, lw)
        dxDrawLine(cx2, cy2, lx2, ly2, col, lw)
        if movingMode == "rotate" then
            dxDrawLineEx(x + sx / 2 - cs / 2, y + sy / 2, x + sx / 2 + cs / 2, y + sy / 2, lw)
            dxDrawLineEx(x + sx / 2, y + sy / 2 - cs / 2, x + sx / 2, y + sy / 2 + cs / 2, lw)
            dxDrawLine(x + sx / 2 - cs / 2, y + sy / 2, x + sx / 2 + cs / 2, y + sy / 2, col, lw)
            dxDrawLine(x + sx / 2, y + sy / 2 - cs / 2, x + sx / 2, y + sy / 2 + cs / 2, col, lw)
        end
    end

    dxSetBlendMode("blend")
    dxSetRenderTarget()
end

function renderEditor()
    if newTextPreviewFont then
		local w = 495
		local h = 48 + w / 9 * 2
		local x = screenX / 2 - w / 2
		local y = screenY / 2 - h / 2 - 48
		dxDrawRectangle(x, y + h, w, 96, tocolor(35, 35, 35))
		dxDrawRectangle(x + 8, y + h + 8, w - 16, 80, tocolor(45, 45, 45))
		dxDrawText(exports.am_gui:getInputValue(newTextInput) or "", x, y + h, x + w, y + h + 96, tocolor(255, 255, 255, 255), 0.5, newTextPreviewFont, "center", "center")
	end

    if mirrorSetStage == 3 or mirrorSetStage == 6 then
		local mx, my = false, false
		local mdx, mdy = false, false
		for i = 0, screenY * 0.025 do
			local pixelsX = dxGetTexturePixels(renderTargetX, screenX / 2, screenY / 2 + i, ts, ts)
			if pixelsX then
				mx = calculateUV(pixelsX, 0, 0)
				local pixelsY = dxGetTexturePixels(renderTargetY, screenX / 2, screenY / 2 + i, ts, ts)
				if pixelsY then
					my = calculateUV(pixelsY, 0, 0)
				end
			end
			pixelsX, pixelsY = nil, nil
			collectgarbage("collect")
			if mx and my then
				for j = 1, screenY * 0.025 do
					local dx, dy = false, false
					local pixelsX = dxGetTexturePixels(renderTargetX, screenX / 2 + j * (mirrorSetStage == 6 and -1 or 1), screenY / 2 + i + j, ts, ts)
					if pixelsX then
						dx = calculateUV(pixelsX, 0, 0)
						local pixelsY = dxGetTexturePixels(renderTargetY, screenX / 2 + j * (mirrorSetStage == 6 and -1 or 1), screenY / 2 + i + j, ts, ts)
						if pixelsY then
							dy = calculateUV(pixelsY, 0, 0)
						end
					end
					pixelsX, pixelsY = nil, nil
					collectgarbage("collect")
					if dx and dy and dx ~= mx and dy ~= my then
						mdx = dx
						mdy = dy
					end
				end
			end
			if mx and my and mdx and mdy then
				break
			end
		end
		if mx and my and mdx and mdy then
			if mirrorSetStage == 3 then
				mirrorPositions[1] = math.floor(mx * ts + 0.5)
				mirrorPositions[2] = math.floor(my * ts + 0.5)
				mirrorPositions[3] = (mdx - mx) / math.abs(mdx - mx)
				mirrorPositions[4] = (mdy - my) / math.abs(mdy - my)
			else
				mirrorPositions[5] = math.floor(mx * ts + 0.5)
				mirrorPositions[6] = math.floor(my * ts + 0.5)
				mirrorPositions[7] = (mdx - mx) / math.abs(mdx - mx)
				mirrorPositions[8] = (mdy - my) / math.abs(mdy - my)
			end
            
			rtToDraw = true
			mirrorsReady = tonumber(mirrorPositions[1]) and tonumber(mirrorPositions[5])
		end
	end

    cx, cy = getCursorPosition()
    if cx then
        cx = cx * screenX 
        cy = cy * screenY 
    end

    if refreshNextFrame then 
        refreshNextFrame = false
        
        pixelsX, pixelsY = nil, nil
        collectgarbage("collect")

        pixelsX = dxGetTexturePixels(renderTargetX)
        pixelsY = dxGetTexturePixels(renderTargetY)
    end

	uvX, uvY = false, false
    if cx and cy then
        if pixelsX and pixelsY then
            uvX, uvY = calculateUV(pixelsX, cx, cy), calculateUV(pixelsY, cx, cy)
            if uvX and uvY then
                uvX = uvX * 1024
                uvY = uvY * 1024
            end
        end
    end
    
	hoveringLayer = false
    if decalPlacing then
		rtToDraw = true
	elseif selectedLayer and uvX and isElement(editor) then
		if movingLayer then
			if movingMode == "resize" then
				local layer = layers[selectedLayer]
				local rot = layer[5]
				local r = math.rad(-rot)
				local s = math.sin(r)
				local c = math.cos(r)
				local ix = (uvX - movingLayer[1]) * c - (uvY - movingLayer[2]) * s
				local iy = (uvX - movingLayer[1]) * s + (uvY - movingLayer[2]) * c
				local osx, osy = movingLayer[5], movingLayer[6]
				local rx, ry = 0, 0
				if getKeyState("lalt") then
					ix = ix * 2
					iy = iy * 2
				end
				if movingLayer[7] == "c4" then
					if getKeyState("lshift") then
						local a1 = iy + osx - iy
						local b1 = ix - (ix - osy)
						local c1 = a1 * ix + b1 * iy
						local det = osy * b1 - a1 * -osx
						ix = (b1 - -osx * c1) / det
						iy = (osy * c1 - a1) / det
					end
					layers[selectedLayer][3] = math.max(24, math.floor(movingLayer[5] + ix))
					layers[selectedLayer][4] = math.max(24, math.floor(movingLayer[6] + iy))
				elseif movingLayer[7] == "c3" then
					if getKeyState("lshift") then
						local a1 = iy + osx - iy
						local b1 = ix - (ix + osy)
						local c1 = a1 * ix + b1 * iy
						local det = -osy * b1 - a1 * -osx
						ix = (b1 - -osx * c1) / det
						iy = (-osy * c1 - a1) / det
					end
					layers[selectedLayer][3] = math.max(24, math.floor(movingLayer[5] + ix))
					layers[selectedLayer][4] = math.max(24, math.floor(movingLayer[6] - iy))
					ry = layers[selectedLayer][4] - osy
				elseif movingLayer[7] == "c2" then
					if getKeyState("lshift") then
						local a1 = iy - osx - iy
						local b1 = ix - (ix - osy)
						local c1 = a1 * ix + b1 * iy
						local det = osy * b1 - a1 * osx
						ix = (b1 - osx * c1) / det
						iy = (osy * c1 - a1) / det
					end
					layers[selectedLayer][3] = math.max(24, math.floor(movingLayer[5] - ix))
					layers[selectedLayer][4] = math.max(24, math.floor(movingLayer[6] + iy))
					rx = layers[selectedLayer][3] - osx
				elseif movingLayer[7] == "c1" then
					if getKeyState("lshift") then
						local a1 = iy - osx - iy
						local b1 = ix - (ix + osy)
						local c1 = a1 * ix + b1 * iy
						local det = -osy * b1 - a1 * osx
						ix = (b1 - osx * c1) / det
						iy = (-osy * c1 - a1) / det
					end
					layers[selectedLayer][3] = math.max(24, math.floor(movingLayer[5] - ix))
					layers[selectedLayer][4] = math.max(24, math.floor(movingLayer[6] - iy))
					rx = layers[selectedLayer][3] - osx
					ry = layers[selectedLayer][4] - osy
				elseif movingLayer[7] == "s4" then
					layers[selectedLayer][3] = math.max(24, math.floor(movingLayer[5] + ix))
				elseif movingLayer[7] == "s3" then
					layers[selectedLayer][3] = math.max(24, math.floor(movingLayer[5] - ix))
					rx = layers[selectedLayer][3] - osx
				elseif movingLayer[7] == "s2" then
					layers[selectedLayer][4] = math.max(24, math.floor(movingLayer[6] + iy))
				elseif movingLayer[7] == "s1" then
					layers[selectedLayer][4] = math.max(24, math.floor(movingLayer[6] - iy))
					ry = layers[selectedLayer][4] - osy
				end
				local sx, sy = layers[selectedLayer][3] - osx, layers[selectedLayer][4] - osy
				local r = math.rad(rot)
				local s = math.sin(r)
				local c = math.cos(r)
				local ix = osx / 2
				local iy = osy / 2
				if not getKeyState("lalt") then
					ix = ix + (sx / 2 - rx) * c - (sy / 2 - ry) * s
					iy = iy + (sx / 2 - rx) * s + (sy / 2 - ry) * c
				end
				layers[selectedLayer][1] = movingLayer[3] + ix - (osx + sx) / 2
				layers[selectedLayer][2] = movingLayer[4] + iy - (osy + sy) / 2
			elseif movingMode == "rotate" then
				local layer = layers[selectedLayer]
				local rot = math.deg(movingLayer[1] - math.atan2(uvX - (layer[1] + layer[3] / 2), uvY - (layer[2] + layer[4] / 2)))
				layers[selectedLayer][5] = movingLayer[2] + rot
				if getKeyState("lshift") then
					layers[selectedLayer][5] = math.floor(layers[selectedLayer][5] / 15 + 0.5) * 5
				end
				layers[selectedLayer][5] = layers[selectedLayer][5] % 360
			else
				layers[selectedLayer][1] = math.floor(movingLayer[3] + uvX - movingLayer[1])
				layers[selectedLayer][2] = math.floor(movingLayer[4] + uvY - movingLayer[2])
			end
			rtToDraw = true
		else
			local layer = layers[selectedLayer]
			local x, y = layer[1], layer[2]
			local sx, sy = layer[3], layer[4]
			local rot = layer[5]
			local r = math.rad(-rot)
			local s = math.sin(r)
			local c = math.cos(r)
			local ix = (x + sx / 2 - uvX) * c - (y + sy / 2 - uvY) * s
			local iy = (x + sx / 2 - uvX) * s + (y + sy / 2 - uvY) * c
			local cs = math.min(math.floor(math.min(sx, sy) / 5 / 2) * 2, 16)
			local lw = cs / 4
			if ix <= sx / 2 + lw / 2 + 1 and ix >= -sx / 2 - lw / 2 - 1 and iy <= sy / 2 + lw / 2 + 1 and iy >= -sy / 2 - lw / 2 - 1 then
				if movingMode == "resize" then
					local hSide = false
					if ix < -sx / 2 + cs then
						if iy < -sy / 2 + cs then
							hSide = "c4"
						elseif iy > sy / 2 - cs then
							hSide = "c3"
						else
							hSide = "s4"
						end
					elseif ix > sx / 2 - cs then
						if iy < -sy / 2 + cs then
							hSide = "c2"
						elseif iy > sy / 2 - cs then
							hSide = "c1"
						else
							hSide = "s3"
						end
					elseif iy < -sy / 2 + cs then
						hSide = "s2"
					elseif iy > sy / 2 - cs then
						hSide = "s1"
					end
					if hSide then
						rtToDraw = true
						hoveringLayer = {
							uvX,
							uvY,
							layer[1],
							layer[2],
							layer[3],
							layer[4],
							hSide
						}
					end
				elseif movingMode == "rotate" then
					hoveringLayer = {
						math.atan2(uvX - (layer[1] + layer[3] / 2), uvY - (layer[2] + layer[4] / 2)),
						layer[5]
					}
				else
					hoveringLayer = {
						uvX,
						uvY,
						layer[1],
						layer[2]
					}
				end
			end
		end
	end

	if prepareSaveNextFrame then
		drawLayers(true)
		saveNextFrame = true
		prepareSaveNextFrame = false
	elseif saveNextFrame then
		drawLayers(true)
        if isElement(editor) then
            destroyElement(editor)
        end
		local screen = dxCreateScreenSource(screenX, screenY)
		if isElement(screen) then
			if isElement(paintjobPreviewTexture) then
				destroyElement(paintjobPreviewTexture)
			end
			paintjobPreviewTexture = nil
			paintjobPreviewTexture = dxCreateRenderTarget(200, 200)
		end
		if isElement(paintjobPreviewTexture) then
			dxUpdateScreenSource(screen, false)
			dxSetRenderTarget(paintjobPreviewTexture)
			dxDrawImage(100 - 200 * (screenX / screenY) / 2, 0, 200 * (screenX / screenY), 200, screen)
			dxSetRenderTarget()
		end
		if isElement(screen) then
			destroyElement(screen)
		end
		createPaintjobSaver()
		saveNextFrame = false
		prepareSaveNextFrame = false
	elseif rtToDraw then
		drawLayers()
		rtToDraw = false
	end
	if saveFakeScreenSource then
		if isElement(saveFakeScreenSource) then
			dxDrawImage(0, 0, screenX, screenY, saveFakeScreenSource)
		end
		if not saveNextFrame and not prepareSaveNextFrame and (mirrorsReady and mirrorsPostReady or 8 <= mirrorTries) then
			if isElement(saveFakeScreenSource) and decalsToLoad <= 0 then
                outputChatBox("TÖRLÖM APÁDA")
				destroyElement(saveFakeScreenSource)
			end
			saveFakeScreenSource = false
		end
		mirrorsPostReady = mirrorsReady
	end
	local loadingState = (mirrorsReady or 8 <= mirrorTries) and 1 or 0.9
	if decalLoadQueue then
		if 0 < #decalLoadQueue then
			local p = 0
			if 0 < decalsToLoad then
				p = 1 - #decalLoadQueue / decalsToLoad
			end
			loadingState = p * 0.9
			for i = 1, 4 do
				if decalLoadQueue[1] then
					loadDecalFinal(decalLoadQueue[1][1], decalLoadQueue[1][2], decalLoadQueue[1][3])
					table.remove(decalLoadQueue, 1)
				end
			end
		else
			decalLoadQueue = false
			selectorCategory = categoryContainer[1]
		end
	end
	if loadingState < 1 then
		dxDrawRectangle(screenX / 2 - 200, screenY / 2 - 4, 400, 8, tocolor(35, 35, 35))
		dxDrawRectangle(screenX / 2 - 200, screenY / 2 - 4, 400 * loadingState, 8, tocolor(165, 219, 114))
	end

    if loadingState > 1 then
        if isElement(saveFakeScreenSource) then
            outputChatBox("TÖRLÖM APÁDA")
            destroyElement(saveFakeScreenSource)
        end
        saveFakeScreenSource = false
    end

    drawLayers()
    if drawRT then
        drawLayers()
        drawRT = false
    end
end

function preRenderEditor(delta)
    dxSetRenderTarget(renderTargetX, true)
    dxSetRenderTarget(renderTargetY, true)
    dxSetRenderTarget()

    if 6 < mirrorSetStage then
        if cx then
            local zoom = camZoom
            local x = camX
            local y = camY

            if prepareSaveNextFrame then
                dxUpdateScreenSource(saveFakeScreenSource, true)
            end
            if prepareSaveNextFrame or saveNextFrame then
                zoom = 2.35
                x = 0.4
                y = 0.25
            end
            
            if getVehicleType(veh) ~= "Automobile" then
                zoom = zoom + 0.5
            end

            setCamera(x, y, minX, minY, maxX, maxY, maxZ, zoom)
            local cx, cy = getCursorPosition()
            if isElement(editor) and getKeyState("mouse2") and cx then
                if not camCursor then
                    camCursor = {cx, cy}
                else
                    local val = cx - camCursor[1]
                    camX = camX + 10 * delta / 1000 * math.pow(math.min(0.15, math.abs(val)), 1.5) * (val < 0 and -1 or 1)
                    local val = cy - camCursor[2]
                    camY = camY + 10 * delta / 1000 * math.pow(math.min(0.15, math.abs(val)), 1.5) * (val < 0 and 1 or -1)
                    camX = camX % 1
                    camY = math.min(1, math.max(0, camY))
                    if camX < 0 then
                        camX = 1 + camX
                    end
                end
            else
                if camCursor then
                    refreshNextFrame = true
                end
                camCursor = false
            end
        end
    end
    if mirrorSetStage <= 6 then
        rtToDraw = true
        local mirrorSide = 3 < mirrorSetStage and -1 or 1
        local m = getElementMatrix(veh)
        local x1, y1, z1 = getVehicleComponentPosition(veh, "door_lf_dummy")
        local x2, y2, z2 = getVehicleComponentPosition(veh, "door_rf_dummy")
        if not (not (4 < mirrorTries) and y1) or not y2 then
            local cx, cy, cz = getPositionFromMatrixOffset(m, ((maxX - minX) / 2 + 2) * mirrorSide, 0, 0.25 - (mirrorTries - 4) * 0.05)
            local tx, ty, tz = getPositionFromMatrixOffset(m, (maxX - minX) / 2 * mirrorSide, 0, 0.25 - (mirrorTries - 4) * 0.05)
            setElementMatrix(cx, cy, cz, tx, ty, tz)
        else
            local y, z = (y2 + y1) / 2, (z2 + z1) / 2
            local cx, cy, cz = getPositionFromMatrixOffset(m, ((maxX - minX) / 2 + 2) * mirrorSide, y - 0.25, z + 0.1 - mirrorTries * 0.05)
            local tx, ty, tz = getPositionFromMatrixOffset(m, (maxX - minX) / 2 * mirrorSide, y - 0.25, z + 0.1 - mirrorTries * 0.05)
            setCameraMatrix(cx, cy, cz, tx, ty, tz)
        end
        mirrorSetStage = mirrorSetStage + 1
    elseif not mirrorsReady and mirrorTries < 8 then
        mirrorSetStage = 1
        mirrorTries = mirrorTries + 1
        if 8 <= mirrorTries then
            mirrorSetStage = 7
            setCamera(camX, camY, minX, minY, maxX, maxY, maxZ, camZoom)
        end
    end
end

function keyEditor(key, state)
    if state then
        if key == "mouse_wheel_down" then
            local x, y = 0, 0
            local w, h = 0, 0
            if isElement(layerSelectorContent) then
                x, y = exports.am_gui:getGuiPosition(layerSelectorContent)
                w, h = exports.am_gui:getGuiSize(layerSelectorContent)
            end
            if isElement(decalSelector) then
                local w, h = exports.am_gui:getGuiSize(decalSelector)
                h = h - 105
                
                local xlength = ((w - 5)/105)
                local ylength = ((h - 5)/105)

                if ((decalScroll*ylength) + (xlength * ylength)) <= #decalContainer[categoryContainer[selectedCategory]] then
                    decalScroll = decalScroll + 1
                    createDecalSelectorContentSticker()
                end
            elseif decalPlacing then
                if getKeyState("lshift") then
                    decalPlaceRot = (decalPlaceRot - 5) % 360
                else
                    decalPlacingSize = math.max(32, decalPlacingSize - 5)
                end
            elseif isElement(layerSelectorContent) and cx >= x and cx <= x + w and cy >= y and cy <= y + h then
                layerScroll = layerScroll + 1
                if layerScroll + 7 > #layers then
                    layerScroll = #layers - 7
                end
                createLayerSelector()
            else
                refreshNextFrame = true
                camZoom = camZoom + 0.1
                if camZoom > 2.75 then
                    camZoom = 2.75
                end
            end
        elseif key == "mouse_wheel_up" then
            local x, y = 0, 0
            local w, h = 0, 0
            if isElement(layerSelectorContent) then
                x, y = exports.am_gui:getGuiPosition(layerSelectorContent)
                w, h = exports.am_gui:getGuiSize(layerSelectorContent)
            end
            if isElement(decalSelector) then
                if decalScroll - 1 >= 0 then
                    decalScroll = decalScroll - 1
                    createDecalSelectorContentSticker()
                end
            elseif decalPlacing then
                if getKeyState("lshift") then
                    decalPlaceRot = (decalPlaceRot + 5) % 360
                else
                    decalPlacingSize = math.min(256, decalPlacingSize + 5)
                end
            elseif isElement(layerSelectorContent) and cx >= x and cx <= x + w and cy >= y and cy <= y + h then
                layerScroll = layerScroll - 1
                if layerScroll < 0 then
                    layerScroll = 0
                end
                createLayerSelector()
            else
                refreshNextFrame = true
                camZoom = camZoom - 0.1
                if camZoom < 1 then
                    camZoom = 1 
                end
            end
        elseif isElement(editor) then
            if key == "delete" then
                triggerEvent("customPJ:deleteLayer", getRootElement())
                cancelEvent()
            elseif key == "c" and getKeyState("lctrl") then
                triggerEvent("customPJ:copyLayer", getRootElement())
                cancelEvent()
            elseif key == "t" then
                triggerEvent("customPJ:openNewTextLayerPanel", getRootElement())
                cancelEvent()
            elseif key == "n" and getKeyState("lctrl") then
                triggerEvent("customPJ:newLayer", getRootElement())
                cancelEvent()
            elseif key == "m" then
                movingMode = "move"
                exports.am_gui:setImageColor(toolbarToggles[1], "accent")
                exports.am_gui:setImageColor(toolbarToggles[2], "#ffffff")
                exports.am_gui:setImageColor(toolbarToggles[3], "#ffffff")
                cancelEvent()
            elseif key == "s" then
                if getKeyState("lctrl") then
                    triggerEvent("customPJ:save", getRootElement())
                else
                    movingMode = "resize"
                    exports.am_gui:setImageColor(toolbarToggles[1], "#ffffff")
                    exports.am_gui:setImageColor(toolbarToggles[2], "accent")
                    exports.am_gui:setImageColor(toolbarToggles[3], "#ffffff")
                end
                cancelEvent()
            elseif key == "r" then
                movingMode = "rotate"
                exports.am_gui:setImageColor(toolbarToggles[1], "#ffffff")
                exports.am_gui:setImageColor(toolbarToggles[2], "#ffffff")
                exports.am_gui:setImageColor(toolbarToggles[3], "accent")
                cancelEvent()
            elseif key == "e" then
                triggerEvent("editLayer", getRootElement())
                cancelEvent()
            end 
        end
    end
end

function clickEditor(key, state)
    if state == "down" then
        if key == "left" then
            if decalPlacing and uvX then
                table.insert(layers, 1, {
                    uvX - decalPlacingSize/2, uvY - decalPlacingSize/2, 
                    decalPlacingSize, decalPlacingSize, 
                    decalPlaceRot + uvR,
                    (type(decalToPlace) == "table" and (decalToPlace[1] .. "/" .. decalToPlace[2] .. ".dds") or decalToPlace), 
                    {decalPlacing[1], decalPlacing[2], decalPlacing[3], decalPlacing[4]},
                    false, false, false, false,
                    type(decalToPlace) == "string",
                    decalPlacing[5]
                })
                newLayerCount = newLayerCount + 1
                decalToPlace = false
                decalPlacing = false
                decalPlacingSize = 128
                createLayerSelector()
            elseif hoveringLayer then
                movingLayer = hoveringLayer
            end
        end
    elseif state == "up" then
        if movingLayer and key == "left" then
            movingLayer = false
        end
    end
end

function enterEditor()
    colorSchemes = exports.am_gui:getColorSchemes()
    local pedveh = getPedOccupiedVehicle(localPlayer)
    if pedveh then
        local pedvehmodel = getElementModel(pedveh)
        if remapContainer[pedvehmodel] then
            editorState = true
            drawRT = true
            
            saveFakeScreenSource = dxCreateScreenSource(screenX, screenY)
            dxUpdateScreenSource(saveFakeScreenSource, true)
            dxDrawImage(0, 0, screenX, screenY, saveFakeScreenSource)

            veh = pedveh
            vehColor = {255, 255, 255}
            minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(veh)

            shader = dxCreateShader(shaderRaw)

            renderTarget = dxCreateRenderTarget(1024, 1024)
            renderTargetX = dxCreateRenderTarget(screenX, screenY, true)
            renderTargetY = dxCreateRenderTarget(screenX, screenY, true)

            dxSetShaderValue(shader, "Tex0", renderTarget)
            dxSetShaderValue(shader, "secondRTX", renderTargetX)
            dxSetShaderValue(shader, "secondRTY", renderTargetY)

            engineApplyShaderToWorldTexture(shader, remapContainer[pedvehmodel], veh)
            engineApplyShaderToWorldTexture(shader, "#" .. utf8.sub(remapContainer[pedvehmodel], 2), veh)

            local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4 = getVehicleColor(veh, true)
            setElementData(veh, "restoreColor", {r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4}, false)
            setVehicleColor(veh, 255, 255, 255, r2, g2, b2, r3, g3, b3, r4, g4, b4)

            createGui()
            createLayerSelector()

            loadTheDecals()

            addEventHandler("onClientRender", getRootElement(), renderEditor)
            addEventHandler("onClientPreRender", getRootElement(), preRenderEditor)
            addEventHandler("onClientKey", getRootElement(), keyEditor)
            addEventHandler("onClientClick", getRootElement(), clickEditor)
            addEventHandler("onClientRestore", getRootElement(), restoreEditor)
        end
    end
end

function createLayerSelector()
    if not isElement(layerSelector) then
        layerSelector = exports.am_gui:createGuiElement("rectangle", 20, 20, 300, 500, editor)
        exports.am_gui:setGuiBackground(layerSelector, "solid", "grey2")
        local header = exports.am_gui:createGuiElement("rectangle", 0, 0, 300, 35, layerSelector)
        exports.am_gui:setGuiBackground(header, "solid", "grey")
        local label = exports.am_gui:createGuiElement("label", 125, 0, 300, 35, header)
        exports.am_gui:setLabelText(label, "Rétegek")
        exports.am_gui:setLabelFont(label, "14/BebasNeueRegular")

        local hr = exports.am_gui:createGuiElement("rectangle", 0, 33, 300, 2, header)
        exports.am_gui:setGuiBackground(hr, "solid", "grey")

        layersFooter = exports.am_gui:createGuiElement("rectangle", 0, 0, 300, 30, layerSelector)
        exports.am_gui:setGuiBackground(layersFooter, "solid", "grey")
        footerLabel = exports.am_gui:createGuiElement("label", 5, 0, 300, 30, layersFooter)
        exports.am_gui:setLabelText(footerLabel, "0 réteg")
        exports.am_gui:setLabelFont(footerLabel, "11/BebasNeueRegular")
        local newLayer = exports.am_gui:createGuiElement("image", 272, 3, 24, 24, layersFooter)
        exports.am_gui:setImageFile(newLayer, exports.am_gui:getFaIconFilename("plus", 24))
        exports.am_gui:setGuiHover(newLayer, "solid", "primary")
        exports.am_gui:setGuiTooltip(newLayer, "Új réteg (CTRL + N)")
        exports.am_gui:setClickEvent(newLayer, "customPJ:newLayer")
        exports.am_gui:setClickSound(newLayer, "sounds/selectdone.wav")
        local newText = exports.am_gui:createGuiElement("image", 272 - 28, 3, 24, 24, layersFooter)
        exports.am_gui:setImageFile(newText, exports.am_gui:getFaIconFilename("heading", 24))
        exports.am_gui:setGuiHover(newText, "solid", "accent")
        exports.am_gui:setGuiTooltip(newText, "Új szöveges réteg (T)")
        exports.am_gui:setClickSound(newText, "sounds/selectdone.wav")
        exports.am_gui:setClickEvent(newText, "customPJ:openNewTextLayerPanel")
        local copy = exports.am_gui:createGuiElement("image", 272 - 56, 3, 24, 24, layersFooter)
        exports.am_gui:setImageFile(copy, exports.am_gui:getFaIconFilename("copy", 24))
        exports.am_gui:setGuiHover(copy, "solid", "accent")
        exports.am_gui:setGuiTooltip(copy, "Másolás (CTRL + C)")
        exports.am_gui:setClickEvent(copy, "customPJ:copyLayer")
        exports.am_gui:setClickSound(copy, "sounds/selectdone.wav")
        local delete = exports.am_gui:createGuiElement("image", 272 - 84, 3, 24, 24, layersFooter)
        exports.am_gui:setImageFile(delete, exports.am_gui:getFaIconFilename("trash-alt", 24))
        exports.am_gui:setGuiHover(delete, "solid", "red")
        exports.am_gui:setGuiTooltip(delete, "Törlés (DELETE)")
        exports.am_gui:setClickEvent(delete, "customPJ:deleteLayer")
        exports.am_gui:setClickSound(delete, "sounds/selectdone.wav")
    end

    local h = 65 
    h = h + (math.min(#layers, 7) * 80)
    
    if isElement(layerSelectorContent) then
        destroyElement(layerSelectorContent)
    end
    layerSelectorContent = exports.am_gui:createGuiElement("null", 0, 35, 300, h - 65, layerSelector)

    layerElements = {}
    for i = 1, 7 do
        if layers[i] then
            local layer = layerScroll + i
            if i ~= #layers then
                local hr = exports.am_gui:createGuiElement("rectangle", 0, i * 80, 300, 1, layerSelectorContent)
                exports.am_gui:setGuiBackground(hr, "solid", "grey")
            end

            local bg = exports.am_gui:createGuiElement("rectangle", 0, (i-1) * 80, 300, 80, layerSelectorContent)
            if layers[layer] and selectedLayer == layer then
                exports.am_gui:setGuiBackground(bg, "solid", "grey3")
                exports.am_gui:setGuiHover(bg, "solid", "grey4")
            else
                exports.am_gui:setGuiBackground(bg, "solid", "grey2")
                exports.am_gui:setGuiHover(bg, "solid", "grey3")
            end
            if layers[layer] then
                exports.am_gui:setClickEvent(bg, "selectLayer")
                exports.am_gui:setClickSound(bg, "sounds/selectdone.wav")
                local imgbg = exports.am_gui:createGuiElement("rectangle", 5, 5, 70, 70, bg)
                exports.am_gui:setGuiBackground(imgbg, "solid", "grey")
                local img = exports.am_gui:createGuiElement("image", 5, 5, 60, 60, imgbg)
                if layers[layer][12] then
                    exports.am_gui:setImageFile(img, decals[layers[layer][6]][1])
                else
                    exports.am_gui:setImageFile(img, ":see_custompj/files/decals/128/" .. layers[layer][6])
                end
                exports.am_gui:setImageColor(img, {layers[layer][7][1], layers[layer][7][2], layers[layer][7][3]})
                exports.am_gui:setGuiAlpha(img, layers[layer][7][4])

                local label = exports.am_gui:createGuiElement("label", 80, 12, 200, 40, imgbg)
                
                if layers[layer][12] then
                    exports.am_gui:setLabelText(label, "Egyedi szöveg")
                else
                    exports.am_gui:setLabelText(label, categoryNameContainer[split(layers[layer][6], "/")[1]])
                end
                exports.am_gui:setLabelAlignment(label, "left", "top")
                exports.am_gui:setLabelFont(label, "12/BebasNeueRegular")
                exports.am_gui:setLabelColor(label, {120, 120, 120})
                local label = exports.am_gui:createGuiElement("label", 80, 14, 200, 40, imgbg)
                exports.am_gui:setLabelText(label, layers[layer][13])
                exports.am_gui:setLabelAlignment(label, "left", "bottom")
                exports.am_gui:setLabelFont(label, "14/BebasNeueRegular")

                local movedown = exports.am_gui:createGuiElement("image", 235, 45, 30, 30, bg)
                exports.am_gui:setImageFile(movedown, exports.am_gui:getFaIconFilename("caret-down", 30))
                exports.am_gui:setGuiHover(movedown, "solid", "primary")
                exports.am_gui:setClickEvent(movedown, "move:moveDown")
                exports.am_gui:setClickSound(movedown, "sounds/selectdone.wav")

                local moveup = exports.am_gui:createGuiElement("image", 265, 45, 30, 30, bg)
                exports.am_gui:setImageFile(moveup, exports.am_gui:getFaIconFilename("caret-up", 30))
                exports.am_gui:setGuiHover(moveup, "solid", "primary")
                exports.am_gui:setClickEvent(moveup, "move:moveUp")
                exports.am_gui:setClickSound(moveup, "sounds/selectdone.wav")
                table.insert(layerElements, {layer, bg, moveup, movedown})
            end
        end
    end

    if #layers > 7 then
        local sb = exports.am_gui:createGuiElement("rectangle", 298, ((h-65)/#layers) * layerScroll, 2, ((h-65)/#layers) * 7, layerSelectorContent)
        exports.am_gui:setGuiBackground(sb, "solid", "primary")
        exports.am_gui:guiToFront(sb)
    end

    exports.am_gui:setGuiSize(layerSelector, 300, h)
    exports.am_gui:setGuiPosition(layersFooter, 0, h - 30)
    
    exports.am_gui:setLabelText(footerLabel, #layers .. " réteg")
end

function createGui()
    editor = exports.am_gui:createGuiElement("null", 0, 0, screenX, screenY)
    toolbar = exports.am_gui:createGuiElement("rectangle", screenX/2 - 464/2, screenY - 50, 465, 40, editor)
    exports.am_gui:setGuiBackground(toolbar, "solid", "grey")
    local move = exports.am_gui:createGuiElement("image", 5, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(move, exports.am_gui:getFaIconFilename("arrows-alt", 30))
    exports.am_gui:setGuiHover(move, "solid", "primary")
    exports.am_gui:setGuiTooltip(move, "Mozgatás (M)")
    exports.am_gui:setClickEvent(move, "movingMode:move")
    exports.am_gui:setClickSound(move, "sounds/selectdone.wav")
    toolbarToggles[1] = move
    local resize = exports.am_gui:createGuiElement("image", 40, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(resize, exports.am_gui:getFaIconFilename("compress-alt", 30))
    exports.am_gui:setGuiHover(resize, "solid", "primary")
    exports.am_gui:setGuiTooltip(resize, "Méretezés (S)")
    exports.am_gui:setClickEvent(resize, "movingMode:resize")
    exports.am_gui:setClickSound(resize, "sounds/selectdone.wav")
    toolbarToggles[2] = resize
    local rotate = exports.am_gui:createGuiElement("image", 75, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(rotate, exports.am_gui:getFaIconFilename("undo", 30))
    exports.am_gui:setGuiHover(rotate, "solid", "primary")
    exports.am_gui:setGuiTooltip(rotate, "Forgatás (R)")
    exports.am_gui:setClickEvent(rotate, "movingMode:rotate")
    exports.am_gui:setClickSound(rotate, "sounds/selectdone.wav")
    toolbarToggles[3] = rotate

    local hr = exports.am_gui:createGuiElement("rectangle", 105, 5, 2, 30, toolbar)
    exports.am_gui:setGuiBackground(hr, "solid", "grey2")

    local hlt = exports.am_gui:createGuiElement("image", 110, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(hlt, exports.am_gui:getFaIconFilename("layer-group", 30))
    exports.am_gui:setGuiHover(hlt, "solid", "accent2")
    exports.am_gui:setGuiTooltip(hlt, "Kijelölt réteg kiemelése")
    exports.am_gui:setClickEvent(hlt, "customPJ:highlight")
    exports.am_gui:setClickSound(hlt, "sounds/selectdone.wav")
    toolbarToggles[4] = hlt
    local mv = exports.am_gui:createGuiElement("image", 145, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(mv, ":see_custompj/files/mv.png")
    exports.am_gui:setGuiHover(mv, "solid", "accent2")
    exports.am_gui:setGuiTooltip(mv, "Függőleges tükrözés")
    exports.am_gui:setClickEvent(mv, "customPJ:mv")
    exports.am_gui:setClickSound(mv, "sounds/selectdone.wav")
    toolbarToggles[5] = mv
    local mh = exports.am_gui:createGuiElement("image", 180, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(mh, ":see_custompj/files/mh.png")
    exports.am_gui:setGuiHover(mh, "solid", "accent2")
    exports.am_gui:setGuiTooltip(mh, "Vízszintes tükrözés")
    exports.am_gui:setClickEvent(mh, "customPJ:mh")
    exports.am_gui:setClickSound(mh, "sounds/selectdone.wav")
    toolbarToggles[6] = mh
    local mirrorcar = exports.am_gui:createGuiElement("image", 215, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(mirrorcar, exports.am_gui:getFaIconFilename("car-side", 30))
    exports.am_gui:setGuiHover(mirrorcar, "solid", "accent2")
    exports.am_gui:setGuiTooltip(mirrorcar, "Tükrözés az autó másik oldalára")
    exports.am_gui:setClickEvent(mirrorcar, "customPJ:mirrorcar")
    exports.am_gui:setClickSound(mirrorcar, "sounds/selectdone.wav")
    toolbarToggles[7] = mirrorcar
    local mirrorcar2 = exports.am_gui:createGuiElement("image", 250, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(mirrorcar2, exports.am_gui:getFaIconFilename("car-side", 30))
    exports.am_gui:setGuiHover(mirrorcar2, "solid", "accent2")
    exports.am_gui:setGuiTooltip(mirrorcar2, "Másolás az autó másik oldalára")
    exports.am_gui:setClickEvent(mirrorcar2, "customPJ:mirrorcar2")
    exports.am_gui:setClickSound(mirrorcar2, "sounds/selectdone.wav")
    toolbarToggles[8] = mirrorcar2
    local edit = exports.am_gui:createGuiElement("image", 285, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(edit, exports.am_gui:getFaIconFilename("edit", 30))
    exports.am_gui:setGuiHover(edit, "solid", "accent2")
    exports.am_gui:setGuiTooltip(edit, "Réteg szerkesztése (E)")
    exports.am_gui:setClickEvent(edit, "editLayer")
    exports.am_gui:setClickSound(edit, "sounds/selectdone.wav")
    local color = exports.am_gui:createGuiElement("image", 320, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(color, exports.am_gui:getFaIconFilename("palette", 30))
    exports.am_gui:setGuiHover(color, "solid", "accent2")
    exports.am_gui:setGuiTooltip(color, "Jármű fényezése, textúrája")
    exports.am_gui:setClickEvent(color, "customPJ:color")
    exports.am_gui:setClickSound(color, "sounds/selectdone.wav")

    local hr = exports.am_gui:createGuiElement("rectangle", 355, 5, 2, 30, toolbar)
    exports.am_gui:setGuiBackground(hr, "solid", "grey2")

    local color = exports.am_gui:createGuiElement("image", 360, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(color, exports.am_gui:getFaIconFilename("folder-open", 30))
    exports.am_gui:setGuiHover(color, "solid", "accent")
    exports.am_gui:setGuiTooltip(color, "Mentett paintjobok")
    exports.am_gui:setClickEvent(color, "decalEditorOpenPaintjob")
    exports.am_gui:setClickSound(color, "sounds/selectdone.wav")
    local save = exports.am_gui:createGuiElement("image", 395, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(save, exports.am_gui:getFaIconFilename("save", 30))
    exports.am_gui:setGuiHover(save, "solid", "accent")
    exports.am_gui:setGuiTooltip(save, "Mentés (CTRL + S)")
    exports.am_gui:setClickEvent(save, "customPJ:save")
    exports.am_gui:setClickSound(save, "sounds/selectdone.wav")
    local exit = exports.am_gui:createGuiElement("image", 430, 5, 30, 30, toolbar)
    exports.am_gui:setImageFile(exit, exports.am_gui:getFaIconFilename("sign-out-alt", 30))
    exports.am_gui:setGuiHover(exit, "solid", "red")
    exports.am_gui:setGuiTooltip(exit, "Kilépés")
    exports.am_gui:setClickEvent(exit, "customPJ:exit")
    exports.am_gui:setClickSound(exit, "sounds/selectdone.wav")
    
    processToolbarToggles()
end

function processToolbarToggles()
    exports.am_gui:setImageColor(toolbarToggles[1], "#ffffff")
    exports.am_gui:setImageColor(toolbarToggles[2], "#ffffff")
    exports.am_gui:setImageColor(toolbarToggles[3], "#ffffff")
    exports.am_gui:setImageColor(toolbarToggles[4], "#ffffff")
    exports.am_gui:setImageColor(toolbarToggles[5], "#ffffff")
    exports.am_gui:setImageColor(toolbarToggles[6], "#ffffff")
    exports.am_gui:setImageColor(toolbarToggles[7], "#ffffff")
    exports.am_gui:setImageColor(toolbarToggles[8], "#ffffff")
    if movingMode == "move" then
        exports.am_gui:setImageColor(toolbarToggles[1], "accent")
    elseif movingMode == "resize" then
        exports.am_gui:setImageColor(toolbarToggles[2], "accent")
    elseif movingMode == "rotate" then
        exports.am_gui:setImageColor(toolbarToggles[3], "accent")
    end
    
    if selectedLayer and layers[selectedLayer] then
        local layer = layers[selectedLayer]
        if layer[8] then
            exports.am_gui:setImageColor(toolbarToggles[6], "accent")
        end
        if layer[9] then
            exports.am_gui:setImageColor(toolbarToggles[5], "accent")
        end
        if layer[10] then
            exports.am_gui:setImageColor(toolbarToggles[7], "accent")
        end
        if layer[11] then
            exports.am_gui:setImageColor(toolbarToggles[8], "accent")
        end
    end 

    if highlight then
        exports.am_gui:setImageColor(toolbarToggles[4], "accent")
    else
        exports.am_gui:setImageColor(toolbarToggles[4], "#ffffff")
    end
end

addEvent("customPJ:selectSticker", true)
addEventHandler("customPJ:selectSticker", getRootElement(),
    function(guiElement)
        local w, h = exports.am_gui:getGuiSize(decalSelector)
        h = h - 105
    
        local ylength = ((h - 5)/105)

        for i = 1, #decalSelectorElements do
            if decalSelectorElements[i][2] == guiElement then
                local realSticker = i + (decalScroll*ylength)
                
                destroyElement(decalSelector)
                createLayerEditor(":see_custompj/files/decals/256/" .. categoryContainer[selectedCategory] .. "/" .. decalContainer[categoryContainer[selectedCategory]][realSticker][1])
                decalToPlace = {categoryContainer[selectedCategory], string.gsub(decalContainer[categoryContainer[selectedCategory]][realSticker][1], ".dds", "")}
            end
        end
    end
)

addEvent("customPJ:hoverSticker", true)
addEventHandler("customPJ:hoverSticker", getRootElement(),
    function(guiElement, isHover)
        if isHover then
            exports.am_gui:setGuiAlphaAnimated(guiElement, 255, 100)
        else
            exports.am_gui:setGuiAlphaAnimated(guiElement, 150, 100)
        end
    end
)

addEvent("customPJ:exit", true)
addEventHandler("customPJ:exit", getRootElement(),
    function()
        closeEditor()
    end
)

addEvent("customPJ:newLayer", true)
addEventHandler("customPJ:newLayer", getRootElement(),
    function()
        destroyElement(editor)

        local w, h = (screenX*0.7 - (screenX*0.7%105)) + 5, (screenY*0.7 - (screenY*0.7%105)) + 110
        if w < 957 then
            w = (1024 - (1024%105)) + 5
        end
        
        decalSelector = exports.am_gui:createGuiElement("rectangle", screenX/2-w/2, screenY/2-h/2, w, h)
        exports.am_gui:setGuiBackground(decalSelector, "solid", "grey3")
        local header = exports.am_gui:createGuiElement("rectangle", 0, 0, w, 40, decalSelector)
        exports.am_gui:setGuiBackground(header, "solid", "grey")
        local label = exports.am_gui:createGuiElement("label", 36, 0, w, 40, header)
        exports.am_gui:setLabelText(label, "Matrica kiválasztása")
        exports.am_gui:setLabelFont(label, "18/BebasNeueRegular")
        local labelimg = exports.am_gui:createGuiElement("image", 2, 2, 36, 36, header)
        exports.am_gui:setImageFile(labelimg, exports.am_gui:getFaIconFilename("star", 36))
        
        local image = exports.am_gui:createGuiElement("image", w - 32 - 4, 4, 32, 32, decalSelector)
        exports.am_gui:setImageFile(image, exports.am_gui:getFaIconFilename("times", 32))
        exports.am_gui:setGuiHover(image, "solid", "red")
        exports.am_gui:setClickEvent(image, "returnToTheMainPaintjobPage3")
        exports.am_gui:setClickSound(image, "sounds/selectdone.wav")
        exports.am_gui:guiToFront(image)

        local categorysbg = exports.am_gui:createGuiElement("rectangle", 0, 40, w, 65, decalSelector)
        exports.am_gui:setGuiBackground(categorysbg, "solid", "grey2")

        local x = 5
        local y = 0
        categoryElements = {}
        for i, category in pairs(categoryContainer) do
            local categoryName = categoryNameContainer[category]
            local textW = dxGetTextWidth(categoryName, 1, Ubuntu12) + 5

            if x + textW > w then
                x = 5
                y = 35
            end

            local categorybg = exports.am_gui:createGuiElement("rectangle", x, y, textW, 30, categorysbg)
            exports.am_gui:setGuiBackground(categorybg, "solid", "grey3")
            exports.am_gui:setGuiHover(categorybg, "solid", "grey4")
            exports.am_gui:setClickEvent(categorybg, "customPJ:selectCategory")
            exports.am_gui:setClickSound(categorybg, "sounds/selectdone.wav")
            local label = exports.am_gui:createGuiElement("label", 0, 0, textW, 30, categorybg)
            exports.am_gui:setLabelText(label, categoryName)
            exports.am_gui:setLabelFont(label, "12/BebasNeueRegular")
            exports.am_gui:setLabelAlignment(label, "center", "center")

            x = x + textW + 5
            table.insert(categoryElements, {i, categorybg})
        end

        --local button = exports.am_gui:createGuiElement("image", 0, 0, 24, 24, categorysbg)
        --exports.am_gui:setImageFile(button, exports.am_gui:getFaIconFilename("caret-left", 280))
        --exports.am_gui:setGuiBackground(button, "solid", "primary")
        --exports.am_gui:setGuiHover(button, "gradient", {"primary", "accent"}, 60)
        --local button = exports.am_gui:createGuiElement("image", w - 24, 0, 24, 24, categorysbg)
        --exports.am_gui:setImageFile(button, exports.am_gui:getFaIconFilename("caret-right", 280))
        --exports.am_gui:setGuiBackground(button, "solid", "primary")
        --exports.am_gui:setGuiHover(button, "gradient", {"primary", "accent"}, 60)

        local hr = exports.am_gui:createGuiElement("rectangle", 0, 105, w, 2, decalSelector)
        exports.am_gui:setGuiBackground(hr, "solid", "grey2")

        createDecalSelectorContent()
    end
)

function hue2rgb(m1, m2, h)
	if h < 0 then
		h = h + 1
	elseif 1 < h then
		h = h - 1
	end
	if 1 > h * 6 then
		return m1 + (m2 - m1) * h * 6
	elseif 1 > h * 2 then
		return m2
	elseif 2 > h * 3 then
		return m1 + (m2 - m1) * (0.6666666666666666 - h) * 6
	else
		return m1
	end
end
function convertHSLToRGB(h, s, l)
	local m2
	if l < 0.5 then
		m2 = l * (s + 1)
	else
		m2 = l + s - l * s
	end
	local m1 = l * 2 - m2
	local r = hue2rgb(m1, m2, h + 0.3333333333333333) * 255
	local g = hue2rgb(m1, m2, h) * 255
	local b = hue2rgb(m1, m2, h - 0.3333333333333333) * 255
	return math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5)
end
function convertRGBToHSL(r, g, b)
	r = r / 255
	g = g / 255
	b = b / 255
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s
	local l = (max + min) / 2
	if max == min then
		h = 0
		s = 0
	else
		local d = max - min
		s = 0.5 < l and d / (2 - max - min) or d / (max + min)
		if max == r then
			h = (g - b) / d + (g < b and 6 or 0)
		end
		if max == g then
			h = (b - r) / d + 2
		end
		if max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end
	return h, s, l
end

function rgbToHex(r, g, b)
    local function toHex(value)
        local hex = string.format("%02X", value)
        return hex
    end
    
    local hexR = toHex(r)
    local hexG = toHex(g)
    local hexB = toHex(b)
    
    local hexColor = "#" .. hexR .. hexG .. hexB
    return hexColor
end

function refreshNewDecalColorPickerBcg(refreshInput)
    local h = exports.am_gui:getSliderValue(sliderH) or 0
    local s = exports.am_gui:getSliderValue(sliderS) or 1
    local l = exports.am_gui:getSliderValue(sliderL) or 0.5
    local o = isElement(sliderO) and exports.am_gui:getSliderValue(sliderO) or 1
    local fR, fG, fB = convertHSLToRGB(h, s, l)

    exports.am_gui:setGuiBackground(bcgH1, "solid", {convertHSLToRGB(0, 0, l)})
    exports.am_gui:setImageColor(bcgH2, {255, 255, 255, s * 255})
    local r, g, b = convertHSLToRGB(0, 0, l)
    local a = math.abs(l - 0.5) / 0.5 * 255
    exports.am_gui:setGuiBackground(bcgH3, "solid", {r, g, b})
    exports.am_gui:setGuiAlpha(bcgH3, a)

    exports.am_gui:setGuiBackground(bcgS1, "solid", {convertHSLToRGB(h, 0, l)})
    exports.am_gui:setImageColor(bcgS2, {convertHSLToRGB(h, 1, l)})

    exports.am_gui:setImageColor(bcgL3, {convertHSLToRGB(h, s, 0.5)})
    if isElement(sliderO) then
        exports.am_gui:setImageColor(bcgO2, {fR, fG, fB})
        exports.am_gui:setSliderColor(sliderO, {fR, fG, fB})
    end

    exports.am_gui:setSliderColor(sliderH, {fR, fG, fB})
    exports.am_gui:setSliderColor(sliderS, {fR, fG, fB})
    exports.am_gui:setSliderColor(sliderL, {fR, fG, fB})

    if refreshInput then
        exports.am_gui:setInputValue(newDecalColorInput, utf8.sub(rgbToHex(fR, fG, fB), 2, 7))
    end

    if isElement(layerPreview) then
        exports.am_gui:setImageColor(layerPreview, {fR, fG, fB})
        exports.am_gui:setGuiAlpha(layerPreview, o * 255)
    end
end

addEvent("newDecalColorPickerChanged", true)
addEventHandler("newDecalColorPickerChanged", getRootElement(),
    function()
        refreshNewDecalColorPickerBcg(true)
    end
)

addEvent("refreshNewDecalColorInput", true)
addEventHandler("refreshNewDecalColorInput", getRootElement(),
    function(val)
        local val = exports.am_gui:getInputValue(newDecalColorInput)
        exports.am_gui:setInputValue(newDecalColorInput, utf8.upper(val))
        local r = tonumber("0x" .. val:sub(1, 2))
        local g = tonumber("0x" .. val:sub(3, 4))
        local b = tonumber("0x" .. val:sub(5, 6))
        
        if r and g and b then
            local h, s, l = convertRGBToHSL(r, g, b)
            exports.am_gui:setSliderValue(sliderH, h) 
            exports.am_gui:setSliderValue(sliderS, s) 
            exports.am_gui:setSliderValue(sliderL, l) 
            refreshNewDecalColorPickerBcg()
        end
    end
)

addEvent("confirmLayerEdit", true)
addEventHandler("confirmLayerEdit", getRootElement(),
    function()
        local val = exports.am_gui:getInputValue(newDecalColorInput)
        local r = tonumber("0x" .. val:sub(1, 2))
        local g = tonumber("0x" .. val:sub(3, 4))
        local b = tonumber("0x" .. val:sub(5, 6))
        if decalToPlace then
            local a = ((isElement(sliderO) and exports.am_gui:getSliderValue(sliderO)) or 1) * 255
            decalPlacing = {r, g, b, a, exports.am_gui:getInputValue(layerNameInput)}
            destroyElement(layerEditor)
            createGui()
            createLayerSelector()
        else
            local a = ((isElement(sliderO) and exports.am_gui:getSliderValue(sliderO)) or 1) * 255
            local name = exports.am_gui:getInputValue(layerNameInput) or "false"

            layers[selectedLayer][13] = name
            layers[selectedLayer][7] = {r, g, b, a}

            destroyElement(layerEditor)
            createGui()
            createLayerSelector()
        end
        pushToDecalColor(r, g, b)
    end
)

addEvent("confirmColorEdit", true)
addEventHandler("confirmColorEdit", getRootElement(),
    function()
        local val = exports.am_gui:getInputValue(newDecalColorInput)
        local name = exports.am_gui:getInputValue(layerNameInput)
        local r = tonumber("0x" .. val:sub(1, 2))
        local g = tonumber("0x" .. val:sub(3, 4))
        local b = tonumber("0x" .. val:sub(5, 6))

        vehColor = {r, g, b}
        carBG = carBackgroundTexture
        carBackgroundSize = 128 + (((isElement(sliderBackgroundSize) and exports.am_gui:getSliderValue(sliderBackgroundSize)) or 1) * 128)
        
        destroyElement(layerEditor)
        createGui()
        createLayerSelector()
        pushToDecalColor(r, g, b)
    end
)

addEvent("editLayer", true)
addEventHandler("editLayer", getRootElement(),
    function()
        if selectedLayer then
            destroyElement(editor)
            if utfSub(layers[selectedLayer][6], 1, 10) == "customtext" then
                createLayerEditor(decals[layers[selectedLayer][6]][1], layers[selectedLayer][7][1], layers[selectedLayer][7][2], layers[selectedLayer][7][3], layers[selectedLayer][7][4], layers[selectedLayer][13])
            else
                createLayerEditor(":see_custompj/files/decals/128/" .. layers[selectedLayer][6], layers[selectedLayer][7][1], layers[selectedLayer][7][2], layers[selectedLayer][7][3], layers[selectedLayer][7][4], layers[selectedLayer][13])
            end
        end
    end
)

addEvent("selectLayer", true)
addEventHandler("selectLayer", getRootElement(),
    function(guiElement)
        for i = 1, #layerElements do
            if layerElements[i][2] == guiElement and (not selectedLayer or selectedLayer ~= layerElements[i][1]) then
                selectedLayer = layerElements[i][1]
                createLayerSelector()
                
                exports.am_gui:setImageColor(toolbarToggles[5], "#ffffff")
                exports.am_gui:setImageColor(toolbarToggles[6], "#ffffff")
                exports.am_gui:setImageColor(toolbarToggles[7], "#ffffff")
                exports.am_gui:setImageColor(toolbarToggles[8], "#ffffff")
                if selectedLayer and layers[selectedLayer] then
                    local layer = layers[selectedLayer]
                    if layer[8] then
                        exports.am_gui:setImageColor(toolbarToggles[6], "accent")
                    end
                    if layer[9] then
                        exports.am_gui:setImageColor(toolbarToggles[5], "accent")
                    end
                    if layer[10] then
                        exports.am_gui:setImageColor(toolbarToggles[7], "accent")
                    end
                    if layer[11] then
                        exports.am_gui:setImageColor(toolbarToggles[8], "accent")
                    end
                end
                break
            end
        end
    end
)

addEvent("movingMode:move", true)
addEventHandler("movingMode:move", getRootElement(),
    function()
        movingMode = "move"
        exports.am_gui:setImageColor(toolbarToggles[1], "accent")
        exports.am_gui:setImageColor(toolbarToggles[2], "#ffffff")
        exports.am_gui:setImageColor(toolbarToggles[3], "#ffffff")
    end
)

addEvent("movingMode:resize", true)
addEventHandler("movingMode:resize", getRootElement(),
    function()
        movingMode = "resize"
        exports.am_gui:setImageColor(toolbarToggles[1], "#ffffff")
        exports.am_gui:setImageColor(toolbarToggles[2], "accent")
        exports.am_gui:setImageColor(toolbarToggles[3], "#ffffff")
    end
)

addEvent("movingMode:rotate", true)
addEventHandler("movingMode:rotate", getRootElement(),
    function()
        movingMode = "rotate"
        exports.am_gui:setImageColor(toolbarToggles[1], "#ffffff")
        exports.am_gui:setImageColor(toolbarToggles[2], "#ffffff")
        exports.am_gui:setImageColor(toolbarToggles[3], "accent")
    end
)

addEvent("customPJ:mh", true)
addEventHandler("customPJ:mh", getRootElement(),
    function()
        if selectedLayer and layers[selectedLayer] then
            layers[selectedLayer][8] = not layers[selectedLayer][8]
            if layers[selectedLayer][9] then
                exports.am_gui:setImageColor(toolbarToggles[6], "accent")
            else
                exports.am_gui:setImageColor(toolbarToggles[6], "#ffffff")
            end
        end
    end
)

addEvent("customPJ:mv", true)
addEventHandler("customPJ:mv", getRootElement(),
    function()
        if selectedLayer and layers[selectedLayer] then
            layers[selectedLayer][9] = not layers[selectedLayer][9]
            if layers[selectedLayer][9] then
                exports.am_gui:setImageColor(toolbarToggles[5], "accent")
            else
                exports.am_gui:setImageColor(toolbarToggles[5], "#ffffff")
            end
        end
    end
)

addEvent("customPJ:highlight", true)
addEventHandler("customPJ:highlight", getRootElement(),
    function()
        highlight = not highlight
        if highlight then
            exports.am_gui:setImageColor(toolbarToggles[4], "accent")
        else
            exports.am_gui:setImageColor(toolbarToggles[4], "#ffffff")
        end
    end
)

function createColorEditor(_, r, g, b, a)
    local w, h = 550, 245
    layerEditor = exports.am_gui:createGuiElement("rectangle", screenX/2-w/2, screenY/2-h/2, w, h)
    exports.am_gui:setGuiBackground(layerEditor, "solid", "grey2")
    layerPreviewBG = exports.am_gui:createGuiElement("rectangle", 8, 8, h-16, h-16, layerEditor)
    exports.am_gui:setGuiBackground(layerPreviewBG, "solid", "grey")
    layerPreview2 = exports.am_gui:createGuiElement("rectangle", 12, 12, h-24, h-24, layerEditor)
    exports.am_gui:setGuiBackground(layerPreview2, "solid", "#ffffff")
    layerPreview = exports.am_gui:createGuiElement("image", 12, 12, h-24, h-24, layerEditor)
    iprint(decalContainer["textures"])
    exports.am_gui:setImageFile(layerPreview, ":see_custompj/files/decals/256/textures/" .. decalContainer["textures"][carBackgroundTexture + 1][1])
    exports.am_gui:guiToFront(layerPreview)

    local bottombar = exports.am_gui:createGuiElement("rectangle", 8, 8 + h - 16 - 32, h - 16, 32, layerEditor)
    exports.am_gui:setGuiBackground(bottombar, "solid", "#000000")
    exports.am_gui:setGuiAlpha(bottombar, 125)
    exports.am_gui:guiToFront(bottombar)
    local label = exports.am_gui:createGuiElement("label", 0, 0, h - 16, 32, bottombar)
    exports.am_gui:setLabelFont(label, "12/BebasNeueRegular")
    exports.am_gui:setLabelText(label, "Mintázat")
    exports.am_gui:setLabelAlignment(label, "center", "center")
    local button = exports.am_gui:createGuiElement("image", 0, 0, 32, 32, bottombar)
    exports.am_gui:setImageFile(button, exports.am_gui:getFaIconFilename("caret-left", 280))
    exports.am_gui:setGuiHover(button, "solid", "primary")
    exports.am_gui:setClickEvent(button, "customPJ:previousTexture")
    exports.am_gui:setClickSound(button, "selectdone.wav")
    local button = exports.am_gui:createGuiElement("image", h - 16 - 32, 0, 32, 32, bottombar)
    exports.am_gui:setImageFile(button, exports.am_gui:getFaIconFilename("caret-right", 280))
    exports.am_gui:setGuiHover(button, "solid", "primary")
    exports.am_gui:setClickEvent(button, "customPJ:nextTexture")
    exports.am_gui:setClickSound(button, "selectdone.wav")

    local layerNameInput = exports.am_gui:createGuiElement("label", h, 8, h + 20, 30, layerEditor)
    exports.am_gui:setLabelText(layerNameInput, "Fényezés")
    exports.am_gui:setLabelFont(layerNameInput, "18/BebasNeueRegular")
    local button = exports.am_gui:createGuiElement("button", h + h + 20, 8, 30, 30, layerEditor)
    exports.am_gui:setGuiBackground(button, "solid", "primary")
    exports.am_gui:setGuiHover(button, "gradient", {"primary", "accent"}, 60)
    exports.am_gui:setClickEvent(button, "confirmColorEdit")
    exports.am_gui:setClickSound(button, "sounds/selectdone.wav")
    local check = exports.am_gui:createGuiElement("image", 5, 5, 20, 20, button)
    exports.am_gui:setImageFile(check, exports.am_gui:getFaIconFilename("check", 20))

    bcgH1 = exports.am_gui:createGuiElement("rectangle", h + 8, 56, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setGuiBackground(bcgH1, "solid", "#000000")
    bcgH2 = exports.am_gui:createGuiElement("image", h + 8, 56, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setImageFile(bcgH2, ":see_custompj/files/col3.dds")
    exports.am_gui:guiToFront(bcgH2)
    bcgH3 = exports.am_gui:createGuiElement("rectangle", h + 8, 56, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:guiToFront(bcgH3)
    sliderH = exports.am_gui:createGuiElement("slider", h + 8, 56 - 4, (w - h - 8) - 16, 20, layerEditor)
    exports.am_gui:setSliderColor(sliderH, {255, 0, 0})
    exports.am_gui:guiToFront(sliderH)
    exports.am_gui:setSliderChangeEvent(sliderH, "newDecalColorPickerChanged")

    bcgS1 = exports.am_gui:createGuiElement("rectangle", h + 8, 84, (w - h - 8) - 16, 12, layerEditor)
    bcgS2 = exports.am_gui:createGuiElement("image", h + 8, 84, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setImageFile(bcgS2, ":see_custompj/files/col1.dds")
    exports.am_gui:guiToFront(bcgS2)
    sliderS = exports.am_gui:createGuiElement("slider", h + 8, 84 - 4, (w - h - 8) - 16, 20, layerEditor)
    exports.am_gui:setSliderColor(sliderS, {0, 0, 0})
    exports.am_gui:guiToFront(sliderS)
    exports.am_gui:setSliderChangeEvent(sliderS, "newDecalColorPickerChanged")
    exports.am_gui:setSliderValue(sliderS, 1)

    bcgL1 = exports.am_gui:createGuiElement("rectangle", h + 8, 112, ((w - h - 8) - 16)/2, 12, layerEditor)
    exports.am_gui:setGuiBackground(bcgL1, "solid", {0, 0, 0})
    bcgL2 = exports.am_gui:createGuiElement("rectangle", h + 8 + ((w - h - 8) - 16)/2, 112, ((w - h - 8) - 16)/2, 12, layerEditor)
    exports.am_gui:setGuiBackground(bcgL2, "solid", {255, 255, 255})
    bcgL3 = exports.am_gui:createGuiElement("image", h + 8, 112, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setImageFile(bcgL3, ":see_custompj/files/col2.dds")
    exports.am_gui:guiToFront(bcgL3)
    sliderL = exports.am_gui:createGuiElement("slider", h + 8, 112 - 4, (w - h - 8) - 16, 20, layerEditor)
    exports.am_gui:setSliderColor(sliderL, {0, 0, 0})
    exports.am_gui:guiToFront(sliderL)
    exports.am_gui:setSliderChangeEvent(sliderL, "newDecalColorPickerChanged")
    exports.am_gui:setSliderValue(sliderL, 1)

    newDecalColorInput = exports.am_gui:createGuiElement("input", h + 8 + ((w - h - 8) - 16)/2 - 80, 140, 160, 30, layerEditor)
    exports.am_gui:setInputPlaceholder(newDecalColorInput, "HEX színkód")
    exports.am_gui:setInputIcon(newDecalColorInput, "fa:hashtag")
    exports.am_gui:setInputMaxLength(newDecalColorInput, 6)
    exports.am_gui:setInputChangeEvent(newDecalColorInput, "refreshNewDecalColorInput")

	local sw = w - h - 8
    local rect = exports.am_gui:createGuiElement("rectangle", h + 8, 175 + 3, 6, 6, layerEditor)
    exports.am_gui:setGuiBackground(rect, "solid", "#ffffff")
    local rect = exports.am_gui:createGuiElement("rectangle", h + sw - 16 - 2, 175, 12, 12, layerEditor)
    exports.am_gui:setGuiBackground(rect, "solid", "#ffffff")
    sliderBackgroundSize = exports.am_gui:createGuiElement("slider", h + 8 + 16, 175, sw - 16 - 32, 12, layerEditor)
    exports.am_gui:setGuiBackground(sliderBackgroundSize, "solid", "grey")
    exports.am_gui:setSliderColor(sliderBackgroundSize, "primary")
    exports.am_gui:setSliderValue(sliderBackgroundSize, 0.5)

    if r and g and b then
        local h, s, l = convertRGBToHSL(r, g, b)
        exports.am_gui:setSliderValue(sliderH, h) 
        exports.am_gui:setSliderValue(sliderS, s) 
        exports.am_gui:setSliderValue(sliderL, l) 
    end

    local c = 1
    local nx, ny = 15, 2
    local h = (h - 200 - 8 + 2) / ny 
    local w = h
    newDecalColorsCount = nx * ny
    newDecalColors = {}
    for j = 0, ny - 1 do
        for i = 0, nx - 1 do
            local rect = exports.am_gui:createGuiElement("rectangle", 250 + i * w + 1, 197 + j * h + 1, w - 2, h - 2, layerEditor)
            if newDecalColorList[c] then
                newDecalColors[rect] = {
                    newDecalColorList[c][1],
                    newDecalColorList[c][2],
                    newDecalColorList[c][3]
                }
                exports.am_gui:setGuiBackground(rect, "solid", newDecalColors[rect])
                exports.am_gui:setClickEvent(rect, "selectNewDecalPreDefinedColor")
                exports.am_gui:setClickSound(rect, "sounds/selectdone.wav")
            else
                exports.am_gui:setGuiBackground(rect, "solid", "grey4")
            end
            c = c + 1
        end
    end

    refreshNewDecalColorPickerBcg(true)
end

function pushToDecalColor(fR, fG, fB)
	local found = false
	for i = 1, #newDecalColorList do
		if fR == newDecalColorList[i][1] and fG == newDecalColorList[i][2] and fB == newDecalColorList[i][3] then
			local tmp = newDecalColorList[i]
			table.remove(newDecalColorList, i)
			table.insert(newDecalColorList, 1, tmp)
			found = true
			break
		end
	end
	if not found then
		table.insert(newDecalColorList, 1, {
			fR,
			fG,
			fB
		})
	end
	if 38 < #newDecalColorList then
		for i = #newDecalColorList, 1, -1 do
			if not newDecalColorList[i][4] then
				table.remove(newDecalColorList, i)
				if #newDecalColorList <= 38 then
					break
				end
			end
		end
	end
end

addEvent("customPJ:color", true)
addEventHandler("customPJ:color", getRootElement(),
    function()
        destroyElement(editor)
        createColorEditor(false, vehColor[1], vehColor[2], vehColor[3])
    end
)

addEvent("customPJ:selectCategory", true)
addEventHandler("customPJ:selectCategory", getRootElement(),
    function(guiElement)
        for i = 1, #categoryElements do
            if categoryElements[i][2] == guiElement then
                decalScroll = 0
                selectedCategory = categoryElements[i][1]
                createDecalSelectorContentSticker()
            end
        end
    end
)

addEvent("customPJ:previousTexture", true)
addEventHandler("customPJ:previousTexture", getRootElement(),
    function()
        carBackgroundTexture = carBackgroundTexture - 1
        if carBackgroundTexture < 0 then
            carBackgroundTexture = #decalContainer["textures"]
        end
        exports.am_gui:setImageFile(layerPreview, ":see_custompj/files/decals/256/textures/" .. decalContainer["textures"][carBackgroundTexture + 1][1])
    end
)

addEvent("customPJ:nextTexture", true)
addEventHandler("customPJ:nextTexture", getRootElement(),
    function()
        carBackgroundTexture = carBackgroundTexture + 1
        if carBackgroundTexture > #decalContainer["textures"] then
            carBackgroundTexture = 0
        end
        exports.am_gui:setImageFile(layerPreview, ":see_custompj/files/decals/256/textures/" .. decalContainer["textures"][carBackgroundTexture + 1][1])
    end
)

function swap(array, index1, index2)
	array[index1], array[index2] = array[index2], array[index1]
end

addEvent("move:moveDown", true)
addEventHandler("move:moveDown", getRootElement(),
    function(guiElement)
        for i = 1, #layerElements do
            if layerElements[i][4] == guiElement then
                if layers[layerElements[i][1] + 1] then
                    selectedLayer = false
                    swap(layers, layerElements[i][1], layerElements[i][1] + 1)
                    createLayerSelector()
                end
            end
        end
    end
)

addEvent("move:moveUp", true)
addEventHandler("move:moveUp", getRootElement(),
    function(guiElement)
        for i = 1, #layerElements do
            if layerElements[i][3] == guiElement then
                if layers[layerElements[i][1] - 1] then
                    selectedLayer = false
                    swap(layers, layerElements[i][1], layerElements[i][1] - 1)
                    createLayerSelector()
                end
            end
        end
    end
)

addEvent("customPJ:deleteLayer", true)
addEventHandler("customPJ:deleteLayer", getRootElement(),
    function()
        if selectedLayer and layers[selectedLayer] then
            table.remove(layers, selectedLayer)
            createLayerSelector()
            exports.am_gui:setImageColor(toolbarToggles[5], "#ffffff")
            exports.am_gui:setImageColor(toolbarToggles[6], "#ffffff")
            exports.am_gui:setImageColor(toolbarToggles[7], "#ffffff")
            exports.am_gui:setImageColor(toolbarToggles[8], "#ffffff")
            selectedLayer = false
        end
    end
)

addEvent("customPJ:copyLayer", true)
addEventHandler("customPJ:copyLayer", getRootElement(),
    function()
        if selectedLayer and layers[selectedLayer] then
            local tmp = {}
            for i = 1, 15 do
                tmp[i] = layers[selectedLayer][i]
            end
            table.insert(layers, selectedLayer, tmp)
            createLayerSelector()
            exports.am_gui:setImageColor(toolbarToggles[5], "#ffffff")
            exports.am_gui:setImageColor(toolbarToggles[6], "#ffffff")
            exports.am_gui:setImageColor(toolbarToggles[7], "#ffffff")
            exports.am_gui:setImageColor(toolbarToggles[8], "#ffffff")
            if selectedLayer and layers[selectedLayer] then
                local layer = layers[selectedLayer]
                if layer[8] then
                    exports.am_gui:setImageColor(toolbarToggles[6], "accent")
                end
                if layer[9] then
                    exports.am_gui:setImageColor(toolbarToggles[5], "accent")
                end
                if layer[10] then
                    exports.am_gui:setImageColor(toolbarToggles[7], "accent")
                end
                if layer[11] then
                    exports.am_gui:setImageColor(toolbarToggles[8], "accent")
                end
            end
        end
    end
)

addEvent("customPJ:mirrorcar", true)
addEventHandler("customPJ:mirrorcar", getRootElement(),
    function()
        if selectedLayer and layers[selectedLayer] then
            layers[selectedLayer][10] = not layers[selectedLayer][10]
            processToolbarToggles()
        end
    end
)

addEvent("customPJ:mirrorcar2", true)
addEventHandler("customPJ:mirrorcar2", getRootElement(),
    function()
        if selectedLayer and layers[selectedLayer] then
            layers[selectedLayer][11] = not layers[selectedLayer][11]
            processToolbarToggles()
        end
    end
)

addEvent("changeNewTextPanelFont", true)
addEventHandler("changeNewTextPanelFont", getRootElement(), 
    function(el)
        if newTextPreviewFontElements[el] then
            newTextPreviewFontId = newTextPreviewFontElements[el]
            for im, i in pairs(newTextPreviewFontElements) do
                if i == newTextPreviewFontId then
                    exports.am_gui:setImageColor(im, "primary")
                else
                    exports.am_gui:setImageColor(im, "#ffffff")
                end
            end
            if isElement(newTextPreviewFont) then
                destroyElement(newTextPreviewFont)
            end
            newTextPreviewFont = dxCreateFont("files/fonts/" .. customTextFonts[newTextPreviewFontId][1], customTextFonts[newTextPreviewFontId][2] * 2, false, "antialiased")
        end
    end
)

addEvent("newTextLayerDone", false)
addEventHandler("newTextLayerDone", getRootElement(), 
    function(button, state, absoluteX, absoluteY, el)
        local text = exports.am_gui:getInputValue(newTextInput)
        if text then
            if isElement(newTextPreviewFont) then
                destroyElement(newTextPreviewFont)
            end
            newTextPreviewFont = false
            decalToPlace = loadCustomTextDecal(text, customTextFonts[newTextPreviewFontId][1], customTextFonts[newTextPreviewFontId][2])
            if decalToPlace then
                createLayerEditor(decals[decalToPlace][1])
                decalPlacingSize = math.min(decalPlacingSize, 64)
                exports.am_gui:setInputValue(layerNameInput, text)
            end
        end
        destroyElement(textPanel)
    end
)

function createNewTextPanel()
    destroyElement(editor)
	local w = 495
	local h = 48 + w / 9 * 2
	local editor = exports.am_gui:createGuiElement("rectangle", screenX / 2 - w / 2, screenY / 2 - h / 2 - 48, w, h)
    textPanel = editor
	exports.am_gui:setGuiBackground(editor, "solid", "grey2")
	local x = 0
	local y = 8
	local sw = w - 16
	newTextInput = exports.am_gui:createGuiElement("input", 8, y, sw - 32 - 8, 32, editor)
	exports.am_gui:setInputPlaceholder(newTextInput, "Szöveg")
	--exports.am_gui:setInputFont(newTextInput, "10/BebasNeueRegular")
	exports.am_gui:setInputIcon(newTextInput, "fa:pencil-alt")
	exports.am_gui:setInputMaxLength(newTextInput, 24)
	local btn = exports.am_gui:createGuiElement("button", 8 + sw - 32, y, 32, 32, editor)
	exports.am_gui:setGuiBackground(btn, "solid", "primary")
	exports.am_gui:setGuiHover(btn, "gradient", {
		"primary",
		"accent"
	}, 60)
	--exports.am_gui:setButtonFont(btn, "12/BebasNeueRegular")
	--exports.am_gui:setButtonIcon(btn, "fa:check")
    local check = exports.am_gui:createGuiElement("image", 5, 5, 20, 20, btn)
    exports.am_gui:setImageFile(check, exports.am_gui:getFaIconFilename("check", 20))
	exports.am_gui:setClickEvent(btn, "newTextLayerDone")
	exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
	y = y + 32 + 8
	newTextPreviewFontElements = {}
	for i = 1, #customTextFonts do
		local im = exports.am_gui:createGuiElement("image", x, y, w / 9, w / 9, editor)
		exports.am_gui:setImageFile(im, ":see_custompj/files/fonts/" .. customTextFonts[i][1] .. ".dds")
		exports.am_gui:setGuiHover(im, "solid", "primary")
		exports.am_gui:setClickEvent(im, "changeNewTextPanelFont")
		exports.am_gui:setClickSound(im, "sounds/selectdone.wav")
		if i == newTextPreviewFontId then
			exports.am_gui:setImageColor(im, "primary")
		else
			--exports.am_gui:setGuiHoverable(im, true)
            --exports.am_gui:setGuiHover(im, "solid", "primary")
            --exports.am_gui:setClickEvent(im, "changeNewTextPanelFont")
            --exports.am_gui:setClickSound(im, "sounds/selectdone.wav")
		end
		newTextPreviewFontElements[im] = i
		x = x + w / 9
		if i == 9 then
			x = 0
			y = y + w / 9
		end
	end
	newTextPreviewFont = dxCreateFont("files/fonts/" .. customTextFonts[newTextPreviewFontId][1], customTextFonts[newTextPreviewFontId][2] * 2, false, "antialiased")
end

addEvent("customPJ:openNewTextLayerPanel", true)
addEventHandler("customPJ:openNewTextLayerPanel", getRootElement(),
    function()
        createNewTextPanel()
    end
)

addEvent("customPJ:save", true)
addEventHandler("customPJ:save", getRootElement(),
    function()
        destroyElement(editor)
        prepareSaveNextFrame = true
        if isElement(saveFakeScreenSource) then
            destroyElement(saveFakeScreenSource)
        end
        saveFakeScreenSource = dxCreateScreenSource(screenX, screenY)
        dxUpdateScreenSource(saveFakeScreenSource, true)
    end
)

function createPaintjobSaver()
	local h = 195
	local editor = exports.am_gui:createGuiElement("rectangle", screenX / 2 - h / 2, screenY / 2 - (h + 96) / 2, h, h + 96)
    paintjobSaver = editor
	exports.am_gui:setGuiBackground(editor, "solid", "grey2")
	if isElement(paintjobPreviewTexture) then
		local image = exports.am_gui:createGuiElement("image", 8, 8, h - 16, h - 16, editor)
		exports.am_gui:setImageFile(image, paintjobPreviewTexture)
		local btn = exports.am_gui:createGuiElement("button", 8, h, h - 16, 24, editor)
		exports.am_gui:setGuiBackground(btn, "solid", "primary")
		exports.am_gui:setGuiHover(btn, "gradient", {
			"primary",
			"accent"
		}, 60)
		exports.am_gui:setButtonFont(btn, "13/BebasNeueRegular")
		exports.am_gui:setButtonText(btn, "Vásárlás")
		exports.am_gui:setClickEvent(btn, "startPaintjobBuying")
		exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
		local btn = exports.am_gui:createGuiElement("button", 8, h + 32, h - 16, 24, editor)
		exports.am_gui:setGuiBackground(btn, "solid", "primary")
		exports.am_gui:setGuiHover(btn, "gradient", {
			"primary",
			"accent"
		}, 60)
		exports.am_gui:setButtonFont(btn, "13/BebasNeueRegular")
		exports.am_gui:setButtonText(btn, "Mentés")
		exports.am_gui:setClickEvent(btn, "saveTheCurrentPaintjob")
		exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
	end
	local btn = exports.am_gui:createGuiElement("button", 8, h + 64, h - 16, 24, editor)
	exports.am_gui:setGuiBackground(btn, "solid", "red")
	exports.am_gui:setGuiHover(btn, "gradient", {
		"red",
		"red2"
	}, 60)
	exports.am_gui:setButtonFont(btn, "13/BebasNeueRegular")
	exports.am_gui:setClickEvent(btn, "returnToTheMainPaintjobPage")
	exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
	exports.am_gui:setButtonText(btn, "Mégsem")
	rtToDraw = true
end

function savePaintjob(bought)
	local filename = getRealTimestamp() .. "_" .. getTickCount()
	local model = getElementModel(veh)
	local file = fileCreate("saves/" .. model .. "/" .. filename .. ".astral")
	local data = ""
	if file then
		for i = 1, #layers do
			if layers[i] then
				data = data .. layers[i][1] .. "\n"
				data = data .. layers[i][2] .. "\n"
				data = data .. layers[i][3] .. "\n"
				data = data .. layers[i][4] .. "\n"
				data = data .. layers[i][5] .. "\n"
				data = data .. layers[i][6] .. "\n"
				data = data .. layers[i][7][1] .. "\n"
				data = data .. layers[i][7][2] .. "\n"
				data = data .. layers[i][7][3] .. "\n"
				data = data .. layers[i][7][4] .. "\n"
				data = data .. (layers[i][8] and 1 or 0) .. "\n"
				data = data .. (layers[i][9] and 1 or 0) .. "\n"
				data = data .. (layers[i][10] and 1 or 0) .. "\n"
				data = data .. (layers[i][11] and 1 or 0) .. "\n"
				data = data .. (layers[i][12] and 1 or 0) .. "\n"
				data = data .. (layers[i][13] or "") .. "\n"
			end
		end
        -- 1, 2, 3, 4,  5,    7,    6,    8,  9,  10, 11,     12,      13
        -- x, y, w, h, rot, path, color, mh, mv, m1, m2, customtext, name
		data = teaEncodeBinary(data, model .. "pjlayer" .. filename)
		fileWrite(file, data)
		fileClose(file)
	end
	local file = fileCreate("saves/" .. model .. "/" .. filename .. "_d.astral")
	if file then
		data = ""
		data = data .. carBackgroundTexture .. "\n"
		data = data .. vehColor[1] .. "\n"
		data = data .. vehColor[2] .. "\n"
		data = data .. vehColor[3] .. "\n"
		data = data .. carBackgroundSize .. "\n"
		for i = 1, #newDecalColorList do
			if newDecalColorList[i] then
				data = data .. newDecalColorList[i][1] .. "\n"
				data = data .. newDecalColorList[i][2] .. "\n"
				data = data .. newDecalColorList[i][3] .. "\n"
				data = data .. (newDecalColorList[i][4] and 1 or 0) .. "\n"
			end
		end
		data = teaEncodeBinary(data, model .. "pjdet" .. filename)
		fileWrite(file, data)
		fileClose(file)
	end
	data = dxGetTexturePixels(paintjobPreviewTexture)
    data = dxConvertPixels(data, "png")
	if data then
		local file = fileCreate("saves/" .. model .. "/" .. filename .. "_p.png")
		if file then
			fileWrite(file, data)
			fileClose(file)
		end
	end
	local listFilename = "saves/" .. model .. ".astral"
	local listFile = false
	if fileExists(listFilename) then
		listFile = fileOpen(listFilename)
		if listFile then
			fileSetPos(listFile, fileGetSize(listFile))
		end
	else
		listFile = fileCreate(listFilename)
	end
	if listFile then
		fileWrite(listFile, (bought and "b" or "") .. filename .. "\n")
		fileClose(listFile)
	end
	data = nil
	collectgarbage("collect")
end

addEvent("saveTheCurrentPaintjob", true)
addEventHandler("saveTheCurrentPaintjob", getRootElement(), function()
    createGui()
    createLayerSelector()
    savePaintjob()
    destroyElement(paintjobSaver)
end)

addEvent("returnToTheMainPaintjobPage", false)
addEventHandler("returnToTheMainPaintjobPage", getRootElement(), function(button, state, absoluteX, absoluteY, el)
    createGui()
    createLayerSelector()
    destroyElement(paintjobSaver)
end)
addEvent("returnToTheMainPaintjobPage2", false)
addEventHandler("returnToTheMainPaintjobPage2", getRootElement(), function(button, state, absoluteX, absoluteY, el)
    createGui()
    createLayerSelector()
    destroyElement(paintjobOpener)
end)
addEvent("returnToTheMainPaintjobPage3", false)
addEventHandler("returnToTheMainPaintjobPage3", getRootElement(), function(button, state, absoluteX, absoluteY, el)
    createGui()
    createLayerSelector()
    destroyElement(decalSelector)
end)

function createBuyingPrompt()
    destroyElement(paintjobSaver)
	local w = 350
	local h = 130
	local editor = exports.am_gui:createGuiElement("rectangle", screenX / 2 - w / 2, screenY / 2 - h / 2, w, h)
    buyingPrompt = editor
	exports.am_gui:setGuiBackground(editor, "solid", "grey2")
	local label = exports.am_gui:createGuiElement("label", 5, 0, w - 10, h - 30 - 5, editor)
	exports.am_gui:setLabelAlignment(label, "center", "center")
	exports.am_gui:setLabelFont(label, "15/BebasNeueRegular")
	if gratisPJ then
		exports.am_gui:setLabelText(label, "Szeretnéd megvásárolni a paintjobot?\n\nA paintjob ára: ingyenes")
	else
		exports.am_gui:setLabelText(label, "Szeretnéd megvásárolni a paintjobot?\n\nA paintjob ára: " .. "#6cb3c940.000#ffffff" .. " PP")
	end
	btn = exports.am_gui:createGuiElement("button", 5, h - 30 - 5, (w - 15) / 2, 30, editor)
	exports.am_gui:setGuiBackground(btn, "solid", "primary")
	exports.am_gui:setGuiHover(btn, "gradient", {
		"primary",
		"accent"
	}, 60)
	exports.am_gui:setButtonFont(btn, "15/BebasNeueRegular")
	exports.am_gui:setButtonTextColor(btn, "#ffffff")
	exports.am_gui:setButtonText(btn, "Igen")
	exports.am_gui:setClickEvent(btn, "decalEditorFinalBuyPaintjob")
	exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
	btn = exports.am_gui:createGuiElement("button", 5 + (w - 15) / 2 + 5, h - 30 - 5, (w - 15) / 2, 30, editor)
	exports.am_gui:setGuiBackground(btn, "solid", "red")
	exports.am_gui:setGuiHover(btn, "gradient", {
		"red",
		"red2"
	}, 60)
	exports.am_gui:setButtonFont(btn, "15/BebasNeueRegular")
	exports.am_gui:setButtonTextColor(btn, "#ffffff")
	exports.am_gui:setButtonText(btn, "Nem")
	exports.am_gui:setClickEvent(btn, "returnToTheSaverPage")
	exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
end

addEvent("startPaintjobBuying", true)
addEventHandler("startPaintjobBuying", getRootElement(), function()
	createBuyingPrompt()
end)
addEvent("decalEditorFinalBuyPaintjob", true)
addEventHandler("decalEditorFinalBuyPaintjob", getRootElement(), function()
    drawLayers(true)
    destroyElement(buyingPrompt)
    createGui()
    createLayerSelector()
    savePaintjob(true)
    local pixels = dxGetTexturePixels(renderTarget)
    pixels = dxConvertPixels(pixels, "png", 100)
    triggerServerEvent("savePaintjob", localPlayer, pixels)
    pixels = nil
    collectgarbage("collect")
    closeEditor()
end)
addEvent("returnToTheSaverPage", true)
addEventHandler("returnToTheSaverPage", getRootElement(), function()
    destroyElement(buyingPrompt)
	createPaintjobSaver()
end)
addEvent("selectNewDecalPreDefinedColor", true)
addEventHandler("selectNewDecalPreDefinedColor", getRootElement(), function(el)
	if newDecalColors[el] then
		local h, s, l = convertRGBToHSL(newDecalColors[el][1], newDecalColors[el][2], newDecalColors[el][3])
		exports.am_gui:setSliderValue(sliderH, h)
		exports.am_gui:setSliderValue(sliderS, s)
		exports.am_gui:setSliderValue(sliderL, l)
		refreshNewDecalColorPickerBcg(true)
	end
end)
addEvent("decalEditorOpenPaintjob", true)
addEventHandler("decalEditorOpenPaintjob", getRootElement(), function()
    createPaintjobOpener()
end)
addEvent("paintjobLoaderPagerClick", true)
addEventHandler("paintjobLoaderPagerClick", getRootElement(), function(el)
    if paintjobLoaderPager[el] then
        if tonumber(paintjobLoaderPager[el]) and currentPaintjobLoaderPage ~= tonumber(paintjobLoaderPager[el]) then
            currentPaintjobLoaderPage = tonumber(paintjobLoaderPager[el])
        elseif paintjobLoaderPager[el] == "plus" then
            currentPaintjobLoaderPage = currentPaintjobLoaderPage + 1
        elseif paintjobLoaderPager[el] == "minus" then
            currentPaintjobLoaderPage = currentPaintjobLoaderPage - 1
        end
        processPaintjobLoader()
    end
end)
addEvent("selectPaintjobToLoad", true)
addEventHandler("selectPaintjobToLoad", getRootElement(), function(el)
    if paintjobLoaderElements[el] then
        paintjobToLoad = paintjobLoaderData[paintjobLoaderElements[el][1] + (currentPaintjobLoaderPage - 1) * sx * sy][1]
        createPaintjobLoadPrompt()
    end
end)

function createPaintjobLoadPrompt()
    -- 1 data = data .. layers[i][1] .. "\n"
    -- 2 data = data .. layers[i][2] .. "\n"
    -- 3 data = data .. layers[i][3] .. "\n"
    -- 4 data = data .. layers[i][4] .. "\n"
    -- 5 data = data .. layers[i][5] .. "\n"
    -- 6 data = data .. layers[i][6] .. "\n"
    -- 7 data = data .. layers[i][7][1] .. "\n"
    -- 8 data = data .. layers[i][7][2] .. "\n"
    -- 9 data = data .. layers[i][7][3] .. "\n"
    -- 10 data = data .. layers[i][7][4] .. "\n"
    -- 11 data = data .. (layers[i][8] and 1 or 0) .. "\n"
    -- 12 data = data .. (layers[i][9] and 1 or 0) .. "\n"
    -- 13 data = data .. (layers[i][10] and 1 or 0) .. "\n"
    -- 14 data = data .. (layers[i][11] and 1 or 0) .. "\n"
    -- 15 data = data .. (layers[i][12] and 1 or 0) .. "\n"
    -- 16 data = data .. layers[i][13] .. "\n"

    if paintjobToLoad then
        if isElement(paintjobOpener) then
            destroyElement(paintjobOpener)
        end 
        if isElement(paintjobLoadPrompt) then
            destroyElement(paintjobLoadPrompt)
        end 
        local h = 256
        paintjobLoadPrompt = exports.am_gui:createGuiElement("rectangle", screenX / 2 - h / 2, screenY / 2 - (h + 96) / 2, h, h + 96)
        exports.am_gui:setGuiBackground(paintjobLoadPrompt, "solid", "grey2")
        local folder = "saves/" .. getElementModel(veh)
        local image = exports.am_gui:createGuiElement("image", 8, 8, h - 16, h - 16, paintjobLoadPrompt)
        if fileExists(folder .. "/" .. paintjobToLoad .. "_p.png") then
            exports.am_gui:setImageFile(image, ":see_custompj/" .. folder .. "/" .. paintjobToLoad .. "_p.png")
        end
        if not paintjobDeleterPrompt then
            local btn = exports.am_gui:createGuiElement("button", 8, h, h - 16, 24, paintjobLoadPrompt)
            exports.am_gui:setGuiBackground(btn, "solid", "primary")
            exports.am_gui:setGuiHover(btn, "gradient", {"primary", "accent"}, 60)
            exports.am_gui:setButtonFont(btn, "13/BebasNeueRegular")
            exports.am_gui:setButtonText(btn, "Megnyitás")
            exports.am_gui:setClickEvent(btn, "loadTheCurrentPaintjob")
            exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
            local btn = exports.am_gui:createGuiElement("button", 8, h + 32, h - 16, 24, paintjobLoadPrompt)
            exports.am_gui:setGuiBackground(btn, "solid", "red")
            exports.am_gui:setGuiHover(btn, "gradient", {"red", "red2"}, 60)
            exports.am_gui:setButtonFont(btn, "13/BebasNeueRegular")
            exports.am_gui:setButtonText(btn, "Törlés")
            exports.am_gui:setClickEvent(btn, "togglePaintjobDeleterPrompt")
            exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
        end
        if paintjobDeleterPrompt then
            local label = exports.am_gui:createGuiElement("label", 0, h, h, 24, paintjobLoadPrompt)
            exports.am_gui:setLabelText(label, "Biztosan törlöd?")
            exports.am_gui:setLabelFont(label, "11/BebasNeueRegular")
            exports.am_gui:setLabelAlignment(label, "center", "center")
            local btn = exports.am_gui:createGuiElement("button", 8, h + 32, h - 16, 24, paintjobLoadPrompt)
            exports.am_gui:setGuiBackground(btn, "solid", "primary")
            exports.am_gui:setGuiHover(btn, "gradient", {"primary", "accent"}, 60)
            exports.am_gui:setButtonFont(btn, "13/BebasNeueRegular")
            exports.am_gui:setButtonText(btn, "Igen")
            exports.am_gui:setClickEvent(btn, "finalDeleteThePaintjob")
            exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
            local btn = exports.am_gui:createGuiElement("button", 8, h + 64, h - 16, 24, paintjobLoadPrompt)
            exports.am_gui:setGuiBackground(btn, "solid", "red")
            exports.am_gui:setGuiHover(btn, "gradient", {"red", "red2"}, 60)
            exports.am_gui:setButtonFont(btn, "13/BebasNeueRegular")
            exports.am_gui:setClickEvent(btn, "togglePaintjobDeleterPrompt")
            exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
            exports.am_gui:setButtonText(btn, "Nem")
        else
            local btn = exports.am_gui:createGuiElement("button", 8, h + 64, h - 16, 24, paintjobLoadPrompt)
            exports.am_gui:setGuiBackground(btn, "solid", "red")
            exports.am_gui:setGuiHover(btn, "gradient", {"red", "red2"}, 60)
            exports.am_gui:setButtonFont(btn, "13/BebasNeueRegular")
            exports.am_gui:setClickEvent(btn, "decalEditorOpenPaintjob")
            exports.am_gui:setClickSound(btn, "sounds/selectdone.wav")
            exports.am_gui:setButtonText(btn, "Mégsem")
        end
    end
end
addEvent("togglePaintjobDeleterPrompt", true)
addEventHandler("togglePaintjobDeleterPrompt", getRootElement(), function(el)
    if paintjobToLoad then
        paintjobDeleterPrompt = not paintjobDeleterPrompt
        createPaintjobLoadPrompt()
    end
end)
addEvent("finalDeleteThePaintjob", true)
addEventHandler("finalDeleteThePaintjob", getRootElement(), function(el)
    if paintjobToLoad then
        local folder = "saves/" .. getElementModel(veh)
        local listFilename = folder .. ".astral"
        if fileExists(folder .. "/" .. paintjobToLoad .. ".astral") then
            fileDelete(folder .. "/" .. paintjobToLoad .. ".astral")
        end
        if fileExists(folder .. "/" .. paintjobToLoad .. "_p.png") then
            fileDelete(folder .. "/" .. paintjobToLoad .. "_p.png")
        end
        if fileExists(folder .. "/" .. paintjobToLoad .. "_d.astral") then
            fileDelete(folder .. "/" .. paintjobToLoad .. "_d.astral")
        end
        if fileExists(listFilename) then
            local file = fileOpen(listFilename)
            if file then
                local buffer = ""
                local data = fileRead(file, fileGetSize(file))
                data = split(data, "\n")
                fileClose(file)
                local file = fileCreate(listFilename)
                if file then
                    for i = 1, #data do
                        if data[i] ~= paintjobToLoad then
                            fileWrite(file, data[i] .. "\n")
                        end
                    end
                    fileClose(file)
                end
                data = nil
                collectgarbage("collect")
            end
        end
    end
    createPaintjobOpener()
end)

addEvent("loadTheCurrentPaintjob", true)
addEventHandler("loadTheCurrentPaintjob", getRootElement(), function()
    if paintjobToLoad then
        local model = getElementModel(veh)
        local folder = "saves/" .. model
        layers = {}
        
        carBackgroundTexture = 0
        carBackground = {
            255, 
            255, 
            255
        }
        carBackgroundSize = 256
        resetTheColorList()
        if fileExists(folder .. "/" .. paintjobToLoad .. "_d.astral") then
            local file = fileOpen(folder .. "/" .. paintjobToLoad .. "_d.astral")
            if file then
                local data = fileRead(file, fileGetSize(file))
                data = teaDecodeBinary(data, model .. "pjdet" .. paintjobToLoad)
                data = split(data, "\n")
                fileClose(file)

                if tonumber(data[1]) then
                    carBackgroundTexture = tonumber(data[1])
                end
                if tonumber(data[2]) and tonumber(data[3]) and tonumber(data[4]) then
                    vehColor[1] = tonumber(data[2])
                    vehColor[2] = tonumber(data[3])
                    vehColor[3] = tonumber(data[4])
                end
                if tonumber(data[5]) then
                    carBackgroundSize = tonumber(data[5])
                end
                newDecalColorList = {}
                local valid = true
                local buffer = false
                for i = 6, #data do
                    local j = (i - 6) % 4 + 1
                    if j == 1 then
                        buffer = {}
                        buffer[1] = tonumber(data[j])
                        if buffer[1] then
                            valid = true
                        end
                    elseif j == 4 then
                        buffer[4] = tonumber(data[i]) == 1
                        if valid then
                            table.insert(newDecalColorList, buffer)
                        end
                    else
                        buffer[j] = tonumber(data[i])
                        if not buffer[j] then
                            valid = false
                        end
                    end
                end
                data = nil
                buffer = nil
                collectgarbage("collect")
            end
        end
        if fileExists(folder .. "/" .. paintjobToLoad .. ".astral") then
            local file = fileOpen(folder .. "/" .. paintjobToLoad .. ".astral")
            if file then
                local data = fileRead(file, fileGetSize(file))
                data = teaDecodeBinary(data, model .. "pjlayer" .. paintjobToLoad)
                local buffer = false
                data = split(data, "\n")
                fileClose(file)
                local valid = true 
                -- 1, 2, 3, 4,  5,    6,   7,    8,  9,  10, 11,     12,      13
                -- x, y, w, h, rot, path, color, mh, mv, m1, m2, customtext, name
				-- 1 data = data .. layers[i][1] .. "\n"
				-- 2 data = data .. layers[i][2] .. "\n"
				-- 3 data = data .. layers[i][3] .. "\n"
				-- 4 data = data .. layers[i][4] .. "\n"
				-- 5 data = data .. layers[i][5] .. "\n"
				-- 6 data = data .. layers[i][6] .. "\n"
				-- 7 data = data .. layers[i][7][1] .. "\n"
				-- 8 data = data .. layers[i][7][2] .. "\n"
				-- 9 data = data .. layers[i][7][3] .. "\n"
				-- 10 data = data .. layers[i][7][4] .. "\n"
				-- 11 data = data .. (layers[i][8] and 1 or 0) .. "\n"
				-- 12 data = data .. (layers[i][9] and 1 or 0) .. "\n"
				-- 13 data = data .. (layers[i][10] and 1 or 0) .. "\n"
				-- 14 data = data .. (layers[i][11] and 1 or 0) .. "\n"
				-- 15 data = data .. (layers[i][12] and 1 or 0) .. "\n"
				-- 16 data = data .. layers[i][13] .. "\n"
                for i = 1, #data do
                    local j = i % 16
                    if j == 1 then
                        buffer = {}
                        buffer[j] = tonumber(data[i])
                        if buffer[j] then
                            valid = true
                        end
                    elseif 2 <= j and j <= 5 then
                        buffer[j] = tonumber(data[i])
                        if not buffer[j] then
                            valid = false
                        end
                    elseif j == 6 then
                        if utf8.sub(data[i], 1, 10) == "customtext" then
                            local dat = split(data[i], "/")
                            table.remove(dat, 1)
                            local font = dat[1]
                            table.remove(dat, 1)
                            local size = tonumber(dat[1]) or 20
                            table.remove(dat, 1)
                            local text = table.concat(dat, "/")
                            buffer[6] = loadCustomTextDecal(text, font, size)
                        else
                            buffer[6] = data[i]
                        end
                        if not buffer[6] then
                            valid = false
                        end
                    elseif j >= 7 and j <= 10 then
                        if not buffer[7] then
                            buffer[7] = {}
                        end
                        local int = tonumber(data[i])
                        if not int then
                            valid = false
                        end
                        buffer[7][j - 6] = int
                    elseif j >= 11 and j <= 15 then
                        buffer[j - 3] = tonumber(data[i]) == 1
                    elseif j == 0 then
                        buffer[13] = data[i]
                        if valid and buffer[13] then
                            table.insert(layers, buffer)
                        end
                    end
                end
                data = nil
                buffer = nil
                collectgarbage("collect")
            end
        end
        selectedLayer = 1
        if not layers[selectedLayer] then
            selectedLayer = false
        end
        layerScroll = 0
    end
    if isElement(paintjobLoadPrompt) then
        destroyElement(paintjobLoadPrompt)
    end
    createGui() 
    createLayerSelector()
end)

addEvent("previousCategory", true)
addEventHandler("previousCategory", getRootElement(), function()

end)

function createPaintjobOpener()
    if isElement(editor) then
        destroyElement(editor)
    end
    if isElement(paintjobLoadPrompt) then
        destroyElement(paintjobLoadPrompt)
    end
    paintjobToLoad = false
    paintjobDeleterPrompt = false
    local ds = 175
    local spacing = 2
    sx = math.floor(screenX / ds) - 3
    sy = math.floor(screenY / ds) - 2
    paintjobOpener = exports.am_gui:createGuiElement("rectangle", screenX / 2 - (sx * ds + spacing * 2) / 2, screenY / 2 - (sy * ds + 32 + spacing * 2 + 64 + 24) / 2, sx * ds + spacing * 2, sy * ds + spacing * 2 + 64 + 24)
    exports.am_gui:setGuiBackground(paintjobOpener, "solid", "grey")
    local image = exports.am_gui:createGuiElement("image", 8, 8, 48, 48, paintjobOpener)
    exports.am_gui:setImageFile(image, exports.am_gui:getFaIconFilename("folder-open", 48))
    local label = exports.am_gui:createGuiElement("label", 64, 0, 0, 64, paintjobOpener)
    exports.am_gui:setLabelFont(label, "20/BebasNeueRegular")
    exports.am_gui:setLabelText(label, "Paintjob betöltése")
    exports.am_gui:setLabelAlignment(label, "left", "center")
    local image = exports.am_gui:createGuiElement("image", sx * ds + spacing * 2 - 32 - 8, 8, 32, 32, paintjobOpener)
    exports.am_gui:setImageFile(image, exports.am_gui:getFaIconFilename("times", 32))
    exports.am_gui:setGuiHover(image, "solid", "red")
    exports.am_gui:setClickEvent(image, "returnToTheMainPaintjobPage2")
    exports.am_gui:setClickSound(image, "sounds/selectdone.wav")
    local x = 16
    local c = 1
    paintjobLoaderData = {}

    local folder = "saves/" .. getElementModel(veh)
    local listFilename = folder .. ".astral"
    if fileExists(listFilename) then
        local file = fileOpen(listFilename)
        if file then
            local buffer = ""
            local data = fileRead(file, fileGetSize(file))
            data = split(data, "\n")
            fileClose(file)
            for i = #data, 1, -1 do
                local bought = utf8.sub(data[i], 1, 1) == "b"
                if bought then
                    data[i] = utf8.sub(data[i], 2, utf8.len(data[i]))
                end
                if data[i] and fileExists(folder .. "/" .. data[i] .. ".astral") then
                    local text = false
                    if fileExists(folder .. "/" .. data[i] .. "_p.png") then
                        text = folder .. "/" .. data[i] .. "_p.png"
                    end
                    table.insert(paintjobLoaderData, {
                        data[i],
                        text,
                        bought
                    })
                end
            end
            buffer = nil
            data = nil
            collectgarbage("collect")
        end
    end
    paintjobLoaderElements = {}
    for y = 0, sy - 1 do
        for x = 0, sx - 1 do
            local lbg = exports.am_gui:createGuiElement("rectangle", spacing + x * ds + spacing, 64 + spacing + y * ds + spacing, ds - spacing * 2, ds - spacing * 2, paintjobOpener)
            exports.am_gui:setGuiBackground(lbg, "solid", "grey2")
            if paintjobLoaderData[c] then 
                exports.am_gui:setGuiHover(lbg, "gradient", {"primary", "accent"}, 0)
                local image = exports.am_gui:createGuiElement("image", 2, 2, ds - spacing * 2 - 4, ds - spacing * 2 - 4, lbg)
                exports.am_gui:setImageFile(image, ":see_custompj/" .. paintjobLoaderData[c][2])
                local icon = exports.am_gui:createGuiElement("image", ds - spacing * 2 - 32 - spacing, ds - spacing * 2 - 32 - spacing, 32, 32, lbg)
                exports.am_gui:setImageFile(icon, exports.am_gui:getFaIconFilename("shopping-cart", 32))
                exports.am_gui:setImageColor(icon, "green")
                paintjobLoaderElements[image] = {
                    c,
                    image,
                    lbg,
                    icon
                }
                exports.am_gui:guiToFront(icon)
                exports.am_gui:setClickEvent(image, "selectPaintjobToLoad")
                exports.am_gui:setClickSound(image, "sounds/selectdone.wav")
            end

            c = c + 1
        end
    end
    local pages = math.ceil(#paintjobLoaderData / (sx * sy))
    local w = 16 * pages
    local pager = exports.am_gui:createGuiElement("null", (sx * ds + spacing * 2) / 2 - w / 2, sy * ds + spacing * 2 + 64 - spacing, w, 24, paintjobOpener)
    paintjobLoaderPager = {}
    --local button = exports.am_gui:createGuiElement("image", -24, 0, 24, 24, pager)
    --exports.am_gui:setImageFile(button, exports.am_gui:getFaIconFilename("caret-left", 200))
    --exports.am_gui:setGuiHover(button, "solid", "#ffffff")
    --exports.am_gui:setImageColor(button, "grey2")
    --exports.am_gui:setClickEvent(button, "paintjobLoaderPagerClick")
    --exports.am_gui:setClickSound(button, "sounds/selectdone.wav")
    --paintjobLoaderPager[button] = "minus"
    --local button = exports.am_gui:createGuiElement("image", w, 0, 24, 24, pager)
    --exports.am_gui:setImageFile(button, exports.am_gui:getFaIconFilename("caret-right", 200))
    --exports.am_gui:setGuiHover(button, "solid", "#ffffff")
    --exports.am_gui:setImageColor(button, "grey2")
    --exports.am_gui:setClickEvent(button, "paintjobLoaderPagerClick")
    --exports.am_gui:setClickSound(button, "sounds/selectdone.wav")
    --paintjobLoaderPager[button] = "plus"
    for i = 1, pages do
        local button = exports.am_gui:createGuiElement("image", (i - 1) * 16, 4, 16, 16, pager)
        exports.am_gui:setGuiHover(button, "solid", "primary")
        exports.am_gui:setClickEvent(button, "paintjobLoaderPagerClick")
        exports.am_gui:setClickSound(button, "sounds/selectdone.wav")
        paintjobLoaderPager[button] = i
    end
    processPaintjobLoader()
end

function processPaintjobLoader()
    for hover, v in pairs(paintjobLoaderElements) do
        if paintjobLoaderData[v[1] + (currentPaintjobLoaderPage - 1) * sx * sy] then
            exports.am_gui:setGuiRenderDisabled(v[4], not paintjobLoaderData[v[1] + (currentPaintjobLoaderPage - 1) * sx * sy][3])
            exports.am_gui:guiToFront(v[4])
            if paintjobLoaderData[v[1] + (currentPaintjobLoaderPage - 1) * sx * sy][2] then
                exports.am_gui:setImageFile(v[2], ":see_custompj/" .. paintjobLoaderData[v[1] + (currentPaintjobLoaderPage - 1) * sx * sy][2])
            else
                exports.am_gui:setImageFile(v[2], false)
            end
            exports.am_gui:setImageColor(v[2], {
                255,
                255,
                255
            })
            exports.am_gui:setGuiHover(v[3], "gradient", {"primary", "accent"}, 0)
        else
            exports.am_gui:setGuiRenderDisabled(v[4], true)
            exports.am_gui:setGuiHover(v[3], false)
            exports.am_gui:setImageFile(v[2], false)
        end
    end
    for el, v in pairs(paintjobLoaderPager) do
        if v == "plus" then

        elseif v == "minus" then

        else
            local curr = v == currentPaintjobLoaderPage
            exports.am_gui:setImageFile(el, exports.am_gui:getFaIconFilename("circle", 16, curr and "solid" or "regular"))
            exports.am_gui:setImageColor(el, curr and "primary" or "#ffffff")
            if curr then
                exports.am_gui:setGuiHover(el, false)
            else
                exports.am_gui:setGuiHover(el, "solid", "primary")
            end
        end
    end
end

function createDecalSelectorContent()
    local w, h = exports.am_gui:getGuiSize(decalSelector)
    h = h - 105
    
    decalSelectorContent = exports.am_gui:createGuiElement("rectangle", 0, 105, w, h, decalSelector)

    local sticker = 0
    for x = 0, ((w - 5)/105) - 1 do
        for y = 0, ((h - 5)/105) - 1 do
            sticker = sticker + 1
            local decalbg = exports.am_gui:createGuiElement("rectangle", 5 + (x * 105), 5 + (y * 105), 100, 100, decalSelectorContent)
            exports.am_gui:setGuiBackground(decalbg, "solid", "grey4")
            local content = exports.am_gui:createGuiElement("image", 5, 5, 90, 90, decalbg)
            exports.am_gui:setClickEvent(content, "customPJ:selectSticker")
            exports.am_gui:setClickSound(content, "sounds/selectdone.wav")
            
            decalSelectorElements[sticker] = {sticker, content, decalbg}
        end 
    end

    if #decalContainer[categoryContainer[selectedCategory]] > sticker then
        local stickers = #decalContainer[categoryContainer[selectedCategory]]
        local max = sticker
        
        decalSelectorsb = exports.am_gui:createGuiElement("rectangle", 0, h - 2, (w/(stickers)) * max, 2, decalSelectorContent)
        exports.am_gui:setGuiBackground(decalSelectorsb, "solid", "accent")
    end
    createDecalSelectorContentSticker()
end

function createDecalSelectorContentSticker()
    local w, h = exports.am_gui:getGuiSize(decalSelector)
    h = h - 105

    local xlength = ((w - 5)/105)
    local ylength = ((h - 5)/105)

    local sticker = 0
    for i = 1, xlength * ylength do
        sticker = sticker + 1

        local realSticker = sticker + (decalScroll*ylength)
        
        local content = decalSelectorElements[sticker][2]
        if decalContainer[categoryContainer[selectedCategory]][realSticker] then
            exports.am_gui:setImageFile(content, ":see_custompj/files/decals/128/" .. categoryContainer[selectedCategory] .. "/" .. decalContainer[categoryContainer[selectedCategory]][realSticker][1])
            exports.am_gui:setGuiAlpha(content, 150)
            exports.am_gui:setHoverEvent(content, "customPJ:hoverSticker")
        else
            exports.am_gui:setImageFile(content, false)
            exports.am_gui:setHoverEvent(content, false)
        end
    end

    if isElement(decalSelectorsb) then
        local stickers = #decalContainer[categoryContainer[selectedCategory]]
        local max = sticker
        
        local rx = math.min(reMap(decalScroll, 0, math.ceil((stickers-(xlength*ylength))/ylength), 0, w - ((w/(stickers)) * max)), w - ((w/(stickers)) * max))
        exports.am_gui:setGuiPosition(decalSelectorsb, rx, h - 2)
        if max < stickers then
            exports.am_gui:setGuiSize(decalSelectorsb, (w/(stickers)) * max, 2)
            exports.am_gui:setGuiAlpha(decalSelectorsb, 255)
        else
            exports.am_gui:setGuiAlpha(decalSelectorsb, 0)
        end
    end
end

function createLayerEditor(image, r, g, b, a, name)
    local w, h = 550, 245
    layerEditor = exports.am_gui:createGuiElement("rectangle", screenX/2-w/2, screenY/2-h/2, w, h)
    exports.am_gui:setGuiBackground(layerEditor, "solid", "grey2")
    layerPreviewBG = exports.am_gui:createGuiElement("rectangle", 8, 8, h-16, h-16, layerEditor)
    exports.am_gui:setGuiBackground(layerPreviewBG, "solid", "grey")
    layerPreview = exports.am_gui:createGuiElement("image", 12, 12, h-24, h-24, layerEditor)
    exports.am_gui:setImageFile(layerPreview, image)
    exports.am_gui:guiToFront(layerPreview)

    layerNameInput = exports.am_gui:createGuiElement("input", h, 8, h + 20, 30, layerEditor)
    exports.am_gui:setInputValue(layerNameInput, name or "Réteg " .. newLayerCount)
    exports.am_gui:setInputPlaceholder(layerNameInput, "Réteg neve") 
    exports.am_gui:setInputIcon(layerNameInput, "fa:pencil-alt") 
    exports.am_gui:setInputMaxLength(layerNameInput, 16)
    local button = exports.am_gui:createGuiElement("button", h + h + 20, 8, 30, 30, layerEditor)
    exports.am_gui:setGuiBackground(button, "solid", "primary")
    exports.am_gui:setGuiHover(button, "gradient", {"primary", "accent"}, 60)
    exports.am_gui:setClickEvent(button, "confirmLayerEdit")
    exports.am_gui:setClickSound(button, "sounds/selectdone.wav")
    local check = exports.am_gui:createGuiElement("image", 5, 5, 20, 20, button)
    exports.am_gui:setImageFile(check, exports.am_gui:getFaIconFilename("check", 20))

    bcgH1 = exports.am_gui:createGuiElement("rectangle", h + 8, 56, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setGuiBackground(bcgH1, "solid", "#000000")
    bcgH2 = exports.am_gui:createGuiElement("image", h + 8, 56, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setImageFile(bcgH2, ":see_custompj/files/col3.dds")
    exports.am_gui:guiToFront(bcgH2)
    bcgH3 = exports.am_gui:createGuiElement("rectangle", h + 8, 56, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:guiToFront(bcgH3)
    sliderH = exports.am_gui:createGuiElement("slider", h + 8, 56 - 4, (w - h - 8) - 16, 20, layerEditor)
    exports.am_gui:setSliderColor(sliderH, {255, 0, 0})
    exports.am_gui:guiToFront(sliderH)
    exports.am_gui:setSliderChangeEvent(sliderH, "newDecalColorPickerChanged")

    bcgS1 = exports.am_gui:createGuiElement("rectangle", h + 8, 84, (w - h - 8) - 16, 12, layerEditor)
    bcgS2 = exports.am_gui:createGuiElement("image", h + 8, 84, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setImageFile(bcgS2, ":see_custompj/files/col1.dds")
    exports.am_gui:guiToFront(bcgS2)
    sliderS = exports.am_gui:createGuiElement("slider", h + 8, 84 - 4, (w - h - 8) - 16, 20, layerEditor)
    exports.am_gui:setSliderColor(sliderS, {0, 0, 0})
    exports.am_gui:guiToFront(sliderS)
    exports.am_gui:setSliderChangeEvent(sliderS, "newDecalColorPickerChanged")
    exports.am_gui:setSliderValue(sliderS, 1)

    bcgL1 = exports.am_gui:createGuiElement("rectangle", h + 8, 112, ((w - h - 8) - 16)/2, 12, layerEditor)
    exports.am_gui:setGuiBackground(bcgL1, "solid", {0, 0, 0})
    bcgL2 = exports.am_gui:createGuiElement("rectangle", h + 8 + ((w - h - 8) - 16)/2, 112, ((w - h - 8) - 16)/2, 12, layerEditor)
    exports.am_gui:setGuiBackground(bcgL2, "solid", {255, 255, 255})
    bcgL3 = exports.am_gui:createGuiElement("image", h + 8, 112, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setImageFile(bcgL3, ":see_custompj/files/col2.dds")
    exports.am_gui:guiToFront(bcgL3)
    sliderL = exports.am_gui:createGuiElement("slider", h + 8, 112 - 4, (w - h - 8) - 16, 20, layerEditor)
    exports.am_gui:setSliderColor(sliderL, {0, 0, 0})
    exports.am_gui:guiToFront(sliderL)
    exports.am_gui:setSliderChangeEvent(sliderL, "newDecalColorPickerChanged")
    exports.am_gui:setSliderValue(sliderL, 1)

    bcgO1 = exports.am_gui:createGuiElement("image", h + 8, 140, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setImageFile(bcgO1, ":see_custompj/files/col4.dds")
    bcgO2 = exports.am_gui:createGuiElement("image", h + 8, 140, (w - h - 8) - 16, 12, layerEditor)
    exports.am_gui:setImageFile(bcgO2, ":see_custompj/files/col1.dds")
    exports.am_gui:guiToFront(bcgO2)
    sliderO = exports.am_gui:createGuiElement("slider", h + 8, 140 - 4, (w - h - 8) - 16, 20, layerEditor)
    exports.am_gui:setSliderColor(sliderO, {0, 0, 0})
    exports.am_gui:guiToFront(sliderO)
    exports.am_gui:setSliderValue(sliderO, 1)
    exports.am_gui:setSliderChangeEvent(sliderO, "newDecalColorPickerChanged")

    newDecalColorInput = exports.am_gui:createGuiElement("input", h + 8 + ((w - h - 8) - 16)/2 - 80, 160, 160, 30, layerEditor)
    exports.am_gui:setInputPlaceholder(newDecalColorInput, "HEX színkód")
    exports.am_gui:setInputIcon(newDecalColorInput, "fa:hashtag")
    exports.am_gui:setInputMaxLength(newDecalColorInput, 6)
    exports.am_gui:setInputChangeEvent(newDecalColorInput, "refreshNewDecalColorInput")

    if r and g and b and a then
        local h, s, l = convertRGBToHSL(r, g, b)
        exports.am_gui:setSliderValue(sliderH, h) 
        exports.am_gui:setSliderValue(sliderS, s) 
        exports.am_gui:setSliderValue(sliderL, l) 
        exports.am_gui:setSliderValue(sliderO, a/255) 
    end

    local c = 1
    local nx, ny = 15, 2
    local h = (h - 200 - 8 + 2) / ny 
    local w = h
    newDecalColorsCount = nx * ny
    newDecalColors = {}
    for j = 0, ny - 1 do
        for i = 0, nx - 1 do
            local rect = exports.am_gui:createGuiElement("rectangle", 250 + i * w + 1, 197 + j * h + 1, w - 2, h - 2, layerEditor)
            if newDecalColorList[c] then
                newDecalColors[rect] = {
                    newDecalColorList[c][1],
                    newDecalColorList[c][2],
                    newDecalColorList[c][3]
                }
                exports.am_gui:setGuiBackground(rect, "solid", newDecalColors[rect])
                exports.am_gui:setClickEvent(rect, "selectNewDecalPreDefinedColor")
                exports.am_gui:setClickSound(rect, "sounds/selectdone.wav")
            else
                exports.am_gui:setGuiBackground(rect, "solid", "grey4")
            end
            c = c + 1
        end
    end

    refreshNewDecalColorPickerBcg(true)
end

function closeEditor()
    editorState = false
    engineRemoveShaderFromWorldTexture(shader, remapContainer[getElementModel(veh)], veh)
    if isElement(shader) then
        destroyElement(shader)
    end
    shader = false

    if isElement(renderTarget) then
        destroyElement(renderTarget)
    end
    renderTarget = false
    if isElement(renderTargetX) then
        destroyElement(renderTargetX)
    end
    renderTargetX = false
    if isElement(renderTargetY) then
        destroyElement(renderTargetY)
    end
    renderTargetY = false
    if isElement(editor) then
        destroyElement(editor)
    end
    editor = false  

    --exports.see_hud:showHUD()
    setCameraTarget(localPlayer)

    removeEventHandler("onClientRender", getRootElement(), renderEditor)
    removeEventHandler("onClientPreRender", getRootElement(), preRenderEditor)
    removeEventHandler("onClientKey", getRootElement(), keyEditor)
    removeEventHandler("onClientClick", getRootElement(), clickEditor)
    removeEventHandler("onClientRestore", getRootElement(), restoreEditor)

    setVehicleColor(veh, unpack(getElementData(veh, "restoreColor")))

	for k in pairs(decals) do
		if isElement(decals[k][1]) then
			destroyElement(decals[k][1])
		end
	end
	decals = {}
	layers = {}
	collectgarbage("collect")
    
    mirrorTries = 0
    mirrorSetStage = 1
    mirrorPositions = {}
    mirrorsReady = false
    mirrorsPostReady = false

    camX, camY = 2, 0
    camZoom = 1.7
    camCursor = false

    vehColor = {255, 255, 255}

    carBackgroundTexture = 0
    carBackgroundSize = 128 + 128/2
    carBG = 0
    selectedLayer = false

	decals = {}
	decalContainer = {}

	resetTheColorList()

    exports.see_tuning:reopen()
end

addCommandHandler("custompj",
    function()
        editorState = not editorState
        if editorState then
            enterEditor()
        else
            closeEditor()
        end
    end
)


function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

local responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

addEventHandler("onClientResourceStart", getRootElement(),
    function()
        Ubuntu12 = dxCreateFont("files/fonts/BebasNeueRegular.otf", respc(27), false, "proof")
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
        if editorState then
            setCameraTarget(localPlayer)
            exports.see_hud:showHUD()
        end
    end
)

function getPositionFromMatrixOffset(m, x, y, z)
	return x * m[1][1] + y * m[2][1] + z * m[3][1] + m[4][1],
			x * m[1][2] + y * m[2][2] + z * m[3][2] + m[4][2],
			x * m[1][3] + y * m[2][3] + z * m[3][3] + m[4][3]
end

local blankTex = dxCreateTexture(1, 1)
local stickerTextures = {}
local stickerDeletes = {}
local usedStickerTextures = {}
local stickersHandled = false
function getSticker(path, w, h)
    if not stickersHandled then
        addEventHandler("onClientPreRender", getRootElement(), getStickerPre)
        stickersHandled = true
    end

    local w = math.abs(w)
    local h = math.abs(h)
    local size = math.max(w, h)
    local textureSize = 32
    
    local s = 32
    local texPath = false
    for i = 1, 4 do
        if size <= s then
            texPath = "files/stickers/" .. s .. "/" .. path
            textureSize = s
            break
        end
        s = s * 2
    end

    if not texPath then
        textureSize = 256
    end
    texPath = texPath or "files/stickers/256/" .. path
    local tex = false

    if stickerTextures[texPath] then
        tex = stickerTextures[texPath]
    else
        stickerTextures[texPath] = dxCreateTexture(texPath, "argb", false)
    end
    usedStickerTextures[texPath] = true

    return tex or blankTex
end

function getStickerPre()
	local now = getTickCount()
    
	local rem = true
	for k in pairs(stickerTextures) do
		rem = false
		if stickerDeletes[k] then
			if now >= stickerDeletes[k] then
				if isElement(stickerTextures[k]) then
					destroyElement(stickerTextures[k])
				end
				stickerTextures[k] = nil
				stickerDeletes[k] = nil
				break
			end
		elseif not usedStickerTextures[k] then
			stickerDeletes[k] = now + 5000
		end
	end
	for k in pairs(usedStickerTextures) do
		usedStickerTextures[k] = nil
		stickerDeletes[k] = nil
		rem = false
	end
	if rem then
		removeEventHandler("onClientPreRender", getRootElement(), getStickerPre)
		stickersHandled = false
	end
end

local dynIMGhandled = false
local dynTex = {}
local usedDynTex = {}
local dynDeletes = {}
function dynamicImage(path)
    if not dynIMGhandled then
        addEventHandler("onClientPreRender", getRootElement(), dynamicImagePre)
        dynIMGhandled = true
    end

    local tex = false
    if dynTex[path] then
        tex = dynTex[path]
    else
        dynTex[path] = dxCreateTexture(path, "argb", false)
        tex = dynTex[path]
    end
    usedDynTex[path] = true

    return tex or blankTex
end

function dynamicImagePre()
	local now = getTickCount()
    
	local rem = true
	for k in pairs(dynTex) do
		rem = false
		if dynDeletes[k] then
			if now >= dynDeletes[k] then
				if isElement(dynTex[k]) then
					destroyElement(dynTex[k])
				end
				dynTex[k] = nil
				dynDeletes[k] = nil
				break
			end
		elseif not usedDynTex[k] then
			dynDeletes[k] = now + 5000
		end
	end
	for k in pairs(usedDynTex) do
		usedDynTex[k] = nil
		dynDeletes[k] = nil
		rem = false
	end
	if rem then
		removeEventHandler("onClientPreRender", getRootElement(), dynamicImagePre)
		dynIMGhandled = false
	end
end

function setCamera(p, p2, minX, minY, maxX, maxY, maxZ, d)
	local x, y, z = 0, 0, 0
	local x2, y2, z2 = 0, 0, 0
	local sideA = maxX - minX
	local sideB = maxY - minY
	local sum = sideA * 2 + sideB * 2
	local pA = sideA / sum
	local pB = sideB / sum
	local r = -pih * 1.5
	if p <= pA and 0 <= p then
		local p2 = p / pA
		x2 = minX + (maxX - minX) * p2
		y2 = minY
		r = r + pih * p2
	elseif pB >= p - pA and 0 <= p - pA then
		local p2 = (p - pA) / pB
		x2 = maxX
		y2 = minY + (maxY - minY) * p2
		r = r + pih * (1 + p2)
	elseif pA >= p - pA - pB and 0 <= p - pA - pB then
		local p2 = (p - pA - pB) / pA
		x2 = maxX + (minX - maxX) * p2
		y2 = maxY
		r = r + pih * (2 + p2)
	else
		local p2 = (p - pA - pB - pA) / pB
		x2 = minX
		y2 = maxY + (minY - maxY) * p2
		r = r + pih * (3 + p2)
	end
	local circle = 2 * d * pih * 2 / 4
	minZ = minZ * 0.25
	local d2 = d * 1.25
	r = pih * 4 * p
	r2 = 0 + pih - pih * 0.75 * p2
	x2 = 0
	y2 = 0
	x = math.cos(r) * d2 * (sideA / 2 + sideB / 4)
	y = math.sin(r) * d2 * (sideB / 2 + sideA / 4)
	z = d2 * math.cos(r2)
	x = x * math.sin(r2)
	y = y * math.sin(r2)
	local m = getElementMatrix(veh)
	local cx, cy, cz = getPositionFromMatrixOffset(m, x, y, z)
	local tx, ty, tz = getPositionFromMatrixOffset(m, x2, y2, z2)
	setCameraMatrix(cx, cy, cz, tx, ty, tz)
	return 10, 10
end

function calculateUV(pixels, x, y)
    local r, g, b, a = dxGetPixelColor(pixels, x, y)
    if r and a > 0 then
        return (r + g + b)/765
    end
end

function dxDrawLineEx(x, y, x2, y2, w)
	dxDrawLine(x + 1, y + 1, x2 + 1, y2 + 1, tocolor(0, 0, 0), w)
	dxDrawLine(x - 1, y + 1, x2 - 1, y2 + 1, tocolor(0, 0, 0), w)
	dxDrawLine(x + 1, y - 1, x2 + 1, y2 - 1, tocolor(0, 0, 0), w)
	dxDrawLine(x - 1, y - 1, x2 - 1, y2 - 1, tocolor(0, 0, 0), w)
end
function teaDecodeBinary(data, key)
	return base64Decode(teaDecode(data, key))
end

function teaEncodeBinary(data, key)
	return teaEncode(base64Encode(data), key)
end

function getRealTimestamp()
    return getRealTime().timestamp
end

function reMap(x, in_min, in_max, out_min, out_max)
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function getPaintJobCount(model)
    if remapContainer[model] then
        return 1
    end
    return false
end

function restoreEditor()
    if not mirrorsReady then
        if isElement(saveFakeScreenSource) then
            destroyElement(saveFakeScreenSource)
        end
        saveFakeScreenSource = dxCreateScreenSource(screenX, screenY)
        dxUpdateScreenSource(saveFakeScreenSource, true)
        dxDrawImage(0, 0, screenX, screenY, saveFakeScreenSource)
        mirrorTries = 0
    end
    rtToDraw = true
end