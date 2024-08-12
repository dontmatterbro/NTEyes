--overwrites diving gear checks to accompany immersive suits
function NTEYE.IsInDivingGear(character)

  if -- I will properly implement this later on, but for now this should suffice as a hotfix
		HF.HasAffliction(character, "pressure4000")
	or  HF.HasAffliction(character, "pressure5750")
	or  HF.HasAffliction(character, "pressure6000")
	or  HF.HasAffliction(character, "pressure6200")
	or  HF.HasAffliction(character, "pressure6650")
	or  HF.HasAffliction(character, "pressure7500")
	or  HF.HasAffliction(character, "pressure8000")
	or  HF.HasAffliction(character, "pressure10000")
  then
  
    return true
	
  end
  
end