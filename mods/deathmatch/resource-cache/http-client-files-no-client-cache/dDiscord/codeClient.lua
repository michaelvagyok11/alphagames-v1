--Kicsit alakitottam rajta, amugy a buttonoket kivettek a discord rpcbol, szoval mar tudsz gombokat beallitani az activitykhez :'(


local app_id = "1264347993918673049"

function ConnectToDiscordRPC()
  setDiscordApplicationID(app_id)

   if isDiscordRichPresenceConnected() then
      local name = getPlayerName(localPlayer)

      local teamCache = {["Defender"] = "DM - Védő", ["Attacker"] = "DM - Támadó"}
      local currentTeam = getElementData(localPlayer, "a.Team<DM>")
      local gamemode = getElementData(localPlayer, "a.Gamemode") or "LOBBY";

      if getElementData(localPlayer, "loggedIn") then
        name = getPlayerName(localPlayer)
      end

      if gamemode == 1 then
        name = name .. " - " .. teamCache[currentTeam]
      end
      
      setDiscordRichPresenceAsset("logo2", "alphaGames v2")
      setDiscordRichPresenceButton(1, "Előregisztrációs szerver", "mtasa://213.181.206.21:22453")
      setDiscordRichPresenceButton(2, "Discord", "https://discord.gg/3q3YHhAAy5")

      if getElementData(localPlayer, "loggedIn") then
        setDiscordRichPresenceState("Játékban")
      else
        setDiscordRichPresenceState("Nincs bejeletkezve")
      end

      setDiscordRichPresenceDetails(name)

      local players = getElementsByType("player")

      setDiscordRichPresencePartySize(#players, 128)
   else
      print("RPC: Discord RPC failed to connect")
   end
end
addEventHandler("onClientResourceStart", resourceRoot, ConnectToDiscordRPC)

addEventHandler("onClientElementDataChange", localPlayer,
    function(key, old, new)
        if key == "loggedIn" and new then
            setDiscordRichPresenceState("Játékban")
        elseif key == "visibleName" and new then
            setDiscordRichPresenceDetails(new)
        else
            setDiscordRichPresenceState("Játékban")
        end
    end
)

addEventHandler("onClientPlayerQuit", root,
  function()
    setTimer(function()
      local players = getElementsByType("player")
      setDiscordRichPresencePartySize(#players, 128)
    end, 1000, 1)
  end
)

addEventHandler("onClientResourceStop", resourceRoot, function()
    resetDiscordRichPresenceData()
end)


-- REGI KOD: 

--[[local discordApplicationID = "1264347993918673049"
local playersInServer = #getElementsByType("player")

function connectFasszopoDiscord()
    setDiscordApplicationID(discordApplicationID)

    local playerID = getElementData(localPlayer, "d/PlayerID") or "(bejelentkezés alatt)"
    
    if isDiscordRichPresenceConnected() and getElementData(localPlayer, "loggedIn") then
        local name = getElementData(localPlayer, "a.PlayerName")

        setDiscordRichPresenceAsset("logo2", "alphaGames v2")
		setDiscordRichPresenceButton(1, "Előregisztrációs szerver", "mtasa://213.181.206.21:22453")
        setDiscordRichPresenceButton(2, "Discord", "https://discord.gg/3q3YHhAAy5")
        setDiscordRichPresenceState(""..playersInServer.."/128 játékos játszik")
        setDiscordRichPresenceDetails(name .. " ("..playerID..")")

        print("connectelt ".. name .."")
	end
end
setTimer(connectFasszopoDiscord, 5000, 0)

addEventHandler("onClientResourceStart", resourceRoot, connectFasszopoDiscord)
 
addEventHandler("onClientResourceStop", resourceRoot, function()
    resetDiscordRichPresenceData()
end)]]