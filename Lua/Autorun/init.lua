NTEYE = {} --Double the eyes double the trouble
NTEYE.Name = "Eyes 2.0"
NTEYE.Version = "A2.0"
NTEYE.VersionNum = 020000000
NTEYE.MinNTVersion = "A1.12.1"
NTEYE.MinNTVersionNum = 01120100
NTEYE.Path = table.pack(...)[1]
Timer.Wait(function()
	if NTC ~= nil then
		NTC.RegisterExpansion(NTEYE)
		NTC.AddPreHumanUpdateHook(NTEYE.PreUpdateHuman)
		NTC.AddHumanUpdateHook(NTEYE.PostUpdateHuman)
	end
end, 1)

Timer.Wait(function()
	if SERVER and NTC == nil then --check if NT is installed
		print("Error loading NT Eyes: It SEEms Neurotrauma isn't loaded!")
		return
	end

	--server side scripts
	if SERVER or (CLIENT and not Game.IsMultiplayer) then
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/humanupdate.lua") -- this is a placeholder for the server side scripts, it will be replaced with the actual script in the future
	end

	--client side scripts
	if CLIENT then
		--dofile(NTEYE.Path .. "/Lua/Scripts/Client/place.holder") -- this is a placeholder for the client side scripts, it will be replaced with the actual script in the future
	end
end, 1)
