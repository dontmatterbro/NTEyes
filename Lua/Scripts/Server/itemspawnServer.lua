--spawns items needed for special eyes at the beginning of the round
Hook.Add("roundStart", "spawninfrareditem", function()

	NTEYE.SpawnEffectItems()
	
end)


--check if the items have spawned or not, spawn them if cant be found
Hook.Add("roundStart", "checkitemspawns", function()

	Timer.Wait(function()
	
		if 
			   ItemPrefab.GetItemPrefab("eyethermalHUDitem")==nil
			or ItemPrefab.GetItemPrefab("eyemedicalHUDitem")==nil
			or ItemPrefab.GetItemPrefab("eyeelectricalHUDitem")==nil
		then
			NTEYE.SpawnEffectItems()
		end
	
	end, 10000)
	
end)


function NTEYE.SpawnEffectItems()

		local thermalitemprefab = ItemPrefab.GetItemPrefab("eyethermalHUDitem")
		local medicalitemprefab = ItemPrefab.GetItemPrefab("eyemedicalHUDitem")
		local electricalitemprefab = ItemPrefab.GetItemPrefab("eyeelectricalHUDitem")
		
		local HUDitemposition = Submarine.MainSub.WorldPosition
		
		Entity.Spawner.AddItemToSpawnQueue(thermalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		Entity.Spawner.AddItemToSpawnQueue(medicalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		Entity.Spawner.AddItemToSpawnQueue(electricalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
		
end