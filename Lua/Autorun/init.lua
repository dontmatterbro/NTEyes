NTEYE = {} --Double the eyes double the trouble
NTEYE.Name = "Eyes"
NTEYE.Version = "2.0.1h4"
NTEYE.VersionNum = 020000104
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
		print("Error loading NT Eyes 2.0: It SEEms Neurotrauma isn't loaded!")
		return
	end

	--server side scripts
	if SERVER or (CLIENT and not Game.IsMultiplayer) then
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/humanUpdate.lua") --passive update checks
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/items.lua") --item functions
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/losWarning.lua") --warning in chat about line of sight
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/hudItemSpawn.lua") --spawns required items for drawing client-side huds
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/serverReceive.lua") --server-client communications
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/multiScalpel.lua") --multipurpouse scalpel override
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/onDamaged.lua") --physical damage calculation
		dofile(NTEYE.Path .. "/Lua/Scripts/Server/spoon.lua") --spoon
	end

	--client side scripts
	if CLIENT then
		dofile(NTEYE.Path .. "/Lua/Scripts/Client/clientUpdate.lua") --client-side updates (visual)
		dofile(NTEYE.Path .. "/Lua/Scripts/Client/clientHUD.lua") --writes hud over screen
		dofile(NTEYE.Path .. "/Lua/Scripts/Client/clientControls.lua") --client keyboard controls
		dofile(NTEYE.Path .. "/Lua/Scripts/Client/healthScanner.lua") --health scanner code for medical eyes
		dofile(NTEYE.Path .. "/Lua/Scripts/Client/clientSend.lua") --server-client communications
	end

	--shared scripts
	dofile(NTEYE.Path .. "/Lua/Scripts/Shared/configData.lua")
	dofile(NTEYE.Path .. "/Lua/Scripts/Shared/interfaceEnable.lua")

	--compatibility scripts
	--dofile(NTEYE.Path .. "/Lua/Scripts/Compatibility/place.holder")
end, 1)
