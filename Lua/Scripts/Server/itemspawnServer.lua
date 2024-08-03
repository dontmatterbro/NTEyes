

Hook.Add("roundStart", "spawninfrareditem", function()
local HUDitemprefab = ItemPrefab.GetItemPrefab("eyethermalHUDitem")
local HUDitemposition = Vector2(1, 1)
Entity.Spawner.AddItemToSpawnQueue(HUDitemprefab, HUDitemposition, nil, nil, function(item) end)
print("roundstartspawn")
end)

