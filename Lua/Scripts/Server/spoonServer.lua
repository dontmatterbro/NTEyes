--Extraction from dead monsters
Hook.Add('spoonUsed', 'eyestealing', function(effect, dt, item, targets, targetCharacter, worldpos)

	for k, spoontarget in pairs(targets) do
		
		if	--human eyes
			spoontarget.IsHuman
		then 
			if 
					not HF.HasAffliction(spoontarget, "noeye") 
				and not HF.HasAffliction(spoontarget, "th_amputation") 
				and	not NTEYE.IsInDivingGear(spoontarget) 
				and not HF.HasAffliction(spoontarget,"stasis",0.1) 
			then
				HF.AddAfflictionLimb(spoontarget, "noeye", 11, 2)
				HF.AddAfflictionLimb(spoontarget, "traumaticshock", 11, 50)
				HF.AddAfflictionLimb(spoontarget, "bleeding", 11, math.random(1,50))
				
				--item.Condition = 10
			end


		else

			
		  
			if --monster eyes
				spoontarget.SpeciesName == "Mudraptor" 
				or spoontarget.SpeciesName == "Crawler" 
				or spoontarget.SpeciesName == "Hammerhead" 
			then
				
				if 
					not HF.HasAffliction(spoontarget, "noeye") 
				then
					
					HF.AddAfflictionLimb(spoontarget, "noeye", 11, 2)
						
					Timer.Wait(function()
						local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_monster")
						Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
						Entity.Spawner.AddItemToRemoveQueue(item)
					end, 1)
						
				end
				  
				  
			elseif --husk eyes
				spoontarget.SpeciesName == "Husk" 
				or spoontarget.SpeciesName == "Crawlerhusk" 
			then
				
				if 
					not HF.HasAffliction(spoontarget, "noeye") 
				then
					
					HF.AddAfflictionLimb(spoontarget, "noeye", 11, 2)
						
					Timer.Wait(function()
						local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_husk")
						Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
						Entity.Spawner.AddItemToRemoveQueue(item)
					end, 1)
						
				end
				
				
			elseif --terror eyes
				spoontarget.SpeciesName == "Charybdis" 
				or spoontarget.SpeciesName == "Latcher" 
			then
				
				if 
					not HF.HasAffliction(spoontarget, "noeye") 
				then
					
					HF.AddAfflictionLimb(spoontarget, "noeye", 11, 2)
						
					Timer.Wait(function()
						local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_terror")
						Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
						Entity.Spawner.AddItemToRemoveQueue(item)
					end, 1)
				end
				
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

				
			then print("2")
				Entity.Spawner.AddItemToSpawnQueue(NTEYE.GiveItemBasedOnEye(v), item.WorldPosition, nil, nil, function(item) end) 
				Entity.Spawner.AddItemToRemoveQueue(item)
			print("3")
			end
		end--]]
	

	end 
	
end) 



