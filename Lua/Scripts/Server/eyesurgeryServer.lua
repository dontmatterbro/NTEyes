
--checks if the eyes are interactable
function NTEYE.CanSurgery(character)
	if not NTEYE.IsInDivingGear(character) and not HF.HasAffliction(character,"stasis",0.1) then
	return true end
end

function NTEYE.HasEyes(targetCharacter)
	if not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "eyesdead") and not HF.HasAffliction(targetCharacter, "th_amputation") 
	then return true
	end
end

--removes eye afflications after surgery
function NTEYE.ClearCharacterEyeAfflictions(character)
  eyeaffs = {
    "noeye",
    "eyedamage",
    "eyeshock",
    "eyedrop",
    "lasereyesurgery",
    "eyemuscle",
    "eyegell",
    "eyenerve",
	"eyelid", 
    "eyeone",
    "lefteyegone",
    "righteyegone",
    "eyesdead",
    "eyesickness",
    "eyecataract",
    "eyepopped",
    "eyebionic",
    "eyenight",
    "eyeinfrared",
    "eyeplastic",
    "eyemonster",
    "eyehusk",
	"eyeterror"
  }
  for eyeaff in eyeaffs do
    -- Nuke eye afflictions on head and torso
    HF.SetAffliction(character, eyeaff, 0)
    HF.SetAfflictionLimb(character, eyeaff, 11, 0)
    -- Nuke eye afflictions on all limbs
    -- Wrong way of doing stuff, but fixes things, gross
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
	HF.SetAffliction(character, cateyeaff, 0)
	HF.SetAfflictionLimb(character, cateyeaff, 11, 0)
	character.CharacterHealth.ReduceAfflictionOnAllLimbs(cateyeaff, 1000)
	end
end


--This function gives eyes back after removal surgery
function NTEYE.GiveItemBasedOnEye(character, usingCharacter)
	if not HF.HasAffliction(character, "noeye") and not HF.HasAffliction(character, "eyesdead") and not HF.HasAffliction(targetCharacter, "th_amputation") then
		if HF.HasAffliction(character, "eyebionic") then
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_bionic", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
		elseif HF.HasAffliction(character, "eyenight") then
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_night", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
		elseif HF.HasAffliction(character, "eyeinfrared") then
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_infrared", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
		elseif HF.HasAffliction(character, "eyeplastic") then
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_plastic", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
		elseif HF.HasAffliction(character, "eyemonster") then
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_monster", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
		elseif HF.HasAffliction(character, "eyehusk") then
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_husk", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
		elseif HF.HasAffliction(character, "eyeterror") then
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes_terror", 90 - HF.GetAfflictionStrength(character, "eyedamage", 0))
			NTC.SetSymptomTrue(targetCharacter, "sym_unconsciousness", 6)
		else
			HF.GiveItemAtCondition(usingCharacter, "transplant_eyes", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
		end
	end
end


--eye removal surgery
Hook.Add("item.applyTreatment", "eyeremovalsurgery", function(item, usingCharacter, targetCharacter, limb)
	local identifier = item.Prefab.Identifier
	
	limbtype = HF.NormalizeLimbType(limb.type)
	
	if NTEYE.CanSurgery(targetCharacter) then
		if identifier == "tweezers" and not HF.HasAffliction(targetCharacter, "corneaincision") and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "th_amputation") then
			if HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") then
				if HF.GetSurgerySkillRequirementMet(usingCharacter, 25) then
					HF.AddAfflictionLimb(targetCharacter, "eyepopped", 11, 100)
				else
					for i=1, 2 do
						Timer.Wait(function()
							HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 5)
							HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
						end, 1000 * i)
					end
					HF.AddAfflictionLimb(targetCharacter, "bleeding", 11, 10)
					if NTEYE.HasEyes(targetCharacter) then HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 5) end
					if HF.Chance(0.5) then
						HF.AddAfflictionLimb(targetCharacter, "eyepopped", 11, 100)
					end
				end
			end
		end

		if identifier == "organscalpel_eyes" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "th_amputation") then
			if HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") and HF.HasAffliction(targetCharacter, "eyepopped") then
				if HF.GetSurgerySkillRequirementMet(usingCharacter, 55) then
					NTEYE.GiveItemBasedOnEye(targetCharacter, usingCharacter)
					NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
					HF.AddAfflictionLimb(targetCharacter, "noeye", 11, 2)
				else
					for i=1, 2 do
						Timer.Wait(function()
							HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 5)
							HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
						end, 1000 * i)
					end
					HF.AddAfflictionLimb(targetCharacter, "bleeding", 11, 10)
					if NTEYE.HasEyes(targetCharacter) then HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 12)	end
					if HF.Chance(0.5) then
						HF.AddAfflictionLimb(targetCharacter, "eyepopped", 11, 100)
					end
				end
			end
		end
	end
end)


--eye transplant surgery
Hook.Add("item.applyTreatment", "eyetransplantsurgery", function(item, usingCharacter, targetCharacter, limb)
	local identifier = item.Prefab.Identifier
	
	limbtype = HF.NormalizeLimbType(limb.type)

	if NTEYE.CanSurgery(targetCharacter) then
	
		if HF.HasAffliction(targetCharacter, "noeye") and HF.HasAffliction(targetCharacter, "eyemuscle") and HF.HasAffliction(targetCharacter, "eyegell") and HF.HasAffliction(targetCharacter, "eyenerve") and HF.HasAffliction(targetCharacter, "eyelid") and not HF.HasAffliction(targetCharacter, "eyesdead") and not HF.HasAffliction(targetCharacter, "th_amputation") then
		
			if identifier == "transplant_eyes" then 
				NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
				HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
				HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
				
				if HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
					HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
				end
				item.Condition = 0
			end

			if identifier =="transplant_eyes_bionic" then
				NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
				HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 50)
				HF.SetAfflictionLimb(targetCharacter, "eyebionic", 11, 2)
				HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
				if HF.Chance(0.1*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
					HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
				end
				item.Condition = 0
			end

			if identifier =="transplant_eyes_night" then
				NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
				HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 80)
				HF.SetAfflictionLimb(targetCharacter, "eyenight", 11, 2)
				HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
				if HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
					HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
				end
				item.Condition = 0
			end
		
			if identifier =="transplant_eyes_infrared" then
				NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
				HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 80)
				HF.SetAfflictionLimb(targetCharacter, "eyeinfrared", 11, 2)
				HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
				if HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
					HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
				end
				item.Condition = 0
			end
		
			if identifier =="transplant_eyes_plastic" then
				NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
				HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
				HF.SetAfflictionLimb(targetCharacter, "eyeplastic", 11, 2)
				HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
				if HF.Chance(0.5*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
					HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 5)
				end
				item.Condition = 0
			end
		
			if identifier =="transplant_eyes_monster" then
				NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
				HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
				HF.SetAfflictionLimb(targetCharacter, "eyemonster", 11, 2)
				HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
				if HF.Chance(0.8*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
				NTC.SetSymptomTrue(targetCharacter, "sym_unconsciousness", 4)
					HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 10)
				end
				item.Condition = 0
			end
		
			if identifier =="transplant_eyes_husk" then
				NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
				HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
				HF.SetAfflictionLimb(targetCharacter, "eyehusk", 11, 2)
				HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
				NTC.SetSymptomTrue(targetCharacter, "sym_unconsciousness", 4)
				if HF.Chance(0.7*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
					HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 10)
				end
				item.Condition = 0
			end
		
			if identifier =="transplant_eyes_terror" then
				NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
				HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
				HF.SetAfflictionLimb(targetCharacter, "eyeterror", 11, 2)
				HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
				NTC.SetSymptomTrue(targetCharacter, "sym_unconsciousness", 6)
				if HF.Chance(0.5*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
					HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 25)
				end
				item.Condition = 0
			end
		end
	
		--prerequisites to eye transplant eyelid in cataracts, no need to dupe it
		if identifier == "eyegel" and HF.HasAffliction(targetCharacter, "noeye") and HF.HasAffliction(targetCharacter, "eyelid") then  
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 50) then
				HF.AddAfflictionLimb(targetCharacter, "eyegell", 11, 100)
			end
			item.Condition = 0
		end
	
		if identifier == "muscleconnectors" and HF.HasAffliction(targetCharacter, "noeye") and HF.HasAffliction(targetCharacter, "eyegell") and HF.HasAffliction(targetCharacter, "eyelid") then  
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 50) then
				HF.AddAfflictionLimb(targetCharacter, "eyemuscle", 11, 100)
			end
			item.Condition = 0
		end
	
		if identifier == "nerveconnectors" and HF.HasAffliction(targetCharacter, "noeye") and HF.HasAffliction(targetCharacter, "eyegell") and HF.HasAffliction(targetCharacter, "eyemuscle") and HF.HasAffliction(targetCharacter, "eyelid") then  
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 50) then
				HF.AddAfflictionLimb(targetCharacter, "eyenerve", 11, 100)
			end
			item.Condition = 0
		end
	end
end)


--cataract surgery
Hook.Add("item.applyTreatment", "eyecataractsurgery", function(item, usingCharacter, targetCharacter, limb)
	local identifier = item.Prefab.identifier

	limbtype = HF.NormalizeLimbType(limb.type)
	
	if NTEYE.CanSurgery(targetCharacter) then

		if identifier == "organscalpel_eyes" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "eyesdead") and not HF.HasAffliction(targetCharacter, "eyepopped") and not HF.HasAffliction(targetCharacter, "th_amputation") then
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 40) then
				if HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") then
				HF.AddAfflictionLimb(targetCharacter, "corneaincision", 11, 100)			
				end
			else
				for i=1, 2 do
					Timer.Wait(function()
						HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 5)
						HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 40)
						if NTEYE.HasEyes(targetCharacter) then HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 12) end
					end, 1000 * i)
				end
				HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100) 
				if NTEYE.HasEyes(targetCharacter) then HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 20) end
				if HF.Chance(0.3) then
				HF.AddAfflictionLimb(targetCharacter, "corneaincision", 11, 2)
				end
			end
		end
		--enhance needle chance
		if identifier == "needle" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "eyesdead") and not HF.HasAffliction(targetCharacter, "th_amputation") then
			if HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") and HF.HasAffliction(targetCharacter, "corneaincision") then
				HF.AddAfflictionLimb(targetCharacter, "emulsification", 11, 2)			
			end
		end

		if identifier == "eyelens" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "eyesdead") and not HF.HasAffliction(targetCharacter, "th_amputation") then
			if HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") and HF.HasAffliction(targetCharacter, "corneaincision") and HF.HasAffliction(targetCharacter, "emulsification") then
				item.Condition = 0	
				NTEYE.CataractClearAfflictions(targetCharacter)
			end
		end

		if identifier == "advretractors" and limbtype == 11 and not HF.HasAfflictionLimb(targetCharacter, "surgeryincision", 11) then
			HF.AddAfflictionLimb(targetCharacter, "eyelid", 11, 100)
		end	
		
	end
end)


--laser surgery and eye drops
Hook.Add("item.applyTreatment", "eyelasersurgery", function(item, usingCharacter, targetCharacter, limb)
	local identifier = item.Prefab.Identifier
	limbtype = HF.NormalizeLimbType(limb.type)

	--laser surgery
	if NTEYE.CanSurgery(targetCharacter) then
		if identifier == "eye_laser_tool" and (limbtype == 11) and HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "eyesdead") and not HF.HasAffliction(targetCharacter, "th_amputation") and not HF.HasAffliction(targetCharacter, "corneaincision") and not HF.HasAffliction(targetCharacter, "eyepopped") then
			if item.OwnInventory.GetItemAt(0)==nil then return end	
				if item.OwnInventory.GetItemAt(0).Condition >= 99 then
					HF.GiveItem(targetCharacter,"ntsfx_selfscan")
					item.OwnInventory.GetItemAt(0).Condition = item.OwnInventory.GetItemAt(0).Condition-100
						if HF.GetSurgerySkillRequirementMet(usingCharacter, 80) then
							HF.AddAfflictionLimb(targetCharacter, "lasereyesurgery", 11, 100)
						else
							for i=1, 2 do
								Timer.Wait(function()
									HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 5)
									HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
									HF.AddAfflictionLimb(targetCharacter, "bleeding", 11, 10)
									if NTEYE.HasEyes(targetCharacter) then HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 10) end
								end, 1000 * i)
							end
							HF.AddAfflictionLimb(targetCharacter, "bleeding", 11, 20)
							HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 50)
							if NTEYE.HasEyes(targetCharacter) then HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 15)	end
							if HF.Chance(0.2) then
								HF.AddAfflictionLimb(targetCharacter, "lasereyesurgery", 11, 50)
							end
						end
				end
		end
	
		--eye drops
		if identifier == "eyedrops" then
			HF.AddAfflictionLimb(targetCharacter, "eyedrop", 11, 25)
			item.Condition = item.Condition - 25
		end
		
	end
end)