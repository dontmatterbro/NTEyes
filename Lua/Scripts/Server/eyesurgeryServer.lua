--Surgery may need a little rework


--This function gives eyes back after surgery
function NTEYE.GiveItemBasedOnEye(character, usingCharacter)
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
  else
    HF.GiveItemAtCondition(usingCharacter, "transplant_eyes", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
  end
end


--Clear Eye Effects for Surgery
function NTEYE.ClearCharacterEyeAfflictions(character)
  eyeaffs = {
    "noeye",
    "eyedamage",
    "eyeshock",
    "eyedrop",
    "eyemuscle",
    "eyegell",
    "eyelid",
    "eyeone",
    "eyesickness",
    "eyecataract",
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


--This is the main bulk
Hook.Add("item.applyTreatment", "NTEYE.eyesurgery", function(item, usingCharacter, targetCharacter, limb)
  local identifier = item.Prefab.Identifier

  -- sadly no switches in lua
  limbtype = HF.NormalizeLimbType(limb.type)
  if not NTEYE.IsInDivingGear(targetCharacter) then
    if identifier=="organscalpel_eyes" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "th_amputation") then
      if HF.HasAffliction(targetCharacter, "analgesia") and HF.HasAffliction(targetCharacter, "eyelid") or HF.HasAffliction(targetCharacter, "sym_unconsciousness") and HF.HasAffliction(targetCharacter, "eyelid") then
        if HF.GetSurgerySkillRequirementMet(usingCharacter, 45) then
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
          HF.AddAfflictionLimb(targetCharacter, "pain_extremity", 11, 100)
          HF.AddAfflictionLimb(targetCharacter, "bleeding", 11, 10)
          HF.AddAfflictionLimb(targetCharacter, "eyedamage", 11, 15)
          if HF.Chance(0.5) then
            NTEYE.GiveItemBasedOnEye(targetCharacter, usingCharacter)
            NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
            HF.AddAfflictionLimb(targetCharacter, "noeye", 11, 2)
          end
        end
      end
    end
    if identifier == "advretractors" and limbtype == 11 and not HF.HasAfflictionLimb(targetCharacter, "surgeryincision", 11) then
      HF.AddAfflictionLimb(targetCharacter, "eyelid", 11, 100)
    end
    if identifier == "eyedrops" then
      HF.AddAfflictionLimb(targetCharacter, "eyedrop", 11, 25)
      item.Condition = item.Condition - 25
    end
    if HF.HasAffliction(targetCharacter, "eyelid") then
      if identifier == "muscleconnectors" and HF.HasAffliction(targetCharacter, "noeye") then
        if HF.GetSurgerySkillRequirementMet(usingCharacter, 45) then
          HF.AddAfflictionLimb(targetCharacter, "eyemuscle", 11, 100)
        end
        item.Condition = 0
      end
      if identifier == "eyegel" and HF.HasAffliction(targetCharacter, "noeye") then
        if HF.GetSurgerySkillRequirementMet(usingCharacter, 45) then
          HF.AddAfflictionLimb(targetCharacter, "eyegell", 11, 100)
        end
        item.Condition = 0
      end
    end

    if HF.HasAffliction(targetCharacter, "noeye") and HF.HasAffliction(targetCharacter, "eyemuscle") and HF.HasAffliction(targetCharacter, "eyegell") and HF.HasAffliction(targetCharacter, "eyelid") then
      if identifier =="transplant_eyes" then
        --print("normal eyes")
        --print(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        --multiply default chance by 1 to 0 depending on surgery skill linearly 0.5 defaut chance from 100
        if HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
      if identifier =="transplant_eyes_bionic" then
        --print("bionic eyes")
        --print(0.1*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
        HF.SetAfflictionLimb(targetCharacter, "eyebionic", 11, 2)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        if HF.Chance(0.1*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
      if identifier =="transplant_eyes_night" then
        --print("night vis eyes")
        --print(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
        HF.SetAfflictionLimb(targetCharacter, "eyenight", 11, 2)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        if HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
      if identifier =="transplant_eyes_infrared" then
        --print("infrared eyes")
        --print(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
        HF.SetAfflictionLimb(targetCharacter, "eyeinfrared", 11, 2)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        if HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
      if identifier =="transplant_eyes_plastic" then
        --print("plastic eyes")
        --print(0.5*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
        HF.SetAfflictionLimb(targetCharacter, "eyeplastic", 11, 2)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        if HF.Chance(0.5*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
      if identifier =="transplant_eyes_monster" then
        --print("monster eyes")
        --print(0.7*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
        HF.SetAfflictionLimb(targetCharacter, "eyemonster", 11, 2)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        if HF.Chance(0.7*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
      if identifier =="transplant_eyes_terror" then
        --print("terror eyes")
        --print(0.7*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyeterror", 11, 2)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        if HF.Chance(0.3*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
      if identifier =="transplant_eyes_husk" then
        --print("husk eyes")
        --print(0.6*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        NTEYE.ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
        HF.SetAfflictionLimb(targetCharacter, "eyehusk", 11, 2)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        if HF.Chance(0.6*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
    end
  end
end)