---@diagnostic disable: lowercase-global, undefined-global
if Game.IsMultiplayer and CLIENT then return end

print("Checking if NeuroEyes [fix] is enabled...")

local enabled = Game.GetEnabledContentPackages()
local isEnabled = false
for key, value in pairs(enabled) do
    if value.Name == "NeuroEyes [fix]" then
        isEnabled = true
    end
end

if isEnabled then
    print("NeuroEyes [fix] enabled.")
    local myModPath = table.pack(...)[1]
    dofile(myModPath .. "/Lua/Scripts/humanstuff.lua")
    dofile(myModPath .. "/Lua/Scripts/helperfunctions.lua")
end
