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