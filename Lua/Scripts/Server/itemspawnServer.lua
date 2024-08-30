NTEYE.ItemsSpawned=nil

--spawns items needed for special eyes at the beginning of the round
Hook.Add("roundStart", "SpawnEyeHUDItems", function()

	NTEYE.SpawnEffectItems()
	
end)

--function to spawn HUD items, sometimes roundstart fucks up
--thats why this is being called multiple times in the code
--kind of a failsafe
function NTEYE.SpawnEffectItems()
	local itemprefab
	local HUDitemposition = Submarine.MainSub.WorldPosition
		
	itemprefab = ItemPrefab.GetItemPrefab("eyethermalHUDitem")
	Entity.Spawner.AddItemToSpawnQueue(itemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		
	itemprefab = ItemPrefab.GetItemPrefab("eyemedicalHUDitem")
	Entity.Spawner.AddItemToSpawnQueue(itemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		
	itemprefab = ItemPrefab.GetItemPrefab("eyeelectricalHUDitem")
	Entity.Spawner.AddItemToSpawnQueue(itemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		
	NTEYE.ItemsSpawned=1
end