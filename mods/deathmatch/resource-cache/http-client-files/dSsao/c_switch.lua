--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
--
--	To switch on:
--			triggerEvent( "onClientSwitchAO", root, true )
--
--	To switch off:
--			triggerEvent( "onClientSwitchAO", root, false )
--
----------------------------------------------------------------
----------------------------------------------------------------


--------------------------------
-- onClientResourceStart
--		Auto switch on at start
--------------------------------
--[[addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		triggerEvent( "onClientSwitchAO", resourceRoot, true )
	end
)]]

--------------------------------
-- Command handler
--		Toggle via command
--------------------------------
addCommandHandler( "ssao",
	function()
		triggerEvent( "onClientSwitchAO", resourceRoot, not aoShader.enabled )
		print(getssaodata())
	end
)


--------------------------------
-- Switch effect on or off
--------------------------------
function handleonClientSwitchAO( bOn )
	if bOn then
		enableAO()
	else
		disableAO()
	end
end

addEvent( "onClientSwitchAO", true )
addEventHandler( "onClientSwitchAO", resourceRoot, handleonClientSwitchAO )
