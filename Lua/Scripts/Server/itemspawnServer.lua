NTEYE.ItemsSpawned=nil

--spawns items needed for special eyes at the beginning of the round
Hook.Add("roundStart", "SpawnEyeHUDItems", function()

	NTEYE.SpawnEffectItems()
	
end)

--function to spawn HUD items, sometimes roundstart fucks up
--thats why this is being called multiple times in the code
--kind of a failsafe
function NTEYE.SpawnEffectItems()

		local thermalitemprefab = ItemPrefab.GetItemPrefab("eyethermalHUDitem")
		local medicalitemprefab = ItemPrefab.GetItemPrefab("eyemedicalHUDitem")
		local electricalitemprefab = ItemPrefab.GetItemPrefab("eyeelectricalHUDitem")
		
		local HUDitemposition = Submarine.MainSub.WorldPosition
		
		Entity.Spawner.AddItemToSpawnQueue(thermalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		Entity.Spawner.AddItemToSpawnQueue(medicalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		Entity.Spawner.AddItemToSpawnQueue(electricalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		
		NTEYE.ItemsSpawned=1
end