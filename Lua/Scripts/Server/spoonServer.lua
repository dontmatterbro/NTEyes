
Hook.Add('spoonUsed', 'eyestealing', function(effect, dt, item, targets, worldpos)


  for k, v in pairs(targets) do
  --item.Condition == math.random(80,90) 
  
    if v.SpeciesName == "Mudraptor" or v.SpeciesName == "Crawler" or v.SpeciesName == "Hammerhead" then
		if not HF.HasAffliction(v, "noeye") then
			HF.AddAfflictionLimb(v, "noeye", 11, 2)
			Timer.Wait(function()
				local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_monster")
				Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
				Entity.Spawner.AddItemToRemoveQueue(item)
			end, 1)
		end
	  
	  
    elseif v.SpeciesName == "Husk" or v.SpeciesName == "Crawlerhusk" then
		if not HF.HasAffliction(v, "noeye") then
			HF.AddAfflictionLimb(v, "noeye", 11, 2)
			Timer.Wait(function()
				local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_husk")
				Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
				Entity.Spawner.AddItemToRemoveQueue(item)
			end, 1)	
		end
	
	
    elseif v.SpeciesName == "Charybdis" or v.SpeciesName == "Latcher" then
		if not HF.HasAffliction(v, "noeye") then
			HF.AddAfflictionLimb(v, "noeye", 11, 2)
			Timer.Wait(function()
				local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_terror")
				Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
				Entity.Spawner.AddItemToRemoveQueue(item)
			end, 1)
		end
	end
  
  
  
  end 
end) 