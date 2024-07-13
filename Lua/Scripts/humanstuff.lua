---@diagnostic disable: lowercase-global, undefined-global
local UpdateCooldownEye = 0
local UpdateIntervalEye = 120
local DeltaTimeEye = UpdateIntervalEye/60 -- Time in seconds that transpires between updates
local debug = false

-- gets run once every two seconds
function UpdateEye()
  -- for every human
  for _, character in pairs(Character.CharacterList) do
    if (character.IsHuman and not character.IsDead) then
      UpdateHumanEye(character)
    end
  end
end

Hook.Add("think", "updateeye", function()
  if SERVER or not Game.Paused then
    UpdateCooldownEye = UpdateCooldownEye-1
    if (UpdateCooldownEye <= 0) then
      UpdateCooldownEye = UpdateIntervalEye
      UpdateEye()
    end
  end
end)

function doStuffEye(unknown)
  return unknown.SpeciesName
end

Hook.Add('eyeDecomposition', 'eyedeco', function(effect, dt, item, targets, worldpos)
  if not pcall(doStuffEye, item.ParentInventory.Owner) then
    -- its item
    if item.ParentInventory.Owner.identifier == "medicalfabricator" then
      return true
    end
  end
end)

Hook.Add('spoonUsed', 'test', function(effect, dt, item, targets, worldpos)
  for k, v in pairs(targets) do
    if v.SpeciesName == "Mudraptor" or v.SpeciesName == "Crawler" or v.SpeciesName == "Hammerhead" or v.SpeciesName == "Spineling" then
      if not HF.HasAffliction(v, "noeye") then
        HF.AddAfflictionLimb(v, "noeye", 11, 2)
        Timer.Wait(function()
			local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_monster")
			Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
            Entity.Spawner.AddItemToRemoveQueue(item)
        end, 1)
      end
    elseif v.SpeciesName == "Husk" or v.SpeciesName == "Crawlerhusk" then
      if not HF.HasAffliction(v, "noeye") then
        HF.AddAfflictionLimb(v, "noeye", 11, 2)
        Timer.Wait(function()
			local prefab = ItemPrefab.GetItemPrefab("transplant_eyes_husk")
			Entity.Spawner.AddItemToSpawnQueue(prefab, item.WorldPosition, nil, nil, function(item) end)
            Entity.Spawner.AddItemToRemoveQueue(item)
        end, 1)
      end
    end
  end
end)

function IsInDivingGear(character)
  local outerSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
  local headSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)

  if outerSlot and outerSlot.HasTag("diving") or outerSlot and outerSlot.HasTag("deepdiving") or headSlot and headSlot.HasTag("diving") or headSlot and headSlot.HasTag("deepdiving") then
    return true
  end
  return false
end

function GetItemInSlot(character, slot)
  if character and slot then
    return character.Inventory.GetItemInLimbSlot(slot)
  end
end

function UpdateHumanEye(character)
  if HF.HasAffliction(character, "cerebralhypoxia", 60) and not HF.HasAffliction(character, "eyebionic") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.1)
  end
  if HF.HasAffliction(character, "hypoxemia", 40) and not HF.HasAffliction(character, "eyebionic") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.2)
  end
  if HF.HasAffliction(character, "stroke", 5) and not HF.HasAffliction(character, "eyebionic") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.3)
  end
  if HF.HasAffliction(character, "sepsis", 40) then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.1)
  end
  if HF.HasAffliction(character, "eyeshock") then
    HF.AddAfflictionLimb(character, "eyeshock", 11, 0.5)
    if HF.HasAffliction(character, "eyeshock", 80) then
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
      ClearCharacterEyeAfflictions(character)
      HF.AddAfflictionLimb(character, "noeye", 11, 2)
    end
  end
  if HF.Chance(0.0005) and HF.HasAffliction(character, "eyedamage", 20) then
    HF.AddAfflictionLimb(character, "eyecataract", 11, 1)
  end
  if HF.HasAffliction(character, "eyecataract") then
    HF.AddAfflictionLimb(character, "eyecataract", 11, 0.4)
  end
  if HF.HasAffliction(character, "eyehusk") and HF.Chance(0.001) then
    HF.AddAffliction(character, "huskinfection", 1)
  end
  if HF.HasAffliction(character, "eyecataract", 50) then
    NTC.SetSymptomTrue(character, "sym_blurredvision", 2)
  end
  if GetItemInSlot(character, InvSlotType.Head) and GetItemInSlot(character, InvSlotType.Head).Prefab.identifier == "eyeglasses" then
    NTC.SetSymptomFalse(character, "sym_blurredvision", 2)
  end
  if character.AnimController.HeadInWater and not IsInDivingGear(character) and not HF.HasAffliction(character, "eyemonster") and not HF.HasAffliction(character, "eyehusk") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.34)
  elseif HF.HasAffliction(character, "eyedamage") and not HF.HasAffliction(character, "eyedamage", 45) or HF.HasAffliction(character, "eyedamage", 50) and not HF.HasAffliction(character, "eyedamage", 95) then
    HF.AddAfflictionLimb(character, "eyedamage", 11, -0.1)
    if HF.HasAffliction(character, "eyedrop") then
      HF.AddAfflictionLimb(character, "eyedamage", 11, -0.2)
    end
  end
  HF.AddAfflictionLimb(character, "eyedrop", 11, -0.8)
end

--ONDAMAGE TESTING, COMMENT THIS OUT BEFORE THE NEW LUA UPDATE RELEASES

Hook.Add("character.applyDamage", "eyeOnDamage", function (characterHealth, attackResult, hitLimb)
  local character = characterHealth.Character
  if not character.IsDead then
    for i, v in pairs(attackResult.Afflictions) do
      if hitLimb.type == LimbType.Head then
        --check damages for gunshot wounds
        --print(v.Strength)
        if v.Identifier == "gunshotwound" then
          --grazing hit
          if HF.Chance(0.01 * v.Strength) then
            HF.AddAfflictionLimb(character, "eyedamage", 11, HF.Clamp(v.Strength * 0.3, 0, 50))
          end
          --full hit in one of the eyes
          if HF.Chance(0.006 * v.Strength) then
            HF.AddAfflictionLimb(character, "eyedamage", 11, 50)
          end
          --check damages for lacerations
        elseif v.Identifier == "lacerations" then
          --blade scratched the eye
          if HF.Chance(v.Strength * 0.02) then
            HF.AddAfflictionLimb(character, "eyedamage", 11, HF.Clamp(v.Strength, 0,50))
          end
          --blade stabbed the eye completely
          if HF.Chance(0.008) then
            HF.AddAfflictionLimb(character, "eyedamage", 11, 50)
          end
          --check damages for bitewounds
        elseif v.Identifier == "bitewounds" then
          --bite scratched the eye
          if HF.Chance(v.Strength * 0.04) then
            HF.AddAfflictionLimb(character, "eyedamage", 11, HF.Clamp(v.Strength * 0.25, 0,50))
          end
          --bite bitten out the eye
          if HF.Chance(0.008) then
            HF.AddAfflictionLimb(character, "eyedamage", 11, 50)
          end
          --check for blunt trauma
        elseif v.Identifier == "blunttrauma" then
          --blunt graze
          if HF.Chance(v.Strength * 0.005) then
            HF.AddAfflictionLimb(character, "eyedamage", 11, HF.Clamp(v.Strength, 0,50))
          end
          --blunt hit the eye hard
          if HF.Chance(0.004) then
            HF.AddAfflictionLimb(character, "eyedamage", 11, 50)
          end
          --check for burns
        elseif v.Identifier == "burn" then
          --just burn damage, no HF.Chances or special hits
          HF.AddAfflictionLimb(character, "eyedamage", 11, v.Strength)
          --check for explosion damage
        elseif v.Identifier == "explosiondamage" then
          --just burn damage, no HF.Chances or special hits
          HF.AddAfflictionLimb(character, "eyedamage", 11, v.Strength * 2 * math.random())
        end
      end
    end
  end
end)
--end of ondamage testing

function GiveItemBasedOnEye(character, usingCharacter)
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
  else
    HF.GiveItemAtCondition(usingCharacter, "transplant_eyes", 100 - HF.GetAfflictionStrength(character, "eyedamage", 0))
  end
end

function ClearCharacterEyeAfflictions(character)
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
    "eyehusk"
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

Hook.Add("item.applyTreatment", "itemusedeye", function(item, usingCharacter, targetCharacter, limb)
  local identifier = item.Prefab.Identifier

  -- sadly no switches in lua
  limbtype = HF.NormalizeLimbType(limb.type)
  if not IsInDivingGear(targetCharacter) then
    if identifier=="organscalpel_eyes" and not HF.HasAffliction(targetCharacter, "noeye") and not HF.HasAffliction(targetCharacter, "th_amputation") then
      if HF.HasAffliction(targetCharacter, "analgesia") and HF.HasAffliction(targetCharacter, "eyelid") or HF.HasAffliction(targetCharacter, "sym_unconsciousness") and HF.HasAffliction(targetCharacter, "eyelid") then
        if HF.GetSurgerySkillRequirementMet(usingCharacter, 45) then
          GiveItemBasedOnEye(targetCharacter, usingCharacter)
          ClearCharacterEyeAfflictions(targetCharacter)
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
            GiveItemBasedOnEye(targetCharacter, usingCharacter)
            ClearCharacterEyeAfflictions(targetCharacter)
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
        ClearCharacterEyeAfflictions(targetCharacter)
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
        ClearCharacterEyeAfflictions(targetCharacter)
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
        ClearCharacterEyeAfflictions(targetCharacter)
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
        ClearCharacterEyeAfflictions(targetCharacter)
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
        ClearCharacterEyeAfflictions(targetCharacter)
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
        ClearCharacterEyeAfflictions(targetCharacter)
        HF.SetAfflictionLimb(targetCharacter, "eyesickness", 11, 100)
        HF.SetAfflictionLimb(targetCharacter, "eyemonster", 11, 2)
        HF.SetAfflictionLimb(targetCharacter, "eyedamage", 11, 100 - item.Condition)
        if HF.Chance(0.7*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1)) then
          HF.AddAfflictionLimb(targetCharacter, "eyeshock", 11, 1)
        end
        item.Condition = 0
      end
      if identifier =="transplant_eyes_husk" then
        --print("husk eyes")
        --print(0.6*HF.Clamp((1-(0.5*(HF.GetSurgerySkill(usingCharacter)/100))),0,1))
        ClearCharacterEyeAfflictions(targetCharacter)
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
