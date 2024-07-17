NTEYE = {} -- Neurotrauma Eyes
NTEYE.Name="Eyes"
NTEYE.Version = "A1.0"
NTEYE.VersionNum = 01000000
NTEYE.MinNTVersion = "A1.9.4h1"
NTEYE.MinNTVersionNum = 01090401
NTEYE.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil then NTC.RegisterExpansion(NTEYE) end end,1)


if SERVER or CLIENT then --we have CLIENT side features so it needs run on both, 
    Timer.Wait(function() --altough now that I think of it we should seperate those
        if SERVER and NTC == nil then
            print("Error loading NT Eyes: It SEEms Neurotrauma isn't loaded!")
            return
        end

        dofile(NTEYE.Path.."/Lua/Scripts/humanstuff.lua")
  --    dofile(NTEYE.Path.."/Lua/Scripts/NAMEGOESHERE.lua")
		if SERVER then
        NTC.AddPreHumanUpdateHook(NTEYE.PreUpdateHuman) --idk what these do
        NTC.AddHumanUpdateHook(NTEYE.PostUpdateHuman) --gonna learn probably important
		end
    end,1)
end


--[[
local enabled = Game.GetEnabledContentPackages()
local isEnabled = false
for key, value in pairs(enabled) do
    if value.Name == "NT Eyes" then
        isEnabled = true
    end
end

if isEnabled then
    local myModPath = table.pack(...)[1]
    dofile(myModPath .. "/Lua/Scripts/humanstuff.lua")
--    dofile(myModPath .. "/Lua/Scripts/eyesurgery.lua")
--   dofile(myModPath .. "/Lua/Scripts/eyeupdate.lua")
--    dofile(myModPath .. "/Lua/Scripts/helperfunctions.lua") I don't think we need this, lua probably can use the NT code
--	dofile(myModPath .. "/Lua/Scripts/newhumanstuff.lua") <----- we will switch to this once the code is optimized
end
--]]