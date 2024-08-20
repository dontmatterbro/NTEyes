--Spoon eye extraction from monsters and humans alike
Hook.Add('spoonUsed', 'eyestealing', function(effect, dt, item, targets, targetCharacter, worldpos)

	spoonEyeDamage=nil
	spoonEyeType=nil

	for k, spoontarget in pairs(targets) do
	print(spoontarget.Name)
		if 
			spoontarget.type==LimbType.Head 
		then
			spoontarget = spoontarget.character
		else return end
		
		if	--human eyes
			spoontarget.IsHuman
			and (spoontarget.IsMale or spoontarget.IsFemale)
		then 
			if --alive
				not spoontarget.IsDead
			then
				if --has eyes
						not HF.HasAffliction(spoontarget, "noeye") 
					and not HF.HasAffliction(spoontarget, "th_amputation")  
					and not HF.HasAffliction(spoontarget, "sh_amputation")  
					and not HF.HasAffliction(spoontarget, "stasis", 0.1) 
					and	not NTEYE.HasEyeProtection(spoontarget)
				then
					NTEYE.SpoonEyeDetect(spoontarget)
					
					NTEYE.ClearCharacterEyeAfflictions(spoontarget)
					Timer.Wait(function() end, 1)
					
					HF.AddAfflictionLimb(spoontarget, "noeye", 11, 2)
					HF.AddAfflictionLimb(spoontarget, "traumaticshock", 11, math.random(15,50))
					HF.AddAfflictionLimb(spoontarget, "bleeding", 11, math.random(1,25))
					
					NTEYE.PlayScream(spoontarget)
					
					Entity.Spawner.AddItemToSpawnQueue(spoonEyeType, item.WorldPosition, spoonEyeDamage, nil, function(item) end)
					
					Entity.Spawner.AddItemToRemoveQueue(item) --remove spoon after use
					
				elseif --has dead eyes
							HF.HasAffliction(spoontarget, "eyesdead")
					and not HF.HasAffliction(spoontarget, "th_amputation")
					and not HF.HasAffliction(spoontarget, "sh_amputation")
					and not HF.HasAffliction(spoontarget, "stasis", 0.1)
					and	not NTEYE.HasEyeProtection(spoontarget)
				then
					NTEYE.ClearCharacterEyeAfflictions(spoontarget)
					Timer.Wait(function() end, 1)
					
					HF.AddAfflictionLimb(spoontarget, "noeye", 11, 2)
					HF.AddAfflictionLimb(spoontarget, "traumaticshock", 11, 15)
					HF.AddAfflictionLimb(spoontarget, "bleeding", 11, math.random(1,10))
					
					NTEYE.PlayScream(spoontarget)
					
					Entity.Spawner.AddItemToRemoveQueue(item) --remove spoon after use
				end
			
			else --dead
				if --has functional eyes
						not HF.HasAffliction(spoontarget, "noeye") 
					and	not HF.HasAffliction(spoontarget, "eyesdead") 
					and not HF.HasAffliction(spoontarget, "th_amputation")
					and not HF.HasAffliction(spoontarget, "sh_amputation")
					and	not NTEYE.HasEyeProtection(spoontarget)
				then
					NTEYE.SpoonEyeDetect(spoontarget)
					
					NTEYE.ClearCharacterEyeAfflictions(spoontarget)
					Timer.Wait(function() end, 1)
					
					local prefab = AfflictionPrefab.Prefabs["noeye"]
					local affliction = prefab.Instantiate(3)
										
					Entity.Spawner.AddItemToSpawnQueue(spoonEyeType, item.WorldPosition, spoonEyeDamage, nil, function(item) end)
					
					Entity.Spawner.AddItemToRemoveQueue(item)
					
					HF.AddAfflictionLimb(spoontarget, "noeye", 11, 2)
					spoontarget.CharacterHealth.ApplyAffliction(spoontarget.AnimController.GetLimb(LimbType.Head), affliction, false)
					
					Networking.CreateEntityEvent(spoontarget, Character.CharacterStatusEventData.__new(true)) --thanks ydrec
				end
			
			end


		else --non human eyes (old code revised)

			spoonEyeDamage = math.random(0,100)
			
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
						
						Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, spoonEyeDamage, nil, function(item) end)
						
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
						
						Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, spoonEyeDamage, nil, function(item) end)
						
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
						
						Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, spoonEyeDamage, nil, function(item) end)
						
						Entity.Spawner.AddItemToRemoveQueue(item)
						
					end, 1)
				end
				
			end
			
		end 
		
	end 
	
end)


function NTEYE.SpoonEyeDetect(character)

	if --check for eye damage
		character.CharacterHealth.GetAffliction("eyedamage")
	then
	eyeDamageAffliction = character.CharacterHealth.GetAffliction("eyedamage")
	eyeDamageValue = eyeDamageAffliction.Strength
	
	else
	eyeDamageValue = 0
	end
	
	
	if --eye condition value
		not character.IsDead
	then --alive
		spoonEyeDamage = 100 - eyeDamageValue - math.random(10,35)
	
	else --dead
		spoonEyeDamage = 100 - eyeDamageValue - math.random(10,70)
	end
	
	
	if --fix negative value
		spoonEyeDamage <= 0
	then
		spoonEyeDamage = 0
	end
	
	
	if --eye type value
		HF.HasAffliction(character, "eyebionic") 
	then
		spoonEyeType = ItemPrefab.GetItemPrefab("transplant_eyes_bionic")

	elseif
		HF.HasAffliction(character, "eyenight") 
	then
		spoonEyeType = ItemPrefab.GetItemPrefab("transplant_eyes_night")
	
	elseif
		HF.HasAffliction(character, "eyeinfrared") 
	then
		spoonEyeType = ItemPrefab.GetItemPrefab("transplant_eyes_infrared")
		
	elseif
		HF.HasAffliction(character, "eyeplastic") 
	then
		spoonEyeType = ItemPrefab.GetItemPrefab("transplant_eyes_plastic")	
	
	elseif
		HF.HasAffliction(character, "eyemonster") 
	then
		spoonEyeType = ItemPrefab.GetItemPrefab("transplant_eyes_monster")
		
	elseif
		HF.HasAffliction(character, "eyehusk") 
	then
		spoonEyeType = ItemPrefab.GetItemPrefab("transplant_eyes_husk")
	
	elseif
		HF.HasAffliction(character, "eyeterror") 
	then
		spoonEyeType = ItemPrefab.GetItemPrefab("transplant_eyes_terror")
	
	else
		spoonEyeType = ItemPrefab.GetItemPrefab("transplant_eyes")
	end
end

function NTEYE.PlayScream(character)

	if 
		character.IsMale
	then
		HF.GiveItem(character,"nteye_male_scream")

	elseif 
		character.IsFemale
	then
		HF.GiveItem(character,"nteye_female_scream")
	end

end