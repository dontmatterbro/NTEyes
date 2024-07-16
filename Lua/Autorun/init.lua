---@diagnostic disable: lowercase-global, undefined-global <----- idk what this is

--Adds NT Eyes as a Neurotrauma expansion.
NTCBE = {} -- NT Eyes
--NTCBE = {} -- this existing should make surgical skill gain work? <--- check this out for NT Surgery comp
NTCBE.Name="NT Eyes"
NTCBE.Version = "A1.0.0"
--NTCBE.VersionNum = 01020401  <------ idk what this is we need to ask guns
NTCBE.MinNTVersion = "A1.9.4h1"
NTCBE.MinNTVersionNum = 01090401
NTCBE.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil and NTC.RegisterExpansion ~= nil then NTC.RegisterExpansion(NTCBE) end end,1)


--if Game.IsMultiplayer and CLIENT then return end <------ causes issues better to assign it to scripts individualy 


-- Checks if NT Eyes is enabled
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
    dofile(myModPath .. "/Lua/Scripts/helperfunctions.lua")
--	dofile(myModPath .. "/Lua/Scripts/newhumanstuff.lua") <----- we will switch to this once the code is optimized
end
