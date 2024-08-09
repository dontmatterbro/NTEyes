--spawns items needed for special eyes at the beginning of the round
Hook.Add("roundStart", "spawninfrareditem", function()

		if Submarine.MainSub == nil then print("no sub exists") return end
		
		local thermalitemprefab = ItemPrefab.GetItemPrefab("eyethermalHUDitem")
		local medicalitemprefab = ItemPrefab.GetItemPrefab("eyemedicalHUDitem")
		local electricalitemprefab = ItemPrefab.GetItemPrefab("eyeelectricalHUDitem")
		
		local HUDitemposition = Submarine.MainSub.WorldPosition
		
		Entity.Spawner.AddItemToSpawnQueue(thermalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		Entity.Spawner.AddItemToSpawnQueue(medicalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		Entity.Spawner.AddItemToSpawnQueue(electricalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
	
end)

