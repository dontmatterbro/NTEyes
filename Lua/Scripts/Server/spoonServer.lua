
Hook.Add('spoonUsed', 'eyestealing', function(effect, dt, item, targets, targetCharacter, worldpos)


	for k, v in pairs(targets) do
  
		if --monster eyes
			v.SpeciesName == "Mudraptor" 
			or v.SpeciesName == "Crawler" 
			or v.SpeciesName == "Hammerhead" 
		then
		
			if 
				not HF.HasAffliction(v, "noeye") 
			then
			
				HF.AddAfflictionLimb(v, "noeye", 11, 2)
				
				Timer.Wait(function()
					local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_monster")
					Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
					Entity.Spawner.AddItemToRemoveQueue(item)
				end, 1)
				
			end
		  
		  
		elseif --husk eyes
			v.SpeciesName == "Husk" 
			or v.SpeciesName == "Crawlerhusk" 
		then
		
			if 
				not HF.HasAffliction(v, "noeye") 
			then
			
				HF.AddAfflictionLimb(v, "noeye", 11, 2)
				
				Timer.Wait(function()
					local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_husk")
					Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
					Entity.Spawner.AddItemToRemoveQueue(item)
				end, 1)
				
			end
		
		
		elseif --terror eyes
			v.SpeciesName == "Charybdis" 
			or v.SpeciesName == "Latcher" 
		then
		
			if 
				not HF.HasAffliction(v, "noeye") 
			then
			
				HF.AddAfflictionLimb(v, "noeye", 11, 2)
				
				Timer.Wait(function()
					local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_terror")
					Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
					Entity.Spawner.AddItemToRemoveQueue(item)
				end, 1)
			end
		
		end

--[[
	if v.SpeciesName == "Human" then
		if 
			not HF.HasAffliction(v, "noeye") 
			and not HF.HasAffliction(v, "th_amputation") 
			
		then print("1")
			if 
				--HF.CanPerformSurgeryOn(targetCharacter) 
				not NTEYE.IsInDivingGear(v) 
				and not HF.HasAffliction(v,"stasis",0.1) 
				and not HF.HasAffliction(v, "robotspawned") 
				
			then print("2")
				Entity.Spawner.AddItemToSpawnQueue(NTEYE.GiveItemBasedOnEye(v), item.WorldPosition, nil, nil, function(item) end) 
				Entity.Spawner.AddItemToRemoveQueue(item)
			print("3")
			end
		end
	end --]]

	end 
end) 