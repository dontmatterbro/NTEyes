NTEYE.UpdateCooldown = 0
NTEYE.UpdateInterval = 120
NTEYE.Deltatime = NTEYE.UpdateInterval/60 -- Time in seconds that transpires between updates

-- This Hook triggers NTEYE.Update function.
Hook.Add("think", "NTEYE.updatetriggerserver", function()
    if HF.GameIsPaused() then return end

    NTEYE.UpdateCooldown = NTEYE.UpdateCooldown-1
    if (NTEYE.UpdateCooldown <= 0) then
        NTEYE.UpdateCooldown = NTEYE.UpdateInterval
        NTEYE.Update() 
    end
end)

--checks if character is in diving gear on demand
function NTEYE.IsInDivingGear(character)
  local outerSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
  local headSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)

  if outerSlot and outerSlot.HasTag("diving") or outerSlot and outerSlot.HasTag("deepdiving") or headSlot and headSlot.HasTag("diving") or headSlot and headSlot.HasTag("deepdiving") then
    return true
  end
--  return false
end

--checks if character is wearing eye protection
function NTEYE.HasEyeProtection(character)
	local outerSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
	local headSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)

	if 
		outerSlot and outerSlot.HasTag("diving")
		or outerSlot and outerSlot.HasTag("deepdiving")
		or headSlot and headSlot.HasTag("diving")
		or headSlot and headSlot.HasTag("deepdiving")
		or headSlot and headSlot.HasTag()
	then
	
	return true	end

end

-- registers slot for above check
function NTEYE.GetItemInSlot(character, slot)
  if character and slot then
    return character.Inventory.GetItemInLimbSlot(slot)
  end
end

--updates human eyes		horrendous code format, I am gonna fix this later on when I learn proper lua programming, works for now tho
function NTEYE.UpdateHumanEye(character)

	if  	--checks if there are eyes
		NTEYE.HasEyes(character)
	then
	
	--print(character.PressureProtection)
	--print(character.IsImmuneToPressure)
		if 		--neurotrauma damage
					HF.HasAffliction(character, "cerebralhypoxia", 60) 
			and not HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "eyeplastic")
			and not HF.HasAffliction(character, "stasis")
			
		then
			HF.AddAfflictionLimb(character, "eyedamage", 11, 0.6)
		end
		  
		  
		if 		--hypoxemia damage
					HF.HasAffliction(character, "hypoxemia", 80) 
			and not HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "eyeplastic")
			and not HF.HasAffliction(character, "stasis")
		then
		
					HF.AddAfflictionLimb(character, "eyedamage", 11, 0.8)
					
		elseif
					HF.HasAffliction(character, "hypoxemia", 40) 
			and not HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "eyeplastic")
			and not HF.HasAffliction(character, "stasis") 
			
		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, 0.5)
		end
		  
		  
		if 		--stroke damage
					HF.HasAffliction(character, "stroke", 5) 
			and not HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "eyeplastic")
			and not HF.HasAffliction(character, "stasis") 
			
		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, 0.3)
		end
		  
		  
		if 		--sepsis damage
					HF.HasAffliction(character, "sepsis", 20) 
			and not HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "eyeplastic")
			and not HF.HasAffliction(character, "stasis") 
			
		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, 0.1)
		end
		  
		  
		if 		--blood pressure damage 
					HF.HasAffliction(character, "bloodpressure", 150)
			and not HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "eyeplastic")
			and not HF.HasAffliction(character, "stasis") 
			
		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, 0.3)
		end
		  
		if		--radiation damage
					HF.HasAffliction(character, "radiationsickness", 60)
			and not HF.HasAffliction(character, "eyebionic")
		  	and not HF.HasAffliction(character, "eyeplastic")
			and not HF.HasAffliction(character, "stasis")
		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, 0.1)
					
		elseif
					HF.HasAffliction(character, "radiationsickness", 60)
				and HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "stasis")
		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, 0.3)
		end
		  
		if 		--eyeshock progression
					HF.HasAffliction(character, "eyeshock") 
			and not HF.HasAffliction(character, "stasis") 
			
		then
					HF.AddAfflictionLimb(character, "eyeshock", 11, 3)
		end
				
				
		if 		--eyeshock damage
					HF.HasAffliction(character, "eyeshock", 60) 
			and not HF.HasAffliction(character, "stasis") 
			
		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, 2)
		end
		  
		  
		if 		--immunity check for eyeshock
					HF.HasAffliction(character, "eyeshock") 
			and (not HF.HasAffliction(character, "immunity", 10)) or HF.HasAffliction(character, "eyebionic")

		then
					HF.AddAfflictionLimb(character, "eyeshock", 11, -1000) 
		end
		  
		--[[ unneeded bloat i dont like it
		if 		--two eye blur
					HF.HasAffliction(character, "eyedamage", 37) 
			and not HF.HasAffliction(character, "eyeone") 

		then
					NTC.SetSymptomTrue(character, "sym_blurredvision", 2)
		end
		
		
		if 		--one eye blur
					HF.HasAffliction(character, "eyedamage", 75) 

		then
					NTC.SetSymptomTrue(character, "sym_blurredvision", 2)
		end
		--]]

		if 		--give cataract over 10 damage at a chance
					HF.Chance(0.002) 
				and HF.HasAffliction(character, "eyedamage", 10) 
			and not HF.HasAffliction(character, "eyebionic") 
			and not HF.HasAffliction(character, "eyeplastic") 

		then
					HF.AddAfflictionLimb(character, "eyecataract", 11, 1)
		end
		  
		  
		if 		--cataract progression
					HF.HasAffliction(character, "eyecataract", 0.1) 
			and not HF.HasAffliction(character, "stasis") 

		then
					HF.AddAfflictionLimb(character, "eyecataract", 11, 0.4)
		end
		  
		  
		if 		--cataract eye blur
					HF.HasAffliction(character, "eyecataract", 40) 

		then
					NTC.SetSymptomTrue(character, "sym_blurredvision", 4)
		end
		  
		
		if 		--glasses check for eyezoomClient.lua
					NTEYE.GetItemInSlot(character, InvSlotType.Head) 
				and NTEYE.GetItemInSlot(character, InvSlotType.Head).Prefab.identifier == "eyeglasses" 

		then
					HF.AddAfflictionLimb(character, "hasglasses", 11, 2)
					NTC.SetSymptomFalse(character, "sym_blurredvision", 2)
		else
					HF.AddAfflictionLimb(character, "hasglasses", 11, -1000)
		end
		
		
		if 		--barotrauma damage
					character.AnimController.HeadInWater
				and	character.InPressure
			and not character.IsImmuneToPressure
			and not NTEYE.IsInDivingGear(character)
			and not HF.HasAffliction(character, "eyemonster")
			and not HF.HasAffliction(character, "eyeterror")
			and not HF.HasAffliction(character, "eyehusk")
			and not HF.HasAffliction(character, "eyeplastic")
			and not HF.HasAffliction(character, "stasis")

		then
			if
				HF.HasAffliction(character, "eyebionic")
			then
				HF.AddAfflictionLimb(character, "eyedamage", 11, 8)
			else
				HF.AddAfflictionLimb(character, "eyedamage", 11, 5)
			end
		end
		  
		  
		if 		--remove eye over 50 damage
					HF.HasAffliction(character, "eyedamage", 50) 
			and not HF.HasAffliction(character, "eyeone") 

		then
					HF.AddAfflictionLimb(character, "eyeone", 11, 2)
		end
		
		
		if 		--remove eyes over 99 damage
					HF.HasAffliction(character, "eyedamage", 99) 

		then
					NTEYE.ClearCharacterEyeAfflictions(character) -- in eyesurgeryServer.lua
					HF.AddAfflictionLimb(character, "eyesdead", 11, 2)
		end
		  
		  
		if 		--randomly blind left or right eye
					HF.HasAffliction(character, "eyeone") 
			and not HF.HasAffliction(character, "lefteyegone") 
			and not HF.HasAffliction(character, "righteyegone") 

		then 
			if math.random(1,2) == 1 
			
			then 
						HF.AddAfflictionLimb(character, "lefteyegone", 11, 2) 
				   else HF.AddAfflictionLimb(character, "righteyegone", 11, 2)	
			end
		end		  


		if 		--give eye back below 50 damage (for bionic primarily)
					HF.HasAffliction(character, "eyeone")
				and	HF.HasAffliction(character, "eyebionic")
			and not	HF.HasAffliction(character, "eyedamage", 50)
			
		then
					character.CharacterHealth.ReduceAfflictionOnAllLimbs("eyeone", 1000)
					character.CharacterHealth.ReduceAfflictionOnAllLimbs("lefteyegone", 1000)
					character.CharacterHealth.ReduceAfflictionOnAllLimbs("righteyegone", 1000)
		end

		  
		if 		--passive healing below 51 damage
					HF.HasAffliction(character, "eyedamage") 
			and not HF.HasAffliction(character, "eyedamage", 51) 
			and not HF.HasAffliction(character, "eyebionic") 
			and not HF.HasAffliction(character, "eyeplastic") 

		then 
					HF.AddAfflictionLimb(character, "eyedamage", 11, -0.05)
		end


		if 		--passive healing above 51 damage
					HF.HasAffliction(character, "eyedamage", 51) 
			and not HF.HasAffliction(character, "eyedamage", 80)
			and not HF.HasAffliction(character, "eyebionic") 
			and not HF.HasAffliction(character, "eyeplastic") 

		then 
					HF.AddAfflictionLimb(character, "eyedamage", 11, -0.05)
		end
		  
		  
		if 		--eyedrop healing below 51 damage
					HF.HasAffliction(character, "eyedrop") 
			and not HF.HasAffliction(character, "eyebionic") 
			and not HF.HasAffliction(character, "eyeplastic") 
			and not HF.HasAffliction(character, "eyedamage", 51) 

		then 	--I will let surgery and drops stack
					HF.AddAfflictionLimb(character, "eyedamage", 11, -0.2)
		end


		if 		--eyedrop healing above 51 damage
					HF.HasAffliction(character, "eyedrop")
				and HF.HasAffliction(character, "eyedamage", 51)
			and not HF.HasAffliction(character, "eyedamage", 80)
			and not HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "eyeplastic")

		then 
					HF.AddAfflictionLimb(character, "eyedamage", 11, -0.1)
		end


		if 		--eye drop decay
					HF.HasAffliction(character, "eyedrop") 

		then
					HF.AddAfflictionLimb(character, "eyedrop", 11, -2)
		end


		if 		--laser healing below 50 damage
					HF.HasAffliction(character, "lasereyesurgery") 
			and not HF.HasAffliction(character, "eyedamage", 50)
			and not HF.HasAffliction(character, "eyebionic")
			and not HF.HasAffliction(character, "eyeplastic")

		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, -0.8)
		end


		if 		--laser healing above 51 damage
					HF.HasAffliction(character, "lasereyesurgery") 
				and HF.HasAffliction(character, "eyedamage", 51) 
			and not HF.HasAffliction(character, "eyedamage", 80)
			and not HF.HasAffliction(character, "eyebionic") 
			and not HF.HasAffliction(character, "eyeplastic") 

		then
					HF.AddAfflictionLimb(character, "eyedamage", 11, -0.4)
		end


		if 		--laser decay
					HF.HasAffliction(character, "lasereyesurgery") 

		then
					HF.AddAfflictionLimb(character, "lasereyesurgery", 11, -2)
		end


		if 		--husk infection chance from eye
					HF.HasAffliction(character, "eyehusk") 
				and HF.Chance(0.003) 

		then
					HF.AddAffliction(character, "huskinfection", 5)
		end
	
	
	end
end 


-- Gets to run once every two seconds triggers NTEYE.UpdateHumanEye
function NTEYE.Update()
	--print("eyeupdatetest")
		local updateHumanEyes = {}
		local amountHumanEyes = 0
		
		
	--fetch character for update
	for key, character in pairs(Character.CharacterList) do
		if not character.IsDead then
			if character.IsHuman then
				table.insert(updateHumanEyes, character)
				amountHumanEyes = amountHumanEyes + 1
			end
		end
	end
	
	--spread the characters out over the duration of an update so that the load isnt done all at once
    for key, value in pairs(updateHumanEyes) do
        -- make sure theyre still alive and human
        if (value ~= nil and not value.Removed and value.IsHuman and not value.IsDead) then
            Timer.Wait(function ()
                if (value ~= nil and not value.Removed and value.IsHuman and not value.IsDead) then
                NTEYE.UpdateHumanEye(value) end
            end, ((key + 1) / amountHumanEyes) * NTEYE.Deltatime * 1000)
        end
    end
end
