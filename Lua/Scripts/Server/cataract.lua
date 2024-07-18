--cataract

Hook.Add("item.applyTreatment", "NTEYE.eyesurgerycataract", function(item, usingCharacter, targetCharacter, limb)
	local = identifier = item.Prefab.identifier

	limbtype = HF.NormalizeLimbType(limb.type)
	
	if NTEYE.CanSurgery(targetCharacter) then
		if identifier == "needle" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "th_amputation") then
			if HF.CanPerformSurgeryOn(targetCharacter) and HF.HasAffliction(targetCharacter, "eyelid") then
				HF.AddAfflictionLimb(targetCharacter, "needleeye", 11, 2)
			
			end
		end
	end






















end