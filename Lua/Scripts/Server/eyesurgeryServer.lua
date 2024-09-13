-- I fucking hate this file

--checks if the eyes are interactable
function NTEYE.CanSurgery(character)

	if 
				HF.CanPerformSurgeryOn(character) 
		and not NTEYE.IsInDivingGear(character) 
		and not HF.HasAffliction(character,"stasis",0.1) 
	then
	return true end
end

--checks if the eyes are alive
function NTEYE.HasEyes(targetCharacter)

	if 
			not HF.HasAffliction(targetCharacter, "noeye") 
		and not HF.HasAffliction(targetCharacter, "eyesdead") 
		and not HF.HasAffliction(targetCharacter, "th_amputation") 
		and not HF.HasAffliction(targetCharacter, "sh_amputation")	
	then 
	return true end
	
end

--nukes eye afflications after surgery
function NTEYE.ClearCharacterEyeAfflictions(character)
  eyeaffs = {
    "noeye", "eyesdead", "eyeone", "lefteyegone", "righteyegone", "eyelowbloodpressure", "eyedamage", "eyeshock", "eyesickness",
    "eyedrop", "lasereyesurgery", "deusizinedrop",
    "eyepopped", "eyelid", "eyegell", "eyemuscle", "eyenerve",
    "corneaincision", "emulsification", "eyecataract",
    "eyebionic", "eyenight", "eyeinfrared", "eyeplastic", "eyemonster", "eyehusk", "eyeterror", "medicallens", "electricallens", "zoomlens"
    	
  }
  for eyeaff in eyeaffs do
    character.CharacterHealth.ReduceAfflictionOnAllLimbs(eyeaff, 1000)
  end
end


--removes cataract eye afflications after cataract surgery 
function NTEYE.CataractClearAfflictions(character)
	cateyeaffs = {
		"corneaincision",
		"emulsification",
		"eyecataract"
				 }
	for cateyeaff in cateyeaffs do
	character.CharacterHealth.ReduceAfflictionOnAllLimbs(cateyeaff, 1000)
	end
end


--gives eyes back after removal surgery
function NTEYE.GiveItemBasedOnEye(character, usingCharacter)

	if NTEYE.HasEyes(character) then
	
		if HF.HasAffliction(character, "eyebionic") then --bionic
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_bionic", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			NTEYE.LensRemoval(character, usingCharacter)
			
		elseif HF.HasAffliction(character, "eyenight") then --night
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_night", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			
		elseif HF.HasAffliction(character, "eyeinfrared") then --infra
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_infrared", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			
		elseif HF.HasAffliction(character, "eyeplastic") then --plastic
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_plastic", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			
		elseif HF.HasAffliction(character, "eyemonster") then --monster
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_monster", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			
		elseif HF.HasAffliction(character, "eyehusk") then --husk
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_husk", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			
		elseif HF.HasAffliction(character, "eyeterror") then --terror
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_terror", 90 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			
		else --this needs to be on the bottom and /else/ - regular eyes don't have an affliction
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			
		end
		
	end
	
end


--Surgery Code
Hook.Add("item.applyTreatment", "NTEYE.Surgery", function(item, usingCharacter, targetCharacter, limb)

	if -- invalid use, dont do anything
		item == nil or
		usingCharacter == nil or
		targetCharacter == nil or
		limb == nil 
	then return end

	local identifier = item.Prefab.Identifier
	local limbtype = HF.NormalizeLimbType(limb.type)
	
	----------------------------EYE REMOVAL SURGERY-----------------------------
	if --surgery check
		NTEYE.CanSurgery(targetCharacter) 
	then
		if --eye popped (tweezers)
			identifier == "tweezers" 
			--and not HF.HasAffliction(targetCharacter, "corneaincision") 
			and not HF.HasAffliction(targetCharacter, "noeye") 
			and not HF.HasAffliction(targetCharacter, "th_amputation")
			and not HF.HasAffliction(targetCharacter, "sh_amputation")
		then
			if 
				HF.CanPerformSurgeryOn(targetCharacter) 
				and HF.HasAffliction(targetCharacter, "eyelid") 
			then
				if 
					HF.GetSurgerySkillRequirementMet(usingCharacter, 25) 
				then
					HF.AddAfflictionLimb(targetCharacter, "eyepopped", 11, 100)
				else
					HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 100)
					HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
					HF.AddAfflictionLimb(targetCharacter, "bleeding", 11, 10)
					
					if --give eye damage on fail
						NTEYE.HasEyes(targetCharacter)
					then 
						HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, math.random(0,10)) 
					end
					
					if 
						HF.Chance(0.5) 
					then
						HF.AddAfflictionLimb(targetCharacter, "eyepopped", 11, math.random(0,100))
					end
				
				end
			
			end
		
		end

		if --eyes removed (organscalpel_eyes)
			identifier == "organscalpel_eyes" 
			and not HF.HasAffliction(targetCharacter, "noeye") 
			and not HF.HasAffliction(targetCharacter, "th_amputation")
			and not HF.HasAffliction(targetCharacter, "sh_amputation")
		then
			if 
					HF.CanPerformSurgeryOn(targetCharacter) 
				and HF.HasAffliction(targetCharacter, "eyelid") 
				and HF.HasAffliction(targetCharacter, "eyepopped") 
			then
				if 
					HF.GetSurgerySkillRequirementMet(usingCharacter, 55) 
				then
					NTEYE.GiveItemBasedOnEye(targetCharacter, usingCharacter)
					
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
					HF.AddAfflictionLimb(targetCharacter, "noeye", 11, 2)
				else
					HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 100)
					HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
					HF.AddAfflictionLimb(targetCharacter, "bleeding", 11, math.random(0,15))
		
					if --give eye damage on fail
						NTEYE.HasEyes(targetCharacter) 
					then 
						HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, math.random(10,20))	
					end
					
					if --a chance to succeed (I don't like this, this should be changed)
						HF.Chance(0.8) 
					then
						NTEYE.GiveItemBasedOnEye(targetCharacter, usingCharacter)
					
						NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
						HF.AddAfflictionLimb(targetCharacter, "noeye", 11, 2)
					end
					
				end
				
			end
			
		end
		
	end
	
	
	------------------------------ EYE TRANSPLANT SURGERY -----------------------------------------------
	if --can do surgery check
		NTEYE.CanSurgery(targetCharacter) 
	then
	
		if --general transplant requirements
					HF.HasAffliction(targetCharacter, "noeye") 
				and HF.HasAffliction(targetCharacter, "eyelid")
				and HF.HasAffliction(targetCharacter, "eyegell") 
				and HF.HasAffliction(targetCharacter, "eyemuscle") 
				and HF.HasAffliction(targetCharacter, "eyenerve") 
			and not HF.HasAffliction(targetCharacter, "eyesdead") 
			and not HF.HasAffliction(targetCharacter, "th_amputation")
			and not HF.HasAffliction(targetCharacter, "sh_amputation")
		then
		
		
			if --regular eye transplant
				identifier == "transplant_eyes" 
			then 
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
					HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
					
					HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
					
					if --eyeshock check (maybe make these a function in the future?)
						HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) 
					then
						HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
					end
					
					item.Condition = 0
			end


			if --bionic eye transplant
				identifier =="transplant_eyes_bionic" 
			then
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
					HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 50 - HF.GetSurgerySkill(usingCharacter)/5)
					
					HF.SetAfflictionLimb(targetCharacter, "eyebionic", 11, 2)
					
					HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
					
					item.Condition = 0
			end


			if --night vision eye transplant
				identifier =="transplant_eyes_night" 
			then
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
					HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 80 - HF.GetSurgerySkill(usingCharacter)/5)
					
					HF.SetAfflictionLimb(targetCharacter, "eyenight", 11, 2)
					
					HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
					
					if --eyeshock check
						HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) 
					then
						HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
					end
					
					item.Condition = 0
			end
		
		
			if --infrared eye transplant
				identifier =="transplant_eyes_infrared" 
			then
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
					HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 80 - HF.GetSurgerySkill(usingCharacter)/5)
					
					HF.SetAfflictionLimb(targetCharacter, "eyeinfrared", 11, 2)
					
					HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
					
					if --eyeshock check
						HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) 
					then
						HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
					end
					
					item.Condition = 0
			end
		
		
			if --plastic eye transplant
				identifier =="transplant_eyes_plastic" 
			then
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
					HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100 - HF.GetSurgerySkill(usingCharacter)/10)
					
					HF.SetAfflictionLimb(targetCharacter, "eyeplastic", 11, 2)
					
					HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
					
					item.Condition = 0
			end
		
		
			if --monster eye transplant
				identifier =="transplant_eyes_monster" 
			then
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
					HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100 - HF.GetSurgerySkill(usingCharacter)/10)
					
					HF.SetAfflictionLimb(targetCharacter, "eyemonster", 11, 2)
					
					HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
					
					NTC.SetSymptomTrue(targetCharacter, "sym_unconsciousness", 4)
					
					if --eyeshock check
						HF.Chance(0.8*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) 
					then
						HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 10)
					end
					
					item.Condition = 0
			end
		
		
			if --husk eye transplant
				identifier =="transplant_eyes_husk" 
			then
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
					HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100 - HF.GetSurgerySkill(usingCharacter)/5)
					
					HF.SetAfflictionLimb(targetCharacter, "eyehusk", 11, 2)
					
					HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
					
					NTC.SetSymptomTrue(targetCharacter, "sym_unconsciousness", 4)
					
					if --eyeshock check
						HF.Chance(0.7*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) 
					then
						HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 10)
					end
					
					item.Condition = 0
			end
		
		
			if --terror eye transplant
				identifier =="transplant_eyes_terror" 
			then
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					
				--	HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100) no eye sickness for terror eyes
					
					HF.SetAfflictionLimb(targetCharacter, "eyeterror", 11, 2)
					
					HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
					
					NTC.SetSymptomTrue(targetCharacter, "sym_unconsciousness", 6)
					
					if --eyeshock check
						HF.Chance(0.9*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) 
					then
						HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 25)
					end
					
					item.Condition = 0
			end
			
		end
	end

-----------------------------------------ITEM APPLICATION STEPS-------------------------------------------------
		if --eyegel application (surgery prerequisets already in cataract surgery, don't dupe it)
				identifier == "eyegel" 
			and HF.HasAffliction(targetCharacter, "noeye") 
			and HF.HasAffliction(targetCharacter, "eyelid") 
		then 
		
			if 
				HF.GetSurgerySkillRequirementMet(usingCharacter, 35) 
			then
				HF.AddAfflictionLimb(targetCharacter, "eyegell", 11, 100)
			end
			
			item.Condition = item.Condition-50
			
			if item.Condition==0 then Entity.Spawner.AddItemToRemoveQueue(item) end --fixes bugs
		end
	
	
		if --muscle connector application
				identifier == "muscleconnectors" 
			and HF.HasAffliction(targetCharacter, "noeye") 
			and HF.HasAffliction(targetCharacter, "eyelid")
			and HF.HasAffliction(targetCharacter, "eyegell") 
		then  
		
			if 
				HF.GetSurgerySkillRequirementMet(usingCharacter, 40) 
			then
				HF.AddAfflictionLimb(targetCharacter, "eyemuscle", 11, 100)
			end
			
			item.Condition = item.Condition-50
			
			if item.Condition==0 then Entity.Spawner.AddItemToRemoveQueue(item) end --fixes bugs
		end
	
	
		if --nerve connector application
				identifier == "nerveconnectors" 
			and HF.HasAffliction(targetCharacter, "noeye") 
			and HF.HasAffliction(targetCharacter, "eyelid") 
			and HF.HasAffliction(targetCharacter, "eyegell") 
			and HF.HasAffliction(targetCharacter, "eyemuscle") 
		then  
		
			if 
				HF.GetSurgerySkillRequirementMet(usingCharacter, 50) 
			then
				HF.AddAfflictionLimb(targetCharacter, "eyenerve", 11, 100)
			end
			
			item.Condition = item.Condition-50
			
			if item.Condition==0 then Entity.Spawner.AddItemToRemoveQueue(item) end --fixes bugs
		end
		
		
		--eye drops
		if 
			identifier == "eyedrops" 
		then
			HF.AddAfflictionLimb(targetCharacter, "eyedrop", 11, 25)
			
			item.Condition = item.Condition - 25
			
			if item.Condition==0 then Entity.Spawner.AddItemToRemoveQueue(item) end --fixes bugs
		end
		
		
		--deusizine drops
		if 
			identifier == "deusizinedrops" 
		then
			HF.AddAfflictionLimb(targetCharacter, "deusizinedrop", 11, 25)
			
			item.Condition = item.Condition - 25
			
			if item.Condition==0 then Entity.Spawner.AddItemToRemoveQueue(item) end
		end
	
-----------------------------------CATARACT SURGERY----------------------------------------------
	if 
		NTEYE.CanSurgery(targetCharacter) 
	then

		if 
					identifier == "organscalpel_eyes" 
			and not HF.HasAffliction(targetCharacter, "noeye") 
			and not HF.HasAffliction(targetCharacter, "eyesdead") 
			and not HF.HasAffliction(targetCharacter, "eyepopped") 
			and not HF.HasAffliction(targetCharacter, "th_amputation")
			and not HF.HasAffliction(targetCharacter, "sh_amputation")
			and not HF.HasAffliction(targetCharacter, "eyebionic")
		then
			if 
				HF.GetSurgerySkillRequirementMet(usingCharacter, 40) 
			then
				if --success
						HF.CanPerformSurgeryOn(targetCharacter) 
					and HF.HasAffliction(targetCharacter, "eyelid") 
				then
					HF.AddAfflictionLimb(targetCharacter, "corneaincision", 11, 100)			
				end
			else
				HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 100)
				HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
				
				if --give eye damage on fail
					NTEYE.HasEyes(targetCharacter) 
				then 
					HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, math.random(1,20)) 
				end

				if --chance to succeed on fail
					HF.Chance(0.5) 
				then
					HF.AddAfflictionLimb(targetCharacter, "corneaincision", 11, 100)
				end
				
			end
		end
		
		--needle
		if 
					identifier == "needle" 
			and not HF.HasAffliction(targetCharacter, "noeye") 
			and not HF.HasAffliction(targetCharacter, "eyesdead") 
			and not HF.HasAffliction(targetCharacter, "th_amputation")
			and not HF.HasAffliction(targetCharacter, "sh_amputation")
		then
			if 
				HF.GetSurgerySkillRequirementMet(usingCharacter, 40) 
			then
				if 
						HF.CanPerformSurgeryOn(targetCharacter) 
					and HF.HasAffliction(targetCharacter, "eyelid") 
					and HF.HasAffliction(targetCharacter, "corneaincision") 
				then
					HF.AddAfflictionLimb(targetCharacter, "emulsification", 11, 2)			
				end
			else
				HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 100)
				HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
				
				if --give eye damage on fail
					NTEYE.HasEyes(targetCharacter) 
				then 
					HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, math.random(1,10)) 
				end

				if --chance to succeed on fail
					HF.Chance(0.5) 
				then
					HF.AddAfflictionLimb(targetCharacter, "emulsification", 11, 2)
				end
			end
		end


		if 
					identifier == "eyelens" 
			and not HF.HasAffliction(targetCharacter, "noeye") 
			and not HF.HasAffliction(targetCharacter, "eyesdead") 
			and not HF.HasAffliction(targetCharacter, "th_amputation")
			and not HF.HasAffliction(targetCharacter, "sh_amputation")
		then
			if 
					HF.CanPerformSurgeryOn(targetCharacter) 
				and HF.HasAffliction(targetCharacter, "eyelid") 
				and HF.HasAffliction(targetCharacter, "corneaincision") 
				and HF.HasAffliction(targetCharacter, "emulsification") 
			then
				item.Condition = 0	
				NTEYE.CataractClearAfflictions(targetCharacter)
			end
		end

		if 
					identifier == "advretractors" 
				and limbtype == 11 
			and not HF.HasAfflictionLimb(targetCharacter, "surgeryincision", 11) 
		then
			HF.AddAfflictionLimb(targetCharacter, "eyelid", 11, 100)
		end	
		
	end
	

-------------------------------------------------LASER SURGERY--------------------------------------------------
	if 
		NTEYE.CanSurgery(targetCharacter) 
	then
		if 
					identifier == "eye_laser_tool" 
				and (limbtype == 11)
				and HF.CanPerformSurgeryOn(targetCharacter) 
				and HF.HasAffliction(targetCharacter, "eyelid") 
			and not HF.HasAffliction(targetCharacter, "noeye") 
			and not HF.HasAffliction(targetCharacter, "eyesdead") 
			and not HF.HasAffliction(targetCharacter, "th_amputation")
			and not HF.HasAffliction(targetCharacter, "sh_amputation")
			and not HF.HasAffliction(targetCharacter, "corneaincision") 
			and not HF.HasAffliction(targetCharacter, "eyepopped") 
		then
			if 
				item.OwnInventory.GetItemAt(0)==nil then return end	
				if 
					item.OwnInventory.GetItemAt(0).Condition >= 99 
				then
					HF.GiveItem(targetCharacter,"nteye_slowlaser")
					item.OwnInventory.GetItemAt(0).Condition = item.OwnInventory.GetItemAt(0).Condition-100
						if 
							HF.GetSurgerySkillRequirementMet(usingCharacter,80)
						then 
							HF.AddAfflictionLimb(targetCharacter, "lasereyesurgery", 11, 100)
						else
							HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 100)
							HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
							HF.AddAfflictionLimb(targetCharacter, "bleeding", 11, math.random(1,20))
							HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, math.random(15,40))
							NTEYE.PlayScream(targetCharacter)
							HF.AddAfflictionLimb(targetCharacter, "lasereyesurgery", 11, math.random(1,80))
						end
				end
		end
	end
--------------------------------------------BIONIC LENS SURGERY-----------------------------------------------------
	if 
		NTEYE.CanSurgery(targetCharacter) 
	then
		if 	--lense application
					(limbtype == 11) 
				and HF.HasAffliction(targetCharacter, "eyelid") 
				and HF.HasAffliction(targetCharacter, "eyepopped")
				and HF.HasAffliction(targetCharacter, "eyebionic")
			and not HF.HasAffliction(targetCharacter, "medicallens")
			and not HF.HasAffliction(targetCharacter, "electricallens")
			and not HF.HasAffliction(targetCharacter, "zoomlens")
		then
		
			
			if 
				identifier=="medicallensitem"
			then
				HF.SetAfflictionLimb(targetCharacter, "medicallens", 11, 2)
				
				item.Condition = 0
				Entity.Spawner.AddItemToRemoveQueue(item) --fixes bugs
			end


			if 
				identifier=="electricallensitem"
			then
				HF.SetAfflictionLimb(targetCharacter, "electricallens", 11, 2)
				
				item.Condition = 0
				Entity.Spawner.AddItemToRemoveQueue(item) --fixes bugs
			end
		
		
			if 
				identifier=="zoomlensitem"
			then
				HF.SetAfflictionLimb(targetCharacter, "zoomlens", 11, 2)
				
				item.Condition = 0 
				Entity.Spawner.AddItemToRemoveQueue(item) --fixes bugs
			end
		
		end


		if 	--lense removal
				(identifier=="screwdriver" or identifier=="screwdriverhardened" or identifier=="screwdriverdementonite")  		
			and (limbtype == 11)
			and HF.HasAffliction(targetCharacter, "eyelid") 
			and HF.HasAffliction(targetCharacter, "eyepopped")
			and HF.HasAffliction(targetCharacter, "eyebionic")
		then
			if
				HF.GetSurgerySkillRequirementMet(usingCharacter, 65) 
			then
				NTEYE.LensRemoval(targetCharacter, usingCharacter)
			else
			
				HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 5)
				HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 40)
				HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, math.random(1,10))
				
				if 
					HF.Chance(0.4) 
				then 
					NTEYE.LensRemoval(targetCharacter, usingCharacter) 
				end

			end
		end
	end


----------------------------------------BIONIC REPAIR SURGERY----------------------------------------------
		if 
					identifier=="fpgacircuit"
				and (limbtype == 11)
				and HF.HasAffliction(targetCharacter, "eyelid")
				and HF.HasAffliction(targetCharacter, "eyepopped")
				and HF.HasAffliction(targetCharacter, "eyebionic")
			and not HF.HasAffliction(targetCharacter, "eyedamage", 80)
		then
			if
				HF.GetSurgerySkillRequirementMet(usingCharacter, 65)
			then --success
				targetCharacter.CharacterHealth.ReduceAfflictionOnAllLimbs("eyedamage", item.Condition/5)
				item.Condition = 0
				Entity.Spawner.AddItemToRemoveQueue(item) --fixes bugs
			else
				if --this is retarded, rewrite this
					HF.Chance(0.8) 
				then --fail
					targetCharacter.CharacterHealth.ReduceAfflictionOnAllLimbs("eyedamage", item.Condition/20)
					item.Condition = item.Condition-50
					if item.Condition==0 then Entity.Spawner.AddItemToRemoveQueue(item) end
				else --success
					targetCharacter.CharacterHealth.ReduceAfflictionOnAllLimbs("eyedamage", item.Condition/5)
					item.Condition = 0
					Entity.Spawner.AddItemToRemoveQueue(item) --fixes bugs
				end
				
			end
			
		end



end)


--removing bionic lenses when eyepopped check twezeers usage
function NTEYE.LensRemoval(targetCharacter, usingCharacter)

		if 
			HF.HasAffliction(targetCharacter, "medicallens") 
		then
			HF.GiveItemAtCondition(usingCharacter, "medicallensitem", 100)
			targetCharacter.CharacterHealth.ReduceAfflictionOnAllLimbs("medicallens", 1000)
		end
		
		if
			HF.HasAffliction(targetCharacter, "electricallens") 
		then
			HF.GiveItemAtCondition(usingCharacter, "electricallensitem", 100)
			targetCharacter.CharacterHealth.ReduceAfflictionOnAllLimbs("electricallens", 1000)
		end
		
		if
			HF.HasAffliction(targetCharacter, "zoomlens")
		then
			HF.GiveItemAtCondition(usingCharacter, "zoomlensitem", 100)
			targetCharacter.CharacterHealth.ReduceAfflictionOnAllLimbs("zoomlens", 1000)
		end
	
end