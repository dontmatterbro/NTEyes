--cataract surgery WORKS move to eyesurgery when ready

--affliction clear for cataract
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

--cataract surgery
Hook.Add("item.applyTreatment", "eyecataractsurgery", function(item, usingCharacter, targetCharacter, limb)
	local identifier = item.Prefab.identifier

	limbtype = HF.NormalizeLimbType(limb.type)
	
	if NTEYE.CanSurgery(targetCharacter) then

		if identifier == "organscalpel_eyes" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "eyepopped") and not HF.HasAffliction(targetCharacter, "th_amputation") then
			if HF.GetSurgerySkillRequirementMet(usingCharacter, 40) then
				if HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") then
				HF.AddAfflictionLimb(targetCharacter, "corneaincision", 11, 2)			
				end
			else
				for i=1, 2 do
					Timer.Wait(function()
						HF.AddAfflictionLimb(targetCharacter, "severepainlite", 11, 5)
						HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 40)
						HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 12)
					end, 1000 * i)
				end
				HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100) 
				HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 20)
				if HF.Chance(0.3) then
				HF.AddAfflictionLimb(targetCharacter, "corneaincision", 11, 2)
				end
			end
		end
		--enhance needle chance
		if identifier == "needle" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "th_amputation") then
			if HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") and HF.HasAffliction(targetCharacter, "corneaincision") then
				HF.AddAfflictionLimb(targetCharacter, "emulsification", 11, 2)			
			end
		end

		if identifier == "eyelens" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "th_amputation") then
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