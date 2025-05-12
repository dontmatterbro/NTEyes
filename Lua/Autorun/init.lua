NTEYE = {} --Double the eyes double the trouble
NTEYE.Name = "Eyes"
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
	if SERVER and (NTC == nil) then --check if NT is installed
		print("Error loading NT Eyes: It SEEms Neurotrauma isn't loaded!")
		return
	end

	--server side scripts
	if SERVER or (CLIENT and not Game.IsMultiplayer) then
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/humanupdate.lua")
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/items.lua")
	end
	--client side scripts
	if CLIENT then
		dofile(NTEYE.Path .. "/Lua/Scripts/Client/clientupdate.lua")
	end

	--shared scripts
	--dofile(NTEYE.Path .. "/Lua/Scripts/Shared/place.holder")

	--compatibility scripts
	--dofile(NTEYE.Path .. "/Lua/Scripts/Compatibility/place.holder")
end, 1)
