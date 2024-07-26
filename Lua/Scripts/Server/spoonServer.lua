
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

--[[ add humans to spoon  
	if not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "th_amputation") then
		if HF.CanPerformSurgeryOn(targetCharacter) then
			NTEYE.GiveItemBasedOnEye(targetCharacter)
			100 - math.random(10, 50) - HF.GetAfflictionStrength(character, "eyedamage", 0) this wont work but i cant be bothered rn
		end
	end
--]]  

	end 
end) 