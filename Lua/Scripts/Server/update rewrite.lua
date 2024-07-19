function NTEYE.UpdateHumanEye(character)
--print("debug:UpdateHumanEye")
  if HF.HasAffliction(character, "cerebralhypoxia", 60) and not HF.HasAffliction(character, "eyebionic") and not HF.HasAffliction(character, "stasis") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.1)
  end
  if HF.HasAffliction(character, "hypoxemia", 75) and not HF.HasAffliction(character, "eyebionic") and not HF.HasAffliction(character, "stasis") then 
    HF.AddAfflictionLimb(character, "eyedamage", 11, 1.2)
	elseif HF.HasAffliction(character, "hypoxemia", 40) and not HF.HasAffliction(character, "eyebionic") and not HF.HasAffliction(character, "stasis") then
	HF.AddAfflictionLimb(character, "eyedamage", 11, 0.6)
  end
  if HF.HasAffliction(character, "stroke", 5) and not HF.HasAffliction(character, "eyebionic") and not HF.HasAffliction(character, "stasis") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.3)
  end
  if HF.HasAffliction(character, "sepsis", 40) and not HF.HasAffliction(character, "stasis") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.1)
  end
  if HF.HasAffliction(character, "eyeshock") and not HF.HasAffliction(character, "stasis") then
    HF.AddAfflictionLimb(character, "eyeshock", 11, 0.5)
    if HF.HasAffliction(character, "eyeshock", 80) and not HF.HasAffliction(character, "stasis") then
      HF.AddAfflictionLimb(character, "eyedamage", 11, 0.8)
    end
  end
  if HF.HasAffliction(character, "eyedamage", 40) then
    NTC.SetSymptomTrue(character, "sym_blurredvision", 2)
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.05)
    if HF.HasAffliction(character, "eyedamage", 50) and not HF.HasAffliction(character, "eyeone") then
      HF.AddAfflictionLimb(character, "eyeone", 11, 2)
    end
    if HF.HasAffliction(character, "eyedamage", 99) then
      NTEYE.ClearCharacterEyeAfflictions(character)
      HF.AddAfflictionLimb(character, "noeye", 11, 2)
    end
  end
  if HF.Chance(0.0005) and HF.HasAffliction(character, "eyedamage", 20) then
    HF.AddAfflictionLimb(character, "eyecataract", 11, 1)
  end
  if HF.HasAffliction(character, "eyecataract", 0.1) and not HF.HasAffliction(character, "stasis") then
    HF.AddAfflictionLimb(character, "eyecataract", 11, 0.4)
  end
  if HF.HasAffliction(character, "eyehusk") and HF.Chance(0.001) then
    HF.AddAffliction(character, "huskinfection", 1)
  end
  if HF.HasAffliction(character, "eyecataract", 50) then
    NTC.SetSymptomTrue(character, "sym_blurredvision", 2)
  end
  if NTEYE.GetItemInSlot(character, InvSlotType.Head) and NTEYE.GetItemInSlot(character, InvSlotType.Head).Prefab.identifier == "eyeglasses" then
    NTC.SetSymptomFalse(character, "sym_blurredvision", 2)
  end
  if character.AnimController.HeadInWater and not NTEYE.IsInDivingGear(character) and not HF.HasAffliction(character, "eyemonster") and not HF.HasAffliction(character, "eyehusk") and not HF.HasAffliction(character, "stasis") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.34)
  elseif HF.HasAffliction(character, "eyedamage") and not HF.HasAffliction(character, "eyedamage", 45) or HF.HasAffliction(character, "eyedamage", 50) and not HF.HasAffliction(character, "eyedamage", 95) then
    HF.AddAfflictionLimb(character, "eyedamage", 11, -0.1)
    if HF.HasAffliction(character, "eyedrop") then
      HF.AddAfflictionLimb(character, "eyedamage", 11, -0.2)
    end
  end
  HF.AddAfflictionLimb(character, "eyedrop", 11, -0.8)
end