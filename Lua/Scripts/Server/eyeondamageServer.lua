Hook.Add("character.applyDamage", "eyeOnDamage", function (characterHealth, attackResult, hitLimb)

local character = characterHealth.Character

if -- invalid attack data or no eyes, don't do anything (from neurotrauma)
	characterHealth == nil or 
	characterHealth.Character == nil or 
	characterHealth.Character.IsDead or
	not characterHealth.Character.IsHuman or 
	attackResult == nil or 
	attackResult.Afflictions == nil or
	#attackResult.Afflictions <= 0 or
	hitLimb == nil or
	hitLimb.IsSevered or
	HF.HasAffliction(targetCharacter, "noeye") or
	HF.HasAffliction(targetCharacter, "eyesdead")
then return end


	for i, v in pairs(attackResult.Afflictions) do
		if hitLimb.type == LimbType.Head then
		
			--gunshot eye
			if v.Identifier == "gunshotwound" then
				
				--bullet hit both eyes (lmao)
				if HF.Chance(0.001 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(80, 95))
				end
				
				--bullet hit eye
				if HF.Chance(0.003 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(50, 60))
				end
				
				--bullet grazed eye
				if HF.Chance(0.01 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(1, 40))
				end
			
			
			--scratch eye
			elseif v.Identifier == "lacerations" then
				
				--blade hit both eyes (lmao x2)
				if HF.Chance(0.002 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(80,95))
				end
				
				--blade hit eye
				if HF.Chance(0.006 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(50, 60))
				end
				
				--blade grazed eye
				if HF.Chance(0.02 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(1, 40))
				end
		
			--bite eye (yummy)
			elseif v.Identifier == "bitewounds" then
				
				--bite bit both eyes (lmao x3)
				if HF.Chance(0.002 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(80,95))
				end
				
				--bite bit eye
				if HF.Chance(0.008 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(50, 60))
				end
				
				--bite grazed eye
				if HF.Chance(0.04 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(1, 40))
				end

			--blunttrauma eye
			elseif v.Identifier == "blunttrauma" then
				
				--object hit both eyes (lmao x4)
				if HF.Chance(0.001 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(80,95))
				end
				
				--object hit eye
				if HF.Chance(0.002 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(50, 60))
				end
				
				--object grazed eye
				if HF.Chance(0.01 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(1, 40))
				end

			--burn eyes (old code made sense, kept it)
			elseif v.Identifier == "burn" then
				HF.AddAfflictionLimb(character, "eyedamage", 11, v.Strength)


			--explode eyes (old code made sense, enhanced it)
			elseif v.Identifier == "explosiondamage" then
				HF.AddAfflictionLimb(character, "eyedamage", 11, v.Strength * math.random(1,10))
			print(v.Strength)
		
			end
		end
	end
end)