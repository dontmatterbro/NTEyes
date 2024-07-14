---@diagnostic disable: lowercase-global, undefined-global

NTCBE = {} -- NT CyberEyes
--NTCBE = {} -- this existing should make surgical skill gain work?
NTCBE.Name="NT CyberEyes"
NTCBE.Version = "A1.0.0"
--NTCBE.VersionNum = 01020401
NTCBE.MinNTVersion = "A1.9.4h1"
NTCBE.MinNTVersionNum = 01090401
NTCBE.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil and NTC.RegisterExpansion ~= nil then NTC.RegisterExpansion(NTCBE) end end,1)


if Game.IsMultiplayer and CLIENT then return end

local enabled = Game.GetEnabledContentPackages()
local isEnabled = false
for key, value in pairs(enabled) do
    if value.Name == "NT CyberEyes" then
        isEnabled = true
    end
end

if isEnabled then
    local myModPath = table.pack(...)[1]
    dofile(myModPath .. "/Lua/Scripts/humanstuff.lua")
    dofile(myModPath .. "/Lua/Scripts/helperfunctions.lua")
end
