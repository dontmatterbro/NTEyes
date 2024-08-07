--spawns items needed for special eyes at the beginning of the round
Hook.Add("roundStart", "spawninfrareditem", function()

		if Submarine.MainSub == nil then print("no sub exists") return end
		local thermalitemprefab = ItemPrefab.GetItemPrefab("eyethermalHUDitem")
		local HUDitemposition = Submarine.MainSub.WorldPosition
		Entity.Spawner.AddItemToSpawnQueue(thermalitemprefab, HUDitemposition, nil, nil, nil, function(item) end)
	
end)

