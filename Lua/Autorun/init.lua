NTEYE = {} -- Neurotrauma Eyes
NTEYE.Name="Eyes"
NTEYE.Version = "A1.0.5"
NTEYE.VersionNum = 01000000
NTEYE.MinNTVersion = "A1.9.4h1"
NTEYE.MinNTVersionNum = 01090401
NTEYE.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil then NTC.RegisterExpansion(NTEYE) end end,1)

-- singleplayer bit buggy due to client only features, maybe a add-on patch later on? why not just make a local server like minecraft barodevs :( ???

Timer.Wait(function() 
	if SERVER and NTC == nil then --checks if NT is installed
		print("Error loading NT Eyes: It SEEms Neurotrauma isn't loaded!")
		return
	end
	
		--server side scripts
	if SERVER or (CLIENT and not Game.IsMultiplayer) then
		dofile(NTEYE.Path.."/Lua/Scripts/Server/eyeupdateServer.lua")
		dofile(NTEYE.Path.."/Lua/Scripts/Server/eyesurgeryServer.lua")
		dofile(NTEYE.Path.."/Lua/Scripts/Server/eyeondamageServer.lua")
		dofile(NTEYE.Path.."/Lua/Scripts/Server/spoonServer.lua")
		dofile(NTEYE.Path.."/Lua/Scripts/Server/eyedecoServer.lua")
		dofile(NTEYE.Path.."/Lua/Scripts/Server/itemspawnServer.lua")
	end
		
		--client side scripts
	if CLIENT then
        dofile(NTEYE.Path.."/Lua/Scripts/Client/eyeupdateClient.lua") 
	end

end,1)